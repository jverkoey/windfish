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
      "0":   .init(sp: 0,      result: .init(sp: 0xfffe, spaddr: (h: 0xffff, l: 0xfffe))),
      "1":   .init(sp: 1,      result: .init(sp: 0xffff, spaddr: (h: 0,      l: 0xffff))),
      "2":   .init(sp: 2,      result: .init(sp: 0,      spaddr: (h: 1,      l: 0))),
      "max": .init(sp: 0xffff, result: .init(sp: 0xfffd, spaddr: (h: 0xfffe, l: 0xfffd))),
    ]
  }

  func test_call_nn() {
    for (name, testCase) in TestCase.testCases {
      for spec in LR35902.InstructionSet.allSpecs() {
        guard case .call(let cnd, .imm16) = spec, cnd == nil,
              let emulator = LR35902.Emulation.call_cnd_nn(spec: spec) else { continue }
        InstructionEmulatorTests.testedSpecs.insert(spec)
        let memory = TestMemory(defaultReadValue: 0x12)

        let cpu = LR35902.zeroed()
        cpu.sp = testCase.sp
        let mutations = cpu.copy()

        var cycle = 0
        repeat {
          cycle += 1
        } while emulator.advance(cpu: cpu, memory: memory, cycle: cycle, sourceLocation: .memory(0)) == .continueExecution

        XCTAssertEqual(cycle, 6, "Test case: \(name)")
        mutations.pc = 0x1212
        mutations.sp = testCase.result.sp
        assertEqual(cpu, mutations, message: "Test case: \(name)")
        XCTAssertEqual(memory.reads, [0, 1], "Test case: \(name)")
        XCTAssertEqual(memory.writes, [
          .init(byte: 0x00, address: testCase.result.spaddr.h),
          .init(byte: 0x02, address: testCase.result.spaddr.l),
        ], "Test case: \(name)")
      }
    }
  }
}
