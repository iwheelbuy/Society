import Foundation

let urlQueryAllowedSet = CharacterSet.urlQueryAllowed

extension String {
    
    var urlQueryConverted: String? {
        return addingPercentEncoding(withAllowedCharacters: urlQueryAllowedSet)
    }
}

// MARK: -

public protocol SocialNetworkFacebookInformationProvider: class {
    
    func socialNetworkFacebookApplicationIdentifier() -> String
    func socialNetworkFacebookRedirectUrl() -> String
}

extension SocialNetworkFacebookInformationProvider {
    
    func socialNetworkFacebookRedirectUrl() -> String {
        return "https://iwheelbuy.github.io/SocialNetwork/facebook.html"
    }
}

// MARK: -

///
public enum SocialNetwork {
    ///
    case facebook
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
}
