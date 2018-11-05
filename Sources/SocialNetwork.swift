import Foundation

private let urlRedirectSimplified = "https://iwheelbuy.github.io/SocialNetwork/simplified.html"

extension String {
    
    var urlHostConverted: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    
    var urlQueryConverted: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
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
    
    init(parameters: [String: String], path: String) {
        let string = path + "?" + parameters.map({ "\($0.key)=\($0.value)" }).joined(separator: "&")
        guard let url = URL(string: string) else {
            fatalError("Failed to create URL from path: \"\(string)\"")
        }
        self = url
    }
}

func getUrlRequestFrom(path: String, parameters: [String: String]) -> URLRequest {
    guard let url = URL(string: path) else {
        fatalError("Failed to create URL from path: \"\(path)\"")
    }
    var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 15)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = parameters.map({ "\($0.key)=\($0.value)" }).joined(separator: "&").data(using: .utf8)
    return request
}

func getParametersFrom(request: URLRequest, _ completion: @escaping ([String: String]) -> ()) {
    switch Thread.isMainThread {
    case true:
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            getParametersFrom(request: request, completion)
        }
    default:
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, _, _) in
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

// MARK: - SocialNetworkDelegate

public protocol SocialNetworkDelegate: class {
    
    func socialNetwork(socialNetwork: SocialNetwork, didCompleteWithParameters parameters: [String: String])
}

// MARK: - SocialNetworkDataSource

public protocol SocialNetworkDataSource: class {
    
    func socialNetworkClientIdentifier(socialNetwork: SocialNetwork) -> String?
    func socialNetworkClientSecret(socialNetwork: SocialNetwork) -> String?
    func socialNetworkPermissions(socialNetwork: SocialNetwork) -> String?
}

public extension SocialNetworkDataSource {
    
    func socialNetworkClientSecret(socialNetwork: SocialNetwork) -> String? {
        return nil
    }
    
    func socialNetworkPermissions(socialNetwork: SocialNetwork) -> String? {
        return nil
    }
}

// MARK: -
/// SocialNetwork
public enum SocialNetwork: String {
    /// SocialNetworkDataSource
    public static weak var dataSource: SocialNetworkDataSource?
    /// SocialNetworkDelegate
    public static weak var delegate: SocialNetworkDelegate?
    /// Facebook
    case facebook = "facebook"
    /// Google
    case google = "google"
    /// Odnoklassniki
    case odnoklassniki = "odnoklassniki"
    /// Vkontakte
    case vkontakte = "vkontakte"
    
    var state: String {
        return "{\"provider\":\"\(self.rawValue)\"}".urlHostConverted!
    }
}

public extension SocialNetwork {
    ///
    public static func didProceed(url: URL) -> Bool {
        if didProceedNative(url: url) {
            return true
        }
        if didProceedOauth(url: url) {
            return true
        }
        return false
    }
    ///
    static func didProceedOauth(url: URL) -> Bool {
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
                fatalError("\(error)")
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
        switch parameters["code"] {
        case .some(let code):
            let request = socialNetwork.getUrlRequest(with: code)
            getParametersFrom(request: request) { (parameters) in
                SocialNetwork.delegate?.socialNetwork(socialNetwork: socialNetwork, didCompleteWithParameters: parameters)
            }
        default:
            async {
                SocialNetwork.delegate?.socialNetwork(socialNetwork: socialNetwork, didCompleteWithParameters: parameters)
            }
        }
        return true
    }
    ///
    static func didProceedNative(url: URL) -> Bool {
        for socialNetwork in [SocialNetwork.facebook, .google, .odnoklassniki, .vkontakte] {
            if socialNetwork.didProceedNative(url: url) {
                return true
            }
        }
        return false
    }
}

extension SocialNetwork {
    
    func didProceedNative(url: URL) -> Bool {
        guard let clientId = SocialNetwork.dataSource?.socialNetworkClientIdentifier(socialNetwork: self) else {
            return false
        }
        
        func getScheme(_ socialNetwork: SocialNetwork) -> String? {
            switch socialNetwork {
            case .facebook:
                return "fb" + clientId
            case .google:
                return nil
            case .odnoklassniki:
                return "ok" + clientId
            case .vkontakte:
                return "vk" + clientId
            }
        }
        
        guard let scheme = getScheme(self), scheme == url.scheme else {
            return false
        }
        let parameters = url
            .absoluteString
            .replacingOccurrences(of: scheme + "://authorize?#", with: scheme + "://authorize?")
            .replacingOccurrences(of: scheme + "://authorize#", with: scheme + "://authorize?")
            .queryItems
        async {
            SocialNetwork.delegate?.socialNetwork(socialNetwork: SocialNetwork.facebook, didCompleteWithParameters: parameters)
        }
        return true
    }
}

public extension SocialNetwork {
    /// Official application exists and allows to authorize
    public var appExists: Bool {
        
        func exists(_ paths: [String]) -> Bool {
            return paths
                .compactMap({ (string: String) -> URL? in
                    return Foundation.URL(string: string)
                })
                .map({ UIApplication.shared.canOpenURL($0) })
                .filter({ $0 == false })
                .count == 0
        }
        
        switch self {
        case .facebook:
            return exists(["fb://", "fbapi://", "fbauth://", "fbauth2://"])
        case .google:
            return false
        case .odnoklassniki:
            return exists(["odnoklassniki://", "okauth://"])
        case .vkontakte:
            return exists(["vk://", "vk-share://", "vkauthorize://"])
        }
    }
}

public extension SocialNetwork {
    /// Official application authorization url
    public var appUrl: URL {
        guard let clientId = SocialNetwork.dataSource?.socialNetworkClientIdentifier(socialNetwork: self) else {
            fatalError("\"\(self.rawValue)\" client identifier is \"nil\"")
        }
        let scope = SocialNetwork.dataSource?.socialNetworkPermissions(socialNetwork: self)
        switch self {
        case .facebook:
            let path = "fbauth://authorize"
            let parameters = [
                "client_id": clientId,
                "sdk": "ios",
                "return_scopes": "true",
                "redirect_uri": "fbconnect://success",
                "scope": scope ?? "public_profile",
                "display": "touch",
                "response_type": "token",
                "legacy_override": "v2.6",
                "sdk_version": "4.7"
            ]
            return URL(parameters: parameters, path: path)
        case .google:
            fatalError("\"\(self.rawValue)\" doesn't allow to open its official application. Does it? PR please")
        case .odnoklassniki:
            let path = "okauth://authorize"
            let parameters = [
                "client_id": clientId,
                "response_type": "token",
                "redirect_uri": "ok" + clientId + "://authorize",
                "scope": scope ?? "VALUABLE_ACCESS",
                "layout": "m"
            ]
            return URL(parameters: parameters, path: path)
        case .vkontakte:
            let path = "vkauthorize://authorize"
            let parameters = [
                "client_id": clientId,
                "revoke": "1",
                "v": "5.87",
                "scope": scope ?? "0",
                "sdk_version": "1.4.6"
            ]
            return URL(parameters: parameters, path: path)
        }
    }
}

public extension SocialNetwork {
    ///
    public var oauthUrl: URL {
        guard let clientId = SocialNetwork.dataSource?.socialNetworkClientIdentifier(socialNetwork: self) else {
            fatalError("\"\(self.rawValue)\" client identifier is \"nil\"")
        }
        let scope = SocialNetwork.dataSource?.socialNetworkPermissions(socialNetwork: self)
        let oauthUsingCodeFlow = SocialNetwork.dataSource?.socialNetworkClientSecret(socialNetwork: self) != nil
        switch self {
        case .facebook:
            switch oauthUsingCodeFlow {
            case false:
                let path = "https://www.facebook.com/v2.12/dialog/oauth"
                let parameters = [
                    "client_id": clientId,
                    "redirect_uri": urlRedirectSimplified,
                    "state": state,
                    "response_type": "token",
                    "scope": scope ?? "public_profile"
                ]
                return URL(parameters: parameters, path: path)
            case true:
                let path = "https://www.facebook.com/v2.12/dialog/oauth"
                let parameters = [
                    "client_id": clientId,
                    "redirect_uri": urlRedirectSimplified,
                    "state": state,
                    "response_type": "code",
                    "scope": scope ?? "public_profile"
                ]
                return URL(parameters: parameters, path: path)
            }
        case .google:
            switch oauthUsingCodeFlow {
            case false:
                let path = "https://accounts.google.com/o/oauth2/v2/auth"
                let parameters = [
                    "client_id": clientId + ".apps.googleusercontent.com",
                    "redirect_uri": urlRedirectSimplified,
                    "state": state,
                    "response_type": "token",
                    "scope": scope ?? "profile"
                ]
                return URL(parameters: parameters, path: path)
            case true:
                let path = "https://accounts.google.com/o/oauth2/v2/auth"
                let parameters = [
                    "client_id": clientId + ".apps.googleusercontent.com",
                    "redirect_uri": urlRedirectSimplified,
                    "response_type": "code",
                    "state": state,
                    "scope": scope ?? "profile"
                ]
                return URL(parameters: parameters, path: path)
            }
        case .odnoklassniki:
            switch oauthUsingCodeFlow {
            case false:
                let path = "https://connect.ok.ru/oauth/authorize"
                let parameters = [
                    "client_id": clientId,
                    "redirect_uri": urlRedirectSimplified,
                    "state": state,
                    "response_type": "token",
                    "scope": scope ?? "VALUABLE_ACCESS",
                    "layout": "m"
                ]
                return URL(parameters: parameters, path: path)
            case true:
                let path = "https://connect.ok.ru/oauth/authorize"
                let parameters = [
                    "client_id": clientId,
                    "redirect_uri": urlRedirectSimplified,
                    "state": state,
                    "response_type": "code",
                    "scope": scope ?? "VALUABLE_ACCESS",
                    "layout": "m"
                ]
                return URL(parameters: parameters, path: path)
            }
        case .vkontakte:
            switch oauthUsingCodeFlow {
            case false:
                let path = "https://oauth.vk.com/authorize"
                let parameters = [
                    "client_id": clientId,
                    "redirect_uri": "vk\(clientId)://authorize".urlHostConverted!,
                    "state": state,
                    "display": "mobile",
                    "sdk_version": "1.4.6",
                    "response_type": "token",
                    "revoke": "1",
                    "scope": scope?.urlQueryConverted ?? "0",
                    "v": "5.87"
                ]
                let url = URL(parameters: parameters, path: path)
                print(url)
                return url
            case true:
                let path = "https://oauth.vk.com/authorize"
                let parameters = [
                    "client_id": clientId,
                    "redirect_uri": urlRedirectSimplified,
                    "state": state,
                    "response_type": "code",
                    "revoke": "1",
                    "scope": scope ?? "0",
                    "v": "5.87"
                ]
                let url = URL(parameters: parameters, path: path)
                return url
            }
        }
    }
}

extension SocialNetwork {
    ///
    func getUrlRequest(with code: String) -> URLRequest {
        guard let clientId = SocialNetwork.dataSource?.socialNetworkClientIdentifier(socialNetwork: self) else {
            fatalError("\"\(self.rawValue)\" client identifier is \"nil\"")
        }
        guard let clientSecret = SocialNetwork.dataSource?.socialNetworkClientSecret(socialNetwork: self) else {
            fatalError("\"\(self.rawValue)\" client secret is \"nil\"")
        }
        switch self {
        case .facebook:
            let path = "https://graph.facebook.com/v2.12/oauth/access_token"
            let parameters = [
                "code": code,
                "client_id": clientId,
                "client_secret": clientSecret,
                "redirect_uri": urlRedirectSimplified
            ]
            return getUrlRequestFrom(path: path, parameters: parameters)
        case .google:
            let path = "https://www.googleapis.com/oauth2/v4/token"
            let parameters = [
                "code": code,
                "client_id": clientId + ".apps.googleusercontent.com",
                "client_secret": clientSecret,
                "redirect_uri": urlRedirectSimplified,
                "grant_type": "authorization_code"
            ]
            return getUrlRequestFrom(path: path, parameters: parameters)
        case .odnoklassniki:
            let path = "https://api.ok.ru/oauth/token.do"
            let parameters = [
                "code": code,
                "client_id": clientId,
                "client_secret": clientSecret,
                "redirect_uri": urlRedirectSimplified,
                "grant_type": "authorization_code"
            ]
            return getUrlRequestFrom(path: path, parameters: parameters)
        case .vkontakte:
            let path = "https://oauth.vk.com/access_token"
            let parameters = [
                "code": code,
                "client_id": clientId,
                "client_secret": clientSecret,
                "redirect_uri": urlRedirectSimplified
            ]
            return getUrlRequestFrom(path: path, parameters: parameters)
        }
    }
}

public extension SocialNetwork {
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
