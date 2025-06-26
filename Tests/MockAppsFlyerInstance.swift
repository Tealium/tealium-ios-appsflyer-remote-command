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
    var lastCryptType: EmailCryptType?
    var lastCurrency: String?
    var lastCustomerId: String?
    var lastAnonymize: Bool?
    var lastDisable: Bool?
    var lastDeepLinkUrls: [String]?
    var lastMonetizationNetwork: String?
    var lastMediationNetwork: MediationNetworkType?
    var lastRevenue: Double?
    var lastAdditionalParameters: [String: Any]?
    var lastGdprApplies: Bool?
    var lastConsentForDataUsage: Bool?
    var lastConsentForAdsPersonalization: Bool?
    var lastConsentForAdStorage: Bool?

    var lastPhoneNumber: String?
    var lastPushDeepLinkPaths: [String]?

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
    
    // Computed property summing all method call counters
    var totalMethodCallCount: Int {
        return initWithoutConfigCount + 
               initWithConfigCount + 
               logEventCount + 
               logLocationCount + 
               setHostCount + 
               setUserEmailsCount + 
               setCurrencyCodeCount + 
               setCustomerIdCount + 
               disableTrackingCount + 
               resolveDeepLinkURLsCount + 
               anonymizeUserCount + 
               logAdRevenueCount + 
               setDMAConsentCount + 
               setPhoneNumberCount + 
               addPushNotificationDeepLinkPathCount + 
               validateAndLogPurchaseCount + 
               setSharingFilterForPartnersCount + 
               appendCustomDataCount + 
               setCurrentDeviceLanguageCount + 
               setPartnerDataCount + 
               appendParametersToDeeplinkURLCount
    }
    
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
    
    func setUserEmails(emails: [String], with cryptType: EmailCryptType) {
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
    
    func logAdRevenue(monetizationNetwork: String, mediationNetwork: MediationNetworkType, revenue: Double, currency: String, additionalParameters: [String: Any]?) {
        lastMonetizationNetwork = monetizationNetwork
        lastMediationNetwork = mediationNetwork
        lastRevenue = revenue
        lastCurrency = currency
        lastAdditionalParameters = additionalParameters
        logAdRevenueCount += 1
    }
    
    func setDMAConsent(gdprApplies: Bool, consentForDataUsage: Bool?, consentForAdsPersonalization: Bool?, consentForAdStorage: Bool?) {
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
    
    func validateAndLogPurchase(productId: String, price: String, currency: String, transactionId: String, additionalParameters: [String: Any]?) {
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

}
