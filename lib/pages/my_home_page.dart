import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:video_demo/pages/login_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final firebaseDatabase = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyHomePage'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: Text('Login Screen'),
          ),
        ],
      ),
    );
  }

  void _writeData() {
    firebaseDatabase.child('users').set({'user_id1': '1'}).then(
      (value) {},
      onError: (error) {
        print('error = ' + error.toString());
      },
    );
  }

  void _readData() {
    firebaseDatabase.child('users').once().then(
      (DataSnapshot snapshot) {
        print(snapshot.value['user_id1']);
      },
    );
  }

  void _deleteData() {
    firebaseDatabase.child('users').remove();
  }
}
