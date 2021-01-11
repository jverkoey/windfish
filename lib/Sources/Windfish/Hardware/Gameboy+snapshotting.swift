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
    if ppu.registers.lcdDisplayEnable {
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

  public func takeSnapshotOfTileData() -> NSImage {
    // TODO: Also render the tile data regions, possibly as lines extending outward from the right-hand side of the
    // image so as not to clutter the tiles themselves.

    let ntiles = Gameboy.tileDataRegionSize / 16
    let ncolumns = 16
    let nrows = ntiles / ncolumns
    let pixelsPerTile = 8
    let imageSize = NSSize(width: CGFloat(ncolumns * pixelsPerTile), height: CGFloat(nrows * pixelsPerTile))

    let colorForBytePair: (UInt8, UInt8, UInt8) -> UInt8 = { highByte, lowByte, bit in
      let mask = UInt8(0x01) << bit
      return (((highByte & mask) >> bit) << 1) | ((lowByte & mask) >> bit)
    }

    var tileColumn = 0
    var tileRow = 0
    var pixelRow = 0
    var imageData = Data(count: ncolumns * 8 * nrows * 8)
    var iterator = tileData.makeIterator()

    while let lowByte = iterator.next() {
      let highByte = iterator.next()!

      for i in 0..<8 {
        let color = colorForBytePair(highByte, lowByte, UInt8(7 - i))
        imageData[Int(tileColumn * 8 + i) + Int((tileRow * 8 + pixelRow) * (ncolumns * 8))] = color
      }
      pixelRow += 1
      if pixelRow >= 16 {
        tileColumn += 1
        pixelRow = 0

        if tileColumn >= ncolumns {
          tileColumn = 0
          tileRow += 2
        }
      }
    }

    let colors: [UInt8: UInt8] = [
      0: 0x00,
      1: UInt8(NSColor.darkGray.whiteComponent * 255),
      2: UInt8(NSColor.lightGray.whiteComponent * 255),
      3: 0xFF,
    ]
    var pixels = imageData.map { colors[$0]! }
    let providerRef = CGDataProvider(data: NSData(bytes: &pixels, length: pixels.count))!
    let cgImage = CGImage(
      width: ncolumns * 8,
      height: nrows * 8,
      bitsPerComponent: 8,
      bitsPerPixel: 8,
      bytesPerRow: ncolumns * 8,
      space: CGColorSpaceCreateDeviceGray(),
      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
      provider: providerRef,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )!
    return NSImage(cgImage: cgImage, size: imageSize)
  }
}
