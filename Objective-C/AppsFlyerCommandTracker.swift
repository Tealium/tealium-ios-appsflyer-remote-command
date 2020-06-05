//
//  AppsFlyerCommandTracker.swift
//  AppsFlyerRemoteCommand
//
//  Created by Christina Sund on 5/29/19.
//  Copyright © 2019 Christina. All rights reserved.
//

import Foundation
import AppsFlyerLib
import TealiumIOS

@objc
public protocol AppsFlyerTrackable {
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

@objc
public class AppsFlyerCommandTracker: NSObject, AppsFlyerTrackable, TealiumRegistration {

    weak var tealium: Tealium?
    
    @objc
    public override init() { }

    @objc
    public init(tealium: Tealium) {
        super.init()
        self.tealium = tealium
        AppsFlyerTracker.shared().delegate = self
    }

    public func initialize(appId: String, appDevKey: String) {
        AppsFlyerTracker.shared().appsFlyerDevKey = appDevKey
        AppsFlyerTracker.shared().appleAppID = appId
    }

    public func initialize(appId: String, appDevKey: String, config: [String: Any]) {
        AppsFlyerTracker.shared().appsFlyerDevKey = appDevKey
        AppsFlyerTracker.shared().appleAppID = appId
        if let debug = config[AppsFlyerConstants.Configuration.debug] as? Bool {
            AppsFlyerTracker.shared().isDebug = debug
        }
        if let disableAdTracking = config[AppsFlyerConstants.Configuration.disableAdTracking] as? Bool {
            AppsFlyerTracker.shared().disableIAdTracking = disableAdTracking
        }
        if let disableAppleAdTracking = config[AppsFlyerConstants.Configuration.disableAppleAdTracking] as? Bool {
            AppsFlyerTracker.shared().disableAppleAdSupportTracking = disableAppleAdTracking
        }
        if let minTimeBetweenSessions = config[AppsFlyerConstants.Configuration.minTimeBetweenSessions] as? Int {
            AppsFlyerTracker.shared().minTimeBetweenSessions = UInt(minTimeBetweenSessions)
        }
        if let anonymizeUser = config[AppsFlyerConstants.Configuration.anonymizeUser] as? Bool {
            AppsFlyerTracker.shared().deviceTrackingDisabled = anonymizeUser
        }
        if let shouldCollectDeviceName = config[AppsFlyerConstants.Configuration.collectDeviceName] as? Bool {
            AppsFlyerTracker.shared().shouldCollectDeviceName = shouldCollectDeviceName
        }
        if let customData = config[AppsFlyerConstants.Configuration.customData] as? [AnyHashable: Any] {
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
            let firstLaunch = conversionInfo[AppsFlyerConstants.Attribution.firstLaunch] as? Bool else {
                tealium.trackEvent(withTitle: AppsFlyerConstants.Attribution.conversionReceived,
                    dataSources: [:])
                return
        }
        guard firstLaunch else {
            print("\(AppsFlyerConstants.attributionLog)Not First Launch")
            return
        }
        tealium.trackEvent(withTitle: AppsFlyerConstants.Attribution.conversionReceived,
            dataSources: conversionInfo)

        guard let status = conversionInfo[AppsFlyerConstants.Attribution.status] as? String else {
            return
        }
        if (status == "Non-organic") {
            if let mediaSource = conversionInfo[AppsFlyerConstants.Attribution.source],
                let campaign = conversionInfo[AppsFlyerConstants.Attribution.campaign] {
                print("\(AppsFlyerConstants.attributionLog)This is a Non-Organic install. Media source: \(mediaSource) Campaign: \(campaign)")
            }
        } else {
            print("\(AppsFlyerConstants.attributionLog)This is an organic install.")
        }
    }

    public func onConversionDataFail(_ error: Error) {
        tealium?.trackEvent(withTitle: AppsFlyerConstants.Attribution.error,
            dataSources: [AppsFlyerConstants.Attribution.errorName: AppsFlyerConstants.Attribution.conversionFailure,
                AppsFlyerConstants.Attribution.errorDescription: error.localizedDescription])
    }

    public func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        guard let tealium = self.tealium else { return }
        guard let attributionData = attributionData as? [String: Any] else {
            return tealium.trackEvent(withTitle: AppsFlyerConstants.Attribution.appOpen,
                dataSources: [:])
        }
        tealium.trackEvent(withTitle: AppsFlyerConstants.Attribution.appOpen,
            dataSources: attributionData)
    }

    public func onAppOpenAttributionFailure(_ error: Error) {
        tealium?.trackEvent(withTitle: AppsFlyerConstants.Attribution.error,
            dataSources: [AppsFlyerConstants.Attribution.errorName: AppsFlyerConstants.Attribution.appOpenFailure,
                AppsFlyerConstants.Attribution.errorDescription: error.localizedDescription])
    }

}
