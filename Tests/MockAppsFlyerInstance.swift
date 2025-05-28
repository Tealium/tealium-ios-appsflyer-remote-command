//
//  MockAppsFlyerInstance.swift
//  TealiumAppsFlyerTests
//
//  Created by Christina S on 5/30/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation
@testable import TealiumAppsFlyer
import AppsFlyerLib

class MockAppsFlyerInstance: AppsFlyerCommand {
    var initWithoutConfigCount = 0
    var initWithConfigCount = 0
    var logEventCount = 0
    var logLocationCount = 0
    var handlePushNotificationCount = 0
    var setHostCount = 0
    var setUserEmailsCount = 0
    var setCurrencyCodeCount = 0
    var setCustomerIdCount = 0
    var disableTrackingCount = 0
    var registerUninstallCount = 0
    var resolveDeepLinkURLsCount = 0
    
    // New method counters
    var stopTrackingCount = 0
    var anonymizeUserCount = 0
    var logAdRevenueCount = 0
    var setDMAConsentCount = 0
    var enableAppsetIdCount = 0
    var setDisableNetworkDataCount = 0
    var setPhoneNumberCount = 0
    var setOutOfStoreCount = 0
    var addPushNotificationDeepLinkPathCount = 0
    var sendPushNotificationDataCount = 0
    var validateAndLogPurchaseCount = 0
    var logSessionCount = 0
    var waitForCustomerUserIdCount = 0
    var setCustomerIdAndLogSessionCount = 0
    var setMinTimeBetweenSessionsCount = 0
    var setAppIdCount = 0
    var setDisableAdvertisingIdentifiersCount = 0
    var enableTcfDataCollectionCount = 0
    var setSharingFilterForPartnersCount = 0
    var updateServerUninstallTokenCount = 0
    var setIsUpdateCount = 0
    var setAdditionalDataCount = 0
    
    // Last received values for verification
    var lastAppId: String?
    var lastAppDevKey: String?
    var lastSettings: [String: Any]?
    var lastEventName: String?
    var lastEventValues: [String: Any]?
    var lastLatitude: Double?
    var lastLongitude: Double?
    var lastHost: String?
    var lastHostPrefix: String?
    var lastEmails: [String]?
    var lastCryptType: Int?
    var lastCurrency: String?
    var lastCustomerId: String?
    var lastAnonymize: Bool?
    var lastStop: Bool?
    var lastDeepLinkUrls: [String]?
    var lastMonetizationNetwork: String?
    var lastMediationNetwork: String?
    var lastRevenue: Double?
    var lastAdditionalParameters: [String: Any]?
    var lastGdprApplies: Bool?
    var lastConsentForDataUsage: Bool?
    var lastConsentForAdsPersonalization: Bool?
    var lastConsentForAdStorage: Bool?
    var lastEnable: Bool?
    var lastDisable: Bool?
    var lastPhoneNumber: String?
    var lastOutOfStoreSource: String?
    var lastPushDeepLinkPaths: [String]?
    var lastPushNotificationData: [String: Any]?
    var lastPurchaseType: String?
    var lastPurchaseToken: String?
    var lastProductId: String?
    var lastPrice: String?
    var lastPurchaseCurrency: String?
    var lastPurchaseAdditionalParameters: [String: Any]?
    var lastWait: Bool?
    var lastSeconds: Int?
    var lastPartners: [String]?
    var lastUninstallToken: String?
    var lastIsUpdate: Bool?
    var lastAdditionalData: [String: Any]?
    
    func initialize(appId: String, appDevKey: String) {
        lastAppId = appId
        lastAppDevKey = appDevKey
        initWithoutConfigCount += 1
    }
    
    func initialize(appId: String, appDevKey: String, settings: [String : Any]?) {
        lastAppId = appId
        lastAppDevKey = appDevKey
        lastSettings = settings
        if settings != nil {
            initWithConfigCount += 1
        } else {
            initWithoutConfigCount += 1
        }
    }
    
    func logEvent(_ eventName: String, values: [String : Any]) {
        lastEventName = eventName
        lastEventValues = values
        logEventCount += 1
    }
    
    func logLocation(longitude: Double, latitude: Double) {
        lastLongitude = longitude
        lastLatitude = latitude
        logLocationCount += 1
    }
    
    func handlePushNofification(payload: [String : Any]?) {
        handlePushNotificationCount += 1
    }
    
    func setHost(_ host: String, with prefix: String) {
        lastHost = host
        lastHostPrefix = prefix
        setHostCount += 1
    }
    
    func setUserEmails(emails: [String], with cryptType: Int) {
        lastEmails = emails
        lastCryptType = cryptType
        setUserEmailsCount += 1
    }
    
    func currencyCode(_ currency: String) {
        lastCurrency = currency
        setCurrencyCodeCount += 1
    }
    
    func customerId(_ id: String) {
        lastCustomerId = id
        setCustomerIdCount += 1
    }
    
    func disableTracking(_ disable: Bool) {
        lastDisable = disable
        disableTrackingCount += 1
    }
    
    func registerUninstall(token: Data) {
        registerUninstallCount += 1
    }
    
    func resolveDeepLinkURLs(_ urls: [String]) {
        lastDeepLinkUrls = urls
        resolveDeepLinkURLsCount += 1
    }
    
    func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void) {
        onReady(AppsFlyerLib.shared())
    }
    
    // MARK: - New Methods
    
    func stopTracking(_ stop: Bool) {
        lastStop = stop
        stopTrackingCount += 1
    }
    
    func anonymizeUser(_ anonymize: Bool) {
        lastAnonymize = anonymize
        anonymizeUserCount += 1
    }
    
    func logAdRevenue(monetizationNetwork: String?, mediationNetwork: String?, revenue: Double?, currency: String?, additionalParameters: [String: Any]?) {
        lastMonetizationNetwork = monetizationNetwork
        lastMediationNetwork = mediationNetwork
        lastRevenue = revenue
        lastCurrency = currency
        lastAdditionalParameters = additionalParameters
        logAdRevenueCount += 1
    }
    
    func setDMAConsent(gdprApplies: Bool?, consentForDataUsage: Bool?, consentForAdsPersonalization: Bool?, consentForAdStorage: Bool?) {
        lastGdprApplies = gdprApplies
        lastConsentForDataUsage = consentForDataUsage
        lastConsentForAdsPersonalization = consentForAdsPersonalization
        lastConsentForAdStorage = consentForAdStorage
        setDMAConsentCount += 1
    }
    
    func enableAppsetId(_ enable: Bool) {
        lastEnable = enable
        enableAppsetIdCount += 1
    }
    
    func setDisableNetworkData(_ disable: Bool) {
        lastDisable = disable
        setDisableNetworkDataCount += 1
    }
    
    func setPhoneNumber(_ phoneNumber: String) {
        lastPhoneNumber = phoneNumber
        setPhoneNumberCount += 1
    }
    
    func setOutOfStore(_ source: String) {
        lastOutOfStoreSource = source
        setOutOfStoreCount += 1
    }
    
    func addPushNotificationDeepLinkPath(_ paths: [String]) {
        lastPushDeepLinkPaths = paths
        addPushNotificationDeepLinkPathCount += 1
    }
    
    func sendPushNotificationData(_ data: [String: Any]) {
        lastPushNotificationData = data
        sendPushNotificationDataCount += 1
    }
    
    func validateAndLogPurchase(purchaseType: String?, token: String?, productId: String?, price: String?, currency: String?, additionalParameters: [String: Any]?) {
        lastPurchaseType = purchaseType
        lastPurchaseToken = token
        lastProductId = productId
        lastPrice = price
        lastPurchaseCurrency = currency
        lastPurchaseAdditionalParameters = additionalParameters
        validateAndLogPurchaseCount += 1
    }
    
    func logSession() {
        logSessionCount += 1
    }
    
    func waitForCustomerUserId(_ wait: Bool) {
        lastWait = wait
        waitForCustomerUserIdCount += 1
    }
    
    func setCustomerIdAndLogSession(_ customerId: String) {
        lastCustomerId = customerId
        setCustomerIdAndLogSessionCount += 1
    }
    
    func setMinTimeBetweenSessions(_ seconds: Int) {
        lastSeconds = seconds
        setMinTimeBetweenSessionsCount += 1
    }
    
    func setAppId(_ appId: String) {
        lastAppId = appId
        setAppIdCount += 1
    }
    
    func setDisableAdvertisingIdentifiers(_ disable: Bool) {
        lastDisable = disable
        setDisableAdvertisingIdentifiersCount += 1
    }
    
    func enableTcfDataCollection(_ enable: Bool) {
        lastEnable = enable
        enableTcfDataCollectionCount += 1
    }
    
    func setSharingFilterForPartners(_ partners: [String]?) {
        lastPartners = partners
        setSharingFilterForPartnersCount += 1
    }
    
    func updateServerUninstallToken(_ token: String) {
        lastUninstallToken = token
        updateServerUninstallTokenCount += 1
    }
    
    func setIsUpdate(_ isUpdate: Bool) {
        lastIsUpdate = isUpdate
        setIsUpdateCount += 1
    }
    
    func setAdditionalData(_ data: [String: Any]) {
        lastAdditionalData = data
        setAdditionalDataCount += 1
    }
}
