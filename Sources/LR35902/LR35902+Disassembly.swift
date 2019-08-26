import Foundation
import Disassembler

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    let cpu: LR35902
    public init(rom: Data) {
      cpu = LR35902(cartridge: rom)

      createDatatype(named: "bool", enumeration: [0: "false", 1: "true"], representation: .decimal)
      createDatatype(named: "STATF", bitmask: [
        0b0100_0000: "STATF_LYC",
        0b0010_0000: "STATF_MODE10",
        0b0001_0000: "STATF_MODE01",
        0b0000_1000: "STATF_MODE00",
        0b0000_0100: "STATF_LYCF",
        0b0000_0010: "STATF_OAM",
        0b0000_0001: "STATF_VB",
        0b0000_0000: "STATF_HB"
      ])
      createDatatype(named: "decimal", representation: .decimal)
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

      createGlobal(at: 0x8000, named: "gbVRAM")
      createGlobal(at: 0x8800, named: "gbBGCHARDAT")
      createGlobal(at: 0x9800, named: "gbBGDAT0")
      createGlobal(at: 0x9c00, named: "gbBGDAT1")
      createGlobal(at: 0xa000, named: "gbCARTRAM")
      createGlobal(at: 0xc000, named: "gbRAM")
      createGlobal(at: 0xfe00, named: "gbOAMRAM")
      createGlobal(at: 0xff00, named: "gbP1")
      createGlobal(at: 0xff01, named: "gbSB")
      createGlobal(at: 0xff02, named: "gbSC")
      createGlobal(at: 0xff04, named: "gbDIV")
      createGlobal(at: 0xff05, named: "gbTIMA")
      createGlobal(at: 0xff06, named: "gbTMA")
      createGlobal(at: 0xff07, named: "gbTAC")
      createGlobal(at: 0xff0f, named: "gbIF")
      createGlobal(at: 0xff10, named: "gbAUD1SWEEP")
      createGlobal(at: 0xff11, named: "gbAUD1LEN")
      createGlobal(at: 0xff12, named: "gbAUD1ENV")
      createGlobal(at: 0xff13, named: "gbAUD1LOW")
      createGlobal(at: 0xff14, named: "gbAUD1HIGH")
      createGlobal(at: 0xff16, named: "gbAUD2LEN")
      createGlobal(at: 0xff17, named: "gbAUD2ENV")
      createGlobal(at: 0xff18, named: "gbAUD2LOW")
      createGlobal(at: 0xff19, named: "gbAUD2HIGH")
      createGlobal(at: 0xff1a, named: "gbAUD3ENA")
      createGlobal(at: 0xff1b, named: "gbAUD3LEN")
      createGlobal(at: 0xff1c, named: "gbAUD3LEVEL")
      createGlobal(at: 0xff1d, named: "gbAUD3LOW")
      createGlobal(at: 0xff1e, named: "gbAUD3HIGH")
      createGlobal(at: 0xff20, named: "gbAUD4LEN")
      createGlobal(at: 0xff21, named: "gbAUD4ENV")
      createGlobal(at: 0xff22, named: "gbAUD4POLY")
      createGlobal(at: 0xff23, named: "gbAUD4CONSEC")
      createGlobal(at: 0xff24, named: "gbAUDVOL")
      createGlobal(at: 0xff25, named: "gbAUDTERM")
      createGlobal(at: 0xff26, named: "gbAUDENA")
      createGlobal(at: 0xff30, named: "gbAUD3WAVERAM")
      createGlobal(at: 0xff40, named: "gbLCDC")
      createGlobal(at: 0xff41, named: "gbSTAT", dataType: "STATF")
      createGlobal(at: 0xff42, named: "gbSCY")
      createGlobal(at: 0xff43, named: "gbSCX")
      createGlobal(at: 0xff44, named: "gbLY")
      createGlobal(at: 0xff45, named: "gbLYC")
      createGlobal(at: 0xff46, named: "gbDMA")
      createGlobal(at: 0xff47, named: "gbBGP")
      createGlobal(at: 0xff48, named: "gbOBP0")
      createGlobal(at: 0xff49, named: "gbOBP1")
      createGlobal(at: 0xff4a, named: "gbWY")
      createGlobal(at: 0xff4b, named: "gbWX")
      createGlobal(at: 0xff4d, named: "gbKEY1")
      createGlobal(at: 0xff4f, named: "gbVBK")
      createGlobal(at: 0xff51, named: "gbHDMA1")
      createGlobal(at: 0xff52, named: "gbHDMA2")
      createGlobal(at: 0xff53, named: "gbHDMA3")
      createGlobal(at: 0xff54, named: "gbHDMA4")
      createGlobal(at: 0xff55, named: "gbHDMA5")
      createGlobal(at: 0xff56, named: "gbRP")
      createGlobal(at: 0xff68, named: "gbBCPS")
      createGlobal(at: 0xff69, named: "gbBCPD")
      createGlobal(at: 0xff6a, named: "gbOCPS")
      createGlobal(at: 0xff6b, named: "gbOCPD")
      createGlobal(at: 0xff70, named: "gbSVBK")
      createGlobal(at: 0xff76, named: "gbPCM12")
      createGlobal(at: 0xff77, named: "gbPCM34")
      createGlobal(at: 0xff80, named: "gbHRAM")
      createGlobal(at: 0xffff, named: "gbIE", dataType: "bool")

      defineMacro(named: "ifHGte", instructions: [
        .any(.ld(.a, .ffimm8addr)),
        .any(.cp(.imm8)),
        .any(.jr(.nc, .simm8)),
      ], code: [
        .ld(.a, .arg(1)),
        .cp(.arg(2)),
        .jr(.nc, .arg(3)),
      ])

      defineMacro(named: "ifHLt", instructions: [
        .any(.ld(.a, .ffimm8addr)),
        .any(.cp(.imm8)),
        .any(.jr(.c, .simm8)),
        ], code: [
          .ld(.a, .arg(1)),
          .cp(.arg(2)),
          .jr(.c, .arg(3)),
      ])

      defineMacro(named: "_ifLt", instructions: [
        .any(.cp(.imm8)),
        .any(.jr(.c, .simm8)),
        ], code: [
          .cp(.arg(1)),
          .jr(.c, .arg(2)),
      ])

      defineMacro(named: "ifHEq", instructions: [
        .any(.ld(.a, .ffimm8addr)),
        .any(.cp(.imm8)),
        .any(.jr(.z, .simm8)),
        ], code: [
          .ld(.a, .arg(1)),
          .cp(.arg(2)),
          .jr(.z, .arg(3)),
      ])

      defineMacro(named: "ifHEqJp", instructions: [
        .any(.ld(.a, .ffimm8addr)),
        .any(.cp(.imm8)),
        .any(.jp(.z, .imm16)),
      ], code: [
        .ld(.a, .arg(1)),
        .cp(.arg(2)),
        .jp(.z, .arg(3)),
      ])

      defineMacro(named: "ifHNe", instructions: [
        .any(.ld(.a, .ffimm8addr)),
        .any(.cp(.imm8)),
        .any(.jr(.nz, .simm8)),
        ], code: [
          .ld(.a, .arg(1)),
          .cp(.arg(2)),
          .jr(.nz, .arg(3)),
      ])

      defineMacro(named: "_ifNe", instructions: [
        .any(.cp(.imm8)),
        .any(.jr(.nz, .simm8)),
        ], code: [
          .cp(.arg(1)),
          .jr(.nz, .arg(2)),
      ])

      defineMacro(named: "ifGte", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.cp(.imm8)),
        .any(.jr(.nc, .simm8)),
        ], code: [
          .ld(.a, .arg(1)),
          .cp(.arg(2)),
          .jr(.nc, .arg(3)),
      ])

      defineMacro(named: "returnIfLt", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.cp(.imm8)),
        .any(.ret(.c)),
      ], code: [
        .ld(.a, .arg(1)),
        .cp(.arg(2)),
        .ret(.c),
      ])

      defineMacro(named: "returnIfGte", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.cp(.imm8)),
        .any(.ret(.nc)),
      ], code: [
        .ld(.a, .arg(1)),
        .cp(.arg(2)),
        .ret(.nc),
      ])

      defineMacro(named: "returnIfHLt", instructions: [
        .any(.ld(.a, .ffimm8addr)),
        .any(.cp(.imm8)),
        .any(.ret(.c)),
        ], code: [
          .ld(.a, .arg(1)),
          .cp(.arg(2)),
          .ret(.c),
      ])

      defineMacro(named: "returnIfHGte", instructions: [
        .any(.ld(.a, .ffimm8addr)),
        .any(.cp(.imm8)),
        .any(.ret(.nc)),
        ], code: [
          .ld(.a, .arg(1)),
          .cp(.arg(2)),
          .ret(.nc),
      ])

      defineMacro(named: "ifLt", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.cp(.imm8)),
        .any(.jr(.c, .simm8)),
        ], code: [
          .ld(.a, .arg(1)),
          .cp(.arg(2)),
          .jr(.c, .arg(3)),
      ])

      defineMacro(named: "ifEq", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.cp(.imm8)),
        .any(.jr(.z, .simm8)),
        ], code: [
          .ld(.a, .arg(1)),
          .cp(.arg(2)),
          .jr(.z, .arg(3)),
      ])

      defineMacro(named: "ifNe", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.cp(.imm8)),
        .any(.jr(.nz, .simm8)),
        ], code: [
          .ld(.a, .arg(1)),
          .cp(.arg(2)),
          .jr(.nz, .arg(3)),
      ])

      defineMacro(named: "ifZero", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.and(.a)),
        .any(.jr(.z, .simm8)),
        ], code: [
          .ld(.a, .arg(1)),
          .and(.a),
          .jr(.z, .arg(2)),
      ])

      defineMacro(named: "ifZeroJp", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.and(.a)),
        .any(.jp(.z, .imm16)),
        ], code: [
          .ld(.a, .arg(1)),
          .and(.a),
          .jp(.z, .arg(2)),
      ])

      defineMacro(named: "ifNotZero", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.and(.a)),
        .any(.jr(.nz, .simm8)),
        ], code: [
          .ld(.a, .arg(1)),
          .and(.a),
          .jr(.nz, .arg(2)),
      ])

      defineMacro(named: "ifNotZeroJp", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.and(.a)),
        .any(.jp(.nz, .imm16)),
        ], code: [
          .ld(.a, .arg(1)),
          .and(.a),
          .jp(.nz, .arg(2)),
      ])

      defineMacro(named: "assignH", instructions: [
        .any(.ld(.a, .imm8)),
        .any(.ld(.ffimm8addr, .a)),
      ], code: [
        .ld(.a, .arg(2)),
        .ld(.arg(1), .a),
      ])

      defineMacro(named: "assign", instructions: [
        .any(.ld(.a, .imm8)),
        .any(.ld(.imm16addr, .a)),
      ], code: [
        .ld(.a, .arg(2)),
        .ld(.arg(1), .a),
      ])

      defineMacro(named: "copyMemory", instructions: [
        .any(.ld(.a, .imm16addr)),
        .any(.ld(.imm16addr, .a)),
      ], code: [
        .ld(.a, .arg(1)),
        .ld(.arg(2), .a),
      ])

      defineMacro(named: "copyMemoryH", instructions: [
        .any(.ld(.a, .ffimm8addr)),
        .any(.ld(.ffimm8addr, .a)),
      ], code: [
        .ld(.a, .arg(1)),
        .ld(.arg(2), .a),
      ])
    }

    // MARK: - Transfers of control

    struct TransferOfControl: Hashable {
      let sourceLocation: CartridgeLocation
      let sourceInstructionSpec: Instruction.Spec
    }
    func transfersOfControl(at pc: Address, in bank: Bank) -> Set<TransferOfControl>? {
      guard let cartAddress = cartAddress(for: pc, in: bank) else {
        return nil
      }
      return transfers[cartAddress]
    }

    public func registerTransferOfControl(to pc: Address, in bank: Bank, from fromPc: Address, in fromBank: Bank, spec: Instruction.Spec) {
      let index = cartAddress(for: pc, in: bank)!
      let fromLocation = cartAddress(for: fromPc, in: fromBank)!
      let transfer = TransferOfControl(sourceLocation: fromLocation, sourceInstructionSpec: spec)
      transfers[index, default: Set()].insert(transfer)

      // Create a label if one doesn't exist.
      if labels[index] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(Int(index)) || instruction(at: pc, in: bank) != nil),
        let label = RGBDSAssembly.defaultLabel(at: pc, in: bank) {
        setLabel(at: pc, in: bank, named: label)
      }
    }
    private var transfers: [CartridgeLocation: Set<TransferOfControl>] = [:]

    // MARK: - Instructions

    func instruction(at pc: Address, in bank: Bank) -> Instruction? {
      let location = cartAddress(for: pc, in: bank)!
      guard code.contains(Int(location)) else {
        return nil
      }
      return instructionMap[location]
    }

    func register(instruction: Instruction, at pc: Address, in bank: Bank) {
      let address = cartAddress(for: pc, in: bank)!

      // Avoid overlapping instructions.
      if code.contains(Int(address)) && instructionMap[address] == nil {
        return
      }

      instructionMap[address] = instruction
      let instructionRange = Int(address)..<(Int(address) + Int(Instruction.widths[instruction.spec]!.total))

      // Remove any overlapping instructions.
      for index in instructionRange.dropFirst() {
        let location = LR35902.CartridgeLocation(index)
        instructionMap[location] = nil
      }

      code.insert(integersIn: instructionRange)
    }
    var instructionMap: [CartridgeLocation: Instruction] = [:]

    // MARK: - Data segments

    public func setData(at address: Address, in bank: Bank) {
      setData(at: address..<(address+1), in: bank)
    }
    public func setData(at range: Range<Address>, in bank: Bank) {
      let lowerBound = cartAddress(for: range.lowerBound, in: bank)!
      let upperBound = cartAddress(for: range.upperBound, in: bank)!
      let cartRange = lowerBound..<upperBound
      dataRanges.insert(cartRange)

      // Shorten any contiguous scopes that contain this data.
      let overlappingScopes = contiguousScopes.filter { $0.overlaps(cartRange) }
      for scope in overlappingScopes {
        if cartRange.lowerBound < scope.upperBound {
          contiguousScopes.remove(scope)
          contiguousScopes.insert(scope.lowerBound..<cartRange.lowerBound)
        }
      }

      let range = Int(lowerBound)..<Int(upperBound)
      data.insert(integersIn: range)
      text.remove(integersIn: range)
      code.remove(integersIn: range)
      for index in range.dropFirst() {
        let location = LR35902.CartridgeLocation(index)
        if let instruction = instructionMap[location] {
          instructionMap[location] = nil
          let end = Int(location + LR35902.CartridgeLocation(LR35902.Instruction.widths[instruction.spec]!.total))
          if end > range.upperBound {
            code.remove(integersIn: range.upperBound..<end)
          }
        }
        labels[location] = nil
      }
    }
    var dataRanges = Set<Range<CartridgeLocation>>()

    public func setJumpTable(at range: Range<Address>, in bank: Bank) {
      let lowerBound = cartAddress(for: range.lowerBound, in: bank)!
      let upperBound = cartAddress(for: range.upperBound, in: bank)!
      jumpTables.insert(lowerBound..<upperBound)

      setData(at: range, in: bank)
    }
    var jumpTables = Set<Range<CartridgeLocation>>()

    // MARK: - Text segments

    public func setText(at range: Range<Address>, in bank: Bank, lineLength: Int? = nil) {
      let lowerBound = cartAddress(for: range.lowerBound, in: bank)!
      let upperBound = cartAddress(for: range.upperBound, in: bank)!
      text.insert(integersIn: Int(lowerBound)..<Int(upperBound))
      if let lineLength = lineLength {
        textLengths[lowerBound..<upperBound] = lineLength
      }
    }
    func lineLengthOfText(at address: Address, in bank: Bank) -> Int? {
      let location = cartAddress(for: address, in: bank)!
      return textLengths.first { pair in
        pair.0.contains(location)
      }?.value
    }
    private var textLengths: [Range<CartridgeLocation>: Int] = [:]

    // MARK: - Bank changes

    func bankChange(at pc: Address, in bank: Bank) -> Bank? {
      return bankChanges[cartAddress(for: pc, in: bank)!]
    }

    public func register(bankChange: Bank, at pc: Address, in bank: Bank) {
      bankChanges[cartAddress(for: pc, in: bank)!] = bankChange
    }
    private var bankChanges: [CartridgeLocation: Bank] = [:]

    // MARK: - Regions

    public enum ByteType {
      case unknown
      case code
      case data
      case jumpTable
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
      } else if jumpTables.contains(where: { $0.contains(cartAddress) }) {
        return .jumpTable
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

    public func knownLocations() -> IndexSet {
      return code.union(data).union(text)
    }

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

    public func contiguousScopes(at pc: Address, in bank: Bank) -> Set<Range<CartridgeLocation>> {
      guard let cartAddress = cartAddress(for: pc, in: bank) else {
        return Set()
      }
      return contiguousScopes.filter { scope in scope.contains(cartAddress) }
    }
    public func labeledContiguousScopes(at pc: Address, in bank: Bank) -> [(label: String, scope: Range<CartridgeLocation>)] {
      return contiguousScopes(at: pc, in: bank).compactMap {
        let addressAndBank = LR35902.addressAndBank(from: $0.lowerBound)
        guard let label = label(at: addressAndBank.address, in: addressAndBank.bank) else {
          return nil
        }
        return (label, $0)
      }
    }
    func addContiguousScope(range: Range<CartridgeLocation>) {
      contiguousScopes.insert(range)
    }
    var contiguousScopes = Set<Range<CartridgeLocation>>()

    public func defineFunction(startingAt pc: Address, in bank: Bank, named name: String) {
      guard let cartAddress = safeCartAddress(for: pc, in: bank) else {
        preconditionFailure("Attempting to set label in non-cart addressable location.")
      }

      setLabel(at: pc, in: bank, named: name)
      functions[cartAddress] = name

      let upperBound: Address = (pc < 0x4000) ? 0x4000 : 0x8000
      disassemble(range: pc..<upperBound, inBank: bank)
    }
    private var functions: [CartridgeLocation: String] = [:]

    func expandScope(forLabel label: String, scope: IndexSet) {
      scopes[label, default: IndexSet()].formUnion(scope)
    }
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
      // Don't return labels that point to the middle of data.
      if data.contains(Int(index)) && dataRanges.contains(where: { $0.dropFirst().contains(index) }) {
        return nil
      }

      guard let name = labels[index] else {
        return nil
      }

      let scopes = contiguousScopes(at: pc, in: bank)
      if let firstScope = scopes.filter({ scope -> Bool in
        scope.lowerBound != index // Ignore ourself.
      }).sorted(by: { (scope1, scope2) -> Bool in
        scope1.lowerBound < scope2.lowerBound
      }).first {
        let addressAndBank = LR35902.addressAndBank(from: firstScope.lowerBound)
        if let firstScopeLabel = label(at: addressAndBank.address, in: addressAndBank.bank)?.components(separatedBy: ".").first {
          return "\(firstScopeLabel).\(name)"
        }
      }

      return name
    }

    func labelLocations(in range: Range<CartridgeLocation>) -> [CartridgeLocation] {
      return range.filter {
        labels[$0] != nil
      }
    }

    public func setLabel(at pc: Address, in bank: Bank, named name: String) {
      precondition(!name.contains("."), "Labels cannot contain dots.")
      guard let cartAddress = safeCartAddress(for: pc, in: bank) else {
        preconditionFailure("Attempting to set label in non-cart addressable location.")
      }
      labels[cartAddress] = name
    }
    var labels: [CartridgeLocation: String] = [:]

    // MARK: - Globals

    // TODO: Allow defining variable types, e.g. enums with well-understood values.
    public func createGlobal(at address: Address, named name: String, dataType: String? = nil) {
      precondition(globals[address] == nil, "Global already exists at \(address).")
      if let dataType = dataType {
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
        self.dataType = dataType
      }
    }
    var globals: [Address: Global] = [:]

    public struct Datatype {
      let namedValues: [UInt8: String]
      let interpretation: Interpretation
      let representation: Representation

      public enum Interpretation {
        case any
        case enumerated
        case bitmask
      }

      public enum Representation {
        case decimal
        case hexadecimal
        case binary
      }
    }
    public func createDatatype(named name: String, enumeration: [UInt8: String], representation: Datatype.Representation = .hexadecimal) {
      precondition(dataTypes[name] == nil, "Data type \(name) already exists.")
      assert(Set(enumeration.values).count == enumeration.count, "There exist duplicate enumeration names.")
      dataTypes[name] = Datatype(namedValues: enumeration, interpretation: .enumerated, representation: representation)
    }
    public func createDatatype(named name: String, bitmask: [UInt8: String], representation: Datatype.Representation = .binary) {
      precondition(dataTypes[name] == nil, "Data type \(name) already exists.")
      dataTypes[name] = Datatype(namedValues: bitmask, interpretation: .bitmask, representation: representation)
    }
    public func createDatatype(named name: String, representation: Datatype.Representation) {
      precondition(dataTypes[name] == nil, "Data type \(name) already exists.")
      dataTypes[name] = Datatype(namedValues: [:], interpretation: .any, representation: representation)
    }
    public func valuesForDatatype(named name: String) -> [UInt8: String]? {
      return dataTypes[name]?.namedValues
    }
    var dataTypes: [String: Datatype] = [:]

    public func setType(at address: LR35902.Address, in bank: LR35902.Bank, to type: String) {
      precondition(dataTypes[type] != nil, "\(type) is not a known type.")
      typeAtLocation[LR35902.cartAddress(for: address, in: bank)!] = type
    }
    var typeAtLocation: [LR35902.CartridgeLocation: String] = [:]

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
    private var preComments: [CartridgeLocation: String] = [:]

    // MARK: - Macros

    public enum MacroLine: Hashable {
      case any(Instruction.Spec)
      case instruction(Instruction)
    }
    public func defineMacro(named name: String,
                            instructions: [MacroLine],
                            code: [Instruction.Spec]? = nil,
                            validArgumentValues: [Int: IndexSet]? = nil,
                            action: (([Int: String], LR35902.Address, LR35902.Bank) -> Void)? = nil) {
      let leaf = instructions.reduce(macroTree, { node, spec in
        let child = node.children[spec, default: MacroNode()]
        node.children[spec] = child
        return child
      })
      leaf.macros.append(.init(name: name, macroLines: instructions, code: code, validArgumentValues: validArgumentValues, action: action))
    }
    public func defineMacro(named name: String, template: String) {
      let assembler = RGBDSAssembler()
      let errors = assembler.assemble(assembly: template)
      guard errors.isEmpty else {
        preconditionFailure("\(errors)")
      }
      defineMacro(named: name, instructions: assembler.instructions.map { .instruction($0) })
    }

    public final class Macro {
      let name: String
      let macroLines: [MacroLine]
      let code: [Instruction.Spec]?
      let validArgumentValues: [Int: IndexSet]?
      let action: (([Int: String], LR35902.Address, LR35902.Bank) -> Void)?
      var hasWritten = false

      init(name: String, macroLines: [MacroLine], code: [Instruction.Spec]?, validArgumentValues: [Int: IndexSet]?, action: (([Int: String], LR35902.Address, LR35902.Bank) -> Void)?) {
        self.name = name
        self.macroLines = macroLines
        self.code = code
        self.validArgumentValues = validArgumentValues
        self.action = action
      }
    }
    public final class MacroNode {
      var children: [MacroLine: MacroNode] = [:]
      var macros: [Macro] = []
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
        guard LR35902.cartAddress(for: toAddress, in: bank) != nil else {
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
        cpu.pc = LR35902.addressAndBank(from: run.startAddress).address

        let advance: (Address) -> Void = { amount in
          let currentCartAddress = cartAddress(for: self.cpu.pc, in: self.cpu.bank)!
          run.visitedRange = run.startAddress..<(currentCartAddress + CartridgeLocation(amount))

          visitedAddresses.insert(integersIn: Int(currentCartAddress)..<Int(currentCartAddress + CartridgeLocation(amount)))

          self.cpu.pc += amount
        }

        var previousInstruction: Instruction? = nil
        linear_sweep: while !run.hasReachedEnd(with: cpu) && cpu.pcIsValid() {
          if data.contains(Int(LR35902.cartAddress(for: cpu.pc, in: cpu.bank)!))
           || text.contains(Int(LR35902.cartAddress(for: cpu.pc, in: cpu.bank)!)) {
            advance(1)
            continue
          }
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

          if let bankChange = bankChange(at: cpu.pc, in: cpu.bank) {
            cpu.bank = bankChange
          }

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
            // TODO: Rewrite these with a macro dector during disassembly time.
          case .ld(.imm16addr, .a):
            if (0x2000..<0x4000).contains(instruction.imm16!),
              let previousInstruction = previousInstruction,
              case .ld(.a, .imm8) = previousInstruction.spec {
              register(bankChange: previousInstruction.imm8!, at: instructionAddress, in: instructionBank)

              cpu.bank = previousInstruction.imm8!
            }
          case .ld(.hladdr, .imm8):
            if case .ld(.hl, .imm16) = previousInstruction?.spec,
              (0x2000..<0x4000).contains(previousInstruction!.imm16!) {
              register(bankChange: instruction.imm8!, at: instructionAddress, in: instructionBank)
              cpu.bank = instruction.imm8!
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
            if jumpTo < 0x4000 || cpu.bank > 0 {
              queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)
            }

            // An unconditional jp is the end of the run.
            if condition == nil {
              break linear_sweep
            }

          case .call(let condition, .imm16):
            // TODO: Allow the user to define macros like this.
            if condition == nil,
              instruction.imm16! == 0x07b9,
              let previousInstruction = previousInstruction,
              case .ld(.a, .imm8) = previousInstruction.spec {
              register(bankChange: previousInstruction.imm8!, at: instructionAddress, in: instructionBank)
              cpu.bank = previousInstruction.imm8!
            }
            let jumpTo = instruction.imm16!
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
