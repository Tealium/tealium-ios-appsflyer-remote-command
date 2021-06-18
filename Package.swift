// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TealiumAppsFlyer",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "TealiumAppsFlyer", targets: ["TealiumAppsFlyer"])
    ],
    dependencies: [
        .package(url: "https://github.com/tealium/tealium-swift", from: "2.3.0"),
        .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework", from: "6.3.0")
    ],
    targets: [
        .target(
            name: "TealiumAppsFlyer",
            dependencies: ["AppsFlyerLib", "TealiumCore", "TealiumRemoteCommands", "TealiumTagManagement"],
            path: "./Sources"),
        .testTarget(
            name: "TealiumAppsFlyerTests",
            dependencies: ["TealiumAppsFlyer"],
            path: "./Tests")
    ]
)