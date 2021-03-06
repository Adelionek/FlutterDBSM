import 'dart:convert';
import 'package:NotepadApplication/models/hive.model.dart';
import 'package:NotepadApplication/screens/change_passwd.dart';
import 'package:NotepadApplication/screens/note_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:is_lock_screen/is_lock_screen.dart';

class MyLogin extends StatefulWidget {
  @override
  _MyLogin createState() => _MyLogin();
}

class _MyLogin extends State<MyLogin> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

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
                  obscureText: true),

              SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                      color: Colors.green,
                      child:
                          Text(_isAuthenticating ? 'Cancel' : 'Login touchId'),
                      onPressed: () async {


                        String username = loginController.text;
                        await _checkBiometrics();
                        if (_canCheckBiometrics == false) return;
                        await _getAvailableBiometrics();
                        var fid = _availableBiometrics[0].index;


                        final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
                        var containsEncryptionKey = await secureStorage.containsKey(key: username);
                        if (!containsEncryptionKey){
                          _showAlertDialog('Status', 'User dont exist');
                          return;
                        }

                        _isAuthenticating
                            ? _cancelAuthentication()
                            : await _authenticate(username, fid);
                        if (_authorized == 'Authorized') {
                          await openBox("vaultBox");
                          passwordController.clear();
                          loginController.clear();
                          bool result = await
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NoteList(username)));
                          if (result){
                            _authorized = 'Not Authorized';
                          }
                          //return NoteList();
                        } else {
                          _showAlertDialog('Status', 'Wrong fingeprint');
                        }
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  RaisedButton(
                    color: Colors.green,
                    child: Text('Login password'),
                    onPressed: () async {

                      var username = loginController.text;
                      var isAuth = await _authUser(loginController.text, passwordController.text);
                      print(isAuth);
                      passwordController.clear();
                      loginController.clear();
                      if (isAuth){
                        await openBox("vaultBox");
                        passwordController.clear();
                        loginController.clear();
                        bool result = await
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NoteList(username)));
                        if (result){
                          _authorized = 'Not Authorized';
                        }
                        //return NoteList();
                      }
                    },
                  ),

                ],
              ),
              RaisedButton(
                color: Colors.yellow,
                child: Text('Register'),
                onPressed: () async {
                  //await getUsers();
                await _registerUser(loginController.text, passwordController.text);
                // await getUsers();
                  // _registerUserWithFingerprint(loginController.text);
                },
              ),
              RaisedButton(
                color: Colors.purple[500],
                textColor: Colors.white,
                onPressed: () {
                  _cancelAuthentication();
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => ChangePasswd()));
                },
                child: Text("Change user password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _cancelAuthentication() {
    print(_authorized);
  }

  Future<void> getUsers() async {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  //await secureStorage.deleteAll();
  print(secureStorage.readAll());
  //var users = await secureStorage.readAll();
  //print(users.length);
}


  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      if (await isLockScreen() == true) {
        canCheckBiometrics = false;
      } else {
        canCheckBiometrics = await auth.canCheckBiometrics;
      }
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate(String username, int fid) async {
    bool authenticated = false;

    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: username);





    if (!containsEncryptionKey) {
      _showAlertDialog('Status', 'User dont exist');
      return 0;
    }else {
      //var userpass = await secureStorage.read(key: username);
      var userpass = await secureStorage.read(key: username+"Fng");
      if (userpass != fid.toString()) {
        _showAlertDialog('Status', 'WrongTouchId');
        return 0;
      } else {

        try {
          setState(() {
            _isAuthenticating = true;
            _authorized = 'Authenticating';
          });
          authenticated = await auth.authenticateWithBiometrics(
              localizedReason: 'Scan your fingerprint to authenticate',
              useErrorDialogs: true,
              stickyAuth: true);
          setState(() {
            _isAuthenticating = false;
            _authorized = 'Authenticating';
          });
        } on PlatformException catch (e) {
          print(e);
        }
        if (!mounted) return;

        final String message = authenticated ? 'Authorized' : 'Not Authorized';
        setState(() {
          _authorized = message;
        });
      }
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future _registerUser(String username, String password) async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var bytes = utf8.encode(password); // data being hashed
    var password_hashed = sha256.convert(bytes).toString();
    var containsEncryptionKey = await secureStorage.containsKey(key: username);

    if (containsEncryptionKey) {
      _showAlertDialog('Status', 'Username already taken');
      passwordController.clear();
      loginController.clear();
    } else {
    var users = await secureStorage.readAll();
    print(users.length);

      await secureStorage.write(key: username, value: password_hashed);
      await secureStorage.write(key: username + "Fng", value: (users.length+1).toString());

      _showAlertDialog('Status', 'User created successfully');
    passwordController.clear();
    loginController.clear();

    }
  }

  void _registerUserWithFingerprint(String username) async {
    await _getAvailableBiometrics();
    var biometric = _availableBiometrics[0];

    if (_availableBiometrics.length < 2){
      _showAlertDialog('Status', 'No fingerprints available');

      return;
    }

    if (biometric == null) {
      _showAlertDialog('Status', 'No fingerprints available');
      return;
    }
    if (await isLockScreen() == true) {
      return;
    }

    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: username);

    var bytes = utf8.encode( biometric.index.toString()); // data being hashed
    var index_hashed = sha256.convert(bytes).toString();


    if (containsEncryptionKey) {
      _showAlertDialog('Status', 'Username already taken');
    } else {
      await secureStorage.write(
          key: username, value: index_hashed);
      _showAlertDialog('Status', 'User created successfully');
    }
  }

  Future openBox(String boxName) async {
    String key;
    if (boxName == 'biometricsData')
      key = 'biokey';
    else
      key = 'key';

    if (await isLockScreen() == true) {
      return;
    } else {
      final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
      var containsEncryptionKey = await secureStorage.containsKey(key: key);
      if (!containsEncryptionKey) {
        var keyGen = Hive.generateSecureKey();
        print("Generating key");
        await secureStorage.write(key: key, value: base64UrlEncode(keyGen));
      }

      var encryptionKey = base64Url.decode(await secureStorage.read(key: key));
      if (!Hive.isBoxOpen(boxName)) {
        Box<HiveNote> encryptedBox = await Hive.openBox(boxName,
            encryptionCipher: HiveAesCipher(encryptionKey));
      }
    }

    return;
  }

  Future<bool> _authUser(String username, String password) async {
    if (await isLockScreen() == true) {
      return false;
    }

    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: username);
    print(containsEncryptionKey);

    var bytes = utf8.encode(password); // data being hashed
    var digest = sha256.convert(bytes).toString();

    if (!containsEncryptionKey) {
      _showAlertDialog('Status', 'User dont exist');
      return false;
    } else {
      var userpass = await secureStorage.read(key: username);
      if (userpass == digest) {
        return true;
      } else {
        return false;
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
