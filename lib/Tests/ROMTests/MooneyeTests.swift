import XCTest
import Windfish

// References:
// - https://gekkio.fi/files/mooneye-gb/latest/

class MooneyeTests: XCTestCase {
  // MARK: - acceptance/bits

  func test_acceptance_bits_mem_oam() throws {
    try XCTSkipUnless(updateGoldens)  // ALL 0s
    try run(testRom: "Resources/mooneye/acceptance/bits/mem_oam")
  }

  func test_acceptance_bits_reg_f() throws {
    try run(testRom: "Resources/mooneye/acceptance/bits/reg_f", expectedInstructions: 93_835)
  }

  func test_acceptance_bits_unused_hwio_gs() throws {
    try XCTSkipUnless(updateGoldens)
    try run(testRom: "Resources/mooneye/acceptance/bits/unused_hwio-GS")
  }

  // MARK: - acceptance/instr

  func test_acceptance_instr_daa() throws {
    try run(testRom: "Resources/mooneye/acceptance/instr/daa", expectedInstructions: 189521)
  }

  // MARK: - acceptance/interrupts

  func test_acceptance_interrupts_ie_push() throws {
    try XCTSkipUnless(updateGoldens)  // R1: not cancelled
    try run(testRom: "Resources/mooneye/acceptance/interrupts/ie_push")
  }

  // MARK: - acceptance/oam_dma

  func test_acceptance_oam_dma_basic() throws {
    try XCTSkipUnless(updateGoldens)  // FAIL: $FE00
    try run(testRom: "Resources/mooneye/acceptance/oam_dma/basic")
  }

  func test_acceptance_oam_dma_reg_read() throws {
    try run(testRom: "Resources/mooneye/acceptance/oam_dma/reg_read", expectedInstructions: 93_399)
  }

  func test_acceptance_oam_dma_sources_GS() throws {
    try XCTSkipUnless(updateGoldens)  // FAIL: $0000
    try run(testRom: "Resources/mooneye/acceptance/oam_dma/sources-GS")
  }

  // MARK: - acceptance/ppu

  func test_acceptance_ppu_hblank_ly_scx_timing_GS() throws {
    try XCTSkipUnless(updateGoldens)
    try run(testRom: "Resources/mooneye/acceptance/ppu/hblank_ly_scx_timing-GS")
  }

  func test_acceptance_ppu_intr_1_2_timing_GS() throws {
    try XCTSkipUnless(updateGoldens)  // D: 14! E: 15!
    try run(testRom: "Resources/mooneye/acceptance/ppu/intr_1_2_timing-GS")
  }

  func test_acceptance_ppu_intr_2_0_timing() throws {
    try run(testRom: "Resources/mooneye/acceptance/ppu/intr_2_0_timing", expectedInstructions: 106_974)
  }

  func test_acceptance_ppu_intr_2_mode0_timing_sprites() throws {
    try XCTSkipUnless(updateGoldens)  // No reason for failure shown
    try run(testRom: "Resources/mooneye/acceptance/ppu/intr_2_mode0_timing_sprites")
  }

  func test_acceptance_ppu_intr_2_mode0_timing() throws {
    try run(testRom: "Resources/mooneye/acceptance/ppu/intr_2_mode0_timing", expectedInstructions: 107_025)
  }

  func test_acceptance_ppu_intr_2_mode3_timing() throws {
    try run(testRom: "Resources/mooneye/acceptance/ppu/intr_2_mode3_timing", expectedInstructions: 106_972)
  }

  func test_acceptance_ppu_intr_2_oam_ok_timing() throws {
    try run(testRom: "Resources/mooneye/acceptance/ppu/intr_2_oam_ok_timing", expectedInstructions: 107_425)
  }

  func test_acceptance_ppu_stat_lyc_onoff() throws {
    try XCTSkipUnless(updateGoldens)  // Fail: r1 step 1
    try run(testRom: "Resources/mooneye/acceptance/ppu/stat_lyc_onoff")
  }

  func test_acceptance_ppu_vblank_stat_intr_GS() throws {
    try run(testRom: "Resources/mooneye/acceptance/ppu/vblank_stat_intr-GS", expectedInstructions: 120_806)
  }

  // MARK: - acceptance/

  func test_acceptance_add_sp_e_timing() throws {
    try XCTSkipUnless(updateGoldens)  // sp appears to be getting corrupted
    try run(testRom: "Resources/mooneye/acceptance/add_sp_e_timing")
  }

  func test_acceptance_boot_div_dmgABCmgb() throws {
    try run(testRom: "Resources/mooneye/acceptance/boot_div-dmgABCmgb", expectedInstructions: 94_125)
  }

  func test_acceptance_boot_hwio_dmgABCmgb() throws {
    try XCTSkipUnless(updateGoldens)  // DMG0 is not supported.
    try run(testRom: "Resources/mooneye/acceptance/boot_hwio-dmgABCmgb")
  }

  func test_acceptance_boot_regs_dmg0() throws {
    try XCTSkipUnless(updateGoldens)  // DMG0 is not supported.
    try run(testRom: "Resources/mooneye/acceptance/boot_regs-dmg0")
  }

  func test_acceptance_boot_regs_dmgABC() throws {
    try run(testRom: "Resources/mooneye/acceptance/boot_regs-dmgABC", expectedInstructions: 93_979)
  }

  func test_acceptance_call_timing() throws {
    try XCTSkipUnless(updateGoldens)  // sp appears to be getting corrupted
    try run(testRom: "Resources/mooneye/acceptance/call_timing")
  }

  func test_acceptance_div_timing() throws {
    try run(testRom: "Resources/mooneye/acceptance/div_timing", expectedInstructions: 93_999)
  }

  func test_acceptance_ei_sequence() throws {
    try XCTSkipUnless(updateGoldens)  // C: A2!
    try run(testRom: "Resources/mooneye/acceptance/ei_sequence", expectedInstructions: 93_927)
  }

  func test_acceptance_ei_timing() throws {
    try XCTSkipUnless(updateGoldens)  // B: 01!
    try run(testRom: "Resources/mooneye/acceptance/ei_timing")
  }

  func test_acceptance_if_ie_registers() throws {
    try XCTSkipUnless(updateGoldens)  // C: E8! E: E0!
    try run(testRom: "Resources/mooneye/acceptance/if_ie_registers")
  }

  func test_acceptance_intr_timing() throws {
    try run(testRom: "Resources/mooneye/acceptance/intr_timing", expectedInstructions: 93_905)
  }

  func test_acceptance_jp_timing() throws {
    try XCTSkipUnless(updateGoldens)  // sp appears to be getting corrupted
    try run(testRom: "Resources/mooneye/acceptance/jp_timing")
  }

  func test_acceptance_ld_hl_sp_e_timing() throws {
    try XCTSkipIf(true)  // Upper Bits of ROM Bank Number not implemented yet
    try run(testRom: "Resources/mooneye/acceptance/ld_hl_sp_e_timing")
  }

  func test_acceptance_oam_dma_restart() throws {
    try run(testRom: "Resources/mooneye/acceptance/oam_dma_restart", expectedInstructions: 113_872)
  }

  func test_acceptance_oam_dma_start() throws {
    try XCTSkipUnless(updateGoldens)  // C: 01!
    try run(testRom: "Resources/mooneye/acceptance/oam_dma_start")
  }

  func test_acceptance_oam_dma_timing() throws {
    try run(testRom: "Resources/mooneye/acceptance/oam_dma_timing", expectedInstructions: 113_865)
  }

  func test_acceptance_pop_timing() throws {
    try run(testRom: "Resources/mooneye/acceptance/pop_timing", expectedInstructions: 94_106)
  }

  func test_acceptance_push_timing() throws {
    try XCTSkipUnless(updateGoldens)  // D: 81! H: 42!
    try run(testRom: "Resources/mooneye/acceptance/push_timing")
  }

  func test_acceptance_rapid_di_ei() throws {
    try XCTSkipUnless(updateGoldens)  // B: 00! C: 00! D: 01!
    try run(testRom: "Resources/mooneye/acceptance/rapid_di_ei")
  }

  func test_acceptance_ret_timing() throws {
    try XCTSkipIf(true)  // Upper Bits of ROM Bank Number not implemented yet
    try run(testRom: "Resources/mooneye/acceptance/ret_timing")
  }

  func test_acceptance_rst_timing() throws {
    try XCTSkipUnless(updateGoldens)  // B: 81! D: FF!
    try run(testRom: "Resources/mooneye/acceptance/rst_timing")
  }

  // MARK: - emulator-only/

  func test_emulator_only_mbc1_bits_bank_1() throws {
    try run(testRom: "Resources/mooneye/emulator-only/mbc1/bits_bank1", expectedInstructions: 1_572_467)
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

    let screenshot: Data = gameboy.takeScaledScreenshot().png!

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
