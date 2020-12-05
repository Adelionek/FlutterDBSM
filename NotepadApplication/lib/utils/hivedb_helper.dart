import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

//
class HiveDbHelper {
  static HiveDbHelper _databaseHelper; //Singleton DatabaseHelper

  //
  // var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
  // if (!containsEncryptionKey) {
  // var key = Hive.generateSecureKey();
  // print("Generating key");
  // await secureStorage.write(key: 'key', value: base64UrlEncode(key));
  // }

  HiveDbHelper._createInstance();

  static final HiveDbHelper _instance = HiveDbHelper._createInstance();

  factory HiveDbHelper() {
    return _instance;
  }

  Future openBox(var encryptionKey) async
  {

    Box encryptedBox = await Hive.openBox('vaultBox', encryptionCipher: HiveAesCipher(encryptionKey));

    var values = encryptedBox.values;
    var map = encryptedBox.toMap();

    return map;


  }

  Future getHiveNoteMapList(var encryptionKey) async {

    Box encryptedBox = await Hive.openBox('vaultBox', encryptionCipher: HiveAesCipher(encryptionKey));

    var values = encryptedBox.values;
    var noteMapList = encryptedBox.values;

    return noteMapList;

  }


  }




