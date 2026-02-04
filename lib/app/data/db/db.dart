import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbProvider {
  // Singleton
  DbProvider._internal();
  static final DbProvider instance = DbProvider._internal();

  static Database? _database;

  static const _dbName = 'app.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await _getDatabasePath();

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  // Windows/Desktop safe
  Future<String> _getDatabasePath() async {
    final directory = await getApplicationSupportDirectory();
    return path.join(directory.path, _dbName);
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    String initialPath = path.join(Directory.current.path, 'lib', 'sql', 'initial.sql');
    File sqlFile = File(initialPath);
    String sql = await sqlFile.readAsString();
    
    await db.execute(sql);
  }

  // Migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
