// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Bismuth",
    platforms: [
        .iOS(.v9),
    ],
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
            dependencies: ["Bismuth"]
          )
      ]
    swiftLanguageVersions: [ .v4, .v5 ]
)
