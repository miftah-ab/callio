import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('callio.db');
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

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
CREATE TABLE templates (
  id $idType,
  name $textType,
  content $textType,
  isDefault $boolType
)
''');

    await db.execute('''
CREATE TABLE rules (
  id $idType,
  name $textType,
  contactGroup $textType,
  templateId INTEGER NOT NULL,
  priority INTEGER NOT NULL DEFAULT 0,
  isActive $boolType,
  FOREIGN KEY (templateId) REFERENCES templates (id)
)
''');

    await db.execute('''
CREATE TABLE logs (
  id $idType,
  phoneNumber $textType,
  timeSent $textType,
  status $textType
)
''');

    // Index for fast throttling queries (e.g., checking if we replied to this number recently)
    await db.execute('CREATE INDEX idx_logs_phone_time ON logs(phoneNumber, timeSent)');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
