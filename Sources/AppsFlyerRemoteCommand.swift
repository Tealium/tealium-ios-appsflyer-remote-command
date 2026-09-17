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
    private let logger: RemoteCommandLogger

    public override var version: String? {
        return AppsFlyerConstants.version
    }

    /// Host apps call this from wherever they happen to be — typically `AppDelegate`, on the main
    /// thread — so hop onto the queue `AppsFlyerInstance` expects.
    public func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void) {
        TealiumQueues.backgroundSerialQueue.async {
            self.appsFlyerInstance.onReady(onReady)
        }
    }

    /// Constructs a RemoteCommand that integrates with the AppsFlyer SDK.
    /// - Parameters:
    ///   - appsFlyerInstance: Optional `AppsFlyerCommand` implementation. Pass an
    ///     `AppsFlyerInstance(tealium:)` here to enable attribution callback tracking
    ///     (onConversionDataSuccess etc.). Defaults to a logger-only instance with
    ///     no attribution tracking.
    ///   - type: The RemoteCommand type (webview or JSON).
    ///   - logLevel: Controls RC log verbosity. Defaults to `.error` (errors only).
    public init(appsFlyerInstance: AppsFlyerCommand? = nil,
                type: RemoteCommandType = .webview,
                logLevel: RemoteCommandLogLevel = .error) {
        self.logger = RemoteCommandLogger(logLevel: logLevel)
        self.appsFlyerInstance = appsFlyerInstance ?? AppsFlyerInstance(logger: logger)
        weak var weakSelf: AppsFlyerRemoteCommand?
        super.init(commandId: AppsFlyerConstants.commandId,
                   description: AppsFlyerConstants.description,
                   type: type,
                   completion: { response in
            guard let payload = response.payload else {
                return
            }
            weakSelf?.processRemoteCommand(with: payload)
        })
        weakSelf = self
    }

    func processRemoteCommand(with payload: [String: Any]) {
        guard let command = payload[AppsFlyerConstants.commandName] as? String else {
            return
        }
        // Trimmed here rather than relying on `CommandNames.fromString`, because an unresolved
        // command is passed on as an event name and `getEventName` does not trim.
        let commands = command.split(separator: AppsFlyerConstants.separator)
        let appsflyerCommands = commands.map { command in
            return command.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        executeCommands(appsflyerCommands, payload: payload)
    }

    /// Runs each command in the order given; validation errors are caught and sent to the logger.
    func executeCommands(_ commands: [String], payload: [String: Any]) {
        commands.forEach { commandString in
            guard let command = AppsFlyerConstants.CommandNames.fromString(commandString) else {
                // Not a built-in command, so treat it as a standard or custom AppsFlyer event.
                appsFlyerInstance.logEvent(getEventName(command: commandString),
                                           values: getEventParameters(payload: payload))
                return
            }
            do {
                logger.debug("Executing command: \(commandString)")
                switch command {
                case .initialize:
                    try executeInitialize(payload)
                case .trackLocation:
                    try executeTrackLocation(payload)
                case .setHost:
                    try executeSetHost(payload)
                case .setUserEmail:
                    try executeSetUserEmail(payload)
                case .setUserFirstName:
                    try executeSetUserFirstName(payload)
                case .setUserLastName:
                    try executeSetUserLastName(payload)
                case .setUserFbLoginId:
                    try executeSetUserFbLoginId(payload)
                case .clearUserPii:
                    appsFlyerInstance.clearUserPii()
                case .setCurrencyCode:
                    try executeSetCurrencyCode(payload)
                case .setCustomerId:
                    try executeSetCustomerId(payload)
                case .disableTracking, .stopTracking: // stopTracking is the Android command name accepted here for cross-platform payloads
                    try executeDisableTracking(payload)
                case .anonymizeUser, .disableDeviceTracking: // disableDeviceTracking is a backwards-compatible alias
                    try executeAnonymizeUser(payload)
                case .resolveDeepLinkUrls:
                    try executeResolveDeepLinkUrls(payload)
                case .setPhoneNumber:
                    try executeSetPhoneNumber(payload)
                case .logAdRevenue:
                    try executeLogAdRevenue(payload)
                case .setConsentData:
                    try executeSetConsentData(payload)
                case .setPartnerData:
                    try executeSetPartnerData(payload)
                case .setSharingFilterForPartners:
                    executeSetSharingFilterForPartners(payload)
                case .handleOpen:
                    try executeHandleOpen(payload)
                case .start:
                    appsFlyerInstance.start()
                case .setCurrentDeviceLanguage:
                    try executeSetCurrentDeviceLanguage(payload)
                case .setAppInviteOneLink:
                    try executeSetAppInviteOneLink(payload)
                }
            } catch let error as AppsFlyerCommandError {
                logger.error("Command '\(commandString)' failed: \(error.message)")
            } catch {
                logger.error("Command '\(commandString)' failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Command execution methods

    private func executeInitialize(_ payload: [String: Any]) throws {
        let appId = try payload.requireParameter(AppsFlyerConstants.Configuration.appId.rawValue, as: String.self)
        let appDevKey = try payload.requireParameter(AppsFlyerConstants.Configuration.appDevKey.rawValue, as: String.self)
        guard var settings = payload[AppsFlyerConstants.Configuration.settings.rawValue] as? [String: Any] else {
            logger.debug("Initializing AppsFlyer without settings")
            return appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: nil)
        }

        // The SDK takes both as `UInt`, so a negative value would trap on conversion.
        dropNegative(AppsFlyerConstants.Settings.deepLinkTimeout, from: &settings)
        dropNegative(AppsFlyerConstants.Settings.minTimeBetweenSessions, from: &settings)

        logger.debug("Initializing AppsFlyer with settings")
        appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: settings)
    }

    private func dropNegative(_ key: String, from settings: inout [String: Any]) {
        guard let value = settings[key] as? Int, value < 0 else {
            return
        }
        logger.warning("\(key) must be >= 0, got: \(value). Ignoring setting.")
        settings.removeValue(forKey: key)
    }

    private func executeTrackLocation(_ payload: [String: Any]) throws {
        let latitude = try payload.requireDouble(AppsFlyerConstants.Parameters.latitude)
        let longitude = try payload.requireDouble(AppsFlyerConstants.Parameters.longitude)
        appsFlyerInstance.logLocation(longitude: longitude, latitude: latitude)
    }

    private func executeSetHost(_ payload: [String: Any]) throws {
        let host = try payload.requireParameter(AppsFlyerConstants.Parameters.host, as: String.self)
        let hostPrefix = try payload.requireParameter(AppsFlyerConstants.Parameters.hostPrefix, as: String.self)
        appsFlyerInstance.setHost(host, with: hostPrefix)
    }

    private func executeSetUserEmail(_ payload: [String: Any]) throws {
        let email = try payload.requireParameter(AppsFlyerConstants.Parameters.email, as: String.self)
        appsFlyerInstance.setUserEmail(email)
    }

    private func executeSetUserFirstName(_ payload: [String: Any]) throws {
        let firstName = try payload.requireParameter(AppsFlyerConstants.Parameters.firstName, as: String.self)
        appsFlyerInstance.setUserFirstName(firstName)
    }

    private func executeSetUserLastName(_ payload: [String: Any]) throws {
        let lastName = try payload.requireParameter(AppsFlyerConstants.Parameters.lastName, as: String.self)
        appsFlyerInstance.setUserLastName(lastName)
    }

    private func executeSetUserFbLoginId(_ payload: [String: Any]) throws {
        let fbLoginId = try payload.requireInt64(AppsFlyerConstants.Parameters.fbLoginId)
        appsFlyerInstance.setUserFbLoginId(fbLoginId)
    }

    private func executeSetCurrencyCode(_ payload: [String: Any]) throws {
        let currency = try payload.requireParameter(AppsFlyerConstants.Parameters.currency, as: String.self)
        appsFlyerInstance.currencyCode(currency)
    }

    private func executeSetCustomerId(_ payload: [String: Any]) throws {
        let customerId = try payload.requireParameter(AppsFlyerConstants.Parameters.customerId, as: String.self)
        appsFlyerInstance.customerId(customerId)
    }

    private func executeDisableTracking(_ payload: [String: Any]) throws {
        let disable = try payload.requireParameter(AppsFlyerConstants.Parameters.stopTracking, as: Bool.self)
        appsFlyerInstance.disableTracking(disable)
    }

    private func executeAnonymizeUser(_ payload: [String: Any]) throws {
        let anonymize = try payload.requireParameter(AppsFlyerConstants.Parameters.anonymizeUser, as: Bool.self)
        appsFlyerInstance.anonymizeUser(anonymize)
    }

    private func executeResolveDeepLinkUrls(_ payload: [String: Any]) throws {
        // Reports against whichever key the tag actually mapped, falling back to the canonical one
        // so an absent parameter is not blamed on the legacy TiQ alias.
        let key = [AppsFlyerConstants.Parameters.deepLinkUrls,
                   AppsFlyerConstants.Parameters.deepLinkUrlsLegacyTiQ].first { payload[$0] != nil }
            ?? AppsFlyerConstants.Parameters.deepLinkUrls
        let urls = try payload.requireParameter(key, as: [String].self)
        appsFlyerInstance.resolveDeepLinkURLs(urls)
    }

    private func executeSetPhoneNumber(_ payload: [String: Any]) throws {
        let countryCode = try payload.requireParameter(AppsFlyerConstants.Parameters.countryCode, as: String.self)
        let phoneNumber = try payload.requireParameter(AppsFlyerConstants.Parameters.phoneNumber, as: String.self)
        appsFlyerInstance.setUserPhone(countryCode: countryCode, phoneNumber: phoneNumber)
    }

    private func executeLogAdRevenue(_ payload: [String: Any]) throws {
        let monetizationNetwork = try payload.requireParameter(AppsFlyerConstants.Parameters.monetizationNetwork, as: String.self)
        let mediationNetwork = try payload.requireParameter(AppsFlyerConstants.Parameters.mediationNetwork, as: String.self)
        let currency = try payload.requireParameter(AppsFlyerConstants.Parameters.adRevenueCurrency, as: String.self)
        let revenue = try payload.requireDouble(AppsFlyerConstants.Parameters.adRevenueAmount)
        guard let mediationNetworkType = MediationNetworkType(mediationNetwork) else {
            throw AppsFlyerCommandError.invalidParameterValue(
                parameter: AppsFlyerConstants.Parameters.mediationNetwork,
                value: mediationNetwork,
                allowedValues: MediationNetworkType.validValues
            )
        }

        let additionalParams = payload[AppsFlyerConstants.Parameters.adRevenueAdditionalParams] as? [String: Any]

        let adRevenueData = AFAdRevenueData(
            monetizationNetwork: monetizationNetwork,
            mediationNetwork: mediationNetworkType,
            currencyIso4217Code: currency,
            eventRevenue: NSNumber(value: revenue)
        )
        appsFlyerInstance.logAdRevenue(adRevenueData, additionalParams: additionalParams)
    }

    /// AppsFlyer documents the call order as initialize, `setConsentData()`, then `start()`:
    /// https://dev.appsflyer.com/hc/docs/ios-send-consent-for-dma-compliance
    /// Not gated on `onReady`, which fires after `start()` and would invert that order.
    ///
    /// `is_user_subject_to_gdpr` is required, the three consent details are optional, and fields
    /// left unmapped are omitted from the `consent_data` the SDK sends rather than defaulted.
    private func executeSetConsentData(_ payload: [String: Any]) throws {
        let isUserSubjectToGDPR = try payload.requireParameter(AppsFlyerConstants.Parameters.isUserSubjectToGDPR, as: Bool.self)
        let hasConsentForDataUsage = payload[AppsFlyerConstants.Parameters.hasConsentForDataUsage] as? Bool
        let hasConsentForAdsPersonalization = payload[AppsFlyerConstants.Parameters.hasConsentForAdsPersonalization] as? Bool
        let hasConsentForAdStorage = payload[AppsFlyerConstants.Parameters.hasConsentForAdStorage] as? Bool

        // AppsFlyer: "If the GDPR does not apply to the user isUserSubjectToGDPR is false and the
        // rest of the parameters must be null."
        // https://dev.appsflyer.com/hc/docs/android-send-consent-for-dma-compliance
        // Warned rather than dropped, so a deliberate mapping is never silently discarded.
        if !isUserSubjectToGDPR, hasConsentForDataUsage != nil || hasConsentForAdsPersonalization != nil
            || hasConsentForAdStorage != nil {
            logger.warning("\(AppsFlyerConstants.Parameters.isUserSubjectToGDPR) is false, so AppsFlyer expects the other consent parameters to be unmapped.")
        }

        let consent = AppsFlyerConsent(
            isUserSubjectToGDPR: isUserSubjectToGDPR as NSNumber,
            hasConsentForDataUsage: hasConsentForDataUsage as NSNumber?,
            hasConsentForAdsPersonalization: hasConsentForAdsPersonalization as NSNumber?,
            hasConsentForAdStorage: hasConsentForAdStorage as NSNumber?
        )
        appsFlyerInstance.setConsentData(consent)
    }

    private func executeSetPartnerData(_ payload: [String: Any]) throws {
        let partnerId = try payload.requireParameter(AppsFlyerConstants.Parameters.partnerId, as: String.self)

        let partnerInfo = payload[AppsFlyerConstants.Parameters.partnerInfo] as? [String: Any]

        appsFlyerInstance.setPartnerData(partnerId: partnerId, partnerInfo: partnerInfo)
    }

    private func executeSetSharingFilterForPartners(_ payload: [String: Any]) {
        // A nil / missing sharing_filter resets the filter — this is valid behavior, not an error.
        let sharingFilter = payload[AppsFlyerConstants.Parameters.sharingFilter] as? [String]
        appsFlyerInstance.setSharingFilterForPartners(sharingFilter)
    }

    private func executeSetCurrentDeviceLanguage(_ payload: [String: Any]) throws {
        let language = try payload.requireParameter(AppsFlyerConstants.Parameters.deviceLanguage, as: String.self)
        appsFlyerInstance.setCurrentDeviceLanguage(language)
    }

    private func executeSetAppInviteOneLink(_ payload: [String: Any]) throws {
        let oneLinkId = try payload.requireParameter(AppsFlyerConstants.Parameters.appInviteOneLinkID, as: String.self)
        appsFlyerInstance.setAppInviteOneLink(oneLinkId)
    }

    private func executeHandleOpen(_ payload: [String: Any]) throws {
        let urlString = try payload.requireParameter(AppsFlyerConstants.Parameters.url, as: String.self)
        guard let url = URL(string: urlString), url.scheme != nil else {
            throw AppsFlyerCommandError.invalidParameterValue(
                parameter: AppsFlyerConstants.Parameters.url,
                value: urlString,
                allowedValues: ["a valid URL with scheme"]
            )
        }
        // Fed by Tealium's automatic deep link tracking, which supplies the URL and the
        // source application. Annotations are not in the data layer yet, so they stay optional.
        let sourceApplication = payload[AppsFlyerConstants.Parameters.sourceApplication] as? String
        let annotation = payload[AppsFlyerConstants.Parameters.annotation]
        appsFlyerInstance.handleOpen(url: url, sourceApplication: sourceApplication, annotation: annotation)
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

extension Dictionary where Key == String, Value == Any {

    /// Reads a required parameter, reporting an unmapped key separately from one mapped to the
    /// wrong type — the log then says which of the two the tag needs fixing.
    func requireParameter<T>(_ parameter: String, as: T.Type) throws -> T {
        guard let value = self[parameter] else {
            throw AppsFlyerCommandError.missingParameter(parameter)
        }
        guard let typedValue = value as? T else {
            throw AppsFlyerCommandError.invalidParameterType(parameter: parameter,
                                                             expectedTypes: "\(T.self)")
        }
        return typedValue
    }

    /// JSON payloads carry `NSNumber`, which bridges to both `Double` and `Int`, but a payload
    /// built in Swift carries a native number that only bridges to its own type — so `af_lat: 33`
    /// needs the `Int` fallback to be accepted.
    func requireDouble(_ parameter: String) throws -> Double {
        guard let value = self[parameter] else {
            throw AppsFlyerCommandError.missingParameter(parameter)
        }
        guard let double = value as? Double ?? (value as? Int).map(Double.init) else {
            throw AppsFlyerCommandError.invalidParameterType(parameter: parameter,
                                                             expectedTypes: "Double or Int")
        }
        return double
    }

    /// `setUserFbLoginId` takes an `Int64`. A JSON payload brings `NSNumber`, which bridges to both,
    /// while a Swift-built payload brings a native `Int` — so the `Int` fallback is needed, as in
    /// `requireDouble` above. The `String` fallback covers webview data layer values, which arrive
    /// as strings even for numeric UDO variables.
    func requireInt64(_ parameter: String) throws -> Int64 {
        guard let value = self[parameter] else {
            throw AppsFlyerCommandError.missingParameter(parameter)
        }
        guard let int64 = value as? Int64
                ?? (value as? Int).map(Int64.init)
                ?? (value as? String).flatMap(Int64.init) else {
            throw AppsFlyerCommandError.invalidParameterType(parameter: parameter,
                                                             expectedTypes: "Int64, Int or numeric String")
        }
        return int64
    }

    private static let allExcludedKeys: Set<String> = {
        let excludedKeys: Set<String> = ["method", AppsFlyerConstants.commandName,
                                         AppsFlyerConstants.Settings.debug]
        let configurationKeys = Set(AppsFlyerConstants.Configuration.allCases.map { $0.rawValue })
        return excludedKeys.union(configurationKeys)
    }()

    func filterVariables() -> [String: Any] {
        return self.filter { !Self.allExcludedKeys.contains($0.key) }
    }

}
