# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0]

### Added
- `start_automatically_on_session_ready` setting, default `true`. When `true`, `initialize` registers the AppsFlyer session-ready listener and calls `start` inside it, so the app must not register its own listener (or must not map `initialize`). When `false`, `initialize` configures the AppsFlyer SDK but registers no listener and does not call `start`; the app calls `initialize(devKey:appId:)`, registers its own listener and starts inside it (for example after ATT consent). Commands gated on `onReady` are released by the next gated command that runs after `isSessionReady()` has turned true, since every `onReady` call re-checks it and nothing observes the transition itself
- Session start command (`start`), for manually resuming a session after `disabletracking`/`stoptracking` — map it as `disabletracking,start` with `stop_tracking: false`. Not needed per foreground: the session-ready listener registered by `initialize` starts each session
- Hashed-PII commands added in AppsFlyer SDK 7 — `setuseremail`, `setuserfirstname`, `setuserlastname`, `setuserfbloginid`, `clearuserpii` — with `email`, `first_name`, `last_name`, and `fb_login_id` parameters. The AppsFlyer SDK normalizes and SHA-256 hashes each value on-device before sending it, except `fb_login_id`, which AppsFlyer sends as an unhashed integer
- App invite OneLink ID configuration (`setappinviteonelink` command)
- User anonymization support (`anonymizeuser` command)
- Deep link handling via `handleopen` command, driven by Tealium's automatic deep link tracking (`url`, `source_application`, `annotation` parameters). Requires `config.sendDeepLinkEvent = true`, as the `deep_link` event is opt-in
- Ad revenue logging (`logadrevenue` command) with support for multiple ad networks
- GDPR/DMA consent data management (`setconsentdata` command). `is_user_subject_to_gdpr` is required; the three consent details are optional and, per AppsFlyer, must be left unmapped when GDPR does not apply. To include consent in the first session, map it ahead of initialize in the same command list: `"launch": "setconsentdata,initialize"`
- Partner data management (`setpartnerdata` command)
- Sharing filter for partners (`setsharingfilterforpartners` command)
- Phone number tracking support (`setphonenumber` command)
- Device language setting (`setcurrentdevicelanguage` command)
- Deep link resolution and appending parameters to deep link URLs
- Host configuration (`sethost` command)
- Currency setting support
- New `locationcoordinates` event
- Cross-platform command aliases: `stoptracking` (Android name for `disabletracking`) and `disabledevicetracking` (backwards-compatible alias for `anonymizeuser`) to support shared TiQ tags on iOS without duplication
- Validation for negative `deepLinkTimeout` values
- `fb_login_id` is accepted as a numeric string, not only a number, since webview data layer values arrive as strings

### Fixed
- Deep links arriving on a cold start are no longer lost — `handleOpen` is gated on `onReady`, which publishes once the session-ready listener fires. Host apps supporting Universal Links must also call `AppsFlyerLib.shared().handleLaunchOptions(_:)` in `application(_:didFinishLaunchingWithOptions:)`; a RemoteCommand has no access to `launchOptions`
- `isDebug` is set before any other SDK call during `initialize`, as AppsFlyer SDK 7 requires for debug logging to cover initialization
- `onReady` waits for `isSessionReady()` instead of treating credentials as readiness. An app that initializes AppsFlyer itself must register a session-ready listener, otherwise `isSessionReady()` never turns true and gated commands never run; commands waiting for readiness are logged at `.debug`
- `onReady` publishes on `TealiumQueues.backgroundSerialQueue`, where its subscribers are added; the AppsFlyer SDK fires the listener on the main queue and the observable is not synchronized

### Changed
- Update AppsFlyer iOS SDK to `>= 7.0.2, < 8.0` in SPM and CocoaPods; Carthage pins `>= 7.0.2`, having no compound-range operator, so a future 8.x may need a follow-up release to cap it
- Upgrade TealiumSwift dependency to `~> 2.19`
- **Breaking:** AppsFlyer SDK 7 replaces automatic session start with an explicit readiness model. `initialize` registers a session-ready listener and calls `start` inside it, skipping `start` while tracking is stopped. The AppsFlyer SDK keeps one listener, so `initialize` replaces a listener the app registered in `didFinishLaunching`; on a cold launch it runs before the session is ready, so the `isSessionReady()` check cannot protect it. Apps that need their own listener set `start_automatically_on_session_ready` to `false`
- `setHost` and `setPartnerData` call AppsFlyer SDK 7's renamed methods with the new argument order/labels. No change to the `AppsFlyerCommand` signatures or the `sethost`/`setpartnerdata` command parameters
- **Breaking:** `setphonenumber` now also requires `country_code`, matching AppsFlyer SDK 7's `setUserPhone(countryCode:phoneNumber:)`. A tag mapping only `phone_number` now fails validation instead of sending a number the AppsFlyer SDK can no longer accept alone
- **Breaking:** `disabletracking` now requires `stop_tracking` instead of defaulting to `false`. The old default resumed tracking whenever the parameter was unmapped, which could re-enable it for a user who had opted out
- **Breaking:** `AppsFlyerCommand` gained requirements for the new commands added in this release (including the hashed-PII ones), so existing conformances outside this library no longer compile
- **Breaking:** `AppsFlyerInstance.init(tealium:)` is now `init(tealium:logLevel:)`. Existing call sites no longer compile — pass `.silent` to keep 3.0.0's behaviour. The parameterless `AppsFlyerInstance()` initializer is unaffected
- `AppsFlyerRemoteCommand.init`'s `logLevel` still defaults, but now to `.error` instead of `.silent`, so integrators see error logs out of the box without opting in
- Attribution data for app opens is now delivered through `AppsFlyerDeepLinkDelegate.didResolveDeepLink`, which AppsFlyer SDK 7 uses in place of the removed `onAppOpenAttribution`/`onAppOpenAttributionFailure` callbacks. Event names and data shape are unchanged. Deferred links are skipped there, since `onConversionDataSuccess` already reports that install as `conversion_data_received`, as in 3.0.0
- Refactor `AppsFlyerConstants` `Configuration` to `String`-based `CaseIterable` enum for improved type safety
- Standardize parameter names and command structures across all classes
- Add `AppsFlyerCommandError` with typed error cases (`missingParameter`, `invalidParameterValue`, `invalidParameterType`) replacing scattered `print` calls; errors now route through `RemoteCommandLogger` with configurable log level, and executed commands are logged at `.debug`
- Replace deprecated methods with current AppsFlyer SDK equivalents
- Replace event enum with an `eventsMap` dictionary for better maintainability
- Update advertising identifier and IDFV collection settings with deprecation handling

### Removed
- **Breaking:** `setuseremails` command and its `customer_emails`/`email_hash_type` parameters. AppsFlyer SDK 7 removed the underlying `setUserEmails(_:withCryptType:)` API — hashing is no longer optional. Use `setuseremail` with the new `email` parameter instead; a tag still mapping `setuseremails` now falls through to the generic event-logging path instead of setting user emails, and both parameters ride along as that event's data — unmap them
- **Breaking:** `wait_for_att_user_authorization_timeout_interval` setting. AppsFlyer SDK 7 deprecated `waitForATTUserAuthorization(timeoutInterval:)`; in 7.0.2 it is a no-op that no longer gates `start`, so collecting ATT consent before `start` is the host app's responsibility. An app that must collect consent first sets `start_automatically_on_session_ready` to `false` and registers its own listener; `onReady` still releases commands queued on that path, once the next gated command runs after `isSessionReady()` has turned true. A tag still mapping this setting is silently ignored

## [3.0.0] - 2024-03-15

### Added
- Carthage/SPM build and publish scripts (`publish.sh`, `xcframeworks.sh`)

### Changed
- Replace `TealiumRegistration` and notification-based initialization with `onReady` callbacks

### Fixed
- Resolve XCFramework build issues caused by naming conflict with `AppsFlyerLib` class

## [2.1.2] - 2023-02-22

### Fixed
- Remove `arm64` architecture exclusion for simulators (was causing build failures on Apple Silicon Macs)

## [2.1.1] - 2023-02-08

### Added
- Custom command support

### Changed
- Update AppsFlyer SDK version
- Update to latest tealium-swift SDK

## [2.1.0] - 2022-02-03

### Added
- Remote command `name` and `version` metadata (used by TealiumSwift to track active remote commands)

### Fixed
- Fix remote command interoperability with TealiumSwift 2.5+

### Changed
- Use JSON file for Carthage dependency resolution
- Update SPM to `upToNextMajor` version strategy
- Update podspec for Tealium 2.6

## [2.0.0] - 2020-10-20

### Added
- JSON-based remote command implementation
- XCFramework support

### Changed
- Rename `Tracker` to `Instance` throughout the codebase
- Refactor to adopt JSON remote command structure

## [1.0.1] - 2020-06-05

### Changed
- Sample app updates and finalize remote command implementation
- Update Objective-C interoperability files

## [1.0.0] - 2020-05-06

### Added
- Initial stable release
- Objective-C delegate methods
- Constants definitions

## [0.0.1] - 2020-04-06

### Added
- Initial pre-release version
