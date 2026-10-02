// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HobbyMaxer",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "HobbyMaxerCore"),
        .executableTarget(name: "HobbyMaxer", dependencies: ["HobbyMaxerCore"]),
        .testTarget(name: "HobbyMaxerCoreTests", dependencies: ["HobbyMaxerCore"]),
    ]
)
