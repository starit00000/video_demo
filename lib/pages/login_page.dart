import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_demo/pages/select_opponent_page.dart';
import 'package:video_demo/utils/config.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _nameController = TextEditingController();
  var _loginController = TextEditingController();

  ProgressDialog progresDialog;

  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    progresDialog = ProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('SignUp'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Full name'),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: TextField(
              controller: _loginController,
              decoration: InputDecoration(hintText: 'Login key'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _signUpUser();
            },
            child: Text('SignUp'),
          ),
          Text('or'),
          ElevatedButton(
            onPressed: () {
              var user = CubeUser(
                  password: DEFAULT_PASS,
                  login: 'x',
                  id: 3727618,
                  fullName: 'x',);

              /*var user = CubeUser(
                password: DEFAULT_PASS,
                login: 'y',
                id: 3727946,
                fullName: 'y',
              );*/

              _loginToCC(context, user);
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  _loginToCC(BuildContext context, CubeUser user) {
    progresDialog.show();

    if (CubeSessionManager.instance.isActiveSessionValid()) {
      print('session valid');
      _loginToCubeChat(context, user);
    } else {
      print('session invalid');
      createSession(user).then(
        (cubeSession) {
          _loginToCubeChat(context, user);
        },
      ).catchError(_processLoginError);
    }
  }

  void _loginToCubeChat(BuildContext context, CubeUser user) {
    CubeChatConnection.instance.login(user).then(
      (cubeUser) {
        /*setState(() {
        _isLoginContinues = false;
        _selectedUserId = 0;
      });*/
        _checkUserActivityInFirebase(cubeUser);
      },
    ).catchError(_processLoginError);
  }

  void _processLoginError(exception) {
    //log("Login error $exception", TAG);

    /*setState(
          () {
        _isLoginContinues = false;
        _selectedUserId = 0;
      },
    );*/

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Error"),
          content: Text("Something went wrong during login to ConnectyCube"),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  void _goSelectOpponentsScreen(BuildContext context, CubeUser cubeUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectOpponentPage(),
      ),
    );
  }

  void _signUpUser() {
    var fullName = _nameController.text.trim();
    var userName = _loginController.text.trim();

    signUp(
      CubeUser(fullName: fullName, login: userName, password: DEFAULT_PASS),
    ).then(
      (user) {
        print('After sign up user = ${jsonEncode(user)}');
      },
    );
  }

  void _checkUserActivityInFirebase(CubeUser user) {
    progresDialog.hide();
    print('cube user after login = ${jsonEncode(user)}');

    var userRef = databaseReference.child('users').child(user.id.toString());
    userRef.once().then((snapshot) {
      print('user in firebase = ${snapshot.key} -> ${snapshot.value}');
      if (snapshot.value == null) {
        userRef.set(jsonEncode(user)).then((value) {
          _goSelectOpponentsScreen(context, user);
        });
      } else {
        CubeUser cubeUser = CubeUser.fromJson(jsonDecode(snapshot.value));
        print('final user from firebase = ${jsonEncode(cubeUser)}');
        _goSelectOpponentsScreen(context, user);
      }
    });
  }
}
