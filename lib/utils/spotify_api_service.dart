import 'package:http/http.dart' as http;
import 'package:songmap_app/models/spotify_track_model.dart';
import 'dart:convert' show ascii, base64, json;
import 'package:songmap_app/models/spotify_user_model.dart';
import 'package:songmap_app/utils/spotify_auth.dart';

class SpotifyApiService {
  static String API_URL = "https://api.spotify.com/v1";

  static Future<SpotifyUser> getSpotifyUser(SpotifySession session) async {
    if (!session.isValid) {
      session = await SpotifyAuth().refreshTokens();
    }
    var uri = Uri.parse('$API_URL/me');
    String jsonResponse =
        await http.read(uri, headers: _authHeaders(session.accessToken));

    return SpotifyUser.fromJson(json.decode(jsonResponse));
  }

  static Future<List<SpotifyTrack>> getSearchedTracks(
      String query, SpotifySession session) async {
    if (!session.isValid) {
      session = await SpotifyAuth().refreshTokens();
    }

    Map<String, String> headers = _authHeaders(session.accessToken);
    headers['Content-Type'] = 'application/json';

    Map<String, dynamic> queryParams = {
      "q": query,
      "type": "track",
      "limit": "5",
      "offset": "0",
    };

    String queryString = Uri(queryParameters: queryParams).query;
    String url = '$API_URL/search' + '?' + queryString;
    var uri = Uri.parse(url);
    String jsonResponse = await http.read(uri, headers: headers);

    Map<String, dynamic> decodedResponse = json.decode(jsonResponse);
    if (decodedResponse.containsKey('error')) {
      print("[SpotifyApiService] error occured.");
      print(decodedResponse);
      return null;
    }
    //  success
    List<SpotifyTrack> tracks = [];
    for (var item in decodedResponse['tracks']['items']) {
      tracks.add(SpotifyTrack.fromJson(item));
    }

    return tracks;
  }

  static Future<List<SpotifyTrack>> getRecentlyPlayedTracks(
      SpotifySession session) async {
    if (!session.isValid) {
      session = await SpotifyAuth().refreshTokens();
    }

    Map<String, String> headers = _authHeaders(session.accessToken);
    headers['Content-Type'] = 'application/json';

    Map<String, dynamic> queryParams = {
      "limit": "7",
    };

    String queryString = Uri(queryParameters: queryParams).query;
    String url = '$API_URL/me/player/recently-played' + '?' + queryString;
    var uri = Uri.parse(url);
    String jsonResponse = await http.read(uri, headers: headers);

    Map<String, dynamic> decodedResponse = json.decode(jsonResponse);
    print("[SpotifyApiService]");
    print(decodedResponse);
    if (decodedResponse.containsKey('error')) {
      print("[SpotifyApiService] error occured.");
      print(decodedResponse);
      return null;
    }
    //  success
    List<SpotifyTrack> tracks = [];
    for (var item in decodedResponse['items']) {
      var track = item['track'];
      tracks.add(SpotifyTrack.fromJson(track));
    }

    return tracks;
  }

  static Map<String, String> _authHeaders(String token) {
    return {"accept": "application/json", "Authorization": "Bearer " + token};
  }
}
