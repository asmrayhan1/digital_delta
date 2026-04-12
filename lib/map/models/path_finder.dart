import 'package:digital_delta/map/models/edge.dart';
import 'package:digital_delta/map/models/node.dart';

class PathFinder {
  static List<String> findShortestPath(
    String startNode, 
    String endNode, 
    List<Node> allNodes, 
    List<Edge> allEdges
  ) {
    // 1. Create Adjacency List (Ignore flooded roads entirely for a "Safe" path)
    Map<String, List<MapEntry<String, int>>> adj = {};
    for (var node in allNodes) {
      adj[node.id] = [];
    }
    
    for (var edge in allEdges) {
      if (!edge.isFlooded) { // Filter: Only use roads that are not flooded
        adj[edge.source]?.add(MapEntry(edge.target, edge.weight));
        adj[edge.target]?.add(MapEntry(edge.source, edge.weight)); // Bi-directional
      }
    }

    // 2. Standard Dijkstra
    Map<String, int> distances = {for (var n in allNodes) n.id: 999999};
    Map<String, String?> previous = {for (var n in allNodes) n.id: null};
    distances[startNode] = 0;

    var pq = [startNode]; // Simple list as PQ for small maps

    while (pq.isNotEmpty) {
      pq.sort((a, b) => distances[a]!.compareTo(distances[b]!));
      var current = pq.removeAt(0);

      if (current == endNode) break;

      for (var neighbor in adj[current]!) {
        int alt = distances[current]! + neighbor.value;
        if (alt < distances[neighbor.key]!) {
          distances[neighbor.key] = alt;
          previous[neighbor.key] = current;
          pq.add(neighbor.key);
        }
      }
    }

    // 3. Reconstruct path
    List<String> path = [];
    String? curr = endNode;
    while (curr != null) {
      path.add(curr);
      curr = previous[curr];
    }
    return path.reversed.toList();
  }
}