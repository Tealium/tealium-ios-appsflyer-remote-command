//
//  TealiumHelper.swift
//  TealiumAppsFlyerExample
//
//  Created by Christina S on 6/18/19.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation
import TealiumSwift
import TealiumAppsFlyer

// Note: Due to a current bug in WebKit, you will see the following console error repeatedly:
// [Process] kill() returned unexpected error 1
// Reference: https://bugs.webkit.org/show_bug.cgi?id=202173 and https://www.mail-archive.com/webkit-changes@lists.webkit.org/msg146193.html

enum TealiumConfiguration {
    static let account = "tealiummobile"
    static let profile = "appsflyer"
    static let environment = "dev"
}

class TealiumHelper {

    static let shared = TealiumHelper()
    var pushMessagingTrackers = [TealiumRegistration]()

    let config = TealiumConfig(account: TealiumConfiguration.account,
                               profile: TealiumConfiguration.profile,
                               environment: TealiumConfiguration.environment)

    var tealium: Tealium?

    private init() {
        config.logLevel = .verbose
        config.shouldUseRemotePublishSettings = false

        tealium = Tealium(config: config,
                          enableCompletion: { [weak self] _ in
                              guard let self = self else { return }
                              guard let remoteCommands = self.tealium?.remoteCommands() else {
                                  return
                              }
                              // MARK: AppsFlyer
                              let appsFlyerCommandTracker = AppsFlyerCommandTracker()
                              let appsFlyerCommand = AppsFlyerRemoteCommand(appsFlyerCommandTracker: appsFlyerCommandTracker)
                              let appsFlyerRemoteCommand = appsFlyerCommand.remoteCommand()
                              remoteCommands.add(appsFlyerRemoteCommand)
                              self.pushMessagingTrackers.append(appsFlyerCommandTracker)
                          })

    }


    public func start() {
        _ = TealiumHelper.shared
    }

    class func trackView(title: String, data: [String: Any]?) {
        TealiumHelper.shared.tealium?.track(title: title, data: data, completion: nil)
    }

    class func trackScreen(_ view: UIViewController, name: String) {
        TealiumHelper.trackView(title: "screen_view",
                                data: ["screen_name": name,
                                       "screen_class": "\(view.classForCoder)"])
    }

    class func trackEvent(title: String, data: [String: Any]?) {
        TealiumHelper.shared.tealium?.track(title: title, data: data, completion: nil)
    }

}
