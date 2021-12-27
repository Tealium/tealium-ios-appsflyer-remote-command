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
        .package(url: "https://github.com/tealium/tealium-swift", from: "2.6.0"),
        .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework", from: "6.4.0")
    ],
    targets: [
        .target(
            name: "TealiumAppsFlyer",
            dependencies: [
                .product(name: "TealiumCore", package: "tealium-swift"),
                .product(name: "TealiumRemoteCommands", package: "tealium-swift"),
                .product(name: "AppsFlyerLib", package: "AppsFlyerLib")
            ],
            path: "./Sources"),
        .testTarget(
            name: "TealiumAppsFlyerTests",
            dependencies: ["TealiumAppsFlyer"],
            path: "./Tests")
    ]
)
