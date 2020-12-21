import XCTest
@testable import Windfish

/** Circumvent immutability of the TestMemory struct by tracking reads in a class instance. */
private class MemoryReadTracer {
  var reads: [LR35902.Address] = []
}

private struct TestMemory: AddressableMemory {
  func read(from address: LR35902.Address) -> UInt8 {
    readMonitor.reads.append(address)
    return defaultReadValue
  }

  mutating func write(_ byte: UInt8, to address: LR35902.Address) {
    writes.append(WriteOp(byte: byte, address: address))
  }

  var defaultReadValue: UInt8 = 0x00
  var readMonitor = MemoryReadTracer()
  struct WriteOp: Equatable {
    let byte: UInt8
    let address: LR35902.Address
  }
  var writes: [WriteOp] = []
}

class InstructionEmulationTests: XCTestCase {
  func test_nop() {
    var cpu = LR35902.zeroed()
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: .nop), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }
}
