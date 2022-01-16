// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Nav",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Nav",
            targets: ["Nav"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../Model"),
        .package(path: "../Umbrella")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Nav",
            dependencies: [
                .byNameItem(name: "Model", condition: nil),
                .byNameItem(name: "Umbrella", condition: nil)
            ]),
        .testTarget(
            name: "NavTests",
            dependencies: ["Nav"]),
    ]
)
