import Foundation

import RGBDS

extension Disassembler {
  final class BankSourceWorker {
    let context: DisassemblerContext
    let bank: Cartridge.Bank
    let router: BankRouter

    // TODO: Separate disassembler artifacts from the disassembler itself. This is only used by RGBDSDisassembler so
    // that it can use the artifacts when generating the statement.
    let disassembler: Disassembler

    init(context: DisassemblerContext, bank: Cartridge.Bank, router: BankRouter, disassembler: Disassembler) {
      self.context = context
      self.bank = bank
      self.router = router
      self.disassembler = disassembler

      let cartridgeSize = context.cartridgeData.count
      self.endAddress = (bank == 0) ? (cartridgeSize < 0x4000 ? LR35902.Address(truncatingIfNeeded: cartridgeSize) : 0x4000) : 0x8000
    }

    var macrosUsed: [Disassembler.EncounteredMacro] = []
    var lines: [Line] = []

    private let endAddress: LR35902.Address
    private var lineBufferAddress: LR35902.Address = 0
    private var lineBuffer: [Line] = []
    private var macroNode: Configuration.MacroNode? = nil
    private var writeContext: (pc: LR35902.Address, bank: Cartridge.Bank) = (pc: 0, bank: 0)

    func generateSource() {
      writeContext = (pc: LR35902.Address((self.bank == 0) ? 0x0000 : 0x4000), bank: max(1, self.bank))
      lineBufferAddress = writeContext.pc

      let dataTypes = context.allDatatypes()
      let characterMap = context.allMappedCharacters()

      lines.append(Line(semantic: .section(bank)))
      lineBuffer.append(Line(semantic: .emptyAndCollapsible))

      while writeContext.pc < endAddress {
        var lineGroup: [Line] = []
        let isLabeled = checkPreamble(&lineGroup)
        if let instruction = router.instruction(at: Cartridge.Location(address: writeContext.pc, bank: bank)) {
          flush(instruction: instruction, &lineGroup, isLabeled)
        } else {
          flushNonCodeBlock(lineGroup, dataTypes, characterMap)
        }
      }

      flushMacro(lastAddress: writeContext.pc)

      flushLineBuffer()
    }

    // MARK: - Generating source

    private func checkPreamble(_ lineGroup: inout [Disassembler.Line]) -> Bool {
      if let preComment = context.preComment(at: Cartridge.Location(address: writeContext.pc, bank: bank)) {
        lineGroup.append(Line(semantic: .emptyAndCollapsible))
        lineGroup.append(Line(semantic: .preComment(comment: preComment)))
      }
      guard let label = router.label(at: Cartridge.Location(address:writeContext.pc, bank: bank)) else {
        return false
      }
      if let transfersOfControl = router.transfersOfControl(at: Cartridge.Location(address: writeContext.pc, bank: bank)) {
        lineGroup.append(Line(semantic: .transferOfControl(transfersOfControl, label), address: writeContext.pc, bank: bank))
      } else {
        let instructionScope = router.labeledContiguousScopes(at: Cartridge.Location(address: writeContext.pc, bank: bank))
        let scope = instructionScope.sorted().joined(separator: ", ")
        lineGroup.append(Line(semantic: .emptyAndCollapsible, address: writeContext.pc, bank: writeContext.bank, scope: scope))
        lineGroup.append(Line(semantic: .label(labelName: label), address: writeContext.pc, bank: writeContext.bank, scope: scope))
      }
      return true
    }

    private func flush(instruction: LR35902.Instruction, _ lineGroup: inout [Disassembler.Line], _ isLabeled: Bool) {
      if let bankChange = router.bankChange(at: Cartridge.Location(address: writeContext.pc, bank: writeContext.bank)) {
        writeContext.bank = bankChange
      }

      // Write the instruction as assembly.
      let index = Cartridge.Location(address: writeContext.pc, bank: bank)
      let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!.total
      let bytes = context.cartridgeData[index.index..<(index + instructionWidth).index]
      let instructionScope = router.labeledContiguousScopes(at: Cartridge.Location(address: writeContext.pc, bank: bank))
      let context = RGBDSDisassembler.Context(
        address: writeContext.pc,
        bank: writeContext.bank,
        disassembly: disassembler,
        argumentString: nil
      )
      lineGroup.append(Line(semantic: .instruction(instruction, RGBDSDisassembler.statement(for: instruction, with: context)),
                            address: writeContext.pc,
                            bank: writeContext.bank,
                            scope: instructionScope.sorted().joined(separator: ", "),
                            data: bytes))

      writeContext.pc += instructionWidth

      // TODO: Start a macro descent for every instruction.

      if let child = initialCheckMacro(instruction: instruction) {
        flushLineBuffer()
        lineBufferAddress = writeContext.pc - instructionWidth
        macroNode = child
      } else if let child = self.followUpCheckMacro(instruction: instruction, isLabeled: isLabeled) {
        macroNode = child
      } else {
        let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!.total
        flushMacro(lastAddress: writeContext.pc - instructionWidth)
      }

      // Handle context changes.
      switch instruction.spec {
      case .jp(let condition, _), .jr(let condition, _):
        let instructionScope = router.labeledContiguousScopes(at: Cartridge.Location(address: writeContext.pc, bank: bank))
        let scope = instructionScope.sorted().joined(separator: ", ")
        lineGroup.append(Line(semantic: .emptyAndCollapsible, scope: scope))
        if condition == nil {
          writeContext.bank = bank
        }
      case .ret(let condition):
        lineGroup.append(Line(semantic: .empty))
        if condition == nil {
          lineGroup.append(Line(semantic: .emptyAndCollapsible))
          writeContext.bank = bank
        }
      case .reti:
        lineGroup.append(Line(semantic: .empty))
        lineGroup.append(Line(semantic: .emptyAndCollapsible))
        writeContext.bank = bank
      default:
        break
      }

      lineBuffer.append(contentsOf: lineGroup)

      // Immediately start looking for the next macro.
      if let child = initialCheckMacro(instruction: instruction) {
        lineBufferAddress = writeContext.pc - instructionWidth
        macroNode = child
      }
    }

    private func flushNonCodeBlock(_ lineGroup: [Disassembler.Line], _ dataTypes: [String : Disassembler.Configuration.Datatype], _ characterMap: [UInt8 : String]) {
      flushMacro(lastAddress: writeContext.pc)

      lineBuffer.append(contentsOf: lineGroup)
      flushLineBuffer()

      let initialType = router.disassemblyType(at: Cartridge.Location(address: writeContext.pc, bank: bank))

      // Accumulate bytes until the next instruction or transfer of control.
      var accumulator: [UInt8] = []
      let initialPc = writeContext.pc
      var global: Configuration.Global?
      repeat {
        if writeContext.pc < 0x4000 {
          global = context.global(at: writeContext.pc)
        }
        accumulator.append(context.cartridgeData[Cartridge.Location(address: writeContext.pc, bank: bank).index])
        writeContext.pc += 1
      } while writeContext.pc < endAddress
        && router.instruction(at: Cartridge.Location(address: writeContext.pc, bank: bank)) == nil
        && router.label(at: Cartridge.Location(address:writeContext.pc, bank: bank)) == nil
        && router.disassemblyType(at: Cartridge.Location(address: writeContext.pc, bank: bank)) == initialType
        && global == nil

      let globalValue: String?
      let globalData: Data?
      if let global = global,
         let dataType = global.dataType,
         let type = dataTypes[dataType],
         let value = type.namedValues[accumulator.last!] {
        globalValue = value
        globalData = Data([accumulator.removeLast()])
      } else {
        globalValue = nil
        globalData = nil
      }

      var chunkPc = initialPc
      switch initialType {
      case .text:
        let lineLength = context.lineLengthOfText(at: Cartridge.Location(address: initialPc, bank: bank)) ?? 36
        for chunk in accumulator.chunked(into: lineLength) {
          lines.append(textLine(for: chunk, characterMap: characterMap, address: chunkPc))
          chunkPc += LR35902.Address(chunk.count)
        }
      case .jumpTable:
        for (index, pair) in accumulator.chunked(into: 2).enumerated() {
          let address = (LR35902.Address(pair[1]) << 8) | LR35902.Address(pair[0])
          let jumpLocation: String
          let effectiveBank: Cartridge.Bank
          if let changedBank = router.bankChange(at: Cartridge.Location(address: chunkPc, bank: bank)) {
            effectiveBank = changedBank
          } else {
            effectiveBank = writeContext.bank
          }
          if let label = router.label(at: Cartridge.Location(address:address, bank: effectiveBank)) {
            jumpLocation = label
          } else {
            jumpLocation = "$\(address.hexString)"
          }
          let bytes = context.cartridgeData[Cartridge.Location(address: chunkPc, bank: bank).index..<(Cartridge.Location(address: chunkPc, bank: bank) + 2).index]
          lines.append(Line(semantic: .jumpTable(jumpLocation, index), address: chunkPc, data: bytes))
          chunkPc += LR35902.Address(pair.count)
        }
        break
      case .code:
        // This should not happen; it means that there is some overlap in interpretation of instructions causing us
        // to parse an instruction mid-instruction. Fall through to treating this as unknown data, but log a
        // warning.
        print("Instruction overlap detected at \(bank.hexString):\(initialPc.hexString)")
        fallthrough
      case .unknown:
        for chunk in accumulator.chunked(into: 8) {
          lines.append(Line(semantic: .unknown(RGBDS.Statement(representingBytes: chunk)), address: chunkPc, data: Data(chunk)))
          chunkPc += LR35902.Address(chunk.count)
        }
      case .data:
        for chunk in accumulator.chunked(into: 8) {
          lines.append(Line(semantic: .data(RGBDS.Statement(representingBytes: chunk)), address: chunkPc, data: Data(chunk)))
          chunkPc += LR35902.Address(chunk.count)
        }
      case .image2bpp:
        lines.append(Line(semantic: .imagePlaceholder(format: .twoBitsPerPixel), address: chunkPc, data: Data(accumulator)))
        for chunk in accumulator.chunked(into: 8) {
          lines.append(Line(semantic: .image2bpp(RGBDS.Statement(representingBytes: chunk)), address: chunkPc, data: Data(chunk)))
          chunkPc += LR35902.Address(chunk.count)
        }
      case .image1bpp:
        lines.append(Line(semantic: .imagePlaceholder(format: .oneBitPerPixel), address: chunkPc, data: Data(accumulator)))
        for chunk in accumulator.chunked(into: 8) {
          lines.append(Line(semantic: .image1bpp(RGBDS.Statement(representingBytes: chunk)), address: chunkPc, data: Data(chunk)))
          chunkPc += LR35902.Address(chunk.count)
        }
      case .ram:
        preconditionFailure()
      }

      if let global = global,
         let dataTypeName = global.dataType,
         let dataType = dataTypes[dataTypeName],
         let globalValue = globalValue {
        lines.append(Line(semantic: .global(RGBDS.Statement(representingBytesWithConstant: globalValue), dataTypeName: dataTypeName, dataType: dataType), address: chunkPc, data: globalData))
      }

      lineBuffer.append(Line(semantic: .emptyAndCollapsible))
      lineBufferAddress = writeContext.pc
      writeContext.bank = bank
    }

    // MARK: - Managing the line buffer

    /** Flushes all lines in the line buffer to the bank's lines. */
    private func flushLineBuffer() {
      lines += lineBuffer
      lineBuffer.removeAll()
      macroNode = nil
    }

    // MARK: - Handling macros

    private func initialCheckMacro(instruction: LR35902.Instruction) -> Configuration.MacroNode? {
      let asInstruction = Configuration.MacroTreeEdge.instruction(instruction)
      let asAny = Configuration.MacroTreeEdge.arg(instruction.spec)
      guard macroNode == nil,
            let child = context.macroTreeRoot().children[asInstruction] ?? context.macroTreeRoot().children[asAny] else {
        return nil
      }
      return child
    }

    private func followUpCheckMacro(instruction: LR35902.Instruction, isLabeled: Bool) -> Configuration.MacroNode? {
      // Is this the beginning of a macro?
      guard let macroNodeIterator = macroNode else {
        return nil
      }
      let asInstruction = Configuration.MacroTreeEdge.instruction(instruction)
      let asArg = Configuration.MacroTreeEdge.arg(instruction.spec)
      // Only descend the tree if we're not a label.
      guard !isLabeled, let child = macroNodeIterator.children[asInstruction] ?? macroNodeIterator.children[asArg] else {
        return nil
      }
      return child
    }

    private func flushMacro(lastAddress: LR35902.Address) -> Void {
      // Is this the beginning of a macro?
      guard let macroNodeIterator = macroNode else {
        return
      }
      // No further nodes to be traversed; is this the end of a macro?
      if !macroNodeIterator.macros.isEmpty {
        let instructions = lineBuffer.compactMap { thisLine -> (LR35902.Instruction, RGBDS.Statement)? in
          if case let .instruction(instruction, assembly) = thisLine.semantic {
            return (instruction, assembly)
          } else {
            return nil
          }
        }

        let macros: [(macro: Disassembler.Configuration.Macro, arguments: [Int: String], rawArguments: [Int: String])] = macroNodeIterator.macros.compactMap { macro in
          // Extract the arguments.
          var anyArgumentMismatches = false
          let arguments: [Int: String] = zip(macro.macroLines, instructions).reduce([:], { (iter, zipped) -> [Int: String] in
            guard case let .arg(spec, argumentOrNil, _) = zipped.0,
                  let argument = argumentOrNil else {
              return iter
            }
            let args = extractArgs(from: zipped.1.1, using: spec, argument: Int(argument))
            return iter.merging(args, uniquingKeysWith: { first, second in
              if first != second {
                anyArgumentMismatches = true
              }
              return first
            })
          })
          if anyArgumentMismatches {
            return nil
          }

          // Arguments without any label replacements.
          let rawArguments: [Int: String] = zip(macro.macroLines, instructions).reduce([:], { (iter, zipped) -> [Int: String] in
            guard case let .arg(spec, argumentOrNil, _) = zipped.0,
                  let argument = argumentOrNil else {
              return iter
            }
            let statement = RGBDSDisassembler.statement(for: zipped.1.0)
            let args = extractArgs(from: statement, using: spec, argument: Int(argument))
            return iter.merging(args, uniquingKeysWith: { first, second in
              if first != second {
                anyArgumentMismatches = true
              }
              return first
            })
          })
          if anyArgumentMismatches {
            return nil
          }

          return (macro: macro, arguments: arguments, rawArguments: rawArguments)
        }

        var validMacros = macros.filter { macro in
          guard let validArgumentValues = macro.macro.validArgumentValues else {
            return true
          }
          let firstInvalidArgument = macro.rawArguments.first { argumentNumber, argumentValue in
            guard validArgumentValues[argumentNumber] != nil else {
              return false
            }
            if argumentValue.hasPrefix("$") {
              let number = Int(LR35902.Address(argumentValue.dropFirst(), radix: 16)!)
              return !validArgumentValues[argumentNumber]!.contains(number)
            } else if argumentValue.hasPrefix("[$") && argumentValue.hasSuffix("]") {
              let number = Int(LR35902.Address(argumentValue.dropFirst(2).dropLast(), radix: 16)!)
              return !validArgumentValues[argumentNumber]!.contains(number)
            }
            preconditionFailure("Unhandled.")
          }
          return firstInvalidArgument == nil
        }

        if validMacros.count > 1 {
          // Try filtering to macros that have validation.
          validMacros = validMacros.filter { macro in
            macro.macro.validArgumentValues != nil
          }
        }

        precondition(validMacros.count <= 1, "More than one macro matched.")

        if let macro = validMacros.first {
          macrosUsed.append((macro: macro.macro, arguments: macro.arguments, rawArguments: macro.rawArguments))

          let lowerBound = Cartridge.Location(address: lineBufferAddress, bank: writeContext.bank)
          let upperBound = Cartridge.Location(address: lastAddress, bank: writeContext.bank)
          let bytes = context.cartridgeData[lowerBound.index..<upperBound.index]

          let macroArgs = macro.arguments.keys.sorted().map { macro.arguments[$0]! }

          let firstInstruction = lineBuffer.firstIndex { line in if case .instruction = line.semantic { return true } else { return false} }!
          let lastInstruction = lineBuffer.lastIndex { line in if case .instruction = line.semantic { return true } else { return false} }!
          let bank: Cartridge.Bank
          if case .instruction = lineBuffer[lastInstruction].semantic {
            bank = lineBuffer[lastInstruction].bank!
          } else {
            bank = writeContext.bank
          }
          let macroScopes = router.labeledContiguousScopes(at: Cartridge.Location(address: lineBufferAddress, bank: bank))
          let statement = RGBDS.Statement(opcode: macro.macro.name, operands: macroArgs)
          lineBuffer.replaceSubrange(firstInstruction...lastInstruction,
                                          with: [Line(semantic: .macro(statement),
                                                      address: lineBufferAddress,
                                                      bank: bank,
                                                      scope: macroScopes.sorted().joined(separator: ", "),
                                                      data: bytes)])
          lineBufferAddress = writeContext.pc
        } else {
          flushLineBuffer()
        }
      } else {
        flushLineBuffer()
      }
      macroNode = nil
    }

  }
}

private func extractArgs(from statement: RGBDS.Statement, using spec: LR35902.Instruction.Spec, argument: Int) -> [Int: String] {
  var args: [Int: String] = [:]
  try? spec.visit { operand, _ in
    guard let operand = operand else {
      return
    }

    switch operand.value {
    case LR35902.Instruction.Numeric.imm16,
         LR35902.Instruction.Numeric.imm8,
         LR35902.Instruction.Numeric.imm16addr,
         LR35902.Instruction.Numeric.simm8,
         LR35902.Instruction.Numeric.sp_plus_simm8,
         LR35902.Instruction.Numeric.ffimm8addr:
      args[argument] = Mirror(reflecting: statement).descendant(1, operand.index) as? String
    default:
      break
    }
  }
  return args
}
