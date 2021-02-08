import Foundation

import CPU
import LR35902

/** A region of addressable memory can be read from and written to. */
public protocol TraceableMemory: class {
  /** Read from the given address and return the resulting byte, if it's known. */
  func read(from address: LR35902.Address) -> UInt8?

  /** Write a byte to the given address. Writing nil will clear any known value at the given address. */
  func write(_ byte: UInt8?, to address: LR35902.Address)

  /** Returns a source code location for the given address based on the current memory configuration. */
  func sourceLocation(from address: LR35902.Address) -> Tracer.SourceLocation

  /** Trace information for a given register. */
  var registerTraces: [LR35902.Instruction.Numeric: [LR35902.RegisterTrace]] { get set }
}

/** A representation of an object that is able to disassemble instructions from a given cartridge location. */
public protocol InstructionDisassembler: class {
  func instruction(at location: Cartridge.Location) -> LR35902.Instruction?
}

extension LR35902 {
  /** Trace information for a specific register. */
  public enum RegisterTrace: Equatable {
    /** The register's value was stored to an address in memory. */
    case storeToAddress(LR35902.Address)

    /** The register's value was loaded from an address in memory. */
    case loadFromAddress(LR35902.Address)

    /** The register's value was loaded from an immediate at some source location. */
    case loadImmediateFromSourceLocation(Tracer.SourceLocation)

    /** The register's value was modified at some source location. */
    case mutationWithImmediateAtSourceLocation(Tracer.SourceLocation)

    /** The register's value was modified at some source location. */
    case mutationFromAddress(Tracer.SourceLocation)
  }
}

private final class TracerMemory: TraceableMemory {
  init(data: Data) {
    self.data = data
  }
  let data: Data
  var mutatedMemory: [LR35902.Address: UInt8] = [:]

  var selectedBank: Cartridge.Bank = 0

  func read(from address: LR35902.Address) -> UInt8? {
    let intAddress = Int(truncatingIfNeeded: address)
    // Read-only memory (ROM) bank 00
    if address <= 0x3FFF {
      guard intAddress < data.count else {
        return 0xff
      }
      return data[intAddress]
    }

    // Read-only memory (ROM) bank 01-7F
    if address >= 0x4000 && address <= 0x7FFF {
      let location = Cartridge.Location(address: address, bank: selectedBank)
      guard location.index < data.count else {
        return 0xff
      }
      return data[location.index]
    }

    return mutatedMemory[address]
  }

  func write(_ byte: UInt8?, to address: LR35902.Address) {
    mutatedMemory[address] = byte
  }

  func sourceLocation(from address: LR35902.Address) -> Tracer.SourceLocation {
    return .cartridge(Cartridge.Location(address: address, bank: selectedBank))
  }

  var registerTraces: [LR35902.Instruction.Numeric : [LR35902.RegisterTrace]] = [:]
}

public final class Tracer {
  /** A representation of a specific address either in the cartridge ROM or in memory. */
  public enum SourceLocation: Equatable {
    /** An address in the cartridge's ROM data. */
    case cartridge(Cartridge.Location)

    /** An address in the Gameboy's memory. */
    case memory(LR35902.Address)
  }

  /**
   Traces execution of the instructions within the given range starting from an initial CPU state.

   The returned dictionary is a mapping of cartridge locations to the post-execution CPU state for the instruction at
   that location.
   */
  public class func trace(range: Range<Cartridge.Location>,
                          cpu: LR35902 = LR35902(),
                          cartridgeData: Data,
                          disassembler: InstructionDisassembler,
                          step: ((LR35902.Instruction, Cartridge.Location, LR35902, TraceableMemory) -> Void)? = nil) {
    let upperBoundPc: LR35902.Address = range.upperBound.address

    let tracerMemory: TracerMemory = TracerMemory(data: cartridgeData)

    cpu.pc = range.lowerBound.address
    let bank: Cartridge.Bank = range.lowerBound.bank
    tracerMemory.selectedBank = bank

    while cpu.pc < upperBoundPc {
      guard let instruction: LR35902.Instruction = disassembler.instruction(at: Cartridge.Location(address: cpu.pc, bank: bank)) else {
        cpu.pc &+= 1
        continue
      }

      let initialPc: LR35902.Address = cpu.pc

      let location: Cartridge.Location = Cartridge.Location(address: cpu.pc, bank: bank)
      let sourceLocation: Tracer.SourceLocation = Tracer.SourceLocation.cartridge(location)
      let opCodeBytes = LR35902.InstructionSet.opcodeBytes[instruction.spec]!
      let opcodeIndex = opCodeBytes.count > 1 ? (256 + Int(truncatingIfNeeded: opCodeBytes[1])) : Int(truncatingIfNeeded: opCodeBytes[0])
      let emulator = LR35902.Emulation.instructionEmulators[opcodeIndex]
      let width: InstructionWidth<UInt16> = LR35902.InstructionSet.widths[instruction.spec]!

      cpu.pc += width.opcode

      emulator.emulate(cpu: cpu, memory: tracerMemory, sourceLocation: sourceLocation)
      step?(instruction, location, cpu, tracerMemory)

      cpu.pc = initialPc + width.total
    }
  }
}
