import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database helper — single instance, manages all tables.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'qr_generator.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ─── Users table ──────────────────────────────────────
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        display_name TEXT,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ─── Generated items (QR + Barcodes) ──────────────────
    await db.execute('''
      CREATE TABLE generated_items (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        type TEXT NOT NULL,
        format TEXT NOT NULL,
        title TEXT,
        data TEXT NOT NULL,
        image_path TEXT,
        embedded_image_path TEXT,
        category TEXT DEFAULT 'uncategorized',
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // ─── Scan history ─────────────────────────────────────
    await db.execute('''
      CREATE TABLE scan_history (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        scanned_data TEXT NOT NULL,
        scan_type TEXT NOT NULL,
        format TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // ─── Folders ──────────────────────────────────────────
    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT NOT NULL,
        color TEXT,
        icon TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
