import 'dart:convert';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import '../models/map_data_model.dart';
import '../providers/map_provider.dart';

class BluetoothMeshService {
  final MapProvider provider;
  final Strategy strategy = Strategy.P2P_CLUSTER; // Supports M-to-N connections
  final String serviceId = "com.digital_delta.mesh"; // Unique ID for your app

  BluetoothMeshService(this.provider);

  // 1. Start the Mesh (Both Advertise and Discover)
  Future<void> startMesh() async {
    String userName = "User_${DateTime.now().millisecond}";

    // Start Advertising (Being found)
    try {
      await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: (id, status) => print("Adv Result: $status"),
        onDisconnected: (id) => print("Disconnected: $id"),
        serviceId: serviceId,
      );

      // Start Discovery (Finding others)
      await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          // When a peer is found, request a connection immediately
          Nearby().requestConnection(userName, id,
              onConnectionInitiated: _onConnectionInitiated,
              onConnectionResult: (id, status) => print("Disc Result: $status"),
              onDisconnected: (id) => print("Disconnected: $id"));
        },
        onEndpointLost: (id) => print("Endpoint lost: $id"),
        serviceId: serviceId,
      );
    } catch (e) {
      print("Mesh Start Error: $e");
    }
  }

  // 2. The "Handshake" Logic
  void _onConnectionInitiated(String id, ConnectionInfo info) {
    // In a disaster, we trust other app users. Accept immediately.
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endpointId, payload) {
        if (payload.type == PayloadType.BYTES) {
          _handleIncomingData(payload.bytes!);
        }
      },
    );
    
    // Once connected, immediately send our current map state to the new peer
    _sendMapState(id);
  }

  // 3. The "Gossip" - Sending Data
  void _sendMapState(String endpointId) {
    // We only send the edges (their flooded/collapsed status and timestamps)
    final String data = json.encode(
      provider.edges.map((e) => e.toJson()).toList(),
    );
    Nearby().sendBytesPayload(endpointId, Uint8List.fromList(data.codeUnits));
  }

  // 4. The Conflict Resolution (Last-Write-Wins)
  void _handleIncomingData(Uint8List bytes) {
    final String rawData = String.fromCharCodes(bytes);
    final List<dynamic> decodedData = json.decode(rawData);
    
    List<MapEdge> incomingEdges = decodedData.map((e) => MapEdge.fromJson(e)).toList();

    // Pass this data to the provider to merge
    provider.syncMeshUpdates(incomingEdges);
  }

  void stopMesh() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Nearby().stopAllEndpoints();
  }
}