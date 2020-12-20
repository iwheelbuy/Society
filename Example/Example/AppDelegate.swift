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

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      SocialNetwork.delegate = self
      SocialNetwork.dataSource = self
      window?.rootViewController = UIViewController()
      window?.makeKeyAndVisible()
      defer {
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            let socialNetwork = SocialNetwork.yandex
            switch socialNetwork.appExists {
            case true:
               UIApplication.shared.open(socialNetwork.appUrl, options: [:], completionHandler: nil)
            case false:
               let controller = SFSafariViewController(url: socialNetwork.oauthUrl)
               self?.window?.rootViewController?.present(controller, animated: true)
            }
         }
      }
      return true
   }

   func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      if SocialNetwork.didProceed(url: url) {
         return true
      }
      return false
   }
}

extension AppDelegate: SocialNetworkDelegate {

   func socialNetwork(socialNetwork: SocialNetwork, didCompleteWithParameters parameters: [String : String]) {
      _ = socialNetwork.getToken(parameters: parameters)
      window?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
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
      case .yandex:
         return "7e0d7e2623e44a46856949e8597f25db"
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
      case .yandex:
         return "40c161a9ee54439c8553a955efcd6d62"
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
      case .yandex:
         return nil
      }
   }
}
