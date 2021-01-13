import AppKit
import Foundation
import Cocoa

import Windfish

final class STATFlagsView: NSView {
  let coincidenceInterruptLabel = CreateLabel()
  let oamInterruptLabel = CreateLabel()
  let vblankInterruptLabel = CreateLabel()
  let hblankInterruptLabel = CreateLabel()
  let coincidenceLabel = CreateLabel()
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    coincidenceInterruptLabel.stringValue = "coincidence"
    oamInterruptLabel.stringValue         = "OAM"
    vblankInterruptLabel.stringValue      = "vblank"
    hblankInterruptLabel.stringValue      = "hblank"
    coincidenceLabel.stringValue          = "ly==lyc"
    for view in [coincidenceInterruptLabel, oamInterruptLabel, vblankInterruptLabel, hblankInterruptLabel, coincidenceLabel] {
      view.font = .systemFont(ofSize: 9, weight: .regular)
      view.translatesAutoresizingMaskIntoConstraints = false
      addSubview(view)
    }

    NSLayoutConstraint.activate([
      coincidenceInterruptLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      oamInterruptLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      vblankInterruptLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      hblankInterruptLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      coincidenceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),

      coincidenceInterruptLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      oamInterruptLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      vblankInterruptLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      hblankInterruptLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      coincidenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

      coincidenceInterruptLabel.topAnchor.constraint(equalTo: topAnchor),
      oamInterruptLabel.topAnchor.constraint(equalTo: coincidenceInterruptLabel.bottomAnchor),
      vblankInterruptLabel.topAnchor.constraint(equalTo: oamInterruptLabel.bottomAnchor),
      hblankInterruptLabel.topAnchor.constraint(equalTo: vblankInterruptLabel.bottomAnchor),
      coincidenceLabel.topAnchor.constraint(equalTo: hblankInterruptLabel.bottomAnchor),
      coincidenceLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(with ppu: PPU) {
    coincidenceInterruptLabel.textColor = ppu.registers.enableCoincidenceInterrupt ? .textColor : .disabledControlTextColor
    oamInterruptLabel.textColor = ppu.registers.enableOAMInterrupt ? .textColor : .disabledControlTextColor
    vblankInterruptLabel.textColor = ppu.registers.enableVBlankInterrupt ? .textColor : .disabledControlTextColor
    hblankInterruptLabel.textColor = ppu.registers.enableHBlankInterrupt ? .textColor : .disabledControlTextColor
    coincidenceLabel.textColor = ppu.registers.coincidence ? .textColor : .disabledControlTextColor
  }
}
