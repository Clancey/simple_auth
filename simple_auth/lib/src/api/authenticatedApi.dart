import 'dart:async';
import 'package:simple_auth/simple_auth.dart';
import 'package:http/http.dart' as http;
import "dart:convert" as Convert;

abstract class AuthenticatedApi extends Api {
  AuthStorage _authStorage;
  AuthenticatedApi(identifier,
      {http.Client client,
      Converter converter,
      AuthStorage authStorage}) : super(identifier:identifier,client:client,converter:converter) {
    _authStorage = authStorage ?? AuthStorage.shared;
  }

  Account currentAccount;

  Future<Account> currentAuthCall;
  Future<Account> authenticate() async {
    if (currentAuthCall == null)
      currentAuthCall = performAuthenticate();
      try{
        var account = await currentAuthCall;
        currentAuthCall = null;
        return account;
      }
      catch(Exception)
      {
        currentAuthCall = null;
        throw Exception;
      }
      
  }

  Future<Account> performAuthenticate();
  Future refreshAccount(Account account);

  @override
  Future<Request> interceptRequest(Request request) async {
    Request req = request;
    if (req.authenticated){ 
      await verifyCredentials();
      req = await authenticateRequest(request);
    }
    return super.interceptRequest(req);
  }

  Future<Request> authenticateRequest(Request request);

  Future<bool> verifyCredentials() async {
    if (currentAccount?.isValid() ?? false) return true;
    var account = await authenticate();
    return account != null;
  }

  @override
  Future logOut() async {
    await _authStorage.write(key: identifier, value: "");
    currentAccount?.invalidate();
    currentAccount = null;
  }

  Future saveAccount(Account account) async {
    var data = account.toJson();
    var json = Convert.jsonEncode(data);
    await _authStorage.write(key: identifier, value: json);
  }

  Future<T> getAccount<T extends Account>() async {
    var json = await _authStorage.read(key: identifier); 
    if (json == null) return null;
    try {
      var data = Convert.jsonDecode(json);
      return getAccountFromMap<T>(data);
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  getAccountFromMap<T extends Account>(Map<String,dynamic> data) => Account.fromJson(data);
}
