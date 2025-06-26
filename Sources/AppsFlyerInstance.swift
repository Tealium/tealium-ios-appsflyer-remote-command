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
    func setUserEmails(emails: [String], with cryptType: EmailCryptType)
    func currencyCode(_ currency: String)
    func customerId(_ id: String)
    func disableTracking(_ disable: Bool)
    func resolveDeepLinkURLs(_ urls: [String])
    func anonymizeUser(_ anonymize: Bool)
    func logAdRevenue(monetizationNetwork: String, mediationNetwork: MediationNetworkType, revenue: Double, currency: String, additionalParameters: [String: Any]?)
    func setDMAConsent(gdprApplies: Bool, consentForDataUsage: Bool?, consentForAdsPersonalization: Bool?, consentForAdStorage: Bool?)
    func setPhoneNumber(_ phoneNumber: String)
    func addPushNotificationDeepLinkPath(_ paths: [String])
    func validateAndLogPurchase(productId: String, price: String, currency: String, transactionId: String, additionalParameters: [String: Any]?)
    func setSharingFilterForPartners(_ partners: [String]?)
    func appendCustomData(_ data: [String: Any])
    func setCurrentDeviceLanguage(_ language: String)
    func setPartnerData(partnerId: String, partnerInfo: [String: Any])
    func appendParametersToDeeplinkURL(contains: String, parameters: [String: String])
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
        let appsFlyer = AppsFlyerLib.shared()
        defer {
            self._onReady.publish(appsFlyer)
        }
        appsFlyer.appsFlyerDevKey = appDevKey
        appsFlyer.appleAppID = appId
        
        guard let settings else {
            return
        }
        
        if let debug = settings[AppsFlyerConstants.Configuration.debug.rawValue] as? Bool {
            appsFlyer.isDebug = debug
        }
        if let disableAdTracking = settings[AppsFlyerConstants.Configuration.disableAdTracking.rawValue] as? Bool {
            appsFlyer.disableAdvertisingIdentifier = disableAdTracking
            appsFlyer.disableIDFVCollection = disableAdTracking
        }
        if let disableAppleAdTracking = settings[AppsFlyerConstants.Configuration.disableAppleAdTracking.rawValue] as? Bool {
            appsFlyer.disableSKAdNetwork = disableAppleAdTracking
        }
        if let disableAppleAdsAttribution = settings[AppsFlyerConstants.Configuration.disableAppleAdsAttribution.rawValue] as? Bool {
            appsFlyer.disableAppleAdsAttribution = disableAppleAdsAttribution
        }
        if let minTimeBetweenSessions = settings[AppsFlyerConstants.Configuration.minTimeBetweenSessions.rawValue] as? Int {
            appsFlyer.minTimeBetweenSessions = UInt(minTimeBetweenSessions)
        }
        if let anonymizeUser = settings[AppsFlyerConstants.Configuration.anonymizeUser.rawValue] as? Bool {
            appsFlyer.anonymizeUser = anonymizeUser
        }
        if let shouldCollectDeviceName = settings[AppsFlyerConstants.Configuration.collectDeviceName.rawValue] as? Bool {
            appsFlyer.shouldCollectDeviceName = shouldCollectDeviceName
        }
        if let customData = settings[AppsFlyerConstants.Configuration.customData.rawValue] as? [AnyHashable: Any] {
            appsFlyer.customData = customData
        }
        if let useUninstallSandbox = settings[AppsFlyerConstants.Configuration.useUninstallSandbox.rawValue] as? Bool {
            appsFlyer.useUninstallSandbox = useUninstallSandbox
        }
        if let enableTCFDataCollection = settings[AppsFlyerConstants.Configuration.enableTCFDataCollection.rawValue] as? Bool {
            appsFlyer.enableTCFDataCollection(enableTCFDataCollection)
        }
        if let appInviteOneLinkID = settings[AppsFlyerConstants.Configuration.appInviteOneLinkID.rawValue] as? String {
            appsFlyer.appInviteOneLinkID = appInviteOneLinkID
        }
        if let deepLinkTimeout = settings[AppsFlyerConstants.Configuration.deepLinkTimeout.rawValue] as? Int, deepLinkTimeout > 0 {
            appsFlyer.deepLinkTimeout = UInt(deepLinkTimeout)
        }
        if let oneLinkCustomDomains = settings[AppsFlyerConstants.Configuration.oneLinkCustomDomains.rawValue] as? [String] {
            appsFlyer.oneLinkCustomDomains = oneLinkCustomDomains
        }
        if let useReceiptValidationSandbox = settings[AppsFlyerConstants.Configuration.useReceiptValidationSandbox.rawValue] as? Bool {
            appsFlyer.useReceiptValidationSandbox = useReceiptValidationSandbox
        }
        // Wait for ATT authorization if configured (iOS 14+ only)
        if let attTimeout = settings[AppsFlyerConstants.Configuration.waitForATTUserAuthorizationTimeoutInterval.rawValue] as? Double {
            if #available(iOS 14, *) {
                appsFlyer.waitForATTUserAuthorization(timeoutInterval: attTimeout)
            }
        }
        if let resolveDeepLinks = settings[AppsFlyerConstants.Configuration.resolveDeepLinks.rawValue] as? [String] {
            appsFlyer.resolveDeepLinkURLs = resolveDeepLinks
        }
        if let stopTracking = settings[AppsFlyerConstants.Configuration.stopTracking.rawValue] as? Bool {
            appsFlyer.isStopped = stopTracking
        }
        if let host = settings[AppsFlyerConstants.Configuration.host.rawValue] as? String,
           let hostPrefix = settings[AppsFlyerConstants.Configuration.hostPrefix.rawValue] as? String {
            appsFlyer.setHost(host, withHostPrefix: hostPrefix)
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
        onReady { appsFlyer in
            appsFlyer.setHost(host, withHostPrefix: prefix)
        }
    }

    public func setUserEmails(emails: [String], with cryptType: EmailCryptType) {
        onReady { appsFlyer in
            appsFlyer.setUserEmails(emails, with: cryptType)
        }
    }

    public func currencyCode(_ currency: String) {
        onReady { appsFlyer in
            appsFlyer.currencyCode = currency
        }
    }

    public func customerId(_ id: String) {
        onReady { appsFlyer in
            appsFlyer.customerUserID = id
        }
    }

    public func disableTracking(_ disable: Bool) {
        onReady { appsFlyer in
            appsFlyer.isStopped = disable
        }
    }

    public func anonymizeUser(_ anonymize: Bool) {
        onReady { appsFlyer in
            appsFlyer.anonymizeUser = anonymize
        }
    }

    public func resolveDeepLinkURLs(_ urls: [String]) {
        onReady { appsFlyer in
            appsFlyer.resolveDeepLinkURLs = urls
        }
    }

    public func logAdRevenue(monetizationNetwork: String, mediationNetwork: MediationNetworkType, revenue: Double, currency: String, additionalParameters: [String: Any]?) {
        onReady { appsFlyer in
            let adRevenueData = AFAdRevenueData(
                monetizationNetwork: monetizationNetwork,
                mediationNetwork: mediationNetwork,
                currencyIso4217Code: currency,
                eventRevenue: NSNumber(value: revenue)
            )
            
            appsFlyer.logAdRevenue(adRevenueData, additionalParameters: additionalParameters)
        }
    }

    public func setDMAConsent(gdprApplies: Bool, consentForDataUsage: Bool?, consentForAdsPersonalization: Bool?, consentForAdStorage: Bool?) {
        onReady { appsFlyer in
            if gdprApplies {
                // User is subject to GDPR
                let consent = AppsFlyerConsent(
                    isUserSubjectToGDPR: true,
                    hasConsentForDataUsage: consentForDataUsage.map { NSNumber(value: $0) },
                    hasConsentForAdsPersonalization: consentForAdsPersonalization.map { NSNumber(value: $0) },
                    hasConsentForAdStorage: consentForAdStorage.map { NSNumber(value: $0) }
                )
                appsFlyer.setConsentData(consent)
            } else {
                // User is not subject to GDPR - other parameters must be null
                let consent = AppsFlyerConsent(
                    isUserSubjectToGDPR: false,
                    hasConsentForDataUsage: nil,
                    hasConsentForAdsPersonalization: nil,
                    hasConsentForAdStorage: nil
                )
                appsFlyer.setConsentData(consent)
            }
        }
    }

    public func setPhoneNumber(_ phoneNumber: String) {
        onReady { appsFlyer in
            appsFlyer.phoneNumber = phoneNumber
        }
    }

    public func addPushNotificationDeepLinkPath(_ paths: [String]) {
        onReady { appsFlyer in
            appsFlyer.addPushNotificationDeepLinkPath(paths)
        }
    }

    public func validateAndLogPurchase(productId: String, price: String, currency: String, transactionId: String, additionalParameters: [String: Any]?) {
        onReady { appsFlyer in
            let purchaseDetails = AFSDKPurchaseDetails(
                productId: productId,
                price: price,
                currency: currency,
                transactionId: transactionId
            )
            
            appsFlyer.validateAndLog(
                inAppPurchase: purchaseDetails,
                extraEventValues: additionalParameters
            ) { result in
                guard let result = result else {
                    print("Purchase validation: No result received")
                    return
                }
                
                switch result.status {
                case .success:
                    print("Purchase validation: SUCCESS - Purchase validated and logged")
                case .failure:  
                    print("Purchase validation: FAILURE - Purchase was not validated")
                case .error:
                    if let error = result.error {
                        print("Purchase validation: ERROR - \(error.localizedDescription)")
                    } else {
                        print("Purchase validation: ERROR - Unknown error occurred")
                    }
                @unknown default:
                    print("Purchase validation: Unknown status - \(result)")
                }
            }
        }
    }

    public func setSharingFilterForPartners(_ partners: [String]?) {
        onReady { appsFlyer in
            appsFlyer.setSharingFilterForPartners(partners)
        }
    }

    public func appendCustomData(_ data: [String: Any]) {
        onReady { appsFlyer in
            var customData = appsFlyer.customData ?? [:]
            customData.merge(data) { (_, new) in new }
            appsFlyer.customData = customData
        }
    }

    public func setCurrentDeviceLanguage(_ language: String) {
        onReady { appsFlyer in
            appsFlyer.currentDeviceLanguage = language
        }
    }

    public func setPartnerData(partnerId: String, partnerInfo: [String: Any]) {
        onReady { appsFlyer in
            appsFlyer.setPartnerData(partnerId: partnerId, partnerInfo: partnerInfo)
        }
    }

    public func appendParametersToDeeplinkURL(contains: String, parameters: [String: String]) {
        onReady { appsFlyer in
            appsFlyer.appendParametersToDeeplinkURL(contains: contains, parameters: parameters)
        }
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
