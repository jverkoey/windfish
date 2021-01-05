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
    if lcdController.lcdDisplayEnable {
      pixels = screenData.map { colors[Int(truncatingIfNeeded: $0)] }
    } else {
      // When the display is turned off, we show a black screen.
      // TODO: Does turning the frame off actually just clobber VRAM? Or is the screen simply "off"?
      pixels = screenData.map { _ in colors[0] }
    }
    let providerRef = CGDataProvider(data: NSData(bytes: &pixels, length: pixels.count))!
    let cgImage = CGImage(
      width: LCDController.screenSize.width,
      height: LCDController.screenSize.height,
      bitsPerComponent: 8,
      bitsPerPixel: 8,
      bytesPerRow: LCDController.screenSize.width,
      space: CGColorSpaceCreateDeviceGray(),
      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
      provider: providerRef,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )!

    let imageSize = NSSize(width: CGFloat(LCDController.screenSize.width),
                           height: CGFloat(LCDController.screenSize.height))
    return NSImage(cgImage: cgImage, size: imageSize)
  }
}
