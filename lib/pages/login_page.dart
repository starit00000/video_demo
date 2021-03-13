import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:video_demo/pages/select_opponent_page.dart';
import 'package:video_demo/utils/config.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _nameController = TextEditingController();
  var _loginController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignUp'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
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
        ElevatedButton(
          onPressed: () {
            var user = CubeUser(password: DEFAULT_PASS, login: 'x', id: 3727618, fullName: 'x');
            _loginToCC(context, user);
          },
          child: Text('Login'),
        ),
      ],
    );
  }

  _loginToCC(BuildContext context, CubeUser user) {
    //if (_isLoginContinues) return;

    /*setState(
          () {
        _isLoginContinues = true;
        _selectedUserId = user.id;
      },
    );*/

    if (CubeSessionManager.instance.isActiveSessionValid()) {
      _loginToCubeChat(context, user);
    } else {
      createSession(user).then(
        (cubeSession) {
          _loginToCubeChat(context, user);
        },
      ).catchError(_processLoginError);
    }
  }

  void _loginToCubeChat(BuildContext context, CubeUser user) {
    CubeChatConnection.instance.login(user).then((cubeUser) {
      /*setState(() {
        _isLoginContinues = false;
        _selectedUserId = 0;
      });*/
      _goSelectOpponentsScreen(context, cubeUser);
      print('cube user after login = ${jsonEncode(cubeUser)}');
    }).catchError(_processLoginError);
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
}
