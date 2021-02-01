import Foundation

import RGBDS

extension Disassembler {
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
    var macrosAsm: String = ""

    var lines: [Line] = []
    var writtenMacros: Set<String> = Set<String>()
    for macro: EncounteredMacro in macrosToWrite.sorted(by: { $0.macro.name < $1.macro.name }) {
      guard !writtenMacros.contains(macro.macro.name) else {
        continue
      }
      writtenMacros.insert(macro.macro.name)

      lines.append(Line(semantic: .emptyAndCollapsible))
      lines.append(Line(semantic: .macroDefinition(macro.macro.name)))
      lines.append(contentsOf: zip(macro.macro.macroLines, macro.instructions).map { line, instruction in
        let macroInstruction = instruction.0

        let argumentString: String?
        switch line {
        case let .arg(_, argumentOrNil, argumentText),
             let .any(_, argument: argumentOrNil, argumentText: argumentText):
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
      lines.append(Line(semantic: .emptyAndCollapsible))
    }
    macrosAsm.append(processLines(lines).source)
    return .macros(content: macrosAsm)
  }
}
