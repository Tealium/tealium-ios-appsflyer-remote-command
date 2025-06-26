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
        case pushnotificationopened
        case locationcoordinates
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
    
    public enum Configuration: String, CaseIterable {
        case appId = "app_id"
        case appDevKey = "app_dev_key"
        case debug = "debug"
        case disableAdTracking = "disable_ad_tracking"
        case disableAppleAdTracking = "disable_apple_ad_tracking"
        case disableAppleAdsAttribution = "disable_apple_ads_attribution"
        case minTimeBetweenSessions = "time_between_sessions"
        case anonymizeUser = "anonymize_user"
        case collectDeviceName = "collect_device_name"
        case customData = "custom_data"
        case settings = "settings"
        case useUninstallSandbox = "use_uninstall_sandbox"
        case enableTCFDataCollection = "enable_tcf_data_collection"
        case appInviteOneLinkID = "app_invite_onelink_id"
        case deepLinkTimeout = "deeplink_timeout"
        case oneLinkCustomDomains = "onelink_custom_domains"
        case useReceiptValidationSandbox = "use_receipt_validation_sandbox"
        case waitForATTUserAuthorizationTimeoutInterval = "wait_for_att_user_authorization_timeout_interval"
        case resolveDeepLinks = "resolve_deep_links"
        case stopTracking = "stop_tracking"
        case host = "host"
        case hostPrefix = "host_prefix"
        
        static let allConfigurationKeys: Set<String> = Set(Configuration.allCases.map { $0.rawValue })
    }

    public enum Parameters {
        // Configuration Parameters
        static let event = "event"

        // Standard Event Parameters
        static let content = AFEventParamContent
        static let contentId = AFEventParamContentId
        static let contentType = AFEventParamContentType
        static let contentList = AFEventParamContentList
        static let currency = AFEventParamCurrency
        static let customerId = AFEventParamCustomerUserId
        static let achievementId = AFEventParamAchievementId
        static let level = AFEventParamLevel
        static let score = AFEventParamScore
        static let success = AFEventParamSuccess
        static let eventPrice = AFEventParamPrice
        static let quantity = AFEventParamQuantity
        static let registrationMethod = AFEventParamRegistrationMethod
        static let paymentInfoAvailable = AFEventParamPaymentInfoAvailable
        static let maxRatingValue = AFEventParamMaxRatingValue
        static let ratingValue = AFEventParamRatingValue
        static let searchString = AFEventParamSearchString
        static let validated = AFEventParamValidated
        static let receiptId = AFEventParamReceiptId
        static let tutorialId = AFEventParamTutorialId
        static let virtualCurrencyName = AFEventParamVirtualCurrencyName
        static let oldVersion = AFEventParamOldVersion
        static let newVersion = AFEventParamNewVersion
        static let reviewText = AFEventParamReviewText
        static let className = AFEventParamClass
        static let eventStart = AFEventParamEventStart
        static let eventEnd = AFEventParamEventEnd
        static let orderId = AFEventParamOrderId
        static let revenue = AFEventParamRevenue
        static let projectedRevenue = AFEventProjectedParamRevenue
        static let couponCode = AFEventParamCouponCode
        static let purchaseCurrency = AFEventParamPurchaseCurrency
        static let dateA = AFEventParamDateA
        static let dateB = AFEventParamDateB
        static let destinationA = AFEventParamDestinationA
        static let destinationB = AFEventParamDestinationB
        static let description = AFEventParamDescription
        static let departingDepartureDate = AFEventParamDepartingDepartureDate
        static let returningDepartureDate = AFEventParamReturningDepartureDate
        static let destinationList = AFEventParamDestinationList
        static let city = AFEventParamCity
        static let region = AFEventParamRegion
        static let country = AFEventParamCountry
        static let departingArrivalDate = AFEventParamDepartingArrivalDate
        static let returningArrivalDate = AFEventParamReturningArrivalDate
        static let suggestedDestinations = AFEventParamSuggestedDestinations
        static let travelStart = AFEventParamTravelStart
        static let travelEnd = AFEventParamTravelEnd
        static let numAdults = AFEventParamNumAdults
        static let numChildren = AFEventParamNumChildren
        static let numInfants = AFEventParamNumInfants
        static let suggestedHotels = AFEventParamSuggestedHotels
        static let userScore = AFEventParamUserScore
        static let hotelScore = AFEventParamHotelScore
        static let preferredStarRatings = AFEventParamPreferredStarRatings
        static let preferredPriceRange = AFEventParamPreferredPriceRange
        static let preferredNeighborhoods = AFEventParamPreferredNeighborhoods
        static let preferredNumStops = AFEventParamPreferredNumStops
        static let param1 = AFEventParam1
        static let param2 = AFEventParam2
        static let param3 = AFEventParam3
        static let param4 = AFEventParam4
        static let param5 = AFEventParam5
        static let param6 = AFEventParam6
        static let param7 = AFEventParam7
        static let param8 = AFEventParam8
        static let param9 = AFEventParam9
        static let param10 = AFEventParam10

        // exist in documentation but not in codebase
        static let adType = "af_adrev_ad_type"
        static let adNetworkName = "af_adrev_network_name"
        static let adPlacementId = "af_adrev_placement_id"
        static let adSize = "af_adrev_ad_size"
        static let adMediatedNetworkName = "af_adrev_mediated_network_name"

        // logLocation() parameters
        static let latitude = AFEventParamLat
        static let longitude = AFEventParamLong

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
        static let pushNotificationDeepLinkPath = "push_notification_deep_link_path"
        
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
        static let deepLinkUrls = AFEventParamDeepLink
        
        // setHost() parameters
        static let host = "host"
        static let hostPrefix = "host_prefix"
        
        // setUserEmails() parameters
        static let emails = "customer_emails"
        static let cryptType = "email_hash_type"
        
        // stopTracking() parameters
        static let stopTracking = "stop_tracking"
        
        // anonymizeUser() parameters
        static let anonymizeUser = "anonymize_user"
    }
        
    public enum Events {
        static let achievedLevel = AFEventLevelAchieved
        static let addPaymentInfo = AFEventAddPaymentInfo
        static let addToCart = AFEventAddToCart
        static let addToWishlist = AFEventAddToWishlist
        static let completeRegistration = AFEventCompleteRegistration
        static let completeTutorial = AFEventTutorial_completion
        static let initiateCheckout = AFEventInitiatedCheckout
        static let purchase = AFEventPurchase
        static let subscribe = AFEventSubscribe
        static let startTrial = AFEventStartTrial
        static let rate = AFEventRate
        static let search = AFEventSearch
        static let spentCredits = AFEventSpentCredits
        static let unlockAchievement = AFEventAchievementUnlocked
        static let contentView = AFEventContentView
        static let listView = AFEventListView
        static let adClick = AFEventAdClick
        static let adView = AFEventAdView
        static let travelBooking = AFEventTravelBooking
        static let share = AFEventShare
        static let invite = AFEventInvite
        static let reEngage = AFEventReEngage
        static let update = AFEventUpdate
        static let login = AFEventLogin
        static let customerSegment = AFEventCustomerSegment
        static let pushNotificationOpened = AFEventOpenedFromPushNotification
        static let locationCoordinates = AFEventLocation
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
        case ironsource
        case applovinmax
        case googleadmob
        case fyber
        case appodeal
        case admost
        case topon
        case tradplus
        case yandex
        case chartboost
        case unity
        case toponpte
        case custommediation
        case directmonetizationnetwork
        
        // Convenience method to convert string directly to AppsFlyerLib type
        public static func appsFlyerTypeFromString(_ value: String) -> MediationNetworkType? {
            guard let mediationNetwork = MediationNetwork(rawValue: value.lowercased()) else {
                return nil
            }
            return mediationNetworkMapping[mediationNetwork]
        }
        
        private static let mediationNetworkMapping: [MediationNetwork: MediationNetworkType] = [
            .ironsource: MediationNetworkType.ironSource,
            .applovinmax: MediationNetworkType.applovinMax,
            .googleadmob: MediationNetworkType.googleAdMob,
            .fyber: MediationNetworkType.fyber,
            .appodeal: MediationNetworkType.appodeal,
            .admost: MediationNetworkType.admost,
            .topon: MediationNetworkType.topon,
            .tradplus: MediationNetworkType.tradplus,
            .yandex: MediationNetworkType.yandex,
            .chartboost: MediationNetworkType.chartBoost,
            .unity: MediationNetworkType.unity,
            .toponpte: MediationNetworkType.toponPte,
            .custommediation: MediationNetworkType.custom,
            .directmonetizationnetwork: MediationNetworkType.directMonetization
        ]
    }
    
    public enum EmailHashType: String, CaseIterable {
        case none = "none"
        case sha256 = "sha256"
        
        public static func appsFlyerTypeFromString(_ value: String) -> EmailCryptType? {
            switch value.lowercased() {
            case EmailHashType.sha256.rawValue:
                return EmailCryptType(rawValue: 3)  // SHA-256 = 3
            case EmailHashType.none.rawValue:
                return EmailCryptType(rawValue: 0)  // NONE = 0
            default:
                return nil
            }
        }
    }
}


