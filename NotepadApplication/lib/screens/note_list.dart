import 'package:NotepadApplication/screens/note_detail.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:NotepadApplication/models/note.dart';
import 'package:NotepadApplication/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:NotepadApplication/screens/login.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {

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
              navigateToLogin();
              //navigateToDetail(this.noteList[position],'Edit note');
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

  void navigateToLogin() async {
    debugPrint("ListTitle clicked");
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyLogin()),
    );
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
