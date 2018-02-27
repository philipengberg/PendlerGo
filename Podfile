platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'PendlerGo'

pod 'Reveal-SDK', :configurations => ['Debug']

pod 'Alamofire', '4.1.0'
pod 'Moya/RxSwift', '8.0.0-beta.4'
pod 'SwiftyJSON', '3.1.3'

pod 'Fabric', '1.6.11'
pod 'Crashlytics', '3.8.3'

pod 'SnapKit', '3.0.2'

pod 'RxSwift', '3.0.1'
pod 'RxCocoa', '3.0.1'
pod 'Action', '2.0.0'

pod 'DateTools', '1.7.0'

pod 'Google/Analytics'
pod 'Google-Mobile-Ads-SDK', '7.14.0'
pod 'Amplitude-iOS', '3.11.1'

pod 'GBDeviceInfo', '4.2.2'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |configuration|
            configuration.build_settings['SWIFT_VERSION'] = "3.0"
        end
    end
end
