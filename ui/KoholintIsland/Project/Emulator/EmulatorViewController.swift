import Foundation
import Cocoa

import LR35902

extension NSUserInterfaceItemIdentifier {
  static let register = NSUserInterfaceItemIdentifier("name")
  static let registerState = NSUserInterfaceItemIdentifier("state")
  static let registerValue = NSUserInterfaceItemIdentifier("value")
}

private final class CPURegister: NSObject {
  init(name: String, state: String, value: UInt16) {
    self.name = name
    self.state = state
    self.value = value
  }

  @objc dynamic var name: String
  @objc dynamic var state: String
  @objc dynamic var value: UInt16
}

final class EmulatorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!

  let cpuController = NSArrayController()
  let registerStateController = NSArrayController()
  var tableView: NSTableView?

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  override func loadView() {
    view = NSView()

    let programCounterLabel = CreateLabel()
    programCounterLabel.translatesAutoresizingMaskIntoConstraints = false
    programCounterLabel.stringValue = "Program counter:"
    programCounterLabel.alignment = .right
    view.addSubview(programCounterLabel)

    let programCounterTextField = NSTextField()
    programCounterTextField.translatesAutoresizingMaskIntoConstraints = false
    programCounterTextField.stringValue = "0x0100"
    programCounterTextField.formatter = LR35902AddressFormatter()
    view.addSubview(programCounterTextField)

    let bankLabel = CreateLabel()
    bankLabel.translatesAutoresizingMaskIntoConstraints = false
    bankLabel.stringValue = "Bank:"
    bankLabel.alignment = .right
    view.addSubview(bankLabel)

    let bankTextField = NSTextField()
    bankTextField.translatesAutoresizingMaskIntoConstraints = false
    bankTextField.stringValue = "0x00"
    bankTextField.formatter = UInt8HexFormatter()
    view.addSubview(bankTextField)

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

    let textFieldAlignmentGuide = NSLayoutGuide()
    view.addLayoutGuide(textFieldAlignmentGuide)

    let columns = [
      Column(name: "Register", identifier: .register, width: 100),
      Column(name: "State", identifier: .registerState, width: 100),
      Column(name: "Value", identifier: .registerValue, width: 50),
    ]

    for columnInfo in columns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      tableView.addTableColumn(column)
    }

    cpuController.add(contentsOf: [
      CPURegister(name: "a", state: "Unknown", value: 0),
      CPURegister(name: "b", state: "Unknown", value: 0),
      CPURegister(name: "c", state: "Unknown", value: 0),
      CPURegister(name: "d", state: "Unknown", value: 0),
      CPURegister(name: "e", state: "Unknown", value: 0),
      CPURegister(name: "h", state: "Unknown", value: 0),
      CPURegister(name: "l", state: "Unknown", value: 0),
    ])
    cpuController.setSelectionIndexes(IndexSet())

    registerStateController.addObject("Unknown")
    registerStateController.addObject("Literal")
    registerStateController.addObject("Address")

    NSLayoutConstraint.activate([
      programCounterLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      programCounterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

      bankLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
      bankLabel.topAnchor.constraint(equalTo: programCounterLabel.bottomAnchor),

      textFieldAlignmentGuide.leadingAnchor.constraint(equalTo: programCounterLabel.trailingAnchor),
      textFieldAlignmentGuide.leadingAnchor.constraint(equalTo: bankLabel.trailingAnchor),
      textFieldAlignmentGuide.widthAnchor.constraint(equalToConstant: 8),

      programCounterTextField.leadingAnchor.constraint(equalTo: textFieldAlignmentGuide.trailingAnchor),
      programCounterTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      programCounterTextField.topAnchor.constraint(equalTo: programCounterLabel.topAnchor),
      bankLabel.topAnchor.constraint(equalTo: programCounterTextField.bottomAnchor),

      bankTextField.leadingAnchor.constraint(equalTo: textFieldAlignmentGuide.trailingAnchor),
      bankTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      bankTextField.topAnchor.constraint(equalTo: bankLabel.topAnchor),

      containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      containerView.topAnchor.constraint(equalToSystemSpacingBelow: bankLabel.bottomAnchor, multiplier: 1),
      containerView.topAnchor.constraint(equalToSystemSpacingBelow: bankTextField.bottomAnchor, multiplier: 1),
      containerView.heightAnchor.constraint(equalToConstant: 200),
    ])

    tableView.bind(.content, to: cpuController, withKeyPath: "arrangedObjects", options: nil)
    tableView.bind(.selectionIndexes, to: cpuController, withKeyPath:"selectionIndexes", options: nil)
    tableView.bind(.sortDescriptors, to: cpuController, withKeyPath: "sortDescriptors", options: nil)
  }
}

extension EmulatorViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let tableColumn = tableColumn else {
      preconditionFailure()
    }

    switch tableColumn.identifier {
    case .register:
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
    case .registerState:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      let view: TypeTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        view = TypeTableCellView()
        view.identifier = identifier
      }
      view.popupButton.bind(.content, to: registerStateController, withKeyPath: "arrangedObjects", options: nil)
      view.popupButton.bind(.selectedObject, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    case .registerValue:
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
