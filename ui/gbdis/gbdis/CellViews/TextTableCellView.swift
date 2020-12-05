//
//  TextTableCellView.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation
import Cocoa

final class TextTableCellView: NSTableCellView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    let textField = NSTextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.isBordered = false
    textField.drawsBackground = false // Required for text color to be set correctly.
    addSubview(textField)

    self.textField = textField

    NSLayoutConstraint.activate([
      textField.leadingAnchor.constraint(equalTo: leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: trailingAnchor),
      textField.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
