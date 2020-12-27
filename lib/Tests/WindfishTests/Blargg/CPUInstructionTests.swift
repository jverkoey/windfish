import XCTest
@testable import Windfish

class CPUInstructionTests: XCTestCase {

  func testAll() throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: "Resources/blargg/cpu_instrs/individual/01-special", ofType: "gb"))
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    var gameboy = Gameboy(cartridge: .init(data: data))

    gameboy = gameboy.advanceInstruction()
    while let loaded = gameboy.cpu.machineInstruction.loaded {
      var pc = Gameboy.Cartridge.addressAndBank(from: loaded.sourceLocation).address
      let instruction = Disassembler.fetchInstruction(pc: &pc, memory: gameboy.memory)
      print("\(loaded.sourceLocation.hexString) \(RGBDSDisassembler.statement(for: instruction).formattedString)")
      gameboy = gameboy.advanceInstruction()
    }
  }
}
