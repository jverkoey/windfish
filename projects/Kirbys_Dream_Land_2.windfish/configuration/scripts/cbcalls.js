// Treats any call to $05E5 as a bank change and call.
/**
    ld   a, $1E
    ld   hl, $4232
    call toc_01_05E5


const call_r16 = 0xcd;
const ld_hl_imm16 = 0x21;
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
    changeBank(previousImmediate, pc, bank);
  }

  previousOpcode = opcode;
  previousImmediate = immediate;
}
*/