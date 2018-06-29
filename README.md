# Simple Auth for Dart/Flutter
Most apps need to make API calls. Every API needs authentication, yet no developer wants to deal with authentication. Simple Auth embeds authentication into the API so you dont need to deal with it.

This is a port of [Clancey.SimpleAuth](https://github.com/clancey/simpleauth) for Dart and Flutter

The network/api part including the generator was based off of [Chopper by Hadrien Lejard](https://github.com/lejard-h/chopper)

iOS: [![Build status](https://build.appcenter.ms/v0.1/apps/788e968e-4f7d-4c90-a662-9877cee9d85a/branches/master/badge)](https://appcenter.ms)

Android: [![Build status](https://build.appcenter.ms/v0.1/apps/339333fd-8d50-4694-ae98-eea0ec992d58/branches/master/badge)](https://appcenter.ms)

## Providers

### Current Built in Providers

* Azure Active Directory
* Amazon
* Dropbox
* Facebook
* Github
* Google
* Instagram
* Linked In
* Microsoft Live Connect
* And of course any standard OAuth2/Basic Auth server.


# Usage
```dart
var api = new simpleAuth.GoogleApi(
      "google", "client_id",clientSecret: "clientSecret",
      scopes: [
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/userinfo.profile"
      ]);
var request = new Request(HttpMethod.Get, "https://www.googleapis.com/oauth2/v1/userinfo?alt=json");
var userInfo = await api.send<UserInfo>(request);
```
That's it! If the user is not logged in, they will automatically be prompted. If their credentials are cached from a previous session, the api call proceeds!

# Flutter Setup
Call `SimpleAuthFlutter.init();` in your Main.Dart. Now Simple Auth can automatically make present your login UI


# Android Manifest
Android requires you to add the callback scheme:
```xml
<activity android:name="clancey.simpleauth.simpleauthflutter.SimpleAuthCallbackActivity" >
    <intent-filter android:label="simple_auth">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="com.googleusercontent.apps.992461286651-k3tsbcreniknqptanrugsetiimt0lkvo" />
    </intent-filter>
</activity>
```

# iOS
To use the Native Safari Authenticator, you are required to add the following snippet in your AppDelegate.

```
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [SimpleAuthFlutterPlugin checkUrl:url];
}

```

You are also required to add the following to add a CFBundleURLSchemes to your info.plist 

For Google: com.googleusercontent.apps.YOUR_CLIENT_ID

```
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>com.googleusercontent.apps.YOURCLIENTID</string>
			</array>
			<key>CFBundleURLName</key>
			<string>googleLogin</string>
		</dict>
	</array>
	
```


# Serialization
Json objects will automatically serialize if you conform to [JsonSerializable](https://github.com/Clancey/simple_auth/blob/master/simple_auth/lib/src/jsonSerializable.dart)

If you use the generator and you objects have the factory `factory JsonSerializable.fromJson(Map<String, dynamic> json)` your api calls will automatically Serialize/Deserialize

Or you can pass your own [Converter](https://github.com/Clancey/simple_auth/blob/master/simple_auth/lib/src/converter.dart) to the api and handle conversion yourself.

# Generator
### Dart
```
pub run build_runner build
```
or for countinuous generation

```
pub run build_runner watch
```


### flutter
```
flutter packages pub run build_runner build
```
or for countinuous generation

```
flutter packages pub run build_runner watch
```

The Generator is not required, and not complete. But will make things magical. More docs to come!


# TODO
* Add more documentation
* Finish Android Authentication
* Create basic Login screen for Basic Authentication
* Port the rest of the providers
* Add native flutter providers for google
* Add AuthStorage for Flutter
* Complete the generator
* More things I can't remember
