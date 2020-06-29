// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AppModuleSettings",
    platforms: [.iOS(.v14), .tvOS(.v14), .macOS(.v10_16), .watchOS(.v7)],
    products: [
        .library(name: "AppModuleSettings", targets: ["AppModuleSettings"])
    ],
    dependencies: [
        .package(url: "https://github.com/teufelaudio/FoundationExtensions", .upToNextMajor(from: "0.0.0")),
        .package(name: "SwiftRex", url: "https://github.com/SwiftRex/SwiftRex", .branch("develop")),
        .package(name: "SubtitleModel", path: "../SubtitleModel"),
        .package(name: "SubtitleDownloader", path: "../SubtitleDownloader")
    ],
    targets: [
        .target(
            name: "AppModuleSettings",
            dependencies: [
                .product(name: "FoundationExtensionsStatic", package: "FoundationExtensions"),
                .product(name: "CombineRex", package: "SwiftRex"),
                "SubtitleModel",
                "SubtitleDownloader"
            ]
        )
    ]
)
