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
  bool isCollapsed;
  int lastUpdated;

  final double elevation; // In meters
  double currentRain = 0.0;
  double cumulativeRain = 0.0;
  double saturation = 0.0;
  double healthScore = 1.0;

  /// 0–1 from TFLite (or heuristic): likelihood road condition worsens for current rain.
  double mlFloodRisk = 0.0;

  MapEdge({
    required this.id,
    required this.source,
    required this.target,
    required this.type,
    required this.baseWeight,
    required this.isFlooded,
    required this.isCollapsed,
    required this.lastUpdated,
    this.elevation = 5.0,
  });

  factory MapEdge.fromJson(Map<String, dynamic> json) => MapEdge(
        id: json['id'],
        source: json['source'],
        target: json['target'],
        type: json['type'] ?? 'road',
        baseWeight: json['base_weight_mins'] ?? 0,
        isFlooded: json['is_flooded'] ?? false,
        isCollapsed: json['is_collapsed'] ?? false,
        // FIX: Default to 0 if not present, so local/mesh updates (with real timestamps) always win
        lastUpdated: json['last_updated_ms'] ?? 0,
        elevation: (json['elevation'] ?? 5.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'target': target,
        'type': type,
        'base_weight_mins': baseWeight,
        'is_flooded': isFlooded,
        'is_collapsed': isCollapsed,
        'last_updated_ms': lastUpdated,
      };
}