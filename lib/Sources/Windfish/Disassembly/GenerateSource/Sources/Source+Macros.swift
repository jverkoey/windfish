import Foundation

import RGBDS

extension Disassembler {
  // TODO: The instructions may no longer be necessary.
  typealias EncounteredMacro = (
    macro: Disassembler.Configuration.Macro,
    arguments: [Int: String],
    rawArguments: [Int: String],
    instructions: [(LR35902.Instruction, RGBDS.Statement)]
  )
  private typealias DatatypeElement = Dictionary<String, Configuration.Datatype>.Element

  func createMacrosSource(macrosToWrite: [EncounteredMacro]) -> Source.FileDescription? {
    guard !macrosToWrite.isEmpty else {
      return nil
    }
    var lines: [Line] = []
    var writtenMacros: Set<String> = Set<String>()
    for macro: EncounteredMacro in macrosToWrite.sorted(by: { $0.macro.name < $1.macro.name }) {
      guard !writtenMacros.contains(macro.macro.name) else {
        continue
      }
      writtenMacros.insert(macro.macro.name)

      lines.append(Line(semantic: .emptyAndCollapsible))
      lines.append(Line(semantic: .macroDefinition(macro.macro.name)))
      lines.append(contentsOf: macro.macro.macroLines.map { line in
        let argumentString: String?
        let macroInstruction: LR35902.Instruction
        switch line {
        case let .arg(spec, number, argumentText):
          if let argumentText = argumentText {
            argumentString = argumentText
          } else if let number = number {
            argumentString = "\\\(number)"
          } else {
            // Lines with an argument in them are expected to have either a number of an explicit string.
            fatalError()
          }

          // Fill the immediate with a default value; it doesn't matter because we'll replace it with argumentString
          // when the RGBDS statement is created.
          let operandWidth = LR35902.InstructionSet.widths[spec]!.operand
          let immediate: LR35902.Instruction.ImmediateValue?
          switch operandWidth {
          case 1:  immediate = .imm8(0)
          case 2:  immediate = .imm16(0)
          default: immediate = nil
          }
          macroInstruction = LR35902.Instruction(spec: spec, immediate: immediate)

        case let .instruction(instruction):
          argumentString = nil
          macroInstruction = instruction

        case .any:
          // This is technically impossible because the macro's lines have already been collapsed into their arg or
          // instruction form in order for us to be parsing it here.
          // TODO: Explore ways to make it so that .any can't be stored on the Macro's lines, but allow .any to be
          // provided in the Macro's definition for the purposes of exploding the tree walk.
          fatalError()
        }

        // Generating the statement with the disassembly context enables the macro to use labels where relevant.
        // TODO: Explore whether it's possible to dropo the address and bank from the context.
        let context: RGBDSDisassembler.Context = RGBDSDisassembler.Context(
          address: 0,
          bank: 0,
          disassembly: self,
          argumentString: argumentString
        )
        let macroAssembly: RGBDS.Statement = RGBDSDisassembler.statement(for: macroInstruction, with: context)
        return Line(semantic: .macroInstruction(macroInstruction, macroAssembly))
      })
      lines.append(Line(semantic: .macroTerminator))
      lines.append(Line(semantic: .emptyAndCollapsible))
    }
    return .macros(content: processLines(lines).source)
  }
}
