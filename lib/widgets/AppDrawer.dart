import 'package:flutter/material.dart';
import 'package:songmap_app/screens/login_screen.dart';
import 'package:songmap_app/utils/auth.dart';
import 'package:songmap_app/utils/spotify_auth.dart';

class AppDrawer extends StatelessWidget {
  final Auth _auth = Auth();
  final SpotifyAuth _spotifyAuth = SpotifyAuth();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Song Map'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Refresh Spotify token'),
            onTap: () async {
              await _spotifyAuth.refreshTokens();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Spotify token refreshed"),
              ));
            },
          ),
          ListTile(
            title: Text('Sign Out'),
            onTap: () async {
              await _auth.signOut();
              await _spotifyAuth.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}
