import Foundation

let urlQueryAllowedSet = CharacterSet.urlQueryAllowed

extension String {
    
    var urlQueryConverted: String? {
        return addingPercentEncoding(withAllowedCharacters: urlQueryAllowedSet)
    }
}

// MARK: -

///
public enum SocialNetwork {
    ///
    case facebook
    ///
    public final class Facebook {
        /// Shared instance of SocialNetwork.Facebook class
        static let shared = SocialNetwork.Facebook()
        ///
        var id: String!
        ///
        public static func prepare(id: String) {
            SocialNetwork.Facebook.shared.id = id
        }
        ///
        static var url: URL? {
            let id = SocialNetwork.Facebook.shared.id
            guard let string = "https://www.facebook.com/v2.12/dialog/oauth?client_id=\(id)&redirect_uri=https://iwheelbuy.github.io/VK/facebook.html&state=fb\(id)&response_type=token".urlQueryConverted else {
                return nil
            }
            guard let url = URL(string: string) else {
                return nil
            }
            return url
        }
    }
}
