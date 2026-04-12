import 'dart:convert';

/// Dart model for CRDT entries stored in SQLite
class CrdtEntryModel {
  final String id;
  final String fieldName;
  final String value;
  final int hlcTimestamp;
  final String nodeId;
  final Map<String, int> vectorClock;
  final bool isConflict;
  final bool resolved;

  CrdtEntryModel({
    required this.id,
    required this.fieldName,
    required this.value,
    required this.hlcTimestamp,
    required this.nodeId,
    required this.vectorClock,
    this.isConflict = false,
    this.resolved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'field_name': fieldName,
      'value': value,
      'hlc_timestamp': hlcTimestamp,
      'node_id': nodeId,
      'vector_clock': jsonEncode(vectorClock),
      'is_conflict': isConflict ? 1 : 0,
      'resolved': resolved ? 1 : 0,
    };
  }

  factory CrdtEntryModel.fromMap(Map<String, dynamic> map) {
    return CrdtEntryModel(
      id: map['id'] as String,
      fieldName: map['field_name'] as String,
      value: map['value'] as String? ?? '',
      hlcTimestamp: map['hlc_timestamp'] as int,
      nodeId: map['node_id'] as String,
      vectorClock: Map<String, int>.from(
        (jsonDecode(map['vector_clock'] as String? ?? '{}') as Map)
            .map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
      ),
      isConflict: (map['is_conflict'] as int?) == 1,
      resolved: (map['resolved'] as int?) == 1,
    );
  }
}
