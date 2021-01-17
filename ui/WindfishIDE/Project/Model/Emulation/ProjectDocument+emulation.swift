import AppKit
import Foundation
import Cocoa

// TODO: Rename to EmulationObserver
@objc protocol EmulationObservers {
  func emulationDidAdvance()
  func emulationDidStart()
  func emulationDidStop()
}

protocol LogObserver {
  func didLog()
}
