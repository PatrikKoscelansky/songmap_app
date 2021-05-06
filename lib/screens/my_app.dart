import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songmap_app/screens/home_screen.dart';
import 'package:songmap_app/screens/login_screen.dart';
import 'package:songmap_app/utils/auth.dart';
import 'package:songmap_app/utils/songpoint_provider.dart';
import 'package:songmap_app/utils/spotify_auth.dart';
import 'package:songmap_app/widgets/AppDrawer.dart';

class MyApp extends StatelessWidget {
  // final Auth _auth = Auth();
  // final SpotifyAuth _spotifyAuth = SpotifyAuth();

  @override
  Widget build(BuildContext context) {
    // var authProvider = Provider.of<AuthProvider>(context);
    return MaterialApp(
      title: 'Song Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: Auth().loadLastStoredUserSession(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.valid) {
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class TokenScreen extends StatelessWidget {
  // var payload;
  // Token({this.payload});

  @override
  Widget build(BuildContext context) {
    Auth auth = Auth();
    return Scaffold(
        appBar: AppBar(
          title: Text("Token"),
        ),
        drawer: AppDrawer(),
        body: Center(
          child: Text(auth.userSession.jwt),
        ));
  }
}
