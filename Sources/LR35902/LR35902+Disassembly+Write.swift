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

private func write(_ string: String, fileHandle: FileHandle) {
  fileHandle.write("\(string)\n".data(using: .utf8)!)
}

private func line(_ transfersOfControl: Set<LR35902.Disassembly.TransferOfControl>, label: String) -> String {
  let sources = transfersOfControl
    .sorted(by: { $0.sourceLocation < $1.sourceLocation })
    .map {
      let (address, _) = LR35902.addressAndBank(from: $0.sourceLocation)
      return "\($0.sourceInstructionSpec.opcode) @ $\(address.hexString)"
    }
    .joined(separator: ", ")
  return line("\(label):", comment: "Sources: \(sources)")
}

extension FileManager {
  fileprivate func restartFile(atPath path: String) throws -> FileHandle {
    if fileExists(atPath: path) {
      try removeItem(atPath: path)
    }
    createFile(atPath: path, contents: Data(), attributes: nil)
    return try FileHandle(forWritingTo: URL(fileURLWithPath: path))
  }
}

private func extractArgs(from statement: RGBDSAssembly.Statement, using spec: LR35902.Instruction.Spec) -> [Int: String] {
  var args: [Int: String] = [:]
  spec.visit { (operand, index) in
    guard let operand = operand, let index = index else {
      return
    }

    if case let LR35902.Instruction.Numeric.arg(argumentNumber) = operand {
      args[argumentNumber] = Mirror(reflecting: statement).descendant(1, 0, index) as? String
    }
  }
  return args
}

private func extractArgTypes(from instruction: LR35902.Instruction.Spec, using spec: LR35902.Instruction.Spec) -> [Int: String] {
  var args: [Int: String] = [:]
  spec.visit { (operand, index) in
    guard let operand = operand, let index = index else {
      return
    }

    if case LR35902.Instruction.Numeric.arg(let argNumber) = operand {
      if let operand = Mirror(reflecting: instruction).descendant(0, index) {
        args[argNumber] = "\(operand)"
      } else if let operand = Mirror(reflecting: instruction).descendant(index) {
        args[argNumber] = "\(operand)"
      }
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
    case instruction(LR35902.Instruction, RGBDSAssembly.Statement, LR35902.Address, LR35902.Bank, String?, Data)
    case macroInstruction(LR35902.Instruction, RGBDSAssembly.Statement)
    case macro(String, LR35902.Address, LR35902.Bank, String?, Data)
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
  public func writeTo(directory: String) throws {
    let fm = FileManager.default
    let directoryUrl = URL(fileURLWithPath: directory)
    try fm.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)

    let makefileHandle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("Makefile").path)

    makefileHandle.write(
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

""".data(using: .utf8)!)

    var macrosHandle: FileHandle? = nil

    let gameHandle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("game.asm").path)

    if !dataTypes.isEmpty {
      let handle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("datatypes.asm").path)

      for dataType in dataTypes.sorted(by: { $0.0 < $1.0 }) {
        handle.write("; Type: \(dataType.key)\n".data(using: .utf8)!)
        let namedValues = dataType.value.namedValues.sorted(by: { $0.key < $1.key })
        let longestVariable = namedValues.reduce(0) { (currentMax, next) in
          max(currentMax, next.value.count)
        }
        handle.write(namedValues.map {
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
        handle.write("\n\n".data(using: .utf8)!)
      }

      gameHandle.write("INCLUDE \"datatypes.asm\"\n".data(using: .utf8)!)
    }

    if !globals.isEmpty {
      let variablesHandle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("variables.asm").path)

      variablesHandle.write(globals.filter { $0.key >= 0x8000 }.sorted { $0.0 < $1.0 }.map { address, global in
        "\(global.name) EQU $\(address.hexString)"
      }.joined(separator: "\n\n").data(using: .utf8)!)

      gameHandle.write("INCLUDE \"variables.asm\"\n".data(using: .utf8)!)
    }

    var instructionsToDecode = Int.max
    var instructionsDecoded = 0

    for bank in UInt8(0)..<UInt8(cpu.numberOfBanks) {
      let fileHandle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("bank_\(bank.hexString).asm").path)

      if bank == 0 {
        write("SECTION \"ROM Bank \(bank.hexString)\", ROM0[$\(bank.hexString)]", fileHandle: fileHandle)
      } else {
        write("SECTION \"ROM Bank \(bank.hexString)\", ROMX[$4000], BANK[$\(bank.hexString)]", fileHandle: fileHandle)
      }

      cpu.pc = (bank == 0) ? 0x0000 : 0x4000
      cpu.bank = bank
      let end: LR35902.Address = (bank == 0) ? 0x4000 : 0x8000

      var lineBufferAddress: LR35902.Address = cpu.pc
      var lineBuffer: [Line] = []
      lineBuffer.append(.empty)
      var macroNode: MacroNode? = nil

      let writeLinesToFile: ([Line], FileHandle) -> Void = { lines, fileHandle in
        var lastLine: Line?
        lines.forEach { thisLine in
          if let lastLine = lastLine, lastLine == .empty && thisLine == .empty {
            return
          }
          write(thisLine.description, fileHandle: fileHandle)
          lastLine = thisLine
        }
      }

      let flush = {
        writeLinesToFile(lineBuffer, fileHandle)
        lineBuffer.removeAll()
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
          let index = LR35902.cartAddress(for: cpu.pc, in: bank)!
          let instructionWidth = LR35902.Instruction.widths[instruction.spec]!.total
          let bytes = cpu[index..<(index + LR35902.CartridgeLocation(instructionWidth))]
          let instructionScope = contiguousScope(at: cpu.pc, in: bank)
          lineGroup.append(.instruction(instruction, RGBDSAssembly.assembly(for: instruction, with: self), cpu.pc, cpu.bank, instructionScope, bytes))

          cpu.pc += instructionWidth

          // TODO: Start a macro descent for every instruction.

          // Is this the beginning of a macro?
          let asInstruction = MacroLine.instruction(instruction)
          let asAny = MacroLine.any(instruction.spec)
          if macroNode == nil, let child = macroTree.children[asInstruction] ?? macroTree.children[asAny] {
            flush()
            lineBufferAddress = cpu.pc - instructionWidth
            macroNode = child

          } else if let macroNodeIterator = macroNode {
            // Only descend the tree if we're not a label.
            if !isLabeled, let child = macroNodeIterator.children[asInstruction] ?? macroNodeIterator.children[asAny] {
              macroNode = child
            } else {
              // No further nodes to be traversed; is this the end of a macro?
              if !macroNodeIterator.macros.isEmpty {
                let instructions = lineBuffer.compactMap { thisLine -> (LR35902.Instruction, RGBDSAssembly.Statement)? in
                  if case let .instruction(instruction, assembly, _, _, _, _) = thisLine {
                    return (instruction, assembly)
                  } else {
                    return nil
                  }
                }

                let macros: [(macro: LR35902.Disassembly.Macro, code: [LR35902.Instruction.Spec], arguments: [Int: String], rawArguments: [Int: String])] = macroNodeIterator.macros.map { macro in

                  var code: [LR35902.Instruction.Spec]
                  if let macroCode = macro.code {
                    code = macroCode
                  } else {
                    code = macro.macroLines.map {
                      if case .instruction(let instruction) = $0 {
                        return instruction.spec
                      }
                      preconditionFailure("Unhandled")
                    }
                  }
                  // Extract the arguments.
                  let arguments: [Int: String] = zip(code, instructions).reduce([:], { (iter, zipped) -> [Int: String] in
                    let args = extractArgs(from: zipped.1.1, using: zipped.0)
                    return iter.merging(args, uniquingKeysWith: { first, second in
                      assert(first == second, "Mismatch in arguments")
                      return first
                    })
                  })

                  let rawArguments: [Int: String] = zip(code, instructions).reduce([:], { (iter, zipped) -> [Int: String] in
                    let args = extractArgs(from: RGBDSAssembly.assembly(for: zipped.1.0), using: zipped.0)
                    return iter.merging(args, uniquingKeysWith: { first, second in
                      assert(first == second, "Mismatch in arguments")
                      return first
                    })
                  })

                  return (macro: macro, code: code, arguments: arguments, rawArguments: rawArguments)
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
                    if macrosHandle == nil {
                      macrosHandle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("macros.asm").path)
                      gameHandle.write("INCLUDE \"macros.asm\"\n".data(using: .utf8)!)
                    }

                    var lines: [Line] = []
                    lines.append(.empty)
                    if !macro.arguments.isEmpty {
                      lines.append(.macroComment("Arguments:"))

                      let macroSpecs: [LR35902.Instruction.Spec] = macro.macro.macroLines.map {
                        switch $0 {
                        case .instruction(let instruction):
                          return instruction.spec
                        case .any(let spec):
                          return spec
                        }
                      }

                      let argumentTypes: [Int: String] = zip(macro.code, macroSpecs).reduce([:], { (iter, zipped) -> [Int: String] in
                        let args = extractArgTypes(from: zipped.1, using: zipped.0)
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
                    lines.append(contentsOf: zip(macro.code, instructions).map { spec, instruction in
                      var macroInstruction = instruction.0
                      macroInstruction.spec = spec
                      let macroAssembly = RGBDSAssembly.assembly(for: macroInstruction, with: self)
                      return .macroInstruction(macroInstruction, macroAssembly)
                    })
                    lines.append(.macroTerminator)
                    writeLinesToFile(lines, macrosHandle!)

                    macro.macro.hasWritten = true
                  }

                  let lowerBound = LR35902.cartAddress(for: lineBufferAddress, in: bank)!
                  let upperBound = LR35902.cartAddress(for: cpu.pc - instructionWidth, in: bank)!
                  let bytes = cpu[lowerBound..<upperBound]

                  let macroArgs = macro.arguments.keys.sorted().map { macro.arguments[$0]! }.joined(separator: ", ")

                  let firstInstruction = lineBuffer.firstIndex { line in if case .instruction = line { return true } else { return false} }!
                  let lastInstruction = lineBuffer.lastIndex { line in if case .instruction = line { return true } else { return false} }!
                  let bank: LR35902.Bank
                  if case let .instruction(_, _, _, instructionBank, _, _) = lineBuffer[lastInstruction] {
                    bank = instructionBank
                  } else {
                    bank = cpu.bank
                  }
                  let macroScope = contiguousScope(at: lineBufferAddress, in: bank)
                  lineBuffer.replaceSubrange(firstInstruction...lastInstruction,
                                             with: [.macro("\(macro.macro.name) \(macroArgs)", lineBufferAddress, bank, macroScope, bytes)])

                  lineBufferAddress = cpu.pc
                } else {
                  flush()
                }
              } else {
                flush()
              }
              macroNode = nil
            }
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
          if macroNode == nil, let child = macroTree.children[asInstruction] ?? macroTree.children[asAny] {
            lineBufferAddress = cpu.pc - instructionWidth
            macroNode = child
          }

        } else {
          lineBuffer.append(contentsOf: lineGroup)
          flush()

          cpu.bank = bank

          // Accumulate bytes until the next instruction or transfer of control.
          var accumulator: [UInt8] = []
          let initialPc = cpu.pc
          let initialType = type(of: cpu.pc, in: bank)
          var global: Global?
          repeat {
            if cpu.pc < 0x4000 {
              global = globals[cpu.pc]
            }
            accumulator.append(cpu[cpu.pc, cpu.bank])
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
          if initialType == .text {
            let lineLength = lineLengthOfText(at: initialPc, in: bank) ?? 254
            for chunk in accumulator.chunked(into: lineLength) {
              write(line(RGBDSAssembly.text(for: chunk), address: chunkPc, addressType: "text"), fileHandle: fileHandle)
              chunkPc += LR35902.Address(chunk.count)
            }
          } else {
            // Dump the bytes in blocks of 8.
            let addressType = initialType == .data ? "data" : nil
            for chunk in accumulator.chunked(into: 8) {
              let instruction = RGBDSAssembly.assembly(for: chunk)
              let displayableBytes = chunk.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
              let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
              write(line(instruction, address: chunkPc, addressType: addressType, comment: "|\(bytesAsCharacters)|"), fileHandle: fileHandle)
              chunkPc += LR35902.Address(chunk.count)
            }
          }

          if let global = global,
            let dataType = global.dataType,
            let globalValue = globalValue {
            write(line(RGBDSAssembly.assembly(for: globalValue), address: chunkPc, addressType: dataType), fileHandle: fileHandle)
          }

          lineBuffer.append(.empty)
          lineBufferAddress = cpu.pc
        }
      }

      flush()
    }

    gameHandle.write(
      ((UInt8(0)..<UInt8(cpu.numberOfBanks))
        .map { "INCLUDE \"bank_\($0.hexString).asm\"" }
        .joined(separator: "\n") + "\n")
        .data(using: .utf8)!)

    print("Instructions decoded: \(instructionsDecoded)")

    print("Disassembled: \(Double(knownLocations().count * 100) / Double(cpu.cartridgeSize))%")
  }
}
