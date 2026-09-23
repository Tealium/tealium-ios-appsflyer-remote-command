//
//  AppsFlyerInstance.swift
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

public protocol AppsFlyerCommand {
    var logger: RemoteCommandLogger { get }
    func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void)
    func initialize(appId: String, appDevKey: String, settings: [String: Any]?)
    func logEvent(_ eventName: String, values: [String: Any])
    func logLocation(longitude: Double, latitude: Double)
    func setHost(_ host: String, with prefix: String)
    func setUserEmail(_ email: String)
    func setUserPhone(countryCode: String, phoneNumber: String)
    func setUserFirstName(_ firstName: String)
    func setUserLastName(_ lastName: String)
    func setUserFbLoginId(_ fbLoginId: Int64)
    func clearUserPii()
    func currencyCode(_ currency: String)
    func customerId(_ id: String)
    func disableTracking(_ disable: Bool)
    func anonymizeUser(_ anonymize: Bool)
    func resolveDeepLinkURLs(_ urls: [String])
    func setPartnerData(partnerId: String, partnerInfo: [String: Any]?)
    func setSharingFilterForPartners(_ sharingFilter: [String]?)
    func logAdRevenue(_ adRevenueData: AFAdRevenueData, additionalParams: [String: Any]?)
    func setConsentData(_ consent: AppsFlyerConsent)
    func handleOpen(url: URL, sourceApplication: String?, annotation: Any?)
    func setCurrentDeviceLanguage(_ language: String)
    func setAppInviteOneLink(_ oneLinkId: String)
}

extension AppsFlyerLib {
    /// True once `initialize(devKey:appId:)` has set both credentials, by our `initialize` command or by the app.
    var hasCredentials: Bool {
        !appleAppID.isEmpty && !appsFlyerDevKey.isEmpty
    }
}

/// All public methods are expected to be called on the `TealiumQueues.backgroundSerialQueue`.
public class AppsFlyerInstance: NSObject, AppsFlyerCommand {

    weak var tealium: Tealium?
    /// Always used from the main thread
    private let _onReady = TealiumReplaySubject<AppsFlyerLib>(cacheSize: 1)
    public let logger: RemoteCommandLogger
    let sessionMode: AppsFlyerSessionMode

    /// Sets no delegate, so attribution callbacks do not fire, and logs nothing. Use
    /// `init(tealium:sessionMode:logLevel:)` to track attribution, or
    /// `AppsFlyerRemoteCommand(sessionMode:type:logLevel:)` if you don't need your own instance.
    /// - Parameter sessionMode: Who registers the session-ready listener and calls `start()`.
    public convenience init(sessionMode: AppsFlyerSessionMode) {
        self.init(sessionMode: sessionMode, logger: RemoteCommandLogger(logLevel: .silent))
    }

    /// Registers as `AppsFlyerLibDelegate` and `AppsFlyerDeepLinkDelegate` and tracks attribution
    /// through `tealium`. `AppsFlyerLib.shared()` is a singleton with one slot per delegate, so a
    /// second instance built this way silently takes both slots from the first. `tealium` is
    /// non-optional because without it this initializer would only displace the host app's
    /// delegates and discard every callback; use `AppsFlyerInstance(sessionMode:)` for no attribution
    /// tracking. Pass the result to `AppsFlyerRemoteCommand(appsFlyerInstance:type:)`, which reuses
    /// this instance's logger.
    /// - Parameters:
    ///   - tealium: The Tealium instance attribution events are tracked through.
    ///   - sessionMode: Who registers the session-ready listener and calls `start()`.
    ///   - logLevel: Log verbosity for this instance and the remote command built on it.
    public convenience init(tealium: Tealium,
                            sessionMode: AppsFlyerSessionMode,
                            logLevel: RemoteCommandLogLevel) {
        self.init(tealium: tealium, sessionMode: sessionMode, logger: RemoteCommandLogger(logLevel: logLevel))
    }

    /// Designated initializer. If the app already called `AppsFlyerLib.shared().initialize(devKey:appId:)`,
    /// `onReady` is released here and, in `.automatic`, the session-ready listener is registered.
    init(tealium: Tealium? = nil, sessionMode: AppsFlyerSessionMode, logger: RemoteCommandLogger) {
        self.logger = logger
        self.sessionMode = sessionMode
        super.init()
        self.tealium = tealium
        // Off the main thread this hop is asynchronous, so create the instance on the main thread
        // or a command may reach `AppsFlyerLib.shared()` before the delegates are set.
        TealiumQueues.secureMainThreadExecution {
            // We need to create the appsFlyer variable anyway because on first usage it must be created from the main thread.
            let appsFlyer = AppsFlyerLib.shared()
            if tealium != nil {
                appsFlyer.delegate = self
                appsFlyer.deepLinkDelegate = self
            }
            // The app may have initialized AppsFlyer before building this instance.
            if appsFlyer.hasCredentials {
                self.markReady(appsFlyer: appsFlyer)
            }
        }
    }

    /// Runs `onReady` on the main thread once AppsFlyer has credentials (`initialize` was called, by
    /// our `initialize` command or by the app), or at once if it already has. This is not "session
    /// started". Commands that log to the SDK are gated on this because the SDK needs credentials to
    /// build a request. SDK 7.0.2 accepts `logEvent` between `initialize` and `start()` but only caches it.
    public func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void) {
        TealiumQueues.secureMainThreadExecution { [self] in
            defer { _onReady.subscribeOnce(onReady) }
            guard _onReady.last() == nil else {
                return
            }
            let appsFlyer = AppsFlyerLib.shared()
            if !appsFlyer.hasCredentials {
                logger.debug("Command queued until AppsFlyer is initialized.")
            } else {
                markReady(appsFlyer: appsFlyer)
            }
        }
    }

    public func initialize(appId: String, appDevKey: String, settings: [String: Any]?) {
        TealiumQueues.secureMainThreadExecution { [self] in
            let appsFlyer = AppsFlyerLib.shared()
            // SDK 7: isDebug must be set before any other SDK call, or earlier calls log nothing.
            if let debug = settings?[AppsFlyerConstants.Settings.debug] as? Bool {
                appsFlyer.isDebug = debug
            }
            // enableFacebookDeferredApplinks must be called before credentials are set and before start().
            if let enableFacebookDeferredApplinks = settings?[AppsFlyerConstants.Settings.enableFacebookDeferredApplinks] as? Bool {
                if enableFacebookDeferredApplinks {
                    if let facebookAppLinkUtilityClass = NSClassFromString("FBSDKAppLinkUtility") {
                        appsFlyer.enableFacebookDeferredApplinks(with: facebookAppLinkUtilityClass)
                    } else {
                        logger.error("Facebook Deferred AppLinks requested but Facebook SDK not found. Please ensure Facebook SDK is integrated in your app.")
                    }
                } else {
                    // Pass nil to disable — mirrors Android's enableFacebookDeferredApplinks(false).
                    appsFlyer.enableFacebookDeferredApplinks(with: nil)
                }
            }
            if appId.isEmpty || appDevKey.isEmpty {
                logger.error("\(AppsFlyerConstants.Configuration.appId) and \(AppsFlyerConstants.Configuration.appDevKey) cannot be empty.")
            } else {
                if appsFlyer.hasCredentials {
                    logger.warning("AppsFlyer already initialized when command initialize is called. Going to initialize again with configured appId and appDevKey. Initialize should only be called once.")
                }
                appsFlyer.initialize(devKey: appDevKey, appId: appId)
            }
            if let settings = settings {
                let disableAdTracking = (settings[AppsFlyerConstants.Settings.disableAdTracking]
                                         ?? settings[AppsFlyerConstants.Settings.disableAdvertisingIdentifiersAlias]) as? Bool
                if let disableAdTracking = disableAdTracking {
                    appsFlyer.disableAdvertisingIdentifier = disableAdTracking
                    appsFlyer.disableIDFVCollection = disableAdTracking
                }
                if let disableAppleAdTracking = settings[AppsFlyerConstants.Settings.disableAppleAdTracking] as? Bool {
                    appsFlyer.disableSKAdNetwork = disableAppleAdTracking
                }
                // Guarded because `UInt(negative)` traps.
                if let minTimeBetweenSessions = settings[AppsFlyerConstants.Settings.minTimeBetweenSessions] as? Int,
                   minTimeBetweenSessions >= 0 {
                    appsFlyer.minTimeBetweenSessions = UInt(minTimeBetweenSessions)
                }
                if let anonymizeUser = settings[AppsFlyerConstants.Settings.anonymizeUser] as? Bool {
                    appsFlyer.anonymizeUser = anonymizeUser
                }
                if let shouldCollectDeviceName = settings[AppsFlyerConstants.Settings.collectDeviceName] as? Bool {
                    appsFlyer.shouldCollectDeviceName = shouldCollectDeviceName
                }
                if let customData = settings[AppsFlyerConstants.Settings.customData] as? [AnyHashable: Any] {
                    appsFlyer.customData = customData
                }
                if let disableAppleAdsAttribution = settings[AppsFlyerConstants.Settings.disableAppleAdsAttribution] as? Bool {
                    appsFlyer.disableAppleAdsAttribution = disableAppleAdsAttribution
                }
                if let enableTCFDataCollection = settings[AppsFlyerConstants.Settings.enableTCFDataCollection] as? Bool {
                    appsFlyer.enableTCFDataCollection(enableTCFDataCollection)
                }
                if let deepLinkTimeout = settings[AppsFlyerConstants.Settings.deepLinkTimeout] as? Int,
                   deepLinkTimeout >= 0 {
                    appsFlyer.deepLinkTimeout = UInt(deepLinkTimeout)
                }
                if let oneLinkCustomDomains = settings[AppsFlyerConstants.Settings.oneLinkCustomDomains] as? [String] {
                    appsFlyer.oneLinkCustomDomains = oneLinkCustomDomains
                }
                if let facebookDeferredAppLink = settings[AppsFlyerConstants.Settings.facebookDeferredAppLink] as? String,
                   let facebookDeferredAppLinkURL = URL(string: facebookDeferredAppLink) {
                    appsFlyer.facebookDeferredAppLink = facebookDeferredAppLinkURL
                }
                if let pushNotificationDeepLinkPath = settings[AppsFlyerConstants.Settings.pushNotificationDeepLinkPath] as? [String] {
                    appsFlyer.addPushNotificationDeepLinkPath(pushNotificationDeepLinkPath)
                }
                if let deepLinkParameters = settings[AppsFlyerConstants.Settings.deepLinkParameters] as? [[String: Any]] {
                    for parameter in deepLinkParameters {
                        if let contains = parameter[AppsFlyerConstants.Parameters.deepLinkContains] as? String,
                           let parameters = parameter[AppsFlyerConstants.Parameters.deepLinkParameters] as? [String: String] {
                            appsFlyer.appendParametersToDeepLinkingURL(contains: contains, parameters: parameters)
                        }
                    }
                }
                // Applied after disable_ad_tracking so it can override the IDFV portion independently.
                if let disableIDFVCollection = settings[AppsFlyerConstants.Settings.disableIDFVCollection] as? Bool {
                    appsFlyer.disableIDFVCollection = disableIDFVCollection
                }
            }
            // Empty credentials were rejected above; unless the app set its own, keep commands queued.
            if appsFlyer.hasCredentials {
                markReady(appsFlyer: appsFlyer)
            }
        }
    }

    private func markReady(appsFlyer: AppsFlyerLib) {
        // onReady is published before registerSessionReadyListener,
        // so that you can inject some additional settings before registering.
        _onReady.publish(appsFlyer)
        guard sessionMode == .automatic else { return }
        guard !appsFlyer.isSessionReady() else {
            logger.error("The AppsFlyerInstance.sessionMode is automatic, but the AppsFlyer session is already ready. You must set sessionMode to appManaged to control the AppsFlyer session. We will skip registering the listener and the automatic start.")
            return
        }
        logger.info("Registering the AppsFlyer session-ready listener; this replaces any listener the app registered itself. Set sessionMode to appManaged to keep your own.")
        appsFlyer.registerSessionReadyListener { appsFlyer.start() }
    }

    public func logEvent(_ eventName: String, values: [String: Any]) {
        onReady { appsFlyer in
            appsFlyer.logEvent(eventName, withValues: values)
        }
    }

    public func logLocation(longitude: Double, latitude: Double) {
        onReady { appsFlyer in
            appsFlyer.logLocation(longitude: longitude, latitude: latitude)
        }
    }

    public func setHost(_ host: String, with prefix: String) {
        // SDK 7 swapped the argument order to match Android: prefix first, host second.
        AppsFlyerLib.shared().setHost(prefix, hostName: host)
    }

    /// The SDK normalises and SHA-256 hashes the value on-device before it reaches the payload, so
    /// the caller passes it in clear text. Same for the other `setUser…` methods below.
    public func setUserEmail(_ email: String) {
        AppsFlyerLib.shared().setUserEmail(email)
    }

    public func setUserPhone(countryCode: String, phoneNumber: String) {
        AppsFlyerLib.shared().setUserPhone(countryCode: countryCode, phoneNumber: phoneNumber)
    }

    public func setUserFirstName(_ firstName: String) {
        AppsFlyerLib.shared().setUserFirstName(firstName)
    }

    public func setUserLastName(_ lastName: String) {
        AppsFlyerLib.shared().setUserLastName(lastName)
    }

    public func setUserFbLoginId(_ fbLoginId: Int64) {
        AppsFlyerLib.shared().setUserFbLoginId(fbLoginId)
    }

    public func clearUserPii() {
        AppsFlyerLib.shared().clearUserPii()
    }

    public func currencyCode(_ currency: String) {
        AppsFlyerLib.shared().currencyCode = currency
    }

    public func customerId(_ id: String) {
        AppsFlyerLib.shared().customerUserID = id
    }

    public func disableTracking(_ disable: Bool) {
        AppsFlyerLib.shared().isStopped = disable
    }

    public func anonymizeUser(_ anonymize: Bool) {
        AppsFlyerLib.shared().anonymizeUser = anonymize
    }

    public func resolveDeepLinkURLs(_ urls: [String]) {
        AppsFlyerLib.shared().resolveDeepLinkURLs = urls
    }

    public func logAdRevenue(_ adRevenueData: AFAdRevenueData, additionalParams: [String: Any]?) {
        onReady { appsFlyer in
            appsFlyer.logAdRevenue(adRevenueData, additionalParameters: additionalParams)
        }
    }

    public func setConsentData(_ consent: AppsFlyerConsent) {
        AppsFlyerLib.shared().setConsentData(consent)
    }


    public func setPartnerData(partnerId: String, partnerInfo: [String: Any]?) {
        AppsFlyerLib.shared().setPartnerData(partnerId: partnerId, data: partnerInfo)
    }

    public func setSharingFilterForPartners(_ sharingFilter: [String]?) {
        AppsFlyerLib.shared().setSharingFilterForPartners(sharingFilter)
    }

    /// Gated on `onReady` (credentials), not on `start()`: on the SDK 7.0.2 simulator a URI-scheme link
    /// passed after `initialize` and before `start()` reached `didResolveDeepLink` as `.found`. Whether a
    /// OneLink URL, which needs a network round trip, resolves before `start()` is unverified.
    public func handleOpen(url: URL, sourceApplication: String?, annotation: Any?) {
        onReady { appsFlyer in
            appsFlyer.handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        }
    }

    public func setCurrentDeviceLanguage(_ language: String) {
        AppsFlyerLib.shared().currentDeviceLanguage = language
    }

    public func setAppInviteOneLink(_ oneLinkId: String) {
        AppsFlyerLib.shared().appInviteOneLinkID = oneLinkId
    }

    func tealiumTrack(title: String, data: [String: Any]? = nil) {
        let event = TealiumEvent(title, dataLayer: data)
        tealium?.track(event)
    }
}

extension AppsFlyerInstance: AppsFlyerLibDelegate {

    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        guard let conversionInfo = conversionInfo as? [String: Any],
              let firstLaunch = conversionInfo[AppsFlyerConstants.Attribution.firstLaunch] as? Bool else {
            return
        }

        guard firstLaunch else {
            logger.debug("\(AppsFlyerConstants.attributionLog)Not First Launch")
            return
        }
        tealiumTrack(title: AppsFlyerConstants.Attribution.conversionReceived, data: conversionInfo)

        guard let status = conversionInfo[AppsFlyerConstants.Attribution.status] as? String else {
            return
        }

        if (status == "Non-organic") {
            if let mediaSource = conversionInfo[AppsFlyerConstants.Attribution.source],
               let campaign = conversionInfo[AppsFlyerConstants.Attribution.campaign] {
                logger.info("\(AppsFlyerConstants.attributionLog)This is a Non-Organic install. Media source: \(mediaSource) Campaign: \(campaign)")
            }
        } else {
            logger.info("\(AppsFlyerConstants.attributionLog)This is an organic install.")
        }
    }

    public func onConversionDataFail(_ error: Error) {
        tealiumTrack(
            title: AppsFlyerConstants.Attribution.error,
            data: [
                AppsFlyerConstants.Attribution.errorName: AppsFlyerConstants.Attribution.conversionFailure,
                AppsFlyerConstants.Attribution.errorDescription: error.localizedDescription
            ]
        )
    }

}

extension AppsFlyerInstance: AppsFlyerDeepLinkDelegate {

    /// SDK 7 delivers app-open attribution here, replacing the removed `onAppOpenAttribution` and
    /// `onAppOpenAttributionFailure` callbacks.
    public func didResolveDeepLink(_ result: DeepLinkResult) {
        switch result.status {
        case .found:
            // A deferred link resolves on first install, which `onConversionDataSuccess` already
            // reports as `conversion_data_received`. The removed `onAppOpenAttribution` never fired
            // for it, so tracking it here would double-report the same install.
            guard result.deepLink?.isDeferred != true else {
                logger.debug("\(AppsFlyerConstants.attributionLog)Deferred deep link resolved — reported through conversion data instead.")
                return
            }
            tealiumTrack(title: AppsFlyerConstants.Attribution.appOpen, data: result.deepLink?.clickEvent)
        case .failure:
            tealiumTrack(
                title: AppsFlyerConstants.Attribution.error,
                data: [
                    AppsFlyerConstants.Attribution.errorName: AppsFlyerConstants.Attribution.appOpenFailure,
                    AppsFlyerConstants.Attribution.errorDescription: result.error?.localizedDescription ?? ""
                ]
            )
        case .notFound:
            break
        }
    }
}
