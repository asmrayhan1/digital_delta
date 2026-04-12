import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:digital_delta/data/local/db_helper.dart';

class LedgerManager {
  static final _dbHelper = DbHelper();
  
  // Create a SHA-256 Hash of the entry
  static String calculateHash(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  static Future<void> addToLedger(String type, Map<String, dynamic> payload, {String? receiverId}) async {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    final int ts = DateTime.now().millisecondsSinceEpoch;
    final String payloadStr = jsonEncode(payload);

    final db = await _dbHelper.db;

    // 1. Get the latest hash from the ledger
    List<Map> lastEntry = await db.query('ledger_entries', orderBy: 'timestamp DESC', limit: 1);
    String prevHash = lastEntry.isEmpty ? "GENESIS_BLOCK" : lastEntry.first['current_hash'];

    // 2. Generate current hash
    String currentHash = calculateHash("$id$type$payloadStr$ts$prevHash");

    // 3. Save to Ledger
    await db.insert('ledger_entries', {
      'id': id,
      'type': type,
      'payload': utf8.encode(payloadStr),
      'sender_id': 'MY_USER_ID', // Replace with actual ID
      'receiver_id': receiverId,
      'timestamp': ts,
      'prev_hash': prevHash,
      'current_hash': currentHash,
    });
  }
}