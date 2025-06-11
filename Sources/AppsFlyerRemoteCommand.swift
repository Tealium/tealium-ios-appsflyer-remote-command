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
                guard let appId = payload[AppsFlyerConstants.Configuration.appId] as? String,
                    let appDevKey = payload[AppsFlyerConstants.Configuration.appDevKey] as? String else {
                        print("\(AppsFlyerConstants.errorPrefix) Must set an app_id and api_key in AppsFlyer Mobile Remote Command tag to initialize")
                        return
                }
                guard let settings = payload[AppsFlyerConstants.Configuration.settings] as? [String: Any] else {
                    return appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: nil)
                }
                if let settingsDebug = settings[AppsFlyerConstants.Configuration.debug] as? Bool {
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
            case .anonymizeUser:
                guard let anonymize = payload[AppsFlyerConstants.Configuration.anonymizeUser] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide anonymize_user parameter")
                    }
                    return
                }
                appsFlyerInstance.anonymizeUser(anonymize)
            case .disableTracking:
                guard let disable = payload[AppsFlyerConstants.Parameters.stopTracking] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)If you would like to disable all tracking, please set the enabled/disabled flag in the configuration settings of the AppsFlyer Mobile Remote Command tag")
                    }
                    return appsFlyerInstance.disableTracking(false)
                }
                appsFlyerInstance.disableTracking(disable)
            case .resolveDeepLinkUrls:
                guard let deepLinkUrls = payload[AppsFlyerConstants.Parameters.deepLinkUrls] as? [String] else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)If you would like to resolve deep link urls, please set the af_deep_link variable in the AppDelegate or AppsFlyer Mobile Remote Command tag")
                    }
                    return
                }
                appsFlyerInstance.resolveDeepLinkURLs(deepLinkUrls)
            case .logAdRevenue:
                guard let monetizationNetwork = payload[AppsFlyerConstants.Parameters.adMonetizationNetwork] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide monetization_network parameter")
                    }
                    return
                }
                guard let mediationNetwork = payload[AppsFlyerConstants.Parameters.adMediationNetwork] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide mediation_network parameter")
                    }
                    return
                }
                guard let revenue = payload[AppsFlyerConstants.Parameters.adRevenue] as? Double else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide ad_revenue parameter")
                    }
                    return
                }
                guard let currency = payload[AppsFlyerConstants.Parameters.currency] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide currency parameter")
                    }
                    return
                }
                let additionalParameters = payload[AppsFlyerConstants.Parameters.adAdditionalParameters] as? [String: Any]
                
                appsFlyerInstance.logAdRevenue(monetizationNetwork: monetizationNetwork, mediationNetwork: mediationNetwork, revenue: revenue, currency: currency, additionalParameters: additionalParameters)
            case .setDMAConsent:
                let gdprApplies = payload[AppsFlyerConstants.Parameters.gdprApplies] as? Bool
                let consentForDataUsage = payload[AppsFlyerConstants.Parameters.consentForDataUsage] as? Bool
                let consentForAdsPersonalization = payload[AppsFlyerConstants.Parameters.consentForAdsPersonalization] as? Bool
                let consentForAdStorage = payload[AppsFlyerConstants.Parameters.consentForAdStorage] as? Bool
                appsFlyerInstance.setDMAConsent(gdprApplies: gdprApplies, consentForDataUsage: consentForDataUsage, consentForAdsPersonalization: consentForAdsPersonalization, consentForAdStorage: consentForAdStorage)
            case .setPhoneNumber:
                guard let phoneNumber = payload[AppsFlyerConstants.Parameters.phoneNumber] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide phone_number parameter")
                    }
                    return
                }
                appsFlyerInstance.setPhoneNumber(phoneNumber)
            case .addPushNotificationDeepLinkPath:
                guard let paths = payload[AppsFlyerConstants.Parameters.pushDeepLinkPath] as? [String] else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide push_deep_link_path parameter")
                    }
                    return
                }
                appsFlyerInstance.addPushNotificationDeepLinkPath(paths)
            case .validateAndLogPurchase:
                let purchaseType = payload[AppsFlyerConstants.Parameters.purchaseType] as? String
                let transactionId = payload[AppsFlyerConstants.Parameters.transactionId] as? String
                let productId = payload[AppsFlyerConstants.Parameters.productId] as? String
                let price = payload[AppsFlyerConstants.Parameters.price] as? String
                let currency = payload[AppsFlyerConstants.Parameters.purchaseCurrency] as? String
                let additionalParameters = payload[AppsFlyerConstants.Parameters.purchaseAdditionalParameters] as? [String: Any]
                appsFlyerInstance.validateAndLogPurchase(purchaseType: purchaseType, transactionId: transactionId, productId: productId, price: price, currency: currency, additionalParameters: additionalParameters)
            case .setSharingFilterForPartners:
                let partners = payload[AppsFlyerConstants.Parameters.sharingFilterPartners] as? [String]
                appsFlyerInstance.setSharingFilterForPartners(partners)
            case .appendCustomData:
                if let customDataToAppend = payload[AppsFlyerConstants.Parameters.customDataToAppend] as? [String: Any] {
                    appsFlyerInstance.appendCustomData(customDataToAppend)
                }
            case .setCurrentDeviceLanguage:
                if let deviceLanguage = payload[AppsFlyerConstants.Parameters.deviceLanguage] as? String {
                    appsFlyerInstance.setCurrentDeviceLanguage(deviceLanguage)
                }
            case .setPartnerData:
                if let partnerId = payload[AppsFlyerConstants.Parameters.partnerId] as? String,
                   let partnerInfo = payload[AppsFlyerConstants.Parameters.partnerInfo] as? [String: Any] {
                    appsFlyerInstance.setPartnerData(partnerId: partnerId, partnerInfo: partnerInfo)
                }
            case .appendParametersToDeeplinkURL:
                if let urlContains = payload[AppsFlyerConstants.Parameters.urlContains] as? String,
                   let urlParameters = payload[AppsFlyerConstants.Parameters.urlParameters] as? [String: String] {
                    appsFlyerInstance.appendParametersToDeeplinkURL(contains: urlContains, parameters: urlParameters)
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
        if let standardEvent = AppsFlyerConstants.EventCommandNames(rawValue: command.lowercased()) {
            return standardEvent.appsFlyerEventName
        }
        return command
    }

}

fileprivate extension Dictionary where Key == String, Value == Any {
    func filterVariables() -> [String: Any] {
        self.filter {
            $0.key != "method" &&
            $0.key != AppsFlyerConstants.commandName &&
            $0.key != AppsFlyerConstants.Configuration.debug &&
            $0.key != AppsFlyerConstants.Configuration.appDevKey &&
            $0.key != AppsFlyerConstants.Configuration.appId &&
            $0.key != AppsFlyerConstants.Configuration.settings &&
            $0.key != AppsFlyerConstants.Configuration.anonymizeUser &&
            $0.key != AppsFlyerConstants.Configuration.disableCollectASA &&
            $0.key != AppsFlyerConstants.Configuration.minTimeBetweenSessions &&
            $0.key != AppsFlyerConstants.Configuration.collectDeviceName &&
            $0.key != AppsFlyerConstants.Configuration.disableAdTracking &&
            $0.key != AppsFlyerConstants.Configuration.disableAppleAdTracking &&
            $0.key != AppsFlyerConstants.Configuration.disableAppleAdsAttribution &&
            $0.key != AppsFlyerConstants.Configuration.customData &&
            $0.key != AppsFlyerConstants.Configuration.useUninstallSandbox &&
            $0.key != AppsFlyerConstants.Configuration.enableTCFDataCollection &&
            $0.key != AppsFlyerConstants.Configuration.appInviteOneLinkID &&
            $0.key != AppsFlyerConstants.Configuration.deepLinkTimeout &&
            $0.key != AppsFlyerConstants.Configuration.oneLinkCustomDomains &&
            $0.key != AppsFlyerConstants.Configuration.useReceiptValidationSandbox &&
            $0.key != AppsFlyerConstants.Configuration.waitForATTUserAuthorizationTimeoutInterval &&
            $0.key != AppsFlyerConstants.Configuration.resolveDeepLinks &&
            $0.key != AppsFlyerConstants.Configuration.stopTracking &&
            $0.key != AppsFlyerConstants.Configuration.customerEmails &&
            $0.key != AppsFlyerConstants.Configuration.emailHashType &&
            $0.key != AppsFlyerConstants.Configuration.host &&
            $0.key != AppsFlyerConstants.Configuration.hostPrefix
        }
    }
}
