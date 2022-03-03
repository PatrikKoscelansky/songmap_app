import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:songmap_app/models/songpoint_model.dart';
import 'package:songmap_app/utils/location_helper.dart';
import 'package:songmap_app/utils/songpoint_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  LocationHelper _locationHelper = LocationHelper();
  LocationData _lastLocationData;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    _loadLastLocationData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _lastLocationData != null
          ? GoogleMap(
        rotateGesturesEnabled: false,
        scrollGesturesEnabled: false,
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
            zoom: 18.7,
            target: LatLng(
                _lastLocationData.latitude, _lastLocationData.longitude)),
        markers: {
          ..._songPointsAsMarkers(
              Provider.of<SongPointProvider>(context).nearSongPoints),
        },
        circles: <Circle>{
          Circle(
            circleId: CircleId("radiusCircle"),
            center: LatLng(
                _lastLocationData.latitude, _lastLocationData.longitude),
            radius: 50,
            fillColor: Colors.greenAccent.withOpacity(0.5),
            strokeWidth: 3,
            strokeColor: Colors.redAccent,
          ),
          Circle(
            circleId: CircleId("me"),
            center: LatLng(
                _lastLocationData.latitude, _lastLocationData.longitude),
            radius: 1,
            fillColor: Colors.yellow,
            strokeWidth: 0,
          )
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  void _loadLastLocationData() async {
    LocationData lastLocationData = await _locationHelper.lastKnownLocation();
    setState(() {
      _lastLocationData = lastLocationData;
    });
  }

  // CameraPosition _initialCameraPosition(List<SongPoint> songPoints) {
  //   return CameraPosition(
  //       target: LatLng(songPoints[0].latitude, songPoints[0].longitude));
  //
  // }

  Set<Marker> _songPointsAsMarkers(List<SongPoint> songPoints) {
    return songPoints
        .map((songPoint) => Marker(
      markerId: MarkerId(songPoint.hashCode.toString()),
      position: LatLng(songPoint.latitude, songPoint.longitude),
      infoWindow: InfoWindow(
        title: songPoint.song.title,
        snippet: songPoint.song.artist,
      ),
      // onTap: () {
      //   print("Tapped SongPoint: " + songPoint.song.title);
      // }
    ))
        .toSet();
  }

// Future<void> _goToTheLake() async {
//   final GoogleMapController controller = await _controller.future;
//   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
// }
}
