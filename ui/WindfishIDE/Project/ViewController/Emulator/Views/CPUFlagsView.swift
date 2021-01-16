import AppKit
import Foundation
import Cocoa

import Windfish

final class CPUFlagsView: NSView {
  let zeroLabel = CreateLabel()
  let subtractLabel = CreateLabel()
  let carryLabel = CreateLabel()
  let halfcarryLabel = CreateLabel()
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    zeroLabel.stringValue = "z"
    subtractLabel.stringValue = "n"
    carryLabel.stringValue = "c"
    halfcarryLabel.stringValue = "h"
    for view in [zeroLabel, subtractLabel, carryLabel, halfcarryLabel] {
      view.font = .monospacedSystemFont(ofSize: 9, weight: .regular)
      view.translatesAutoresizingMaskIntoConstraints = false
      addSubview(view)
    }

    NSLayoutConstraint.activate([
      zeroLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      subtractLabel.leadingAnchor.constraint(equalTo: leadingAnchor),

      carryLabel.leadingAnchor.constraint(equalTo: zeroLabel.trailingAnchor, constant: 2),
      halfcarryLabel.leadingAnchor.constraint(equalTo: subtractLabel.trailingAnchor, constant: 2),

      carryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      halfcarryLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

      zeroLabel.topAnchor.constraint(equalTo: topAnchor),
      carryLabel.topAnchor.constraint(equalTo: topAnchor),

      subtractLabel.topAnchor.constraint(equalTo: zeroLabel.bottomAnchor),
      halfcarryLabel.topAnchor.constraint(equalTo: carryLabel.bottomAnchor),

      subtractLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
      halfcarryLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(with emulator: Emulator) {
    let gb = emulator.gb.pointee
    let flags = Int(truncatingIfNeeded: gb.f)
    zeroLabel.textColor = (flags & GB_ZERO_FLAG) != 0 ? .textColor : .disabledControlTextColor
    subtractLabel.textColor = (flags & GB_SUBTRACT_FLAG) != 0 ? .textColor : .disabledControlTextColor
    carryLabel.textColor = (flags & GB_CARRY_FLAG) != 0 ? .textColor : .disabledControlTextColor
    halfcarryLabel.textColor = (flags & GB_HALF_CARRY_FLAG) != 0 ? .textColor : .disabledControlTextColor
  }
}
