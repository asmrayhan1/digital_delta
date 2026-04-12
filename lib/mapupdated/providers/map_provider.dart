import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/map_data_model.dart';
import '../services/storage_service.dart';
import '../logic/path_finder.dart';
import '../services/bluetooth_mesh_service.dart';
import '../services/permission_service.dart';

class MapProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  late final BluetoothMeshService _meshService;
  
  List<MapNode> nodes = [];
  List<MapEdge> edges = [];
  PathResult? currentPathResult;
  
  String? selectedStart;
  String? selectedEnd;

  // Mesh State
  bool isMeshActive = false;
  String meshStatus = "Mesh Offline";

  MapProvider() {
    _meshService = BluetoothMeshService(this);
  }

  Future<void> initializeMap(String assetJson) async {
    final data = json.decode(assetJson);
    nodes = (data['nodes'] as List).map((n) => MapNode.fromJson(n)).toList();
    List<MapEdge> baseEdges = (data['edges'] as List).map((e) => MapEdge.fromJson(e)).toList();

    List<MapEdge> localUpdates = await _storage.loadEdgeUpdates();

    edges = baseEdges.map((base) {
      final update = localUpdates.firstWhere((u) => u.id == base.id, orElse: () => base);
      return update.lastUpdated >= base.lastUpdated ? update : base;
    }).toList();

    notifyListeners();
  }

  // Mesh Toggle Logic
  Future<void> toggleMesh() async {
    if (isMeshActive) {
      _meshService.stopMesh();
      isMeshActive = false;
      meshStatus = "Mesh Offline";
    } else {
      meshStatus = "Requesting Permissions...";
      notifyListeners();

      bool granted = await PermissionService.requestMeshPermissions();
      if (granted) {
        meshStatus = "Mesh Active: Searching for Peers...";
        await _meshService.startMesh();
        isMeshActive = true;
      } else {
        meshStatus = "Permissions Denied";
        isMeshActive = false;
      }
    }
    notifyListeners();
  }

  void updateEdgeCondition(String edgeId, String condition) {
    final index = edges.indexWhere((e) => e.id == edgeId);
    if (index != -1) {
      edges[index].isFlooded = (condition == "Flooded");
      edges[index].isCollapsed = (condition == "Collapsed");
      edges[index].lastUpdated = DateTime.now().millisecondsSinceEpoch;
      
      _storage.saveEdgeUpdates(edges);
      _calculatePath();
      notifyListeners();
      
      // If mesh is active, the update will be shared automatically 
      // when nodes handshake, or you can trigger a broadcast here.
    }
  }

  void syncMeshUpdates(List<MapEdge> incomingEdges) {
    bool hasChanged = false;
    for (var incoming in incomingEdges) {
      final localIndex = edges.indexWhere((e) => e.id == incoming.id);
      if (localIndex != -1) {
        if (incoming.lastUpdated > edges[localIndex].lastUpdated) {
          edges[localIndex].isFlooded = incoming.isFlooded;
          edges[localIndex].isCollapsed = incoming.isCollapsed;
          edges[localIndex].lastUpdated = incoming.lastUpdated;
          hasChanged = true;
        }
      }
    }

    if (hasChanged) {
      _storage.saveEdgeUpdates(edges);
      _calculatePath();
      notifyListeners();
    }
  }

  void setPoints(String? start, String? end) {
    selectedStart = start;
    selectedEnd = end;
    _calculatePath();
    notifyListeners();
  }

  void _calculatePath() {
    if (selectedStart != null && selectedEnd != null) {
      currentPathResult = PathFinder.findPath(selectedStart!, selectedEnd!, nodes, edges);
    }
  }

  String getNodeName(String id) {
    return nodes.firstWhere((n) => n.id == id, orElse: () => MapNode(id: id, name: id, lat: 0, lng: 0)).name;
  }
}