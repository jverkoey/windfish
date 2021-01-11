import Foundation
import Cocoa

import Windfish

final class PPURegistersView: NSView {
  let modeView = LabeledView(longestWord: "searchingOAM")
  let statFlagsView = STATFlagsView()
  let lyView = RegisterView<UInt8>(formatter: nil, longestValue: "000")
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    modeView.name = "mode:"
    lyView.name = "ly:"

    for view in [modeView, statFlagsView, lyView] {
      view.translatesAutoresizingMaskIntoConstraints = false
      addSubview(view)
    }

    NSLayoutConstraint.activate([
      modeView.leadingAnchor.constraint(equalTo: leadingAnchor),
      statFlagsView.leadingAnchor.constraint(equalTo: leadingAnchor),
      lyView.leadingAnchor.constraint(equalTo: leadingAnchor),

      modeView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
      statFlagsView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
      lyView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

      modeView.topAnchor.constraint(equalTo: topAnchor),
      statFlagsView.topAnchor.constraint(equalTo: modeView.bottomAnchor),
      lyView.topAnchor.constraint(equalTo: statFlagsView.bottomAnchor),
      lyView.bottomAnchor.constraint(equalTo: bottomAnchor),
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
    lyView.value = ppu.registers.ly
  }
}
