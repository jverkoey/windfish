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
  public private(set) var lcdController = LCDController() {
    didSet {
      _memory.mapRegion(to: lcdController)
    }
  }

  public mutating func addMemoryTracer(_ tracer: AddressableMemory) {
    _memory.tracers.append(tracer)
  }

  public func advance() -> Gameboy {
    var mutated = self
    mutated.cpu = cpu.advance(memory: &mutated.memory)
    mutated.lcdController = lcdController.advance()
    return mutated
  }

  public func advanceInstruction() -> Gameboy {
    var mutated = self
    if mutated.cpu.machineInstruction.loaded == nil {
      mutated = mutated.advance()
    }
    if let sourceLocation = mutated.cpu.machineInstruction.loaded?.sourceLocation {
      while sourceLocation == mutated.cpu.machineInstruction.loaded?.sourceLocation {
        mutated = mutated.advance()
      }
    }
    return mutated
  }

  private var _memory = Memory()
}
