import '../models/map_data_model.dart';

class PathResult {
  final List<String> nodeIds;
  final String travelMode; // "ROAD", "BOAT", "DRONE"

  PathResult({required this.nodeIds, required this.travelMode});
}

class PathFinder {
  static PathResult findPath(
    String start,
    String end,
    List<MapNode> nodes,
    List<MapEdge> edges,
  ) {
    // --- STAGE 1: Try to find a Normal ROAD path ---
    List<String> roadPath = _dijkstra(
      start, 
      end, 
      nodes, 
      edges, 
      allowedTypes: ['road'], 
      allowFlooded: false
    );
    
    if (roadPath.isNotEmpty) {
      return PathResult(nodeIds: roadPath, travelMode: "ROAD");
    }

    // --- STAGE 2: Try to find a path that requires a BOAT (Roads or Rivers) ---
    // We allow 'river' and 'isFlooded' roads here.
    List<String> boatPath = _dijkstra(
      start, 
      end, 
      nodes, 
      edges, 
      allowedTypes: ['road', 'river'], 
      allowFlooded: true // Allows flooded roads
    );

    if (boatPath.isNotEmpty) {
      return PathResult(nodeIds: boatPath, travelMode: "BOAT");
    }

    // --- STAGE 3: NO VIABLE PATH FOUND ---
    // Return empty list which triggers the "DRONE" UI status
    return PathResult(nodeIds: [], travelMode: "DRONE");
  }

  /// Core Dijkstra implementation with strict filtering
  static List<String> _dijkstra(
    String start,
    String end,
    List<MapNode> nodes,
    List<MapEdge> edges, {
    required List<String> allowedTypes,
    required bool allowFlooded,
  }) {
    Map<String, List<MapEntry<String, MapEdge>>> adj = {
      for (var n in nodes) n.id: [],
    };

    for (var edge in edges) {
      // 1. Completely ignore collapsed roads in the search
      if (edge.isCollapsed) continue;

      // 2. Filter by allowed transport types (road/river)
      if (!allowedTypes.contains(edge.type)) continue;

      // 3. If we are in "Road only" mode, ignore flooded roads
      if (!allowFlooded && edge.isFlooded) continue;

      adj[edge.source]?.add(MapEntry(edge.target, edge));
      adj[edge.target]?.add(MapEntry(edge.source, edge));
    }

    Map<String, int> dist = {for (var n in nodes) n.id: 2147483647}; // Use Max Int
    Map<String, String?> prev = {for (var n in nodes) n.id: null};
    dist[start] = 0;

    List<String> pq = [start];

    while (pq.isNotEmpty) {
      pq.sort((a, b) => dist[a]!.compareTo(dist[b]!));
      String u = pq.removeAt(0);
      
      if (u == end) break;
      if (dist[u] == 2147483647) break; // Unreachable

      for (var entry in adj[u]!) {
        String v = entry.key;
        MapEdge edge = entry.value;

        // Weighting: Rivers/Flooded roads are "slower" (higher cost) than clear roads
        int weight = (edge.isFlooded || edge.type == 'river') 
            ? edge.baseWeight * 3 
            : edge.baseWeight;

        if (dist[u]! + weight < dist[v]!) {
          dist[v] = dist[u]! + weight;
          prev[v] = u;
          pq.add(v);
        }
      }
    }

    List<String> path = [];
    String? curr = end;
    
    // Check if the end node was actually reached
    if (dist[end] == 2147483647) return [];

    while (curr != null) {
      path.add(curr);
      curr = prev[curr];
    }
    
    return path.reversed.toList();
  }
}