import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_authenticator/src/keys.dart';
import 'package:amplify_authenticator/src/widgets/component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AmplifySignOutButtonCustom extends StatelessAuthenticatorComponent {
  const AmplifySignOutButtonCustom({Key key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context,
      AuthenticatorState state,
      AuthStringResolver stringResolver,
      ) {
    final buttonResolver = stringResolver.buttons;
    return ListTile(
      key: keySignOutButton,
      title: Text(buttonResolver.resolve(
        context,
        ButtonResolverKey.signout,
      )),
      onTap: state.signOut,
    );
  }
}