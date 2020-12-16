//
//  HorizontalLine.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 12/1/20.
//

import Foundation
import Cocoa

final class HorizontalLine: NSBox {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    self.boxType = .separator
    self.titlePosition = .noTitle
  }

  convenience init() {
    self.init(frame: .zero)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: NSSize {
    return NSSize(width: NSView.noIntrinsicMetric, height: 1)
  }
}
