import AppKit
import Foundation
import Cocoa

import Windfish

extension NSUserInterfaceItemIdentifier {
  static let typeCell = NSUserInterfaceItemIdentifier("typeCell")
  static let textCell = NSUserInterfaceItemIdentifier("textCell")
  static let numberCell = NSUserInterfaceItemIdentifier("numberCell")
  static let addressCell = NSUserInterfaceItemIdentifier("addressCell")
  static let bankCell = NSUserInterfaceItemIdentifier("bankCell")
}

extension NSUserInterfaceItemIdentifier {
  static let type = NSUserInterfaceItemIdentifier("regionType")
  static let name = NSUserInterfaceItemIdentifier("name")
  static let bank = NSUserInterfaceItemIdentifier("bank")
  static let address = NSUserInterfaceItemIdentifier("address")
  static let length = NSUserInterfaceItemIdentifier("length")
}

final class RegionEditorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolNameOrImageName: "book", accessibilityDescription: "Region editor")!
  let selectedTabImage = NSImage(systemSymbolNameOrImageName: "book.fill", accessibilityDescription: "Region editor")!

  let project: Project
  let elementsController = NSArrayController()
  var tableView: EditorTableView?
  let regionTypeController = NSArrayController()

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  init(project: Project) {
    self.project = project

    super.init(nibName: nil, bundle: nil)

    regionTypeController.addObject(Region.Kind.region)
    regionTypeController.addObject(Region.Kind.label)
    regionTypeController.addObject(Region.Kind.function)
    regionTypeController.addObject(Region.Kind.string)
    regionTypeController.addObject(Region.Kind.data)
    regionTypeController.addObject(Region.Kind.image1bpp)
    regionTypeController.addObject(Region.Kind.image2bpp)
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
    tableView.tableView?.target = self
    tableView.tableView?.doubleAction = #selector(didDoubleTap(_:))
    view.addSubview(tableView)
    self.tableView = tableView

    let columns = [
      Column(name: "Type", identifier: .type, width: 100),
      Column(name: "Name", identifier: .name, width: 120),
      Column(name: "Bank", identifier: .bank, width: 35),
      Column(name: "Address", identifier: .address, width: 50),
      Column(name: "Size", identifier: .length, width: 35),
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

    let contextMenu = NSMenu()
    contextMenu.addItem(withTitle: "Set breakpoint...", action: #selector(setBreakpoint(_:)), keyEquivalent: "")
    tableView.tableView?.menu = contextMenu

    
    let safeAreas: ViewOrLayoutGuide
    if #available(OSX 11.0, *) {
      safeAreas = view.safeAreaLayoutGuide
    } else {
      safeAreas = view
    }
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
    ])

    elementsController.sortDescriptors = [
      NSSortDescriptor(key: NSUserInterfaceItemIdentifier.bank.rawValue, ascending: true),
      NSSortDescriptor(key: NSUserInterfaceItemIdentifier.address.rawValue, ascending: true),
    ]

    elementsController.bind(.contentArray, to: project.configuration, withKeyPath: "regions", options: nil)
    tableView.tableView?.bind(.content, to: elementsController, withKeyPath: "arrangedObjects", options: nil)
    tableView.tableView?.bind(.selectionIndexes, to: elementsController, withKeyPath:"selectionIndexes", options: nil)
    tableView.tableView?.bind(.sortDescriptors, to: elementsController, withKeyPath: "sortDescriptors", options: nil)
  }

  @objc func setBreakpoint(_ sender: Any?) {
    guard let region = elementsController.selectedObjects.first as? Region else {
      return
    }
    project.nextDebuggerCommand = "breakpoint $\(((region.address < 0x4000) ? 0 : region.bank).hexString):$\(region.address.hexString)"
    project.sameboyDebuggerSemaphore.signal()
  }

  @objc func didDoubleTap(_ sender: Any?) {
    guard let region = elementsController.selectedObjects.first as? Region else {
      return
    }
    NotificationCenter.default.post(name: .selectedRegionDidChange, object: project, userInfo: ["selectedRegion": region])
  }
}

extension RegionEditorViewController: EditorTableViewDelegate {
  func editorTableViewCreateElement(_ tableView: EditorTableView) -> String {
    project.configuration.regions.append(
      Region(regionType: Region.Kind.label, name: "New region", bank: 0, address: 0, length: 0)
    )
    return "Create Region"
  }

  func editorTableViewDeleteSelectedElements(_ tableView: EditorTableView) -> String {
    project.configuration.regions.removeAll { region in
      elementsController.selectedObjects.contains { $0 as! Region === region }
    }
    return "Delete Region"
  }

  func editorTableViewStashElements(_ tableView: EditorTableView) -> Any {
    return project.configuration.regions
  }

  func editorTableView(_ tableView: EditorTableView, restoreElements elements: Any) {
    project.configuration.regions = elements as! [Region]
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
      }
      view.popupButton.bind(.content, to: regionTypeController, withKeyPath: "arrangedObjects", options: nil)
      view.popupButton.bind(.selectedObject, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
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
    case .bank:
      let identifier = NSUserInterfaceItemIdentifier.bankCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = UInt8HexFormatter()
      }
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
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
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
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
      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    default:
      preconditionFailure()
    }
  }
}
