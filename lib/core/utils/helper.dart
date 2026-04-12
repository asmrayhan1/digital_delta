import 'package:digital_delta/data/local/db_helper.dart';

Future<void> debugPrintLogs() async {
  final db = await DbHelper().db;
  final List<Map<String, dynamic>> logs = await db.query('audit_logs');

  for (var log in logs) {
    print(
      "ID: ${log['id']} | Event: ${log['event']} | Hash: ${log['current_hash']}",
    );
  }
}

Future<void> debugPrintUsers() async {
  final db = await DbHelper().db;
  final List<Map<String, dynamic>> users = await db.query('users');

  for (var user in users) {
    print(
      "ID: ${user['id']} | Username: ${user['username']} | Role: ${user['role']} | Public Key: ${user['public_key']}",
    );
  }
}
