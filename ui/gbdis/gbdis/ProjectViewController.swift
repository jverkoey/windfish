//
//  ViewController.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import Combine
import Cocoa

func constraints(for contentView: NSView, filling containerView: NSView) -> [NSLayoutConstraint] {
  return [
    contentView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
    contentView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
    contentView.topAnchor.constraint(equalTo: containerView.topAnchor),
    contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
  ]
}

enum NodeType: Int, Codable {
  case container
  case document
  case separator
  case unknown
}

class OutlineNode: NSObject {
  var type: NodeType = .unknown
  var title: String = ""
  var identifier: String = ""
  var url: URL?
  @objc dynamic var children = [OutlineNode]()
}

extension OutlineNode {

  @objc var count: Int {
    children.count
  }

  @objc dynamic var isLeaf: Bool {
    return type == .document || type == .separator
  }

  var isURLNode: Bool {
    return url != nil
  }

  var canChange: Bool {
    // You can only change (rename or add to) non-url based directory node.
    return isDirectory && url == nil
  }

  var isSeparator: Bool {
    return type == .separator
  }

  var isDirectory: Bool {
    return type == .container
  }

}


extension URL {
  // Returns the human-visible localized name.
  var localizedName: String {
    var localizedName = ""
    if let fileNameResource = try? resourceValues(forKeys: [.localizedNameKey]) {
      localizedName = fileNameResource.localizedName!
    } else {
      // Failed to get the localized name, use it's last path component as the name.
      localizedName = lastPathComponent
    }
    return localizedName
  }
}

final class OutlineViewController: NSViewController {
  let document: ProjectDocument

  let containerView = NSScrollView()
  let outlineView = NSOutlineView()
  let treeController = NSTreeController()
  @objc var contents: [OutlineNode] = []

  private var disassembledSubscriber: AnyCancellable?

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)

    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        for filename in document.disassemblyFiles!.keys.sorted() {
          let node = OutlineNode()
          node.title = filename
          node.type = .document
          self.treeController.insert(node, atArrangedObjectIndexPath: IndexPath(indexes: [0, self.treeController.arrangedObjects.children![0].children!.count]))
        }
      })
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()

    containerView.hasVerticalScroller = true
    containerView.hasHorizontalScroller = true
    containerView.autohidesScrollers = true
    containerView.drawsBackground = false
    containerView.usesPredominantAxisScrolling = false

    for subview in [containerView] {
      subview.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(subview)
    }

    // Data bindings
    treeController.objectClass = OutlineNode.self
    treeController.childrenKeyPath = "children"
    treeController.countKeyPath = "count"
    treeController.leafKeyPath = "isLeaf"

    treeController.bind(NSBindingName(rawValue: "contentArray"),
                        to: self,
                        withKeyPath: "contents",
                        options: nil)

    outlineView.bind(NSBindingName(rawValue: "content"),
                     to: treeController,
                     withKeyPath: "arrangedObjects",
                     options: nil)

    let column = NSTableColumn(identifier: .init(rawValue: "col1"))
    column.isEditable = false
    column.headerCell.stringValue = "Header"
    column.resizingMask = .autoresizingMask
    outlineView.addTableColumn(column)
    outlineView.outlineTableColumn = column

    outlineView.headerView = nil  // Hide the header

    outlineView.delegate = self
    outlineView.backgroundColor = .clear
    outlineView.style = .automatic
    outlineView.selectionHighlightStyle = .sourceList
    outlineView.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
    outlineView.allowsMultipleSelection = false
    outlineView.allowsEmptySelection = true
    outlineView.allowsColumnSelection = false
//    outlineView.autosaveName = "OutlineView"
    outlineView.autosaveTableColumns = false
    outlineView.indentationPerLevel = 13
    outlineView.indentationMarkerFollowsCell = true
    outlineView.rowSizeStyle = .default
    outlineView.autosaveExpandedItems = true
    outlineView.allowsColumnResizing = false
    outlineView.allowsColumnReordering = false
    outlineView.floatsGroupRows = false

    NSLayoutConstraint.activate(constraints(for: containerView, filling: view))

    addGroupNode("Disassembly", identifier: "disassembly")

    outlineView.expandItem(treeController.arrangedObjects.children![0])

    containerView.documentView = outlineView
  }

  private func addGroupNode(_ folderName: String, identifier: String) {
    let node = OutlineNode()
    node.type = .container
    node.title = folderName
    node.identifier = identifier

    let insertionIndexPath = IndexPath(index: contents.count)
    treeController.insert(node, atArrangedObjectIndexPath: insertionIndexPath)
  }
}

final class TextTableCellView: NSTableCellView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    let textField = NSTextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.isBordered = false
    textField.drawsBackground = false // Required for text color to be set correctly.
    addSubview(textField)

    self.textField = textField

    NSLayoutConstraint.activate([
      textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
      textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 3),
      textField.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension OutlineViewController: NSOutlineViewDelegate {
  // Return a Node class from the given outline view item, through it's representedObject.
  class func node(from item: Any) -> OutlineNode? {
    if let treeNode = item as? NSTreeNode, let node = treeNode.representedObject as? OutlineNode {
      return node
    } else {
      return nil
    }
  }

  func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    if let node = OutlineViewController.node(from: item) {
      return node.type == .container
    }
    return false
  }

  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    if let node = OutlineViewController.node(from: item) {
      return node.type != .container
    }
    return true
  }

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    guard let node = OutlineViewController.node(from: item) else {
      return nil
    }

    let identifier = NSUserInterfaceItemIdentifier("content-cell")
    var view: NSTableCellView?
    if let recycledView = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView {
      view = recycledView
    } else {
      let newCell = TextTableCellView()
      newCell.identifier = identifier
      view = newCell
    }

    view?.textField?.stringValue = node.title
    view?.textField?.isEditable = false

    return view
  }
}

final class ContentViewController: NSViewController {
  override func loadView() {
    view = NSView()
  }
}

final class SplitViewController: NSSplitViewController {
  let sidebarViewController: NSViewController
  let contentViewController: NSViewController

  init(document: ProjectDocument) {
    self.sidebarViewController = OutlineViewController(document: document)
    self.contentViewController = ContentViewController()

    super.init(nibName: nil, bundle: nil)

    addSplitViewItem(NSSplitViewItem(sidebarWithViewController: sidebarViewController))
    addSplitViewItem(NSSplitViewItem(viewController: contentViewController))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    splitView.dividerStyle = .paneSplitter
    splitView.isVertical = true
    splitView.autosaveName = NSSplitView.AutosaveName(splitViewResorationIdentifier)
    splitView.identifier = NSUserInterfaceItemIdentifier(splitViewResorationIdentifier)
  }

  private let splitViewResorationIdentifier = "com.featherless.restorationId:SplitViewController"
}

final class ProjectViewController: NSViewController {

  let document: ProjectDocument
  let containerView = NSView()
  let horizontalLine = HorizontalLine()
  let progressIndicator = NSProgressIndicator()
  let contentViewController: NSViewController

  init(document: ProjectDocument) {
    self.document = document
    self.contentViewController = SplitViewController(document: document)

    super.init(nibName: nil, bundle: nil)

    self.addChild(self.contentViewController)
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

    contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(contentViewController.view)

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
    ] + constraints(for: contentViewController.view, filling: containerView))
  }
}
