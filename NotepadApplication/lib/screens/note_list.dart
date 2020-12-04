import 'dart:convert';

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
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {

  Box encryptedBox;
  Box normalBox;
  // TODO change this
  static var encryptionKey;



  @override
    void initState(){
      super.initState();
      Hive.registerAdapter(HiveNoteAdapter());
      openBox();
    }


  Future openBox() async {


    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    normalBox = await Hive.openBox('normalBox');



    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();



    var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();
      print("Generating key");
      await secureStorage.write(key: 'key', value: base64UrlEncode(key));
    }


    print(base64Url.decode(await secureStorage.read(key: 'key')));

    encryptionKey = base64Url.decode(await secureStorage.read(key: 'key'));
    print('Encryption key: $encryptionKey');

    encryptedBox = await Hive.openBox('vaultBox', encryptionCipher: HiveAesCipher(encryptionKey));

    print(encryptedBox.toMap());
    var keys = encryptedBox.keys;
    var noteId;

    if (!encryptedBox.isEmpty){
      noteId = keys.last+1;
    }else{
      noteId = 0;

    }

    HiveNote hiveNote = HiveNote(int.parse(noteId.toString()),
        'tytulHive',
        DateFormat.yMMMd().format(DateTime.now()),
        1,
        'Hive note description');

    var len = encryptedBox.length;
    encryptedBox.add(hiveNote);
    print(encryptedBox.toMap());

    print(1);

    return;
  }


  void putData(){
    //encryptedBox.put('name2', 'value2');
    //encryptedBox.add('value auto index');
  }

  void getdata(){
   // String name = encryptedBox.get('name2');
 //   var values = encryptedBox.values;
  // var map = encryptedBox.toMap();

   // print(name);

  // print(map);

  }






  DatabaseHelper databaseHelper = DatabaseHelper();
  HiveDbHelper hiveDbHelper = HiveDbHelper();
  List<Note> noteList;
  int count = 0;

  /////// HIVE



  Future<Map<dynamic, dynamic>> _getNotes() async{
    var notes = await hiveDbHelper.openBox(encryptionKey);
    return notes;
  }

    ////////






  @override
  Widget build(BuildContext context) {
    // putData();
    // getdata();



    if (noteList == null){
      noteList = List<Note>();
      updateListView();
    }



    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),

      //returns list view of notes
      body: getNoteListView(),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          navigateToDetail(Note('','',2),'Add note');
        },
        tooltip: 'Add note',

        child: Icon(Icons.add),
      ),
    );
  }

  ListView  getNoteListView(){
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position){
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(this.noteList[position].title),
            subtitle: Text(this.noteList[position].date),
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey),
              onTap: (){
                _delete(context, noteList[position]);
              },
            ),
            onTap: (){
              // encryptedBox.put('key', 'this is my note');
              // print(encryptedBox.get('key'));
              _getNotes();
              putData();
              getdata();


              navigateToDetail(this.noteList[position],'Edit note');
            },
          )
        );
      },
    );
  }

  // Returns priority color
  Color getPriorityColor(int priority){
    switch (priority){
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
  Icon getPriorityIcon(int priority){
    switch (priority){
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

  void _delete(BuildContext context, Note note) async{
    int result = await databaseHelper.deleteNote(note.id);
    if(result != 0){
      _showSnackBar(context, 'Note deleted successfully');
      updateListView();
    }
  }


  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }


  void navigateToDetail(Note note, String title) async {
    debugPrint("ListTitle clicked");
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){
      return NoteDetail(note, title);
    }));
    if (result == true){
      updateListView();
    }
  }




  void updateListView(){

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });

  }

}
