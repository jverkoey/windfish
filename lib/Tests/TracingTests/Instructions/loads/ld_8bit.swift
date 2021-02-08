import XCTest

import LR35902
@testable import Tracing

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
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      mutations[dst] = mutations[src] as UInt8?
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
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      mutations.pc += 1
      mutations[dst] = 0x12 as UInt8
      assertEqual(cpu, mutations)
    }
  }

  func test_ld_a_ffnnaddr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ld_a_ffnnaddr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      mutations.pc += 1
      mutations.a = 0x12
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0, 0xff12])
      XCTAssertEqual(memory.writes, [])
    }
  }

  func test_ld_ffnnaddr_a() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ld_ffnnaddr_a(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.a = 0xab
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

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
      guard let emulator = LR35902.Emulation.ld_a_nnaddr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      mutations.pc += 2
      mutations.a = 0x12
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0, 1, 0x1212])
      XCTAssertEqual(memory.writes, [])
    }
  }

  func test_ld_nnaddr_a() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ld_nnaddr_a(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.a = 0xab
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      mutations.pc += 2
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0, 1])
      XCTAssertEqual(memory.writes, [
        .init(byte: 0xab, address: 0x1212)
      ])
    }
  }

  func test_ld_r_rraddr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(let dst, let src) = spec, let emulator = LR35902.Emulation.ld_r_rraddr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu[src] = 0xabcd as UInt16
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      mutations[dst] = 0x12 as UInt8
      assertEqual(cpu, mutations)
      XCTAssertEqual(memory.reads, [0xabcd])
      XCTAssertEqual(memory.writes, [])
    }
  }

  func test_ld_rraddr_n() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(let dst, .imm8) = spec,
            let emulator = LR35902.Emulation.ld_rraddr_n(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0xab)

      let cpu = LR35902.zeroed()
      cpu[dst] = 0x4567 as UInt16
      let mutations = cpu.copy()
      mutations.pc += 1
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [0], "\(spec)")
      XCTAssertEqual(memory.writes, [
        .init(byte: 0xab, address: 0x4567)
      ], "\(spec)")
    }
  }

  func test_ld_rraddr_r() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(let dst, let src) = spec, !(dst == .hladdr && (src == .h || src == .l)),
            let emulator = LR35902.Emulation.ld_rraddr_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu[src] = 0xab as UInt8
      cpu[dst] = 0x4567 as UInt16
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [], "\(spec)")
      XCTAssertEqual(memory.writes, [
        .init(byte: 0xab, address: 0x4567)
      ], "\(spec)")
    }
  }

  func test_ld_hladdr_h() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(.hladdr, .h) = spec, let emulator = LR35902.Emulation.ld_rraddr_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.hl = 0x4567
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [], "\(spec)")
      XCTAssertEqual(memory.writes, [
        .init(byte: 0x45, address: 0x4567)
      ], "\(spec)")
    }
  }

  func test_ld_hladdr_l() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard case .ld(.hladdr, .l) = spec, let emulator = LR35902.Emulation.ld_rraddr_r(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.hl = 0x4567
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [], "\(spec)")
      XCTAssertEqual(memory.writes, [
        .init(byte: 0x67, address: 0x4567)
      ], "\(spec)")
    }
  }

  func test_ldd_a_hladdr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ldd_a_hladdr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.hl = 0x4567
      let mutations = cpu.copy()
      mutations.hl = 0x4566
      mutations.a = 0x12
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [0x4567], "\(spec)")
      XCTAssertEqual(memory.writes, [])
    }
  }

  func test_ldd_hladdr_a() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ldd_hladdr_a(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()
      cpu.a = 0x12
      cpu.hl = 0x4567
      let mutations = cpu.copy()
      mutations.hl = 0x4566
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [], "\(spec)")
      XCTAssertEqual(memory.writes, [
        .init(byte: 0x12, address: 0x4567)
      ])
    }
  }

  func test_ldi_a_hladdr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ldi_a_hladdr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.hl = 0x4567
      let mutations = cpu.copy()
      mutations.hl = 0x4568
      mutations.a = 0x12
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [0x4567], "\(spec)")
      XCTAssertEqual(memory.writes, [])
    }
  }

  func test_ldi_hladdr_a() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ldi_hladdr_a(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()
      cpu.a = 0x12
      cpu.hl = 0x4567
      let mutations = cpu.copy()
      mutations.hl = 0x4568
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [], "\(spec)")
      XCTAssertEqual(memory.writes, [
        .init(byte: 0x12, address: 0x4567)
      ])
    }
  }

  func test_ldh_a_ccaddr() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ldh_a_ccaddr(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory(defaultReadValue: 0x12)

      let cpu = LR35902.zeroed()
      cpu.c = 0xab
      let mutations = cpu.copy()
      mutations.a = 0x12
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [0xffab], "\(spec)")
      XCTAssertEqual(memory.writes, [])
    }
  }

  func test_ldh_ccaddr_a() {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard let emulator = LR35902.Emulation.ldh_ccaddr_a(spec: spec) else { continue }
      InstructionEmulatorTests.testedSpecs.insert(spec)
      let memory = TestMemory()

      let cpu = LR35902.zeroed()
      cpu.a = 0x12
      cpu.c = 0xab
      let mutations = cpu.copy()
      emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

      assertEqual(cpu, mutations, message: "\(spec)")
      XCTAssertEqual(memory.reads, [], "\(spec)")
      XCTAssertEqual(memory.writes, [
        .init(byte: 0x12, address: 0xffab)
      ])
    }
  }

}


