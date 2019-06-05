// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Bismuth",
    products: [
        .library(
            name: "Bismuth",
            targets: ["Bismuth"]),
        ],
    dependencies: [],
    targets: [
        .target(
            name: "Bismuth",
            dependencies: []
        .testTarget(
            name: "BismuthTests",
            dependencies: ["Bismuth"])
        ]
)
