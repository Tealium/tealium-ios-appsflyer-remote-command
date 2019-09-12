//
//  AppsFlyerCommandRunner.swift
//  AppsFlyerRemoteCommand
//
//  Created by Christina Sund on 5/29/19.
//  Copyright © 2019 Christina. All rights reserved.
//

import Foundation
import AppsFlyerLib
import TealiumSwift

protocol AppsFlyerCommandRunnable {
    func initialize(appId: String, appDevKey: String)
    func initialize(appId: String, appDevKey: String, config: [String: Any])
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

class AppsFlyerCommandRunner: NSObject, AppsFlyerCommandRunnable, TealiumRegistration {

    override init() {
        super.init()
        AppsFlyerTracker.shared().delegate = self
    }
    
    func initialize(appId: String, appDevKey: String) {
        AppsFlyerTracker.shared().appsFlyerDevKey = appDevKey
        AppsFlyerTracker.shared().appleAppID = appId
    }
    
    func initialize(appId: String, appDevKey: String, config: [String: Any]) {
        AppsFlyerTracker.shared().appsFlyerDevKey = appDevKey
        AppsFlyerTracker.shared().appleAppID = appId
        if let debug = config[AppsFlyer.Configuration.debug] as? Bool {
            AppsFlyerTracker.shared().isDebug = debug
        }
        if let disableAdTracking = config[AppsFlyer.Configuration.disableAdTracking] as? Bool {
            AppsFlyerTracker.shared().disableIAdTracking = disableAdTracking
        }
        if let disableAppleAdTracking = config[AppsFlyer.Configuration.disableAppleAdTracking] as? Bool {
            AppsFlyerTracker.shared().disableAppleAdSupportTracking = disableAppleAdTracking
        }
        if let minTimeBetweenSessions = config[AppsFlyer.Configuration.minTimeBetweenSessions] as? Int {
            AppsFlyerTracker.shared().minTimeBetweenSessions = UInt(minTimeBetweenSessions)
        }
        if let anonymizeUser = config[AppsFlyer.Configuration.anonymizeUser] as? Bool {
            AppsFlyerTracker.shared().deviceTrackingDisabled = anonymizeUser
        }
        if let shouldCollectDeviceName = config[AppsFlyer.Configuration.collectDeviceName] as? Bool {
            AppsFlyerTracker.shared().shouldCollectDeviceName = shouldCollectDeviceName
        }
        if let customData = config[AppsFlyer.Configuration.customData] as? [AnyHashable: Any] {
            AppsFlyerTracker.shared().customData = customData
        }
    }
    
    func trackLaunch() {
        AppsFlyerTracker.shared().trackAppLaunch()
    }
    
    func trackEvent(_ eventName: String, values: [String : Any]) {
        AppsFlyerTracker.shared()?.trackEvent(eventName, withValues: values)
    }
    
    func trackLocation(longitude: Double, latitude: Double) {
        AppsFlyerTracker.shared()?.trackLocation(longitude, latitude: latitude)
    }
    
    /// Used to track push notification activity from native APNs or other push service
    /// Please refer to this for more information:
    /// https://support.appsflyer.com/hc/en-us/articles/207364076-Measuring-Push-Notification-Re-Engagement-Campaigns
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerTracker.shared()?.handlePushNotification(userInfo)
        AppsFlyerTracker.shared()?.trackEvent(AppsFlyer.Events.pushNotificationOpened, withValues: [:])
    }
    
    func handlePushNofification(payload: [String : Any]?) {
        AppsFlyerTracker.shared()?.handlePushNotification(payload)
    }
    
    func setHost(_ host: String, with prefix: String) {
        AppsFlyerTracker.shared()?.setHost(host, withHostPrefix: prefix)
    }
    
    func setUserEmails(emails: [String], with cryptType: Int) {
        AppsFlyerTracker.shared()?.setUserEmails(emails, with: EmailCryptType(rawValue: EmailCryptType.RawValue(cryptType)))
    }
    
    func currencyCode(_ currency: String) {
        AppsFlyerTracker.shared()?.currencyCode = currency
    }
    
    func customerId(_ id: String) {
        AppsFlyerTracker.shared()?.customerUserID = id
    }
    
    func disableTracking(_ disable: Bool) {
        AppsFlyerTracker.shared()?.isStopTracking = disable
    }
    
    /// APNs and Push Messaging must be configured in order to track installs.
    /// Apple will not register the uninstall until 8 days after the user removes the app.
    /// Instructions to set up: https://support.appsflyer.com/hc/en-us/articles/210289286-Uninstall-Measurement#iOS-Uninstall
    func registerPushToken(_ token: String) {
        guard let dataToken = token.data(using: .utf8) else { return }
        AppsFlyerTracker.shared()?.registerUninstall(dataToken)
    }
    
    func resolveDeepLinkURLs(_ urls: [String]) {
        AppsFlyerTracker.shared()?.resolveDeepLinkURLs = urls
    }
   
}

extension AppsFlyerCommandRunner: AppsFlyerTrackerDelegate {
    
    func onConversionDataReceived(_ installData: [AnyHashable : Any]!) {
        guard let installData = installData as? [String: Any] else {
            return TealiumHelper.trackEvent(title: "conversion_data_received", data: nil)
        }
        TealiumHelper.trackEvent(title: "conversion_data_received", data: installData)
    }
    
    func onConversionDataRequestFailure(_ error: Error!) {
        TealiumHelper.trackEvent(title: "appsflyer_error", data: ["error_name": "conversion_data_request_failure",
                                                                 "error_description": error.localizedDescription])
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]!) {
        guard let attributionData = attributionData as? [String: Any] else {
            return TealiumHelper.trackEvent(title: "app_open_attribution", data: [:])
        }
        TealiumHelper.trackEvent(title: "app_open_attribution", data: attributionData)
    }
    
    func onAppOpenAttributionFailure(_ error: Error!) {
        TealiumHelper.trackEvent(title: "appsflyer_error", data: ["error_name": "app_open_attribution_failure",
                                                                 "error_description": error.localizedDescription])
    }
    
}
