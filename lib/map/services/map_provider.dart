import 'dart:async';
import 'dart:convert';
import 'package:digital_delta/map/models/edge.dart';
import 'package:digital_delta/map/models/node.dart';
import 'package:digital_delta/map/models/path_finder.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MapProvider extends ChangeNotifier {
  List<Node> nodes = [];
  List<Edge> edges = [];
  List<String> currentPath = [];

  // These were missing! They store the IDs of the start and end nodes.
  String? selectedStart;
  String? selectedEnd;

  // Set the start node and trigger a path recalculation
  void setStart(String nodeId) {
    selectedStart = nodeId;
    _calculatePath();
    notifyListeners();
  }

  // Set the end node and trigger a path recalculation
  void setEnd(String nodeId) {
    selectedEnd = nodeId;
    _calculatePath();
    notifyListeners();
  }

  void _calculatePath() {
    if (selectedStart != null && selectedEnd != null) {
      currentPath = PathFinder.findShortestPath(
        selectedStart!, 
        selectedEnd!, 
        nodes, 
        edges
      );
    }
  }

  Future<void> fetchStatus() async {
    try {
      // Use 10.0.0.2 for Android Emulator or your local IP for physical devices
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/network/status'));
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        nodes = (data['nodes'] as List).map((n) => Node.fromJson(n)).toList();
        edges = (data['edges'] as List).map((e) => Edge.fromJson(e)).toList();
        
        // Update the path based on new flood data from the server
        _calculatePath();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Connection Error: $e");
    }
  }
}