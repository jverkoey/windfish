import AppKit
import Foundation
import Cocoa

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

    document.sameboyView.screenSizeChanged()
  }
}
