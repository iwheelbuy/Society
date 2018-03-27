# SocialNetwork

[![CI Status](http://img.shields.io/travis/iwheelbuy/SocialNetwork.svg?style=flat)](https://travis-ci.org/iwheelbuy/SocialNetwork)
[![Version](https://img.shields.io/cocoapods/v/SocialNetwork.svg?style=flat)](http://cocoapods.org/pods/SocialNetwork)
[![License](https://img.shields.io/cocoapods/l/SocialNetwork.svg?style=flat)](http://cocoapods.org/pods/SocialNetwork)
[![Platform](https://img.shields.io/cocoapods/p/SocialNetwork.svg?style=flat)](http://cocoapods.org/pods/SocialNetwork)

```ruby
pod 'SocialNetwork', '0.3.2'
```

## Usage

You can open an official application of the social network or present `SFSafariViewController` for authorization:

```swift
switch SocialNetwork.facebook.appExists {
case true:
    UIApplication.shared.openURL(SocialNetwork.facebook.appUrl)
case false:
    let controller = SFSafariViewController(url: SocialNetwork.facebook.oauthUrl)
    UIApplication.shared.keyWindow?.rootViewController?.present(controller: controller)
}
```

## Info.plist setup

To be able to use `appExists` variable you should provide `LSApplicationQueriesSchemes` for desired social networks in `Info.plist`:

```swift
<key>LSApplicationQueriesSchemes</key>
<array>
    <!-- facebook.com -->
    <string>fb</string>
    <string>fbapi</string>
    <string>fbauth</string>
    <string>fbauth2</string>
    <!-- ok.ru -->
    <string>odnoklassniki</string>
    <string>okauth</string>
    <!-- vk.com -->
    <string>vk</string>
    <string>vk-share</string>
    <string>vkauthorize</string>
</array>
```

Required `CFBundleURLType` is `socialnetwork`. Other `CFBundleURLTypes` are optional and should be provided if you plan to use authorization via official applications:

```swift
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>SocialNetwork</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>socialnetwork</string>
            <!-- facebook.com -->
            <string>fb0123456789</string>
            <!-- ok.ru -->
            <string>ok0123456789</string>
            <!-- vk.com -->
            <string>vk0123456789</string>
        </array>
    </dict>
</array>
```

## Basic setup

Set the `SocialNetworkDataSource` and the `SocialNetworkDelegate` somewhere in your project:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    SocialNetwork.dataSource = self
    SocialNetwork.delegate = self
    return true
}
```

Proceed the URL this way:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    if SocialNetwork.didProceed(url: url) {
        return true
    }
    return false
}
```

Conform to `SocialNetworkDelegate` to receive authorization data:

```swift
extension AppDelegate: SocialNetworkDelegate {
    
    func socialNetwork(socialNetwork: SocialNetwork, didCompleteWithParameters parameters: [String : String]) {
        // hide authorization controllers if there are some
        if let token = socialNetwork.getToken(parameters: parameters) {
            // do something with token
        }
    }
}
```

Conform to `SocialNetworkDataSource` and provide information for required social networks:

```swift
extension AppDelegate: SocialNetworkDataSource {
    
    func socialNetworkClientIdentifier(socialNetwork: SocialNetwork) -> String? {
        switch socialNetwork {
        case .facebook:
            return "0123456789"
        default:
            return nil
        }
    }
}
```

There are some additional optional methods, where you can provide client secret for code flow authorization or change the default permissions:

```swift
extension AppDelegate: SocialNetworkDataSource {
    
    func socialNetworkClientSecret(socialNetwork: SocialNetwork) -> String? {
        switch socialNetwork {
        case .facebook:
            return "987654321"
        default:
            return nil
        }
    }
    
    func socialNetworkPermissions(socialNetwork: SocialNetwork) -> String? {
        switch socialNetwork {
        case .facebook:
            return "public_profile,email"
        default:
            return nil
        }
    }
}
```

## Author

iwheelbuy, iwheelbuy@gmail.com

## License

SocialNetwork is available under the MIT license. See the LICENSE file for more info.
