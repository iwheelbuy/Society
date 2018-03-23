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

public extension SocialNetworkGoogleInformationProvider {
    
    func socialNetworkGoogleRedirectUrl() -> String {
        return "https://iwheelbuy.github.io/SocialNetwork/google.html"
    }
}

// MARK: -

///
public enum SocialNetwork {
    ///
    case facebook
    case google
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
            let identifier = informationProvider!.socialNetworkGoogleApplicationIdentifier()
            guard let string = "https://accounts.google.com/o/oauth2/v2/auth?scope=email&response_type=code&redirect_uri=com.googleusercontent.apps.\(identifier):/socialnetwork?provider=google&client_id=\(identifier).apps.googleusercontent.com".urlQueryConverted, let url = URL(string: string) else {
                fatalError()
            }
            return url
        }
    }
}
