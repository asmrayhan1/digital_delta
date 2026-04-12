import 'dart:io';
import 'dart:convert';
import 'package:digital_delta/mapupdated/models/map_data_model.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String _updateFileName = 'map_updates.json';

  Future<void> saveEdgeUpdates(List<MapEdge> edges) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_updateFileName');
      
      final String jsonContent = json.encode(
        edges.map((e) => e.toJson()).toList(),
      );
      await file.writeAsString(jsonContent);
    } catch (e) {
      print("Offline Storage Error: $e");
    }
  }

  Future<List<MapEdge>> loadEdgeUpdates() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_updateFileName');

      if (await file.exists()) {
        final String contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        return jsonData.map((e) => MapEdge.fromJson(e)).toList();
      }
    } catch (e) {
      print("No local updates found: $e");
    }
    return [];
  }
}