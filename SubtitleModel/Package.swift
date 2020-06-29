// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SubtitleModel",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(name: "SubtitleModel", targets: ["SubtitleModel"])
    ],
    dependencies: [
        .package(url: "https://github.com/teufelaudio/FoundationExtensions", .upToNextMajor(from: "0.0.0")),
        .package(name: "FunctionalParser", path: "../FunctionalParser")
    ],
    targets: [
        .target(
            name: "SubtitleModel",
            dependencies: [
                .product(name: "FoundationExtensionsStatic", package: "FoundationExtensions"),
                "FunctionalParser"
            ]
        ),
        .testTarget(name: "SubtitleModelTests", dependencies: ["SubtitleModel"])
    ]
)
