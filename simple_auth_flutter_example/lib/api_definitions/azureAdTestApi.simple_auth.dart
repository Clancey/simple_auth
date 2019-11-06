// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azureAdTestApi.dart';

// **************************************************************************
// SimpleAuthGenerator
// **************************************************************************

class AzureAdTestApi extends AzureADApi implements AzureADDefinition {
  AzureAdTestApi(String identifier,
      {String clientId: 'client_id',
      String authorizationUrl:
          'https://login.microsoftonline.com/azureTennant/oauth2/authorize',
      String tokenUrl:
          'https://login.microsoftonline.com/azureTennant/oauth2/token',
      String resource: 'resource',
      String redirectUrl: 'redirecturl',
      String clientSecret: 'client_secret',
      List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, authorizationUrl, tokenUrl, resource,
            redirectUrl,
            clientSecret: clientSecret,
            scopes: scopes,
            client: client,
            converter: converter,
            authStorage: authStorage);
}
