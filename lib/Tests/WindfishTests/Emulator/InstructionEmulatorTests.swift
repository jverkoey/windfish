import XCTest
@testable import Windfish

// References:
// - https://izik1.github.io/gbops/

class InstructionEmulatorTests: XCTestCase {
  static var testedSpecs = Set<LR35902.Instruction.Spec>()
  static var timings: [LR35902.Instruction.Spec: Set<Int>] = [:]

  // 2 specs to go.
  static override func tearDown() {
    let ignoredSpecs = Set<LR35902.Instruction.Spec>([
      .invalid,
      .prefix(.cb)
    ])
    let remainingSpecs = LR35902.InstructionSet.allSpecs().filter { !testedSpecs.contains($0) && !ignoredSpecs.contains($0) }
    print("\(remainingSpecs.count) specs remaining to test")
    print(remainingSpecs)

    var index: UInt16 = 0
    print(LR35902.InstructionSet.allSpecs().compactMap {
      index += 1
      guard let timings = timings[$0] else { return nil}
      return "\((index - 1).hexString) \(timings.map { "\($0 * 4)" }.joined(separator: ", "))"
    }.joined(separator: "\n"))
  }
}
