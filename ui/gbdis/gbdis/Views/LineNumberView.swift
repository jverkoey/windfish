//
//  LineNumberView.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/5/20.
//

import Foundation
import Cocoa
import LR35902
import Combine

protocol LineNumberViewDelegate: NSObject {
  func lineNumberView(_ lineNumberView: LineNumberView, didActivate lineNumber: Int)
  func lineNumberViewWillDraw(_ lineNumberView: LineNumberView)
}

private let scopeColumnWidth: CGFloat = 8
private let columnPadding: CGFloat = 4

final class LineNumberView: NSRulerView {
  var bankLines: [LR35902.Disassembly.Line]?
  weak var delegate: LineNumberViewDelegate?

  private let font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
  private let textColor = NSColor.systemGray
  private let backgroundColor = NSColor.textBackgroundColor
  private let scopeLineColor = NSColor.highlightColor
  private var didProcessEditingSubscriber: AnyCancellable?
  private var tappedLineNumber: Int?
  var lineAnalysis: LineAnalysis?

  override init(scrollView: NSScrollView?, orientation: NSRulerView.Orientation) {
    super.init(scrollView: scrollView, orientation: orientation)

    let digitSize = digitColumnWidth()
    let bankDigitSize = bankColumnWidth()
    let dataSize = dataColumnWidth()
    ruleThickness = max(dataSize + bankDigitSize + scopeColumnWidth + digitSize, 10)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var isFlipped: Bool {
    return true
  }

  private func currentTextStorage() -> NSTextStorage? {
    return (clientView as? NSTextView)?.textStorage
  }

  private func textAttributes() -> [NSAttributedString.Key: AnyObject] {
    return [
      .font: font,
      .foregroundColor: textColor
    ]
  }

  override func viewWillDraw() {
    super.viewWillDraw()

    delegate?.lineNumberViewWillDraw(self)
  }

  func digitColumnWidth() -> CGFloat {
    return ceil(NSString("0000").size(withAttributes: textAttributes()).width + columnPadding)
  }

  func bankColumnWidth() -> CGFloat {
    return ceil(NSString("00").size(withAttributes: textAttributes()).width + columnPadding)
  }

  func dataColumnWidth() -> CGFloat {
    return ceil(NSString("|........|").size(withAttributes: textAttributes()).width + columnPadding)
  }

  func processLines(in rect: NSRect,
                    dataHandler: ((LR35902.Disassembly.Line.Semantic, Data, NSRect) -> Void)? = nil,
                    scopeHandler: ((LR35902.Disassembly.Line?, LR35902.Disassembly.Line, LR35902.Disassembly.Line?, NSRect) -> Void)? = nil,
                    bankHandler: ((LR35902.Bank, NSRect) -> Void)? = nil,
                    handler: (Int, NSString, NSRect) -> Bool) {
    guard let textView = clientView as? NSTextView else {
      return
    }

    let textStorage = textView.textStorage
    guard let lineAnalysis = lineAnalysis,
          let storageString = textStorage?.string,
          let layoutManager = textView.layoutManager,
          let visibleRect = scrollView?.contentView.bounds,
          let textContainer = textView.textContainer,
          let bankLines = bankLines else {
      return
    }
    let textString = NSString(string: storageString)
    let textContainerInset = textView.textContainerInset
    let rightMostDrawableLocation = borderLineRect().minX

    let visibleGlyphGrange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
    let visibleCharacterRange = layoutManager.characterRange(forGlyphRange: visibleGlyphGrange, actualGlyphRange: nil)
    let textAttributes = self.textAttributes()

    let digitSize = digitColumnWidth()
    let bankDigitSize = bankColumnWidth()
    let dataSize = dataColumnWidth()

    var lastLinePositionY: CGFloat = -1.0
    var layoutRectCount: Int = 0
    withUnsafeMutablePointer(to: &layoutRectCount) { layoutRectCount in
      var characterIndex = visibleCharacterRange.location

      while characterIndex < (visibleCharacterRange.location + visibleCharacterRange.length) {
        let lineNumber = lineAnalysis.lineIndex(for: characterIndex)
        if lineNumber == NSNotFound {
          break
        }
        let characterRange = NSRange(location: characterIndex, length: 0)
        guard let layoutRects = layoutManager.rectArray(
          forCharacterRange: characterRange,
          withinSelectedCharacterRange: NSRange(location: NSNotFound, length: 0),
          in: textContainer,
          rectCount: layoutRectCount
        ), layoutRectCount.pointee > 0 else {
          break
        }

        let previousLine = lineNumber > 0 ? bankLines[lineNumber - 1] : nil
        let currentLine = bankLines[lineNumber]
        let nextLine = lineNumber < bankLines.count - 1 ? bankLines[lineNumber + 1] : nil

        let isLabel: Bool
        switch bankLines[lineNumber].semantic {
        case .label: fallthrough
        case .empty: fallthrough
        case .transferOfControl:
          isLabel = true
        default:
          isLabel = false
        }

        if let data = bankLines[lineNumber].data, let dataHandler = dataHandler {
          let dataRect = NSRect(
            x: rightMostDrawableLocation - digitSize - scopeColumnWidth - bankDigitSize - dataSize,
            y: layoutRects.pointee.minY + textContainerInset.height - visibleRect.minY,
            width: dataSize,
            height: layoutRects.pointee.height
          )
          dataHandler(bankLines[lineNumber].semantic, data, dataRect)
        }

        if !isLabel, let bank = bankLines[lineNumber].bank, let bankHandler = bankHandler {
          let bankRect = NSRect(
            x: rightMostDrawableLocation - digitSize - scopeColumnWidth - bankDigitSize + columnPadding,
            y: layoutRects.pointee.minY + textContainerInset.height - visibleRect.minY,
            width: bankDigitSize,
            height: layoutRects.pointee.height
          )
          bankHandler(bank, bankRect)
        }

        if let scopeHandler = scopeHandler {
          let scopeRect = NSRect(
            x: rightMostDrawableLocation - digitSize - scopeColumnWidth,
            y: layoutRects.pointee.minY + textContainerInset.height - visibleRect.minY,
            width: scopeColumnWidth,
            height: layoutRects.pointee.height
          )
          scopeHandler(previousLine, currentLine, nextLine, scopeRect)
        }

        // TODO: Also show the current bank and current execution context
        // TODO: Cmd+clicking labels should jump to the label
        if !isLabel, let address = bankLines[lineNumber].address {
          let lineString = NSString(string: address.hexString)
          let lineStringSize = lineString.size(withAttributes: textAttributes)
          let lineStringRect = NSRect(
            x: rightMostDrawableLocation - digitSize,
            y: layoutRects.pointee.minY + textContainerInset.height - visibleRect.minY + (layoutRects.pointee.height - lineStringSize.height) / 2.0,
            width: lineStringSize.width,
            height: lineStringSize.height
          )

          if lineStringRect.minY != lastLinePositionY {
            if !handler(lineNumber, lineString, lineStringRect) {
              break
            }
          }

          lastLinePositionY = lineStringRect.minY
        }

        withUnsafeMutablePointer(to: &characterIndex) { pointer in
          textString.getLineStart(nil, end: pointer, contentsEnd: nil, for: characterRange)
        }
      }
    }
  }

  private func borderLineRect() -> NSRect {
    return NSRect(x: bounds.maxX - 1, y: 0, width: 1, height: bounds.height)
  }

  override func drawHashMarksAndLabels(in rect: NSRect) {
    guard self.orientation == .verticalRuler else {
      preconditionFailure()
    }

    backgroundColor.set()
    rect.fill()

    let borderLineRect = self.borderLineRect()
    if needsToDraw(borderLineRect) {
      backgroundColor.shadow(withLevel: 0.1)?.set()
      borderLineRect.fill()
    }

    let textAttributes = self.textAttributes()

    processLines(in: rect, dataHandler: { semantic, data, dataRect in
      if self.needsToDraw(dataRect.insetBy(dx: -4, dy: -4)) {
        let textRect = dataRect.offsetBy(dx: 2, dy: 0)
        switch semantic {
        case .unknown: fallthrough
        case .data:
          let displayableBytes = data.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
          let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
          let dataString = "|\(bytesAsCharacters)|"
          dataString.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: textAttributes)
        case .instruction:
          let dataString = data.map { "$\($0.hexString)" }.joined(separator: " ")
          dataString.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: textAttributes)
        default:
          break
        }
      }
    }, scopeHandler: { (previousLine, currentLine, nextLine, scopeRect) in
      let previousScope = previousLine?.scope
      let currentScope = currentLine.scope
      let nextScope = nextLine?.scope

      self.scopeLineColor.set()
      if let currentScope = currentScope {
        if previousScope == currentScope && currentScope == nextScope {
          // Continuation of scope.
          NSRect(
            x: scopeRect.midX,
            y: scopeRect.minY,
            width: 1,
            height: scopeRect.height
          ).fill()
        } else if previousScope != currentScope && currentScope == nextScope {
          // Starting a new scope.

          if previousScope != nil {
            // Close the previous scope.
            NSRect(
              x: scopeRect.minX + 1,
              y: scopeRect.minY,
              width: scopeRect.width - 2,
              height: 1
            ).fill()
          }

          // Start the next scope.
          NSRect(
            x: scopeRect.midX - 1,
            y: scopeRect.midY - 1,
            width: 3,
            height: 3
          ).fill()
          NSRect(
            x: scopeRect.midX,
            y: scopeRect.midY,
            width: 1,
            height: scopeRect.height / 2
          ).fill()
        } else if previousScope == currentScope && currentScope != nextScope {
          // Ending the current scope.

          NSRect(
            x: scopeRect.midX,
            y: scopeRect.minY,
            width: 1,
            height: scopeRect.height
          ).fill()
          // Finish the current scope.
          NSRect(
            x: scopeRect.minX + 1,
            y: scopeRect.maxY - 1,
            width: scopeRect.width - 2,
            height: 1
          ).fill()
        }
      }
    }, bankHandler: { (bank, bankRect) in
      let bankString = NSString(string: bank.hexString)
      if self.needsToDraw(bankRect.insetBy(dx: -4, dy: -4)) {
        bankString.draw(with: bankRect, options: .usesLineFragmentOrigin, attributes: textAttributes)
      }
    }, handler: { _, lineString, lineStringRect in
      if needsToDraw(lineStringRect.insetBy(dx: -4, dy: -4)) {
        lineString.draw(with: lineStringRect, options: .usesLineFragmentOrigin, attributes: textAttributes)
      }
      return true
    })
  }
}

// MARK: - User interaction

extension LineNumberView {
  private func lineNumber(at location: NSPoint) -> Int? {
    var tappedLineNumber: Int? = nil
    processLines(in: bounds, handler: { lineNumber, lineString, lineStringRect in
      if lineStringRect.contains(location) {
        tappedLineNumber = lineNumber
        return false
      }
      return true
    })
    return tappedLineNumber
  }

// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/MouseTrackingEvents/MouseTrackingEvents.html
//  override func mouseMoved(with event: NSEvent) {
//    super.mouseDown(with: event)
//
//    let location = self.convert(event.locationInWindow, from: nil)
//    if lineNumber(at: location) != nil {
//      NSCursor.pointingHand.set()
//    } else {
//      NSCursor.arrow.set()
//    }
//  }

  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)

    let location = self.convert(event.locationInWindow, from: nil)
    self.tappedLineNumber = lineNumber(at: location)
  }

  override func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)

    guard let tappedLineNumber = tappedLineNumber else {
      return
    }
    let location = self.convert(event.locationInWindow, from: nil)
    if lineNumber(at: location) == tappedLineNumber {
      delegate?.lineNumberView(self, didActivate: tappedLineNumber)
    }
  }
}
