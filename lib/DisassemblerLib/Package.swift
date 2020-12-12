// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DisassemblerLib",
  platforms: [
    .iOS("13.0"),
    .macOS("10.15")
  ],
  products: [
    .executable(
      name: "gbdis",
      targets: ["gbdis"]),
    .library(
      name: "LR35902",
      targets: ["LR35902"]
    )
  ],
  targets: [
    .target(
      name: "gbdis",
      dependencies: [
        "LR35902",
      ]),
    .target(
      name: "LR35902",
      dependencies: [
        "FoundationExtensions",
        "CPU",
        "Disassembler",
        "RGBDS",
      ]
    ),
    .target(
      name: "Disassembler",
      dependencies: ["CPU"]
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
      name: "LR35902Tests",
      dependencies: ["LR35902"],
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

