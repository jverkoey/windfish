import Foundation
import Cocoa
import Combine

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
  let screenImageView = PixelImageView()

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()

    screenImageView.frame = view.bounds
    screenImageView.autoresizingMask = [.width, .height]
    view.addSubview(screenImageView)
  }

  private var screenSubscriber: AnyCancellable?
  override func viewWillAppear() {
    super.viewWillAppear()

    guard let document = projectDocument else {
      fatalError()
    }
    document.emulationObservers.append(self)
    screenImageView.image = document.gameboy.takeScreenshot()
  }
}

extension LCDViewController: EmulationObservers {
  func emulationDidAdvance(screenImage: NSImage, tileDataImage: NSImage, fps: Double?, ips: Double?) {
    screenImageView.image = screenImage
  }

  func emulationDidStart() {}
  func emulationDidStop() {}
}
