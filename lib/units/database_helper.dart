import 'package:notekeeper/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper {
  static  Database _database="null" as Database;
  static DatabaseHelper _databaseHelper= "null" as DatabaseHelper; //SINGLETON DBHELPER
  DatabaseHelper._createInstance(); //NAMED CONST TO CREATE INSTANCE OF THE DBHELPER

  String noteTable = 'note_table';
  String colid = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colPriority = 'priority';

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper =
          DatabaseHelper._createInstance(); //EXEC ONLY ONCE (SINGLETON OBJ)
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //GET THE PATH TO THE DIRECTORY FOR IOS AND ANDROID TO STORE DB
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "note.db";

    //OPEN/CREATE THE DB AT A GIVEN PATH
    var notesDatabase =
    await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colid INTEGER PRIMARY KEY AUTOINCREMENT,'
            '$colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  //FETCH TO GET ALL NOTES
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result =
    db.rawQuery("SELECT * FROM $noteTable ORDER BY $colPriority ASC");
//    var result = await db.query(noteTable, orderBy: "$colPriority ASC");  //WORKS THE SAME CALLED HELPER FUNC
    return result;
  }

  //INSERT OPS
  Future<int> insertNote(Note note) async
  {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //UPDATE OPS
  Future<int> updateNote(Note note) async
  {
    var db = await this.database;
    var result =
    await db.update(noteTable, note.toMap(), where: '$colid = ?', whereArgs: [note.id]);
    return result;
  }

  //DELETE OPS
  Future<int> deleteNote(int id) async
  {
    var db = await this.database;
    int result = await db.delete(noteTable, where:"$colid = ?", whereArgs: [id]);
    return result;
  }

  //GET THE NO:OF NOTES
  Future<int?> getCount() async
  {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery("SELECT COUNT (*) FROM $noteTable");
    int? result = Sqflite.firstIntValue(x);
    return result;
  }

  //GET THE 'MAP LIST' [List<Map>] and CONVERT IT TO 'Note List' [List<Note>]
  Future<List<Note>> getNoteList() async
  {
    var noteMapList = await getNoteMapList(); //GET THE MAPLIST FROM DB
    int count = noteMapList.length; //COUNT OF OBJS IN THE LIST
    List<Note> noteList = <Note>[];
    for(int index=0; index<count; index++)
    {
      noteList.add(Note.fromMapObject(noteMapList[index]));
    }
    return noteList;
  }
}