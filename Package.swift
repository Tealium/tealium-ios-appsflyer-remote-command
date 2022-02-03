// swift-tools-version:5.5
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
        .package(name: "TealiumSwift", url: "https://github.com/tealium/tealium-swift", .upToNextMajor(from: "2.6.0")),
        .package(name: "AppsFlyerLib", url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework", .upToNextMajor(from: "6.4.0"))
    ],
    targets: [
        .target(
            name: "TealiumAppsFlyer",
            dependencies: [
                .product(name: "TealiumCore", package: "TealiumSwift"),
                .product(name: "TealiumRemoteCommands", package: "TealiumSwift"),
                .product(name: "AppsFlyerLib", package: "AppsFlyerLib")
            ],
            path: "./Sources",
            exclude: ["Support"]),
        .testTarget(
            name: "TealiumAppsFlyerTests",
            dependencies: ["TealiumAppsFlyer"],
            path: "./Tests",
            exclude: ["Support"])
    ]
)
