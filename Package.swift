// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "subt",
    products: [
        .executable(name: "subt", targets: ["subt"]),
        .library(name: "SubtitlePlayer", targets: ["SubtitlePlayer"]),
        .library(name: "OpenSubtitlesDownloader", targets: ["OpenSubtitlesDownloader"]),
        .library(name: "Common", targets: ["Common"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", "4.0.0" ..< "5.0.0")
    ],
    targets: [
        .target(name: "Common", dependencies: []),
        .target(name: "SubtitlePlayer", dependencies: ["Common", "RxSwift"]),
        .target(name: "OpenSubtitlesDownloader", dependencies: ["Common", "RxSwift"]),
        .target(name: "subt", dependencies: ["Common", "SubtitlePlayer", "OpenSubtitlesDownloader"]),
        .testTarget(name: "CommonTests", dependencies: ["Common"]),
        .testTarget(name: "SubtitlePlayerTests", dependencies: ["SubtitlePlayer"]),
        .testTarget(name: "subtTests", dependencies: ["subt"])
    ]
)
