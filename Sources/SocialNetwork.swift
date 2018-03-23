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

// MARK: -

public protocol SocialNetworkDelegate: class {
    
    func socialNetwork(socialNetwork: SocialNetwork, didCompleteWithToken token: String?)
}

// MARK: -

public protocol SocialNetworkFacebookInformationProvider: class {
    
    func socialNetworkFacebookApplicationIdentifier() -> String
    func socialNetworkFacebookRedirectUrl() -> String
}

public extension SocialNetworkFacebookInformationProvider {
    
    func socialNetworkFacebookRedirectUrl() -> String {
        return "https://iwheelbuy.github.io/SocialNetwork/facebook.html"
    }
}

// MARK: -

public protocol SocialNetworkGoogleInformationProvider: class {
    
    func socialNetworkGoogleApplicationIdentifier() -> String
    func socialNetworkGoogleRedirectUrl() -> String
}

// MARK: -

///
public enum SocialNetwork: String {
    ///
    public static weak var delegate: SocialNetworkDelegate?
    ///
    case facebook = "facebook"
    case google = "google"
    ///
    public static func didProceed(url: URL) -> Bool {
        guard url.pathComponents.contains("socialnetwork") else {
            return false
        }
        let queryItems = url.queryItems
        func getProvider(queryItems: [String: String]) -> String? {
            if let provider = queryItems["provider"] {
                return provider
            }
            if let state = queryItems["state"], let data = state.data(using: String.Encoding.utf8) {
                if let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let dictionary = object as? [String: String] {
                    return dictionary["provider"]
                }
            }
            return nil
        }
        guard let provider = getProvider(queryItems: queryItems) else {
            return false
        }
        guard let socialNetwork = SocialNetwork(rawValue: provider) else {
            return false
        }
        switch socialNetwork {
        case .facebook:
            let token = queryItems["token"]
            defer {
                SocialNetwork.delegate?.socialNetwork(socialNetwork: socialNetwork, didCompleteWithToken: token)
            }
            return true
        case .google:
            let token = queryItems["token"]
            defer {
                SocialNetwork.delegate?.socialNetwork(socialNetwork: socialNetwork, didCompleteWithToken: token)
            }
            return true
        }
    }
    ///
    public final class Facebook {
        ///
        public static weak var informationProvider: SocialNetworkFacebookInformationProvider?
        ///
        public static var url: URL {
            let identifier = informationProvider!.socialNetworkFacebookApplicationIdentifier()
            let redirect = informationProvider!.socialNetworkFacebookRedirectUrl()
            guard let string = "https://www.facebook.com/v2.12/dialog/oauth?client_id=\(identifier)&redirect_uri=\(redirect)&state=fb\(identifier)&response_type=token".urlQueryConverted else {
                fatalError()
            }
            guard let url = URL(string: string) else {
                fatalError()
            }
            return url
        }
    }
    ///
    public final class Google {
        ///
        public static weak var informationProvider: SocialNetworkGoogleInformationProvider?
        ///
        public static var url: URL {
            let identifier = informationProvider!.socialNetworkGoogleApplicationIdentifier()//com.googleusercontent.apps.
            guard let string = "https://accounts.google.com/o/oauth2/v2/auth?state=\(identifier)&scope=email&response_type=code&redirect_uri=https://iwheelbuy.github.io/SocialNetwork/google.html&client_id=\(identifier).apps.googleusercontent.com".urlQueryConverted, let url = URL(string: string) else {
                fatalError()
            }
            return url
        }
    }
}
