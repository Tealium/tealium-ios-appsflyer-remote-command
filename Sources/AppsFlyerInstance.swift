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
    func stopTracking(_ stop: Bool)
    func anonymizeUser(_ anonymize: Bool)
    func resolveDeepLinkURLs(_ urls: [String])
    func logAdRevenue(monetizationNetwork: String?, mediationNetwork: String?, revenue: Double?, currency: String?, additionalParameters: [String: Any]?)
    func setDMAConsent(gdprApplies: Bool?, consentForDataUsage: Bool?, consentForAdsPersonalization: Bool?, consentForAdStorage: Bool?)
    func enableAppsetId(_ enable: Bool)
    func setDisableNetworkData(_ disable: Bool)
    func setPhoneNumber(_ phoneNumber: String)
    func setOutOfStore(_ source: String)
    func addPushNotificationDeepLinkPath(_ paths: [String])
    func sendPushNotificationData(_ data: [String: Any])
    func validateAndLogPurchase(purchaseType: String?, token: String?, productId: String?, price: String?, currency: String?, additionalParameters: [String: Any]?)
    func logSession()
    func waitForCustomerUserId(_ wait: Bool)
    func setCustomerIdAndLogSession(_ customerId: String)
    func setMinTimeBetweenSessions(_ seconds: Int)
    func setAppId(_ appId: String)
    func setDisableAdvertisingIdentifiers(_ disable: Bool)
    func enableTcfDataCollection(_ enable: Bool)
    func setSharingFilterForPartners(_ partners: [String]?)
    func updateServerUninstallToken(_ token: String)
    func setIsUpdate(_ isUpdate: Bool)
    func setAdditionalData(_ data: [String: Any])
    func registerUninstall(deviceToken: Data?)
    func setUseUninstallSandbox(_ sandbox: Bool)
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
        
        // Handle flat configuration structure (like Android)
        if let debug = settings[AppsFlyerConstants.Configuration.debug] as? Bool {
            appsFlyer.isDebug = debug
        }
        if let disableAdTracking = settings[AppsFlyerConstants.Configuration.disableAdTracking] as? Bool {
            appsFlyer.disableAdvertisingIdentifier = disableAdTracking
            appsFlyer.disableIDFVCollection = disableAdTracking
        }
        if let disableAppleAdTracking = settings[AppsFlyerConstants.Configuration.disableAppleAdTracking] as? Bool {
            appsFlyer.disableSKAdNetwork = disableAppleAdTracking
        }
        if let disableNetworkData = settings[AppsFlyerConstants.Configuration.disableNetworkData] as? Bool {
            appsFlyer.disableCollectASA = disableNetworkData
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

    public func stopTracking(_ stop: Bool) {
        AppsFlyerLib.shared().isStopped = stop
    }

    public func anonymizeUser(_ anonymize: Bool) {
        AppsFlyerLib.shared().anonymizeUser = anonymize
    }

    public func resolveDeepLinkURLs(_ urls: [String]) {
        AppsFlyerLib.shared().resolveDeepLinkURLs = urls
    }

    public func logAdRevenue(monetizationNetwork: String?, mediationNetwork: String?, revenue: Double?, currency: String?, additionalParameters: [String: Any]?) {
        guard let monetizationNetwork = monetizationNetwork,
              let mediationNetworkString = mediationNetwork,
              let revenue = revenue,
              let currency = currency else {
            return
        }
        
        // Convert our string to MediationNetworkType enum, then to official iOS type
        guard let mediationNetworkType = AppsFlyerConstants.MediationNetworkType.fromString(mediationNetworkString) else {
            print("AppsFlyerInstance: Unknown mediation network type: \(mediationNetworkString)")
            return
        }
        
        let appsFlyerMediationNetworkType = mediationNetworkType.toAppsFlyerMediationNetworkType()
        
        onReady { appsFlyer in
            // Use the official iOS SDK AFAdRevenueData object (SDK v6.15.0+)
            let adRevenueData = AFAdRevenueData(
                monetizationNetwork: monetizationNetwork,
                mediationNetwork: appsFlyerMediationNetworkType,
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

    public func enableAppsetId(_ enable: Bool) {
        // iOS equivalent - there's no direct AppSet ID in iOS, but we can set a flag
        if #available(iOS 14.0, *) {
            // iOS 14+ has different advertising tracking permissions
            // This would be handled differently in iOS
        }
    }

    public func setDisableNetworkData(_ disable: Bool) {
        AppsFlyerLib.shared().disableCollectASA = disable
    }

    public func setPhoneNumber(_ phoneNumber: String) {
        AppsFlyerLib.shared().phoneNumber = phoneNumber
    }

    public func setOutOfStore(_ source: String) {
        // iOS doesn't have direct out-of-store equivalent, set as custom data
        var customData = AppsFlyerLib.shared().customData ?? [:]
        customData["out_of_store_source"] = source
        AppsFlyerLib.shared().customData = customData
    }

    public func addPushNotificationDeepLinkPath(_ paths: [String]) {
        AppsFlyerLib.shared().addPushNotificationDeepLinkPath(paths)
    }

    public func sendPushNotificationData(_ data: [String: Any]) {
        // Store push notification data for later use
        AppsFlyerLib.shared().handlePushNotification(data)
    }

    public func validateAndLogPurchase(purchaseType: String?, token: String?, productId: String?, price: String?, currency: String?, additionalParameters: [String: Any]?) {
        guard let productId = productId,
              let price = price,
              let currency = currency else {
            return
        }
        
        onReady { appsFlyer in
            // Use official iOS SDK validateAndLogInAppPurchase method (SDK v6.14.1+)
            let purchaseDetails = AFSDKPurchaseDetails(
                productId: productId,
                price: price,
                currency: currency,
                transactionId: token ?? "" // 'token' parameter maps to 'transactionId' in iOS (equivalent to 'purchaseToken' in Android)
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

    public func logSession() {
        // iOS doesn't have explicit session logging - it's automatic
        // We can track a custom event to indicate manual session logging
        onReady { appsFlyer in
            appsFlyer.logEvent("af_session", withValues: [:])
        }
    }

    public func waitForCustomerUserId(_ wait: Bool) {
        if wait {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 30)
        }
    }

    public func setCustomerIdAndLogSession(_ customerId: String) {
        AppsFlyerLib.shared().customerUserID = customerId
        logSession()
    }

    public func setMinTimeBetweenSessions(_ seconds: Int) {
        AppsFlyerLib.shared().minTimeBetweenSessions = UInt(seconds)
    }

    public func setAppId(_ appId: String) {
        AppsFlyerLib.shared().appleAppID = appId
    }

    public func setDisableAdvertisingIdentifiers(_ disable: Bool) {
        AppsFlyerLib.shared().disableAdvertisingIdentifier = disable
        AppsFlyerLib.shared().disableIDFVCollection = disable
    }

    public func enableTcfDataCollection(_ enable: Bool) {
        // Use official iOS SDK enableTCFDataCollection API for DMA compliance (SDK v6.13.0+)
        AppsFlyerLib.shared().enableTCFDataCollection(enable)
    }

    public func setSharingFilterForPartners(_ partners: [String]?) {
        guard let partners = partners else { return }
        AppsFlyerLib.shared().setSharingFilterForPartners(partners)
    }

    public func updateServerUninstallToken(_ token: String) {
        // iOS uses different mechanism for uninstall tracking
        var customData = AppsFlyerLib.shared().customData ?? [:]
        customData["uninstall_token"] = token
        AppsFlyerLib.shared().customData = customData
    }

    public func setIsUpdate(_ isUpdate: Bool) {
        // iOS doesn't have direct equivalent, store in custom data
        var customData = AppsFlyerLib.shared().customData ?? [:]
        customData["is_update"] = isUpdate
        AppsFlyerLib.shared().customData = customData
    }

    public func setAdditionalData(_ data: [String: Any]) {
        var customData = AppsFlyerLib.shared().customData ?? [:]
        customData.merge(data) { (_, new) in new }
        AppsFlyerLib.shared().customData = customData
    }

    public func registerUninstall(deviceToken: Data?) {
        AppsFlyerLib.shared().registerUninstall(deviceToken)
    }

    public func setUseUninstallSandbox(_ sandbox: Bool) {
        AppsFlyerLib.shared().useUninstallSandbox = sandbox
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
