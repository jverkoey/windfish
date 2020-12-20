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

  func testMissingContextPropagatesNoInformation() {
    let disassembly = disassemblyInitialized(with: """
ld   a, e
xor  $E0
ld   e, a
""")

    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size).sorted(by: { $0.key < $1.key })
    let lastState = states[states.count - 1]

    XCTAssertEqual(lastState.value.a, nil)
    XCTAssertEqual(lastState.value.b, nil)
    XCTAssertEqual(lastState.value.c, nil)
    XCTAssertEqual(lastState.value.d, nil)
    XCTAssertEqual(lastState.value.e, nil)
    XCTAssertEqual(lastState.value.h, nil)
    XCTAssertEqual(lastState.value.l, nil)
    XCTAssertEqual(lastState.value.ram, [:])
    XCTAssertEqual(lastState.value.pc, 0x0004)
    XCTAssertEqual(lastState.value.bank, 0x00)
  }

  func test_ld_a_imm8__xor_imm8__ld_e_a() {
    let disassembly = disassemblyInitialized(with: """
ld   a, $01
xor  $E0
ld   e, a
""")

    let trace = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size).sorted(by: { $0.key < $1.key })

    XCTAssertEqual(trace[0].value.a, .init(value: 0x01, sourceLocation: 0))
    XCTAssertEqual(trace[0].value.b, nil)
    XCTAssertEqual(trace[0].value.c, nil)
    XCTAssertEqual(trace[0].value.d, nil)
    XCTAssertEqual(trace[0].value.e, nil)
    XCTAssertEqual(trace[0].value.h, nil)
    XCTAssertEqual(trace[0].value.l, nil)
    XCTAssertEqual(trace[0].value.ram, [:])
    XCTAssertEqual(trace[0].value.pc, 0x0002)
    XCTAssertEqual(trace[0].value.bank, 0x00)

    XCTAssertEqual(trace[1].value.a, .init(value: 0xE1, sourceLocation: 2))
    XCTAssertEqual(trace[1].value.b, nil)
    XCTAssertEqual(trace[1].value.c, nil)
    XCTAssertEqual(trace[1].value.d, nil)
    XCTAssertEqual(trace[0].value.e, nil)
    XCTAssertEqual(trace[1].value.h, nil)
    XCTAssertEqual(trace[1].value.l, nil)
    XCTAssertEqual(trace[1].value.ram, [:])
    XCTAssertEqual(trace[1].value.pc, 0x0004)
    XCTAssertEqual(trace[1].value.bank, 0x00)

    XCTAssertEqual(trace[2].value.a, .init(value: 0xE1, sourceLocation: 2))
    XCTAssertEqual(trace[2].value.b, nil)
    XCTAssertEqual(trace[2].value.c, nil)
    XCTAssertEqual(trace[2].value.d, nil)
    XCTAssertEqual(trace[2].value.e, .init(value: 0xE1, sourceLocation: 2))
    XCTAssertEqual(trace[2].value.h, nil)
    XCTAssertEqual(trace[2].value.l, nil)
    XCTAssertEqual(trace[2].value.ram, [:])
    XCTAssertEqual(trace[2].value.pc, 0x0005)
    XCTAssertEqual(trace[2].value.bank, 0x00)
  }

  func test_ld_a_addr__and_imm8__ld_e_a() {
    let disassembly = disassemblyInitialized(with: """
ld   a, [$D6FD]
and  %01111111
ld   e, a
""")

    let trace = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size).sorted(by: { $0.key < $1.key })

    XCTAssertEqual(trace[0].value.a, .init(value: nil, sourceLocation: 0, variableLocation: 0xD6FD))
    XCTAssertEqual(trace[0].value.b, nil)
    XCTAssertEqual(trace[0].value.c, nil)
    XCTAssertEqual(trace[0].value.d, nil)
    XCTAssertEqual(trace[0].value.e, nil)
    XCTAssertEqual(trace[0].value.h, nil)
    XCTAssertEqual(trace[0].value.l, nil)
    XCTAssertEqual(trace[0].value.ram, [:])
    XCTAssertEqual(trace[0].value.pc, 0x0003)
    XCTAssertEqual(trace[0].value.bank, 0x00)

    // TODO: a should capture the and operation that affected it here somehow.
    XCTAssertEqual(trace[1].value.a, .init(value: nil, sourceLocation: 0, variableLocation: 0xD6FD))
    XCTAssertEqual(trace[1].value.b, nil)
    XCTAssertEqual(trace[1].value.c, nil)
    XCTAssertEqual(trace[1].value.d, nil)
    XCTAssertEqual(trace[0].value.e, nil)
    XCTAssertEqual(trace[1].value.h, nil)
    XCTAssertEqual(trace[1].value.l, nil)
    XCTAssertEqual(trace[1].value.ram, [:])
    XCTAssertEqual(trace[1].value.pc, 0x0005)
    XCTAssertEqual(trace[1].value.bank, 0x00)

    XCTAssertEqual(trace[2].value.a, .init(value: nil, sourceLocation: 0, variableLocation: 0xD6FD))
    XCTAssertEqual(trace[2].value.b, nil)
    XCTAssertEqual(trace[2].value.c, nil)
    XCTAssertEqual(trace[2].value.d, nil)
    XCTAssertEqual(trace[2].value.e, .init(value: nil, sourceLocation: 0, variableLocation: 0xD6FD))
    XCTAssertEqual(trace[2].value.h, nil)
    XCTAssertEqual(trace[2].value.l, nil)
    XCTAssertEqual(trace[2].value.ram, [:])
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

    var initialState = LR35902.CPUState()

    initialState.a = LR35902.CPUState.RegisterState<UInt8>(value: 0b0000_1111, sourceLocation: 0)
    initialState.ram[0xffcb] = .init(value: 0b0000_1100, sourceLocation: 0)

    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size,
                                      initialState: initialState).sorted(by: { $0.key < $1.key })
    let lastState = states[states.count - 1]

    XCTAssertEqual(lastState.value.a, .init(value: 0b0000_1111, sourceLocation: 0))
    XCTAssertEqual(lastState.value.c, .init(value: 0b0000_1111, sourceLocation: 0))
    XCTAssertEqual(lastState.value.ram[0xffcb], .init(value: 0b0000_1111, sourceLocation: 0))
    XCTAssertEqual(lastState.value.ram[0xffcc], .init(value: 0b0000_0011, sourceLocation: 4))
    XCTAssertEqual(lastState.value.pc, 0x000A)
    XCTAssertEqual(lastState.value.bank, 0x00)
  }
}
