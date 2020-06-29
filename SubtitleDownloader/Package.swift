// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SubtitleDownloader",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(name: "SubtitleDownloader", targets: ["SubtitleDownloader"])
    ],
    dependencies: [
        .package(url: "https://github.com/teufelaudio/FoundationExtensions", .upToNextMajor(from: "0.0.0"))
    ],
    targets: [
        .target(
            name: "SubtitleDownloader",
            dependencies: [
                .product(name: "FoundationExtensionsStatic", package: "FoundationExtensions")
            ]
        )
    ]
)
