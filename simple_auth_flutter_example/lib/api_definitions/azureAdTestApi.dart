import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

part 'azureAdTestApi.simple_auth.dart';

@AzureADApiDeclaration(
  "AzureAdTestApi",
  "client_id",
  "resource",
  "redirecturl",
  azureTennant: "azureTennant",
  clientSecret: "client_secret"
)
abstract class AzureADDefinition {

}

