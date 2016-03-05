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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        #if !(TARGET_IPHONE_SIMULATOR)
        Fabric.with([Crashlytics.self])
        #endif
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        
        self.window?.rootViewController = UINavigationController(rootViewController: BoardContainmentViewController())
        
        self.window?.makeKeyAndVisible()
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(
            UIApplicationBackgroundFetchIntervalMinimum)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil))
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        
//        UIApplication.sharedApplication().cancelAllLocalNotifications()
//        let notification = UILocalNotification()
//        notification.alertBody = "Tjek om dit tog er forsinket"
//        notification.fireDate = NSDate(year: 2016, month: 2, day: 26, hour: 21, minute: 1, second: 0)
//        notification.soundName = UILocalNotificationDefaultSoundName
//        notification.applicationIconBadgeNumber = 5
////        notification.repeatInterval = .Minute
//        UIApplication.sharedApplication().scheduleLocalNotification(notification)
//        
        for lol in UIApplication.sharedApplication().scheduledLocalNotifications! {
            print(lol)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        Settings.sharedSettings.initialize()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        PendlerGoDebugAPI.request(.Board(locationId: Settings.sharedSettings.homeLocation!.id)).mapJSON().mapToObject(DepartureBoard).map({ (board) -> [Departure] in
            return board.departures
        }).subscribeNext { (departures) -> Void in
            
            var changes = Dictionary<String, String>()
            
            for departure in departures {
                
                guard departure.departureTime.hour() == 7 && departure.departureTime.minute() <= 45 && departure.departureTime.minute() >= 30 else { continue }
                
                if departure.cancelled {
                    changes[departure.name] = "\(departure.name) kl. \(departure.time) er AFLYST"
                    continue
                }
                
                if departure.isDelayed {
                    changes[departure.name] = "\(departure.name) kl. \(departure.time) er \(abs(Int(departure.realDepartureTime.minutesFrom(departure.departureTime)))) min forsinket"
                }
                
                if let realTrack = departure.realTrack where departure.hasChangedTrack {
                    if var delay = changes[departure.name] {
                        delay += " og skiftet til spor \(realTrack)"
                        changes[departure.name] = delay
                    } else {
                        changes[departure.name] = "\(departure.name) kl. \(departure.time) er ændret til Spor \(realTrack)"
                    }
                }
            }
            
            if changes.count > 0 {
                self.scheduleNotification(Array(changes.values).joinWithSeparator("\n"))
            }
            
            completionHandler(.NewData)
            
        }.addDisposableTo(bag)
        
//        Settings.sharedSettings.homeLocationVariable.asObservable().take(1).subscribeNext({ (_) -> Void in
//            
//            
//            completionHandler(.NewData)
//        }).addDisposableTo(bag)
        
        Settings.sharedSettings.initialize()
        
    }
    
    func scheduleNotification(message: String) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        notification.alertBody = message
        notification.fireDate = NSDate()
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}

