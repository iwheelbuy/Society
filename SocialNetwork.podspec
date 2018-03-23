# git tag 0.1.0
# git push origin 0.1.0
# pod lib lint SocialNetwork.podspec --no-clean
# pod spec lint SocialNetwork.podspec --allow-warnings
# pod trunk push SocialNetwork.podspec --allow-warnings

Pod::Spec.new do |s|

    s.name                  = 'SocialNetwork'
    s.version               = '0.1.0'
    s.ios.deployment_target = '9.0'
    s.source_files          = 'Sources/**/*.swift'
    s.homepage              = 'https://github.com/iwheelbuy/SocialNetwork'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'iWheelBuy' => 'iwheelbuy@gmail.com' }
    s.source                = { :git => 'https://github.com/iwheelbuy/SocialNetwork.git', :tag => s.version.to_s }
    s.summary               = 'SocialNetwork'
    s.description           = 'SocialNetwork +'
    s.cocoapods_version     = '>= 1.4.0'

end
