//
//  RegionInspectorViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/3/20.
//

import Foundation
import Cocoa
import LR35902

class Region: NSObject, NSCopying {
  @objc dynamic let name: String
  @objc dynamic let bank: LR35902.Bank
  @objc dynamic let address: LR35902.Address
  @objc dynamic let length: LR35902.Address

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

final class LR35902AddressFormatter: Formatter {
  override func string(for obj: Any?) -> String? {
    guard let address = obj as? LR35902.Address else {
      return nil
    }
    return "0x\(address.hexString)"
  }
//
//  override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
//                               for string: String,
//                               errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
//    if string.hasPrefix("0x") {
//      let numericalValue = string.dropFirst(3)
//      obj?.pointee = LR35902.Address(numericalValue, radix: 16)
//      return true
//    }
//    return false
//  }
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

    for columnName in [("Name", "name"), ("Bank", "bank"), ("Address", "address"), ("Length", "length")] {
      let column = NSTableColumn(identifier: .init(rawValue: columnName.1))
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
    case .init("name"): fallthrough
    case .init("bank"): fallthrough
    case .init("length"):
      let identifier = NSUserInterfaceItemIdentifier("textCell")
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
      }
    case .init("address"):
      let identifier = NSUserInterfaceItemIdentifier("numberCell")
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
