import AppKit
import Foundation
import Cocoa
import Combine

class ProjectOutlineNode: NSObject {
  enum NodeType: Int, Codable {
    case container
    case document
    case unknown
  }

  var type: NodeType = .unknown
  var title: String = ""
  var identifier: String = ""
  var url: URL?
  @objc dynamic var children = [ProjectOutlineNode]()
}

extension ProjectOutlineNode {

  @objc var count: Int {
    children.count
  }

  @objc dynamic var isLeaf: Bool {
    return type == .document
  }
}


final class OutlineViewController: NSViewController {
  let project: Project
  let containerView = NSScrollView()
  let outlineView = NSOutlineView()
  let treeController = NSTreeController()
  @objc var contents: [ProjectOutlineNode] = []

  private var disassembledSubscriber: AnyCancellable?
  private var treeControllerObserver: NSKeyValueObservation?

  init(project: Project) {
    self.project = project

    super.init(nibName: nil, bundle: nil)
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    populateFromDocument()

    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: project)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        let selectionIndexPaths = self.treeController.selectionIndexPaths
        self.populateFromDocument()
        self.treeController.setSelectionIndexPaths(selectionIndexPaths)
      })
  }

  private func populateFromDocument() {
    guard let disassemblyFiles = project.disassemblyResults?.files else {
      return
    }
    let children = treeController.arrangedObjects.children![0]
    children.mutableChildren.removeAllObjects()
    disassemblyFiles.keys.sorted().reversed().forEach {
      let node = ProjectOutlineNode()
      node.title = $0
      node.type = .document
      treeController.insert(node, atArrangedObjectIndexPath: IndexPath(indexes: [0, 0]))
    }
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
    treeController.objectClass = ProjectOutlineNode.self
    treeController.childrenKeyPath = "children"
    treeController.countKeyPath = "count"
    treeController.leafKeyPath = "isLeaf"
    treeController.preservesSelection = true
    treeController.selectsInsertedObjects = false

    treeController.bind(.contentArray,
                        to: self,
                        withKeyPath: "contents",
                        options: nil)

    outlineView.bind(.content,
                     to: treeController,
                     withKeyPath: "arrangedObjects",
                     options: nil)
    outlineView.bind(.selectionIndexPaths,
                     to: treeController,
                     withKeyPath: "selectionIndexPaths",
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
    outlineView.style = .plain
//    outlineView.selectionHighlightStyle = .sourceList
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

    NSLayoutConstraint.activate([
      containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
      containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    addGroupNode("Source", identifier: "disassembly")

    outlineView.expandItem(treeController.arrangedObjects.children![0])

    containerView.documentView = outlineView

    // Clear any default selection.
    outlineView.deselectAll(self)

    var lastSelectedObjects: [ProjectOutlineNode] = []
    treeControllerObserver = treeController.observe(\.selectedObjects, options: [.new]) { (treeController, change) in
      precondition(treeController.selectedObjects.count <= 1, "Multiple selection not supported")
      guard let selectedNodes = treeController.selectedObjects as? [ProjectOutlineNode] else {
        return
      }
      guard lastSelectedObjects != selectedNodes else {
        return
      }
      lastSelectedObjects = selectedNodes

      NotificationCenter.default.post(
        name: .selectedFileDidChange,
        object: self.project,
        userInfo: ["selectedNodes": treeController.selectedObjects]
      )
    }
  }

  private func addGroupNode(_ folderName: String, identifier: String) {
    let node = ProjectOutlineNode()
    node.type = .container
    node.title = folderName
    node.identifier = identifier

    let insertionIndexPath = IndexPath(index: contents.count)
    treeController.insert(node, atArrangedObjectIndexPath: insertionIndexPath)
  }
}

extension OutlineViewController: NSOutlineViewDelegate {
  // Return a Node class from the given outline view item, through it's representedObject.
  class func node(from item: Any) -> ProjectOutlineNode? {
    if let treeNode = item as? NSTreeNode, let node = treeNode.representedObject as? ProjectOutlineNode {
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
