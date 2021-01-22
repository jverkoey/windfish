import Foundation

extension Disassembler {
  func rewriteScopes(_ run: Disassembler.Run) {
    // Compute scope and rewrite function labels if we're a function.

    let registers8 = LR35902.Instruction.Numeric.registers8

    for runGroup in run.runGroups() {
      // TODO: We should do this after all disassembly has been done and before writing to disk.
      for run in runGroup {
        guard let visitedRange = run.visitedRange else {
          continue
        }

        trace(range: visitedRange) { instruction, location, cpu in
          switch instruction.spec {
            // TODO: This only works if we're simulating the run as part of the linear sweep.
            // TODO: Fold the simulation logic into the linear sweep somehow.
//          case .ld(.imm16addr, let src) where registers8.contains(src):
//            if (0x2000..<0x4000).contains(instruction.imm16!),
//              let srcValue: CPUState.RegisterState<UInt8> = self[src],
//              case .value(let value) = srcValue.value {
//              let addressAndBank = Cartridge.addressAndBank(from: location)
//              self.register(bankChange: value, at: addressAndBank.address, in: addressAndBank.bank)
//            }

          case .ld(.imm16addr, let numeric) where registers8.contains(numeric):
            guard case let .imm16(immediate) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            if let global = self.globals[immediate],
              let dataType = global.dataType,
              case let .cartridge(sourceLocation) = cpu.registerTraces[.a]?.sourceLocation {
              self.typeAtLocation[sourceLocation] = dataType
            }

          case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
            guard case let .imm8(immediate) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            let address = 0xFF00 | LR35902.Address(immediate)
            if let global = self.globals[address],
              let dataType = global.dataType,
              case let .cartridge(sourceLocation) = cpu.registerTraces[.a]?.sourceLocation {
              self.typeAtLocation[sourceLocation] = dataType
            }

          case .cp(_):
            if let address = cpu.registerTraces[.a]?.loadAddress,
              let global = self.globals[address],
              let dataType = global.dataType {
              self.typeAtLocation[location] = dataType
            }

          case .ld(.ffimm8addr, let src) where registers8.contains(src):
            guard case let .imm8(immediate) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            let address = 0xFF00 | LR35902.Address(immediate)
            if let global = self.globals[address],
              let dataType = global.dataType,
              case let .cartridge(sourceLocation) = cpu.registerTraces[src]?.sourceLocation {
              self.typeAtLocation[sourceLocation] = dataType
            }

          case .and(.imm8):
            if let address = cpu.registerTraces[.a]?.loadAddress,
              let global = self.globals[address],
              let dataType = global.dataType,
              let type = self.dataTypes[dataType],
              (!type.namedValues.isEmpty || type.representation == .hexadecimal) {
              self.typeAtLocation[location] = dataType

            } else if self.typeAtLocation[location] == nil {
              self.typeAtLocation[location] = "binary"
            }

          default:
            break
          }
        }
      }
      // Define the initial contiguous scope for the rungroup's label.
      // This allows functions to rewrite local labels as relative labels.
      guard let contiguousScope = runGroup.firstContiguousScopeRange else {
        continue
      }
      registerContiguousScope(range: Cartridge.Location(location: contiguousScope.lowerBound)..<Cartridge.Location(location: contiguousScope.upperBound))

      let headlessContiguousScope = contiguousScope.dropFirst()
      inferLoops(in: headlessContiguousScope)
      inferElses(in: headlessContiguousScope)
      inferReturns(in: Cartridge.Location(location: headlessContiguousScope.lowerBound)..<Cartridge.Location(location: headlessContiguousScope.upperBound))
    }
  }

  private func inferReturns(in scope: Range<Cartridge.Location>) {
    let labelLocations = self.labelLocations(in: scope)
    let returnLabelAddresses = labelLocations.filter { instructionMap[Cartridge._Location(truncatingIfNeeded: $0.index)]?.spec.category == .ret }
    for cartLocation in returnLabelAddresses {
      labelTypes[cartLocation] = .returnType
    }
  }

  private func inferLoops(in scope: Range<Cartridge._Location>) {
    let tocs: [(destination: Cartridge._Location, tocs: Set<Cartridge.Location>)] = scope.compactMap {
      let (address, bank) = Cartridge.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: Cartridge.Location(address: address, bank: bank)) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let backwardTocs: [(source: Cartridge._Location, destination: Cartridge._Location)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains(Cartridge._Location(truncatingIfNeeded: $0.index)) && element.destination < Cartridge._Location(truncatingIfNeeded: $0.index)
          && (labelNames[element.destination] != nil || labelTypes[Cartridge.Location(location: element.destination)] != nil)
      }
      for toc in tocsInThisScope {
        let _toc = Cartridge._Location(truncatingIfNeeded: toc.index)
        if case .jr(let condition, _) = instructionMap[_toc]?.spec,
          condition != nil {
          accumulator.append((_toc, element.destination))
        }
      }
    })
    if backwardTocs.isEmpty {
      return
    }
    // Loops do not include other unconditional transfers of control.
    let loops = backwardTocs.filter {
      let loopRange = ($0.destination..<$0.source)
      let tocsWithinLoop: [LR35902.Instruction] = tocs.flatMap {
        $0.tocs
          .filter { loopRange.contains(Cartridge._Location(truncatingIfNeeded: $0.index)) }
          .compactMap { instructionMap[Cartridge._Location(truncatingIfNeeded: $0.index)] }
      }
      return !tocsWithinLoop.contains {
        switch $0.spec {
        case .jp(let condition, _), .ret(let condition):
          return condition == nil
        default:
          return false
        }
      }
    }
    if loops.isEmpty {
      return
    }
    let destinations = Set(loops.map { $0.destination })
    for cartLocation in destinations {
      labelTypes[Cartridge.Location(location: cartLocation)] = .loopType
    }
  }

  private func inferElses(in scope: Range<Cartridge._Location>) {
    let tocs: [(destination: Cartridge._Location, tocs: Set<Cartridge.Location>)] = scope.compactMap {
      let (address, bank) = Cartridge.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: Cartridge.Location(address: address, bank: bank)) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let forwardTocs: [(source: Cartridge._Location, destination: Cartridge._Location)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains(Cartridge._Location(truncatingIfNeeded: $0.index))
          && element.destination > Cartridge._Location(truncatingIfNeeded: $0.index)
          && (labelNames[element.destination] != nil || labelTypes[Cartridge.Location(location: element.destination)] != nil)
      }
      for toc in tocsInThisScope {
        let _toc = Cartridge._Location(truncatingIfNeeded: toc.index)
        if case .jr(let condition, _) = instructionMap[_toc]?.spec,
          condition != nil {
          accumulator.append((_toc, element.destination))
        }
      }
    })
    if forwardTocs.isEmpty {
      return
    }
    let destinations = Set(forwardTocs.map { $0.destination })
    for cartLocation in destinations {
      labelTypes[Cartridge.Location(location: cartLocation)] = .elseType
    }
  }
}
