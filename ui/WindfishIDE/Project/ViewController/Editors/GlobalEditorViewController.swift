import AppKit
import Foundation
import Cocoa

import Windfish

extension NSUserInterfaceItemIdentifier {
  static let dataType = NSUserInterfaceItemIdentifier("dataType")
}

final class GlobalEditorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "character.book.closed", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "character.book.closed.fill", accessibilityDescription: nil)!

  let project: Project
  let elementsController = NSArrayController()
  var tableView: EditorTableView?
  let dataTypeController = NSArrayController()

  init(project: Project) {
    self.project = project

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  override func loadView() {
    view = NSView()

    let tableView = EditorTableView(elementsController: elementsController)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.tableView?.delegate = self
    view.addSubview(tableView)
    self.tableView = tableView

    let columns = [
      Column(name: "Name", identifier: .name, width: 120),
      Column(name: "Address", identifier: .address, width: 50),
      Column(name: "Data type", identifier: .dataType, width: 35),
    ]

    for columnInfo in columns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      // Note: this only works for cell-based tables.
//      column.bind(.value, to: regionController, withKeyPath: "arrangedObjects.name", options: nil)
      tableView.tableView?.addTableColumn(column)
    }

    let safeAreas = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
    ])

    elementsController.sortDescriptors = [
      NSSortDescriptor(key: NSUserInterfaceItemIdentifier.address.rawValue, ascending: true),
    ]

    elementsController.bind(.contentArray, to: project.configuration, withKeyPath: "globals", options: nil)
    dataTypeController.bind(.contentArray, to: project.configuration, withKeyPath: "dataTypes", options: nil)
    tableView.tableView?.bind(.content, to: elementsController, withKeyPath: "arrangedObjects", options: nil)
    tableView.tableView?.bind(.selectionIndexes, to: elementsController, withKeyPath:"selectionIndexes", options: nil)
    tableView.tableView?.bind(.sortDescriptors, to: elementsController, withKeyPath: "sortDescriptors", options: nil)
  }
}

extension GlobalEditorViewController: EditorTableViewDelegate {
  func editorTableViewCreateElement(_ tableView: EditorTableView) -> String {
    project.configuration.globals.append(
      Global(name: "global", address: 0x0000, dataType: "")
    )
    return "Create Global"
  }

  func editorTableViewDeleteSelectedElements(_ tableView: EditorTableView) -> String {
    project.configuration.globals.removeAll { global in
      elementsController.selectedObjects.contains { $0 as! Global === global }
    }
    return "Delete Global"
  }

  func editorTableViewStashElements(_ tableView: EditorTableView) -> Any {
    return project.configuration.globals
  }

  func editorTableView(_ tableView: EditorTableView, restoreElements elements: Any) {
    project.configuration.globals = elements as! [Global]
  }
}

extension GlobalEditorViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
    let rowView = NSTableRowView()
    return rowView
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let tableColumn = tableColumn else {
      preconditionFailure()
    }

    switch tableColumn.identifier {
    case .dataType:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      let view: TypeTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        view = TypeTableCellView()
        view.identifier = identifier
      }
      view.popupButton.bind(.content, to: dataTypeController, withKeyPath: "arrangedObjects.@distinctUnionOfObjects.name", options: nil)
      view.popupButton.bind(.selectedObject, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    case .name:
      let identifier = NSUserInterfaceItemIdentifier.textCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
      }
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    case .address:
      let identifier = NSUserInterfaceItemIdentifier.addressCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = LR35902AddressFormatter()
      }
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    default:
      preconditionFailure()
    }
  }
}
