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
        let string = String(data: self.document.disassemblyFiles![node.title]!, encoding: .utf8)!
        self.contentViewController.textStorage = NSTextStorage(string: string)

        if let metadata = self.document.metadata, let bank = metadata.bankMap[node.title] {
          self.contentViewController.showBank(bank: bank)
        } else {
          self.contentViewController.showBank(bank: nil)
        }
      })

    if document.isDisassembling {
      startProgressIndicator()
    }
  }

  private let splitViewResorationIdentifier = "com.featherless.restorationId:SplitViewController"
}
