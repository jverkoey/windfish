// Treats any call to $05CF as a bank change and call.

const ld_a_imm8 = 0x3e;
const ld_hl_imm16 = 0x21;
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
  if (history.length < 3) {
    return;
  }
  let window = history.slice(history.length - 3);
  if (window[0].opcode == ld_hl_imm16
      && window[1].opcode == ld_a_imm8
      && window[2].opcode == call_r16
      && window[2].immediate == 0x05CF) {
    didEncounterTransferOfControl(window[1].immediate, window[0].immediate, bank, pc);
  }
}