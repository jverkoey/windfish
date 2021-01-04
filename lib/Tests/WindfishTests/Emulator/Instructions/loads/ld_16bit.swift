import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_ld_nnaddr_sp() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ld_nnaddr_sp(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.sp = 0xabcd
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
      XCTAssertEqual(cycle, 5)
      mutations.pc += 2
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0, 1], "\(spec)")
      XCTAssertEqual(memory.writes, [
        .init(byte: 0xcd, address: 0x1212),
        .init(byte: 0xab, address: 0x1213),
      ])
    }
  }

  func test_ld_rr_nn() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(let dst, .imm16) = spec, let emulator = LR35902.Emulation.ld_rr_nn(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
      XCTAssertEqual(cycle, 3)
      mutations.pc += 2
      mutations[dst] = 0x1212 as UInt16
      assertEqual(cpu, mutations)
    }
  }

  func test_ld_sp_hl() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ld_sp_hl(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()
      cpu.hl = 0x1234
      let mutations = cpu.copy()
      mutations.sp = 0x1234

      var cycle = 0
      repeat {
        cycle += 1
      } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

      InstructionEmulatorTests.timings[spec, default: Set()].insert(cycle)
      XCTAssertEqual(cycle, 2)
      assertEqual(cpu, mutations)
    }
  }
}
