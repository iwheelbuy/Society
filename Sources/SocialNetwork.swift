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

func async(_ block: @escaping () -> ()) {
    DispatchQueue.global().async {
        DispatchQueue.main.async {
            block()
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

func getUrlFrom(path: String, parameters: [String: String]) -> URL {
    let string = path + "?" + parameters.map({ "\($0.key)=\($0.value)" }).joined(separator: "&")
    guard let url = URL(string: string.urlQueryConverted ?? string) else {
        fatalError("Failed to create URL from string: \"\(string)\"")
    }
    return url
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
    func socialNetworkGoogleClientSecret() -> String?
}

public extension SocialNetworkGoogleDataSource {
    
    func socialNetworkGoogleClientSecret() -> String? {
        return nil
    }
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
//    public init?(rawValue: String) {
//        //
//    }
    
    
    /// Official application exists and allows to authorize
    public var appExists: Bool {
        switch self {
        case .facebook:
            return SocialNetwork.Facebook.appExists
        case .google:
            return false
        case .odnoklassniki:
            return SocialNetwork.Odnoklassniki.appExists
        case .vkontakte:
            return SocialNetwork.Vkontakte.appExists
        }
    }
    /// Official application authorization url
    public var appUrl: URL {
        switch self {
        case .facebook:
            return SocialNetwork.Facebook.appUrl
        case .google:
            fatalError("Goodle doesn't allow to open its official application. Does it? PR please")
        case .odnoklassniki:
            return SocialNetwork.Odnoklassniki.appUrl
        case .vkontakte:
            return SocialNetwork.Vkontakte.appUrl
        }
    }
    /// Oauth url
    public var oauthUrl: URL {
        switch self {
        case .facebook:
            return SocialNetwork.Facebook.oauthUrl
        case .google:
            return SocialNetwork.Google.oauthUrl
        case .odnoklassniki:
            return SocialNetwork.Odnoklassniki.oauthUrl
        case .vkontakte:
            return SocialNetwork.Vkontakte.oauthUrl
        }
    }
    /// Get access token from parameters
    public func getToken(parameters: [String: String]) -> String? {
        switch self {
        case .facebook:
            return parameters["access_token"]
        case .google:
            return parameters["id_token"] ?? parameters["access_token"]
        case .odnoklassniki:
            return parameters["access_token"]
        case .vkontakte:
            return parameters["access_token"]
        }
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
        guard let stateJsonString = parameters["state"] else {
            fatalError("\"state\" is missing")
        }
        guard let data = stateJsonString.data(using: .utf8) else {
            fatalError("unable to parse \"state\" json")
        }
        let object: Any = {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch let error {
                fatalError("\"error\"")
            }
        }()
        guard let state = object as? [String: String] else {
            fatalError("\"state\" json is not of type [String: String]")
        }
        guard let provider = state["provider"] else {
            fatalError("\"provider\" is missing")
        }
        guard let socialNetwork = SocialNetwork(rawValue: provider) else {
            fatalError("SocialNetwork doesn't contain \"\(provider)\" provider")
        }
        parameters["state"] = nil
        if socialNetwork == .google, state["jwt"] != nil {
            guard let code = parameters["code"] else {
                fatalError("\"code\" is missing")
            }
            SocialNetwork.Google.exchangeForParameters(code: code) { (parameters) in
                SocialNetwork.delegate?.socialNetwork(socialNetwork: .google, didCompleteWithParameters: parameters)
            }
        } else {
            async {
                SocialNetwork.delegate?.socialNetwork(socialNetwork: socialNetwork, didCompleteWithParameters: parameters)
            }
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
        if didProceedNativeVkontakteSimplified(url: url) {
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
        let parameters = url
            .absoluteString
            .replacingOccurrences(of: scheme + "://authorize#", with: scheme + "://authorize?")
            .queryItems
        async {
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
        let parameters = url
            .absoluteString
            .replacingOccurrences(of: scheme + "://authorize#", with: scheme + "://authorize?")
            .queryItems
        async {
            SocialNetwork.delegate?.socialNetwork(socialNetwork: SocialNetwork.odnoklassniki, didCompleteWithParameters: parameters)
        }
        return true
    }
    ///
    static func didProceedNativeVkontakteSimplified(url: URL) -> Bool {
        guard let provider = SocialNetwork.Vkontakte.dataSource else {
            return false
        }
        let scheme = "vk" + provider.socialNetworkVkontakteClientIdentifier()
        guard scheme == url.scheme else {
            return false
        }
        let parameters = url
            .absoluteString
            .replacingOccurrences(of: scheme + "://authorize?#", with: scheme + "://authorize?")
            .queryItems
        async {
            SocialNetwork.delegate?.socialNetwork(socialNetwork: SocialNetwork.vkontakte, didCompleteWithParameters: parameters)
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
                    "state": "{\"provider\":\"facebook\"}",
                    "response_type": "token",
                    "scope": "public_profile"
                ]
                return getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkFacebookDataSource doesn't exist")
        }
        ///
        public static var appExists: Bool {
            return ["fb://", "fbapi://", "fbauth://", "fbauth2://"]
                .flatMap({ Foundation.URL(string: $0) })
                .map({ UIApplication.shared.canOpenURL($0) })
                .filter({ $0 == false })
                .count == 0
        }
        ///
        public static var appUrl: URL {
            if let dataSource = dataSource {
                let path = "fbauth://authorize"
                let parameters = [
                    "client_id": dataSource.socialNetworkFacebookClientIdentifier(),
                    "sdk": "ios",
                    "return_scopes": "true",
                    "redirect_uri": "fbconnect://success",
                    "scope": "public_profile",
                    "display": "touch",
                    "response_type": "token",
                    "legacy_override": "v2.6",
                    "sdk_version": "4.7"
                ]
                return getUrlFrom(path: path, parameters: parameters)
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
        public static var oauthUrl: URL {
            if let dataSource = dataSource {
                switch dataSource.socialNetworkGoogleClientSecret() {
                case .none:
                    let path = "https://accounts.google.com/o/oauth2/v2/auth"
                    let parameters = [
                        "client_id": dataSource.socialNetworkGoogleClientIdentifier() + ".apps.googleusercontent.com",
                        "redirect_uri": urlRedirectSimplified,
                        "state": "{\"provider\":\"google\"}",
                        "response_type": "token",
                        "scope": "profile"
                    ]
                    return getUrlFrom(path: path, parameters: parameters)
                case .some:
                    let path = "https://accounts.google.com/o/oauth2/v2/auth"
                    let parameters = [
                        "client_id": dataSource.socialNetworkGoogleClientIdentifier() + ".apps.googleusercontent.com",
                        "redirect_uri": urlRedirectSimplified,
                        "state": "{\"provider\":\"google\",\"jwt\":\"1\"}",
                        "response_type": "code",
                        "scope": "profile"
                    ]
                    return getUrlFrom(path: path, parameters: parameters)
                }
            }
            fatalError("SocialNetworkGoogleDataSource doesn't exist")
        }
        public static func exchangeForParameters(code: String, _ completion: @escaping ([String: String]) -> ()) {
            DispatchQueue.global(qos: .userInteractive).async {
                let parameters = [
                    "code": code,
                    "client_id": dataSource!.socialNetworkGoogleClientIdentifier() + ".apps.googleusercontent.com",
                    "client_secret": dataSource!.socialNetworkGoogleClientSecret()!,
                    "redirect_uri": urlRedirectSimplified,
                    "grant_type": "authorization_code"
                ]
                let url = URL(string: "https://www.googleapis.com/oauth2/v4/token")!
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = parameters.map({ "\($0.key)=\($0.value)" }).joined(separator: "&").data(using: .utf8)
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, _) in
                    guard let data = data else {
                        return
                    }
                    guard let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                        return
                    }
                    guard let dictionary = object as? [String: Any] else {
                        return
                    }
                    let parameters = dictionary
                        .reduce(into: [String: String](), { (parameters, object) in
                            switch object.value as? String {
                            case .some(let value):
                                parameters[object.key] = value
                            case .none:
                                parameters[object.key] = String(describing: object.value)
                            }
                        })
                    DispatchQueue.main.async {
                        completion(parameters)
                    }
                })
                task.resume()
            }
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
                    "state": "{\"provider\":\"odnoklassniki\"}",
                    "response_type": "token",
                    "scope": "VALUABLE_ACCESS",
                    "layout": "m"
                ]
                return getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkOdnoklassnikiDataSource doesn't exist")
        }
        ///
        public static var appExists: Bool {
            return ["odnoklassniki://", "okauth://"]
                .flatMap({ Foundation.URL(string: $0) })
                .map({ UIApplication.shared.canOpenURL($0) })
                .filter({ $0 == false })
                .count == 0
        }
        ///
        public static var appUrl: URL {
            if let dataSource = dataSource {
                let path = "okauth://authorize"
                let parameters = [
                    "client_id": dataSource.socialNetworkOdnoklassnikiClientIdentifier(),
                    "response_type": "token",
                    "redirect_uri": "ok" + dataSource.socialNetworkOdnoklassnikiClientIdentifier() + "://authorize",
                    "scope": "VALUABLE_ACCESS",
                    "layout": "m"
                ]
                return getUrlFrom(path: path, parameters: parameters)
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
        public static var oauthUrl: URL {
            if let dataSource = dataSource {
                let path = "https://oauth.vk.com/authorize"
                let parameters = [
                    "client_id": dataSource.socialNetworkVkontakteClientIdentifier(),
                    "redirect_uri": urlRedirectSimplified,
                    "state": "{\"provider\":\"vkontakte\"}",
                    "response_type": "token",
                    "revoke": "1",
                    "v": "5.73"
                ]
                return getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkVkontakteDataSource doesn't exist")
        }
        ///
        public static var appExists: Bool {
            return ["vk://", "vk-share://", "vkauthorize://"]
                .flatMap({ Foundation.URL(string: $0) })
                .map({ UIApplication.shared.canOpenURL($0) })
                .filter({ $0 == false })
                .count == 0
        }
        ///
        public static var appUrl: URL {
            if let dataSource = dataSource {
                let path = "vkauthorize://authorize"
                let parameters = [
                    "client_id": dataSource.socialNetworkVkontakteClientIdentifier(),
                    "revoke": "1",
                    "v": "5.73",
                    "sdk_version": "1.4.6"
                ]
                return getUrlFrom(path: path, parameters: parameters)
            }
            fatalError("SocialNetworkVkontakteDataSource doesn't exist")
        }
    }
}
