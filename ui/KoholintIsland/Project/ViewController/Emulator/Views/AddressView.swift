import AppKit
import Foundation
import Cocoa

final class AddressView: NSView {
  let label = CreateLabel()
  let textField = FixedWidthTextView()
  let columnLayoutGuide = NSLayoutGuide()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    let monospacedFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)

    label.font = monospacedFont

    textField.font = monospacedFont
    textField.formatter = LR35902AddressFormatter()
    textField.isEditable = false // TODO: Allow editing.

    label.translatesAutoresizingMaskIntoConstraints = false
    textField.translatesAutoresizingMaskIntoConstraints = false

    addSubview(label)
    addSubview(textField)

    addLayoutGuide(columnLayoutGuide)

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor),
      label.trailingAnchor.constraint(equalTo: columnLayoutGuide.leadingAnchor),

      columnLayoutGuide.widthAnchor.constraint(equalToConstant: 4),

      textField.leadingAnchor.constraint(equalTo: columnLayoutGuide.trailingAnchor),
      textField.widthAnchor.constraint(equalToConstant: NSString(string: "0xFFFF").size(withAttributes: [.font: monospacedFont]).width + 10),
      textField.trailingAnchor.constraint(equalTo: trailingAnchor),

      label.firstBaselineAnchor.constraint(equalTo: textField.firstBaselineAnchor),

      textField.topAnchor.constraint(equalTo: topAnchor),
      textField.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var name: String {
    set {
      label.stringValue = newValue
    }
    get {
      return label.stringValue
    }
  }

  var value: UInt16 {
    set {
      if newValue != _value {
        textField.objectValue = newValue
        _value = newValue
      }
    }
    get { return _value }
  }
  var _value: UInt16 = 0
}
