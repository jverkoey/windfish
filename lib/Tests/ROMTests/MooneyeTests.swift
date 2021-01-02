import XCTest
import Windfish

// References:
// - https://gekkio.fi/files/mooneye-gb/latest/

class MooneyeTests: XCTestCase {

  func run(testRom: String) throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: testRom, ofType: "gb"))
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let gameboy = Gameboy()
    gameboy.cartridge = .init(data: data)
    gameboy.cpu.pc = 0x100  // Assume the boot sequence has concluded.

    let maxInstructions = 2_000_000
    var instructions = 0
    repeat {
      gameboy.advanceInstruction()
      if case .ld(.b, .b) = gameboy.cpu.machineInstruction.spec {
        break
      }

      if let spec = gameboy.cpu.machineInstruction.spec {
        let instruction: LR35902.Instruction
        if let operandWidth = LR35902.InstructionSet.widths[spec]?.operand,
           let sourceAddress = gameboy.cpu.machineInstruction.sourceAddress(),
           operandWidth > 0 {
          switch operandWidth {
          case 1:
            instruction = .init(spec: spec, immediate: .imm8(gameboy.memory.read(from: sourceAddress + 1)))
          case 2:
            let lsb = UInt16(truncatingIfNeeded: gameboy.memory.read(from: sourceAddress + 1))
            let msb = UInt16(truncatingIfNeeded: gameboy.memory.read(from: sourceAddress + 2)) << 8
            instruction = .init(spec: spec, immediate: .imm16(lsb | msb))
          default:
            instruction = .init(spec: spec)
          }
        } else {
          instruction = .init(spec: spec)
        }
        print("\(gameboy.cpu.machineInstruction.sourceAddress()!.hexString): \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      }

      instructions += 1
    } while instructions < maxInstructions

    XCTAssertEqual(gameboy.cpu.a, 0, "Assertion failure: \(testRom)")
    XCTAssert(gameboy.cpu.b == 3 && gameboy.cpu.c == 5 && gameboy.cpu.d == 8 && gameboy.cpu.e == 13 && gameboy.cpu.h == 21 && gameboy.cpu.l == 34,
              "Hardware test failed: \(testRom)")
  }

  func test_acceptance_call_timing() throws {
    try XCTSkipIf(true)  // sp appears to be getting corrupted
    try run(testRom: "Resources/acceptance/call_timing")
  }

  func test_emulator_only_mbc1_bits_bank_1() throws {
    try run(testRom: "Resources/emulator-only/mbc1/bits_bank1")
  }

  func test_emulator_only_mbc1_bits_bank_2() throws {
    try XCTSkipIf(true)  // RAM banks not implemented yet.
    try run(testRom: "Resources/emulator-only/mbc1/bits_bank2")
  }

  func test_emulator_only_mbc1_bits_mode() throws {
    try XCTSkipIf(true)  // Upper Bits of ROM Bank Number not implemented yet
    try run(testRom: "Resources/emulator-only/mbc1/bits_mode")
  }
}
