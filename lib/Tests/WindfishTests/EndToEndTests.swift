import XCTest
@testable import Windfish

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
        let intValue = Int(byteValue)
      }
    }
  }

  func testWallTimePerformanceTruncatingIfNeeded() throws {
    try XCTSkipIf(true)
    let byteValue = UInt8(0xFA)
    // ~0.664
    measure {
      for _ in 0..<1_000_000 {
        let intValue = Int(truncatingIfNeeded: byteValue)
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

  func disable_testWallTimePerformance() throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: "Resources/2048", ofType: "gb"))
    let rom = try Data(contentsOf: URL(fileURLWithPath: path))

    // ~0.255
    measure {
      let disassembly = Disassembler(data: rom)
      disassembly.disassembleAsGameboyCartridge()
      _ = try! disassembly.generateSource()
    }
  }

  func disable_testCPUPerformance() throws {
    let path = try XCTUnwrap(Bundle.module.path(forResource: "Resources/2048", ofType: "gb"))
    let rom = try Data(contentsOf: URL(fileURLWithPath: path))

    // 1,540,000
    measure(metrics: [XCTCPUMetric(limitingToCurrentThread: true)]) {
      let disassembly = Disassembler(data: rom)
      disassembly.disassembleAsGameboyCartridge()
      _ = try! disassembly.generateSource()
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
