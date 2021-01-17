import AppKit
import Foundation
import Cocoa

final class LCDViewController: NSViewController {
  let sameboyView: SameboyGBView
  init(sameboyView: SameboyGBView) {
    self.sameboyView = sameboyView

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    sameboyView.frame = view.bounds
    sameboyView.autoresizingMask = [.width, .height]
    view.addSubview(sameboyView)

    sameboyView.screenSizeChanged()
  }
}
