# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0]

### Added
- `AppsFlyerSessionMode`, a required constructor argument that decides who owns AppsFlyer SDK 7's single session-ready listener and `start`. `.automatic`: once AppsFlyer is initialized, the RemoteCommand registers the listener and calls `start` inside it, so the app must not register its own; if the session is already ready at that point it logs an error and registers nothing. `.appManaged`: the RemoteCommand never registers a listener or calls `start`; the app registers its own listener and starts inside it (for example after ATT consent). It is deliberately not a remote setting, because it has to match the app code. "Initialized" covers both the `initialize` command and an app calling `AppsFlyerLib.shared().initialize(devKey:appId:)` itself, which is also detected when the instance is constructed
- Hashed-PII commands added in AppsFlyer SDK 7 — `setuseremail`, `setuserfirstname`, `setuserlastname`, `setuserfbloginid`, `clearuserpii` — with `email`, `first_name`, `last_name`, and `fb_login_id` parameters. The AppsFlyer SDK normalizes and SHA-256 hashes each value on-device before sending it, except `fb_login_id`, which AppsFlyer sends as an unhashed integer
- App invite OneLink ID configuration (`setappinviteonelink` command)
- User anonymization support (`anonymizeuser` command)
- Deep link handling via `handleopen` command, driven by Tealium's automatic deep link tracking (`url`, `source_application`, `annotation` parameters). Requires `config.sendDeepLinkEvent = true`, as the `deep_link` event is opt-in. Gated on `onReady`, so links arriving on a cold start are not dropped before AppsFlyer is initialized. On AppsFlyer SDK 7.0.2 a URI-scheme link handled after initialize and before `start` still resolves through `didResolveDeepLink`; OneLink URLs before `start` are unverified. Host apps supporting Universal Links must also call `AppsFlyerLib.shared().handleLaunchOptions(_:)` in `application(_:didFinishLaunchingWithOptions:)`; a RemoteCommand has no access to `launchOptions`
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
- `isDebug` is set before any other SDK call during `initialize`, as AppsFlyer SDK 7 requires for debug logging to cover initialization

### Changed
- Update AppsFlyer iOS SDK to `>= 7.0.2, < 8.0` (SPM, CocoaPods) and `>= 7.0.2` (Carthage)
- Upgrade TealiumSwift dependency to `~> 2.19`
- **Breaking:** `TealiumAppsFlyer.xcframework` (release zip, Carthage) is now a static framework and no longer bundles its own copy of AppsFlyerLib, which duplicated every AppsFlyer class when the app also linked the SDK.
- **Breaking:** Previously (AppsFlyer SDK 6.x / 3.0.0) the app had to call `AppsFlyerLib.shared().start()` itself in `applicationDidBecomeActive` on every foreground; the RemoteCommand never called `start`. With AppsFlyer SDK 7, `start` must instead be called inside the SDK's session-ready listener, and who registers that listener and calls `start` in it is chosen with `AppsFlyerSessionMode` (see Added): in `.automatic` the RemoteCommand registers the listener and calls `start`, so apps must remove their own `applicationDidBecomeActive` call to `start`; in `.appManaged` the app registers its own listener and calls `start` inside it
- **Breaking:** `onReady` means "AppsFlyer is initialized" (credentials set, by the `initialize` command or by the app), and its callbacks run on the main thread. Commands that log to the SDK (`logEvent`, `logLocation`, `logAdRevenue`, `handleOpen`) are gated on it and queue until then. On AppsFlyer SDK 7.0.2, events logged after initialize and before `start` are cached by the SDK rather than sent; whether that `start` sends them in the same session is unverified
- **Breaking:** `setphonenumber` now also requires `country_code`, matching AppsFlyer SDK 7's `setUserPhone(countryCode:phoneNumber:)`. A tag mapping only `phone_number` now fails validation
- **Breaking:** `disabletracking` now requires `stop_tracking` instead of defaulting to `false`, which resumed tracking whenever the parameter was unmapped
- **Breaking:** `AppsFlyerCommand` changed: `setUserEmails(emails:with:)` is removed, `setPhoneNumber(_:)` is now `setUserPhone(countryCode:phoneNumber:)`, and the new commands added in this release (including the hashed-PII ones) are new requirements, so existing conformances outside this library no longer compile
- **Breaking:** initializers now require a `sessionMode`, and the log level is passed once, to whichever object creates the logger:
  - `AppsFlyerInstance()` is now `AppsFlyerInstance(sessionMode:)` (logs nothing, tracks no attribution)
  - `AppsFlyerInstance.init(tealium:)` is now `init(tealium:sessionMode:logLevel:)`. Pass `.silent` to disable logging
  - `AppsFlyerRemoteCommand(type:)` is now `AppsFlyerRemoteCommand(sessionMode:type:logLevel:)`; `logLevel` defaults to `.error`
  - `AppsFlyerRemoteCommand.init(appsFlyerInstance:type:)`: `appsFlyerInstance` no longer has a default value; the command logs through the instance's `logger`
- `RemoteCommandLogger` and its `init(logLevel:)` are now public, so custom `AppsFlyerCommand` conformers can supply one
- App-open attribution is now delivered through `AppsFlyerDeepLinkDelegate.didResolveDeepLink`, replacing the removed `onAppOpenAttribution`/`onAppOpenAttributionFailure` callbacks. Event names and data shape are unchanged. Deferred links do not track `app_open_attribution`; `onConversionDataSuccess` already reports that install as `conversion_data_received`
- Refactor `AppsFlyerConstants` `Configuration` to `String`-based `CaseIterable` enum for improved type safety
- Standardize parameter names and command structures across all classes
- Add `AppsFlyerCommandError` with typed error cases (`missingParameter`, `invalidParameterValue`, `invalidParameterType`) replacing scattered `print` calls; errors now route through `RemoteCommandLogger` with configurable log level, and executed commands are logged at `.debug`
- Replace deprecated methods with current AppsFlyer SDK equivalents
- Replace event enum with an `eventsMap` dictionary for better maintainability
- Update advertising identifier and IDFV collection settings with deprecation handling

### Removed
- **Breaking:** `setuseremails` command and its `customer_emails`/`email_hash_type` parameters; AppsFlyer SDK 7 removed `setUserEmails(_:withCryptType:)`. Use `setuseremail` with the `email` parameter instead. A tag still mapping `setuseremails` now logs a generic event named after the command, with both parameters as its data — unmap them
- **Breaking:** `wait_for_att_user_authorization_timeout_interval` setting. AppsFlyer SDK 7 deprecated `waitForATTUserAuthorization(timeoutInterval:)` and it no longer gates `start`. Apps that must collect ATT consent first use `AppsFlyerSessionMode.appManaged` and start inside their own listener. A tag still mapping this setting is silently ignored

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
