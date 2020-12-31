import XCTest
@testable import Windfish

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

class CPUInstructionTests: XCTestCase {

  func testAll() throws {
    try XCTSkipIf(true)
    let path = try XCTUnwrap(Bundle.module.path(forResource: "Resources/blargg/cpu_instrs/individual/01-special", ofType: "gb"))
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let gameboy = Gameboy()
    gameboy.cartridge = .init(data: data)

    gameboy.advanceInstruction()
    while let loaded = gameboy.cpu.machineInstruction.loaded {
      var address = loaded.sourceLocation.address()
      let instruction = Disassembler.fetchInstruction(at: &address, memory: gameboy.memory)
      print("\(loaded.sourceLocation.address().hexString) \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      gameboy.advanceInstruction()
    }
  }
}
