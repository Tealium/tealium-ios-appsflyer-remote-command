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

    
    // MARK: Webview Remote Command Tests
    
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
    }
    
    func testInitWithConfigNotRun() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "settings": ["test": "test"]]
        
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
        XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
    }
    
    func testInitWithFlatConfig() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test_app",
                                      "app_dev_key": "test_key",
                                      "debug": true,
                                      "disable_collect_asa": true,
                                      "anonymize_user": false]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithConfigCount)
        XCTAssertEqual("test_app", self.appsFlyerInstance.lastAppId)
        XCTAssertEqual("test_key", self.appsFlyerInstance.lastAppDevKey)
        XCTAssertNotNil(self.appsFlyerInstance.lastSettings)
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
                                      "email_hash_type": 1]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
    }
    
    func testSetUserEmailsWNotRun() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "email_hash_type": 1]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setUserEmailsCount)
    }
    
    func testCurrencyCode() {
        let payload: [String: Any] = ["command_name": "currencycode", "af_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.currencyCodeCount)
    }
    
    func testCurrencyCodeNotRun() {
        let payload: [String: Any] = ["command_name": "currencycode"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.currencyCodeCount)
    }
    
    func testCustomerId() {
        let payload: [String: Any] = ["command_name": "customerid", "af_customer_user_id": "ABC123"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.customerIdCount)
    }
    
    func testCustomerIdNotRun() {
        let payload: [String: Any] = ["command_name": "customerid"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.customerIdCount)
    }
    
    func testResolveDeepLinkURLs() {
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls", "af_deep_link": ["app://test.com", "app://test?home=true"]]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.resolveDeepLinkURLsCount)
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

    // MARK: - New Tests for Missing Commands
    
    func testStopTracking() {
        let payload: [String: Any] = ["command_name": "stoptracking", "stop_tracking": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.stopTrackingCount)
        XCTAssertEqual(true, self.appsFlyerInstance.lastStop)
    }
    
    func testStopTrackingNotRun() {
        let payload: [String: Any] = ["command_name": "stoptracking"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.stopTrackingCount)
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
        XCTAssertEqual("ironsource", self.appsFlyerInstance.lastMediationNetwork)
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
        XCTAssertEqual(1, self.appsFlyerInstance.setDMAConsentCount)
        XCTAssertNil(self.appsFlyerInstance.lastGdprApplies)
        XCTAssertNil(self.appsFlyerInstance.lastConsentForDataUsage)
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
                                      "push_deep_link_path": ["path1", "path2"]]
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
                                      "purchase_type": "subscription",
                                      "transaction_id": "txn123",
                                      "product_id": "premium_monthly",
                                      "price": "9.99",
                                      "currency": "USD",
                                      "additional_parameters": ["user_id": "123"]]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertEqual("subscription", self.appsFlyerInstance.lastPurchaseType)
        XCTAssertEqual("txn123", self.appsFlyerInstance.lastTransactionId)
        XCTAssertEqual("premium_monthly", self.appsFlyerInstance.lastProductId)
        XCTAssertEqual("9.99", self.appsFlyerInstance.lastPrice)
        XCTAssertEqual("USD", self.appsFlyerInstance.lastPurchaseCurrency)
    }
    
    func testValidateAndLogPurchaseWithNilValues() {
        let payload: [String: Any] = ["command_name": "validateandlogpurchase"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.validateAndLogPurchaseCount)
        XCTAssertNil(self.appsFlyerInstance.lastPurchaseType)
        XCTAssertNil(self.appsFlyerInstance.lastTransactionId)
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
    }
    
    func testAppendCustomDataNotRun() {
        let payload: [String: Any] = ["command_name": "appendcustomdata"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.appendCustomDataCount)
    }
    
    // MARK: - Event Parameter Tests
    
    func testGetEventParametersWithEventKey() {
        let eventParams: [String: Any] = ["event_param1": "value1", "event_param2": 123]
        let payload: [String: Any] = ["command_name": "customevent",
                                      "event": eventParams,
                                      "other_param": "should_be_filtered"]
        
        let result = appsFlyerCommand.getEventParameters(payload: payload)
        XCTAssertEqual(result["event_param1"] as? String, "value1")
        XCTAssertEqual(result["event_param2"] as? Int, 123)
        XCTAssertNil(result["other_param"])
    }
    
    func testGetEventParametersWithoutEventKey() {
        let payload: [String: Any] = ["command_name": "customevent",
                                      "param1": "value1",
                                      "param2": 123,
                                      "app_id": "should_be_filtered",
                                      "method": "should_be_filtered"]
        
        let result = appsFlyerCommand.getEventParameters(payload: payload)
        XCTAssertEqual(result["param1"] as? String, "value1")
        XCTAssertEqual(result["param2"] as? Int, 123)
        XCTAssertNil(result["app_id"])
        XCTAssertNil(result["method"])
        XCTAssertNil(result["command_name"])
    }
    
    func testGetEventNameWithStandardEvent() {
        let result = appsFlyerCommand.getEventName(command: "af_purchase")
        XCTAssertEqual(result, "af_purchase")
    }
    
    func testGetEventNameWithCustomEvent() {
        let result = appsFlyerCommand.getEventName(command: "custom_event_name")
        XCTAssertEqual(result, "custom_event_name")
    }
    
    // MARK: - Multiple Commands Test
    
    func testMultipleCommands() {
        let payload: [String: Any] = ["command_name": "currencycode,customerid",
                                      "af_currency": "EUR",
                                      "af_customer_user_id": "user456"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.currencyCodeCount)
        XCTAssertEqual(1, self.appsFlyerInstance.customerIdCount)
        XCTAssertEqual("EUR", self.appsFlyerInstance.lastCurrency)
        XCTAssertEqual("user456", self.appsFlyerInstance.lastCustomerId)
    }
    
    // MARK: - Configuration Parameter Tests
    
    func testInitWithAllConfigParameters() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test_app",
                                      "app_dev_key": "test_key",
                                      "debug": true,
                                      "disable_collect_asa": false,
                                      "anonymize_user": true,
                                      "time_between_sessions": 30, 
                                      "collect_device_name": false,
                                      "disable_ad_tracking": true,
                                      "disable_apple_ad_tracking": false,
                                      "use_uninstall_sandbox": true,
                                      "enable_tcf_data_collection": true,
                                      "disable_advertising_identifier": true,
                                      "disable_idfv_collection": false,
                                      "custom_data": ["custom_key": "custom_value"]]
        
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithConfigCount)
        XCTAssertNotNil(self.appsFlyerInstance.lastSettings)
        
        let settings = self.appsFlyerInstance.lastSettings!
        XCTAssertEqual(settings["debug"] as? Bool, true)
        XCTAssertEqual(settings["disable_collect_asa"] as? Bool, false)
        XCTAssertEqual(settings["anonymize_user"] as? Bool, true)
        XCTAssertEqual(settings["time_between_sessions"] as? Int, 30) 
        XCTAssertEqual(settings["collect_device_name"] as? Bool, false)
        XCTAssertEqual(settings["disable_ad_tracking"] as? Bool, true)
        XCTAssertEqual(settings["disable_apple_ad_tracking"] as? Bool, false)
        XCTAssertEqual(settings["use_uninstall_sandbox"] as? Bool, true)
        XCTAssertEqual(settings["enable_tcf_data_collection"] as? Bool, true)
        XCTAssertEqual(settings["disable_advertising_identifier"] as? Bool, true)
        XCTAssertEqual(settings["disable_idfv_collection"] as? Bool, false)
        XCTAssertNotNil(settings["custom_data"])
    }
    
    // MARK: - Missing Tests
    
    func testSetUserEmailsWithSingleString() {
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": "test@example.com",
                                      "email_hash_type": 1]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
        XCTAssertEqual(["test@example.com"], self.appsFlyerInstance.lastEmails)
    }
    
    // MARK: - LogAdRevenue Error Cases
    
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
    
    // MARK: - Case Insensitive Command Tests
    
    func testCaseInsensitiveCommands() {
        let payloadUpper: [String: Any] = ["command_name": "INITIALIZE",
                                           "app_id": "test",
                                           "app_dev_key": "test"]
        appsFlyerCommand.processRemoteCommand(with: payloadUpper)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithoutConfigCount)
        
        let payloadMixed: [String: Any] = ["command_name": "CurrencyCode", "af_currency": "GBP"]
        appsFlyerCommand.processRemoteCommand(with: payloadMixed)
        XCTAssertEqual(2, self.appsFlyerInstance.currencyCodeCount)
    }
    
    // MARK: - Edge Cases
    
    func testCommandNameWithSpaces() {
        let payload: [String: Any] = ["command_name": " initialize , currencycode ",
                                      "app_id": "test",
                                      "app_dev_key": "test",
                                      "af_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithoutConfigCount)
        XCTAssertEqual(1, self.appsFlyerInstance.currencyCodeCount)
    }
    
    func testEmptyCommandName() {
        let payload: [String: Any] = ["command_name": ""]
        appsFlyerCommand.processRemoteCommand(with: payload)
        // Should handle empty command gracefully
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
        // Should return early without processing
        XCTAssertEqual(0, self.appsFlyerInstance.initWithoutConfigCount)
    }
}
