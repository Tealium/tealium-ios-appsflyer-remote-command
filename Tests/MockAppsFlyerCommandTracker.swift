//
//  MockAppsFlyerCommandRunner.swift
//  AppsFlyerRemoteCommandTests
//
//  Created by Christina S on 5/30/19.
//  Copyright © 2019 Christina. All rights reserved.
//

import Foundation
@testable import TealiumAppsFlyer

class MockAppsFlyerCommandTracker: AppsFlyerTrackable {
    
    var initWithoutConfigCount = 0
    var initWithConfigCount = 0
    var trackLaunchCount = 0
    var trackEventCount = 0
    var trackLocationCount = 0
    var handlePushNotificationCount = 0
    var setHostCount = 0
    var setUserEmailsCount = 0
    var setCurrencyCodeCount = 0
    var setCustomerIdCount = 0
    var disableTrackingCount = 0
    var registerUninstallCount = 0
    var resolveDeepLinkURLsCount = 0
    
    func initialize(appId: String, appDevKey: String) {
        initWithoutConfigCount += 1
    }
    
    func initialize(appId: String, appDevKey: String, settings: [String : Any]?) {
        if settings != nil {
            initWithConfigCount += 1
        } else {
            initWithoutConfigCount += 1
        }
    }
    
    func trackLaunch() {
        trackLaunchCount += 1
    }
    
    func trackEvent(_ eventName: String, values: [String : Any]) {
        trackEventCount += 1
    }
    
    func trackLocation(longitude: Double, latitude: Double) {
        trackLocationCount += 1
    }
    
    func handlePushNofification(payload: [String : Any]?) {
        handlePushNotificationCount += 1
    }
    
    func setHost(_ host: String, with prefix: String) {
        setHostCount += 1
    }
    
    func setUserEmails(emails: [String], with cryptType: Int) {
        setUserEmailsCount += 1
    }
    
    func currencyCode(_ currency: String) {
        setCurrencyCodeCount += 1
    }
    
    func customerId(_ id: String) {
        setCustomerIdCount += 1
    }
    
    func disableTracking(_ disable: Bool) {
        disableTrackingCount += 1
    }
    
    func registerUninstall(token: Data) {
        registerUninstallCount += 1
    }
    
    func resolveDeepLinkURLs(_ urls: [String]) {
        resolveDeepLinkURLsCount += 1
    }
    
}
