import "dart:async";
import "package:simple_auth/simple_auth.dart";
import "package:http/http.dart" as http;
import "dart:convert" as convert;

typedef void ShowOauthPasswordAuthenticator(
    OauthPasswordAuthenticator authenticator);

class OAuthPasswordApi extends OAuthApi {
  String loginUrl;
  String tokenUrl;
  OauthPasswordAuthenticator currentAuthenticator;
  static ShowOauthPasswordAuthenticator sharedShowAuthenticator;


  OAuthPasswordApi(String identifier, 
      this.loginUrl,
      this.tokenUrl,
      String clientId,
      String clientSecret,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super.fromIdAndSecret(identifier, clientId, clientSecret,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage) {
        this.scopesRequired = false;
      }

  OAuthAccount get currentOauthAccount => currentAccount as OAuthAccount;


  @override
  Future<Account> performAuthenticate() async {
    if (scopesRequired && (scopes?.length ?? 0) == 0) {
      throw Exception("Scopes are required");
    }
    OAuthAccount account =
        currentOauthAccount ?? await loadAccountFromCache<OAuthAccount>();
    if (account != null &&
        ((account.refreshToken?.isNotEmpty ?? false) ||
            (account.expiresIn != null && account.expiresIn <= 0))) {
      var valid = account.isValid();
      if (!valid || forceRefresh ?? false) {
        //If there is no interent, give them the current expired account
        if (!await pingUrl(tokenUrl)) {
          return account;
        }
        if (await refreshAccount(account))
          account = currentOauthAccount ?? loadAccountFromCache<OAuthAccount>();
      }
      if (account.isValid()) {
        saveAccountToCache(account);
        currentAccount = account;
        return account;
      }
    }

    var _authenticator = getAuthenticator();
    await _authenticator.resetAuthenticator();
    if (sharedShowAuthenticator != null)
      sharedShowAuthenticator(_authenticator);
    else
      throw new Exception(
          "You are required to implement the 'showAuthenticator or sharedShowAuthenticator");
    var token = await _authenticator.getAuthCode();
    if (token?.isEmpty ?? true) {
      throw new Exception("Null Token");
    }
    account = await getAccountFromAuthCode(_authenticator);
    saveAccountToCache(account);
    currentAccount = account;
    return account;
  }


  @override  
  OauthPasswordAuthenticator getAuthenticator() => OauthPasswordAuthenticator(identifier, clientId, clientSecret,loginUrl , tokenUrl, baseUrl, redirectUrl, scopes);


  @override
  Future<OAuthAccount> getAccountFromAuthCode(
      WebAuthenticator authenticator) async {
    var auth = authenticator as OauthPasswordAuthenticator;
    return OAuthAccount(identifier,
        created: DateTime.now().toUtc(),
        expiresIn: auth.token.expiresIn,
        refreshToken: auth.token.refreshToken,
        scope: authenticator.scope ?? List<String>(),
        tokenType: auth.token.tokenType,
        token: auth.token.accessToken);
  }
}
