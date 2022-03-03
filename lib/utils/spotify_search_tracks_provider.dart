import 'package:flutter/material.dart';
import 'package:songmap_app/models/spotify_track_model.dart';
// import 'package:songmap_app/utils/songmap_api_service.dart';
import 'package:songmap_app/utils/spotify_api_service.dart';
import 'package:songmap_app/utils/spotify_auth.dart';

// import 'auth.dart';

class SpotifySearchTracksProvider extends ChangeNotifier {
  List<SpotifyTrack> _searchedSongs;
  List<SpotifyTrack> _recentlyPlayedSongs;

  // Auth _auth;
  SpotifyAuth _spotifyAuth;

  SpotifySearchTracksProvider() {
    this._searchedSongs = [];
    this._recentlyPlayedSongs = [];

    // _auth = Auth();
    _spotifyAuth = SpotifyAuth();
  }

  List<SpotifyTrack> get searchedSongs => this._searchedSongs;
  List<SpotifyTrack> get recentlyPlayedSongs => this._recentlyPlayedSongs;

  Future<void> getRecentlyPlayed() async {
    List<SpotifyTrack> spotifyTracks =
    await SpotifyApiService.getRecentlyPlayedTracks(
        _spotifyAuth.getSpotifySession);
    this._recentlyPlayedSongs = spotifyTracks;
    notifyListeners();
  }

  Future<void> searchSongs(String query) async {
    List<SpotifyTrack> spotifyTracks =
    await SpotifyApiService.getSearchedTracks(
        query, _spotifyAuth.getSpotifySession);
    this._searchedSongs = spotifyTracks;
    notifyListeners();
  }
}
