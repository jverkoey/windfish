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

  var filename: String?

  var bank: LR35902.Bank? {
    didSet {
      refreshFileContents()
      refreshBank()
    }
  }
  private func refreshBank() {
    if let bank = bank {
      let bankLines = document.disassemblyResults?.bankLines?[bank]
      lineNumbersRuler?.bankLines = bankLines
    } else {
      lineNumbersRuler?.bankLines = nil
    }
    lineNumbersRuler?.needsDisplay = true

    if let lineNumbersRuler = lineNumbersRuler {
      containerView?.contentView.contentInsets.left = lineNumbersRuler.ruleThickness
    }
  }

  private func refreshFileContents() {
    if let bank = bank, let bankTextStorage = document.disassemblyResults?.bankTextStorage,
       let bankString = bankTextStorage[bank] {
      textStorage = NSTextStorage(attributedString: bankString)
    } else if let filename = filename {
      let string = String(data: document.disassemblyResults!.files[filename]!, encoding: .utf8)!

      let storage = NSTextStorage(string: string, attributes: [
        .foregroundColor: NSColor.textColor,
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
      ])
      textStorage = storage
    } else {
      textStorage = NSTextStorage()
    }
  }

  var textStorage = NSTextStorage() {
    didSet {
      let originalOffset = containerView?.documentVisibleRect.origin
      textView?.layoutManager?.replaceTextStorage(textStorage)
      textView?.linkTextAttributes = [
        .foregroundColor: NSColor.linkColor,
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium),
        .underlineColor: NSColor.linkColor,
        .underlineStyle: NSUnderlineStyle.single.rawValue,
        .cursor: NSCursor.pointingHand,
      ]
      if let originalOffset = originalOffset {
        textView?.layoutManager?.ensureLayout(for: textView!.textContainer!)
        containerView?.documentView?.scroll(CGPoint(x: originalOffset.x, y: originalOffset.y))
      }
    }
  }

  let document: ProjectDocument
  private var disassembledSubscriber: AnyCancellable?

  private var didProcessEditingSubscriber: AnyCancellable?
  var lineAnalysis: LineAnalysis? {
    didSet {
      lineNumbersRuler?.lineAnalysis = lineAnalysis

      // TODO: This needs to happen between analysis and setting of the storage.
      // 1. Set new storage.
      // 2. Analyze and mutate the storage if needed.
      // 3. Set the storage.
//      if let lineAnalysis = lineAnalysis, lineAnalysis.lineRanges.count > 0 {
//        refreshFileContents()
//
//        let range = lineAnalysis.lineRanges[20]
//        let imageAttachment = NSTextAttachment()
//        imageAttachment.image = NSImage(systemSymbolName: "pencil.circle", accessibilityDescription: nil)
//        textStorage.insert(NSAttributedString(attachment: imageAttachment), at: range.lowerBound)
//      }
    }
  }

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()

    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor

    let containerView = NSScrollView()
    self.containerView = containerView
    containerView.frame = view.bounds
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true
    containerView.borderType = .noBorder
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
    textView.allowsUndo = false
    textView.isSelectable = true
    textView.drawsBackground = false
    textView.usesFindBar = true
    textView.isIncrementalSearchingEnabled = true
    containerView.documentView = textView

    let lineNumbersRuler = LineNumberView(scrollView: containerView, orientation: .verticalRuler)
    lineNumbersRuler.clientView = textView
    lineNumbersRuler.delegate = self
    containerView.hasVerticalRuler = true
    containerView.verticalRulerView = lineNumbersRuler
    containerView.rulersVisible = true
    self.lineNumbersRuler = lineNumbersRuler

    let safeAreaLayoutGuide = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      // Text content
      containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
    ])

    self.bank = nil

    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        self.refreshBank()
        self.refreshFileContents()
      })

    didProcessEditingSubscriber = NotificationCenter.default.publisher(for: NSTextStorage.didProcessEditingNotification)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard notification.object as? NSTextStorage === textView.textStorage else {
          return
        }
        self.lineAnalysis = nil
        lineNumbersRuler.needsDisplay = true
      })
  }
}

final class LineAnalysis {
  internal init(lineStartCharacterIndices: UnsafeMutablePointer<Int>, lineRanges: [NSRange], numberOfLines: Int) {
    self.lineStartCharacterIndices = lineStartCharacterIndices
    self.lineRanges = lineRanges
    self.numberOfLines = numberOfLines
  }

  var lineStartCharacterIndices: UnsafeMutablePointer<Int>
  var lineRanges: [NSRange]
  var numberOfLines: Int

  deinit {
    lineStartCharacterIndices.deallocate()
  }

  func lineIndex(for characterIndex: Int) -> Int {
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

}

extension ContentViewController: LineNumberViewDelegate {
  private func updateLineInformation() {
    let lineStartCharacterIndices = NSMutableIndexSet()
    guard let clientString = textView?.textStorage?.string else {
      return
    }
    let nsString = NSString(string: clientString)
    let range = NSRange(location: 0, length: nsString.length)
    var lineRanges: [NSRange] = []
    nsString.enumerateSubstrings(in: range, options: [String.EnumerationOptions.byLines, .substringNotRequired]) { (_, substringRange, _, _) in
      lineStartCharacterIndices.add(substringRange.location)
      lineRanges.append(substringRange)
    }

    let numberOfLines = lineStartCharacterIndices.count
    let buffer = UnsafeMutablePointer<Int>.allocate(capacity: numberOfLines)
    lineStartCharacterIndices.getIndexes(buffer, maxCount: numberOfLines, inIndexRange: nil)
    self.lineAnalysis = LineAnalysis(lineStartCharacterIndices: buffer, lineRanges: lineRanges, numberOfLines: numberOfLines)
  }

  func lineNumberViewWillDraw(_ lineNumberView: LineNumberView) {
    if lineAnalysis == nil {
      updateLineInformation()
    }
  }

  func lineNumberView(_ lineNumberView: LineNumberView, didActivate lineNumber: Int) {
//    guard let bankLines = lineNumbersRuler?.bankLines else {
//      return
//    }
//    guard let address = bankLines[lineNumber].address else {
//      return
//    }
//    let iterator = bankLines.makeIterator().dropFirst(lineNumber + 1)
//
//    let range: HFRange
//    if let nextLineAddress = iterator.first(where: { $0.address != nil })?.address {
//      range = HFRange(location: UInt64(address), length: UInt64(nextLineAddress - address))
//    } else {
//      range = HFRange(location: UInt64(address), length: 1)
//    }
//    print(range)
  }
}
