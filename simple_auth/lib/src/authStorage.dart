import 'dart:async';
import 'package:meta/meta.dart';

class AuthStorage {
  static AuthStorage shared = new AuthStorage();
  //We use a basic in memory auth storage for dart.
  Map<String, String> _memoryMap = {};
  Future<void> write({@required String key, @required String value}) async =>
      _memoryMap[key] = value;

  Future<String> read({@required String key}) async =>
      _memoryMap.containsKey(key) ? _memoryMap[key] : null;
}
