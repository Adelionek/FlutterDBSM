import 'dart:convert';

import 'package:NotepadApplication/screens/note_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class MyLogin extends StatefulWidget {
  @override
  _MyLogin createState() => _MyLogin();
}

class _MyLogin extends State<MyLogin> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headline2,
                  textAlign: TextAlign.center,
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Username',
                ),
                controller: loginController,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                controller: passwordController,
                obscureText: true
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    color: Colors.green,
                    child: Text('ENTER'),
                    onPressed: () async {
                      String username = loginController.text;
                      String password = loginController.text;

                      var isAuthorized = await _authUser(username, password);


                      if (isAuthorized == 1) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NoteList(username)));

                        //return NoteList();
                      } else {

                      }
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  RaisedButton(
                    color: Colors.yellow,
                    child: Text('Register'),
                    onPressed: () {
                      _registerUser(loginController.text,
                          passwordController.text);
                      loginController.clear();
                      passwordController.clear();
                    },
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void _registerUser(String username, String password) async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var bytes = utf8.encode(password); // data being hashed
    var password_hashed = sha256.convert(bytes).toString();
    var containsEncryptionKey = await secureStorage.containsKey(key: username);


    if (containsEncryptionKey){
      _showAlertDialog(
          'Status', 'Username already taken');
    }else{
      await secureStorage.write(key: username, value: password_hashed);
      _showAlertDialog(
          'Status', 'User created successfully');
    }
  }

  Future<int> _authUser(String username, String password) async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: username);

    var bytes = utf8.encode(password); // data being hashed
    var digest = sha256.convert(bytes).toString();

    if (!containsEncryptionKey){
      _showAlertDialog(
          'Status', 'User dont exist');
      return 0;
    }else{
      var userpass = await secureStorage.read(key: username);
      if (userpass == digest){
        return 1;
      }else{
        return 0;
      }
    }
  }


}
