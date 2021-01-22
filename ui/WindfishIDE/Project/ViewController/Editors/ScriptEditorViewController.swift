import AppKit
import Foundation
import Cocoa

import Windfish

final class ScriptEditorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolNameOrImageName: "curlybraces.square", accessibilityDescription: "Scripts")!
  let selectedTabImage = NSImage(systemSymbolNameOrImageName: "curlybraces.square.fill", accessibilityDescription: "Scripts")!

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

    elementsController.bind(.contentArray, to: project.configuration, withKeyPath: "scripts", options: nil)
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

extension ScriptEditorViewController: EditorTableViewDelegate {
  func editorTableViewCreateElement(_ tableView: EditorTableView) -> String {
    project.configuration.scripts.append(
      Script(name: "newscript", source: """
// Custom JavaScript integration
""")
    )
    return "Create Script"
  }

  func editorTableViewDeleteSelectedElements(_ tableView: EditorTableView) -> String {
    project.configuration.scripts.removeAll { dataType in
      elementsController.selectedObjects.contains { $0 as! Script === dataType }
    }
    return "Delete Script"
  }

  func editorTableViewStashElements(_ tableView: EditorTableView) -> Any {
    return project.configuration.scripts
  }

  func editorTableView(_ tableView: EditorTableView, restoreElements elements: Any) {
    project.configuration.scripts = elements as! [Script]
  }
}

extension ScriptEditorViewController: NSTableViewDelegate {
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
