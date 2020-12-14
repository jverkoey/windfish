import XCTest
@testable import LR35902

class CPUStateTests: XCTestCase {

  // MARK: - Initialization

  func test_initializes_a() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.a = .init(value: .literal(1), sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(a: 1))
  }

  func test_initializes_b() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.b = .init(value: .literal(1), sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(b: 1))
  }

  func test_initializes_c() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.c = .init(value: .literal(1), sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(c: 1))
  }

  func test_initializes_d() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.d = .init(value: .literal(1), sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(d: 1))
  }

  func test_initializes_e() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.e = .init(value: .literal(1), sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(e: 1))
  }

  func test_initializes_h() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.h = .init(value: .literal(1), sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(h: 1))
  }

  func test_initializes_l() throws {
    var mutatedState = LR35902.CPUState()
    mutatedState.l = .init(value: .literal(1), sourceLocation: 0)
    assertEqual(mutatedState, LR35902.CPUState(l: 1))
  }

  // MARK: - Wide registers

  func test_bc_is_b_and_c() throws {
    let state = LR35902.CPUState(b: 0x01, c: 0x20)
    XCTAssertEqual(state.bc, LR35902.CPUState.RegisterState<UInt16>(value: .literal(0x0120), sourceLocation: 0))
  }

  func test_de_is_d_and_e() throws {
    let state = LR35902.CPUState(d: 0x01, e: 0x20)
    XCTAssertEqual(state.de, LR35902.CPUState.RegisterState<UInt16>(value: .literal(0x0120), sourceLocation: 0))
  }

  func test_hl_is_h_and_l() throws {
    let state = LR35902.CPUState(h: 0x01, l: 0x20)
    XCTAssertEqual(state.hl, LR35902.CPUState.RegisterState<UInt16>(value: .literal(0x0120), sourceLocation: 0))
  }
}
