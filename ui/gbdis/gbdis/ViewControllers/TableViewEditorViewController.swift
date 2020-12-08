//
//  TableViewEditorViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/7/20.
//

import Foundation

extension NSUserInterfaceItemIdentifier {
  static let typeCell = NSUserInterfaceItemIdentifier("typeCell")
  static let textCell = NSUserInterfaceItemIdentifier("textCell")
  static let numberCell = NSUserInterfaceItemIdentifier("numberCell")
  static let addressCell = NSUserInterfaceItemIdentifier("addressCell")
}

class TableViewEditorViewController: NSViewController {
  let elementsController = NSArrayController()
  private var stashedTextFieldValue: String?
  var textEditActionName = "Edit"
  var tableView: EditorTableView?

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  override func loadView() {
    view = NSView()

    let tableView = EditorTableView(elementsController: elementsController)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    self.tableView = tableView

    let safeAreas = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
    ])

    tableView.tableView?.bind(.content, to: elementsController, withKeyPath: "arrangedObjects", options: nil)
    tableView.tableView?.bind(.selectionIndexes, to: elementsController, withKeyPath:"selectionIndexes", options: nil)
    tableView.tableView?.bind(.sortDescriptors, to: elementsController, withKeyPath: "sortDescriptors", options: nil)
  }
}

extension TableViewEditorViewController: NSTextFieldDelegate {
  func controlTextDidBeginEditing(_ obj: Notification) {
    guard let textField = obj.object as? NSTextField else {
      preconditionFailure()
    }
    stashedTextFieldValue = textField.stringValue
  }

  func controlTextDidEndEditing(_ obj: Notification) {
    guard let textField = obj.object as? NSTextField else {
      preconditionFailure()
    }

    if let stashedTextFieldValue = stashedTextFieldValue,
       stashedTextFieldValue != textField.stringValue {
      // TODO: This needs to be provided the textField's mapped object rather than the text field itself.
      // May need to set up KVO on the object value rather than listening to the text field event.
      registerUndoForTextEdit(textField: textField, originalValue: stashedTextFieldValue)
    }
  }

  func registerUndoForTextEdit(textField: NSTextField, originalValue: String) {
    undoManager?.registerUndo(withTarget: self, handler: { controller in
      let redoValue = textField.stringValue
      textField.stringValue = originalValue
      controller.registerRedoForTextEdit(textField: textField, newValue: redoValue)
    })
    undoManager?.setActionName(textEditActionName)
  }

  func registerRedoForTextEdit(textField: NSTextField, newValue: String) {
    undoManager?.registerUndo(withTarget: self, handler: { controller in
      let redoValue = textField.stringValue
      textField.stringValue = newValue
      controller.registerUndoForTextEdit(textField: textField, originalValue: redoValue)
    })
    undoManager?.setActionName(textEditActionName)
  }
}
