import AppKit
import Foundation
import Cocoa

final class PixelImageView: NSImageView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)

    imageScaling = .scaleProportionallyUpOrDown

    wantsLayer = true
    layer?.shouldRasterize = true
    layer?.magnificationFilter = .nearest
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class LCDViewController: NSViewController {
  override func loadView() {
    view = NSView()
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let document = projectDocument else {
      fatalError()
    }

    document.sameboyView.frame = view.bounds
    document.sameboyView.autoresizingMask = [.width, .height]
    view.addSubview(document.sameboyView)
  }
}
