import 'dart:convert';
import 'package:digital_delta/core/services/vector_clock_service.dart';
import 'package:digital_delta/data/local/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// CRDT Service — LWW-Register Implementation (M2.1)
///
/// Each inventory field (e.g. "water_bottles", "bandages") is an LWW-Register.
/// Concurrent conflicting updates are detected via vector clocks and surfaced
/// in the conflict resolution UI.
class CrdtService {
  final VectorClockService _vcService;
  final DbHelper _dbHelper = DbHelper();
  final String nodeId;

  CrdtService({required this.nodeId, required VectorClockService vcService})
      : _vcService = vcService;

  /// Update (or create) a CRDT field with a new value
  Future<Map<String, dynamic>> updateField(String fieldName, String value) async {
    // Increment vector clock before mutation
    final clock = _vcService.increment();
    final hlcTimestamp = DateTime.now().microsecondsSinceEpoch;
    final id = const Uuid().v4();

    final db = await _dbHelper.db;
    await db.insert('crdt_entries', {
      'id': id,
      'field_name': fieldName,
      'value': value,
      'hlc_timestamp': hlcTimestamp,
      'node_id': nodeId,
      'vector_clock': jsonEncode(clock),
      'is_conflict': 0,
      'resolved': 0,
    });

    return {
      'id': id,
      'field_name': fieldName,
      'value': value,
      'hlc_timestamp': hlcTimestamp,
      'node_id': nodeId,
      'vector_clock': clock,
    };
  }

  /// Get the latest value for a field (LWW winner)
  Future<Map<String, dynamic>?> getField(String fieldName) async {
    final db = await _dbHelper.db;
    final results = await db.query(
      'crdt_entries',
      where: 'field_name = ? AND resolved = 0',
      whereArgs: [fieldName],
      orderBy: 'hlc_timestamp DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get all current field values (latest per field)
  Future<List<Map<String, dynamic>>> getAllFields() async {
    final db = await _dbHelper.db;
    // Get latest entry per field_name
    final results = await db.rawQuery('''
      SELECT * FROM crdt_entries c1
      WHERE hlc_timestamp = (
        SELECT MAX(hlc_timestamp) FROM crdt_entries c2
        WHERE c2.field_name = c1.field_name
      )
      ORDER BY field_name
    ''');
    return results;
  }

  /// Merge remote CRDT entries with local state (M2.1)
  /// Returns list of conflicts detected
  Future<List<CrdtConflict>> mergeRemoteEntries(
      List<Map<String, dynamic>> remoteEntries) async {
    final db = await _dbHelper.db;
    final conflicts = <CrdtConflict>[];

    for (final remote in remoteEntries) {
      final fieldName = remote['field_name'] as String;
      final remoteTimestamp = remote['hlc_timestamp'] as int;
      final remoteNodeId = remote['node_id'] as String;
      final remoteClock = (remote['vector_clock'] is String)
          ? Map<String, int>.from(
              (jsonDecode(remote['vector_clock']) as Map).map(
                  (k, v) => MapEntry(k.toString(), (v as num).toInt())))
          : remote['vector_clock'] as Map<String, int>;

      // Find our latest local entry for this field
      final localEntries = await db.query(
        'crdt_entries',
        where: 'field_name = ?',
        whereArgs: [fieldName],
        orderBy: 'hlc_timestamp DESC',
        limit: 1,
      );

      if (localEntries.isEmpty) {
        // No local entry — just accept the remote
        await db.insert('crdt_entries', {
          'id': remote['id'],
          'field_name': fieldName,
          'value': remote['value'],
          'hlc_timestamp': remoteTimestamp,
          'node_id': remoteNodeId,
          'vector_clock': jsonEncode(remoteClock),
          'is_conflict': 0,
          'resolved': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        continue;
      }

      final local = localEntries.first;
      final localClock = Map<String, int>.from(
          (jsonDecode(local['vector_clock'] as String) as Map)
              .map((k, v) => MapEntry(k.toString(), (v as num).toInt())));

      // Check causality using vector clocks
      if (VectorClockService.isAfter(remoteClock, localClock)) {
        // Remote is strictly newer — accept it
        await db.insert('crdt_entries', {
          'id': remote['id'],
          'field_name': fieldName,
          'value': remote['value'],
          'hlc_timestamp': remoteTimestamp,
          'node_id': remoteNodeId,
          'vector_clock': jsonEncode(remoteClock),
          'is_conflict': 0,
          'resolved': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      } else if (VectorClockService.isConcurrent(localClock, remoteClock)) {
        // CONCURRENT WRITES — CONFLICT DETECTED (M2.3)
        // Use LWW (higher timestamp wins), but flag as conflict for UI
        await db.insert('crdt_entries', {
          'id': remote['id'],
          'field_name': fieldName,
          'value': remote['value'],
          'hlc_timestamp': remoteTimestamp,
          'node_id': remoteNodeId,
          'vector_clock': jsonEncode(remoteClock),
          'is_conflict': 1,
          'resolved': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        // Mark local as conflict too
        await db.update(
          'crdt_entries',
          {'is_conflict': 1},
          where: 'id = ?',
          whereArgs: [local['id']],
        );

        conflicts.add(CrdtConflict(
          fieldName: fieldName,
          localValue: local['value'] as String,
          localTimestamp: local['hlc_timestamp'] as int,
          localNodeId: local['node_id'] as String,
          remoteValue: remote['value'] as String,
          remoteTimestamp: remoteTimestamp,
          remoteNodeId: remoteNodeId,
        ));
      }
      // If local is strictly newer, ignore remote (already up to date)
    }

    // Merge vector clocks
    _vcService.merge(remoteEntries.isNotEmpty
        ? Map<String, int>.from(
            (jsonDecode(remoteEntries.last['vector_clock'] as String) as Map)
                .map((k, v) => MapEntry(k.toString(), (v as num).toInt())))
        : {});

    return conflicts;
  }

  /// Get all unresolved conflicts (M2.3)
  Future<List<Map<String, dynamic>>> getUnresolvedConflicts() async {
    final db = await _dbHelper.db;
    return db.query(
      'crdt_entries',
      where: 'is_conflict = 1 AND resolved = 0',
      orderBy: 'field_name, hlc_timestamp DESC',
    );
  }

  /// Resolve a conflict by choosing a value (M2.3)
  Future<void> resolveConflict(
      String fieldName, String chosenValue, String chosenNodeId) async {
    final db = await _dbHelper.db;

    // Mark all entries for this field as resolved
    await db.update(
      'crdt_entries',
      {'resolved': 1},
      where: 'field_name = ? AND is_conflict = 1',
      whereArgs: [fieldName],
    );

    // Create a new definitive entry
    final clock = _vcService.increment();
    final id = const Uuid().v4();
    await db.insert('crdt_entries', {
      'id': id,
      'field_name': fieldName,
      'value': chosenValue,
      'hlc_timestamp': DateTime.now().microsecondsSinceEpoch,
      'node_id': nodeId,
      'vector_clock': jsonEncode(clock),
      'is_conflict': 0,
      'resolved': 0,
    });

    // Log the resolution decision
    await db.insert('mesh_events_log', {
      'event_type': 'CONFLICT_RESOLVED',
      'description': 'Field "$fieldName" conflict resolved. Chose value from $chosenNodeId: "$chosenValue"',
      'node_id': nodeId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'metadata': jsonEncode({
        'field': fieldName,
        'chosen_value': chosenValue,
        'chosen_node': chosenNodeId,
      }),
    });
  }

  /// Get entries that are newer than a given vector clock (for delta sync)
  Future<List<Map<String, dynamic>>> getEntriesAfterClock(
      Map<String, int> remoteClock) async {
    final db = await _dbHelper.db;
    final allEntries = await db.query(
      'crdt_entries',
      where: 'resolved = 0',
      orderBy: 'hlc_timestamp ASC',
    );

    // Filter: return entries whose vector clock is not dominated by remoteClock
    return allEntries.where((entry) {
      final entryClock = Map<String, int>.from(
          (jsonDecode(entry['vector_clock'] as String) as Map)
              .map((k, v) => MapEntry(k.toString(), (v as num).toInt())));
      return !VectorClockService.isAfter(remoteClock, entryClock);
    }).toList();
  }
}

/// Represents a detected CRDT conflict on a field (M2.3)
class CrdtConflict {
  final String fieldName;
  final String localValue;
  final int localTimestamp;
  final String localNodeId;
  final String remoteValue;
  final int remoteTimestamp;
  final String remoteNodeId;

  CrdtConflict({
    required this.fieldName,
    required this.localValue,
    required this.localTimestamp,
    required this.localNodeId,
    required this.remoteValue,
    required this.remoteTimestamp,
    required this.remoteNodeId,
  });
}
