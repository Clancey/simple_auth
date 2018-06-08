import "dart:async";

import "package:simple_auth/simple_auth.dart";

abstract class Authenticator {

  String identifier;
  String authCode;
  bool allowsCancel = true;
  String title = "Sign in";
  Completer<String> _completer = Completer<String>();
  bool hasCompleted = false;
  Future resetAuthenticator() async
  {
    //_completer?.completeError(CancelledException());
    hasCompleted = false;
    _completer = Completer<String>();
  } 

  Future<String> getAuthCode() => _completer.future;

  void cancel() {
    hasCompleted = true;
    _completer?.completeError(CancelledException());
  }

  void foundAuthCode(String authCode)
  {
    this.authCode = authCode;
    hasCompleted = true;
    _completer?.complete(authCode);    
  }
  void onError(String error)
  {
    hasCompleted = true;
    _completer?.completeError(new Exception(error));
  }


}