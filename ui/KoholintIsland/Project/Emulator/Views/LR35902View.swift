import Foundation
import Cocoa

import Windfish

final class RegisterView: NSView {
  let label = CreateLabel()
  let textField = NSTextField()
  let columnLayoutGuide = NSLayoutGuide()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    let monospacedFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)

    label.font = monospacedFont

    textField.font = monospacedFont
    textField.formatter = UInt8HexFormatter()
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
      textField.widthAnchor.constraint(equalToConstant: NSString(string: "0xFF").size(withAttributes: [.font: monospacedFont]).width + 10),
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

  var value: UInt8 {
    set {
      textField.objectValue = newValue
    }
    get {
      return textField.objectValue as! UInt8
    }
  }
}

final class AddressView: NSView {
  let label = CreateLabel()
  let textField = NSTextField()
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
      textField.objectValue = newValue
    }
    get {
      return textField.objectValue as! UInt16
    }
  }
}

final class LR35902View: NSView {
  let pcView = AddressView()
  let spView = AddressView()
  let aView = RegisterView()
  let fView = RegisterView()
  let bView = RegisterView()
  let cView = RegisterView()
  let dView = RegisterView()
  let eView = RegisterView()
  let hView = RegisterView()
  let lView = RegisterView()
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

    NSLayoutConstraint.activate([
      pcView.leadingAnchor.constraint(equalTo: leadingAnchor),
      pcView.topAnchor.constraint(equalTo: topAnchor),

      spView.topAnchor.constraint(equalTo: pcView.bottomAnchor),
      spView.leadingAnchor.constraint(equalTo: pcView.leadingAnchor),

      aView.leadingAnchor.constraint(equalToSystemSpacingAfter: pcView.trailingAnchor, multiplier: 1),
      fView.leadingAnchor.constraint(equalTo: aView.trailingAnchor, constant: 4),
      fView.trailingAnchor.constraint(equalTo: trailingAnchor),

      aView.topAnchor.constraint(equalTo: topAnchor),
      fView.topAnchor.constraint(equalTo: aView.topAnchor),

      bView.leadingAnchor.constraint(equalTo: aView.leadingAnchor),
      cView.leadingAnchor.constraint(equalTo: bView.trailingAnchor, constant: 4),
      cView.trailingAnchor.constraint(equalTo: trailingAnchor),

      bView.topAnchor.constraint(equalTo: aView.bottomAnchor),
      cView.topAnchor.constraint(equalTo: bView.topAnchor),

      dView.leadingAnchor.constraint(equalTo: aView.leadingAnchor),
      eView.leadingAnchor.constraint(equalTo: dView.trailingAnchor, constant: 4),
      eView.trailingAnchor.constraint(equalTo: trailingAnchor),

      dView.topAnchor.constraint(equalTo: bView.bottomAnchor),
      eView.topAnchor.constraint(equalTo: dView.topAnchor),

      hView.leadingAnchor.constraint(equalTo: aView.leadingAnchor),
      lView.leadingAnchor.constraint(equalTo: hView.trailingAnchor, constant: 4),
      lView.trailingAnchor.constraint(equalTo: trailingAnchor),

      hView.topAnchor.constraint(equalTo: dView.bottomAnchor),
      lView.topAnchor.constraint(equalTo: hView.topAnchor),

      hView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(with cpu: LR35902) {
    pcView.value = cpu.machineInstruction.sourceAddressAndBank()?.address ?? 0x100
    spView.value = cpu.sp
    aView.value = cpu.a
    fView.value = cpu.f
    bView.value = cpu.b
    cView.value = cpu.c
    dView.value = cpu.d
    eView.value = cpu.e
    hView.value = cpu.h
    lView.value = cpu.l
  }
}
