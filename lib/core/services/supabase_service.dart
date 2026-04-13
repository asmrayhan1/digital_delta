import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:digital_delta/data/local/db_helper.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  final _supabase = Supabase.instance.client;
  final _dbHelper = DbHelper();

  void init() {
    try {
      // Listen to network changes and push pending changes when online
      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
        if (results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.ethernet)) {
          syncPendingUsers();
        }
      }, onError: (e) {
        print("Connectivity stream error: $e");
      });
    } catch (e) {
      print("Warning: Connectivity listener failed to initialize. If you just added the package, fully stop and rebuild the app. Error: $e");
    }
    
    // Also try syncing on startup
    syncPendingUsers();
  }

  Future<void> syncPendingUsers() async {
    final db = await _dbHelper.db;

    // Fetch all users that haven't been synced yet
    final List<Map<String, dynamic>> pendingUsers = await db.query(
      'users',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    if (pendingUsers.isEmpty) return;

    for (var user in pendingUsers) {
      try {
        final payload = {
          'id': user['id'],
          'username': user['username'],
          'mobile': user['mobile'],
          'role': user['role'],
          'public_key': user['public_key'],
          'created_at': DateTime.fromMillisecondsSinceEpoch(user['created_at'] ?? DateTime.now().millisecondsSinceEpoch).toIso8601String(),
        };

        // Upsert into Supabase `persons` table
        await _supabase.from('persons').upsert(payload, onConflict: 'id');

        // If successful, mark as synced
        await db.update(
          'users',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [user['id']],
        );
        print("Synced user ${user['id']} to Supabase.");
      } catch (e) {
        print("Failed to sync user ${user['id']}: $e");
      }
    }
  }
}
