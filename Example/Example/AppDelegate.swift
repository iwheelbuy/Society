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
        SocialNetwork.dataSource = self
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        defer {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//                //
//                switch SocialNetwork.Facebook.appExists {
//                case true:
//                    UIApplication.shared.openURL(SocialNetwork.Facebook.appUrl)
//                case false:
//                    let controller = SFSafariViewController(url: SocialNetwork.Facebook.oauthUrl)
//                    self?.window?.rootViewController?.present(controller, animated: true)
//                }
//                //
////                let controller = SFSafariViewController(url: SocialNetwork.Google.url)
////                self?.window?.rootViewController?.present(controller, animated: true)
//                //
////                switch SocialNetwork.Odnoklassniki.appExists {
////                case true:
////                    UIApplication.shared.openURL(SocialNetwork.Odnoklassniki.appUrl)
////                case false:
////                    let controller = SFSafariViewController(url: SocialNetwork.Odnoklassniki.oauthUrl)
////                    self?.window?.rootViewController?.present(controller, animated: true)
////                }
//                //
////                switch SocialNetwork.Vkontakte.appExists {
////                case true:
////                    UIApplication.shared.openURL(SocialNetwork.Vkontakte.appUrl)
////                case false:
////                    let controller = SFSafariViewController(url: SocialNetwork.Vkontakte.oauthUrl)
////                    self?.window?.rootViewController?.present(controller, animated: true)
////                }
//            }
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

extension AppDelegate: SocialNetworkDataSource {
    
    func socialNetworkClientIdentifier(socialNetwork: SocialNetwork) -> String? {
        switch socialNetwork {
        case .facebook:
            return ""
        case .google:
            return ""
        case .odnoklassniki:
            return ""
        case .vkontakte:
            return ""
        }
    }
    
    func socialNetworkClientSecret(socialNetwork: SocialNetwork) -> String? {
        switch socialNetwork {
        case .facebook:
            return ""
        case .google:
            return ""
        case .odnoklassniki:
            return ""
        case .vkontakte:
            return ""
        }
    }
    
    func socialNetworkPermissions(socialNetwork: SocialNetwork) -> String? {
        switch socialNetwork {
        case .facebook:
            return "public_profile,email"
        case .google:
            return "email profile"
        case .odnoklassniki:
            return "GET_EMAIL,VALUABLE_ACCESS"
        case .vkontakte:
            return "email"
        }
    }
}
