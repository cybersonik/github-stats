// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let dependencies: [Package.Dependency]
#if os(Linux)
dependencies = [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0")
    ]
#else
dependencies = [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.55.1")
    ]
#endif

internal let plugins: [Target.PluginUsage]
#if os(Linux)
    plugins = []
#else
    plugins = [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
#endif


internal let package = Package(
    name: "GitHubStats",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "githubstats",
            targets: ["GitHubStats"]),
        .library(name: "GitHubStatsCore", targets: ["GitHubStatsCore"])
    ],
    dependencies: dependencies,
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "GitHubStats",
            dependencies: [
                "GitHubStatsCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            plugins: plugins
        ),
        .target(
            name: "GitHubStatsCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            plugins: plugins
        ),
        .testTarget(
            name: "GitHubStatsCoreTests",
            dependencies: ["GitHubStatsCore"],
            plugins: plugins
        )
    ]
)
