//
//  AppDelegate.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 8/13/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit
import UserNotifications
import TealiumSwift

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

