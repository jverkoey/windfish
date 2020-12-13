import Foundation

import Disassembler
import RGBDS

extension LR35902.Instruction.Spec: InstructionSpecDisassemblyInfo {
  public var category: InstructionCategory? {
    switch self {
    case .call: return .call
    case .ret, .reti: return .ret
    default: return nil
    }
  }
}

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    public let cpu: LR35902
    public init(rom: Data) {
      cpu = LR35902(cartridge: Cartridge(rom: rom))
    }

    public func disassembleAsGameboyCartridge() {
      // Restart addresses
      let numberOfRestartAddresses: Address = 8
      let restartSize: Address = 8
      let rstAddresses = (0..<numberOfRestartAddresses).map { ($0 * restartSize)..<($0 * restartSize + restartSize) }
      rstAddresses.forEach {
        setLabel(at: $0.lowerBound, in: 0x00, named: "RST_\($0.lowerBound.hexString)")
        disassemble(range: $0, inBank: 0)
      }

      disassemble(range: 0x0040..<0x0048, inBank: 0)
      disassemble(range: 0x0048..<0x0050, inBank: 0)
      disassemble(range: 0x0050..<0x0058, inBank: 0)
      disassemble(range: 0x0058..<0x0060, inBank: 0)
      disassemble(range: 0x0060..<0x0068, inBank: 0)
      disassemble(range: 0x0100..<0x0104, inBank: 0)

      setData(at: 0x0104..<0x0134, in: 0x00)
      setText(at: 0x0134..<0x0143, in: 0x00)
      setData(at: 0x0144..<0x0146, in: 0x00)
      setData(at: 0x0147, in: 0x00)
      setData(at: 0x014B, in: 0x00)
      setData(at: 0x014C, in: 0x00)
      setData(at: 0x014D, in: 0x00)
      setData(at: 0x014E..<0x0150, in: 0x00)
    }

    // MARK: - Transfers of control

    func transfersOfControl(at pc: Address, in bank: Bank) -> Set<TransferOfControl>? {
      guard let cartridgeLocation = LR35902.Cartridge.location(for: pc, in: bank) else {
        return nil
      }
      return transfers[cartridgeLocation]
    }
    public func registerTransferOfControl(to pc: Address, in bank: Bank, from fromPc: Address, in fromBank: Bank, spec: Instruction.Spec) {
      let index = LR35902.Cartridge.location(for: pc, in: bank)!
      let fromLocation = LR35902.Cartridge.location(for: fromPc, in: fromBank)!
      let transfer = TransferOfControl(sourceLocation: fromLocation, sourceInstructionSpec: spec)
      transfers[index, default: Set()].insert(transfer)

      // Create a label if one doesn't exist.
      if labelTypes[index] == nil
          // Don't create a label in the middle of an instruction.
          && (!code.contains(Int(index)) || instruction(at: pc, in: bank) != nil) {
        labelTypes[index] = .transferOfControlType
      }
    }
    public struct TransferOfControl: Hashable {
      public let sourceLocation: Cartridge.Location
      public let sourceInstructionSpec: Instruction.Spec
    }
    private var transfers: [Cartridge.Location: Set<TransferOfControl>] = [:]

    // MARK: - Instructions

    public func instruction(at pc: Address, in bank: Bank) -> Instruction? {
      let location = LR35902.Cartridge.location(for: pc, in: bank)!
      guard code.contains(Int(location)) else {
        return nil
      }
      return instructionMap[location]
    }

    func register(instruction: Instruction, at pc: Address, in bank: Bank) {
      let address = LR35902.Cartridge.location(for: pc, in: bank)!

      // Avoid overlapping instructions.
      if code.contains(Int(address)) && instructionMap[address] == nil {
        return
      }

      instructionMap[address] = instruction
      let instructionRange = Int(address)..<(Int(address) + Int(InstructionSet.widths[instruction.spec]!.total))

      // Remove any overlapping instructions.
      let subRange = instructionRange.dropFirst()
      for index in subRange {
        let location = LR35902.Cartridge.Location(index)
        instructionMap[location] = nil
      }

      code.insert(integersIn: instructionRange)
    }
    var instructionMap: [Cartridge.Location: Instruction] = [:]

    // MARK: - Data segments

    public enum DataFormat {
      case bytes
      case image1bpp
      case image2bpp
    }

    public func setData(at address: Address, in bank: Bank) {
      setData(at: address..<(address+1), in: bank)
    }
    public func setData(at range: Range<Address>, in bank: Bank, format: DataFormat = .bytes) {
      let lowerBound = LR35902.Cartridge.location(for: range.lowerBound, in: bank)!
      let upperBound = LR35902.Cartridge.location(for: range.upperBound, in: bank)!
      let cartRange = lowerBound..<upperBound
      dataBlocks.insert(integersIn: Int(lowerBound + 1)..<Int(upperBound))
      dataFormats[cartRange] = format

      let scopeBank = effectiveBank(at: range.lowerBound, in: bank)
      // Shorten any contiguous scopes that contain this data.
      let overlappingScopes = contiguousScopes[scopeBank, default: Set()].filter { $0.overlaps(cartRange) }
      for scope in overlappingScopes {
        if cartRange.lowerBound < scope.upperBound {
          contiguousScopes[scopeBank, default: Set()].remove(scope)
          contiguousScopes[scopeBank, default: Set()].insert(scope.lowerBound..<cartRange.lowerBound)
        }
      }

      let range = Int(lowerBound)..<Int(upperBound)
      data.insert(integersIn: range)
      text.remove(integersIn: range)
      code.remove(integersIn: range)
      for index in range.dropFirst() {
        let location = LR35902.Cartridge.Location(index)
        if let instruction = instructionMap[location] {
          instructionMap[location] = nil
          let end = Int(location + LR35902.Cartridge.Location(LR35902.InstructionSet.widths[instruction.spec]!.total))
          if end > range.upperBound {
            code.remove(integersIn: range.upperBound..<end)
          }
        }
        labels[location] = nil
        labelTypes[location] = nil
      }
    }
    func formatOfData(at address: Address, in bank: Bank) -> DataFormat? {
      let location = LR35902.Cartridge.location(for: address, in: bank)!
      return dataFormats.first { pair in
        pair.0.contains(location)
      }?.value
    }
    private var dataBlocks = IndexSet()
    private var dataFormats: [Range<Cartridge.Location>: DataFormat] = [:]

    public func setJumpTable(at range: Range<Address>, in bank: Bank) {
      let lowerBound = LR35902.Cartridge.location(for: range.lowerBound, in: bank)!
      let upperBound = LR35902.Cartridge.location(for: range.upperBound, in: bank)!
      jumpTables.insert(integersIn: Int(lowerBound)..<Int(upperBound))

      setData(at: range, in: bank)
    }
    var jumpTables = IndexSet()

    // MARK: - Text segments

    public func setText(at range: Range<Address>, in bank: Bank, lineLength: Int? = nil) {
      let lowerBound = LR35902.Cartridge.location(for: range.lowerBound, in: bank)!
      let upperBound = LR35902.Cartridge.location(for: range.upperBound, in: bank)!
      text.insert(integersIn: Int(lowerBound)..<Int(upperBound))
      if let lineLength = lineLength {
        textLengths[lowerBound..<upperBound] = lineLength
      }
    }
    func lineLengthOfText(at address: Address, in bank: Bank) -> Int? {
      let location = LR35902.Cartridge.location(for: address, in: bank)!
      return textLengths.first { pair in
        pair.0.contains(location)
      }?.value
    }
    private var textLengths: [Range<Cartridge.Location>: Int] = [:]

    public func mapCharacter(_ character: UInt8, to string: String) {
      characterMap[character] = string
    }
    var characterMap: [UInt8: String] = [:]

    // MARK: - Bank changes

    func bankChange(at pc: Address, in bank: Bank) -> Bank? {
      return bankChanges[LR35902.Cartridge.location(for: pc, in: bank)!]
    }

    public func register(bankChange: Bank, at pc: Address, in bank: Bank) {
      bankChanges[LR35902.Cartridge.location(for: pc, in: bank)!] = bankChange
    }
    private var bankChanges: [Cartridge.Location: Bank] = [:]

    // MARK: - Regions

    public enum ByteType {
      case unknown
      case code
      case data
      case jumpTable
      case text
      case image1bpp
      case image2bpp
      case ram
    }
    public func type(of address: Address, in bank: Bank) -> ByteType {
      guard let cartridgeLocation = LR35902.Cartridge.location(for: address, in: bank) else {
        return .ram
      }
      let index = Int(cartridgeLocation)
      if code.contains(index) {
        return .code
      } else if jumpTables.contains(index) {
        return .jumpTable
      } else if data.contains(index) {
        switch formatOfData(at: address, in: bank) {
        case .image1bpp:
          return .image1bpp
        case .image2bpp:
          return .image2bpp
        case .bytes: fallthrough
        default:
          return .data
        }
      } else if text.contains(index) {
        return .text
      } else {
        return .unknown
      }
    }

    private var code = IndexSet()
    private var data = IndexSet()
    private var text = IndexSet()

    public func knownLocations() -> IndexSet {
      return code.union(data).union(text)
    }

    public func setSoftTerminator(at pc: Address, in bank: Bank) {
      softTerminators[LR35902.Cartridge.location(for: pc, in: bank)!] = true
    }
    var softTerminators: [LR35902.Cartridge.Location: Bool] = [:]

    private func effectiveBank(at pc: Address, in bank: Bank) -> Bank {
      if pc < 0x4000 {
        return 0
      }
      return bank
    }

    public func contiguousScopes(at pc: Address, in bank: Bank) -> Set<Range<Cartridge.Location>> {
      guard let cartridgeLocation = LR35902.Cartridge.location(for: pc, in: bank) else {
        return Set()
      }
      return contiguousScopes[effectiveBank(at: pc, in: bank), default: Set()].filter { scope in scope.contains(cartridgeLocation) }
    }
    public func labeledContiguousScopes(at pc: Address, in bank: Bank) -> [(label: String, scope: Range<Cartridge.Location>)] {
      return contiguousScopes(at: pc, in: bank).compactMap {
        let addressAndBank = LR35902.Cartridge.addressAndBank(from: $0.lowerBound)
        guard let label = label(at: addressAndBank.address, in: addressAndBank.bank) else {
          return nil
        }
        return (label, $0)
      }
    }
    func addContiguousScope(range: Range<Cartridge.Location>) {
      let bankAndAddress = LR35902.Cartridge.addressAndBank(from: range.lowerBound)
      let bankAndAddress2 = LR35902.Cartridge.addressAndBank(from: range.upperBound - 1)
      precondition(bankAndAddress.bank == bankAndAddress2.bank, "Scopes can't cross banks")
      contiguousScopes[effectiveBank(at: bankAndAddress.address, in: bankAndAddress.bank), default: Set()].insert(range)
    }
    var contiguousScopes: [Bank: Set<Range<Cartridge.Location>>] = [:]

    public func defineFunction(startingAt pc: Address, in bank: Bank, named name: String) {
      setLabel(at: pc, in: bank, named: name)
      let upperBound: Address = (pc < 0x4000) ? 0x4000 : 0x8000
      disassemble(range: pc..<upperBound, inBank: bank)
    }

    // MARK: - Labels

    public func label(at pc: Address, in bank: Bank) -> String? {
      guard let index = LR35902.Cartridge.location(for: pc, in: bank) else {
        return nil
      }
      // Don't return labels that point to the middle of instructions.
      if instructionMap[index] == nil && code.contains(Int(index)) {
        return nil
      }
      // Don't return labels that point to the middle of data.
      if dataBlocks.contains(Int(index)) {
        return nil
      }

      let name: String
      if let explicitName = labels[index] {
        name = explicitName
      } else if let labelType = labelTypes[index] {
        let bank: Bank = (pc < 0x4000) ? 0 : bank
        switch labelType {
        case .transferOfControlType: name = "toc_\(bank.hexString)_\(pc.hexString)"
        case .elseType:              name = "else_\(bank.hexString)_\(pc.hexString)"
        case .loopType:              name = "loop_\(bank.hexString)_\(pc.hexString)"
        case .returnType:            name = "return_\(bank.hexString)_\(pc.hexString)"
        }
      } else {
        return nil
      }

      let scopes = contiguousScopes(at: pc, in: bank)
      if let firstScope = scopes.filter({ scope -> Bool in
        scope.lowerBound != index // Ignore ourself.
      }).sorted(by: { (scope1, scope2) -> Bool in
        scope1.lowerBound < scope2.lowerBound
      }).first {
        let addressAndBank = LR35902.Cartridge.addressAndBank(from: firstScope.lowerBound)
        if let firstScopeLabel = label(at: addressAndBank.address, in: addressAndBank.bank)?.components(separatedBy: ".").first {
          return "\(firstScopeLabel).\(name)"
        }
      }

      return name
    }

    func labelLocations(in range: Range<Cartridge.Location>) -> [Cartridge.Location] {
      return range.filter {
        labels[$0] != nil || labelTypes[$0] != nil
      }
    }

    public func setLabel(at pc: Address, in bank: Bank, named name: String) {
      precondition(!name.contains("."), "Labels cannot contain dots.")
      guard let cartridgeLocation = LR35902.Cartridge.safeLocation(for: pc, in: bank) else {
        preconditionFailure("Attempting to set label in non-cart addressable location.")
      }
      labels[cartridgeLocation] = name
    }
    public var labels: [Cartridge.Location: String] = [:]
    enum LabelType {
      case transferOfControlType
      case elseType
      case returnType
      case loopType
    }
    var labelTypes: [Cartridge.Location: LabelType] = [:]

    // MARK: - Globals

    // TODO: Allow defining variable types, e.g. enums with well-understood values.
    public func createGlobal(at address: Address, named name: String, dataType: String? = nil) {
      precondition(globals[address] == nil, "Global already exists at \(address).")
      if let dataType = dataType, !dataType.isEmpty {
        precondition(dataTypes[dataType] != nil, "Data type is not registered.")
      }
      globals[address] = Global(name: name, dataType: dataType)

      precondition(address < 0x4000 || address >= 0x8000, "Cannot set globals in switchable banks.")

      if address < 0x4000 {
        setLabel(at: address, in: 0, named: name)
        setData(at: address, in: 0)
      }
    }
    final class Global {
      let name: String
      let dataType: String?
      init(name: String, dataType: String? = nil) {
        self.name = name
        if let dataType = dataType, !dataType.isEmpty {
          self.dataType = dataType
        } else {
          self.dataType = nil
        }
      }
    }
    var globals: [Address: Global] = [:]

    public struct Datatype: Equatable {
      public let namedValues: [UInt8: String]
      public let interpretation: Interpretation
      public let representation: Representation

      public enum Interpretation {
        case any
        case enumerated
        case bitmask
      }

      public enum Representation: Int, Codable {
        case decimal
        case hexadecimal
        case binary
      }
    }
    public func createDatatype(named name: String, enumeration: [UInt8: String], representation: Datatype.Representation = .hexadecimal) {
      precondition(!name.isEmpty, "Data type has invalid name.")
      precondition(dataTypes[name] == nil, "Data type \(name) already exists.")
      assert(Set(enumeration.values).count == enumeration.count, "There exist duplicate enumeration names.")
      dataTypes[name] = Datatype(namedValues: enumeration, interpretation: .enumerated, representation: representation)
    }
    public func createDatatype(named name: String, bitmask: [UInt8: String], representation: Datatype.Representation = .binary) {
      precondition(!name.isEmpty, "Data type has invalid name.")
      precondition(dataTypes[name] == nil, "Data type \(name) already exists.")
      dataTypes[name] = Datatype(namedValues: bitmask, interpretation: .bitmask, representation: representation)
    }
    public func createDatatype(named name: String, representation: Datatype.Representation) {
      precondition(!name.isEmpty, "Data type has invalid name.")
      precondition(dataTypes[name] == nil, "Data type \(name) already exists.")
      dataTypes[name] = Datatype(namedValues: [:], interpretation: .any, representation: representation)
    }
    public func valuesForDatatype(named name: String) -> [UInt8: String]? {
      return dataTypes[name]?.namedValues
    }
    var dataTypes: [String: Datatype] = [:]

    public func setType(at address: LR35902.Address, in bank: LR35902.Bank, to type: String) {
      precondition(!type.isEmpty, "Invalid type provided.")
      precondition(dataTypes[type] != nil, "\(type) is not a known type.")
      typeAtLocation[LR35902.Cartridge.location(for: address, in: bank)!] = type
    }
    var typeAtLocation: [LR35902.Cartridge.Location: String] = [:]

    // MARK: - Comments

    public func preComment(at address: Address, in bank: Bank) -> String? {
      guard let cartridgeLocation = LR35902.Cartridge.location(for: address, in: bank) else {
        return nil
      }
      return preComments[cartridgeLocation]
    }
    public func setPreComment(at address: Address, in bank: Bank, text: String) {
      guard let cartridgeLocation = LR35902.Cartridge.location(for: address, in: bank) else {
        preconditionFailure("Attempting to set pre-comment in non-cart addressable location.")
      }
      preComments[cartridgeLocation] = text
    }
    private var preComments: [Cartridge.Location: String] = [:]

    // MARK: - Macros

    public enum MacroLine: Hashable {
      case any([Instruction.Spec], argument: UInt64? = nil, argumentText: String? = nil)
      case arg(Instruction.Spec, argument: UInt64? = nil, argumentText: String? = nil)
      case instruction(Instruction)

      func asEdges() -> [MacroTreeEdge] {
        switch self {
        case .any(let specs, _, _):         return specs.map { .arg($0) }
        case .arg(let spec, _, _):          return [.arg(spec)]
        case .instruction(let instruction): return [.instruction(instruction)]
        }
      }
      func specs() -> [Instruction.Spec] {
        switch self {
        case .any(let specs, _, _):         return specs
        case .arg(let spec, _, _):          return [spec]
        case .instruction(let instruction): return [instruction.spec]
        }
      }
    }
    enum MacroTreeEdge: Hashable {
      case arg(Instruction.Spec)
      case instruction(Instruction)

      func resolve(into line: MacroLine) -> MacroLine {
        switch line {
        case let .any(_, argument, argumentText):
          guard case let .arg(spec) = self else {
            preconditionFailure("Mismatched types")
          }
          return .arg(spec, argument: argument, argumentText: argumentText)
        case let .arg(spec, argument, argumentText):
          return .arg(spec, argument: argument, argumentText: argumentText)
        case let .instruction(instruction):
          return .instruction(instruction)
        }
      }
    }
    // TODO: Verify that each instruction actually exists in the instruction table.
    public func defineMacro(named name: String,
                            instructions: [MacroLine],
                            validArgumentValues: [Int: IndexSet]? = nil,
                            action: (([Int: String], LR35902.Address, LR35902.Bank) -> Void)? = nil) {
      precondition(!macroNames.contains(name))
      macroNames.insert(name)

      let macro = Macro(name: name, macroLines: instructions, validArgumentValues: validArgumentValues, action: action)
      walkTree(lines: instructions, node: macroTree, macro: macro)
    }
    private func walkTree(lines: [MacroLine], node: MacroNode, macro: Macro, lineHistory: [MacroLine] = []) {
      guard let line = lines.first else {
        node.macros.append(Macro(name: macro.name,
                                 macroLines: lineHistory,
                                 validArgumentValues: macro.validArgumentValues,
                                 action: macro.action))
        return
      }
      for edge in line.asEdges() {
        let child: MacroNode
        if let existingChild = node.children[edge] {
          child = existingChild
        } else {
          child = MacroNode()
          node.children[edge] = child
        }
        walkTree(lines: Array<MacroLine>(lines.dropFirst()),
                 node: child,
                 macro: macro,
                 lineHistory: lineHistory + [edge.resolve(into: line)])
      }
    }
    public func defineMacro(named name: String, template: String) {
      var lines: [MacroLine] = []
      template.enumerateLines { line, _ in
        guard let statement = RGBDS.Statement(fromLine: line) else {
          return
        }
        let specs = LR35902.InstructionSet.specs(for: statement)

        guard !specs.isEmpty else {
          preconditionFailure("No instruction specification found matching this statement: \(line).")
        }

        if let argumentNumber = statement.operands.first(where: { $0.contains("#") }) {
          let scanner = Scanner(string: argumentNumber)
          _ = scanner.scanUpToString("#")
          _ = scanner.scanCharacter()
          let argument = scanner.scanUInt64()
          if specs.count > 1 {
            lines.append(.any(specs, argument: argument, argumentText: nil))
          } else {
            lines.append(.arg(specs.first!, argument: argument, argumentText: nil))
          }
        } else {
          let potentialInstructions: [LR35902.Instruction] = try! specs.compactMap { spec in
            try RGBDSAssembler.instruction(from: statement, using: spec)
          }
          guard potentialInstructions.count > 0 else {
            preconditionFailure("No instruction was able to represent \(statement.formattedString)")
          }
          let shortestInstruction = potentialInstructions.sorted(by: { pair1, pair2 in
            LR35902.InstructionSet.widths[pair1.spec]!.total < LR35902.InstructionSet.widths[pair2.spec]!.total
          })[0]
          lines.append(.instruction(shortestInstruction))
        }
      }
      defineMacro(named: name, instructions: lines)
    }
    private var macroNames = Set<String>()

    public final class Macro {
      let name: String
      let macroLines: [MacroLine]
      let validArgumentValues: [Int: IndexSet]?
      let action: (([Int: String], LR35902.Address, LR35902.Bank) -> Void)?
      var hasWritten = false

      init(name: String, macroLines: [MacroLine], validArgumentValues: [Int: IndexSet]?, action: (([Int: String], LR35902.Address, LR35902.Bank) -> Void)?) {
        self.name = name
        self.macroLines = macroLines
        self.validArgumentValues = validArgumentValues
        self.action = action
      }
    }
    final class MacroNode {
      init(children: [MacroTreeEdge : MacroNode] = [:], macros: [Macro] = []) {
        self.children = children
        self.macros = macros
      }

      var children: [MacroTreeEdge: MacroNode] = [:]
      var macros: [Macro] = []
    }
    let macroTree = MacroNode()

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
        guard LR35902.Cartridge.location(for: toAddress, in: bank) != nil else {
          return // We aren't sure which bank we're in, so we can't safely disassemble it.
        }
        let run = Run(from: toAddress, initialBank: bank)
        run.invocationInstruction = instruction
        runQueue.add(run)

        fromRun.children.append(run)

        self.registerTransferOfControl(to: toAddress, in: bank, from: fromAddress, in: bank, spec: instruction.spec)
      }

      while !runQueue.isEmpty {
        let run = runQueue.dequeue()

        if visitedAddresses.contains(Int(run.startAddress)) {
          // We've already visited this instruction, so we can skip it.
          continue
        }

        // Initialize the CPU
        cpu.bank = run.initialBank
        cpu.pc = LR35902.Cartridge.addressAndBank(from: run.startAddress).address

        let advance: (Address) -> Void = { amount in
          let currentCartAddress = LR35902.Cartridge.location(for: self.cpu.pc, in: self.cpu.bank)!
          run.visitedRange = run.startAddress..<(currentCartAddress + Cartridge.Location(amount))

          visitedAddresses.insert(integersIn: Int(currentCartAddress)..<Int(currentCartAddress + Cartridge.Location(amount)))

          self.cpu.pc += amount
        }

        var previousInstruction: Instruction? = nil
        linear_sweep: while !run.hasReachedEnd(with: cpu) && cpu.pcIsValid() {
          let location = LR35902.Cartridge.location(for: cpu.pc, in: cpu.bank)!
          if softTerminators[location] != nil {
            break
          }
          if data.contains(Int(LR35902.Cartridge.location(for: cpu.pc, in: cpu.bank)!))
           || text.contains(Int(LR35902.Cartridge.location(for: cpu.pc, in: cpu.bank)!)) {
            advance(1)
            continue
          }

          guard let instruction = LR35902.InstructionSet.instruction(from: self.cpu.cartridge[location...]) else {
            advance(1)
            continue
          }

          // STOP must be followed by 0
          if case .stop = instruction.spec, case let .imm8(immediate) = instruction.immediate, immediate != 0 {
            advance(1)
            continue
          }

          register(instruction: instruction, at: cpu.pc, in: cpu.bank)

          let instructionAddress = cpu.pc
          let instructionBank = cpu.bank

          if let bankChange = bankChange(at: instructionAddress, in: instructionBank) {
            cpu.bank = bankChange
          }

          let instructionWidth = InstructionSet.widths[instruction.spec]!
          advance(instructionWidth.total)

          switch instruction.spec {
            // TODO: Rewrite these with a macro dector during disassembly time.
          case .ld(.imm16addr, .a):
            if case let .imm16(immediate) = instruction.immediate,
               (0x2000..<0x4000).contains(immediate),
               let previousInstruction = previousInstruction,
               case .ld(.a, .imm8) = previousInstruction.spec {
              guard case let .imm8(previousImmediate) = previousInstruction.immediate else {
                preconditionFailure("Invalid immediate associated with instruction")
              }
              register(bankChange: previousImmediate, at: instructionAddress, in: instructionBank)

              cpu.bank = previousImmediate
            }
          case .ld(.hladdr, .imm8):
            if case .ld(.hl, .imm16) = previousInstruction?.spec,
               case let .imm16(previousImmediate) = previousInstruction?.immediate,
               case let .imm8(immediate) = instruction.immediate,
              (0x2000..<0x4000).contains(previousImmediate) {
              register(bankChange: immediate, at: instructionAddress, in: instructionBank)
              cpu.bank = immediate
            }

          case .jr(let condition, .simm8):
            guard case let .imm8(immediate) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            let relativeJumpAmount = Int8(bitPattern: immediate)
            let jumpTo = cpu.pc.advanced(by: Int(relativeJumpAmount))
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

            // An unconditional jr is the end of the run.
            if condition == nil {
              break linear_sweep
            }

          case .jp(let condition, .imm16):
            guard case let .imm16(immediate) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            let jumpTo = immediate
            if jumpTo < 0x4000 || cpu.bank > 0 {
              queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)
            }

            // An unconditional jp is the end of the run.
            if condition == nil {
              break linear_sweep
            }

          case .call(let condition, .imm16):
            // TODO: Allow the user to define macros like this.
            guard case let .imm16(immediate) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            if condition == nil, immediate == 0x07b9,
              let previousInstruction = previousInstruction,
              case .ld(.a, .imm8) = previousInstruction.spec,
              case let .imm8(previousImmediate) = previousInstruction.immediate {
              register(bankChange: previousImmediate, at: instructionAddress, in: instructionBank)
              cpu.bank = previousImmediate
            }
            let jumpTo = immediate
            if jumpTo < 0x4000 || cpu.bank > 0 {
              queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)
            }

          case .jp(nil, _), .ret(nil), .reti:
            break linear_sweep

            // TODO: This is specific to the rom; make it possible to pull this out.
          case .rst(.x00):
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
