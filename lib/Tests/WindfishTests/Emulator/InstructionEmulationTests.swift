import XCTest
@testable import Windfish

class InstructionEmulationTests: XCTestCase {
  func test_00_nop() {
    var cpu = LR35902.zeroed()
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x00]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_01_ld_bc_imm16() {
    let initialCpu = LR35902.zeroed()
    var cpu = initialCpu
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x01], immediate: .imm16(0xabcd)), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b = 0xab
    cpu.c = 0xcd
    cpu.pc += 3

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [
      .bc: .init(sourceLocation: Gameboy.Cartridge.location(for: initialCpu.pc, in: initialCpu.bank)!)
    ])
  }

  func test_02_ld_bcaddr_a() {
    var cpu = LR35902(a: 0x12, b: 0xab, c: 0xcd)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x02]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [.init(byte: 0x12, address: 0xabcd)])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_03_inc_bc() {
    var cpu = LR35902.zeroed()
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x03]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.bc += 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_03_inc_bc_overflow() {
    var cpu = LR35902(b: 0xff, c: 0xff)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x03]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.bc &+= 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_04_inc_b() {
    var cpu = LR35902()
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x04]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b += 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_04_inc_b_overflow() {
    var cpu = LR35902(b: 0xff)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x04]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b &+= 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_05_dec_b() {
    var cpu = LR35902(b: 0xff)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x05]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b -= 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_05_dec_b_underflow() {
    var cpu = LR35902(b: 0x00)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x05]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b &-= 1
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_06_ld_b_imm8() {
    let initialCpu = LR35902()
    var cpu = initialCpu
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x06], immediate: .imm8(0xab)), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.b = 0xab
    cpu.pc += 2

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [
      .b: .init(sourceLocation: Gameboy.Cartridge.location(for: initialCpu.pc, in: initialCpu.bank)!)
    ])
  }

  func test_07_rlca_0000_0000() {
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
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_07_rlca_0000_0011() {
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
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_07_rlca_1000_0000() {
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
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_08_ld_imm16addr_sp() {
    var cpu = LR35902(sp: 0xabcd)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x08], immediate: .imm16(0x1234)), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.pc += 3

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [
      .init(byte: 0xcd, address: 0x1234),
      .init(byte: 0xab, address: 0x1235)
    ])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_09_add_hl_bc() {
    var cpu = LR35902(fzero: true, fsubtract: true, fhalfcarry: true, fcarry: true)
    cpu.bc = 0b1111_0000
    cpu.hl = 0b0000_1111
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x09]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.hl = 0b1111_1111
    cpu.fcarry = false
    cpu.fhalfcarry = false
    cpu.fsubtract = false
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_09_add_hl_bc_low_to_high_overflow() {
    var cpu = LR35902(fzero: true, fsubtract: true, fhalfcarry: true, fcarry: true)
    cpu.bc = 0b0000_0000_0000_0001
    cpu.hl = 0b0000_0000_1111_1111
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x09]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.hl = 0b0000_0001_0000_0000
    cpu.fcarry = false
    cpu.fhalfcarry = false
    cpu.fsubtract = false
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_09_add_hl_bc_overflow() {
    var cpu = LR35902(fzero: true, fsubtract: true, fhalfcarry: false, fcarry: false)
    cpu.bc = 1
    cpu.hl = 0xffff
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x09]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.hl = 0b0000_0000_0000_0000
    cpu.fcarry = true
    cpu.fhalfcarry = true
    cpu.fsubtract = false
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_09_add_hl_bc_low_to_high_halfcarry() {
    var cpu = LR35902(fzero: true, fsubtract: true, fhalfcarry: false, fcarry: true)
    cpu.bc = 0b0000_0000_0000_0001
    cpu.hl = 0b0000_1111_1111_1111
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x09]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.hl = 0b0001_0000_0000_0000
    cpu.fcarry = false
    cpu.fhalfcarry = true
    cpu.fsubtract = false
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_0A_ld_a_bcaddr() {
    let initialCpu = LR35902(b: 0x12, c: 0x34)
    var cpu = initialCpu
    var memory: AddressableMemory = TestMemory(defaultReadValue: 0xab)
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x0A]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.a = 0xab
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [0x1234])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [
      .a: .init(sourceLocation: Gameboy.Cartridge.location(for: initialCpu.pc, in: initialCpu.bank)!, loadAddress: 0x1234)
    ])
  }

  func test_0B_dec_bc() {
    var cpu = LR35902.zeroed()
    cpu.bc = 0x0001
    var memory: AddressableMemory = TestMemory(defaultReadValue: 0xab)
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x0B]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.bc = 0x0000
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_0B_dec_bc_underflow() {
    var cpu = LR35902.zeroed()
    cpu.bc = 0x0000
    var memory: AddressableMemory = TestMemory(defaultReadValue: 0xab)
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x0B]), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.bc = 0xFFFF
    cpu.pc += 1

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_C3_jp_imm16() {
    var cpu = LR35902.zeroed()
    var memory: AddressableMemory = TestMemory(defaultReadValue: 0xab)
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xC3], immediate: .imm16(0xabcd)), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.pc = 0xabcd

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_CD_call_imm16() {
    var cpu = LR35902(sp: 0xFFFD, pc: 0x0100)
    var memory: AddressableMemory = TestMemory(defaultReadValue: 0xab)
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xCD], immediate: .imm16(0xabcd)), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.pc = 0xabcd
    cpu.sp -= 2

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [
      .init(byte: 0x01, address: 0xFFFC),
      .init(byte: 0x00, address: 0xFFFB)
    ])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_E0_ld_ffimm8addr_a() {
    var cpu = LR35902(a: 0x12)
    var memory: AddressableMemory = TestMemory()
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xE0], immediate: .imm8(0xab)), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.pc += 2

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [])
    XCTAssertEqual((memory as! TestMemory).writes, [
      .init(byte: 0x12, address: 0xffab)
    ])
    XCTAssertEqual(mutatedCpu.registerTraces, [:])
  }

  func test_F0_ld_a_ffimm8addr() {
    let initialCpu = LR35902()
    var cpu = initialCpu
    var memory: AddressableMemory = TestMemory(defaultReadValue: 0x12)
    let mutatedCpu = cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xF0], immediate: .imm8(0xab)), memory: &memory, followControlFlow: true)

    // Expected mutations
    cpu.a = 0x12
    cpu.pc += 2

    assertEqual(cpu, mutatedCpu)
    XCTAssertEqual((memory as! TestMemory).readMonitor.reads, [0xffab])
    XCTAssertEqual((memory as! TestMemory).writes, [])
    XCTAssertEqual(mutatedCpu.registerTraces, [
      .a: .init(sourceLocation: Gameboy.Cartridge.location(for: initialCpu.pc, in: initialCpu.bank)!, loadAddress: 0xffab)
    ])
  }
}
