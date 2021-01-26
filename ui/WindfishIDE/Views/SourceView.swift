import AppKit
import Foundation
import Cocoa

import Windfish

protocol SourceViewDelegate: class {
  func didRenameLabel(at line: Disassembler.Line, to name: String)
}

final class SourceView: NSTextView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    self.isVerticallyResizable = true
    self.autoresizingMask = [.width]
    self.textContainer?.containerSize = NSSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude)
    self.textContainer?.widthTracksTextView = true
    self.focusRingType = .none
    self.drawsBackground = false
  }

  override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
    super.init(frame: frameRect, textContainer: container)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

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
  var bankLines: [Disassembler.Line]?
  var lineAnalysis: LineAnalysis?
  var editingLine: Disassembler.Line?
  weak var sourceViewDelegate: SourceViewDelegate?

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

  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)

    if event.clickCount == 2 {
      guard let lineAnalysis: LineAnalysis = lineAnalysis,
            let bankLines: [Disassembler.Line] = bankLines else {
        return
      }
      let selectedRange: NSRange = self.selectedRange()
      let lineIndex: Int = lineAnalysis.lineIndex(for: selectedRange.location)
      guard lineIndex != NSNotFound,
            lineIndex < bankLines.count,
            let lineRange: Range = Range(lineAnalysis.lineRanges[lineIndex], in: self.string)
            else {
        return
      }
      let line: Disassembler.Line = bankLines[lineIndex]
      switch line.semantic {
      case .transferOfControl(_, let labelName): fallthrough
      case .label(let labelName):
        guard let layoutManager: NSLayoutManager = layoutManager,
              let textContainer: NSTextContainer = textContainer  else {
          return
        }
        let glyphRange: NSRange = layoutManager.glyphRange(forCharacterRange: NSRange(lineRange, in: self.string), actualCharacterRange: nil)
        let boundingRect: NSRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        let lineRect: NSRect = NSRect(
          x: 0,
          y: boundingRect.minY,
          width: bounds.width,
          height: boundingRect.height
        ).offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
        .insetBy(dx: 3, dy: 0)  // Align the text field text with the source text.
        let textField = NSTextField(frame: lineRect)
        textField.isBezeled = false
        textField.stringValue = labelName
        textField.font = self.font
        textField.delegate = self
        addSubview(textField)

        editingLine = line
        textField.becomeFirstResponder()

      default:
        break  // Do nothing.
      }
    }
  }
}

extension SourceView: NSTextFieldDelegate {
  func controlTextDidEndEditing(_ obj: Notification) {
    guard let textField: NSTextField = obj.object as? NSTextField,
          let editingLine: Disassembler.Line = editingLine else {
      return
    }

    switch editingLine.semantic {
    case .transferOfControl(_, let labelName): fallthrough
    case .label(let labelName):
      guard labelName != textField.stringValue else {
        break
      }
      sourceViewDelegate?.didRenameLabel(at: editingLine, to: textField.stringValue)

    default:
      break
    }
    textField.removeFromSuperview()
  }
}
