import AppKit
import Foundation
import Cocoa

import Windfish

extension NSUserInterfaceItemIdentifier {
  static let label = NSUserInterfaceItemIdentifier("label")
}

private class CallStack: NSObject {
  internal init(address: LR35902.Address, bank: Gameboy.Cartridge.Bank, label: String) {
    self.address = address
    self.bank = bank
    self.label = label
  }

  @objc let address: LR35902.Address
  @objc let bank: Gameboy.Cartridge.Bank
  @objc let label: String
}

final class CallStackViewController: NSViewController {
  let elementsController = NSArrayController()
  var tableView: NSTableView?
  let regionTypeController = NSArrayController()
  @objc private dynamic var stackTrace: [CallStack] = [
    .init(address: 0xff00, bank: 0x01, label: "toc_ffff_00")
  ]

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  override func loadView() {
    view = NSView()

    let containerView = NSScrollView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true

    let tableView = NSTableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.style = .fullWidth
    tableView.selectionHighlightStyle = .regular
    tableView.delegate = self
    containerView.documentView = tableView
    view.addSubview(containerView)
    self.tableView = tableView

    let columns = [
      Column(name: "Address", identifier: .address, width: 45),
      Column(name: "Bank", identifier: .bank, width: 30),
      Column(name: "Label", identifier: .label, width: 50),
    ]

    for columnInfo in columns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      tableView.addTableColumn(column)
    }

    let safeAreas = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
    ])

    elementsController.bind(.contentArray, to: self, withKeyPath: "stackTrace", options: nil)
    tableView.bind(.content, to: elementsController, withKeyPath: "arrangedObjects", options: nil)
    tableView.bind(.selectionIndexes, to: elementsController, withKeyPath:"selectionIndexes", options: nil)
    tableView.bind(.sortDescriptors, to: elementsController, withKeyPath: "sortDescriptors", options: nil)
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let document = projectDocument else {
      return
    }
    document.emulationObservers.append(self)
  }
}

extension CallStackViewController: EmulationObservers {
  func emulationDidAdvance() {}

  func emulationDidStart() {}

  func emulationDidStop() {
    guard let document = projectDocument else {
      return
    }

    let gb = document.sameboy.gb.pointee

    let current = CallStack(address: document.address, bank: document.bank, label: "")
    let stack = [current] + (0..<gb.backtrace_size).map { i -> CallStack in
      var bank: UInt16 = 0
      var address: UInt16 = 0
      gb_get_backtrace_return(document.sameboy.gb, Int32(i), &bank, &address)
      return CallStack(address: address, bank: Gameboy.Cartridge.Bank(truncatingIfNeeded: bank), label: "")
    }.reversed()
    if let disassembly = document.disassemblyResults?.disassembly {
      stackTrace = stack.map {
        let scopes = disassembly.labeledContiguousScopes(at: $0.address, in: max(1, $0.bank))
        if scopes.isEmpty {
          // Let's look for the closest label then.
          return $0
        }
        let scopeNames = scopes.map { $0.label }.sorted().joined(separator: ", ")
        return CallStack(address: $0.address, bank: $0.bank, label: scopeNames)
      }
    } else {
      stackTrace = stack
    }
  }
}

extension CallStackViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let tableColumn = tableColumn else {
      preconditionFailure()
    }
    let view: NSTableCellView

    switch tableColumn.identifier {
    case .label:
      let identifier = NSUserInterfaceItemIdentifier.textCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
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
    case .bank:
      let identifier = NSUserInterfaceItemIdentifier.numberCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = UInt8HexFormatter()
      }
    default:
      preconditionFailure()
    }

    view.textField?.isEditable = false
    view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)

    return view
  }
}
