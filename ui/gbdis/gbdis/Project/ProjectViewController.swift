//
//  ViewController.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import Cocoa
import Combine

final class ProjectViewController: NSViewController {

  let document: ProjectDocument
  let containerView = NSView()
  let horizontalLine = HorizontalLine()
  let progressIndicator = NSProgressIndicator()
  let splitViewController: NSSplitViewController

  let sidebarViewController: OutlineViewController
  let contentViewController: ContentViewController
  let inspectorViewController: InspectorViewController

  private var selectedFileDidChangeSubscriber: AnyCancellable?
  private var selectedRegionDidChangeSubscriber: AnyCancellable?
  private var didCreateRegionSubscriber: AnyCancellable?

  init(document: ProjectDocument) {
    self.document = document

    self.splitViewController = NSSplitViewController()
    self.sidebarViewController = OutlineViewController(document: document)
    self.contentViewController = ContentViewController(document: document)
    self.inspectorViewController = InspectorViewController(document: document)

    let leadingSidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarViewController)
    leadingSidebarItem.canCollapse = false
    splitViewController.addSplitViewItem(leadingSidebarItem)

    splitViewController.addSplitViewItem(NSSplitViewItem(viewController: contentViewController))

    let trailingSidebarItem = NSSplitViewItem(sidebarWithViewController: inspectorViewController)
    trailingSidebarItem.canCollapse = false
    trailingSidebarItem.minimumThickness = 400
    splitViewController.addSplitViewItem(trailingSidebarItem)

    super.init(nibName: nil, bundle: nil)

    self.addChild(self.splitViewController)
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

    for subview in [containerView, horizontalLine, progressIndicator] {
      subview.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(subview)
    }

    splitViewController.view.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(splitViewController.view)

    splitViewController.splitView.dividerStyle = .thin
    splitViewController.splitView.isVertical = true
    splitViewController.splitView.autosaveName = NSSplitView.AutosaveName(splitViewResorationIdentifier)
    splitViewController.splitView.identifier = NSUserInterfaceItemIdentifier(splitViewResorationIdentifier)

    progressIndicator.controlSize = .small
    progressIndicator.style = .spinning
    progressIndicator.isHidden = true

    NSLayoutConstraint.activate([
      // Container view
      containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
      containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -29),

      // Horizontal line
      horizontalLine.leftAnchor.constraint(equalTo: view.leftAnchor),
      horizontalLine.rightAnchor.constraint(equalTo: view.rightAnchor),
      horizontalLine.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -1),

      // Progress indicator
      progressIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
      progressIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -7)
    ] + constraints(for: splitViewController.view, filling: containerView))

    var lastSelectedFile: String? = nil
    selectedFileDidChangeSubscriber = NotificationCenter.default.publisher(for: .selectedFileDidChange, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard let nodes = notification.userInfo?["selectedNodes"] as? [ProjectOutlineNode] else {
          preconditionFailure()
        }
        guard let node = nodes.first else {
          self.contentViewController.textStorage = NSTextStorage(string: "")
          return
        }
        guard lastSelectedFile != node.title else {
          return
        }
        lastSelectedFile = node.title
        self.contentViewController.filename = node.title

        if let metadata = self.document.metadata, let bank = metadata.bankMap[node.title] {
          self.contentViewController.bank = bank
        } else {
          self.contentViewController.bank = nil
        }
      })

    selectedRegionDidChangeSubscriber = NotificationCenter.default.publisher(for: .selectedRegionDidChange, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        guard let region = notification.userInfo?["selectedRegion"] as? Region else {
          preconditionFailure()
        }

        guard let metadata = self.document.metadata else {
          return
        }
        let fileName = metadata.bankMap.first { key, value in
          value == region.bank
        }?.key
        guard let index = self.sidebarViewController.treeController.arrangedObjects.descendant(at: IndexPath(indexes: [0]))?.children?.firstIndex(where: { node in
          (node.representedObject as? ProjectOutlineNode)?.title == fileName
        }) else {
          return
        }
        self.sidebarViewController.treeController.setSelectionIndexPath(IndexPath(indexes: [0, index]))

        guard let bankLines = self.document.disassemblyResults?.bankLines?[region.bank] else {
          return
        }
        guard let lineIndex = bankLines.firstIndex(where: { line in
          if let address = line.address {
            return address >= region.address
          } else {
            return false
          }
        }) else {
          return
        }

        guard let analysis = self.contentViewController.lineAnalysis,
              let textView = self.contentViewController.textView,
              let containerView = self.contentViewController.containerView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer,
              analysis.lineRanges.count > 0 else {
          return
        }

        let lineRange = analysis.lineRanges[lineIndex]
        let glyphGraph = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
        let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphGraph, in: textContainer)
        self.contentViewController.textView?.scroll(boundingRect.offsetBy(dx: 0, dy: -containerView.bounds.height / 2).origin)
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

    if document.isDisassembling {
      startProgressIndicator()
    }
  }

  private let splitViewResorationIdentifier = "com.featherless.restorationId:SplitViewController"
}
