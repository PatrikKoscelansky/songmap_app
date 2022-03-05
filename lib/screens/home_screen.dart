import 'dart:async';
import 'dart:developer';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:songmap_app/models/songpoint_model.dart';
import 'package:songmap_app/models/user_model.dart';
import 'package:songmap_app/utils/auth_session_holder.dart';
import 'package:songmap_app/utils/location_helper.dart';
import 'package:songmap_app/utils/songmap_api_service.dart';
import 'package:songmap_app/utils/songpoint_provider.dart';
import 'package:songmap_app/utils/spotify_auth.dart';
import 'package:songmap_app/widgets/AppDrawer.dart';
import 'package:songmap_app/widgets/map_tabbar_view.dart';
import 'package:songmap_app/widgets/songpoints_tabbar_view.dart';

import 'add_spotify_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthSession _authSession;
  SpotifyAuth _spotifyAuth;
  User userData;
  LocationHelper _locHelper;

  Future<SpotifySession> _spotifySessionFuture;
  Future<List<SongPoint>> _nearSongPointsFuture;

  //TODO:
  // - endpoints for creating songs and songpoints
  // - delete uncecessary pages and stuff
  // - handle SongPoint and Spotify errors in a nice way. Mainly SongPointApi errors
  // - in the card for SongPoint on this Screen, rather calculate distance
  // - screen for a songpoint. If songpoint is part of track, then track screen
  // - if songpoint from track found, render card for that track
  // - render songpoints, later tracks on map

  //handle spotify errors
  //handle SongMapAPI errors

  @override
  void initState() {
    _spotifyAuth = SpotifyAuth();
    _locHelper = LocationHelper();

    _spotifySessionFuture = _spotifyAuth.loadStoredSpotifySession();
    _nearSongPointsFuture = Future.wait([_fetchSession(), _locHelper.getLocation()]).then((values) async {
      _authSession = values[0];
      String accessToken = (values[0] as CognitoAuthSession).userPoolTokens.accessToken;
      log("[home_screen] after _fetchSession() token: " + accessToken);
      LocationData location = values[1];
      return await SongMapApi.getNearSongPoints(
          location.longitude, location.latitude, accessToken);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => SongPointProvider(_authSession),
    child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Songs",
                icon: Icon(Icons.queue_music),
              ),
              Tab(
                text: "Map",
                icon: Icon(Icons.map),
              )
            ],
          ),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
          Future.wait([_spotifySessionFuture, _nearSongPointsFuture]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // if (snapshot.hasError) {
              //   print("[HomeScreen] SOME ERROR OCCURED");
              //   print(snapshot.error.toString());
              //   print("[HomeScreen][spotifySessionFuture] " +
              //       snapshot.data[0].toString());
              //   print("[HomeScreen][nearSongPointsFuture] " +
              //       snapshot.data[1].toString());
              //   print("[HomeScreen][nearSongPointsFuture] " +
              //       snapshot.data[1].toString());
              // }
              List<SongPoint> songPoints = snapshot.data[1];

              return _spotifyAuth.getSpotifySession != null
                  ? TabBarView(
                children: [
                  SongPointsTabBarView(songPoints),
                  MapTabBarView(songPoints),
                ],
              )
                  : Center(
                child: connectSpotifyButton(context),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    ),
  );

  TextButton connectSpotifyButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        String code = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddSpotifyScreen(_spotifyAuth.authorizationURL())));
        if (code != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Hooray, connected to Spotify!!!"),
          ));
          SpotifySession spotifySession =
          await _spotifyAuth.obtainTokensForCode(code);
          spotifySession != null
              ? setState(() {})
              : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("TOKEN NOT OBTAINED"),
          ));
        }
      },
      child: Text('Connect to Spotify'),
    );
  }

  Future<AuthSession> _fetchSession() async {
    AuthSessionHolder sessionHolder = new AuthSessionHolder();
    await sessionHolder.loadAuthSession();
    return sessionHolder.authSession;
  }
}
