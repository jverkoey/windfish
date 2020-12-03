//
//  OutlineViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation
import Cocoa
import Combine

final class OutlineViewController: NSViewController {
  let document: ProjectDocument

  let containerView = NSScrollView()
  let outlineView = NSOutlineView()
  let treeController = NSTreeController()
  @objc var contents: [ProjectOutlineNode] = []

  private var disassembledSubscriber: AnyCancellable?
  private var treeControllerObserver: NSKeyValueObservation?

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)

    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        let selectionIndexPaths = self.treeController.selectionIndexPaths
        self.populateFromDocument()
        self.treeController.setSelectionIndexPaths(selectionIndexPaths)
      })
  }

  private func populateFromDocument() {
    guard let disassemblyFiles = document.disassemblyFiles else {
      return
    }
    let children = self.treeController.arrangedObjects.children![0]
    children.mutableChildren.removeAllObjects()
    for filename in disassemblyFiles.keys.sorted() {
      let node = ProjectOutlineNode()
      node.title = filename
      node.type = .document
      self.treeController.insert(node, atArrangedObjectIndexPath: IndexPath(indexes: [0, self.treeController.arrangedObjects.children![0].children!.count]))
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

    NSLayoutConstraint.activate(constraints(for: containerView, filling: view))

    addGroupNode("Source", identifier: "disassembly")

    outlineView.expandItem(treeController.arrangedObjects.children![0])

    containerView.documentView = outlineView

    treeControllerObserver = treeController.observe(\.selectedObjects, options: [.new]) { (treeController, change) in
      let nodes = treeController.selectedNodes.map { OutlineViewController.node(from: $0) }
      NotificationCenter.default.post(name: .selectedFileDidChange, object: self.document, userInfo: ["selectedNodes": nodes])
    }

    populateFromDocument()

    // Clear any default selection.
    outlineView.deselectAll(self)
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
