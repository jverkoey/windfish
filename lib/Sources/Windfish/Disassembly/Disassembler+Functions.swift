import Foundation

extension Disassembler {

  /** Registers a function at the given location. */
  public func registerFunction(startingAt pc: LR35902.Address, in bank: Cartridge.Bank, named name: String) {
    precondition(bank > 0)
    registerLabel(at: pc, in: bank, named: name)

    let upperBound: LR35902.Address = (pc < 0x4000) ? 0x4000 : 0x8000
    // TODO: Just register the fact that a function exists at this location. When disassembly begins use each of these
    // functions as a starting point for a run.
    disassemble(range: pc..<upperBound, inBank: bank)
  }
}
