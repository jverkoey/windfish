import XCTest
import Windfish

// References:
// - https://gekkio.fi/files/mooneye-gb/latest/

class MooneyeTests: XCTestCase {

  func testAll() throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: "Resources/mooneye-gb_hwtests/emulator-only/mbc1/bits_bank1", ofType: "gb"))
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
      instructions += 1
    } while instructions < maxInstructions

    XCTAssertEqual(gameboy.cpu.a, 0, "Assertion failure.")
    XCTAssert(gameboy.cpu.b == 3 && gameboy.cpu.c == 5 && gameboy.cpu.d == 8 && gameboy.cpu.e == 13 && gameboy.cpu.h == 21 && gameboy.cpu.l == 34,
              "Hardware test failed")
  }
}
