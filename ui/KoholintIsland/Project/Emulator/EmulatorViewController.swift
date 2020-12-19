import Foundation
import Cocoa

import LR35902

extension NSUserInterfaceItemIdentifier {
  static let register = NSUserInterfaceItemIdentifier("name")
  static let registerState = NSUserInterfaceItemIdentifier("state")
  static let registerValue = NSUserInterfaceItemIdentifier("value")
}

private final class CPURegister: NSObject {
  init(name: String, state: String, value: String) {
    self.name = name
    self.state = state
    self.value = value
  }

  @objc dynamic var name: String
  @objc dynamic var state: String
  @objc dynamic var value: String
}

final class EmulatorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "cpu", accessibilityDescription: nil)!

  let cpuController = NSArrayController()
  var tableView: NSTableView?

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
      CPURegister(name: "a", state: "Unknown", value: ""),
      CPURegister(name: "b", state: "Unknown", value: ""),
      CPURegister(name: "c", state: "Unknown", value: ""),
      CPURegister(name: "d", state: "Unknown", value: ""),
      CPURegister(name: "e", state: "Unknown", value: ""),
      CPURegister(name: "h", state: "Unknown", value: ""),
      CPURegister(name: "l", state: "Unknown", value: ""),
    ])
    cpuController.setSelectionIndexes(IndexSet())

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
    case .register, .registerState, .registerValue:
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
    default:
      preconditionFailure()
    }
  }
}
