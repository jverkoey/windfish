//
//  HexViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation
import Cocoa
import Combine

// TODO: Add support for line offsets.
final class LineCountingRepresenter: HFLineCountingRepresenter {
  override func cycleLineNumberFormat() {
    // Do nothing.
  }
}

final class HexViewController: NSViewController {
  let hexController = HFController()
  let layoutRepresenter = HFLayoutRepresenter()
  let minimumWidth: CGFloat

  private var disassembledSubscriber: AnyCancellable?

  init() {
    hexController.editable = false

    let lineRepresenter = LineCountingRepresenter()
    lineRepresenter.lineNumberFormat = .hexadecimal
    lineRepresenter.minimumDigitCount = 4
    let textRepresenter = HFHexTextRepresenter()
    textRepresenter.rowBackgroundColors = []
    let asciiRepresenter = HFStringEncodingTextRepresenter()
    asciiRepresenter.rowBackgroundColors = []
    let verticalScrollerRepresenter = HFVerticalScrollerRepresenter()

    hexController.addRepresenter(layoutRepresenter)

    for representer in [lineRepresenter, textRepresenter, asciiRepresenter, verticalScrollerRepresenter] {
      hexController.addRepresenter(representer)
      layoutRepresenter.addRepresenter(representer)
    }

    self.minimumWidth = layoutRepresenter.representers.map { $0 as! HFRepresenter }.reduce(0) {
      $0 + $1.minimumViewWidth(forBytesPerLine: 8)
    }

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = layoutRepresenter.view()
  }
}
