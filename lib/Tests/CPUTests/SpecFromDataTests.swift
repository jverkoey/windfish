import XCTest
@testable import CPU

class SpecFromDataTests: XCTestCase {

  // MARK: - Specs

  // The InstructionSet makes the assumption that the index of each specification in its .table corresponds to the
  // opcode's identifier, and that creating a spec from this opcode will create the corresponding spec in the table.
  func testInstructionSetOpcodesMatchTableIndex() {
    for (index, spec) in SimpleCPU.InstructionSet.table.enumerated() {
      if case .prefix = spec, let prefixTable = SimpleCPU.InstructionSet.prefixTables[spec] {
        // Traverse the prefix table. Note that this only supports a single layer of traversals.
        // TODO[https://github.com/jverkoey/windfish/issues/24]: Test 3+ byte opcodes.
        for (prefixIndex, prefixSpec) in prefixTable.enumerated() {
          let data = Data([UInt8(index), UInt8(prefixIndex)])
          let disassemblySpec = SimpleCPU.Instruction.spec(from: data)
          XCTAssertEqual(disassemblySpec, prefixSpec)
        }
      } else {
        let data = Data([UInt8(index)])
        let disassemblySpec = SimpleCPU.Instruction.spec(from: data)
        XCTAssertEqual(disassemblySpec, spec)
      }
    }
  }

  func testEmptyDataReturnsNil() {
    let data = Data([])
    let spec = SimpleCPU.Instruction.spec(from: data)
    XCTAssertNil(spec)
  }

  func testPartialInstructionReturnsNil() {
    let data = Data([UInt8(SimpleCPU.InstructionSet.table.firstIndex(of: .prefix(.sub))!)])
    let spec = SimpleCPU.Instruction.spec(from: data)
    XCTAssertNil(spec)
  }

  // MARK: - Instructions

  func test_nonexisting_op_fails() throws {
    let data = Data([0xff])
    XCTAssertNil(SimpleCPU.Instruction.from(data))
  }

  func test_nop() throws {
    let data = Data([0x00])
    let instruction = try XCTUnwrap(SimpleCPU.Instruction.from(data))
    XCTAssertEqual(instruction.spec, .nop)
    XCTAssertNil(instruction.immediate)
  }

  func test_ld_a_imm8() throws {
    let data = Data([0x01, 0xaa])
    let instruction = try XCTUnwrap(SimpleCPU.Instruction.from(data))
    XCTAssertEqual(instruction.spec, .ld(.a, .imm8))
    XCTAssertEqual(instruction.immediate, .imm8(0xaa))
  }

  func test_ld_a_imm8_fails_when_partial() throws {
    let data = Data([0x01])
    XCTAssertNil(SimpleCPU.Instruction.from(data))
  }

  func test_ld_a_imm16() throws {
    let data = Data([0x02, 0xaa, 0xbb])
    let instruction = try XCTUnwrap(SimpleCPU.Instruction.from(data))
    XCTAssertEqual(instruction.spec, .ld(.a, .imm16))
    XCTAssertEqual(instruction.immediate, .imm16(0xbbaa))
  }

  func test_call_nz_imm16() throws {
    let data = Data([0x03, 0xaa, 0xbb])
    let instruction = try XCTUnwrap(SimpleCPU.Instruction.from(data))
    XCTAssertEqual(instruction.spec, .call(.nz, .imm16))
    XCTAssertEqual(instruction.immediate, .imm16(0xbbaa))
  }

  func test_call_imm16() throws {
    let data = Data([0x04, 0xaa, 0xbb])
    let instruction = try XCTUnwrap(SimpleCPU.Instruction.from(data))
    XCTAssertEqual(instruction.spec, .call(nil, .imm16))
    XCTAssertEqual(instruction.immediate, .imm16(0xbbaa))
  }

  func test_sub_cp_imm8() throws {
    let data = Data([0x05, 0x00, 0xaa])
    let instruction = try XCTUnwrap(SimpleCPU.Instruction.from(data))
    XCTAssertEqual(instruction.spec, .sub(.cp(.imm8)))
    XCTAssertEqual(instruction.immediate, .imm8(0xaa))
  }

  func test_sub_cp_imm8_fails_when_partial() throws {
    let data = Data([0x05, 0x00])
    XCTAssertNil(SimpleCPU.Instruction.from(data))
  }
}
