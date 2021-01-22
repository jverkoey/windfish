import AppKit
import Foundation
import Cocoa

final class InspectorEditorViewController: TabViewController, TabSelectable {
  let deselectedTabImage = NSImage(systemSymbolNameOrImageName: "pencil.circle", accessibilityDescription: "Inspector")!
  let selectedTabImage = NSImage(systemSymbolNameOrImageName: "pencil.circle.fill", accessibilityDescription: "Inspector")!
}

final class InspectorViewController: NSViewController {
  let project: Project
  let tabViewController = TabViewController()

  init(project: Project) {
    self.project = project

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var regionInspectorViewController: RegionInspectorViewController {
    return tabViewController.tabViewController.tabViewItems[1].viewController as! RegionInspectorViewController
  }

  var regionEditorViewController: RegionEditorViewController {
    return (tabViewController.tabViewController.tabViewItems[0].viewController as! TabViewController).tabViewController.tabViewItems[0].viewController as! RegionEditorViewController
  }

  override func loadView() {
    view = NSView()

    tabViewController.view.translatesAutoresizingMaskIntoConstraints = false

    let editorTabViewController = InspectorEditorViewController()
    editorTabViewController.tabViewController.addTabViewItem(NSTabViewItem(viewController: RegionEditorViewController(project: project)))
    editorTabViewController.tabViewController.addTabViewItem(NSTabViewItem(viewController: DataTypeEditorViewController(project: project)))
    editorTabViewController.tabViewController.addTabViewItem(NSTabViewItem(viewController: GlobalEditorViewController(project: project)))
    editorTabViewController.tabViewController.addTabViewItem(NSTabViewItem(viewController: MacroEditorViewController(project: project)))
    editorTabViewController.tabViewController.addTabViewItem(NSTabViewItem(viewController: ScriptEditorViewController(project: project)))
    tabViewController.tabViewController.addTabViewItem(NSTabViewItem(viewController: editorTabViewController))
    tabViewController.tabViewController.addTabViewItem(NSTabViewItem(viewController: RegionInspectorViewController(project: project)))

    addChild(tabViewController)
    view.addSubview(tabViewController.view)

    tabViewController.setUp()
    editorTabViewController.setUp()

    let safeAreas: ViewOrLayoutGuide
    if #available(OSX 11.0, *) {
      safeAreas = view.safeAreaLayoutGuide
    } else {
      safeAreas = view
    }

    NSLayoutConstraint.activate([
      tabViewController.view.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      tabViewController.view.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
      tabViewController.view.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      tabViewController.view.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
    ])
  }
}
