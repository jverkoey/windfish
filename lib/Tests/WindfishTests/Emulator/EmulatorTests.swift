import XCTest
@testable import Windfish

func disassemblyInitialized(with assembly: String) -> Disassembler {
  let results = RGBDSAssembler.assemble(assembly: assembly)

  let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
  let disassembly = Disassembler(data: data)
  disassembly.willStart()
  disassembly.mutableConfiguration.registerPotentialCode(
    at: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: data.count, bank: 0x01),
    named: "main"
  )
  disassembly.disassemble()
  return disassembly
}

/** Asserts that two CPU states are equal. */
func assertEqual(_ state1: LR35902, _ state2: LR35902, message: String = "", file: StaticString = #file, line: UInt = #line) {
  XCTAssertEqual(state1.a?.hexString, state2.a?.hexString,        "a mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.b?.hexString, state2.b?.hexString,        "b mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.c?.hexString, state2.c?.hexString,        "c mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.d?.hexString, state2.d?.hexString,        "d mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.e?.hexString, state2.e?.hexString,        "e mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.h?.hexString, state2.h?.hexString,        "h mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.l?.hexString, state2.l?.hexString,        "l mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.fzero, state2.fzero,                    "fzero mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.fsubtract, state2.fsubtract,            "fsubtract mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.fhalfcarry, state2.fhalfcarry,          "fhalfcarry mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.fcarry, state2.fcarry,                  "fcarry mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.sp?.hexString, state2.sp?.hexString,      "sp mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.pc.hexString, state2.pc.hexString,      "pc mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.halted, state2.halted,                  "halted mismatch \(message)", file: file, line: line)
}

class EmulatorTests: XCTestCase {
  // MARK: - To be categorized

  func testMissingContextPropagatesNoInformation() {
    let disassembly = disassemblyInitialized(with: """
ld   a, e
xor  $E0
ld   e, a
""")

    let cpu = LR35902.zeroed()
    // TODO: Make the trace invocation a class function; it doesn't need to be executed as part of the worker.
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)
    let lastState = cpu

    XCTAssertEqual(lastState.a, 0xE0)
    XCTAssertEqual(lastState.b, 0)
    XCTAssertEqual(lastState.c, 0)
    XCTAssertEqual(lastState.d, 0)
    XCTAssertEqual(lastState.e, 0xE0)
    XCTAssertEqual(lastState.h, 0)
    XCTAssertEqual(lastState.l, 0)
    XCTAssertEqual(lastState.pc, 0x0004)
  }

  func test_ld_a_imm8__xor_imm8__ld_e_a() {
    let disassembly = disassemblyInitialized(with: """
ld   a, $01
xor  $E0
ld   e, a
""")

    let cpu = LR35902.zeroed()
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    XCTAssertEqual(cpu.a, 0xE1)
    XCTAssertEqual(cpu.b, 0)
    XCTAssertEqual(cpu.c, 0)
    XCTAssertEqual(cpu.d, 0)
    XCTAssertEqual(cpu.e, 0xE1)
    XCTAssertEqual(cpu.h, 0)
    XCTAssertEqual(cpu.l, 0)
    XCTAssertEqual(cpu.pc, 0x0005)
  }

  func test_ld_a_addr__and_imm8__ld_e_a() {
    let disassembly = disassemblyInitialized(with: """
ld   a, [$D6FD]
and  %01111111
ld   e, a
""")

    let cpu = LR35902.zeroed()
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    XCTAssertNil(cpu.a)
    XCTAssertEqual(cpu.b, 0)
    XCTAssertEqual(cpu.c, 0)
    XCTAssertEqual(cpu.d, 0)
    XCTAssertNil(cpu.e)
    XCTAssertEqual(cpu.h, 0)
    XCTAssertEqual(cpu.l, 0)
    XCTAssertEqual(cpu.pc, 0x0006)
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

    let cpu = LR35902()
    cpu.a = 0b0000_1111

    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    XCTAssertEqual(cpu.a, 0b0000_1111)
    XCTAssertEqual(cpu.c, 0b0000_1111)
    XCTAssertEqual(cpu.pc, 0x000A)
  }
}
