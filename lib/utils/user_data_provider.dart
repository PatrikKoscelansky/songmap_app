import 'package:flutter/material.dart';
import 'package:songmap_app/models/song_model.dart';
import 'package:songmap_app/models/user_model.dart';

import 'auth.dart';

class UserDataProvider extends ChangeNotifier {
  User _user;
  //more data in the future. e.g localy saved songpoints

  UserDataProvider(User user) {
    this._user = user;
  }

  User get user => this._user;
}
