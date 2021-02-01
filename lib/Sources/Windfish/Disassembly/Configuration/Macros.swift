import Foundation

import RGBDS

extension Disassembler.Configuration {
  /** A representation of a macro. */
  final class Macro {
    /** The name by which the macro is invoked in the generated assembly. */
    let name: String

    /** A templatized representation of this macro's instructions. */
    let macroLines: [MacroLine]

    /** The range of valid values for each argument. */
    let validArgumentValues: [Int: IndexSet]?

    init(name: String, macroLines: [MacroLine], validArgumentValues: [Int: IndexSet]?) {
      self.name = name
      self.macroLines = macroLines
      self.validArgumentValues = validArgumentValues
    }
  }

  /** A representation of a single templatized line in a macro. */
  enum MacroLine: Equatable {
    /** The line can match any of a given set of opcodes. */
    case any(specs: [LR35902.Instruction.Spec], number: UInt64? = nil, argumentText: String? = nil)

    /** The line must match a specific opcode. */
    case arg(spec: LR35902.Instruction.Spec, number: UInt64? = nil, argumentText: String? = nil)

    /** the line must match exactly the given opcode and arguments. */
    case instruction(LR35902.Instruction)

    /** Returns all possible edges that this line can be represented as. */
    func asEdges() -> [MacroTreeEdge] {
      switch self {
      case .any(let specs, _, _):         return specs.map { .arg($0) }
      case .arg(let spec, _, _):          return [.arg(spec)]
      case .instruction(let instruction): return [.instruction(instruction)]
      }
    }

    /** Returns all possible opcodes that can match this line. */
    func specs() -> [LR35902.Instruction.Spec] {
      switch self {
      case .any(let specs, _, _):         return specs
      case .arg(let spec, _, _):          return [spec]
      case .instruction(let instruction): return [instruction.spec]
      }
    }
  }

  /** A representation of an edge in the macro parser tree. */
  enum MacroTreeEdge: Hashable {
    case arg(LR35902.Instruction.Spec)
    case instruction(LR35902.Instruction)

    /** Simplifies the given line into a line representing exactly one opcode: this edge's. */
    func resolve(into line: MacroLine) -> MacroLine {
      switch line {
      case let .any(_, number, argumentText):
        guard case let .arg(spec) = self else {
          preconditionFailure("Mismatched types")
        }
        return .arg(spec: spec, number: number, argumentText: argumentText)

      case let .arg(spec, number, argumentText):
        return .arg(spec: spec, number: number, argumentText: argumentText)

      case let .instruction(instruction):
        return .instruction(instruction)
      }
    }
  }

  /** A representation of a single node in macro tree. */
  final class MacroNode {
    /** Each child represents an edge that can be traversed to get to longer macro. */
    var children: [MacroTreeEdge: MacroNode] = [:]

    /** Macros that are terminated at this node. */
    var macros: [Macro] = []

    init(children: [MacroTreeEdge : MacroNode] = [:], macros: [Macro] = []) {
      self.children = children
      self.macros = macros
    }
  }

  func macroTreeRoot() -> MacroNode {
    return macroTree
  }

  /** Registers a new macro with the given template string. */
  public func registerMacro(named name: String, template: String, validArgumentValues: [Int: IndexSet]? = nil) {
    var lines: [MacroLine] = []
    template.enumerateLines { (line: String, stop: inout Bool) in
      guard let statement: RGBDS.Statement = RGBDS.Statement(fromLine: line) else {
        return
      }
      let specs: [LR35902.Instruction.Spec] = LR35902.InstructionSet.specs(for: statement)

      if specs.isEmpty {
        // No instruction specification found matching this statement.
        // TODO: Return a human-readable error.
        stop = true
        return
      }

      if let argumentOperand = statement.operands.first(where: { $0.contains("#") }) {
        let number: UInt64?
        let argumentText: String?

        // Special-case the bank extraction method as a function that accepts a literal argument.
        if argumentOperand.hasPrefix("bank(") && argumentOperand.hasSuffix(")") {
          argumentText = argumentOperand.replacingOccurrences(of: "#", with: "\\")
          number = nil
        } else {
          argumentText = nil
          let scanner = Scanner(string: argumentOperand)
          _ = scanner.scanUpToString("#")
          _ = scanner.scanCharacter()
          number = scanner.scanUInt64()
        }
        if specs.count > 1 {
          lines.append(.any(specs: specs, number: number, argumentText: argumentText))
        } else {
          lines.append(.arg(spec: specs.first!, number: number, argumentText: argumentText))
        }
      } else {
        let potentialInstructions: [LR35902.Instruction]
        do {
          potentialInstructions = try specs.compactMap { spec in
            try RGBDSAssembler.instruction(from: statement, using: spec)
          }
        } catch {
          // TODO: Track this error and return it.
          stop = true
          return
        }
        guard potentialInstructions.count > 0 else {
          preconditionFailure("No instruction was able to represent \(statement.formattedString)")
        }
        let shortestInstruction: LR35902.Instruction = potentialInstructions.sorted(by: { pair1, pair2 in
          LR35902.InstructionSet.widths[pair1.spec]!.total < LR35902.InstructionSet.widths[pair2.spec]!.total
        })[0]
        lines.append(.instruction(shortestInstruction))
      }
    }
    defineMacro(named: name, instructions: lines, validArgumentValues: validArgumentValues)
  }

  private func defineMacro(named name: String, instructions: [MacroLine], validArgumentValues: [Int: IndexSet]? = nil) {
    let macro: Macro = Macro(name: name, macroLines: instructions, validArgumentValues: validArgumentValues)
    insert(lines: instructions, intoTree: macroTree, macro: macro)
  }

  private func insert(lines: [MacroLine], intoTree node: MacroNode, macro: Macro, lineHistory: [MacroLine] = []) {
    guard let line = lines.first else {
      node.macros.append(Macro(name: macro.name,
                               macroLines: lineHistory,
                               validArgumentValues: macro.validArgumentValues))
      return
    }
    for edge: MacroTreeEdge in line.asEdges() {
      let child: MacroNode
      if let existingChild: MacroNode = node.children[edge] {
        child = existingChild
      } else {
        child = MacroNode()
        node.children[edge] = child
      }
      insert(lines: Array<MacroLine>(lines.dropFirst()),
             intoTree: child,
             macro: macro,
             lineHistory: lineHistory + [edge.resolve(into: line)])
    }
  }

}
