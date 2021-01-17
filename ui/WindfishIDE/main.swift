import AppKit
import Foundation
import Cocoa

@objc protocol LabelJumper {
  @objc func jumpToLabel(_ labelName: String)
}

extension AppDelegate {
  @objc func handleUrl(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
    guard let url = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue else {
      return
    }
    let jumpToPrefix = "windfish://jumpto/"
    if url.hasPrefix(jumpToPrefix) {
      let label = url.dropFirst(jumpToPrefix.count)
      NSApplication.shared.sendAction(#selector(LabelJumper.jumpToLabel(_:)), to: nil, from: label)
    }
  }
}

autoreleasepool {
  let delegate = AppDelegate()
  NSAppleEventManager.shared().setEventHandler(delegate,
                                               andSelector: #selector(delegate.handleUrl(event:replyEvent:)),
                                               forEventClass: AEEventClass(kInternetEventClass),
                                               andEventID: AEEventID(kAEGetURL))
  NSApplication.shared.delegate = delegate
  NSApplication.shared.setActivationPolicy(.regular)
  NSApplication.shared.run()
}
