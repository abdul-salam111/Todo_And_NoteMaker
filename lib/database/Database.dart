import 'package:notemaker/model/notesModel.dart';
import 'package:notemaker/model/todoModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:path/path.dart';

class NotesDataBase {
  //create database instance
  static Database? _db;
  //initializing Database
  Future<Database?> get database async {
    if (_db != null) {
      return _db;
    }
    _db = await initializeDatabase();
    return _db;
  }

  initializeDatabase() async {
    try {
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentDirectory.path, "notesDatabase");
      var db = await openDatabase(path, version: 1, onCreate: _onCreate);
      return db;
    } catch (e) {
      print(e);
    }
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL, description TEXT NOT NULL,date_time TEXT NOT NULL,photoName TEXT)");
    await db.execute(
        "CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, todoName TEXT NOT NULL, dateTime TEXT,taskStatus TEXT)");
  }

  Future<bool> insertNote(NotesModel notesModel) async {
    try {
      var dbClient = await database;
      dbClient!.insert("notes", notesModel.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteNotes(int id) async {
    try {
      var dbClient = await database;
      dbClient!.delete("notes", where: "id=?", whereArgs: [id]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<NotesModel>> getAllNotes() async {
    var dbclient = await database;
    final List<Map<String, dynamic>> queryResult =
        await dbclient!.query("notes");
    return queryResult.map((e) => NotesModel.fromMap(e)).toList();
  }

  Future<bool> updateNote(NotesModel notesModel) async {
    try {
      var dbclient = await database;
      await dbclient!.update(
        "notes",
        notesModel.toMap(),
        where: "id=?",
        whereArgs: [notesModel.id],
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<NotesModel>> searchNotes(String notesTitle) async {
    var dbclient = await database;
    final List<Map<String, dynamic>> searchResult = await dbclient!
        .query("notes", where: "title=?", whereArgs: [notesTitle]);
    return searchResult.map((e) => NotesModel.fromMap(e)).toList();
  }

  // todos insertion deletion and updation
  Future<bool> insertToDo(TodoModel todoModel) async {
    try {
      var dbClient = await database;
      dbClient!.insert("todos", todoModel.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteToDo(int id) async {
    try {
      var dbClient = await database;
      dbClient!.delete("todos", where: "id=?", whereArgs: [id]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<TodoModel>> getAllToDos() async {
    var dbclient = await database;
    final List<Map<String, dynamic>> queryResult =
        await dbclient!.query("todos");
    return queryResult.map((e) => TodoModel.fromMap(e)).toList();
  }

  Future<bool> updateToDos(TodoModel todos) async {
    try {
      var dbclient = await database;
      await dbclient!.rawUpdate("UPDATE todos SET taskStatus=? WHERE id=?",
          [todos.taskStatus, todos.id]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
