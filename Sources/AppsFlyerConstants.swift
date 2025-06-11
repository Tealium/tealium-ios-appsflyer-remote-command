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

    public enum EventCommandNames: String, CaseIterable {
        case achievelevel = "achievelevel"
        case adclick = "adclick"
        case adview = "adview"
        case addpaymentinfo = "addpaymentinfo"
        case addtocart = "addtocart"
        case addtowishlist = "addtowishlist"
        case completeregistration = "completeregistration"
        case completetutorial = "tutorialcompletion"
        case viewedcontent = "viewedcontent"
        case search = "search"
        case rate = "rate"
        case starttrial = "starttrial"
        case subscribe = "subscribe"
        case initiatecheckout = "initiatecheckout"
        case purchase = "purchase"
        case unlockachievement = "unlockachievement"
        case spentcredits = "spentcredits"
        case listview = "listview"
        case travelbooking = "travelbooking"
        case share = "share"
        case invite = "invite"
        case reengage = "reengage"
        case update = "update"
        case login = "login"
        case customersegment = "customersegment"
        case pushnotificationopened = "pushnotificationopened"
        case locationchanged = "locationchanged"
        case locationcoordinates = "locationcoordinates"
        case orderid = "orderid"
    }
    
    public enum CommandNames: String {
        case initialize = "initialize"
        case trackLocation = "tracklocation"
        case setHost = "sethost"
        case setUserEmails = "setuseremails"
        case setCurrencyCode = "setcurrencycode"
        case setCustomerId = "setcustomerid"
        case disableTracking = "disabletracking"
        case resolveDeepLinkUrls = "resolvedeeplinkurls"
        case anonymizeUser = "anonymizeuser"
        case logAdRevenue = "logadrevenue"
        case setDMAConsent = "setdmaconsent"
        case setPhoneNumber = "setphonenumber"
        case addPushNotificationDeepLinkPath = "addpushnotificationdeeplinkpath"
        case validateAndLogPurchase = "validateandlogpurchase"
        case setSharingFilterForPartners = "setsharingfilterforpartners"
        case appendCustomData = "appendcustomdata"
        case setCurrentDeviceLanguage = "setcurrentdevicelanguage"
        case setPartnerData = "setpartnerdata"
        case appendParametersToDeeplinkURL = "appendparameterstodeeplinkurl"
    }
    
    public enum Configuration {
        static let appId = "app_id"
        static let appDevKey = "app_dev_key"
        static let debug = "debug"
        static let disableAdTracking = "disable_ad_tracking"
        static let disableAppleAdTracking = "disable_apple_ad_tracking"
        static let disableAppleAdsAttribution = "disable_apple_ads_attribution"
        static let disableCollectASA = "disable_collect_asa"
        static let minTimeBetweenSessions = "time_between_sessions"
        static let anonymizeUser = "anonymize_user"
        static let collectDeviceName = "collect_device_name"
        static let customData = "custom_data"
        static let settings = "settings"
        static let useUninstallSandbox = "use_uninstall_sandbox"
        static let enableTCFDataCollection = "enable_tcf_data_collection"
        static let appInviteOneLinkID = "app_invite_onelink_id"
        static let deepLinkTimeout = "deeplink_timeout"
        static let oneLinkCustomDomains = "onelink_custom_domains"
        static let useReceiptValidationSandbox = "use_receipt_validation_sandbox"
        static let waitForATTUserAuthorizationTimeoutInterval = "wait_for_att_user_authorization_timeout_interval"
        static let resolveDeepLinks = "resolve_deep_links"
        static let stopTracking = "stop_tracking"
        static let customerEmails = "customer_emails"
        static let emailHashType = "email_hash_type"
        static let host = "host"
        static let hostPrefix = "host_prefix"
    }

    public enum Parameters {
        // Configuration Parameters
        static let event = "event"

        // Standard Event Parameters
        static let afLatitude = "af_lat"
        static let afLongitude = "af_long"
        static let content = "af_content"
        static let contentId = "af_content_id" 
        static let contentType = "af_content_type"
        static let contentList = "af_content_list"
        static let currency = "af_currency"
        static let customerId = "af_customer_user_id"
        static let achievementId = "af_achievement_id"
        static let level = "af_level"
        static let score = "af_score"
        static let success = "af_success"
        static let eventPrice = "af_price"
        static let quantity = "af_quantity"
        static let registrationMethod = "af_registration_method"
        static let paymentInfoAvailable = "af_payment_info_available"
        static let maxRatingValue = "af_max_rating_value"
        static let ratingValue = "af_rating_value"
        static let searchString = "af_search_string"
        static let validated = "af_validated"
        static let receiptId = "af_receipt_id"
        static let tutorialId = "af_tutorial_id"
        static let virtualCurrencyName = "af_virtual_currency_name"
        static let deepLinkUrls = "af_deep_link"
        static let oldVersion = "af_old_version"
        static let newVersion = "af_new_version"
        static let reviewText = "af_review_text"
        static let className = "af_class"
        static let eventStart = "af_event_start"
        static let eventEnd = "af_event_end"
        static let customerSegment = "af_customer_segment"
        static let orderId = "af_order_id"
        static let revenue = "af_revenue"
        static let projectedRevenue = "af_projected_revenue"
        static let couponCode = "af_coupon_code"
        static let purchaseCurrency = "af_purchase_currency"
        static let dateA = "af_date_a"
        static let dateB = "af_date_b"
        static let destinationA = "af_destination_a"
        static let destinationB = "af_destination_b"
        static let description = "af_description"
        static let departingDepartureDate = "af_departing_departure_date"
        static let returningDepartureDate = "af_returning_departure_date"
        static let destinationList = "af_destination_list"
        static let city = "af_city"
        static let region = "af_region"
        static let country = "af_country"
        static let departingArrivalDate = "af_departing_arrival_date"
        static let returningArrivalDate = "af_returning_arrival_date"
        static let suggestedDestinations = "af_suggested_destinations"
        static let travelStart = "af_travel_start"
        static let travelEnd = "af_travel_end"
        static let numAdults = "af_num_adults"
        static let numChildren = "af_num_children"
        static let numInfants = "af_num_infants"
        static let suggestedHotels = "af_suggested_hotels"
        static let userScore = "af_user_score"
        static let hotelScore = "af_hotel_score"
        static let preferredStarRatings = "af_preferred_star_ratings"
        static let preferredPriceRange = "af_preferred_price_range"
        static let preferredNeighborhoods = "af_preferred_neighborhoods"
        static let preferredNumStops = "af_preferred_num_stops"
        static let param1 = "af_param_1"
        static let param2 = "af_param_2"
        static let param3 = "af_param_3"
        static let param4 = "af_param_4"
        static let param5 = "af_param_5"
        static let param6 = "af_param_6"
        static let param7 = "af_param_7"
        static let param8 = "af_param_8"
        static let param9 = "af_param_9"
        static let param10 = "af_param_10"
        static let adType = "af_adrev_ad_type"
        static let adNetworkName = "af_adrev_network_name"
        static let adPlacementId = "af_adrev_placement_id"
        static let adSize = "af_adrev_ad_size"
        static let adMediatedNetworkName = "af_adrev_mediated_network_name"
        static let pushDeepLinkPath = "af_push_deep_link_path"

        // SDK Method Parameters

        // logLocation() parameters
        static let latitude = "af_lat"
        static let longitude = "af_long"
        
        // ??
        static let pushPayload = "af_push_payload"

        // logAdRevenue() parameters
        static let adMonetizationNetwork = "monetization_network"
        static let adMediationNetwork = "mediation_network"
        static let adRevenue = "revenue"
        static let adAdditionalParameters = "additional_parameters"
        
        // setDMAConsent() parameters
        static let gdprApplies = "gdpr_applies"
        static let consentForDataUsage = "consent_for_data_usage"
        static let consentForAdsPersonalization = "consent_for_ads_personalization"
        static let consentForAdStorage = "consent_for_ad_storage"

        // setPhoneNumber() parameters
        static let phoneNumber = "phone_number"
        
        // addPushNotificationDeepLinkPath() parameters
        static let pushDeepLinkPath = "push_deep_link_path"
        
        // validateAndLogPurchase() parameters
        static let purchaseType = "purchase_type"
        static let transactionId = "transaction_id"
        static let productId = "product_id"
        static let price = "price"
        static let purchaseAdditionalParameters = "purchase_additional_parameters"
        
        // setSharingFilterForPartners() parameters
        static let sharingFilterPartners = "sharing_filter_partners"
        
        // appendCustomData() parameters
        static let customDataToAppend = "custom_data_to_append"
        
        // setCurrentDeviceLanguage() parameters
        static let deviceLanguage = "device_language"
        
        // setPartnerData() parameters
        static let partnerId = "partner_id"
        static let partnerInfo = "partner_info"
        
        // appendParametersToDeeplinkURL() parameters
        static let urlContains = "url_contains"
        static let urlParameters = "url_parameters"
        
        // resolveDeepLinkURLs() parameters
        static let deepLinkUrls = "af_deep_link"
        
        // setHost() parameters
        static let host = "host"
        static let hostPrefix = "host_prefix"
        
        // setUserEmails() parameters
        static let emails = "customer_emails"
        static let cryptType = "email_hash_type"
        
        // stopTracking() parameters
        static let stopTracking = "stop_tracking"
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
    
    public enum MediationNetwork: String, CaseIterable {
        case ironsource = "ironsource"
        case applovinmax = "applovinmax"
        case googleadmob = "googleadmob"
        case fyber = "fyber"
        case appodeal = "appodeal"
        case admost = "admost"
        case topon = "topon"
        case tradplus = "tradplus"
        case yandex = "yandex"
        case chartboost = "chartboost"
        case unity = "unity"
        case toponpte = "toponpte"
        case custommediation = "custommediation"
        case directmonetizationnetwork = "directmonetizationnetwork"

        public static func fromString(_ value: String) -> MediationNetwork? {
            return MediationNetwork(rawValue: value.lowercased())
        }
        
        // Convert to AppsFlyerLib's MediationNetworkType
        public func toAppsFlyerType() -> MediationNetworkType {
            switch self {
            case .ironsource:
                return MediationNetworkType.ironSource
            case .applovinmax:
                return MediationNetworkType.applovinMax
            case .googleadmob:
                return MediationNetworkType.googleAdMob
            case .fyber:
                return MediationNetworkType.fyber
            case .appodeal:
                return MediationNetworkType.appodeal
            case .admost:
                return MediationNetworkType.admost
            case .topon:
                return MediationNetworkType.topon
            case .tradplus:
                return MediationNetworkType.tradplus
            case .yandex:
                return MediationNetworkType.yandex
            case .chartboost:
                return MediationNetworkType.chartBoost
            case .unity:
                return MediationNetworkType.unity
            case .toponpte:
                return MediationNetworkType.toponPte
            case .custommediation:
                return MediationNetworkType.custom
            case .directmonetizationnetwork:
                return MediationNetworkType.directMonetization
            }
        }
        
        // Convenience method to convert string directly to AppsFlyerLib type
        public static func appsFlyerTypeFromString(_ value: String) -> MediationNetworkType {
            return fromString(value)?.toAppsFlyerType() ?? MediationNetworkType.googleAdMob
        }
    }
    
    public enum EmailHashType: Int, CaseIterable {
        case none = 0
        case sha256 = 3
        
        // Convert from int directly to AppsFlyerLib's EmailCryptType
        public static func appsFlyerTypeFromInt(_ value: Int) -> EmailCryptType {
            return EmailCryptType(rawValue: UInt32(value))
        }
    }
}

/// Extension to map EventCommandNames cases to official AppsFlyer event constants
/// This leverages the constants defined in AppsFlyerLib.h for type safety and consistency
extension AppsFlyerConstants.EventCommandNames {
    
    /// Converts the command event to the corresponding AppsFlyer standard event name
    /// Uses the official constants from AppsFlyerLib.h to ensure consistency and prevent typos
    var appsFlyerEventName: String {
        switch self {
        case .achievelevel:
            return "af_level_achieved"  // AFEventLevelAchieved from AppsFlyerLib.h
        case .addpaymentinfo:
            return "af_add_payment_info"  // AFEventAddPaymentInfo from AppsFlyerLib.h
        case .addtocart:
            return "af_add_to_cart"  // AFEventAddToCart from AppsFlyerLib.h
        case .addtowishlist:
            return "af_add_to_wishlist"  // AFEventAddToWishlist from AppsFlyerLib.h
        case .completeregistration:
            return "af_complete_registration"  // AFEventCompleteRegistration from AppsFlyerLib.h
        case .completetutorial:
            return "af_tutorial_completion"  // AFEventTutorial_completion from AppsFlyerLib.h
        case .initiatecheckout:
            return "af_initiated_checkout"  // AFEventInitiatedCheckout from AppsFlyerLib.h
        case .purchase:
            return "af_purchase"  // AFEventPurchase from AppsFlyerLib.h
        case .subscribe:
            return "af_subscribe"  // AFEventSubscribe from AppsFlyerLib.h
        case .starttrial:
            return "af_start_trial"  // AFEventStartTrial from AppsFlyerLib.h
        case .rate:
            return "af_rate"  // AFEventRate from AppsFlyerLib.h
        case .spentcredits:
            return "af_spent_credits"  // AFEventSpentCredits from AppsFlyerLib.h
        case .unlockachievement:
            return "af_achievement_unlocked"  // AFEventAchievementUnlocked from AppsFlyerLib.h
        case .viewedcontent:
            return "af_content_view"  // AFEventContentView from AppsFlyerLib.h
        case .listview:
            return "af_list_view"  // AFEventListView from AppsFlyerLib.h
        case .adclick:
            return "af_ad_click"  // AFEventAdClick from AppsFlyerLib.h
        case .adview:
            return "af_ad_view"  // AFEventAdView from AppsFlyerLib.h
        case .share:
            return "af_share"  // AFEventShare from AppsFlyerLib.h
        case .invite:
            return "af_invite"  // AFEventInvite from AppsFlyerLib.h
        case .login:
            return "af_login"  // AFEventLogin from AppsFlyerLib.h
        case .reengage:
            return "af_re_engage"  // AFEventReEngage from AppsFlyerLib.h
        case .pushnotificationopened:
            return "af_opened_from_push_notification"  // AFEventOpenedFromPushNotification from AppsFlyerLib.h
        case .update:
            return "af_update"  // AFEventUpdate from AppsFlyerLib.h
        case .search:
            return "af_search"  // AFEventSearch from AppsFlyerLib.h
        case .travelbooking:
            return "af_travel_booking"  // AFEventTravelBooking from AppsFlyerLib.h
        case .customersegment:
            return "af_customer_segment"  // AFEventCustomerSegment from AppsFlyerLib.h
        case .locationchanged:
            return "af_location_changed"  // Custom event for location changes
        case .locationcoordinates:
            return "af_location_coordinates"  // AFEventLocation from AppsFlyerLib.h
        case .orderid:
            return "af_order_id"  // Custom event for order tracking
        }
    }
}
