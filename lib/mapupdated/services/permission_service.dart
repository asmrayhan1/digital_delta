import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestMeshPermissions() async {
    if (!Platform.isAndroid) return true; // iOS handled via Info.plist

    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;

    List<Permission> permissions = [];

    // Always needed for the Nearby API to scan
    permissions.add(Permission.location);

    if (sdkInt >= 31) {
      // Android 12+ needs specific Bluetooth permissions
      permissions.add(Permission.bluetoothScan);
      permissions.add(Permission.bluetoothAdvertise);
      permissions.add(Permission.bluetoothConnect);
    } else {
      // Legacy Bluetooth
      permissions.add(Permission.bluetooth);
    }

    if (sdkInt >= 33) {
      // Android 13+ specifically needs this for Wi-Fi Direct/Mesh
      permissions.add(Permission.nearbyWifiDevices);
    }

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Verify everything was granted
    return statuses.values.every((status) => status.isGranted);
  }
}