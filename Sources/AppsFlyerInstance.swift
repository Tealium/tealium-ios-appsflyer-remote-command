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
    func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void)
    func start()
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

/// All public methods are expected to be called on the `TealiumQueues.backgroundSerialQueue`.
public class AppsFlyerInstance: NSObject, AppsFlyerCommand {

    weak var tealium: Tealium?
    private let _onReady = TealiumReplaySubject<AppsFlyerLib>(cacheSize: 1)
    private let logger: RemoteCommandLogger

    /// Sets no delegate, so attribution callbacks do not fire. Use `init(tealium:)` to track them.
    public override convenience init() {
        self.init(logger: RemoteCommandLogger(logLevel: .silent))
    }

    /// Registers as `AppsFlyerLibDelegate` and `AppsFlyerDeepLinkDelegate` and tracks attribution
    /// through `tealium`. `AppsFlyerLib.shared()` is a singleton with one slot per delegate, so a
    /// second instance built this way silently takes both slots from the first. `tealium` is
    /// non-optional because without it this initializer would only displace the host app's
    /// delegates and discard every callback; use `AppsFlyerInstance()` for no attribution tracking.
    public convenience init(tealium: Tealium,
                             logLevel: RemoteCommandLogLevel) {
        self.init(tealium: tealium, logger: RemoteCommandLogger(logLevel: logLevel))
    }

    init(tealium: Tealium, logger: RemoteCommandLogger) {
        self.logger = logger
        super.init()
        self.tealium = tealium
        // Off the main thread this hop is asynchronous, so create the instance on the main thread
        // or a command may reach `AppsFlyerLib.shared()` before the delegates are set.
        TealiumQueues.secureMainThreadExecution {
            AppsFlyerLib.shared().delegate = self
            AppsFlyerLib.shared().deepLinkDelegate = self
        }
    }


    /// Used by `AppsFlyerRemoteCommand` when no instance is supplied, sharing its logger. Sets no
    /// delegate: a `RemoteCommand` has no access to its Tealium instance, so it cannot track
    /// attribution. Pass `AppsFlyerInstance(tealium:logLevel:)` to
    /// `AppsFlyerRemoteCommand.init(appsFlyerInstance:)` to enable it.
    init(logger: RemoteCommandLogger) {
        self.logger = logger
        super.init()

        // Same main-thread requirement as `init(tealium:logger:)`.
        TealiumQueues.secureMainThreadExecution { _ = AppsFlyerLib.shared() }
    }

    /// Runs `onReady` once the AppsFlyer session is ready, or at once if it already is. Commands that
    /// log to the SDK are gated on this because the SDK holds events logged before a successful
    /// `start()` and replays them only on its next init, so they would miss this session.
    public func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void) {
        defer { _onReady.subscribeOnce(onReady) }
        guard _onReady.last() == nil else {
            return
        }
        let appsFlyer = AppsFlyerLib.shared()
        // `isSessionReady()` is SDK 7's only readiness signal; credentials being set is not one, since
        // the session no longer starts on its own. It turns true once a registered session-ready
        // listener has fired in this foreground cycle (ours from `initialize`, or the host's). A host
        // that calls `start()` without registering a listener never makes it true, hence the log.
        // A host that gates `start` on ATT consent inside its listener starts after the listener has
        // fired, so commands released here can still miss that session.
        if appsFlyer.isSessionReady() {
            _onReady.publish(appsFlyer)
        } else {
            logger.debug("Command queued until the AppsFlyer session is ready. An app that initializes AppsFlyer itself must register a session-ready listener, or queued commands never run.")
        }
    }

    public func initialize(appId: String, appDevKey: String, settings: [String: Any]?) {
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

        appsFlyer.initialize(devKey: appDevKey, appId: appId)
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
        // SDK 7: the listener re-fires every foreground, so `start` belongs inside it, replacing the
        // old per-`applicationDidBecomeActive` call. `onReady` is published inside the block so it
        // also waits on the listener's own readiness checks.
        //
        // Two things only the host app can do, so this command does not: call
        // `AppsFlyerLib.shared().handleLaunchOptions(_:)` from `didFinishLaunchingWithOptions`, without
        // which the SDK does not wait for a cold-launch Universal Link before firing the listener; and
        // gate `start` on ATT consent, by setting `start_automatically_on_session_ready` to `false`,
        // calling `initialize(devKey:appId:)` itself (`registerSessionReadyListener` asserts credentials)
        // and starting inside its own listener.
        //
        // The SDK keeps one listener and a second registration replaces the block for good.
        // `isSessionReady()` is true only after a registered listener fired this foreground cycle, so a
        // listener (the host's, or ours from an earlier `initialize`) already owns `start`. Only
        // release the queued commands.
        if appsFlyer.isSessionReady() {
            logger.warning("Session already ready in this foreground cycle. Keeping the registered session-ready listener, which owns start, and releasing queued commands.")
            _onReady.publish(appsFlyer)
            return
        }
        // `true` (default): this command owns the SDK's single session-ready listener and `start`, so the
        // app must not register a listener of its own. `false`: the app calls `initialize(devKey:appId:)`,
        // registers its own listener and starts inside it; this command only configures the SDK.
        let startsAutomatically = settings?[AppsFlyerConstants.Settings.startAutomaticallyOnSessionReady] as? Bool ?? true
        guard startsAutomatically else {
            logger.info("start_automatically_on_session_ready is false: not registering a session-ready listener or calling start; the app does both.")
            return
        }
        // On a cold launch nothing has fired yet, so the check above cannot detect a listener the host
        // registered in `didFinishLaunching`; the SDK exposes no way to tell an occupied slot from a
        // free one. Logged, not detected.
        logger.info("Registering the AppsFlyer session-ready listener; this replaces any listener the app registered itself. Set start_automatically_on_session_ready to false to keep your own.")
        // `registerSessionReadyListener` reads `UIApplication.applicationState` synchronously, so it has to
        // run on the main thread; commands arrive here on `TealiumQueues.backgroundSerialQueue`.
        TealiumQueues.secureMainThreadExecution {
            appsFlyer.registerSessionReadyListener { [weak self] in
                // The SDK fires this on the main queue; `_onReady` subscribers are added on
                // `TealiumQueues.backgroundSerialQueue` and `TealiumObservable` is not synchronized,
                // so publishing hops back to that queue.
                //
                // The SDK's `start()` does not honour `isStopped` (it still runs its config check and
                // writes the session timestamp), so guard it here for users who opted out.
                if appsFlyer.isStopped {
                    self?.logger.debug("Session start skipped: tracking is stopped.")
                } else {
                    appsFlyer.start()
                }
                TealiumQueues.backgroundSerialQueue.async {
                    self?._onReady.publish(appsFlyer)
                }
            }
        }
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

    /// Not needed per foreground: the session-ready listener registered in `initialize` calls `start`
    /// there. Use it only to resume after `disabletracking`/`stoptracking`, mapped as
    /// `disabletracking,start` with `stop_tracking: false`.
    public func start() {
        // Same main-queue hop as the delegate assignment in `init(tealium:logger:)`, so FIFO ordering
        // on `DispatchQueue.main` runs this after it even when called right after off-main construction.
        TealiumQueues.secureMainThreadExecution {
            // Same `isStopped` guard as the session-ready listener in `initialize`.
            if AppsFlyerLib.shared().isStopped {
                self.logger.debug("Session start skipped: tracking is stopped.")
            } else {
                AppsFlyerLib.shared().start()
            }
        }
    }

    /// Gated on `onReady` because the SDK discards deep links received before `start()`,
    /// which is what happens on a cold start without the gate.
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
