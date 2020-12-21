import Foundation
import Cocoa

final class CodeTextView: NSTextView {
  var highlightedLine: Int? {
    didSet {
      self.needsDisplay = true
    }
  }
  var emulationLine: Int? {
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
          !lineAnalysis.lineRanges.isEmpty else {
      return
    }

    if let highlightedLine = highlightedLine,
       let range = Range(lineAnalysis.lineRanges[highlightedLine], in: self.string) {
      let lineRange = self.string.lineRange(for: range)
      let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(lineRange, in: self.string), actualCharacterRange: nil)
      let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
      let lineRect = NSRect(x: 0, y: boundingRect.minY, width: bounds.width, height: boundingRect.height).offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
      NSColor.unemphasizedSelectedContentBackgroundColor.set()
      lineRect.fill()
    }

    if let emulationLine = emulationLine,
       emulationLine < lineAnalysis.lineRanges.count,
       let range = Range(lineAnalysis.lineRanges[emulationLine], in: self.string) {
      let lineRange = self.string.lineRange(for: range)
      let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(lineRange, in: self.string), actualCharacterRange: nil)
      let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
      let lineRect = NSRect(x: 0, y: boundingRect.minY, width: bounds.width, height: boundingRect.height).offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
      NSColor.selectedContentBackgroundColor.set()
      lineRect.frame()
    }
  }
}
