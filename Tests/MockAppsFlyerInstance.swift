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

    var setHostCount = 0
    var setUserEmailsCount = 0
    var setCurrencyCodeCount = 0
    var setCustomerIdCount = 0
    var disableTrackingCount = 0
    var resolveDeepLinkURLsCount = 0
    var anonymizeUserCount = 0
    var logAdRevenueCount = 0
    var setDMAConsentCount = 0 
    var setPhoneNumberCount = 0
    var addPushNotificationDeepLinkPathCount = 0
    var validateAndLogPurchaseCount = 0
    var setSharingFilterForPartnersCount = 0
    var appendCustomDataCount = 0
    var setCurrentDeviceLanguageCount = 0
    var setPartnerDataCount = 0
    var appendParametersToDeeplinkURLCount = 0
    
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
    var lastDisable: Bool?
    var lastDeepLinkUrls: [String]?
    var lastMonetizationNetwork: String?
    var lastMediationNetwork: String?
    var lastRevenue: Double?
    var lastAdditionalParameters: [String: Any]?
    var lastGdprApplies: Bool?
    var lastConsentForDataUsage: Bool?
    var lastConsentForAdsPersonalization: Bool?
    var lastConsentForAdStorage: Bool?

    var lastPhoneNumber: String?
    var lastPushDeepLinkPaths: [String]?

    var lastPurchaseType: String?
    var lastTransactionId: String?
    var lastProductId: String?
    var lastPrice: String?
    var lastPurchaseCurrency: String?
    var lastPurchaseAdditionalParameters: [String: Any]?

    var lastPartners: [String]?
    var lastAdditionalData: [String: Any]?
    var lastDeviceLanguage: String?
    var lastPartnerId: String?
    var lastPartnerInfo: [String: Any]?
    var lastUrlContains: String?
    var lastUrlParameters: [String: String]?
    
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
    
    func resolveDeepLinkURLs(_ urls: [String]) {
        lastDeepLinkUrls = urls
        resolveDeepLinkURLsCount += 1
    }
    
    func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void) {
        onReady(AppsFlyerLib.shared())
    }

    func anonymizeUser(_ anonymize: Bool) {
        lastAnonymize = anonymize
        anonymizeUserCount += 1
    }
    
    func logAdRevenue(monetizationNetwork: String, mediationNetwork: String, revenue: Double, currency: String, additionalParameters: [String: Any]?) {
        lastMonetizationNetwork = monetizationNetwork
        lastMediationNetwork = mediationNetwork
        lastRevenue = revenue
        lastCurrency = currency
        lastAdditionalParameters = additionalParameters
        logAdRevenueCount += 1
    }
    
    func setDMAConsent(gdprApplies: Bool?, consentForDataUsage: Bool?, consentForAdsPersonalization: Bool?, consentForAdStorage: Bool?) {
        // Mirror the guard logic from real AppsFlyerInstance
        guard let gdprApplies = gdprApplies else { 
            // Still record that the method was called for testing purposes
            lastGdprApplies = gdprApplies
            lastConsentForDataUsage = consentForDataUsage
            lastConsentForAdsPersonalization = consentForAdsPersonalization
            lastConsentForAdStorage = consentForAdStorage
            setDMAConsentCount += 1
            return 
        }
        
        lastGdprApplies = gdprApplies
        lastConsentForDataUsage = consentForDataUsage
        lastConsentForAdsPersonalization = consentForAdsPersonalization
        lastConsentForAdStorage = consentForAdStorage
        setDMAConsentCount += 1
    }
    
    func setPhoneNumber(_ phoneNumber: String) {
        lastPhoneNumber = phoneNumber
        setPhoneNumberCount += 1
    }
    
    func addPushNotificationDeepLinkPath(_ paths: [String]) {
        lastPushDeepLinkPaths = paths
        addPushNotificationDeepLinkPathCount += 1
    }
    
    func validateAndLogPurchase(purchaseType: String?, transactionId: String?, productId: String?, price: String?, currency: String?, additionalParameters: [String: Any]?) {
        // Mirror the guard logic from real AppsFlyerInstance
        guard let productId = productId,
              let price = price,
              let currency = currency,
              let transactionId = transactionId
              else {
            return
        }
        
        lastPurchaseType = purchaseType
        lastTransactionId = transactionId
        lastProductId = productId
        lastPrice = price
        lastPurchaseCurrency = currency
        lastPurchaseAdditionalParameters = additionalParameters
        validateAndLogPurchaseCount += 1
    }
    
    func setSharingFilterForPartners(_ partners: [String]?) {
        lastPartners = partners
        setSharingFilterForPartnersCount += 1
    }
    
    func appendCustomData(_ data: [String: Any]) {
        lastAdditionalData = data
        appendCustomDataCount += 1
    }
    
    func setCurrentDeviceLanguage(_ language: String) {
        lastDeviceLanguage = language
        setCurrentDeviceLanguageCount += 1
    }
    
    func setPartnerData(partnerId: String, partnerInfo: [String: Any]) {
        lastPartnerId = partnerId
        lastPartnerInfo = partnerInfo
        setPartnerDataCount += 1
    }
    
    func appendParametersToDeeplinkURL(contains: String, parameters: [String: String]) {
        lastUrlContains = contains
        lastUrlParameters = parameters
        appendParametersToDeeplinkURLCount += 1
    }
    
    // MARK: - Test Helper Methods
    
    func reset() {
        // Reset all counters
        initWithoutConfigCount = 0
        initWithConfigCount = 0
        logEventCount = 0
        logLocationCount = 0
        setHostCount = 0
        setUserEmailsCount = 0
        setCurrencyCodeCount = 0
        setCustomerIdCount = 0
        disableTrackingCount = 0
        resolveDeepLinkURLsCount = 0
        anonymizeUserCount = 0
        logAdRevenueCount = 0
        setDMAConsentCount = 0
        setPhoneNumberCount = 0
        addPushNotificationDeepLinkPathCount = 0
        validateAndLogPurchaseCount = 0
        setSharingFilterForPartnersCount = 0
        appendCustomDataCount = 0
        setCurrentDeviceLanguageCount = 0
        setPartnerDataCount = 0
        appendParametersToDeeplinkURLCount = 0
        
        // Reset all last values
        lastAppId = nil
        lastAppDevKey = nil
        lastSettings = nil
        lastEventName = nil
        lastEventValues = nil
        lastLatitude = nil
        lastLongitude = nil
        lastHost = nil
        lastHostPrefix = nil
        lastEmails = nil
        lastCryptType = nil
        lastCurrency = nil
        lastCustomerId = nil
        lastAnonymize = nil
        lastDisable = nil
        lastDeepLinkUrls = nil
        lastMonetizationNetwork = nil
        lastMediationNetwork = nil
        lastRevenue = nil
        lastAdditionalParameters = nil
        lastGdprApplies = nil
        lastConsentForDataUsage = nil
        lastConsentForAdsPersonalization = nil
        lastConsentForAdStorage = nil
        lastPhoneNumber = nil
        lastPushDeepLinkPaths = nil
        lastPurchaseType = nil
        lastTransactionId = nil
        lastProductId = nil
        lastPrice = nil
        lastPurchaseCurrency = nil
        lastPurchaseAdditionalParameters = nil
        lastPartners = nil
        lastAdditionalData = nil
        lastDeviceLanguage = nil
        lastPartnerId = nil
        lastPartnerInfo = nil
        lastUrlContains = nil
        lastUrlParameters = nil
    }
}
