//
//  AppsFlyerRemoteCommand.swift
//  AppsFlyerRemoteCommand
//
//  Created by Christina S on 5/29/19.
//  Copyright © 2019 Christina. All rights reserved.
//

import Foundation
#if COCOAPODS
import TealiumSwift
#else
import TealiumCore
import TealiumDelegate
import TealiumTagManagement
import TealiumRemoteCommands
#endif

public class AppsFlyerRemoteCommand {
    
    let appsFlyerCommandTracker: AppsFlyerTrackable
    
    public init(appsFlyerCommandTracker: AppsFlyerTrackable = AppsFlyerCommandTracker()) {
        self.appsFlyerCommandTracker = appsFlyerCommandTracker
    }
    
    public func remoteCommand() -> TealiumRemoteCommand {
        return TealiumRemoteCommand(commandId: "appsflyer", description: "AppsFlyer Remote Command") { response in
            
            var payload = response.payload()
            
            if let disableTracking = payload[AppsFlyerConstants.Parameters.stopTracking] as? Bool {
                if disableTracking == true {
                    self.appsFlyerCommandTracker.disableTracking(true)
                    return
                }
            }
            
            guard let command = payload[AppsFlyerConstants.commandName] as? String else {
                return
            }
            
            let commands = command.split(separator: AppsFlyerConstants.separator)
            let appsflyerCommands = commands.map { command in
                return command.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            payload = payload.filterVariables()
            self.parseCommands(appsflyerCommands, payload: payload)
        }
    }
    
    public func parseCommands(_ commands: [String], payload: [String: Any]) {
        commands.forEach { [weak self] command in
            let commandName = AppsFlyerConstants.CommandNames(rawValue: command.lowercased())
            guard let self = self else {
                return
            }
            if let appsFlyerEvent = AppsFlyerConstants.EventCommandNames(rawValue: command.lowercased()) {
                self.appsFlyerCommandTracker.trackEvent(self.appsflyerEvent[appsFlyerEvent], values: payload)
            } else {
                switch commandName {
                case .initialize:
                    guard let appId = payload[.appId] as? String,
                        let appDevKey = payload[.appDevKey] as? String else {
                            print("\(AppsFlyerConstants.errorPrefix) Must set an app_id and api_key in AppsFlyer Mobile Remote Command tag to initialize")
                            return
                    }
                    guard let settings = payload[.settings] as? [String: Any] else {
                        return self.appsFlyerCommandTracker.initialize(appId: appId, appDevKey: appDevKey, settings: nil)
                    }
                    return self.appsFlyerCommandTracker.initialize(appId: appId, appDevKey: appDevKey, settings: settings)
                case .launch:
                    self.appsFlyerCommandTracker.trackLaunch()
                case .trackLocation:
                    guard let latitude = payload[.latitude] as? Double,
                        let longitude = payload[.longitude]  as? Double else {
                            print("\(AppsFlyerConstants.errorPrefix)Must map af_lat and af_long in the AppsFlyer Mobile Remote Command tag to track location")
                            return
                    }
                    self.appsFlyerCommandTracker.trackLocation(longitude: longitude, latitude: latitude)
                case .setHost:
                    guard let host = payload[.host] as? String,
                        let hostPrefix = payload[.hostPrefix] as? String else {
                            print("\(AppsFlyerConstants.errorPrefix)Must map host and host_prefix in the AppsFlyer Mobile Remote Command tag to set host")
                            return
                    }
                    self.appsFlyerCommandTracker.setHost(host, with: hostPrefix)
                case .setUserEmails:
                    guard let emails = payload[.emails] as? [String],
                        let cryptType = payload[.cryptType] as? Int else {
                            print("\(AppsFlyerConstants.errorPrefix)Must map customer_emails and cryptType in the AppsFlyer Mobile Remote Command tag to set user emails")
                            return
                    }
                    self.appsFlyerCommandTracker.setUserEmails(emails: emails, with: cryptType)
                case .setCurrencyCode:
                    guard let currency = payload[.currency] as? String else {
                        print("\(AppsFlyerConstants.errorPrefix)Must map af_currency in the AppsFlyer Mobile Remote Command tag to call set currency")
                        return
                    }
                    self.appsFlyerCommandTracker.currencyCode(currency)
                case .setCustomerId:
                    guard let customerId = payload[.customerId] as? String else {
                        print("\(AppsFlyerConstants.errorPrefix)Must map af_customer_user_id in the AppsFlyer Mobile Remote Command tag to call set customer id")
                        return
                    }
                    self.appsFlyerCommandTracker.customerId(customerId)
                case .disableTracking:
                    guard let disable = payload[.stopTracking] as? Bool else {
                        print("\(AppsFlyerConstants.errorPrefix)If you would like to disable all tracking, please set the enabled/disabled flag in the configuration settings of the AppsFlyer Mobile Remote Command tag")
                        return self.appsFlyerCommandTracker.disableTracking(false)
                    }
                    self.appsFlyerCommandTracker.disableTracking(disable)
                case .resolveDeepLinkUrls:
                    guard let deepLinkUrls = payload[.deepLinkUrls] as? [String] else {
                        print("\(AppsFlyerConstants.errorPrefix)If you would like to resolve deep link urls, please set the af_deep_link variable in the AppDelegate or AppsFlyer Mobile Remote Command tag")
                        return
                    }
                    self.appsFlyerCommandTracker.resolveDeepLinkURLs(deepLinkUrls)
                default: break
                }
            }
        }
    }
    
    let appsflyerEvent = EnumMap<AppsFlyerConstants.EventCommandNames, String> { command in
        switch command {
        case .achievelevel:
            return AppsFlyerConstants.Events.achievedLevel
        case .adclick:
            return AppsFlyerConstants.Events.adClick
        case .adview:
            return AppsFlyerConstants.Events.adView
        case .addpaymentinfo:
            return AppsFlyerConstants.Events.addPaymentInfo
        case .addtocart:
            return AppsFlyerConstants.Events.addToCart
        case .addtowishlist:
            return AppsFlyerConstants.Events.addToWishlist
        case .completeregistration:
            return AppsFlyerConstants.Events.completeRegistration
        case .completetutorial:
            return AppsFlyerConstants.Events.completeTutorial
        case .viewedcontent:
            return AppsFlyerConstants.Events.contentView
        case .search:
            return AppsFlyerConstants.Events.search
        case .rate:
            return AppsFlyerConstants.Events.rate
        case .starttrial:
            return AppsFlyerConstants.Events.startTrial
        case .subscribe:
            return AppsFlyerConstants.Events.subscribe
        case .initiatecheckout:
            return AppsFlyerConstants.Events.initiateCheckout
        case .purchase:
            return AppsFlyerConstants.Events.purchase
        case .unlockachievement:
            return AppsFlyerConstants.Events.unlockAchievement
        case .spentcredits:
            return AppsFlyerConstants.Events.spentCredits
        case .listview:
            return AppsFlyerConstants.Events.listView
        case .travelbooking:
            return AppsFlyerConstants.Events.travelBooking
        case .share:
            return AppsFlyerConstants.Events.share
        case .invite:
            return AppsFlyerConstants.Events.invite
        case .reengage:
            return AppsFlyerConstants.Events.reEngage
        case .update:
            return AppsFlyerConstants.Events.update
        case .login:
            return AppsFlyerConstants.Events.login
        case .customersegment:
            return AppsFlyerConstants.Events.customerSegment
        }
    }
    
}

fileprivate extension Dictionary where Key == String, Value == Any {
    
    func filterVariables() -> [String: Any] {
        self.filter {
            $0.key != "debug" &&
            $0.key != "method" &&
            $0.key != AppsFlyerConstants.commandName
        }
    }
}

fileprivate extension Dictionary where Key: ExpressibleByStringLiteral {
    subscript(key: AppsFlyerConstants.Parameters) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
        set {
            self[key.rawValue as! Key] = newValue
        }
    }
    
    subscript(key: AppsFlyerConstants.Configuration) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
        set {
            self[key.rawValue as! Key] = newValue
        }
    }
}
