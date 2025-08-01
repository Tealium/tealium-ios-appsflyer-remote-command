//
//  AppsFlyerRemoteCommandTests.swift
//  TealiumAppsFlyerTests
//
//  Created by Christina S on 5/24/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import XCTest
@testable import TealiumAppsFlyer
import TealiumRemoteCommands
import TealiumCore
import AppsFlyerLib


class AppsFlyerRemoteCommandTests: XCTestCase {

    var appsFlyerInstance = MockAppsFlyerInstance()
    var appsFlyerCommand: AppsFlyerRemoteCommand!
    
    override func setUp() {
        appsFlyerCommand = AppsFlyerRemoteCommand(appsFlyerInstance: appsFlyerInstance)
    }

    override func tearDown() { }
    
    func testGetEventNameCaseInsensitive() {
        let result1 = appsFlyerCommand.getEventName(command: "PURCHASE")
        let result2 = appsFlyerCommand.getEventName(command: "Purchase")
        let result3 = appsFlyerCommand.getEventName(command: "purchase")
        
        XCTAssertEqual(result1, "af_purchase")
        XCTAssertEqual(result2, "af_purchase")
        XCTAssertEqual(result3, "af_purchase")
    }
    
    func testProcessRemoteCommandWithoutCommandName() {
        let payload: [String: Any] = ["app_id": "test", "app_dev_key": "test"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.initWithoutSettingsCount, 0)
        XCTAssertEqual(appsFlyerInstance.logEventCount, 0)
    }
    
    func testSetUserEmailsWithSingleEmailString() {
        let payload: [String: Any] = [
            "command_name": "setuseremails",
            "customer_emails": "test@example.com",
            "email_hash_type": 1
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserEmailsCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastEmails?.count, 1)
        XCTAssertEqual(appsFlyerInstance.lastEmails?.first, "test@example.com")
        XCTAssertEqual(appsFlyerInstance.lastCryptType, 1)
    }
    
    func testMultipleCommands() {
        let payload: [String: Any] = [
            "command_name": "setcurrencycode,setcustomerid,viewedcontent",
            "af_currency": "USD",
            "af_customer_user_id": "user123"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setCurrencyCodeCount, 1)
        XCTAssertEqual(appsFlyerInstance.setCustomerIdCount, 1)
        XCTAssertEqual(appsFlyerInstance.logEventCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastCurrency, "USD")
        XCTAssertEqual(appsFlyerInstance.lastCustomerId, "user123")
        XCTAssertEqual(appsFlyerInstance.lastEventName, "af_content_view")
    }
    
    func testEventParametersFiltering() {
        let payload: [String: Any] = [
            "command_name": "customevent",
            "user_id": "123",
            "product_name": "iPhone",
            "debug": true,
            "method": "POST",
            "app_dev_key": "secret",
            "app_id": "myapp",
            "settings": ["key": "value"]
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        // Verify that system variables are filtered out
        let lastValues = appsFlyerInstance.lastEventValues
        XCTAssertNotNil(lastValues)
        XCTAssertEqual(lastValues?["user_id"] as? String, "123")
        XCTAssertEqual(lastValues?["product_name"] as? String, "iPhone")
        XCTAssertEqual(lastValues?["debug"] as? Bool, true)
        XCTAssertNil(lastValues?["method"])
        XCTAssertNil(lastValues?["app_dev_key"])
        XCTAssertNil(lastValues?["app_id"])
        XCTAssertNil(lastValues?["command_name"])
        XCTAssertNil(lastValues?["settings"])
    }
    
    func testInitWithoutConfig() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithoutSettingsCount)
        XCTAssertEqual(appsFlyerInstance.lastAppId, "test")
        XCTAssertEqual(appsFlyerInstance.lastAppDevKey, "test")
        XCTAssertNil(appsFlyerInstance.lastSettings)
    }
    
    func testInitWithoutConfigNotRun() {
        let payload: [String: Any] = ["command_name": "initialize"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithoutSettingsCount)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithSettingsCount)
        XCTAssertNil(appsFlyerInstance.lastAppId)
        XCTAssertNil(appsFlyerInstance.lastAppDevKey)
    }
    
    func testInitWithConfig() {
        let customData: [String: Any] = ["custom_key": "custom_value", "user_level": 5]
        let oneLinkDomains = ["custom.domain.com", "another.domain.org"]
        let deepLinkParameters: [[String: Any]] = [
            [
                "contains": "onelink.me",
                "parameters": ["utm_source": "appsflyer", "utm_medium": "deep_link"]
            ],
            [
                "contains": "custom.domain.com", 
                "parameters": ["campaign": "summer", "source": "email"]
            ]
        ]
        let settings: [String: Any] = [
            "debug": true,
            "disable_ad_tracking": false,
            "disable_apple_ads_attribution": true,
            "disable_apple_ad_tracking": false,
            "time_between_sessions": 60,
            "anonymize_user": true,
            "collect_device_name": false,
            "custom_data": customData,
            "enable_tcf_data_collection": true,
            "app_invite_onelink_id": "test_onelink_id",
            "deep_link_timeout": 3000,
            "one_link_custom_domains": oneLinkDomains,
            "facebook_deferred_app_link": "https://facebook.com/deferred",
            "push_notification_deep_link_path": ["af_push_link", "custom_link"],
            "deep_link_parameters": deepLinkParameters,
            "enable_facebook_deferred_applinks": true,
            "wait_for_att_user_authorization_timeout_interval": 45
        ]
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test_app",
                                      "app_dev_key": "test_key",
                                      "settings": settings]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithSettingsCount)
        XCTAssertEqual(appsFlyerInstance.lastAppId, "test_app")
        XCTAssertEqual(appsFlyerInstance.lastAppDevKey, "test_key")
        XCTAssertNotNil(appsFlyerInstance.lastSettings)
        
        // Test all settings are passed through correctly
        XCTAssertEqual(appsFlyerInstance.lastSettings?["debug"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["disable_ad_tracking"] as? Bool, false)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["disable_apple_ads_attribution"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["disable_apple_ad_tracking"] as? Bool, false)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["time_between_sessions"] as? Int, 60)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["anonymize_user"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["collect_device_name"] as? Bool, false)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["enable_tcf_data_collection"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["app_invite_onelink_id"] as? String, "test_onelink_id")
        XCTAssertEqual(appsFlyerInstance.lastSettings?["deep_link_timeout"] as? Int, 3000)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["facebook_deferred_app_link"] as? String, "https://facebook.com/deferred")
        
        // Test custom_data dictionary
        let receivedCustomData = appsFlyerInstance.lastSettings?["custom_data"] as? [String: Any]
        XCTAssertNotNil(receivedCustomData)
        XCTAssertEqual(receivedCustomData?["custom_key"] as? String, "custom_value")
        XCTAssertEqual(receivedCustomData?["user_level"] as? Int, 5)
        
        // Test one_link_custom_domains array
        let receivedDomains = appsFlyerInstance.lastSettings?["one_link_custom_domains"] as? [String]
        XCTAssertNotNil(receivedDomains)
        XCTAssertEqual(receivedDomains, oneLinkDomains)
        
        // Test new settings
        let receivedPushPath = appsFlyerInstance.lastSettings?["push_notification_deep_link_path"] as? [String]
        XCTAssertNotNil(receivedPushPath)
        XCTAssertEqual(receivedPushPath, ["af_push_link", "custom_link"])
        
        let receivedDeepLinkParams = appsFlyerInstance.lastSettings?["deep_link_parameters"] as? [[String: Any]]
        XCTAssertNotNil(receivedDeepLinkParams)
        XCTAssertEqual(receivedDeepLinkParams?.count, 2)
        
        // Test first deep link parameter set
        let firstParam = receivedDeepLinkParams?[0]
        XCTAssertEqual(firstParam?["contains"] as? String, "onelink.me")
        let firstParameters = firstParam?["parameters"] as? [String: String]
        XCTAssertEqual(firstParameters?["utm_source"], "appsflyer")
        XCTAssertEqual(firstParameters?["utm_medium"], "deep_link")
        
        // Test second deep link parameter set
        let secondParam = receivedDeepLinkParams?[1]
        XCTAssertEqual(secondParam?["contains"] as? String, "custom.domain.com")
        let secondParameters = secondParam?["parameters"] as? [String: String]
        XCTAssertEqual(secondParameters?["campaign"], "summer")
        XCTAssertEqual(secondParameters?["source"], "email")
        
        XCTAssertEqual(appsFlyerInstance.lastSettings?["enable_facebook_deferred_applinks"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["wait_for_att_user_authorization_timeout_interval"] as? Int, 45)
    }
    
    func testInitWithConfigNotRun() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "settings": ["test": "test"]]
        
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithSettingsCount)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithoutSettingsCount)
    }
    
    func testTrackEvent() {
        let payload: [String: Any] = ["command_name": "viewedcontent,rate,login"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(3, self.appsFlyerInstance.logEventCount)
        XCTAssertEqual(appsFlyerInstance.lastEventName, "af_login")
    }
    
    func testTrackCustomEvent() {
        let payload: [String: Any] = ["command_name": "custom_command_name",
                                      "custom_param": "value123"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logEventCount)
        XCTAssertEqual(appsFlyerInstance.lastEventName, "custom_command_name")
        XCTAssertEqual(appsFlyerInstance.lastEventValues?["custom_param"] as? String, "value123")
    }
    
    func testTrackLocationWithLatLongInts() {
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33,
                                      "af_long": 122]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
        XCTAssertEqual(appsFlyerInstance.lastLatitude, 33.0)
        XCTAssertEqual(appsFlyerInstance.lastLongitude, 122.0)
    }
    
    func testTrackLocationWithLatLongDoubles() {
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33.0,
                                      "af_long": -122.0]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
        XCTAssertEqual(appsFlyerInstance.lastLatitude, 33.0)
        XCTAssertEqual(appsFlyerInstance.lastLongitude, -122.0)
    }
    
    func testTrackLocationNotRun() {
        let payload: [String: Any] = ["command_name": "tracklocation"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logLocationCount)
        XCTAssertNil(appsFlyerInstance.lastLatitude)
        XCTAssertNil(appsFlyerInstance.lastLongitude)
    }
    
    func testSetHost() {
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host": "test.com",
                                      "host_prefix": "test"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setHostCount)
        XCTAssertEqual(appsFlyerInstance.lastHost, "test.com")
        XCTAssertEqual(appsFlyerInstance.lastPrefix, "test")
    }
    
    func testSetHostNotRun() {
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host_prefix": "test"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setHostCount)
        XCTAssertNil(appsFlyerInstance.lastHost)
        XCTAssertNil(appsFlyerInstance.lastPrefix)
    }
    
    func testSetUserEmails() {
        let emails = ["user@example.com", "admin@example.com"]
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": emails,
                                      "email_hash_type": 2]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
        XCTAssertEqual(appsFlyerInstance.lastEmails, emails)
        XCTAssertEqual(appsFlyerInstance.lastCryptType, 2)
    }
    
    func testSetUserEmailsWNotRun() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "email_hash_type": 1]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setUserEmailsCount)
        XCTAssertNil(appsFlyerInstance.lastEmails)
        XCTAssertNil(appsFlyerInstance.lastCryptType)
    }
    
    func testSetCurrencyCode() {
        let payload: [String: Any] = ["command_name": "setcurrencycode", "af_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setCurrencyCodeCount)
        XCTAssertEqual(appsFlyerInstance.lastCurrency, "USD")
    }
    
    func testSetCurrencyCodeNotRun() {
        let payload: [String: Any] = ["command_name": "setcurrencycode"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setCurrencyCodeCount)
        XCTAssertNil(appsFlyerInstance.lastCurrency)
    }
    
    func testSetCustomerId() {
        let payload: [String: Any] = ["command_name": "setcustomerid", "af_customer_user_id": "ABC123"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setCustomerIdCount)
        XCTAssertEqual(appsFlyerInstance.lastCustomerId, "ABC123")
    }
    
    func testSetCustomerIdNotRun() {
        let payload: [String: Any] = ["command_name": "setcustomerid"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setCustomerIdCount)
        XCTAssertNil(appsFlyerInstance.lastCustomerId)
    }
    
    func testDisableTrackingTrue() {
        let payload: [String: Any] = ["command_name": "disabletracking", "stop_tracking": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
        XCTAssertEqual(appsFlyerInstance.lastDisableTracking, true)
    }
    
    func testDisableTrackingFalse() {
        let payload: [String: Any] = ["command_name": "disabletracking", "stop_tracking": false]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
        XCTAssertEqual(appsFlyerInstance.lastDisableTracking, false)
    }
    
    func testDisableTrackingDefaultValue() {
        let payload: [String: Any] = ["command_name": "disabletracking"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
        XCTAssertEqual(appsFlyerInstance.lastDisableTracking, false)
    }

    func testResolveDeepLinkURLs() {
        let urls = ["app://product/123", "app://category/electronics"]
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls", "af_deep_link": urls]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.resolveDeepLinkURLsCount)
        XCTAssertEqual(appsFlyerInstance.lastUrls, urls)
    }
    
    func testResolveDeepLinkURLsNotRun() {
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.resolveDeepLinkURLsCount)
        XCTAssertNil(appsFlyerInstance.lastUrls)
    }

    func testOnReadyCalledAfterInitialize() {
        let onReadyCalled = expectation(description: "OnReady is called")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test"]
        appsFlyerCommand = AppsFlyerRemoteCommand()
        appsFlyerCommand.onReady { _ in
            onReadyCalled.fulfill()
        }
        appsFlyerCommand.processRemoteCommand(with: payload)
        TealiumQueues.backgroundSerialQueue.sync {
            waitForExpectations(timeout: 1.0)
        }
    }

    func testOnReadyCalledOnFirstLogWhenManuallyInitialized() {
        let onReadyCalled = expectation(description: "OnReady is called")
        let payload: [String: Any] = ["command_name": "viewedcontent"]
        appsFlyerCommand = AppsFlyerRemoteCommand()
        appsFlyerCommand.onReady { _ in
            onReadyCalled.fulfill()
        }
        let lib = AppsFlyerLib.shared()
        lib.appleAppID = "test_appid"
        lib.appsFlyerDevKey = "test_devkey"
        appsFlyerCommand.processRemoteCommand(with: payload)
        TealiumQueues.backgroundSerialQueue.sync {
            waitForExpectations(timeout: 1.0)
        }
    }

    func testOnReadyCalledOnRegistrationWhenPreviouslyManuallyInitialized() {
        let onReadyCalled = expectation(description: "OnReady is called")
        appsFlyerCommand = AppsFlyerRemoteCommand()
        let lib = AppsFlyerLib.shared()
        lib.appleAppID = "test_appid"
        lib.appsFlyerDevKey = "test_devkey"
        appsFlyerCommand.onReady { _ in
            onReadyCalled.fulfill()
        }
        TealiumQueues.backgroundSerialQueue.sync {
            waitForExpectations(timeout: 1.0)
        }
    }

    func testSetPhoneNumber() {
        let payload: [String: Any] = [
            "command_name": "setphonenumber",
            "phone_number": "+48123456789"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setPhoneNumberCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastPhoneNumber, "+48123456789")
    }

    func testDeepLinkTimeoutValidation() {
        // Test that negative deepLinkTimeout is filtered out
        let settings: [String: Any] = [
            "deep_link_timeout": -1000, 
        ]
        let payload: [String: Any] = [
            "command_name": "initialize",
            "app_id": "test",
            "app_dev_key": "test",
            "settings": settings
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(1, self.appsFlyerInstance.initWithSettingsCount)
        XCTAssertNotNil(appsFlyerInstance.lastSettings)
        
        // deep_link_timeout should be removed due to negative value
        XCTAssertNil(appsFlyerInstance.lastSettings?["deep_link_timeout"])
    }
    
    func testLogAdRevenue() {
        let additionalParams: [String: Any] = ["custom_param": "value", "level": 5]
        let payload: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "AdMob",
            "mediation_network": "googleadmob",
            "ad_revenue_currency": "USD",
            "ad_revenue_amount": 0.05,
            "ad_revenue_additional_params": additionalParams
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.logAdRevenueCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastMonetizationNetwork, "AdMob")
        XCTAssertEqual(appsFlyerInstance.lastMediationNetworkType, .googleAdMob)
        XCTAssertEqual(appsFlyerInstance.lastAdRevenueCurrency, "USD")
        XCTAssertEqual(appsFlyerInstance.lastAdRevenueAmount, 0.05)
        XCTAssertNotNil(appsFlyerInstance.lastAdRevenueAdditionalParams)
        XCTAssertEqual(appsFlyerInstance.lastAdRevenueAdditionalParams?["custom_param"] as? String, "value")
        XCTAssertEqual(appsFlyerInstance.lastAdRevenueAdditionalParams?["level"] as? Int, 5)
    }
    
    func testLogAdRevenueWithoutAdditionalParams() {
        let payload: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "IronSource",
            "mediation_network": "ironsource",
            "ad_revenue_currency": "EUR",
            "ad_revenue_amount": 0.12
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.logAdRevenueCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastMonetizationNetwork, "IronSource")
        XCTAssertEqual(appsFlyerInstance.lastMediationNetworkType, .ironSource)
        XCTAssertEqual(appsFlyerInstance.lastAdRevenueCurrency, "EUR")
        XCTAssertEqual(appsFlyerInstance.lastAdRevenueAmount, 0.12)
        XCTAssertNil(appsFlyerInstance.lastAdRevenueAdditionalParams)
    }
    
    func testLogAdRevenueNotRunWithMissingParameters() {
        let payload: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "AdMob",
            "mediation_network": "googleadmob",
            // Missing ad_revenue_currency and ad_revenue_amount
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.logAdRevenueCount, 0)
        XCTAssertNil(appsFlyerInstance.lastMonetizationNetwork)
    }
    
    func testLogAdRevenueNotRunWithInvalidMediationNetwork() {
        let payload: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "AdMob",
            "mediation_network": "invalid_network",
            "ad_revenue_currency": "USD",
            "ad_revenue_amount": 0.05
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.logAdRevenueCount, 0)
        XCTAssertNil(appsFlyerInstance.lastMonetizationNetwork)
    }
    
    func testSetConsentData() {
        let payload: [String: Any] = [
            "command_name": "setconsentdata",
            "is_user_subject_to_gdpr": true,
            "has_consent_for_data_usage": true,
            "has_consent_for_ads_personalization": false,
            "has_consent_for_ad_storage": true
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.setConsentDataCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastIsUserSubjectToGDPR, true)
        XCTAssertEqual(appsFlyerInstance.lastHasConsentForDataUsage, true)
        XCTAssertEqual(appsFlyerInstance.lastHasConsentForAdsPersonalization, false)
        XCTAssertEqual(appsFlyerInstance.lastHasConsentForAdStorage, true)
    }
    
    func testSetConsentDataNotRunWithMissingParameters() {
        let payload: [String: Any] = [
            "command_name": "setconsentdata",
            "is_user_subject_to_gdpr": true,
            "has_consent_for_data_usage": true
            // Missing has_consent_for_ads_personalization and has_consent_for_ad_storage
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.setConsentDataCount, 0)
        XCTAssertNil(appsFlyerInstance.lastIsUserSubjectToGDPR)
    }
    
    func testSetPartnerData() {
        let partnerInfo: [String: Any] = ["puid": "123456789", "user_segment": "premium"]
        let payload: [String: Any] = [
            "command_name": "setpartnerdata",
            "partner_id": "analytics_partner_int",
            "partner_info": partnerInfo
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.setPartnerDataCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastPartnerId, "analytics_partner_int")
        XCTAssertNotNil(appsFlyerInstance.lastPartnerInfo)
        XCTAssertEqual(appsFlyerInstance.lastPartnerInfo?["puid"] as? String, "123456789")
        XCTAssertEqual(appsFlyerInstance.lastPartnerInfo?["user_segment"] as? String, "premium")
    }
    
    func testSetPartnerDataWithoutPartnerInfo() {
        let payload: [String: Any] = [
            "command_name": "setpartnerdata",
            "partner_id": "test_partner_int"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.setPartnerDataCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastPartnerId, "test_partner_int")
        XCTAssertNil(appsFlyerInstance.lastPartnerInfo)
    }
    
    func testSetPartnerDataNotRunWithMissingPartnerId() {
        let payload: [String: Any] = [
            "command_name": "setpartnerdata",
            "partner_info": ["test": "value"]
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.setPartnerDataCount, 0)
        XCTAssertNil(appsFlyerInstance.lastPartnerId)
    }
    
    func testSetSharingFilterForPartners() {
        let sharingFilter = ["facebook_int", "google_int"]
        let payload: [String: Any] = [
            "command_name": "setsharingfilterforpartners",
            "sharing_filter": sharingFilter
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.setSharingFilterForPartnersCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastSharingFilter, sharingFilter)
    }
    
    func testSetSharingFilterForPartnersWithAllFilter() {
        let sharingFilter = ["all"]
        let payload: [String: Any] = [
            "command_name": "setsharingfilterforpartners",
            "sharing_filter": sharingFilter
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.setSharingFilterForPartnersCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastSharingFilter, sharingFilter)
    }
    
    func testSetSharingFilterForPartnersReset() {
        let payload: [String: Any] = [
            "command_name": "setsharingfilterforpartners"
            // No sharing_filter parameter = nil = reset
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        XCTAssertEqual(appsFlyerInstance.setSharingFilterForPartnersCount, 1)
        XCTAssertNil(appsFlyerInstance.lastSharingFilter)
    }

}
