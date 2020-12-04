import 'package:NotepadApplication/screens/note_detail.dart';
import 'package:flutter/material.dart';
import 'package:NotepadApplication/screens/note_list.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async{

  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // print("printed text");
    // Box box;
    //
    // Future openBox() async {
    //   await Hive.initFlutter();
    //   box = await Hive.openBox('database');
    //   return;
    // }
    //
    // openBox();
    //
    // void putData(){
    //   box.put('name', 'value');
    //   box.add("value");
    // }
    //
    // void getdata(){
    //   print(box.get('name'));
    // }
    //
    // getdata();
    // putData();
    // getdata();
    //

























    return MaterialApp(
      title: "NoteKeeper",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple
      ),
      home: NoteList(),
    );
  }
}
