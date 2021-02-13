import Foundation

#if os(macOS)
import os.log
#endif

import LR35902
import RGBDS
import Tracing

extension LR35902.Instruction.Spec: InstructionSpecDisassemblyInfo {
  var category: InstructionCategory? {
    switch self {
    case .call: return .call
    case .ret, .reti: return .ret
    default: return nil
    }
  }
}

/// A class that owns and manages disassembly information for a given ROM.
public final class Disassembler {
  public let mutableConfiguration: MutableConfiguration
  var configuration: Configuration {
    return mutableConfiguration
  }

  public init(data: Data) {
    self.mutableConfiguration = MutableConfiguration(cartridgeData: data)
  }

  var lastBankRouter: BankRouter?

  public func disassemble() {
    // The pre-computed instruction set lookup tables aren't thread-safe, so we pre-load them all here.
    let _ = LR35902.InstructionSet.prefixTables
    let _ = LR35902.InstructionSet.widths
    let _ = LR35902.InstructionSet.opcodeBytes
    let _ = LR35902.InstructionSet.opcodeStrings
    let _ = LR35902.InstructionSet.reflectedArgumentTypes

#if os(macOS)
    let log = OSLog(subsystem: "com.featherless.windfish", category: "PointsOfInterest")
    let signpostID = OSSignpostID(log: log)
    os_signpost(.begin, log: log, name: "Disassembler", signpostID: signpostID, "%{public}s", "disassemble")
#endif

    for range in configuration.allPotentialCode().sorted(by: { (a: Range<Cartridge.Location>, b: Range<Cartridge.Location>) -> Bool in
      a.lowerBound < b.lowerBound
    }) {
      let run = Run(from: range.lowerBound.address, selectedBank: range.lowerBound.bank, upTo: range.upperBound.address,
                    numberOfBanks: configuration.numberOfBanks)
      lastBankRouter!.schedule(run: run)
    }

    lastBankRouter!.finish()

    for (address, _) in configuration.allGlobals() {
      if address < 0x4000 {
        let location = Cartridge.Location(address: address, bank: 0x01)
        lastBankRouter!.registerRegion(range: location..<(location + 1), as: .data)
      }
    }

    for range: Range<Cartridge.Location> in configuration.allPotentialData() {
      lastBankRouter!.registerRegion(range: range, as: .data)
    }

    for range: Range<Cartridge.Location> in configuration.allPotentialText() {
      lastBankRouter!.registerRegion(range: range, as: .text)
    }

#if os(macOS)
    os_signpost(.end, log: log, name: "Disassembler", signpostID: signpostID, "%{public}s", "disassemble")
#endif
  }

  /** Returns the label at the given location, if any. */
  public func labeledContiguousScope(at location: Cartridge.Location) -> String? {
    return lastBankRouter!.labeledContiguousScope(at: location)
  }
}
