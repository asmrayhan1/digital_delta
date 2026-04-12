class Edge {
  final String id;
  final String source;
  final String target;
  final int weight;
  final bool isFlooded;

  Edge({required this.id, required this.source, required this.target, required this.weight, required this.isFlooded});

  factory Edge.fromJson(Map<String, dynamic> json) => Edge(
    id: json['id'],
    source: json['source'],
    target: json['target'],
    weight: json['base_weight_mins'],
    isFlooded: json['is_flooded'],
  );
}