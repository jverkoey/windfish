import Foundation

extension LR35902.Disassembly {
  func rewriteScopes(_ run: LR35902.Disassembly.Run) {
    // Compute scope and rewrite function labels if we're a function.

    for runGroup in run.runGroups() {
      // TODO: We should do this after all disassembly has been done and before writing to disk.
      for run in runGroup {
        guard let visitedRange = run.visitedRange else {
          continue
        }
        inferVariableTypes(in: visitedRange)
      }
      guard let runStartAddress = runGroup.startAddress,
        let runGroupLabel = labels[runStartAddress],
        let runGroupName = runGroupLabel.components(separatedBy: ".").first else {
        continue
      }

      // Expand scopes for the label.
      // TODO: This doesn't work well if the labels change after the scope has been defined.
      // TODO: Labels should be annotable with a name and a scope independently.
      let scope = runGroup.scope
      if scope.isEmpty {
        continue
      }
      expandScope(forLabel: runGroupName, scope: scope)

      // Define the initial contiguous scope for the rungroup's label.
      // This allows functions to rewrite local labels as relative labels.
      guard let contiguousScope = runGroup.firstContiguousScopeRange else {
        continue
      }
      addContiguousScope(range: contiguousScope)

      let labelLocations = self.labelLocations(in: contiguousScope.dropFirst())

      rewriteLoopLabels(in: contiguousScope.dropFirst())
      rewriteElseLabels(in: contiguousScope.dropFirst())
      rewriteReturnLabels(at: labelLocations)
    }
  }

  private func rewriteReturnLabels(at locations: [LR35902.CartridgeLocation]) {
    let returnLabelAddresses = locations.filter { instructionMap[$0]?.spec.category == .ret }
    for cartLocation in returnLabelAddresses {
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "return_\(addressAndBank.address.hexString)_\(addressAndBank.bank.hexString)"
    }
  }

  private func rewriteLoopLabels(in scope: Range<LR35902.CartridgeLocation>) {
    let tocs: [(destination: LR35902.CartridgeLocation, tocs: Set<TransferOfControl>)] = scope.compactMap {
      let (address, bank) = LR35902.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: address, in: bank) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let backwardTocs: [(source: LR35902.CartridgeLocation, destination: LR35902.CartridgeLocation)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0.sourceLocation) && element.destination < $0.sourceLocation && labels[element.destination] != nil
      }
      for toc in tocsInThisScope {
        if case .jr(let condition, _) = instructionMap[toc.sourceLocation]?.spec,
          condition != nil {
          accumulator.append((toc.sourceLocation, element.destination))
        }
      }
    })
    if backwardTocs.isEmpty {
      return
    }
    // Loops do not include other unconditional transfers of control.
    let loops = backwardTocs.filter {
      let loopRange = ($0.destination..<$0.source)
      let tocsWithinLoop = tocs.flatMap {
        $0.tocs.filter { loopRange.contains($0.sourceLocation) }.map { $0.sourceInstructionSpec }
      }
      return !tocsWithinLoop.contains {
        switch $0 {
        case .jp(let condition, _), .ret(let condition):
          return condition == nil
        default:
          return false
        }
      }
    }
    if loops.isEmpty {
      return
    }
    let destinations = Set(loops.map { $0.destination })
    for cartLocation in destinations {
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "loop_\(addressAndBank.address.hexString)_\(addressAndBank.bank.hexString)"
    }
  }

  private func rewriteElseLabels(in scope: Range<LR35902.CartridgeLocation>) {
    let tocs: [(destination: LR35902.CartridgeLocation, tocs: Set<TransferOfControl>)] = scope.compactMap {
      let (address, bank) = LR35902.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: address, in: bank) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let forwardTocs: [(source: LR35902.CartridgeLocation, destination: LR35902.CartridgeLocation)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0.sourceLocation) && element.destination > $0.sourceLocation && labels[element.destination] != nil
      }
      for toc in tocsInThisScope {
        if case .jr(let condition, _) = instructionMap[toc.sourceLocation]?.spec,
          condition != nil {
          accumulator.append((toc.sourceLocation, element.destination))
        }
      }
    })
    if forwardTocs.isEmpty {
      return
    }
    let destinations = Set(forwardTocs.map { $0.destination })
    for cartLocation in destinations {
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "else_\(addressAndBank.address.hexString)_\(addressAndBank.bank.hexString)"
    }
  }

  private struct CPUState {
    enum RegisterValue<T: BinaryInteger> {
      case variable(LR35902.Address)
      case value(T)
    }
    struct RegisterState<T: BinaryInteger> {
      let value: RegisterValue<T>
      let sourceLocation: LR35902.CartridgeLocation
    }
    var a: RegisterState<UInt8>?
    var b: RegisterState<UInt8>?
    var c: RegisterState<UInt8>?
    var d: RegisterState<UInt8>?
    var e: RegisterState<UInt8>?
    var h: RegisterState<UInt8>?
    var l: RegisterState<UInt8>?
    var bc: RegisterState<UInt16>? {
      get {
        if let sourceLocation = b?.sourceLocation,
          case .value(let b) = b?.value,
          case .value(let c) = c?.value {
          return RegisterState<UInt16>(value: .value(UInt16(b) << 8 | UInt16(c)), sourceLocation: sourceLocation)
        }
        return _bc
      }
      set {
        if let sourceLocation = newValue?.sourceLocation,
          case .value(let bc) = newValue?.value {
          b = .init(value: .value(UInt8(bc >> 8)), sourceLocation: sourceLocation)
          c = .init(value: .value(UInt8(bc & 0x00FF)), sourceLocation: sourceLocation)
        }
        _bc = newValue
      }
    }
    private var _bc: RegisterState<UInt16>?
    var hl: RegisterState<UInt16>? {
      get {
        if let sourceLocation = h?.sourceLocation,
          case .value(let h) = h?.value,
          case .value(let l) = l?.value {
          return RegisterState<UInt16>(value: .value(UInt16(h) << 8 | UInt16(l)), sourceLocation: sourceLocation)
        }
        return _hl
      }
      set {
        if let sourceLocation = newValue?.sourceLocation,
          case .value(let hl) = newValue?.value {
          h = .init(value: .value(UInt8(hl >> 8)), sourceLocation: sourceLocation)
          l = .init(value: .value(UInt8(hl & 0x00FF)), sourceLocation: sourceLocation)
        }
        _hl = newValue
      }
    }
    private var _hl: RegisterState<UInt16>?
    var sp: RegisterState<UInt16>?
    var next: [LR35902.CartridgeLocation] = []
    var ram: [LR35902.Address: RegisterState<UInt8>] = [:]

    subscript(numeric: LR35902.Instruction.Numeric) -> RegisterState<UInt8>? {
      get {
        switch numeric {
        case .a: return a
        case .b: return b
        case .c: return c
        case .d: return d
        case .e: return e
        default: return nil
        }
      }
      set {
        switch numeric {
        case .a: a = newValue
        case .b: b = newValue
        case .c: c = newValue
        case .d: d = newValue
        case .e: e = newValue
        default: break
        }
      }
    }

    subscript(numeric: LR35902.Instruction.Numeric) -> RegisterState<UInt16>? {
      get {
        switch numeric {
        case .bc: return bc
        case .hl: return hl
        default: return nil
        }
      }
      set {
        switch numeric {
        case .bc: bc = newValue
        case .hl: hl = newValue
        default: break
        }
      }
    }
  }

  // TODO: Extract this engine into a generic emulator so that the following code can be debugged in an interactive session:
  /*
   ; Store the read joypad state into c
   ld   c, a                                    ; $282A (00): ReadJoypadState $4F
   ld   a, [hPreviousJoypadState]               ; $282B (00): ReadJoypadState $F0 $CB
   xor  c                                       ; $282D (00): ReadJoypadState $A9
   and  c                                       ; $282E (00): ReadJoypadState $A1
   ld   [hJoypadState], a                       ; $282F (00): ReadJoypadState $E0 $CC
   ld   a, c                                    ; $2831 (00): ReadJoypadState $79
   ld   [hPreviousJoypadState], a               ; $2832 (00): ReadJoypadState $E0 $CB
   */
  private func inferVariableTypes(in range: Range<LR35902.CartridgeLocation>) {
    var (pc, bank) = LR35902.addressAndBank(from: range.lowerBound)
    let upperBoundPc = LR35902.addressAndBank(from: range.upperBound).address

    var state = CPUState()

    // TODO: Store this globally.
    var states: [LR35902.CartridgeLocation: CPUState] = [:]

    let registers8: Set<LR35902.Instruction.Numeric> = Set([
      .a,
      .b,
      .c,
      .d,
      .e,
      .h,
      .l,
    ])

    let registers16: Set<LR35902.Instruction.Numeric> = Set([
      .bc,
      .hl,
    ])

    while pc < upperBoundPc {
      guard let instruction = self.instruction(at: pc, in: bank) else {
        pc += 1
        continue
      }

      let location = LR35902.cartAddress(for: pc, in: bank)!

      switch instruction.spec {
      case .ld(let numeric, .imm8) where registers8.contains(numeric):
        state[numeric] = CPUState.RegisterState<UInt8>(value: .value(instruction.imm8!), sourceLocation: location)

      case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
        let srcValue: CPUState.RegisterState<UInt8>? = state[src]
        state[dst] = srcValue

      case .ld(let dst, .imm16addr) where registers8.contains(dst):
        state[dst] = CPUState.RegisterState<UInt8>(value: .variable(instruction.imm16!), sourceLocation: location)

      case .ld(let dst, .imm16) where registers16.contains(dst):
        state[dst] = CPUState.RegisterState<UInt16>(value: .value(instruction.imm16!), sourceLocation: location)

      case .ld(let numeric, .ffimm8addr) where registers8.contains(numeric):
        let address = 0xFF00 | LR35902.Address(instruction.imm8!)
        state[numeric] = CPUState.RegisterState<UInt8>(value: .variable(address), sourceLocation: location)

      case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
        let address = 0xFF00 | LR35902.Address(instruction.imm8!)
        if let global = globals[address],
          let dataType = global.dataType,
          let sourceLocation = state.a?.sourceLocation {
          typeAtLocation[sourceLocation] = dataType
        }
        state.ram[address] = state[numeric]

      case .cp(_):
        if case .variable(let address) = state.a?.value,
          let global = globals[address],
          let dataType = global.dataType {
          typeAtLocation[location] = dataType
        }

      case .xor(.a):
        state.a = .init(value: .value(0), sourceLocation: location)

      case .and(let numeric) where registers8.contains(numeric):
        if case .value(let dst) = state.a?.value,
          let register: CPUState.RegisterState<UInt8> = state[numeric],
          case .value(let src) = register.value {
          state.a = .init(value: .value(dst & src), sourceLocation: location)
          // TODO: Compute the flag bits.
        } else {
          state.a = nil
        }

      case .and(.imm8):
        if case .variable(let address) = state.a?.value,
          let global = globals[address],
          let dataType = global.dataType {
          typeAtLocation[location] = dataType
        }

        if case .value(let dst) = state.a?.value {
          state.a = .init(value: .value(dst & instruction.imm8!), sourceLocation: location)
          // TODO: Compute the flag bits.
        }

      case .ld(.sp, .imm16):
        state.sp = .init(value: .value(instruction.imm16!), sourceLocation: location)

      case .reti, .ret:
        state.a = nil
        state.bc = nil
        state.hl = nil
        state.sp = nil
        state.ram.removeAll()

      // TODO: For calls, we need to look up the affected registers and arguments.
      default:
        break
      }

      let width = LR35902.Instruction.widths[instruction.spec]!.total

      var thisState = state
      thisState.next = [location + LR35902.CartridgeLocation(width)]
      states[location] = thisState

      pc += width
    }
  }
}
