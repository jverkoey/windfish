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
  static let typeCell = NSUserInterfaceItemIdentifier("typeCell")
  static let textCell = NSUserInterfaceItemIdentifier("textCell")
  static let numberCell = NSUserInterfaceItemIdentifier("numberCell")
  static let addressCell = NSUserInterfaceItemIdentifier("addressCell")
}

extension NSUserInterfaceItemIdentifier {
  static let type = NSUserInterfaceItemIdentifier("regionType")
  static let name = NSUserInterfaceItemIdentifier("name")
  static let bank = NSUserInterfaceItemIdentifier("bank")
  static let address = NSUserInterfaceItemIdentifier("address")
  static let length = NSUserInterfaceItemIdentifier("length")
}

final class RegionEditorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "book", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "book.fill", accessibilityDescription: nil)!

  let document: ProjectDocument
  let elementsController = NSArrayController()
  var tableView: EditorTableView?
  private var selectionObserver: NSKeyValueObservation?
  let regionTypeController = NSArrayController()

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)

    regionTypeController.addObject(Region.Kind.region)
    regionTypeController.addObject(Region.Kind.label)
    regionTypeController.addObject(Region.Kind.function)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
      Column(name: "Type", identifier: .type, width: 100),
      Column(name: "Name", identifier: .name, width: 120),
      Column(name: "Bank", identifier: .bank, width: 35),
      Column(name: "Address", identifier: .address, width: 50),
      Column(name: "Region length", identifier: .length, width: 35),
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

    selectionObserver = elementsController.observe(\.selectedObjects, options: []) { (controller, change) in
      if let region = controller.selectedObjects.first as? Region {
        NotificationCenter.default.post(name: .selectedRegionDidChange, object: self.document, userInfo: ["selectedRegion": region])
      }
    }

    let safeAreas = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
    ])

    elementsController.bind(.contentArray, to: document.configuration, withKeyPath: "regions", options: nil)
    tableView.tableView?.bind(.content, to: elementsController, withKeyPath: "arrangedObjects", options: nil)
    tableView.tableView?.bind(.selectionIndexes, to: elementsController, withKeyPath:"selectionIndexes", options: nil)
    tableView.tableView?.bind(.sortDescriptors, to: elementsController, withKeyPath: "sortDescriptors", options: nil)
  }
}

extension RegionEditorViewController: EditorTableViewDelegate {
  func createElement() -> String {
    document.configuration.regions.append(
      Region(regionType: Region.Kind.label, name: "New region", bank: 0, address: 0, length: 0)
    )
    return "Create Region"
  }

  func deleteSelectedElements() -> String {
    document.configuration.regions.removeAll { region in
      elementsController.selectedObjects.contains { $0 as! Region === region }
    }
    return "Delete Region"
  }

  func stashElements() -> Any {
    return document.configuration.regions
  }

  func restoreElements(_ elements: Any) {
    document.configuration.regions = elements as! [Region]
  }
}

extension RegionEditorViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
    let rowView = NSTableRowView()
    return rowView
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let tableColumn = tableColumn else {
      preconditionFailure()
    }

    switch tableColumn.identifier {
    case .type:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      let view: TypeTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        view = TypeTableCellView()
        view.identifier = identifier
        view.popupButton.bind(.content, to: regionTypeController, withKeyPath: "arrangedObjects", options: nil)
        view.popupButton.bind(.selectedObject, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      }
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
    case .bank: fallthrough
    case .length:
      let identifier = NSUserInterfaceItemIdentifier.numberCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = NumberFormatter()
      }
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
      return view
    default:
      preconditionFailure()
    }
  }
}

// TODO: Surface detected labels in the region inspector; add a new column indicating whether a region is automatic or manual.
// TODO: Editing an automatic label turns it into a manaul label.
// TODO: Allow sorting of the regions.
