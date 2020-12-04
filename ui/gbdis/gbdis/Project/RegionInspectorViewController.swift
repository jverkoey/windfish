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
  fileprivate static let name = NSUserInterfaceItemIdentifier("name")
  fileprivate static let bank = NSUserInterfaceItemIdentifier("bank")
  fileprivate static let address = NSUserInterfaceItemIdentifier("address")
  fileprivate static let length = NSUserInterfaceItemIdentifier("length")

  fileprivate static let textCell = NSUserInterfaceItemIdentifier("textCell")
  fileprivate static let numberCell = NSUserInterfaceItemIdentifier("numberCell")
  fileprivate static let addressCell = NSUserInterfaceItemIdentifier("addressCell")
}

class Region: NSObject, NSCopying {
  @objc dynamic var name: String
  @objc dynamic var bank: LR35902.Bank
  @objc dynamic var address: LR35902.Address
  @objc dynamic var length: LR35902.Address

  init(name: String, bank: LR35902.Bank, address: LR35902.Address, length: LR35902.Address) {
    self.name = name
    self.bank = bank
    self.address = address
    self.length = length
  }

  func copy(with zone: NSZone? = nil) -> Any {
    return Region(name: name, bank: bank, address: address, length: length)
  }
}

final class RegionInspectorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "book", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "book.fill", accessibilityDescription: nil)!

  let regionController = NSArrayController()

  override func loadView() {
    view = NSView()

    let containerView = NSScrollView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true

    let regionTableView = NSTableView()
    regionTableView.translatesAutoresizingMaskIntoConstraints = false
    regionTableView.delegate = self
    regionTableView.style = .fullWidth
    regionTableView.selectionHighlightStyle = .regular
    containerView.documentView = regionTableView
    view.addSubview(containerView)

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.heightAnchor.constraint(equalToConstant: 200)
    ])

    for columnName in [("Name", NSUserInterfaceItemIdentifier.name), ("Bank", .bank), ("Address", .address), ("Length", .length)] {
      let column = NSTableColumn(identifier: columnName.1)
      column.isEditable = false
      column.headerCell.stringValue = columnName.0
      column.width = 50
      // Note: this only works for cell-based tables.
//      column.bind(.value, to: regionController, withKeyPath: "arrangedObjects.name", options: nil)
      regionTableView.addTableColumn(column)
    }

    regionController.addObject(Region(
      name: "RST_00",
      bank: 0,
      address: 0x0000,
      length: 8
    ))

    regionTableView.bind(.content, to: regionController, withKeyPath: "arrangedObjects", options: nil)
    regionTableView.bind(.selectionIndexes, to: regionController, withKeyPath:"selectionIndexes", options: nil)
    regionTableView.bind(.sortDescriptors, to: regionController, withKeyPath: "sortDescriptors", options: nil)
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
    let view: TextTableCellView

    switch tableColumn.identifier {
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

    view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)

    return view
  }
}
