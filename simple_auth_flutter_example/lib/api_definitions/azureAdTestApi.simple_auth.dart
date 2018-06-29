// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azureAdTestApi.dart';

// **************************************************************************
// SimpleAuthGenerator
// **************************************************************************

class AzureAdTestApi extends AzureADApi implements AzureADDefinition {
  AzureAdTestApi(String identifier,
      [String clientId = 'resource',
      String authorizationUrl =
          'https://login.microsoftonline.com/azureTennant/oauth2/authorize',
      String tokenUrl =
          'https://login.microsoftonline.com/azureTennant/oauth2/token',
      String resource = 'client_id',
      String clientSecret = 'client_secret',
      String redirectUrl = 'http://localhost',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage])
      : super(identifier, clientId, authorizationUrl, tokenUrl, resource,
            clientSecret: clientSecret,
            redirectUrl: redirectUrl,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage) {}
}
