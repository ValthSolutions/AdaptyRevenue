// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdaptyRevenue",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "AdaptyRevenue",
            targets: ["AdaptyRevenue"]),
        
    ],
    dependencies: [
        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS.git", branch: "master")
    ],
    targets: [
        .target(
            name: "AdaptyRevenue",
            dependencies: [
                .product(name: "Adapty", package: "AdaptySDK-iOS")
            ],
        ),

    ]
)
