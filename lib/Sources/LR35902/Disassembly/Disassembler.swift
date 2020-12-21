import Foundation

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

/// A class that owns and manages disassembly information for a given ROM.
public class Disassembler {

  public let cartridge: Gameboy.Cartridge
  public let cartridgeData: Data
  public init(data: Data) {
    self.cartridge = Gameboy.Cartridge(data: data)
    self.cartridgeData = data
  }

  /** Returns true if the program counter is pointing to addressable memory. */
  func pcIsValid(pc: LR35902.Address, bank: LR35902.Bank) -> Bool {
    return
      ((bank == 0 && pc < 0x4000)
        || (bank != 0 && pc < 0x8000))
      && Gameboy.Cartridge.location(for: pc, in: bank)! < cartridge.size
  }

  public func disassembleAsGameboyCartridge() {
    // Restart addresses
    let numberOfRestartAddresses: LR35902.Address = 8
    let restartSize: LR35902.Address = 8
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

  func transfersOfControl(at pc: LR35902.Address, in bank: LR35902.Bank) -> Set<TransferOfControl>? {
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: pc, in: bank) else {
      return nil
    }
    return transfers[cartridgeLocation]
  }
  public func registerTransferOfControl(to pc: LR35902.Address, in bank: LR35902.Bank, from fromPc: LR35902.Address, in fromBank: LR35902.Bank, spec: LR35902.Instruction.Spec) {
    let index = Gameboy.Cartridge.location(for: pc, in: bank)!
    let fromLocation = Gameboy.Cartridge.location(for: fromPc, in: fromBank)!
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
    public let sourceLocation: Gameboy.Cartridge.Location
    public let sourceInstructionSpec: LR35902.Instruction.Spec
  }
  private var transfers: [Gameboy.Cartridge.Location: Set<TransferOfControl>] = [:]

  // MARK: - Instructions

  public func instruction(at pc: LR35902.Address, in bank: LR35902.Bank) -> LR35902.Instruction? {
    let location = Gameboy.Cartridge.location(for: pc, in: bank)!
    guard code.contains(Int(location)) else {
      return nil
    }
    return instructionMap[location]
  }

  func register(instruction: LR35902.Instruction, at pc: LR35902.Address, in bank: LR35902.Bank) {
    let address = Gameboy.Cartridge.location(for: pc, in: bank)!

    // Avoid overlapping instructions.
    if code.contains(Int(address)) && instructionMap[address] == nil {
      return
    }

    instructionMap[address] = instruction
    let instructionRange = Int(address)..<(Int(address) + Int(LR35902.InstructionSet.widths[instruction.spec]!.total))

    // Remove any overlapping instructions.
    let subRange = instructionRange.dropFirst()
    for index in subRange {
      let location = Gameboy.Cartridge.Location(index)
      instructionMap[location] = nil
    }

    code.insert(integersIn: instructionRange)
  }
  var instructionMap: [Gameboy.Cartridge.Location: LR35902.Instruction] = [:]

  // MARK: - Data segments

  public enum DataFormat {
    case bytes
    case image1bpp
    case image2bpp
  }

  public func setData(at address: LR35902.Address, in bank: LR35902.Bank) {
    setData(at: address..<(address+1), in: bank)
  }
  public func setData(at range: Range<LR35902.Address>, in bank: LR35902.Bank, format: DataFormat = .bytes) {
    let lowerBound = Gameboy.Cartridge.location(for: range.lowerBound, in: bank)!
    let upperBound = Gameboy.Cartridge.location(for: range.upperBound, in: bank)!
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
      let location = Gameboy.Cartridge.Location(index)
      if let instruction = instructionMap[location] {
        instructionMap[location] = nil
        let end = Int(location + Gameboy.Cartridge.Location(LR35902.InstructionSet.widths[instruction.spec]!.total))
        if end > range.upperBound {
          code.remove(integersIn: range.upperBound..<end)
        }
      }
      labels[location] = nil
      labelTypes[location] = nil
    }
  }
  func formatOfData(at address: LR35902.Address, in bank: LR35902.Bank) -> DataFormat? {
    let location = Gameboy.Cartridge.location(for: address, in: bank)!
    return dataFormats.first { pair in
      pair.0.contains(location)
    }?.value
  }
  private var dataBlocks = IndexSet()
  private var dataFormats: [Range<Gameboy.Cartridge.Location>: DataFormat] = [:]

  public func setJumpTable(at range: Range<LR35902.Address>, in bank: LR35902.Bank) {
    let lowerBound = Gameboy.Cartridge.location(for: range.lowerBound, in: bank)!
    let upperBound = Gameboy.Cartridge.location(for: range.upperBound, in: bank)!
    jumpTables.insert(integersIn: Int(lowerBound)..<Int(upperBound))

    setData(at: range, in: bank)
  }
  var jumpTables = IndexSet()

  // MARK: - Text segments

  public func setText(at range: Range<LR35902.Address>, in bank: LR35902.Bank, lineLength: Int? = nil) {
    let lowerBound = Gameboy.Cartridge.location(for: range.lowerBound, in: bank)!
    let upperBound = Gameboy.Cartridge.location(for: range.upperBound, in: bank)!
    text.insert(integersIn: Int(lowerBound)..<Int(upperBound))
    if let lineLength = lineLength {
      textLengths[lowerBound..<upperBound] = lineLength
    }
  }
  func lineLengthOfText(at address: LR35902.Address, in bank: LR35902.Bank) -> Int? {
    let location = Gameboy.Cartridge.location(for: address, in: bank)!
    return textLengths.first { pair in
      pair.0.contains(location)
    }?.value
  }
  private var textLengths: [Range<Gameboy.Cartridge.Location>: Int] = [:]

  public func mapCharacter(_ character: UInt8, to string: String) {
    characterMap[character] = string
  }
  var characterMap: [UInt8: String] = [:]

  // MARK: - Bank changes

  func bankChange(at pc: LR35902.Address, in bank: LR35902.Bank) -> LR35902.Bank? {
    return bankChanges[Gameboy.Cartridge.location(for: pc, in: bank)!]
  }

  public func register(bankChange: LR35902.Bank, at pc: LR35902.Address, in bank: LR35902.Bank) {
    bankChanges[Gameboy.Cartridge.location(for: pc, in: bank)!] = bankChange
  }
  private var bankChanges: [Gameboy.Cartridge.Location: LR35902.Bank] = [:]

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
  public func type(of address: LR35902.Address, in bank: LR35902.Bank) -> ByteType {
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank) else {
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

  public func setSoftTerminator(at pc: LR35902.Address, in bank: LR35902.Bank) {
    softTerminators[Gameboy.Cartridge.location(for: pc, in: bank)!] = true
  }
  var softTerminators: [Gameboy.Cartridge.Location: Bool] = [:]

  private func effectiveBank(at pc: LR35902.Address, in bank: LR35902.Bank) -> LR35902.Bank {
    if pc < 0x4000 {
      return 0
    }
    return bank
  }

  public func contiguousScopes(at pc: LR35902.Address, in bank: LR35902.Bank) -> Set<Range<Gameboy.Cartridge.Location>> {
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: pc, in: bank) else {
      return Set()
    }
    return contiguousScopes[effectiveBank(at: pc, in: bank), default: Set()].filter { scope in scope.contains(cartridgeLocation) }
  }
  public func labeledContiguousScopes(at pc: LR35902.Address, in bank: LR35902.Bank) -> [(label: String, scope: Range<Gameboy.Cartridge.Location>)] {
    return contiguousScopes(at: pc, in: bank).compactMap {
      let addressAndBank = Gameboy.Cartridge.addressAndBank(from: $0.lowerBound)
      guard let label = label(at: addressAndBank.address, in: addressAndBank.bank) else {
        return nil
      }
      return (label, $0)
    }
  }
  func addContiguousScope(range: Range<Gameboy.Cartridge.Location>) {
    let bankAndAddress = Gameboy.Cartridge.addressAndBank(from: range.lowerBound)
    let bankAndAddress2 = Gameboy.Cartridge.addressAndBank(from: range.upperBound - 1)
    precondition(bankAndAddress.bank == bankAndAddress2.bank, "Scopes can't cross banks")
    contiguousScopes[effectiveBank(at: bankAndAddress.address, in: bankAndAddress.bank), default: Set()].insert(range)
  }
  var contiguousScopes: [LR35902.Bank: Set<Range<Gameboy.Cartridge.Location>>] = [:]

  public func defineFunction(startingAt pc: LR35902.Address, in bank: LR35902.Bank, named name: String) {
    setLabel(at: pc, in: bank, named: name)
    let upperBound: LR35902.Address = (pc < 0x4000) ? 0x4000 : 0x8000
    disassemble(range: pc..<upperBound, inBank: bank)
  }

  // MARK: - Labels

  public func label(at pc: LR35902.Address, in bank: LR35902.Bank) -> String? {
    guard let index = Gameboy.Cartridge.location(for: pc, in: bank) else {
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
      let bank: LR35902.Bank = (pc < 0x4000) ? 0 : bank
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
      let addressAndBank = Gameboy.Cartridge.addressAndBank(from: firstScope.lowerBound)
      if let firstScopeLabel = label(at: addressAndBank.address, in: addressAndBank.bank)?.components(separatedBy: ".").first {
        return "\(firstScopeLabel).\(name)"
      }
    }

    return name
  }

  func labelLocations(in range: Range<Gameboy.Cartridge.Location>) -> [Gameboy.Cartridge.Location] {
    return range.filter {
      labels[$0] != nil || labelTypes[$0] != nil
    }
  }

  public func setLabel(at pc: LR35902.Address, in bank: LR35902.Bank, named name: String) {
    precondition(!name.contains("."), "Labels cannot contain dots.")
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: pc, inHumanProvided: bank) else {
      preconditionFailure("Attempting to set label in non-cart addressable location.")
    }
    labels[cartridgeLocation] = name
  }
  public var labels: [Gameboy.Cartridge.Location: String] = [:]
  enum LabelType {
    case transferOfControlType
    case elseType
    case returnType
    case loopType
  }
  var labelTypes: [Gameboy.Cartridge.Location: LabelType] = [:]

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

  public func setType(at address: LR35902.Address, in bank: LR35902.Bank, to type: String) {
    precondition(!type.isEmpty, "Invalid type provided.")
    precondition(dataTypes[type] != nil, "\(type) is not a known type.")
    typeAtLocation[Gameboy.Cartridge.location(for: address, in: bank)!] = type
  }
  var typeAtLocation: [Gameboy.Cartridge.Location: String] = [:]

  // MARK: - Comments

  public func preComment(at address: LR35902.Address, in bank: LR35902.Bank) -> String? {
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank) else {
      return nil
    }
    return preComments[cartridgeLocation]
  }
  public func setPreComment(at address: LR35902.Address, in bank: LR35902.Bank, text: String) {
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank) else {
      preconditionFailure("Attempting to set pre-comment in non-cart addressable location.")
    }
    preComments[cartridgeLocation] = text
  }
  private var preComments: [Gameboy.Cartridge.Location: String] = [:]

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
    let bank: LR35902.Bank
    let address: LR35902.Address
  }

  private func fetchInstructionSpec(pc: inout LR35902.Address) -> LR35902.Instruction.Spec {
    // Fetch
    let instructionByte = cartridge.read(from: pc)
    pc += 1

    // Decode
    let spec = LR35902.InstructionSet.table[Int(instructionByte)]
    if let prefixTable = LR35902.InstructionSet.prefixTables[spec] {
      // Fetch
      let cbInstructionByte = cartridge.read(from: pc)
      pc += 1

      // Decode
      return prefixTable[Int(cbInstructionByte)]
    }
    return spec
  }

  private func fetchInstruction(pc: inout LR35902.Address) -> LR35902.Instruction {
    let spec = fetchInstructionSpec(pc: &pc)

    guard let instructionWidth = LR35902.InstructionSet.widths[spec] else {
      preconditionFailure("\(spec) is missing its width, implying a misconfiguration of the instruction set."
                            + " Verify that all specifications are computing and storing a corresponding width in the"
                            + " instruction set's width table.")
    }

    if instructionWidth.operand > 0 {
      var operandBytes: [UInt8] = []
      for _ in 0..<Int(instructionWidth.operand) {
        let byte = cartridge.read(from: pc)
        pc += 1
        operandBytes.append(byte)
      }
      return LR35902.Instruction(spec: spec, immediate: LR35902.Instruction.ImmediateValue(data: Data(operandBytes)))
    }

    return LR35902.Instruction(spec: spec, immediate: nil)
  }

  public func disassemble(range: Range<LR35902.Address>, inBank bankInitial: LR35902.Bank) {
    var visitedAddresses = IndexSet()

    var runQueue = Queue<Disassembler.Run>()
    let firstRun = Run(from: range.lowerBound, initialBank: bankInitial, upTo: range.upperBound)
    runQueue.add(firstRun)

    let queueRun: (Run, LR35902.Address, LR35902.Address, LR35902.Bank, LR35902.Instruction) -> Void = { fromRun, fromAddress, toAddress, bank, instruction in
      if toAddress > 0x8000 {
        return // We can't disassemble in-memory regions.
      }
      guard Gameboy.Cartridge.location(for: toAddress, in: bank) != nil else {
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

      // Initialize the run's program counter
      var runContext = (pc: Gameboy.Cartridge.addressAndBank(from: run.startAddress).address,
                        bank: run.initialBank)

      let advance: (LR35902.Address) -> Void = { amount in
        let currentCartAddress = Gameboy.Cartridge.location(for: runContext.pc, in: runContext.bank)!
        run.visitedRange = run.startAddress..<(currentCartAddress + Gameboy.Cartridge.Location(amount))

        visitedAddresses.insert(integersIn: Int(currentCartAddress)..<Int(currentCartAddress + Gameboy.Cartridge.Location(amount)))

        runContext.pc += amount
      }

      var previousInstruction: LR35902.Instruction? = nil
      linear_sweep: while !run.hasReachedEnd(pc: runContext.pc) && pcIsValid(pc: runContext.pc, bank: runContext.bank) {
        let location = Gameboy.Cartridge.location(for: runContext.pc, in: runContext.bank)!
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
        let instruction = fetchInstruction(pc: &instructionPc)

        // STOP must be followed by 0
        if case .stop = instruction.spec, case let .imm8(immediate) = instruction.immediate, immediate != 0 {
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
          if jumpTo < 0x4000 || runContext.bank > 0 {
            queueRun(run, instructionContext.pc, jumpTo, instructionContext.bank, instruction)
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
            register(bankChange: previousImmediate, at: instructionContext.pc, in: instructionContext.bank)
            runContext.bank = previousImmediate
          }
          let jumpTo = immediate
          if jumpTo < 0x4000 || runContext.bank > 0 {
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

        previousInstruction = instruction
      }
    }

    rewriteScopes(firstRun)
  }
}
