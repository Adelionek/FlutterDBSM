import 'dart:convert';
import 'dart:typed_data';

import 'package:NotepadApplication/screens/note_detail.dart';
import 'package:NotepadApplication/utils/hivedb_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:NotepadApplication/models/note.dart';
import 'package:NotepadApplication/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:NotepadApplication/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:NotepadApplication/models/hive.model.dart';
import 'dart:math';

class NoteList extends StatefulWidget {
  final String userName;

  NoteList(this.userName);

  @override
  _NoteListState createState() => _NoteListState(this.userName);

}

class _NoteListState extends State<NoteList> {
  Box<HiveNote> encryptedBox;
  String userName;
  _NoteListState(this.userName);

  // TODO change this
  static var encryptionKey;

  @override
  void initState() {
    super.initState();
    encryptedBox = Hive.box('vaultBox');
    print(encryptedBox.length);
  }

  // Future openBox() async {
  //
  //   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  //   var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
  //   if (!containsEncryptionKey) {
  //     var key = Hive.generateSecureKey();
  //     print("Generating key");
  //     await secureStorage.write(key: 'key', value: base64UrlEncode(key));
  //   }
  //
  //   encryptionKey = base64Url.decode(await secureStorage.read(key: 'key'));
  //   encryptedBox = await Hive.openBox('vaultBox', encryptionCipher: HiveAesCipher(encryptionKey));
  //
  //   return;
  // }

  DatabaseHelper databaseHelper = DatabaseHelper();
  HiveDbHelper hiveDbHelper = HiveDbHelper();
  List<Note> noteList;
  List<HiveNote> hiveNoteList;
  HiveNote hiveNote;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
      print('count from 1st functoin:$count');
      //updateHiveListView();
    }

    if (hiveNoteList == null) {
      hiveNoteList = List<HiveNote>();
      updateHiveListView();
      print('count from 2nd functoin:$count');

    }


    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),

      //returns list view of notes

      body: getHiveNoteListView(),
      //body: _buildListView(),

      //body: getNoteListView(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(
              Note('', '', 2),
              HiveNote(
                  null, '', DateFormat.yMMMd().format(DateTime.now()), 1, ''),
              'Add note');
        },
        tooltip: 'Add note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getHiveNoteListView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (context, index) {

          Map<dynamic, dynamic> raw = encryptedBox.toMap();

          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.ac_unit),
              ),
              title: Text(this.hiveNoteList[index].title),
              subtitle: Text(this.hiveNoteList[index].description),
              trailing: GestureDetector(
                child: Icon(Icons.delete, color: Colors.grey),
                // ON TAP OF DELETE ICON
                onTap: () {
                  //_delete(context, noteList[position]);
                },
              ),

              // ON TAP OF LISTED NOTE
              onTap: () {

                navigateToDetail(this.noteList[0], hiveNoteList[index], 'Edit note');
              },
            ),
          );
          final hiveNote = encryptedBox.get(index) as HiveNote;

          return ListTile(
            title: Text(hiveNote.title),
            subtitle: Text(hiveNote.description),
          );
        });
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(this.noteList[position].title),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                child: Icon(Icons.delete, color: Colors.grey),
                onTap: () {
                  _delete(context, noteList[position]);
                },
              ),
              onTap: () {
                navigateToDetail(
                    this.noteList[position], hiveNote, 'Edit note');
              },
            ));
      },
    );
  }

  // Returns priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  //Returns priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.warning_amber_rounded);
        break;
      case 2:
        return Icon(Icons.arrow_forward_ios_rounded);
        break;
      default:
        return Icon(Icons.arrow_forward_ios_rounded);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note deleted successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, HiveNote hiveNote, String title) async {
    debugPrint("ListTitle clicked");
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, hiveNote, title);
    }));
    if (result == true) {
      //updateListView();
      updateHiveListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          //this.count = noteList.length;
        });
      });
    });
  }

  void updateHiveListView() async{

    Map<dynamic, dynamic> raw = encryptedBox.toMap();
    List<HiveNote> hiveList = raw.values.toList();
    setState(() {
      this.hiveNoteList = hiveList;
      this.count = hiveList.length;
    });




  }

  ListView _buildListView() {
    //final Box encryptedBox = Hive.box('vaultBox');

    return ListView.builder(
        itemCount: encryptedBox.length,
        itemBuilder: (context, index) {
          final note = encryptedBox.getAt(index) as HiveNote;
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.description),
          );
        });
  }

  Future<Uint8List> getEnctyptionKey() async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var encryptionKey = base64Url.decode(await secureStorage.read(key: 'key'));
    return encryptionKey;
  }

  Future<Map<dynamic, dynamic>> _getNotes() async {
    var notes = await hiveDbHelper.openBox(encryptionKey);
    return notes;
  }

  Future<List<HiveNote>> _getHiveNoteMapList() async {
    var noteMapList = await hiveDbHelper.getHiveNoteMapList(encryptionKey);
    return noteMapList;
  }

  void putData() {
    //encryptedBox.put('name2', 'value2');
    //encryptedBox.add('value auto index');
  }

  void getdata() {
    // String name = encryptedBox.get('name2');
    //   var values = encryptedBox.values;
    // var map = encryptedBox.toMap();

    // print(name);

    // print(map);
  }
}
