import 'dart:async';
import 'package:simple_auth/simple_auth.dart';
import 'package:http/http.dart' as http;
import "dart:convert" as Convert;

abstract class AuthenticatedApi extends Api {
  AuthStorage _authStorage;
  AuthenticatedApi(String identifier,
      {http.Client client, Converter converter, AuthStorage authStorage})
      : super(identifier: identifier, client: client, converter: converter) {
    _authStorage = authStorage ?? AuthStorage.shared;
  }

  Account currentAccount;

  Future<Account> _currentAuthCall;

  ///Call this method to get the Authenticated user.
  Future<Account> authenticate() async {
    if (_currentAuthCall == null) _currentAuthCall = performAuthenticate();
    try {
      var account = await _currentAuthCall;
      _currentAuthCall = null;
      return account;
    } catch (Exception) {
      _currentAuthCall = null;
      throw Exception;
    }
  }

  ///This method is for subclasses only. Call [authenticate()] instead.
  Future<Account> performAuthenticate();
  Future refreshAccount(Account account);

  @override
  Future<Request> interceptRequest(Request request) async {
    Request req = request;
    if (req.authenticated) {
      await verifyCredentials();
      req = await authenticateRequest(request);
    }
    return super.interceptRequest(req);
  }

  ///Called internally to apply the credentials to a request
  Future<Request> authenticateRequest(Request request);

  ///Called to determine if the current credentials are valid.
  Future<bool> verifyCredentials() async {
    if (currentAccount?.isValid() ?? false) return true;
    var account = await authenticate();
    return account != null;
  }

  ///Log the user out
  @override
  Future logOut() async {
    await _authStorage.write(key: identifier, value: '');
    currentAccount?.invalidate();
    currentAccount = null;
  }

  ///This should not be called, it is used to cache the account locally
  Future saveAccountToCache(Account account) async {
    var data = account.toJson();
    var json = Convert.jsonEncode(data);
    await _authStorage.write(key: identifier, value: json);
  }

  ///This should not be called, it is used to cache the account locally
  Future<T> loadAccountFromCache<T extends Account>() async {
    var json = await _authStorage.read(key: identifier);
    if (json == null || json == '') return null;
    try {
      var data = Convert.jsonDecode(json);
      return getAccountFromMap<T>(data);
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  getAccountFromMap<T extends Account>(Map<String, dynamic> data) =>
      Account.fromJson(data);
}
