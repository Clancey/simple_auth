import "dart:async";

import "package:simple_auth/simple_auth.dart";

abstract class Authenticator {
  String identifier;
  String authCode;
  bool allowsCancel = true;
  String title = "Sign in";
  Completer<String> _completer = Completer<String>();
  bool hasCompleted = false;

  Future resetAuthenticator() async {
    //_completer?.completeError(CancelledException());
    hasCompleted = false;
    _completer = Completer<String>();
  }

  ///This method will return once an Auth Code is found.
  Future<String> getAuthCode() => _completer.future;

  ///Cancels the current authentication request.
  void cancel() {
    hasCompleted = true;
    _completer?.completeError(CancelledException());
  }

  ///Call this when you recieve the Auth token.
  void foundAuthCode(String authCode) {
    this.authCode = authCode;
    hasCompleted = true;
    _completer?.complete(authCode);
  }

  ///Cancels the request with an error message.
  void onError(String error) {
    hasCompleted = true;
    _completer?.completeError(new Exception(error));
  }
}
