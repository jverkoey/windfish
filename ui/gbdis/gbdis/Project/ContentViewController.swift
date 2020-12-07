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

  var filename: String? {
    didSet {
      refreshFileContents()
    }
  }

  var bank: LR35902.Bank? {
    didSet {
      refreshBank()
    }
  }
  private func refreshBank() {
    if let bank = bank {
      let bankLines = document.bankLines?[bank]
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
    if let filename = filename {
      let string = String(data: document.disassemblyFiles![filename]!, encoding: .utf8)!
      textStorage = NSTextStorage(string: string)
    } else {
      textStorage = NSTextStorage()
    }
  }

  var textStorage = NSTextStorage() {
    didSet {
      textStorage.delegate = self
      textView?.layoutManager?.replaceTextStorage(textStorage)
      textStorage.delegate?.textStorage?(
        textStorage,
        didProcessEditing: .editedCharacters,
        range: NSRange(location: 0, length: textStorage.string.count),
        changeInLength: 0
      )
    }
  }

  let document: ProjectDocument
  private var disassembledSubscriber: AnyCancellable?

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
    textView.isEditable = true
    textView.allowsUndo = true
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
  }
}

extension ContentViewController: NSTextStorageDelegate {
  func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
    guard editedMask == [.editedCharacters] else {
      return
    }
    textStorage.beginEditing()
    textStorage.addAttributes([
      .foregroundColor: NSColor.textColor,
      .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    ], range: editedRange)

    guard let regex = try? NSRegularExpression(pattern: ";.+$", options: [.anchorsMatchLines]) else {
      return
    }
    regex.enumerateMatches(in: textStorage.string, options: [], range: editedRange) { result, flags, out in
      guard let result = result else {
        return
      }
      textStorage.addAttributes([.foregroundColor: NSColor.systemGray], range: result.range)
    }

    try? NSRegularExpression(pattern: "^[^;\\n]+:", options: [.anchorsMatchLines])
      .enumerateMatches(in: textStorage.string, options: [], range: editedRange) { result, flags, out in
        guard let result = result else {
          return
        }
        textStorage.addAttributes([.foregroundColor: NSColor.systemOrange], range: result.range)
      }

    try? NSRegularExpression(pattern: "^    \\w+ ", options: [.anchorsMatchLines])
      .enumerateMatches(in: textStorage.string, options: [], range: editedRange) { result, flags, out in
        guard let result = result else {
          return
        }
        textStorage.addAttributes([.foregroundColor: NSColor.systemGreen], range: result.range)
      }
    textStorage.endEditing()
  }
}

extension ContentViewController: LineNumberViewDelegate {
  func lineNumberView(_ lineNumberView: LineNumberView, didActivate lineNumber: Int) {
    guard let bankLines = lineNumbersRuler?.bankLines else {
      return
    }
    guard let address = bankLines[lineNumber].address else {
      return
    }
    let iterator = bankLines.makeIterator().dropFirst(lineNumber + 1)

    let range: HFRange
    if let nextLineAddress = iterator.first(where: { $0.address != nil })?.address {
      range = HFRange(location: UInt64(address), length: UInt64(nextLineAddress - address))
    } else {
      range = HFRange(location: UInt64(address), length: 1)
    }
    print(range)
  }
}

// To get the width of the scroller region.
// -NSScroller.scrollerWidth(for: .regular, scrollerStyle: .overlay)
