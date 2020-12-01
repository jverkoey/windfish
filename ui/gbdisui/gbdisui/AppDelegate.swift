//
//  AppDelegate.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 11/29/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  override func buildMenu(with builder: UIMenuBuilder) {
    super.buildMenu(with: builder)

    guard builder.system == UIMenuSystem.main else { return }

    let openRomCommand = UIKeyCommand(
      title: "Open rom...",
      action: #selector(openRom(_:)),
      input: "o",
      modifierFlags: [.command]
    )
    let openRomMenu = UIMenu(title: "", options: .displayInline, children: [openRomCommand])
    builder.insertChild(openRomMenu, atStartOfMenu: .file)
  }

  @objc
  func openRom(_ sender: Any?) {
    NotificationCenter.default.post(name: .openRom, object: self)
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

}


