import Foundation
import Cocoa

import Windfish

final class PPURegistersView: NSView {
  let modeView = LabeledView(longestWord: "searchingOAM")
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    modeView.name = "mode:"
    modeView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(modeView)

    NSLayoutConstraint.activate([
      modeView.leadingAnchor.constraint(equalTo: leadingAnchor),
      modeView.topAnchor.constraint(equalTo: topAnchor),
      modeView.trailingAnchor.constraint(equalTo: trailingAnchor),

      modeView.topAnchor.constraint(equalTo: topAnchor),
      modeView.bottomAnchor.constraint(equalTo: bottomAnchor),
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
  }
}
