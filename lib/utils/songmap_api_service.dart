import 'package:http/http.dart' as http;
import 'package:songmap_app/models/song_model.dart';
import 'package:songmap_app/models/songpoint_model.dart';
import 'package:songmap_app/models/user_model.dart';
import 'dart:convert' show ascii, base64, json;
import 'package:songmap_app/utils/auth.dart';

const SERVER_IP = 'http://10.0.2.2:8000';

class SongMapApi {
  static Future<User> getUser(UserSession session) async {
    if (!session.isValid) {
      return null;
    }
    var uri = Uri.parse('$SERVER_IP/users/me/');
    String jsonResponse =
        await http.read(uri, headers: _authHeaders(session.jwt));

    return User.fromJson(json.decode(jsonResponse));
  }

  static Future<List<SongPoint>> getNearSongPoints(
      double longitude, double latitude, UserSession session) async {
    if (!session.isValid) {
      return null;
    }
    Map<String, String> queryParams = {
      "longitude": longitude.toString(),
      "latitude": latitude.toString()
    };
    String queryString = Uri(queryParameters: queryParams).query;
    String url = "$SERVER_IP/songpoints/" + "?" + queryString;
    var uri = Uri.parse(url);

    String jsonResponse =
        await http.read(uri, headers: _authHeaders(session.jwt));

    // Map<String, dynamic> decodedResponse = json.decode(jsonResponse);
    dynamic decodedResponse = json.decode(jsonResponse);
    // print("[SongMapApi] error occured.");
    // print(decodedResponse);
    try {
      if (decodedResponse.containsKey('detail')) {
        print("[SongMapApi] error occured.");
        print(decodedResponse);
        return null;
      }
    } catch (e) {
      print("[SongMapApi] .. error? ok, not a map.");
    }

    //  success
    List<SongPoint> songPoints = [];
    for (var item in decodedResponse) {
      songPoints.add(SongPoint.fromJson(item));
    }

    return songPoints;
  }

  static Future<List<SongPoint>> createSongPoints(
      List<SongPoint> songPoints, UserSession session) async {
    if (!session.isValid) {
      return null;
    }

    if (songPoints.length > 0) {
      List<dynamic> songPointsJson = [];
      for (SongPoint songPoint in songPoints) {
        songPointsJson.add(songPoint.toJson());
      }

      var body = json.encode(songPointsJson);
      var uri = Uri.parse('$SERVER_IP/users/me/songpoints/');
      var res =
          await http.post(uri, body: body, headers: _authHeaders(session.jwt));
      print(res.body);
      if (res.statusCode == 200) {
        List<SongPoint> createdSongPoints = [];
        dynamic response = json.decode(res.body);
        for (var item in response) {
          createdSongPoints.add(SongPoint.fromJson(item));
        }
        return createdSongPoints;
      }
      return null;
    }
    return [];
  }

  //SONG

  static Future<Song> getSongBySpotifyID(
      String spotifyId, UserSession session) async {
    if (!session.isValid) {
      return null;
    }
    Map<String, String> queryParams = {"spotify_id": spotifyId};
    String queryString = Uri(queryParameters: queryParams).query;
    String url = "$SERVER_IP/songs/spotify/" + "?" + queryString;
    var uri = Uri.parse(url);

    String jsonResponse;
    try {
      jsonResponse = await http.read(uri, headers: _authHeaders(session.jwt));
    } catch (e) {
      print("[SongMapApi] error occured.");
      print(e);
      return null;
    }

    dynamic decodedResponse = json.decode(jsonResponse);
    try {
      if (decodedResponse.containsKey('detail')) {
        print("[SongMapApi] error occured.");
        print(decodedResponse);
        return null;
      }
    } catch (e) {
      print("[SongMapApi] .. error? ok, not a map.");
    }

    //  success
    Song song = Song.fromJson(decodedResponse);
    return song;
  }

  static Future<List<Song>> getSongsBySpotifyIDs(
      List<String> spotifyIDs, UserSession session) async {
    if (!session.isValid) {
      return null;
    }

    List<Future<Song>> songsFutures = [];
    for (String spotifyID in spotifyIDs) {
      Future<Song> songFuture = getSongBySpotifyID(spotifyID, session);
      songsFutures.add(songFuture);
    }

    List<Song> foundSongs = [];
    await Future.wait([...songsFutures]).then((List<Song> data) {
      for (Song song in data) {
        if (song != null) {
          foundSongs.add(song);
        }
      }
    });

    return foundSongs;
  }

  static Future<List<Song>> createSongs(
      List<Song> songs, UserSession session) async {
    if (!session.isValid) {
      return null;
    }

    if (songs.length > 0) {
      List<dynamic> songsJson = [];
      for (Song song in songs) {
        songsJson.add(song.toJson());
      }

      var body = json.encode(songsJson);
      var uri = Uri.parse('$SERVER_IP/songs/');
      var res =
          await http.post(uri, body: body, headers: _authHeaders(session.jwt));
      print(res.body);
      if (res.statusCode == 200) {
        List<Song> createdSongs = [];
        dynamic response = json.decode(res.body);
        for (var item in response) {
          createdSongs.add(Song.fromJson(item));
        }
        return createdSongs;
      }
      return null;
    }
    return [];
  }

  //helper functions

  static Map<String, String> _authHeaders(String jwt) {
    return {"accept": "application/json", "Authorization": "Bearer " + jwt};
  }
}
