platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'PendlerGo'

pod 'Reveal-SDK', '9', :configurations => ['Debug']

pod 'Alamofire', '4.5.0'
pod 'Moya/RxSwift', '8.0.5'
pod 'SwiftyJSON', '3.1.4'

pod 'Fabric', '1.6.12'
pod 'Crashlytics', '3.8.5'

pod 'SnapKit', '3.2.0'

pod 'RxSwift', '3.6.0'
pod 'RxCocoa', '3.6.0'
pod 'Action', '3.1.1'

pod 'DateTools', '1.7.0'

pod 'Google/Analytics'
pod 'Google-Mobile-Ads-SDK', '7.14.0'
pod 'Amplitude-iOS', '3.14.1'

pod 'GBDeviceInfo', '4.3.0'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |configuration|
            configuration.build_settings['SWIFT_VERSION'] = "3.0"
        end
    end
end
