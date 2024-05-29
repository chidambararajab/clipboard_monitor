import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:clipboard_monitor/models/clipboard_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'clipboard.db');

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE clipboard_items(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, imagePath TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertClipboardItem(ClipboardItem item) async {
    final db = await database;
    await db.insert('clipboard_items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ClipboardItem>> getClipboardItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clipboard_items');

    return List.generate(maps.length, (i) {
      return ClipboardItem(
        id: maps[i]['id'],
        text: maps[i]['text'],
        imagePath: maps[i]['imagePath'],
      );
    });
  }

  Future<void> deleteClipboardItem(int id) async {
    final db = await database;
    await db.delete('clipboard_items', where: 'id = ?', whereArgs: [id]);
  }
}
