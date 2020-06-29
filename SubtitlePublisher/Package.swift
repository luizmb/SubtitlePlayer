// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SubtitlePublisher",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(name: "SubtitlePublisher", targets: ["SubtitlePublisher"])
    ],
    dependencies: [
        .package(url: "https://github.com/teufelaudio/FoundationExtensions", .upToNextMajor(from: "0.0.0")),
        .package(name: "SubtitleModel", path: "../SubtitleModel")
    ],
    targets: [
        .target(
            name: "SubtitlePublisher",
            dependencies: [
                .product(name: "FoundationExtensionsStatic", package: "FoundationExtensions"),
                "SubtitleModel"
            ]
        )
    ]
)
