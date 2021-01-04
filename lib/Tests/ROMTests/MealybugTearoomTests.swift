import XCTest
import Windfish

// References:
// - https://github.com/mattcurrie/mealybug-tearoom-tests

class MealybugTearoomTests: XCTestCase {
  let updateGoldens = false

  func test_m3_bgp_change() throws {
    try XCTSkipUnless(updateGoldens)
    try run(rom: "Resources/mealybug-tearoom/m3_bgp_change")
  }

  func test_m3_lcdc_bg_en_change() throws {
    try XCTSkipUnless(updateGoldens)
    try run(rom: "Resources/mealybug-tearoom/m3_lcdc_bg_en_change")
  }

  func test_m3_scy_change() throws {
    try XCTSkipUnless(updateGoldens)
    try run(rom: "Resources/mealybug-tearoom/m3_scy_change")
  }

  func test_m3_wx_4_change() throws {
    try XCTSkipUnless(updateGoldens)
    try run(rom: "Resources/mealybug-tearoom/m3_wx_4_change")
  }

  func test_m3_wx_5_change() throws {
    try XCTSkipUnless(updateGoldens)
    try run(rom: "Resources/mealybug-tearoom/m3_wx_5_change")
  }

  func test_m3_wx_6_change() throws {
    try XCTSkipUnless(updateGoldens)
    try run(rom: "Resources/mealybug-tearoom/m3_wx_6_change")
  }

  func run(rom: String, expectedInstructions: Int = 2_000_000) throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: rom, ofType: "gb"))
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let gameboy = Gameboy()
    gameboy.cartridge = .init(data: data)
    gameboy.cpu.pc = 0x100  // Assume the boot sequence has concluded.

    let instructionsForSuccessToPrint = 17500

    var instructions = 0
    repeat {
      gameboy.advanceInstruction()
      instructions += 1
    } while instructions < (expectedInstructions + instructionsForSuccessToPrint)

    let screenshot: Data = gameboy.takeScreenshot().png!

    if let screenshotPath = Bundle.module.path(forResource: rom, ofType: "png") {
      let existingScreenshot = try Data(contentsOf: URL(fileURLWithPath: screenshotPath))
      XCTAssertEqual(screenshot.checksum, existingScreenshot.checksum)
    }

    if updateGoldens {
      let localFile = NSURL(fileURLWithPath: #file).deletingLastPathComponent!.appendingPathComponent(rom).appendingPathExtension("png")
      try screenshot.write(to: localFile)
    }
  }

}
