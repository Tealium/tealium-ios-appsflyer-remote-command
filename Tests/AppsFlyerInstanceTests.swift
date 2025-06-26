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


class AppsFlyerInstanceTests: XCTestCase {

    var appsFlyerInstance = MockAppsFlyerInstance()
    var appsFlyerCommand: AppsFlyerRemoteCommand!
    
    override func setUp() {
        appsFlyerCommand = AppsFlyerRemoteCommand(appsFlyerInstance: appsFlyerInstance)
    }

    override func tearDown() { }

    func testInitWithoutConfig() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithoutConfigCount)
    }
    
    func testInitWithoutConfigNotRun() {
        let payload: [String: Any] = ["command_name": "initialize"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithoutConfigCount)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
    }
    
    func testInitWithConfig() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test",
                                      "settings": ["test": "test"]]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithConfigCount)
        XCTAssertNotNil(self.appsFlyerInstance.lastSettings)
        
        guard let settings = self.appsFlyerInstance.lastSettings else {
            XCTFail("Settings are missing")
            return
        }
        XCTAssertEqual(settings["test"] as? String, "test")
    }
    
    func testInitWithConfigNotRun() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "settings": ["test": "test"]]
        
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
    }

    func testInitWithoutSettingsParam() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test_app",
                                      "app_dev_key": "test_key"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithoutConfigCount)
        XCTAssertEqual("test_app", self.appsFlyerInstance.lastAppId)
        XCTAssertEqual("test_key", self.appsFlyerInstance.lastAppDevKey)
        XCTAssertNil(self.appsFlyerInstance.lastSettings)
    }
    
    func testInitWithAllConfigParameters() {
        let payload: [String: Any] = [
            "command_name": "initialize",
            "app_id": "test_app", 
            "app_dev_key": "test_key",
            "settings": [
                "debug": true,
                "disable_ad_tracking": true,
                "disable_apple_ad_tracking": false,
                "disable_apple_ads_attribution": true,
                "anonymize_user": false,
                "time_between_sessions": 30,
                "collect_device_name": false,
                "use_uninstall_sandbox": true,
                "enable_tcf_data_collection": true,
                "app_invite_onelink_id": "test_onelink",
                "deeplink_timeout": 5,
                "onelink_custom_domains": ["custom1.example.com", "custom2.example.com"],
                "use_receipt_validation_sandbox": true,
                "wait_for_att_user_authorization_timeout_interval": 30.0,
                "resolve_deep_links": ["app://deeplink1", "app://deeplink2"],
                "stop_tracking": false,
                "host": "custom.host.com",
                "host_prefix": "custom_prefix",
                "custom_data": ["custom_key": "custom_value"]
            ]
        ]
        
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithConfigCount)
        XCTAssertEqual("test_app", self.appsFlyerInstance.lastAppId)
        XCTAssertEqual("test_key", self.appsFlyerInstance.lastAppDevKey)
        XCTAssertNotNil(self.appsFlyerInstance.lastSettings)
        
        guard let settings = self.appsFlyerInstance.lastSettings else {
            XCTFail("Settings are missing")
            return
        }
        
        // Check all boolean settings
        XCTAssertEqual(settings["debug"] as? Bool, true)
        XCTAssertEqual(settings["disable_ad_tracking"] as? Bool, true)
        XCTAssertEqual(settings["disable_apple_ad_tracking"] as? Bool, false)
        XCTAssertEqual(settings["disable_apple_ads_attribution"] as? Bool, true)
        XCTAssertEqual(settings["anonymize_user"] as? Bool, false)
        XCTAssertEqual(settings["collect_device_name"] as? Bool, false)
        XCTAssertEqual(settings["use_uninstall_sandbox"] as? Bool, true)
        XCTAssertEqual(settings["enable_tcf_data_collection"] as? Bool, true)
        XCTAssertEqual(settings["use_receipt_validation_sandbox"] as? Bool, true)
        XCTAssertEqual(settings["stop_tracking"] as? Bool, false)
        
        // Check integer settings
        XCTAssertEqual(settings["time_between_sessions"] as? Int, 30)
        XCTAssertEqual(settings["deeplink_timeout"] as? Int, 5)
        
        // Check double settings
        XCTAssertEqual(settings["wait_for_att_user_authorization_timeout_interval"] as? Double, 30.0)
        
        // Check string settings
        XCTAssertEqual(settings["app_invite_onelink_id"] as? String, "test_onelink")
        XCTAssertEqual(settings["host"] as? String, "custom.host.com")
        XCTAssertEqual(settings["host_prefix"] as? String, "custom_prefix")
        
        // Check array settings
        let onelinkDomains = settings["onelink_custom_domains"] as? [String]
        XCTAssertNotNil(onelinkDomains)
        XCTAssertEqual(onelinkDomains?.count, 2)
        XCTAssertTrue(onelinkDomains?.contains("custom1.example.com") == true)
        XCTAssertTrue(onelinkDomains?.contains("custom2.example.com") == true)
        
        let deepLinks = settings["resolve_deep_links"] as? [String]
        XCTAssertNotNil(deepLinks)
        XCTAssertEqual(deepLinks?.count, 2)
        XCTAssertTrue(deepLinks?.contains("app://deeplink1") == true)
        XCTAssertTrue(deepLinks?.contains("app://deeplink2") == true)
        
        // Check custom_data dictionary
        let customData = settings["custom_data"] as? [String: Any]
        XCTAssertNotNil(customData)
        XCTAssertEqual(customData?["custom_key"] as? String, "custom_value")
    }
    
    func testConfigurationKeyStringsAreStable() {
        XCTAssertEqual(AppsFlyerConstants.Configuration.debug.rawValue, "debug")
        XCTAssertEqual(AppsFlyerConstants.Configuration.disableAdTracking.rawValue, "disable_ad_tracking")
        XCTAssertEqual(AppsFlyerConstants.Configuration.disableAppleAdTracking.rawValue, "disable_apple_ad_tracking")
        XCTAssertEqual(AppsFlyerConstants.Configuration.disableAppleAdsAttribution.rawValue, "disable_apple_ads_attribution")
        XCTAssertEqual(AppsFlyerConstants.Configuration.minTimeBetweenSessions.rawValue, "time_between_sessions")
        XCTAssertEqual(AppsFlyerConstants.Configuration.anonymizeUser.rawValue, "anonymize_user")
        XCTAssertEqual(AppsFlyerConstants.Configuration.collectDeviceName.rawValue, "collect_device_name")
        XCTAssertEqual(AppsFlyerConstants.Configuration.appId.rawValue, "app_id")
        XCTAssertEqual(AppsFlyerConstants.Configuration.appDevKey.rawValue, "app_dev_key")
        XCTAssertEqual(AppsFlyerConstants.Configuration.customData.rawValue, "custom_data")
        XCTAssertEqual(AppsFlyerConstants.Configuration.settings.rawValue, "settings")
        XCTAssertEqual(AppsFlyerConstants.Configuration.useUninstallSandbox.rawValue, "use_uninstall_sandbox")
        XCTAssertEqual(AppsFlyerConstants.Configuration.enableTCFDataCollection.rawValue, "enable_tcf_data_collection")
        XCTAssertEqual(AppsFlyerConstants.Configuration.appInviteOneLinkID.rawValue, "app_invite_onelink_id")
        XCTAssertEqual(AppsFlyerConstants.Configuration.deepLinkTimeout.rawValue, "deeplink_timeout")
        XCTAssertEqual(AppsFlyerConstants.Configuration.oneLinkCustomDomains.rawValue, "onelink_custom_domains")
        XCTAssertEqual(AppsFlyerConstants.Configuration.useReceiptValidationSandbox.rawValue, "use_receipt_validation_sandbox")
        XCTAssertEqual(AppsFlyerConstants.Configuration.waitForATTUserAuthorizationTimeoutInterval.rawValue, "wait_for_att_user_authorization_timeout_interval")
        XCTAssertEqual(AppsFlyerConstants.Configuration.resolveDeepLinks.rawValue, "resolve_deep_links")
        XCTAssertEqual(AppsFlyerConstants.Configuration.stopTracking.rawValue, "stop_tracking")
        XCTAssertEqual(AppsFlyerConstants.Configuration.host.rawValue, "host")
        XCTAssertEqual(AppsFlyerConstants.Configuration.hostPrefix.rawValue, "host_prefix")
    }
    
    func testCaseInsensitiveCommands() {
        let payloadUpper: [String: Any] = ["command_name": "INITIALIZE",
                                           "app_id": "test",
                                           "app_dev_key": "test",
                                           "settings": ["debug": true]]
        appsFlyerCommand.processRemoteCommand(with: payloadUpper)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithConfigCount)
        XCTAssertNotNil(self.appsFlyerInstance.lastSettings)
        
        guard let settings = self.appsFlyerInstance.lastSettings else {
            XCTFail("Settings are missing")
            return
        }
        XCTAssertEqual(settings["debug"] as? Bool, true)
        
        let payloadMixed: [String: Any] = ["command_name": "SetCurrencyCode", "af_currency": "GBP"]
        appsFlyerCommand.processRemoteCommand(with: payloadMixed)
        XCTAssertEqual(1, self.appsFlyerInstance.setCurrencyCodeCount)
    }

    func testEmptyCommandName() {
        let payload: [String: Any] = ["command_name": ""]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logEventCount)
        XCTAssertNil(self.appsFlyerInstance.lastEventName)
    }
    
    func testInvalidCommandName() {
        let payload: [String: Any] = ["command_name": "invalid_command_that_does_not_exist"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logEventCount)
        XCTAssertEqual("invalid_command_that_does_not_exist", self.appsFlyerInstance.lastEventName)
    }
    
    func testMissingCommandName() {
        let payload: [String: Any] = ["app_id": "test", "app_dev_key": "test"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.totalMethodCallCount)
    }
    
    func testInvalidCommandNameType() {
        let payload: [String: Any] = ["command_name": 123, "app_id": "test"]  // Int instead of String
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.totalMethodCallCount)
    }
    
    func testTrackEvent() {
        let payload: [String: Any] = ["command_name": "viewedcontent,rate,login"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(3, self.appsFlyerInstance.logEventCount)
    }
    
    func testTrackCustomEvent() {
        let payload: [String: Any] = ["command_name": "custom_command_name"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logEventCount)
    }
    
    func testTrackLocationWithLatLongInts() {
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33,
                                      "af_long": 122]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
        XCTAssertEqual(33, self.appsFlyerInstance.lastLatitude)
        XCTAssertEqual(122, self.appsFlyerInstance.lastLongitude)
    }
    
    func testTrackLocationWithLatLongDoubles() {
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33.0,
                                      "af_long": -122.0]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
    }
    
    func testTrackLocationNotRun() {
        let payload: [String: Any] = ["command_name": "tracklocation"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logLocationCount)
    }
    
    func testSetHost() {
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host": "test.com",
                                      "host_prefix": "test"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setHostCount)
        XCTAssertEqual("test.com", self.appsFlyerInstance.lastHost)
        XCTAssertEqual("test", self.appsFlyerInstance.lastHostPrefix)
    }
    
    func testSetHostNotRun() {
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host_prefix": "test"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setHostCount)
    }
    
    func testSetUserEmails() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": ["blah", "blah2"],
                                      "email_hash_type": "sha256"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
        XCTAssertEqual(["blah", "blah2"], self.appsFlyerInstance.lastEmails)
        XCTAssertEqual(AppsFlyerConstants.EmailHashType.appsFlyerTypeFromString("sha256"), self.appsFlyerInstance.lastCryptType)
    }
    
    func testSetUserEmailsWNotRun() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "email_hash_type": "none"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setUserEmailsCount)
    }
    
    func testSetUserEmailsWithSingleString() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": "test@example.com",
                                      "email_hash_type": "none"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
        XCTAssertEqual(["test@example.com"], self.appsFlyerInstance.lastEmails)
        XCTAssertEqual(AppsFlyerConstants.EmailHashType.appsFlyerTypeFromString("none"), self.appsFlyerInstance.lastCryptType)
    }
    
    func testSetUserEmailsWithSHA256HashType() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": ["test1@example.com"],
                                      "email_hash_type": "sha256"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
        XCTAssertEqual(["test1@example.com"], self.appsFlyerInstance.lastEmails)
        XCTAssertEqual(AppsFlyerConstants.EmailHashType.appsFlyerTypeFromString("sha256"), self.appsFlyerInstance.lastCryptType)
    }
    
    func testSetUserEmailsWithNoneHashType() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": ["test2@example.com"],
                                      "email_hash_type": "none"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
        XCTAssertEqual(["test2@example.com"], self.appsFlyerInstance.lastEmails)
        XCTAssertEqual(AppsFlyerConstants.EmailHashType.appsFlyerTypeFromString("none"), self.appsFlyerInstance.lastCryptType)
    }
    
    func testSetUserEmailsWithCaseInsensitiveHashType() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": ["test3@example.com"],
                                      "email_hash_type": "SHA256"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
        XCTAssertEqual(["test3@example.com"], self.appsFlyerInstance.lastEmails)
        XCTAssertEqual(AppsFlyerConstants.EmailHashType.appsFlyerTypeFromString("SHA256"), self.appsFlyerInstance.lastCryptType)
    }
    
    func testSetUserEmailsWithInvalidHashType() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": ["test@example.com"],
                                      "email_hash_type": "invalid_hash_type"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        // Should not be called due to invalid hash type
        XCTAssertEqual(0, self.appsFlyerInstance.setUserEmailsCount)
        XCTAssertNil(self.appsFlyerInstance.lastCryptType)
        XCTAssertNil(self.appsFlyerInstance.lastEmails)
    }
    
    func testSetCurrencyCode() {
        let payload: [String: Any] = ["command_name": "setcurrencycode", "af_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setCurrencyCodeCount)
    }
    
    func testSetCurrencyCodeNotRun() {
        let payload: [String: Any] = ["command_name": "setcurrencycode"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setCurrencyCodeCount)
    }
    
    func testSetCustomerId() {
        let payload: [String: Any] = ["command_name": "setcustomerid", "af_customer_user_id": "ABC123"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setCustomerIdCount)
    }
    
    func testSetCustomerIdNotRun() {
        let payload: [String: Any] = ["command_name": "setcustomerid"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setCustomerIdCount)
    }
    
    func testDisableTrackingCommandName() {
        let payload: [String: Any] = ["command_name": "disabletracking"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
    }
    
    func testDisableTrackingVariable() {
        let payload: [String: Any] = ["command_name": "disabletracking", "stop_tracking": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
        XCTAssertEqual(true, self.appsFlyerInstance.lastDisable)
    }
    
    func testResolveDeepLinkURLs() {
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls", "af_deep_link": ["app://test.com", "app://test?home=true"]]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.resolveDeepLinkURLsCount)
        XCTAssertEqual(["app://test.com", "app://test?home=true"], self.appsFlyerInstance.lastDeepLinkUrls)
    }
    
    func testResolveDeepLinkURLsNotRun() {
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.resolveDeepLinkURLsCount)
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

    
    func testAnonymizeUser() {
        let payload: [String: Any] = ["command_name": "anonymizeuser", "anonymize_user": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.anonymizeUserCount)
        XCTAssertEqual(true, self.appsFlyerInstance.lastAnonymize)
    }
    
    func testAnonymizeUserNotRun() {
        let payload: [String: Any] = ["command_name": "anonymizeuser"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.anonymizeUserCount)
    }
    
    func testLogAdRevenue() {
        let payload: [String: Any] = ["command_name": "logadrevenue",
                                      "monetization_network": "TestNetwork",
                                      "mediation_network": "ironsource",
                                      "revenue": 1.99,
                                      "af_currency": "USD",
                                      "additional_parameters": ["key": "value"]]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logAdRevenueCount)
        XCTAssertEqual("TestNetwork", self.appsFlyerInstance.lastMonetizationNetwork)
        XCTAssertEqual(AppsFlyerConstants.MediationNetwork.appsFlyerTypeFromString("ironsource"), self.appsFlyerInstance.lastMediationNetwork)
        XCTAssertEqual(1.99, self.appsFlyerInstance.lastRevenue)
        XCTAssertEqual("USD", self.appsFlyerInstance.lastCurrency)
    }
    
    func testLogAdRevenueWithNilValues() {
        let payload: [String: Any] = ["command_name": "logadrevenue"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logAdRevenueCount)
        XCTAssertNil(self.appsFlyerInstance.lastMonetizationNetwork)
        XCTAssertNil(self.appsFlyerInstance.lastMediationNetwork)
        XCTAssertNil(self.appsFlyerInstance.lastRevenue)
        XCTAssertNil(self.appsFlyerInstance.lastCurrency)
    }
    
    func testSetDMAConsent() {
        let payload: [String: Any] = ["command_name": "setdmaconsent",
                                      "gdpr_applies": true,
                                      "consent_for_data_usage": true,
                                      "consent_for_ads_personalization": false,
                                      "consent_for_ad_storage": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setDMAConsentCount)
        XCTAssertEqual(true, self.appsFlyerInstance.lastGdprApplies)
        XCTAssertEqual(true, self.appsFlyerInstance.lastConsentForDataUsage)
        XCTAssertEqual(false, self.appsFlyerInstance.lastConsentForAdsPersonalization)
        XCTAssertEqual(true, self.appsFlyerInstance.lastConsentForAdStorage)
    }
    
    func testSetDMAConsentWithNilValues() {
        let payload: [String: Any] = ["command_name": "setdmaconsent"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setDMAConsentCount)
        XCTAssertNil(self.appsFlyerInstance.lastGdprApplies)
        XCTAssertNil(self.appsFlyerInstance.lastConsentForDataUsage)
        XCTAssertNil(self.appsFlyerInstance.lastConsentForAdsPersonalization)
        XCTAssertNil(self.appsFlyerInstance.lastConsentForAdStorage)
    }

    func testSetDMAConsentGdprNotApplies() {
        let payload: [String: Any] = ["command_name": "setdmaconsent",
                                      "gdpr_applies": false,
                                      "consent_for_data_usage": true,
                                      "consent_for_ads_personalization": true,
                                      "consent_for_ad_storage": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setDMAConsentCount)
        XCTAssertEqual(false, self.appsFlyerInstance.lastGdprApplies)
        XCTAssertEqual(true, self.appsFlyerInstance.lastConsentForDataUsage)
        XCTAssertEqual(true, self.appsFlyerInstance.lastConsentForAdsPersonalization)
        XCTAssertEqual(true, self.appsFlyerInstance.lastConsentForAdStorage)
    }
    
    func testSetDMAConsentGdprAppliesWithMixedConsents() {
        let payload: [String: Any] = ["command_name": "setdmaconsent",
                                      "gdpr_applies": true,
                                      "consent_for_data_usage": true,
                                      "consent_for_ad_storage": false]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setDMAConsentCount)
        XCTAssertEqual(true, self.appsFlyerInstance.lastGdprApplies)
        XCTAssertEqual(true, self.appsFlyerInstance.lastConsentForDataUsage)
        XCTAssertNil(self.appsFlyerInstance.lastConsentForAdsPersonalization)
        XCTAssertEqual(false, self.appsFlyerInstance.lastConsentForAdStorage)
    }
    
    func testSetDMAConsentGdprAppliesAllNilConsents() {
        let payload: [String: Any] = ["command_name": "setdmaconsent",
                                      "gdpr_applies": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setDMAConsentCount)
        XCTAssertEqual(true, self.appsFlyerInstance.lastGdprApplies)
        XCTAssertNil(self.appsFlyerInstance.lastConsentForDataUsage)
        XCTAssertNil(self.appsFlyerInstance.lastConsentForAdsPersonalization)
        XCTAssertNil(self.appsFlyerInstance.lastConsentForAdStorage)
    }
    
    func testSetPhoneNumber() {
        let payload: [String: Any] = ["command_name": "setphonenumber", "phone_number": "+1234567890"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setPhoneNumberCount)
        XCTAssertEqual("+1234567890", self.appsFlyerInstance.lastPhoneNumber)
    }
    
    func testSetPhoneNumberNotRun() {
        let payload: [String: Any] = ["command_name": "setphonenumber"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setPhoneNumberCount)
    }
    
    func testAddPushNotificationDeepLinkPath() {
        let payload: [String: Any] = ["command_name": "addpushnotificationdeeplinkpath", 
                                      "push_notification_deep_link_path": ["path1", "path2"]]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.addPushNotificationDeepLinkPathCount)
        XCTAssertEqual(["path1", "path2"], self.appsFlyerInstance.lastPushDeepLinkPaths)
    }
    
    func testAddPushNotificationDeepLinkPathNotRun() {
        let payload: [String: Any] = ["command_name": "addpushnotificationdeeplinkpath"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.addPushNotificationDeepLinkPathCount)
    }
    
    func testValidateAndLogPurchase() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase",
                                      "transaction_id": "txn123",
                                      "product_id": "premium_monthly",
                                      "price": "9.99",
                                      "af_purchase_currency": "USD",
                                      "purchase_additional_parameters": ["user_id": "123", "campaign": "winter_sale", "discount": 10]]
        appsFlyerCommand.processRemoteCommand(with: payload)
        
        // Verify the method was called
        XCTAssertEqual(1, self.appsFlyerInstance.validateAndLogPurchaseCount)
        
        // Verify all required parameters are correctly passed
        XCTAssertEqual("txn123", self.appsFlyerInstance.lastTransactionId)
        XCTAssertEqual("premium_monthly", self.appsFlyerInstance.lastProductId)
        XCTAssertEqual("9.99", self.appsFlyerInstance.lastPrice)
        XCTAssertEqual("USD", self.appsFlyerInstance.lastPurchaseCurrency)
        
        // Verify optional additional parameters are correctly passed
        XCTAssertNotNil(self.appsFlyerInstance.lastPurchaseAdditionalParameters)
        guard let additionalParams = self.appsFlyerInstance.lastPurchaseAdditionalParameters else {
            XCTFail("Additional parameters should not be nil")
            return
        }
        XCTAssertEqual("123", additionalParams["user_id"] as? String)
        XCTAssertEqual("winter_sale", additionalParams["campaign"] as? String)
        XCTAssertEqual(10, additionalParams["discount"] as? Int)
    }
    
    func testValidateAndLogPurchaseWithNilValues() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertNil(self.appsFlyerInstance.lastTransactionId)
        XCTAssertNil(self.appsFlyerInstance.lastProductId)
        XCTAssertNil(self.appsFlyerInstance.lastPrice)
        XCTAssertNil(self.appsFlyerInstance.lastPurchaseCurrency)
    }
    
    func testValidateAndLogPurchaseMissingProductId() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase",
                                      "transaction_id": "txn123",
                                      "price": "9.99",
                                      "af_purchase_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertNil(self.appsFlyerInstance.lastProductId)
        XCTAssertNil(self.appsFlyerInstance.lastTransactionId)
        XCTAssertNil(self.appsFlyerInstance.lastPrice)
        XCTAssertNil(self.appsFlyerInstance.lastPurchaseCurrency)
    }
    
    func testValidateAndLogPurchaseMissingPrice() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase",
                                      "transaction_id": "txn123",
                                      "product_id": "premium_monthly",
                                      "af_purchase_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertNil(self.appsFlyerInstance.lastPrice)
        XCTAssertNil(self.appsFlyerInstance.lastTransactionId)
        XCTAssertNil(self.appsFlyerInstance.lastProductId)
        XCTAssertNil(self.appsFlyerInstance.lastPurchaseCurrency)
    }
    
    func testValidateAndLogPurchaseMissingCurrency() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase",
                                      "transaction_id": "txn123",
                                      "product_id": "premium_monthly",
                                      "price": "9.99"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertNil(self.appsFlyerInstance.lastPurchaseCurrency)
        XCTAssertNil(self.appsFlyerInstance.lastTransactionId)
        XCTAssertNil(self.appsFlyerInstance.lastProductId)
        XCTAssertNil(self.appsFlyerInstance.lastPrice)
    }
    
    func testValidateAndLogPurchaseMissingTransactionId() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase",
                                      "product_id": "premium_monthly",
                                      "price": "9.99",
                                      "af_purchase_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertNil(self.appsFlyerInstance.lastTransactionId)
        XCTAssertNil(self.appsFlyerInstance.lastProductId)
        XCTAssertNil(self.appsFlyerInstance.lastPrice)
        XCTAssertNil(self.appsFlyerInstance.lastPurchaseCurrency)
    }
    
    func testValidateAndLogPurchaseMissingMultipleRequiredParams() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertNil(self.appsFlyerInstance.lastProductId)
        XCTAssertNil(self.appsFlyerInstance.lastPrice)
        XCTAssertNil(self.appsFlyerInstance.lastPurchaseCurrency)
        XCTAssertNil(self.appsFlyerInstance.lastTransactionId)
        XCTAssertNil(self.appsFlyerInstance.lastPurchaseAdditionalParameters)
    }
    
    func testValidateAndLogPurchaseWithRequiredParametersOnly() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase",
                                      "product_id": "premium_monthly",
                                      "price": "9.99",
                                      "af_purchase_currency": "USD",
                                      "transaction_id": "txn123"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertEqual("premium_monthly", self.appsFlyerInstance.lastProductId)
        XCTAssertEqual("9.99", self.appsFlyerInstance.lastPrice)
        XCTAssertEqual("USD", self.appsFlyerInstance.lastPurchaseCurrency)
        XCTAssertEqual("txn123", self.appsFlyerInstance.lastTransactionId)
        // Optional parameters should be nil when not provided
        XCTAssertNil(self.appsFlyerInstance.lastPurchaseAdditionalParameters)
    }
    
    func testValidateAndLogPurchaseWithEmptyAdditionalParameters() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase",
                                      "product_id": "premium_yearly",
                                      "price": "99.99",
                                      "af_purchase_currency": "EUR",
                                      "transaction_id": "txn456",
                                      "purchase_additional_parameters": [:]]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertEqual("premium_yearly", self.appsFlyerInstance.lastProductId)
        XCTAssertEqual("99.99", self.appsFlyerInstance.lastPrice)
        XCTAssertEqual("EUR", self.appsFlyerInstance.lastPurchaseCurrency)
        XCTAssertEqual("txn456", self.appsFlyerInstance.lastTransactionId)
        
        // Empty additional parameters should be passed through
        XCTAssertNotNil(self.appsFlyerInstance.lastPurchaseAdditionalParameters)
        XCTAssertEqual(0, self.appsFlyerInstance.lastPurchaseAdditionalParameters?.count)
    }
    
    func testValidateAndLogPurchaseWithComplexAdditionalParameters() {
        let complexAdditionalParams: [String: Any] = [
            "user_id": "user123",
            "campaign": "black_friday_2024",
            "discount_percent": 25,
            "subscription_duration": 12,
            "is_trial": false,
            "metadata": ["platform": "ios", "version": "1.2.3"],
            "tags": ["premium", "annual"]
        ]
        
        let payload: [String: Any] = ["command_name": "validateandlogpurchase",
                                      "product_id": "premium_annual",
                                      "price": "119.99",
                                      "af_purchase_currency": "GBP",
                                      "transaction_id": "txn789",
                                      "purchase_additional_parameters": complexAdditionalParams]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.validateAndLogPurchaseCount)
        
        // Verify all required parameters
        XCTAssertEqual("premium_annual", self.appsFlyerInstance.lastProductId)
        XCTAssertEqual("119.99", self.appsFlyerInstance.lastPrice)
        XCTAssertEqual("GBP", self.appsFlyerInstance.lastPurchaseCurrency)
        XCTAssertEqual("txn789", self.appsFlyerInstance.lastTransactionId)
        
        // Verify complex additional parameters are preserved
        XCTAssertNotNil(self.appsFlyerInstance.lastPurchaseAdditionalParameters)
        guard let additionalParams = self.appsFlyerInstance.lastPurchaseAdditionalParameters else {
            XCTFail("Additional parameters should not be nil")
            return
        }
        
        XCTAssertEqual("user123", additionalParams["user_id"] as? String)
        XCTAssertEqual("black_friday_2024", additionalParams["campaign"] as? String)
        XCTAssertEqual(25, additionalParams["discount_percent"] as? Int)
        XCTAssertEqual(12, additionalParams["subscription_duration"] as? Int)
        XCTAssertEqual(false, additionalParams["is_trial"] as? Bool)
        
        let metadata = additionalParams["metadata"] as? [String: String]
        XCTAssertNotNil(metadata)
        XCTAssertEqual("ios", metadata?["platform"])
        XCTAssertEqual("1.2.3", metadata?["version"])
        
        let tags = additionalParams["tags"] as? [String]
        XCTAssertNotNil(tags)
        XCTAssertEqual(2, tags?.count)
        XCTAssertTrue(tags?.contains("premium") == true)
        XCTAssertTrue(tags?.contains("annual") == true)
    }
    
    func testSetSharingFilterForPartners() {
        let payload: [String: Any] = ["command_name": "setsharingfilterforpartners", 
                                      "sharing_filter_partners": ["partner1", "partner2"]]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setSharingFilterForPartnersCount)
        XCTAssertEqual(["partner1", "partner2"], self.appsFlyerInstance.lastPartners)
    }
    
    func testSetSharingFilterForPartnersWithNil() {
        let payload: [String: Any] = ["command_name": "setsharingfilterforpartners"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setSharingFilterForPartnersCount)
        XCTAssertNil(self.appsFlyerInstance.lastPartners)
    }
    
    func testAppendCustomData() {
        let additionalData: [String: Any] = ["key1": "value1", "key2": 123]
        let payload: [String: Any] = ["command_name": "appendcustomdata", "custom_data_to_append": additionalData]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.appendCustomDataCount)
        XCTAssertNotNil(self.appsFlyerInstance.lastAdditionalData)
        XCTAssertEqual("value1", self.appsFlyerInstance.lastAdditionalData?["key1"] as? String)
        XCTAssertEqual(123, self.appsFlyerInstance.lastAdditionalData?["key2"] as? Int)
    }
    
    func testAppendCustomDataNotRun() {
        let payload: [String: Any] = ["command_name": "appendcustomdata"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.appendCustomDataCount)
    }
    
    func testGetEventParametersWithEventKey() {
        // When "event" key is present, should return only event contents and ignore everything else
        let payload: [String: Any] = [
            "command_name": "customevent",
            "event": [
                "event_param1": "value1",
                "event_param2": 123,
                "user_id": "test_user"
            ],
            "app_id": "ignored_when_event_key_present",
            "method": "ignored_when_event_key_present",
            "debug": true,
            "settings": ["key": "value"]
        ]
        
        let result = appsFlyerCommand.getEventParameters(payload: payload)
        XCTAssertEqual(result["event_param1"] as? String, "value1")
        XCTAssertEqual(result["event_param2"] as? Int, 123)
        XCTAssertEqual(result["user_id"] as? String, "test_user")
        XCTAssertNil(result["app_id"])
        XCTAssertNil(result["method"])
        XCTAssertNil(result["debug"])
        XCTAssertNil(result["settings"])
    }
    
    func testGetEventParametersWithoutEventKeyFiltersAllConfigurationKeys() {
        // When no "event" key, should filter all configuration keys but pass event parameters
        var payload: [String: Any] = [
            "command_name": "customevent",
            "method": "system_value",
            // Valid event parameters that should pass through
            "user_id": "user123",
            "product_name": "Premium Plan",
            "af_content_id": "premium_001",
            "order_total": 99.99
        ]
        
        // Dynamically add ALL configuration keys that should be filtered out
        for configCase in AppsFlyerConstants.Configuration.allCases {
            payload[configCase.rawValue] = "should_be_filtered"
        }
        
        let result = appsFlyerCommand.getEventParameters(payload: payload)
        
        // Verify ALL configuration keys are filtered out
        for configCase in AppsFlyerConstants.Configuration.allCases {
            XCTAssertNil(result[configCase.rawValue], "Configuration key '\(configCase.rawValue)' should be filtered out")
        }
        
        // Verify system keys are filtered out
        XCTAssertNil(result["command_name"], "command_name should be filtered out")
        XCTAssertNil(result["method"], "method should be filtered out")
        
        // Verify valid event parameters pass through
        XCTAssertEqual(result["user_id"] as? String, "user123")
        XCTAssertEqual(result["product_name"] as? String, "Premium Plan")
        XCTAssertEqual(result["af_content_id"] as? String, "premium_001")
        XCTAssertEqual(result["order_total"] as? Double, 99.99)
        
        // Verify result contains only the expected event parameters
        XCTAssertEqual(result.count, 4, "Should contain exactly 4 event parameters")
        let expectedKeys = Set(["user_id", "product_name", "af_content_id", "order_total"])
        let actualKeys = Set(result.keys)
        XCTAssertEqual(actualKeys, expectedKeys, "Result should only contain event parameters")
    }
    
    func testGetEventNameWithStandardEvent() {
        let result = appsFlyerCommand.getEventName(command: "af_purchase")
        XCTAssertEqual(result, "af_purchase")
    }
    
    func testMultipleCommands() {
        let payload: [String: Any] = ["command_name": "setcurrencycode,setcustomerid",
                                      "af_currency": "EUR",
                                      "af_customer_user_id": "user456"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setCurrencyCodeCount)
        XCTAssertEqual(1, self.appsFlyerInstance.setCustomerIdCount)
        XCTAssertEqual("EUR", self.appsFlyerInstance.lastCurrency)
        XCTAssertEqual("user456", self.appsFlyerInstance.lastCustomerId)
    }
    
    func testLogAdRevenueWithoutMonetizationNetwork() {
        let payload: [String: Any] = ["command_name": "logadrevenue",
                                      "mediation_network": "ironsource",
                                      "revenue": 1.99,
                                      "af_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logAdRevenueCount)
    }
    
    func testLogAdRevenueWithoutMediationNetwork() {
        let payload: [String: Any] = ["command_name": "logadrevenue",
                                      "monetization_network": "TestNetwork",
                                      "revenue": 1.99,
                                      "af_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logAdRevenueCount)
    }
    
    func testLogAdRevenueWithoutRevenue() {
        let payload: [String: Any] = ["command_name": "logadrevenue",
                                      "monetization_network": "TestNetwork",
                                      "mediation_network": "ironsource",
                                      "af_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logAdRevenueCount)
    }
    
    func testLogAdRevenueWithoutCurrency() {
        let payload: [String: Any] = ["command_name": "logadrevenue",
                                      "monetization_network": "TestNetwork",
                                      "mediation_network": "ironsource",
                                      "revenue": 1.99]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logAdRevenueCount)
    }
    
    func testSetCurrentDeviceLanguage() {
        let payload: [String: Any] = ["command_name": "setcurrentdevicelanguage", "device_language": "es"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setCurrentDeviceLanguageCount)
        XCTAssertEqual("es", self.appsFlyerInstance.lastDeviceLanguage)
    }
    
    func testSetPartnerData() {
        let partnerInfo = ["key1": "value1", "key2": 123] as [String: Any]
        let payload: [String: Any] = ["command_name": "setpartnerdata", 
                                      "partner_id": "partner123",
                                      "partner_info": partnerInfo]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setPartnerDataCount)
        XCTAssertEqual("partner123", self.appsFlyerInstance.lastPartnerId)
        XCTAssertNotNil(self.appsFlyerInstance.lastPartnerInfo)
        XCTAssertEqual("value1", self.appsFlyerInstance.lastPartnerInfo?["key1"] as? String)
        XCTAssertEqual(123, self.appsFlyerInstance.lastPartnerInfo?["key2"] as? Int)
    }
    
    func testAppendParametersToDeeplinkURL() {
        let parameters = ["param1": "value1", "param2": "value2"]
        let payload: [String: Any] = ["command_name": "appendparameterstodeeplinkurl",
                                      "url_contains": "example.com",
                                      "url_parameters": parameters]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.appendParametersToDeeplinkURLCount)
        XCTAssertEqual("example.com", self.appsFlyerInstance.lastUrlContains)
        XCTAssertEqual(parameters, self.appsFlyerInstance.lastUrlParameters)
    }
    
    func testLogEventReceivesFilteredParameters() {
        // Integration test: verify that logEvent receives properly filtered parameters
        var payload: [String: Any] = [
            "command_name": "customevent",
            // Valid event parameters
            "event_param": "should_pass",
            "product_name": "Test Product",
            "user_id": "user123"
        ]
        
        // Add configuration keys that should be filtered out
        for configCase in AppsFlyerConstants.Configuration.allCases {
            payload[configCase.rawValue] = "should_be_filtered"
        }
        
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logEventCount)
        XCTAssertEqual("customevent", self.appsFlyerInstance.lastEventName)
        XCTAssertNotNil(self.appsFlyerInstance.lastEventValues)
        
        let eventValues = self.appsFlyerInstance.lastEventValues!
        
        // Verify event parameters passed through
        XCTAssertEqual(eventValues["event_param"] as? String, "should_pass")
        XCTAssertEqual(eventValues["product_name"] as? String, "Test Product")
        XCTAssertEqual(eventValues["user_id"] as? String, "user123")
        
        // Verify configuration keys were filtered out
        for configCase in AppsFlyerConstants.Configuration.allCases {
            XCTAssertNil(eventValues[configCase.rawValue], 
                        "Configuration key '\(configCase.rawValue)' should not reach logEvent")
        }
        XCTAssertNil(eventValues["command_name"], "command_name should not reach logEvent")
        
        // Verify we only have the expected event parameters
        XCTAssertEqual(eventValues.count, 3, "Should contain exactly 3 event parameters")
    }
}
