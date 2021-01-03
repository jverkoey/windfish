import XCTest
import Windfish

// References:
// - https://github.com/mattcurrie/mealybug-tearoom-tests

class MealybugTearoomTests: XCTestCase {
  let updateGoldens = false

  func test_01_Special() throws {
    try XCTSkipUnless(updateGoldens)  // DMG0 is not supported.
    try run(rom: "Resources/mealybug-tearoom/m3_wx_4_change")
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
    repeat {
      gameboy.advanceInstruction()

      //      if let sourceLocation = gameboy.cpu.machineInstruction.sourceLocation {
      //        var address = sourceLocation.address()
      //        let instruction = Disassembler.fetchInstruction(at: &address, memory: gameboy.memory)
      //        print("\(sourceLocation.address().hexString) \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      //      }

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

    XCTAssertTrue(success, String(bytes: gameboy.serialDataReceived, encoding: .ascii)!)
    XCTAssertEqual(instructions - instructionsForSuccessToPrint, expectedInstructions)
  }

}
