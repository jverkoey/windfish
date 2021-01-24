import XCTest
@testable import Windfish

extension InstructionEmulatorTests {
  private struct TestCase {
    let sp: UInt16
    struct Result {
      let sp: UInt16
      let spaddr: (h: UInt16, l: UInt16)
    }
    let result: Result

    static let testCases: [String: TestCase] = [
      "0":   .init(sp: 0,      result: .init(sp: 2, spaddr: (h: 1, l: 0))),
      "1":   .init(sp: 1,      result: .init(sp: 3, spaddr: (h: 2, l: 1))),
      "max": .init(sp: 0xffff, result: .init(sp: 1, spaddr: (h: 0, l: 0xffff))),
    ]
  }

  func test_ret() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .ret(nil) = spec, let emulator = LR35902.Emulation.ret(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: 0x12)

        let cpu = LR35902.zeroed()
        cpu.sp = testCase.sp
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.pc = 0x1212
        mutations.sp = testCase.result.sp
        assertEqual(cpu, mutations, message: "Test case: \(name)")
        XCTAssertEqual(memory.reads, [testCase.result.spaddr.l, testCase.result.spaddr.h], "Test case: \(name)")
        XCTAssertEqual(memory.writes, [], "Test case: \(name)")
      }
    }
  }

  func test_reti() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .reti = spec, let emulator = LR35902.Emulation.reti(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: 0x12)

        let cpu = LR35902.zeroed()
        cpu.sp = testCase.sp
        cpu.ime = false
        let mutations = cpu.copy()

        emulator.emulate(cpu: cpu, memory: memory, sourceLocation: .memory(0))

        mutations.pc = 0x1212
        mutations.sp = testCase.result.sp
        mutations.ime = true
        assertEqual(cpu, mutations, message: "Test case: \(name)")
        XCTAssertEqual(memory.reads, [testCase.result.spaddr.l, testCase.result.spaddr.h], "Test case: \(name)")
        XCTAssertEqual(memory.writes, [], "Test case: \(name)")
      }
    }
  }
}
