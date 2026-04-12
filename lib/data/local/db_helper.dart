import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _db;

  Future<Database> get db async => _db ??= await initDb();

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'hackathon_auth.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      // Identity & RBAC Table
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          username TEXT,
          role TEXT,
          public_key TEXT,
          created_at INTEGER
        )
      ''');

      // M1.4 Audit Trail Table
      await db.execute('''
        CREATE TABLE audit_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          event TEXT,
          timestamp INTEGER,
          prev_hash TEXT,
          current_hash TEXT
        )
      ''');
    });
  }
}