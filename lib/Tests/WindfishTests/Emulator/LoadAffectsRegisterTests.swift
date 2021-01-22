import XCTest
@testable import Windfish

class LoadAffectsRegisterTests: XCTestCase {
  func test_ld_a() throws {
    let disassembly = disassemblyInitialized(with: """
ld   a, 1
""")
    let cpu = LR35902.zeroed()
    disassembly.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu)

    assertEqual(cpu, LR35902(a: 1, pc: 0x0002))
  }

  func test_ld_b() throws {
    let disassembly = disassemblyInitialized(with: """
ld   b, 1
""")
    let cpu = LR35902.zeroed()
    disassembly.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu)

    assertEqual(cpu, LR35902(b: 1, pc: 0x0002))
  }

  func test_ld_c() throws {
    let disassembly = disassemblyInitialized(with: """
ld   c, 1
""")
    let cpu = LR35902.zeroed()
    disassembly.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu)

    assertEqual(cpu, LR35902(c: 1, pc: 0x0002))
  }

  func test_ld_d() throws {
    let disassembly = disassemblyInitialized(with: """
ld   d, 1
""")
    let cpu = LR35902.zeroed()
    disassembly.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu)

    assertEqual(cpu, LR35902(d: 1, pc: 0x0002))
  }

  func test_ld_e() throws {
    let disassembly = disassemblyInitialized(with: """
ld   e, 1
""")
    let cpu = LR35902.zeroed()
    disassembly.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu)

    assertEqual(cpu, LR35902(e: 1, pc: 0x0002))
  }

  func test_ld_h() throws {
    let disassembly = disassemblyInitialized(with: """
ld   h, 1
""")
    let cpu = LR35902.zeroed()
    disassembly.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu)

    assertEqual(cpu, LR35902(h: 1, pc: 0x0002))
  }

  func test_ld_l() throws {
    let disassembly = disassemblyInitialized(with: """
ld   l, 1
""")
    let cpu = LR35902.zeroed()
    disassembly.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.cartridgeSize), bank: 1), cpu: cpu)

    assertEqual(cpu, LR35902(l: 1, pc: 0x0002))
  }
}
