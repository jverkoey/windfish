// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "gbdis",
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
      dependencies: ["LR35902"]),
    .testTarget(
      name: "LR35902Tests",
      dependencies: ["LR35902"]),

    .target(
      name: "LR35902",
      dependencies: ["FixedWidthInteger", "AssemblyGenerator", "CPU", "Disassembler"]),

    .target(
      name: "AssemblyGenerator",
      dependencies: ["FixedWidthInteger"]),

    .target(
      name: "FixedWidthInteger",
      dependencies: []),

    .target(
      name: "CPU",
      dependencies: []),
    .testTarget(
      name: "CPUTests",
      dependencies: ["CPU"]),

    .target(
      name: "Disassembler",
      dependencies: ["CPU"]),
  ]
)

