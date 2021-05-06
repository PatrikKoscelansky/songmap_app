import 'package:songmap_app/models/song_model.dart';

class SongPoint {
  double longitude;
  double latitude;
  DateTime timeAdded;
  int ownerId;
  int likes;
  Song song;

  SongPoint(
      {this.longitude,
      this.latitude,
      this.timeAdded,
      this.ownerId,
      this.likes,
      this.song});

  SongPoint.createModel(
      {this.longitude, this.latitude, this.timeAdded, this.song});

  // what we get back
  SongPoint.fromJson(Map<String, dynamic> json) {
    this.longitude = json['longitude'];
    this.latitude = json['latitude'];
    this.timeAdded = DateTime.parse(json['time_added']);
    this.ownerId = json['owner_id'];
    this.likes = json['likes'];
    this.song = Song.fromJson(json['song']);
  }

  // what we need to send
  Map<String, dynamic> toJson() => {
        "longitude": this.longitude,
        "latitude": this.latitude,
        "time_added": this.timeAdded.toIso8601String(),
        "song_id": this.song.id
      };
}
