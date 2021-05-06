import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:songmap_app/models/songpoint_model.dart';
import 'package:songmap_app/models/user_model.dart';
import 'package:songmap_app/utils/auth.dart';
import 'package:songmap_app/utils/location_helper.dart';
import 'package:songmap_app/utils/songmap_api_service.dart';
import 'package:songmap_app/utils/songpoint_provider.dart';
import 'package:songmap_app/utils/spotify_auth.dart';
import 'package:songmap_app/widgets/AppDrawer.dart';
import 'add_songpoint_screen.dart';
import 'add_spotify_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Auth _auth;
  SpotifyAuth _spotifyAuth;
  User userData;
  LocationHelper _locHelper;

  Future<SpotifySession> _spotifySessionFuture;
  Future<List<SongPoint>> _nearSongPointsFuture;

  //TODO:
  // - google maps
  // - use 3rd party auth + refresh its tokens automatically
  // - in the card for SongPoint on this Screen, rather calculate distance
  // - screen for a songpoint. If songpoint is part of track, then track screen
  // - if songpoint from track found, render card for that track
  // - render songpoints, later tracks on map

  //handle spotify errors
  //handle SongMapAPI errors

  @override
  void initState() {
    _auth = Auth();
    _spotifyAuth = SpotifyAuth();
    _locHelper = LocationHelper();

    _spotifySessionFuture = _spotifyAuth.loadStoredSpotifySession();
    _nearSongPointsFuture =
        _locHelper.getLocation().then((LocationData location) async {
      return await SongMapApi.getNearSongPoints(
          location.longitude, location.latitude, _auth.userSession);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => SongPointProvider(),
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
                  if (snapshot.hasError) {
                    print("[HomeScreen] SOME ERROR OCCURED");
                  }
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
            content: Text("Hooray, we have a code."),
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
}

class MapTabBarView extends StatefulWidget {
  final List<SongPoint> initialSongPoints;
  MapTabBarView(this.initialSongPoints);

  @override
  _MapTabBarViewState createState() => _MapTabBarViewState();
}

class _MapTabBarViewState extends State<MapTabBarView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MapSample();
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}

class SongPointsTabBarView extends StatefulWidget {
  final List<SongPoint> initialSongPoints;
  SongPointsTabBarView(this.initialSongPoints);

  @override
  _SongPointsTabBarViewState createState() => _SongPointsTabBarViewState();
}

class _SongPointsTabBarViewState extends State<SongPointsTabBarView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        SongPointsListBody(widget.initialSongPoints),
        Positioned(
          child: Align(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                child: Text('ADD'),
                onPressed: () async {
                  List<SongPoint> songPoints = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddSongPointScreen()));
                  Provider.of<SongPointProvider>(context, listen: false)
                      .addSongPointsToList(songPoints);
                },
              ),
            ),
            alignment: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }
}

class SongPointsListBody extends StatefulWidget {
  final List<SongPoint> initialSongPoints;
  SongPointsListBody(this.initialSongPoints);

  @override
  _SongPointsListBodyState createState() => _SongPointsListBodyState();
}

class _SongPointsListBodyState extends State<SongPointsListBody> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      List<SongPoint> songPoints =
          Provider.of<SongPointProvider>(context, listen: false).nearSongPoints;
      if (songPoints.length == 0) {
        Provider.of<SongPointProvider>(context, listen: false)
            .addSongPointsToList(widget.initialSongPoints);
      }
    });
    print(widget.initialSongPoints);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        LocationData loc = await LocationHelper().getLocation();
        await Provider.of<SongPointProvider>(context, listen: false)
            .getNearSongPoints(loc);
        return null;
      },
      child: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: Provider.of<SongPointProvider>(context)
                    .nearSongPoints
                    .length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      // leading: Icon(Icons.music_note),
                      dense: true,
                      title: Text(Provider.of<SongPointProvider>(context)
                          .nearSongPoints[index]
                          .song
                          .title),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
