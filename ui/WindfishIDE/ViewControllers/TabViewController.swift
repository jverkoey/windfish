import AppKit
import Foundation
import Cocoa

protocol TabSelectable {
  var deselectedTabImage: NSImage { get }
  var selectedTabImage: NSImage { get }
}

class TabViewController: NSViewController {
  let tabViewController = NSTabViewController()
  var tabButtons: [NSButton]?
  var tabPickerView: NSStackView?

  init() {
    tabViewController.view.translatesAutoresizingMaskIntoConstraints = false
    tabViewController.tabStyle = .unspecified

    super.init(nibName: nil, bundle: nil)

    addChild(tabViewController)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()

    let tabPickerView = NSStackView()
    tabPickerView.translatesAutoresizingMaskIntoConstraints = false
    tabPickerView.orientation = .horizontal
    tabPickerView.distribution = .gravityAreas
    self.tabPickerView = tabPickerView
    // TODO: Enable and make buttons wider.
    //    tabPickerView.spacing = 0

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
  }

  func setUp() {
    if !self.isViewLoaded {
      self.loadView()
    }
    guard let tabPickerView = tabPickerView else {
      preconditionFailure()
    }
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

    didSelectTab(tabButtons[0])
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
