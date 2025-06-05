//
//  AppDelegate.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 8/13/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit
import UserNotifications
import AppsFlyerLib
import TealiumSwift
// AppsFlyer Push Notification Campaign
// https://support.appsflyer.com/hc/en-us/articles/207364076-Measuring-push-notification-re-engagement-campaigns#setting-up-a-push-notification-campaign

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let tealiumHelper = TealiumHelper.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        notificationRegistration(application)
        
        // Initialize AppsFlyer through Tealium Remote Command
        TealiumHelper.trackEvent(title: "initialize", data: [
            "app_id": "1234567890",
            "app_dev_key": "YOUR_APPSFLYER_DEV_KEY"
        ])
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        tealiumHelper.appsFlyerRemoteCommand.onReady { appsFlyer in
            appsFlyer.registerUninstall(deviceToken)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        tealiumHelper.appsFlyerRemoteCommand.onReady { appsFlyer in
            appsFlyer.handlePushNotification(response.notification.request.content.userInfo)
        }
        completionHandler()
    }
    
    func notificationRegistration(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        application.registerForRemoteNotifications()
    }
}

