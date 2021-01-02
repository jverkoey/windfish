import XCTest
import Windfish

// References:
// - https://gekkio.fi/files/mooneye-gb/latest/

class MooneyeTests: XCTestCase {
  let updateGoldens = false

  // MARK: - acceptance/bits

  func test_acceptance_bits_mem_oam() throws {
    try XCTSkipUnless(updateGoldens)  // ALL 0s
    try run(testRom: "Resources/mooneye/acceptance/bits/mem_oam")
  }

  func test_acceptance_bits_reg_f() throws {
    try run(testRom: "Resources/mooneye/acceptance/bits/reg_f", expectedInstructions: 93_751)
  }

  func test_acceptance_bits_unused_hwio_gs() throws {
    try XCTSkipUnless(updateGoldens)
    try run(testRom: "Resources/mooneye/acceptance/bits/unused_hwio-GS", expectedInstructions: 93_218)
  }

  // MARK: - acceptance/instr

  func test_acceptance_instr_daa() throws {
    try run(testRom: "Resources/mooneye/acceptance/instr/daa", expectedInstructions: 188939)
  }

  // MARK: - acceptance/interrupts

  func test_acceptance_interrupts_ie_push() throws {
    try XCTSkipUnless(updateGoldens)  // R1: not cancelled
    try run(testRom: "Resources/mooneye/acceptance/interrupts/ie_push", expectedInstructions: 92_597)
  }

  // MARK: - acceptance/oam_dma

  func test_acceptance_oam_dma_basic() throws {
    try XCTSkipUnless(updateGoldens)  // FAIL: $FE00
    try run(testRom: "Resources/mooneye/acceptance/oam_dma/basic", expectedInstructions: 93_847)
  }

  func test_acceptance_oam_dma_reg_read() throws {
    try run(testRom: "Resources/mooneye/acceptance/oam_dma/reg_read", expectedInstructions: 93_315)
  }

  func test_acceptance_oam_dma_sources_GS() throws {
    try XCTSkipUnless(updateGoldens)  // FAIL: $0000
    try run(testRom: "Resources/mooneye/acceptance/oam_dma/sources-GS", expectedInstructions: 208_553)
  }

  // MARK: - acceptance/ppu

  func test_acceptance_ppu_hblank_ly_scx_timing_GS() throws {
    try XCTSkipUnless(updateGoldens)  // Never completes
    try run(testRom: "Resources/mooneye/acceptance/ppu/hblank_ly_scx_timing-GS")
  }

  func test_acceptance_ppu_intr_1_2_timing_GS() throws {
    try XCTSkipUnless(updateGoldens)  // Never completes
    try run(testRom: "Resources/mooneye/acceptance/ppu/intr_1_2_timing-GS")
  }

  func test_acceptance_ppu_intr_2_0_timing() throws {
    try XCTSkipUnless(updateGoldens)  // Never completes
    try run(testRom: "Resources/mooneye/acceptance/ppu/intr_2_0_timing")
  }

  // MARK: - acceptance/

  func test_acceptance_add_sp_e_timing() throws {
    try XCTSkipUnless(updateGoldens)  // sp appears to be getting corrupted
    try run(testRom: "Resources/mooneye/acceptance/add_sp_e_timing")
  }

  func test_acceptance_boot_regs_dmg0() throws {
    try XCTSkipUnless(updateGoldens)  // Some registers aren't matching.
    try run(testRom: "Resources/mooneye/acceptance/boot_regs-dmg0", expectedInstructions: 94007)
  }

  func test_acceptance_call_timing() throws {
    try XCTSkipUnless(updateGoldens)  // sp appears to be getting corrupted
    try run(testRom: "Resources/mooneye/acceptance/call_timing")
  }

  // MARK: - emulator-only/

  func test_emulator_only_mbc1_bits_bank_1() throws {
    try run(testRom: "Resources/mooneye/emulator-only/mbc1/bits_bank1", expectedInstructions: 1_571_834)
  }

  func test_emulator_only_mbc1_bits_bank_2() throws {
    try XCTSkipIf(true)  // RAM banks not implemented yet.
    try run(testRom: "Resources/mooneye/emulator-only/mbc1/bits_bank2")
  }

  func test_emulator_only_mbc1_bits_mode() throws {
    try XCTSkipIf(true)  // Upper Bits of ROM Bank Number not implemented yet
    try run(testRom: "Resources/mooneye/emulator-only/mbc1/bits_mode")
  }

  func run(testRom: String, expectedInstructions: Int = 5_000_000) throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: testRom, ofType: "gb"))
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let gameboy = Gameboy()
    gameboy.cartridge = .init(data: data)
    gameboy.cpu.pc = 0x100  // Assume the boot sequence has concluded.

    var instructions = 0
    repeat {
      gameboy.advanceInstruction()
      if case .ld(.b, .b) = gameboy.cpu.machineInstruction.spec {
        break
      }

      //      if let sourceLocation = gameboy.cpu.machineInstruction.sourceLocation {
      //        var address = sourceLocation.address()
      //        let instruction = Disassembler.fetchInstruction(at: &address, memory: gameboy.memory)
      //        print("\(sourceLocation.address().hexString) \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      //      }

      instructions += 1
    } while instructions <= expectedInstructions

    let screenshot: Data = gameboy.takeScreenshot().png!

    if let screenshotPath = Bundle.module.path(forResource: testRom, ofType: "png") {
      let existingScreenshot = try Data(contentsOf: URL(fileURLWithPath: screenshotPath))
//      print([UInt8](existingScreenshot))
//      print([UInt8](screenshot))
      XCTAssertEqual(screenshot.checksum, existingScreenshot.checksum, "Checksum failure for \(testRom)")
    }

    if updateGoldens {
      let localFile = NSURL(fileURLWithPath: #file).deletingLastPathComponent!.appendingPathComponent(testRom).appendingPathExtension("png")
      try screenshot.write(to: localFile)
    }

    XCTAssertEqual(instructions, expectedInstructions)
    XCTAssertEqual(gameboy.cpu.a, 0, "Assertion failure: \(testRom)")
    XCTAssert(gameboy.cpu.b == 3 && gameboy.cpu.c == 5 && gameboy.cpu.d == 8 && gameboy.cpu.e == 13 && gameboy.cpu.h == 21 && gameboy.cpu.l == 34,
              "Hardware test failed: \(testRom)")
  }

}
