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

    /// Constructs a RemoteCommand that integrates with the AppsFlyer SDK.
    /// - Parameters:
    ///   - appsFlyerInstance: Optional implementation of `AppsFlyerCommand` (for testing).
    ///   - type: The RemoteCommand type (webview or JSON).
    ///   - logLevel: Controls RC log verbosity. Defaults to `.silent` (no output).
    public init(appsFlyerInstance: AppsFlyerCommand = AppsFlyerInstance(),
                type: RemoteCommandType = .webview,
                logLevel: RemoteCommandLogLevel = .silent) {
        RemoteCommandLogger.logLevel = logLevel
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
        parseCommands(appsflyerCommands, payload: payload)
    }

    /// Calls the individual commands consecutively with optional parameters from the payload object.
    /// Validation errors thrown by execute methods are caught here and forwarded to the logger.
    func parseCommands(_ commands: [String], payload: [String: Any]) {
        commands.forEach { commandString in
            let command = AppsFlyerConstants.CommandNames.fromString(commandString)
            do {
                switch command {
                case .initialize:
                    try executeInitialize(payload)
                case .trackLocation:
                    try executeTrackLocation(payload)
                case .setHost:
                    try executeSetHost(payload)
                case .setUserEmails:
                    try executeSetUserEmails(payload)
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
                case .none:
                    // Unknown command falls back to a standard or custom AppsFlyer event.
                    appsFlyerInstance.logEvent(getEventName(command: commandString),
                                               values: getEventParameters(payload: payload))
                }
            } catch let error as AppsFlyerCommandError {
                RemoteCommandLogger.error("Command '\(commandString)' failed: \(error.message)")
            } catch {
                RemoteCommandLogger.error("Command '\(commandString)' failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Command execution methods

    private func executeInitialize(_ payload: [String: Any]) throws {
        guard let appId = payload[AppsFlyerConstants.Configuration.appId.rawValue] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Configuration.appId.rawValue)
        }
        guard let appDevKey = payload[AppsFlyerConstants.Configuration.appDevKey.rawValue] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Configuration.appDevKey.rawValue)
        }
        guard var settings = payload[AppsFlyerConstants.Configuration.settings.rawValue] as? [String: Any] else {
            RemoteCommandLogger.debug("Initializing AppsFlyer without settings")
            return appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: nil)
        }

        if let deepLinkTimeout = settings[AppsFlyerConstants.Settings.deepLinkTimeout] as? Int,
           deepLinkTimeout < 0 {
            RemoteCommandLogger.warning("deepLinkTimeout must be >= 0, got: \(deepLinkTimeout). Ignoring setting.")
            settings.removeValue(forKey: AppsFlyerConstants.Settings.deepLinkTimeout)
        }

        RemoteCommandLogger.debug("Initializing AppsFlyer with settings")
        appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: settings)
    }

    private func executeTrackLocation(_ payload: [String: Any]) throws {
        if let latitude = payload[AppsFlyerConstants.Parameters.latitude] as? Double,
           let longitude = payload[AppsFlyerConstants.Parameters.longitude] as? Double {
            appsFlyerInstance.logLocation(longitude: longitude, latitude: latitude)
            return
        }
        if let latitude = payload[AppsFlyerConstants.Parameters.latitude] as? Int,
           let longitude = payload[AppsFlyerConstants.Parameters.longitude] as? Int {
            appsFlyerInstance.logLocation(longitude: Double(longitude), latitude: Double(latitude))
            return
        }
        if payload[AppsFlyerConstants.Parameters.latitude] == nil {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.latitude)
        }
        if payload[AppsFlyerConstants.Parameters.longitude] == nil {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.longitude)
        }
        throw AppsFlyerCommandError.invalidParameterType(
            parameter: "\(AppsFlyerConstants.Parameters.latitude)/\(AppsFlyerConstants.Parameters.longitude)",
            expectedTypes: "Double or Int"
        )
    }

    private func executeSetHost(_ payload: [String: Any]) throws {
        guard let host = payload[AppsFlyerConstants.Parameters.host] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.host)
        }
        guard let hostPrefix = payload[AppsFlyerConstants.Parameters.hostPrefix] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.hostPrefix)
        }
        appsFlyerInstance.setHost(host, with: hostPrefix)
    }

    private func executeSetUserEmails(_ payload: [String: Any]) throws {
        var payload = payload
        if let email = payload[AppsFlyerConstants.Parameters.emails] as? String {
            payload[AppsFlyerConstants.Parameters.emails] = [email]
        }
        guard let emails = payload[AppsFlyerConstants.Parameters.emails] as? [String] else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.emails)
        }
        guard let cryptType = payload[AppsFlyerConstants.Parameters.cryptType] as? Int else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.cryptType)
        }
        appsFlyerInstance.setUserEmails(emails: emails, with: cryptType)
    }

    private func executeSetCurrencyCode(_ payload: [String: Any]) throws {
        guard let currency = payload[AppsFlyerConstants.Parameters.currency] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.currency)
        }
        appsFlyerInstance.currencyCode(currency)
    }

    private func executeSetCustomerId(_ payload: [String: Any]) throws {
        guard let customerId = payload[AppsFlyerConstants.Parameters.customerId] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.customerId)
        }
        appsFlyerInstance.customerId(customerId)
    }

    private func executeDisableTracking(_ payload: [String: Any]) throws {
        guard let disable = payload[AppsFlyerConstants.Parameters.stopTracking] as? Bool else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.stopTracking)
        }
        appsFlyerInstance.disableTracking(disable)
    }

    private func executeAnonymizeUser(_ payload: [String: Any]) throws {
        guard let anonymize = payload[AppsFlyerConstants.Parameters.anonymizeUser] as? Bool else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.anonymizeUser)
        }
        appsFlyerInstance.anonymizeUser(anonymize)
    }

    private func executeResolveDeepLinkUrls(_ payload: [String: Any]) throws {
        let deepLinkUrls = (payload[AppsFlyerConstants.Parameters.deepLinkUrls] as? [String])
            ?? (payload[AppsFlyerConstants.Parameters.deepLinkUrlsLegacyTiQ] as? [String])
        guard let urls = deepLinkUrls else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.deepLinkUrls)
        }
        appsFlyerInstance.resolveDeepLinkURLs(urls)
    }

    private func executeSetPhoneNumber(_ payload: [String: Any]) throws {
        guard let phoneNumber = payload[AppsFlyerConstants.Parameters.phoneNumber] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.phoneNumber)
        }
        appsFlyerInstance.setPhoneNumber(phoneNumber)
    }

    private func executeLogAdRevenue(_ payload: [String: Any]) throws {
        guard let monetizationNetwork = payload[AppsFlyerConstants.Parameters.monetizationNetwork] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.monetizationNetwork)
        }
        guard let mediationNetwork = payload[AppsFlyerConstants.Parameters.mediationNetwork] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.mediationNetwork)
        }
        guard let currency = payload[AppsFlyerConstants.Parameters.adRevenueCurrency] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.adRevenueCurrency)
        }
        guard let revenue = payload[AppsFlyerConstants.Parameters.adRevenueAmount] as? Double else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.adRevenueAmount)
        }
        guard let mediationNetworkType = MediationNetworkType(mediationNetwork) else {
            throw AppsFlyerCommandError.invalidParameterValue(
                parameter: AppsFlyerConstants.Parameters.mediationNetwork,
                value: mediationNetwork,
                allowedValues: MediationNetworkType.validValues
            )
        }

        let additionalParams = payload[AppsFlyerConstants.Parameters.adRevenueAdditionalParams] as? [String: Any]

        appsFlyerInstance.logAdRevenue(
            monetizationNetwork: monetizationNetwork,
            mediationNetworkType: mediationNetworkType,
            currency: currency,
            revenue: revenue,
            additionalParams: additionalParams
        )
    }

    private func executeSetConsentData(_ payload: [String: Any]) throws {
        guard let isUserSubjectToGDPR = payload[AppsFlyerConstants.Parameters.isUserSubjectToGDPR] as? Bool else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.isUserSubjectToGDPR)
        }
        guard let hasConsentForDataUsage = payload[AppsFlyerConstants.Parameters.hasConsentForDataUsage] as? Bool else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.hasConsentForDataUsage)
        }
        guard let hasConsentForAdsPersonalization = payload[AppsFlyerConstants.Parameters.hasConsentForAdsPersonalization] as? Bool else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.hasConsentForAdsPersonalization)
        }
        guard let hasConsentForAdStorage = payload[AppsFlyerConstants.Parameters.hasConsentForAdStorage] as? Bool else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.hasConsentForAdStorage)
        }

        appsFlyerInstance.setConsentData(
            isUserSubjectToGDPR: isUserSubjectToGDPR,
            hasConsentForDataUsage: hasConsentForDataUsage,
            hasConsentForAdsPersonalization: hasConsentForAdsPersonalization,
            hasConsentForAdStorage: hasConsentForAdStorage
        )
    }

    private func executeSetPartnerData(_ payload: [String: Any]) throws {
        guard let partnerId = payload[AppsFlyerConstants.Parameters.partnerId] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.partnerId)
        }

        let partnerInfo = payload[AppsFlyerConstants.Parameters.partnerInfo] as? [String: Any]

        appsFlyerInstance.setPartnerData(partnerId: partnerId, partnerInfo: partnerInfo)
    }

    private func executeSetSharingFilterForPartners(_ payload: [String: Any]) {
        // A nil / missing sharing_filter resets the filter — this is valid behavior, not an error.
        let sharingFilter = payload[AppsFlyerConstants.Parameters.sharingFilter] as? [String]
        appsFlyerInstance.setSharingFilterForPartners(sharingFilter)
    }

    private func executeSetCurrentDeviceLanguage(_ payload: [String: Any]) throws {
        guard let language = payload[AppsFlyerConstants.Parameters.deviceLanguage] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.deviceLanguage)
        }
        appsFlyerInstance.setCurrentDeviceLanguage(language)
    }

    private func executeHandleOpen(_ payload: [String: Any]) throws {
        guard let urlString = payload[AppsFlyerConstants.Parameters.url] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.url)
        }
        guard let url = URL(string: urlString), url.scheme != nil else {
            throw AppsFlyerCommandError.invalidParameterValue(
                parameter: AppsFlyerConstants.Parameters.url,
                value: urlString,
                allowedValues: ["a valid URL with scheme"]
            )
        }
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
