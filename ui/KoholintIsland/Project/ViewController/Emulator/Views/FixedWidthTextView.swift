import AppKit
import Foundation

import Cocoa

final class FixedWidthTextView: NSTextField {
  override func invalidateIntrinsicContentSize() {
    // Every time objectValue is set, NSControl invokes invalidateIntrinsicContentSize which is a fairly expensive
    // operation. We know our register fields will never change their intrinsic content size, so we short-circuit this
    // logic to improve rendering performance during emulation (13k instructions/s -> 16k instructions/s).
  }
}
