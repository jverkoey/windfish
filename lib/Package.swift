// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Windfish",
  platforms: [
    .macOS("10.15")
  ],
  products: [
    .library(
      name: "Windfish",
      targets: ["Windfish"]
    )
  ],
  targets: [
    .target(
      name: "Windfish",
      dependencies: [
        "FoundationExtensions",
        "CPU",
        "RGBDS",
      ]
    ),
    .target(
      name: "CPU",
      dependencies: []
    ),
    .target(
      name: "RGBDS",
      dependencies: [
        "FoundationExtensions",
      ]
    ),
    .target(
      name: "FoundationExtensions",
      dependencies: []
    ),

    .testTarget(
      name: "WindfishTests",
      dependencies: ["Windfish"],
      resources: [
        .copy("Resources"),
      ]
    ),
    .testTarget(
      name: "MooneyeTests",
      dependencies: ["Windfish"],
      resources: [
        .copy("Resources"),
      ]
    ),
    .testTarget(
      name: "CPUTests",
      dependencies: ["CPU"]
    ),
    .testTarget(
      name: "RGBDSTests",
      dependencies: ["RGBDS"]
    ),
  ]
)

