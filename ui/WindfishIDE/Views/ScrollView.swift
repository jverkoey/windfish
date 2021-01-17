import AppKit
import Foundation

func CreateScrollView(bounds: NSRect) -> NSScrollView {
  let scrollView = NSScrollView()
  scrollView.frame = bounds
  scrollView.hasVerticalScroller = true
  scrollView.borderType = .noBorder
  return scrollView
}
