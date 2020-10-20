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


class AppsFlyerInstanceTests: XCTestCase {

    var appsFlyerInstance = MockAppsFlyerInstance()
    var appsFlyerCommand: AppsFlyerRemoteCommand!
    
    override func setUp() {
        appsFlyerCommand = AppsFlyerRemoteCommand(appsFlyerInstance: appsFlyerInstance)
    }

    override func tearDown() { }

    
    // MARK: Webview Remote Command Tests
    
    func testInitWithoutConfig() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:) method run")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.initWithoutConfigCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testInitWithoutConfigNotRun() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:) method does not run")
        let payload: [String: Any] = ["command_name": "initialize"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.initWithoutConfigCount)
            XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testInitWithConfig() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:settings:) method run")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test",
                                      "settings": ["test": "test"]]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.initWithConfigCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testInitWithConfigNotRun() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:settings:) method does not run")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "settings": ["test": "test"]]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
            XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackEvent() {
        let expect = expectation(description: "AppsFlyerRunner trackEvent(eventName:values:) method run")
        let payload: [String: Any] = ["command_name": "viewedcontent,rate,login"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(3, self.appsFlyerInstance.logEventCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackEventNotRun() {
        let expect = expectation(description: "AppsFlyerRunner trackEvent(eventName:values:) method run")
        let payload: [String: Any] = ["command_name": "unrecognized,nope,test"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.logEventCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackLocationWithLatLongInts() {
        let expect = expectation(description: "AppsFlyerRunner trackLocation(longitude:latitude:) method run")
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33,
                                      "af_long": 122]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackLocationWithLatLongDoubles() {
        let expect = expectation(description: "AppsFlyerRunner trackLocation(longitude:latitude:) method run")
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33.0,
                                      "af_long": -122.0]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackLocationNotRun() {
        let expect = expectation(description: "AppsFlyerRunner trackLocation(longitude:latitude:) method has not run")
        let payload: [String: Any] = ["command_name": "tracklocation"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.logLocationCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetHost() {
        let expect = expectation(description: "AppsFlyerRunner setHost(_ host:with:) method run")
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host": "test.com",
                                      "host_prefix": "test"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.setHostCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetHostNotRun() {
        let expect = expectation(description: "AppsFlyerRunner setHost(_ host:with:) method has not run")
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host_prefix": "test"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.setHostCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetUserEmails() {
        let expect = expectation(description: "AppsFlyerRunner setUserEmails(emails:with:) method run")
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": ["blah", "blah2"],
                                      "email_hash_type": 1]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetUserEmailsWNotRun() {
        let expect = expectation(description: "AppsFlyerRunner setUserEmails(emails:with:) method has not run")
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "email_hash_type": 1]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.setUserEmailsCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetCurrencyCode() {
        let expect = expectation(description: "AppsFlyerRunner currencyCode(currency:) method run")
        let payload: [String: Any] = ["command_name": "setcurrencycode", "af_currency": "USD"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.setCurrencyCodeCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetCurrencyCodeNotRun() {
        let expect = expectation(description: "AppsFlyerRunner currencyCode(currency:) method has not run")
        let payload: [String: Any] = ["command_name": "setcurrencycode"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.setCurrencyCodeCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetCustomerId() {
        let expect = expectation(description: "AppsFlyerRunner customerId(id:) method run")
        let payload: [String: Any] = ["command_name": "setcustomerid", "af_customer_user_id": "ABC123"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.setCustomerIdCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetCustomerIdNotRun() {
        let expect = expectation(description: "AppsFlyerRunner customerId(id:) method has not run")
        let payload: [String: Any] = ["command_name": "setcustomerid"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.setCustomerIdCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testDisableTrackingCommandName() {
        let expect = expectation(description: "AppsFlyerRunner disableTracking(disable:) method run")
        let payload: [String: Any] = ["command_name": "disabletracking"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testDisableTrackingNotRun() {
        let expect = expectation(description: "AppsFlyerRunner disableTracking(disable:) method has not run")
        let payload: [String: Any] = ["command_name": "disable"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.disableTrackingCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testDisableTrackingVariable() {
        let expect = expectation(description: "AppsFlyerRunner disableTracking(disable:) method run")
        let payload: [String: Any] = ["command_name": "disabletracking"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testResolveDeepLinkURLs() {
        let expect = expectation(description: "AppsFlyerRunner resolveDeepLinkURLs(urls:) method run")
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls", "af_deep_link": ["app://test.com", "app://test?home=true"]]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.resolveDeepLinkURLsCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testResolveDeepLinkURLsNotRun() {
        let expect = expectation(description: "AppsFlyerRunner resolveDeepLinkURLs(urls:) method has not run")
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .webview, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.resolveDeepLinkURLsCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    // MARK: JSON Remote Command Tests
    
    func testInitWithoutConfigJSON() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:) method run")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.initWithoutConfigCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testInitWithoutConfigNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:) method does not run")
        let payload: [String: Any] = ["command_name": "initialize"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.initWithoutConfigCount)
            XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testInitWithConfigJSON() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:settings:) method run")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test",
                                      "settings": ["test": "test"]]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.initWithConfigCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testInitWithConfigNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:settings:) method does not run")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "settings": ["test": "test"]]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
            XCTAssertEqual(0, self.appsFlyerInstance.initWithConfigCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackEventJSON() {
        let expect = expectation(description: "AppsFlyerRunner trackEvent(eventName:values:) method run")
        let payload: [String: Any] = ["command_name": "viewedcontent,rate,login"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(3, self.appsFlyerInstance.logEventCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackEventNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner trackEvent(eventName:values:) method does not run")
        let payload: [String: Any] = ["command_name": "unrecognized,nope,test"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.logEventCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackLocationWithLatLongIntsJSON() {
        let expect = expectation(description: "AppsFlyerRunner trackLocation(longitude:latitude:) method run")
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33,
                                      "af_long": 122]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackLocationWithLatLongDoublesJSON() {
        let expect = expectation(description: "AppsFlyerRunner trackLocation(longitude:latitude:) method run")
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33.0,
                                      "af_long": -122.0]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testTrackLocationNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner trackLocation(longitude:latitude:) method has not run")
        let payload: [String: Any] = ["command_name": "tracklocation"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.logLocationCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetHostJSON() {
        let expect = expectation(description: "AppsFlyerRunner setHost(_ host:with:) method run")
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host": "test.com",
                                      "host_prefix": "test"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.setHostCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetHostNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner setHost(_ host:with:) method has not run")
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host_prefix": "test"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.setHostCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetUserEmailsJSON() {
        let expect = expectation(description: "AppsFlyerRunner setUserEmails(emails:with:) method run")
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": ["blah", "blah2"],
                                      "email_hash_type": 1]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.setUserEmailsCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetUserEmailsWNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner setUserEmails(emails:with:) method has not run")
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "email_hash_type": 1]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.setUserEmailsCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetCurrencyCodeJSON() {
        let expect = expectation(description: "AppsFlyerRunner currencyCode(currency:) method run")
        let payload: [String: Any] = ["command_name": "setcurrencycode", "af_currency": "USD"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.setCurrencyCodeCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetCurrencyCodeNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner currencyCode(currency:) method has not run")
        let payload: [String: Any] = ["command_name": "setcurrencycode"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.setCurrencyCodeCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetCustomerIdJSON() {
        let expect = expectation(description: "AppsFlyerRunner customerId(id:) method run")
        let payload: [String: Any] = ["command_name": "setcustomerid", "af_customer_user_id": "ABC123"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.setCustomerIdCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testSetCustomerIdNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner customerId(id:) method has not run")
        let payload: [String: Any] = ["command_name": "setcustomerid"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.setCustomerIdCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testDisableTrackingCommandNameJSON() {
        let expect = expectation(description: "AppsFlyerRunner disableTracking(disable:) method run")
        let payload: [String: Any] = ["command_name": "disabletracking"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testDisableTrackingNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner disableTracking(disable:) method has not run")
        let payload: [String: Any] = ["command_name": "disable"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.disableTrackingCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testDisableTrackingVariableJSON() {
        let expect = expectation(description: "AppsFlyerRunner disableTracking(disable:) method run")
        let payload: [String: Any] = ["command_name": "disabletracking"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testResolveDeepLinkURLsJSON() {
        let expect = expectation(description: "AppsFlyerRunner resolveDeepLinkURLs(urls:) method run")
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls", "af_deep_link": ["app://test.com", "app://test?home=true"]]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(1, self.appsFlyerInstance.resolveDeepLinkURLsCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
    
    func testResolveDeepLinkURLsNotRunJSON() {
        let expect = expectation(description: "AppsFlyerRunner resolveDeepLinkURLs(urls:) method has not run")
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls"]
        
        if let response = HttpTestHelpers.createRemoteCommandResponse(type: .JSON, commandId: "appsflyer", payload: payload) {
            appsFlyerCommand.completion(response)
            expect.fulfill()
            XCTAssertEqual(0, self.appsFlyerInstance.resolveDeepLinkURLsCount)
        }
        
        wait(for: [expect], timeout: 2.0)
    }
}
