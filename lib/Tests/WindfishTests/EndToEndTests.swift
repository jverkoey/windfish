import XCTest
@testable import Windfish

extension Disassembler {
  func disassembleAsGameboyCartridge() {
    // Restart addresses
    let numberOfRestartAddresses: LR35902.Address = 8
    let restartSize: LR35902.Address = 8
    let rstAddresses = (0..<numberOfRestartAddresses).map { ($0 * restartSize)..<($0 * restartSize + restartSize) }
    rstAddresses.forEach {
      registerLabel(at: $0.lowerBound, in: 0x01, named: "RST_\($0.lowerBound.hexString)")
      disassemble(range: $0, inBank: 0x01)
    }

    disassemble(range: 0x0040..<0x0048, inBank: 0x01)
    disassemble(range: 0x0048..<0x0050, inBank: 0x01)
    disassemble(range: 0x0050..<0x0058, inBank: 0x01)
    disassemble(range: 0x0058..<0x0060, inBank: 0x01)
    disassemble(range: 0x0060..<0x0068, inBank: 0x01)
    disassemble(range: 0x0100..<0x0104, inBank: 0x01)

    registerData(at: 0x0104..<0x0134, in: 0x01)
    registerText(at: 0x0134..<0x0143, in: 0x01)
    registerData(at: 0x0144..<0x0146, in: 0x01)
    registerData(at: 0x0147, in: 0x01)
    registerData(at: 0x014B, in: 0x01)
    registerData(at: 0x014C, in: 0x01)
    registerData(at: 0x014D, in: 0x01)
    registerData(at: 0x014E..<0x0150, in: 0x01)
  }
}

class EndToEndTests: XCTestCase {

  func testROMExists() {
    // ROM sourced from https://gbhh.avivace.com/game/2048gb
    let path = Bundle.module.path(forResource: "Resources/2048", ofType: "gb")
    XCTAssertNotNil(path)
  }

  func testWallTimePerformance() throws {
    try XCTSkipIf(true)
    let byteValue = UInt8(0xFA)
    // ~0.687
    measure {
      for _ in 0..<1_000_000 {
        _ = Int(byteValue)
      }
    }
  }

  func testWallTimePerformanceTruncatingIfNeeded() throws {
    try XCTSkipIf(true)
    let byteValue = UInt8(0xFA)
    // ~0.664
    measure {
      for _ in 0..<1_000_000 {
        _ = Int(truncatingIfNeeded: byteValue)
      }
    }
  }

  func testWallTimePerformanceUnsafebound() throws {
    try XCTSkipIf(true)
    let byteValue = UInt8(0xFA)
    // ~0.621
    measure {
      for _ in 0..<1_000_000 {
        var intValue: Int = 0
        withUnsafeMutableBytes(of: &intValue) { (pointer: UnsafeMutableRawBufferPointer) in
          pointer[0] = byteValue
        }
      }
    }
  }

  func testGoldens() throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: "Resources/2048", ofType: "gb"))
    let rom = try Data(contentsOf: URL(fileURLWithPath: path))

    let disassembly = Disassembler(data: rom)
    disassembly.disassembleAsGameboyCartridge()
    let (disassembledSource, statistics) = try! disassembly.generateSource()
    XCTAssertEqual(
      statistics,
      Disassembler.Statistics(instructionsDecoded: 1310, percent: 6.5704345703125, bankPercents: [
        0: 13.140869140625,
        1: 0
      ])
    )

    let disassemblyFiles: [String: String] = disassembledSource.sources.mapValues {
      switch $0 {
      case .bank(_, let content, _): fallthrough
      case .charmap(content: let content): fallthrough
      case .datatypes(content: let content): fallthrough
      case .game(content: let content): fallthrough
      case .macros(content: let content): fallthrough
      case .makefile(content: let content): fallthrough
      case .variables(content: let content):
        return content
      }
    }

    let updateGoldens = false

    try disassemblyFiles.forEach { key, value in
      let path = try XCTUnwrap(Bundle.module.path(forResource: key, ofType: nil, inDirectory: "Resources/goldens"))
      let goldenUrl = URL(fileURLWithPath: path)
      if updateGoldens {
        try value.write(to: goldenUrl, atomically: true, encoding: .utf8)
        print(goldenUrl)
      } else {
        let goldenFile = try String(contentsOf: goldenUrl)
        XCTAssertEqual(goldenFile, value)
      }
    }
  }
}
