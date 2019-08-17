import XCTest
@testable import LR35902

class RGBDAssembler: XCTestCase {

  func test_nop_failsWithExtraOperand() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop nop
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [RGBDSAssembler.Error(lineNumber: 1, error: "Unexpected operand for nop")])
  }

  func test_nop_1() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertTrue(errors.isEmpty)
    XCTAssertEqual(try XCTUnwrap(disassembly.instruction(at: 0x0000, in: 0x00)),
                   LR35902.Instruction(spec: .nop))
  }

  func test_nop_2() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop
    nop
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertTrue(errors.isEmpty)
    XCTAssertEqual(try XCTUnwrap(disassembly.instruction(at: 0x0000, in: 0x00)),
                   LR35902.Instruction(spec: .nop))
    XCTAssertEqual(try XCTUnwrap(disassembly.instruction(at: 0x0001, in: 0x00)),
                   LR35902.Instruction(spec: .nop))
  }

}
