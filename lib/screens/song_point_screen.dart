import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:songmap_app/models/songpoint_model.dart';
import 'package:songmap_app/widgets/AppDrawer.dart';
import 'package:device_apps/device_apps.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class SongPointScreen extends StatelessWidget {
  final SongPoint songPoint;

  SongPointScreen({this.songPoint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SongPoint detail"),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              songPoint.song.title,
              textAlign: TextAlign.start,
            ),
            TextButton(
              onPressed: () async {
                print("is pressed");
                //  TODO: https://stackoverflow.com/questions/55771211/can-any-one-tell-me-how-to-open-another-app-using-flutter
                bool isInstalled =
                await DeviceApps.isAppInstalled('com.spotify.music');
                if (isInstalled) {
                  print("is installed");
                  if (Platform.isAndroid) {
                    print("is android");

                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: "spotify:track:" + songPoint.song.spotifyId,
                      arguments: {
                        'EXTRA_REFERRER': 'com.patrikkoscelansky.songmap_app'
                      },
                    );
                    await intent.launch();
                  }
                } else {}
              },
              child: Text("Open in Spotify"),
            )
          ],
        ),
      ),
    );
  }
}
