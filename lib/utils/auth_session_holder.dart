import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class AuthSessionHolder {
  AuthSession _authSession;

  static final AuthSessionHolder _instance = AuthSessionHolder._internal();

  factory AuthSessionHolder() {
    return _instance;
  }

  AuthSessionHolder._internal() {
    this._authSession = null;
  }

  AuthSession get authSession => this._authSession;
  String get jwt => (this._authSession as CognitoAuthSession).userPoolTokens.accessToken;

  Future<AuthSession> loadAuthSession() async {
    if(_authSession != null){
      return _authSession;
    }

    try {
      _authSession = await Amplify.Auth.fetchAuthSession(
        options: CognitoSessionOptions(getAWSCredentials: true),
      );
    } catch (e) {
      print(e.message);
    }
    return _authSession;
  }
}
