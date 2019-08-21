import Foundation
import Disassembler

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    let cpu: LR35902
    public init(rom: Data) {
      cpu = LR35902(cartridge: rom)
    }

    public func disassembleAsGameboyCartridge() {
      // Restart addresses
      let numberOfRestartAddresses = 8
      let restartSize = 8
      let rstAddresses = (0..<numberOfRestartAddresses)
        .map { Address($0 * restartSize)..<Address($0 * restartSize + restartSize) }
      rstAddresses.forEach {
        setLabel(at: $0.lowerBound, in: 0x00, named: "RST_\($0.lowerBound.hexString)")
        disassemble(range: $0, inBank: 0)
      }

      setLabel(at: 0x0040, in: 0x00, named: "VBlankInterrupt")
      disassemble(range: 0x0040..<0x0048, inBank: 0)

      setLabel(at: 0x0048, in: 0x00, named: "LCDCInterrupt")
      disassemble(range: 0x0048..<0x0050, inBank: 0)

      setLabel(at: 0x0050, in: 0x00, named: "TimerOverflowInterrupt")
      disassemble(range: 0x0050..<0x0058, inBank: 0)

      setLabel(at: 0x0058, in: 0x00, named: "SerialTransferCompleteInterrupt")
      disassemble(range: 0x0058..<0x0060, inBank: 0)

      setLabel(at: 0x0060, in: 0x00, named: "JoypadTransitionInterrupt")
      disassemble(range: 0x0060..<0x0068, inBank: 0)

      setLabel(at: 0x0100, in: 0x00, named: "Boot")
      disassemble(range: 0x0100..<0x104, inBank: 0)

      setLabel(at: 0x0104, in: 0x00, named: "HeaderLogo")
      setData(at: 0x0104..<0x0134, in: 0x00)

      setLabel(at: 0x0134, in: 0x00, named: "HeaderTitle")
      setText(at: 0x0134..<0x0143, in: 0x00)

      setLabel(at: 0x0143, in: 0x00, named: "HeaderIsColorGB")
      setData(at: 0x0143, in: 0x00)

      setLabel(at: 0x0144, in: 0x00, named: "HeaderNewLicenseeCode")
      setData(at: 0x0144..<0x0146, in: 0x00)

      setLabel(at: 0x0146, in: 0x00, named: "HeaderSGBFlag")
      setData(at: 0x0146, in: 0x00)

      setLabel(at: 0x0147, in: 0x00, named: "HeaderCartridgeType")
      setData(at: 0x0147, in: 0x00)

      setLabel(at: 0x0148, in: 0x00, named: "HeaderROMSize")
      setData(at: 0x0148, in: 0x00)

      setLabel(at: 0x0149, in: 0x00, named: "HeaderRAMSize")
      setData(at: 0x0149, in: 0x00)

      setLabel(at: 0x014A, in: 0x00, named: "HeaderDestinationCode")
      setData(at: 0x014A, in: 0x00)

      setLabel(at: 0x014B, in: 0x00, named: "HeaderOldLicenseeCode")
      setData(at: 0x014B, in: 0x00)

      setLabel(at: 0x014C, in: 0x00, named: "HeaderMaskROMVersion")
      setData(at: 0x014C, in: 0x00)

      setLabel(at: 0x014D, in: 0x00, named: "HeaderComplementCheck")
      setData(at: 0x014D, in: 0x00)

      setLabel(at: 0x014E, in: 0x00, named: "HeaderGlobalChecksum")
      setData(at: 0x014E..<0x0150, in: 0x00)

      createGlobal(at: 0xA000, named: "CARTRAM")
      createGlobal(at: 0xFF47, named: "rBGP")
      createGlobal(at: 0xFF48, named: "rOBP0")
      createGlobal(at: 0xFF49, named: "rOBP1")
    }

    // MARK: - Transfers of control

    struct TransferOfControl: Hashable {
      let sourceAddress: Address
      let sourceInstructionSpec: Instruction.Spec
    }
    func transfersOfControl(at pc: Address, in bank: Bank) -> Set<TransferOfControl>? {
      guard let cartAddress = cartAddress(for: pc, in: bank) else {
        return nil
      }
      return transfers[cartAddress]
    }

    func registerTransferOfControl(to pc: Address, in bank: Bank, from fromPc: Address, spec: Instruction.Spec) {
      let index = cartAddress(for: pc, in: bank)!
      let transfer = TransferOfControl(sourceAddress: fromPc, sourceInstructionSpec: spec)
      transfers[index, default: Set()].insert(transfer)

      // Create a label if one doesn't exist.
      if labels[index] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(Int(index)) || instruction(at: pc, in: bank) != nil) {
        labels[index] = RGBDSAssembly.defaultLabel(at: pc, in: bank)
      }
    }
    private var transfers: [CartridgeAddress: Set<TransferOfControl>] = [:]

    // MARK: - Instructions

    func instruction(at pc: Address, in bank: Bank) -> Instruction? {
      return instructionMap[cartAddress(for: pc, in: bank)!]
    }

    func register(instruction: Instruction, at pc: Address, in bank: Bank) {
      let address = cartAddress(for: pc, in: bank)!

      // Avoid overlapping instructions.
      if code.contains(Int(address)) && instructionMap[address] == nil {
        return
      }

      instructionMap[address] = instruction

      code.insert(integersIn: Int(address)..<(Int(address) + Int(Instruction.widths[instruction.spec]!.total)))
    }
    var instructionMap: [CartridgeAddress: Instruction] = [:]

    // MARK: - Data segments

    public func setData(at address: Address, in bank: Bank) {
      data.insert(Int(cartAddress(for: address, in: bank)!))
    }
    public func setData(at range: Range<Address>, in bank: Bank) {
      let lowerBound = cartAddress(for: range.lowerBound, in: bank)!
      let upperBound = cartAddress(for: range.upperBound, in: bank)!
      data.insert(integersIn: Int(lowerBound)..<Int(upperBound))
    }

    // MARK: - Text segments

    public func setText(at range: Range<Address>, in bank: Bank) {
      let lowerBound = cartAddress(for: range.lowerBound, in: bank)!
      let upperBound = cartAddress(for: range.upperBound, in: bank)!
      text.insert(integersIn: Int(lowerBound)..<Int(upperBound))
    }

    // MARK: - Bank changes

    public func bankChange(at pc: Address, in bank: Bank) -> Bank? {
      return bankChanges[cartAddress(for: pc, in: bank)!]
    }

    func register(bankChange: Bank, at pc: Address, in bank: Bank) {
      bankChanges[cartAddress(for: pc, in: bank)!] = bankChange
    }
    private var bankChanges: [CartridgeAddress: Bank] = [:]

    // MARK: - Regions

    public enum ByteType {
      case unknown
      case code
      case data
      case text
      case ram
    }
    public func type(of address: Address, in bank: Bank) -> ByteType {
      guard let cartAddress = cartAddress(for: address, in: bank) else {
        return .ram
      }
      let index = Int(cartAddress)
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

    // MARK: - Functions

    public func function(startingAt pc: Address, in bank: Bank) -> String? {
      guard let cartAddress = cartAddress(for: pc, in: bank) else {
        return nil
      }
      return functions[cartAddress]
    }
    public func scope(at pc: Address, in bank: Bank) -> Set<String> {
      guard let cartAddress = cartAddress(for: pc, in: bank) else {
        return Set()
      }
      let intersectingScopes = scopes.filter { iterator in
        iterator.value.contains(Int(cartAddress))
      }
      return Set(intersectingScopes.keys)
    }
    public func contiguousScope(at pc: Address, in bank: Bank) -> String? {
      guard let cartAddress = cartAddress(for: pc, in: bank) else {
        return nil
      }
      return contiguousScopes[cartAddress]
    }

    public func defineFunction(startingAt pc: Address, in bank: Bank, named name: String) {
      guard let cartAddress = cartAddress(for: pc, in: bank) else {
        preconditionFailure("Attempting to set label in non-cart addressable location.")
      }

      setLabel(at: pc, in: bank, named: name)
      functions[cartAddress] = name

      let upperBound: Address = (bank == 0) ? 0x4000 : 0x8000
      disassemble(range: pc..<upperBound, inBank: bank)
    }
    private var functions: [CartridgeAddress: String] = [:]

    func expandScope(forLabel label: String, scope: IndexSet) {
      scopes[label, default: IndexSet()].formUnion(scope)
    }
    var contiguousScopes: [CartridgeAddress: String] = [:]
    private var scopes: [String: IndexSet] = [:]

    // MARK: - Labels

    public func label(at pc: Address, in bank: Bank) -> String? {
      guard let index = cartAddress(for: pc, in: bank) else {
        return nil
      }
      // Don't return labels that point to the middle of instructions.
      if code.contains(Int(index)) && instructionMap[index] == nil {
        return nil
      }
      return labels[index]
    }

    public func setLabel(at pc: Address, in bank: Bank, named name: String) {
      guard let cartAddress = cartAddress(for: pc, in: bank) else {
        preconditionFailure("Attempting to set label in non-cart addressable location.")
      }
      labels[cartAddress] = name
    }
    var labels: [CartridgeAddress: String] = [:]

    // MARK: - Globals

    public func createGlobal(at address: Address, named name: String) {
      globals[address] = name
    }
    var globals: [Address: String] = [:]

    // MARK: - Comments

    public func preComment(at address: Address, in bank: Bank) -> String? {
      guard let cartAddress = cartAddress(for: address, in: bank) else {
        return nil
      }
      return preComments[cartAddress]
    }
    public func setPreComment(at address: Address, in bank: Bank, text: String) {
      guard let cartAddress = cartAddress(for: address, in: bank) else {
        preconditionFailure("Attempting to set pre-comment in non-cart addressable location.")
      }
      preComments[cartAddress] = text
    }
    private var preComments: [CartridgeAddress: String] = [:]

    // MARK: - Macros

    public enum MacroLine: Hashable {
      case any(Instruction.Spec)
      case instruction(Instruction)
    }
    public func defineMacro(named name: String,
                            instructions: [MacroLine],
                            code: [Instruction.Spec],
                            validArgumentValues: [Int: IndexSet]) {
      let leaf = instructions.reduce(macroTree, { node, spec in
        let child = node.children[spec, default: MacroNode()]
        node.children[spec] = child
        return child
      })
      leaf.macro = name
      leaf.code = code
      leaf.macroLines = instructions
      leaf.validArgumentValues = validArgumentValues
    }

    public class MacroNode {
      var children: [MacroLine: MacroNode] = [:]
      var macro: String?
      var code: [Instruction.Spec]?
      var macroLines: [MacroLine]?
      var validArgumentValues: [Int: IndexSet]?
      var hasWritten = false
    }
    public let macroTree = MacroNode()

    private struct DisassemblyIntent: Hashable {
      let bank: Bank
      let address: Address
    }

    public func disassemble(range: Range<Address>, inBank bankInitial: Bank) {
      var visitedAddresses = IndexSet()

      var runQueue = Disassembler.Queue<LR35902.Disassembly.Run>()
      let firstRun = Run(from: range.lowerBound, initialBank: bankInitial, upTo: range.upperBound)
      runQueue.add(firstRun)

      let queueRun: (Run, Address, Address, Bank, Instruction) -> Void = { fromRun, fromAddress, toAddress, bank, instruction in
        if toAddress > 0x8000 {
          return // We can't disassemble in-memory regions.
        }
        let run = Run(from: toAddress, initialBank: bank)
        run.invocationInstruction = instruction
        runQueue.add(run)

        fromRun.children.append(run)

        self.registerTransferOfControl(to: toAddress, in: bank, from: fromAddress, spec: instruction.spec)
      }

      while !runQueue.isEmpty {
        let run = runQueue.dequeue()

        if visitedAddresses.contains(Int(run.startAddress)) {
          // We've already visited this instruction, so we can skip it.
          continue
        }

        // Initialize the CPU
        cpu.bank = run.initialBank
        cpu.pc = LR35902.addressAndBank(from: run.startAddress).address

        let advance: (Address) -> Void = { amount in
          let currentCartAddress = cartAddress(for: self.cpu.pc, in: self.cpu.bank)!
          run.visitedRange = run.startAddress..<(currentCartAddress + CartridgeAddress(amount))

          visitedAddresses.insert(integersIn: Int(currentCartAddress)..<Int(currentCartAddress + CartridgeAddress(amount)))

          self.cpu.pc += amount
        }

        var previousInstruction: Instruction? = nil
        linear_sweep: while !run.hasReachedEnd(with: cpu) && cpu.pcIsValid() {
          let byte = Int(cpu[cpu.pc, cpu.bank])

          var spec = Instruction.table[byte]

          switch spec {
          case .invalid:
            advance(1)
            continue

          case .cb:
            let byteCB = Int(cpu[cpu.pc + 1, cpu.bank])
            let cbInstruction = Instruction.tableCB[byteCB]
            if case .invalid = spec {
              advance(2)
              continue
            }
            spec = cbInstruction

          default:
            break
          }

          let instructionWidth = Instruction.widths[spec]!

          let instructionAddress = cpu.pc
          let instructionBank = cpu.bank
          let instruction: Instruction
          switch instructionWidth.operand {
          case 1:
            instruction = Instruction(spec: spec, imm8: cpu[instructionAddress + instructionWidth.opcode, instructionBank])
          case 2:
            let low = Address(cpu[instructionAddress + instructionWidth.opcode, instructionBank])
            let high = Address(cpu[instructionAddress + instructionWidth.opcode + 1, instructionBank]) << 8
            let immediate16 = high | low
            instruction = Instruction(spec: spec, imm16: immediate16)
          default:
            instruction = Instruction(spec: spec)
          }

          // STOP must be followed by 0
          if case .stop = spec, instruction.imm8 != 0 {
            advance(1)
            continue
          }

          register(instruction: instruction, at: instructionAddress, in: instructionBank)
          advance(instructionWidth.total)

          switch spec {
          case .ld(.imm16addr, .a):
            if (0x2000..<0x4000).contains(instruction.imm16!),
              let previousInstruction = previousInstruction,
              case .ld(.a, .imm8) = previousInstruction.spec {
              register(bankChange: previousInstruction.imm8!, at: instructionAddress, in: instructionBank)

              cpu.bank = previousInstruction.imm8!
            }

          case .jr(let condition, .simm8):
            let relativeJumpAmount = Int8(bitPattern: instruction.imm8!)
            let jumpTo = cpu.pc.advanced(by: Int(relativeJumpAmount))
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

            // An unconditional jr is the end of the run.
            if condition == nil {
              break linear_sweep
            }

          case .jp(let condition, .imm16):
            let jumpTo = instruction.imm16!
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

            // An unconditional jp is the end of the run.
            if condition == nil {
              break linear_sweep
            }

          case .call(_, .imm16):
            let jumpTo = instruction.imm16!
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

          case .jp(_, nil), .ret, .reti:
            break linear_sweep

          default:
            break
          }

          previousInstruction = instruction
        }
      }

      rewriteScopes(firstRun)
    }
  }
}
