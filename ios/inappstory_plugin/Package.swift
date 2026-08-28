// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "inappstory_plugin",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "inappstory-plugin", targets: ["inappstory_plugin"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/inappstory/IAS-iOS-SPM.git", exact: "1.29.5")
    ],
    targets: [
        .target(
            name: "inappstory_plugin",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "InAppStorySDK", package: "IAS-iOS-SPM")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
