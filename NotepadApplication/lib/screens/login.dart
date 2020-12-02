import 'package:flutter/material.dart';

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
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headline3,
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
              RaisedButton(
                color: Colors.yellow,
                child: Text('ENTER'),
                onPressed: () {
                  if (loginController.text == 'admin' && passwordController.text == 'admin'){
                    Navigator.pop(context, true);

                  }
                  else{
                    loginController.clear();
                    passwordController.clear();
                    print(loginController.text);
                    print(passwordController.text);
                  }

                },
              )
            ],
          ),
        ),
      ),
    );
  }
}