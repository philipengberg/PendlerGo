use_frameworks!
inhibit_all_warnings!

def ios_pods
    pod 'Reveal-SDK', '9', :configurations => ['Debug']
    
    pod 'Fabric', '1.6.12'
    pod 'Crashlytics', '3.8.5'
    pod 'SnapKit', '3.2.0'
    pod 'DateTools', '2.0.0'
    pod 'Google/Analytics'
    pod 'Google-Mobile-Ads-SDK', '7.21.0'
    pod 'Amplitude-iOS', '3.14.1'
    pod 'GBDeviceInfo', '4.3.0'
    pod 'RxCocoa', '3.6.0'
end

def shared_pods
    pod 'Alamofire', '4.5.0'
    pod 'Moya/RxSwift', '8.0.5'
    pod 'SwiftyJSON', '3.1.4'
    
    pod 'RxSwift', '3.6.0'
    pod 'Action', '3.1.1'
    pod 'RxSwiftExt', '2.5.1'
end

target 'PendlerGo' do
    platform :ios, '9.0'
    ios_pods
    shared_pods
end

target 'TodayWidget' do
    platform :ios, '9.0'
    ios_pods
    shared_pods
end

target 'WatchApp' do
    platform :watchos, '3.0'
    shared_pods
end

target 'WatchApp Extension' do
    platform :watchos, '3.0'
    shared_pods
end
