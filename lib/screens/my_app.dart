import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:songmap_app/screens/home_screen.dart';

import '../amplifyconfiguration.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      // Add the following line to add Auth plugin to your app.
      await Amplify.addPlugin(AmplifyAuthCognito());

      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
    } on Exception catch (e) {
      print('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticator = Authenticator(
      child: const Scaffold(
        body: Center(child: Text('You are logged in!')),
      ),
    );

    // Wrap your MaterialApp in an Authenticator component.
    return Authenticator(
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),

        // `builder` must be specified with `Authenticator.builder()`.
        builder: Authenticator.builder(),

        // You can use any combination of `routes`, `home`,
        // `onGenerateRoute`, etc. as long as `builder` is
        // configured as shown above.
        home: HomeScreen(),
      ),
    );
  }
}
