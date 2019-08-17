import Foundation

/**
 Enables generic methods to create Foundation integers from bit pattern representations.

 Foundation integer types already implement the bitPattern initializer, but this initializer is
 not exposed via any generic protocols. The result is that it's not possible to initialize a
 Foundation integer in a generic method.
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
