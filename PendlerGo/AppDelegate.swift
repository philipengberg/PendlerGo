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
        
//        Settings.sharedSettings.initialize()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        PendlerGoAPI.request(.Board(locationId: Settings.sharedSettings.workLocation!.id)).mapJSON().mapToObject(DepartureBoard).map({ (board) -> [Departure] in
            return board.departures
        }).subscribeNext { (departures) -> Void in
            
            var delayed = ""
            var track = ""
            for departure in departures {
                if !departure.realTime.isEmpty && departure.time != departure.realTime {
                    delayed += "\(departure.name) kl. \(departure.time) er \(abs(Int(departure.realDepartureTime.minutesFrom(departure.departureTime)))) forsinket"
                }
                
                if let realTrack = departure.realTrack where  realTrack != departure.track {
                    if !track.isEmpty { track += "\n" }
                    track += "\(departure.name) kl. \(departure.time) er ændret til Spor \(realTrack)"
                }
            }
            
            if !track.isEmpty {
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                let notification = UILocalNotification()
                notification.alertBody = track
                notification.fireDate = NSDate()
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.applicationIconBadgeNumber = 5
                //        notification.repeatInterval = .Minute
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }.addDisposableTo(bag)
        
        Settings.sharedSettings.homeLocationVariable.asObservable().take(1).subscribeNext({ (_) -> Void in
            
            
            completionHandler(.NewData)
        }).addDisposableTo(bag)
        
        Settings.sharedSettings.initialize()
        
    }

}

