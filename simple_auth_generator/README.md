# Simple Auth Generator
This is the API Generator for Simple Auth
# Usage

### Dart
```
pub run build_runner build
```

### flutter
```
flutter packages pub run build_runner build
```

Add the following to your pubspec.yaml
```yaml
dev_dependencies:
  simple_auth_generator: 
  build_runner: ^0.8.0
```

The Generator is not required, however it will make things magical.

```dart
@GoogleApiDeclaration("GoogleTestApi","client_id",clientSecret: "client_secret", scopes: ["TestScope", "Scope2"])
abstract class GoogleTestDefinition {
  @Get(url: "https://www.googleapis.com/oauth2/v1/userinfo?alt=json")
  Future<Response<GoogleUser>> getCurrentUserInfo();
}

```

will generate a new Api for you that is easy to use!

```dart
var api = new GoogleTestApi("google");
var user = await getCurrentUserInfo();
```

For more examples, check out the [example project](https://github.com/Clancey/simple_auth/tree/master/simple_auth_flutter_example/lib/api_definitions)


# Serialization
Json objects will automatically serialize if you conform to [JsonSerializable](https://github.com/Clancey/simple_auth/blob/master/simple_auth/lib/src/jsonSerializable.dart)

If you use the generator and you objects have the factory `factory JsonSerializable.fromJson(Map<String, dynamic> json)` your api calls will automatically Serialize/Deserialize

Or you can pass your own [Converter](https://github.com/Clancey/simple_auth/blob/master/simple_auth/lib/src/converter.dart) to the api and handle conversion yourself.
\