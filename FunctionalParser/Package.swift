// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FunctionalParser",
    platforms: [.macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v6)],
    products: [
        .library(name: "FunctionalParser", targets: ["FunctionalParser"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "FunctionalParser"),
        .testTarget(name: "FunctionalParserTests", dependencies: ["FunctionalParser"])
    ]
)
