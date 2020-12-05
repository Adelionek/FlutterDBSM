import 'dart:convert';

import 'package:NotepadApplication/screens/note_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
                    onPressed: () {
                      print(loginController.text);
                      print(passwordController.text);
                      String username = loginController.text;

                      if (loginController.text == 'admin' &&
                          passwordController.text == 'admin') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NoteList(username)));

                        //return NoteList();
                      } else {
                        loginController.clear();
                        passwordController.clear();
                        print(loginController.text);
                        print(passwordController.text);
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
    var containsEncryptionKey = await secureStorage.containsKey(key: username);

    if (containsEncryptionKey){
      _showAlertDialog(
          'Status', 'Username already taken');
    }else{
      await secureStorage.write(key: username, value: password);
      _showAlertDialog(
          'Status', 'User created successfully');
    }
  }
}
