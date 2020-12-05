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



class MyApp extends StatelessWidget {
  var encryptionKey;
  Box<HiveNote> encryptedBox;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "NoteKeeper",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple
      ),
      home: FutureBuilder(
        future: openBox(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasError)
              return Text('Error');
            else
              return MyLogin();
          }
          else
            return Scaffold();
        },

      ),
    );
  }



  Future openBox() async {

    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();
      print("Generating key");
      await secureStorage.write(key: 'key', value: base64UrlEncode(key));
    }
    encryptionKey = base64Url.decode(await secureStorage.read(key: 'key'));

    encryptedBox = await Hive.openBox('vaultBox', encryptionCipher: HiveAesCipher(encryptionKey));
    //encryptedBox.clear();

    return;
  }

}
