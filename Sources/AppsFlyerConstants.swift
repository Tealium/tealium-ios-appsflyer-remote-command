//
//  AppsFlyerConstants.swift
//  TealiumAppsFlyer
//
//  Created by Christina S on 5/29/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation

public enum AppsFlyerConstants {
    
    static let commandName = "command_name"
    static let separator: Character = ","
    static let commandId = "appsflyer"
    static let description = "AppsFlyer Remote Command"
    static let errorPrefix = "AppsFlyer Error: "
    static let attributionLog = "AppsFlyer Attribution: "
    static let version = "2.1.2"
    
    /// Standard AppsFlyer events: https://support.appsflyer.com/hc/en-us/articles/115005544169#Event-Types
    public enum EventCommandNames: String, CaseIterable {
        case achievelevel
        case adclick
        case adview
        case addpaymentinfo
        case addtocart
        case addtowishlist
        case completeregistration
        case completetutorial
        case viewedcontent
        case search
        case rate
        case starttrial
        case subscribe
        case initiatecheckout
        case purchase
        case unlockachievement
        case spentcredits
        case listview
        case travelbooking
        case share
        case invite
        case reengage
        case update
        case login
        case customersegment
    }
    
    public enum CommandNames: String {
        case launch = "launch"
        case initialize = "initialize"
        case trackLocation = "tracklocation"
        case setHost = "sethost"
        case setUserEmails = "setuseremails"
        case setCurrencyCode = "setcurrencycode"
        case setCustomerId = "setcustomerid"
        case disableTracking = "disabletracking"
        case resolveDeepLinkUrls = "resolvedeeplinkurls"
    }
    
    public enum Configuration {
        static let appId = "app_id"
        static let appDevKey = "app_dev_key"
        static let debug = "debug"
        static let disableAdTracking = "disable_ad_tracking"
        static let disableAppleAdTracking = "disable_apple_ad_tracking"
        static let minTimeBetweenSessions = "time_between_sessions"
        static let anonymizeUser = "anonymize_user"
        static let collectDeviceName = "collect_device_name"
        static let customData = "custom_data"
        static let settings = "settings"
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
    }
    
    public enum Events {
        static let achievedLevel = "af_level_achieved"
        static let addPaymentInfo = "af_add_payment_info"
        static let addToCart = "af_add_to_cart"
        static let addToWishlist = "af_add_to_wishlist"
        static let completeRegistration = "af_complete_registration"
        static let completeTutorial = "af_tutorial_completion"
        static let initiateCheckout = "af_initiated_checkout"
        static let purchase = "af_purchase"
        static let subscribe = "af_subscribe"
        static let startTrial = "af_start_trial"
        static let rate = "af_rate"
        static let search = "af_search"
        static let spentCredits = "af_spent_credits"
        static let unlockAchievement = "af_achievement_unlocked"
        static let contentView = "af_content_view"
        static let listView = "af_list_view"
        static let adClick = "af_ad_click"
        static let adView = "af_ad_view"
        static let travelBooking = "af_travel_booking"
        static let share = "af_share"
        static let invite = "af_invite"
        static let reEngage = "af_re_engage"
        static let update = "af_update"
        static let login = "af_login"
        static let customerSegment = "af_customer_segment"
        static let pushNotificationOpened = "af_opened_from_push_notification"
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
