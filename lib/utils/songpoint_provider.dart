import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:songmap_app/models/songpoint_model.dart';
import 'package:songmap_app/utils/songmap_api_service.dart';

class SongPointProvider extends ChangeNotifier {

  List<SongPoint> _nearSongPoints;
  AuthSession _authSession;

  SongPointProvider(AuthSession authSession) {
    this._nearSongPoints = [];

    _authSession = authSession;
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
    String jwt = (_authSession as CognitoAuthSession).userPoolTokens.accessToken;
    this._nearSongPoints = await SongMapApi.getNearSongPoints(
        location.longitude, location.latitude, jwt);
    _orderByDateTime();
    notifyListeners();
    return this._nearSongPoints;
  }

  void _orderByDateTime() {
    this._nearSongPoints.sort((a, b) => b.timeAdded.compareTo(a.timeAdded));
  }
}
