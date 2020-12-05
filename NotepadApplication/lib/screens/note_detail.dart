import 'package:NotepadApplication/encryption.dart';
import 'package:NotepadApplication/models/hive.model.dart';
import 'package:NotepadApplication/screens/login.dart';
import 'package:NotepadApplication/screens/note_list.dart';
import 'package:NotepadApplication/utils/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:NotepadApplication/models/note.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  final HiveNote hiveNote;

  NoteDetail(this.note, this.hiveNote, this.appBarTitle);

  @override
  // need to pass values to create
  _NoteDetailState createState() =>
      _NoteDetailState(this.note, this.hiveNote, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  String appBarTitle;
  Note note;
  HiveNote hiveNote;

  Box<HiveNote> encryptedBox;

  @override
  void initState(){
    super.initState();
    encryptedBox = Hive.box('vaultBox');
  }

  var _formKey = GlobalKey<FormState>();
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();

  _NoteDetailState(this.note, this.hiveNote, this.appBarTitle);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;

    titleController.text = hiveNote.title;
    descriptionController.text = hiveNote.description;

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded),
              onPressed: () {
                moveToLastScreen();
              },
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: ListView(
                  children: <Widget>[
                    //First element - dropdown button
                    ListTile(
                      title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem));
                        }).toList(),
                        style: textStyle,
                        value: getPriorityAsString(note.priority),
                        onChanged: (valueSelectedByUser) {
                          setState(() {
                            debugPrint('User selected $valueSelectedByUser');
                            updatePriorityAsInt(valueSelectedByUser);
                          });
                        },
                      ),
                    ),

                    //Second element - title field
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: titleController,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter some title";
                          }
                          return null;
                        },
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint('Something changed in title text field');
                          updateTitle();
                          updateHiveNoteTitle();
                        },
                        decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),

                    //Third element - description field
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: descriptionController,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter some description";
                          }
                          return null;
                        },
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint(
                              'Something changed in description text field');
                          updateDescription();
                          updateHiveNoteDescription();
                        },
                        decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),

                    //Fourth element
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              //save button
                              child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Save',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  debugPrint("Save button clicked");
                                  _saveHiveNote();
                                  //_save();
                                });
                              }
                            },
                          )),
                          Container(
                            width: 5.0,
                          ),
                          Expanded(
                              //delete button
                              child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  debugPrint("Delete button clicked");
                                  _deleteHiveNote();
                                  //_delete();
                                });
                              }
                            },
                          ))
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          color: Colors.red[600],
                          textColor: Colors.white,
                          onPressed: () {
                            // CODE TO ENCRYPT
                          },
                          child: Text("SaveToEncrypedDB"),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        RaisedButton(
                          color: Colors.green[500],
                          textColor: Colors.white,
                          onPressed: () {
                            navigateToLogin();
                          },
                          child: Text("Delete"),
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        ));
  }

  void moveToLastScreen() {
    // true will be passed to note_list, after adding/deleting note it will invoke updateListView()
    Navigator.pop(context, true);
  }

  //convert string priority to int
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //converts int priority to int
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  //helper functions to update title
  void updateTitle() {

    note.title = titleController.text;
  }

  void updateHiveNoteTitle(){
    hiveNote.title = titleController.text;
  }

  //helper functions to update description
  void updateDescription() {

    note.description = descriptionController.text;
  }
  void updateHiveNoteDescription(){
    hiveNote.description = titleController.text;

  }

  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;

    if (note.id != null) {
      //update note
      result = await helper.updateNote(note);
    } else {
      // add new note
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Note saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem saving note');
    }
  }

  void _saveHiveNote() {
    moveToLastScreen();
    int id = 0;
    if (hiveNote.id == null) {
      if (encryptedBox.isNotEmpty) {
        id = encryptedBox.keys.last;
        hiveNote.id = id + 1;
      } else {
        hiveNote.id = 0;
      }
      hiveNote.priority = 1;
      hiveNote.title = titleController.text;
      hiveNote.description = descriptionController.text;
      hiveNote.date = DateFormat.yMMMd().format(DateTime.now());
      encryptedBox.add(hiveNote);
      print('HIVE NOTE ADDED!!');
    }else{

      hiveNote.priority = 1;
      hiveNote.title = titleController.text;
      hiveNote.description = descriptionController.text;
      hiveNote.date = DateFormat.yMMMd().format(DateTime.now());
      encryptedBox.putAt(hiveNote.id, hiveNote);
      print('HIVE NOTE EDITED!!');
    }

  }


  void _deleteHiveNote()  {
    moveToLastScreen();
    if (hiveNote.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }else{
      encryptedBox.deleteAt(hiveNote.id);
      _showAlertDialog('Status', 'Note deleted Successfully');
    }
  }


  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      //delete existing note
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }
    int result = await helper.deleteNote(note.id);

    if (result != 0) {
      _showAlertDialog('Status', 'Note deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Problem with deleting note');
    }
  }

  void navigateToLogin() async {
    debugPrint("ListTitle clicked");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyLogin()),
    );
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }


  void addHiveNote(HiveNote note){
    Hive.box('vaultBox').add(note);
  }




}
