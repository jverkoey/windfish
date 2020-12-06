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

final class LineNumberView: NSRulerView {
  var bankLines: [LR35902.Disassembly.Line]?

  private let font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
  private let textColor = NSColor.systemGray
  private let backgroundColor = NSColor.textBackgroundColor
  private var lineInformationValid = false
  private var numberOfLines: Int?
  private var lineStartCharacterIndices: UnsafeMutablePointer<Int>?
  private var didProcessEditingSubscriber: AnyCancellable?

  deinit {
    lineStartCharacterIndices?.deallocate()
  }

  override var isFlipped: Bool {
    return true
  }

  override var clientView: NSView? {
    didSet {
      guard let textView = clientView as? NSTextView else {
        return
      }
      didProcessEditingSubscriber = NotificationCenter.default.publisher(
        for: NSTextStorage.didProcessEditingNotification
      )
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] notification in
        guard let self = self else {
          return
        }
        guard notification.object as? NSTextStorage === textView.textStorage else {
          return
        }
        self.lineInformationValid = false
        self.needsDisplay = true
      })
    }
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

  private func updateLineInformation() {
    let lineStartCharacterIndices = NSMutableIndexSet()
    guard let clientString = currentTextStorage()?.string else {
      return
    }
    let nsString = NSString(string: clientString)
    let range = NSRange(location: 0, length: nsString.length)
    nsString.enumerateSubstrings(in: range, options: [String.EnumerationOptions.byLines, .substringNotRequired]) { (_, substringRange, _, _) in
      lineStartCharacterIndices.add(substringRange.location)
    }

    self.lineStartCharacterIndices?.deallocate()

    let numberOfLines = lineStartCharacterIndices.count
    let buffer = UnsafeMutablePointer<Int>.allocate(capacity: numberOfLines)
    lineStartCharacterIndices.getIndexes(buffer, maxCount: numberOfLines, inIndexRange: nil)
    self.numberOfLines = numberOfLines
    self.lineStartCharacterIndices = buffer

    lineInformationValid = true

    let digitSize = NSString("0000").size(withAttributes: textAttributes())
    ruleThickness = max(ceil(digitSize.width + 8), 10)
  }

  override func viewWillDraw() {
    super.viewWillDraw()

    if !lineInformationValid {
      updateLineInformation()
    }
  }

  func lineIndex(for characterIndex: Int) -> Int {
    guard let lineStartCharacterIndices = lineStartCharacterIndices,
          let numberOfLines = numberOfLines else {
      return NSNotFound
    }

    let foundIndex = withUnsafePointer(to: characterIndex) { pointer in
      bsearch_b(pointer, lineStartCharacterIndices, numberOfLines, MemoryLayout<Int>.size) { pointer1, pointer2 in
        guard let pointer1 = pointer1, let pointer2 = pointer2 else {
          return 0
        }
        let value1 = pointer1.bindMemory(to: Int.self, capacity: 1).pointee
        let value2 = pointer2.bindMemory(to: Int.self, capacity: 1).pointee
        if value1 < value2 {
          return -1
        } else if value1 > value2 {
          return 1;
        }
        return 0
      }
    }
    if let foundIndex = foundIndex {
      return -foundIndex.distance(to: lineStartCharacterIndices) / MemoryLayout<Int>.size
    }
    return NSNotFound
  }

  override func drawHashMarksAndLabels(in rect: NSRect) {
    guard self.orientation == .verticalRuler else {
      preconditionFailure()
    }

    backgroundColor.set()
    rect.fill()

    let borderLineRect = NSRect(x: bounds.maxX - 1, y: 0, width: 1, height: bounds.height)
    if needsToDraw(borderLineRect) {
      backgroundColor.shadow(withLevel: 0.4)?.set()
      borderLineRect.fill()
    }

    guard let textView = clientView as? NSTextView else {
      return
    }

    let textStorage = textView.textStorage
    guard let storageString = textStorage?.string,
          let layoutManager = textView.layoutManager,
          let visibleRect = scrollView?.contentView.bounds,
          let textContainer = textView.textContainer,
          let bankLines = bankLines else {
      return
    }
    let textString = NSString(string: storageString)
    let textContainerInset = textView.textContainerInset
    let rightMostDrawableLocation = borderLineRect.minX

    let visibleGlyphGrange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
    let visibleCharacterRange = layoutManager.characterRange(forGlyphRange: visibleGlyphGrange, actualGlyphRange: nil)
    let textAttributes = self.textAttributes()

    var lastLinePositionY: CGFloat = -1.0
    var layoutRectCount: Int = 0
    withUnsafeMutablePointer(to: &layoutRectCount) { layoutRectCount in
      var characterIndex = visibleCharacterRange.location
      while characterIndex < (visibleCharacterRange.location + visibleCharacterRange.length) {
        let lineNumber = lineIndex(for: characterIndex)
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

        if let address = bankLines[lineNumber].address {
          let lineString = NSString(string: address.hexString)
          let lineStringSize = lineString.size(withAttributes: textAttributes)
          let lineStringRect = NSRect(
            x: rightMostDrawableLocation - lineStringSize.width,
            y: layoutRects.pointee.minY + textContainerInset.height - visibleRect.minY + (layoutRects.pointee.height - lineStringSize.height) / 2.0,
            width: lineStringSize.width,
            height: lineStringSize.height
          )

          if needsToDraw(lineStringRect.insetBy(dx: -4, dy: -4)) && lineStringRect.minY != lastLinePositionY {
            lineString.draw(with: lineStringRect, options: .usesLineFragmentOrigin, attributes: textAttributes)
          }

          lastLinePositionY = lineStringRect.minY
        }

        withUnsafeMutablePointer(to: &characterIndex) { pointer in
          textString.getLineStart(nil, end: pointer, contentsEnd: nil, for: characterRange)
        }
      }
    }
  }
}
