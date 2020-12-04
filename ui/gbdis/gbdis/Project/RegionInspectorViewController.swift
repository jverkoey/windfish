//
//  RegionInspectorViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/3/20.
//

import Foundation
import Cocoa

final class RegionInspectorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "book", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "book.fill", accessibilityDescription: nil)!

  override func loadView() {
    view = NSView()

    let containerView = NSScrollView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true

    let regionTableView = NSTableView()
    regionTableView.translatesAutoresizingMaskIntoConstraints = false
    regionTableView.dataSource = self
    regionTableView.delegate = self
    containerView.documentView = regionTableView
    view.addSubview(containerView)

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.heightAnchor.constraint(equalToConstant: 200)
    ])

    for columnName in ["Name", "Bank", "Start address", "Length"] {
      let column = NSTableColumn(identifier: .init(rawValue: columnName))
      column.isEditable = false
      column.headerCell.stringValue = columnName
      regionTableView.addTableColumn(column)
    }
  }
}

extension RegionInspectorViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return 10
  }
}

extension RegionInspectorViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let textField: NSTextField

    switch tableColumn?.identifier {
    case .init("Name"):
      let identifier = NSUserInterfaceItemIdentifier("textCell")
      if let existingTextField = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTextField {
        textField = existingTextField
      } else {
        textField = NSTextField()
        textField.identifier = identifier
        textField.drawsBackground = false
      }
      textField.stringValue = "Hello"
    case .init("Bank"): fallthrough
    case .init("Start address"): fallthrough
    case .init("Length"):
      let identifier = NSUserInterfaceItemIdentifier("numberCell")
      if let existingTextField = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTextField {
        textField = existingTextField
      } else {
        textField = NSTextField()
        textField.identifier = identifier
        textField.drawsBackground = false
      }
      textField.stringValue = "123"
    default:
      preconditionFailure()
    }


    return textField
  }
}
