# git tag 0.1.3
# git push origin 0.1.3
# pod lib lint SocialNetwork.podspec --allow-warnings
# pod spec lint SocialNetwork.podspec --allow-warnings
# pod trunk push SocialNetwork.podspec --allow-warnings

Pod::Spec.new do |s|

    s.name                  = 'SocialNetwork'
    s.version               = '0.1.3'
    s.ios.deployment_target = '9.0'
    s.source_files          = 'Sources/**/*.swift'
    s.homepage              = 'https://github.com/iwheelbuy/SocialNetwork'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'iWheelBuy' => 'iwheelbuy@gmail.com' }
    s.source                = { :git => 'https://github.com/iwheelbuy/SocialNetwork.git', :tag => s.version.to_s }
    s.summary               = 'SocialNetwork'
    s.description           = 'SocialNetwork handles OAuth for various social networks'
    s.cocoapods_version     = '>= 1.4.0'

end
