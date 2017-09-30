# git tag 4.1.0-beta.1
# git push origin 4.1.0-beta.1
# pod lib lint Style.podspec --no-clean
# pod spec lint Style.podspec --allow-warnings
# pod trunk push Style.podspec --allow-warnings

Pod::Spec.new do |s|

s.name                  = 'Style'
s.version               = '4.1.0-beta.1'
s.summary               = 'Elegant UIView customizations in Swift'
s.homepage              = 'https://github.com/iwheelbuy/Style'
s.license               = { :type => 'MIT', :file => 'LICENSE' }
s.author                = { 'iwheelbuy' => 'iwheelbuy@gmail.com' }
s.source                = { :git => 'https://github.com/iwheelbuy/Style.git', :tag => s.version.to_s }
s.ios.deployment_target = '9.0'
s.source_files          = 'Style/Classes/**/*'

end
