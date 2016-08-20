# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'

target 'Kenko' do

use_frameworks!
pod 'Parse', '~> 1.7.5'
pod 'ParseFacebookUtils', '~> 1.7.5'
#pod 'ParseFacebookUtilsV4', '~> 1.11'
pod 'ParseCrashReporting', '~> 1.7.5'
# Workaround for the unknown crashes Bolts (https://github.com/BoltsFramework/Bolts-iOS/issues/102)
pod 'Bolts', :git => 'https://github.com/kwkhaw/Bolts-iOS.git'
pod 'ParseUI', '1.1.4'
pod 'MBProgressHUD', '~> 0.9.1'
pod 'Fabric'
pod 'Crashlytics'

pod 'FormatterKit', '~> 1.8'
pod 'Canvas'
pod 'FormatterKit', '~> 1.8.0'
pod 'UIImageEffects', '~> 0.0.1'
pod 'UIImageAFAdditions', :git => 'https://github.com/teklabs/UIImageAFAdditions.git'
pod 'Synchronized', '~> 2.0.0'
pod 'Reachability', '~> 3.2'
pod 'IQKeyboardManagerSwift', '~> 4.0'

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
