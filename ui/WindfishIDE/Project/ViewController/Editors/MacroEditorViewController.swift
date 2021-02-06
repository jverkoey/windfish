import AppKit
import Foundation
import Cocoa

import Windfish

final class TextViewStringTransformer: ValueTransformer {
  override class func transformedValueClass() -> AnyClass {
    return NSAttributedString.self
  }

  override class func allowsReverseTransformation() -> Bool {
    return true
  }

  override func transformedValue(_ value: Any?) -> Any? {
    guard let string = value as? String else {
      return nil
    }
    return NSAttributedString(string: string, attributes: DefaultCodeAttributes())
  }

  override func reverseTransformedValue(_ value: Any?) -> Any? {
    guard let attributedString = value as? NSAttributedString else {
      return nil
    }
    return attributedString.string
  }
}

final class MacroEditorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolNameOrImageName: "chevron.left.slash.chevron.right", accessibilityDescription: "Macros")!
  let selectedTabImage = NSImage(systemSymbolNameOrImageName: "chevron.left.slash.chevron.right", accessibilityDescription: "Macros")!

  init(project: Project) {
    self.project = project

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let project: Project
  let elementsController = NSArrayController()
  var tableView: EditorTableView?
  private var selectionObserver: NSKeyValueObservation?

  var sourceContainerView: NSScrollView?
  var sourceTextView: NSTextView?

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
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
      Column(name: "Name", identifier: .name, width: 200),
    ]

    for columnInfo in columns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      tableView.tableView?.addTableColumn(column)
    }

    let containerView = CreateScrollView(bounds: view.bounds)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(containerView)

    let textView = SourceView(frame: view.bounds)
    textView.isEditable = true
    textView.allowsUndo = true
    textView.isSelectable = true
    containerView.documentView = textView

    self.sourceContainerView = containerView
    self.sourceTextView = textView

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

      tableView.bottomAnchor.constraint(equalTo: containerView.topAnchor),

      containerView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
      containerView.heightAnchor.constraint(equalToConstant: 200)
    ])

    elementsController.sortDescriptors = [
      NSSortDescriptor(key: NSUserInterfaceItemIdentifier.name.rawValue, ascending: true),
    ]

    elementsController.bind(.contentArray, to: project.configuration, withKeyPath: "macros", options: nil)
    tableView.tableView?.bind(.content, to: elementsController, withKeyPath: "arrangedObjects", options: nil)
    tableView.tableView?.bind(.selectionIndexes, to: elementsController, withKeyPath:"selectionIndexes", options: nil)
    tableView.tableView?.bind(.sortDescriptors, to: elementsController, withKeyPath: "sortDescriptors", options: nil)

    selectionObserver = elementsController.observe(\.selectedObjects, options: []) { (controller, change) in
      if let selectedObject = controller.selectedObjects.first {
        textView.bind(.attributedString, to: selectedObject, withKeyPath: "source", options: [.valueTransformer: TextViewStringTransformer()])
      } else {
        textView.unbind(.attributedString)
      }
    }

    elementsController.setSelectionIndexes(IndexSet())
  }
}

extension MacroEditorViewController: EditorTableViewDelegate {
  func editorTableViewCreateElement(_ tableView: EditorTableView) -> String {
    project.configuration.macros.append(
      Macro(name: "newmacro", source: """
; Write your macro as RGBDS assembly
; Macro args can be specified by replacing an
; instruction's operand with a # followed by the
; argument number. E.g. ld a, #1
; Arguments use 1-based indexing; there is no
; argument 0.
""")
    )
    return "Create Macro"
  }

  func editorTableViewDeleteSelectedElements(_ tableView: EditorTableView) -> String {
    project.configuration.macros.removeAll { dataType in
      elementsController.selectedObjects.contains { $0 as! Macro === dataType }
    }
    return "Delete Macro"
  }

  func editorTableViewStashElements(_ tableView: EditorTableView) -> Any {
    return project.configuration.macros
  }

  func editorTableView(_ tableView: EditorTableView, restoreElements elements: Any) {
    project.configuration.macros = elements as! [Macro]
  }
}

extension MacroEditorViewController: NSTableViewDelegate {
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
    default:
      preconditionFailure()
    }
  }
}
