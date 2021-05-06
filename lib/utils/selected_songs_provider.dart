import 'package:flutter/material.dart';
import 'package:songmap_app/models/song_model.dart';

class SelectedSongsProvider extends ChangeNotifier {
  List<Song> _songsToAddToSongMap;

  SelectedSongsProvider() {
    this._songsToAddToSongMap = [];
  }

  List<Song> get songs => this._songsToAddToSongMap;

  void addSong(Song song) {
    _songsToAddToSongMap.add(song);
  }

  void removeBySpotifyId(String id) {
    _songsToAddToSongMap.removeWhere((element) => element.spotifyId == id);
  }
}
