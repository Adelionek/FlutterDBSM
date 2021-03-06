import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(MyApp());
}


class PermissionsService {
  final PermissionHandler _permissionHandler = PermissionHandler();

  Future<bool> _requestPermission(PermissionGroup permission) async {
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  /// Requests the users permission to read their contacts.
  Future<bool> requestContactsPermission() async {
    return _requestPermission(PermissionGroup.contacts);
  }
  /// Requests the users permission to read their location when the app is in use
  Future<bool> requestLocationPermission() async {
    return _requestPermission(PermissionGroup.locationWhenInUse);
  }

  /// Requests the users permission to read their contacts.
  // Future<bool> requestContactsPermission() async {
  //   var granted = await _requestPermission(PermissionGroup.contacts);
  //   if (!granted) {
  //     onPermissionDenied();
  //   }
  //   return granted;
  // }

  Future<bool> hasContactsPermission() async {
    return hasPermission(PermissionGroup.contacts);
  }
  Future<bool> hasPermission(PermissionGroup permission) async {
    var permissionStatus =
    await _permissionHandler.checkPermissionStatus(permission);
    return permissionStatus == PermissionStatus.granted;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: Center(
            child: MaterialButton(
              color: Colors.yellow[300],
              child: Text('Request contacts permission'),
              onPressed: () {
                PermissionsService().requestContactsPermission(
                    // onPermissionDenied: () {
                    //   print('Permission has been denied');
                    // }
                    );
              },
            ),
          ),
        ));
  }
}



