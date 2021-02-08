import AppKit
import Foundation
import Darwin
import Cocoa
import Combine

import LR35902
import Tracing
import Windfish

func DefaultCodeAttributes() -> [NSAttributedString.Key : Any] {
  return [
    .foregroundColor: NSColor.textColor,
    .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
  ]
}

final class SourceViewController: NSViewController {
  // TODO: Make this an enum of either filename or bank.
  let project: Project
  var filename: String?
  var bank: Cartridge.Bank? { didSet { didSetBank() } }
  var textStorage = NSTextStorage() { didSet { didSetTextStorage(oldValue: oldValue) } }
  var lineAnalysis: LineAnalysis? {
    didSet {
      sourceRulerView?.lineAnalysis = lineAnalysis
      sourceView?.lineAnalysis = lineAnalysis
    }
  }

  init(project: Project) {
    self.project = project

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // Views
  var sourceContainerView: NSScrollView?
  var sourceView: SourceView?
  var sourceRulerView: SourceRulerView?
  var toggleEmulationButton: NSButton?

  override func loadView() {
    view = NSView()

    let sourceContainerView = CreateScrollView(bounds: view.bounds)
    sourceContainerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(sourceContainerView)
    self.sourceContainerView = sourceContainerView

    let sourceView = SourceView(frame: view.bounds)
    sourceView.sourceViewDelegate = self
    sourceView.isEditable = false
    sourceView.allowsUndo = false
    sourceView.isSelectable = true
    sourceView.usesFindBar = true
    sourceView.isIncrementalSearchingEnabled = true
    sourceContainerView.documentView = sourceView
    self.sourceView = sourceView

    let sourceRulerView = SourceRulerView(scrollView: sourceContainerView, orientation: .verticalRuler)
    sourceRulerView.clientView = sourceView
    sourceRulerView.delegate = self
    sourceContainerView.hasVerticalRuler = true
    sourceContainerView.verticalRulerView = sourceRulerView
    sourceContainerView.rulersVisible = true
    self.sourceRulerView = sourceRulerView

    let toolbarHeight: CGFloat = 28  // Matches Xcode's debugger bar's height.

    let undoButton = NSButton(image: NSImage(systemSymbolNameOrImageName: "arrow.uturn.backward",
                                             accessibilityDescription: "Undo")!,
                              target: nil,
                              action: #selector(ProjectDocument.undoCommand(_:)))
    undoButton.toolTip = "Undo"

    let stepOverButton = NSButton(image: NSImage(systemSymbolNameOrImageName: "arrowshape.bounce.forward.fill",
                                                 accessibilityDescription: "Step over")!,
                                  target: nil,
                                  action: #selector(ProjectDocument.stepForward(_:)))
    stepOverButton.toolTip = "Step over"

    let stepIntoButton = NSButton(image: NSImage(systemSymbolNameOrImageName: "arrow.right.to.line.alt",
                                                 accessibilityDescription: "Step into")!,
                                  target: nil,
                                  action: #selector(ProjectDocument.stepInto(_:)))
    stepIntoButton.toolTip = "Step into"

    let toggleEmulationButton = NSButton(image: NSImage(systemSymbolNameOrImageName: "play",
                                                        accessibilityDescription: "Play")!,
                                  target: nil,
                                  action: #selector(ProjectDocument.toggleEmulation(_:)))
    toggleEmulationButton.alternateImage = NSImage(systemSymbolNameOrImageName: "pause",
                                                   accessibilityDescription: "Pause")!
    toggleEmulationButton.setButtonType(.toggle)
    toggleEmulationButton.state = .on
    toggleEmulationButton.toolTip = "Toggle emulation"
    self.toggleEmulationButton = toggleEmulationButton

    let restartButton = NSButton(image: NSImage(systemSymbolNameOrImageName: "arrow.clockwise",
                                                 accessibilityDescription: "Restart")!,
                                  target: nil,
                                  action: #selector(ProjectDocument.restartEmulation(_:)))
    restartButton.toolTip = "Restart"

    let buttons = [undoButton, stepOverButton, stepIntoButton, toggleEmulationButton, restartButton]
    for button in buttons {
      button.isBordered = false
      button.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        button.widthAnchor.constraint(equalToConstant: toolbarHeight)
      ])
    }

    let toolbarTopBorder = HorizontalLine()
    toolbarTopBorder.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toolbarTopBorder)

    let toolbar = NSStackView(views: buttons)
    toolbar.translatesAutoresizingMaskIntoConstraints = false
    toolbar.orientation = .horizontal
    toolbar.wantsLayer = true
    toolbar.edgeInsets = NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    view.addSubview(toolbar)

    let safeAreas: ViewOrLayoutGuide
    if #available(OSX 11.0, *) {
      safeAreas = view.safeAreaLayoutGuide
    } else {
      safeAreas = view
    }
    NSLayoutConstraint.activate([
      sourceContainerView.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      sourceContainerView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      sourceContainerView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),

      toolbarTopBorder.topAnchor.constraint(equalTo: sourceContainerView.bottomAnchor),
      toolbarTopBorder.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      toolbarTopBorder.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),

      toolbar.topAnchor.constraint(equalTo: toolbarTopBorder.bottomAnchor),
      toolbar.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      toolbar.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight),
      toolbar.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
    ])
  }

  override func viewWillAppear() {
    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: project)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        self.refreshBank()
        self.refreshFileContents()
        self.sourceView!.emulationLine = self.project.disassemblyResults?.lineFor(address: self.project.address, bank: self.project.bank)
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

    self.toggleEmulationButton?.state = project.sameboy.debugStopped ? .off : .on
    project.emulationObservers.add(self)
  }

  // Subscribers
  private var disassembledSubscriber: AnyCancellable?
  private var didProcessEditingSubscriber: AnyCancellable?
}

extension SourceViewController: EmulationObservers {
  func emulationDidAdvance() {
  }

  func emulationDidStart() {
    toggleEmulationButton?.state = .on
  }

  func emulationDidStop() {
    toggleEmulationButton?.state = .off
  }
}

extension SourceViewController {
  fileprivate func didSetBank() {
    refreshFileContents()
    refreshBank()
  }

  private func refreshBank() {
    if let bank = bank {
      let bankLines = project.disassemblyResults?.bankLines?[bank]
      sourceRulerView?.bankLines = bankLines
      sourceView?.bankLines = bankLines
    } else {
      sourceRulerView?.bankLines = nil
      sourceView?.bankLines = nil
    }
    sourceRulerView?.needsDisplay = true

    if let lineNumbersRuler = sourceRulerView {
      sourceContainerView?.contentView.contentInsets.left = lineNumbersRuler.ruleThickness
    }
  }

  private func refreshFileContents() {
    if let bank = bank, let bankTextStorage = project.disassemblyResults?.bankTextStorage,
       let bankString = bankTextStorage[bank] {
      textStorage = NSTextStorage(attributedString: bankString)
    } else if let filename = filename {
      let string = String(data: project.disassemblyResults!.files[filename]!, encoding: .utf8)!

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
    let originalOffset = sourceContainerView?.documentVisibleRect.origin
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
      sourceContainerView?.documentView?.scroll(CGPoint(x: originalOffset.x, y: originalOffset.y))
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

extension SourceViewController: LineNumberViewDelegate {
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

extension SourceViewController: SourceViewDelegate {
  func didRenameLabel(at line: Disassembler.Line, to name: String) {
    guard let lineAddress: LR35902.Address = line.address,
          let lineBank: Cartridge.Bank = line.bank else {
      return
    }
    let location: Cartridge.Location = Cartridge.Location(address: lineAddress, bank: lineBank)
    if let region = project.configuration.regions.first(where: { (region: Region) -> Bool in
      Cartridge.Location(address: region.address, bank: region.bank) == location
    }) {
      region.name = name
    } else {
      project.configuration.regions.append(Region(
        regionType: Region.Kind.label,
        name: name,
        bank: lineBank,
        address: lineAddress,
        length: 0
      ))
    }

    // TODO: Add a fake label to the source view with the renamed label name until disassembly concludes.

    NSApplication.shared.sendAction(#selector(ProjectDocument.disassemble(_:)), to: nil, from: self)
  }
}
