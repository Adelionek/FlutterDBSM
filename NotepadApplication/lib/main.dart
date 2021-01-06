import 'package:NotepadApplication/models/hive.model.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "NoteKeeper",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple
      ),

      home: MyLogin(),

    );
  }
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }}
