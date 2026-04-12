import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:digital_delta/core/services/mesh_service.dart';
import 'package:digital_delta/core/services/crdt_service.dart';
import 'package:digital_delta/features/mesh/screens/conflict_resolution_screen.dart';
import 'package:digital_delta/features/mesh/screens/mesh_chat_screen.dart';
import 'package:digital_delta/features/mesh/screens/system_logs_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Mesh Dashboard — Hub screen showing peers, role, sync, and navigation
class MeshDashboardScreen extends StatefulWidget {
  final MeshSyncManager meshManager;

  const MeshDashboardScreen({super.key, required this.meshManager});

  @override
  State<MeshDashboardScreen> createState() => _MeshDashboardScreenState();
}

class _MeshDashboardScreenState extends State<MeshDashboardScreen> {
  MeshSyncManager get _mesh => widget.meshManager;
  bool _isAdvertising = false;
  bool _isDiscovering = false;
  String _currentRole = 'CLIENT';
  final List<String> _logs = [];
  Map<String, dynamic> _peers = {};
  List<CrdtConflict> _pendingConflicts = [];

  late StreamSubscription _peerSub;
  late StreamSubscription _roleSub;
  late StreamSubscription _logSub;
  late StreamSubscription _conflictSub;

  // CRDT inventory fields for demo
  final _fieldController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _peerSub = _mesh.peerStream.listen((peers) {
      if (mounted) setState(() => _peers = peers);
    });
    _roleSub = _mesh.roleStream.listen((role) {
      if (mounted) setState(() => _currentRole = role);
    });
    _logSub = _mesh.logStream.listen((log) {
      if (mounted) {
        setState(() {
          _logs.insert(0, '[${_timeStr()}] $log');
          if (_logs.length > 100) _logs.removeLast();
        });
      }
    });
    _conflictSub = _mesh.conflictStream.listen((conflicts) {
      if (mounted) setState(() => _pendingConflicts = conflicts);
    });
  }

  /// Request all runtime permissions needed by nearby_connections
  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return true; // Default true for non-Android testing

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    List<Permission> permissions = [];

    if (sdkInt >= 33) {
      // Android 13+
      permissions = [
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
        Permission.nearbyWifiDevices,
      ];
    } else if (sdkInt >= 31) {
      // Android 12
      permissions = [
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ];
    } else {
      // Android 11 and lower
      permissions = [
        Permission.bluetooth,
        Permission.location,
      ];
    }

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Check if all critical permissions are granted
    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
        _logs.insert(0, '[${_timeStr()}] ⚠ ${permission.toString().split('.').last} not granted');
      }
    });

    if (!allGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some permissions were denied. Mesh may not work.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    return allGranted;
  }

  String _timeStr() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _peerSub.cancel();
    _roleSub.cancel();
    _logSub.cancel();
    _conflictSub.cancel();
    _fieldController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text('Mesh Network'),
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        actions: [
          // Role badge
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _currentRole == 'RELAY'
                  ? const Color(0xFF2EC4B6)
                  : const Color(0xFF3A86FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _currentRole,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Connection Controls ───
            _sectionTitle('Connection', Icons.bluetooth_connected),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.cell_tower,
                    label: _isAdvertising ? 'Stop Advertise' : 'Advertise',
                    color: _isAdvertising ? Colors.red : const Color(0xFF2EC4B6),
                    onTap: () async {
                      if (_isAdvertising) {
                        await _mesh.stopAll();
                        setState(() {
                          _isAdvertising = false;
                          _isDiscovering = false;
                        });
                      } else {
                        final granted = await _requestPermissions();
                        if (!granted) return;
                        await _mesh.startAdvertising();
                        setState(() => _isAdvertising = true);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    icon: Icons.search,
                    label: _isDiscovering ? 'Stop Discovery' : 'Discover',
                    color: _isDiscovering ? Colors.red : const Color(0xFF3A86FF),
                    onTap: () async {
                      if (_isDiscovering) {
                        await _mesh.stopAll();
                        setState(() {
                          _isDiscovering = false;
                          _isAdvertising = false;
                        });
                      } else {
                        final granted = await _requestPermissions();
                        if (!granted) return;
                        await _mesh.startDiscovery();
                        setState(() => _isDiscovering = true);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ─── Connected Peers ───
            _sectionTitle('Connected Peers (${_peers.length})', Icons.devices),
            const SizedBox(height: 8),
            if (_peers.isEmpty)
              _emptyCard('No peers connected. Start Advertising & Discovery.')
            else
              ..._peers.entries.map((e) {
                final info = e.value;
                return _peerCard(
                  endpointId: e.key,
                  name: info.deviceName,
                  role: info.role,
                  battery: info.batteryLevel,
                );
              }),

            const SizedBox(height: 20),

            // ─── Quick Actions ───
            _sectionTitle('Actions', Icons.flash_on),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.message,
                    label: 'Chat',
                    color: const Color(0xFF0B1F33),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MeshChatScreen(meshManager: _mesh),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    icon: Icons.warning_amber,
                    label: 'Conflicts (${_pendingConflicts.length})',
                    color: _pendingConflicts.isNotEmpty
                        ? const Color(0xFFFF9F1C)
                        : Colors.grey,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConflictResolutionScreen(
                            meshManager: _mesh,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ─── CRDT Inventory (M2.1 Demo) ───
            _sectionTitle('Supply Inventory (CRDT)', Icons.inventory),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fieldController,
                          decoration: InputDecoration(
                            hintText: 'Item name',
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _valueController,
                          decoration: InputDecoration(
                            hintText: 'Quantity',
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final field = _fieldController.text.trim();
                          final value = _valueController.text.trim();
                          if (field.isNotEmpty && value.isNotEmpty) {
                            await _mesh.crdtService.updateField(field, value);
                            _fieldController.clear();
                            _valueController.clear();
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.add_circle),
                        color: const Color(0xFF2EC4B6),
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _mesh.crdtService.getAllFields(),
                    builder: (_, snap) {
                      if (!snap.hasData || snap.data!.isEmpty) {
                        return const Text('No inventory items.',
                            style: TextStyle(color: Colors.grey));
                      }
                      return Column(
                        children: snap.data!.map((e) {
                          final isConflict = (e['is_conflict'] as int?) == 1;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              isConflict ? Icons.warning : Icons.check_circle,
                              color: isConflict ? Colors.orange : Colors.green,
                              size: 20,
                            ),
                            title: Text(e['field_name'] as String),
                            trailing: Text(
                              e['value'] as String? ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Vector Clock State ───
            _sectionTitle('Vector Clock', Icons.access_time),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1F33),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _mesh.vcService.clock.isEmpty
                    ? '{ empty }'
                    : _mesh.vcService.clock.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n'),
                style: const TextStyle(
                    color: Color(0xFF2EC4B6),
                    fontFamily: 'monospace',
                    fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Event Log ───
            _sectionTitle('Mesh Log', Icons.list_alt),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1F33),
                borderRadius: BorderRadius.circular(14),
              ),
              child: _logs.isEmpty
                  ? const Center(
                      child: Text('No events yet.',
                          style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          _logs[i],
                          style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'monospace',
                              fontSize: 11),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            _actionButton(
              icon: Icons.history,
              label: 'View All Persistent Logs',
              color: const Color(0xFF0B1F33).withOpacity(0.8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SystemLogsScreen()),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0B1F33)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B1F33))),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _peerCard({
    required String endpointId,
    required String name,
    required String role,
    required int battery,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: role == 'RELAY'
                  ? const Color(0xFF2EC4B6).withValues(alpha: 0.15)
                  : const Color(0xFF3A86FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              role == 'RELAY' ? Icons.cell_tower : Icons.phone_android,
              color: role == 'RELAY'
                  ? const Color(0xFF2EC4B6)
                  : const Color(0xFF3A86FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$role • Battery: $battery%',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey)),
    );
  }
}
