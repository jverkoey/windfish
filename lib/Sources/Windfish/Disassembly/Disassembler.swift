import Foundation
import JavaScriptCore

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

private final class DisassemblerMemory: AddressableMemory {
  init(data: Data) {
    self.data = data
  }
  let data: Data

  var selectedBank: Gameboy.Cartridge.Bank = 0

  func read(from address: LR35902.Address) -> UInt8 {
    // Read-only memory (ROM) bank 00
    if address <= 0x3FFF {
      return data[Int(address)]
    }

    // Read-only memory (ROM) bank 01-7F
    if address >= 0x4000 && address <= 0x7FFF {
      guard let location = Gameboy.Cartridge.location(for: address, in: max(1, selectedBank)) else {
        preconditionFailure("Invalid location for address 0x\(address.hexString) in bank 0x\(selectedBank.hexString)")
      }
      return data[Int(location)]
    }

    fatalError()
  }

  func write(_ byte: UInt8, to address: LR35902.Address) {
    fatalError()
  }

  func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .cartridge(Gameboy.Cartridge.location(for: address, in: (selectedBank == 0) ? 1 : selectedBank)!)
  }
}

/// A class that owns and manages disassembly information for a given ROM.
public class Disassembler {

  private let memory: DisassemblerMemory
  let cartridgeData: Data
  let cartridgeSize: Gameboy.Cartridge.Length
  public let numberOfBanks: Gameboy.Cartridge.Bank
  public init(data: Data) {
    self.cartridgeData = data
    self.memory = DisassemblerMemory(data: data)
    self.cartridgeSize = Gameboy.Cartridge.Length(data.count)
    self.numberOfBanks = Gameboy.Cartridge.Bank((cartridgeSize + Gameboy.Cartridge.bankSize - 1) / Gameboy.Cartridge.bankSize)
  }

  /** Returns true if the program counter is pointing to addressable memory. */
  func pcIsValid(pc: LR35902.Address, bank: Gameboy.Cartridge.Bank) -> Bool {
    return pc < 0x8000 && Gameboy.Cartridge.location(for: pc, in: bank)! < cartridgeSize
  }

  public func disassembleAsGameboyCartridge() {
    // Restart addresses
    let numberOfRestartAddresses: LR35902.Address = 8
    let restartSize: LR35902.Address = 8
    let rstAddresses = (0..<numberOfRestartAddresses).map { ($0 * restartSize)..<($0 * restartSize + restartSize) }
    rstAddresses.forEach {
      setLabel(at: $0.lowerBound, in: 0x01, named: "RST_\($0.lowerBound.hexString)")
      disassemble(range: $0, inBank: 0x01)
    }

    disassemble(range: 0x0040..<0x0048, inBank: 0x01)
    disassemble(range: 0x0048..<0x0050, inBank: 0x01)
    disassemble(range: 0x0050..<0x0058, inBank: 0x01)
    disassemble(range: 0x0058..<0x0060, inBank: 0x01)
    disassemble(range: 0x0060..<0x0068, inBank: 0x01)
    disassemble(range: 0x0100..<0x0104, inBank: 0x01)

    setData(at: 0x0104..<0x0134, in: 0x01)
    setText(at: 0x0134..<0x0143, in: 0x01)
    setData(at: 0x0144..<0x0146, in: 0x01)
    setData(at: 0x0147, in: 0x01)
    setData(at: 0x014B, in: 0x01)
    setData(at: 0x014C, in: 0x01)
    setData(at: 0x014D, in: 0x01)
    setData(at: 0x014E..<0x0150, in: 0x01)
  }

  // MARK: - Representing source locations

  /** A representation of the location from which an instruction was disassembled. */
  public enum SourceLocation: Equatable {
    /** The instruction was disassembled from a location in the cartridge data. */
    case cartridge(Gameboy.Cartridge.Location)

    /** The instruction was disassembled from the gameboy's memory. */
    case memory(LR35902.Address)
  }

  /**
   Returns a source location for the given program counter and bank.

   - Parameter address: An address in the gameboy's memory.
   - Parameter bank: The selected bank.
   */
  public static func sourceLocation(for address: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> SourceLocation {
    precondition(bank > 0)
    if let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank) {
      return .cartridge(cartridgeLocation)
    }
    return .memory(address)
  }

  // MARK: - Transfers of control

  func transfersOfControl(at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> Set<TransferOfControl>? {
    precondition(bank > 0)
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: pc, in: bank) else {
      return nil
    }
    return transfers[cartridgeLocation]
  }
  public func registerTransferOfControl(to pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank, from fromPc: LR35902.Address, in fromBank: Gameboy.Cartridge.Bank, spec: LR35902.Instruction.Spec) {
    precondition(bank > 0)
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

  public func instruction(at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> LR35902.Instruction? {
    precondition(bank > 0)
    guard let location = Gameboy.Cartridge.location(for: pc, in: bank) else {
      return nil
    }
    guard code.contains(Int(location)) else {
      return nil
    }
    return instructionMap[location]
  }

  func register(instruction: LR35902.Instruction, at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) {
    precondition(bank > 0)
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

  public func setData(at address: LR35902.Address, in bank: Gameboy.Cartridge.Bank) {
    precondition(bank > 0)
    setData(at: address..<(address+1), in: bank)
  }
  public func setData(at range: Range<LR35902.Address>, in bank: Gameboy.Cartridge.Bank, format: DataFormat = .bytes) {
    precondition(bank > 0)
    let lowerBound = Gameboy.Cartridge.location(for: range.lowerBound, in: bank)!
    let upperBound = Gameboy.Cartridge.location(for: range.upperBound, in: bank)!
    let cartRange = lowerBound..<upperBound
    dataBlocks.insert(integersIn: Int(lowerBound + 1)..<Int(upperBound))
    dataFormats[cartRange] = format

    let scopeBank = effectiveBank(at: range.lowerBound, in: bank)
    precondition(scopeBank > 0)
    // Shorten any contiguous scopes that contain this data.
    let overlappingScopes = contiguousScopes[scopeBank, default: Set()].filter { $0.overlaps(cartRange) }
    for scope in overlappingScopes {
      if cartRange.lowerBound < scope.upperBound {
        contiguousScopes[scopeBank, default: Set()].remove(scope)
        contiguousScopes[scopeBank, default: Set()].insert(scope.lowerBound..<cartRange.lowerBound)
      }
    }

    clearCode(in: cartRange)
    let range = Int(lowerBound)..<Int(upperBound)
    data.insert(integersIn: range)
    text.remove(integersIn: range)
  }
  private func clearCode(in _range: Range<Gameboy.Cartridge.Location>) {
    let range = Int(_range.lowerBound)..<Int(_range.upperBound)
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

  func formatOfData(at address: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> DataFormat? {
    precondition(bank > 0)
    let location = Gameboy.Cartridge.location(for: address, in: bank)!
    return dataFormats.first { pair in
      pair.0.contains(location)
    }?.value
  }
  private var dataBlocks = IndexSet()
  private var dataFormats: [Range<Gameboy.Cartridge.Location>: DataFormat] = [:]

  public func setJumpTable(at range: Range<LR35902.Address>, in bank: Gameboy.Cartridge.Bank) {
    precondition(bank > 0)
    let lowerBound = Gameboy.Cartridge.location(for: range.lowerBound, in: bank)!
    let upperBound = Gameboy.Cartridge.location(for: range.upperBound, in: bank)!
    jumpTables.insert(integersIn: Int(lowerBound)..<Int(upperBound))

    setData(at: range, in: bank)
  }
  var jumpTables = IndexSet()

  // MARK: - Text segments

  public func setText(at range: Range<LR35902.Address>, in bank: Gameboy.Cartridge.Bank, lineLength: Int? = nil) {
    precondition(bank > 0)
    let lowerBound = Gameboy.Cartridge.location(for: range.lowerBound, in: bank)!
    let upperBound = Gameboy.Cartridge.location(for: range.upperBound, in: bank)!
    clearCode(in: lowerBound..<upperBound)
    let range = Int(lowerBound)..<Int(upperBound)
    text.insert(integersIn: range)
    data.remove(integersIn: range)
    if let lineLength = lineLength {
      textLengths[lowerBound..<upperBound] = lineLength
    }
  }
  func lineLengthOfText(at address: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> Int? {
    precondition(bank > 0)
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

  func bankChange(at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> Gameboy.Cartridge.Bank? {
    precondition(bank > 0)
    return bankChanges[Gameboy.Cartridge.location(for: pc, in: bank)!]
  }

  public func register(bankChange: Gameboy.Cartridge.Bank, at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) {
    precondition(bank > 0)
    bankChanges[Gameboy.Cartridge.location(for: pc, in: bank)!] = bankChange
  }
  private var bankChanges: [Gameboy.Cartridge.Location: Gameboy.Cartridge.Bank] = [:]

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
  public func type(of address: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> ByteType {
    precondition(bank > 0)
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

  public func setSoftTerminator(at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) {
    precondition(bank > 0)
    softTerminators[Gameboy.Cartridge.location(for: pc, in: bank)!] = true
  }
  var softTerminators: [Gameboy.Cartridge.Location: Bool] = [:]

  private func effectiveBank(at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> Gameboy.Cartridge.Bank {
    if pc < 0x4000 {
      return 1
    }
    return bank
  }

  public func contiguousScopes(at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> Set<Range<Gameboy.Cartridge.Location>> {
    precondition(bank > 0)
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: pc, in: bank) else {
      return Set()
    }
    return contiguousScopes[effectiveBank(at: pc, in: bank), default: Set()].filter { scope in scope.contains(cartridgeLocation) }
  }
  public func labeledContiguousScopes(at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> [(label: String, scope: Range<Gameboy.Cartridge.Location>)] {
    precondition(bank > 0)
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
  var contiguousScopes: [Gameboy.Cartridge.Bank: Set<Range<Gameboy.Cartridge.Location>>] = [:]

  public func defineFunction(startingAt pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank, named name: String) {
    precondition(bank > 0)
    setLabel(at: pc, in: bank, named: name)
    let upperBound: LR35902.Address = (pc < 0x4000) ? 0x4000 : 0x8000
    disassemble(range: pc..<upperBound, inBank: bank)
  }

  // MARK: - Labels

  public func label(at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> String? {
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
      let bank: Gameboy.Cartridge.Bank = (pc < 0x4000) ? 1 : bank
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

  public func setLabel(at pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank, named name: String) {
    precondition(bank > 0)
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
      setLabel(at: address, in: 0x01, named: name)
      setData(at: address, in: 0x01)
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

  public func setType(at address: LR35902.Address, in bank: Gameboy.Cartridge.Bank, to type: String) {
    precondition(!type.isEmpty, "Invalid type provided.")
    precondition(dataTypes[type] != nil, "\(type) is not a known type.")
    typeAtLocation[Gameboy.Cartridge.location(for: address, in: bank)!] = type
  }
  var typeAtLocation: [Gameboy.Cartridge.Location: String] = [:]

  // MARK: - Comments

  public func preComment(at address: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> String? {
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank) else {
      return nil
    }
    return preComments[cartridgeLocation]
  }
  public func setPreComment(at address: LR35902.Address, in bank: Gameboy.Cartridge.Bank, text: String) {
    guard let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank) else {
      preconditionFailure("Attempting to set pre-comment in non-cart addressable location.")
    }
    preComments[cartridgeLocation] = text
  }
  private var preComments: [Gameboy.Cartridge.Location: String] = [:]

  // MARK: - Scripts
  public final class Script {
    init(source: String) {
      self.source = source
    }
    let source: String
    var context: JSContext?
    var linearSweepDidStep: JSValue?
    var disassemblyWillStart: JSValue?

    func prepareForRun() {
      // TODO: Provide a linearSweepDidStart method rather than blowing away the context on each run
      let context = JSContext()!
      context.exceptionHandler = { context, exception in
        print(exception)
      }
      context.evaluateScript(source)
      self.context = context
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
                          action: (([Int: String], LR35902.Address, Gameboy.Cartridge.Bank) -> Void)? = nil) {
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
    let action: (([Int: String], LR35902.Address, Gameboy.Cartridge.Bank) -> Void)?

    init(name: String, macroLines: [MacroLine], validArgumentValues: [Int: IndexSet]?, action: (([Int: String], LR35902.Address, Gameboy.Cartridge.Bank) -> Void)?) {
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
    let bank: Gameboy.Cartridge.Bank
    let address: LR35902.Address
  }

  public static func fetchInstructionSpec(pc: inout LR35902.Address, memory: AddressableMemory) -> LR35902.Instruction.Spec {
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

  public static func fetchInstruction(at address: inout LR35902.Address, memory: AddressableMemory) -> LR35902.Instruction {
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
    for script in scripts.values {
      script.prepareForRun()
    }

    // Extract any scripted events.
    let disassemblyWillStarts = scripts.values.filter { $0.disassemblyWillStart != nil }
    guard !disassemblyWillStarts.isEmpty else {
      return  // Nothing to do here.
    }

    // Script functions
    let getROMData: @convention(block) (Int, Int, Int) -> [UInt8] = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return []
      }
      let startLocation = Gameboy.Cartridge.location(for: LR35902.Address(truncatingIfNeeded: startAddress),
                                                     inHumanProvided: Gameboy.Cartridge.Bank(truncatingIfNeeded: bank))!
      let endLocation = Gameboy.Cartridge.location(for: LR35902.Address(truncatingIfNeeded: endAddress),
                                                   inHumanProvided: Gameboy.Cartridge.Bank(truncatingIfNeeded: bank))!
      return [UInt8](self.cartridgeData[startLocation..<endLocation])
    }
    let registerText: @convention(block) (Int, Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress, lineLength in
      guard let self = self else {
        return
      }
      self.setText(at: LR35902.Address(truncatingIfNeeded: startAddress)..<LR35902.Address(truncatingIfNeeded: endAddress),
                   in: max(1, Gameboy.Cartridge.Bank(truncatingIfNeeded: bank)),
                   lineLength: lineLength)
    }
    let registerData: @convention(block) (Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return
      }
      self.setData(at: LR35902.Address(truncatingIfNeeded: startAddress)..<LR35902.Address(truncatingIfNeeded: endAddress),
                   in: max(1, Gameboy.Cartridge.Bank(truncatingIfNeeded: bank)))
    }
    let registerJumpTable: @convention(block) (Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return
      }
      self.setJumpTable(at: LR35902.Address(truncatingIfNeeded: startAddress)..<LR35902.Address(truncatingIfNeeded: endAddress),
                        in: max(1, Gameboy.Cartridge.Bank(truncatingIfNeeded: bank)))
    }
    let registerTransferOfControl: @convention(block) (Int, Int, Int, Int, Int) -> Void = { [weak self] toBank, toAddress, fromBank, fromAddress, opcode in
      guard let self = self else {
        return
      }
      self.registerTransferOfControl(
        to: LR35902.Address(truncatingIfNeeded: toAddress), in: max(1, Gameboy.Cartridge.Bank(truncatingIfNeeded: toBank)),
        from: LR35902.Address(truncatingIfNeeded: fromAddress), in: max(1, Gameboy.Cartridge.Bank(truncatingIfNeeded: fromBank)),
        spec: LR35902.InstructionSet.table[opcode]
      )
    }
    let registerFunction: @convention(block) (Int, Int, String) -> Void = { [weak self] bank, address, name in
      guard let self = self else {
        return
      }
      self.defineFunction(startingAt: LR35902.Address(truncatingIfNeeded: address),
                          in: max(1, Gameboy.Cartridge.Bank(truncatingIfNeeded: bank)),
                          named: name)
    }
    let registerBankChange: @convention(block) (Int, Int, Int) -> Void = { [weak self] _desiredBank, address, bank in
      guard let self = self else {
        return
      }
      let desiredBank = Gameboy.Cartridge.Bank(truncatingIfNeeded: _desiredBank)
      self.register(
        bankChange: max(1, desiredBank),
        at: LR35902.Address(truncatingIfNeeded: address),
        in: max(1, Gameboy.Cartridge.Bank(truncatingIfNeeded: bank))
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

    for script in disassemblyWillStarts {
      script.context?.setObject(getROMData, forKeyedSubscript: "getROMData" as NSString)
      script.context?.setObject(registerText, forKeyedSubscript: "registerText" as NSString)
      script.context?.setObject(registerData, forKeyedSubscript: "registerData" as NSString)
      script.context?.setObject(registerJumpTable, forKeyedSubscript: "registerJumpTable" as NSString)
      script.context?.setObject(registerTransferOfControl, forKeyedSubscript: "registerTransferOfControl" as NSString)
      script.context?.setObject(registerFunction, forKeyedSubscript: "registerFunction" as NSString)
      script.context?.setObject(registerBankChange, forKeyedSubscript: "registerBankChange" as NSString)
      script.context?.setObject(hex16, forKeyedSubscript: "hex16" as NSString)
      script.context?.setObject(hex8, forKeyedSubscript: "hex8" as NSString)
      script.context?.setObject(log, forKeyedSubscript: "log" as NSString)
      script.disassemblyWillStart?.call(withArguments: [])
    }
  }

  public func disassemble(range: Range<LR35902.Address>, inBank bankInitial: Gameboy.Cartridge.Bank) {
    var visitedAddresses = IndexSet()

    var runQueue = Queue<Disassembler.Run>()
    let firstRun = Run(from: range.lowerBound, initialBank: bankInitial, upTo: range.upperBound)
    runQueue.add(firstRun)

    let queueRun: (Run, LR35902.Address, LR35902.Address, Gameboy.Cartridge.Bank, LR35902.Instruction) -> Void = { fromRun, fromAddress, toAddress, bank, instruction in
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

      // Script functions
      let registerBankChange: @convention(block) (Int, Int, Int) -> Void = { [weak self] _desiredBank, address, bank in
        guard let self = self else {
          return
        }
        let desiredBank = Gameboy.Cartridge.Bank(truncatingIfNeeded: _desiredBank)
        self.register(
          bankChange: max(1, desiredBank),
          at: LR35902.Address(truncatingIfNeeded: address),
          in: max(1, Gameboy.Cartridge.Bank(truncatingIfNeeded: bank))
        )
        runContext.bank = desiredBank
      }

      // Prepare all scripts for the next run
      // TODO: Only do this for scripts that have wired up run event hooks
      for script in scripts.values {
        script.prepareForRun()
        script.context?.setObject(registerBankChange, forKeyedSubscript: "registerBankChange" as NSString)
      }

      // Extract any scripted events.
      let linearSweepDidSteps = scripts.values.compactMap { $0.linearSweepDidStep }

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
            linearSweepDidStep.call(withArguments: args)
          }
        }

        previousInstruction = instruction
      }
    }

    rewriteScopes(firstRun)
  }
}
