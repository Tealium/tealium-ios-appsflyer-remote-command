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
    func setUserEmails(emails: [String], with cryptType: Int)
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
    func handleOpen(url: URL, options: [UIApplication.OpenURLOptionsKey: Any])
    func setCurrentDeviceLanguage(_ language: String)
}

public class AppsFlyerInstance: NSObject, AppsFlyerCommand {

    weak var tealium: Tealium?
    private let _onReady = TealiumReplaySubject<AppsFlyerLib>(cacheSize: 1)
    public override init() { }

    public init(tealium: Tealium) {
        super.init()
        self.tealium = tealium
        AppsFlyerLib.shared().delegate = self
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
        DispatchQueue.main.async {
            let appsFlyer = AppsFlyerLib.shared()
            // enableFacebookDeferredApplinks must be called before credentials are set and before start().
            if let enableFacebookDeferredApplinks = settings?[AppsFlyerConstants.Settings.enableFacebookDeferredApplinks] as? Bool {
                if enableFacebookDeferredApplinks {
                    if let facebookAppLinkUtilityClass = NSClassFromString("FBSDKAppLinkUtility") {
                        appsFlyer.enableFacebookDeferredApplinks(with: facebookAppLinkUtilityClass)
                    } else {
                        RemoteCommandLogger.error("Facebook Deferred AppLinks requested but Facebook SDK not found. Please ensure Facebook SDK is integrated in your app.")
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
                if let minTimeBetweenSessions = settings[AppsFlyerConstants.Settings.minTimeBetweenSessions] as? Int {
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
                if let appInviteOneLinkID = settings[AppsFlyerConstants.Settings.appInviteOneLinkID] as? String {
                    appsFlyer.appInviteOneLinkID = appInviteOneLinkID
                }
                if let deepLinkTimeout = settings[AppsFlyerConstants.Settings.deepLinkTimeout] as? Int {
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
            self._onReady.publish(appsFlyer)
            appsFlyer.start()
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

    public func setUserEmails(emails: [String], with cryptType: Int) {
        let resolvedType = EmailCryptType(rawInt: cryptType) ?? EmailCryptTypeNone
        AppsFlyerLib.shared().setUserEmails(emails, with: resolvedType)
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

    public func start() {
        AppsFlyerLib.shared().start()
    }

    public func handleOpen(url: URL, sourceApplication: String?, annotation: Any?) {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
    }

    public func handleOpen(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {
        AppsFlyerLib.shared().handleOpen(url, options: options)
    }

    public func setCurrentDeviceLanguage(_ language: String) {
        AppsFlyerLib.shared().currentDeviceLanguage = language
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
            RemoteCommandLogger.debug("\(AppsFlyerConstants.attributionLog)Not First Launch")
            return
        }
        tealiumTrack(title: AppsFlyerConstants.Attribution.conversionReceived, data: conversionInfo)

        guard let status = conversionInfo[AppsFlyerConstants.Attribution.status] as? String else {
            return
        }

        if (status == "Non-organic") {
            if let mediaSource = conversionInfo[AppsFlyerConstants.Attribution.source],
               let campaign = conversionInfo[AppsFlyerConstants.Attribution.campaign] {
                RemoteCommandLogger.info("\(AppsFlyerConstants.attributionLog)This is a Non-Organic install. Media source: \(mediaSource) Campaign: \(campaign)")
            }
        } else {
            RemoteCommandLogger.info("\(AppsFlyerConstants.attributionLog)This is an organic install.")
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
