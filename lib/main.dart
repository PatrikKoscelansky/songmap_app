import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:songmap_app/screens/my_app.dart';
import 'package:songmap_app/utils/auth.dart';

const SERVER_IP = 'http://10.0.2.2:8000';
final storage = FlutterSecureStorage();

//TODO: connect to Spotify with:
// https://developer.spotify.com/documentation/general/guides/authorization-guide/#authorization-code-flow

void main() {
  runApp(MyApp());
}
