import Foundation

import Cocoa

final class RegisterView<T: BinaryInteger>: NSView {
  let label = CreateLabel()
  let textField = FixedWidthTextView()
  let columnLayoutGuide = NSLayoutGuide()

  init(formatter: Formatter? = UInt8HexFormatter(), longestValue: String = "0xFF") {
    super.init(frame: .zero)

    let monospacedFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)

    label.font = monospacedFont

    textField.font = monospacedFont
    textField.formatter = formatter
    textField.isEditable = false // TODO: Allow editing.
    textField.objectValue = 0

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
      textField.widthAnchor.constraint(equalToConstant: NSString(string: longestValue).size(withAttributes: [.font: textField.font!]).width + 10),
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

  var value: T {
    set {
      if newValue != _value {
        textField.objectValue = newValue
        _value = newValue
      }
    }
    get { return _value }
  }
  var _value: T = 0
}
