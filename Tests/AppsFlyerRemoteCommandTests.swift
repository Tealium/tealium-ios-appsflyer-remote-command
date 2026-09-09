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
        appsFlyerCommand = AppsFlyerRemoteCommand(appsFlyerInstance: appsFlyerInstance, logLevel: .silent)
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

    func testSetUserEmail() {
        let payload: [String: Any] = [
            "command_name": "setuseremail",
            "email": "test@example.com"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserEmailCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastEmail, "test@example.com")
    }

    func testSetUserEmailNotRunWithUnsupportedEmailType() {
        let payload: [String: Any] = [
            "command_name": "setuseremail",
            "email": 42
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserEmailCount, 0)
        XCTAssertNil(appsFlyerInstance.lastEmail)
    }

    func testSetUserEmailNotRunWithMissingParameter() {
        let payload: [String: Any] = ["command_name": "setuseremail"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserEmailCount, 0)
        XCTAssertNil(appsFlyerInstance.lastEmail)
    }

    func testSetUserFirstName() {
        let payload: [String: Any] = ["command_name": "setuserfirstname", "first_name": "Ada"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserFirstNameCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastFirstName, "Ada")
    }

    func testSetUserFirstNameNotRunWithMissingParameter() {
        appsFlyerCommand.processRemoteCommand(with: ["command_name": "setuserfirstname"])
        XCTAssertEqual(appsFlyerInstance.setUserFirstNameCount, 0)
    }

    func testSetUserLastName() {
        let payload: [String: Any] = ["command_name": "setuserlastname", "last_name": "Lovelace"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserLastNameCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastLastName, "Lovelace")
    }

    func testSetUserLastNameNotRunWithMissingParameter() {
        appsFlyerCommand.processRemoteCommand(with: ["command_name": "setuserlastname"])
        XCTAssertEqual(appsFlyerInstance.setUserLastNameCount, 0)
    }

    func testSetUserFbLoginId() {
        let payload: [String: Any] = ["command_name": "setuserfbloginid", "fb_login_id": 1234567890123]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserFbLoginIdCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastFbLoginId, 1234567890123)
    }

    /// `0` is the SDK's unset sentinel, so it must reach the SDK rather than be rejected.
    func testSetUserFbLoginIdAcceptsZeroSentinel() {
        let payload: [String: Any] = ["command_name": "setuserfbloginid", "fb_login_id": 0]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserFbLoginIdCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastFbLoginId, 0)
    }

    /// Webview data layer values arrive as strings even for numeric UDO variables, so a mapped
    /// `fb_login_id` has to be accepted in that form too.
    func testSetUserFbLoginIdAcceptsNumericString() {
        let payload: [String: Any] = ["command_name": "setuserfbloginid", "fb_login_id": "1234567890123"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserFbLoginIdCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastFbLoginId, 1234567890123)
    }

    func testSetUserFbLoginIdNotRunWithUnsupportedType() {
        let payload: [String: Any] = ["command_name": "setuserfbloginid", "fb_login_id": "not-a-number"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserFbLoginIdCount, 0)
        XCTAssertNil(appsFlyerInstance.lastFbLoginId)
    }

    func testClearUserPii() {
        appsFlyerCommand.processRemoteCommand(with: ["command_name": "clearuserpii"])
        XCTAssertEqual(appsFlyerInstance.clearUserPiiCount, 1)
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

        // Verify that system variables (method, command_name, debug, and all Configuration keys) are filtered out.
        let lastValues = appsFlyerInstance.lastEventValues
        XCTAssertEqual(lastValues?["user_id"] as? String, "123")
        XCTAssertEqual(lastValues?["product_name"] as? String, "iPhone")
        XCTAssertNil(lastValues?["debug"])
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

    /// `AppsFlyerInstance.initialize` starts the first session itself, so the command must not
    /// issue a `start` of its own — a second one would be a separate session request.
    func testInitializeDoesNotIssueSeparateStart() {
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test_id",
                                      "app_dev_key": "test_key"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.initWithoutSettingsCount, 1)
        XCTAssertEqual(appsFlyerInstance.startCount, 0)
    }

    func testStartCommand() {
        let payload: [String: Any] = ["command_name": "start"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.startCount, 1)
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
            "deep_link_timeout": 3000,
            "one_link_custom_domains": oneLinkDomains,
            "facebook_deferred_app_link": "https://facebook.com/deferred",
            "push_notification_deep_link_path": ["af_push_link", "custom_link"],
            "deep_link_parameters": deepLinkParameters,
            "enable_facebook_deferred_applinks": true
        ]
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test_app",
                                      "app_dev_key": "test_key",
                                      "settings": settings]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithSettingsCount)
        XCTAssertEqual(appsFlyerInstance.lastAppId, "test_app")
        XCTAssertEqual(appsFlyerInstance.lastAppDevKey, "test_key")

        // Test all settings are passed through correctly
        XCTAssertEqual(appsFlyerInstance.lastSettings?["debug"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["disable_ad_tracking"] as? Bool, false)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["disable_apple_ads_attribution"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["disable_apple_ad_tracking"] as? Bool, false)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["time_between_sessions"] as? Int, 60)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["anonymize_user"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["collect_device_name"] as? Bool, false)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["enable_tcf_data_collection"] as? Bool, true)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["deep_link_timeout"] as? Int, 3000)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["facebook_deferred_app_link"] as? String, "https://facebook.com/deferred")

        // Test custom_data dictionary
        let receivedCustomData = appsFlyerInstance.lastSettings?["custom_data"] as? [String: Any]
        XCTAssertEqual(receivedCustomData?["custom_key"] as? String, "custom_value")
        XCTAssertEqual(receivedCustomData?["user_level"] as? Int, 5)

        // Test one_link_custom_domains array
        let receivedDomains = appsFlyerInstance.lastSettings?["one_link_custom_domains"] as? [String]
        XCTAssertEqual(receivedDomains, oneLinkDomains)

        // Test new settings
        let receivedPushPath = appsFlyerInstance.lastSettings?["push_notification_deep_link_path"] as? [String]
        XCTAssertEqual(receivedPushPath, ["af_push_link", "custom_link"])

        let receivedDeepLinkParams = appsFlyerInstance.lastSettings?["deep_link_parameters"] as? [[String: Any]]
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
    }

    func testInitWithDisableIDFVCollection() {
        let settings: [String: Any] = [
            "disable_idfv_collection": true
        ]
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test",
                                      "settings": settings]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithSettingsCount)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["disable_idfv_collection"] as? Bool, true)
    }

    func testInitWithDisableAdvertisingIdentifiersAlias() {
        // Android cross-platform alias: `disable_advertising_identifiers` must be accepted alongside the iOS key.
        let settings: [String: Any] = [
            "disable_advertising_identifiers": true
        ]
        let payload: [String: Any] = ["command_name": "initialize",
                                      "app_id": "test",
                                      "app_dev_key": "test",
                                      "settings": settings]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.initWithSettingsCount)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["disable_advertising_identifiers"] as? Bool, true)
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
                                      "af_lat": NSNumber(value: 33),
                                      "af_long": NSNumber(value: 122)]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
        XCTAssertEqual(appsFlyerInstance.lastLatitude, 33.0)
        XCTAssertEqual(appsFlyerInstance.lastLongitude, 122.0)
    }

    /// Native Swift `Int` does not bridge to `Double` via `as?`, unlike the `NSNumber` a JSON
    /// payload carries — so this covers a payload built in code rather than parsed.
    func testTrackLocationWithNativeSwiftInts() {
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33,
                                      "af_long": -122]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.logLocationCount)
        XCTAssertEqual(appsFlyerInstance.lastLatitude, 33.0)
        XCTAssertEqual(appsFlyerInstance.lastLongitude, -122.0)
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

    func testTrackLocationNotRunWithMissingLongitude() {
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": 33.0]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logLocationCount)
        XCTAssertNil(appsFlyerInstance.lastLatitude)
        XCTAssertNil(appsFlyerInstance.lastLongitude)
    }

    func testTrackLocationNotRunWithMissingLatitude() {
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_long": 122.0]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.logLocationCount)
        XCTAssertNil(appsFlyerInstance.lastLatitude)
        XCTAssertNil(appsFlyerInstance.lastLongitude)
    }

    func testTrackLocationNotRunWithInvalidType() {
        let payload: [String: Any] = ["command_name": "tracklocation",
                                      "af_lat": "not-a-number",
                                      "af_long": "also-invalid"]
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

    func testSetHostNotRunWithoutHostPrefix() {
        let payload: [String: Any] = ["command_name": "sethost",
                                      "host": "test.com"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.setHostCount)
        XCTAssertNil(appsFlyerInstance.lastHost)
        XCTAssertNil(appsFlyerInstance.lastPrefix)
    }

    /// Without a mapped `event` object the payload becomes the event values, minus command plumbing
    /// only. A mapping like `setuseremail,…,completeregistration` therefore feeds the identifier
    /// parameters to both the `setuser…` commands, which hash them on-device, and the event itself —
    /// the tag mapped them, so passing them on is the integrator's call, not this library's to veto.
    func testIdentifierParametersReachBothCommandsAndEventValues() {
        let payload: [String: Any] = [
            "command_name": "setuseremail,setuserfirstname,setuserlastname,completeregistration",
            "email": "user@example.com",
            "first_name": "Ada",
            "last_name": "Lovelace",
            "product_name": "iPhone"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.logEventCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastEventName, "af_complete_registration")
        let values = appsFlyerInstance.lastEventValues
        XCTAssertEqual(values?["product_name"] as? String, "iPhone")
        XCTAssertEqual(values?["email"] as? String, "user@example.com")
        XCTAssertEqual(values?["first_name"] as? String, "Ada")
        // The values also reached the hashing commands themselves.
        XCTAssertEqual(appsFlyerInstance.lastEmail, "user@example.com")
        XCTAssertEqual(appsFlyerInstance.lastFirstName, "Ada")
        XCTAssertEqual(appsFlyerInstance.lastLastName, "Lovelace")
    }

    /// A mapped `event` object is the integrator's explicit list of event values, so it replaces the
    /// payload wholesale rather than being merged with it — a key present in both wins from `event`,
    /// and a payload key absent from `event` is not added.
    func testNestedEventObjectIsPassedThroughVerbatim() {
        let payload: [String: Any] = [
            "command_name": "customevent",
            "email": "payload@example.com",
            "af_currency": "USD",
            "event": [
                "email": "kept@example.com",
                "product_name": "iPhone"
            ]
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.logEventCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastEventValues?.count, 2)
        let values = appsFlyerInstance.lastEventValues
        XCTAssertEqual(values?["product_name"] as? String, "iPhone")
        XCTAssertEqual(values?["email"] as? String, "kept@example.com")
        XCTAssertNil(values?["af_currency"])
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

    func testDisableTrackingNotRunWithMissingParameter() {
        let payload: [String: Any] = ["command_name": "disabletracking"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, self.appsFlyerInstance.disableTrackingCount)
        XCTAssertNil(appsFlyerInstance.lastDisableTracking)
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
        appsFlyerCommand = AppsFlyerRemoteCommand(logLevel: .silent)
        appsFlyerCommand.onReady { _ in
            onReadyCalled.fulfill()
        }
        appsFlyerCommand.processRemoteCommand(with: payload)
        waitForExpectations(timeout: 1.0)
    }

    func testSetPhoneNumber() {
        let payload: [String: Any] = [
            "command_name": "setphonenumber",
            "country_code": "48",
            "phone_number": "123456789"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserPhoneCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastCountryCode, "48")
        XCTAssertEqual(appsFlyerInstance.lastPhoneNumber, "123456789")
    }

    /// SDK 7 needs the country code separately, so a tag mapping only `phone_number` must fail
    /// rather than send a number the SDK cannot normalise.
    func testSetPhoneNumberNotRunWithoutCountryCode() {
        let payload: [String: Any] = [
            "command_name": "setphonenumber",
            "phone_number": "123456789"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setUserPhoneCount, 0)
        XCTAssertNil(appsFlyerInstance.lastPhoneNumber)
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
        // Without this, a nil settings dictionary would satisfy the assertion below.
        XCTAssertNotNil(appsFlyerInstance.lastSettings)
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

    func testSetConsentDataRunsWithOnlyGDPRFlag() {
        let payload: [String: Any] = [
            "command_name": "setconsentdata",
            "is_user_subject_to_gdpr": false
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.setConsentDataCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastIsUserSubjectToGDPR, false)
        // AppsFlyerConsent exposes these two as non-optional BOOL, so a nil
        // NSNumber? passed at init surfaces as `false` when read back.
        XCTAssertEqual(appsFlyerInstance.lastHasConsentForDataUsage, false)
        XCTAssertEqual(appsFlyerInstance.lastHasConsentForAdsPersonalization, false)
        XCTAssertNil(appsFlyerInstance.lastHasConsentForAdStorage)
    }

    func testSetConsentDataNotRunWithMissingGDPRFlag() {
        let payload: [String: Any] = [
            "command_name": "setconsentdata",
            "has_consent_for_data_usage": true,
            "has_consent_for_ads_personalization": true,
            "has_consent_for_ad_storage": true
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.setConsentDataCount, 0)
        XCTAssertNil(appsFlyerInstance.lastIsUserSubjectToGDPR)
    }

    func testSetConsentDataNotRunWithNonBoolGDPRFlag() {
        let payload: [String: Any] = [
            "command_name": "setconsentdata",
            "is_user_subject_to_gdpr": "true",
            "has_consent_for_data_usage": true
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.setConsentDataCount, 0)
    }

    func testSetConsentDataForwardsDetailsWhenGDPRDoesNotApply() {
        // AppsFlyer expects the details to be unmapped here, so the command warns — but it still
        // forwards what the tag mapped rather than dropping values silently.
        let payload: [String: Any] = [
            "command_name": "setconsentdata",
            "is_user_subject_to_gdpr": false,
            "has_consent_for_data_usage": true,
            "has_consent_for_ad_storage": true
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.setConsentDataCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastIsUserSubjectToGDPR, false)
        XCTAssertEqual(appsFlyerInstance.lastHasConsentForDataUsage, true)
        XCTAssertEqual(appsFlyerInstance.lastHasConsentForAdStorage, true)
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

    func testHandleOpenWithSourceApplicationAndAnnotation() {
        let payload: [String: Any] = [
            "command_name": "handleopen",
            "url": "app://product/123",
            "source_application": "com.example.source",
            "annotation": "test_annotation_value"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.handleOpenWithSourceAppCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastHandleOpenUrl?.absoluteString, "app://product/123")
        XCTAssertEqual(appsFlyerInstance.lastHandleOpenSourceApplication, "com.example.source")
        XCTAssertEqual(appsFlyerInstance.lastHandleOpenAnnotation as? String, "test_annotation_value")
    }

    func testHandleOpenWithoutSourceApplicationAndAnnotation() {
        let payload: [String: Any] = [
            "command_name": "handleopen",
            "url": "app://category/electronics"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.handleOpenWithSourceAppCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastHandleOpenUrl?.absoluteString, "app://category/electronics")
        XCTAssertNil(appsFlyerInstance.lastHandleOpenSourceApplication)
        XCTAssertNil(appsFlyerInstance.lastHandleOpenAnnotation)
    }

    func testHandleOpenNotRunWithInvalidURL() {
        let payload: [String: Any] = [
            "command_name": "handleopen",
            "url": "invalid-url-string"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.handleOpenWithSourceAppCount, 0)
        XCTAssertNil(appsFlyerInstance.lastHandleOpenUrl)
    }

    /// Covers the `URL(string:)` returning nil branch, as opposed to the missing-scheme branch in
    /// `testHandleOpenNotRunWithInvalidURL`. Foundation percent-encodes a space in the path, so
    /// only a space in the host — or an empty string — actually fails to parse.
    func testHandleOpenNotRunWhenURLInitReturnsNil() {
        for urlString in ["http://exa mple.com", ""] {
            appsFlyerInstance = MockAppsFlyerInstance()
            appsFlyerCommand = AppsFlyerRemoteCommand(appsFlyerInstance: appsFlyerInstance, logLevel: .silent)

            appsFlyerCommand.processRemoteCommand(with: [
                "command_name": "handleopen",
                "url": urlString
            ])

            XCTAssertEqual(appsFlyerInstance.handleOpenWithSourceAppCount, 0, "Failed for \(urlString.debugDescription)")
            XCTAssertNil(appsFlyerInstance.lastHandleOpenUrl, "Failed for \(urlString.debugDescription)")
        }
    }

    func testHandleOpenNotRunWithoutURL() {
        let payload: [String: Any] = [
            "command_name": "handleopen",
            "source_application": "com.example.app"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)

        XCTAssertEqual(appsFlyerInstance.handleOpenWithSourceAppCount, 0)
        XCTAssertNil(appsFlyerInstance.lastHandleOpenUrl)
    }

    func testHandleOpenSupportsAllURLSchemes() {
        let testURLs = [
            "myapp://category/electronics",
            "https://example.com/deep/link",
            "http://example.com/link",
            "ftp://files.example.com/document",
            "mailto:support@example.com"
        ]

        for (index, testURL) in testURLs.enumerated() {
            appsFlyerInstance = MockAppsFlyerInstance()
            appsFlyerCommand = AppsFlyerRemoteCommand(appsFlyerInstance: appsFlyerInstance, logLevel: .silent)

            let payload: [String: Any] = [
                "command_name": "handleopen",
                "url": testURL
            ]
            appsFlyerCommand.processRemoteCommand(with: payload)

            XCTAssertEqual(appsFlyerInstance.handleOpenWithSourceAppCount, 1, "Failed for URL \(index): \(testURL)")
            XCTAssertEqual(appsFlyerInstance.lastHandleOpenUrl?.absoluteString, testURL, "Failed for URL \(index): \(testURL)")
        }
    }

    func testStopTrackingCommandAlias() {
        let payload: [String: Any] = ["command_name": "stoptracking", "stop_tracking": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.disableTrackingCount)
        XCTAssertEqual(appsFlyerInstance.lastDisableTracking, true)
    }

    func testAnonymizeUserTrue() {
        let payload: [String: Any] = ["command_name": "anonymizeuser", "anonymize_user": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, appsFlyerInstance.anonymizeUserCount)
        XCTAssertEqual(appsFlyerInstance.lastAnonymizeUser, true)
    }

    func testAnonymizeUserFalse() {
        let payload: [String: Any] = ["command_name": "anonymizeuser", "anonymize_user": false]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, appsFlyerInstance.anonymizeUserCount)
        XCTAssertEqual(appsFlyerInstance.lastAnonymizeUser, false)
    }

    func testAnonymizeUserNotRun() {
        let payload: [String: Any] = ["command_name": "anonymizeuser"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, appsFlyerInstance.anonymizeUserCount)
        XCTAssertNil(appsFlyerInstance.lastAnonymizeUser)
    }

    func testDisableDeviceTrackingAlias() {
        let payload: [String: Any] = ["command_name": "disabledevicetracking", "anonymize_user": true]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, appsFlyerInstance.anonymizeUserCount)
        XCTAssertEqual(appsFlyerInstance.lastAnonymizeUser, true)
    }

    func testSetPhoneNumberNotRun() {
        let payload: [String: Any] = ["command_name": "setphonenumber"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, appsFlyerInstance.setUserPhoneCount)
        XCTAssertNil(appsFlyerInstance.lastPhoneNumber)
    }

    func testResolveDeepLinkURLsWithLegacyKey() {
        let urls = ["click.example.com", "email.example.com"]
        let payload: [String: Any] = ["command_name": "resolvedeeplinkurls", "resolve_deep_links": urls]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, self.appsFlyerInstance.resolveDeepLinkURLsCount)
        XCTAssertEqual(appsFlyerInstance.lastUrls, urls)
    }

    func testSetCurrentDeviceLanguage() {
        let payload: [String: Any] = ["command_name": "setcurrentdevicelanguage", "device_language": "en-US"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, appsFlyerInstance.setCurrentDeviceLanguageCount)
        XCTAssertEqual(appsFlyerInstance.lastDeviceLanguage, "en-US")
    }

    func testSetCurrentDeviceLanguageNotRun() {
        let payload: [String: Any] = ["command_name": "setcurrentdevicelanguage"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, appsFlyerInstance.setCurrentDeviceLanguageCount)
        XCTAssertNil(appsFlyerInstance.lastDeviceLanguage)
    }

    func testSetAppInviteOneLink() {
        let payload: [String: Any] = ["command_name": "setappinviteonelink", "app_invite_onelink_id": "XY1A"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(1, appsFlyerInstance.setAppInviteOneLinkCount)
        XCTAssertEqual(appsFlyerInstance.lastOneLinkId, "XY1A")
    }

    func testSetAppInviteOneLinkNotRun() {
        let payload: [String: Any] = ["command_name": "setappinviteonelink"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(0, appsFlyerInstance.setAppInviteOneLinkCount)
        XCTAssertNil(appsFlyerInstance.lastOneLinkId)
    }

    /// 3.0.0 exposed `AppsFlyerInstance()` and integrators passed it in like this, so the
    /// parameterless initializer has to keep compiling.
    func testParameterlessInstanceInitRemainsAvailable() {
        let command = AppsFlyerRemoteCommand(appsFlyerInstance: AppsFlyerInstance(), logLevel: .silent)
        XCTAssertEqual(command.version, AppsFlyerConstants.version)
    }

    // MARK: - completion closure

    /// Every other test calls `processRemoteCommand` directly, which skips the closure the
    /// RemoteCommands module actually invokes — including its nil-payload guard.
    func testCompletionForwardsPayload() {
        let response = MockRemoteCommandResponse(payload: [
            "command_name": "setcurrencycode",
            "af_currency": "EUR"
        ])
        appsFlyerCommand.completion(response)
        XCTAssertEqual(appsFlyerInstance.setCurrencyCodeCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastCurrency, "EUR")
    }

    func testCompletionIgnoresMissingPayload() {
        appsFlyerCommand.completion(MockRemoteCommandResponse(payload: nil))
        XCTAssertEqual(appsFlyerInstance.setCurrencyCodeCount, 0)
        XCTAssertEqual(appsFlyerInstance.logEventCount, 0)
    }

    /// Whitespace around list items must be stripped before the token is used, including for an
    /// unresolved command that becomes an event name — otherwise the name keeps the space and no
    /// longer matches `eventsMap`.
    func testCommandListToleratesWhitespace() {
        let payload: [String: Any] = ["command_name": " setcurrencycode , viewedcontent ",
                                      "af_currency": "USD"]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setCurrencyCodeCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastCurrency, "USD")
        XCTAssertEqual(appsFlyerInstance.lastEventName, "af_content_view")
    }

    func testVersionMatchesConstant() {
        XCTAssertEqual(appsFlyerCommand.version, AppsFlyerConstants.version)
    }

    func testGetEventParametersUsesNestedEventKey() {
        // When `event` dict is present, payload-level keys must be ignored in favor of nested values.
        let payload: [String: Any] = [
            "command_name": "customevent",
            "event": ["nested_key": "nested_value"],
            "outer_key": "outer_value"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        let lastValues = appsFlyerInstance.lastEventValues
        XCTAssertEqual(lastValues?["nested_key"] as? String, "nested_value")
        XCTAssertNil(lastValues?["outer_key"])
    }

    func testInitWithSettingsWrongTypeFallsBackToNoSettings() {
        // Non-dictionary `settings` value should not crash; falls back to no-settings init.
        let payload: [String: Any] = [
            "command_name": "initialize",
            "app_id": "test",
            "app_dev_key": "test",
            "settings": "not_a_dict"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.initWithoutSettingsCount, 1)
        XCTAssertEqual(appsFlyerInstance.initWithSettingsCount, 0)
        XCTAssertNil(appsFlyerInstance.lastSettings)
    }

    func testLogAdRevenueNotRunWithMissingMonetizationNetwork() {
        let payload: [String: Any] = [
            "command_name": "logadrevenue",
            "mediation_network": "googleadmob",
            "ad_revenue_currency": "USD",
            "ad_revenue_amount": 0.05
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.logAdRevenueCount, 0)
    }

    func testLogAdRevenueNotRunWithMissingCurrency() {
        let payload: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "AdMob",
            "mediation_network": "googleadmob",
            "ad_revenue_amount": 0.05
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.logAdRevenueCount, 0)
    }

    func testLogAdRevenueNotRunWithMissingAmount() {
        let payload: [String: Any] = [
            "command_name": "logadrevenue",
            "monetization_network": "AdMob",
            "mediation_network": "googleadmob",
            "ad_revenue_currency": "USD"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.logAdRevenueCount, 0)
    }

    func testParseCommandsContinuesAfterThrowingCommand() {
        // First command throws (missing currency); subsequent commands must still execute.
        let payload: [String: Any] = [
            "command_name": "setcurrencycode,setcustomerid",
            "af_customer_user_id": "user_after_throw"
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.setCurrencyCodeCount, 0)
        XCTAssertEqual(appsFlyerInstance.setCustomerIdCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastCustomerId, "user_after_throw")
    }

    func testInitDeepLinkTimeoutZeroIsKept() {
        // 0 is a valid boundary value (>= 0); only negative values are filtered.
        let settings: [String: Any] = ["deep_link_timeout": 0]
        let payload: [String: Any] = [
            "command_name": "initialize",
            "app_id": "test",
            "app_dev_key": "test",
            "settings": settings
        ]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.initWithSettingsCount, 1)
        XCTAssertEqual(appsFlyerInstance.lastSettings?["deep_link_timeout"] as? Int, 0)
    }

    func testProcessRemoteCommandWithNonStringCommandName() {
        let payload: [String: Any] = ["command_name": 123]
        appsFlyerCommand.processRemoteCommand(with: payload)
        XCTAssertEqual(appsFlyerInstance.logEventCount, 0)
        XCTAssertEqual(appsFlyerInstance.initWithoutSettingsCount, 0)
        XCTAssertEqual(appsFlyerInstance.initWithSettingsCount, 0)
    }

}
