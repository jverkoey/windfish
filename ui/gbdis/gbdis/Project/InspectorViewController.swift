//
//  EditorViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation

protocol TabSelectable {
  var deselectedTabImage: NSImage { get }
  var selectedTabImage: NSImage { get }
}

final class BankInspectorViewController: NSViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: nil)!
  let selectedTabImage = NSImage(systemSymbolName: "questionmark.circle.fill", accessibilityDescription: nil)!

  override func loadView() {
    view = NSView()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.blue.cgColor
  }
}

final class InspectorViewController: NSViewController {
  let document: ProjectDocument

  let tabViewController = NSTabViewController()
  var tabButtons: [NSButton]?

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()

    tabViewController.view.translatesAutoresizingMaskIntoConstraints = false
    tabViewController.tabStyle = .unspecified

    tabViewController.addTabViewItem(NSTabViewItem(viewController: RegionEditorViewController(document: document)))
    tabViewController.addTabViewItem(NSTabViewItem(viewController: RegionInspectorViewController(document: document)))
    tabViewController.addTabViewItem(NSTabViewItem(viewController: BankInspectorViewController()))

    addChild(tabViewController)

    let tabPickerView = NSStackView()
    tabPickerView.translatesAutoresizingMaskIntoConstraints = false
    tabPickerView.orientation = .horizontal
    tabPickerView.distribution = .gravityAreas
    // TODO: Enable and make buttons wider.
//    tabPickerView.spacing = 0

    let tabButtons: [NSButton] = tabViewController.tabViewItems.map {
      guard let tabSelectable = $0.viewController as? TabSelectable else {
        preconditionFailure()
      }
      let button = NSButton()
      button.bezelStyle = .rounded
      button.isBordered = false
      button.setButtonType(.toggle)
      button.image = tabSelectable.deselectedTabImage
      button.font = .systemFont(ofSize: 16)
      button.target = self
      button.action = #selector(didSelectTab(_:))
      return button
    }
    for button in tabButtons {
      tabPickerView.addView(button, in: .center)
    }
    self.tabButtons = tabButtons

    view.addSubview(tabPickerView)
    view.addSubview(tabViewController.view)

    let safeAreaLayoutGuide = view.safeAreaLayoutGuide

    NSLayoutConstraint.activate([
      tabPickerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      tabPickerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      tabPickerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      tabPickerView.heightAnchor.constraint(equalToConstant: 28),

      tabViewController.view.topAnchor.constraint(equalTo: tabPickerView.bottomAnchor),

      tabViewController.view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      tabViewController.view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      tabViewController.view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
    ])

    didSelectTab(self.tabButtons![0])
  }

  @objc func didSelectTab(_ sender: NSButton) {
    self.tabButtons!.filter { $0.state == .on }.forEach {
      let item = tabViewController.tabViewItems[self.tabButtons!.firstIndex(of: $0)!]
      $0.image = (item.viewController as! TabSelectable).deselectedTabImage
      $0.state = .off
    }
    sender.state = .on
    let selectedIndex = self.tabButtons!.firstIndex(of: sender)!
    let selectedItem = tabViewController.tabViewItems[selectedIndex]
    sender.image = (selectedItem.viewController as! TabSelectable).selectedTabImage

    tabViewController.selectedTabViewItemIndex = selectedIndex
  }
}
