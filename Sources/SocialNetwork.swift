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
            let id = informationProvider!.socialNetworkFacebookApplicationIdentifier()
            guard let string = "https://www.facebook.com/v2.12/dialog/oauth?client_id=\(id)&redirect_uri=https://iwheelbuy.github.io/VK/facebook.html&state=fb\(id)&response_type=token".urlQueryConverted else {
                fatalError()
            }
            guard let url = URL(string: string) else {
                fatalError()
            }
            return url
        }
    }
}
