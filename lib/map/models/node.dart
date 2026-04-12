class Node {
  final String id;
  final String name;
  final double lat;
  final double lng;

  Node({required this.id, required this.name, required this.lat, required this.lng});

  factory Node.fromJson(Map<String, dynamic> json) => Node(
    id: json['id'],
    name: json['name'],
    lat: json['lat'],
    lng: json['lng'],
  );
}