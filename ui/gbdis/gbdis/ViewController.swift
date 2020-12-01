//
//  ViewController.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import Cocoa

func splitView(_ views: [NSView]) -> NSSplitView {
  let sv = NSSplitView()
  sv.isVertical = true
  sv.dividerStyle = .thin
  for v in views {
    sv.addArrangedSubview(v)
  }
  sv.setHoldingPriority(.defaultLow - 1, forSubviewAt: 0)
  sv.autoresizingMask = [.width, .height]
  sv.autosaveName = "SplitView"
  return sv
}

extension NSTextView {
  func configureAndWrapInScrollView(isEditable editable: Bool, inset: CGSize) -> NSScrollView {
    let scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true

    isEditable = editable
    textContainerInset = inset
    autoresizingMask = [.width]
    isAutomaticQuoteSubstitutionEnabled = false
    isAutomaticDashSubstitutionEnabled = false
    scrollView.documentView = self
    return scrollView
  }
}

final class ViewController: NSViewController {
  let editor = NSTextView()
  let output = NSTextView()
  override func loadView() {
    let editorSV = editor.configureAndWrapInScrollView(isEditable: true, inset: CGSize(width: 30, height: 10))
    let outputSV = output.configureAndWrapInScrollView(isEditable: false, inset: CGSize(width: 10, height: 10))
    outputSV.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
    output.string = "output"
    editor.allowsUndo = true

    self.view = splitView([editorSV, outputSV])
  }
}
