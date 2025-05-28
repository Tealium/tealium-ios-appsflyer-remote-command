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
    static let version = "3.1.0"
    
    /// Standard AppsFlyer events: https://support.appsflyer.com/hc/en-us/articles/115005544169#Event-Types
    public enum EventCommandNames: String, CaseIterable {
        case levelachieved = "af_level_achieved"
        case addpaymentinfo = "af_add_payment_info"
        case addtocart = "af_add_to_cart"
        case addtowishlist = "af_add_to_wishlist"
        case completeregistration = "af_complete_registration"
        case tutorialcompletion = "af_tutorial_completion"
        case initiatecheckout = "af_initiated_checkout"
        case purchase = "af_purchase"
        case subscribe = "af_subscribe"
        case starttrial = "af_start_trial"
        case rate = "af_rate"
        case spentcredits = "af_spent_credits"
        case achievementunlocked = "af_achievement_unlocked"
        case contentview = "af_content_view"
        case listview = "af_list_view"
        case adclick = "af_ad_click"
        case adview = "af_ad_view"
        case share = "af_share"
        case invite = "af_invite"
        case login = "af_login"
        case reengage = "af_re_engage"
        case openfrompushnotification = "af_opened_from_push_notification"
        case update = "af_update"
        case search = "af_search"
        case travelbooking = "af_travel_booking"
        case customersegment = "af_customer_segment"
        case locationchanged = "af_location_changed"
        case locationcoordinates = "af_location_coordinates"
        case orderid = "af_order_id"
    }
    
    public enum CommandNames: String {
        case initialize = "initialize"
        case trackLocation = "tracklocation"
        case setHost = "sethost"
        case setUserEmails = "setuseremails"
        case setCurrencyCode = "setcurrencycode"
        case setCustomerId = "setcustomerid"
        case anonymizeUser = "anonymizeuser"
        case resolveDeepLinkUrls = "resolvedeeplinkurls"
        case stopTracking = "stoptracking"
        case logAdRevenue = "logadrevenue"
        case enableAppsetId = "enableappsetid"
        case setDMAConsent = "setdmaconsent"
        case setDisableNetworkData = "setdisablenetworkdata"
        case setPhoneNumber = "setphonenumber"
        case setOutOfStore = "setoutofstore"
        case addPushNotificationDeepLinkPath = "addpushnotificationdeeplinkpath"
        case sendPushNotificationData = "sendpushnotificationdata"
        case validateAndLogPurchase = "validateandlogpurchase"
        case logSession = "logsession"
        case waitForCustomerUserId = "waitforcustomeruserid"
        case setCustomerIdAndLogSession = "setcustomeridandlogsession"
        case setMinTimeBetweenSessions = "setmintimebetweensessions"
        case setAppId = "setappid"
        case setDisableAdvertisingIdentifiers = "setdisableadvertisingidentifiers"
        case enableTcfDataCollection = "enabletcfdatacollection"
        case setSharingFilterForPartners = "setsharingfilterforpartners"
        case updateServerUninstallToken = "updateserveruninstalltoken"
        case setIsUpdate = "setisupdate"
        case setAdditionalData = "setadditionaldata"
        case registerUninstall = "registeruninstall"
        case setUseUninstallSandbox = "setuseuninstallsandbox"
    }
    
    public enum Configuration {
        static let appId = "app_id"
        static let appDevKey = "app_dev_key"
        static let debug = "debug"
        static let disableAdTracking = "disable_ad_tracking"
        static let disableAppleAdTracking = "disable_apple_ad_tracking"
        static let disableNetworkData = "disable_network_data"
        static let enableAppsetId = "enable_appset_id"
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
        
        // Ad Revenue Parameters
        static let adMonetizationNetwork = "monetization_network"
        static let adMediationNetwork = "mediation_network"
        static let adRevenue = "revenue"
        static let adAdditionalParameters = "additional_parameters"
        
        // DMA Consent Parameters
        static let gdprApplies = "gdpr_applies"
        static let consentForDataUsage = "consent_for_data_usage"
        static let consentForAdsPersonalization = "consent_for_ads_personalization"
        static let consentForAdStorage = "consent_for_ad_storage"
        
        // Phone Number
        static let phoneNumber = "phone_number"
        
        // Out of Store
        static let outOfStoreSource = "out_of_store_source"
        
        // Push Notification
        static let pushDeepLinkPath = "push_deep_link_path"
        
        // In-App Purchase Validation
        static let purchaseType = "purchase_type"
        static let purchaseToken = "purchase_token"
        static let productId = "product_id"
        static let price = "price"
        static let purchaseCurrency = "currency"
        static let purchaseAdditionalParameters = "additional_parameters"
        
        // Customer User ID
        static let waitForCustomerUserId = "wait_for_customer_user_id"
        
        // App Config
        static let appId = "app_id"
        static let minTimeBetweenSessions = "min_time_between_sessions"
        
        // Privacy
        static let disableAdvertisingIdentifiers = "disable_advertising_identifiers"
        static let enableTcfDataCollection = "enable_tcf_data_collection"
        static let sharingFilterPartners = "sharing_filter_partners"
        
        // Analytics
        static let uninstallToken = "uninstall_token"
        static let deviceToken = "device_token"
        static let useUninstallSandbox = "use_uninstall_sandbox"
        static let isUpdate = "is_update"
        static let additionalData = "additional_data"
        
        // Standard Event Parameters
        static let content = "af_content"
        static let contentId = "af_content_id" 
        static let contentType = "af_content_type"
        static let contentList = "af_content_list"
        static let registrationMethod = "af_registration_method"
        static let achievementId = "af_achievement_id"
        static let couponCode = "af_coupon_code"
        static let quantity = "af_quantity"
        static let revenue = "af_revenue"
        static let level = "af_level"
        static let score = "af_score"
        static let orderId = "af_order_id"
        static let success = "af_success"
        static let maxRatingValue = "af_max_rating_value"
        static let ratingValue = "af_rating_value"
        static let searchString = "af_search_string"
        static let validated = "af_validated"
        static let projectedRevenue = "af_projected_revenue"
        static let receiptId = "af_receipt_id"
        static let tutorialId = "af_tutorial_id"
        static let virtualCurrencyName = "af_virtual_currency_name"
        static let deepLink = "af_deep_link"
        static let oldVersion = "af_old_version"
        static let newVersion = "af_new_version"
        static let reviewText = "af_review_text"
        static let paymentInfoAvailable = "af_payment_info_available"
        static let dateA = "af_date_a"
        static let dateB = "af_date_b"
        static let destinationA = "af_destination_a"
        static let destinationB = "af_destination_b"
        static let description = "af_description"
        static let className = "af_class"
        static let eventStart = "af_event_start"
        static let eventEnd = "af_event_end"
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
        static let touchObj = "af_touch_obj"
        static let afChannel = "af_channel"
        
        // Legacy parameters for backward compatibility
        static let eventTime = "af_event_time"
        static let userId = "af_user_id"
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
    
    // Mediation Network Types from Android version - mapped to iOS AppsFlyerAdRevenueMediationNetworkType
    public enum MediationNetworkType: String, CaseIterable {
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

        public static func fromString(_ value: String) -> MediationNetworkType? {
            return MediationNetworkType(rawValue: value.lowercased())
        }
    }
    
    // Email Hash Types from Android version
    public enum EmailHashType: String, CaseIterable {
        case none = "none"
        case sha256 = "sha256"

        public static func fromString(_ value: String) -> EmailHashType? {
            return EmailHashType(rawValue: value.lowercased())
        }
    }
    
    // Purchase Types from Android version
    public enum PurchaseType: String, CaseIterable {
        case oneTimePurchase = "one_time_purchase"
        case subscription = "subscription"
        
        public static func fromString(_ value: String) -> PurchaseType? {
            return PurchaseType(rawValue: value.lowercased())
        }
    }
}
