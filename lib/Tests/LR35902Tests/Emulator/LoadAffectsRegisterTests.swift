import XCTest
@testable import LR35902

class LoadAffectsRegisterTests: XCTestCase {
  func test_ld_a() throws {
    let disassembly = disassemblyInitialized(with: """
ld   a, 1
""")
    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size)

    let state = try XCTUnwrap(states[LR35902.Cartridge.Location(0x0000)])
    assertEqual(state, LR35902.CPUState(a: 1))
  }

  func test_ld_b() throws {
    let disassembly = disassemblyInitialized(with: """
ld   b, 1
""")
    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size)

    let state = try XCTUnwrap(states[LR35902.Cartridge.Location(0x0000)])
    assertEqual(state, LR35902.CPUState(b: 1))
  }

  func test_ld_c() throws {
    let disassembly = disassemblyInitialized(with: """
ld   c, 1
""")
    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size)

    let state = try XCTUnwrap(states[LR35902.Cartridge.Location(0x0000)])
    assertEqual(state, LR35902.CPUState(c: 1))
  }

  func test_ld_d() throws {
    let disassembly = disassemblyInitialized(with: """
ld   d, 1
""")
    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size)

    let state = try XCTUnwrap(states[LR35902.Cartridge.Location(0x0000)])
    assertEqual(state, LR35902.CPUState(d: 1))
  }

  func test_ld_e() throws {
    let disassembly = disassemblyInitialized(with: """
ld   e, 1
""")
    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size)

    let state = try XCTUnwrap(states[LR35902.Cartridge.Location(0x0000)])
    assertEqual(state, LR35902.CPUState(e: 1))
  }

  func test_ld_h() throws {
    let disassembly = disassemblyInitialized(with: """
ld   h, 1
""")
    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size)

    let state = try XCTUnwrap(states[LR35902.Cartridge.Location(0x0000)])
    assertEqual(state, LR35902.CPUState(h: 1))
  }

  func test_ld_l() throws {
    let disassembly = disassemblyInitialized(with: """
ld   l, 1
""")
    let states = disassembly.trace(range: 0..<disassembly.cpu.cartridge.size)

    let state = try XCTUnwrap(states[LR35902.Cartridge.Location(0x0000)])
    assertEqual(state, LR35902.CPUState(l: 1))
  }
}
