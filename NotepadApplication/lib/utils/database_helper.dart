import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:NotepadApplication/models/note.dart';


class DatabaseHelper{

  static DatabaseHelper _databaseHelper; //Singleton DatabaseHelper
  static Database _database; // Singleton database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); //Named constructor to create db helper

  factory DatabaseHelper(){
    if (_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

    if(_database == null){
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //open/create database
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {

    String sql = 'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,'
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)';
    await db.execute(sql);
  }


  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote (Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  Future<int> updateNote (Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote (int noteId) async {
    Database db = await this.database;
    var result = await db.delete(noteTable, where: '$colId = ?', whereArgs: [noteId]);
    return result;
  }

  //Get number of notes in db
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('Select Count (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  // get the list of Map<String, dynamic> and convert it to List<Note>
  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList(); // get map list from db
    int count = noteMapList.length; // count number of map entries
    List<Note> noteList = List<Note>();

    for (int i=0; i<count; i++ ){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }





}