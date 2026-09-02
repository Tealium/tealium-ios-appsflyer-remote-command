# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.0] - 2026-04-29

### Added
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

### Fixed
- Deep links arriving on a cold start are no longer lost. `handleOpen` is now gated on `onReady`, and `onReady` publishes after `start()`, so the SDK never receives a deep link before the session has started

### Changed
- Update AppsFlyer iOS SDK to 6.17.9
- Update tealium-swift to 2.18.3
- Upgrade TealiumSwift dependency to `~> 2.18`
- Upgrade AppsFlyerFramework to `~> 6.17`
- **Breaking:** `disabletracking` now requires `stop_tracking` instead of defaulting to `false`. The old default resumed tracking whenever the parameter was unmapped, which could re-enable it for a user who had opted out
- **Breaking:** `AppsFlyerCommand` gained requirements for the new commands, so existing conformances outside this library no longer compile
- **Breaking:** `setUserEmails(emails:with:)` now takes an `EmailCryptType` instead of an `Int`, and `email_hash_type` accepts only `0` (none) and `3` (SHA256) — the values AppsFlyer kept in SDK 6.x. Tags mapping the removed SHA1/MD5 types now fail validation instead of hashing with an undefined type
- Refactor `AppsFlyerConstants` `Configuration` to `String`-based `CaseIterable` enum for improved type safety
- Standardize parameter names and command structures across all classes
- Add `AppsFlyerCommandError` with typed error cases (`missingParameter`, `invalidParameterValue`, `invalidParameterType`) replacing scattered `print` calls; errors now route through `RemoteCommandLogger` with configurable log level
- Replace deprecated methods with current AppsFlyer SDK equivalents
- Improve `filterVariables` to use a `Set` for excluded keys
- Replace event enum with an `eventsMap` dictionary for better maintainability
- Update advertising identifier and IDFV collection settings with deprecation handling

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
