//
//  AppDelegate.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import UIKit
import Google
import Fabric
import Crashlytics
import RxSwift
import RxCocoa
import DateTools

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let bag = DisposeBag()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if !(TARGET_IPHONE_SIMULATOR)
            Fabric.with([Crashlytics.self])
        #endif
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        UINavigationBar.appearance().backgroundColor = Theme.color.mainColor
        UINavigationBar.appearance().barTintColor = Theme.color.mainColor
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: Theme.font.demiBold(size: .xtraLarge)!, NSForegroundColorAttributeName: UIColor.white]
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        
        self.window?.rootViewController = UINavigationController(rootViewController: BoardContainmentViewController())
        
        self.window?.makeKeyAndVisible()
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
//        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval( UIApplicationBackgroundFetchIntervalMinimum)
//        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil))
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20))
        view.backgroundColor = UIColor.blue.withAlphaComponent(0.05)
        self.window!.rootViewController!.view.addSubview(view)
        
        Analytics.initialize()
        Analytics.UserState.updateUser()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        
//        UIApplication.sharedApplication().cancelAllLocalNotifications()
//        let notification = UILocalNotification()
//        notification.alertBody = "Tjek om dit tog er forsinket"
//        notification.fireDate = NSDate(year: 2016, month: 2, day: 26, hour: 21, minute: 1, second: 0)
//        notification.soundName = UILocalNotificationDefaultSoundName
//        notification.applicationIconBadgeNumber = 5
////        notification.repeatInterval = .Minute
//        UIApplication.sharedApplication().scheduleLocalNotification(notification)
//        
        for lol in UIApplication.shared.scheduledLocalNotifications! {
            print(lol)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        Analytics.UserState.updateUser()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        Settings.initialize()
        Analytics.UserState.updateUser()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        
//        PendlerGoAPI.request(.Board(locationId: Settings.sharedSettings.homeLocation!.id)).mapJSON().mapToObject(DepartureBoard).map({ (board) -> [Departure] in
//            return board.departures
//        }).subscribe(onNext: { (departures) -> Void in
//            
//            self.checkForAnomalies(departures)
//            
//            completionHandler(.NewData)
//            
//        }).addDisposableTo(bag)
        
//        Settings.sharedSettings.homeLocationVariable.asObservable().take(1).subscribe(onNext: { (_) -> Void in
//            
//            
//            completionHandler(.NewData)
//        }).addDisposableTo(bag)
        
        Settings.initialize()
        
    }
    
    func checkForAnomalies(_ departures: [Departure]) {
        var changes = Dictionary<String, String>()
        
        for departure in departures {
            
            guard (departure.departureTime as NSDate).hour() == 7 && (departure.departureTime as NSDate).minute() <= 45 && (departure.departureTime as NSDate).minute() >= 30 else { continue }
            
            if departure.cancelled {
                changes[departure.name] = "\(departure.name) kl. \(departure.time) er AFLYST"
                continue
            }
            
            if departure.isDelayed {
                changes[departure.name] = "\(departure.name) kl. \(departure.time) er \(abs(Int((departure.realDepartureTime as NSDate).minutes(from: departure.departureTime as Date!)))) min forsinket"
            }
            
            if let realTrack = departure.realTrack, departure.hasChangedTrack {
                if var delay = changes[departure.name] {
                    delay += " og skiftet til spor \(realTrack)"
                    changes[departure.name] = delay
                } else {
                    changes[departure.name] = "\(departure.name) kl. \(departure.time) er ændret til Spor \(realTrack)"
                }
            }
        }
        
        if changes.count > 0 {
            self.scheduleNotification(Array(changes.values).joined(separator: "\n"))
        }
    }
    
    func scheduleNotification(_ message: String) {
        UIApplication.shared.cancelAllLocalNotifications()
        let notification = UILocalNotification()
        notification.alertBody = message
        notification.fireDate = Date()
        UIApplication.shared.scheduleLocalNotification(notification)
    }

}

