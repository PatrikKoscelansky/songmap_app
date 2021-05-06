class SpotifyUser {
  String displayName;
  String id;

  SpotifyUser({this.displayName, this.id});

  SpotifyUser.fromJson(Map<String, dynamic> json) {
    this.displayName = json['display_name'];
    this.id = json['id'];
  }

  Map<String, dynamic> toJson() => {
        'display_name': this.displayName,
        'id': this.id,
      };
}
