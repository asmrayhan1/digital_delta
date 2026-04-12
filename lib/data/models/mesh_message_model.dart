/// Dart model for mesh messages stored in SQLite
class MeshMessageModel {
  final String messageId;
  final String sourceId;
  final String destinationId;
  final List<int>? encryptedPayload;
  final int ttl;
  final List<String> hopList;
  final int createdAt;
  final bool delivered;
  final int? receivedAt;

  MeshMessageModel({
    required this.messageId,
    required this.sourceId,
    required this.destinationId,
    this.encryptedPayload,
    this.ttl = 5,
    this.hopList = const [],
    required this.createdAt,
    this.delivered = false,
    this.receivedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'source_id': sourceId,
      'destination_id': destinationId,
      'encrypted_payload': encryptedPayload,
      'ttl': ttl,
      'hop_list': hopList.join(','),
      'created_at': createdAt,
      'delivered': delivered ? 1 : 0,
      'received_at': receivedAt,
    };
  }

  factory MeshMessageModel.fromMap(Map<String, dynamic> map) {
    return MeshMessageModel(
      messageId: map['message_id'] as String,
      sourceId: map['source_id'] as String,
      destinationId: map['destination_id'] as String,
      encryptedPayload: map['encrypted_payload'] as List<int>?,
      ttl: map['ttl'] as int? ?? 5,
      hopList: (map['hop_list'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      createdAt: map['created_at'] as int,
      delivered: (map['delivered'] as int?) == 1,
      receivedAt: map['received_at'] as int?,
    );
  }
}
