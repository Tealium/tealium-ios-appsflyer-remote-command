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

    /// Whether `initialize` claimed the SDK's single session-ready listener slot. That listener is
    /// the only way this library learns the session started, so `onReady` needs a fallback when the
    /// slot belongs to the host app instead.
    private var didRegisterSessionReadyListener = false

    /// Sets no delegate, so attribution callbacks do not fire. Use `init(tealium:)` to track them.
    public override convenience init() {
        self.init(logger: RemoteCommandLogger(logLevel: .silent))
    }

    /// Registers as `AppsFlyerLibDelegate` and `AppsFlyerDeepLinkDelegate`, tracked through `tealium`.
    /// `AppsFlyerLib.shared()` is a singleton — a second instance created with this initializer
    /// silently steals both delegate slots from the first.
    public convenience init(tealium: Tealium?,
                             logLevel: RemoteCommandLogLevel) {
        self.init(tealium: tealium, logger: RemoteCommandLogger(logLevel: logLevel))
    }

    init(tealium: Tealium?, logger: RemoteCommandLogger) {
        self.logger = logger
        super.init()
        self.tealium = tealium

        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
    }


    /// Used by `AppsFlyerRemoteCommand` when no instance is supplied, so it can share its own
    /// logger with this instance instead of building a second one. Sets no delegate, so
    /// attribution callbacks do not fire on this path — a `RemoteCommand` has no access to the
    /// Tealium instance it belongs to, so it cannot track on its own.
    /// Pass `AppsFlyerInstance(tealium:)` to `AppsFlyerRemoteCommand.init(appsFlyerInstance:)`
    /// to enable attribution tracking.
    init(logger: RemoteCommandLogger) {
        self.logger = logger
        super.init()
    }

    public func onReady(_ onReady: @escaping (AppsFlyerLib) -> Void) {
        defer { _onReady.subscribeOnce(onReady) }
        let appsFlyerAlreadyPublished = _onReady.last() != nil
        guard !appsFlyerAlreadyPublished else {
            return
        }
        let appsFlyer = AppsFlyerLib.shared()
        // SDK 7: credentials being set doesn't mean the session started, so the SDK's own readiness
        // flag decides — `isSessionReady()` turns true once a session-ready listener has fired.
        if appsFlyer.isSessionReady() {
            _onReady.publish(appsFlyer)
            return
        }
        // Fallback for a host app that initializes AppsFlyer itself the SDK 6 way (`initialize` plus a
        // direct `start`): it owns the SDK's single listener slot, so no readiness flag is ever set
        // here and without this every gated command is stranded forever. `appsFlyerDevKey` is readonly
        // and set by `initialize(devKey:appId:)`, so it answers whether the SDK was initialized at all.
        guard !didRegisterSessionReadyListener, !appsFlyer.appsFlyerDevKey.isEmpty else {
            return
        }
        _onReady.publish(appsFlyer)
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
        // SDK 7: the listener re-fires every foreground, so `start` belongs inside it, replacing
        // the old per-`applicationDidBecomeActive` call. Publishing `onReady` inside the block (not
        // right after registering) makes it wait on the listener's own readiness checks too.
        //
        // Two things the SDK expects from the host app, which a RemoteCommand cannot do for it:
        // - Universal Links: the SDK only waits for a cold-launch link to resolve before firing this
        //   listener if `AppsFlyerLib.shared().handleLaunchOptions(_:)` was called from
        //   `application(_:didFinishLaunchingWithOptions:)`, and only the host has `launchOptions`.
        // - ATT consent before `start`: the SDK keeps a single listener, claimed here, so a host that
        //   must collect consent first initializes AppsFlyer itself and registers its own listener
        //   rather than mapping the `initialize` command. `onReady` supports that path.
        appsFlyer.registerSessionReadyListener { [weak self] in
            // Always dispatched on the main queue by the SDK, while `_onReady` subscribers are added
            // from `TealiumQueues.backgroundSerialQueue` — `TealiumObservable` is not synchronized,
            // so publishing has to hop back onto that queue.
            //
            // The listener fires again on every foreground, so an unconditional `start` would resume
            // tracking for a user who opted out through `disabletracking`/`stoptracking`.
            if appsFlyer.isStopped {
                self?.logger.debug("Session start skipped: tracking is stopped.")
            } else {
                appsFlyer.start()
            }
            TealiumQueues.backgroundSerialQueue.async {
                self?._onReady.publish(appsFlyer)
            }
        }
        didRegisterSessionReadyListener = true
    }

    /// Gated on `onReady`: the SDK discards events logged before `start()`.
    public func logEvent(_ eventName: String, values: [String: Any]) {
        onReady { appsFlyer in
            appsFlyer.logEvent(eventName, withValues: values)
        }
    }

    /// Gated on `onReady`: the SDK discards events logged before `start()`.
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

    /// Gated on `onReady`: the SDK discards events logged before `start()`.
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

    /// SDK 7 re-invokes the session-ready listener registered in `initialize` on every foreground,
    /// calling `start` there automatically — this command is no longer needed for that. It now
    /// matches Android's usage: call it only to manually resume after `disabletracking`/`stoptracking`.
    public func start() {
        AppsFlyerLib.shared().start()
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
