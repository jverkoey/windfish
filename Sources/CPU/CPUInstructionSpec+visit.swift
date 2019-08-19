import Cocoa

extension CPUInstructionSpec {
  public func visit(visitor: (Any?, Int?) -> Void) {
    guard let operands = Mirror(reflecting: self).children.first else {
      visitor(nil, nil)
      return
    }
    if let subSpec = operands.value as? Self {
      subSpec.visit(visitor: visitor)
    }
    var index = 0
    for child in Mirror(reflecting: operands.value).children {
      // Any isn't nullable, even though it might represent a null value (e.g. a .jr(nil, .imm8) spec with an
      // optional first argument), so we need to use Optional<Any>.none to represent an optional argument in this case.
      if case Optional<Any>.none = child.value {
        continue
      }
      defer {
        index += 1
      }

      visitor(child.value, index)
    }
  }
}
