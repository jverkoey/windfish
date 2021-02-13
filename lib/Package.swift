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
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
  ],
  targets: [
    .target(
      name: "ocarina",
      dependencies: [
        "Windfish",
        "Tracing",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .target(
      name: "Windfish",
      dependencies: [
        "FoundationExtensions",
        "CPU",
        "RGBDS",
        "LR35902",
        "Tracing",
      ]
    ),
    .target(
      name: "Tracing",
      dependencies: [
        "LR35902"
      ]
    ),
    .target(
      name: "LR35902",
      dependencies: [
        "CPU"
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
    .testTarget(
      name: "RGBDSTests",
      dependencies: ["RGBDS"]
    ),

    .target(
      name: "FoundationExtensions",
      dependencies: []
    ),
    .testTarget(
      name: "FoundationExtensionsTests",
      dependencies: ["FoundationExtensions"]
    ),

    .testTarget(
      name: "WindfishTests",
      dependencies: ["Windfish"],
      resources: [
        .copy("Resources"),
      ]
    ),
    .testTarget(
      name: "LR35902Tests",
      dependencies: ["LR35902"]
    ),
    .testTarget(
      name: "TracingTests",
      dependencies: ["Tracing", "FoundationExtensions"]
    ),
    .testTarget(
      name: "CPUTests",
      dependencies: ["CPU"]
    ),
  ]
)

