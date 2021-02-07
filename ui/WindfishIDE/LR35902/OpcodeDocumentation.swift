import Foundation

import LR35902
import Windfish

// Docs sourced from http://marc.rawer.de/Gameboy/Docs/GBCPUman.pdf
let opcodeDocumentation: [LR35902.Instruction.Spec: String] = [
  .call(nil, .imm16): "Push address of next instruction onto stack and then jump to address represented by immediate.",
  .rrca: """
Rotate A right. Old bit 0 to Carry flag.

Flags affected:
 Z - Set if result is zero.
 N - Reset.
 H - Reset.
 C - Contains old bit 0 data.
"""
]
