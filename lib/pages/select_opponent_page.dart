import 'dart:convert';

import 'package:connectycube_sdk/connectycube_calls.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'call_screen.dart';

class SelectOpponentPage extends StatefulWidget {
  @override
  _SelectOpponentPageState createState() => _SelectOpponentPageState();
}

class _SelectOpponentPageState extends State<SelectOpponentPage> {
  final databaseReference =
      FirebaseDatabase.instance.reference().child('users').once();

  Set<int> _selectedUsers;
  P2PClient _callClient;
  P2PSession _currentCall;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Opponent'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: databaseReference,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DataSnapshot dataSnapshot = snapshot.data;
          Map map = dataSnapshot.value;

          List<CubeUser> usersList = [];

          map.forEach((key, value) {
            print('$key -> $value');
            usersList.add(CubeUser.fromJson(jsonDecode(value)));
          });
          return _usersList(usersList);
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget _usersList(List<CubeUser> usersList) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: usersList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: (){
                  _selectedUsers.clear();
                  _selectedUsers.add(usersList[index].id);
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(usersList[index].id.toString()),
                        Text(usersList[index].fullName),
                      ],
                    )
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 24),
              child: FloatingActionButton(
                heroTag: "VideoCall",
                child: Icon(
                  Icons.videocam,
                  color: Colors.white,
                ),
                backgroundColor: Colors.blue,
                onPressed: () {
                  _startCall(CallType.VIDEO_CALL, _selectedUsers);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 24),
              child: FloatingActionButton(
                heroTag: "AudioCall",
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                ),
                backgroundColor: Colors.green,
                onPressed: () {
                  _startCall(CallType.AUDIO_CALL, _selectedUsers);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedUsers = {};
    _initCustomMediaConfigs();
    _initCalls();
  }

  void _initCalls() {
    _callClient = P2PClient.instance;

    _callClient.init();

    _callClient.onReceiveNewSession = (callSession) {
      if (_currentCall != null &&
          _currentCall.sessionId != callSession.sessionId) {
        callSession.reject();
        return;
      }

      _showIncomingCallScreen(callSession);
    };

    _callClient.onSessionClosed = (callSession) {
      if (_currentCall != null &&
          _currentCall.sessionId == callSession.sessionId) {
        _currentCall = null;
      }
    };
  }

  void _startCall(int callType, Set<int> opponents) {
    if (opponents.isEmpty) return;

    P2PSession callSession = _callClient.createCallSession(callType, opponents);
    _currentCall = callSession;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationCallScreen(callSession, false),
      ),
    );
  }

  void _showIncomingCallScreen(P2PSession callSession) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(callSession),
      ),
    );
  }

  void _initCustomMediaConfigs() {
    RTCMediaConfig mediaConfig = RTCMediaConfig.instance;
    mediaConfig.minHeight = 720;
    mediaConfig.minWidth = 1280;
    mediaConfig.minFrameRate = 30;
  }

}
