import Foundation

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    // MARK: - Transfers of control

    public struct TransferOfControl: Hashable {
      public enum Kind {
        case jr, jp, call
      }
      public let sourceAddress: UInt16
      public let kind: Kind
    }
    public func transfersOfControl(at pc: UInt16, in bank: UInt8) -> Set<TransferOfControl>? {
      return transfers[romAddress(for: pc, in: bank)]
    }

    func registerTransferOfControl(to pc: UInt16, in bank: UInt8, from fromPc: UInt16, kind: TransferOfControl.Kind) {
      let index = romAddress(for: pc, in: bank)
      transfers[index, default: Set()]
        .insert(TransferOfControl(sourceAddress: fromPc, kind: kind))
      if labels[index] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(Int(index)) || instruction(at: pc, in: bank) != nil) {
        labels[index] = RGBDSAssembly.defaultLabel(at: pc, in: bank)
      }
    }
    private var transfers: [UInt32: Set<TransferOfControl>] = [:]

    // MARK: - Instructions

    public func instruction(at pc: UInt16, in bank: UInt8) -> Instruction? {
      return instructionMap[romAddress(for: pc, in: bank)]
    }

    func register(instruction: Instruction, at pc: UInt16, in bank: UInt8) {
      let address = romAddress(for: pc, in: bank)
      instructionMap[address] = instruction

      code.insert(integersIn: Int(address)..<(Int(address) + Int(LR35902.instructionWidths[instruction.spec]!)))
    }
    private var instructionMap: [UInt32: Instruction] = [:]

    // MARK: - Data segments

    public func setData(at address: UInt16, in bank: UInt8) {
      data.insert(Int(romAddress(for: address, in: bank)))
    }
    public func setData(at range: Range<UInt16>, in bank: UInt8) {
      let lowerBound = romAddress(for: range.lowerBound, in: bank)
      let upperBound = romAddress(for: range.upperBound, in: bank)
      data.insert(integersIn: Int(lowerBound)..<Int(upperBound))
    }

    // MARK: - Text segments

    public func setText(at range: Range<UInt16>, in bank: UInt8) {
      let lowerBound = romAddress(for: range.lowerBound, in: bank)
      let upperBound = romAddress(for: range.upperBound, in: bank)
      text.insert(integersIn: Int(lowerBound)..<Int(upperBound))
    }

    // MARK: - Bank changes

    public func bankChange(at pc: UInt16, in bank: UInt8) -> UInt8? {
      return bankChanges[romAddress(for: pc, in: bank)]
    }

    func register(bankChange: UInt8, at pc: UInt16, in bank: UInt8) {
      bankChanges[romAddress(for: pc, in: bank)] = bankChange
    }
    private var bankChanges: [UInt32: UInt8] = [:]

    // MARK: - Regions

    public enum ByteType {
      case unknown
      case code
      case data
      case text
    }
    public func type(of address: UInt16, in bank: UInt8) -> ByteType {
      let index = Int(romAddress(for: address, in: bank))
      if code.contains(index) {
        return .code
      } else if data.contains(index) {
        return .data
      } else if text.contains(index) {
        return .text
      } else {
        return .unknown
      }
    }

    private var code = IndexSet()
    private var data = IndexSet()
    private var text = IndexSet()

    // MARK: - Labels

    public func label(at pc: UInt16, in bank: UInt8) -> String? {
      return labels[romAddress(for: pc, in: bank)]
    }

    public func setLabel(at pc: UInt16, in bank: UInt8, named name: String) {
      labels[romAddress(for: pc, in: bank)] = name
    }
    private var labels: [UInt32: String] = [:]

    // MARK: - Variables

    public func createVariable(at address: UInt16, named name: String) {
      variables[address] = name
    }
    var variables: [UInt16: String] = [:]

    // MARK: - Comments

    public func preComment(at address: UInt16, in bank: UInt8) -> String? {
      return preComments[romAddress(for: address, in: bank)]
    }
    public func setPreComment(at address: UInt16, in bank: UInt8, text: String) {
      preComments[romAddress(for: address, in: bank)] = text
    }
    private var preComments: [UInt32: String] = [:]

    // MARK: - Macros

    public enum MacroLine: Hashable {
      case any(InstructionSpec)
      case instruction(Instruction)
    }
    public func defineMacro(named name: String,
                            instructions: [MacroLine],
                            code: [InstructionSpec]) {
      let leaf = instructions.reduce(macroTree, { node, spec in
        let child = node.children[spec, default: MacroNode()]
        node.children[spec] = child
        return child
      })
      leaf.macro = name
      leaf.code = code
      leaf.macroLines = instructions
    }

    public class MacroNode {
      var children: [MacroLine: MacroNode] = [:]
      var macro: String?
      var code: [InstructionSpec]?
      var macroLines: [MacroLine]?
      var hasWritten = false
    }
    public let macroTree = MacroNode()
  }
}
