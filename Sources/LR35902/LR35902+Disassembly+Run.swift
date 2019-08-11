import Foundation

extension LR35902.Disassembly {
  class Run {
    let startAddress: UInt16
    let endAddress: UInt16?
    let bank: UInt8
    let function: String?

    // TODO: Remove need for function because any run should be treatable as a "function" in retrospect.
    init(from startAddress: UInt16, inBank bank: UInt8, upTo endAddress: UInt16? = nil, function: String? = nil) {
      self.startAddress = startAddress
      self.endAddress = endAddress
      self.bank = bank
      self.function = function
    }

    var visitedRange: Range<UInt32>?

    weak var parent: Run? = nil
    var children: [Run] = []

    var invocationInstruction: LR35902.Instruction?
    var invocationAddress: UInt16?

    func hasReachedEnd(with cpu: LR35902) -> Bool {
      let pc = cpu.pc
      let bank = cpu.bank
      if let endAddress = endAddress {
        return cpu.pc >= endAddress
      }
      return (bank == 0 && pc >= 0x4000) || (bank != 0 && pc >= 0x8000)
    }
  }
}
