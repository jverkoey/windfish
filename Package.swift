// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "gbdis",
  products: [
    .executable(
      name: "gbdis",
      targets: ["gbdis"]),
  ],
  targets: [
    .target(
      name: "gbdis",
      dependencies: ["LR35902", "AssemblyGenerator", "FixedWidthInteger"]),
    .testTarget(
      name: "gbdisTests",
      dependencies: ["gbdis"]),

    .target(
      name: "LR35902",
      dependencies: ["FixedWidthInteger"]),
    .target(
      name: "AssemblyGenerator",
      dependencies: ["FixedWidthInteger"]),
    .target(
      name: "FixedWidthInteger",
      dependencies: []),
  ]
)

