import Foundation
import Cocoa

final class CodeTextView: NSTextView {
  var highlightedLine: Int? {
    didSet {
      self.needsDisplay = true
    }
  }
  var lineAnalysis: LineAnalysis?

  override func drawBackground(in rect: NSRect) {
    super.drawBackground(in: rect)

    guard let lineAnalysis = lineAnalysis,
          let layoutManager = layoutManager,
          let textContainer = textContainer,
          !lineAnalysis.lineRanges.isEmpty,
          let highlightedLine = highlightedLine,
          let range = Range(lineAnalysis.lineRanges[highlightedLine], in: self.string) else {
      return
    }

    let lineRange = self.string.lineRange(for: range)
    let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(lineRange, in: self.string), actualCharacterRange: nil)
    let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    let lineRect = NSRect(x: 0, y: boundingRect.minY, width: bounds.width, height: boundingRect.height).offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
    NSColor.unemphasizedSelectedContentBackgroundColor.set()
    lineRect.fill()
  }
}
