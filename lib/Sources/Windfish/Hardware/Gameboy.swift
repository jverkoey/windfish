import Foundation

public struct Gameboy {
  public init() {} // No cartridge loaded.

  public init(cartridge: Gameboy.Cartridge) {
    self.load(cartridge: cartridge)
  }

  public mutating func load(cartridge: Gameboy.Cartridge) {
    self.cartridge = cartridge
    self._memory.mapRegion(to: cartridge)
  }

  public private(set) var cartridge: Cartridge?
  public var memory: AddressableMemory {
    get { return _memory }
    set { _memory = newValue as! Memory }
  }
  public var cpu = LR35902()
  public internal(set) var lcdController = LCDController() {
    didSet {
      _memory.mapRegion(to: lcdController)
    }
  }

  public mutating func addMemoryTracer(_ tracer: AddressableMemory) {
    _memory.tracers.append(tracer)
  }

  private var _memory = Memory()
}
