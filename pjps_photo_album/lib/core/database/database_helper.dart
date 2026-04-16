import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

// Use sqflite_common_ffi for Windows/desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final _lock = Lock();

  Future<Database> get database async {
    if (_database != null) return _database!;
    return _lock.synchronized(() async {
      if (_database != null) return _database!;

      // Initialize FFI (for desktop)
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;

      _database = await _initDatabase(databaseFactory);
      return _database!;
    });
  }

  Future<Database> _initDatabase(DatabaseFactory databaseFactory) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pjps_offline.db');

    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      ),
    );

    // Set WAL safely after database is open
    await db.rawQuery('PRAGMA journal_mode = WAL');

    return db;
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    // Do NOT set WAL here on desktop/Windows
  }

  Future _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        registration_number TEXT,
        first_name TEXT,
        last_name TEXT,
        full_name TEXT,
        email TEXT,
        user_type TEXT,
        is_active INTEGER,
        date_joined TEXT,
        last_sync TEXT
      )
    ''');

    // Students table
    await db.execute('''
      CREATE TABLE students(
        id TEXT PRIMARY KEY,
        registration_number TEXT,
        full_name TEXT,
        first_name TEXT,
        last_name TEXT,
        other_names TEXT,
        diocese_name TEXT,
        hometown TEXT,
        state_name TEXT,
        class_id TEXT,
        class_name TEXT,
        year_level TEXT,
        profile_photo_url TEXT,
        profile_photo_local TEXT,
        personal_notes TEXT,
        is_active INTEGER,
        is_dirty INTEGER DEFAULT 0,
        last_sync TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Classes table
    await db.execute('''
      CREATE TABLE classes(
        id TEXT PRIMARY KEY,
        name TEXT,
        year_level_id TEXT,
        year_level_name TEXT,
        academic_year TEXT,
        academic_year_name TEXT,
        student_count INTEGER,
        notes TEXT,
        is_dirty INTEGER DEFAULT 0,
        last_sync TEXT
      )
    ''');

    // Year levels table
    await db.execute('''
      CREATE TABLE year_levels(
        id TEXT PRIMARY KEY,
        name TEXT,
        display_order INTEGER,
        class_count INTEGER,
        student_count INTEGER,
        last_sync TEXT
      )
    ''');

    // Staff table
    await db.execute('''
      CREATE TABLE staff(
        id TEXT PRIMARY KEY,
        staff_id TEXT,
        full_name TEXT,
        first_name TEXT,
        last_name TEXT,
        position TEXT,
        department_name TEXT,
        category_name TEXT,
        work_email TEXT,
        work_phone TEXT,
        office_location TEXT,
        bio TEXT,
        profile_photo_url TEXT,
        profile_photo_local TEXT,
        is_active INTEGER,
        is_dirty INTEGER DEFAULT 0,
        last_sync TEXT
      )
    ''');

    // Remarks table
    await db.execute('''
      CREATE TABLE remarks(
        id TEXT PRIMARY KEY,
        object_type TEXT,
        object_id TEXT,
        title TEXT,
        content TEXT,
        author_name TEXT,
        author_id TEXT,
        remark_type TEXT,
        visibility TEXT,
        created_at TEXT,
        is_dirty INTEGER DEFAULT 1,
        sync_status TEXT DEFAULT 'PENDING'
      )
    ''');

    // Sync queue
    await db.execute('''
      CREATE TABLE sync_queue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT,
        table_name TEXT,
        record_id TEXT,
        data TEXT,
        created_at TEXT,
        attempts INTEGER DEFAULT 0
      )
    ''');

    // Images cache table
    await db.execute('''
      CREATE TABLE images_cache(
        id TEXT PRIMARY KEY,
        url TEXT,
        local_path TEXT,
        file_size INTEGER,
        downloaded_at TEXT,
        last_accessed TEXT
      )
    ''');

    // Last sync info
    await db.execute('''
      CREATE TABLE sync_info(
        key TEXT PRIMARY KEY,
        value TEXT,
        last_updated TEXT
      )
    ''');

    await db.insert('sync_info', {
      'key': 'last_full_sync',
      'value': DateTime.now().toIso8601String(),
      'last_updated': DateTime.now().toIso8601String(),
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // Generic CRUD operations
  Future<int> insert(
    String table,
    Map<String, dynamic> data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data,
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Queue offline operation
  Future<void> queueOperation(String operation, String table, String recordId,
      Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('sync_queue', {
      'operation': operation,
      'table_name': table,
      'record_id': recordId,
      'data': json.encode(data),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get pending sync operations
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  // Remove operation from queue after successful sync
  Future<void> removeOperation(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  // Clear old data (keep last 30 days)
  Future<void> clearOldData() async {
    final db = await database;
    final cutoff =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

    await db.delete('students', where: 'last_sync < ?', whereArgs: [cutoff]);
    await db.delete('remarks', where: 'created_at < ?', whereArgs: [cutoff]);
    await db.delete('images_cache',
        where: 'last_accessed < ?', whereArgs: [cutoff]);
  }
}
