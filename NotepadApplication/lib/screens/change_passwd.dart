import 'dart:convert';

import 'package:NotepadApplication/screens/note_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ChangePasswd extends StatefulWidget {
  @override
  _ChangePasswd createState() => _ChangePasswd();
}

class _ChangePasswd extends State<ChangePasswd> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final newpasswordController = TextEditingController();
  final newpassword2Controller = TextEditingController();

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
                  'Change password',
                  style: Theme.of(context).textTheme.headline5,
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
                  obscureText: true),
              TextField(
                  decoration: InputDecoration(
                    hintText: 'New password',
                  ),
                  controller: newpasswordController,
                  obscureText: true),
              TextField(
                  decoration: InputDecoration(
                    hintText: 'Confirm new password',
                  ),
                  controller: newpassword2Controller,
                  obscureText: true),
              SizedBox(height: 20),
              RaisedButton(
                color: Colors.purple[500],
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                onPressed: () async {
                  var isAuthorized = await _authUser(
                      this.loginController.text, this.passwordController.text);
                  if (isAuthorized == 0) {
                    _showAlertDialog('Status', 'Wrong username or password');
                    return;
                  }

                  if (validatePassword(passwordController.text) == false) {
                    _showAlertDialog(
                        'Status', 'Password must be at least 15 char long :)');
                    return;
                  }

                  if (newpasswordController.text !=
                      newpassword2Controller.text) {
                    newpassword2Controller.clear();
                    newpasswordController.clear();
                    _showAlertDialog('Status', 'New passwrods are not equal');
                    return;
                  }

                  _changeUserPassword(
                      this.loginController.text, this.passwordController.text);
                  Navigator.pop(context, true);

                },
                child: Text("Change user password"),
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

  void _changeUserPassword(String username, String newPassword) async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var bytes = utf8.encode(newPassword); // data being hashed
    var password_hashed = sha256.convert(bytes).toString();

    await secureStorage.write(key: username, value: password_hashed);
    _showAlertDialog('Status', 'Password chanegd successfully');
  }

  Future<int> _authUser(String username, String password) async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: username);

    var bytes = utf8.encode(password); // data being hashed
    var digest = sha256.convert(bytes).toString();

    if (!containsEncryptionKey) {
      _showAlertDialog('Status', 'User dont exist');
      return 0;
    } else {
      var userpass = await secureStorage.read(key: username);
      if (userpass == digest) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  bool validatePassword(String password) {
    if (password.length < 10) {
      return false;
    } else {
      return true;
    }
  }
}

//
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => NoteList(username)));
