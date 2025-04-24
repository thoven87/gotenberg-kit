// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

let package = Package(
    name: "gotenberg-kit",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GotenbergKit",
            targets: ["GotenbergKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GotenbergKit",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ]
        ),
        .testTarget(
            name: "GotenbergKitTests",
            dependencies: ["GotenbergKit"],
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
