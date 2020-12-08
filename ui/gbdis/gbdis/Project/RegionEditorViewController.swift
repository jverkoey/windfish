//
//  RegionInspectorViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/3/20.
//

import Foundation
import Cocoa
import LR35902

final class RegionEditorViewController: TableViewEditorViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "book", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "book.fill", accessibilityDescription: nil)!

  let document: ProjectDocument
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

    self.textEditActionName = "Region Edit"

    regionTypeController.addObject(Region.Kind.region)
    regionTypeController.addObject(Region.Kind.label)
    regionTypeController.addObject(Region.Kind.function)
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
      tableView.addTableColumn(column)
    }

    selectionObserver = regionController.observe(\.selectedObjects, options: []) { (controller, change) in
      if let region = controller.selectedObjects.first as? Region {
        NotificationCenter.default.post(name: .selectedRegionDidChange, object: self.document, userInfo: ["selectedRegion": region])
      }
    }

    regionController.bind(.contentArray, to: document.configuration, withKeyPath: "regions", options: nil)
    tableView.bind(.content, to: regionController, withKeyPath: "arrangedObjects", options: nil)
    tableView.bind(.selectionIndexes, to: regionController, withKeyPath:"selectionIndexes", options: nil)
    tableView.bind(.sortDescriptors, to: regionController, withKeyPath: "sortDescriptors", options: nil)
  }

  override func createElement() -> String {
    document.configuration.regions.append(
      Region(regionType: Region.Kind.label, name: "New region", bank: 0, address: 0, length: 0)
    )
    return "Create Region"
  }

  override func deleteSelectedElements() -> String {
    document.configuration.regions.removeAll { region in
      regionController.selectedObjects.contains { $0 as! Region === region }
    }
    return "Delete Region"
  }

  override func stashElements() -> Any {
    return document.configuration.regions
  }

  override func restoreElements(_ elements: Any) {
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
    let view: NSTableCellView

    switch tableColumn.identifier {
    case .type:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        let typeView = TypeTableCellView()
        typeView.identifier = identifier
        typeView.popupButton.bind(.content, to: regionTypeController, withKeyPath: "arrangedObjects", options: nil)
        typeView.popupButton.bind(.selectedObject, to: typeView, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
        view = typeView
      }
    case .name:
      let identifier = NSUserInterfaceItemIdentifier.textCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
      }
    case .bank: fallthrough
    case .length:
      let identifier = NSUserInterfaceItemIdentifier.numberCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = NumberFormatter()
      }
    case .address:
      let identifier = NSUserInterfaceItemIdentifier.addressCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = LR35902AddressFormatter()
      }
    default:
      preconditionFailure()
    }

    view.textField?.delegate = self
    view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)

    return view
  }
}

// TODO: Surface detected labels in the region inspector; add a new column indicating whether a region is automatic or manual.
// TODO: Editing an automatic label turns it into a manaul label.
// TODO: Allow sorting of the regions.
