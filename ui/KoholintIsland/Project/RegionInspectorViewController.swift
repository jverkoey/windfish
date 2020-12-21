//
//  RegionInspectorViewController.swiftui
//
//  Created by Jeff Verkoeyen on 12/3/20.
//

import Foundation
import Cocoa
import Windfish

final class RegionInspectorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "book", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "book.fill", accessibilityDescription: nil)!

  let document: ProjectDocument
  let regionController = NSArrayController()
  private var selectionObserver: NSKeyValueObservation?
  let regionTypeController = NSArrayController()
  var tableView = NSTableView()

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

    let containerView = NSScrollView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true

    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.style = .fullWidth
    tableView.selectionHighlightStyle = .regular
    tableView.delegate = self
    containerView.documentView = tableView
    view.addSubview(containerView)

    let contextMenu = NSMenu()
    contextMenu.addItem(withTitle: "Define label...", action: #selector(createRegion(_:)), keyEquivalent: "")
    tableView.menu = contextMenu

    let safeAreas = view.safeAreaLayoutGuide

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
    ])

    let columns = [
      Column(name: "Name", identifier: .name, width: 120),
      Column(name: "Bank", identifier: .bank, width: 35),
      Column(name: "Address", identifier: .address, width: 50),
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

    regionController.sortDescriptors = [
      NSSortDescriptor(key: NSUserInterfaceItemIdentifier.bank.rawValue, ascending: true),
      NSSortDescriptor(key: NSUserInterfaceItemIdentifier.address.rawValue, ascending: true),
    ]

    regionController.bind(.contentArray, to: document, withKeyPath: "disassemblyResults.regions", options: nil)
    tableView.bind(.content, to: regionController, withKeyPath: "arrangedObjects", options: nil)
    tableView.bind(.selectionIndexes, to: regionController, withKeyPath:"selectionIndexes", options: nil)
    tableView.bind(.sortDescriptors, to: regionController, withKeyPath: "sortDescriptors", options: nil)
  }
}

extension RegionInspectorViewController: NSUserInterfaceValidations {
  @objc func createRegion(_ sender: AnyObject) {
    guard let region = (regionController.arrangedObjects as? [Region])?[tableView.clickedRow] else {
      return
    }
    document.configuration.regions.append(region)

    NotificationCenter.default.post(name: .didCreateRegion, object: document, userInfo: ["region": region])
  }

  func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    guard let region = (regionController.arrangedObjects as? [Region])?[tableView.clickedRow] else {
      return false
    }
    guard document.configuration.regions.first(where: { existingRegion in
      existingRegion.bank == region.bank && existingRegion.address == region.address
    }) == nil else {
      return false
    }
    return true
  }
}

extension RegionInspectorViewController: NSTableViewDelegate {
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
    case .name:
      let identifier = NSUserInterfaceItemIdentifier.textCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
      }
    case .bank:
      let identifier = NSUserInterfaceItemIdentifier.numberCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = UInt8HexFormatter()
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

    view.textField?.isEditable = false
    view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)

    return view
  }
}
