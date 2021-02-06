// Treats any call to $05E5 as a bank change and call.

const ld_a_imm8 = 0x3e;
const call_r16 = 0xcd;

let history = [];

function linearSweepWillStart() {
  history = [];
}

function linearSweepDidStep(opcode, immediate, pc, bank) {
  history.push({
    'opcode': opcode,
    'immediate': immediate,
  });
  if (history.length < 2) {
    return;
  }
  let window = history.slice(history.length - 2);
  if (window[0].opcode == ld_a_imm8
      && window[1].opcode == call_r16
      && (window[1].immediate == 0x05DD
          || window[1].immediate == 0x05F3)) {
    changeBank(window[0].immediate, pc, bank);
  }
}