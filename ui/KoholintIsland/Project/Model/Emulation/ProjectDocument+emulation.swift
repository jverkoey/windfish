import AppKit
import Foundation
import Cocoa

// TODO: Rename to EmulationObserver
protocol EmulationObservers {
  func emulationDidAdvance()
  func emulationDidStart()
  func emulationDidStop()
}
