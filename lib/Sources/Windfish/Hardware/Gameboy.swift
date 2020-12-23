import Foundation

public struct Gameboy {
  public init(cartridge: Gameboy.Cartridge) {
    self.cartridge = cartridge
    self._memory.mapRegion(to: self.cartridge)
  }

  public let cartridge: Cartridge
  public var memory: AddressableMemory {
    get { return _memory }
    set { _memory = newValue as! Memory }
  }
  public var cpu = LR35902.zeroed()

  public mutating func addMemoryTracer(_ tracer: AddressableMemory) {
    _memory.tracers.append(tracer)
  }

  public func advance() -> Gameboy {
    var mutated = self
    mutated.cpu = cpu.advance(memory: &mutated.memory)
    return mutated
  }

  public func advanceInstruction() -> Gameboy {
    var mutated = self
    mutated.cpu = mutated.cpu.advance(memory: &mutated.memory)
    let sourceLocation = mutated.cpu.machineInstruction.sourceLocation
    while sourceLocation == mutated.cpu.machineInstruction.sourceLocation {
      mutated.cpu = mutated.cpu.advance(memory: &mutated.memory)
    }
    return mutated
  }

  private var _memory = Memory()
}
