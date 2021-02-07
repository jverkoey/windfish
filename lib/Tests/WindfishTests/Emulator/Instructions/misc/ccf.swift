import XCTest

import LR35902
@testable import Windfish

extension InstructionEmulatorTests {
  func test_ccf_true() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ccf(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()
      cpu.fcarry = true
      cpu.fsubtract = true
      cpu.fhalfcarry = true
      let mutations = cpu.copy()
      mutations.fcarry = false
      mutations.fsubtract = false
      mutations.fhalfcarry = false
emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations)
    }
  }

  func test_ccf_false() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ccf(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()
      cpu.fcarry = false
      cpu.fsubtract = true
      cpu.fhalfcarry = true
      let mutations = cpu.copy()
      mutations.fcarry = true
      mutations.fsubtract = false
      mutations.fhalfcarry = false
emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations)
    }
  }
}
