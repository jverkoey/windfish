import Foundation
import Cocoa

import Windfish

final class PPURegistersView: NSView {
  let modeView = LabeledView(longestWord: "searchingOAM")
  let statFlagsView = STATFlagsView()
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    modeView.name = "mode:"
    modeView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(modeView)

    statFlagsView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(statFlagsView)

    NSLayoutConstraint.activate([
      modeView.leadingAnchor.constraint(equalTo: leadingAnchor),
      statFlagsView.leadingAnchor.constraint(equalTo: leadingAnchor),
      modeView.trailingAnchor.constraint(equalTo: trailingAnchor),
      statFlagsView.trailingAnchor.constraint(equalTo: trailingAnchor),

      modeView.topAnchor.constraint(equalTo: topAnchor),
      statFlagsView.topAnchor.constraint(equalTo: modeView.bottomAnchor),
      statFlagsView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(with ppu: PPU) {
    switch ppu.registers.lcdMode {
    case .hblank:         modeView.value = "hblank"
    case .vblank:         modeView.value = "vblank"
    case .pixelTransfer:  modeView.value = "pixelTransfer"
    case .searchingOAM:   modeView.value = "searchingOAM"
    }
    statFlagsView.update(with: ppu)
  }
}
