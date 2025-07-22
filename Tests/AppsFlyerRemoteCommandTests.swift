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
        let settings: [String: Any] = ["debug": true, "minTimeBetweenSessions": 60]
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test_app",
                                      "app_dev_key": "test_key",
                                      "settings": settings]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithSettingsCount)
        XCTAssertEqual(appsFlyerInstance.lastAppId, "test_app")
        XCTAssertEqual(appsFlyerInstance.lastAppDevKey, "test_key")
        XCTAssertNotNil(appsFlyerInstance.lastSettings)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["debug"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["minTimeBetweenSessions"] as? Int, 60)
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
}
