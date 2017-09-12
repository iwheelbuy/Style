# git tag 0.2.1
# git push origin 0.2.1
# pod lib lint Style.podspec --no-clean
# pod spec lint Style.podspec --allow-warnings
# pod trunk push Style.podspec

Pod::Spec.new do |s|

s.name                  = 'Style'
s.version               = '0.2.1'
s.summary               = 'Elegant UIView customizations in Swift'
s.homepage              = 'https://github.com/iwheelbuy/Style'
s.license               = { :type => 'MIT', :file => 'LICENSE' }
s.author                = { 'iwheelbuy' => 'iwheelbuy@gmail.com' }
s.source                = { :git => 'https://github.com/iwheelbuy/Style.git', :tag => s.version.to_s }
s.ios.deployment_target = '9.0'
s.source_files          = 'Style/Classes/**/*'

end
