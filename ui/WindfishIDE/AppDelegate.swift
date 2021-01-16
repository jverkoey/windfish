import AppKit
import Cocoa
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    let defaults = UserDefaults.standard
    defaults.register(defaults: [
      "GBRight": kVK_RightArrow,
      "GBLeft": kVK_LeftArrow,
      "GBUp": kVK_UpArrow,
      "GBDown": kVK_DownArrow,

      "GBA": kVK_ANSI_X,
      "GBB": kVK_ANSI_Z,
      "GBSelect": kVK_Delete,
      "GBStart": kVK_Return,

      "GBTurbo": kVK_Space,
      "GBRewind": kVK_Tab,
      "GBSloMotion": kVK_Shift,

      "GBFilter": "NearestNeighbor",
      "GBColorCorrection": GB_COLOR_CORRECTION_EMULATE_HARDWARE.rawValue,
      "GBHighpassFilter": GB_HIGHPASS_REMOVE_DC_OFFSET.rawValue,
      "GBRewindLength": 10,
      "GBFrameBlendingMode": GB_FRAME_BLENDING_MODE_DISABLED.rawValue,

      "GBDMGModel": GB_MODEL_DMG_B.rawValue,
      "GBCGBModel": GB_MODEL_DMG_B.rawValue,
      "GBSGBModel": GB_MODEL_SGB2.rawValue,
      "GBRumbleMode": GB_RUMBLE_CARTRIDGE_ONLY.rawValue,
    ])

    JOYController.start(on: RunLoop.current, withOptions: [
      JOYAxes2DEmulateButtonsKey: true,
      JOYHatsEmulateButtonsKey: true
    ])
  }
}
