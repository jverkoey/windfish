//
//  RegionInspectorViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/3/20.
//

import Foundation
import Cocoa
import LR35902

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

final class RegionEditorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "book", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "book.fill", accessibilityDescription: nil)!

  let document: ProjectDocument
  let regionController = NSArrayController()
  private var stashedTextFieldValue: String?
  private var selectionObserver: NSKeyValueObservation?
  let regionTypeController = NSArrayController()

  private struct Column {
    let name: String
    let identifier: NSUserInterfaceItemIdentifier
    let width: CGFloat
  }

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)

    regionTypeController.addObject(Region.Kind.region)
    regionTypeController.addObject(Region.Kind.label)
    regionTypeController.addObject(Region.Kind.function)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()

    let containerView = NSScrollView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true

    let regionTableView = NSTableView()
    regionTableView.translatesAutoresizingMaskIntoConstraints = false
    regionTableView.delegate = self
    regionTableView.style = .fullWidth
    regionTableView.selectionHighlightStyle = .regular
    containerView.documentView = regionTableView
    view.addSubview(containerView)

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

    let columns = [
      Column(name: "Type", identifier: .type, width: 100),
      Column(name: "Name", identifier: .name, width: 120),
      Column(name: "Bank", identifier: .bank, width: 35),
      Column(name: "Address", identifier: .address, width: 50),
      Column(name: "Region length", identifier: .length, width: 35),
    ]

    for columnInfo in columns {
      let column = NSTableColumn(identifier: columnInfo.identifier)
      column.isEditable = false
      column.headerCell.stringValue = columnInfo.name
      column.width = columnInfo.width
      // Note: this only works for cell-based tables.
//      column.bind(.value, to: regionController, withKeyPath: "arrangedObjects.name", options: nil)
      regionTableView.addTableColumn(column)
    }

    selectionObserver = regionController.observe(\.selectedObjects, options: []) { (controller, change) in
      tableControls.setEnabled(controller.selectedObjects.count > 0, forSegment: 1)

      if let region = controller.selectedObjects.first as? Region {
        NotificationCenter.default.post(name: .selectedRegionDidChange, object: self.document, userInfo: ["selectedRegion": region])
      }
    }

    regionController.bind(.contentArray, to: document.configuration, withKeyPath: "regions", options: nil)
    regionTableView.bind(.content, to: regionController, withKeyPath: "arrangedObjects", options: nil)
    regionTableView.bind(.selectionIndexes, to: regionController, withKeyPath:"selectionIndexes", options: nil)
    regionTableView.bind(.sortDescriptors, to: regionController, withKeyPath: "sortDescriptors", options: nil)
  }

  @objc func performTableControlAction(_ sender: NSSegmentedControl) {
    applyChangeToRegions {
      if sender.selectedSegment == 0 {
        // Add
        document.configuration.regions.append(
          Region(regionType: Region.Kind.label, name: "New region", bank: 0, address: 0, length: 0)
        )
        return "Create Region"
      } else if sender.selectedSegment == 1 {
        // Remove
        document.configuration.regions.removeAll { region in
          regionController.selectedObjects.contains { $0 as! Region === region }
        }
        return "Delete Region"
      } else {
        preconditionFailure()
      }
    }
  }

  func applyChangeToRegions(_ action: () -> String) {
    let originalRegions = document.configuration.regions
    let undoName = action()
    document.undoManager?.registerUndo(withTarget: self, handler: { controller in
      controller.undoChangeToRegions {
        controller.document.configuration.regions = originalRegions
        return undoName
      }
    })
    document.undoManager?.setActionName(undoName)
  }

  func undoChangeToRegions(_ action: () -> String) {
    let originalRegions = document.configuration.regions
    let undoName = action()
    document.undoManager?.registerUndo(withTarget: self, handler: { controller in
      controller.applyChangeToRegions {
        controller.document.configuration.regions = originalRegions
        return undoName
      }
    })
    document.undoManager?.setActionName(undoName)
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
    let view: NSTableCellView

    switch tableColumn.identifier {
    case .type:
      let identifier = NSUserInterfaceItemIdentifier.typeCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TypeTableCellView {
        view = recycledView
      } else {
        let typeView = TypeTableCellView()
        typeView.identifier = identifier
        typeView.popupButton.bind(.content, to: regionTypeController, withKeyPath: "arrangedObjects", options: nil)
        typeView.popupButton.bind(.selectedObject, to: typeView, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)
        view = typeView
      }
    case .name:
      let identifier = NSUserInterfaceItemIdentifier.textCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
      }
    case .bank: fallthrough
    case .length:
      let identifier = NSUserInterfaceItemIdentifier.numberCell
      if let recycledView = tableView.makeView(withIdentifier: identifier, owner: self) as? TextTableCellView {
        view = recycledView
      } else {
        view = TextTableCellView()
        view.identifier = identifier
        view.textField?.formatter = NumberFormatter()
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
    default:
      preconditionFailure()
    }

    view.textField?.delegate = self
    view.textField?.bind(.value, to: view, withKeyPath: "objectValue.\(tableColumn.identifier.rawValue)", options: nil)

    return view
  }
}

extension RegionEditorViewController: NSTextFieldDelegate {
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
      registerUndoForRegion(textField: textField, originalValue: stashedTextFieldValue)
    }
  }

  func registerUndoForRegion(textField: NSTextField, originalValue: String) {
    document.undoManager?.registerUndo(withTarget: self, handler: { controller in
      let redoValue = textField.stringValue
      textField.stringValue = originalValue
      controller.registerRedoForRegion(textField: textField, newValue: redoValue)
    })
    document.undoManager?.setActionName("Region Edit")
  }

  func registerRedoForRegion(textField: NSTextField, newValue: String) {
    document.undoManager?.registerUndo(withTarget: self, handler: { controller in
      let redoValue = textField.stringValue
      textField.stringValue = newValue
      controller.registerUndoForRegion(textField: textField, originalValue: redoValue)
    })
    document.undoManager?.setActionName("Region Edit")
  }
}

// TODO: Surface detected labels in the region inspector; add a new column indicating whether a region is automatic or manual.
// TODO: Editing an automatic label turns it into a manaul label.
// TODO: Allow sorting of the regions.
