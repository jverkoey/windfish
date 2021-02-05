import XCTest
@testable import Windfish

class LoadAffectsRegisterTests: XCTestCase {
  func test_ld_a() throws {
    let disassembly = disassemblyInitialized(with: """
ld   a, 1
""")
    let cpu = LR35902.zeroed()
    let mutated = cpu.copy()
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.configuration.cartridgeData.count), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    mutated.a = 1
    mutated.pc = 0x0002
    assertEqual(cpu, mutated)
  }

  func test_ld_b() throws {
    let disassembly = disassemblyInitialized(with: """
ld   b, 1
""")
    let cpu = LR35902.zeroed()
    let mutated = cpu.copy()
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.configuration.cartridgeData.count), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    mutated.b = 1
    mutated.pc = 0x0002
    assertEqual(cpu, mutated)
  }

  func test_ld_c() throws {
    let disassembly = disassemblyInitialized(with: """
ld   c, 1
""")
    let cpu = LR35902.zeroed()
    let mutated = cpu.copy()
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.configuration.cartridgeData.count), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    mutated.c = 1
    mutated.pc = 0x0002
    assertEqual(cpu, mutated)
  }

  func test_ld_d() throws {
    let disassembly = disassemblyInitialized(with: """
ld   d, 1
""")
    let cpu = LR35902.zeroed()
    let mutated = cpu.copy()
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.configuration.cartridgeData.count), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    mutated.d = 1
    mutated.pc = 0x0002
    assertEqual(cpu, mutated)
  }

  func test_ld_e() throws {
    let disassembly = disassemblyInitialized(with: """
ld   e, 1
""")
    let cpu = LR35902.zeroed()
    let mutated = cpu.copy()
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.configuration.cartridgeData.count), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    mutated.e = 1
    mutated.pc = 0x0002
    assertEqual(cpu, mutated)
  }

  func test_ld_h() throws {
    let disassembly = disassemblyInitialized(with: """
ld   h, 1
""")
    let cpu = LR35902.zeroed()
    let mutated = cpu.copy()
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.configuration.cartridgeData.count), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    mutated.h = 1
    mutated.pc = 0x0002
    assertEqual(cpu, mutated)
  }

  func test_ld_l() throws {
    let disassembly = disassemblyInitialized(with: """
ld   l, 1
""")
    let cpu = LR35902.zeroed()
    let mutated = cpu.copy()
    Disassembler.trace(range: Cartridge.Location(address: 0, bank: 1)..<Cartridge.Location(address: LR35902.Address(disassembly.configuration.cartridgeData.count), bank: 1), cpu: cpu, context: disassembly.configuration, router: disassembly.lastBankRouter!)

    mutated.l = 1
    mutated.pc = 0x0002
    assertEqual(cpu, mutated)
  }
}
