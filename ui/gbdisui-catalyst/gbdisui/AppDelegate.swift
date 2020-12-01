//
//  AppDelegate.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var windows: [UIWindow] = []

  override func buildMenu(with builder: UIMenuBuilder) {
    super.buildMenu(with: builder)

    guard builder.system == UIMenuSystem.main else { return }

    builder.remove(menu: .services)
    builder.remove(menu: .format)
//    builder.remove(menu: .toolbar)
    builder.remove(menu: .edit)
//    builder.remove(menu: .view)
//    builder.remove(menu: .window)
    builder.remove(menu: .help)

    let newProjectCommand = UIKeyCommand(
      title: "New project",
      action: #selector(newProject(_:)),
      input: "n",
      modifierFlags: [.command]
    )
    let openRomCommand = UIKeyCommand(
      title: "Open rom...",
      action: #selector(openRom(_:)),
      input: "o",
      modifierFlags: [.command]
    )
    builder.insertChild(UIMenu(title: "", options: .displayInline, children: [openRomCommand]), atStartOfMenu: .file)
    builder.insertChild(UIMenu(title: "", options: .displayInline, children: [newProjectCommand]), atStartOfMenu: .file)
  }

  @objc func newProject(_ sender: Any?) {
    createNewWindow()
    NotificationCenter.default.post(name: .newProject, object: self)
  }

  @objc func openRom(_ sender: Any?) {
    NotificationCenter.default.post(name: .openRom, object: self)
  }

  func applicationDidFinishLaunching(_ application: UIApplication) {
    createNewWindow()
  }

  func createNewWindow() {
    let window = UIWindow()

    window.rootViewController = ProjectDocumentViewController()
    window.makeKeyAndVisible()

    windows.append(window)
  }

  func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Ensure the URL is a file URL
    guard inputURL.isFileURL else { return false }

    return true
  }
}


