import Cocoa

extension InstructionSpec {
  /**
   Invokes a visitor for each operand of the subspec.

   - parameter visitor: Invoked on each operand of the specification.
     The first argument is the operand's value.
     The second argument is the operand's index (ignoring nil operands).
     Optional operands are skipped.
   */
  public func visit(visitor: (Any?, Int?) -> Void) {
    guard let operands = Mirror(reflecting: self).children.first else {
      visitor(nil, nil)
      return
    }
    if let subSpec = operands.value as? Self {
      subSpec.visit(visitor: visitor)
      return
    }
    let children: Mirror.Children
    let reflectedChildren = Mirror(reflecting: operands.value).children
    if reflectedChildren.count > 0 {
      children = reflectedChildren
    } else {
      children = Mirror.Children([(label: nil, value: operands.value)])
    }
    var index = 0
    for child in children {
      // Any isn't nullable, even though it might represent a null value (e.g. a .jr(nil, .imm8) spec with an
      // optional first argument), so we need to use Optional<Any>.none to represent an optional argument in this case.
      if case Optional<Any>.none = child.value {
        continue
      }
      visitor(child.value, index)
      index += 1
    }
  }
}
