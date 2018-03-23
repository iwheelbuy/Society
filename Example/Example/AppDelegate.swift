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
        SocialNetwork.Google.informationProvider = self
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        defer {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//                let controller = SFSafariViewController(url: SocialNetwork.Google.url)
//                self?.window?.rootViewController?.present(controller, animated: true)
//            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                let controller = SFSafariViewController(url: SocialNetwork.Facebook.url)
                self?.window?.rootViewController?.present(controller, animated: true)
            }
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url, url.pathComponents, url.queryItems, url.scheme)
        return false
    }
}

extension URL {
    
    var queryItems: [String: String] {
        guard let items = URLComponents(string: absoluteString)?.queryItems else {
            return [:]
        }
        return items
            .reduce(into: [String:String]()) { (dictionary, item) in
                dictionary[item.name] = item.value
        }
    }
}

extension AppDelegate: SocialNetworkFacebookInformationProvider {
    
    func socialNetworkFacebookApplicationIdentifier() -> String {
        return "570084943360654"
    }
}

extension AppDelegate: SocialNetworkGoogleInformationProvider {
    
    func socialNetworkGoogleApplicationIdentifier() -> String {
        return "683698461214-ablpl858n3fta66oq65f2g62aan5duq8"
    }
}
