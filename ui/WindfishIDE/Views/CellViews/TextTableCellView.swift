import AppKit
import Foundation
import Cocoa

final class TextTableCellView: NSTableCellView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    let textField = NSTextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.isBordered = false
    textField.drawsBackground = false // Required for text color to be set correctly.
    textField.lineBreakMode = .byTruncatingTail
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

final class TypeTableCellView: NSTableCellView {
  let popupButton = NSPopUpButton()
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    popupButton.isBordered = false
    popupButton.translatesAutoresizingMaskIntoConstraints = false
    addSubview(popupButton)

    NSLayoutConstraint.activate([
      popupButton.leadingAnchor.constraint(equalTo: leadingAnchor),
      popupButton.trailingAnchor.constraint(equalTo: trailingAnchor),
      popupButton.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
