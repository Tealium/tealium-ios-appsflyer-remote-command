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
                
                // Collect all configuration parameters from payload (flat structure like Android)
                var configSettings: [String: Any] = [:]
                
                // Add all config parameters if they exist in payload
                if let debugValue = payload[AppsFlyerConstants.Configuration.debug] as? Bool {
                    configSettings[AppsFlyerConstants.Configuration.debug] = debugValue
                    debug = debugValue
                }
                if let disableNetworkData = payload[AppsFlyerConstants.Configuration.disableNetworkData] as? Bool {
                    configSettings[AppsFlyerConstants.Configuration.disableNetworkData] = disableNetworkData
                }
                if let anonymizeUser = payload[AppsFlyerConstants.Configuration.anonymizeUser] as? Bool {
                    configSettings[AppsFlyerConstants.Configuration.anonymizeUser] = anonymizeUser
                }
                if let minTimeBetweenSessions = payload[AppsFlyerConstants.Configuration.minTimeBetweenSessions] as? Int {
                    configSettings[AppsFlyerConstants.Configuration.minTimeBetweenSessions] = minTimeBetweenSessions
                }
                if let enableAppsetId = payload[AppsFlyerConstants.Configuration.enableAppsetId] as? Bool {
                    configSettings[AppsFlyerConstants.Configuration.enableAppsetId] = enableAppsetId
                }
                if let collectDeviceName = payload[AppsFlyerConstants.Configuration.collectDeviceName] as? Bool {
                    configSettings[AppsFlyerConstants.Configuration.collectDeviceName] = collectDeviceName
                }
                if let disableAdTracking = payload[AppsFlyerConstants.Configuration.disableAdTracking] as? Bool {
                    configSettings[AppsFlyerConstants.Configuration.disableAdTracking] = disableAdTracking
                }
                if let disableAppleAdTracking = payload[AppsFlyerConstants.Configuration.disableAppleAdTracking] as? Bool {
                    configSettings[AppsFlyerConstants.Configuration.disableAppleAdTracking] = disableAppleAdTracking
                }
                if let customData = payload[AppsFlyerConstants.Configuration.customData] as? [AnyHashable: Any] {
                    configSettings[AppsFlyerConstants.Configuration.customData] = customData
                }
                
                // Handle legacy nested settings structure for backward compatibility
                if let legacySettings = payload[AppsFlyerConstants.Configuration.settings] as? [String: Any] {
                    if configSettings.isEmpty {
                        // Use legacy structure if no flat config found
                        configSettings = legacySettings
                        if let settingsDebug = legacySettings[AppsFlyerConstants.Configuration.debug] as? Bool {
                            debug = settingsDebug
                        }
                    }
                }
                
                return appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: configSettings.isEmpty ? nil : configSettings)
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
            case .stopTracking:
                guard let stop = payload[AppsFlyerConstants.Parameters.stopTracking] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide stop_tracking parameter")
                    }
                    return
                }
                appsFlyerInstance.stopTracking(stop)
            case .resolveDeepLinkUrls:
                guard let deepLinkUrls = payload[AppsFlyerConstants.Parameters.deepLinkUrls] as? [String] else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)If you would like to resolve deep link urls, please set the af_deep_link variable in the AppDelegate or AppsFlyer Mobile Remote Command tag")
                    }
                    return
                }
                appsFlyerInstance.resolveDeepLinkURLs(deepLinkUrls)
            case .logAdRevenue:
                let monetizationNetwork = payload[AppsFlyerConstants.Parameters.adMonetizationNetwork] as? String
                let mediationNetwork = payload[AppsFlyerConstants.Parameters.adMediationNetwork] as? String
                let revenue = payload[AppsFlyerConstants.Parameters.adRevenue] as? Double
                let currency = payload[AppsFlyerConstants.Parameters.currency] as? String
                let additionalParameters = payload[AppsFlyerConstants.Parameters.adAdditionalParameters] as? [String: Any]
                appsFlyerInstance.logAdRevenue(monetizationNetwork: monetizationNetwork, mediationNetwork: mediationNetwork, revenue: revenue, currency: currency, additionalParameters: additionalParameters)
            case .setDMAConsent:
                let gdprApplies = payload[AppsFlyerConstants.Parameters.gdprApplies] as? Bool
                let consentForDataUsage = payload[AppsFlyerConstants.Parameters.consentForDataUsage] as? Bool
                let consentForAdsPersonalization = payload[AppsFlyerConstants.Parameters.consentForAdsPersonalization] as? Bool
                let consentForAdStorage = payload[AppsFlyerConstants.Parameters.consentForAdStorage] as? Bool
                appsFlyerInstance.setDMAConsent(gdprApplies: gdprApplies, consentForDataUsage: consentForDataUsage, consentForAdsPersonalization: consentForAdsPersonalization, consentForAdStorage: consentForAdStorage)
            case .enableAppsetId:
                guard let enable = payload[AppsFlyerConstants.Configuration.enableAppsetId] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide enable_appset_id parameter")
                    }
                    return
                }
                appsFlyerInstance.enableAppsetId(enable)
            case .setDisableNetworkData:
                guard let disable = payload[AppsFlyerConstants.Configuration.disableNetworkData] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide disable_network_data parameter")
                    }
                    return
                }
                appsFlyerInstance.setDisableNetworkData(disable)
            case .setPhoneNumber:
                guard let phoneNumber = payload[AppsFlyerConstants.Parameters.phoneNumber] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide phone_number parameter")
                    }
                    return
                }
                appsFlyerInstance.setPhoneNumber(phoneNumber)
            case .setOutOfStore:
                guard let source = payload[AppsFlyerConstants.Parameters.outOfStoreSource] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide out_of_store_source parameter")
                    }
                    return
                }
                appsFlyerInstance.setOutOfStore(source)
            case .addPushNotificationDeepLinkPath:
                guard let paths = payload[AppsFlyerConstants.Parameters.pushDeepLinkPath] as? [String] else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide push_deep_link_path parameter")
                    }
                    return
                }
                appsFlyerInstance.addPushNotificationDeepLinkPath(paths)
            case .sendPushNotificationData:
                guard let data = payload[AppsFlyerConstants.Parameters.pushPayload] as? [String: Any] else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide push notification data")
                    }
                    return
                }
                appsFlyerInstance.sendPushNotificationData(data)
            case .validateAndLogPurchase:
                let purchaseType = payload[AppsFlyerConstants.Parameters.purchaseType] as? String
                let token = payload[AppsFlyerConstants.Parameters.purchaseToken] as? String
                let productId = payload[AppsFlyerConstants.Parameters.productId] as? String
                let price = payload[AppsFlyerConstants.Parameters.price] as? String
                let currency = payload[AppsFlyerConstants.Parameters.purchaseCurrency] as? String
                let additionalParameters = payload[AppsFlyerConstants.Parameters.purchaseAdditionalParameters] as? [String: Any]
                appsFlyerInstance.validateAndLogPurchase(purchaseType: purchaseType, token: token, productId: productId, price: price, currency: currency, additionalParameters: additionalParameters)
            case .logSession:
                appsFlyerInstance.logSession()
            case .waitForCustomerUserId:
                guard let wait = payload[AppsFlyerConstants.Parameters.waitForCustomerUserId] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide wait_for_customer_user_id parameter")
                    }
                    return
                }
                appsFlyerInstance.waitForCustomerUserId(wait)
            case .setCustomerIdAndLogSession:
                guard let customerId = payload[AppsFlyerConstants.Parameters.customerId] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide customer_id parameter")
                    }
                    return
                }
                appsFlyerInstance.setCustomerIdAndLogSession(customerId)
            case .setMinTimeBetweenSessions:
                guard let seconds = payload[AppsFlyerConstants.Parameters.minTimeBetweenSessions] as? Int else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide min_time_between_sessions parameter")
                    }
                    return
                }
                appsFlyerInstance.setMinTimeBetweenSessions(seconds)
            case .setAppId:
                guard let appId = payload[AppsFlyerConstants.Parameters.appId] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide app_id parameter")
                    }
                    return
                }
                appsFlyerInstance.setAppId(appId)
            case .setDisableAdvertisingIdentifiers:
                guard let disable = payload[AppsFlyerConstants.Parameters.disableAdvertisingIdentifiers] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide disable_advertising_identifiers parameter")
                    }
                    return
                }
                appsFlyerInstance.setDisableAdvertisingIdentifiers(disable)
            case .enableTcfDataCollection:
                guard let enable = payload[AppsFlyerConstants.Parameters.enableTcfDataCollection] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide enable_tcf_data_collection parameter")
                    }
                    return
                }
                appsFlyerInstance.enableTcfDataCollection(enable)
            case .setSharingFilterForPartners:
                let partners = payload[AppsFlyerConstants.Parameters.sharingFilterPartners] as? [String]
                appsFlyerInstance.setSharingFilterForPartners(partners)
            case .updateServerUninstallToken:
                guard let token = payload[AppsFlyerConstants.Parameters.uninstallToken] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide uninstall_token parameter")
                    }
                    return
                }
                appsFlyerInstance.updateServerUninstallToken(token)
            case .setIsUpdate:
                guard let isUpdate = payload[AppsFlyerConstants.Parameters.isUpdate] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide is_update parameter")
                    }
                    return
                }
                appsFlyerInstance.setIsUpdate(isUpdate)
            case .setAdditionalData:
                guard let data = payload[AppsFlyerConstants.Parameters.additionalData] as? [String: Any] else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide additional_data parameter")
                    }
                    return
                }
                appsFlyerInstance.setAdditionalData(data)
            case .registerUninstall:
                // Handle device token for uninstall measurement
                // Device token can be passed as Data or String (hex representation)
                let deviceToken: Data?
                if let tokenData = payload[AppsFlyerConstants.Parameters.deviceToken] as? Data {
                    deviceToken = tokenData
                } else if let tokenString = payload[AppsFlyerConstants.Parameters.deviceToken] as? String {
                    // Convert hex string to Data if provided as string
                    deviceToken = Data(tokenString.utf8)
                } else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide device_token parameter for uninstall registration")
                    }
                    return
                }
                appsFlyerInstance.registerUninstall(deviceToken: deviceToken)
            case .setUseUninstallSandbox:
                guard let sandbox = payload[AppsFlyerConstants.Parameters.useUninstallSandbox] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must provide use_uninstall_sandbox parameter")
                    }
                    return
                }
                appsFlyerInstance.setUseUninstallSandbox(sandbox)
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
        return AppsFlyerConstants.EventCommandNames(rawValue: command.lowercased())?.rawValue ?? command
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
            $0.key != AppsFlyerConstants.Configuration.disableNetworkData &&
            $0.key != AppsFlyerConstants.Configuration.enableAppsetId &&
            $0.key != AppsFlyerConstants.Configuration.minTimeBetweenSessions &&
            $0.key != AppsFlyerConstants.Configuration.collectDeviceName &&
            $0.key != AppsFlyerConstants.Configuration.disableAdTracking &&
            $0.key != AppsFlyerConstants.Configuration.disableAppleAdTracking &&
            $0.key != AppsFlyerConstants.Configuration.customData
        }
    }
}
