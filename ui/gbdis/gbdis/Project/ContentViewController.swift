//
//  ContentViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation
import Darwin
import Cocoa
import Combine
import LR35902

final class ContentViewController: NSViewController {
  var containerView: NSScrollView?
  var textView: NSTextView?
  var lineNumbersRuler: LineNumberView?

  var textStorage = NSTextStorage() {
    didSet {
      textStorage.delegate = self
      textView?.layoutManager?.replaceTextStorage(textStorage)
      textView?.textColor = .textColor
      textView?.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
    }
  }

  let document: ProjectDocument
  let hexViewController: HexViewController
  var bankConstraints: [NSLayoutConstraint] = []
  var fileConstraints: [NSLayoutConstraint] = []

  init(document: ProjectDocument) {
    self.document = document
    self.hexViewController = HexViewController()

    super.init(nibName: nil, bundle: nil)

    self.addChild(self.hexViewController)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()

    self.hexViewController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(self.hexViewController.view)

    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor

    let containerView = NSScrollView()
    self.containerView = containerView
    containerView.frame = view.bounds
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true
    containerView.borderType = .noBorder
    containerView.hasVerticalRuler = true
    view.addSubview(containerView)

    let textView = NSTextView()
    self.textView = textView
    textView.isVerticallyResizable = true
    textView.autoresizingMask = [.width]
    textView.textContainer?.containerSize = NSSize(width: containerView.contentSize.width,
                                                   height: CGFloat.greatestFiniteMagnitude)
    textView.textContainer?.widthTracksTextView = true
    textView.focusRingType = .none
    textView.isEditable = false
    textView.isSelectable = true
    textView.drawsBackground = false
    textView.usesFindBar = true
    textView.isIncrementalSearchingEnabled = true
    containerView.documentView = textView

    let lineNumbersRuler = LineNumberView(scrollView: containerView, orientation: .verticalRuler)
    lineNumbersRuler.clientView = textView
    containerView.verticalRulerView = lineNumbersRuler
    containerView.rulersVisible = true
    self.lineNumbersRuler = lineNumbersRuler

    let safeAreaLayoutGuide = view.safeAreaLayoutGuide

    bankConstraints = [containerView.trailingAnchor.constraint(equalTo: self.hexViewController.view.leadingAnchor)]
    fileConstraints = [containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)]

    NSLayoutConstraint.activate([
      // Text content
      containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),

      // Hex viewer
      self.hexViewController.view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      self.hexViewController.view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      self.hexViewController.view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      self.hexViewController.view.widthAnchor.constraint(equalToConstant: self.hexViewController.minimumWidth),
    ])

    showBank(bank: nil)
  }

  func showBank(bank: LR35902.Bank?) {
    guard let slice = document.slice else {
      return
    }

    if let bank = bank {
      let range = LR35902.rangeOf(bank: bank)
      let byteArray = HFBTreeByteArray()
      byteArray.insertByteSlice(slice.subslice(with: HFRange(location: UInt64(range.location), length: UInt64(range.length))),
                                in: HFRange(location: 0, length: 0))
      hexViewController.hexController.byteArray = byteArray
      hexViewController.view.isHidden = false
      NSLayoutConstraint.deactivate(fileConstraints)
      NSLayoutConstraint.activate(bankConstraints)
      lineNumbersRuler?.bankLines = document.bankLines?[bank]
    } else {
      hexViewController.hexController.byteArray = HFBTreeByteArray()
      hexViewController.view.isHidden = true
      NSLayoutConstraint.deactivate(bankConstraints)
      NSLayoutConstraint.activate(fileConstraints)
      lineNumbersRuler?.bankLines = nil
    }
  }
}

extension ContentViewController: NSTextStorageDelegate {
  func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
    textStorage.removeAttribute(.foregroundColor, range: editedRange)
    textStorage.addAttributes([.foregroundColor: NSColor.textColor], range: editedRange)

    guard let regex = try? NSRegularExpression(pattern: ";.+$", options: [.anchorsMatchLines]) else {
      return
    }
    regex.enumerateMatches(in: textStorage.string, options: [], range: editedRange) { result, flags, out in
      guard let result = result else {
        return
      }
      textStorage.addAttributes([.foregroundColor: NSColor.systemGray], range: result.range)
    }
  }
}

class LineNumberView: NSRulerView {
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
