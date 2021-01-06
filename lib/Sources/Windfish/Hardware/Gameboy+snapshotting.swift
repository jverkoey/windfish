import Foundation
import Cocoa

extension Gameboy {
  /** Takes a screenshot of the Gameboy's LCD and returns the image. */
  public func takeScreenshot() -> NSImage {
    let colors = ContiguousArray<UInt8>([
      0x00,
      UInt8(NSColor.darkGray.whiteComponent * 255),
      UInt8(NSColor.lightGray.whiteComponent * 255),
      0xFF,
    ])
    var pixels: [UInt8]
    if lcdController.registers.lcdDisplayEnable {
      pixels = screenData.map { colors[Int(truncatingIfNeeded: $0)] }
    } else {
      // When the display is turned off, we show a black screen.
      // TODO: Does turning the frame off actually just clobber VRAM? Or is the screen simply "off"?
      pixels = screenData.map { _ in colors[0] }
    }
    let providerRef = CGDataProvider(data: NSData(bytes: &pixels, length: pixels.count))!
    let cgImage = CGImage(
      width: PPU.screenSize.width,
      height: PPU.screenSize.height,
      bitsPerComponent: 8,
      bitsPerPixel: 8,
      bytesPerRow: PPU.screenSize.width,
      space: CGColorSpaceCreateDeviceGray(),
      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
      provider: providerRef,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )!

    let imageSize = NSSize(width: CGFloat(PPU.screenSize.width),
                           height: CGFloat(PPU.screenSize.height))
    return NSImage(cgImage: cgImage, size: imageSize)
  }
}
