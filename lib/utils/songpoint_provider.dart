import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:songmap_app/models/songpoint_model.dart';
import 'package:songmap_app/utils/auth.dart';
import 'package:songmap_app/utils/songmap_api_service.dart';

class SongPointProvider extends ChangeNotifier {
  Auth _auth;
  List<SongPoint> _nearSongPoints;

  SongPointProvider() {
    this._nearSongPoints = [];

    _auth = Auth();
  }

  List<SongPoint> get nearSongPoints => this._nearSongPoints;

  void addSongPointToList(SongPoint songPoint) {
    this._nearSongPoints.add(songPoint);
    notifyListeners();
  }

  void addSongPointsToList(List<SongPoint> songPoints) {
    if (songPoints != null) {
      this._nearSongPoints = new List.from(this._nearSongPoints)
        ..addAll(songPoints);
      _orderByDateTime();
      notifyListeners();
    }
  }

  Future<List<SongPoint>> getNearSongPoints(LocationData location) async {
    this._nearSongPoints = await SongMapApi.getNearSongPoints(
        location.longitude, location.latitude, _auth.userSession);
    _orderByDateTime();
    notifyListeners();
    return this._nearSongPoints;
  }

  void _orderByDateTime() {
    this._nearSongPoints.sort((a, b) => b.timeAdded.compareTo(a.timeAdded));
  }
}
