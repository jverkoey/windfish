import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_ld_r_r() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(let dst, let src) = spec, let emulator = LR35902.Emulation.ld_r_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()
      cpu[src] = UInt8(0x01)
      cpu[dst] = UInt8(0x10)

      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 1)
      mutations[dst] = mutations[src] as UInt8
      assertEqual(cpu, mutations)
    }
  }

  func test_ld_r_n() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(let dst, .imm8) = spec, let emulator = LR35902.Emulation.ld_r_n(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 2)
      mutations.pc += 1
      mutations[dst] = 0x12 as UInt8
      assertEqual(cpu, mutations)
    }
  }

  func test_ld_a_ffnnaddr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(.a, .ffimm8addr) = spec, let emulator = LR35902.Emulation.ld_a_ffnnaddr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 3)
      mutations.pc += 1
      mutations.a = 0x12
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0, 0xff12])
      XCTAssertEqual(memory.writes, [])
    }
  }

  func test_ld_ffnnaddr_a() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(.ffimm8addr, .a) = spec, let emulator = LR35902.Emulation.ld_ffnnaddr_a(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.a = 0xab
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 3)
      mutations.pc += 1
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0])
      XCTAssertEqual(memory.writes, [
        .init(byte: 0xab, address: 0xff12)
      ])
    }
  }

  func test_ld_a_nnaddr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(.a, .imm16addr) = spec, let emulator = LR35902.Emulation.ld_a_nnaddr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 4)
      mutations.pc += 2
      mutations.a = 0x12
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0, 1, 0x1212])
      XCTAssertEqual(memory.writes, [])
    }
  }

  func test_ld_nnaddr_a() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(.imm16addr, .a) = spec, let emulator = LR35902.Emulation.ld_nnaddr_a(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.a = 0xab
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      XCTAssertEqual(cycle, 4)
      mutations.pc += 2
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0, 1])
      XCTAssertEqual(memory.writes, [
        .init(byte: 0xab, address: 0x1212)
      ])
    }
  }
}
