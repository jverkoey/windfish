//
//  DocumentViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import UIKit

class ProjectDocumentViewController: UISplitViewController {

  init() {
    super.init(style: .tripleColumn)

    let sidebarViewController = SidebarViewController()

    primaryBackgroundStyle = .sidebar
    preferredDisplayMode = .twoBesideSecondary

    setViewController(sidebarViewController, for: .primary)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var document: UIDocument?

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Access the document
    document?.open(completionHandler: { (success) in
      if success {
        // Display the content of the document, e.g.:
      } else {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
      }
    })
  }

  func dismissDocumentViewController() {
    dismiss(animated: true) {
      self.document?.close(completionHandler: nil)
    }
  }
}

