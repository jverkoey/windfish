import XCTest
import Windfish

// References:
// - https://gbdev.gg8.se/files/roms/blargg-gb-tests/

extension Disassembler.SourceLocation {
  func address() -> LR35902.Address {
    switch self {
    case .cartridge(let location):
      return Gameboy.Cartridge.addressAndBank(from: location).address
    case .memory(let address):
      return address
    }
  }
}

extension NSBitmapImageRep {
  var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
  var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
  var png: Data? { tiffRepresentation?.bitmap?.png }
}

extension Data {
  var checksum: Int {
    return self.map { Int($0) }.reduce(0, +) & 0xff
  }
}

class BlarggTests: XCTestCase {
  let updateGoldens = false

  func test_01_Special() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/01-special", expectedInstructions: 1_279_058)
  }

  func test_02_interrupts() throws {
    try XCTSkipUnless(updateGoldens)  // Gets stuck at 0xC7F4 running a jr   @-$00
    try run(rom: "Resources/blargg/cpu_instrs/individual/02-interrupts", expectedInstructions: 1_092_295)
  }

  func test_03_op_sp_hl() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/03-op sp,hl", expectedInstructions: 1_091_112)
  }

  func test_04_op_r_imm() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/04-op r,imm", expectedInstructions: 1_283_258)
  }

  func test_05_op_rp() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/05-op rp", expectedInstructions: 1_790_572)
  }

  func test_06_ld_r_r() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/06-ld r,r", expectedInstructions: 270_401)
  }

  func test_07_jr_jp_call_ret_rst() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/07-jr,jp,call,ret,rst", expectedInstructions: 322_332)
  }

  func test_08_misc_instrs() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/08-misc instrs", expectedInstructions: 252_567)
  }

  func test_09_op_r_r() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/09-op r,r", expectedInstructions: 4_443_002)
  }

  func test_10_bit_ops() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/10-bit ops", expectedInstructions: 6_733_717)
  }

  func test_11_op_a_hladdr() throws {
    try XCTSkipUnless(updateGoldens)  // Failing with "CB 0E CB 2E"
    try run(rom: "Resources/blargg/cpu_instrs/individual/11-op a,(hl)", expectedInstructions: 15_740_332)
  }

  func run(rom: String, expectedInstructions: Int) throws {
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
    XCTAssertEqual(successInstructionCount, expectedInstructions)
  }

}
