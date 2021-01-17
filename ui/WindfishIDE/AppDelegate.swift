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
      "GBRewindLength": 10,
    ])

    JOYController.start(on: RunLoop.current, withOptions: [
      JOYAxes2DEmulateButtonsKey: true,
      JOYHatsEmulateButtonsKey: true
    ])
  }
}
