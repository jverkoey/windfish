//
//  HexViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation
import Cocoa
import LR35902
import Combine

final class LineCountingRepresenter: HFLineCountingRepresenter {
  override func cycleLineNumberFormat() {
    // Do nothing.
  }
}

final class HexViewController: NSViewController {
  let document: ProjectDocument

  let hexController = HFController()
  let layoutRepresenter = HFLayoutRepresenter()
  let minimumWidth: CGFloat

  private var disassembledSubscriber: AnyCancellable?

  init(document: ProjectDocument) {
    self.document = document

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

  func showBank(bank: LR35902.Bank?) {
    guard let slice = document.slice else {
      return
    }

    if let bank = bank {
      let range = LR35902.rangeOf(bank: bank)
      let byteArray = HFBTreeByteArray()
      byteArray.insertByteSlice(slice.subslice(with: HFRange(location: UInt64(range.location), length: UInt64(range.length))),
                                in: HFRange(location: 0, length: 0))
      hexController.byteArray = byteArray
    } else {
      hexController.byteArray = HFBTreeByteArray()
    }
  }
}
