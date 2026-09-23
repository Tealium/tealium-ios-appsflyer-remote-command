# tealium-ios-appsflyer-remote-command

[![License](https://img.shields.io/badge/license-Proprietary-blue.svg?style=flat
           )](https://github.com/Tealium/tealium-swift/blob/master/LICENSE.txt)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)



## Session modes

AppsFlyer SDK 7 keeps a single session-ready listener, and `AppsFlyerLib.shared().start()` has to be called inside it. `AppsFlyerSessionMode` decides who owns that listener. It is a required constructor argument, not a remote setting, because it has to match what the app code does.

| Mode | Who registers the listener | Who calls `start()` |
|------|----------------------------|---------------------|
| `.automatic` | The RemoteCommand, once AppsFlyer is initialized. The app must not register its own listener, or it replaces ours. If the session is already ready, the RemoteCommand logs an error and registers nothing. | The RemoteCommand's listener |
| `.appManaged` | The app | The app, inside its listener |

"Initialized" means AppsFlyer has credentials: either the `initialize` command ran, or the app called `AppsFlyerLib.shared().initialize(devKey:appId:)` itself. If the app does that before building the `AppsFlyerInstance`/`AppsFlyerRemoteCommand`, the instance detects it at construction and, in `.automatic`, registers the listener right away.

`onReady` means AppsFlyer is initialized, not that the session has started. Its callbacks run on the main thread, at once if AppsFlyer is already initialized, otherwise in the order they were queued once it is.

### Constructing the RemoteCommand

```swift
// No attribution tracking; the RemoteCommand creates its own AppsFlyerInstance.
let command = AppsFlyerRemoteCommand(sessionMode: .automatic,
                                     type: .webview,
                                     logLevel: .error)

// Attribution tracking (onConversionDataSuccess, didResolveDeepLink) through Tealium.
let instance = AppsFlyerInstance(tealium: tealium, sessionMode: .automatic, logLevel: .error)
let trackingCommand = AppsFlyerRemoteCommand(appsFlyerInstance: instance, type: .webview)
```

### `.appManaged` examples

If the app initializes AppsFlyer itself, it can register right away. Don't also map the `initialize` command.

```swift
let command = AppsFlyerRemoteCommand(sessionMode: .appManaged)
let appsFlyerLib = AppsFlyerLib.shared()
appsFlyerLib.initialize(devKey: appDevKey, appId: appId)
appsFlyerLib.registerSessionReadyListener { appsFlyerLib.start() }
```

If the `initialize` command initializes AppsFlyer, register only once `onReady` has run.

```swift
let command = AppsFlyerRemoteCommand(sessionMode: .appManaged)
command.onReady { appsFlyerLib in
    // Runs only after the `initialize` command has run
    appsFlyerLib.registerSessionReadyListener { appsFlyerLib.start() }
}
```

To start only after App Tracking Transparency consent:

```swift
appsFlyerLib.registerSessionReadyListener {
    ATTrackingManager.requestTrackingAuthorization { _ in AppsFlyerLib.shared().start() }
}
```

In `.automatic` mode you can still use `onReady` for SDK calls that need initialization, as long as you don't register a listener in it.

### Universal Links

In both modes, apps supporting Universal Links must call `AppsFlyerLib.shared().handleLaunchOptions(launchOptions)` in `application(_:didFinishLaunchingWithOptions:)`, before the listener is registered. Otherwise the SDK does not wait for a cold-launch Universal Link before firing the session-ready listener. A RemoteCommand has no access to `launchOptions`, so it can't do this for you.

## Documentation
For full documentation, please see the Tealium Learning Community: 

[https://docs.tealium.com/platforms/remote-commands/integrations/appsflyer/](https://docs.tealium.com/platforms/remote-commands/integrations/appsflyer/)

## License

Use of this software is subject to the terms and conditions of the license agreement contained in the file titled "LICENSE.txt".  Please read the license before downloading or using any of the files contained in this repository. By downloading or using any of these files, you are agreeing to be bound by and comply with the license agreement.

 
---
Copyright (C) 2012-2026, Tealium Inc.