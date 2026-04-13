import 'dart:convert';
import 'dart:typed_data';
import 'package:digital_delta/mapupdated/services/permission_service.dart';
import 'package:location/location.dart' as loc;
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/map_data_model.dart';
import '../providers/map_provider.dart';

class BluetoothMeshService {
  final MapProvider provider;
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final String serviceId =
      "com.digital_delta.sylhet_mesh"; // Ensure this is unique

  BluetoothMeshService(this.provider);

  Future<void> startMesh() async {
    String userName = "Responder_${DateTime.now().millisecond}";

    // 1. Ensure permissions are granted first
  bool hasPermissions = await PermissionService.requestMeshPermissions();
  if (!hasPermissions) {
    print("Mesh cannot start: Permissions denied.");
    return;
  }

  // 2. Check and Enable Location Service (GPS)
  loc.Location location = loc.Location();
  bool isLocationServiceEnabled = await location.serviceEnabled();
  if (!isLocationServiceEnabled) {
    isLocationServiceEnabled = await location.requestService();
    if (!isLocationServiceEnabled) return; // User refused to turn on GPS
  }

  // 3. Check Bluetooth Service
  // Note: permission_handler can check if it's on, but on Android, 
  // Nearby().startAdvertising() usually triggers the system Bluetooth prompt automatically.
  bool isBluetoothEnabled = await Permission.bluetooth.serviceStatus.isEnabled;
  if (!isBluetoothEnabled) {
    print("Bluetooth is OFF. Attempting to start advertising will prompt user...");
  }

    try {
      // 1. Start Advertising
      await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: (id, status) => print("Connection Result: $status"),
        onDisconnected: (id) => print("Disconnected from: $id"),
        serviceId: serviceId,
      );

      // 2. Start Discovery
      await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, sid) {
          Nearby().requestConnection(
            userName,
            id,
            onConnectionInitiated: _onConnectionInitiated,
            onConnectionResult: (id, status) =>
                print("Discovery Result: $status"),
            onDisconnected: (id) => print("Disconnected: $id"),
          );
        },
        onEndpointLost: (id) => print("Peer lost: $id"),
        serviceId: serviceId,
      );
    } catch (e) {
      print("Bluetooth Start Error: $e");
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    // FIX: Explicitly accept on both sides and set up the listener
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endpointId, payload) {
        if (payload.type == PayloadType.BYTES) {
          // FIX: Use utf8 decode for cross-platform safety
          final String rawData = utf8.decode(payload.bytes!);
          _handleIncomingData(rawData);
        }
      },
    );
    // Send our state immediately after accepting
    _sendMapState(id);
  }

  void _sendMapState(String endpointId) {
    final String data = json.encode(
      provider.edges.map((e) => e.toJson()).toList(),
    );
    // FIX: Use utf8 encode
    Nearby().sendBytesPayload(
      endpointId,
      Uint8List.fromList(utf8.encode(data)),
    );
  }

  void _handleIncomingData(String rawData) {
    try {
      final List<dynamic> decodedData = json.decode(rawData);
      final List<MapEdge> incomingEdges = decodedData
          .map((item) => MapEdge.fromJson(item as Map<String, dynamic>))
          .toList();
      provider.syncMeshUpdates(incomingEdges);
    } catch (e) {
      print("Data Sync Error: $e");
    }
  }

  void stopMesh() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Nearby().stopAllEndpoints();
  }
}
