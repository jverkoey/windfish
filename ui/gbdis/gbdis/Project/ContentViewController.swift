//
//  ContentViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation
import Cocoa

final class ContentViewController: NSViewController {
  let textField = NSTextField()
  override func loadView() {
    view = NSView()

    textField.frame = view.bounds
    textField.autoresizingMask = [.width, .height]
    textField.focusRingType = .none
    textField.isEditable = false
    view.addSubview(textField)
  }
}
