import XCTest
@testable import Windfish

class LR35902Tests: XCTestCase {

  // MARK: - 8-bit initialization

  func test_initializes_a() throws {
    let cpu = LR35902.zeroed()
    cpu.a = 1
    assertEqual(cpu, LR35902(a: 1))
  }

  func test_initializes_b() throws {
    let cpu = LR35902.zeroed()
    cpu.b = 1
    assertEqual(cpu, LR35902(b: 1))
  }

  func test_initializes_c() throws {
    let cpu = LR35902.zeroed()
    cpu.c = 1
    assertEqual(cpu, LR35902(c: 1))
  }

  func test_initializes_d() throws {
    let cpu = LR35902.zeroed()
    cpu.d = 1
    assertEqual(cpu, LR35902(d: 1))
  }

  func test_initializes_e() throws {
    let cpu = LR35902.zeroed()
    cpu.e = 1
    assertEqual(cpu, LR35902(e: 1))
  }

  func test_initializes_h() throws {
    let cpu = LR35902.zeroed()
    cpu.h = 1
    assertEqual(cpu, LR35902(h: 1))
  }

  func test_initializes_l() throws {
    let cpu = LR35902.zeroed()
    cpu.l = 1
    assertEqual(cpu, LR35902(l: 1))
  }

  // MARK: - Wide registers

  func test_bc_is_b_and_c() throws {
    let cpu = LR35902(b: 0x01, c: 0x20)
    XCTAssertEqual(cpu.bc, 0x0120)
  }

  func test_de_is_d_and_e() throws {
    let cpu = LR35902(d: 0x01, e: 0x20)
    XCTAssertEqual(cpu.de, 0x0120)
  }

  func test_hl_is_h_and_l() throws {
    let cpu = LR35902(h: 0x01, l: 0x20)
    XCTAssertEqual(cpu.hl, 0x0120)
  }

  // MARK: - 8-bit subscripts

  func test_a_subscript() throws {
    let cpu = LR35902(a: 1)
    XCTAssertEqual(cpu[.a] as UInt8, 1)
  }

  func test_b_subscript() throws {
    let cpu = LR35902(b: 1)
    XCTAssertEqual(cpu[.b] as UInt8, 1)
  }

  func test_c_subscript() throws {
    let cpu = LR35902(c: 1)
    XCTAssertEqual(cpu[.c] as UInt8, 1)
  }

  func test_d_subscript() throws {
    let cpu = LR35902(d: 1)
    XCTAssertEqual(cpu[.d] as UInt8, 1)
  }

  func test_e_subscript() throws {
    let cpu = LR35902(e: 1)
    XCTAssertEqual(cpu[.e] as UInt8, 1)
  }

  func test_h_subscript() throws {
    let cpu = LR35902(h: 1)
    XCTAssertEqual(cpu[.h] as UInt8, 1)
  }

  func test_l_subscript() throws {
    let cpu = LR35902(l: 1)
    XCTAssertEqual(cpu[.l] as UInt8, 1)
  }

  func test_a_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.a] = 1 as UInt8
    XCTAssertEqual(cpu[.a] as UInt8, 1)
  }

  func test_b_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.b] = 1 as UInt8
    XCTAssertEqual(cpu[.b] as UInt8, 1)
  }

  func test_c_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.c] = 1 as UInt8
    XCTAssertEqual(cpu[.c] as UInt8, 1)
  }

  func test_d_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.d] = 1 as UInt8
    XCTAssertEqual(cpu[.d] as UInt8, 1)
  }

  func test_e_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.e] = 1 as UInt8
    XCTAssertEqual(cpu[.e] as UInt8, 1)
  }

  func test_h_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.h] = 1 as UInt8
    XCTAssertEqual(cpu[.h] as UInt8, 1)
  }

  func test_l_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.l] = 1 as UInt8
    XCTAssertEqual(cpu[.l] as UInt8, 1)
  }

  // MARK: - 16-bit subscripts

  func test_bc_subscript() throws {
    let cpu = LR35902(b: 0x01, c: 0x20)
    XCTAssertEqual(cpu[.bc] as UInt16, 0x0120)
  }

  func test_de_subscript() throws {
    let cpu = LR35902(d: 0x01, e: 0x20)
    XCTAssertEqual(cpu[.de] as UInt16, 0x0120)
  }

  func test_hl_subscript() throws {
    let cpu = LR35902(h: 0x01, l: 0x20)
    XCTAssertEqual(cpu[.hl] as UInt16, 0x0120)
  }

  func test_bc_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.bc] = 0x0120 as UInt16
    XCTAssertEqual(cpu[.bc] as UInt16, 0x0120)
  }

  func test_de_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.de] = 0x0120 as UInt16
    XCTAssertEqual(cpu[.de] as UInt16, 0x0120)
  }

  func test_hl_subscript_setter() throws {
    let cpu = LR35902.zeroed()
    cpu[.hl] = 0x0120 as UInt16
    XCTAssertEqual(cpu[.hl] as UInt16, 0x0120)
  }
}
