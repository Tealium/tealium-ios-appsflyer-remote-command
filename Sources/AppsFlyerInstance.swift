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
    func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void)
    func start()
    func initialize(appId: String, appDevKey: String, settings: [String: Any]?)
    func logEvent(_ eventName: String, values: [String: Any])
    func logLocation(longitude: Double, latitude: Double)
    func setHost(_ host: String, with prefix: String)
    func setUserEmails(emails: [String], with cryptType: EmailCryptType)
    func currencyCode(_ currency: String)
    func customerId(_ id: String)
    func disableTracking(_ disable: Bool)
    func anonymizeUser(_ anonymize: Bool)
    func resolveDeepLinkURLs(_ urls: [String])
    func setPhoneNumber(_ phoneNumber: String)
    func setPartnerData(partnerId: String, partnerInfo: [String: Any]?)
    func setSharingFilterForPartners(_ sharingFilter: [String]?)
    func logAdRevenue(_ adRevenueData: AFAdRevenueData, additionalParams: [String: Any]?)
    func setConsentData(_ consent: AppsFlyerConsent)
    func handleOpen(url: URL, sourceApplication: String?, annotation: Any?)
    func setCurrentDeviceLanguage(_ language: String)
    func setAppInviteOneLink(_ oneLinkId: String)
}

public class AppsFlyerInstance: NSObject, AppsFlyerCommand {

    weak var tealium: Tealium?
    private let _onReady = TealiumReplaySubject<AppsFlyerLib>(cacheSize: 1)
    private let logger: RemoteCommandLogger

    /// Sets no delegate, so attribution callbacks do not fire. Use `init(tealium:)` to track them.
    public override convenience init() {
        self.init(logger: RemoteCommandLogger())
    }

    /// Registers as the `AppsFlyerLibDelegate`, so attribution callbacks
    /// (`onConversionDataSuccess` and friends) are tracked through `tealium`.
    public init(tealium: Tealium) {
        self.logger = RemoteCommandLogger()
        super.init()
        self.tealium = tealium
        AppsFlyerLib.shared().delegate = self
    }

    /// Used by `AppsFlyerRemoteCommand` when no instance is supplied. Sets no delegate, so
    /// attribution callbacks do not fire on this path — a `RemoteCommand` has no access to the
    /// Tealium instance it belongs to, so it cannot track on its own.
    /// Pass `AppsFlyerInstance(tealium:)` to `AppsFlyerRemoteCommand.init(appsFlyerInstance:)`
    /// to enable attribution tracking.
    init(logger: RemoteCommandLogger) {
        self.logger = logger
        super.init()
    }

    public func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void) {
        defer { _onReady.subscribeOnce(onReady) }
        let appsFlyerAlreadyPublished = _onReady.last() != nil
        guard !appsFlyerAlreadyPublished else {
            return
        }
        let appsFlyer = AppsFlyerLib.shared()
        let appsFlyerManuallyInitialized = !appsFlyer.appsFlyerDevKey.isEmpty || !appsFlyer.appleAppID.isEmpty
        guard appsFlyerManuallyInitialized else {
            return
        }
        _onReady.publish(appsFlyer)
    }

    public func initialize(appId: String, appDevKey: String, settings: [String: Any]?) {
        TealiumQueues.secureMainThreadExecution {
            let appsFlyer = AppsFlyerLib.shared()
            // enableFacebookDeferredApplinks must be called before credentials are set and before start().
            if let enableFacebookDeferredApplinks = settings?[AppsFlyerConstants.Settings.enableFacebookDeferredApplinks] as? Bool {
                if enableFacebookDeferredApplinks {
                    if let facebookAppLinkUtilityClass = NSClassFromString("FBSDKAppLinkUtility") {
                        appsFlyer.enableFacebookDeferredApplinks(with: facebookAppLinkUtilityClass)
                    } else {
                        self.logger.error("Facebook Deferred AppLinks requested but Facebook SDK not found. Please ensure Facebook SDK is integrated in your app.")
                    }
                } else {
                    // Pass nil to disable — mirrors Android's enableFacebookDeferredApplinks(false).
                    appsFlyer.enableFacebookDeferredApplinks(with: nil)
                }
            }
            appsFlyer.appsFlyerDevKey = appDevKey
            appsFlyer.appleAppID = appId
            if let settings = settings {
                if let debug = settings[AppsFlyerConstants.Settings.debug] as? Bool {
                    appsFlyer.isDebug = debug
                }
                let disableAdTracking = (settings[AppsFlyerConstants.Settings.disableAdTracking]
                    ?? settings[AppsFlyerConstants.Settings.disableAdvertisingIdentifiersAlias]) as? Bool
                if let disableAdTracking = disableAdTracking {
                    appsFlyer.disableAdvertisingIdentifier = disableAdTracking
                    appsFlyer.disableIDFVCollection = disableAdTracking
                }
                if let disableAppleAdTracking = settings[AppsFlyerConstants.Settings.disableAppleAdTracking] as? Bool {
                    appsFlyer.disableSKAdNetwork = disableAppleAdTracking
                }
                // Guarded because `UInt(negative)` traps.
                if let minTimeBetweenSessions = settings[AppsFlyerConstants.Settings.minTimeBetweenSessions] as? Int,
                   minTimeBetweenSessions >= 0 {
                    appsFlyer.minTimeBetweenSessions = UInt(minTimeBetweenSessions)
                }
                if let anonymizeUser = settings[AppsFlyerConstants.Settings.anonymizeUser] as? Bool {
                    appsFlyer.anonymizeUser = anonymizeUser
                }
                if let shouldCollectDeviceName = settings[AppsFlyerConstants.Settings.collectDeviceName] as? Bool {
                    appsFlyer.shouldCollectDeviceName = shouldCollectDeviceName
                }
                if let customData = settings[AppsFlyerConstants.Settings.customData] as? [AnyHashable: Any] {
                    appsFlyer.customData = customData
                }
                if let disableAppleAdsAttribution = settings[AppsFlyerConstants.Settings.disableAppleAdsAttribution] as? Bool {
                    appsFlyer.disableAppleAdsAttribution = disableAppleAdsAttribution
                }
                if let enableTCFDataCollection = settings[AppsFlyerConstants.Settings.enableTCFDataCollection] as? Bool {
                    appsFlyer.enableTCFDataCollection(enableTCFDataCollection)
                }
                if let deepLinkTimeout = settings[AppsFlyerConstants.Settings.deepLinkTimeout] as? Int,
                   deepLinkTimeout >= 0 {
                    appsFlyer.deepLinkTimeout = UInt(deepLinkTimeout)
                }
                if let oneLinkCustomDomains = settings[AppsFlyerConstants.Settings.oneLinkCustomDomains] as? [String] {
                    appsFlyer.oneLinkCustomDomains = oneLinkCustomDomains
                }
                if let facebookDeferredAppLink = settings[AppsFlyerConstants.Settings.facebookDeferredAppLink] as? String,
                   let facebookDeferredAppLinkURL = URL(string: facebookDeferredAppLink) {
                    appsFlyer.facebookDeferredAppLink = facebookDeferredAppLinkURL
                }
                if let pushNotificationDeepLinkPath = settings[AppsFlyerConstants.Settings.pushNotificationDeepLinkPath] as? [String] {
                    appsFlyer.addPushNotificationDeepLinkPath(pushNotificationDeepLinkPath)
                }
                if let deepLinkParameters = settings[AppsFlyerConstants.Settings.deepLinkParameters] as? [[String: Any]] {
                    for parameter in deepLinkParameters {
                        if let contains = parameter[AppsFlyerConstants.Parameters.deepLinkContains] as? String,
                           let parameters = parameter[AppsFlyerConstants.Parameters.deepLinkParameters] as? [String: String] {
                            appsFlyer.appendParametersToDeeplinkURL(contains: contains, parameters: parameters)
                        }
                    }
                }
                if let waitForATTTimeoutInterval = settings[AppsFlyerConstants.Settings.waitForATTUserAuthorizationTimeoutInterval] as? Double {
                    if #available(iOS 14, *) {
                        appsFlyer.waitForATTUserAuthorization(timeoutInterval: waitForATTTimeoutInterval)
                    }
                }
                // Applied after disable_ad_tracking so it can override the IDFV portion independently.
                if let disableIDFVCollection = settings[AppsFlyerConstants.Settings.disableIDFVCollection] as? Bool {
                    appsFlyer.disableIDFVCollection = disableIDFVCollection
                }
            }
            // Start the first session. Subsequent sessions require calling start()
            // on each applicationDidBecomeActive — see public func start() below.
            // Published after start() so onReady implies a started session.
            appsFlyer.start()
            self._onReady.publish(appsFlyer)
        }
    }

    public func logEvent(_ eventName: String, values: [String: Any]) {
        onReady { appsFlyer in
            appsFlyer.logEvent(eventName, withValues: values)
        }
    }

    public func logLocation(longitude: Double, latitude: Double) {
        onReady { appsFlyer in
            appsFlyer.logLocation(longitude: longitude, latitude: latitude)
        }
    }

    public func setHost(_ host: String, with prefix: String) {
        AppsFlyerLib.shared().setHost(host, withHostPrefix: prefix)
    }

    public func setUserEmails(emails: [String], with cryptType: EmailCryptType) {
        AppsFlyerLib.shared().setUserEmails(emails, with: cryptType)
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

    public func anonymizeUser(_ anonymize: Bool) {
        AppsFlyerLib.shared().anonymizeUser = anonymize
    }

    public func resolveDeepLinkURLs(_ urls: [String]) {
        AppsFlyerLib.shared().resolveDeepLinkURLs = urls
    }

    public func setPhoneNumber(_ phoneNumber: String) {
        AppsFlyerLib.shared().phoneNumber = phoneNumber
    }
    
    public func logAdRevenue(_ adRevenueData: AFAdRevenueData, additionalParams: [String: Any]?) {
        onReady { appsFlyer in
            appsFlyer.logAdRevenue(adRevenueData, additionalParameters: additionalParams)
        }
    }
    
    public func setConsentData(_ consent: AppsFlyerConsent) {
        AppsFlyerLib.shared().setConsentData(consent)
    }
    

    public func setPartnerData(partnerId: String, partnerInfo: [String: Any]?) {
        AppsFlyerLib.shared().setPartnerData(partnerId: partnerId, partnerInfo: partnerInfo)
    }
    
    public func setSharingFilterForPartners(_ sharingFilter: [String]?) {
        AppsFlyerLib.shared().setSharingFilterForPartners(sharingFilter)
    }

    /// Starts (or re-starts) an AppsFlyer session. Call this on every
    /// `applicationDidBecomeActive` to ensure each foreground visit logs
    /// an `af_app_opened` event. In a JSON Remote Command setup, send a
    /// Tealium event mapped to the `"start"` command (e.g. `"wake"`).
    public func start() {
        TealiumQueues.secureMainThreadExecution {
            AppsFlyerLib.shared().start()
        }
    }

    /// Gated on `onReady` because the SDK discards deep links received before `start()`,
    /// which is what happens on a cold start without the gate.
    public func handleOpen(url: URL, sourceApplication: String?, annotation: Any?) {
        onReady { appsFlyer in
            TealiumQueues.secureMainThreadExecution {
                appsFlyer.handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
            }
        }
    }

    public func setCurrentDeviceLanguage(_ language: String) {
        AppsFlyerLib.shared().currentDeviceLanguage = language
    }

    public func setAppInviteOneLink(_ oneLinkId: String) {
        AppsFlyerLib.shared().appInviteOneLinkID = oneLinkId
    }

    func tealiumTrack(title: String, data: [String: Any]? = nil) {
        let event = TealiumEvent(title, dataLayer: data)
        tealium?.track(event)
    }
}

extension AppsFlyerInstance: AppsFlyerLibDelegate {

    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        guard let conversionInfo = conversionInfo as? [String: Any],
              let firstLaunch = conversionInfo[AppsFlyerConstants.Attribution.firstLaunch] as? Bool else {
            return
        }

        guard firstLaunch else {
            logger.debug("\(AppsFlyerConstants.attributionLog)Not First Launch")
            return
        }
        tealiumTrack(title: AppsFlyerConstants.Attribution.conversionReceived, data: conversionInfo)

        guard let status = conversionInfo[AppsFlyerConstants.Attribution.status] as? String else {
            return
        }

        if (status == "Non-organic") {
            if let mediaSource = conversionInfo[AppsFlyerConstants.Attribution.source],
               let campaign = conversionInfo[AppsFlyerConstants.Attribution.campaign] {
                logger.info("\(AppsFlyerConstants.attributionLog)This is a Non-Organic install. Media source: \(mediaSource) Campaign: \(campaign)")
            }
        } else {
            logger.info("\(AppsFlyerConstants.attributionLog)This is an organic install.")
        }
    }

    public func onConversionDataFail(_ error: Error) {
        tealiumTrack(
            title: AppsFlyerConstants.Attribution.error,
            data: [
                AppsFlyerConstants.Attribution.errorName: AppsFlyerConstants.Attribution.conversionFailure,
                AppsFlyerConstants.Attribution.errorDescription: error.localizedDescription
            ]
        )
    }

    public func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        guard let attributionData = attributionData as? [String: Any] else {
            return tealiumTrack(title: AppsFlyerConstants.Attribution.appOpen)
        }
        tealiumTrack(
            title: AppsFlyerConstants.Attribution.appOpen,
            data: attributionData
        )
    }

    public func onAppOpenAttributionFailure(_ error: Error) {
        tealiumTrack(
            title: AppsFlyerConstants.Attribution.error,
            data: [
                AppsFlyerConstants.Attribution.errorName: AppsFlyerConstants.Attribution.appOpenFailure,
                AppsFlyerConstants.Attribution.errorDescription: error.localizedDescription
            ]
        )
    }
}
