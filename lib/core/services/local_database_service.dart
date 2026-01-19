import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart'; // Required for TimeOfDay
import '../../hydration/data/intake_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  static Database? _database;

  LocalDatabaseService._internal();

  factory LocalDatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hydrobuddy.db');

    return await openDatabase(
      path,
      version: 2, // Incremented version to handle the new table
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE intake_logs(
            local_id INTEGER PRIMARY KEY AUTOINCREMENT,
            supabase_id TEXT,
            user_id TEXT NOT NULL,
            amount_ml INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        
        // Create table for persistent notification times
        await db.execute('''
          CREATE TABLE notification_settings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hour INTEGER NOT NULL,
            minute INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE notification_settings(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              hour INTEGER NOT NULL,
              minute INTEGER NOT NULL
            )
          ''');
        }
      },
    );
  }

  // --- Notification Persistence Methods ---

  Future<void> saveNotificationTimes(List<TimeOfDay> times) async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear old times and insert current list to keep it synced
      await txn.delete('notification_settings');
      for (var time in times) {
        await txn.insert('notification_settings', {
          'hour': time.hour,
          'minute': time.minute,
        });
      }
    });
  }

  Future<List<TimeOfDay>> getNotificationTimes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notification_settings');
    
    if (maps.isEmpty) {
      return [const TimeOfDay(hour: 8, minute: 0)]; // Default if none saved
    }

    return maps.map((m) => TimeOfDay(hour: m['hour'], minute: m['minute'])).toList();
  }

  // --- Existing Intake Methods ---

  Future<int> insertIntake(IntakeModel intake) async {
    final db = await database;
    return await db.insert('intake_logs', intake.toLocalJson());
  }

  Future<List<IntakeModel>> getUnsyncedIntakes(String userId) async {
    final db = await database;
    final maps = await db.query(
      'intake_logs',
      where: 'is_synced = ? AND user_id = ?',
      whereArgs: [0, userId],
    );
    return maps.map((e) => IntakeModel.fromLocalJson(e)).toList();
  }

  Future<void> markAsSynced(int localId, String supabaseId) async {
    final db = await database;
    await db.update(
      'intake_logs',
      {'is_synced': 1, 'supabase_id': supabaseId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<int> getTodayTotal(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final todayPrefix = now.toIso8601String().substring(0, 10);

    final result = await db.rawQuery('''
      SELECT SUM(amount_ml) as total 
      FROM intake_logs 
      WHERE user_id = ? AND timestamp LIKE '$todayPrefix%'
    ''', [userId]);

    if (result.first['total'] == null) return 0;
    return result.first['total'] as int;
  }

  Future<List<IntakeModel>> getTodayLogs(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final todayPrefix = now.toIso8601String().substring(0, 10);

    final maps = await db.query(
      'intake_logs',
      where: 'user_id = ? AND timestamp LIKE "$todayPrefix%"',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );

    return maps.map((e) => IntakeModel.fromLocalJson(e)).toList();
  }

  Future<void> deleteTodayIntakes(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final todayPrefix = now.toIso8601String().substring(0, 10);
    
    await db.delete(
      'intake_logs',
      where: 'user_id = ? AND timestamp LIKE "$todayPrefix%"',
      whereArgs: [userId],
    );
  }
}