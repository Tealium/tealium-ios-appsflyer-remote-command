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
    
    public func remoteCommand() -> TealiumRemoteCommand {
        return TealiumRemoteCommand(commandId: "appsflyer", description: "AppsFlyer Remote Command") { response in
            
            let payload = response.payload()
            
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
            
            self.parseCommands(appsflyerCommands, payload: payload)
        }
    }
    
    public func parseCommands(_ commands: [String], payload: [String: Any]) {
        commands.forEach { [weak self] command in
            let lowercasedCommand = command.lowercased()
            guard let self = self else {
                return
            }
            if let appsFlyerEvent = AppsFlyerConstants.EventCommandNames(rawValue: lowercasedCommand) {
                self.appsFlyerCommandTracker.trackEvent(self.appsflyerEvent[appsFlyerEvent], values: payload)
            } else {
                switch lowercasedCommand {
                case AppsFlyerConstants.CommandNames.initialize:
                    guard let appId = payload[AppsFlyerConstants.appId] as? String,
                        let appDevKey = payload[AppsFlyerConstants.Configuration.appDevKey] as? String else {
                            print("Appsflyer: Must set an app_id and api_key in AppsFlyer Mobile Remote Command tag to initialize")
                            return
                    }
                    guard let settings = payload[AppsFlyerConstants.Configuration.settings] as? [String: Any] else {
                        return self.appsFlyerCommandTracker.initialize(appId: appId, appDevKey: appDevKey, settings: nil)
                    }
                    return self.appsFlyerCommandTracker.initialize(appId: appId, appDevKey: appDevKey, settings: settings)
                case AppsFlyerConstants.CommandNames.launch:
                    self.appsFlyerCommandTracker.trackLaunch()
                case AppsFlyerConstants.CommandNames.trackLocation:
                    guard let latitude = payload[AppsFlyerConstants.Parameters.latitude] as? Double,
                        let longitude = payload[AppsFlyerConstants.Parameters.longitude]  as? Double else {
                            print("Appsflyer: Must map af_lat and af_long in the AppsFlyer Mobile Remote Command tag to track location")
                            return
                    }
                    self.appsFlyerCommandTracker.trackLocation(longitude: longitude, latitude: latitude)
                case AppsFlyerConstants.CommandNames.setHost:
                    guard let host = payload[AppsFlyerConstants.Parameters.host] as? String,
                        let hostPrefix = payload[AppsFlyerConstants.Parameters.hostPrefix] as? String else {
                            print("Appsflyer: Must map host and host_prefix in the AppsFlyer Mobile Remote Command tag to set host")
                            return
                    }
                    self.appsFlyerCommandTracker.setHost(host, with: hostPrefix)
                case AppsFlyerConstants.CommandNames.setUserEmails:
                    guard let emails = payload[AppsFlyerConstants.Parameters.emails] as? [String],
                        let cryptType = payload[AppsFlyerConstants.Parameters.cryptType] as? Int else {
                            print("Appsflyer: Must map customer_emails and cryptType in the AppsFlyer Mobile Remote Command tag to set user emails")
                            return
                    }
                    self.appsFlyerCommandTracker.setUserEmails(emails: emails, with: cryptType)
                case AppsFlyerConstants.CommandNames.setCurrencyCode:
                    guard let currency = payload[AppsFlyerConstants.Parameters.currency] as? String else {
                        print("Appsflyer: Must map af_currency in the AppsFlyer Mobile Remote Command tag to call set currency")
                        return
                    }
                    self.appsFlyerCommandTracker.currencyCode(currency)
                case AppsFlyerConstants.CommandNames.setCustomerId:
                    guard let customerId = payload[AppsFlyerConstants.Parameters.customerId] as? String else {
                        print("Appsflyer: Must map af_customer_user_id in the AppsFlyer Mobile Remote Command tag to call set customer id")
                        return
                    }
                    self.appsFlyerCommandTracker.customerId(customerId)
                case AppsFlyerConstants.CommandNames.disableTracking:
                    guard let disable = payload[AppsFlyerConstants.Parameters.stopTracking] as? Bool else {
                        print("Appsflyer: If you would like to disable all tracking, please set the enabled/disabled flag in the configuration settings of the AppsFlyer Mobile Remote Command tag")
                        return self.appsFlyerCommandTracker.disableTracking(false)
                    }
                    self.appsFlyerCommandTracker.disableTracking(disable)
                case AppsFlyerConstants.CommandNames.resolveDeepLinkUrls:
                    guard let deepLinkUrls = payload[AppsFlyerConstants.Parameters.deepLinkUrls] as? [String] else {
                        print("Appsflyer: If you would like to resolve deep link urls, please set the af_deep_link variable in the AppDelegate or AppsFlyer Mobile Remote Command tag")
                        return
                    }
                    self.appsFlyerCommandTracker.resolveDeepLinkURLs(deepLinkUrls)
                default: break
                }
            }
        }
    }
    
}
