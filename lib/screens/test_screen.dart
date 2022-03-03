import 'dart:developer';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import '../widgets/AppDrawer.dart';

class TestScreen extends StatefulWidget {
  TestScreen();

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _accessToken;
  String _userName;

  @override
  void initState() {
    _isSignedIn();
    _fetchSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SongPoint detail"),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: Text(_accessToken)),
      ),
    );
  }

  Future<String> _fetchSession() async {
    try {
      AuthSession res = await Amplify.Auth.fetchAuthSession(
        options: CognitoSessionOptions(getAWSCredentials: true),
      );
      String accessToken = (res as CognitoAuthSession).userPoolTokens.accessToken;
      log('accessToken: $accessToken');
      setState(() {
        _accessToken = accessToken;
      });
      return accessToken;
    } on AuthException catch (e) {
      print(e.message);
    }
    return "";
  }

  Future<String> _fetchCurrentUser() async {
    final user = await Amplify.Auth.getCurrentUser();
    setState(() {
      _userName = user.username;
    });
    return user.username;
  }

  Future<bool> _isSignedIn() async {
    final result = await Amplify.Auth.fetchAuthSession();
    final user = await Amplify.Auth.getCurrentUser();

    print("Is signed in: " + result.isSignedIn.toString());
    print("User: " + user.username);
    return result.isSignedIn;
  }
}
