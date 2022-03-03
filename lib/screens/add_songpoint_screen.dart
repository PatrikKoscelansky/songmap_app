import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:songmap_app/models/song_model.dart';
import 'package:songmap_app/models/songpoint_model.dart';
import 'package:songmap_app/utils/auth_session_holder.dart';
import 'package:songmap_app/utils/location_helper.dart';
import 'package:songmap_app/utils/selected_songs_provider.dart';
import 'package:songmap_app/utils/songmap_api_service.dart';
import 'package:songmap_app/utils/spotify_search_tracks_provider.dart';
import 'package:songmap_app/widgets/AppDrawer.dart';

class AddSongPointScreen extends StatefulWidget {
  @override
  _AddSongPointScreenState createState() => _AddSongPointScreenState();
}

class _AddSongPointScreenState extends State<AddSongPointScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (context) => SpotifySearchTracksProvider()),
      ChangeNotifierProvider(create: (context) => SelectedSongsProvider())
    ], child: AddSongPointScreenBody());
  }
}

class AddSongPointScreenBody extends StatefulWidget {
  @override
  _AddSongPointScreenBodyState createState() => _AddSongPointScreenBodyState();
}

class _AddSongPointScreenBodyState extends State<AddSongPointScreenBody> {
  String _jwt;
  LocationHelper _locationHelper;

  @override
  void initState() {
    _jwt = AuthSessionHolder().jwt;
    _locationHelper = LocationHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var selectedSongsProvider =
        Provider.of<SelectedSongsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Add SongPoint")),
      drawer: AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.audiotrack),
            label: 'SongPoints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Track',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () async {
          Loader.show(
            context,
            isAppbarOverlay: true,
            isBottomBarOverlay: true,
            progressIndicator: CircularProgressIndicator(),
          );
          List<Song> selectedSongs = selectedSongsProvider.songs;
          List<SongPoint> createdSongPoints =
              await createSongPointsFlow(selectedSongs);
          Loader.hide();
          Navigator.pop(context, createdSongPoints);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SpotifySongsBody(),
    );
  }

  //TODO: handle ERRORS properly, e.g. 404

  Future<List<SongPoint>> createSongPointsFlow(List<Song> selectedSongs) async {
    List<String> selectedSongsSpotifyIDs =
        selectedSongs.map((e) => e.spotifyId).toList();
    List<Song> foundSongs = [];
    foundSongs = await SongMapApi.getSongsBySpotifyIDs(
        selectedSongsSpotifyIDs, _jwt);
    List<Song> toCreate = whichSongsToCreate(selectedSongs, foundSongs);
    List<Song> createdSongs = [];
    createdSongs = await SongMapApi.createSongs(toCreate, _jwt);
    List<Song> songsForNewSongPoints = new List.from(foundSongs)
      ..addAll(createdSongs);
    List<SongPoint> createdSongPoints =
        await createSongPoints(songsForNewSongPoints);
    if (createdSongPoints == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong when creating SongPoints."),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("SongPoints successfully created."),
      ));
    }
    return createdSongPoints;
  }

  Future<List<SongPoint>> createSongPoints(List<Song> songs) async {
    LocationData location = await _locationHelper.getLocation();
    List<SongPoint> songPoints = [];

    for (Song song in songs) {
      songPoints.add(SongPoint(
          longitude: location.longitude,
          latitude: location.latitude,
          timeAdded: DateTime.now(),
          song: song));
    }

    return await SongMapApi.createSongPoints(songPoints, _jwt);
  }

  List<Song> whichSongsToCreate(List<Song> selected, List<Song> found) {
    // Set<Song> selectedSet = selected.toSet();
    // Set<Song> foundSet = found.toSet();

    Set<String> selectedSongsSpotifyIDs =
        selected.map((e) => e.spotifyId).toSet();
    Set<String> foundSongsSpotifyIDs = found.map((e) => e.spotifyId).toSet();

    Set<String> toCreateSpotifyIDs =
        selectedSongsSpotifyIDs.difference(foundSongsSpotifyIDs);

    List<Song> toCreate = [];
    for (String spotifyID in toCreateSpotifyIDs.toList()) {
      for (Song selectedSong in selected) {
        if (selectedSong.spotifyId == spotifyID) {
          toCreate.add(selectedSong);
        }
      }
    }
    return toCreate;
    // return selectedSet.difference(foundSet).toList();
  }
}

class SpotifySongsBody extends StatefulWidget {
  @override
  _SpotifySongsBodyState createState() => _SpotifySongsBodyState();
}

class _SpotifySongsBodyState extends State<SpotifySongsBody> {
  Set<int> _selectedSongsIndexesSEARCHED = {};
  Set<int> _selectedSongsIndexesRECENT = {};
  List<Song> _songsToAddToSongMap = [];

  SelectedSongsProvider _selectedSongsProvider;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<SpotifySearchTracksProvider>(context, listen: false)
          .getRecentlyPlayed();
      _selectedSongsProvider =
          Provider.of<SelectedSongsProvider>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Flexible(
                    child: TextField(
                  controller: this._searchController,
                )),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      var query = this._searchController.text;
                      Provider.of<SpotifySearchTracksProvider>(context,
                              listen: false)
                          .searchSongs(query);
                    }),
              ],
            ),
          ),
          Column(
            children: [
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: Provider.of<SpotifySearchTracksProvider>(context)
                      .searchedSongs
                      .length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        // leading: Icon(Icons.music_note),
                        selected: _selectedSongsIndexesSEARCHED.contains(index),
                        onTap: () {
                          var spotifySong =
                              Provider.of<SpotifySearchTracksProvider>(context,
                                      listen: false)
                                  .searchedSongs[index];
                          if (!_selectedSongsIndexesSEARCHED.contains(index)) {
                            setState(() {
                              _selectedSongsIndexesSEARCHED.add(index);
                              // _songsToAddToSongMap.add(Song(
                              //     artist: spotifySong.artist,
                              //     title: spotifySong.title,
                              //     spotifyId: spotifySong.spotifyId));
                              _selectedSongsProvider.addSong(Song(
                                  artist: spotifySong.artist,
                                  title: spotifySong.title,
                                  spotifyId: spotifySong.spotifyId));
                            });
                          } else {
                            setState(() {
                              _selectedSongsIndexesSEARCHED.remove(index);
                              // _songsToAddToSongMap.removeWhere((element) =>
                              //     element.spotifyId == spotifySong.spotifyId);
                              _selectedSongsProvider
                                  .removeBySpotifyId(spotifySong.spotifyId);
                            });
                          }
                          print(_songsToAddToSongMap);
                        },
                        dense: true,
                        title: Text(
                            Provider.of<SpotifySearchTracksProvider>(context)
                                .searchedSongs[index]
                                .title),
                        subtitle: Text(
                            Provider.of<SpotifySearchTracksProvider>(context)
                                .searchedSongs[index]
                                .artist),
                        trailing: Icon(Icons.more_vert),
                      ),
                    );
                  }),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Recently played",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: Provider.of<SpotifySearchTracksProvider>(context)
                      .recentlyPlayedSongs
                      .length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        // leading: Icon(Icons.music_note),
                        selected: _selectedSongsIndexesRECENT.contains(index),
                        onTap: () {
                          var spotifySong =
                              Provider.of<SpotifySearchTracksProvider>(context,
                                      listen: false)
                                  .recentlyPlayedSongs[index];
                          print(_selectedSongsIndexesRECENT);
                          if (!_selectedSongsIndexesRECENT.contains(index)) {
                            setState(() {
                              _selectedSongsIndexesRECENT.add(index);
                              // _songsToAddToSongMap.add(Song(
                              //     artist: spotifySong.artist,
                              //     title: spotifySong.title,
                              //     spotifyId: spotifySong.spotifyId));
                              _selectedSongsProvider.addSong(Song(
                                  artist: spotifySong.artist,
                                  title: spotifySong.title,
                                  spotifyId: spotifySong.spotifyId));
                            });
                          } else {
                            setState(() {
                              _selectedSongsIndexesRECENT.remove(index);
                              // _songsToAddToSongMap.removeWhere((element) =>
                              //     element.spotifyId == spotifySong.spotifyId);
                              _selectedSongsProvider
                                  .removeBySpotifyId(spotifySong.spotifyId);
                            });
                          }
                          print(_songsToAddToSongMap);
                        },
                        dense: true,
                        // selected: true,
                        title: Text(
                            Provider.of<SpotifySearchTracksProvider>(context)
                                .recentlyPlayedSongs[index]
                                .title),
                        subtitle: Text(
                            Provider.of<SpotifySearchTracksProvider>(context)
                                .recentlyPlayedSongs[index]
                                .artist),
                        trailing: Icon(Icons.more_vert),
                      ),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
