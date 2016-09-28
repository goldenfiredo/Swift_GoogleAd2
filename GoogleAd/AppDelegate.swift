//
//  AppDelegate.swift
//  GoogleAd
//
//  Created by Limin Du on 8/27/14.
//  Copyright (c) 2014 GoldenFire.Do. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error ) in
                
            }

        } else {
            // Fallback on earlier versions
            let settings = UIUserNotificationSettings(types:[UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound], categories:nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        cancelLocalNotification()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        //For demo purpose, I'll send notification after 1 minute, 8 minutes and 27 minutes
        setLocalNotification(1)
        setLocalNotification(2)
        setLocalNotification(3)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        cancelLocalNotification()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, handleWatchKitExtensionRequest
        userInfo: [AnyHashable: Any]?, reply: (@escaping ([AnyHashable: Any]?) -> Void)) {
            print("in handleWatchKitExtensionRequest")
            
            let info = userInfo as? [String: String]
            let command = info?["command"]
            if command != nil && command == "Refresh" {
                print("post kRefreshFMDBNotification")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "kRefreshFMDBNotification"), object: nil)
                //reply.map { $0(["response" : "success"]) }
                reply(["response" : "success"])
            } else {
                //reply.map { $0(["response" : "fail"]) }
                reply(["response" : "fail"])
            }
    }

    func setLocalNotification(_ num:Int) {
        let unit = 60.0 //minutes
        let interval:TimeInterval = unit * Double(num) * Double(num) * Double(num)
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = "Notification"
            content.body = "It's time to notify you"
            content.sound = UNNotificationSound.default()
            content.badge = num as NSNumber?
            
            let identifier = String(format: "mynotification%d", num)
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error) in
            }
            
        } else {
            let noti = UILocalNotification()
            let now = Date()
            
            noti.fireDate = Date(timeInterval: interval, since: now)
            noti.alertBody = "It's time to notify you"
            noti.timeZone = TimeZone(identifier:"GMT")
            noti.soundName = UILocalNotificationDefaultSoundName
            noti.applicationIconBadgeNumber = num
            UIApplication.shared.scheduleLocalNotification(noti)
        }
    }

    func cancelLocalNotification() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            //center.removeDeliveredNotifications(withIdentifiers: ["my notification"])
            center.removePendingNotificationRequests(withIdentifiers: ["mynotification1","mynotification2","mynotification3"])
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
}

