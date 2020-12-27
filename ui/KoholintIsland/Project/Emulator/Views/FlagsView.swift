import Foundation
import Cocoa

import Windfish

final class FlagsView: NSView {
  let label = CreateLabel()
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    label.frame = bounds
    label.autoresizingMask = [.width, .height]

    addSubview(label)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateLabel(from cpu: LR35902) {
    let text = NSMutableAttributedString(string: "Flags: ")
    let enabledAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: NSColor.textColor,
    ]
    let disabledAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: NSColor.disabledControlTextColor,
    ]
    text.append(NSAttributedString(string: "zero ", attributes: cpu.fzero ? enabledAttributes : disabledAttributes))
    text.append(NSAttributedString(string: "subtract ", attributes: cpu.fsubtract ? enabledAttributes : disabledAttributes))
    text.append(NSAttributedString(string: "carry ", attributes: cpu.fcarry ? enabledAttributes : disabledAttributes))
    text.append(NSAttributedString(string: "halfcarry ", attributes: cpu.fhalfcarry ? enabledAttributes : disabledAttributes))
    label.attributedStringValue = text
  }

  override var intrinsicContentSize: NSSize {
    return label.intrinsicContentSize
  }
}
