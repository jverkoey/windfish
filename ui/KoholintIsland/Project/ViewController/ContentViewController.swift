import AppKit
import Foundation
import Darwin
import Cocoa
import Combine

import Windfish

func DefaultCodeAttributes() -> [NSAttributedString.Key : Any] {
  return [
    .foregroundColor: NSColor.textColor,
    .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
  ]
}

final class ContentViewController: NSViewController {
  // TODO: Make this an enum of either filename or bank.
  var filename: String?
  var bank: Gameboy.Cartridge.Bank? { didSet { didSetBank() } }
  var textStorage = NSTextStorage() { didSet { didSetTextStorage(oldValue: oldValue) } }
  var lineAnalysis: LineAnalysis? {
    didSet {
      sourceRulerView?.lineAnalysis = lineAnalysis
      sourceView?.lineAnalysis = lineAnalysis
    }
  }

  // Views
  var containerView: NSScrollView?
  var sourceView: SourceView?
  var sourceRulerView: SourceRulerView?

  override func loadView() {
    view = NSView()

    let containerView = CreateScrollView(bounds: view.bounds)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(containerView)
    self.containerView = containerView

    let sourceView = SourceView(frame: view.bounds)
    sourceView.isEditable = false
    sourceView.allowsUndo = false
    sourceView.isSelectable = true
    sourceView.usesFindBar = true
    sourceView.isIncrementalSearchingEnabled = true
    containerView.documentView = sourceView
    self.sourceView = sourceView

    let sourceRulerView = SourceRulerView(scrollView: containerView, orientation: .verticalRuler)
    sourceRulerView.clientView = sourceView
    sourceRulerView.delegate = self
    containerView.hasVerticalRuler = true
    containerView.verticalRulerView = sourceRulerView
    containerView.rulersVisible = true
    self.sourceRulerView = sourceRulerView

    let safeAreaLayoutGuide = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      // Text content
      containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
    ])
  }

  override func viewWillAppear() {
    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: projectDocument)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        self.refreshBank()
        self.refreshFileContents()
        if let projectDocument = self.projectDocument, let cartridge = projectDocument.gameboy.cartridge {
          self.sourceView!.emulationLine = projectDocument.disassemblyResults?.lineFor(address: projectDocument.gameboy.cpu.pc, bank: cartridge.selectedBank)
        }
      })

    didProcessEditingSubscriber = NotificationCenter.default.publisher(for: NSTextStorage.didProcessEditingNotification)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard notification.object as? NSTextStorage === self.sourceView!.textStorage else {
          return
        }
        self.lineAnalysis = nil
        self.sourceRulerView!.needsDisplay = true
      })
  }

  // Subscribers
  private var disassembledSubscriber: AnyCancellable?
  private var didProcessEditingSubscriber: AnyCancellable?
}

extension ContentViewController {
  fileprivate func didSetBank() {
    refreshFileContents()
    refreshBank()
  }

  private func refreshBank() {
    if let bank = bank {
      let bankLines = projectDocument?.disassemblyResults?.bankLines?[bank]
      sourceRulerView?.bankLines = bankLines
    } else {
      sourceRulerView?.bankLines = nil
    }
    sourceRulerView?.needsDisplay = true

    if let lineNumbersRuler = sourceRulerView {
      containerView?.contentView.contentInsets.left = lineNumbersRuler.ruleThickness
    }
  }

  private func refreshFileContents() {
    if let bank = bank, let bankTextStorage = projectDocument?.disassemblyResults?.bankTextStorage,
       let bankString = bankTextStorage[bank] {
      textStorage = NSTextStorage(attributedString: bankString)
    } else if let filename = filename {
      let string = String(data: projectDocument!.disassemblyResults!.files[filename]!, encoding: .utf8)!

      let storage = NSTextStorage(string: string, attributes: DefaultCodeAttributes())
      textStorage = storage
    } else {
      textStorage = NSTextStorage()
    }
  }

  fileprivate func didSetTextStorage(oldValue: NSTextStorage) {
    if oldValue.string != textStorage.string {
      sourceView?.highlightedLine = nil
    }
    let originalOffset = containerView?.documentVisibleRect.origin
    sourceView?.layoutManager?.replaceTextStorage(textStorage)
    sourceView?.linkTextAttributes = [
      .foregroundColor: NSColor.linkColor,
      .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium),
      .underlineColor: NSColor.linkColor,
      .underlineStyle: NSUnderlineStyle.single.rawValue,
      .cursor: NSCursor.pointingHand,
    ]
    if let originalOffset = originalOffset {
      sourceView?.layoutManager?.ensureLayout(for: sourceView!.textContainer!)
      containerView?.documentView?.scroll(CGPoint(x: originalOffset.x, y: originalOffset.y))
    }
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
    guard let clientString = sourceView?.textStorage?.string else {
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

  func lineNumberViewWillDraw(_ lineNumberView: SourceRulerView) {
    if lineAnalysis == nil {
      updateLineInformation()
    }
  }

  func lineNumberView(_ lineNumberView: SourceRulerView, didActivate lineNumber: Int) {
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
