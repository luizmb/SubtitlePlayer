// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "subt",
    products: [
        .executable(name: "subt", targets: ["subt"]),
        .library(name: "SubtitlePlayer", targets: ["SubtitlePlayer"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", "4.0.0" ..< "5.0.0")
    ],
    targets: [
        .target(name: "SubtitlePlayer", dependencies: ["RxSwift"]),
        .target(name: "subt", dependencies: ["SubtitlePlayer"]),
        .testTarget(name: "SubtitlePlayerTests", dependencies: ["SubtitlePlayer"]),
        .testTarget(name: "subtTests", dependencies: ["subt"])
    ]
)
