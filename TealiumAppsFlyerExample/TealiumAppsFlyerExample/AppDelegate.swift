//
//  AppDelegate.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 8/13/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit
import UserNotifications
// AppsFlyer Push Notification Campaign
// https://support.appsflyer.com/hc/en-us/articles/207364076-Measuring-push-notification-re-engagement-campaigns#setting-up-a-push-notification-campaign

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let tealiumHelper = TealiumHelper.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        notificationRegistration(application)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        print(token)

        let deviceTokenString = String(format: "%@", deviceToken as CVarArg)
        
        // Use rc to register push token
        tealiumHelper.pushMessagingTrackers.forEach { tracker in
            tracker.registerPushToken(deviceTokenString)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Use rc to log push notification receipt/open
        tealiumHelper.pushMessagingTrackers.forEach { tracker in
            tracker.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Use rc to log push notification receipt/open
        tealiumHelper.pushMessagingTrackers.forEach { tracker in
            tracker.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
        }
    }
    
    func notificationRegistration(_ application: UIApplication) {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (granted, error) in
                guard error == nil else {
                    return
                }
                if granted {
                    DispatchQueue.main.async {
                        // use rc to log remote notification opt-in/out
                        self?.tealiumHelper.pushMessagingTrackers.forEach { tracker in
                            tracker.pushAuthorization(fromUserNotificationCenter: granted)
                        }
                        application.registerForRemoteNotifications()
                    }
                }
            }
            application.registerForRemoteNotifications()
        }
        else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
}

