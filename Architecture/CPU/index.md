# Windfish CPU

The `CPU` module defines a protocol-based representation of a CPU's instruction set that can be used to translate between binary and semantic representations of instructions.

<p align="center">
  <img title="Interchange between binary and semantic representations" width="222" height="149" src="../diagrams/interchange.png">
</p>

## Introduction

Every instruction in a CPU's instruction set has a unique binary footprint.
This footprint represents one or more bytes in memory starting with the instruction's **opcode** and ending with the instruction's **immediate**, if the opcode requires one.

Each byte of the opcode corresponds to a location in a lookup table describing the intended shape and behavior of the instruction.
[See an example of a lookup table for the Gameboy CPU](https://www.pastraiser.com/cpu/gameboy/gameboy_opcodes.html).

Many instructions have an immediate.
An immediate is one or more bytes of additional information that can augment the behavior of the instruction.
For example, the Gameboy CPU opcode `$E0` corresponds to an instruction of the form `LD [$FF00+(a8)], a` which requires an 8-bit (one byte) immediate.
This means that `$E0 $89` is represented as `ld [$FF89], a` in assembly.

> Note: when an instruction is written in assembly form, each comma-separated value after the opcode is called an *operand*.
> Some operands are implicit in the opcode's instruction definition, while others come from the immediate.

<p align="center">
  <img title="Representation of an instruction's opcode and operands" width="147" height="64" src="../diagrams/opcode_operands.png">
</p>

## Overview

The `CPU` module represents instruction sets using three important types:

- `InstructionSpec`: describes a specific instruction's binary footprint.
- `InstructionSet`: translates a series of opcode bytes into an `InstructionSpec`.
- `Instruction`: represents a CPU instruction as an `InstructionSpec` and the value of its immediate, if it has one.

## Topics

- [How to represent an instruction set](how_to_represent_an_instruction_set.md)
- [Visiting operands](visiting_operands.md)
- [Cookbook](cookbook.md)
