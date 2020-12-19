import XCTest
@testable import LR35902

func disassemblyInitialized(with assembly: String) -> LR35902.Disassembly {
  let results = RGBDSAssembler.assemble(assembly: assembly)

  let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
  let disassembly = LR35902.Disassembly(rom: data)
  disassembly.disassemble(range: 0..<LR35902.Address(data.count), inBank: 0x00)
  return disassembly
}

/** Asserts that two CPU states are equal. */
func assertEqual(_ state1: LR35902.CPUState, _ state2: LR35902.CPUState, file: StaticString = #file, line: UInt = #line) {
  XCTAssertEqual(state1.a, state2.a, "a mismatch", file: file, line: line)
  XCTAssertEqual(state1.b, state2.b, "b mismatch", file: file, line: line)
  XCTAssertEqual(state1.c, state2.c, "c mismatch", file: file, line: line)
  XCTAssertEqual(state1.d, state2.d, "d mismatch", file: file, line: line)
  XCTAssertEqual(state1.e, state2.e, "e mismatch", file: file, line: line)
  XCTAssertEqual(state1.h, state2.h, "h mismatch", file: file, line: line)
  XCTAssertEqual(state1.l, state2.l, "l mismatch", file: file, line: line)
  XCTAssertEqual(state1.sp, state2.sp, "sp mismatch", file: file, line: line)
  XCTAssertEqual(state1.ram, state2.ram, "ram mismatch", file: file, line: line)
  XCTAssertEqual(state1.pc, state2.pc, "pc mismatch", file: file, line: line)
  XCTAssertEqual(state1.bank, state2.bank, "bank mismatch", file: file, line: line)
}

class EmulatorTests: XCTestCase {
  // MARK: - To be categorized

  func testComplexInstruction() {
    let disassembly = disassemblyInitialized(with: """
ld   c, a
ld   a, [$ffcb]
xor  c
and  c
ld   [$ffcc], a
ld   a, c
ld   [$ffcb], a
""")

    var initialState = LR35902.CPUState()

    initialState.a = LR35902.CPUState.RegisterState<UInt8>(value: .literal(0b0000_1111), sourceLocation: 0)
    initialState.ram[0xffcb] = .init(value: .literal(0b0000_1100), sourceLocation: 0)

    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size,
                                      initialState: initialState).sorted(by: { $0.key < $1.key })
    let lastState = states[states.count - 1]

    XCTAssertEqual(lastState.value.a, .init(value: .literal(0b0000_1111), sourceLocation: 0))
    XCTAssertEqual(lastState.value.c, .init(value: .literal(0b0000_1111), sourceLocation: 0))
    XCTAssertEqual(lastState.value.ram[0xffcb], .init(value: .literal(0b0000_1111), sourceLocation: 0))
    XCTAssertEqual(lastState.value.ram[0xffcc], .init(value: .literal(0b0000_0011), sourceLocation: 4))
    XCTAssertEqual(lastState.value.pc, 0x0008)
    XCTAssertEqual(lastState.value.bank, 0x00)
  }
}
