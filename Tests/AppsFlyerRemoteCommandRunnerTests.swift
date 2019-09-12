//
//  AppsFlyerRemoteCommandTests.swift
//  AppsFlyerRemoteCommandTests
//
//  Created by Christina Sund on 5/24/19.
//  Copyright © 2019 Christina. All rights reserved.
//

import XCTest
@testable import RemoteCommandModules
@testable import TealiumSwift

class AppsFlyerRemoteCommandRunnerTests: XCTestCase {

    var appsFlyerCommandRunner = MockAppsFlyerCommandRunner()
    var appsFlyerCommand: AppsFlyerCommand!
    var remoteCommand: TealiumRemoteCommand!
    
    override func setUp() {
        appsFlyerCommand = AppsFlyerCommand(appsFlyerCommandRunner: appsFlyerCommandRunner)
        remoteCommand = appsFlyerCommand.remoteCommand()
    }
    
    func createRemoteCommandResponse(commandId: String, payload: [String: Any]) -> TealiumRemoteCommandResponse? {
        let responseDescription = HttpTestHelpers.httpRequestDescription(commandId: commandId, config: [:], payload: payload)
        if let description = responseDescription {
            return TealiumRemoteCommandResponse(urlString: description)
        }
        XCTFail("Could not create Remote Command Response description from stubs provided")
        return nil
    }

    override func tearDown() { }

    func testInitWithoutConfig() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:) method run")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.initWithoutConfigCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testInitWithoutConfigNotRun() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:) method does not run")
        let payload: [String: Any] = ["command_name": "initialize"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.initWithoutConfigCount)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.initWithConfigCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testInitWithConfig() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:config:) method run")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test",
                                      "config": ["test": "test"]]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.initWithConfigCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testInitWithConfigNotRun() {
        let expect = expectation(description: "AppsFlyerRunner initialize(appId:appDevKey:config:) method does not run")
        let payload: [String: Any] = ["command_name": "initialize",
                                      "config": ["test": "test"]]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.initWithConfigCount)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.initWithConfigCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }

    func testTrackLaunch() {
        let expect = expectation(description: "AppsFlyerRunner trackLaunch() method run")
        let payload: [String: Any] = ["command_name": "launch"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.trackLaunchCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testTrackLaunchNotRun() {
        let expect = expectation(description: "AppsFlyerRunner trackLaunch() method does not run")
        let payload: [String: Any] = ["command_name": "tracklaunch"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.trackLaunchCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testTrackEvent() {
        let expect = expectation(description: "AppsFlyerRunner trackEvent(eventName:values:) method run")
        let payload: [String: Any] = ["command_name": "viewedcontent,rate,login"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(3, self.appsFlyerCommandRunner.trackEventCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testTrackEventNotRun() {
        let expect = expectation(description: "AppsFlyerRunner trackEvent(eventName:values:) method run")
        let payload: [String: Any] = ["command_name": "unrecognized,nope,test"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.trackEventCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testTrackLocation() {
        let expect = expectation(description: "AppsFlyerRunner trackLocation(longitude:latitude:) method run")
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33,
                                      "af_long": 122]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.trackLocationCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testTrackLocationNotRun() {
        let expect = expectation(description: "AppsFlyerRunner trackLocation(longitude:latitude:) method has not run")
        let payload: [String: Any] = ["command_name": "tracklocation"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.trackLocationCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testSetHost() {
        let expect = expectation(description: "AppsFlyerRunner setHost(_ host:with:) method run")
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host": "test.com",
                                      "host_prefix": "test"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.setHostCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testSetHostNotRun() {
        let expect = expectation(description: "AppsFlyerRunner setHost(_ host:with:) method has not run")
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host_prefix": "test"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.setHostCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testSetUserEmails() {
        let expect = expectation(description: "AppsFlyerRunner setUserEmails(emails:with:) method run")
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "customer_emails": ["blah", "blah2"],
                                      "email_hash_type": 1]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.setUserEmailsCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testSetUserEmailsWNotRun() {
        let expect = expectation(description: "AppsFlyerRunner setUserEmails(emails:with:) method has not run")
        let payload: [String: Any] = ["command_name": "setuseremails",
                                      "email_hash_type": 1]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.setUserEmailsCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testSetCurrencyCode() {
        let expect = expectation(description: "AppsFlyerRunner currencyCode(currency:) method run")
        let payload: [String: Any] = ["command_name": "setcurrencycode", "af_currency": "USD"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.setCurrencyCodeCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testSetCurrencyCodeNotRun() {
        let expect = expectation(description: "AppsFlyerRunner currencyCode(currency:) method has not run")
        let payload: [String: Any] = ["command_name": "setcurrencycode"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.setCurrencyCodeCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testSetCustomerId() {
        let expect = expectation(description: "AppsFlyerRunner customerId(id:) method run")
        let payload: [String: Any] = ["command_name": "setcustomerid", "af_customer_user_id": "ABC123"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.setCustomerIdCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testSetCustomerIdNotRun() {
        let expect = expectation(description: "AppsFlyerRunner customerId(id:) method has not run")
        let payload: [String: Any] = ["command_name": "setcustomerid"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.setCustomerIdCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testDisableTrackingCommandName() {
        let expect = expectation(description: "AppsFlyerRunner disableTracking(disable:) method run")
        let payload: [String: Any] = ["command_name": "disabletracking"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.disableTrackingCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testDisableTrackingNotRun() {
        let expect = expectation(description: "AppsFlyerRunner disableTracking(disable:) method has not run")
        let payload: [String: Any] = ["command_name": "disable"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.disableTrackingCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testDisableTrackingVariable() {
        let expect = expectation(description: "AppsFlyerRunner disableTracking(disable:) method run")
        let payload: [String: Any] = ["command_name": "disabletracking"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.disableTrackingCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testResolveDeepLinkURLs() {
        let expect = expectation(description: "AppsFlyerRunner resolveDeepLinkURLs(urls:) method run")
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls", "af_deep_link": ["app://test.com", "app://test?home=true"]]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(1, self.appsFlyerCommandRunner.resolveDeepLinkURLsCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    func testResolveDeepLinkURLsNotRun() {
        let expect = expectation(description: "AppsFlyerRunner resolveDeepLinkURLs(urls:) method has not run")
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls"]
        
        if let response = createRemoteCommandResponse(commandId: "appsflyer", payload: payload) {
            remoteCommand.remoteCommandCompletion(response)
            XCTAssertEqual(0, self.appsFlyerCommandRunner.resolveDeepLinkURLsCount)
        }
        
        expect.fulfill()
        wait(for: [expect], timeout: 5.0)
    }
    
    
}
