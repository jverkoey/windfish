import Foundation

/** Object Attribute Map addressable memory. */
public final class OAM {
  static let addressableRange: ClosedRange<LR35902.Address> = 0xFE00...0xFE9F

  struct Sprite {
    var x: UInt8
    var y: UInt8
    var tile: UInt8
    var flags: UInt8 {
      get {
        return
          (priority              ? 0b1000_0000 : 0)
          | (yflip               ? 0b0100_0000 : 0)
          | (xflip               ? 0b0010_0000 : 0)
          | (palette == .obj1pal ? 0b0001_0000 : 0)
      }
      set {
        priority = (newValue & 0b1000_0000) != 0
        yflip    = (newValue & 0b0100_0000) != 0
        xflip    = (newValue & 0b0010_0000) != 0
        palette  = ((newValue & 0b0001_0000) != 0) ? .obj1pal : .obj0pal
      }
    }

    enum Palette {
      case obj0pal
      case obj1pal
    }
    var priority: Bool   // bit 7
    var yflip: Bool      // bit 6
    var xflip: Bool      // bit 5
    var palette: Palette // bit 4
  }
  private(set) var sprites: [Sprite] = (0..<40).map { _ -> Sprite in
    Sprite(x: 0, y: 0, tile: 0, priority: false, yflip: false, xflip: false, palette: .obj0pal)
  }
}

extension OAM: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
    let relativeOffset = (address - OAM.addressableRange.lowerBound)
    let oamIndex = relativeOffset / 4
    let oam = sprites[Int(oamIndex)]
    switch relativeOffset % 4 {
    case 0: return oam.y
    case 1: return oam.x
    case 2: return oam.tile
    case 3: return oam.flags
    default: fatalError()
    }
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    let relativeOffset = (address - OAM.addressableRange.lowerBound)
    let oamIndex = Int(relativeOffset / 4)
    var oam = sprites[oamIndex]
    switch relativeOffset % 4 {
    case 0: oam.y = byte
    case 1: oam.x = byte
    case 2: oam.tile = byte
    case 3: oam.flags = byte
    default: fatalError()
    }
    sprites[oamIndex] = oam
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
