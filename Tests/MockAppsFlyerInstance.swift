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
    var initWithoutSettingsCount = 0
    var initWithSettingsCount = 0
    var logEventCount = 0
    var logLocationCount = 0
    var setHostCount = 0
    var setUserEmailsCount = 0
    var setCurrencyCodeCount = 0
    var setCustomerIdCount = 0
    var disableTrackingCount = 0
    var anonymizeUserCount = 0
    var resolveDeepLinkURLsCount = 0
    var setPhoneNumberCount = 0
    var lastPhoneNumber: String?
    var setCurrentDeviceLanguageCount = 0
    var lastDeviceLanguage: String?
    var logAdRevenueCount = 0
    var setConsentDataCount = 0
    var setPartnerDataCount = 0
    var setSharingFilterForPartnersCount = 0
    var startCount = 0
    var handleOpenWithSourceAppCount = 0
    var setAppInviteOneLinkCount = 0
    var lastOneLinkId: String?
    
    // Store last call parameters for verification
    var lastEventName: String?
    var lastEventValues: [String: Any]?
    var lastEmails: [String]?
    var lastCurrency: String?
    var lastAppId: String?
    var lastAppDevKey: String?
    var lastSettings: [String: Any]?
    var lastLongitude: Double?
    var lastLatitude: Double?
    var lastHost: String?
    var lastPrefix: String?
    var lastCryptType: EmailCryptType?
    var lastCustomerId: String?
    var lastDisableTracking: Bool?
    var lastAnonymizeUser: Bool?
    var lastUrls: [String]?
    
    // New function parameters
    var lastMonetizationNetwork: String?
    var lastMediationNetworkType: MediationNetworkType?
    var lastAdRevenueCurrency: String?
    var lastAdRevenueAmount: Double?
    var lastAdRevenueAdditionalParams: [String: Any]?
    var lastIsUserSubjectToGDPR: Bool?
    var lastHasConsentForDataUsage: Bool?
    var lastHasConsentForAdsPersonalization: Bool?
    var lastHasConsentForAdStorage: Bool?
    var lastPartnerId: String?
    var lastPartnerInfo: [String: Any]?
    var lastSharingFilter: [String]?
    
    // Deep link handling parameters
    var lastHandleOpenUrl: URL?
    var lastHandleOpenSourceApplication: String?
    var lastHandleOpenAnnotation: Any?

    func initialize(appId: String, appDevKey: String, settings: [String : Any]?) {
        lastAppId = appId
        lastAppDevKey = appDevKey
        lastSettings = settings
        if settings != nil {
            initWithSettingsCount += 1
        } else {
            initWithoutSettingsCount += 1
        }
    }
    
    func logEvent(_ eventName: String, values: [String : Any]) {
        logEventCount += 1
        lastEventName = eventName
        lastEventValues = values
    }
    
    func logLocation(longitude: Double, latitude: Double) {
        logLocationCount += 1
        lastLongitude = longitude
        lastLatitude = latitude
    }
    
    func setHost(_ host: String, with prefix: String) {
        setHostCount += 1
        lastHost = host
        lastPrefix = prefix
    }
    
    func setUserEmails(emails: [String], with cryptType: EmailCryptType) {
        setUserEmailsCount += 1
        lastEmails = emails
        lastCryptType = cryptType
    }
    
    func currencyCode(_ currency: String) {
        setCurrencyCodeCount += 1
        lastCurrency = currency
    }
    
    func customerId(_ id: String) {
        setCustomerIdCount += 1
        lastCustomerId = id
    }
    
    func disableTracking(_ disable: Bool) {
        disableTrackingCount += 1
        lastDisableTracking = disable
    }

    func anonymizeUser(_ anonymize: Bool) {
        anonymizeUserCount += 1
        lastAnonymizeUser = anonymize
    }

    func resolveDeepLinkURLs(_ urls: [String]) {
        resolveDeepLinkURLsCount += 1
        lastUrls = urls
    }
    
    func setPhoneNumber(_ phoneNumber: String) {
        setPhoneNumberCount += 1
        lastPhoneNumber = phoneNumber
    }

    func setCurrentDeviceLanguage(_ language: String) {
        setCurrentDeviceLanguageCount += 1
        lastDeviceLanguage = language
    }

    func start() {
        startCount += 1
    }

    func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void) {
        onReady(AppsFlyerLib.shared())
    }
    
    func logAdRevenue(_ adRevenueData: AFAdRevenueData, additionalParams: [String: Any]?) {
        logAdRevenueCount += 1
        lastMonetizationNetwork = adRevenueData.monetizationNetwork
        lastMediationNetworkType = adRevenueData.mediationNetwork
        lastAdRevenueCurrency = adRevenueData.currencyIso4217Code
        lastAdRevenueAmount = adRevenueData.eventRevenue.doubleValue
        lastAdRevenueAdditionalParams = additionalParams
    }

    func setConsentData(_ consent: AppsFlyerConsent) {
        setConsentDataCount += 1
        lastIsUserSubjectToGDPR = consent.isUserSubjectToGDPR
        lastHasConsentForDataUsage = consent.hasConsentForDataUsage
        lastHasConsentForAdsPersonalization = consent.hasConsentForAdsPersonalization
        // `hasConsentForAdStorage` is exposed as `NSNumber?` on the SDK class — unwrap to Bool for verification.
        lastHasConsentForAdStorage = consent.hasConsentForAdStorage?.boolValue
    }
    
    func setPartnerData(partnerId: String, partnerInfo: [String: Any]?) {
        setPartnerDataCount += 1
        lastPartnerId = partnerId
        lastPartnerInfo = partnerInfo
    }
    
    func setSharingFilterForPartners(_ sharingFilter: [String]?) {
        setSharingFilterForPartnersCount += 1
        lastSharingFilter = sharingFilter
    }
    
    func setAppInviteOneLink(_ oneLinkId: String) {
        setAppInviteOneLinkCount += 1
        lastOneLinkId = oneLinkId
    }

    func handleOpen(url: URL, sourceApplication: String?, annotation: Any?) {
        handleOpenWithSourceAppCount += 1
        lastHandleOpenUrl = url
        lastHandleOpenSourceApplication = sourceApplication
        lastHandleOpenAnnotation = annotation
    }

}
