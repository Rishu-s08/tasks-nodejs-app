import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todonodejs/models/user_model.dart';

class AuthLocalRepository {
  String tabelName = 'users';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDb();
      return _database!;
    }
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'auth.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE $tabelName(
          id TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          token TEXT NOT NULL,
          name TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
''');
      },
    );
  }

  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert(
      tabelName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    final db = await database;
    final result = await db.query(tabelName, limit: 1);
    if (result.isEmpty) {
      return null;
    }
    return UserModel.fromMap(result.first);
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete(tabelName);
  }
}
