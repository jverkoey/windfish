import XCTest
@testable import LR35902

class CPUStateTests: XCTestCase {

  // MARK: - 8-bit initialization

  func test_initializes_a() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.a = .init(value: 1, sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(a: 1))
  }

  func test_initializes_b() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.b = .init(value: 1, sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(b: 1))
  }

  func test_initializes_c() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.c = .init(value: 1, sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(c: 1))
  }

  func test_initializes_d() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.d = .init(value: 1, sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(d: 1))
  }

  func test_initializes_e() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.e = .init(value: 1, sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(e: 1))
  }

  func test_initializes_h() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.h = .init(value: 1, sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(h: 1))
  }

  func test_initializes_l() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.l = .init(value: 1, sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(l: 1))
  }

  // MARK: - Wide registers

  func test_bc_is_b_and_c() throws {
    let state = LR35902.CPUState(b: 0x01, c: 0x20)
    XCTAssertEqual(state.bc, LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0))
  }

  func test_de_is_d_and_e() throws {
    let state = LR35902.CPUState(d: 0x01, e: 0x20)
    XCTAssertEqual(state.de, LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0))
  }

  func test_hl_is_h_and_l() throws {
    let state = LR35902.CPUState(h: 0x01, l: 0x20)
    XCTAssertEqual(state.hl, LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0))
  }

  // MARK: - 8-bit subscripts

  func test_a_subscript() throws {
    let state = LR35902.CPUState(a: 1)
    XCTAssertEqual(state[.a], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_b_subscript() throws {
    let state = LR35902.CPUState(b: 1)
    XCTAssertEqual(state[.b], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_c_subscript() throws {
    let state = LR35902.CPUState(c: 1)
    XCTAssertEqual(state[.c], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_d_subscript() throws {
    let state = LR35902.CPUState(d: 1)
    XCTAssertEqual(state[.d], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_e_subscript() throws {
    let state = LR35902.CPUState(e: 1)
    XCTAssertEqual(state[.e], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_h_subscript() throws {
    let state = LR35902.CPUState(h: 1)
    XCTAssertEqual(state[.h], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_l_subscript() throws {
    let state = LR35902.CPUState(l: 1)
    XCTAssertEqual(state[.l], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_a_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.a] = LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0)
    XCTAssertEqual(state[.a], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_b_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.b] = LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0)
    XCTAssertEqual(state[.b], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_c_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.c] = LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0)
    XCTAssertEqual(state[.c], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_d_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.d] = LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0)
    XCTAssertEqual(state[.d], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_e_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.e] = LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0)
    XCTAssertEqual(state[.e], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_h_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.h] = LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0)
    XCTAssertEqual(state[.h], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  func test_l_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.l] = LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0)
    XCTAssertEqual(state[.l], LR35902.CPUState.RegisterState<UInt8>(value: 1, sourceLocation: 0))
  }

  // MARK: - 16-bit subscripts

  func test_bc_subscript() throws {
    let state = LR35902.CPUState(b: 0x01, c: 0x20)
    XCTAssertEqual(state[.bc], LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0))
  }

  func test_de_subscript() throws {
    let state = LR35902.CPUState(d: 0x01, e: 0x20)
    XCTAssertEqual(state[.de], LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0))
  }

  func test_hl_subscript() throws {
    let state = LR35902.CPUState(h: 0x01, l: 0x20)
    XCTAssertEqual(state[.hl], LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0))
  }

  func test_bc_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.bc] = LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0)
    XCTAssertEqual(state[.bc], LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0))
  }

  func test_de_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.de] = LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0)
    XCTAssertEqual(state[.de], LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0))
  }

  func test_hl_subscript_setter() throws {
    var state = LR35902.CPUState()
    state[.hl] = LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0)
    XCTAssertEqual(state[.hl], LR35902.CPUState.RegisterState<UInt16>(value: 0x0120, sourceLocation: 0))
  }
}
