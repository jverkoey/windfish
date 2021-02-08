import AppKit
import Foundation
import Cocoa

import Tracing
import Windfish

func CreateLabel() -> NSTextField {
  let label = NSTextField()
  label.isBezeled = false
  label.isEditable = false
  label.drawsBackground = false
  return label
}

final class StatisticsView: NSView {
  var statistics: Disassembler.Statistics? {
    didSet {
      resetLabels()
    }
  }

  private let instructionsDecodedLabel: NSTextField
  private let percentDecodedLabel: NSTextField

  override init(frame frameRect: NSRect) {
    instructionsDecodedLabel = CreateLabel()
    instructionsDecodedLabel.translatesAutoresizingMaskIntoConstraints = false

    percentDecodedLabel = CreateLabel()
    percentDecodedLabel.translatesAutoresizingMaskIntoConstraints = false

    super.init(frame: frameRect)

    addSubview(instructionsDecodedLabel)
    addSubview(percentDecodedLabel)

    let safeAreas: ViewOrLayoutGuide
    if #available(OSX 11.0, *) {
      safeAreas = safeAreaLayoutGuide
    } else {
      safeAreas = self
    }
    NSLayoutConstraint.activate([
      instructionsDecodedLabel.leadingAnchor.constraint(equalTo: safeAreas.leadingAnchor),
      instructionsDecodedLabel.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      instructionsDecodedLabel.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),

      percentDecodedLabel.leadingAnchor.constraint(equalToSystemOrDefaultSpacingAfter: instructionsDecodedLabel.trailingAnchor, multiplier: 1),

      percentDecodedLabel.topAnchor.constraint(equalTo: safeAreas.topAnchor),
      percentDecodedLabel.bottomAnchor.constraint(equalTo: safeAreas.bottomAnchor),
      percentDecodedLabel.trailingAnchor.constraint(equalTo: safeAreas.trailingAnchor),
    ])

    resetLabels()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func resetLabels() {
    if let statistics = statistics {
      instructionsDecodedLabel.stringValue = "\(statistics.instructionsDecoded) instructions decoded"
      percentDecodedLabel.stringValue = String(format: "%.2f", statistics.percent) + "% decoded"
      percentDecodedLabel.toolTip = statistics.bankPercents.map { (key: Cartridge.Bank, value: Double) in
        return "Bank \(key.hexString): \(String(format: "%.2f", value))%"
      }.sorted().joined(separator: "\n")
    } else {
      instructionsDecodedLabel.stringValue = "Waiting for disassembly results..."
      percentDecodedLabel.stringValue = ""
      percentDecodedLabel.toolTip = ""
    }
  }
}
