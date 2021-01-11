import Foundation
import Cocoa

final class PPUViewController: NSViewController {

  override func loadView() {
    view = NSView()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.red.cgColor
  }
}
