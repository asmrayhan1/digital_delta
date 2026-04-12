import 'package:digital_delta/core/services/mesh_service.dart';
import 'package:flutter/material.dart';

/// Conflict Resolution Screen (M2.3)
///
/// Shows detected CRDT conflicts where the same field was updated
/// concurrently on two disconnected devices. Displays both values
/// and lets user pick which one wins. Resolution is logged.
class ConflictResolutionScreen extends StatefulWidget {
  final MeshSyncManager meshManager;

  const ConflictResolutionScreen({super.key, required this.meshManager});

  @override
  State<ConflictResolutionScreen> createState() =>
      _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends State<ConflictResolutionScreen> {
  MeshSyncManager get _mesh => widget.meshManager;
  List<Map<String, dynamic>> _conflicts = [];

  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    final conflicts = await _mesh.crdtService.getUnresolvedConflicts();
    if (mounted) setState(() => _conflicts = conflicts);
  }

  @override
  Widget build(BuildContext context) {
    // Group conflicts by field_name
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final c in _conflicts) {
      final field = c['field_name'] as String;
      grouped.putIfAbsent(field, () => []).add(c);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text('Conflict Resolution'),
        backgroundColor: const Color(0xFFFF9F1C),
        foregroundColor: Colors.white,
      ),
      body: grouped.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No conflicts!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('All CRDT entries are consistent.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9F1C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFF9F1C).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: Color(0xFFFF9F1C), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Concurrent updates detected on the same field from different devices. Choose which value to keep.',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...grouped.entries.map((entry) {
                  return _conflictCard(entry.key, entry.value);
                }),
              ],
            ),
    );
  }

  Widget _conflictCard(
      String fieldName, List<Map<String, dynamic>> entries) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field name header
          Row(
            children: [
              const Icon(Icons.warning, color: Color(0xFFFF9F1C), size: 18),
              const SizedBox(width: 8),
              Text(
                fieldName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),

          // Show each conflicting value
          ...entries.map((entry) {
            final nodeId = entry['node_id'] as String;
            final value = entry['value'] as String? ?? '';
            final ts = entry['hlc_timestamp'] as int? ?? 0;
            final time = DateTime.fromMicrosecondsSinceEpoch(ts);
            final timeStr =
                '${time.hour}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Node: ${nodeId.length > 16 ? '${nodeId.substring(0, 16)}...' : nodeId}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(value,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1F33))),
                        const SizedBox(height: 2),
                        Text('at $timeStr',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EC4B6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onPressed: () async {
                      await _mesh.crdtService
                          .resolveConflict(fieldName, value, nodeId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                              'Resolved "$fieldName" → "$value" from $nodeId'),
                        ),
                      );
                      await _loadConflicts();
                    },
                    child: const Text('Keep', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
