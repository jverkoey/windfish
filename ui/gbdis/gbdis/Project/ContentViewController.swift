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
      textStorage.delegate?.textStorage?(
        textStorage,
        didProcessEditing: .editedCharacters,
        range: NSRange(location: 0, length: textStorage.string.count),
        changeInLength: 0
      )
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
    lineNumbersRuler.delegate = self
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
    guard editedMask == [.editedCharacters] else {
      return
    }
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

    try? NSRegularExpression(pattern: "^[^;]+:", options: [.anchorsMatchLines])
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
    hexViewController.hexController.centerContentsRange(range)
    hexViewController.hexController.selectedContentsRanges = [HFRangeWrapper.withRange(range)]
    hexViewController.hexController.pulseSelection()
  }
}
