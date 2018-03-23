import SafariServices
import SocialNetwork
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        return window
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SocialNetwork.Facebook.informationProvider = self
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                let controller = SFSafariViewController(url: SocialNetwork.Facebook.url)
                self?.window?.rootViewController?.present(controller, animated: true)
            }
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        return false
    }
}

extension AppDelegate: SocialNetworkFacebookInformationProvider {
    
    func socialNetworkFacebookApplicationIdentifier() -> String {
        return "570084943360654"
    }
}
