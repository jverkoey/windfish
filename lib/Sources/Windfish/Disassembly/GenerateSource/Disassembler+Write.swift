import Foundation

import os.log

import CPU
import RGBDS

extension Array {
  public func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

private func stringWithNewline(_ string: String) -> String {
  return string + "\n"
}

private func extractArgs(from statement: RGBDS.Statement, using spec: LR35902.Instruction.Spec, argument: Int) -> [Int: String] {
  var args: [Int: String] = [:]
  try! spec.visit { operand, _ in
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

private func extractArgTypes(from instruction: LR35902.Instruction.Spec, using spec: LR35902.Instruction.Spec, argument: Int) -> [Int: String] {
  var args: [Int: String] = [:]
  try! spec.visit { operand, _ in
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
      if let operand = Mirror(reflecting: instruction).descendant(0, operand.index) {
        args[argument] = "\(operand)"
      } else if let operand = Mirror(reflecting: instruction).descendant(operand.index) {
        args[argument] = "\(operand)"
      }
    default:
      break
    }
  }
  return args
}

func prettify(_ label: String) -> String {
  let parts = label.components(separatedBy: ".")
  if parts.count == 1 {
    return label
  }
  return ".\(parts.last!)"
}

func textLine(for bytes: [UInt8], characterMap: [UInt8: String], address: LR35902.Address) -> Disassembler.Line {
  return Disassembler.Line(semantic: .text(RGBDS.Statement(withAscii: bytes, characterMap: characterMap)),
                           address: address,
                           data: Data(bytes))
}

extension Disassembler {
  public func generateSource() throws -> (Source, Statistics) {
    var sources: [String: Source.FileDescription] = [:]

    sources["Makefile"] = createMakefile()

    var gameAsm = ""

    if let dataTypesSource = createDataTypesSource() {
      sources["datatypes.asm"] = dataTypesSource
      gameAsm += "INCLUDE \"datatypes.asm\"\n"
    }
    if let variablesSource = createVariablesSource() {
      sources["variables.asm"] = variablesSource
      gameAsm += "INCLUDE \"variables.asm\"\n"
    }

    let characterMap = configuration.allMappedCharacters()
    if !characterMap.isEmpty {
      let asm = characterMap.sorted { $0.key < $1.key }.map { value, string in
        "charmap \"\(string)\", $\(value.hexString)"
      }.joined(separator: "\n")

      sources["charmap.asm"] = .charmap(content: asm)
      gameAsm += "INCLUDE \"charmap.asm\"\n"
    }

    var instructionsDecoded: ContiguousArray<Int> = ContiguousArray<Int>(repeating: 0, count: Int(truncatingIfNeeded: numberOfBanks))

    let linesAsString: ([Line]) -> String = { lines in
      return lines.map { $0.asString(detailedComments: false) }.joined(separator: "\n")
    }

    let log = OSLog(subsystem: "com.featherless.windfish", category: "PointsOfInterest")

    // TODO: Source should be generated in a tokenized fashion, such that there is a String representing the source and
    // an array of tokens representing a range and a set of attributes. This will enable the Windfish UI to associate
    // attributes to the string by simply mapping tokens to attributes.

    let dataTypes = configuration.allDatatypes()
    var macrosAsm: String? = nil
    var macrosToWrite: [(macro: Disassembler.Configuration.Macro, arguments: [Int: String], rawArguments: [Int: String],
                      instructions: [(LR35902.Instruction, Statement)])] = []
    let q = DispatchQueue(label: "sync queue")
    DispatchQueue.concurrentPerform(iterations: Int(truncatingIfNeeded: numberOfBanks)) { (index: Int) in
      let signpostID = OSSignpostID(log: log)
      os_signpost(.begin, log: log, name: "Generate source", signpostID: signpostID, "%{public}d", index)

      let bankToWrite: Cartridge.Bank = Cartridge.Bank(truncatingIfNeeded: index)
      var macrosUsed: [(macro: Disassembler.Configuration.Macro, arguments: [Int: String], rawArguments: [Int: String],
                        instructions: [(LR35902.Instruction, Statement)])] = []

      var bankLines: [Line] = []
      defer {
        os_signpost(.end, log: log, name: "Generate source", signpostID: signpostID, "%{public}d", index)

        q.sync {
          macrosToWrite.append(contentsOf: macrosUsed)

          var lastLine: Line?
          let filteredBankLines = bankLines.filter { thisLine in
            if let lastLine = lastLine, lastLine.semantic == .empty && thisLine.semantic == .empty {
              return false
            }
            lastLine = thisLine
            return true
          }
          sources["bank_\(bankToWrite.hexString).asm"] = .bank(number: bankToWrite, content: linesAsString(filteredBankLines), lines: filteredBankLines)
        }
      }

      bankLines.append(Line(semantic: .section(bankToWrite)))

      var writeContext = (pc: LR35902.Address((bankToWrite == 0) ? 0x0000 : 0x4000),
                          bank: max(1, bankToWrite))
      let end: LR35902.Address = (bankToWrite == 0) ? (cartridgeSize < 0x4000 ? LR35902.Address(cartridgeSize) : 0x4000) : 0x8000

      let initialBank = max(1, bankToWrite)

      var lineBufferAddress: LR35902.Address = writeContext.pc
      var lineBuffer: [Line] = []
      lineBuffer.append(Line(semantic: .empty))
      var macroNode: Configuration.MacroNode? = nil

      let flush = {
        bankLines += lineBuffer
        lineBuffer.removeAll()
        macroNode = nil
      }

      let initialCheckMacro: (LR35902.Instruction) -> Configuration.MacroNode? = { instruction in
        let asInstruction = Configuration.MacroTreeEdge.instruction(instruction)
        let asAny = Configuration.MacroTreeEdge.arg(instruction.spec)
        guard macroNode == nil,
              let child = self.configuration.macroTreeRoot().children[asInstruction] ?? self.configuration.macroTreeRoot().children[asAny] else {
          return nil
        }
        return child
      }

      let followUpCheckMacro: (LR35902.Instruction, Bool) -> Configuration.MacroNode? = { instruction, isLabeled in
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

      let flushMacro: (LR35902.Address) throws -> Void = { lastAddress in
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
            macrosUsed.append((macro: macro.macro, arguments: macro.arguments, rawArguments: macro.rawArguments, instructions))

            let lowerBound = Cartridge.Location(address: lineBufferAddress, bank: writeContext.bank)
            let upperBound = Cartridge.Location(address: lastAddress, bank: writeContext.bank)
            let bytes = self.cartridgeData[lowerBound.index..<upperBound.index]

            let macroArgs = macro.arguments.keys.sorted().map { macro.arguments[$0]! }

            let firstInstruction = lineBuffer.firstIndex { line in if case .instruction = line.semantic { return true } else { return false} }!
            let lastInstruction = lineBuffer.lastIndex { line in if case .instruction = line.semantic { return true } else { return false} }!
            let bank: Cartridge.Bank
            if case .instruction = lineBuffer[lastInstruction].semantic {
              bank = lineBuffer[lastInstruction].bank!
            } else {
              bank = writeContext.bank
            }
            let macroScopes = self.lastBankRouter!.labeledContiguousScopes(at: Cartridge.Location(address: lineBufferAddress, bank: bank))
            let statement = RGBDS.Statement(opcode: macro.macro.name, operands: macroArgs)
            lineBuffer.replaceSubrange(firstInstruction...lastInstruction,
                                       with: [Line(semantic: .macro(statement),
                                                   address: lineBufferAddress,
                                                   bank: bank,
                                                   scope: macroScopes.sorted().joined(separator: ", "),
                                                   data: bytes)])
            lineBufferAddress = writeContext.pc
          } else {
            flush()
          }
        } else {
          flush()
        }
        macroNode = nil
      }

      while writeContext.pc < end {
        var isLabeled = false
        var lineGroup: [Line] = []
        if let preComment = configuration.preComment(at: Cartridge.Location(address: writeContext.pc, bank: writeContext.bank)) {
          lineGroup.append(Line(semantic: .empty))
          lineGroup.append(Line(semantic: .preComment(comment: preComment)))
        }
        if let label = lastBankRouter!.label(at: Cartridge.Location(address:writeContext.pc, bank: initialBank)) {
          if let transfersOfControl = lastBankRouter!.transfersOfControl(at: Cartridge.Location(address: writeContext.pc, bank: initialBank)) {
            lineGroup.append(Line(semantic: .transferOfControl(transfersOfControl, label), address: writeContext.pc, bank: writeContext.bank))
          } else {
            let instructionScope = lastBankRouter!.labeledContiguousScopes(at: Cartridge.Location(address: writeContext.pc, bank: initialBank))
            let scope = instructionScope.sorted().joined(separator: ", ")
            lineGroup.append(Line(semantic: .empty, address: writeContext.pc, bank: writeContext.bank, scope: scope))
            lineGroup.append(Line(semantic: .label(labelName: label), address: writeContext.pc, bank: writeContext.bank, scope: scope))
          }
          isLabeled = true
        }

        if let instruction = lastBankRouter!.instruction(at: Cartridge.Location(address: writeContext.pc, bank: initialBank)) {
          instructionsDecoded[Int(truncatingIfNeeded: bankToWrite)] += 1

          if let bankChange = lastBankRouter!.bankChange(at: Cartridge.Location(address: writeContext.pc, bank: writeContext.bank)) {
            writeContext.bank = bankChange
          }

          // Write the instruction as assembly.
          let index = Cartridge.Location(address: writeContext.pc, bank: initialBank)
          let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!.total
          let bytes = cartridgeData[index.index..<(index + instructionWidth).index]
          let instructionScope = lastBankRouter!.labeledContiguousScopes(at: Cartridge.Location(address: writeContext.pc, bank: initialBank))
          let context = RGBDSDisassembler.Context(
            address: writeContext.pc,
            bank: writeContext.bank,
            disassembly: self,
            argumentString: nil
          )
          lineGroup.append(Line(semantic: .instruction(instruction, RGBDSDisassembler.statement(for: instruction, with: context)),
                                address: writeContext.pc,
                                bank: writeContext.bank,
                                scope: instructionScope.sorted().joined(separator: ", "),
                                data: bytes))

          writeContext.pc += instructionWidth

          // TODO: Start a macro descent for every instruction.

          if let child = initialCheckMacro(instruction) {
            flush()
            lineBufferAddress = writeContext.pc - instructionWidth
            macroNode = child
          } else if let child = followUpCheckMacro(instruction, isLabeled) {
            macroNode = child
          } else {
            let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!.total
            try! flushMacro(writeContext.pc - instructionWidth)
          }

          // Handle context changes.
          switch instruction.spec {
          case .jp(let condition, _), .jr(let condition, _):
            let instructionScope = lastBankRouter!.labeledContiguousScopes(at: Cartridge.Location(address: writeContext.pc, bank: initialBank))
            let scope = instructionScope.sorted().joined(separator: ", ")
            lineGroup.append(Line(semantic: .empty, scope: scope))
            if condition == nil {
              writeContext.bank = initialBank
            }
          case .ret(let condition):
            lineGroup.append(Line(semantic: .newline))
            if condition == nil {
              lineGroup.append(Line(semantic: .empty))
              writeContext.bank = initialBank
            }
          case .reti:
            lineGroup.append(Line(semantic: .newline))
            lineGroup.append(Line(semantic: .empty))
            writeContext.bank = initialBank
          default:
            break
          }

          lineBuffer.append(contentsOf: lineGroup)

          // Immediately start looking for the next macro.
          if let child = initialCheckMacro(instruction) {
            lineBufferAddress = writeContext.pc - instructionWidth
            macroNode = child
          }

        } else {
          try! flushMacro(writeContext.pc)

          lineBuffer.append(contentsOf: lineGroup)
          flush()

          let initialType = lastBankRouter!.disassemblyType(at: Cartridge.Location(address: writeContext.pc, bank: initialBank))

          // Accumulate bytes until the next instruction or transfer of control.
          var accumulator: [UInt8] = []
          let initialPc = writeContext.pc
          var global: Configuration.Global?
          repeat {
            if writeContext.pc < 0x4000 {
              global = configuration.global(at: writeContext.pc)
            }
            accumulator.append(cartridgeData[Cartridge.Location(address: writeContext.pc, bank: initialBank).index])
            writeContext.pc += 1
          } while writeContext.pc < end
            && lastBankRouter!.instruction(at: Cartridge.Location(address: writeContext.pc, bank: initialBank)) == nil
            && lastBankRouter!.label(at: Cartridge.Location(address:writeContext.pc, bank: initialBank)) == nil
            && lastBankRouter!.disassemblyType(at: Cartridge.Location(address: writeContext.pc, bank: initialBank)) == initialType
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
            let lineLength = configuration.lineLengthOfText(at: Cartridge.Location(address: initialPc, bank: initialBank)) ?? 36
            for chunk in accumulator.chunked(into: lineLength) {
              bankLines.append(textLine(for: chunk, characterMap: characterMap, address: chunkPc))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .jumpTable:
            for (index, pair) in accumulator.chunked(into: 2).enumerated() {
              let address = (LR35902.Address(pair[1]) << 8) | LR35902.Address(pair[0])
              let jumpLocation: String
              let effectiveBank: Cartridge.Bank
              if let changedBank = lastBankRouter!.bankChange(at: Cartridge.Location(address: chunkPc, bank: initialBank)) {
                effectiveBank = changedBank
              } else {
                effectiveBank = writeContext.bank
              }
              if let label = lastBankRouter!.label(at: Cartridge.Location(address:address, bank: effectiveBank)) {
                jumpLocation = label
              } else {
                jumpLocation = "$\(address.hexString)"
              }
              let bytes = cartridgeData[Cartridge.Location(address: chunkPc, bank: initialBank).index..<(Cartridge.Location(address: chunkPc, bank: initialBank) + 2).index]
              bankLines.append(Line(semantic: .jumpTable(jumpLocation, index), address: chunkPc, data: bytes))
              chunkPc += LR35902.Address(pair.count)
            }
            break
          case .code:
            // This should not happen; it means that there is some overlap in interpretation of instructions causing us
            // to parse an instruction mid-instruction. Fall through to treating this as unknown data, but log a
            // warning.
            print("Instruction overlap detected at \(initialBank.hexString):\(initialPc.hexString)")
            fallthrough
          case .unknown:
            for chunk in accumulator.chunked(into: 8) {
              bankLines.append(Line(semantic: .unknown(RGBDS.Statement(representingBytes: chunk)), address: chunkPc, data: Data(chunk)))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .data:
            for chunk in accumulator.chunked(into: 8) {
              bankLines.append(Line(semantic: .data(RGBDS.Statement(representingBytes: chunk)), address: chunkPc, data: Data(chunk)))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .image2bpp:
            bankLines.append(Line(semantic: .imagePlaceholder(format: .twoBitsPerPixel), address: chunkPc, data: Data(accumulator)))
            for chunk in accumulator.chunked(into: 8) {
              bankLines.append(Line(semantic: .image2bpp(RGBDS.Statement(representingBytes: chunk)), address: chunkPc, data: Data(chunk)))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .image1bpp:
            bankLines.append(Line(semantic: .imagePlaceholder(format: .oneBitPerPixel), address: chunkPc, data: Data(accumulator)))
            for chunk in accumulator.chunked(into: 8) {
              bankLines.append(Line(semantic: .image1bpp(RGBDS.Statement(representingBytes: chunk)), address: chunkPc, data: Data(chunk)))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .ram:
            preconditionFailure()
          }

          if let global = global,
             let dataTypeName = global.dataType,
             let dataType = dataTypes[dataTypeName],
             let globalValue = globalValue {
            bankLines.append(Line(semantic: .global(RGBDS.Statement(representingBytesWithConstant: globalValue), dataTypeName: dataTypeName, dataType: dataType), address: chunkPc, data: globalData))
          }

          lineBuffer.append(Line(semantic: .empty))
          lineBufferAddress = writeContext.pc
          writeContext.bank = initialBank
        }
      }

      try! flushMacro(writeContext.pc)

      flush()
    }

    if !macrosToWrite.isEmpty {
      macrosAsm = ""
      gameAsm += "INCLUDE \"macros.asm\"\n"

      var writtenMacros: Set<String> = Set<String>()
      for macro in macrosToWrite.sorted(by: { $0.macro.name < $1.macro.name }) {
        guard !writtenMacros.contains(macro.macro.name) else {
          continue
        }
        writtenMacros.insert(macro.macro.name)

        var lines: [Line] = []
        lines.append(Line(semantic: .empty))
        if !macro.arguments.isEmpty {
          lines.append(Line(semantic: .macroComment(comment: "Arguments:")))

          let macroSpecs: [LR35902.Instruction.Spec] = macro.macro.macroLines.map { $0.specs() }.reduce([], +)

          let argumentTypes: [Int: String] = zip(macro.macro.macroLines, macroSpecs).reduce([:], { (iter, zipped) -> [Int: String] in
            guard case let .arg(spec, argumentOrNil, _) = zipped.0,
                  let argument = argumentOrNil else {
              return iter
            }
            let args = extractArgTypes(from: zipped.1, using: spec, argument: Int(argument))
            return iter.merging(args, uniquingKeysWith: { first, second in
              assert(first == second, "Mismatch in arguments")
              return first
            })
          })

          for argNumber in macro.arguments.keys.sorted() {
            let argType: String
            if let type = argumentTypes[argNumber] {
              argType = " type: \(type)"
            } else {
              argType = ""
            }
            if let validation = macro.macro.validArgumentValues?[argNumber] {
              let ranges = validation.rangeView.map {
                "$\(LR35902.Address($0.lowerBound).hexString)..<$\(LR35902.Address($0.upperBound).hexString)"
              }.joined(separator: ", ")
              lines.append(Line(semantic: .macroComment(comment: "- \(argNumber)\(argType): valid values in \(ranges)")))
            } else {
              lines.append(Line(semantic: .macroComment(comment: "- \(argNumber)\(argType)")))
            }
          }
        }
        lines.append(Line(semantic: .macroDefinition(macro.macro.name)))
        lines.append(contentsOf: zip(macro.macro.macroLines, macro.instructions).map { line, instruction in
          let macroInstruction = instruction.0

          let argumentString: String?
          switch line {
          case let .arg(_, argumentOrNil, argumentText):
            if let argumentText = argumentText {
              argumentString = argumentText
            } else if let argument = argumentOrNil {
              argumentString = "\\\(argument)"
            } else {
              argumentString = nil
            }
          case let .any(_, argument: argumentOrNil, argumentText: argumentText):
            if let argumentText = argumentText {
              argumentString = argumentText
            } else if let argument = argumentOrNil {
              argumentString = "\\\(argument)"
            } else {
              argumentString = nil
            }
          case .instruction:
            argumentString = nil
          }

          let context = RGBDSDisassembler.Context(
            address: 0,
            bank: 0,
            disassembly: self,
            argumentString: argumentString
          )
          let macroAssembly = RGBDSDisassembler.statement(for: macroInstruction, with: context)
          return Line(semantic: .macroInstruction(macroInstruction, macroAssembly))
        })
        lines.append(Line(semantic: .macroTerminator))
        macrosAsm?.append(linesAsString(lines))
        macrosAsm?.append("\n")
      }
      if let macrosAsm = macrosAsm {
        sources["macros.asm"] = .macros(content: macrosAsm)
      }
    }

    gameAsm += ((UInt8(0)..<UInt8(numberOfBanks))
                  .map { "INCLUDE \"bank_\($0.hexString).asm\"" }
                  .joined(separator: "\n") + "\n")

    sources["game.asm"] = .game(content: gameAsm)

    let disassembledLocations = self.lastBankRouter!.disassembledLocations()
    let bankPercents: [Cartridge.Bank: Double] = (0..<numberOfBanks).reduce(into: [:]) { accumulator, bank in
      let disassembledBankLocations = disassembledLocations.intersection(
        IndexSet(integersIn: (Int(bank) * Int(Cartridge.bankSize))..<(Int(bank + 1) * Int(Cartridge.bankSize)))
      )
      accumulator[bank] = Double(disassembledBankLocations.count * 100) / Double(Cartridge.bankSize)
    }
    let statistics = Statistics(
      instructionsDecoded: instructionsDecoded.reduce(0, +),
      percent: Double(disassembledLocations.count * 100) / Double(cartridgeSize),
      bankPercents: bankPercents
    )

    return (Source(sources: sources), statistics)
  }

  public struct Statistics: Equatable {
    public let instructionsDecoded: Int
    public let percent: Double
    public let bankPercents: [Cartridge.Bank: Double]
  }
}
