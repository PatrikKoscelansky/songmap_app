class Song {
  int id;
  String artist;
  String title;
  String spotifyId;

  Song({this.artist, this.title, this.spotifyId});

  Song.withId({this.id, this.artist, this.title, this.spotifyId});

  // Song.fromJson(Map<String, dynamic> json) {
  //   this.artist = json['artist'];
  //   this.title = json['title'];
  //   this.spotifyId = json['spotify_id'];
  // }

  Song.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.artist = json['artist'];
    this.title = json['title'];
    this.spotifyId = json['spotify_id'];
  }

  Map<String, dynamic> toJson() => {
        "artist": this.artist,
        "title": this.title,
        "spotify_id": this.spotifyId
      };
}
