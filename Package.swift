// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "StackFlux",
// Uncomment for Combine:
//
//    platforms: [
//        .iOS(.v13),
//        .macOS(.v10_15),
//        .tvOS(.v13),
//        .watchOS(.v6),
//    ],
    products: [
        .library(
            name: "StackFlux",
            targets: ["StackFlux"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "StackFlux",
            dependencies: []),
        .testTarget(
            name: "StackFluxTests",
            dependencies: ["StackFlux"]),
    ]
)
