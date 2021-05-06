class SpotifyTrack {
  String title;
  String artist;
  String spotifyId;

  SpotifyTrack({this.artist, this.title, this.spotifyId});

  SpotifyTrack.fromJson(Map<String, dynamic> json) {
    this.title = json['name'];
    this.artist = json['artists'][0]['name'];
    this.spotifyId = json['id'];
  }

  Map<String, dynamic> toJson() => {
        "artist": this.artist,
        "title": this.title,
        "spotify_id": this.spotifyId
      };
}
