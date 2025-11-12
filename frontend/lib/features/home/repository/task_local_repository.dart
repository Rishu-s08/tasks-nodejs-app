import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todonodejs/models/task_model.dart';
import 'package:todonodejs/models/user_model.dart';

class TaskLocalRepository {
  String tabelName = 'tasks';
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
    final path = join(databasePath, 'tasks.db');
    return openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $tabelName ADD COLUMN isSynced INTEGER NOT NULL',
          );
        }
      },
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE $tabelName(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          uid TEXT NOT NULL,
          hexColor TEXT NOT NULL,
          dueAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          isSynced INTEGER NOT NULL
        )
''');
      },
    );
  }

  Future<void> insertTask(TaskModel task) async {
    final db = await database;
    await db.insert(
      tabelName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTasks(List<TaskModel> task) async {
    final db = await database;
    final batch = db.batch();
    for (final task in task) {
      batch.insert(
        tabelName,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<TaskModel>> getTask() async {
    final db = await database;
    final result = await db.query(tabelName);
    if (result.isNotEmpty) {
      List<TaskModel> tasks = [];
      for (final ele in result) {
        tasks.add(TaskModel.fromMap(ele));
      }
      return tasks;
    }
    return [];
  }

  Future<List<TaskModel>> getUnsyncedTasks() async {
    final db = await database;
    final result = await db.query(
      tabelName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    if (result.isNotEmpty) {
      List<TaskModel> tasks = [];
      for (final ele in result) {
        tasks.add(TaskModel.fromMap(ele));
      }
      return tasks;
    }
    return [];
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await database;
    await db.update(
      tabelName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
