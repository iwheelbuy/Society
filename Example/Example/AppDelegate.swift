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
        SocialNetwork.delegate = self
        SocialNetwork.Facebook.dataSource = self
        SocialNetwork.Google.dataSource = self
        SocialNetwork.Odnoklassniki.dataSource = self
        SocialNetwork.Vkontakte.dataSource = self
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                //
//                switch SocialNetwork.Facebook.officialApplicationExists {
//                case true:
//                    UIApplication.shared.openURL(SocialNetwork.Facebook.officialApplicationUrl)
//                case false:
//                    let controller = SFSafariViewController(url: SocialNetwork.Facebook.oauthUrl)
//                    self?.window?.rootViewController?.present(controller, animated: true)
//                }
                //
//                let controller = SFSafariViewController(url: SocialNetwork.Google.url)
                //
                switch SocialNetwork.Odnoklassniki.officialApplicationExists {
                case true:
                    UIApplication.shared.openURL(SocialNetwork.Odnoklassniki.officialApplicationUrl)
                case false:
                    let controller = SFSafariViewController(url: SocialNetwork.Odnoklassniki.oauthUrl)
                    self?.window?.rootViewController?.present(controller, animated: true)
                }
                //
//                let controller = SFSafariViewController(url: SocialNetwork.Vkontakte.url)
                
            }
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url)
        if SocialNetwork.didProceed(url: url) {
            return true
        }
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

extension AppDelegate: SocialNetworkDelegate {
    
    func socialNetwork(socialNetwork: SocialNetwork, didCompleteWithParameters parameters: [String : String]) {
        print(socialNetwork.rawValue, parameters)
    }
}

extension AppDelegate: SocialNetworkFacebookDataSource {
    
    func socialNetworkFacebookClientIdentifier() -> String {
        return "570084943360654"
    }
}

extension AppDelegate: SocialNetworkGoogleDataSource {
    
    func socialNetworkGoogleClientIdentifier() -> String {
        return "683698461214-h7n4hki1pagc5d7fvveq4fbb3baolt72"
    }
}

extension AppDelegate: SocialNetworkOdnoklassnikiDataSource {
    
    func socialNetworkOdnoklassnikiClientIdentifier() -> String {
        return "1264616960"
    }
}

extension AppDelegate: SocialNetworkVkontakteDataSource {
    
    func socialNetworkVkontakteClientIdentifier() -> String {
        return "6357688"
    }
}
