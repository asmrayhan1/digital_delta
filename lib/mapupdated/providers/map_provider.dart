import 'dart:convert';
import 'package:digital_delta/mapupdated/models/map_data_model.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../logic/path_finder.dart';

class MapProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<MapNode> nodes = [];
  List<MapEdge> edges = [];
  PathResult? currentPathResult;

  String? selectedStart;
  String? selectedEnd;

  Future<void> initializeMap(String assetJson) async {
    final data = json.decode(assetJson);
    nodes = (data['nodes'] as List).map((n) => MapNode.fromJson(n)).toList();
    List<MapEdge> baseEdges = (data['edges'] as List)
        .map((e) => MapEdge.fromJson(e))
        .toList();

    List<MapEdge> localUpdates = await _storage.loadEdgeUpdates();

    edges = baseEdges.map((base) {
      final update = localUpdates.firstWhere(
        (u) => u.id == base.id,
        orElse: () => base,
      );
      return update.lastUpdated >= base.lastUpdated ? update : base;
    }).toList();

    notifyListeners();
  }

  void toggleFloodStatus(String edgeId) {
    final index = edges.indexWhere((e) => e.id == edgeId);
    if (index != -1) {
      edges[index].isFlooded = !edges[index].isFlooded;
      edges[index].lastUpdated = DateTime.now().millisecondsSinceEpoch;
      _storage.saveEdgeUpdates(edges);
      _calculatePath();
      notifyListeners();
    }
  }

  // Update ONLY the update method inside your existing MapProvider class
  void updateEdgeCondition(String edgeId, String condition) {
  final index = edges.indexWhere((e) => e.id == edgeId);
  if (index != -1) {
    // Reset all and set the specific one
    edges[index].isFlooded = (condition == "Flooded");
    edges[index].isCollapsed = (condition == "Collapsed");
    edges[index].lastUpdated = DateTime.now().millisecondsSinceEpoch;
    
    _storage.saveEdgeUpdates(edges);
    _calculatePath();
    notifyListeners();
  }
}

  // Helper to get Node Name by ID for the UI
  String getNodeName(String id) {
    return nodes
        .firstWhere(
          (n) => n.id == id,
          orElse: () => MapNode(id: id, name: id, lat: 0, lng: 0),
        )
        .name;
  }

  void setPoints(String? start, String? end) {
    selectedStart = start;
    selectedEnd = end;
    _calculatePath();
    notifyListeners();
  }

  void _calculatePath() {
    if (selectedStart != null && selectedEnd != null) {
      currentPathResult = PathFinder.findPath(
        selectedStart!,
        selectedEnd!,
        nodes,
        edges,
      );
    }
  }
}
