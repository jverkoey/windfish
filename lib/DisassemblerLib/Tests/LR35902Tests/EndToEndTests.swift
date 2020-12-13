import XCTest
@testable import LR35902

class EndToEndTests: XCTestCase {

  func testROMExists() {
    // ROM sourced from https://gbhh.avivace.com/game/2048gb
    let path = Bundle.module.path(forResource: "Resources/2048", ofType: "gb")
    XCTAssertNotNil(path)
  }

  func testWallTimePerformance() throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: "Resources/2048", ofType: "gb"))
    let rom = try Data(contentsOf: URL(fileURLWithPath: path))

    // ~0.241
    measure {
      let disassembly = LR35902.Disassembly(rom: rom)
      disassembly.disassembleAsGameboyCartridge()
      _ = try! disassembly.generateSource()
    }
  }

  func testCPUPerformance() throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: "Resources/2048", ofType: "gb"))
    let rom = try Data(contentsOf: URL(fileURLWithPath: path))

    // 1,530,000
    measure(metrics: [XCTCPUMetric(limitingToCurrentThread: true)]) {
      let disassembly = LR35902.Disassembly(rom: rom)
      disassembly.disassembleAsGameboyCartridge()
      _ = try! disassembly.generateSource()
    }
  }

  func testGoldens() throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: "Resources/2048", ofType: "gb"))
    let rom = try Data(contentsOf: URL(fileURLWithPath: path))

    let disassembly = LR35902.Disassembly(rom: rom)
    disassembly.disassembleAsGameboyCartridge()
    let (disassembledSource, statistics) = try! disassembly.generateSource()
    XCTAssertEqual(
      statistics,
      LR35902.Disassembly.Statistics(instructionsDecoded: 1310, percent: 6.5704345703125, bankPercents: [
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

    let goldensPath = try XCTUnwrap(Bundle.module.resourcePath)
    let goldensUrl = URL(fileURLWithPath: goldensPath).appendingPathComponent("Resources/goldens")
    try disassemblyFiles.forEach { key, value in
      let goldenUrl = goldensUrl.appendingPathComponent(key)
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
