import Foundation
import CPU

import AssemblyGenerator

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

private func extractArgs(from statement: RGBDSAssembly.Statement, using spec: LR35902.Instruction.Spec, argument: Int) -> [Int: String] {
  var args: [Int: String] = [:]
  spec.visit { operand in
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
      args[argument] = Mirror(reflecting: statement).descendant(1, 0, operand.index) as? String
    default:
      break
    }
  }
  return args
}

private func extractArgTypes(from instruction: LR35902.Instruction.Spec, using spec: LR35902.Instruction.Spec, argument: Int) -> [Int: String] {
  var args: [Int: String] = [:]
  spec.visit { operand in
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

extension LR35902.Disassembly {
  public struct Line: Equatable {
    public enum ImageFormat {
      case oneBitPerPixel
      case twoBitsPerPixel
    }
    public enum Semantic: Equatable {
      case newline
      case empty
      case macroComment(comment: String)
      case preComment(comment: String)
      case label(labelName: String)
      case section(LR35902.Bank)
      case transferOfControl(Set<TransferOfControl>, String)
      case instruction(LR35902.Instruction, RGBDSAssembly.Statement)
      case macroInstruction(LR35902.Instruction, RGBDSAssembly.Statement)
      case macro(String)
      case macroDefinition(String)
      case macroTerminator
      case imagePlaceholder(format: ImageFormat)
      case image1bpp(RGBDSAssembly.Statement)
      case image2bpp(RGBDSAssembly.Statement)
      case data(RGBDSAssembly.Statement)
      case text(RGBDSAssembly.Statement)
      case jumpTable(String, Int)
      case unknown(RGBDSAssembly.Statement)
      case global(RGBDSAssembly.Statement, dataTypeName: String, dataType: Datatype)
    }

    init(semantic: Semantic, address: LR35902.Address? = nil, bank: LR35902.Bank? = nil, scope: String? = nil, data: Data? = nil) {
      self.semantic = semantic
      self.address = address
      self.bank = bank
      if let scope = scope {
        if scope.isEmpty {
          self.scope = nil
        } else {
          self.scope = scope
        }
      } else {
        self.scope = nil
      }
      self.data = data
    }

    public let semantic: Semantic
    public let address: LR35902.Address?
    public let bank: LR35902.Bank?
    public let scope: String?
    public let data: Data?

    public func asString(detailedComments: Bool) -> String {
      switch semantic {
      case .newline:                           return ""

      case .empty:                             return ""

      case .imagePlaceholder:                  return ""

      case let .label(label):                  return "\(prettify(label)):"

      case let .section(bank):
        if bank == 0 {
          return "SECTION \"ROM Bank \(bank.hexString)\", ROM0[$\(bank.hexString)]"
        } else {
          return "SECTION \"ROM Bank \(bank.hexString)\", ROMX[$4000], BANK[$\(bank.hexString)]"
        }
      case let .macroComment(comment):         return "; \(comment)"

      case let .preComment(comment):           return line(comment: comment)

      case let .transferOfControl(toc, label):
        if detailedComments {
          let sources = toc
            .sorted(by: { $0.sourceLocation < $1.sourceLocation })
            .map {
              let (address, _) = LR35902.Cartridge.addressAndBank(from: $0.sourceLocation)
              return "\(LR35902.InstructionSet.opcodeStrings[$0.sourceInstructionSpec]!) @ $\(address.hexString)"
            }
            .joined(separator: ", ")
          return line("\(label):", comment: "Sources: \(sources)")
        } else {
          return line("\(label):", comment: nil)
        }

      case let .instruction(_, assembly):
        if detailedComments {
          return line(assembly.description, address: address!, bank: bank!, scope: scope!, bytes: data!)
        } else {
          return line(assembly.description)
        }

      case let .macroInstruction(_, assembly): return line(assembly.description)

      case let .macro(assembly):
        if detailedComments {
          return line(assembly, address: address!, bank: bank!, scope: scope!, bytes: data!)
        } else {
          return line(assembly)
        }

      case let .macroDefinition(name):         return "\(name): MACRO"

      case .macroTerminator:                   return line("ENDM")

      case let .text(statement):
        if detailedComments {
          return line(statement.description, address: address!, addressType: "text")
        } else {
          return line(statement.description)
        }

      case let .jumpTable(jumpLocation, index):
        if detailedComments {
          return line("dw \(jumpLocation)", address: address!, addressType: "jumpTable [\(index)]", comment: "\(data!.map { "$\($0.hexString)" }.joined(separator: " "))")
        } else {
          return line("dw \(jumpLocation)", addressType: "jumpTable [\(index)]")
        }

      case let .image1bpp(statement):
        if detailedComments {
          let displayableBytes = data!.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
          let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
          return line(statement.description, address: address!, addressType: "image1bpp", comment: "|\(bytesAsCharacters)|")
        } else {
          return line(statement.description)
        }

      case let .image2bpp(statement):
        if detailedComments {
          let displayableBytes = data!.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
          let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
          return line(statement.description, address: address!, addressType: "image2bpp", comment: "|\(bytesAsCharacters)|")
        } else {
          return line(statement.description)
        }

      case let .data(statement):
        if detailedComments {
          let displayableBytes = data!.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
          let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
          return line(statement.description, address: address!, addressType: "data", comment: "|\(bytesAsCharacters)|")
        } else {
          return line(statement.description)
        }

      case let .unknown(statement):
        if detailedComments {
          let displayableBytes = data!.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
          let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
          return line(statement.description, address: address!, addressType: nil, comment: "|\(bytesAsCharacters)|")
        } else {
          return line(statement.description)
        }

      case let .global(statement, addressType, _):
        if detailedComments {
          return line(statement.description, address: address!, addressType: addressType)
        } else {
          return line(statement.description)
        }
      }
    }

    public var description: String {
      return asString(detailedComments: true)
    }

    var asString: String {
      return asString(detailedComments: true) + "\n"
    }

    public var asEditorString: String {
      return asString(detailedComments: false) + "\n"
    }
  }

  public struct Source {
    public enum FileDescription {
      case charmap(content: String)
      case datatypes(content: String)
      case game(content: String)
      case macros(content: String)
      case makefile(content: String)
      case variables(content: String)
      case bank(number: LR35902.Bank, content: String, lines: [Line])
    }
    public let sources: [String: FileDescription]
  }

  public func generateSource() throws -> (Source, Statistics) {
    var sources: [String: Source.FileDescription] = [:]

    sources["Makefile"] = .makefile(content:
      """
all: game.gb

game.o: game.asm bank_*.asm
\trgbasm -h -o game.o game.asm

game.gb: game.o
\trgblink -d -n game.sym -m game.map -o $@ $<
\trgbfix -v -p 255 $@

\tmd5 $@

clean:
\trm -f game.o game.gb game.sym game.map *.o
\tfind . \\( -iname '*.1bpp' -o -iname '*.2bpp' \\) -exec rm {} +

""")

    var gameAsm = ""

    if !dataTypes.isEmpty {
      var asm = String()

      for dataType in dataTypes.sorted(by: { $0.0 < $1.0 }) {
        guard !dataType.value.namedValues.isEmpty else {
          continue
        }
        asm += "; Type: \(dataType.key)\n"
        let namedValues = dataType.value.namedValues.sorted(by: { $0.key < $1.key })
        let longestVariable = namedValues.reduce(0) { (currentMax, next) in
          max(currentMax, next.value.count)
        }
        asm += namedValues.map {
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
        }.joined(separator: "\n")
        asm += "\n\n"
      }
      sources["datatypes.asm"] = .datatypes(content: asm)
      gameAsm += "INCLUDE \"datatypes.asm\"\n"
    }

    if !globals.isEmpty {
      let asm = globals.filter { $0.key >= 0x8000 }.sorted { $0.0 < $1.0 }.map { address, global in
        "\(global.name) EQU $\(address.hexString)"
      }.joined(separator: "\n\n")

      sources["variables.asm"] = .variables(content: asm)
      gameAsm += "INCLUDE \"variables.asm\"\n"
    }

    if !characterMap.isEmpty {
      let asm = characterMap.sorted { $0.key < $1.key }.map { value, string in
        "charmap \"\(string)\", $\(value.hexString)"
      }.joined(separator: "\n")

      sources["charmap.asm"] = .charmap(content: asm)
      gameAsm += "INCLUDE \"charmap.asm\"\n"
    }

    var instructionsToDecode = Int.max
    var instructionsDecoded = 0

    var macrosAsm: String? = nil

    for bank in UInt8(0)..<UInt8(cpu.cartridge.numberOfBanks) {
      var bankLines: [Line] = []
      defer {
        var lastLine: Line?
        let filteredBankLines = bankLines.filter { thisLine in
          if let lastLine = lastLine, lastLine.semantic == .empty && thisLine.semantic == .empty {
            return false
          }
          lastLine = thisLine
          return true
        }
        sources["bank_\(bank.hexString).asm"] = .bank(number: bank, content: linesAsString(filteredBankLines), lines: filteredBankLines)
      }

      let linesAsString: ([Line]) -> String = { lines in
        return lines.map { $0.asString(detailedComments: false) }.joined(separator: "\n")
      }

      bankLines.append(Line(semantic: .section(bank)))

      cpu.pc = (bank == 0) ? 0x0000 : 0x4000
      cpu.bank = bank
      let end: LR35902.Address = (bank == 0) ? (cpu.cartridge.size < 0x4000 ? LR35902.Address(cpu.cartridge.size) : 0x4000) : 0x8000

      var lineBufferAddress: LR35902.Address = cpu.pc
      var lineBuffer: [Line] = []
      lineBuffer.append(Line(semantic: .empty))
      var macroNode: MacroNode? = nil

      let flush = {
        bankLines += lineBuffer
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
            if case let .instruction(instruction, assembly) = thisLine.semantic {
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
                macrosAsm = ""
                gameAsm += "INCLUDE \"macros.asm\"\n"
              }

              var lines: [Line] = []
              lines.append(Line(semantic: .empty))
              if !macro.arguments.isEmpty {
                lines.append(Line(semantic: .macroComment(comment: "Arguments:")))

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
                    lines.append(Line(semantic: .macroComment(comment: "- \(argNumber)\(argType): valid values in \(ranges)")))
                  } else {
                    lines.append(Line(semantic: .macroComment(comment: "- \(argNumber)\(argType)")))
                  }
                }
              }
              lines.append(Line(semantic: .macroDefinition(macro.macro.name)))
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
                return Line(semantic: .macroInstruction(macroInstruction, macroAssembly))
              })
              lines.append(Line(semantic: .macroTerminator))
              macrosAsm?.append(linesAsString(lines))

              macro.macro.hasWritten = true
            }

            let lowerBound = LR35902.Cartridge.location(for: lineBufferAddress, in: bank)!
            let upperBound = LR35902.Cartridge.location(for: lastAddress, in: bank)!
            let bytes = self.cpu.cartridge[lowerBound..<upperBound]

            let macroArgs = macro.arguments.keys.sorted().map { macro.arguments[$0]! }.joined(separator: ", ")

            let firstInstruction = lineBuffer.firstIndex { line in if case .instruction = line.semantic { return true } else { return false} }!
            let lastInstruction = lineBuffer.lastIndex { line in if case .instruction = line.semantic { return true } else { return false} }!
            let bank: LR35902.Bank
            if case .instruction = lineBuffer[lastInstruction].semantic {
              bank = lineBuffer[lastInstruction].bank!
            } else {
              bank = self.cpu.bank
            }
            let macroScopes = self.labeledContiguousScopes(at: lineBufferAddress, in: bank).map { $0.label }
            lineBuffer.replaceSubrange(firstInstruction...lastInstruction,
                                       with: [Line(semantic: .macro("\(macro.macro.name) \(macroArgs)"),
                                                   address: lineBufferAddress,
                                                   bank: bank,
                                                   scope: macroScopes.sorted().joined(separator: ", "),
                                                   data: bytes)])

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
          lineGroup.append(Line(semantic: .empty))
          lineGroup.append(Line(semantic: .preComment(comment: preComment)))
        }
        if let label = label(at: cpu.pc, in: bank) {
          if let transfersOfControl = transfersOfControl(at: cpu.pc, in: bank) {
            lineGroup.append(Line(semantic: .transferOfControl(transfersOfControl, label), address: cpu.pc, bank: cpu.bank))
          } else {
            let instructionScope = labeledContiguousScopes(at: cpu.pc, in: bank).map { $0.label }
            let scope = instructionScope.sorted().joined(separator: ", ")
            lineGroup.append(Line(semantic: .empty, address: cpu.pc, bank: cpu.bank, scope: scope))
            lineGroup.append(Line(semantic: .label(labelName: label), address: cpu.pc, bank: cpu.bank, scope: scope))
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
          let index = LR35902.Cartridge.location(for: cpu.pc, in: bank)!
          let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!.total
          let bytes = cpu.cartridge[index..<(index + LR35902.Cartridge.Location(instructionWidth))]
          let instructionScope = labeledContiguousScopes(at: cpu.pc, in: bank).map { $0.label }
          lineGroup.append(Line(semantic: .instruction(instruction, RGBDSAssembly.assembly(for: instruction, with: self)),
                                address: cpu.pc,
                                bank: cpu.bank,
                                scope: instructionScope.sorted().joined(separator: ", "),
                                data: bytes))

          cpu.pc += instructionWidth

          // TODO: Start a macro descent for every instruction.

          if let child = initialCheckMacro(instruction) {
            flush()
            lineBufferAddress = self.cpu.pc - instructionWidth
            macroNode = child
          } else if let child = followUpCheckMacro(instruction, isLabeled) {
            macroNode = child
          } else {
            let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!.total
            try flushMacro(cpu.pc - instructionWidth)
          }

          // Handle context changes.
          switch instruction.spec {
          case .jp(let condition, _), .jr(let condition, _):
            let instructionScope = labeledContiguousScopes(at: cpu.pc, in: bank).map { $0.label }
            let scope = instructionScope.sorted().joined(separator: ", ")
            lineGroup.append(Line(semantic: .empty, scope: scope))
            if condition == nil {
              cpu.bank = bank
            }
          case .ret(let condition):
            lineGroup.append(Line(semantic: .newline))
            if condition == nil {
              lineGroup.append(Line(semantic: .empty))
              cpu.bank = bank
            }
          case .reti:
            lineGroup.append(Line(semantic: .newline))
            lineGroup.append(Line(semantic: .empty))
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
            accumulator.append(cpu.cartridge[cpu.pc, bank])
            cpu.pc += 1
          } while cpu.pc < end
            && (instructionsToDecode == 0 || instruction(at: cpu.pc, in: bank) == nil)
            && label(at: cpu.pc, in: bank) == nil
            && type(of: cpu.pc, in: bank) == initialType
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
            let lineLength = lineLengthOfText(at: initialPc, in: bank) ?? 36
            for chunk in accumulator.chunked(into: lineLength) {
              bankLines.append(RGBDSAssembly.textLine(for: chunk, characterMap: characterMap, address: chunkPc))
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
              let bytes = cpu.cartridge[LR35902.Cartridge.location(for: chunkPc, in: bank)!..<(LR35902.Cartridge.location(for: chunkPc, in: bank)! + 2)]
              bankLines.append(Line(semantic: .jumpTable(jumpLocation, index), address: chunkPc, data: bytes))
              chunkPc += LR35902.Address(pair.count)
            }
            break
          case .unknown:
            for chunk in accumulator.chunked(into: 8) {
              bankLines.append(Line(semantic: .unknown(RGBDSAssembly.statement(for: chunk)), address: chunkPc, data: Data(chunk)))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .data:
            for chunk in accumulator.chunked(into: 8) {
              bankLines.append(Line(semantic: .data(RGBDSAssembly.statement(for: chunk)), address: chunkPc, data: Data(chunk)))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .image2bpp:
            bankLines.append(Line(semantic: .imagePlaceholder(format: .twoBitsPerPixel), address: chunkPc, data: Data(accumulator)))
            for chunk in accumulator.chunked(into: 8) {
              bankLines.append(Line(semantic: .image2bpp(RGBDSAssembly.statement(for: chunk)), address: chunkPc, data: Data(chunk)))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .image1bpp:
            bankLines.append(Line(semantic: .imagePlaceholder(format: .oneBitPerPixel), address: chunkPc, data: Data(accumulator)))
            for chunk in accumulator.chunked(into: 8) {
              bankLines.append(Line(semantic: .image1bpp(RGBDSAssembly.statement(for: chunk)), address: chunkPc, data: Data(chunk)))
              chunkPc += LR35902.Address(chunk.count)
            }
          case .code:
            preconditionFailure()
          case .ram:
            preconditionFailure()
          }

          if let global = global,
             let dataTypeName = global.dataType,
             let dataType = dataTypes[dataTypeName],
             let globalValue = globalValue {
            bankLines.append(Line(semantic: .global(RGBDSAssembly.statement(for: globalValue), dataTypeName: dataTypeName, dataType: dataType), address: chunkPc, data: globalData))
          }

          lineBuffer.append(Line(semantic: .empty))
          lineBufferAddress = cpu.pc
          cpu.bank = bank
        }
      }

      flush()
    }

    if let macrosAsm = macrosAsm {
      sources["macros.asm"] = .macros(content: macrosAsm)
    }
    gameAsm += ((UInt8(0)..<UInt8(cpu.cartridge.numberOfBanks))
                  .map { "INCLUDE \"bank_\($0.hexString).asm\"" }
                  .joined(separator: "\n") + "\n")

    sources["game.asm"] = .game(content: gameAsm)

    let disassembledLocations = knownLocations()
    let bankPercents: [LR35902.Bank: Double] = (0..<cpu.cartridge.numberOfBanks).reduce(into: [:]) { accumulator, bank in
      let disassembledBankLocations = disassembledLocations.intersection(
        IndexSet(integersIn: (Int(bank) * Int(LR35902.bankSize))..<(Int(bank + 1) * Int(LR35902.bankSize)))
      )
      accumulator[bank] = Double(disassembledBankLocations.count * 100) / Double(LR35902.bankSize)
    }
    let statistics = Statistics(
      instructionsDecoded: instructionsDecoded,
      percent: Double(disassembledLocations.count * 100) / Double(cpu.cartridge.size),
      bankPercents: bankPercents
    )

    return (Source(sources: sources), statistics)
  }

  public struct Statistics {
    public let instructionsDecoded: Int
    public let percent: Double
    public let bankPercents: [LR35902.Bank: Double]
  }
}
