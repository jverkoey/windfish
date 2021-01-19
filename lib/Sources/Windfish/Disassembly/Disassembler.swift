import Foundation
import JavaScriptCore

import RGBDS

extension Range where Bound == Int {
  func asCartridgeLocationRange() -> Range<Cartridge.Location> {
    return Cartridge.Location(truncatingIfNeeded: lowerBound)..<Cartridge.Location(truncatingIfNeeded: upperBound)
  }
}

extension Range where Bound == Cartridge.Location {
  func asIntRange() -> Range<Int> {
    return Int(truncatingIfNeeded: lowerBound)..<Int(truncatingIfNeeded: upperBound)
  }
}

extension Range where Bound == LR35902.Address {
  func asCartridgeRange(in bank: Cartridge.Bank) -> Range<Cartridge.Location>? {
    guard let lowerBound: Cartridge.Location = Cartridge.location(for: lowerBound, in: bank),
          let upperBound: Cartridge.Location = Cartridge.location(for: upperBound, in: bank) else {
      return nil
    }
    return lowerBound..<upperBound
  }
}

extension LR35902.Instruction.Spec: InstructionSpecDisassemblyInfo {
  public var category: InstructionCategory? {
    switch self {
    case .call: return .call
    case .ret, .reti: return .ret
    default: return nil
    }
  }
}

/// A class that owns and manages disassembly information for a given ROM.
public final class Disassembler {

  private let memory: DisassemblerMemory
  let cartridgeData: Data
  let cartridgeSize: Cartridge.Length
  public let numberOfBanks: Cartridge.Bank
  public init(data: Data) {
    self.cartridgeData = data
    self.memory = DisassemblerMemory(data: data)
    self.cartridgeSize = Cartridge.Length(data.count)
    self.numberOfBanks = Cartridge.Bank((cartridgeSize + Cartridge.bankSize - 1) / Cartridge.bankSize)
  }

  /** Returns true if the program counter is pointing to addressable memory. */
  func pcIsValid(pc: LR35902.Address, bank: Cartridge.Bank) -> Bool {
    return pc < 0x8000 && Cartridge.location(for: pc, in: bank)! < cartridgeSize
  }

  // MARK: - Disassembly metadata

  // MARK: Code

  /** Locations that can transfer control (jp/call) to a specific location. */
  var transfers: [Cartridge.Location: Set<Cartridge.Location>] = [:]

  /** Which instruction exists at a specific location. */
  var instructionMap: [Cartridge.Location: LR35902.Instruction] = [:]

  // MARK: Data

  /** All locations that represent data. */
  var data = IndexSet()

  /**
   We never want to show labels in the middle of a contiguous block of data, so when registering data regions we remove
   the first byte of the data region and then register that range to this index set. When determining whether a label
   can be shown at a given location we consult this "swiss cheese" index set rather than the data index set.
   */
  var dataBlocks = IndexSet()

  /** The format of the data at specific locations. */
  var dataFormats: [DataFormat: IndexSet] = [:]

  /** All locations that represent code. */
  var code = IndexSet()

  // MARK: Text

  /** All locations that represent text. */
  var text = IndexSet()

  // MARK: - Data segments

  public func setJumpTable(at range: Range<LR35902.Address>, in bank: Cartridge.Bank) {
    precondition(bank > 0)
    let lowerBound = Cartridge.location(for: range.lowerBound, in: bank)!
    let upperBound = Cartridge.location(for: range.upperBound, in: bank)!
    jumpTables.insert(integersIn: Int(lowerBound)..<Int(upperBound))

    registerData(at: range, in: bank)
  }
  var jumpTables = IndexSet()

  // MARK: - Text segments

  public func setText(at range: Range<LR35902.Address>, in bank: Cartridge.Bank, lineLength: Int? = nil) {
    precondition(bank > 0)
    guard let lowerBound = Cartridge.location(for: range.lowerBound, in: bank),
          let upperBound = Cartridge.location(for: range.upperBound, in: bank) else {
      return
    }
    let range = Int(truncatingIfNeeded: lowerBound)..<Int(truncatingIfNeeded: upperBound)
    clearCode(in: range)
    text.insert(integersIn: range)
    data.remove(integersIn: range)
    if let lineLength = lineLength {
      textLengths[lowerBound..<upperBound] = lineLength
    }
  }
  func lineLengthOfText(at address: LR35902.Address, in bank: Cartridge.Bank) -> Int? {
    precondition(bank > 0)
    let location = Cartridge.location(for: address, in: bank)!
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

  func bankChange(at pc: LR35902.Address, in bank: Cartridge.Bank) -> Cartridge.Bank? {
    precondition(bank > 0)
    return bankChanges[Cartridge.location(for: pc, in: bank)!]
  }

  public func register(bankChange: Cartridge.Bank, at pc: LR35902.Address, in bank: Cartridge.Bank) {
    precondition(bank > 0)
    bankChanges[Cartridge.location(for: pc, in: bank)!] = bankChange
  }
  private var bankChanges: [Cartridge.Location: Cartridge.Bank] = [:]

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
  public func type(of address: LR35902.Address, in bank: Cartridge.Bank) -> ByteType {
    precondition(bank > 0)
    guard let cartridgeLocation = Cartridge.location(for: address, in: bank) else {
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

  public func knownLocations() -> IndexSet {
    return code.union(data).union(text)
  }

  public func setSoftTerminator(at pc: LR35902.Address, in bank: Cartridge.Bank) {
    precondition(bank > 0)
    softTerminators[Cartridge.location(for: pc, in: bank)!] = true
  }
  var softTerminators: [Cartridge.Location: Bool] = [:]

  func effectiveBank(at pc: LR35902.Address, in bank: Cartridge.Bank) -> Cartridge.Bank {
    if pc < 0x4000 {
      return 1
    }
    return bank
  }

  public func contiguousScopes(at pc: LR35902.Address, in bank: Cartridge.Bank) -> Set<Range<Cartridge.Location>> {
    precondition(bank > 0)
    guard let cartridgeLocation = Cartridge.location(for: pc, in: bank) else {
      return Set()
    }
    return contiguousScopes[effectiveBank(at: pc, in: bank), default: Set()].filter { scope in scope.contains(cartridgeLocation) }
  }
  public func labeledContiguousScopes(at pc: LR35902.Address, in bank: Cartridge.Bank) -> [(label: String, scope: Range<Cartridge.Location>)] {
    precondition(bank > 0)
    return contiguousScopes(at: pc, in: bank).compactMap {
      let addressAndBank = Cartridge.addressAndBank(from: $0.lowerBound)
      guard let label = label(at: addressAndBank.address, in: addressAndBank.bank) else {
        return nil
      }
      return (label, $0)
    }
  }
  func addContiguousScope(range: Range<Cartridge.Location>) {
    let bankAndAddress = Cartridge.addressAndBank(from: range.lowerBound)
    let bankAndAddress2 = Cartridge.addressAndBank(from: range.upperBound - 1)
    precondition(bankAndAddress.bank == bankAndAddress2.bank, "Scopes can't cross banks")
    contiguousScopes[effectiveBank(at: bankAndAddress.address, in: bankAndAddress.bank), default: Set()].insert(range)
  }
  var contiguousScopes: [Cartridge.Bank: Set<Range<Cartridge.Location>>] = [:]

  public func defineFunction(startingAt pc: LR35902.Address, in bank: Cartridge.Bank, named name: String) {
    precondition(bank > 0)
    setLabel(at: pc, in: bank, named: name)
    let upperBound: LR35902.Address = (pc < 0x4000) ? 0x4000 : 0x8000
    disassemble(range: pc..<upperBound, inBank: bank)
  }

  // MARK: - Labels

  public func label(at pc: LR35902.Address, in bank: Cartridge.Bank) -> String? {
    guard let index = Cartridge.location(for: pc, in: bank) else {
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
      let bank: Cartridge.Bank = (pc < 0x4000) ? 1 : bank
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
      let addressAndBank = Cartridge.addressAndBank(from: firstScope.lowerBound)
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

  public func setLabel(at pc: LR35902.Address, in bank: Cartridge.Bank, named name: String) {
    precondition(bank > 0)
    precondition(!name.contains("."), "Labels cannot contain dots.")
    guard let cartridgeLocation = Cartridge.location(for: pc, inHumanProvided: bank) else {
      preconditionFailure("Setting a label in a non-cart addressable location is not yet supported.")
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
  public func createGlobal(at address: LR35902.Address, named name: String, dataType: String? = nil) {
    precondition(globals[address] == nil, "Global already exists at \(address).")
    if let dataType = dataType, !dataType.isEmpty {
      precondition(dataTypes[dataType] != nil, "Data type is not registered.")
    }
    globals[address] = Global(name: name, dataType: dataType)

    precondition(address < 0x4000 || address >= 0x8000, "Cannot set globals in switchable banks.")

    if address < 0x4000 {
      setLabel(at: address, in: 0x01, named: name)
      registerData(at: address, in: 0x01)
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
  var globals: [LR35902.Address: Global] = [:]

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

  public func setType(at address: LR35902.Address, in bank: Cartridge.Bank, to type: String) {
    precondition(!type.isEmpty, "Invalid type provided.")
    precondition(dataTypes[type] != nil, "\(type) is not a known type.")
    typeAtLocation[Cartridge.location(for: address, in: bank)!] = type
  }
  var typeAtLocation: [Cartridge.Location: String] = [:]

  // MARK: - Comments

  public func preComment(at address: LR35902.Address, in bank: Cartridge.Bank) -> String? {
    guard let cartridgeLocation = Cartridge.location(for: address, in: bank) else {
      return nil
    }
    return preComments[cartridgeLocation]
  }
  public func setPreComment(at address: LR35902.Address, in bank: Cartridge.Bank, text: String) {
    guard let cartridgeLocation = Cartridge.location(for: address, in: bank) else {
      preconditionFailure("Attempting to set pre-comment in non-cart addressable location.")
    }
    preComments[cartridgeLocation] = text
  }
  private var preComments: [Cartridge.Location: String] = [:]

  // MARK: - Scripts
  public final class Script {
    init(source: String) {
      self.source = source

      let context = JSContext()!
      context.exceptionHandler = { context, exception in
        print(exception)
      }
      context.evaluateScript(source)
      self.context = context
      if let linearSweepWillStart = context.objectForKeyedSubscript("linearSweepWillStart"), !linearSweepWillStart.isUndefined {
        self.linearSweepWillStart = linearSweepWillStart
      } else {
        self.linearSweepWillStart = nil
      }
      if let linearSweepDidStep = context.objectForKeyedSubscript("linearSweepDidStep"), !linearSweepDidStep.isUndefined {
        self.linearSweepDidStep = linearSweepDidStep
      } else {
        self.linearSweepDidStep = nil
      }
      if let disassemblyWillStart = context.objectForKeyedSubscript("disassemblyWillStart"), !disassemblyWillStart.isUndefined {
        self.disassemblyWillStart = disassemblyWillStart
      } else {
        self.disassemblyWillStart = nil
      }
    }
    let source: String
    let context: JSContext
    let linearSweepWillStart: JSValue?
    let linearSweepDidStep: JSValue?
    let disassemblyWillStart: JSValue?
  }
  public func defineScript(named name: String, source: String) {
    precondition(scripts[name] == nil, "A script named \(name) already exists.")
    scripts[name] = Script(source: source)
  }
  private var scripts: [String: Script] = [:]

  // MARK: - Macros

  public enum MacroLine: Hashable {
    case any([LR35902.Instruction.Spec], argument: UInt64? = nil, argumentText: String? = nil)
    case arg(LR35902.Instruction.Spec, argument: UInt64? = nil, argumentText: String? = nil)
    case instruction(LR35902.Instruction)

    func asEdges() -> [MacroTreeEdge] {
      switch self {
      case .any(let specs, _, _):         return specs.map { .arg($0) }
      case .arg(let spec, _, _):          return [.arg(spec)]
      case .instruction(let instruction): return [.instruction(instruction)]
      }
    }
    func specs() -> [LR35902.Instruction.Spec] {
      switch self {
      case .any(let specs, _, _):         return specs
      case .arg(let spec, _, _):          return [spec]
      case .instruction(let instruction): return [instruction.spec]
      }
    }
  }
  enum MacroTreeEdge: Hashable {
    case arg(LR35902.Instruction.Spec)
    case instruction(LR35902.Instruction)

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
                          action: (([Int: String], LR35902.Address, Cartridge.Bank) -> Void)? = nil) {
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
    let action: (([Int: String], LR35902.Address, Cartridge.Bank) -> Void)?

    init(name: String, macroLines: [MacroLine], validArgumentValues: [Int: IndexSet]?, action: (([Int: String], LR35902.Address, Cartridge.Bank) -> Void)?) {
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
    let bank: Cartridge.Bank
    let address: LR35902.Address
  }

  static func fetchInstructionSpec(pc: inout LR35902.Address, memory: AddressableMemory) -> LR35902.Instruction.Spec {
    // Fetch
    let instructionByte = memory.read(from: pc)
    pc += 1

    // Decode
    let spec = LR35902.InstructionSet.table[Int(instructionByte)]
    if let prefixTable = LR35902.InstructionSet.prefixTables[spec] {
      // Fetch
      let cbInstructionByte = memory.read(from: pc)
      pc += 1

      // Decode
      return prefixTable[Int(cbInstructionByte)]
    }
    return spec
  }

  static func fetchInstruction(at address: inout LR35902.Address, memory: AddressableMemory) -> LR35902.Instruction {
    let spec = fetchInstructionSpec(pc: &address, memory: memory)

    guard let instructionWidth = LR35902.InstructionSet.widths[spec] else {
      preconditionFailure("\(spec) is missing its width, implying a misconfiguration of the instruction set."
                            + " Verify that all specifications are computing and storing a corresponding width in the"
                            + " instruction set's width table.")
    }

    if instructionWidth.operand > 0 {
      var operandBytes: [UInt8] = []
      for _ in 0..<Int(instructionWidth.operand) {
        let byte = memory.read(from: address)
        address += 1
        operandBytes.append(byte)
      }
      return LR35902.Instruction(spec: spec, immediate: LR35902.Instruction.ImmediateValue(data: Data(operandBytes)))
    }

    return LR35902.Instruction(spec: spec, immediate: nil)
  }

  public func willStart() {
    // Script functions
    let getROMData: @convention(block) (Int, Int, Int) -> [UInt8] = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return []
      }
      let startLocation = Cartridge.location(for: LR35902.Address(truncatingIfNeeded: startAddress),
                                                     inHumanProvided: Cartridge.Bank(truncatingIfNeeded: bank))!
      let endLocation = Cartridge.location(for: LR35902.Address(truncatingIfNeeded: endAddress),
                                                   inHumanProvided: Cartridge.Bank(truncatingIfNeeded: bank))!
      return [UInt8](self.cartridgeData[startLocation..<endLocation])
    }
    let registerText: @convention(block) (Int, Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress, lineLength in
      guard let self = self else {
        return
      }
      self.setText(at: LR35902.Address(truncatingIfNeeded: startAddress)..<LR35902.Address(truncatingIfNeeded: endAddress),
                   in: max(1, Cartridge.Bank(truncatingIfNeeded: bank)),
                   lineLength: lineLength)
    }
    let registerData: @convention(block) (Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return
      }
      self.registerData(at: LR35902.Address(truncatingIfNeeded: startAddress)..<LR35902.Address(truncatingIfNeeded: endAddress),
                   in: max(1, Cartridge.Bank(truncatingIfNeeded: bank)))
    }
    let registerJumpTable: @convention(block) (Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return
      }
      self.setJumpTable(at: LR35902.Address(truncatingIfNeeded: startAddress)..<LR35902.Address(truncatingIfNeeded: endAddress),
                        in: max(1, Cartridge.Bank(truncatingIfNeeded: bank)))
    }
    let registerTransferOfControl: @convention(block) (Int, Int, Int, Int, Int) -> Void = { [weak self] toBank, toAddress, fromBank, fromAddress, opcode in
      guard let self = self else {
        return
      }
      self.registerTransferOfControl(
        to: LR35902.Address(truncatingIfNeeded: toAddress), in: max(1, Cartridge.Bank(truncatingIfNeeded: toBank)),
        from: LR35902.Address(truncatingIfNeeded: fromAddress), in: max(1, Cartridge.Bank(truncatingIfNeeded: fromBank)),
        spec: LR35902.InstructionSet.table[opcode]
      )
    }
    let registerFunction: @convention(block) (Int, Int, String) -> Void = { [weak self] bank, address, name in
      guard let self = self else {
        return
      }
      self.defineFunction(startingAt: LR35902.Address(truncatingIfNeeded: address),
                          in: max(1, Cartridge.Bank(truncatingIfNeeded: bank)),
                          named: name)
    }
    let registerBankChange: @convention(block) (Int, Int, Int) -> Void = { [weak self] _desiredBank, address, bank in
      guard let self = self else {
        return
      }
      let desiredBank = Cartridge.Bank(truncatingIfNeeded: _desiredBank)
      self.register(
        bankChange: max(1, desiredBank),
        at: LR35902.Address(truncatingIfNeeded: address),
        in: max(1, Cartridge.Bank(truncatingIfNeeded: bank))
      )
    }
    let hex16: @convention(block) (Int) -> String = { value in
      return UInt16(truncatingIfNeeded: value).hexString
    }
    let hex8: @convention(block) (Int) -> String = { value in
      return UInt8(truncatingIfNeeded: value).hexString
    }
    let log: @convention(block) (Int) -> Void = { value in
      print(value.hexString)
    }

    for script in scripts.values {
      script.context.setObject(getROMData, forKeyedSubscript: "getROMData" as NSString)
      script.context.setObject(registerText, forKeyedSubscript: "registerText" as NSString)
      script.context.setObject(registerData, forKeyedSubscript: "registerData" as NSString)
      script.context.setObject(registerJumpTable, forKeyedSubscript: "registerJumpTable" as NSString)
      script.context.setObject(registerTransferOfControl, forKeyedSubscript: "registerTransferOfControl" as NSString)
      script.context.setObject(registerFunction, forKeyedSubscript: "registerFunction" as NSString)
      script.context.setObject(registerBankChange, forKeyedSubscript: "registerBankChange" as NSString)
      script.context.setObject(hex16, forKeyedSubscript: "hex16" as NSString)
      script.context.setObject(hex8, forKeyedSubscript: "hex8" as NSString)
      script.context.setObject(log, forKeyedSubscript: "log" as NSString)
    }

    // Extract any scripted events.
    let disassemblyWillStarts = scripts.values.filter { $0.disassemblyWillStart != nil }
    guard !disassemblyWillStarts.isEmpty else {
      return  // Nothing to do here.
    }

    for script in disassemblyWillStarts {
      script.disassemblyWillStart?.call(withArguments: [])
    }
  }

  public func disassemble(range: Range<LR35902.Address>, inBank bankInitial: Cartridge.Bank) {
    var visitedAddresses = IndexSet()

    var runQueue = Queue<Disassembler.Run>()
    let firstRun = Run(from: range.lowerBound, initialBank: bankInitial, upTo: range.upperBound)
    runQueue.add(firstRun)

    let queueRun: (Run, LR35902.Address, LR35902.Address, Cartridge.Bank, LR35902.Instruction) -> Void = { fromRun, fromAddress, toAddress, bank, instruction in
      if toAddress > 0x8000 {
        return // We can't disassemble in-memory regions.
      }
      guard Cartridge.location(for: toAddress, in: bank) != nil else {
        return // We aren't sure which bank we're in, so we can't safely disassemble it.
      }
      let run = Run(from: toAddress, initialBank: bank)
      run.invocationInstruction = instruction
      runQueue.add(run)

      fromRun.children.append(run)

      self.registerTransferOfControl(to: toAddress, in: bank, from: fromAddress, in: bank, spec: instruction.spec)
    }

    // Extract any scripted events.
    let linearSweepDidSteps = scripts.values.filter { $0.linearSweepDidStep != nil }
    let linearSweepWillStarts = scripts.values.filter { $0.linearSweepWillStart != nil }

    while !runQueue.isEmpty {
      linearSweepWillStarts.forEach {
        $0.linearSweepWillStart?.call(withArguments: [])
      }

      let run = runQueue.dequeue()

      if visitedAddresses.contains(Int(run.startAddress)) {
        // We've already visited this instruction, so we can skip it.
        continue
      }

      // Initialize the run's program counter
      var runContext = (pc: Cartridge.addressAndBank(from: run.startAddress).address,
                        bank: run.initialBank)

      // Script functions
      let registerBankChange: @convention(block) (Int, Int, Int) -> Void = { [weak self] _desiredBank, address, bank in
        guard let self = self else {
          return
        }
        let desiredBank = Cartridge.Bank(truncatingIfNeeded: _desiredBank)
        self.register(
          bankChange: max(1, desiredBank),
          at: LR35902.Address(truncatingIfNeeded: address),
          in: max(1, Cartridge.Bank(truncatingIfNeeded: bank))
        )
        runContext.bank = desiredBank
      }
      for script in scripts.values {
        script.context.setObject(registerBankChange, forKeyedSubscript: "registerBankChange" as NSString)
      }

      let advance: (LR35902.Address) -> Void = { amount in
        let currentCartAddress = Cartridge.location(for: runContext.pc, in: runContext.bank)!
        run.visitedRange = run.startAddress..<(currentCartAddress + Cartridge.Location(amount))

        visitedAddresses.insert(integersIn: Int(currentCartAddress)..<Int(currentCartAddress + Cartridge.Location(amount)))

        runContext.pc += amount
      }

      var previousInstruction: LR35902.Instruction? = nil
      linear_sweep: while !run.hasReachedEnd(pc: runContext.pc) && pcIsValid(pc: runContext.pc, bank: runContext.bank) {
        let location = Cartridge.location(for: runContext.pc, in: runContext.bank)!
        if softTerminators[location] != nil {
          break
        }
        if data.contains(Int(location)) || text.contains(Int(location)) {
          advance(1)
          continue
        }

        let instructionContext = runContext

        // Don't commit the fetch to the context pc yet in case the instruction was invalid.
        var instructionPc = runContext.pc
        memory.selectedBank = runContext.bank
        let instruction = Disassembler.fetchInstruction(at: &instructionPc, memory: memory)

        // STOP must be followed by 0
        if case .stop = instruction.spec, case let .imm8(immediate) = instruction.immediate, immediate != 0 {
          // STOP wasn't followed by a 0, so skip this byte.
          advance(1)
          continue
        }

        if case .invalid = instruction.spec {
          // This isn't a valid instruction; skip it.
          advance(1)
          continue
        }

        register(instruction: instruction, at: instructionContext.pc, in: instructionContext.bank)

        if let bankChange = bankChange(at: instructionContext.pc, in: instructionContext.bank) {
          runContext.bank = bankChange
        }

        let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!
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
            register(bankChange: previousImmediate, at: instructionContext.pc, in: instructionContext.bank)

            runContext.bank = previousImmediate
          }
        case .ld(.hladdr, .imm8):
          if case .ld(.hl, .imm16) = previousInstruction?.spec,
             case let .imm16(previousImmediate) = previousInstruction?.immediate,
             case let .imm8(immediate) = instruction.immediate,
             (0x2000..<0x4000).contains(previousImmediate) {
            register(bankChange: immediate, at: instructionContext.pc, in: instructionContext.bank)
            runContext.bank = immediate
          }

        case .jr(let condition, .simm8):
          guard case let .imm8(immediate) = instruction.immediate else {
            preconditionFailure("Invalid immediate associated with instruction")
          }
          let relativeJumpAmount = Int8(bitPattern: immediate)
          let jumpTo = runContext.pc.advanced(by: Int(relativeJumpAmount))
          queueRun(run, instructionContext.pc, jumpTo, instructionContext.bank, instruction)

          // An unconditional jr is the end of the run.
          if condition == nil {
            break linear_sweep
          }

        case .jp(let condition, .imm16):
          guard case let .imm16(immediate) = instruction.immediate else {
            preconditionFailure("Invalid immediate associated with instruction")
          }
          let jumpTo = immediate
          if jumpTo < 0x8000 {
            queueRun(run, instructionContext.pc, jumpTo, (instructionContext.bank == 0 ? 1 : instructionContext.bank), instruction)
          }

          // An unconditional jp is the end of the run.
          if condition == nil {
            break linear_sweep
          }

        case .call(_, .imm16):
          // TODO: Allow the user to define macros like this.
          guard case let .imm16(immediate) = instruction.immediate else {
            preconditionFailure("Invalid immediate associated with instruction")
          }
          let jumpTo = immediate
          if jumpTo < 0x8000 {
            queueRun(run, instructionContext.pc, jumpTo, instructionContext.bank, instruction)
          }

        case .jp(nil, _), .ret(nil), .reti:
          break linear_sweep

        // TODO: This is specific to the rom; make it possible to pull this out.
        case .rst(.x00):
          break linear_sweep

        default:
          break
        }

        // linearSweepDidStep event
        if !linearSweepDidSteps.isEmpty {
          let args: [Any] = [
            LR35902.InstructionSet.opcodeBytes[instruction.spec]!,
            instruction.immediate?.asInt() ?? 0,
            instructionContext.pc,
            instructionContext.bank
          ]
          for linearSweepDidStep in linearSweepDidSteps {
            linearSweepDidStep.linearSweepDidStep?.call(withArguments: args)
          }
        }

        previousInstruction = instruction
      }
    }

    rewriteScopes(firstRun)
  }
}
