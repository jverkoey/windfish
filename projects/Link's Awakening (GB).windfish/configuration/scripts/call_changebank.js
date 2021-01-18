// Treats any call to $07b9 as a bank change.

const call_r16 = 0xcd;
const ld_a_imm8 = 0x3e;

let previousOpcode = null;
let previousImmediate = null;

function linearSweepWillStart() {
  previousOpcode = null;
  previousImmediate = null;
}

function linearSweepDidStep(opcode, immediate, pc, bank) {
  if (previousOpcode == ld_a_imm8
      && opcode == call_r16 && immediate == 0x07b9) {
    registerBankChange(previousImmediate, pc, bank);
  }

  previousOpcode = opcode;
  previousImmediate = immediate;
}