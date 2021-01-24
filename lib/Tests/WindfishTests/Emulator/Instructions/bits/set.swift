import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let value: UInt8
    struct Result {
      let value: [LR35902.Instruction.Bit: UInt8]
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "zero": .init(value: 0,    result: .init(value: [.b0: 0x01, .b1: 0x02, .b2: 0x04, .b3: 0x08, .b4: 0x10, .b5: 0x20, .b6: 0x40, .b7: 0x80])),
      "all":  .init(value: 0xff, result: .init(value: [.b0: 0xff, .b1: 0xff, .b2: 0xff, .b3: 0xff, .b4: 0xff, .b5: 0xff, .b6: 0xff, .b7: 0xff])),
    ]
  }

  func test_set_b_r() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .cb(.set(let bit, let register)) = spec,
              let emulator = LR35902.Emulation.set_b_r(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory()
        let cpu = LR35902.zeroed()
        cpu[register] = testCase.value
        cpu.fhalfcarry = false
        cpu.fsubtract = true
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations[register] = testCase.result.value[bit]!
        assertEqual(cpu, mutations, message: "Test case: \(name) \(bit)")
      }
    }
  }

  func test_set_b_hladdr() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .cb(.set(let bit, .hladdr)) = spec,
              let emulator = LR35902.Emulation.set_b_hladdr(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: testCase.value)
        let cpu = LR35902.zeroed()
        cpu.fhalfcarry = false
        cpu.fsubtract = true
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        XCTAssertEqual(memory.writes, [
          .init(byte: testCase.result.value[bit]!, address: 0)
        ])
        assertEqual(cpu, mutations, message: "Test case: \(name) \(bit)")
      }
    }
  }
}
