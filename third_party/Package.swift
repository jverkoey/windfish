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
      targets: ["Core", "JoyKit", "Cocoa"]
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
    .target(
      name: "Cocoa",
      path: "Sameboy/Cocoa",
      sources: [
        "BigSurToolbar.h",
        "CallbackBridge.h",
        "CallbackBridge.m",
        "Document.h",
        "Document.m",
        "GBAudioClient.h",
        "GBAudioClient.m",
        "GBBorderView.h",
        "GBBorderView.m",
        "GBButtons.h",
        "GBButtons.m",
        "GBCheatTextFieldCell.h",
        "GBCheatTextFieldCell.m",
        "GBCheatWindowController.h",
        "GBCheatWindowController.m",
        "GBColorCell.h",
        "GBColorCell.m",
        "GBCompleteByteSlice.h",
        "GBCompleteByteSlice.m",
        "GBGLShader.h",
        "GBGLShader.m",
        "GBImageCell.h",
        "GBImageCell.m",
        "GBImageView.h",
        "GBImageView.m",
        "GBMemoryByteArray.h",
        "GBMemoryByteArray.m",
        "GBOpenGLView.h",
        "GBOpenGLView.m",
        "GBOptionalVisualEffectView.h",
        "GBOptionalVisualEffectView.m",
        "GBPreferencesWindow.h",
        "GBPreferencesWindow.m",
        "GBSplitView.h",
        "GBSplitView.m",
        "GBTerminalTextFieldCell.h",
        "GBTerminalTextFieldCell.m",
        "GBView.h",
        "GBView.m",
        "GBViewGL.h",
        "GBViewGL.m",
        "GBViewMetal.h",
        "GBViewMetal.m",
        "GBWarningPopover.h",
        "GBWarningPopover.m",
        "KeyboardShortcutPrivateAPIs.h",
        "NSImageNamedDarkSupport.m",
        "NSObject+MavericksCompat.m",
        "NSString+StringForKey.h",
        "NSString+StringForKey.m",
      ],
      cSettings: [
        .headerSearchPath("../"),  // Enables Core/gb.h to be imported
      ]
    ),
  ]
)

