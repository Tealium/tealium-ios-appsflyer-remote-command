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
    func initialize(appId: String, appDevKey: String, settings: [String: Any]?)
    func logEvent(_ eventName: String, values: [String: Any])
    func logLocation(longitude: Double, latitude: Double)
    func setHost(_ host: String, with prefix: String)
    func setUserEmails(emails: [String], with cryptType: Int)
    func currencyCode(_ currency: String)
    func customerId(_ id: String)
    func disableTracking(_ disable: Bool)
    func resolveDeepLinkURLs(_ urls: [String])
    func setPhoneNumber(_ phoneNumber: String)
}

public class AppsFlyerInstance: NSObject, AppsFlyerCommand {

    weak var tealium: Tealium?
    private let _onReady = TealiumReplaySubject<AppsFlyerLib>(cacheSize: 1)
    public override init() {
        super.init()
        AppsFlyerLib.shared().delegate = self
    }

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
        let appsFlyer = AppsFlyerLib.shared()
        defer {
            self._onReady.publish(appsFlyer)
        }
        appsFlyer.appsFlyerDevKey = appDevKey
        appsFlyer.appleAppID = appId
        guard let settings = settings else {
            return
        }
        if let debug = settings[AppsFlyerConstants.Settings.debug] as? Bool {
            appsFlyer.isDebug = debug
        }
        // DEPRECATED: disables both IDFA and IDFV collection. Use disable_advertising_identifier and disable_idfv_collection instead. Will be removed in a future release.
        if let disableAdTracking = settings[AppsFlyerConstants.Settings.disableAdTracking] as? Bool {
            appsFlyer.disableAdvertisingIdentifier = disableAdTracking
            appsFlyer.disableIDFVCollection = disableAdTracking 
        }
        if let disableAdvertisingIdentifier = settings[AppsFlyerConstants.Settings.disableAdvertisingIdentifier] as? Bool {
            appsFlyer.disableAdvertisingIdentifier = disableAdvertisingIdentifier
        }
        if let disableIDFVCollection = settings[AppsFlyerConstants.Settings.disableIDFVCollection] as? Bool {
            appsFlyer.disableIDFVCollection = disableIDFVCollection
        }
        // DEPRECATED: disables SKAdNetwork attribution. Use disable_skadnetwork instead. Will be removed in a future release.
        if let disableAppleAdTracking = settings[AppsFlyerConstants.Settings.disableAppleAdTracking] as? Bool {
            appsFlyer.disableSKAdNetwork = disableAppleAdTracking
        }
        if let disableSKAdNetwork = settings[AppsFlyerConstants.Settings.disableSKAdNetwork] as? Bool {
            appsFlyer.disableSKAdNetwork = disableSKAdNetwork
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
        if let resolveDeepLinkURLs = settings[AppsFlyerConstants.Settings.resolveDeepLinkURLs] as? [String] {
            appsFlyer.resolveDeepLinkURLs = resolveDeepLinkURLs
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

    public func resolveDeepLinkURLs(_ urls: [String]) {
        AppsFlyerLib.shared().resolveDeepLinkURLs = urls
    }

    public func setPhoneNumber(_ phoneNumber: String) {
        AppsFlyerLib.shared().phoneNumber = phoneNumber
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
    
    private func tealiumTrack(title: String, data: [String: Any]? = nil) {
        let event = TealiumEvent(title, dataLayer: data)
        tealium?.track(event)
    }
}
