import XCTest
import Windfish

// References:
// - ROMS: https://gbdev.gg8.se/files/roms/blargg-gb-tests/
// - Source: https://github.com/retrio/gb-test-roms

class BlarggTests: XCTestCase {
  // MARK: - Instructions

  func test_01_Special() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/01-special", expectedInstructions: 1_277_938)
  }

  func test_02_interrupts() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/02-interrupts", expectedInstructions: 189_922)
  }

  func test_03_op_sp_hl() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/03-op sp,hl", expectedInstructions: 1_089_978)
  }

  func test_04_op_r_imm() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/04-op r,imm", expectedInstructions: 1_282_124)
  }

  func test_05_op_rp() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/05-op rp", expectedInstructions: 1_789_466)
  }

  func test_06_ld_r_r() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/06-ld r,r", expectedInstructions: 269_281)
  }

  func test_07_jr_jp_call_ret_rst() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/07-jr,jp,call,ret,rst", expectedInstructions: 321_079)
  }

  func test_08_misc_instrs() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/08-misc instrs", expectedInstructions: 251_405)
  }

  func test_09_op_r_r() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/09-op r,r", expectedInstructions: 4_441_889)
  }

  func test_10_bit_ops() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/10-bit ops", expectedInstructions: 6_732_590)
  }

  func test_11_op_a_hladdr() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/11-op a,(hl)", expectedInstructions: 7_453_922)
  }

  // MARK: - Instruction timing

  func test_instr_timing() throws {
    try run(rom: "Resources/blargg/instr_timing/instr_timing", expectedInstructions: 273_267)
  }

  // MARK: - Serial interrupt timing

  func test_interrupt_time() throws {
    try XCTSkipUnless(updateGoldens)  // TODO: Implement serial interrupts.
    try run(rom: "Resources/blargg/interrupt_time/interrupt_time")
  }

  // MARK: - Memory timing

  func test_mem_timing_01_read_timing() throws {
    try run(rom: "Resources/blargg/mem_timing/individual/01-read_timing", expectedInstructions: 203_908)
  }

  func test_mem_timing_02_write_timing() throws {
    try run(rom: "Resources/blargg/mem_timing/individual/02-write_timing", expectedInstructions: 196_800)
  }

  func test_mem_timing_03_modify_timing() throws {
    try run(rom: "Resources/blargg/mem_timing/individual/03-modify_timing", expectedInstructions: 217_114)
  }

  func run(rom: String, expectedInstructions: Int = 2_000_000) throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: rom, ofType: "gb"))
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let gameboy = Gameboy()
    gameboy.cartridge = .init(data: data)
    gameboy.cpu.pc = 0x100  // Assume the boot sequence has concluded.

    let instructionsForSuccessToPrint = 17500

    var instructions = 0
    var success = false
    var successInstructionCount = 0
    var remainingPrintInstructions = 0
    repeat {
      gameboy.advanceInstruction()

      //      if let sourceLocation = gameboy.cpu.machineInstruction.sourceLocation {
      //        var address = sourceLocation.address()
      //        let instruction = Disassembler.fetchInstruction(at: &address, memory: gameboy.memory)
      //        print("\(sourceLocation.address().hexString) \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      //      }

      if !gameboy.serialDataReceived.isEmpty {
        guard let string = String(bytes: gameboy.serialDataReceived, encoding: .ascii) else {
          print("Failed to decode \(gameboy.serialDataReceived)")
          XCTFail()
          break
        }
        if !success && string.hasSuffix("Passed\n") {
          success = true
          successInstructionCount = instructions
          remainingPrintInstructions = instructionsForSuccessToPrint
        }
      }

      instructions += 1
      if success {
        remainingPrintInstructions -= 1
      }
    } while (instructions < expectedInstructions + instructionsForSuccessToPrint) && (!success || remainingPrintInstructions > 0)

    let screenshot: Data = gameboy.takeScaledScreenshot().png!

    if let screenshotPath = Bundle.module.path(forResource: rom, ofType: "png") {
      let existingScreenshot = try Data(contentsOf: URL(fileURLWithPath: screenshotPath))
      XCTAssertEqual(screenshot.checksum, existingScreenshot.checksum)
    }

    if updateGoldens {
      let localFile = NSURL(fileURLWithPath: #file).deletingLastPathComponent!.appendingPathComponent(rom).appendingPathExtension("png")
      try screenshot.write(to: localFile)
    }

    XCTAssertTrue(success, String(bytes: gameboy.serialDataReceived, encoding: .ascii)!)
    XCTAssertEqual(successInstructionCount, expectedInstructions)
  }

}
