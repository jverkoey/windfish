import Foundation

/**
 Enables generic methods to create Foundation integers from bit pattern representations.

 Foundation integer types already implement the bitPattern initializer, but this initializer is
 not exposed via any generic protocols. This protocol exposes the fact that those initializers
 exist on Foundation types.
 */
protocol BitPatternInitializable {
  associatedtype CompanionType
  init(bitPattern x: CompanionType)
}

extension UInt16: BitPatternInitializable {
  typealias CompanionType = Int16
}

extension UInt8: BitPatternInitializable {
  typealias CompanionType = Int8
}
