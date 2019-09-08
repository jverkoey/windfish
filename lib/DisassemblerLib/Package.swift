// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DisassemblerLib",
  products: [
    .executable(
      name: "gbdis",
      targets: ["gbdis"]),
    .library(
      name: "LR35902",
      targets: ["LR35902"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
  ],
  targets: [
    .target(
      name: "gbdis",
      dependencies: [
        "LR35902",
        "DisassemblyRequest",
      ]),

    .target(
      name: "LR35902",
      dependencies: [
        "FixedWidthInteger",
        "AssemblyGenerator",
        "CPU",
        "Disassembler",
        "SwiftProtobuf",
      ]
    ),
    .testTarget(
      name: "LR35902Tests",
      dependencies: [
        "LR35902",
      ]
    ),

    .target(
      name: "AssemblyGenerator",
      dependencies: ["FixedWidthInteger"]),

    .target(
      name: "FixedWidthInteger",
      dependencies: []),

    .target(
      name: "CPU",
      dependencies: []
    ),
    .testTarget(
      name: "CPUTests",
      dependencies: ["CPU"]
    ),

    .target(
      name: "Disassembler",
      dependencies: ["CPU"]
    ),

    .target(
      name: "DisassemblyRequest",
      dependencies: ["SwiftProtobuf", "CPU"]
    ),
  ]
)

