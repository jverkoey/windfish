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

class BlarggTests: XCTestCase {

  func run(rom: String) throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: rom, ofType: "gb"))
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let gameboy = Gameboy()
    gameboy.cartridge = .init(data: data)
    gameboy.cpu.pc = 0x100  // Assume the boot sequence has concluded.

    let maxInstructions = 1_300_000
    var instructions = 0
    var success = false
    repeat {
      gameboy.advanceInstruction()

      if let sourceLocation = gameboy.cpu.machineInstruction.sourceLocation {
        var address = sourceLocation.address()
        let instruction = Disassembler.fetchInstruction(at: &address, memory: gameboy.memory)
        print("\(sourceLocation.address().hexString) \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      }

      if !gameboy.serialDataReceived.isEmpty {
        let string = String(bytes: gameboy.serialDataReceived, encoding: .ascii)!
        if string.hasSuffix("Passed\n") {
          success = true
          break
        }
      }

      instructions += 1
    } while instructions < maxInstructions

    XCTAssertTrue(success, String(bytes: gameboy.serialDataReceived, encoding: .ascii)!)
  }

  func test_01_Special() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/01-special")
  }

  func test_02_interrupts() throws {
    try run(rom: "Resources/blargg/cpu_instrs/individual/02-interrupts")
  }
}
