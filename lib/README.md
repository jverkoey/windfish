# Windfish disassembler

The Windfish disassembler is written in Swift. It relies heavily on Swift language features to provide a disassembly library that is
both flexible and expressive.

## The CPU

At its core, Windfish defines an protocol-based representation of a CPU and the instructions it is able to execute.

Implementing a CPU starts by implementing the `InstructionSpec` protocol, typically as an enum. The `InstructionSpec` type both defines the potential shape of an instruction and the assembly language names of the instructions. In the example below, we define an instruction specification that is able to represent four different types of operations, most accepting one or more operands:

```swift
enum Spec: CPU.InstructionSpec {
  typealias WidthType = UInt16

  case nop
  case cp(Numeric)
  case ld(Numeric, Numeric)
  case call(Condition? = nil, Numeric)

  enum Numeric: Hashable {
    case imm8
    case imm16
    case a
    case arg(Int)
  }

  enum Condition: Hashable {
    case nz
    case z
  }
}
```
