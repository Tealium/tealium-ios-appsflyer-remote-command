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
    func stopTracking(_ stop: Bool)
    func anonymizeUser(_ anonymize: Bool)
    func resolveDeepLinkURLs(_ urls: [String])
    func logAdRevenue(monetizationNetwork: String, mediationNetwork: String, revenue: Double, currency: String, additionalParameters: [String: Any]?)
    func setDMAConsent(gdprApplies: Bool?, consentForDataUsage: Bool?, consentForAdsPersonalization: Bool?, consentForAdStorage: Bool?)
    func setPhoneNumber(_ phoneNumber: String)
    func addPushNotificationDeepLinkPath(_ paths: [String])
    func validateAndLogPurchase(purchaseType: String?, transactionId: String?, productId: String?, price: String?, currency: String?, additionalParameters: [String: Any]?)
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
        
        guard let settings = settings else {
            return
        }
        
        if let debug = settings[AppsFlyerConstants.Configuration.debug] as? Bool {
            appsFlyer.isDebug = debug
        }
        // TODO: Remove, splited into disableAdvertisingIdentifier and disableIDFVCollection
        if let disableAdTracking = settings[AppsFlyerConstants.Configuration.disableAdTracking] as? Bool {
            appsFlyer.disableAdvertisingIdentifier = disableAdTracking
            appsFlyer.disableIDFVCollection = disableAdTracking
        }
        // TODO: Should be renamed to disableSKAdNetwork
        if let disableAppleAdTracking = settings[AppsFlyerConstants.Configuration.disableAppleAdTracking] as? Bool {
            appsFlyer.disableSKAdNetwork = disableAppleAdTracking
        }
        if let disableAppleAdsAttribution = settings[AppsFlyerConstants.Configuration.disableAppleAdsAttribution] as? Bool {
            appsFlyer.disableAppleAdsAttribution = disableAppleAdsAttribution
        }
        if let disableCollectASA = settings[AppsFlyerConstants.Configuration.disableCollectASA] as? Bool {
            appsFlyer.disableCollectASA = disableCollectASA
        }
        if let minTimeBetweenSessions = settings[AppsFlyerConstants.Configuration.minTimeBetweenSessions] as? Int {
            appsFlyer.minTimeBetweenSessions = UInt(minTimeBetweenSessions)
        }
        if let anonymizeUser = settings[AppsFlyerConstants.Configuration.anonymizeUser] as? Bool {
            appsFlyer.anonymizeUser = anonymizeUser
        }
        if let shouldCollectDeviceName = settings[AppsFlyerConstants.Configuration.collectDeviceName] as? Bool {
            appsFlyer.shouldCollectDeviceName = shouldCollectDeviceName
        }
        if let customData = settings[AppsFlyerConstants.Configuration.customData] as? [AnyHashable: Any] {
            appsFlyer.customData = customData
        }
        if let useUninstallSandbox = settings[AppsFlyerConstants.Configuration.useUninstallSandbox] as? Bool {
            appsFlyer.useUninstallSandbox = useUninstallSandbox
        }
        if let enableTCFDataCollection = settings[AppsFlyerConstants.Configuration.enableTCFDataCollection] as? Bool {
            appsFlyer.enableTCFDataCollection(enableTCFDataCollection)
        }
        if let appInviteOneLinkID = settings[AppsFlyerConstants.Configuration.appInviteOneLinkID] as? String {
            appsFlyer.appInviteOneLinkID = appInviteOneLinkID
        }
        if let deepLinkTimeout = settings[AppsFlyerConstants.Configuration.deepLinkTimeout] as? Int {
            appsFlyer.deepLinkTimeout = UInt(deepLinkTimeout)
        }
        if let oneLinkCustomDomains = settings[AppsFlyerConstants.Configuration.oneLinkCustomDomains] as? [String] {
            appsFlyer.oneLinkCustomDomains = oneLinkCustomDomains
        }
        if let useReceiptValidationSandbox = settings[AppsFlyerConstants.Configuration.useReceiptValidationSandbox] as? Bool {
            appsFlyer.useReceiptValidationSandbox = useReceiptValidationSandbox
        }
        // Wait for ATT authorization if configured (iOS 14+ only)
        if let attTimeout = settings[AppsFlyerConstants.Configuration.waitForATTUserAuthorizationTimeoutInterval] as? Int {
            if #available(iOS 14, *) {
                appsFlyer.waitForATTUserAuthorization(timeoutInterval: TimeInterval(attTimeout))
            }
        }
        if let resolveDeepLinks = settings[AppsFlyerConstants.Configuration.resolveDeepLinks] as? [String] {
            appsFlyer.resolveDeepLinkURLs = resolveDeepLinks
        }
        if let stopTracking = settings[AppsFlyerConstants.Configuration.stopTracking] as? Bool {
            appsFlyer.isStopped = stopTracking
        }
        if let customerEmails = settings[AppsFlyerConstants.Configuration.customerEmails] as? [String],
           let emailHashType = settings[AppsFlyerConstants.Configuration.emailHashType] as? Int {
            let emailCryptType = AppsFlyerConstants.EmailHashType.appsFlyerTypeFromInt(emailHashType)
            appsFlyer.setUserEmails(customerEmails, with: emailCryptType)
        }
        if let host = settings[AppsFlyerConstants.Configuration.host] as? String,
           let hostPrefix = settings[AppsFlyerConstants.Configuration.hostPrefix] as? String {
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
        AppsFlyerLib.shared().setHost(host, withHostPrefix: prefix)
    }

    public func setUserEmails(emails: [String], with cryptType: Int) {
        let emailCryptType = AppsFlyerConstants.EmailHashType.appsFlyerTypeFromInt(cryptType)
        AppsFlyerLib.shared().setUserEmails(emails, with: emailCryptType)
    }

    public func currencyCode(_ currency: String) {
        AppsFlyerLib.shared().currencyCode = currency
    }

    public func customerId(_ id: String) {
        AppsFlyerLib.shared().customerUserID = id
    }

    public func stopTracking(_ stop: Bool) {
        AppsFlyerLib.shared().isStopped = stop
    }

    public func anonymizeUser(_ anonymize: Bool) {
        AppsFlyerLib.shared().anonymizeUser = anonymize
    }

    // TiQ: resolve_deep_links
    public func resolveDeepLinkURLs(_ urls: [String]) {
        AppsFlyerLib.shared().resolveDeepLinkURLs = urls
    }

    public func logAdRevenue(monetizationNetwork: String, mediationNetwork: String, revenue: Double, currency: String, additionalParameters: [String: Any]?) {

        onReady { appsFlyer in
            // Use our enum's conversion method
            let mediationNetworkType = AppsFlyerConstants.MediationNetwork.appsFlyerTypeFromString(mediationNetwork)
            
            let adRevenueData = AFAdRevenueData(
                monetizationNetwork: monetizationNetwork,
                mediationNetwork: mediationNetworkType,
                currencyIso4217Code: currency,
                eventRevenue: NSNumber(value: revenue)
            )
            
            appsFlyer.logAdRevenue(adRevenueData, additionalParameters: additionalParameters)
        }
    }

    public func setDMAConsent(gdprApplies: Bool?, consentForDataUsage: Bool?, consentForAdsPersonalization: Bool?, consentForAdStorage: Bool?) {
        guard let gdprApplies = gdprApplies else { return }
        
        if gdprApplies {
            // User is subject to GDPR
            let consent = AppsFlyerConsent(
                isUserSubjectToGDPR: true,
                hasConsentForDataUsage: consentForDataUsage.map { NSNumber(value: $0) },
                hasConsentForAdsPersonalization: consentForAdsPersonalization.map { NSNumber(value: $0) },
                hasConsentForAdStorage: consentForAdStorage.map { NSNumber(value: $0) }
            )
            AppsFlyerLib.shared().setConsentData(consent)
        } else {
            // User is not subject to GDPR - other parameters must be null
            let consent = AppsFlyerConsent(
                isUserSubjectToGDPR: false,
                hasConsentForDataUsage: nil,
                hasConsentForAdsPersonalization: nil,
                hasConsentForAdStorage: nil
            )
            AppsFlyerLib.shared().setConsentData(consent)
        }
    }

    public func setPhoneNumber(_ phoneNumber: String) {
        AppsFlyerLib.shared().phoneNumber = phoneNumber
    }

    public func addPushNotificationDeepLinkPath(_ paths: [String]) {
        AppsFlyerLib.shared().addPushNotificationDeepLinkPath(paths)
    }

    public func validateAndLogPurchase(purchaseType: String?, transactionId: String?, productId: String?, price: String?, currency: String?, additionalParameters: [String: Any]?) {
        guard let productId = productId,
              let price = price,
              let currency = currency,
              let transactionId = transactionId
              else {
            return
        }
        
        onReady { appsFlyer in
            let purchaseDetails = AFSDKPurchaseDetails(
                productId: productId,
                price: price,
                currency: currency,
                transactionId: transactionId
            )
            
            // Note: purchaseType is not part of official iOS SDK AFSDKPurchaseDetails
            // but can be added as additional parameter for consistency with Android
            var extraEventValues: [String: Any] = [:]
            if let type = purchaseType {
                extraEventValues["purchase_type"] = type
            }
            if let additional = additionalParameters {
                extraEventValues.merge(additional) { (_, new) in new }
            }
            
            appsFlyer.validateAndLog(
                inAppPurchase: purchaseDetails,
                extraEventValues: extraEventValues.isEmpty ? nil : extraEventValues
            ) { result in
                if let result = result {
                    print("Purchase validation result: \(result)")
                } else {
                    print("Purchase validation completed")
                }
            }
        }
    }

    public func setSharingFilterForPartners(_ partners: [String]?) {
        AppsFlyerLib.shared().setSharingFilterForPartners(partners)
    }

    public func appendCustomData(_ data: [String: Any]) {
        var customData = AppsFlyerLib.shared().customData ?? [:]
        customData.merge(data) { (_, new) in new }
        AppsFlyerLib.shared().customData = customData
    }

    public func setCurrentDeviceLanguage(_ language: String) {
        AppsFlyerLib.shared().currentDeviceLanguage = language
    }

    public func setPartnerData(partnerId: String, partnerInfo: [String: Any]) {
        AppsFlyerLib.shared().setPartnerData(partnerId: partnerId, partnerInfo: partnerInfo)
    }

    public func appendParametersToDeeplinkURL(contains: String, parameters: [String: String]) {
        AppsFlyerLib.shared().appendParametersToDeeplinkURL(contains: contains, parameters: parameters)
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
