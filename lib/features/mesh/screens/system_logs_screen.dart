import 'package:flutter/material.dart';
import 'package:digital_delta/data/local/db_helper.dart';

class SystemLogEntry {
  final String source;
  final String title;
  final String? description;
  final int timestamp;
  final String? extraHash;

  SystemLogEntry({
    required this.source,
    required this.title,
    this.description,
    required this.timestamp,
    this.extraHash,
  });
}

class SystemLogsScreen extends StatefulWidget {
  const SystemLogsScreen({super.key});

  @override
  State<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends State<SystemLogsScreen> {
  final DbHelper _dbHelper = DbHelper();
  List<SystemLogEntry> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final db = await _dbHelper.db;
      final List<SystemLogEntry> combinedLogs = [];

      // 1. Load Audit Logs (Auth/System)
      final auditRows = await db.query('audit_logs');
      for (var row in auditRows) {
        combinedLogs.add(SystemLogEntry(
          source: 'AUTH',
          title: row['event'] as String? ?? 'Unknown Auth Event',
          timestamp: row['timestamp'] as int? ?? 0,
          extraHash: row['current_hash'] as String?,
        ));
      }

      // 2. Load Mesh Events
      final meshRows = await db.query('mesh_events_log');
      for (var row in meshRows) {
        combinedLogs.add(SystemLogEntry(
          source: 'MESH',
          title: row['event_type'] as String? ?? 'Unknown Mesh Event',
          description: row['description'] as String?,
          timestamp: row['timestamp'] as int? ?? 0,
        ));
      }

      // Sort by timestamp descending (newest first)
      combinedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _logs = combinedLogs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading logs: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatTime(int msTimestamp) {
    if (msTimestamp == 0) return 'Unknown Time';
    final date = DateTime.fromMillisecondsSinceEpoch(msTimestamp);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text('System Logs'),
        backgroundColor: const Color(0xFF0B1F33),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // onAction: () => _loadLogs(),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(
                  child: Text('No persistent logs found.',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final isAuth = log.source == 'AUTH';

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAuth
                                        ? const Color(0xFFFF9F1C)
                                            .withOpacity(0.2)
                                        : const Color(0xFF3A86FF)
                                            .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    log.source,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isAuth
                                          ? const Color(0xFFD67E0A)
                                          : const Color(0xFF1E5BB5),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatTime(log.timestamp),
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              log.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (log.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                log.description!,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black87),
                              ),
                            ],
                            if (log.extraHash != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Hash: ${log.extraHash}',
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      color: Colors.black54),
                                ),
                              )
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
