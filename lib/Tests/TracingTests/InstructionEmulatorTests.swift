import XCTest

import FoundationExtensions
import LR35902
import Tracing

// References:
// - https://izik1.github.io/gbops/

/** Asserts that two CPU states are equal. */
func assertEqual(_ state1: LR35902, _ state2: LR35902, message: String = "", file: StaticString = #file, line: UInt = #line) {
  XCTAssertEqual(state1.a?.hexString, state2.a?.hexString,      "a mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.b?.hexString, state2.b?.hexString,      "b mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.c?.hexString, state2.c?.hexString,      "c mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.d?.hexString, state2.d?.hexString,      "d mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.e?.hexString, state2.e?.hexString,      "e mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.h?.hexString, state2.h?.hexString,      "h mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.l?.hexString, state2.l?.hexString,      "l mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.fzero, state2.fzero,                    "fzero mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.fsubtract, state2.fsubtract,            "fsubtract mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.fhalfcarry, state2.fhalfcarry,          "fhalfcarry mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.fcarry, state2.fcarry,                  "fcarry mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.sp?.hexString, state2.sp?.hexString,    "sp mismatch \(message)", file: file, line: line)
  XCTAssertEqual(state1.pc.hexString, state2.pc.hexString,      "pc mismatch \(message)", file: file, line: line)
}

class InstructionEmulatorTests: XCTestCase {
  static var testedSpecs = Set<LR35902.Instruction.Spec>()

  static override func tearDown() {
    let ignoredSpecs = Set<LR35902.Instruction.Spec>([
      .invalid,
      .prefix(.cb)
    ])
    let remainingSpecs = LR35902.InstructionSet.allSpecs().filter { !testedSpecs.contains($0) && !ignoredSpecs.contains($0) }
    print("\(remainingSpecs.count) specs remaining to test")
    print(remainingSpecs)
  }
}
