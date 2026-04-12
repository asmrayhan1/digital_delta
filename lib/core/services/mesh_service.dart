import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/db_helper.dart';
import '../../generated/mesh.pb.dart';
import 'vector_clock_service.dart';
import 'crdt_service.dart';
import 'encryption_service.dart';

/// Mesh Sync Manager — Complete Rewrite
///
/// Handles:
/// - Device discovery + advertising via nearby_connections (M2.4)
/// - CRDT sync with vector clocks (M2.1, M2.2)
/// - Store-and-forward message relay (M3.1)
/// - Dual-role node switching: CLIENT / RELAY (M3.2)
/// - E2E encrypted messaging (M3.3)
/// - Delta-sync only: transmit changed records since last vector clock
class MeshSyncManager {
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  static const String _serviceId = 'com.digitaldelta.mesh';
  static const int _defaultTtl = 5;

  final DbHelper _dbHelper = DbHelper();
  final String userId;
  final String deviceName;

  late VectorClockService _vcService;
  late CrdtService _crdtService;

  // Connected peers: endpointId → NodeInfo
  final Map<String, NodeInfo> _connectedPeers = {};

  // Seen message IDs for deduplication
  final Set<String> _seenMessageIds = {};

  // Current role
  String _currentRole = 'CLIENT';
  String get currentRole => _currentRole;

  // Streams for UI updates
  final _peerController = StreamController<Map<String, NodeInfo>>.broadcast();
  Stream<Map<String, NodeInfo>> get peerStream => _peerController.stream;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  final _conflictController = StreamController<List<CrdtConflict>>.broadcast();
  Stream<List<CrdtConflict>> get conflictStream => _conflictController.stream;

  final _roleController = StreamController<String>.broadcast();
  Stream<String> get roleStream => _roleController.stream;

  final _logController = StreamController<String>.broadcast();
  Stream<String> get logStream => _logController.stream;

  MeshSyncManager({required this.userId, required this.deviceName}) {
    _vcService = VectorClockService(nodeId: userId);
    _crdtService = CrdtService(nodeId: userId, vcService: _vcService);
  }

  CrdtService get crdtService => _crdtService;
  VectorClockService get vcService => _vcService;
  Map<String, NodeInfo> get connectedPeers => Map.unmodifiable(_connectedPeers);

  // ═══════════════════════════════════════════════════════════════
  // 1. ADVERTISING — So others can discover us
  // ═══════════════════════════════════════════════════════════════
  Future<void> startAdvertising() async {
    _log('Starting advertising as "$deviceName"...');
    try {
      await Nearby().startAdvertising(
        deviceName,
        _strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );
      _log('Advertising started.');
    } catch (e) {
      _log('Advertising error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. DISCOVERY — Find other devices
  // ═══════════════════════════════════════════════════════════════
  Future<void> startDiscovery() async {
    _log('Starting discovery...');
    try {
      await Nearby().startDiscovery(
        deviceName,
        _strategy,
        onEndpointFound: (endpointId, name, serviceId) {
          _log('Found peer: $name ($endpointId)');
          Nearby().requestConnection(
            deviceName,
            endpointId,
            onConnectionInitiated: _onConnectionInitiated,
            onConnectionResult: _onConnectionResult,
            onDisconnected: _onDisconnected,
          );
        },
        onEndpointLost: (endpointId) {
          _log('Lost peer: $endpointId');
        },
        serviceId: _serviceId,
      );
      _log('Discovery started.');
    } catch (e) {
      _log('Discovery error: $e');
    }
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) {
    _log('Connection initiated with ${info.endpointName} ($endpointId)');
    // Auto-accept all connections
    Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: (eid, payload) => _handlePayload(eid, payload),
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      _log('Connected to $endpointId');
      // Send our node info
      _sendNodeInfo(endpointId);
      // Initiate sync
      _initiateSync(endpointId);
      // Flush relay queue
      _flushRelayQueue(endpointId);
      // Evaluate role
      _evaluateRole();
    } else {
      _log('Connection to $endpointId failed: $status');
    }
  }

  void _onDisconnected(String endpointId) {
    _log('Disconnected from $endpointId');
    _connectedPeers.remove(endpointId);
    _peerController.add(Map.from(_connectedPeers));
    _evaluateRole();
  }

  Future<void> stopAll() async {
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    await Nearby().stopAllEndpoints();
    _connectedPeers.clear();
    _peerController.add({});
    _log('All connections stopped.');
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. SEND NODE INFO (M3.2)
  // ═══════════════════════════════════════════════════════════════
  Future<void> _sendNodeInfo(String endpointId) async {
    final pubKeyBytes = await EncryptionService.getPublicKeyBytes(userId);
    final nodeInfo = NodeInfo()
      ..nodeId = userId
      ..deviceName = deviceName
      ..role = _currentRole
      ..batteryLevel = 80 // TODO: read actual battery
      ..signalStrength = 100
      ..publicKey = pubKeyBytes ?? Uint8List(0);

    final envelope = MeshEnvelope()
      ..type = MeshEnvelope_PayloadType.NODE_INFO
      ..data = nodeInfo.writeToBuffer();

    await Nearby().sendBytesPayload(endpointId, envelope.writeToBuffer());
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. INITIATE LEDGER SYNC (M2.4 Delta Sync)
  // ═══════════════════════════════════════════════════════════════
  Future<void> _initiateSync(String endpointId) async {
    final db = await _dbHelper.db;
    final lastHash = await _getLastHashFromDb(db);

    final request = SyncRequest()..lastKnownHash = lastHash;

    final envelope = MeshEnvelope()
      ..type = MeshEnvelope_PayloadType.SYNC_REQUEST
      ..data = request.writeToBuffer();

    await Nearby().sendBytesPayload(endpointId, envelope.writeToBuffer());
    _log('Sync request sent to $endpointId (lastHash: ${lastHash.substring(0, 8)}...)');
  }

  // ═══════════════════════════════════════════════════════════════
  // 5. HANDLE ALL INCOMING PAYLOADS
  // ═══════════════════════════════════════════════════════════════
  Future<void> _handlePayload(String endpointId, Payload payload) async {
    if (payload.type != PayloadType.BYTES || payload.bytes == null) return;

    try {
      final envelope = MeshEnvelope.fromBuffer(payload.bytes!);

      switch (envelope.type) {
        case MeshEnvelope_PayloadType.SYNC_REQUEST:
          await _handleSyncRequest(endpointId, SyncRequest.fromBuffer(envelope.data));
          break;
        case MeshEnvelope_PayloadType.SYNC_RESPONSE:
          await _handleSyncResponse(SyncResponse.fromBuffer(envelope.data));
          break;
        case MeshEnvelope_PayloadType.MESH_MESSAGE:
          await _handleMeshMessage(endpointId, MeshMessage.fromBuffer(envelope.data));
          break;
        case MeshEnvelope_PayloadType.NODE_INFO:
          await _handleNodeInfo(endpointId, NodeInfo.fromBuffer(envelope.data));
          break;
        case MeshEnvelope_PayloadType.CRDT_SYNC_REQUEST:
          await _handleCrdtSyncRequest(endpointId, CrdtSyncRequest.fromBuffer(envelope.data));
          break;
        case MeshEnvelope_PayloadType.CRDT_SYNC_RESPONSE:
          await _handleCrdtSyncResponse(CrdtSyncResponse.fromBuffer(envelope.data));
          break;
        default:
          _log('Unknown payload type: ${envelope.type}');
      }
    } catch (e) {
      _log('Payload handling error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 6. SYNC REQUEST HANDLER — Send delta entries to peer
  // ═══════════════════════════════════════════════════════════════
  Future<void> _handleSyncRequest(String endpointId, SyncRequest request) async {
    _log('Sync request from $endpointId');
    final db = await _dbHelper.db;

    final List<Map<String, dynamic>> maps = await db.query(
      'ledger_entries',
      orderBy: 'timestamp ASC',
    );

    final response = SyncResponse();
    bool foundStart = (request.lastKnownHash == "GENESIS");

    for (var m in maps) {
      if (foundStart) {
        response.entries.add(LedgerEntry()
          ..id = m['id'] as String
          ..type = (m['type'] == 'MESSAGE') ? EntryType.MESSAGE : EntryType.POST
          ..payload = m['payload'] is List<int>
              ? Uint8List.fromList(m['payload'] as List<int>)
              : utf8.encode(m['payload'].toString())
          ..senderId = m['sender_id'] as String? ?? ''
          ..receiverId = m['receiver_id'] as String? ?? ''
          ..timestamp = fixnum.Int64(m['timestamp'] as int)
          ..prevHash = m['prev_hash'] as String? ?? ''
          ..currentHash = m['current_hash'] as String? ?? '');
      }
      if (m['current_hash'] == request.lastKnownHash) foundStart = true;
    }

    if (response.entries.isNotEmpty) {
      final envelope = MeshEnvelope()
        ..type = MeshEnvelope_PayloadType.SYNC_RESPONSE
        ..data = response.writeToBuffer();

      await Nearby().sendBytesPayload(endpointId, envelope.writeToBuffer());
      _log('Sent ${response.entries.length} delta entries to $endpointId');
    }

    // Also send CRDT sync
    final crdtRequest = CrdtSyncRequest()
      ..senderClock = (VectorClock()..clocks.addAll(
          _vcService.clock.map((k, v) => MapEntry(k, fixnum.Int64(v)))));

    final crdtEnvelope = MeshEnvelope()
      ..type = MeshEnvelope_PayloadType.CRDT_SYNC_REQUEST
      ..data = crdtRequest.writeToBuffer();

    await Nearby().sendBytesPayload(endpointId, crdtEnvelope.writeToBuffer());
  }

  // ═══════════════════════════════════════════════════════════════
  // 7. SYNC RESPONSE HANDLER — Receive and merge entries
  // ═══════════════════════════════════════════════════════════════
  Future<void> _handleSyncResponse(SyncResponse response) async {
    final db = await _dbHelper.db;
    int saved = 0;

    for (var entry in response.entries) {
      if (_verifyIntegrity(entry)) {
        await _saveToLocalDb(db, entry);
        saved++;
      }
    }

    _log('Merged $saved ledger entries from sync.');
  }

  // ═══════════════════════════════════════════════════════════════
  // 8. CRDT SYNC HANDLERS (M2.1 + M2.2)
  // ═══════════════════════════════════════════════════════════════
  Future<void> _handleCrdtSyncRequest(String endpointId, CrdtSyncRequest request) async {
    // Get entries newer than the remote's clock
    final remoteClock = request.senderClock.clocks
        .map((k, v) => MapEntry(k, v.toInt()));

    final entries = await _crdtService.getEntriesAfterClock(remoteClock);

    final response = CrdtSyncResponse();
    response.senderClock = VectorClock()..clocks.addAll(
        _vcService.clock.map((k, v) => MapEntry(k, fixnum.Int64(v))));

    for (final entry in entries) {
      final clock = Map<String, int>.from(
          (jsonDecode(entry['vector_clock'] as String) as Map)
              .map((k, v) => MapEntry(k.toString(), (v as num).toInt())));

      response.entries.add(CrdtEntry()
        ..id = entry['id'] as String
        ..fieldName = entry['field_name'] as String
        ..value = entry['value'] as String? ?? ''
        ..hlcTimestamp = fixnum.Int64(entry['hlc_timestamp'] as int)
        ..nodeId = entry['node_id'] as String
        ..vectorClock = (VectorClock()..clocks.addAll(
            clock.map((k, v) => MapEntry(k, fixnum.Int64(v))))));
    }

    final envelope = MeshEnvelope()
      ..type = MeshEnvelope_PayloadType.CRDT_SYNC_RESPONSE
      ..data = response.writeToBuffer();

    await Nearby().sendBytesPayload(endpointId, envelope.writeToBuffer());
    _log('Sent ${entries.length} CRDT entries to $endpointId');
  }

  Future<void> _handleCrdtSyncResponse(CrdtSyncResponse response) async {
    final remoteEntries = response.entries.map((e) => {
      'id': e.id,
      'field_name': e.fieldName,
      'value': e.value,
      'hlc_timestamp': e.hlcTimestamp.toInt(),
      'node_id': e.nodeId,
      'vector_clock': jsonEncode(
          e.vectorClock.clocks.map((k, v) => MapEntry(k, v.toInt()))),
    }).toList();

    final conflicts = await _crdtService.mergeRemoteEntries(remoteEntries);
    _log('CRDT sync: merged ${remoteEntries.length} entries, ${conflicts.length} conflicts.');

    if (conflicts.isNotEmpty) {
      _conflictController.add(conflicts);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 9. MESH MESSAGE — Store-and-Forward Relay (M3.1)
  // ═══════════════════════════════════════════════════════════════
  Future<void> sendMessage(String destinationId, String plaintext) async {
    final db = await _dbHelper.db;

    // Get recipient's public key from peers table
    final peerRows = await db.query(
      'peers',
      where: 'id = ?',
      whereArgs: [destinationId],
    );

    Uint8List? recipientPubKey;
    if (peerRows.isNotEmpty && peerRows.first['public_key'] != null) {
      final pkStr = peerRows.first['public_key'] as String;
      recipientPubKey = Uint8List.fromList(base64Decode(pkStr));
    }

    // Encrypt payload (E2E — M3.3)
    Uint8List encryptedPayload;
    if (recipientPubKey != null) {
      encryptedPayload = await EncryptionService.encryptForRecipient(
        plaintext, recipientPubKey, userId,
      );
    } else {
      // Fallback: plaintext if no key known (shouldn't happen in production)
      encryptedPayload = Uint8List.fromList(utf8.encode(plaintext));
    }

    final senderPubKey = await EncryptionService.getPublicKeyBytes(userId);
    final messageId = const Uuid().v4();

    final meshMsg = MeshMessage()
      ..messageId = messageId
      ..sourceId = userId
      ..destinationId = destinationId
      ..encryptedPayload = encryptedPayload
      ..ttl = _defaultTtl
      ..createdAt = fixnum.Int64(DateTime.now().millisecondsSinceEpoch)
      ..senderPublicKey = senderPubKey ?? Uint8List(0);

    // Save to our own DB
    await db.insert('mesh_messages', {
      'message_id': messageId,
      'source_id': userId,
      'destination_id': destinationId,
      'encrypted_payload': encryptedPayload,
      'ttl': _defaultTtl,
      'hop_list': '',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'delivered': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Also add to ledger
    await _addToLedger('MESSAGE', {'text': plaintext}, receiverId: destinationId);

    // Wrap and broadcast
    final envelope = MeshEnvelope()
      ..type = MeshEnvelope_PayloadType.MESH_MESSAGE
      ..data = meshMsg.writeToBuffer();

    _seenMessageIds.add(messageId);
    await _broadcastToAllPeers(envelope, exclude: null);
    _log('Sent message $messageId → $destinationId via ${_connectedPeers.length} peers');
  }

  Future<void> _handleMeshMessage(String fromEndpoint, MeshMessage msg) async {
    // Deduplication (M3.1)
    if (_seenMessageIds.contains(msg.messageId)) {
      _log('Duplicate message ${msg.messageId} — dropped.');
      return;
    }
    _seenMessageIds.add(msg.messageId);

    final db = await _dbHelper.db;

    if (msg.destinationId == userId) {
      // ═══ This message is FOR US ═══
      _log('Received message ${msg.messageId} from ${msg.sourceId}');

      // Try to decrypt (M3.3)
      String content;
      try {
        content = await EncryptionService.decryptWithPrivateKey(
          Uint8List.fromList(msg.encryptedPayload),
          Uint8List.fromList(msg.senderPublicKey),
          userId,
        );
      } catch (_) {
        // Fallback: try plaintext
        content = utf8.decode(msg.encryptedPayload, allowMalformed: true);
      }

      // Save message
      await db.insert('mesh_messages', {
        'message_id': msg.messageId,
        'source_id': msg.sourceId,
        'destination_id': msg.destinationId,
        'encrypted_payload': Uint8List.fromList(msg.encryptedPayload),
        'ttl': msg.ttl,
        'hop_list': msg.hopList.join(','),
        'created_at': msg.createdAt.toInt(),
        'delivered': 1,
        'received_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Save to messages table for UI
      await db.insert('messages', {
        'id': msg.messageId,
        'sender_id': msg.sourceId,
        'receiver_id': msg.destinationId,
        'content': content,
        'timestamp': msg.createdAt.toInt(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Notify UI
      _messageController.add({
        'message_id': msg.messageId,
        'source_id': msg.sourceId,
        'content': content,
        'timestamp': msg.createdAt.toInt(),
      });

    } else {
      // ═══ RELAY MODE — Forward the message (M3.1) ═══
      if (msg.ttl <= 0) {
        _log('Message ${msg.messageId} TTL expired — dropped.');
        return;
      }

      _log('Relaying message ${msg.messageId} → ${msg.destinationId} (TTL: ${msg.ttl - 1})');

      // Decrement TTL and add ourselves to hop list
      final relayedMsg = MeshMessage()
        ..messageId = msg.messageId
        ..sourceId = msg.sourceId
        ..destinationId = msg.destinationId
        ..encryptedPayload = msg.encryptedPayload
        ..ttl = msg.ttl - 1
        ..createdAt = msg.createdAt
        ..senderPublicKey = msg.senderPublicKey;
      relayedMsg.hopList.addAll(msg.hopList);
      relayedMsg.hopList.add(userId);

      final envelope = MeshEnvelope()
        ..type = MeshEnvelope_PayloadType.MESH_MESSAGE
        ..data = relayedMsg.writeToBuffer();

      // Store in relay queue (survives offline — M3.1)
      await db.insert('relay_queue', {
        'message_id': msg.messageId,
        'envelope_bytes': envelope.writeToBuffer(),
        'destination_id': msg.destinationId,
        'ttl': msg.ttl - 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'forwarded': 0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Forward to all connected peers except the one who sent it to us
      await _broadcastToAllPeers(envelope, exclude: fromEndpoint);

      // Mark as forwarded
      await db.update(
        'relay_queue',
        {'forwarded': 1},
        where: 'message_id = ?',
        whereArgs: [msg.messageId],
      );

      // Log relay event
      await _logMeshEvent('MESSAGE_RELAYED',
          'Relayed ${msg.messageId} toward ${msg.destinationId}');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 10. FLUSH RELAY QUEUE — Resume after coming back online (M3.1)
  // ═══════════════════════════════════════════════════════════════
  Future<void> _flushRelayQueue(String endpointId) async {
    final db = await _dbHelper.db;
    final pending = await db.query(
      'relay_queue',
      where: 'forwarded = 0',
    );

    for (final row in pending) {
      final bytes = row['envelope_bytes'] as List<int>;
      await Nearby().sendBytesPayload(endpointId, Uint8List.fromList(bytes));
      await db.update(
        'relay_queue',
        {'forwarded': 1},
        where: 'message_id = ?',
        whereArgs: [row['message_id']],
      );
    }

    if (pending.isNotEmpty) {
      _log('Flushed ${pending.length} queued relay messages to $endpointId');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 11. NODE INFO HANDLER (M3.2)
  // ═══════════════════════════════════════════════════════════════
  Future<void> _handleNodeInfo(String endpointId, NodeInfo info) async {
    _connectedPeers[endpointId] = info;
    _peerController.add(Map.from(_connectedPeers));

    // Save peer info and public key
    final db = await _dbHelper.db;
    await db.insert('peers', {
      'id': info.nodeId,
      'device_name': info.deviceName,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
      'public_key': base64Encode(info.publicKey),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    _log('Peer info: ${info.deviceName} (${info.role}), battery: ${info.batteryLevel}%');
    _evaluateRole();
  }

  // ═══════════════════════════════════════════════════════════════
  // 12. DUAL-ROLE NODE SWITCHING (M3.2)
  // ═══════════════════════════════════════════════════════════════
  void _evaluateRole() {
    final peerCount = _connectedPeers.length;
    // Heuristic: If we have 2+ connections, become a RELAY
    // In production, also factor in battery level and signal strength
    final newRole = peerCount >= 2 ? 'RELAY' : 'CLIENT';

    if (newRole != _currentRole) {
      _currentRole = newRole;
      _roleController.add(_currentRole);
      _logMeshEvent('ROLE_SWITCH', 'Switched to $newRole (peers: $peerCount)');
      _log('Role switched to $newRole');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════
  Future<void> _broadcastToAllPeers(MeshEnvelope envelope, {String? exclude}) async {
    final envelopeBytes = envelope.writeToBuffer();
    for (final endpointId in _connectedPeers.keys) {
      if (endpointId != exclude) {
        try {
          await Nearby().sendBytesPayload(endpointId, envelopeBytes);
        } catch (e) {
          _log('Failed to send to $endpointId: $e');
        }
      }
    }
  }

  Future<void> _saveToLocalDb(Database db, LedgerEntry entry) async {
    await db.insert(
      'ledger_entries',
      {
        'id': entry.id,
        'type': entry.type == EntryType.MESSAGE ? 'MESSAGE' : 'POST',
        'payload': entry.payload,
        'sender_id': entry.senderId,
        'receiver_id': entry.receiverId,
        'timestamp': entry.timestamp.toInt(),
        'prev_hash': entry.prevHash,
        'current_hash': entry.currentHash,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  bool _verifyIntegrity(LedgerEntry entry) {
    var bytes = utf8.encode(
      "${entry.id}${entry.type}${entry.payload}${entry.timestamp}${entry.prevHash}",
    );
    var hash = sha256.convert(bytes).toString();
    return hash == entry.currentHash;
  }

  Future<String> _getLastHashFromDb(Database db) async {
    final List<Map<String, dynamic>> res = await db.query(
      'ledger_entries',
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    return res.isEmpty ? "GENESIS" : res.first['current_hash'] as String;
  }

  Future<void> _addToLedger(String type, Map<String, dynamic> payload,
      {String? receiverId}) async {
    final db = await _dbHelper.db;
    final String id = const Uuid().v4();
    final int ts = DateTime.now().millisecondsSinceEpoch;
    final String payloadStr = jsonEncode(payload);

    List<Map> lastEntry = await db.query(
        'ledger_entries', orderBy: 'timestamp DESC', limit: 1);
    String prevHash = lastEntry.isEmpty
        ? "GENESIS_BLOCK"
        : lastEntry.first['current_hash'] as String;

    String currentHash = sha256
        .convert(utf8.encode("$id$type$payloadStr$ts$prevHash"))
        .toString();

    await db.insert('ledger_entries', {
      'id': id,
      'type': type,
      'payload': utf8.encode(payloadStr),
      'sender_id': userId,
      'receiver_id': receiverId,
      'timestamp': ts,
      'prev_hash': prevHash,
      'current_hash': currentHash,
    });
  }

  Future<void> _logMeshEvent(String eventType, String description) async {
    try {
      final db = await _dbHelper.db;
      await db.insert('mesh_events_log', {
        'event_type': eventType,
        'description': description,
        'node_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  void _log(String message) {
    debugPrint('[MeshSync] $message');
    _logController.add(message);
  }

  /// Get all messages for display
  Future<List<Map<String, dynamic>>> getMessages() async {
    final db = await _dbHelper.db;
    return db.query('messages', orderBy: 'timestamp ASC');
  }

  /// Get mesh event logs
  Future<List<Map<String, dynamic>>> getMeshEvents() async {
    final db = await _dbHelper.db;
    return db.query('mesh_events_log', orderBy: 'timestamp DESC', limit: 50);
  }

  void dispose() {
    _peerController.close();
    _messageController.close();
    _conflictController.close();
    _roleController.close();
    _logController.close();
  }
}
