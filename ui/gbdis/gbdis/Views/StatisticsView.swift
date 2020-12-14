import Foundation
import Cocoa

import LR35902

final class StatisticsView: NSView {
  var statistics: LR35902.Disassembly.Statistics? {
    didSet {
      resetLabels()
    }
  }

  private let instructionsDecodedLabel: NSTextField
  private let percentDecodedLabel: NSTextField

  override init(frame frameRect: NSRect) {
    instructionsDecodedLabel = NSTextField()
    instructionsDecodedLabel.translatesAutoresizingMaskIntoConstraints = false
    instructionsDecodedLabel.isBezeled = false
    instructionsDecodedLabel.isEditable = false
    instructionsDecodedLabel.drawsBackground = false

    percentDecodedLabel = NSTextField()
    percentDecodedLabel.translatesAutoresizingMaskIntoConstraints = false
    percentDecodedLabel.isBezeled = false
    percentDecodedLabel.isEditable = false
    percentDecodedLabel.drawsBackground = false

    super.init(frame: frameRect)

    addSubview(instructionsDecodedLabel)
    addSubview(percentDecodedLabel)

    NSLayoutConstraint.activate([
      instructionsDecodedLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      instructionsDecodedLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      instructionsDecodedLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

      percentDecodedLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: instructionsDecodedLabel.trailingAnchor, multiplier: 1),

      percentDecodedLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      percentDecodedLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: percentDecodedLabel.trailingAnchor),
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
      percentDecodedLabel.toolTip = statistics.bankPercents.map { (key: LR35902.Bank, value: Double) in
        return "Bank \(key.hexString): \(String(format: "%.2f", value))%"
      }.sorted().joined(separator: "\n")
    } else {
      instructionsDecodedLabel.stringValue = "Waiting for disassembly results..."
      percentDecodedLabel.stringValue = ""
      percentDecodedLabel.toolTip = ""
    }
  }
}
