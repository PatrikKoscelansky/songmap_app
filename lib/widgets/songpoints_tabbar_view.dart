import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:songmap_app/models/songpoint_model.dart';
import 'package:songmap_app/screens/add_songpoint_screen.dart';
import 'package:songmap_app/screens/song_point_screen.dart';
import 'package:songmap_app/utils/location_helper.dart';
import 'package:songmap_app/utils/songpoint_provider.dart';

class SongPointsTabBarView extends StatefulWidget {
  final List<SongPoint> initialSongPoints;
  SongPointsTabBarView(this.initialSongPoints);

  @override
  _SongPointsTabBarViewState createState() => _SongPointsTabBarViewState();
}

class _SongPointsTabBarViewState extends State<SongPointsTabBarView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        SongPointsListBody(widget.initialSongPoints),
        Positioned(
          child: Align(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                child: Text('ADD'),
                onPressed: () async {
                  List<SongPoint> songPoints = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddSongPointScreen()));
                  Provider.of<SongPointProvider>(context, listen: false)
                      .addSongPointsToList(songPoints);
                },
              ),
            ),
            alignment: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }
}

class SongPointsListBody extends StatefulWidget {
  final List<SongPoint> initialSongPoints;
  SongPointsListBody(this.initialSongPoints);

  @override
  _SongPointsListBodyState createState() => _SongPointsListBodyState();
}

class _SongPointsListBodyState extends State<SongPointsListBody> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      List<SongPoint> songPoints =
          Provider.of<SongPointProvider>(context, listen: false).nearSongPoints;
      if (songPoints.length == 0) {
        Provider.of<SongPointProvider>(context, listen: false)
            .addSongPointsToList(widget.initialSongPoints);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        LocationData loc = await LocationHelper().getLocation();
        await Provider.of<SongPointProvider>(context, listen: false)
            .getNearSongPoints(loc);
        return null;
      },
      child: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: Provider.of<SongPointProvider>(context)
                    .nearSongPoints
                    .length,
                itemBuilder: (context, index) {
                  return SongPointTile(
                    songPoint: Provider.of<SongPointProvider>(context)
                        .nearSongPoints[index],
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class SongPointTile extends StatelessWidget {
  final SongPoint songPoint;

  SongPointTile({this.songPoint});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text(this.songPoint.song.title),
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SongPointScreen(
                    songPoint: this.songPoint,
                  )));
        },
      ),
    );
  }
}
