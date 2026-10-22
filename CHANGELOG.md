# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2026-10-22

### Added
- `AppsFlyerSessionMode` (required): `.automatic` lets the RemoteCommand register the session-ready listener and call `start`; `.appManaged` leaves both to the app, e.g. to wait for ATT consent. See README
- Hashed-PII commands: `setuseremail`, `setuserfirstname`, `setuserlastname`, `setuserfbloginid`, `clearuserpii`. The SDK hashes values on-device, except `fb_login_id`
- `handleopen` command for deep links. Requires `config.sendDeepLinkEvent = true`; for Universal Links the app also calls `AppsFlyerLib.shared().handleLaunchOptions(_:)`
- `setconsentdata` command (GDPR/DMA). Map it before `initialize` to include consent in the first session: `"launch": "setconsentdata,initialize"`
- Commands: `setappinviteonelink`, `anonymizeuser`, `logadrevenue`, `setpartnerdata`, `setsharingfilterforpartners`, `setphonenumber`, `setcurrentdevicelanguage`, `sethost`
- Currency setting, deep link URL resolution and parameters, `locationcoordinates` event
- Aliases: `stoptracking` (Android name for `disabletracking`) and `disabledevicetracking` (for `anonymizeuser`)
- `fb_login_id` accepts numeric strings
- Validation for negative `deepLinkTimeout`

### Fixed
- `isDebug` is set first in `initialize`, so debug logs cover initialization

### Changed
- AppsFlyer iOS SDK `>= 7.0.2, < 8.0` (SPM, CocoaPods), `>= 7.0.2` (Carthage); TealiumSwift `~> 2.19`
- **Breaking:** `TealiumAppsFlyer.xcframework` is static and no longer bundles AppsFlyerLib
- **Breaking:** remove your `AppsFlyerLib.shared().start()` call from `applicationDidBecomeActive`. SDK 7 starts inside the session-ready listener; `AppsFlyerSessionMode` decides who owns it
- **Breaking:** `onReady` means "AppsFlyer has credentials" and runs on the main thread. `logEvent`, `logLocation`, `logAdRevenue` and `handleOpen` queue until then
- **Breaking:** `setphonenumber` requires `country_code`
- **Breaking:** `disabletracking` requires `stop_tracking` (no longer defaults to `false`)
- **Breaking:** initializers require `sessionMode`: `AppsFlyerInstance(sessionMode:)`, `AppsFlyerInstance(tealium:sessionMode:logLevel:)`, `AppsFlyerRemoteCommand(sessionMode:type:logLevel:)` (`logLevel` defaults to `.error`). `AppsFlyerRemoteCommand(appsFlyerInstance:type:)` has no default instance
- **Breaking:** `AppsFlyerCommand` protocol changed (`setUserPhone(countryCode:phoneNumber:)`, new command methods); update custom conformances
- **Breaking:** `AppsFlyerInstance(tealium:sessionMode:logLevel:)` also sets `deepLinkDelegate`. If the app has its own, set it afterwards and forward to `didResolveDeepLink(_:)`
- App-open attribution comes from `didResolveDeepLink` (SDK 7 removed `onAppOpenAttribution`). Event names and data unchanged; deferred links are reported only as `conversion_data_received`
- `RemoteCommandLogger` is public
- Errors are logged as typed `AppsFlyerCommandError` through `RemoteCommandLogger` instead of `print`
- Standardized parameter names and command structures
- Internal: deprecated SDK methods replaced, `eventsMap` replaces the event enum, `AppsFlyerConstants.Configuration` is a `String` enum, IDFA/IDFV settings handle deprecations

### Removed
- **Breaking:** `setuseremails` and its `customer_emails`/`email_hash_type` parameters (removed in SDK 7). Use `setuseremail` with `email`, and unmap the old command, or it is logged as a custom event
- **Breaking:** `wait_for_att_user_authorization_timeout_interval`, ignored by SDK 7. Use `.appManaged` to wait for ATT consent

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
