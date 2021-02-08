# Visiting operands

The `CPU` module provides a mechanism for iterating over an `Instruction` type's operands.
This mechanism is used in a variety of contexts including:

- Computing an instruction specification's immediate width.
- Tokenizing instruction RGBDS statements for macro tree traversal.
- Validating operands from RGBDS assembly statements.

## Example

Let's look at how we automatically compute the width of an instruction specification's immediate using `visit`:

```swift
var immediateWidth: AddressType {
  var width: AddressType = 0
  try? visit { operand, shouldStop in
    guard let numeric = operand?.value as? ImmediateOperand,
          numeric.width > 0 else {
      return
    }
    width = AddressType(numeric.width)
    shouldStop = true
  }
  return width
}
```

Note how we add up the width of all operands in order to compute the width of the immediate for this specification.
This approach makes the assumption that there is only one immediate value per instruction.
If an instruction could have more than operand with a non-zero width then a different approach would need to be used to compute the immediate width.
