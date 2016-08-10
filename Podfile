# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'

target 'Kenko' do

use_frameworks!
pod 'Parse'
pod 'ParseUI'
pod 'MBProgressHUD'
pod 'Fabric'
pod 'Crashlytics'
pod 'ParseCrashReporting', '~> 1.9'
pod 'ParseFacebookUtilsV4', '~> 1.11'
pod 'FormatterKit', '~> 1.8'
pod 'Canvas'
pod 'FormatterKit'
pod 'UIImageEffects'
pod 'UIImageAFAdditions', :git => 'https://github.com/teklabs/UIImageAFAdditions.git'
pod 'Synchronized'


end

target 'KenkoTests' do

end

target 'KenkoUITests' do

end

# Disable bitcode for now.
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
