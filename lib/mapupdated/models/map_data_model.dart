class MapNode {
  final String id;
  final String name;
  final double lat;
  final double lng;

  MapNode({required this.id, required this.name, required this.lat, required this.lng});

  factory MapNode.fromJson(Map<String, dynamic> json) => MapNode(
        id: json['id'],
        name: json['name'],
        lat: json['lat'],
        lng: json['lng'],
      );
}

class MapEdge {
  final String id;
  final String source;
  final String target;
  final String type;
  final int baseWeight;
  bool isFlooded;
  bool isCollapsed; // NEW: Added for the "Collapsed" state
  int lastUpdated;

  MapEdge({
    required this.id,
    required this.source,
    required this.target,
    required this.type,
    required this.baseWeight,
    required this.isFlooded,
    required this.isCollapsed, // NEW
    required this.lastUpdated,
  });

  factory MapEdge.fromJson(Map<String, dynamic> json) => MapEdge(
        id: json['id'],
        source: json['source'],
        target: json['target'],
        type: json['type'] ?? 'road',
        baseWeight: json['base_weight_mins'] ?? 0,
        isFlooded: json['is_flooded'] ?? false,
        isCollapsed: json['is_collapsed'] ?? false, // NEW
        lastUpdated: json['last_updated_ms'] ?? DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'target': target,
        'type': type,
        'base_weight_mins': baseWeight,
        'is_flooded': isFlooded,
        'is_collapsed': isCollapsed, // NEW
        'last_updated_ms': lastUpdated,
      };
}