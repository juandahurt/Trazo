// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCanvas",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TCanvas",
            targets: ["TCanvas"]),
    ],
    dependencies: [
        .package(path: "../TGraphics"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TCanvas",
            dependencies: [
                .byName(name: "TGraphics")
            ]
        ),

    ]
)
