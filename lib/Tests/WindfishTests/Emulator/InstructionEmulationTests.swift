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
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x00]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_ld_bc_imm16() {
    var cpu = LR35902.zeroed()
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x01], immediate: .imm16(0xabcd)), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b = 0xab
    cpu.c = 0xcd
    cpu.pc += 3

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_ld_bcaddr_a() {
    var cpu = LR35902(a: 0x12, b: 0xab, c: 0xcd)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x02]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [.init(byte: 0x12, address: 0xabcd)])
  }

  func test_inc_bc() {
    var cpu = LR35902.zeroed()
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x03]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.bc += 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_inc_bc_overflow() {
    var cpu = LR35902(b: 0xff, c: 0xff)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x03]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.bc &+= 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_inc_b() {
    var cpu = LR35902()
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x04]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b += 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_inc_b_overflow() {
    var cpu = LR35902(b: 0xff)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x04]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b &+= 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_dec_b() {
    var cpu = LR35902(b: 0xff)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x05]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b -= 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_dec_b_underflow() {
    var cpu = LR35902(b: 0x00)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x05]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b &-= 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_ld_b_imm8() {
    var cpu = LR35902()
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x06], immediate: .imm8(0xab)), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b = 0xab
    cpu.pc += 2

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_rlca_0000_0000() {
    var cpu = LR35902(fzero: false, fsubtract: true, fhalfcarry: true, fcarry: true)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x07]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.fcarry = false
    cpu.a = 0
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_rlca_0000_0011() {
    var cpu = LR35902(a: 0b0000_0011, fzero: false, fsubtract: true, fhalfcarry: true, fcarry: true)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x07]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.fcarry = false
    cpu.a = 0b0000_0110
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }

  func test_rlca_1000_0000() {
    var cpu = LR35902(a: 0b1000_0000, fzero: false, fsubtract: true, fhalfcarry: true, fcarry: false)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x07]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.fcarry = true
    cpu.a = 0b0000_0001
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
  }
}
