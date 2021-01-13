// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "ThirdParty",
  platforms: [
    .macOS("10.15")
  ],
  products: [
    .library(
      name: "Sameboy",
      targets: ["Core", "JoyKit"]
    ),
  ],
  targets: [
    .target(
      name: "Core",
      path: "Sameboy/Core",
      cSettings: [
        .define("GB_INTERNAL"),
      ]
    ),
    .target(
      name: "JoyKit",
      path: "Sameboy/JoyKit"
    ),
  ]
)

