// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Aleph",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Aleph",
            targets: ["Aleph"]
        ),
    ],
    dependencies: [
        .package(name: "Tartarus", path: "../Tartarus")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Aleph",
            dependencies: ["Tartarus"],
            resources: [
                .process("Graphics/Shaders/Textures.metal"),
                .process("Graphics/Shaders/Merge.metal"),
                .process("Resources/shape-0.png"),
                .process("Resources/shape-1.png"),
                .process("Resources/shape-2.png"),
                .process("Resources/shape-3.png"),
                .process("Resources/gran-0.png"),
                .process("Resources/gran-1.png"),
            ]
        ),

    ]
)
