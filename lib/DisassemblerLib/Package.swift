// swift-tools-version:5.0
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
        "FixedWidthInteger",
        "AssemblyGenerator",
        "CPU",
        "Disassembler",
      ]
    ),
    .target(
      name: "AssemblyGenerator",
      dependencies: ["FixedWidthInteger"]),
    .target(
      name: "Disassembler",
      dependencies: ["CPU"]
    ),
    .target(
      name: "CPU",
      dependencies: []
    ),
    .target(
      name: "FixedWidthInteger",
      dependencies: []
    ),

    .testTarget(
      name: "LR35902Tests",
      dependencies: ["LR35902"]
    ),
    .testTarget(
      name: "CPUTests",
      dependencies: ["CPU"]
    ),
    .testTarget(
      name: "DisassemblerTests",
      dependencies: ["Disassembler"]
    ),
  ]
)

