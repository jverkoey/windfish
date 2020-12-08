//
//  TableViewEditorViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/7/20.
//

import Foundation

extension NSUserInterfaceItemIdentifier {
  static let type = NSUserInterfaceItemIdentifier("regionType")
  static let name = NSUserInterfaceItemIdentifier("name")
  static let bank = NSUserInterfaceItemIdentifier("bank")
  static let address = NSUserInterfaceItemIdentifier("address")
  static let length = NSUserInterfaceItemIdentifier("length")

  static let typeCell = NSUserInterfaceItemIdentifier("typeCell")
  static let textCell = NSUserInterfaceItemIdentifier("textCell")
  static let numberCell = NSUserInterfaceItemIdentifier("numberCell")
  static let addressCell = NSUserInterfaceItemIdentifier("addressCell")
}

class TableViewEditorViewController: NSViewController {
  let regionController = NSArrayController()
  private var stashedTextFieldValue: String?
  private var selectionObserver: NSKeyValueObservation?
  var textEditActionName = "Edit"
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
    containerView.documentView = tableView
    view.addSubview(containerView)
    self.tableView = tableView

    let tableControls = NSSegmentedControl()
    tableControls.translatesAutoresizingMaskIntoConstraints = false
    tableControls.trackingMode = .momentary
    tableControls.segmentStyle = .smallSquare
    tableControls.segmentCount = 2
    tableControls.setImage(NSImage(imageLiteralResourceName: NSImage.addTemplateName), forSegment: 0)
    tableControls.setImage(NSImage(imageLiteralResourceName: NSImage.removeTemplateName), forSegment: 1)
    tableControls.setWidth(40, forSegment: 0)
    tableControls.setWidth(40, forSegment: 1)
    tableControls.setEnabled(true, forSegment: 0)
    tableControls.setEnabled(false, forSegment: 1)
    tableControls.target = self
    tableControls.action = #selector(performTableControlAction(_:))
    view.addSubview(tableControls)

    let safeAreas = view.safeAreaLayoutGuide

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: tableControls.topAnchor),

      tableControls.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      tableControls.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
      tableControls.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
    ])

    selectionObserver = regionController.observe(\.selectedObjects, options: []) { (controller, change) in
      tableControls.setEnabled(controller.selectedObjects.count > 0, forSegment: 1)
    }

    tableView.bind(.content, to: regionController, withKeyPath: "arrangedObjects", options: nil)
    tableView.bind(.selectionIndexes, to: regionController, withKeyPath:"selectionIndexes", options: nil)
    tableView.bind(.sortDescriptors, to: regionController, withKeyPath: "sortDescriptors", options: nil)
  }

  @objc func performTableControlAction(_ sender: NSSegmentedControl) {
    applyChangeToRegions {
      if sender.selectedSegment == 0 {
        return self.createElement()
      } else if sender.selectedSegment == 1 {
        return self.deleteSelectedElements()
      } else {
        preconditionFailure()
      }
    }
  }

  func createElement() -> String {
    preconditionFailure()
  }

  func deleteSelectedElements() -> String {
    preconditionFailure()
  }

  func stashElements() -> Any {
    preconditionFailure()
  }

  func restoreElements(_ elements: Any) {
    preconditionFailure()
  }

  func applyChangeToRegions(_ action: () -> String) {
    let original = stashElements()
    let undoName = action()
    undoManager?.registerUndo(withTarget: self, handler: { controller in
      controller.undoChangeToRegions {
        controller.restoreElements(original)
        return undoName
      }
    })
    undoManager?.setActionName(undoName)
  }

  func undoChangeToRegions(_ action: () -> String) {
    let original = stashElements()
    let undoName = action()
    undoManager?.registerUndo(withTarget: self, handler: { controller in
      controller.applyChangeToRegions {
        controller.restoreElements(original)
        return undoName
      }
    })
    undoManager?.setActionName(undoName)
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
