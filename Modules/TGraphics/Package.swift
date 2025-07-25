// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TGraphics",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TGraphics",
            targets: ["TGraphics"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TGraphics", resources: [
                .process("Shaders/Textures.metal"),
                .process("Shaders/Drawing.metal"),
                .process("Textures/h-spray-m.png"),
                .process("Textures/noise.png"),
            ]),
        .testTarget(name: "TGraphicsTests",
                    dependencies: [.byName(name: "TGraphics")])
    ]
)
