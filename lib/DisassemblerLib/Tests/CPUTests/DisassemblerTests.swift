import XCTest
@testable import CPU

class DisassemblerTests: XCTestCase {
  func testDisassemblyOfSpecsFromData() {
    for (index, spec) in SimpleCPU.InstructionSet.table.enumerated() {
      if case .prefix = spec, let prefixTable = SimpleCPU.InstructionSet.prefixTables[spec] {
        for (prefixIndex, prefixSpec) in prefixTable.enumerated() {
          let data = Data([UInt8(index), UInt8(prefixIndex)])
          let disassemblySpec = SimpleCPU.InstructionSet.spec(from: data)
          XCTAssertEqual(disassemblySpec, prefixSpec)
        }

      } else {
        let data = Data([UInt8(index)])
        let disassemblySpec = SimpleCPU.InstructionSet.spec(from: data)
        XCTAssertEqual(disassemblySpec, spec)
      }
    }
  }

  func testEmptyDataReturnsNil() {
    let data = Data([])
    let spec = SimpleCPU.InstructionSet.spec(from: data)
    XCTAssertNil(spec)
  }

  func testPartialInstructionReturnsNil() {
    let data = Data([UInt8(SimpleCPU.InstructionSet.table.firstIndex(of: .prefix(.sub))!)])
    let spec = SimpleCPU.InstructionSet.spec(from: data)
    XCTAssertNil(spec)
  }
}
