//
//  AppsFlyerCommandTracker.swift
//  TealiumAppsFlyer
//
//  Created by Christina S on 5/29/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation
import AppsFlyerLib
#if COCOAPODS
    import TealiumSwift
#else
    import TealiumCore
    import TealiumDelegate
    import TealiumTagManagement
    import TealiumRemoteCommands
#endif


public protocol AppsFlyerTrackable {
    func initialize(appId: String, appDevKey: String, settings: [String: Any]?)
    func trackLaunch()
    func trackEvent(_ eventName: String, values: [String: Any])
    func trackLocation(longitude: Double, latitude: Double)
    func setHost(_ host: String, with prefix: String)
    func setUserEmails(emails: [String], with cryptType: Int)
    func currencyCode(_ currency: String)
    func customerId(_ id: String)
    func disableTracking(_ disable: Bool)
    func resolveDeepLinkURLs(_ urls: [String])
}

public class AppsFlyerCommandTracker: NSObject, AppsFlyerTrackable, TealiumRegistration {

    weak var tealium: Tealium?

    public override init() { }

    public init(tealium: Tealium) {
        super.init()
        self.tealium = tealium
        AppsFlyerTracker.shared().delegate = self
    }

    public func initialize(appId: String, appDevKey: String, settings: [String: Any]?) {
        AppsFlyerTracker.shared().appsFlyerDevKey = appDevKey
        AppsFlyerTracker.shared().appleAppID = appId
        guard let settings = settings else {
            AppsFlyerTracker.shared().appsFlyerDevKey = appDevKey
            AppsFlyerTracker.shared().appleAppID = appId
            return
        }
        if let debug = settings[AppsFlyerConstants.Configuration.debug] as? Bool {
            AppsFlyerTracker.shared().isDebug = debug
        }
        if let disableAdTracking = settings[AppsFlyerConstants.Configuration.disableAdTracking] as? Bool {
            AppsFlyerTracker.shared().disableIAdTracking = disableAdTracking
        }
        if let disableAppleAdTracking = settings[AppsFlyerConstants.Configuration.disableAppleAdTracking] as? Bool {
            AppsFlyerTracker.shared().disableAppleAdSupportTracking = disableAppleAdTracking
        }
        if let minTimeBetweenSessions = settings[AppsFlyerConstants.Configuration.minTimeBetweenSessions] as? Int {
            AppsFlyerTracker.shared().minTimeBetweenSessions = UInt(minTimeBetweenSessions)
        }
        if let anonymizeUser = settings[AppsFlyerConstants.Configuration.anonymizeUser] as? Bool {
            AppsFlyerTracker.shared().deviceTrackingDisabled = anonymizeUser
        }
        
        // [ASK]
        if let shouldCollectDeviceName = settings[AppsFlyerConstants.Configuration.collectDeviceName] as? Bool {
            AppsFlyerTracker.shared().shouldCollectDeviceName = shouldCollectDeviceName
        }
        if let customData = settings[AppsFlyerConstants.Configuration.customData] as? [AnyHashable: Any] {
            AppsFlyerTracker.shared().customData = customData
        }
    }

    public func trackLaunch() {
        AppsFlyerTracker.shared().trackAppLaunch()
    }

    public func trackEvent(_ eventName: String, values: [String: Any]) {
        AppsFlyerTracker.shared().trackEvent(eventName, withValues: values)
    }

    public func trackLocation(longitude: Double, latitude: Double) {
        AppsFlyerTracker.shared().trackLocation(longitude, latitude: latitude)
    }

    /// Used to track push notification activity from native APNs or other push service
    /// Please refer to this for more information:
    /// https://support.appsflyer.com/hc/en-us/articles/207364076-Measuring-Push-Notification-Re-Engagement-Campaigns
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerTracker.shared().handlePushNotification(userInfo)
        AppsFlyerTracker.shared().trackEvent(AppsFlyerConstants.Events.pushNotificationOpened, withValues: [:])
    }

    public func handlePushNofification(payload: [String: Any]?) {
        AppsFlyerTracker.shared().handlePushNotification(payload)
    }

    public func setHost(_ host: String, with prefix: String) {
        AppsFlyerTracker.shared().setHost(host, withHostPrefix: prefix)
    }

    public func setUserEmails(emails: [String], with cryptType: Int) {
        AppsFlyerTracker.shared().setUserEmails(emails, with: EmailCryptType(rawValue: EmailCryptType.RawValue(cryptType)))
    }

    public func currencyCode(_ currency: String) {
        AppsFlyerTracker.shared().currencyCode = currency
    }

    public func customerId(_ id: String) {
        AppsFlyerTracker.shared().customerUserID = id
    }

    public func disableTracking(_ disable: Bool) {
        AppsFlyerTracker.shared().isStopTracking = disable
    }

    /// APNs and Push Messaging must be configured in order to track installs.
    /// Apple will not register the uninstall until 8 days after the user removes the app.
    /// Instructions to set up: https://support.appsflyer.com/hc/en-us/articles/210289286-Uninstall-Measurement#iOS-Uninstall
    public func registerPushToken(_ token: String) {
        guard let dataToken = token.data(using: .utf8) else { return }
        AppsFlyerTracker.shared().registerUninstall(dataToken)
    }

    public func resolveDeepLinkURLs(_ urls: [String]) {
        AppsFlyerTracker.shared().resolveDeepLinkURLs = urls
    }

}

extension AppsFlyerCommandTracker: AppsFlyerTrackerDelegate {

    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        guard let tealium = tealium else { return }
        guard let conversionInfo = conversionInfo as? [String: Any],
              let first_launch_flag = conversionInfo["is_first_launch"] as? Bool else {
                // Fallback
                tealium.track(title: "conversion_data_received",
                data: nil,
                completion: nil)
                return
        }
        guard first_launch_flag else {
            print("Not First Launch")
            return
        }
        tealium.track(title: "conversion_data_received",
        data: conversionInfo,
        completion: nil)
        
        // Debug output
        guard let status = conversionInfo["af_status"] as? String else {
            return
        }
                
        if (status == "Non-organic") {
            if let media_source = conversionInfo["media_source"],
                let campaign = conversionInfo["campaign"] {
                print("This is a Non-Organic install. Media source: \(media_source) Campaign: \(campaign)")
            }
        } else {
            print("This is an organic install.")
        }
    }

    public func onConversionDataFail(_ error: Error) {
        tealium?.track(title: "appsflyer_error",
            data: ["error_name": "conversion_data_failure",
                "error_description": error.localizedDescription],
            completion: nil)
    }
    
    public func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        guard let tealium = tealium else { return }
        guard let attributionData = attributionData as? [String: Any] else {
            return tealium.track(title: "app_open_attribution",
                data: nil,
                completion: nil)
        }
        tealium.track(title: "app_open_attribution",
            data: attributionData,
            completion: nil)
    }

    public func onAppOpenAttributionFailure(_ error: Error) {
        tealium?.track(title: "appsflyer_error",
            data: ["error_name": "app_open_attribution_failure",
                "error_description": error.localizedDescription],
            completion: nil)
    }

}
