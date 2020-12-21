import XCTest
@testable import LR35902

func disassemblyInitialized(with assembly: String) -> Disassembler {
  let results = RGBDSAssembler.assemble(assembly: assembly)

  let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
  let disassembly = Disassembler(data: data)
  disassembly.disassemble(range: 0..<LR35902.Address(data.count), inBank: 0x00)
  return disassembly
}

/** Asserts that two CPU states are equal. */
func assertEqual(_ state1: LR35902, _ state2: LR35902, file: StaticString = #file, line: UInt = #line) {
  XCTAssertEqual(state1.a, state2.a, "a mismatch", file: file, line: line)
  XCTAssertEqual(state1.b, state2.b, "b mismatch", file: file, line: line)
  XCTAssertEqual(state1.c, state2.c, "c mismatch", file: file, line: line)
  XCTAssertEqual(state1.d, state2.d, "d mismatch", file: file, line: line)
  XCTAssertEqual(state1.e, state2.e, "e mismatch", file: file, line: line)
  XCTAssertEqual(state1.h, state2.h, "h mismatch", file: file, line: line)
  XCTAssertEqual(state1.l, state2.l, "l mismatch", file: file, line: line)
  XCTAssertEqual(state1.sp, state2.sp, "sp mismatch", file: file, line: line)
  XCTAssertEqual(state1.pc, state2.pc, "pc mismatch", file: file, line: line)
  XCTAssertEqual(state1.bank, state2.bank, "bank mismatch", file: file, line: line)
}

class EmulatorTests: XCTestCase {
  // MARK: - To be categorized

  func testMissingContextPropagatesNoInformation() {
    let disassembly = disassemblyInitialized(with: """
ld   a, e
xor  $E0
ld   e, a
""")

    let states = disassembly.trace(range: 0..<disassembly.cartridge.size).sorted(by: { $0.key < $1.key })
    let lastState = states[states.count - 1]

    XCTAssertEqual(lastState.value.a, 0xE0)
    XCTAssertEqual(lastState.value.b, 0)
    XCTAssertEqual(lastState.value.c, 0)
    XCTAssertEqual(lastState.value.d, 0)
    XCTAssertEqual(lastState.value.e, 0xE0)
    XCTAssertEqual(lastState.value.h, 0)
    XCTAssertEqual(lastState.value.l, 0)
    XCTAssertEqual(lastState.value.pc, 0x0004)
    XCTAssertEqual(lastState.value.bank, 0x00)
  }

  func test_ld_a_imm8__xor_imm8__ld_e_a() {
    let disassembly = disassemblyInitialized(with: """
ld   a, $01
xor  $E0
ld   e, a
""")

    let trace = disassembly.trace(range: 0..<disassembly.cartridge.size).sorted(by: { $0.key < $1.key })

    XCTAssertEqual(trace[0].value.a, 0x01)
    XCTAssertEqual(trace[0].value.b, 0)
    XCTAssertEqual(trace[0].value.c, 0)
    XCTAssertEqual(trace[0].value.d, 0)
    XCTAssertEqual(trace[0].value.e, 0)
    XCTAssertEqual(trace[0].value.h, 0)
    XCTAssertEqual(trace[0].value.l, 0)
    XCTAssertEqual(trace[0].value.pc, 0x0002)
    XCTAssertEqual(trace[0].value.bank, 0x00)

    XCTAssertEqual(trace[1].value.a, 0xE1)
    XCTAssertEqual(trace[1].value.b, 0)
    XCTAssertEqual(trace[1].value.c, 0)
    XCTAssertEqual(trace[1].value.d, 0)
    XCTAssertEqual(trace[0].value.e, 0)
    XCTAssertEqual(trace[1].value.h, 0)
    XCTAssertEqual(trace[1].value.l, 0)
    XCTAssertEqual(trace[1].value.pc, 0x0004)
    XCTAssertEqual(trace[1].value.bank, 0x00)

    XCTAssertEqual(trace[2].value.a, 0xE1)
    XCTAssertEqual(trace[2].value.b, 0)
    XCTAssertEqual(trace[2].value.c, 0)
    XCTAssertEqual(trace[2].value.d, 0)
    XCTAssertEqual(trace[2].value.e, 0xE1)
    XCTAssertEqual(trace[2].value.h, 0)
    XCTAssertEqual(trace[2].value.l, 0)
    XCTAssertEqual(trace[2].value.pc, 0x0005)
    XCTAssertEqual(trace[2].value.bank, 0x00)
  }

  func test_ld_a_addr__and_imm8__ld_e_a() {
    let disassembly = disassemblyInitialized(with: """
ld   a, [$D6FD]
and  %01111111
ld   e, a
""")

    let trace = disassembly.trace(range: 0..<disassembly.cartridge.size).sorted(by: { $0.key < $1.key })

    XCTAssertEqual(trace[0].value.a, 0)
    XCTAssertEqual(trace[0].value.b, 0)
    XCTAssertEqual(trace[0].value.c, 0)
    XCTAssertEqual(trace[0].value.d, 0)
    XCTAssertEqual(trace[0].value.e, 0)
    XCTAssertEqual(trace[0].value.h, 0)
    XCTAssertEqual(trace[0].value.l, 0)
    XCTAssertEqual(trace[0].value.pc, 0x0003)
    XCTAssertEqual(trace[0].value.bank, 0x00)

    // TODO: a should capture the and operation that affected it here somehow.
    XCTAssertEqual(trace[1].value.a, 0)
    XCTAssertEqual(trace[1].value.b, 0)
    XCTAssertEqual(trace[1].value.c, 0)
    XCTAssertEqual(trace[1].value.d, 0)
    XCTAssertEqual(trace[0].value.e, 0)
    XCTAssertEqual(trace[1].value.h, 0)
    XCTAssertEqual(trace[1].value.l, 0)
    XCTAssertEqual(trace[1].value.pc, 0x0005)
    XCTAssertEqual(trace[1].value.bank, 0x00)

    XCTAssertEqual(trace[2].value.a, 0)
    XCTAssertEqual(trace[2].value.b, 0)
    XCTAssertEqual(trace[2].value.c, 0)
    XCTAssertEqual(trace[2].value.d, 0)
    XCTAssertEqual(trace[2].value.e, 0)
    XCTAssertEqual(trace[2].value.h, 0)
    XCTAssertEqual(trace[2].value.l, 0)
    XCTAssertEqual(trace[2].value.pc, 0x0006)
    XCTAssertEqual(trace[2].value.bank, 0x00)
  }

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

    var initialState = LR35902()

    initialState.a = 0b0000_1111

    let states = disassembly.trace(range: 0..<disassembly.cartridge.size,
                                   initialState: initialState).sorted(by: { $0.key < $1.key })
    let lastState = states[states.count - 1]

    XCTAssertEqual(lastState.value.a, 0b0000_1111)
    XCTAssertEqual(lastState.value.c, 0b0000_1111)
    XCTAssertEqual(lastState.value.pc, 0x000A)
    XCTAssertEqual(lastState.value.bank, 0x00)
  }
}
