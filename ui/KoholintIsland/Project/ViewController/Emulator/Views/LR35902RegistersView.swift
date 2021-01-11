import Foundation
import Cocoa

import Windfish

final class LR35902RegistersView: NSView {
  let pcView = AddressView()
  let spView = AddressView()
  let aView = RegisterView<UInt8>()
  let fView = RegisterView<UInt8>()
  let bView = RegisterView<UInt8>()
  let cView = RegisterView<UInt8>()
  let dView = RegisterView<UInt8>()
  let eView = RegisterView<UInt8>()
  let hView = RegisterView<UInt8>()
  let lView = RegisterView<UInt8>()
  let flagsView = CPUFlagsView()
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    pcView.name = "pc:"
    pcView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(pcView)

    spView.name = "sp:"
    spView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(spView)

    aView.name = "a:"
    aView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(aView)
    fView.name = "f:"
    fView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(fView)

    bView.name = "b:"
    bView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(bView)
    cView.name = "c:"
    cView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(cView)

    dView.name = "d:"
    dView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(dView)
    eView.name = "e:"
    eView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(eView)

    hView.name = "h:"
    hView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hView)
    lView.name = "l:"
    lView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(lView)

    flagsView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(flagsView)

    NSLayoutConstraint.activate([
      pcView.leadingAnchor.constraint(equalTo: leadingAnchor),
      pcView.topAnchor.constraint(equalTo: topAnchor),

      spView.topAnchor.constraint(equalTo: pcView.bottomAnchor),
      spView.leadingAnchor.constraint(equalTo: pcView.leadingAnchor),

      aView.leadingAnchor.constraint(equalToSystemSpacingAfter: pcView.trailingAnchor, multiplier: 1),
      fView.leadingAnchor.constraint(equalTo: aView.trailingAnchor, constant: 4),

      flagsView.leadingAnchor.constraint(equalTo: fView.trailingAnchor, constant: 4),
      flagsView.centerYAnchor.constraint(equalTo: fView.centerYAnchor),
      flagsView.trailingAnchor.constraint(equalTo: trailingAnchor),

      aView.topAnchor.constraint(equalTo: topAnchor),
      fView.topAnchor.constraint(equalTo: aView.topAnchor),

      bView.leadingAnchor.constraint(equalTo: aView.leadingAnchor),
      cView.leadingAnchor.constraint(equalTo: bView.trailingAnchor, constant: 4),

      bView.topAnchor.constraint(equalTo: aView.bottomAnchor),
      cView.topAnchor.constraint(equalTo: bView.topAnchor),

      dView.leadingAnchor.constraint(equalTo: aView.leadingAnchor),
      eView.leadingAnchor.constraint(equalTo: dView.trailingAnchor, constant: 4),

      dView.topAnchor.constraint(equalTo: bView.bottomAnchor),
      eView.topAnchor.constraint(equalTo: dView.topAnchor),

      hView.leadingAnchor.constraint(equalTo: aView.leadingAnchor),
      lView.leadingAnchor.constraint(equalTo: hView.trailingAnchor, constant: 4),

      hView.topAnchor.constraint(equalTo: dView.bottomAnchor),
      lView.topAnchor.constraint(equalTo: hView.topAnchor),

      hView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(with cpu: LR35902) {
    pcView.value = cpu.machineInstruction.sourceAddress() ?? 0x100
    spView.value = cpu.sp
    aView.value = cpu.a
    fView.value = cpu.f
    bView.value = cpu.b
    cView.value = cpu.c
    dView.value = cpu.d
    eView.value = cpu.e
    hView.value = cpu.h
    lView.value = cpu.l
    flagsView.update(with: cpu)
  }
}
