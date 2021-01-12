import Foundation

extension PPU.PixelTransferMode {
  struct Pixel: Equatable {
    let colorIndex: UInt8
    let palette: PPU.Palette
    let bgPriority: UInt8
  }
  final class Fifo {
    func clear() {
      count = 0
      firstPixelIndex = 0
      nextPixelIndex = 0
    }

    public subscript(index: Int) -> Pixel {
      get { return pixels[(firstPixelIndex + index) % 16] }
      set { pixels[(firstPixelIndex + index) % 16] = newValue }
    }

    func queuePixel(_ pixel: Pixel) {
      pixels[nextPixelIndex] = pixel
      nextPixelIndex = (nextPixelIndex + 1) % 16
      count += 1
    }

    func removeFirst() {
      precondition(count > 0)
      firstPixelIndex = (firstPixelIndex + 1) % 16
      count -= 1
    }

    func dequeuePixel() -> UInt8 {
      precondition(count > 0)

      let pixel = pixels[firstPixelIndex]
      firstPixelIndex = (firstPixelIndex + 1) % 16
      count -= 1
      return pixel.palette[Int(truncatingIfNeeded: pixel.colorIndex)]
    }

    private var nextPixelIndex = 0
    private var firstPixelIndex = 0
    internal private(set) var count = 0
    private var pixels = ContiguousArray<Pixel>(repeating: PPU.PixelTransferMode.Pixel(colorIndex: 0, palette: [], bgPriority: 0), count: 16)
  }
}
