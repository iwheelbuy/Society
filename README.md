# SocialNetwork

[![CI Status](http://img.shields.io/travis/iwheelbuy/SocialNetwork.svg?style=flat)](https://travis-ci.org/iwheelbuy/SocialNetwork)
[![Version](https://img.shields.io/cocoapods/v/SocialNetwork.svg?style=flat)](http://cocoapods.org/pods/SocialNetwork)
[![License](https://img.shields.io/cocoapods/l/SocialNetwork.svg?style=flat)](http://cocoapods.org/pods/SocialNetwork)
[![Platform](https://img.shields.io/cocoapods/p/SocialNetwork.svg?style=flat)](http://cocoapods.org/pods/SocialNetwork)

## Example

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

## Installation

SocialNetwork is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SocialNetwork', '0.3.2'
```

## Author

iwheelbuy, iwheelbuy@gmail.com

## License

SocialNetwork is available under the MIT license. See the LICENSE file for more info.
