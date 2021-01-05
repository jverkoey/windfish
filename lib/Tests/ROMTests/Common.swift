import Foundation
import Cocoa
import Windfish

let updateGoldens = false

extension Disassembler.SourceLocation {
  func address() -> LR35902.Address {
    switch self {
    case .cartridge(let location):
      return Gameboy.Cartridge.addressAndBank(from: location).address
    case .memory(let address):
      return address
    }
  }
}

extension NSBitmapImageRep {
  var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
  var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
  var png: Data? { tiffRepresentation?.bitmap?.png }
}

extension Data {
  var checksum: Int {
    return self.map { Int($0) }.reduce(0, +) & 0xff
  }
}

extension Gameboy {
  func takeScaledScreenshot() -> NSImage {
    let image = takeScreenshot()
    let scaledImage = NSImage(size: NSSize(width: image.size.width, height: image.size.height))
    scaledImage.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .none
    image.draw(at: .zero, from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height), operation: .copy, fraction: 1.0)
    scaledImage.unlockFocus()
    return scaledImage
  }
}
