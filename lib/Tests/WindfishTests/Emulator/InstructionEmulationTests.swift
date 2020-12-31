import XCTest
@testable import Windfish

class InstructionEmulationTests: XCTestCase {
  func test_00_nop() {
    let cpu = LR35902.zeroed()
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x00]), memory: memory, followControlFlow: true)

    // Expected mutations
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_01_ld_bc_imm16() {
    let cpu = LR35902.zeroed()
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x01], immediate: .imm16(0xabcd)), memory: memory, followControlFlow: true)

    // Expected mutations
    state.b = 0xab
    state.c = 0xcd
    pc += 3

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [
      .bc: .init(sourceLocation: Disassembler.sourceLocation(for: 0, in: 0))
    ])
  }

  func test_02_ld_bcaddr_a() {
    let cpu = LR35902(a: 0x12, b: 0xab, c: 0xcd)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x02]), memory: memory, followControlFlow: true)

    // Expected mutations
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [.init(byte: 0x12, address: 0xabcd)])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_03_inc_bc() {
    let cpu = LR35902.zeroed()
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x03]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.bc += 1
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_03_inc_bc_overflow() {
    let cpu = LR35902(b: 0xff, c: 0xff)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x03]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.bc &+= 1
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_04_inc_b() {
    let cpu = LR35902()
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x04]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.b += 1
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_04_inc_b_overflow() {
    let cpu = LR35902(b: 0xff)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x04]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.b &+= 1
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_05_dec_b() {
    let cpu = LR35902(b: 0xff)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x05]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.b -= 1
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_05_dec_b_underflow() {
    let cpu = LR35902(b: 0x00)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x05]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.b &-= 1
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_06_ld_b_imm8() {
    let cpu = LR35902()
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x06], immediate: .imm8(0xab)), memory: memory, followControlFlow: true)

    // Expected mutations
    state.b = 0xab
    pc += 2

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [
      .b: .init(sourceLocation: Disassembler.sourceLocation(for: 0, in: 0))
    ])
  }

  func test_07_rlca_0000_0000() {
    let cpu = LR35902(fzero: false, fsubtract: true, fhalfcarry: true, fcarry: true)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x07]), memory: memory, followControlFlow: true)

    // Expected mutations
    fcarry = false
    a = 0
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_07_rlca_0000_0011() {
    let cpu = LR35902(a: 0b0000_0011, fzero: false, fsubtract: true, fhalfcarry: true, fcarry: true)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x07]), memory: memory, followControlFlow: true)

    // Expected mutations
    fcarry = false
    a = 0b0000_0110
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_07_rlca_1000_0000() {
    let cpu = LR35902(a: 0b1000_0000, fzero: false, fsubtract: true, fhalfcarry: true, fcarry: false)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x07]), memory: memory, followControlFlow: true)

    // Expected mutations
    fcarry = true
    a = 0b0000_0001
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_08_ld_imm16addr_sp() {
    let cpu = LR35902(sp: 0xabcd)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x08], immediate: .imm16(0x1234)), memory: memory, followControlFlow: true)

    // Expected mutations
    pc += 3

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [
      .init(byte: 0xcd, address: 0x1234),
      .init(byte: 0xab, address: 0x1235)
    ])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_09_add_hl_bc() {
    let cpu = LR35902(fzero: true, fsubtract: true, fhalfcarry: true, fcarry: true)
    cpu.bc = 0b1111_0000
    cpu.hl = 0b0000_1111
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x09]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.hl = 0b1111_1111
    fcarry = false
    fhalfcarry = false
    fsubtract = false
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_09_add_hl_bc_low_to_high_overflow() {
    let cpu = LR35902(fzero: true, fsubtract: true, fhalfcarry: true, fcarry: true)
    cpu.bc = 0b0000_0000_0000_0001
    cpu.hl = 0b0000_0000_1111_1111
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x09]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.hl = 0b0000_0001_0000_0000
    fcarry = false
    fhalfcarry = false
    fsubtract = false
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_09_add_hl_bc_overflow() {
    let cpu = LR35902(fzero: true, fsubtract: true, fhalfcarry: false, fcarry: false)
    cpu.bc = 1
    cpu.hl = 0xffff
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x09]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.hl = 0b0000_0000_0000_0000
    fcarry = true
    fhalfcarry = true
    fsubtract = false
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_09_add_hl_bc_low_to_high_halfcarry() {
    let cpu = LR35902(fzero: true, fsubtract: true, fhalfcarry: false, fcarry: true)
    cpu.bc = 0b0000_0000_0000_0001
    cpu.hl = 0b0000_1111_1111_1111
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x09]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.hl = 0b0001_0000_0000_0000
    fcarry = false
    fhalfcarry = true
    fsubtract = false
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_0A_ld_a_bcaddr() {
    let cpu = LR35902(b: 0x12, c: 0x34)
    var state = cpu
    let memory = TestMemory(defaultReadValue: 0xab)
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x0A]), memory: memory, followControlFlow: true)

    // Expected mutations
    a = 0xab
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [0x1234])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [
      .a: .init(sourceLocation: Disassembler.sourceLocation(for: 0, in: 0), loadAddress: 0x1234)
    ])
  }

  func test_0B_dec_bc() {
    let cpu = LR35902.zeroed()
    cpu.bc = 0x0001
    var state = cpu
    let memory = TestMemory(defaultReadValue: 0xab)
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x0B]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.bc = 0x0000
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_0B_dec_bc_underflow() {
    let cpu = LR35902.zeroed()
    cpu.bc = 0x0000
    var state = cpu
    let memory = TestMemory(defaultReadValue: 0xab)
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0x0B]), memory: memory, followControlFlow: true)

    // Expected mutations
    state.bc = 0xFFFF
    pc += 1

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_C3_jp_imm16() {
    let cpu = LR35902.zeroed()
    var state = cpu
    let memory = TestMemory(defaultReadValue: 0xab)
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xC3], immediate: .imm16(0xabcd)), memory: memory, followControlFlow: true)

    // Expected mutations
    pc = 0xabcd

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_CD_call_imm16() {
    let cpu = LR35902(sp: 0xFFFD, pc: 0x0100)
    var state = cpu
    let memory = TestMemory(defaultReadValue: 0xab)
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xCD], immediate: .imm16(0xabcd)), memory: memory, followControlFlow: true)

    // Expected mutations
    pc = 0xabcd
    state.sp -= 2

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [
      .init(byte: 0x01, address: 0xFFFC),
      .init(byte: 0x00, address: 0xFFFB)
    ])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_E0_ld_ffimm8addr_a() {
    let cpu = LR35902(a: 0x12)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xE0], immediate: .imm8(0xab)), memory: memory, followControlFlow: true)

    // Expected mutations
    pc += 2

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [
      .init(byte: 0x12, address: 0xffab)
    ])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_F0_ld_a_ffimm8addr() {
    let cpu = LR35902()
    var state = cpu
    let memory = TestMemory(defaultReadValue: 0x12)
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xF0], immediate: .imm8(0xab)), memory: memory, followControlFlow: true)

    // Expected mutations
    a = 0x12
    pc += 2

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [0xffab])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [
      .a: .init(sourceLocation: Disassembler.sourceLocation(for: 0, in: 0), loadAddress: 0xffab)
    ])
  }

  func test_FE_cp_imm8_equal() {
    let cpu = LR35902(a: 0xab, fzero: false, fsubtract: false, fhalfcarry: true, fcarry: true)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xFE], immediate: .imm8(0xab)), memory: memory, followControlFlow: true)

    // Expected mutations
    state.fzero = true
    fsubtract = true
    fhalfcarry = false
    fcarry = false
    pc += 2

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_FE_cp_imm8_greater() {
    let cpu = LR35902(a: 0xac, fzero: true, fsubtract: false, fhalfcarry: true, fcarry: true)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xFE], immediate: .imm8(0xab)), memory: memory, followControlFlow: true)

    // Expected mutations
    state.fzero = false
    fsubtract = true
    fhalfcarry = false
    fcarry = false
    pc += 2

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_FE_cp_imm8_less() {
    let cpu = LR35902(a: 0b0000_0001, fzero: true, fsubtract: false, fhalfcarry: false, fcarry: false)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xFE], immediate: .imm8(0b0000_0010)), memory: memory, followControlFlow: true)

    // Expected mutations
    state.fzero = false
    fsubtract = true
    fhalfcarry = true
    fcarry = true
    pc += 2

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }

  func test_FE_cp_imm8_less_high() {
    let cpu = LR35902(a: 0b0010_0000, fzero: true, fsubtract: false, fhalfcarry: true, fcarry: false)
    var state = cpu
    let memory = TestMemory()
    cpu.emulate(instruction: .init(spec: LR35902.InstructionSet.table[0xFE], immediate: .imm8(0b0011_0000)), memory: memory, followControlFlow: true)

    // Expected mutations
    state.fzero = false
    fsubtract = true
    fhalfcarry = false
    fcarry = true
    pc += 2

    assertEqual(cpu, state)
    XCTAssertEqual(memory.reads, [])
    XCTAssertEqual(memory.writes, [])
    XCTAssertEqual(cpu.registerTraces, [:])
  }
}
