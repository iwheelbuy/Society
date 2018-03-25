import Foundation

private let urlRedirectSimplified = "https://iwheelbuy.github.io/SocialNetwork/simplified.html"
private let urlQueryAllowedSet = CharacterSet.urlQueryAllowed

extension String {
    
    var urlQueryConverted: String? {
        return addingPercentEncoding(withAllowedCharacters: urlQueryAllowedSet)
    }
    
    var queryItems: [String: String] {
        guard let items = URLComponents(string: self)?.queryItems else {
            return [:]
        }
        return items
            .reduce(into: [String:String]()) { (dictionary, item) in
                dictionary[item.name] = item.value
        }
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

// MARK: - SocialNetworkFacebookDataSource

public protocol SocialNetworkFacebookDataSource: class {
    
    func socialNetworkFacebookClientIdentifier() -> String
}

// MARK: - SocialNetworkGoogleDataSource

public protocol SocialNetworkGoogleDataSource: class {
    
    func socialNetworkGoogleClientIdentifier() -> String
}

// MARK: - SocialNetworkOdnoklassnikiDataSource

public protocol SocialNetworkOdnoklassnikiDataSource: class {
    
    func socialNetworkOdnoklassnikiClientIdentifier() -> String
}

// MARK: - SocialNetworkVkontakteDataSource

public protocol SocialNetworkVkontakteDataSource: class {
    
    func socialNetworkVkontakteClientIdentifier() -> String
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
    static func getUrlFrom(path: String, parameters: [String: String]) -> URL {
        let string = path + "?" + parameters.map({ "\($0.key)=\($0.value)" }).joined(separator: "&")
        guard let url = URL(string: string.urlQueryConverted ?? string) else {
            fatalError("Failed to create URL from string: \"\(string)\"")
        }
        return url
    }
}

public extension SocialNetwork {
    ///
    public static func didProceed(url: URL) -> Bool {
        if didProceedOauthSimplified(url: url) {
            return true
        }
        if didProceedNativeSimplified(url: url) {
            return true
        }
        return false
    }
    ///
    static func didProceedOauthSimplified(url: URL) -> Bool {
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
    static func didProceedNativeSimplified(url: URL) -> Bool {
        if didProceedNativeFacebookSimplified(url: url) {
            return true
        }
        if didProceedNativeOdnoklassnikiSimplified(url: url) {
            return true
        }
        return false
    }
    ///
    static func didProceedNativeFacebookSimplified(url: URL) -> Bool {
        guard let provider = SocialNetwork.Facebook.dataSource else {
            return false
        }
        let scheme = "fb" + provider.socialNetworkFacebookClientIdentifier()
        guard scheme == url.scheme else {
            return false
        }
        defer {
            let parameters = url.absoluteString.replacingOccurrences(of: scheme + "://authorize#", with: scheme + "://authorize?").queryItems
            SocialNetwork.delegate?.socialNetwork(socialNetwork: SocialNetwork.facebook, didCompleteWithParameters: parameters)
        }
        return true
    }
    ///
    static func didProceedNativeOdnoklassnikiSimplified(url: URL) -> Bool {
        guard let provider = SocialNetwork.Odnoklassniki.dataSource else {
            return false
        }
        let scheme = "ok" + provider.socialNetworkOdnoklassnikiClientIdentifier()
        guard scheme == url.scheme else {
            return false
        }
        defer {
            let parameters = url.absoluteString.replacingOccurrences(of: scheme + "://authorize#", with: scheme + "://authorize?").queryItems
            SocialNetwork.delegate?.socialNetwork(socialNetwork: SocialNetwork.odnoklassniki, didCompleteWithParameters: parameters)
        }
        return true
    }
}

// MARK: - Facebook

public extension SocialNetwork {
    /// Facebook
    public final class Facebook {
        ///
        public static weak var dataSource: SocialNetworkFacebookDataSource?
        ///
        public static var oauthUrl: URL {
            if let dataSource = dataSource {
                let path = "https://www.facebook.com/v2.12/dialog/oauth"
                let parameters = [
                    "client_id": dataSource.socialNetworkFacebookClientIdentifier(),
                    "redirect_uri": urlRedirectSimplified,
                    "state": "facebook",
                    "response_type": "token",
                    "scope": "email"
                ]
                return SocialNetwork.getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkFacebookDataSource doesn't exist")
        }
        ///
        public static var officialApplicationExists: Bool {
            return ["fb://", "fbapi://", "fbauth://", "fbauth2://"]
                .flatMap({ Foundation.URL(string: $0) })
                .map({ UIApplication.shared.canOpenURL($0) })
                .filter({ $0 == false })
                .count == 0
        }
        ///
        public static var officialApplicationUrl: URL {
            if let dataSource = dataSource {
                let path = "fbauth://authorize"
                let parameters = [
                    "client_id": dataSource.socialNetworkFacebookClientIdentifier(),
                    "sdk": "ios",
                    "return_scopes": "true",
                    "redirect_uri": "fbconnect://success",
                    "scope": "email",
                    "display": "touch",
                    "response_type": "token",
                    "legacy_override": "v2.6",
                    "sdk_version": "4.7"
                ]
                return SocialNetwork.getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkFacebookDataSource doesn't exist")
        }
    }
}

// MARK: - Google

public extension SocialNetwork {
    /// Google
    public final class Google {
        ///
        public static weak var dataSource: SocialNetworkGoogleDataSource?
        ///
        public static var url: URL {
            if let dataSource = dataSource {
                let path = "https://accounts.google.com/o/oauth2/v2/auth"
                let parameters = [
                    "client_id": dataSource.socialNetworkGoogleClientIdentifier() + ".apps.googleusercontent.com",
                    "redirect_uri": urlRedirectSimplified,
                    "state": "google",
                    "response_type": "token",
                    "scope": "email"
                ]
                return SocialNetwork.getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkGoogleDataSource doesn't exist")
        }
    }
}

// MARK: - Odnoklassniki

public extension SocialNetwork {
    /// Odnoklassniki
    public final class Odnoklassniki {
        ///
        public static weak var dataSource: SocialNetworkOdnoklassnikiDataSource?
        ///
        public static var oauthUrl: URL {
            if let dataSource = dataSource {
                let path = "https://connect.ok.ru/oauth/authorize"
                let parameters = [
                    "client_id": dataSource.socialNetworkOdnoklassnikiClientIdentifier(),
                    "redirect_uri": urlRedirectSimplified,
                    "state": "odnoklassniki",
                    "response_type": "token",
                    "scope": "VALUABLE_ACCESS",
                    "layout": "m"
                ]
                return SocialNetwork.getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkOdnoklassnikiDataSource doesn't exist")
        }
        ///
        public static var officialApplicationExists: Bool {
            return ["odnoklassniki://", "okauth://"]
                .flatMap({ Foundation.URL(string: $0) })
                .map({ UIApplication.shared.canOpenURL($0) })
                .filter({ $0 == false })
                .count == 0
        }
        ///
        public static var officialApplicationUrl: URL {
            if let dataSource = dataSource {
                let path = "okauth://authorize"
                let parameters = [
                    "client_id": dataSource.socialNetworkOdnoklassnikiClientIdentifier(),
                    "response_type": "token",
                    "redirect_uri": "ok" + dataSource.socialNetworkOdnoklassnikiClientIdentifier() + "://authorize",
                    "scope": "VALUABLE_ACCESS",
                    "layout": "m"
                ]
                return SocialNetwork.getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkOdnoklassnikiDataSource doesn't exist")
        }
    }
}

// MARK: - Vkontakte

public extension SocialNetwork {
    /// Vkontakte
    public final class Vkontakte {
        ///
        public static weak var dataSource: SocialNetworkVkontakteDataSource?
        ///
        public static var url: URL {
            if let dataSource = dataSource {
                let path = "https://oauth.vk.com/authorize"
                let parameters = [
                    "client_id": dataSource.socialNetworkVkontakteClientIdentifier(),
                    "redirect_uri": urlRedirectSimplified,
                    "state": "vkontakte",
                    "response_type": "token",
                    "scope": "email",
                    "revoke": "1",
                    "v": "5.73"
                ]
                return SocialNetwork.getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkVkontakteDataSource doesn't exist")
        }
    }
}
