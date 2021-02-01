import Foundation

import RGBDS

extension Disassembler {
  private typealias DatatypeElement = Dictionary<String, Configuration.Datatype>.Element

  func createMacrosSource(macrosToWrite: [
    (
      macro: Disassembler.Configuration.Macro,
      arguments: [Int: String],
      rawArguments: [Int: String],
      instructions: [(LR35902.Instruction, RGBDS.Statement)]
    )
  ]) -> Source.FileDescription? {
    guard !macrosToWrite.isEmpty else {
      return nil
    }
    var macrosAsm: String = ""

    var writtenMacros: Set<String> = Set<String>()
    for macro in macrosToWrite.sorted(by: { $0.macro.name < $1.macro.name }) {
      guard !writtenMacros.contains(macro.macro.name) else {
        continue
      }
      writtenMacros.insert(macro.macro.name)

      var lines: [Line] = []
      lines.append(Line(semantic: .emptyAndCollapsible))
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
      macrosAsm.append(linesAsString(lines))
      macrosAsm.append("\n")
    }
    return .macros(content: macrosAsm)
  }
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
