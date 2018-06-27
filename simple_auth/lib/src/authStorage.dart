import 'dart:async';
import 'package:meta/meta.dart';

// class AuthStorage {
//   static AuthStorage shared = new AuthStorage();

//   static const MethodChannel _channel =
//       const MethodChannel('simple_auth');

//   Future<void> write({@required String key, @required String value}) async =>
//       _channel
//           .invokeMethod('write', <String, String>{'key': key, 'value': value});

//   Future<String> read({@required String key}) async {
//     final String value =
//         await _channel.invokeMethod('read', <String, String>{'key': key});
//     return value;
//   }
// }

class AuthStorage {
  static AuthStorage shared = new AuthStorage();
  //We use a basic in memory auth storage for dart.
  Map<String, String> _memoryMap = {};
  Future<void> write({@required String key, @required String value}) async =>
      _memoryMap[key] = value;

  Future<String> read({@required String key}) async =>
      _memoryMap.containsKey(key) ? _memoryMap[key] : null;
}
