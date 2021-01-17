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
      exclude: ["graphics"],
      cSettings: [
        .define("GB_INTERNAL"),
      ]
    ),
    .target(
      name: "JoyKit",
      path: "Sameboy/JoyKit",
      exclude: ["ControllerConfiguration.inc"]
    ),
    .target(
      name: "Cocoa",
      path: "Sameboy/Cocoa",
      exclude: [
        "AppIcon.icns",
        "AppDelegate.m",
        "CPU.png",
        "CPU@2x.png",
        "Cartridge.icns",
        "ColorCartridge.icns",
        "Display.png",
        "Display@2x.png",
        "Info.plist",
        "Joypad.png",
        "Joypad@2x.png",
        "Joypad~dark.png",
        "Joypad~dark@2x.png",
        "License.html",
        "PkgInfo",
        "Speaker.png",
        "Speaker@2x.png",
        "Speaker~dark.png",
        "Speaker~dark@2x.png",
        "main.m",
      ],
      sources: [
        "BigSurToolbar.h",
        "Document.h",
        "Document.m",
        "Emulator.h",
        "Emulator.m",
        "GBAudioClient.h",
        "GBAudioClient.m",
        "GBBorderView.h",
        "GBBorderView.m",
        "GBButtons.h",
        "GBButtons.m",
        "GBCallbackBridge.h",
        "GBCallbackBridge.m",
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

