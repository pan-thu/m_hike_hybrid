import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/hike.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hikes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hikes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        date INTEGER NOT NULL,
        length REAL NOT NULL,
        difficulty TEXT NOT NULL,
        parkingAvailable INTEGER NOT NULL,
        description TEXT,
        groupSize INTEGER,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE hikes ADD COLUMN groupSize INTEGER');
    }
  }

  // CRUD Operations
  Future<int> createHike(Hike hike) async {
    final db = await database;
    return await db.insert('hikes', hike.toMap());
  }

  Future<List<Hike>> getAllHikes() async {
    final db = await database;
    final result = await db.query('hikes', orderBy: 'createdAt DESC');
    return result.map((map) => Hike.fromMap(map)).toList();
  }

  Future<Hike?> getHike(int id) async {
    final db = await database;
    final maps = await db.query(
      'hikes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Hike.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateHike(Hike hike) async {
    final db = await database;
    hike.updatedAt = DateTime.now();
    return await db.update(
      'hikes',
      hike.toMap(),
      where: 'id = ?',
      whereArgs: [hike.id],
    );
  }

  Future<int> deleteHike(int id) async {
    final db = await database;
    return await db.delete(
      'hikes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('hikes');
  }
}
