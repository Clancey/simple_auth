import UIKit
import Flutter
import SimpleAuth;

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    override func application(_ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any]?) -> Bool{
        return SimpleAuth.CheckUrl(url);
    }
}
