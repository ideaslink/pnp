import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scan_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('point_and_play.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        phone_numbers TEXT NOT NULL,
        emails TEXT NOT NULL,
        websites TEXT NOT NULL,
        addresses TEXT NOT NULL,
        raw_text TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertScan(ScanRecord scan) async {
    final db = await instance.database;
    return await db.insert('scans', scan.toMap());
  }

  Future<List<ScanRecord>> getScans() async {
    final db = await instance.database;
    final maps = await db.query(
      'scans',
      orderBy: 'timestamp DESC',
    );

    if (maps.isNotEmpty) {
      return maps.map((map) => ScanRecord.fromMap(map)).toList();
    } else {
      return [];
    }
  }

  Future<void> deleteScan(int id) async {
    final db = await instance.database;
    await db.delete(
      'scans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllScans() async {
    final db = await instance.database;
    await db.delete('scans');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
