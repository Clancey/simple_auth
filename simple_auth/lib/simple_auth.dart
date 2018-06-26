library simple_auth;

export 'src/api/api.dart';
export 'src/api/account.dart';
export 'src/converter.dart';
export 'src/jsonSerializable.dart';
export 'src/request.dart';
export 'src/response.dart';
export 'src/authStorage.dart';
export 'src/annotations.dart';
export 'src/api/webAuthenticator.dart';
export 'src/api/authenticatedApi.dart';
export 'src/api/authenticator.dart';
export 'src/cancelledException.dart';
export 'src/oauth/oauthAuthenticator.dart';
export 'src/oauth/oauthAccount.dart';
export 'src/oauth/oauthResponse.dart';
export 'src/oauth/oauthApi.dart';
export 'src/providers/google.dart';
export 'src/basic/basicAuthAccount.dart';
export 'src/basic/basicAuthApi.dart';
export 'src/basic/basicAuthAuthenticator.dart';

// import 'dart:async';
// import 'package:flutter/services.dart';


// class SimpleAuth {
//   static const MethodChannel _channel =
//       const MethodChannel('simple_auth');

//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }
