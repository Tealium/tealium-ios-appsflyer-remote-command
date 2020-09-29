//
//  AppsFlyerRemoteCommand.swift
//  TealiumAppsFlyer
//
//  Created by Christina S on 5/29/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation
#if COCOAPODS
    import TealiumSwift
#else
    import TealiumCore
    import TealiumTagManagement
    import TealiumRemoteCommands
#endif

public class AppsFlyerRemoteCommand: RemoteCommand {

    let appsFlyerCommandTracker: AppsFlyerTrackable?

    public init(appsFlyerCommandTracker: AppsFlyerTrackable = AppsFlyerCommandTracker(), type: RemoteCommandType = .webview) {
        self.appsFlyerCommandTracker = appsFlyerCommandTracker
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
        guard let appsFlyerCommandTracker = appsFlyerCommandTracker,
              let command = payload[AppsFlyerConstants.commandName] as? String else {
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
                    return appsFlyerCommandTracker.initialize(appId: appId, appDevKey: appDevKey, settings: nil)
                }
                if let settingsDebug = settings[AppsFlyerConstants.Configuration.debug] as? Bool {
                    debug = settingsDebug
                }
                return appsFlyerCommandTracker.initialize(appId: appId, appDevKey: appDevKey, settings: settings)
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
                    return appsFlyerCommandTracker.logLocation(longitude: Double(longitude), latitude: Double(latitude))
                }
                appsFlyerCommandTracker.logLocation(longitude: longitude, latitude: latitude)
            case .setHost:
                guard let host = payload[AppsFlyerConstants.Parameters.host] as? String,
                    let hostPrefix = payload[AppsFlyerConstants.Parameters.hostPrefix] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must map host and host_prefix in the AppsFlyer Mobile Remote Command tag to set host")

                    }
                    return
                }
                appsFlyerCommandTracker.setHost(host, with: hostPrefix)
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
                appsFlyerCommandTracker.setUserEmails(emails: emails, with: cryptType)
            case .setCurrencyCode:
                guard let currency = payload[AppsFlyerConstants.Parameters.currency] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must map af_currency in the AppsFlyer Mobile Remote Command tag to call set currency")
                    }
                    return
                }
                appsFlyerCommandTracker.currencyCode(currency)
            case .setCustomerId:
                guard let customerId = payload[AppsFlyerConstants.Parameters.customerId] as? String else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)Must map af_customer_user_id in the AppsFlyer Mobile Remote Command tag to call set customer id")
                    }
                    return
                }
                appsFlyerCommandTracker.customerId(customerId)
            case .disableTracking:
                guard let disable = payload[AppsFlyerConstants.Parameters.stopTracking] as? Bool else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)If you would like to disable all tracking, please set the enabled/disabled flag in the configuration settings of the AppsFlyer Mobile Remote Command tag")
                    }
                    return appsFlyerCommandTracker.disableTracking(false)
                }
                appsFlyerCommandTracker.disableTracking(disable)
            case .resolveDeepLinkUrls:
                guard let deepLinkUrls = payload[AppsFlyerConstants.Parameters.deepLinkUrls] as? [String] else {
                    if debug {
                        print("\(AppsFlyerConstants.errorPrefix)If you would like to resolve deep link urls, please set the af_deep_link variable in the AppDelegate or AppsFlyer Mobile Remote Command tag")
                    }
                    return
                }
                appsFlyerCommandTracker.resolveDeepLinkURLs(deepLinkUrls)
            default:
                if let appsFlyerEvent = AppsFlyerConstants.EventCommandNames(rawValue: $0.lowercased()) {
                    let eventName = String(standardEventName: appsFlyerEvent)
                    guard let eventParameters = payload[AppsFlyerConstants.Parameters.event] as? [String: Any] else {
                        return appsFlyerCommandTracker.logEvent(eventName, values: payload.filterVariables())
                    }
                    appsFlyerCommandTracker.logEvent(eventName, values: eventParameters)
                }
                break
            }
        }
    }

}

fileprivate extension Dictionary where Key == String, Value == Any {
    func filterVariables() -> [String: Any] {
        self.filter {
                $0.key != "debug" &&
                    $0.key != "method" &&
                    $0.key != "app_dev_key" &&
                    $0.key != "app_id" &&
                    $0.key != AppsFlyerConstants.commandName &&
                    $0.key != "settings"
            }
    }
}

fileprivate extension String {
    init(standardEventName: AppsFlyerConstants.EventCommandNames) {
        switch standardEventName {
        case .achievelevel:
            self = AppsFlyerConstants.Events.achievedLevel
        case .adclick:
            self = AppsFlyerConstants.Events.adClick
        case .adview:
            self = AppsFlyerConstants.Events.adView
        case .addpaymentinfo:
            self = AppsFlyerConstants.Events.addPaymentInfo
        case .addtocart:
            self = AppsFlyerConstants.Events.addToCart
        case .addtowishlist:
            self = AppsFlyerConstants.Events.addToWishlist
        case .completeregistration:
            self = AppsFlyerConstants.Events.completeRegistration
        case .completetutorial:
            self = AppsFlyerConstants.Events.completeTutorial
        case .viewedcontent:
            self = AppsFlyerConstants.Events.contentView
        case .search:
            self = AppsFlyerConstants.Events.search
        case .rate:
            self = AppsFlyerConstants.Events.rate
        case .starttrial:
            self = AppsFlyerConstants.Events.startTrial
        case .subscribe:
            self = AppsFlyerConstants.Events.subscribe
        case .initiatecheckout:
            self = AppsFlyerConstants.Events.initiateCheckout
        case .purchase:
            self = AppsFlyerConstants.Events.purchase
        case .unlockachievement:
            self = AppsFlyerConstants.Events.unlockAchievement
        case .spentcredits:
            self = AppsFlyerConstants.Events.spentCredits
        case .listview:
            self = AppsFlyerConstants.Events.listView
        case .travelbooking:
            self = AppsFlyerConstants.Events.travelBooking
        case .share:
            self = AppsFlyerConstants.Events.share
        case .invite:
            self = AppsFlyerConstants.Events.invite
        case .reengage:
            self = AppsFlyerConstants.Events.reEngage
        case .update:
            self = AppsFlyerConstants.Events.update
        case .login:
            self = AppsFlyerConstants.Events.login
        case .customersegment:
            self = AppsFlyerConstants.Events.customerSegment
        }
    }
}
