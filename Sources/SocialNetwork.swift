import Foundation

let urlQueryAllowedSet = CharacterSet.urlQueryAllowed

extension String {
    
    var urlQueryConverted: String? {
        return addingPercentEncoding(withAllowedCharacters: urlQueryAllowedSet)
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

// MARK: - SocialNetworkDelegate

public protocol SocialNetworkDelegate: class {
    
    func socialNetwork(socialNetwork: SocialNetwork, didCompleteWithParameters parameters: [String: String])
}

// MARK: - SocialNetworkFacebookInformationProviderSimplified

public protocol SocialNetworkFacebookInformationProviderSimplified: class {
    
    func socialNetworkFacebookApplicationIdentifier() -> String
}

// MARK: - SocialNetworkGoogleInformationProviderSimplified

public protocol SocialNetworkGoogleInformationProviderSimplified: class {
    
    func socialNetworkGoogleApplicationIdentifier() -> String
}

// MARK: - SocialNetworkOdnoklassnikiInformationProviderSimplified

public protocol SocialNetworkOdnoklassnikiInformationProviderSimplified: class {
    
    func socialNetworkOdnoklassnikiApplicationIdentifier() -> String
}

// MARK: - SocialNetworkVkontakteInformationProviderSimplified

public protocol SocialNetworkVkontakteInformationProviderSimplified: class {
    
    func socialNetworkVkontakteApplicationIdentifier() -> String
}

// MARK: -
/// SocialNetwork
public enum SocialNetwork: String {
    ///
    public static weak var delegate: SocialNetworkDelegate?
    /// Facebook
    case facebook = "facebook"
    /// Google
    case google = "google"
    /// Odnoklassniki
    case odnoklassniki = "odnoklassniki"
    /// Vkontakte
    case vkontakte = "vkontakte"
    ///
    public static func didProceed(url: URL) -> Bool {
        if didProceedSimplified(url: url) {
            return true
        }
        return false
    }
    ///
    static func didProceedSimplified(url: URL) -> Bool {
        guard url.scheme?.lowercased() == "socialnetwork" else {
            return false
        }
        guard url.pathComponents.map({ $0.lowercased() }).contains("simplified") else {
            return false
        }
        var parameters = url.queryItems
        guard let provider = parameters["state"] else {
            fatalError("\"state\" is missing")
        }
        guard let socialNetwork = SocialNetwork(rawValue: provider) else {
            fatalError("SocialNetwork doesn't contain \"\(provider)\" provider")
        }
        parameters["state"] = nil
        defer {
            SocialNetwork.delegate?.socialNetwork(socialNetwork: socialNetwork, didCompleteWithParameters: parameters)
        }
        return true
    }
    ///
    static func getSimplifiedRedirectUrl() -> String {
        return "https://iwheelbuy.github.io/SocialNetwork/simplified.html"
    }
    ///
    static func getSimplifiedUrl(path: String, parameters: [String: String]) -> URL {
        let string = path + "?" + parameters.map({ "\($0.key)=\($0.value)" }).joined(separator: "&")
        guard let url = URL(string: string.urlQueryConverted ?? string) else {
            fatalError("Failed to create URL from string: \"\(string)\"")
        }
        return url
    }
    /// Facebook
    public final class Facebook {
        ///
        public static weak var informationProviderSimplified: SocialNetworkFacebookInformationProviderSimplified?
        ///
        public static var url: URL {
            if let informationProviderSimplified = informationProviderSimplified {
                let path = "https://www.facebook.com/v2.12/dialog/oauth"
                let parameters = [
                    "client_id": informationProviderSimplified.socialNetworkFacebookApplicationIdentifier(),
                    "redirect_uri": SocialNetwork.getSimplifiedRedirectUrl(),
                    "state": "facebook",
                    "response_type": "token",
                    "scope": "email"
                ]
                return SocialNetwork.getSimplifiedUrl(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkFacebookInformationProviderSimplified doesn't exist")
        }
    }
    /// Google
    public final class Google {
        ///
        public static weak var informationProviderSimplified: SocialNetworkGoogleInformationProviderSimplified?
        ///
        public static var url: URL {
            if let informationProviderSimplified = informationProviderSimplified {
                let path = "https://accounts.google.com/o/oauth2/v2/auth"
                let parameters = [
                    "client_id": informationProviderSimplified.socialNetworkGoogleApplicationIdentifier() + ".apps.googleusercontent.com",
                    "redirect_uri": SocialNetwork.getSimplifiedRedirectUrl(),
                    "state": "google",
                    "response_type": "token",
                    "scope": "email"
                ]
                return SocialNetwork.getSimplifiedUrl(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkGoogleInformationProviderSimplified doesn't exist")
        }
    }
    /// Odnoklassniki
    public final class Odnoklassniki {
        ///
        public static weak var informationProviderSimplified: SocialNetworkOdnoklassnikiInformationProviderSimplified?
        ///
        public static var url: URL {
            if let informationProviderSimplified = informationProviderSimplified {
                let path = "https://connect.ok.ru/oauth/authorize"
                let parameters = [
                    "client_id": informationProviderSimplified.socialNetworkOdnoklassnikiApplicationIdentifier(),
                    "redirect_uri": SocialNetwork.getSimplifiedRedirectUrl(),
                    "state": "odnoklassniki",
                    "response_type": "token",
                    "scope": "GET_EMAIL",
                    "layout": "m"
                ]
                return SocialNetwork.getSimplifiedUrl(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkOdnoklassnikiInformationProviderSimplified doesn't exist")
        }
    }
    /// Vkontakte
    public final class Vkontakte {
        ///
        public static weak var informationProviderSimplified: SocialNetworkVkontakteInformationProviderSimplified?
        ///
        public static var url: URL {
            if let informationProviderSimplified = informationProviderSimplified {
                let path = "https://oauth.vk.com/authorize"
                let parameters = [
                    "client_id": informationProviderSimplified.socialNetworkVkontakteApplicationIdentifier(),
                    "redirect_uri": SocialNetwork.getSimplifiedRedirectUrl(),
                    "state": "vkontakte",
                    "response_type": "token",
                    "scope": "email",
                    "revoke": "1",
                    "v": "5.73"
                ]
                return SocialNetwork.getSimplifiedUrl(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkVkontakteInformationProviderSimplified doesn't exist")
        }
    }
}
