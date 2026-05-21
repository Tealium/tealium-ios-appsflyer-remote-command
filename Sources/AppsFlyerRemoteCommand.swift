//
//  AppsFlyerRemoteCommand.swift
//  TealiumAppsFlyer
//
//  Created by Christina S on 5/29/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation
import UIKit
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
    ///   - logLevel: Controls RC log verbosity. Defaults to `.silent` (no output).
    public init(appsFlyerInstance: AppsFlyerCommand? = nil,
                type: RemoteCommandType = .webview,
                logLevel: RemoteCommandLogLevel = .silent) {
        let logger = RemoteCommandLogger(logLevel: logLevel)
        self.logger = logger
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
        let commands = command.split(separator: AppsFlyerConstants.separator)
        let appsflyerCommands = commands.map { command in
            return command.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        parseCommands(appsflyerCommands, payload: payload)
    }

    /// Calls each command in sequence; validation errors are caught and forwarded to the logger.
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
                case .setAppInviteOneLink:
                    try executeSetAppInviteOneLink(payload)
                case nil:
                    // Unknown command falls back to a standard or custom AppsFlyer event.
                    appsFlyerInstance.logEvent(getEventName(command: commandString),
                                               values: getEventParameters(payload: payload))
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
        guard let appId = payload[AppsFlyerConstants.Configuration.appId.rawValue] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Configuration.appId.rawValue)
        }
        guard let appDevKey = payload[AppsFlyerConstants.Configuration.appDevKey.rawValue] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Configuration.appDevKey.rawValue)
        }
        guard var settings = payload[AppsFlyerConstants.Configuration.settings.rawValue] as? [String: Any] else {
            logger.debug("Initializing AppsFlyer without settings")
            return appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: nil)
        }

        if let deepLinkTimeout = settings[AppsFlyerConstants.Settings.deepLinkTimeout] as? Int,
           deepLinkTimeout < 0 {
            logger.warning("deepLinkTimeout must be >= 0, got: \(deepLinkTimeout). Ignoring setting.")
            settings.removeValue(forKey: AppsFlyerConstants.Settings.deepLinkTimeout)
        }

        logger.debug("Initializing AppsFlyer with settings")
        appsFlyerInstance.initialize(appId: appId, appDevKey: appDevKey, settings: settings)
    }

    private func executeTrackLocation(_ payload: [String: Any]) throws {
        guard let latitude = payload[AppsFlyerConstants.Parameters.latitude] as? Double else {
            throw AppsFlyerCommandError.invalidParameterType(parameter: AppsFlyerConstants.Parameters.latitude, expectedTypes: "Double")
        }
        guard let longitude = payload[AppsFlyerConstants.Parameters.longitude] as? Double else {
            throw AppsFlyerCommandError.invalidParameterType(parameter: AppsFlyerConstants.Parameters.longitude, expectedTypes: "Double")
        }
        appsFlyerInstance.logLocation(longitude: longitude, latitude: latitude)
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
        guard let emails = payload[AppsFlyerConstants.Parameters.emails] as? [String] else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.emails)
        }
        guard let cryptTypeInt = payload[AppsFlyerConstants.Parameters.cryptType] as? Int else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.cryptType)
        }
        guard let cryptType = EmailCryptType(rawInt: cryptTypeInt) else {
            throw AppsFlyerCommandError.invalidParameterValue(
                parameter: AppsFlyerConstants.Parameters.cryptType,
                value: "\(cryptTypeInt)",
                allowedValues: EmailCryptType.validValues.map { "\($0)" }
            )
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

        let adRevenueData = AFAdRevenueData(
            monetizationNetwork: monetizationNetwork,
            mediationNetwork: mediationNetworkType,
            currencyIso4217Code: currency,
            eventRevenue: NSNumber(value: revenue)
        )
        appsFlyerInstance.logAdRevenue(adRevenueData, additionalParams: additionalParams)
    }

    private func executeSetConsentData(_ payload: [String: Any]) throws {
        guard let isUserSubjectToGDPR = payload[AppsFlyerConstants.Parameters.isUserSubjectToGDPR] as? Bool else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.isUserSubjectToGDPR)
        }
        let hasConsentForDataUsage = payload[AppsFlyerConstants.Parameters.hasConsentForDataUsage] as? Bool
        let hasConsentForAdsPersonalization = payload[AppsFlyerConstants.Parameters.hasConsentForAdsPersonalization] as? Bool
        let hasConsentForAdStorage = payload[AppsFlyerConstants.Parameters.hasConsentForAdStorage] as? Bool

        let consent = AppsFlyerConsent(
            isUserSubjectToGDPR: isUserSubjectToGDPR as NSNumber,
            hasConsentForDataUsage: hasConsentForDataUsage as NSNumber?,
            hasConsentForAdsPersonalization: hasConsentForAdsPersonalization as NSNumber?,
            hasConsentForAdStorage: hasConsentForAdStorage as NSNumber?
        )
        appsFlyerInstance.setConsentData(consent)
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

    private func executeSetAppInviteOneLink(_ payload: [String: Any]) throws {
        guard let oneLinkId = payload[AppsFlyerConstants.Parameters.appInviteOneLinkID] as? String else {
            throw AppsFlyerCommandError.missingParameter(AppsFlyerConstants.Parameters.appInviteOneLinkID)
        }
        appsFlyerInstance.setAppInviteOneLink(oneLinkId)
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
        let optionsDict = payload[AppsFlyerConstants.Parameters.options] as? [String: Any]
        let sourceApplication = payload[AppsFlyerConstants.Parameters.sourceApplication] as? String
        let annotation = payload[AppsFlyerConstants.Parameters.annotation]

        // Prefer the options-based overload when `options` is present.
        // Fall back to the legacy overload for cross-platform payloads that supply sourceApplication/annotation instead.
        if let optionsDict = optionsDict {
            let openURLOptions = Dictionary(uniqueKeysWithValues: optionsDict.map { key, value in
                (UIApplication.OpenURLOptionsKey(rawValue: key), value)
            })
            appsFlyerInstance.handleOpen(url: url, options: openURLOptions)
        } else {
            appsFlyerInstance.handleOpen(url: url, sourceApplication: sourceApplication, annotation: annotation)
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
        let excludedKeys: Set<String> = ["method", AppsFlyerConstants.commandName, AppsFlyerConstants.Settings.debug]
        let configurationKeys = Set(AppsFlyerConstants.Configuration.allCases.map { $0.rawValue })
        return excludedKeys.union(configurationKeys)
    }()

    func filterVariables() -> [String: Any] {
        return self.filter { !Self.allExcludedKeys.contains($0.key) }
    }

}
