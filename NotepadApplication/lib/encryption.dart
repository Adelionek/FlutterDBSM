import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';

class MyEncryptionDecryption{

  //AES
  // TODO save key in secure storage
  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(AES(key, mode: encrypt.AESMode.cbc));

  static encryptAES(text){
    final encrypted = encrypter.encrypt(text, iv: iv);

    print(encrypted.bytes);
    print(encrypted.base16);
    print(encrypted.base64);
    return encrypted;
  }

  static decryptAES(text){
    return encrypter.decrypt(text, iv: iv);
  }
}