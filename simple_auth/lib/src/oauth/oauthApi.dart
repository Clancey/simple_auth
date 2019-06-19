import "dart:async";

import "package:simple_auth/simple_auth.dart";
import "package:http/http.dart" as http;
import "dart:convert" as convert;

typedef void ShowAuthenticator(WebAuthenticator authenticator);

class OAuthApi extends AuthenticatedApi {
  static ShowAuthenticator sharedShowAuthenticator;
  ShowAuthenticator showAuthenticator;

  OAuthAuthenticator authenticator;
  String clientId;
  String clientSecret;
  String tokenUrl;
  String authorizationUrl;
  String redirectUrl;
  bool scopesRequired = true;
  List<String> scopes;
  bool forceRefresh = false;

  OAuthApi(identifier, this.clientId, this.clientSecret, this.tokenUrl,
      this.authorizationUrl, this.redirectUrl,
      {this.scopes,
      http.Client client,
      Converter converter,
      bool usePkce,
      AuthStorage authStorage})
      : super(identifier,
            client: client, converter: converter, authStorage: authStorage) {
    authenticator = OAuthAuthenticator(identifier, clientId, clientSecret,
        tokenUrl, authorizationUrl, redirectUrl, scopes, usePkce);
  }

  OAuthApi.fromIdAndSecret(String identifier, this.clientId, this.clientSecret,
      {this.scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier,
            client: client, converter: converter, authStorage: authStorage);

  OAuthApi.fromAuthenticator(String identifier, this.authenticator,
      {http.Client client, Converter converter, AuthStorage authStorage})
      : super(identifier,
            client: client, converter: converter, authStorage: authStorage) {
    this.clientId = authenticator.clientId;
    this.clientSecret = authenticator.clientSecret;
    this.tokenUrl = authenticator.tokenUrl;
    this.scopes = authenticator.scope;
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
    if (showAuthenticator != null)
      showAuthenticator(_authenticator);
    else if (sharedShowAuthenticator != null)
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
  Future<Request> authenticateRequest(Request request) async {
    Map<String, String> map = new Map.from(request.headers);
    map["Authorization"] =
        "${currentOauthAccount.tokenType} ${currentOauthAccount.token}";
    return request.replace(headers: map);
  }

  Future<OAuthAccount> getAccountFromAuthCode(
      WebAuthenticator authenticator) async {
    if (tokenUrl?.isEmpty ?? true) throw new Exception("Invalid tokenURL");
    var postData = await authenticator.getTokenPostData(clientSecret);
    var resp = await httpClient.post(tokenUrl,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: postData);
    var map = convert.json.decode(resp.body);
    var result = OAuthResponse.fromJson(map);
    var account = OAuthAccount(identifier,
        created: DateTime.now().toUtc(),
        expiresIn: result.expiresIn,
        idToken: result.idToken,
        refreshToken: result.refreshToken,
        scope: authenticator.scope,
        tokenType: result.tokenType,
        token: result.accessToken);
    return account;
  }

  Authenticator getAuthenticator() => authenticator;
  @override
  getAccountFromMap<T extends Account>(Map<String, dynamic> data) =>
      OAuthAccount.fromJson(data);
  @override
  Future<bool> refreshAccount(Account _account) async {
    try {
      var account = _account as OAuthAccount;
      if (account == null) throw new Exception("Invalid Account");
      var postData = await getRefreshTokenPostData(account);

      var resp = await httpClient.post(tokenUrl,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: postData);
      var map = convert.json.decode(resp.body);
      var result = OAuthResponse.fromJson(map);
      if (result?.error?.isNotEmpty ?? false) {
        if ((account.refreshToken?.isEmpty ?? true) ||
            result.error == "invalid_grant" ||
            (result.errorDescription?.contains("revoked") ?? false)) {
          account.token = "";
          account.refreshToken = "";
          saveAccountToCache(account);
          return await performAuthenticate() != null;
        } else
          throw new Exception("${result.error} : ${result.errorDescription}");
      }
      if (result.refreshToken?.isNotEmpty ?? false)
        account.refreshToken = result.refreshToken;
      account.tokenType = result.tokenType;
      account.token = result.accessToken;
      account.expiresIn = result.expiresIn;
      account.created = DateTime.now().toUtc();
      currentAccount = account;
      saveAccountToCache(account);
      return true;
    } catch (exception) {}
    return false;
  }

  Future<Map<String, String>> getRefreshTokenPostData(Account account) async {
    var oaccount = account as OAuthAccount;
    if (oaccount == null) throw new Exception("Invalid Account");
    return {
      "grant_type": "refresh_token",
      "refresh_token": oaccount.refreshToken,
      "client_id": clientId,
      "client_secret": clientSecret,
    };
  }
}
