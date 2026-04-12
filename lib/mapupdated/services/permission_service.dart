import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestMeshPermissions() async {
    // A disaster app needs multiple hardware permissions to create a mesh
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    // Check if all are granted
    return statuses.values.every((status) => status.isGranted);
  }
}