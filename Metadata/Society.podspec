Pod::Spec.new do |s|

s.name                  = 'Society'
s.version               = '0.1.0'
s.ios.deployment_target = '9.0'
s.source_files          = '../Sources/**/*.swift'
s.homepage              = 'https://github.com/iwheelbuy/Society'
s.license               = 'MIT'
s.author                = 'iWheelBuy'
s.source                = { :git => 'git@github.com:iwheelbuy/Society.git', :tag => s.version.to_s }
s.summary               = 'Social Networks'
s.cocoapods_version     = '>= 1.4.0'

end

