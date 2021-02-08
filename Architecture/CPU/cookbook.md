# Cookbook

Provided below is a cookbook of common workflows for the `CPU` module.

#### Disassembling instructions from data

```swift
let data = Data([0x01, 0xAB])
let instruction: Instruction = Instruction.from(data)
```

#### Assembling instructions to data

```swift
let data: Data = instruction.asData()
```

#### Getting the width of an instruction's opcode

```swift
let width: Int = InstructionSet.widths[.ld(.a, .imm8)].opcode
```

#### Getting the width of an instruction's immediate

```swift
let width: Int = InstructionSet.widths[.ld(.a, .imm8)].immediate
```

#### Getting the string representation of an opcode

```swift
let opcode: String = InstructionSet.opcodeStrings[.ld(.a, .imm8)]
```

#### Getting the byte representation of an opcode

```swift
let opcode: String = InstructionSet.opcodeBytes[.ld(.a, .imm8)]
```
