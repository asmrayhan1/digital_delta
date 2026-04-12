import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _db;

  Future<Database> get db async => _db ??= await initDb();

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'hackathon_auth.db');
    return await openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          if (oldVersion < newVersion) {
            await db.execute("DROP TABLE IF EXISTS users");
            await db.execute("DROP TABLE IF EXISTS audit_logs");
            // Re-trigger the creation logic
            await _createTables(db);
          }
        }
      },
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          username TEXT,
          mobile TEXT UNIQUE,
          role TEXT,
          public_key TEXT,
          created_at INTEGER
        )
      ''');

    await db.execute('''
        CREATE TABLE audit_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          event TEXT,
          timestamp INTEGER,
          prev_hash TEXT,
          current_hash TEXT
        )
      ''');
  }
}
