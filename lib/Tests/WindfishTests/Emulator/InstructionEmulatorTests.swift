import XCTest
@testable import Windfish

// References:
// - https://izik1.github.io/gbops/

class InstructionEmulatorTests: XCTestCase {
  static var testedSpecs = Set<LR35902.Instruction.Spec>()

  // 2 specs to go.
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
