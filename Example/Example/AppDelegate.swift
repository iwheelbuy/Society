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
        SocialNetwork.Facebook.informationProviderSimplified = self
        SocialNetwork.Google.informationProviderSimplified = self
        SocialNetwork.Odnoklassniki.informationProviderSimplified = self
        SocialNetwork.Vkontakte.informationProviderSimplified = self
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//                let controller = SFSafariViewController(url: SocialNetwork.Facebook.url)
                let controller = SFSafariViewController(url: SocialNetwork.Google.url)
//                let controller = SFSafariViewController(url: SocialNetwork.Odnoklassniki.url)
//                let controller = SFSafariViewController(url: SocialNetwork.Vkontakte.url)
                self?.window?.rootViewController?.present(controller, animated: true)
            }
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
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
    
    func socialNetwork(socialNetwork: SocialNetwork, didCompleteWithParameters token: String?) {
        print(socialNetwork.rawValue, token)
    }
}

extension AppDelegate: SocialNetworkFacebookInformationProviderSimplified {
    
    func socialNetworkFacebookApplicationIdentifier() -> String {
        return "570084943360654"
    }
}

extension AppDelegate: SocialNetworkGoogleInformationProviderSimplified {
    
    func socialNetworkGoogleApplicationIdentifier() -> String {
        return "683698461214-h7n4hki1pagc5d7fvveq4fbb3baolt72"
    }
    
    func socialNetworkGoogleRedirectUrl() -> String {
        return "https://iwheelbuy.github.io/SocialNetwork/google.html"
    }
}

extension AppDelegate: SocialNetworkOdnoklassnikiInformationProviderSimplified {
    
    func socialNetworkOdnoklassnikiApplicationIdentifier() -> String {
        return "1264616960"
    }
}

extension AppDelegate: SocialNetworkVkontakteInformationProviderSimplified {
    
    func socialNetworkVkontakteApplicationIdentifier() -> String {
        return "6357688"
    }
}
