import 'dart:async';
import 'dart:convert';
import 'package:digital_delta/mapupdated/logic/decay_engine.dart';
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

  bool isMeshActive = false;
  String meshStatus = "Mesh Offline";

  // --- ML / rainfall simulation ---
  Timer? _decayTimer;

  final DecayEngine _decayEngine = DecayEngine();
  double _globalRainIntensity = 0.0;
  double get globalRainIntensity => _globalRainIntensity;
  set globalRainIntensity(double value) {
    _globalRainIntensity = value;
    _refreshMlPredictionsForAllEdges();
    notifyListeners();
  }

  /// Updates [MapEdge.mlFloodRisk] from the model for the current slider rain (no health mutation).
  void _refreshMlPredictionsForAllEdges() {
    if (edges.isEmpty) return;

    if (_globalRainIntensity <= 0.001) {
      for (final edge in edges) {
        edge.mlFloodRisk = 0.0;
        edge.currentRain = 0.0;
      }
      return;
    }

    for (final edge in edges) {
      edge.currentRain = _globalRainIntensity;
      final projectedCumulative =
          edge.cumulativeRain + _globalRainIntensity * 40.0;
      final projectedSat = (projectedCumulative / 100.0).clamp(0.0, 1.0);

      edge.mlFloodRisk = _decayEngine.predictRoadWorseningRisk(
        _globalRainIntensity,
        projectedCumulative,
        edge.elevation,
        projectedSat,
      );
    }
  }

  MapProvider() {
    _meshService = BluetoothMeshService(this);
  }

  Future<void> initializeMap(String assetJson) async {
    // 1. Load Base Assets
    final data = json.decode(assetJson);
    nodes = (data['nodes'] as List).map((n) => MapNode.fromJson(n)).toList();
    List<MapEdge> baseEdges = (data['edges'] as List)
        .map((e) => MapEdge.fromJson(e))
        .toList();

    // 2. Load Local Storage
    List<MapEdge> localUpdates = await _storage.loadEdgeUpdates();

    // 3. FIX: Strict Merge Logic
    // If we have a local update for an edge, and its timestamp is > 0, use it.
    edges = baseEdges.map((base) {
      final update = localUpdates.firstWhere(
        (u) => u.id == base.id,
        orElse: () => base,
      );
      // Since base.lastUpdated is now 0, local updates will always win.
      return update.lastUpdated >= base.lastUpdated ? update : base;
    }).toList();

    _calculatePath();
    notifyListeners();
  }

  // --- NEW METHOD: Start the ML Simulation Loop ---
  Future<void> startDecaySimulation() async {
    // Initialize TFLite model
    await _decayEngine.init();

    // Reset timer if it's already running
    _decayTimer?.cancel();

    // Runs every 5 seconds to simulate environmental decay
    _decayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (globalRainIntensity <= 0) return;

      bool persistMesh = false;

      for (var edge in edges) {
        edge.currentRain = globalRainIntensity;
        edge.cumulativeRain += globalRainIntensity * 5;
        edge.saturation = (edge.cumulativeRain / 100).clamp(0.0, 1.0);

        final risk = _decayEngine.predictRoadWorseningRisk(
          edge.currentRain,
          edge.cumulativeRain,
          edge.elevation,
          edge.saturation,
        );
        edge.mlFloodRisk = risk;

        final decayStep = risk * 0.08;
        edge.healthScore = (edge.healthScore - decayStep).clamp(0.0, 1.0);

        if (edge.healthScore < 0.3 && !edge.isFlooded) {
          edge.isFlooded = true;
          edge.lastUpdated = DateTime.now().millisecondsSinceEpoch;
          persistMesh = true;
        }
      }

      if (persistMesh) {
        _storage.saveEdgeUpdates(edges);
        _calculatePath();
      }
      notifyListeners();
    });
  }

  void updateEdgeCondition(String edgeId, String condition) {
    final index = edges.indexWhere((e) => e.id == edgeId);
    if (index != -1) {
      edges[index].isFlooded = (condition == "Flooded");
      edges[index].isCollapsed = (condition == "Collapsed");

      // FIX: Ensure high-precision timestamp
      edges[index].lastUpdated = DateTime.now().millisecondsSinceEpoch;

      _storage.saveEdgeUpdates(edges);
      _calculatePath();
      notifyListeners();
    }
  }

  void syncMeshUpdates(List<dynamic> incomingData) {
    bool hasChanged = false;
    for (var item in incomingData) {
      final incomingEdge = MapEdge.fromJson(item);
      final localIndex = edges.indexWhere((e) => e.id == incomingEdge.id);

      if (localIndex != -1) {
        // GOSSIP PROTOCOL: Only update if the peer's info is newer than ours
        if (incomingEdge.lastUpdated > edges[localIndex].lastUpdated) {
          edges[localIndex].isFlooded = incomingEdge.isFlooded;
          edges[localIndex].isCollapsed = incomingEdge.isCollapsed;
          edges[localIndex].lastUpdated = incomingEdge.lastUpdated;
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

  // ... (setPoints, _calculatePath, getNodeName stay the same)
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

  String getNodeName(String id) {
    return nodes
        .firstWhere(
          (n) => n.id == id,
          orElse: () => MapNode(id: id, name: id, lat: 0, lng: 0),
        )
        .name;
  }

  Future<void> toggleMesh() async {
    if (isMeshActive) {
      _meshService.stopMesh();
      isMeshActive = false;
      meshStatus = "Mesh Offline";
    } else {
      meshStatus = "Checking Hardware...";
      notifyListeners();
      if (await PermissionService.requestMeshPermissions()) {
        await _meshService.startMesh();
        isMeshActive = true;
        meshStatus = "Mesh Active: Broadcasting...";
      } else {
        meshStatus = "Permissions Denied";
      }
    }
    notifyListeners();
  }

  void notifyListenersManually() {
    notifyListeners();
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    _decayEngine.dispose();
    super.dispose();
  }
}
