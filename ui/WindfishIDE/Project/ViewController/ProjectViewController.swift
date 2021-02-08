import AppKit
import Cocoa
import Combine

import LR35902
import Tracing
import Windfish

final class ProjectViewController: NSViewController {

  let project: Project
  let containerView = NSView()
  let horizontalLine = HorizontalLine()
  let progressIndicator = NSProgressIndicator()
  let statisticsView = StatisticsView()
  let threePaneSplitViewController: NSSplitViewController
  let leadingSplitViewController: NSSplitViewController
  let centerSplitViewController: NSSplitViewController

  let sidebarViewController: OutlineViewController
  let callstackViewController: CallStackViewController
  let sourceViewController: SourceViewController
  let debuggingViewController: DebuggingViewController
  let inspectorViewController: InspectorViewController

  private var selectedFileDidChangeSubscriber: AnyCancellable?
  private var selectedRegionDidChangeSubscriber: AnyCancellable?
  private var jumpToLocationSubscriber: AnyCancellable?
  private var didCreateRegionSubscriber: AnyCancellable?
  private var disassembledSubscriber: AnyCancellable?

  init(project: Project) {
    self.project = project

    self.threePaneSplitViewController = NSSplitViewController()
    self.leadingSplitViewController = NSSplitViewController()
    self.centerSplitViewController = NSSplitViewController()
    self.callstackViewController = CallStackViewController(project: project)
    self.sidebarViewController = OutlineViewController(project: project)
    self.sourceViewController = SourceViewController(project: project)
    self.debuggingViewController = DebuggingViewController(project: project)
    self.inspectorViewController = InspectorViewController(project: project)

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
      progressIndicator.leadingAnchor.constraint(equalToSystemOrDefaultSpacingAfter: bottomBarLayoutGuide.leadingAnchor, multiplier: 1),
      progressIndicator.bottomAnchor.constraint(equalTo: bottomBarLayoutGuide.bottomAnchor, constant: -7),

      // Statistics view
      statisticsView.leadingAnchor.constraint(equalToSystemOrDefaultSpacingAfter: progressIndicator.trailingAnchor, multiplier: 1),
      statisticsView.centerYAnchor.constraint(equalTo: bottomBarLayoutGuide.centerYAnchor),
    ])

    var lastSelectedFile: String? = nil
    selectedFileDidChangeSubscriber = NotificationCenter.default.publisher(for: .selectedFileDidChange, object: project)
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
        if let metadata = self.project.metadata, let bank = metadata.bankMap[node.title] {
          self.sourceViewController.bank = bank
        } else {
          self.sourceViewController.bank = nil
        }
      })

    selectedRegionDidChangeSubscriber = NotificationCenter.default.publisher(for: .selectedRegionDidChange, object: project)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard let region = notification.userInfo?["selectedRegion"] as? Region else {
          preconditionFailure()
        }
        self.showRegion(region)
      })

    jumpToLocationSubscriber = NotificationCenter.default.publisher(for: .jumpToLocation, object: project)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard let location = notification.userInfo?["location"] as? Cartridge.Location else {
          preconditionFailure()
        }
        self.jumpTo(address: location.address, bank: location.bank, highlight: true)
      })

    didCreateRegionSubscriber = NotificationCenter.default.publisher(for: .didCreateRegion, object: project)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard let region = notification.userInfo?["region"] as? Region else {
          preconditionFailure()
        }
        self.inspectorViewController.tabViewController.tabViewController.selectedTabViewItemIndex = 0
        self.inspectorViewController.regionEditorViewController.elementsController.setSelectedObjects([region])
      })

    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: project)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        self.statisticsView.statistics = self.project.disassemblyResults?.statistics
      })

    if project.isDisassembling {
      startProgressIndicator()
    }
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    project.emulationObservers.add(self)
  }

  func jumpTo(address: LR35902.Address, bank _bank: Cartridge.Bank, highlight: Bool = false) {
    let bank = (address < 0x4000) ? 0 : _bank
    guard let metadata = project.metadata else {
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

    let jumpToLine: () -> Void = {
      guard let lineIndex = self.project.disassemblyResults?.lineFor(address: address, bank: bank) else {
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

    let desiredIndexPath: IndexPath = IndexPath(indexes: [0, index])
    if self.sidebarViewController.treeController.selectionIndexPath != desiredIndexPath {
      self.sidebarViewController.treeController.setSelectionIndexPath(desiredIndexPath)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: jumpToLine)
    } else {
      jumpToLine()
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
    guard let region = project.disassemblyResults?.regionLookup?[labelName] else {
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
    let address = project.address
    let bank = project.bank
    self.sourceViewController.sourceView?.emulationLine = project.disassemblyResults?.lineFor(address: address, bank: bank)
    self.jumpTo(address: address, bank: bank)
  }
}
