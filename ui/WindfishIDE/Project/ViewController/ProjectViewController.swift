//
//  ViewController.swift
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import AppKit
import Cocoa
import Combine

import Windfish

extension NSViewController {
  var projectDocument: ProjectDocument? {
    return self.view.window?.windowController?.document as? ProjectDocument
  }
}

final class ProjectViewController: NSViewController {

  let document: ProjectDocument
  let containerView = NSView()
  let horizontalLine = HorizontalLine()
  let progressIndicator = NSProgressIndicator()
  let statisticsView = StatisticsView()
  let threePaneSplitViewController: NSSplitViewController
  let leadingSplitViewController: NSSplitViewController
  let centerSplitViewController: NSSplitViewController

  let sidebarViewController: OutlineViewController
  let callstackViewController = CallStackViewController()
  let sourceViewController: SourceViewController
  let debuggingViewController: DebuggingViewController
  let inspectorViewController: InspectorViewController

  private var selectedFileDidChangeSubscriber: AnyCancellable?
  private var selectedRegionDidChangeSubscriber: AnyCancellable?
  private var didCreateRegionSubscriber: AnyCancellable?
  private var disassembledSubscriber: AnyCancellable?

  init(document: ProjectDocument) {
    self.document = document

    self.threePaneSplitViewController = NSSplitViewController()
    self.leadingSplitViewController = NSSplitViewController()
    self.centerSplitViewController = NSSplitViewController()
    self.sidebarViewController = OutlineViewController()
    self.sourceViewController = SourceViewController()
    self.debuggingViewController = DebuggingViewController()
    self.inspectorViewController = InspectorViewController(document: document)

    // Leading
    leadingSplitViewController.addSplitViewItem(NSSplitViewItem(viewController: sidebarViewController))
    let callStackItem = NSSplitViewItem(viewController: callstackViewController)
    callStackItem.canCollapse = false
    callStackItem.minimumThickness = 200 // TODO: This doesn't appear to actually be getting enforced.
    leadingSplitViewController.addSplitViewItem(callStackItem)

    // Center
    centerSplitViewController.addSplitViewItem(NSSplitViewItem(viewController: sourceViewController))
    let debuggingItem = NSSplitViewItem(viewController: debuggingViewController)
    debuggingItem.canCollapse = false
    debuggingItem.minimumThickness = 200 // TODO: This doesn't appear to actually be getting enforced.
    centerSplitViewController.addSplitViewItem(debuggingItem)

    // Three-pane
    let leadingSidebarItem = NSSplitViewItem(sidebarWithViewController: leadingSplitViewController)
    leadingSidebarItem.canCollapse = false
    threePaneSplitViewController.addSplitViewItem(leadingSidebarItem)
    threePaneSplitViewController.addSplitViewItem(NSSplitViewItem(viewController: centerSplitViewController))
    let trailingSidebarItem = NSSplitViewItem(sidebarWithViewController: inspectorViewController)
    trailingSidebarItem.canCollapse = false
    trailingSidebarItem.minimumThickness = 300
    threePaneSplitViewController.addSplitViewItem(trailingSidebarItem)

    super.init(nibName: nil, bundle: nil)

    self.addChild(self.threePaneSplitViewController)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func startProgressIndicator() {
    progressIndicator.isHidden = false
    progressIndicator.startAnimation(self)
  }

  public func stopProgressIndicator() {
    progressIndicator.isHidden = true
    progressIndicator.stopAnimation(self)
  }

  override func loadView() {
    view = NSView()

    for subview in [containerView, horizontalLine, progressIndicator, statisticsView] {
      subview.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(subview)
    }

    threePaneSplitViewController.view.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(threePaneSplitViewController.view)

    leadingSplitViewController.splitView.dividerStyle = .thin
    leadingSplitViewController.splitView.isVertical = false
    leadingSplitViewController.splitView.autosaveName = NSSplitView.AutosaveName(leadingSplitViewResorationIdentifier)
    leadingSplitViewController.splitView.identifier = NSUserInterfaceItemIdentifier(leadingSplitViewResorationIdentifier)

    centerSplitViewController.splitView.dividerStyle = .thin
    centerSplitViewController.splitView.isVertical = false
    centerSplitViewController.splitView.autosaveName = NSSplitView.AutosaveName(centralSplitViewResorationIdentifier)
    centerSplitViewController.splitView.identifier = NSUserInterfaceItemIdentifier(centralSplitViewResorationIdentifier)

    threePaneSplitViewController.splitView.dividerStyle = .thin
    threePaneSplitViewController.splitView.isVertical = true
    threePaneSplitViewController.splitView.autosaveName = NSSplitView.AutosaveName(splitViewResorationIdentifier)
    threePaneSplitViewController.splitView.identifier = NSUserInterfaceItemIdentifier(splitViewResorationIdentifier)

    progressIndicator.controlSize = .small
    progressIndicator.style = .spinning
    progressIndicator.isHidden = true

    let bottomBarLayoutGuide = NSLayoutGuide()
    view.addLayoutGuide(bottomBarLayoutGuide)

    NSLayoutConstraint.activate([
      // Container view
      containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
      containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -29),

      threePaneSplitViewController.view.leftAnchor.constraint(equalTo: containerView.leftAnchor),
      threePaneSplitViewController.view.rightAnchor.constraint(equalTo: containerView.rightAnchor),
      threePaneSplitViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
      threePaneSplitViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

      // Horizontal line
      horizontalLine.leftAnchor.constraint(equalTo: view.leftAnchor),
      horizontalLine.rightAnchor.constraint(equalTo: view.rightAnchor),
      horizontalLine.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -1),

      // Bottom bar layout guide
      bottomBarLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor),
      bottomBarLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor),
      bottomBarLayoutGuide.topAnchor.constraint(equalTo: containerView.bottomAnchor),
      bottomBarLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      // Progress indicator
      progressIndicator.leadingAnchor.constraint(equalToSystemSpacingAfter: bottomBarLayoutGuide.leadingAnchor, multiplier: 1),
      progressIndicator.bottomAnchor.constraint(equalTo: bottomBarLayoutGuide.bottomAnchor, constant: -7),

      // Statistics view
      statisticsView.leadingAnchor.constraint(equalToSystemSpacingAfter: progressIndicator.trailingAnchor, multiplier: 1),
      statisticsView.centerYAnchor.constraint(equalTo: bottomBarLayoutGuide.centerYAnchor),
    ])

    var lastSelectedFile: String? = nil
    selectedFileDidChangeSubscriber = NotificationCenter.default.publisher(for: .selectedFileDidChange, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard let nodes = notification.userInfo?["selectedNodes"] as? [ProjectOutlineNode] else {
          preconditionFailure()
        }
        guard let node = nodes.first else {
          self.sourceViewController.textStorage = NSTextStorage(string: "")
          return
        }
        guard lastSelectedFile != node.title else {
          return
        }
        lastSelectedFile = node.title
        self.sourceViewController.filename = node.title

        guard let document = self.view.window?.windowController?.document as? ProjectDocument else {
          return
        }
        if let metadata = document.metadata, let bank = metadata.bankMap[node.title] {
          self.sourceViewController.bank = bank
        } else {
          self.sourceViewController.bank = nil
        }
      })

    selectedRegionDidChangeSubscriber = NotificationCenter.default.publisher(for: .selectedRegionDidChange, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard let region = notification.userInfo?["selectedRegion"] as? Region else {
          preconditionFailure()
        }
        self.showRegion(region)
      })

    didCreateRegionSubscriber = NotificationCenter.default.publisher(for: .didCreateRegion, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard let region = notification.userInfo?["region"] as? Region else {
          preconditionFailure()
        }
        self.inspectorViewController.tabViewController.tabViewController.selectedTabViewItemIndex = 0
        self.inspectorViewController.regionEditorViewController.elementsController.setSelectedObjects([region])
      })

    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        self.statisticsView.statistics = self.document.disassemblyResults?.statistics
      })

    if document.isDisassembling {
      startProgressIndicator()
    }
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    document.emulationObservers.append(self)
  }

  func jumpTo(address: LR35902.Address, bank _bank: Gameboy.Cartridge.Bank, highlight: Bool = false) {
    let bank = (address < 0x4000) ? 0 : _bank
    guard let metadata = self.document.metadata else {
      return
    }
    let fileName = metadata.bankMap.first { key, value in
      value == bank
    }?.key
    guard let index = self.sidebarViewController.treeController.arrangedObjects.descendant(at: IndexPath(indexes: [0]))?.children?.firstIndex(where: { node in
      (node.representedObject as? ProjectOutlineNode)?.title == fileName
    }) else {
      return
    }
    self.sidebarViewController.treeController.setSelectionIndexPath(IndexPath(indexes: [0, index]))

    guard let lineIndex = self.document.disassemblyResults?.lineFor(address: address, bank: bank) else {
      return
    }

    guard let analysis = self.sourceViewController.lineAnalysis,
          let textView = self.sourceViewController.sourceView,
          let containerView = self.sourceViewController.sourceContainerView,
          let layoutManager = textView.layoutManager,
          let textContainer = textView.textContainer,
          analysis.lineRanges.count > 0 else {
      return
    }

    if highlight {
      self.sourceViewController.sourceView?.highlightedLine = lineIndex
    }

    if analysis.lineRanges.count > lineIndex {
      let lineRange = analysis.lineRanges[lineIndex]
      let glyphGraph = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
      let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphGraph, in: textContainer)
      self.sourceViewController.sourceView?.scroll(boundingRect.offsetBy(dx: 0, dy: -containerView.bounds.height / 2).origin)
    }
  }

  func showRegion(_ region: Region) {
    jumpTo(address: region.address, bank: region.bank, highlight: true)
  }

  private let splitViewResorationIdentifier = "com.featherless.restorationId:SplitViewController"
  private let centralSplitViewResorationIdentifier = "com.featherless.restorationId:CenterSplitViewController"
  private let leadingSplitViewResorationIdentifier = "com.featherless.restorationId:LeadingSplitViewController"
}

extension ProjectViewController: LabelJumper {
  func jumpToLabel(_ labelName: String) {
    guard let region = document.disassemblyResults?.regionLookup?[labelName] else {
      return
    }
    showRegion(region)
  }
}

extension ProjectViewController: EmulationObservers {
  func emulationDidAdvance() {
  }

  func emulationDidStart() {
  }

  func emulationDidStop() {
    let address = document.address
    let bank = document.bank
    self.sourceViewController.sourceView?.emulationLine = self.document.disassemblyResults?.lineFor(address: address, bank: bank)
    self.jumpTo(address: address, bank: bank)
  }
}
