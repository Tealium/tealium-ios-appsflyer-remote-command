//
//  AppsFlyerRemoteCommand.swift
//  TealiumAppsFlyer
//
//  Created by Christina S on 5/29/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation
import AppsFlyerLib
#if COCOAPODS
import TealiumSwift
#else
import TealiumCore
import TealiumRemoteCommands
#endif

public class AppsFlyerRemoteCommand: RemoteCommand {

    let appsFlyerInstance: AppsFlyerCommand

    public override var version: String? {
        return AppsFlyerConstants.version
    }

    public func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void) {
        TealiumQueues.backgroundSerialQueue.async {
            self.appsFlyerInstance.onReady(onReady)
        }
    }

    public init(appsFlyerInstance: AppsFlyerCommand = AppsFlyerInstance(), type: RemoteCommandType = .webview) {
        self.appsFlyerInstance = appsFlyerInstance
        weak var selfWorkaround: AppsFlyerRemoteCommand?
        super.init(commandId: AppsFlyerConstants.commandId,
                   description: AppsFlyerConstants.description,
                   type: type,
                   completion: { response in
            guard let payload = response.payload else {
                return
            }
            selfWorkaround?.processRemoteCommand(with: payload)
        })
        selfWorkaround = self
    }

    func processRemoteCommand(with payload: [String: Any]) {
        guard let command = payload[AppsFlyerConstants.commandName] as? String else {
            return
        }
        let commands = command.split(separator: AppsFlyerConstants.separator)
        let appsflyerCommands = commands.map { command in
            return command.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        var debug = false
        appsflyerCommands.forEach {
            let commandName = AppsFlyerConstants.CommandNames(rawValue: $0.lowercased())
            switch commandName {
            case .initialize:
                guard let appId = payload[AppsFlyerConstants.Configuration.appId.rawValue] as? String,
                      let appDevKey = payload[AppsFlyerConstants.Configuration.appDevKey.rawValue] as? String else {
                    print("\(AppsFlyerConstants.errorPrefix) Must set an app_id and api_key in AppsFlyer Mobile Remote Command tag to initialize")
                    return
                }
                guard var settings = payload[AppsFlyerConstants.Configuration.settings.rawValue] as? [String: Any] else {
                    return appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: nil)
                }

                if let deepLinkTimeout = settings[AppsFlyerConstants.Settings.deepLinkTimeout] as? Int {
                    if deepLinkTimeout < 0 {
                        if debug {
                            print("\(AppsFlyerConstants.errorPrefix)deepLinkTimeout must be >= 0, got: \(deepLinkTimeout). Ignoring setting.")
                        }
                        settings.removeValue(forKey: AppsFlyerConstants.Settings.deepLinkTimeout)
                    }
                }

                if let settingsDebug = settings[AppsFlyerConstants.Settings.debug] as? Bool {
                    debug = settingsDebug
                }
                return appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: settings)
            case .trackLocation:
                guard let latitude = payload[AppsFlyerConstants.Parameters.latitude] as? Double,
                      let longitude = payload[AppsFlyerConstants.Parameters.longitude] as? Double else {
                    guard let latitude = payload[AppsFlyerConstants.Parameters.latitude] as? Int,
                          let longitude = payload[AppsFlyerConstants.Parameters.longitude] as? Int else {
                        if debug {
                            print("\(AppsFlyerConstants.errorPrefix)Must map af_lat and af_long in the AppsFlyer Mobile Remote Command tag to track location")
                        }
                        return
                    }
                    return appsFlyerInstance.logLocation(longitude: Double(longitude), latitude: Double(latitude))
                }
                appsFlyerInstance.logLocation(longitude: longitude, latitude: latitude)
            case .setHost:
                guard let host = payload[AppsFlyerConstants.Parameters.host] as? String,
                      let hostPrefix = payload[AppsFlyerConstants.Parameters.hostPrefix] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must map host and host_prefix in the AppsFlyer Mobile Remote Command tag to set host")

                    }
                    return
                }
                appsFlyerInstance.setHost(host, with: hostPrefix)
            case .setUserEmails:
                var payload = payload
                if let email = payload[AppsFlyerConstants.Parameters.emails] as? String {
                    payload[AppsFlyerConstants.Parameters.emails] = [email]
                }
                guard let emails = payload[AppsFlyerConstants.Parameters.emails] as? [String],
                      let cryptType = payload[AppsFlyerConstants.Parameters.cryptType] as? Int else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must map customer_emails and cryptType in the AppsFlyer Mobile Remote Command tag to set user emails")
                    }
                    return
                }
                appsFlyerInstance.setUserEmails(emails: emails, with: cryptType)
            case .setCurrencyCode:
                guard let currency = payload[AppsFlyerConstants.Parameters.currency] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must map af_currency in the AppsFlyer Mobile Remote Command tag to call set currency")
                    }
                    return
                }
                appsFlyerInstance.currencyCode(currency)
            case .setCustomerId:
                guard let customerId = payload[AppsFlyerConstants.Parameters.customerId] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must map af_customer_user_id in the AppsFlyer Mobile Remote Command tag to call set customer id")
                    }
                    return
                }
                appsFlyerInstance.customerId(customerId)
            case .disableTracking:
                guard let disable = payload[AppsFlyerConstants.Parameters.stopTracking] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)If you would like to disable all tracking, please set the enabled/disabled flag in the configuration settings of the AppsFlyer Mobile Remote Command tag")
                    }
                    return appsFlyerInstance.disableTracking(false)
                }
                appsFlyerInstance.disableTracking(disable)
            case .anonymizeUser:
                guard let anonymize = payload[AppsFlyerConstants.Parameters.anonymizeUser] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide anonymize_user boolean flag to anonymize user")
                    }
                    return
                }
                appsFlyerInstance.anonymizeUser(anonymize)
            case .resolveDeepLinkUrls:
                guard let deepLinkUrls = payload[AppsFlyerConstants.Parameters.deepLinkUrls] as? [String] else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)If you would like to resolve deep link urls, please set the af_deep_link variable in the AppDelegate or AppsFlyer Mobile Remote Command tag")
                    }
                    return
                }
                appsFlyerInstance.resolveDeepLinkURLs(deepLinkUrls)
            case .setPhoneNumber:
                guard let phoneNumber = payload[AppsFlyerConstants.Parameters.phoneNumber] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must map phone_number in the AppsFlyer Mobile Remote Command tag to set phone number")
                    }
                    return
                }
                appsFlyerInstance.setPhoneNumber(phoneNumber)
            case .logAdRevenue:
                guard let monetizationNetwork = payload[AppsFlyerConstants.Parameters.monetizationNetwork] as? String,
                      let mediationNetwork = payload[AppsFlyerConstants.Parameters.mediationNetwork] as? String,
                      let currency = payload[AppsFlyerConstants.Parameters.adRevenueCurrency] as? String,
                      let revenue = payload[AppsFlyerConstants.Parameters.adRevenueAmount] as? Double else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Ad revenue requires monetization_network, mediation_network, ad_revenue_currency, and ad_revenue_amount")
                    }
                    return
                }
                
                // Validate mediation network
                guard let mediationNetworkType = AppsFlyerConstants.mediationNetworksMap[mediationNetwork.lowercased()] else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Invalid mediation_network '\(mediationNetwork)'. Supported networks: \(AppsFlyerConstants.mediationNetworksMap.keys.joined(separator: ", "))")
                    }
                    return
                }
                
                let additionalParams = payload[AppsFlyerConstants.Parameters.adRevenueAdditionalParams] as? [String: Any]
                
                appsFlyerInstance.logAdRevenue(
                    monetizationNetwork: monetizationNetwork,
                    mediationNetworkType: mediationNetworkType,
                    currency: currency,
                    revenue: revenue,
                    additionalParams: additionalParams
                )
            case .setConsentData:
                guard let isUserSubjectToGDPR = payload[AppsFlyerConstants.Parameters.isUserSubjectToGDPR] as? Bool,
                      let hasConsentForDataUsage = payload[AppsFlyerConstants.Parameters.hasConsentForDataUsage] as? Bool,
                      let hasConsentForAdsPersonalization = payload[AppsFlyerConstants.Parameters.hasConsentForAdsPersonalization] as? Bool,
                      let hasConsentForAdStorage = payload[AppsFlyerConstants.Parameters.hasConsentForAdStorage] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Consent data requires is_user_subject_to_gdpr, has_consent_for_data_usage, has_consent_for_ads_personalization, and has_consent_for_ad_storage")
                    }
                    return
                }
                
                appsFlyerInstance.setConsentData(
                    isUserSubjectToGDPR: isUserSubjectToGDPR,
                    hasConsentForDataUsage: hasConsentForDataUsage,
                    hasConsentForAdsPersonalization: hasConsentForAdsPersonalization,
                    hasConsentForAdStorage: hasConsentForAdStorage
                )

            case .setPartnerData:
                guard let partnerId = payload[AppsFlyerConstants.Parameters.partnerId] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide partner_id to set partner data")
                    }
                    return
                }
                
                let partnerInfo = payload[AppsFlyerConstants.Parameters.partnerInfo] as? [String: Any]
                
                appsFlyerInstance.setPartnerData(partnerId: partnerId, partnerInfo: partnerInfo)
            case .setSharingFilterForPartners:
                let sharingFilter = payload[AppsFlyerConstants.Parameters.sharingFilter] as? [String]
                
                appsFlyerInstance.setSharingFilterForPartners(sharingFilter)
            case .handleOpen:
                guard let urlString = payload[AppsFlyerConstants.Parameters.url] as? String,
                      let url = URL(string: urlString),
                      url.scheme != nil else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide valid url with scheme for handleOpen")
                    }
                    return
                }
                
                if let options = payload[AppsFlyerConstants.Parameters.options] as? [String: Any] {
                    var urlOptions: [UIApplication.OpenURLOptionsKey: Any] = [:]
                    for (key, value) in options {
                        let optionKey = UIApplication.OpenURLOptionsKey(rawValue: key)
                        urlOptions[optionKey] = value
                    }
                    appsFlyerInstance.handleOpen(url: url, options: urlOptions)
                } else {
                    let sourceApplication = payload[AppsFlyerConstants.Parameters.sourceApplication] as? String
                    let annotation = payload[AppsFlyerConstants.Parameters.annotation]
                    appsFlyerInstance.handleOpen(url: url, sourceApplication: sourceApplication, annotation: annotation)
                }
            default:
                appsFlyerInstance.logEvent(getEventName(command: $0), values: getEventParameters(payload: payload))
                break
            }
        }
    }

    func getEventParameters(payload: [String: Any]) -> [String: Any] {
        guard let eventParameters = payload[AppsFlyerConstants.Parameters.event] as? [String: Any] else {
            return payload.filterVariables()
        }
        return eventParameters
    }

    func getEventName(command: String) -> String {
        return AppsFlyerConstants.eventsMap[command.lowercased()] ?? command
    }

}

fileprivate extension Dictionary where Key == String, Value == Any {

    private static let allExcludedKeys: Set<String> = {
        let excludedKeys: Set<String> = ["method", AppsFlyerConstants.commandName]
        let configurationKeys = Set(AppsFlyerConstants.Configuration.allCases.map { $0.rawValue })
        return excludedKeys.union(configurationKeys)
    }()

    func filterVariables() -> [String: Any] {
        return self.filter { !Self.allExcludedKeys.contains($0.key) }
    }
}


