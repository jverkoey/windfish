import Foundation

extension LR35902.Disassembly {
  public static func fromRequest(_ data: Data) throws -> LR35902.Disassembly {
    let request = try Disassembly_Request(serializedData: data)
    let disassembly = LR35902.Disassembly(rom: request.binary)
    for (name, datatype) in request.hints.datatypes {
      let representation: Datatype.Representation
      switch datatype.representation {
      case .hexadecimal:
        representation = .hexadecimal
      case .binary:
        representation = .binary
      case .decimal:
        representation = .decimal
      case .UNRECOGNIZED(_):
        continue
      }
      let valueNames = datatype.valueNames.reduce(into: [:]) { accumulator, element in
        accumulator[UInt8(element.key)] = element.value
      }
      switch datatype.kind {
      case .any:
        disassembly.createDatatype(named: name, representation: representation)
      case .bitmask:
        disassembly.createDatatype(named: name, bitmask: valueNames, representation: representation)
      case .enumeration:
        disassembly.createDatatype(named: name, enumeration: valueNames, representation: representation)
      case .UNRECOGNIZED(_):
        continue
      }
    }

    for (address, global) in request.hints.globals {
      disassembly.createGlobal(at: LR35902.Address(address), named: global.name, dataType: global.datatype)
    }

    for (location, label) in request.hints.labels {
      let addressAndBank = LR35902.addressAndBank(from: LR35902.CartridgeLocation(location))
      disassembly.setLabel(at: addressAndBank.address, in: addressAndBank.bank, named: label)
    }

    for (name, macro) in request.hints.macros {
      let macroLines: [MacroLine] = macro.patterns.map {
        let instructionData: Data = $0.opcode + $0.operands
        let cpu = LR35902(cartridge: instructionData)
        let spec = cpu.spec(at: 0, in: 0)!
        if let instruction = cpu.instruction(at: 0, in: 0, spec: spec) {
          return .instruction(instruction)
        } else if !$0.argumentText.isEmpty {
          return .any(spec, argumentText: $0.argumentText)
        } else if $0.argument > 0 {
          return .any(spec, argument: $0.argument)
        } else {
          return .any(spec)
        }
      }
      let validArgumentValues = macro.validArgumentValues.reduce(into: [:]) { accumulator, element in
        accumulator[Int(element.key)] = element.value.ranges.reduce(into: IndexSet()) { indexSet, range in
          indexSet.insert(integersIn: Int(range.inclusiveLower)..<Int(range.exclusiveUpper))
        }
      }
      if validArgumentValues.isEmpty {
        disassembly.defineMacro(named: name, instructions: macroLines)
      } else {
        disassembly.defineMacro(named: name, instructions: macroLines, validArgumentValues: validArgumentValues)
      }
    }

    return disassembly
  }
}
