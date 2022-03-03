import 'dart:developer' as logging;

import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert'
    show ascii, base64, json, utf8, base64Url, base64UrlEncode;
import 'secrets.dart' show SPOTIFY_CLIENT_ID, SONGMAP_API_HOST;

class SpotifyAuth {
  static const String _spotifyClientId = SPOTIFY_CLIENT_ID;
  static const String AUTH_URL = "https://accounts.spotify.com/authorize";
  static const String TOKEN_URL = "https://accounts.spotify.com/api/token";
  static const String AUTH_REDIRECT_URI =
      SONGMAP_API_HOST + "spotify_auth_callback/";
  static const String scopes =
      "user-read-recently-played user-read-private user-read-email user-library-modify user-library-read app-remote-control streaming playlist-read-private playlist-read-collaborative playlist-modify-public playlist-modify-private user-read-currently-playing";

  FlutterSecureStorage _storage;
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890_.-~';
  Random _rnd;
  SpotifySession _spotifySession;

  static final SpotifyAuth _instance = SpotifyAuth._internal();

  factory SpotifyAuth() {
    return _instance;
  }

  SpotifyAuth._internal() {
    this._storage = FlutterSecureStorage();
    this._rnd = Random.secure();
    this._spotifySession = null;
  }

  String _codeVerifier;

  SpotifySession get getSpotifySession => this._spotifySession;

  // Future<String> authorize() async {
  //   String codeVerifier = _generateCodeVerifier();
  //   String codeChallenge = _getCodeChallenge(codeVerifier);
  //   String state = "df654er12v6";
  //
  //   Map<String, String> queryParams = {
  //     "client_id": _spotifyClientId,
  //     "response_type": "code",
  //     "redirect_uri": AUTH_REDIRECT_URI,
  //     "code_challenge_method": "S256",
  //     "code_challenge": codeChallenge,
  //     "state": state,
  //     "scope": scopes
  //   };
  //   String queryString = Uri(queryParameters: queryParams).query;
  //   String url = AUTH_URL + "?" + queryString;
  //   return await http.read(
  //     url,
  //   );
  // }

  String authorizationURL() {
    _codeVerifier = _generateCodeVerifier();
    String codeChallenge = _getCodeChallenge(_codeVerifier);
    String state = "";

    Map<String, String> queryParams = {
      "client_id": _spotifyClientId,
      "response_type": "code",
      "redirect_uri": AUTH_REDIRECT_URI,
      "code_challenge_method": "S256",
      "code_challenge": codeChallenge,
      "state": state,
      "scope": scopes
    };
    String queryString = Uri(queryParameters: queryParams).query;
    String url = AUTH_URL + "?" + queryString;
    // print("[Auth] my URL: " + url);
    return url;
  }

  Future<void> signOut() async {
    this._spotifySession = null;
    // notifyListeners();
    _storage.delete(key: "spotify_tokens");
  }

  Future<SpotifySession> obtainTokensForCode(String code) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    Map<String, String> data = {
      "client_id": _spotifyClientId,
      "grant_type": "authorization_code",
      "code": code,
      "redirect_uri": AUTH_REDIRECT_URI,
      "code_verifier": _codeVerifier
    };

    logging.log("[spotify_auth] obtaining tokens ...");
    var uri = Uri.parse(TOKEN_URL);
    var res = await http.post(uri, headers: headers, body: data);
    logging.log("[spotify_auth] status code: " + res.statusCode.toString());
    logging.log("[spotify_auth] body: " + res.body);

    if (res.statusCode == 200) {
      logging.log("[spotify_auth] obtained tokens: " + res.body);
      dynamic response = json.decode(res.body);
      this._spotifySession = SpotifySession(
          accessToken: response['access_token'],
          refreshToken: response['refresh_token'],
          expires: SpotifySession.expiresInToDateTime(response['expires_in']));
      await _storage.write(
          key: "spotify_tokens", value: this._spotifySession.toJson());
      logging.log("[spotify_auth] tokens saved");
      return this._spotifySession;
    }
    return null;
  }

  Future<SpotifySession> loadStoredSpotifySession() async {
    String tokensFromStorage = await _spotifyTokensFromStorage();
    // print("[SpotifyAuth][loadStoredSpotifySession][tokensFromStorage]" +
    //     tokensFromStorage);
    logging.log("[spotify_auth] loading stored session: " + tokensFromStorage);
    tokensFromStorage == null ? logging.log("[spotify_auth] tokens null") : logging.log("[spotify_auth] tokens not null");
    if (tokensFromStorage != null) {
      dynamic tokensStorageDecoded = json.decode(tokensFromStorage);
      this._spotifySession = SpotifySession(
          accessToken: tokensStorageDecoded['access_token'],
          refreshToken: tokensStorageDecoded['refresh_token'],
          expires: DateTime.parse(tokensStorageDecoded['expires']));
      if (!this._spotifySession.isValid) {
        this._spotifySession = await refreshTokens();
      }
      return this._spotifySession;
    }
    return null;
  }

  Future<SpotifySession> refreshTokens() async {
    //  WHY
    // if (this._spotifySession == null) {
    //   await loadStoredSpotifySession();
    // }

    logging.log("[spotify_auth] refreshing session...");

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    Map<String, String> data = {
      "grant_type": "refresh_token",
      "refresh_token": this._spotifySession.refreshToken,
      "client_id": _spotifyClientId,
    };

    var uri = Uri.parse(TOKEN_URL);
    var res = await http.post(uri, headers: headers, body: data);

    if (res.statusCode == 200) {
      logging.log("[spotify_auth] obtained tokens: " + res.body);
      dynamic response = json.decode(res.body);
      this._spotifySession = SpotifySession(
          accessToken: response['access_token'],
          refreshToken: response['refresh_token'],
          expires: DateTime.parse(response['expires']));
      await _storage.write(
          key: "spotify_tokens", value: this._spotifySession.toJson());
      logging.log("[spotify_auth] tokens saved");

      logging.log("[spotify_auth] tokens refreshed");
      return this._spotifySession;
    }
    logging.log("[spotify_auth] tokens refreshed");
    return null;
  }

  Future<String> _spotifyTokensFromStorage() async {
    var tokens = await _storage.read(key: "spotify_tokens");
    if (tokens != null && tokens.isNotEmpty) {
      return tokens;
    }
    return null;
  }

  String _generateCodeVerifier() {
    return _getRandomString(128);
  }

  String _getCodeChallenge(String codeVerifier) {
    // var bytes = utf8.encode(codeVerifier);
    // Digest digest = sha256.convert(bytes);
    // return base64UrlEncode(digest.bytes);

    var hash = sha256.convert(ascii.encode(codeVerifier));
    return base64Url
        .encode(hash.bytes)
        .replaceAll("=", "")
        .replaceAll("+", "-")
        .replaceAll("/", "_");
  }

  //use length between 43 and 128
  String _getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

class SpotifySession {
  String accessToken;
  String refreshToken;
  DateTime expires;
  // bool get isValid => expires.isAfter(DateTime.now());
  bool get isValid => DateTime.now().isBefore(expires);

  SpotifySession({this.accessToken, this.refreshToken, this.expires});

  String toJson() {
    return json.encode({
      "access_token": this.accessToken,
      "refresh_token": this.refreshToken,
      "expires": expires.toIso8601String()
    });
  }

  static DateTime expiresInToDateTime(int expiresIn) {
    return DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch + expiresIn * 1000);
  }
}
