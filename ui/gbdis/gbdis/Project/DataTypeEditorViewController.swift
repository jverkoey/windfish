//
//  RegionInspectorViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/3/20.
//

import Foundation
import Cocoa
import LR35902

extension NSUserInterfaceItemIdentifier {
  static let representation = NSUserInterfaceItemIdentifier("representation")
  static let interpretation = NSUserInterfaceItemIdentifier("interpretation")
}

final class DataTypeEditorViewController: TableViewEditorViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "number.circle", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "number.circle.fill", accessibilityDescription: nil)!

  let document: ProjectDocument
  private var selectionObserver: NSKeyValueObservation?
  let representationController = NSArrayController()
  let interpretationController = NSArrayController()

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)

    self.textEditActionName = "Data Type Edit"

    representationController.addObject(DataType.Representation.decimal)
    representationController.addObject(DataType.Representation.hexadecimal)
    representationController.addObject(DataType.Representation.binary)

    interpretationController.addObject(DataType.Interpretation.any)
    interpretationController.addObject(DataType.Interpretation.bitmask)
    interpretationController.addObject(DataType.Interpretation.enumerated)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let tableView = tableView else {
      preconditionFailure()
    }

    tableView.delegate = self

    let columns = [
      Column(name: "Name", identifier: .name, width: 120),
      Column(name: "Representation", identifier: .representation, width: 100),
      Column(name: "Interpretation", identifier: .interpretation, width: 120),
    ]

    for columnInfo in columns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      // Note: this only works for cell-based tables.
//      column.bind(.value, to: regionController, withKeyPath: "arrangedObjects.name", options: nil)
      tableView.addTableColumn(column)
    }

    selectionObserver = elementsController.observe(\.selectedObjects, options: []) { (controller, change) in
      if let region = controller.selectedObjects.first as? Region {
        NotificationCenter.default.post(name: .selectedRegionDidChange, object: self.document, userInfo: ["selectedRegion": region])
      }
    }

    elementsController.bind(.contentArray, to: document.configuration, withKeyPath: "dataTypes", options: nil)
    tableView.bind(.content, to: elementsController, withKeyPath: "arrangedObjects", options: nil)
    tableView.bind(.selectionIndexes, to: elementsController, withKeyPath:"selectionIndexes", options: nil)
    tableView.bind(.sortDescriptors, to: elementsController, withKeyPath: "sortDescriptors", options: nil)
  }

  override func createElement() -> String {
    document.configuration.dataTypes.append(
      DataType(name: "New data type", representation: DataType.Representation.decimal, interpretation: DataType.Interpretation.any, namedValues: [:])
    )
    return "Create Data Type"
  }

  override func deleteSelectedElements() -> String {
    document.configuration.dataTypes.removeAll { region in
      elementsController.selectedObjects.contains { $0 as! Region === region }
    }
    return "Delete Data Type"
  }

  override func stashElements() -> Any {
    return document.configuration.dataTypes
  }

  override func restoreElements(_ elements: Any) {
    document.configuration.dataTypes = elements as! [DataType]
  }
}

extension DataTypeEditorViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
    let rowView = NSTableRowView()
    return rowView
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let tableColumn = tableColumn else {
      preconditionFailure()
    }

    switch tableColumn.identifier {
    case .name:
      let identifier = NSUserInterfaceItemIdentifier.textCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
      }
      view.textField?.delegate = self
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    case .representation:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      let view: TypeTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        view = TypeTableCellView()
        view.identifier = identifier
      }
      view.popupButton.bind(.content, to: representationController, withKeyPath: "arrangedObjects", options: nil)
      view.popupButton.bind(.selectedObject, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    case .interpretation:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      let view: TypeTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        view = TypeTableCellView()
        view.identifier = identifier
      }
      view.popupButton.bind(.content, to: interpretationController, withKeyPath: "arrangedObjects", options: nil)
      view.popupButton.bind(.selectedObject, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    default:
      preconditionFailure()
    }
  }
}
