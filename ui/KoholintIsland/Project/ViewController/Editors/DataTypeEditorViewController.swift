//
//  RegionInspectorViewController.swiftui
//
//  Created by Jeff Verkoeyen on 12/3/20.
//

import Foundation
import Cocoa
import Windfish

extension NSUserInterfaceItemIdentifier {
  static let representation = NSUserInterfaceItemIdentifier("representation")
  static let interpretation = NSUserInterfaceItemIdentifier("interpretation")
  static let value = NSUserInterfaceItemIdentifier("value")
}

final class DataTypeEditorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "number.circle", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "number.circle.fill", accessibilityDescription: nil)!

  let document: ProjectDocument
  let elementsController = NSArrayController()
  var tableView: EditorTableView?
  let representationController = NSArrayController()
  let interpretationController = NSArrayController()
  private var selectionObserver: NSKeyValueObservation?

  let mappingElementsController = NSArrayController()
  var mappingTableView: EditorTableView?

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)

    representationController.addObject(DataType.Representation.decimal)
    representationController.addObject(DataType.Representation.hexadecimal)
    representationController.addObject(DataType.Representation.binary)

    interpretationController.addObject(DataType.Interpretation.any)
    interpretationController.addObject(DataType.Interpretation.bitmask)
    interpretationController.addObject(DataType.Interpretation.enumerated)
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
      Column(name: "Name", identifier: .name, width: 180),
      Column(name: "Representation", identifier: .representation, width: 100),
      Column(name: "Interpretation", identifier: .interpretation, width: 120),
    ]

    for columnInfo in columns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      tableView.tableView?.addTableColumn(column)
    }

    let mappingTableView = EditorTableView(elementsController: mappingElementsController)
    mappingTableView.translatesAutoresizingMaskIntoConstraints = false
    mappingTableView.delegate = self
    mappingTableView.tableView?.delegate = self
    view.addSubview(mappingTableView)
    self.mappingTableView = mappingTableView

    let mappingColumns = [
      Column(name: "Name", identifier: .name, width: 180),
      Column(name: "Value", identifier: .value, width: 100),
    ]
    for columnInfo in mappingColumns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      mappingTableView.tableView?.addTableColumn(column)
    }

    let safeAreas = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: safeAreas.topAnchor),

      tableView.bottomAnchor.constraint(equalTo: mappingTableView.topAnchor),

      mappingTableView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      mappingTableView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      mappingTableView.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
      mappingTableView.heightAnchor.constraint(equalToConstant: 200)
    ])

    elementsController.bind(.contentArray, to: document.configuration, withKeyPath: "dataTypes", options: nil)
    tableView.tableView?.bind(.content, to: elementsController, withKeyPath: "arrangedObjects", options: nil)
    tableView.tableView?.bind(.selectionIndexes, to: elementsController, withKeyPath:"selectionIndexes", options: nil)
    tableView.tableView?.bind(.sortDescriptors, to: elementsController, withKeyPath: "sortDescriptors", options: nil)

    selectionObserver = elementsController.observe(\.selectedObjects, options: []) { (controller, change) in
      if let selectedObject = controller.selectedObjects.first {
        self.mappingElementsController.bind(.contentArray, to: selectedObject, withKeyPath: "mappings", options: nil)
      } else {
        self.mappingElementsController.unbind(.contentArray)
      }
    }
    mappingTableView.tableView?.bind(.content, to: mappingElementsController, withKeyPath: "arrangedObjects", options: nil)
    mappingTableView.tableView?.bind(.selectionIndexes, to: mappingElementsController, withKeyPath:"selectionIndexes", options: nil)
    mappingTableView.tableView?.bind(.sortDescriptors, to: mappingElementsController, withKeyPath: "sortDescriptors", options: nil)

    elementsController.setSelectionIndexes(IndexSet())
  }
}

extension DataTypeEditorViewController: EditorTableViewDelegate {
  func editorTableViewCreateElement(_ tableView: EditorTableView) -> String {
    if tableView == self.tableView {
      document.configuration.dataTypes.append(
        DataType(name: "New data type", representation: DataType.Representation.decimal, interpretation: DataType.Interpretation.any, mappings: [])
      )
      return "Create Data Type"
    } else if tableView == self.mappingTableView {
      guard let selectedObject = elementsController.selectedObjects.first as? DataType else {
        preconditionFailure()
      }
      selectedObject.mappings.append(DataType.Mapping(name: "Variable", value: 1))
      return "Create Data Type Mapping"
    }
    preconditionFailure()
  }

  func editorTableViewDeleteSelectedElements(_ tableView: EditorTableView) -> String {
    if tableView == self.tableView {
      document.configuration.dataTypes.removeAll { dataType in
        elementsController.selectedObjects.contains { $0 as! DataType === dataType }
      }
      return "Delete Data Type"
    } else if tableView == self.mappingTableView {
      guard let selectedObject = elementsController.selectedObjects.first as? DataType else {
        preconditionFailure()
      }
      selectedObject.mappings.removeAll { mapping in
        mappingElementsController.selectedObjects.contains { $0 as! DataType.Mapping === mapping }
      }
      return "Delete Data Type Mapping"
    }
    preconditionFailure()
  }

  func editorTableViewStashElements(_ tableView: EditorTableView) -> Any {
    if tableView == self.tableView {
      return document.configuration.dataTypes
    } else if tableView == self.mappingTableView {
      return self.mappingElementsController.content!
    }
    preconditionFailure()
  }

  func editorTableView(_ tableView: EditorTableView, restoreElements elements: Any) {
    if tableView == self.tableView {
      document.configuration.dataTypes = elements as! [DataType]
      return
    } else if tableView == self.mappingTableView {
      self.mappingElementsController.content = elements
      return
    }
    preconditionFailure()
  }
}

extension DataTypeEditorViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let tableColumn = tableColumn else {
      preconditionFailure()
    }

    switch tableColumn.identifier {
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
    case .representation:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      let view: TypeTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        view = TypeTableCellView()
        view.identifier = identifier
      }
      view.popupButton.bind(.content, to: representationController, withKeyPath: "arrangedObjects", options: nil)
      view.popupButton.bind(.selectedObject, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    case .interpretation:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      let view: TypeTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        view = TypeTableCellView()
        view.identifier = identifier
      }
      view.popupButton.bind(.content, to: interpretationController, withKeyPath: "arrangedObjects", options: nil)
      view.popupButton.bind(.selectedObject, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    case .value:
      let identifier = NSUserInterfaceItemIdentifier.numberCell
      let view: TextTableCellView
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
      }

      if let selectedObject = elementsController.selectedObjects.first as? DataType {
        if selectedObject.representation == DataType.Representation.hexadecimal {
          view.textField?.formatter = UInt8HexFormatter()
        } else if selectedObject.representation == DataType.Representation.binary {
          view.textField?.formatter = UInt8BinaryFormatter()
        } else {
          view.textField?.formatter = NumberFormatter()
        }
      }

      view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
      return view
    default:
      preconditionFailure()
    }
  }
}
