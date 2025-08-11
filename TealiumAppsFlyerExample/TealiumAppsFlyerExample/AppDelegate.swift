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

    func applicationDidBecomeActive(_ application: UIApplication) {
        TealiumHelper.shared.appsFlyerRemoteCommand.onReady { appsFlyer in
            appsFlyer.start()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) { }
    
    // MARK: - Deep Link Handling
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle deep links via AppsFlyer Remote Command
        let data: [String: Any] = [
            "command_name": "handleopen",
            "url": url.absoluteString,
            "options": options.reduce(into: [String: Any]()) { result, pair in
                result[pair.key.rawValue] = pair.value
            }
        ]
        
        // Track via Tealium to trigger Remote Command
        TealiumHelper.trackEvent(title: "handle_deeplink", data: data)
        
        return true
    }
    
    // Alternative method with individual parameters (for compatibility)
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Handle deep links via AppsFlyer Remote Command
        var data: [String: Any] = [
            "command_name": "handleopen",
            "url": url.absoluteString
        ]
        
        if let sourceApp = sourceApplication {
            data["source_application"] = sourceApp
        }
        data["annotation"] = annotation
        
        // Track via Tealium to trigger Remote Command
        TealiumHelper.trackEvent(title: "handle_deeplink", data: data)
        
        return true
    }
    
    // MARK: - Universal Links
    // Extract URL from NSUserActivity and send to the same handleOpen method
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            // Send universal link URL to the same handleOpen command as deep links
            let data: [String: Any] = [
                "command_name": "handleopen",
                "url": url.absoluteString
            ]
            
            // Track via Tealium to trigger Remote Command
            TealiumHelper.trackEvent(title: "handle_universal_link", data: data)
        }
        
        return true
    }
    
    // MARK: - SceneDelegate Support
    /*
     For apps using SceneDelegate, implement similar methods in your SceneDelegate:
     
     func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
         guard let url = URLContexts.first?.url else { return }
         
         let data: [String: Any] = [
             "command_name": "handleopen",
             "url": url.absoluteString,
             "options": URLContexts.first?.options.compactMapValues { $0 } ?? [:]
         ]
         
         TealiumHelper.trackEvent(title: "handle_deeplink", data: data)
     }
     
     func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
         if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL {
             // Same handleOpen command for SceneDelegate universal links
             let data: [String: Any] = [
                 "command_name": "handleopen",
                 "url": url.absoluteString
             ]
             
             TealiumHelper.trackEvent(title: "handle_universal_link", data: data)
         }
     }
     */

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

