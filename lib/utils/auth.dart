import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show ascii, base64, json;
// import 'package:flutter/material.dart';

const SERVER_IP = 'http://10.0.2.2:8000';

//TODO: we should also have a refresh method

class Auth {
  FlutterSecureStorage _storage;
  UserSession _userSession;

  static final Auth _instance = Auth._internal();

  factory Auth() {
    return _instance;
  }

  Auth._internal() {
    this._storage = FlutterSecureStorage();
    this._userSession = null;
  }

  UserSession get userSession => this._userSession;
  bool get onLine => this._userSession == null ? false : true;

  Future<UserSession> loadLastStoredUserSession() async {
    UserSession userSession = await _storedUserSession();
    if (userSession == null) {
      print(
          "[AuthProvider] Loaded token missing or invalid. Returning invalid session.");
      return UserSession.invalid();
    }
    if (!DateTime.fromMillisecondsSinceEpoch(userSession.payload["exp"] * 1000)
        .isAfter(DateTime.now())) {
      print("[AuthProvider] Token expired. Returning invalid session.");
      return UserSession.invalid();
    }

    this._userSession = userSession;
    this._userSession.valid = true;
    print("[AuthProvider] Loaded valid, non-expired token.");
    return this._userSession;
  }

  Future<UserSession> signIn(String username, String password) async {
    String jwt = await _attemptLogIn(username, password);
    if (jwt == null) {
      return null;
    }
    await _storage.write(key: "jwt", value: jwt);
    this._userSession = UserSession(jwt: jwt);
    return this._userSession;
  }

  Future<void> signOut() async {
    this._userSession = null;
    // notifyListeners();
    _storage.delete(key: "jwt");
  }

  Future<int> signUp(String username, String email, String password) async {
    var body = json
        .encode({"username": username, "email": email, "password": password});
    var uri = Uri.parse('$SERVER_IP/users/new/');
    var res = await http.post(uri, body: body);
    return res.statusCode;
  }

  Future<String> _attemptLogIn(String username, String password) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    Map<String, String> data = {
      'grant_type': '',
      'username': username,
      'password': password,
      'scope': '',
      'client_id': '',
      'client_secret': ''
    };

    var uri = Uri.parse("$SERVER_IP/token/");
    var res = await http.post(uri, headers: headers, body: data);
    if (res.statusCode == 200) {
      dynamic response = json.decode(res.body);
      var accessToken = response['access_token'];
      return accessToken;
    }
    return null;
  }

  Future<UserSession> _storedUserSession() async {
    String storageJWT = await _jwtFromStorage();

    //a.k.a. nothing loaded
    if (storageJWT.split(".").length != 3) {
      return null;
    }

    return UserSession(jwt: storageJWT);
  }

  Future<String> _jwtFromStorage() async {
    var jwt = await _storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }
}

class UserSession {
  var jwt;
  var payload;
  bool valid;

  bool get isValid => DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
      .isAfter(DateTime.now());

  UserSession({this.jwt}) {
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    valid = false;
  }

  UserSession.invalid() {
    jwt = null;
    payload = null;
    valid = false;
  }
}

// Future<String> attemptLogIn(String username, String password) async {
//   Map<String, String> headers = {
//     'Accept': 'application/json',
//     'Content-Type': 'application/x-www-form-urlencoded'
//   };
//   Map<String, String> data = {
//     'grant_type': '',
//     'username': username,
//     'password': password,
//     'scope': '',
//     'client_id': '',
//     'client_secret': ''
//   };
//
//   var res = await http.post("$SERVER_IP/token/", headers: headers, body: data);
//   if (res.statusCode == 200) {
//     dynamic response = json.decode(res.body);
//     var accessToken = response['access_token'];
//     return accessToken;
//   }
//   return null;
// }

// Future<int> attemptSignUp(String username, String password) async {
//   var res = await http.post('$SERVER_IP/signup',
//       body: {"username": username, "password": password});
//   return res.statusCode;
// }
