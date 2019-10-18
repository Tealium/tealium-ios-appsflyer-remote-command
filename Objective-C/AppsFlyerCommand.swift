//
//  AppsFlyerCommand.swift
//  AppsFlyerRemoteCommand
//
//  Created by Christina Sund on 5/29/19.
//  Copyright © 2019 Christina. All rights reserved.
//

import Foundation
import TealiumIOS

public class AppsFlyerCommand: NSObject {

    let appsFlyerCommandTracker: AppsFlyerTrackable
    
    @objc
    public init(appsFlyerCommandTracker: AppsFlyerTrackable = AppsFlyerCommandTracker()) {
        self.appsFlyerCommandTracker = appsFlyerCommandTracker
    }
    
    let appsflyerEvent = EnumMap<AppsFlyer.EventCommandNames, String> { command in
        switch command {
        case .achievelevel:
            return AppsFlyer.Events.achievedLevel
        case .adclick:
            return AppsFlyer.Events.adClick
        case .adview:
            return AppsFlyer.Events.adView
        case .addpaymentinfo:
            return AppsFlyer.Events.addPaymentInfo
        case .addtocart:
            return AppsFlyer.Events.addToCart
        case .addtowishlist:
            return AppsFlyer.Events.addToWishlist
        case .completeregistration:
            return AppsFlyer.Events.completeRegistration
        case .completetutorial:
            return AppsFlyer.Events.completeTutorial
        case .viewedcontent:
            return AppsFlyer.Events.contentView
        case .search:
            return AppsFlyer.Events.search
        case .rate:
            return AppsFlyer.Events.rate
        case .starttrial:
            return AppsFlyer.Events.startTrial
        case .subscribe:
            return AppsFlyer.Events.subscribe
        case .initiatecheckout:
            return AppsFlyer.Events.initiateCheckout
        case .purchase:
            return AppsFlyer.Events.purchase
        case .unlockachievement:
            return AppsFlyer.Events.unlockAchievement
        case .spentcredits:
            return AppsFlyer.Events.spentCredits
        case .listview:
            return AppsFlyer.Events.listView
        case .travelbooking:
            return AppsFlyer.Events.travelBooking
        case .share:
            return AppsFlyer.Events.share
        case .invite:
            return AppsFlyer.Events.invite
        case .reengage:
            return AppsFlyer.Events.reEngage
        case .update:
            return AppsFlyer.Events.update
        case .login:
            return AppsFlyer.Events.login
        case .customersegment:
            return AppsFlyer.Events.customerSegment
        }
    }
    
    @objc
    public func remoteCommand() -> TEALRemoteCommandResponseBlock {
        return { response in
            guard let payload = response?.requestPayload as? [String: Any] else {
                return
            }
            
            if let disableTracking = payload[AppsFlyer.Parameters.stopTracking] as? Bool {
                if disableTracking == true {
                    self.appsFlyerCommandTracker.disableTracking(true)
                    return
                }
            }
            
            guard let command = payload[AppsFlyer.commandName] as? String else {
                return
            }
            let commands = command.split(separator: ",")
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
            if let appsFlyerEvent = AppsFlyer.EventCommandNames(rawValue: lowercasedCommand) {
                self.appsFlyerCommandTracker.trackEvent(self.appsflyerEvent[appsFlyerEvent], values: payload)
            } else {
                switch lowercasedCommand {
                case AppsFlyer.CommandNames.initialize:
                    guard let appId = payload[AppsFlyer.appId] as? String,
                        let appDevKey = payload[AppsFlyer.Configuration.appDevKey] as? String else {
                            print("Appsflyer: Must set an app_id and api_key in AppsFlyer Mobile Remote Command tag to initialize")
                            return
                    }
                    guard let config = payload[AppsFlyer.Configuration.config] as? [String: Any] else {
                        return self.appsFlyerCommandTracker.initialize(appId: appId, appDevKey: appDevKey)
                    }
                    return self.appsFlyerCommandTracker.initialize(appId: appId, appDevKey: appDevKey, config: config)
                case AppsFlyer.CommandNames.launch:
                    self.appsFlyerCommandTracker.trackLaunch()
                case AppsFlyer.CommandNames.trackLocation:
                    guard let latitude = payload[AppsFlyer.Parameters.latitude] as? Double,
                        let longitude = payload[AppsFlyer.Parameters.longitude]  as? Double else {
                            print("Appsflyer: Must map af_lat and af_long in the AppsFlyer Mobile Remote Command tag to track location")
                            return
                    }
                    self.appsFlyerCommandTracker.trackLocation(longitude: longitude, latitude: latitude)
                case AppsFlyer.CommandNames.setHost:
                    guard let host = payload[AppsFlyer.Parameters.host] as? String,
                        let hostPrefix = payload[AppsFlyer.Parameters.hostPrefix] as? String else {
                            print("Appsflyer: Must map host and host_prefix in the AppsFlyer Mobile Remote Command tag to set host")
                            return
                    }
                    self.appsFlyerCommandTracker.setHost(host, with: hostPrefix)
                case AppsFlyer.CommandNames.setUserEmails:
                    guard let emails = payload[AppsFlyer.Parameters.emails] as? [String],
                        let cryptType = payload[AppsFlyer.Parameters.cryptType] as? Int else {
                            print("Appsflyer: Must map customer_emails and cryptType in the AppsFlyer Mobile Remote Command tag to set user emails")
                            return
                    }
                    self.appsFlyerCommandTracker.setUserEmails(emails: emails, with: cryptType)
                case AppsFlyer.CommandNames.setCurrencyCode:
                    guard let currency = payload[AppsFlyer.Parameters.currency] as? String else {
                        print("Appsflyer: Must map af_currency in the AppsFlyer Mobile Remote Command tag to call set currency")
                        return
                    }
                    self.appsFlyerCommandTracker.currencyCode(currency)
                case AppsFlyer.CommandNames.setCustomerId:
                    guard let customerId = payload[AppsFlyer.Parameters.customerId] as? String else {
                        print("Appsflyer: Must map af_customer_user_id in the AppsFlyer Mobile Remote Command tag to call set customer id")
                        return
                    }
                    self.appsFlyerCommandTracker.customerId(customerId)
                case AppsFlyer.CommandNames.disableTracking:
                    guard let disable = payload[AppsFlyer.Parameters.stopTracking] as? Bool else {
                        print("Appsflyer: If you would like to disable all tracking, please set the enabled/disabled flag in the configuration settings of the AppsFlyer Mobile Remote Command tag")
                        return self.appsFlyerCommandTracker.disableTracking(false)
                    }
                    self.appsFlyerCommandTracker.disableTracking(disable)
                case AppsFlyer.CommandNames.resolveDeepLinkUrls:
                    guard let deepLinkUrls = payload[AppsFlyer.Parameters.deepLinkUrls] as? [String] else {
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

