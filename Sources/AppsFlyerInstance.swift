//
//  AppsFlyerInstance.swift
//  TealiumAppsFlyer
//
//  Created by Christina S on 5/29/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import UIKit
import AppsFlyerLib
#if COCOAPODS
    import TealiumSwift
#else
    import TealiumCore
    import TealiumRemoteCommands
#endif


public protocol AppsFlyerCommand {
    func initialize(appId: String, appDevKey: String, settings: [String: Any]?)
    func logEvent(_ eventName: String, values: [String: Any])
    func logLocation(longitude: Double, latitude: Double)
    func setHost(_ host: String, with prefix: String)
    func setUserEmails(emails: [String], with cryptType: Int)
    func currencyCode(_ currency: String)
    func customerId(_ id: String)
    func disableTracking(_ disable: Bool)
    func resolveDeepLinkURLs(_ urls: [String])
}

public class AppsFlyerInstance: NSObject, AppsFlyerCommand, TealiumRegistration {

    weak var tealium: Tealium?

    public override init() { }

    public init(tealium: Tealium) {
        super.init()
        self.tealium = tealium
        AppsFlyerLib.shared().delegate = self
    }

    public func initialize(appId: String, appDevKey: String, settings: [String: Any]?) {
        AppsFlyerLib.shared().appsFlyerDevKey = appDevKey
        AppsFlyerLib.shared().appleAppID = appId
        guard let settings = settings else {
            AppsFlyerLib.shared().appsFlyerDevKey = appDevKey
            AppsFlyerLib.shared().appleAppID = appId
            return
        }
        if let debug = settings[AppsFlyerConstants.Configuration.debug] as? Bool {
            AppsFlyerLib.shared().isDebug = debug
        }
        if let disableAdTracking = settings[AppsFlyerConstants.Configuration.disableAdTracking] as? Bool {
            AppsFlyerLib.shared().disableAdvertisingIdentifier = disableAdTracking
            AppsFlyerLib.shared().disableIDFVCollection = disableAdTracking
        }
        if let disableAppleAdTracking = settings[AppsFlyerConstants.Configuration.disableAppleAdTracking] as? Bool {
            AppsFlyerLib.shared().disableSKAdNetwork = disableAppleAdTracking
        }
        if let minTimeBetweenSessions = settings[AppsFlyerConstants.Configuration.minTimeBetweenSessions] as? Int {
            AppsFlyerLib.shared().minTimeBetweenSessions = UInt(minTimeBetweenSessions)
        }
        if let anonymizeUser = settings[AppsFlyerConstants.Configuration.anonymizeUser] as? Bool {
            AppsFlyerLib.shared().anonymizeUser = anonymizeUser
        }
        if let shouldCollectDeviceName = settings[AppsFlyerConstants.Configuration.collectDeviceName] as? Bool {
            AppsFlyerLib.shared().shouldCollectDeviceName = shouldCollectDeviceName
        }
        if let customData = settings[AppsFlyerConstants.Configuration.customData] as? [AnyHashable: Any] {
            AppsFlyerLib.shared().customData = customData
        }
    }

    public func logEvent(_ eventName: String, values: [String: Any]) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: values)
    }

    public func logLocation(longitude: Double, latitude: Double) {
        AppsFlyerLib.shared().logLocation(longitude: longitude, latitude: latitude)
    }

    /// Used to track push notification activity from native APNs or other push service
    /// Please refer to this for more information:
    /// https://support.appsflyer.com/hc/en-us/articles/207364076-Measuring-Push-Notification-Re-Engagement-Campaigns
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
        AppsFlyerLib.shared().logEvent(AppsFlyerConstants.Events.pushNotificationOpened, withValues: [:])
    }

    public func handlePushNofification(payload: [String: Any]?) {
        AppsFlyerLib.shared().handlePushNotification(payload)
    }

    public func setHost(_ host: String, with prefix: String) {
        AppsFlyerLib.shared().setHost(host, withHostPrefix: prefix)
    }

    public func setUserEmails(emails: [String], with cryptType: Int) {
        AppsFlyerLib.shared().setUserEmails(emails, with: EmailCryptType(rawValue: EmailCryptType.RawValue(cryptType)))
    }

    public func currencyCode(_ currency: String) {
        AppsFlyerLib.shared().currencyCode = currency
    }

    public func customerId(_ id: String) {
        AppsFlyerLib.shared().customerUserID = id
    }

    public func disableTracking(_ disable: Bool) {
        AppsFlyerLib.shared().isStopped = disable
    }

    /// APNs and Push Messaging must be configured in order to track installs.
    /// Apple will not register the uninstall until 8 days after the user removes the app.
    /// Instructions to set up: https://support.appsflyer.com/hc/en-us/articles/210289286-Uninstall-Measurement#iOS-Uninstall
    public func registerPushToken(_ token: String) {
        guard let dataToken = token.data(using: .utf8) else { return }
        AppsFlyerLib.shared().registerUninstall(dataToken)
    }

    public func resolveDeepLinkURLs(_ urls: [String]) {
        AppsFlyerLib.shared().resolveDeepLinkURLs = urls
    }

}

extension AppsFlyerInstance: AppsFlyerLibDelegate {

    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        guard let conversionInfo = conversionInfo as? [String: Any],
            let firstLaunch = conversionInfo[AppsFlyerConstants.Attribution.firstLaunch] as? Bool else {
            tealiumTrack(title: AppsFlyerConstants.Attribution.conversionReceived)
                return
        }
        guard firstLaunch else {
            print("\(AppsFlyerConstants.attributionLog)Not First Launch")
            return
        }
        tealiumTrack(title: AppsFlyerConstants.Attribution.conversionReceived)

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
        tealiumTrack(title: AppsFlyerConstants.Attribution.error,
            data: [AppsFlyerConstants.Attribution.errorName: AppsFlyerConstants.Attribution.conversionFailure,
                AppsFlyerConstants.Attribution.errorDescription: error.localizedDescription])
    }

    public func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        guard let attributionData = attributionData as? [String: Any] else {
            return tealiumTrack(title: AppsFlyerConstants.Attribution.appOpen)
        }
        tealiumTrack(title: AppsFlyerConstants.Attribution.appOpen,
            data: attributionData)
    }

    public func onAppOpenAttributionFailure(_ error: Error) {
        tealiumTrack(title: AppsFlyerConstants.Attribution.error,
            data: [AppsFlyerConstants.Attribution.errorName: AppsFlyerConstants.Attribution.appOpenFailure,
                AppsFlyerConstants.Attribution.errorDescription: error.localizedDescription])
    }
    
    private func tealiumTrack(title: String, data: [String: Any]? = nil) {
        let event = TealiumEvent(title, dataLayer: data)
        tealium?.track(event)
    }

}
