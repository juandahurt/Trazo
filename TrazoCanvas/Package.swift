// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrazoCanvas",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TrazoCanvas",
            targets: ["TrazoCanvas"]),
    ],
    dependencies: [
        .package(path: "./../TrazoCore"),
        .package(path: "./../TrazoEngine")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TrazoCanvas",
            dependencies: [
                .product(name: "TrazoCore", package: "TrazoCore"),
                .product(name: "TrazoEngine", package: "TrazoEngine")
            ]
        ),
    ]
)
