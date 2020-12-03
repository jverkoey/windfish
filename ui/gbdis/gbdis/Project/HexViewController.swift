//
//  HexViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation
import Cocoa
import Combine

final class HexViewController: NSViewController {
  let document: ProjectDocument

  let hexController = HFController()
  let textRepresenter = HFHexTextRepresenter()

  private var disassembledSubscriber: AnyCancellable?

  init(document: ProjectDocument) {
    self.document = document

    super.init(nibName: nil, bundle: nil)

    textRepresenter.rowBackgroundColors = []
    hexController.addRepresenter(textRepresenter)

    disassembledSubscriber = NotificationCenter.default.publisher(for: .disassembled, object: document)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { notification in
        self.updateMemory()
      })
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = textRepresenter.view()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    updateMemory()
  }

  func updateMemory() {
    guard let data = document.romData else {
      return
    }

    let slice = HFSharedMemoryByteSlice(unsharedData: data)
    let byteArray = HFBTreeByteArray()
    byteArray.insertByteSlice(slice, in: HFRange(location: 0, length: 0))
    hexController.byteArray = byteArray
  }
}
