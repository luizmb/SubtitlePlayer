// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TerminalSubtitlePlayer",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "TerminalSubtitlePlayer", targets: ["TerminalSubtitlePlayer"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.0.0")),
        .package(url: "https://github.com/teufelaudio/FoundationExtensions", .upToNextMajor(from: "0.0.0")),
        .package(name: "Gzip", url: "https://github.com/1024jp/GzipSwift", .upToNextMajor(from: "5.1.1")),
        .package(name: "SubtitlePublisher", path: "../SubtitlePublisher"),
        .package(name: "SubtitleDownloader", path: "../SubtitleDownloader")
    ],
    targets: [
        .target(
            name: "TerminalSubtitlePlayer",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Gzip", package: "Gzip"),
                .product(name: "FoundationExtensionsStatic", package: "FoundationExtensions"),
                "SubtitlePublisher",
                "SubtitleDownloader"
            ]
        )
    ]
)
