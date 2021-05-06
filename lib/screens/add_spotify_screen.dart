import 'dart:io';
import 'package:flutter/material.dart';
import 'package:songmap_app/utils/spotify_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddSpotifyScreen extends StatefulWidget {
  final String url;

  AddSpotifyScreen(this.url);

  @override
  _AddSpotifyScreenState createState() => _AddSpotifyScreenState(url);
}

class _AddSpotifyScreenState extends State<AddSpotifyScreen> {
  _AddSpotifyScreenState(this._url);

  SpotifyAuth spotifyAuth = SpotifyAuth();
  String _url;
  final _key = UniqueKey();
  WebViewController _webController;

  // _AddSpotifyScreenState();
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect to Spotify'),
      ),
//      backgroundColor: Colors.teal,
      body: Column(
        children: <Widget>[
          Expanded(
            child: WebView(
              key: _key,
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: _url,
              onWebViewCreated: (WebViewController webController) async {
                _webController = webController;
                String currentUrl = await _webController.currentUrl();
                print('ON WEBVIEW CREATED URL: ' + currentUrl);
              },
              onPageFinished: (String url) {
                print('ON PAGE FINISHED URL: ' + url);
                Map<String, String> queryParams = _parseQueryParameters(url);
                if (queryParams.containsKey('code')) {
                  print("[AddSpotifyScreen] code: " + queryParams['code']);
                  Navigator.pop(context, queryParams['code']);
                } else if (queryParams.containsKey('error')) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Error occured."),
                  ));
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getCodeFromURL(String url) {
    Map<String, String> params = _parseQueryParameters(url);

    if (params.containsKey('error')) {
      print("[AddSpotifyScreen] " + params['error']);
      return null;
    }

    if (params.containsKey('code')) {
      print("[AddSpotifyScreen] CODE:" + params['code']);
      return params['code'];
    }

    return null;
  }

  Map<String, String> _parseQueryParameters(String url) {
    Map<String, String> params = {};

    var uri = Uri.parse(url);
    uri.queryParameters.forEach((k, v) {
      params[k] = v;
    });

    return params;
  }

  // Future<String> _getCurrentUrl() async {
  //   return await _webController.currentUrl();
  // }
}
