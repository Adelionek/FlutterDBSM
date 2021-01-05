import 'dart:convert';

import 'package:NotepadApplication/models/hive.model.dart';
import 'package:NotepadApplication/screens/note_detail.dart';
import 'package:flutter/material.dart';
import 'package:NotepadApplication/screens/note_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:NotepadApplication/screens/login.dart';


void main() async{

  await Hive.initFlutter();
  Hive.registerAdapter(HiveNoteAdapter());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //var encryptionKey;
  //Box<HiveNote> encryptedBox;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "NoteKeeper",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple
      ),

      home: MyLogin(),


      // home: FutureBuilder(
      //   future: openBox(),
      //   builder: (BuildContext context, AsyncSnapshot snapshot){
      //     if(snapshot.connectionState == ConnectionState.done){
      //       if(snapshot.hasError)
      //         return Text('Error');
      //       else
      //         return MyLogin();
      //     }
      //     else
      //       return Scaffold();
      //   },
      //
      // ),
    );
  }
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }}
