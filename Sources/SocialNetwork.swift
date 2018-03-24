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

///
public enum SocialNetwork: String {
    ///
    public static weak var delegate: SocialNetworkDelegate?
    ///
    case facebook = "facebook"
    case google = "google"
    case odnoklassniki = "odnoklassniki"
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
        print(url.pathComponents.map({ $0.lowercased() }))
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
    /// Facebook
    public final class Facebook {
        ///
        public static weak var informationProviderSimplified: SocialNetworkFacebookInformationProviderSimplified?
        ///
        public static var url: URL {
            guard let informationProviderSimplified = informationProviderSimplified else {
                fatalError("SocialNetworkFacebookInformationProviderSimplified doesn't exist")
            }
            let identifier = informationProviderSimplified.socialNetworkFacebookApplicationIdentifier()
            let redirect = "https://iwheelbuy.github.io/SocialNetwork/simplified.html"
            guard let string = "https://www.facebook.com/v2.12/dialog/oauth?client_id=\(identifier)&redirect_uri=\(redirect)&state=facebook&response_type=token&scope=email".urlQueryConverted else {
                fatalError()
            }
            guard let url = URL(string: string) else {
                fatalError()
            }
            return url
        }
    }
    /// Google
    public final class Google {
        ///
        public static weak var informationProviderSimplified: SocialNetworkGoogleInformationProviderSimplified?
        ///
        public static var url: URL {
            guard let informationProviderSimplified = informationProviderSimplified else {
                fatalError("SocialNetworkGoogleInformationProviderSimplified doesn't exist")
            }
            let identifier = informationProviderSimplified.socialNetworkGoogleApplicationIdentifier()
            let redirect = "https://iwheelbuy.github.io/SocialNetwork/simplified.html"
            guard let string = "https://accounts.google.com/o/oauth2/v2/auth?state=google&scope=email&response_type=token&redirect_uri=\(redirect)&client_id=\(identifier).apps.googleusercontent.com".urlQueryConverted, let url = URL(string: string) else {
                fatalError()
            }
            return url
        }
    }
    /// Odnoklassniki
    public final class Odnoklassniki {
        ///
        public static weak var informationProviderSimplified: SocialNetworkOdnoklassnikiInformationProviderSimplified?
        ///
        public static var url: URL {
            guard let informationProviderSimplified = informationProviderSimplified else {
                fatalError("SocialNetworkOdnoklassnikiInformationProviderSimplified doesn't exist")
            }
            let identifier = informationProviderSimplified.socialNetworkOdnoklassnikiApplicationIdentifier()
            let redirect = "https://iwheelbuy.github.io/SocialNetwork/simplified.html"
            guard let string = "https://connect.ok.ru/oauth/authorize?state=odnoklassniki&scope=GET_EMAIL&response_type=token&redirect_uri=\(redirect)&client_id=\(identifier)&layout=m".urlQueryConverted, let url = URL(string: string) else {
                fatalError()
            }
            return url
        }
    }
    /// Vkontakte
    public final class Vkontakte {
        ///
        public static weak var informationProviderSimplified: SocialNetworkVkontakteInformationProviderSimplified?
        ///
        public static var url: URL {
            guard let informationProviderSimplified = informationProviderSimplified else {
                fatalError("SocialNetworkVkontakteInformationProviderSimplified doesn't exist")
            }
            let identifier = informationProviderSimplified.socialNetworkVkontakteApplicationIdentifier()
            let redirect = "https://iwheelbuy.github.io/SocialNetwork/simplified.html"
            guard let string = "https://oauth.vk.com/authorize?client_id=\(identifier)&state=vkontakte&redirect_uri=\(redirect)&response_type=token&revoke=1&v=5.73&scope=email".urlQueryConverted, let url = URL(string: string) else {
                fatalError()
            }
            return url
        }
    }
}
