//
//  EditorTableView.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/7/20.
//

import Foundation
import Cocoa
import Combine

protocol EditorTableViewDelegate: NSObject {
  func createElement() -> String
  func deleteSelectedElements() -> String
  func stashElements() -> Any
  func restoreElements(_ elements: Any)
}

final class EditorTableView: NSView {
  let elementsController: NSArrayController
  var tableView: NSTableView?
  weak var delegate: EditorTableViewDelegate?

  private var selectionObserver: NSKeyValueObservation?

  init(elementsController: NSArrayController) {
    self.elementsController = elementsController

    super.init(frame: NSRect())

    let containerView = NSScrollView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true

    let tableView = NSTableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.style = .fullWidth
    tableView.selectionHighlightStyle = .regular
    containerView.documentView = tableView
    addSubview(containerView)
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
    addSubview(tableControls)

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: tableControls.topAnchor),

      tableControls.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      tableControls.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      tableControls.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
    ])

    selectionObserver = elementsController.observe(\.selectedObjects, options: []) { (controller, change) in
      tableControls.setEnabled(controller.selectedObjects.count > 0, forSegment: 1)
    }

    tableView.bind(.content, to: elementsController, withKeyPath: "arrangedObjects", options: nil)
    tableView.bind(.selectionIndexes, to: elementsController, withKeyPath:"selectionIndexes", options: nil)
    tableView.bind(.sortDescriptors, to: elementsController, withKeyPath: "sortDescriptors", options: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func performTableControlAction(_ sender: NSSegmentedControl) {
    guard let delegate = delegate else {
      return
    }
    applyChangeToRegions {
      if sender.selectedSegment == 0 {
        return delegate.createElement()
      } else if sender.selectedSegment == 1 {
        return delegate.deleteSelectedElements()
      } else {
        preconditionFailure()
      }
    }
  }

  func applyChangeToRegions(_ action: () -> String) {
    guard let delegate = delegate else {
      return
    }
    let original = delegate.stashElements()
    let undoName = action()
    undoManager?.registerUndo(withTarget: self, handler: { controller in
      controller.undoChangeToRegions {
        controller.delegate?.restoreElements(original)
        return undoName
      }
    })
    undoManager?.setActionName(undoName)
  }

  func undoChangeToRegions(_ action: () -> String) {
    guard let delegate = delegate else {
      return
    }
    let original = delegate.stashElements()
    let undoName = action()
    undoManager?.registerUndo(withTarget: self, handler: { controller in
      controller.applyChangeToRegions {
        controller.delegate?.restoreElements(original)
        return undoName
      }
    })
    undoManager?.setActionName(undoName)
  }
}
