//
//  TextView.swiftui
//
//  Created by Jeff Verkoeyen on 12/5/20.
//

import AppKit
import Foundation
import Cocoa

final class TextView: NSTextView {
  var selectedLineRect: NSRect? {
    guard let layout = layoutManager,
          let container = textContainer,
          let text = textStorage else { return nil }

    if selectedRange().length > 0 { return nil }

    let lineRange = text.string.lineRange(for: Range(selectedRange(), in: text.string)!)
    return layout.boundingRect(forGlyphRange: NSRange(lineRange, in: text.string), in: container)
  }

  override public func draw(_ dirtyRect: NSRect) {
    guard let context = NSGraphicsContext.current?.cgContext else { return }

    context.setFillColor(backgroundColor.cgColor)
    context.fill(dirtyRect)

    if let textRect = selectedLineRect {
      let lineRect = NSRect(x: 0, y: textRect.origin.y, width: dirtyRect.width, height: textRect.height)
      context.setFillColor(NSColor.systemRed.cgColor)
      context.fill(lineRect)
    }

    super.draw(dirtyRect)
  }

  override public func setSelectedRange(_ charRange: NSRange, affinity: NSSelectionAffinity, stillSelecting stillSelectingFlag: Bool) {
    super.setSelectedRange(charRange, affinity: affinity, stillSelecting: stillSelectingFlag)
    needsDisplay = true
  }
}

extension UnicodeScalar {
  var isWhitespace: Bool {
    return NSCharacterSet.whitespaces.contains(self) || NSCharacterSet.newlines.contains(self)
  }

  var isNewline: Bool {
    return NSCharacterSet.newlines.contains(self)
  }
}
