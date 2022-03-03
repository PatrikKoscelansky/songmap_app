import 'package:location/location.dart';

//TODO: change this into background task
class LocationHelper {
  LocationData _lastKnownLocation;

  Location _location;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  static final LocationHelper _instance = LocationHelper._internal();

  factory LocationHelper() {
    return _instance;
  }

  LocationHelper._internal() {
    this._location = new Location();
    this._serviceEnabled = false;
    this._permissionGranted = PermissionStatus.denied;
  }

  Future<LocationData> getLocation() async {
    bool ok = await _check();
    if (!ok) {
      //or throw
      return null;
    }
    this._lastKnownLocation = await _location.getLocation();
    return this._lastKnownLocation;
  }

  Future<LocationData> lastKnownLocation() async {
    if (this._lastKnownLocation != null) {
      return this._lastKnownLocation;
    }
    return await getLocation();
  }

  Future<bool> _check() async {
    if (!this._serviceEnabled) {
      await _enableService();
      if (!this._serviceEnabled) {
        print("[LocHelper] service not enabled.");
        return false;
      }
    }
    if (this._permissionGranted != PermissionStatus.granted) {
      await _requestPermission();
      print("[LocHelper] permission granted?");
      print(this._permissionGranted);
      if (this._permissionGranted != PermissionStatus.granted) {
        print("[LocHelper] permission not granted.");
        return false;
      }
    }
    print("[LocHelper] everything in CHECK");
    return true;
  }

  Future<bool> _enableService() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    return _serviceEnabled;
  }

  Future<bool> _requestPermission() async {
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return _permissionGranted == PermissionStatus.granted;
  }
}

// class LocationHelper {
//   Location _location;
//   bool _serviceEnabled;
//   PermissionStatus _permissionGranted;
//
//   LocationHelper() {
//     this._location = new Location();
//     this._serviceEnabled = false;
//     this._permissionGranted = PermissionStatus.denied;
//   }
//
//   Future<LocationData> getLocation() async {
//     bool ok = await _check();
//     if (!ok) {
//       //or throw
//       return null;
//     }
//     return await _location.getLocation();
//   }
//
//   Future<bool> _check() async {
//     if (!this._serviceEnabled) {
//       await _enableService();
//       if (!this._serviceEnabled) {
//         print("[LocHelper] service not enabled.");
//         return false;
//       }
//     }
//     if (this._permissionGranted != PermissionStatus.granted) {
//       await _requestPermission();
//       print("[LocHelper] permission granted?");
//       print(this._permissionGranted);
//       if (this._permissionGranted != PermissionStatus.granted) {
//         print("[LocHelper] permission not granted.");
//         return false;
//       }
//     }
//     print("[LocHelper] everything in CHECK");
//     return true;
//   }
//
//   Future<bool> _enableService() async {
//     _serviceEnabled = await _location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await _location.requestService();
//       if (!_serviceEnabled) {
//         return false;
//       }
//     }
//     return _serviceEnabled;
//   }
//
//   Future<bool> _requestPermission() async {
//     _permissionGranted = await _location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await _location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return false;
//       }
//     }
//     return _permissionGranted == PermissionStatus.granted;
//   }
// }
