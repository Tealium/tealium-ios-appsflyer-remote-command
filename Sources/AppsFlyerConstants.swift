//
//  AppsFlyerConstants.swift
//  TealiumAppsFlyer
//
//  Created by Christina S on 5/29/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation
import AppsFlyerLib

public enum AppsFlyerConstants {
    
    static let commandName = "command_name"
    static let separator: Character = ","
    static let commandId = "appsflyer"
    static let description = "AppsFlyer Remote Command"
    static let errorPrefix = "AppsFlyer Error: "
    static let attributionLog = "AppsFlyer Attribution: "
    static let version = "3.1.0"
    
    /// Standard AppsFlyer events: https://dev.appsflyer.com/hc/docs/in-app-events-ios
    static let eventsMap: [String: String] = [
        "achievelevel": AFEventLevelAchieved,
        "adclick": AFEventAdClick,
        "adview": AFEventAdView,
        "addpaymentinfo": AFEventAddPaymentInfo,
        "addtocart": AFEventAddToCart,
        "addtowishlist": AFEventAddToWishlist,
        "completeregistration": AFEventCompleteRegistration,
        "completetutorial": AFEventTutorial_completion,
        "viewedcontent": AFEventContentView,
        "search": AFEventSearch,
        "rate": AFEventRate,
        "starttrial": AFEventStartTrial,
        "subscribe": AFEventSubscribe,
        "initiatecheckout": AFEventInitiatedCheckout,
        "purchase": AFEventPurchase,
        "unlockachievement": AFEventAchievementUnlocked,
        "spentcredits": AFEventSpentCredits,
        "listview": AFEventListView,
        "travelbooking": AFEventTravelBooking,
        "share": AFEventShare,
        "invite": AFEventInvite,
        "reengage": AFEventReEngage,
        "update": AFEventUpdate,
        "login": AFEventLogin,
        "customersegment": AFEventCustomerSegment,
        "pushnotificationopened": AFEventOpenedFromPushNotification,
        "locationcoordinates": AFEventLocation
    ]
    
    // Command names come from the AppsFlyer SDK https://dev.appsflyer.com/hc/docs/ios-sdk-reference-appsflyerlib
    public enum CommandNames: String {
        case initialize = "initialize"
        case trackLocation = "tracklocation"
        case setHost = "sethost"
        case setUserEmails = "setuseremails"
        case setCurrencyCode = "setcurrencycode"
        case setCustomerId = "setcustomerid" // customerUserID
        case disableTracking = "disabletracking"
        case resolveDeepLinkUrls = "resolvedeeplinkurls"
        case setPhoneNumber = "setphonenumber"
    }
    
    public enum Configuration: String, CaseIterable {
        case appId = "app_id" // appleAppID
        case appDevKey = "app_dev_key" // appsFlyerDevKey
        case settings = "settings"
    }
    
    // Settings names come from the AppsFlyer SDK https://dev.appsflyer.com/hc/docs/ios-sdk-reference-appsflyerlib
    public enum Settings {
        static let debug = "debug"
        static let disableAdTracking = "disable_ad_tracking"
        static let disableAppleAdsAttribution = "disable_apple_ads_attribution"
        static let disableAppleAdTracking = "disable_apple_ad_tracking"
        static let minTimeBetweenSessions = "time_between_sessions"
        static let anonymizeUser = "anonymize_user"
        static let collectDeviceName = "collect_device_name"
        static let customData = "custom_data"
        static let enableTCFDataCollection = "enable_tcf_data_collection"
        static let appInviteOneLinkID = "app_invite_onelink_id"
        static let deepLinkTimeout = "deep_link_timeout"
        static let oneLinkCustomDomains = "one_link_custom_domains"
        static let facebookDeferredAppLink = "facebook_deferred_app_link"
    }

    public enum Parameters {
        static let latitude = "af_lat"
        static let longitude = "af_long"
        static let pushPayload = "af_push_payload"
        static let host = "host"
        static let hostPrefix = "host_prefix"
        static let emails = "customer_emails"
        static let cryptType = "email_hash_type"
        static let currency = "af_currency"
        static let customerId = "af_customer_user_id"
        static let stopTracking = "stop_tracking"
        static let deepLinkUrls = "af_deep_link"
        static let event = "event"
        static let phoneNumber = "phone_number"
    }
    
    public enum Attribution {
        static let appOpen = "app_open_attribution"
        static let appOpenFailure = "app_open_attribution_failure"
        static let firstLaunch = "is_first_launch"
        static let conversionReceived = "conversion_data_received"
        static let conversionFailure = "conversion_data_failure"
        static let errorName = "error_name"
        static let errorDescription = "error_description"
        static let status = "af_status"
        static let source = "source"
        static let campaign = "campaign"
        static let error = "appsflyer_error"
    }
    
}
