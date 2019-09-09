import Foundation
import CPU

import AssemblyGenerator

extension Array {
  fileprivate func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

private func write(_ string: String) -> Data {
  return "\(string)\n".data(using: .utf8)!
}

private func line(_ transfersOfControl: Set<LR35902.Disassembly.TransferOfControl>, label: String) -> String {
  let sources = transfersOfControl
    .sorted(by: { $0.sourceLocation < $1.sourceLocation })
    .map {
      let (address, _) = LR35902.addressAndBank(from: $0.sourceLocation)
      return "\(LR35902.Instruction.opcodes[$0.sourceInstructionSpec]!) @ $\(address.hexString)"
    }
    .joined(separator: ", ")
  return line("\(label):", comment: "Sources: \(sources)")
}

private func extractArgs(from statement: RGBDSAssembly.Statement, using spec: LR35902.Instruction.Spec, argument: Int) -> [Int: String] {
  var args: [Int: String] = [:]
  spec.visit { (operand, index) in
    guard let operand = operand, let index = index else {
      return
    }

    switch operand {
    case LR35902.Instruction.Numeric.imm16,
         LR35902.Instruction.Numeric.imm8,
         LR35902.Instruction.Numeric.imm16addr,
         LR35902.Instruction.Numeric.simm8,
         LR35902.Instruction.Numeric.sp_plus_simm8,
         LR35902.Instruction.Numeric.ffimm8addr:
      args[argument] = Mirror(reflecting: statement).descendant(1, 0, index) as? String
    default:
      break
    }
  }
  return args
}

private func extractArgTypes(from instruction: LR35902.Instruction.Spec, using spec: LR35902.Instruction.Spec, argument: Int) -> [Int: String] {
  var args: [Int: String] = [:]
  spec.visit { (operand, index) in
    guard let operand = operand, let index = index else {
      return
    }

    switch operand {
    case LR35902.Instruction.Numeric.imm16,
         LR35902.Instruction.Numeric.imm8,
         LR35902.Instruction.Numeric.imm16addr,
         LR35902.Instruction.Numeric.simm8,
         LR35902.Instruction.Numeric.sp_plus_simm8,
         LR35902.Instruction.Numeric.ffimm8addr:
      if let operand = Mirror(reflecting: instruction).descendant(0, index) {
        args[argument] = "\(operand)"
      } else if let operand = Mirror(reflecting: instruction).descendant(index) {
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

extension LR35902.Disassembly {
  enum Line: Equatable, CustomStringConvertible {
    case newline
    case empty
    case macroComment(String)
    case preComment(String)
    case label(String)
    case transferOfControl(Set<TransferOfControl>, String)
    case instruction(LR35902.Instruction, RGBDSAssembly.Statement, LR35902.Address, LR35902.Bank, String, Data)
    case macroInstruction(LR35902.Instruction, RGBDSAssembly.Statement)
    case macro(String, LR35902.Address, LR35902.Bank, String, Data)
    case macroDefinition(String)
    case macroTerminator

    var description: String {
      switch self {
      case .newline:                           return ""
      case .empty:                             return ""
      case let .label(label):                  return "\(prettify(label)):"
      case let .macroComment(comment):         return "; \(comment)"
      case let .preComment(comment):           return line(comment: comment)
      case let .transferOfControl(toc, label): return line(toc, label: prettify(label))
      case let .instruction(_, assembly, address, bank, scope, bytes): return line(assembly.description, address: address, bank: bank, scope: scope, bytes: bytes)
      case let .macroInstruction(_, assembly): return line(assembly.description)
      case let .macro(assembly, address, bank, scope, bytes): return line(assembly, address: address, bank: bank, scope: scope, bytes: bytes)
      case let .macroDefinition(name):         return "\(name): MACRO"
      case .macroTerminator:                   return line("ENDM")
      }
    }
  }
  public func generateFiles() throws -> [String: Data] {
    var files: [String: Data] = [:]
    files["Makefile"] =
"""
all: game.gb

game.o: game.asm bank_*.asm
	rgbasm -h -o game.o game.asm

game.gb: game.o
	rgblink -d -n game.sym -m game.map -o $@ $<
	rgbfix -v -p 255 $@

	md5 $@

clean:
	rm -f game.o game.gb game.sym game.map *.o
	find . \\( -iname '*.1bpp' -o -iname '*.2bpp' \\) -exec rm {} +

""".data(using: .utf8)!

    var gameAsm = Data()

    if !dataTypes.isEmpty {
      var asm = Data(capacity: 1024 * 1024) // 1MB capacity

      for dataType in dataTypes.sorted(by: { $0.0 < $1.0 }) {
        guard !dataType.value.namedValues.isEmpty else {
          continue
        }
        asm.append("; Type: \(dataType.key)\n".data(using: .utf8)!)
        let namedValues = dataType.value.namedValues.sorted(by: { $0.key < $1.key })
        let longestVariable = namedValues.reduce(0) { (currentMax, next) in
          max(currentMax, next.value.count)
        }
        asm.append(namedValues.map {
          let name = $0.value.padding(toLength: longestVariable, withPad: " ", startingAt: 0)
          let value: String
          switch dataType.value.representation {
          case .binary:
            value = "%\($0.key.binaryString)"
          case .decimal:
            value = "\($0.key)"
          case .hexadecimal:
            value = "$\($0.key.hexString)"
          }
          return "\(name) EQU \(value)"
        }.joined(separator: "\n").data(using: .utf8)!)
        asm.append("\n\n".data(using: .utf8)!)
      }
      files["datatypes.asm"] = asm

      gameAsm.append("INCLUDE \"datatypes.asm\"\n".data(using: .utf8)!)
    }

    if !globals.isEmpty {
      var asm = Data()

      asm.append(globals.filter { $0.key >= 0x8000 }.sorted { $0.0 < $1.0 }.map { address, global in
        "\(global.name) EQU $\(address.hexString)"
      }.joined(separator: "\n\n").data(using: .utf8)!)

      files["variables.asm"] = asm
      gameAsm.append("INCLUDE \"variables.asm\"\n".data(using: .utf8)!)
    }

    if !characterMap.isEmpty {
      var asm = Data()

      asm.append(characterMap.sorted { $0.key < $1.key }.map { value, string in
        "charmap \"\(string)\", $\(value.hexString)"
      }.joined(separator: "\n").data(using: .utf8)!)

      files["charmap.asm"] = asm
      gameAsm.append("INCLUDE \"charmap.asm\"\n".data(using: .utf8)!)
    }

    var instructionsToDecode = Int.max
    var instructionsDecoded = 0

    var macrosAsm: Data? = nil

    for bank in UInt8(0)..<UInt8(cpu.numberOfBanks) {
      var asm = Data()
      defer {
        files["bank_\(bank.hexString).asm"] = asm
      }

      if bank == 0 {
        asm.append(write("SECTION \"ROM Bank \(bank.hexString)\", ROM0[$\(bank.hexString)]"))
      } else {
        asm.append(write("SECTION \"ROM Bank \(bank.hexString)\", ROMX[$4000], BANK[$\(bank.hexString)]"))
      }

      cpu.pc = (bank == 0) ? 0x0000 : 0x4000
      cpu.bank = bank
      let end: LR35902.Address = (bank == 0) ? 0x4000 : 0x8000

      var lineBufferAddress: LR35902.Address = cpu.pc
      var lineBuffer: [Line] = []
      lineBuffer.append(.empty)
      var macroNode: MacroNode? = nil

      let writeLines: ([Line]) -> Data = { lines in
        var data = Data()
        var lastLine: Line?
        lines.forEach { thisLine in
          if let lastLine = lastLine, lastLine == .empty && thisLine == .empty {
            return
          }
          data.append(write(thisLine.description))
          lastLine = thisLine
        }
        return data
      }

      let flush = {
        asm.append(writeLines(lineBuffer))
        lineBuffer.removeAll()
        macroNode = nil
      }

      let initialCheckMacro: (LR35902.Instruction) -> MacroNode? = { instruction in
        let asInstruction = MacroTreeEdge.instruction(instruction)
        let asAny = MacroTreeEdge.any(instruction.spec)
        guard macroNode == nil, let child = self.macroTree.children[asInstruction] ?? self.macroTree.children[asAny] else {
          return nil
        }
        return child
      }

      let followUpCheckMacro: (LR35902.Instruction, Bool) -> MacroNode? = { instruction, isLabeled in
        // Is this the beginning of a macro?
        guard let macroNodeIterator = macroNode else {
          return nil
        }
        let asInstruction = MacroTreeEdge.instruction(instruction)
        let asAny = MacroTreeEdge.any(instruction.spec)
        // Only descend the tree if we're not a label.
        guard !isLabeled, let child = macroNodeIterator.children[asInstruction] ?? macroNodeIterator.children[asAny] else {
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
          let instructions = lineBuffer.compactMap { thisLine -> (LR35902.Instruction, RGBDSAssembly.Statement)? in
            if case let .instruction(instruction, assembly, _, _, _, _) = thisLine {
              return (instruction, assembly)
            } else {
              return nil
            }
          }

          let macros: [(macro: LR35902.Disassembly.Macro, arguments: [Int: String], rawArguments: [Int: String])] = macroNodeIterator.macros.compactMap { macro in
            // Extract the arguments.
            var anyArgumentMismatches = false
            let arguments: [Int: String] = zip(macro.macroLines, instructions).reduce([:], { (iter, zipped) -> [Int: String] in
              guard case let .any(spec, argumentOrNil, _) = zipped.0,
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
              guard case let .any(spec, argumentOrNil, _) = zipped.0,
                let argument = argumentOrNil else {
                  return iter
              }
              let args = extractArgs(from: RGBDSAssembly.assembly(for: zipped.1.0), using: spec, argument: Int(argument))
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
            if !macro.macro.hasWritten {
              if macrosAsm == nil {
                macrosAsm = Data()
                gameAsm.append("INCLUDE \"macros.asm\"\n".data(using: .utf8)!)
              }

              var lines: [Line] = []
              lines.append(.empty)
              if !macro.arguments.isEmpty {
                lines.append(.macroComment("Arguments:"))

                let macroSpecs: [LR35902.Instruction.Spec] = macro.macro.macroLines.map { $0.spec() }

                let argumentTypes: [Int: String] = zip(macro.macro.macroLines, macroSpecs).reduce([:], { (iter, zipped) -> [Int: String] in
                  guard case let .any(spec, argumentOrNil, _) = zipped.0,
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
                    lines.append(.macroComment("- \(argNumber)\(argType): valid values in \(ranges)"))
                  } else {
                    lines.append(.macroComment("- \(argNumber)\(argType)"))
                  }
                }
              }
              lines.append(.macroDefinition(macro.macro.name))
              lines.append(contentsOf: zip(macro.macro.macroLines, instructions).map { line, instruction in
                var macroInstruction = instruction.0
                macroInstruction.spec = line.spec()
                let argumentString: String?
                if case let .any(_, argumentOrNil, argumentText) = line {
                  if let argumentText = argumentText {
                    argumentString = argumentText
                  } else if let argument = argumentOrNil {
                    argumentString = "\\\(argument)"
                  } else {
                    argumentString = nil
                  }
                } else {
                  argumentString = nil
                }
                let macroAssembly = RGBDSAssembly.assembly(for: macroInstruction, with: self, argumentString: argumentString)
                return .macroInstruction(macroInstruction, macroAssembly)
              })
              lines.append(.macroTerminator)
              macrosAsm?.append(writeLines(lines))

              macro.macro.hasWritten = true
            }

            let lowerBound = LR35902.cartridgeLocation(for: lineBufferAddress, in: bank)!
            let upperBound = LR35902.cartridgeLocation(for: lastAddress, in: bank)!
            let bytes = self.cpu[lowerBound..<upperBound]

            let macroArgs = macro.arguments.keys.sorted().map { macro.arguments[$0]! }.joined(separator: ", ")

            let firstInstruction = lineBuffer.firstIndex { line in if case .instruction = line { return true } else { return false} }!
            let lastInstruction = lineBuffer.lastIndex { line in if case .instruction = line { return true } else { return false} }!
            let bank: LR35902.Bank
            if case let .instruction(_, _, _, instructionBank, _, _) = lineBuffer[lastInstruction] {
              bank = instructionBank
            } else {
              bank = self.cpu.bank
            }
            let macroScopes = self.labeledContiguousScopes(at: lineBufferAddress, in: bank).map { $0.label }
            lineBuffer.replaceSubrange(firstInstruction...lastInstruction,
                                       with: [.macro("\(macro.macro.name) \(macroArgs)", lineBufferAddress, bank, macroScopes.sorted().joined(separator: ", "), bytes)])

            if let action = macro.macro.action {
              action(macro.arguments, lineBufferAddress, bank)
            }
            lineBufferAddress = self.cpu.pc
          } else {
            flush()
          }
        } else {
          flush()
        }
        macroNode = nil
      }

      while cpu.pc < end {
        var isLabeled = false
        var lineGroup: [Line] = []
        if let preComment = preComment(at: cpu.pc, in: bank) {
          lineGroup.append(.empty)
          lineGroup.append(.preComment(preComment))
        }
        if let label = label(at: cpu.pc, in: bank) {
          if let transfersOfControl = transfersOfControl(at: cpu.pc, in: bank) {
            lineGroup.append(.transferOfControl(transfersOfControl, label))
          } else {
            lineGroup.append(.empty)
            lineGroup.append(.label(label))
          }
          isLabeled = true
        }

        if instructionsToDecode > 0, let instruction = instruction(at: cpu.pc, in: bank) {
          instructionsToDecode -= 1
          instructionsDecoded += 1

          if let bankChange = bankChange(at: cpu.pc, in: bank) {
            cpu.bank = bankChange
          }

          // Write the instruction as assembly.
          let index = LR35902.cartridgeLocation(for: cpu.pc, in: bank)!
          let instructionWidth = LR35902.Instruction.widths[instruction.spec]!.total
          let bytes = cpu[index..<(index + LR35902.CartridgeLocation(instructionWidth))]
          let instructionScope = labeledContiguousScopes(at: cpu.pc, in: bank).map { $0.label }
          lineGroup.append(.instruction(instruction, RGBDSAssembly.assembly(for: instruction, with: self), cpu.pc, cpu.bank, instructionScope.sorted().joined(separator: ", "), bytes))

          cpu.pc += instructionWidth

          // TODO: Start a macro descent for every instruction.

          if let child = initialCheckMacro(instruction) {
            flush()
            lineBufferAddress = self.cpu.pc - instructionWidth
            macroNode = child
          } else if let child = followUpCheckMacro(instruction, isLabeled) {
            macroNode = child
          } else {
            let instructionWidth = LR35902.Instruction.widths[instruction.spec]!.total
            try flushMacro(cpu.pc - instructionWidth)
          }

          // Handle context changes.
          switch instruction.spec {
          case .jp(let condition, _), .jr(let condition, _):
            lineGroup.append(.empty)
            if condition == nil {
              cpu.bank = bank
            }
          case .ret(let condition):
            lineGroup.append(.newline)
            if condition == nil {
              lineGroup.append(.empty)
              cpu.bank = bank
            }
          case .reti:
            lineGroup.append(.newline)
            lineGroup.append(.empty)
            cpu.bank = bank
          default:
            break
          }

          lineBuffer.append(contentsOf: lineGroup)

          // Immediately start looking for the next macro.
          if let child = initialCheckMacro(instruction) {
            lineBufferAddress = self.cpu.pc - instructionWidth
            macroNode = child
          }

        } else {
          try flushMacro(cpu.pc)

          lineBuffer.append(contentsOf: lineGroup)
          flush()

          // Accumulate bytes until the next instruction or transfer of control.
          var accumulator: [UInt8] = []
          let initialPc = cpu.pc
          let initialType = type(of: cpu.pc, in: bank)
          var global: Global?
          repeat {
            if cpu.pc < 0x4000 {
              global = globals[cpu.pc]
            }
            accumulator.append(cpu[cpu.pc, bank])
            cpu.pc += 1
          } while cpu.pc < end
            && (instructionsToDecode == 0 || instruction(at: cpu.pc, in: bank) == nil)
            && label(at: cpu.pc, in: bank) == nil
            && type(of: cpu.pc, in: bank) == initialType
            && global == nil

          let globalValue: String?
          if let global = global,
            let dataType = global.dataType,
            let type = dataTypes[dataType],
            let value = type.namedValues[accumulator.last!] {
            globalValue = value
            accumulator.removeLast()
          } else {
            globalValue = nil
          }

          var chunkPc = initialPc
          switch initialType {
          case .text:
            let lineLength = lineLengthOfText(at: initialPc, in: bank) ?? 254
            for chunk in accumulator.chunked(into: lineLength) {
              asm.append(write(line(RGBDSAssembly.text(for: chunk, characterMap: characterMap), address: chunkPc, addressType: "text")))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .jumpTable:
            for (index, pair) in accumulator.chunked(into: 2).enumerated() {
              let address = (LR35902.Address(pair[1]) << 8) | LR35902.Address(pair[0])
              let jumpLocation: String
              let effectiveBank: LR35902.Bank
              if let changedBank = bankChange(at: chunkPc, in: bank) {
                effectiveBank = changedBank
              } else {
                effectiveBank = cpu.bank
              }
              if let label = label(at: address, in: effectiveBank) {
                jumpLocation = label
              } else {
                jumpLocation = "$\(address.hexString)"
              }
              let bytes = cpu[LR35902.cartridgeLocation(for: chunkPc, in: bank)!..<(LR35902.cartridgeLocation(for: chunkPc, in: bank)! + 2)]
              asm.append(write(line("dw \(jumpLocation)", address: chunkPc, addressType: "jumpTable [\(index)]", comment: "\(bytes.map { "$\($0.hexString)" }.joined(separator: " "))")))
              chunkPc += LR35902.Address(pair.count)
            }
            break
          default:
            // Dump the bytes in blocks of 8.
            let addressType = initialType == .data ? "data" : nil
            for chunk in accumulator.chunked(into: 8) {
              let instruction = RGBDSAssembly.assembly(for: chunk)
              let displayableBytes = chunk.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
              let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
              asm.append(write(line(instruction, address: chunkPc, addressType: addressType, comment: "|\(bytesAsCharacters)|")))
              chunkPc += LR35902.Address(chunk.count)
            }
          }

          if let global = global,
            let dataType = global.dataType,
            let globalValue = globalValue {
            asm.append(write(line(RGBDSAssembly.assembly(for: globalValue), address: chunkPc, addressType: dataType)))
          }

          lineBuffer.append(.empty)
          lineBufferAddress = cpu.pc
          cpu.bank = bank
        }
      }

      flush()
    }

    files["macros.asm"] = macrosAsm
    gameAsm.append(
      ((UInt8(0)..<UInt8(cpu.numberOfBanks))
        .map { "INCLUDE \"bank_\($0.hexString).asm\"" }
        .joined(separator: "\n") + "\n")
        .data(using: .utf8)!)

    files["game.asm"] = gameAsm

    print("Instructions decoded: \(instructionsDecoded)")

    let disassembledLocations = knownLocations()
    print("Disassembled: \(Double(disassembledLocations.count * 100) / Double(cpu.cartridgeSize))%")
    for bank in 0..<cpu.numberOfBanks {
      let disassembledBankLocations = disassembledLocations.intersection(IndexSet(integersIn:
        (Int(bank) * Int(LR35902.bankSize))..<(Int(bank + 1) * Int(LR35902.bankSize))))
      print("Bank \(bank.hexString): \(Double(disassembledBankLocations.count * 100) / Double(LR35902.bankSize))%")
    }
    return files
  }
}
