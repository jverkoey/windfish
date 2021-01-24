import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  func test_jp_nn() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .jp(let cnd, .imm16) = spec, cnd == nil,
            let emulator = LR35902.Emulation.jp_cnd_nn(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      mutations.pc = 0x1212
      assertEqual(cpu, mutations, message: "Test case: \(name)")
    }
  }

  func test_jp_hl() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .jp(nil, .hl) = spec, let emulator = LR35902.Emulation.jp_hl(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.hl = 0x1234
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      mutations.pc = 0x1234
      assertEqual(cpu, mutations, message: "Test case: \(name)")
    }
  }
}

