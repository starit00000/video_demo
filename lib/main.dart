import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:video_demo/pages/my_home_page.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:video_demo/utils/config.dart' as config;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    init(
      config.APP_ID,
      config.AUTH_KEY,
      config.AUTH_SECRET
    );
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}
