import "dart:async";
import "package:simple_auth/simple_auth.dart";
import "package:http/http.dart" as http;

typedef void ShowBasicAuthenticator(BasicAuthAuthenticator authenticator);

class BasicAuthApi extends AuthenticatedApi {
  String loginUrl;
  BasicAuthAuthenticator currentAuthenticator;
  static ShowBasicAuthenticator sharedShowAuthenticator;
  ShowBasicAuthenticator showAuthenticator;

  BasicAuthApi(String identifier, this.loginUrl,
      {http.Client client, Converter converter, AuthStorage authStorage})
      : super(identifier,
            client: client, converter: converter, authStorage: authStorage) {
    currentAuthenticator = BasicAuthAuthenticator(client, loginUrl);
  }

  BasicAuthAccount get currentBasicAccount =>
      currentAccount as BasicAuthAccount;

  @override
  Future<Request> authenticateRequest(Request request) async {
    Map<String, String> map = new Map.from(request.headers);
    map["Authorization"] = "Basic ${currentBasicAccount.key}";
    return request.replace(headers: map);
  }

  BasicAuthAuthenticator getAuthenticator() => currentAuthenticator;

  @override
  Future<Account> performAuthenticate() async {
    BasicAuthAccount account =
        currentBasicAccount ?? await loadAccountFromCache<BasicAuthAccount>();
    if (account?.isValid() ?? false) {
      return currentAccount = account;
    }
    BasicAuthAuthenticator authenticator = getAuthenticator();
    await authenticator.resetAuthenticator();

    if (showAuthenticator != null)
      showAuthenticator(authenticator);
    else if (sharedShowAuthenticator != null)
      sharedShowAuthenticator(authenticator);
    else
      throw new Exception(
          "Please call `SimpleAuthFlutter.init();` or implement the 'showAuthenticator' or 'sharedShowAuthenticator'");
    var token = await authenticator.getAuthCode();
    if (token?.isEmpty ?? true) {
      throw new Exception("Null Token");
    }
    account = new BasicAuthAccount(identifier, key: token);
    saveAccountToCache(account);
    currentAccount = account;
    return account;
  }

  @override
  Future refreshAccount(Account account) async {
    //No need to refresh this puppy!
    return;
  }
}
