import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _db;

  Future<Database> get db async => _db ??= await initDb();

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'hackathon_auth.db');
    return await openDatabase(
      path,
      version: 4,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Drop and recreate everything on major schema change
          await db.execute("DROP TABLE IF EXISTS users");
          await db.execute("DROP TABLE IF EXISTS audit_logs");
          await db.execute("DROP TABLE IF EXISTS messages");
          await db.execute("DROP TABLE IF EXISTS posts");
          await db.execute("DROP TABLE IF EXISTS ledger_entries");
          await db.execute("DROP TABLE IF EXISTS sync_state");
          await db.execute("DROP TABLE IF EXISTS peers");
          await db.execute("DROP TABLE IF EXISTS mesh_messages");
          await db.execute("DROP TABLE IF EXISTS crdt_entries");
          await db.execute("DROP TABLE IF EXISTS relay_queue");
          await db.execute("DROP TABLE IF EXISTS mesh_events_log");
          await _createTables(db);
        }
        if (oldVersion == 3 && newVersion >= 4) {
          await db.execute("ALTER TABLE users ADD COLUMN is_synced INTEGER DEFAULT 0");
        }
      },
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Users
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT,
        mobile TEXT UNIQUE,
        role TEXT,
        public_key TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at INTEGER
      )
    ''');

    // Audit logs with hash chaining
    await db.execute('''
      CREATE TABLE audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event TEXT,
        timestamp INTEGER,
        prev_hash TEXT,
        current_hash TEXT
      )
    ''');

    // Messages (derived from ledger)
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        sender_id TEXT,
        receiver_id TEXT,
        content TEXT,
        timestamp INTEGER
      )
    ''');

    // Posts
    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        content TEXT,
        timestamp INTEGER
      )
    ''');

    // Ledger (CORE TABLE)
    await db.execute('''
      CREATE TABLE ledger_entries (
        id TEXT PRIMARY KEY,
        type TEXT,
        payload BLOB,
        sender_id TEXT,
        receiver_id TEXT,
        timestamp INTEGER,
        prev_hash TEXT,
        current_hash TEXT
      )
    ''');

    // Sync state (per peer)
    await db.execute('''
      CREATE TABLE sync_state (
        peer_id TEXT PRIMARY KEY,
        last_synced_hash TEXT,
        last_synced_at INTEGER
      )
    ''');

    // Known peers
    await db.execute('''
      CREATE TABLE peers (
        id TEXT PRIMARY KEY,
        device_name TEXT,
        last_seen INTEGER,
        public_key TEXT
      )
    ''');

    // ─── NEW: Mesh Messages (M3.1 Store-and-Forward) ───
    await db.execute('''
      CREATE TABLE mesh_messages (
        message_id TEXT PRIMARY KEY,
        source_id TEXT NOT NULL,
        destination_id TEXT NOT NULL,
        encrypted_payload BLOB,
        ttl INTEGER DEFAULT 5,
        hop_list TEXT,
        created_at INTEGER,
        delivered INTEGER DEFAULT 0,
        received_at INTEGER
      )
    ''');

    // ─── NEW: CRDT Entries (M2.1 LWW-Register) ───
    await db.execute('''
      CREATE TABLE crdt_entries (
        id TEXT PRIMARY KEY,
        field_name TEXT NOT NULL,
        value TEXT,
        hlc_timestamp INTEGER NOT NULL,
        node_id TEXT NOT NULL,
        vector_clock TEXT,
        is_conflict INTEGER DEFAULT 0,
        resolved INTEGER DEFAULT 0
      )
    ''');

    // ─── NEW: Relay Queue (M3.1) ───
    await db.execute('''
      CREATE TABLE relay_queue (
        message_id TEXT PRIMARY KEY,
        envelope_bytes BLOB NOT NULL,
        destination_id TEXT NOT NULL,
        ttl INTEGER DEFAULT 5,
        created_at INTEGER,
        forwarded INTEGER DEFAULT 0
      )
    ''');

    // ─── NEW: Mesh Events Log (M2.3 + M3.2) ───
    await db.execute('''
      CREATE TABLE mesh_events_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_type TEXT NOT NULL,
        description TEXT,
        node_id TEXT,
        timestamp INTEGER,
        metadata TEXT
      )
    ''');
  }
}
