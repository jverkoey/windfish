import Foundation

extension LR35902 {
  static let opcodeDescription: [UInt8: InstructionSpec] = [
    0x00: .nop,
    0x01: .ld(.bc, .immediate16),
    0x02: .ld(.bcAddress, .a),
    0x03: .inc(.bc),
    0x04: .inc(.b),
    0x05: .dec(.b),
    0x06: .ld(.b, .immediate8),
    0x07: .rlca,
    0x08: .ld(.immediate16address, .sp),
    0x09: .add(.hl, .bc),
    0x0a: .ld(.a, .bcAddress),
    0x0b: .dec(.bc),
    0x0c: .inc(.c),
    0x0d: .dec(.c),
    0x0e: .ld(.c, .immediate8),
    0x0f: .rrca,

    0x10: .stop,
    0x11: .ld(.de, .immediate16),
    0x12: .ld(.deAddress, .a),
    0x13: .inc(.de),
    0x14: .inc(.d),
    0x15: .dec(.d),
    0x16: .ld(.d, .immediate8),
    0x17: .rla,
    0x18: .jr(.immediate8signed),
    0x19: .add(.hl, .de),
    0x1a: .ld(.a, .deAddress),
    0x1b: .dec(.de),
    0x1c: .inc(.e),
    0x1d: .dec(.e),
    0x1e: .ld(.e, .immediate8),
    0x1f: .rra,

    0x20: .jr(.immediate8signed, .nz),
    0x21: .ld(.hl, .immediate16),
    0x22: .ldi(.hlAddress, .a),
    0x23: .inc(.hl),
    0x24: .inc(.h),
    0x25: .dec(.h),
    0x26: .ld(.h, .immediate8),
    0x27: .daa,
    0x28: .jr(.immediate8signed, .z),
    0x29: .add(.hl, .hl),
    0x2a: .ldi(.a, .hlAddress),
    0x2b: .dec(.hl),
    0x2c: .inc(.l),
    0x2d: .dec(.l),
    0x2e: .ld(.l, .immediate8),
    0x2f: .cpl,

    0x30: .jr(.immediate8signed, .nc),
    0x31: .ld(.sp, .immediate16),
    0x32: .ldd(.hlAddress, .a),
    0x33: .inc(.sp),
    0x34: .inc(.hlAddress),
    0x35: .dec(.hlAddress),
    0x36: .ld(.hlAddress, .immediate8),
    0x37: .scf,
    0x38: .jr(.immediate8signed, .c),
    0x39: .add(.hl, .sp),
    0x3a: .ldd(.a, .hlAddress),
    0x3b: .dec(.sp),
    0x3c: .inc(.a),
    0x3d: .dec(.a),
    0x3e: .ld(.a, .immediate8),
    0x3f: .ccf,

    0x40: .ld(.b, .b),
    0x41: .ld(.b, .c),
    0x42: .ld(.b, .d),
    0x43: .ld(.b, .e),
    0x44: .ld(.b, .h),
    0x45: .ld(.b, .l),
    0x46: .ld(.b, .hlAddress),
    0x47: .ld(.b, .a),
    0x48: .ld(.c, .b),
    0x49: .ld(.c, .c),
    0x4a: .ld(.c, .d),
    0x4b: .ld(.c, .e),
    0x4c: .ld(.c, .h),
    0x4d: .ld(.c, .l),
    0x4e: .ld(.c, .hlAddress),
    0x4f: .ld(.c, .a),

    0x50: .ld(.d, .b),
    0x51: .ld(.d, .c),
    0x52: .ld(.d, .d),
    0x53: .ld(.d, .e),
    0x54: .ld(.d, .h),
    0x55: .ld(.d, .l),
    0x56: .ld(.d, .hlAddress),
    0x57: .ld(.d, .a),
    0x58: .ld(.e, .b),
    0x59: .ld(.e, .c),
    0x5a: .ld(.e, .d),
    0x5b: .ld(.e, .e),
    0x5c: .ld(.e, .h),
    0x5d: .ld(.e, .l),
    0x5e: .ld(.e, .hlAddress),
    0x5f: .ld(.e, .a),

    0x60: .ld(.h, .b),
    0x61: .ld(.h, .c),
    0x62: .ld(.h, .d),
    0x63: .ld(.h, .e),
    0x64: .ld(.h, .h),
    0x65: .ld(.h, .l),
    0x66: .ld(.h, .hlAddress),
    0x67: .ld(.h, .a),
    0x68: .ld(.l, .b),
    0x69: .ld(.l, .c),
    0x6a: .ld(.l, .d),
    0x6b: .ld(.l, .e),
    0x6c: .ld(.l, .h),
    0x6d: .ld(.l, .l),
    0x6e: .ld(.l, .hlAddress),
    0x6f: .ld(.l, .a),

    0x70: .ld(.hlAddress, .b),
    0x71: .ld(.hlAddress, .c),
    0x72: .ld(.hlAddress, .d),
    0x73: .ld(.hlAddress, .e),
    0x74: .ld(.hlAddress, .h),
    0x75: .ld(.hlAddress, .l),
    0x76: .halt,
    0x77: .ld(.hlAddress, .a),
    0x78: .ld(.a, .b),
    0x79: .ld(.a, .c),
    0x7a: .ld(.a, .d),
    0x7b: .ld(.a, .e),
    0x7c: .ld(.a, .h),
    0x7d: .ld(.a, .l),
    0x7e: .ld(.a, .hlAddress),
    0x7f: .ld(.a, .a),

    0x80: .add(.b),
    0x81: .add(.c),
    0x82: .add(.d),
    0x83: .add(.e),
    0x84: .add(.h),
    0x85: .add(.l),
    0x86: .add(.hlAddress),
    0x87: .add(.a),
    0x88: .adc(.b),
    0x89: .adc(.c),
    0x8a: .adc(.d),
    0x8b: .adc(.e),
    0x8c: .adc(.h),
    0x8d: .adc(.l),
    0x8e: .adc(.hlAddress),
    0x8f: .adc(.a),

    0x90: .sub(.b),
    0x91: .sub(.c),
    0x92: .sub(.d),
    0x93: .sub(.e),
    0x94: .sub(.h),
    0x95: .sub(.l),
    0x96: .sub(.hlAddress),
    0x97: .sub(.a),
    0x98: .sbc(.b),
    0x99: .sbc(.c),
    0x9a: .sbc(.d),
    0x9b: .sbc(.e),
    0x9c: .sbc(.h),
    0x9d: .sbc(.l),
    0x9e: .sbc(.hlAddress),
    0x9f: .sbc(.a),

    0xa0: .and(.b),
    0xa1: .and(.c),
    0xa2: .and(.d),
    0xa3: .and(.e),
    0xa4: .and(.h),
    0xa5: .and(.l),
    0xa6: .and(.hlAddress),
    0xa7: .and(.a),
    0xa8: .xor(.b),
    0xa9: .xor(.c),
    0xaa: .xor(.d),
    0xab: .xor(.e),
    0xac: .xor(.h),
    0xad: .xor(.l),
    0xae: .xor(.hlAddress),
    0xaf: .xor(.a),

    0xb0: .or(.b),
    0xb1: .or(.c),
    0xb2: .or(.d),
    0xb3: .or(.e),
    0xb4: .or(.h),
    0xb5: .or(.l),
    0xb6: .or(.hlAddress),
    0xb7: .or(.a),
    0xb8: .cp(.b),
    0xb9: .cp(.c),
    0xba: .cp(.d),
    0xbb: .cp(.e),
    0xbc: .cp(.h),
    0xbd: .cp(.l),
    0xbe: .cp(.hlAddress),
    0xbf: .cp(.a),

    0xc0: .ret(.nz),
    0xc1: .pop(.bc),
    0xc2: .jp(.immediate16, .nz),
    0xc3: .jp(.immediate16),
    0xc4: .call(.immediate16, .nz),
    0xc5: .push(.bc),
    0xc6: .add(.immediate8),
    0xc7: .rst(.x00),
    0xc8: .ret(.z),
    0xc9: .ret(),
    0xca: .jp(.immediate16, .z),
    0xcb: .cb,
    0xcc: .call(.immediate16, .z),
    0xcd: .call(.immediate16),
    0xce: .adc(.immediate8),
    0xcf: .rst(.x08),

    0xd0: .ret(.nc),
    0xd1: .pop(.de),
    0xd2: .jp(.immediate16, .nc),
    0xd3: .invalid,
    0xd4: .call(.immediate16, .nc),
    0xd5: .push(.de),
    0xd6: .sub(.immediate8),
    0xd7: .rst(.x10),
    0xd8: .ret(.c),
    0xd9: .reti,
    0xda: .jp(.immediate16, .c),
    0xdb: .invalid,
    0xdc: .call(.immediate16, .c),
    0xdd: .invalid,
    0xde: .sbc(.immediate8),
    0xdf: .rst(.x18),

    0xe0: .ld(.ffimmediate8Address, .a),
    0xe1: .pop(.hl),
    0xe2: .ld(.ffccAddress, .a),
    0xe3: .invalid,
    0xe4: .invalid,
    0xe5: .push(.hl),
    0xe6: .and(.immediate8),
    0xe7: .rst(.x20),
    0xe8: .add(.sp, .immediate8),
    0xe9: .jp(.hl),
    0xea: .ld(.immediate16address, .a),
    0xeb: .invalid,
    0xec: .invalid,
    0xed: .invalid,
    0xee: .xor(.immediate8),
    0xef: .rst(.x28),

    0xf0: .ld(.a, .ffimmediate8Address),
    0xf1: .pop(.af),
    0xf2: .ld(.a, .ffccAddress),
    0xf3: .di,
    0xf4: .invalid,
    0xf5: .push(.af),
    0xf6: .or(.immediate8),
    0xf7: .rst(.x30),
    0xf8: .ld(.hl, .spPlusImmediate8Signed),
    0xf9: .ld(.sp, .hl),
    0xfa: .ld(.a, .immediate16address),
    0xfb: .ei,
    0xfc: .invalid,
    0xfd: .invalid,
    0xfe: .cp(.immediate8),
    0xff: .rst(.x38),
  ]

  static let cbOpcodeDescription: [UInt8: InstructionSpec] = [
    0x00: .rlc(.b),
    0x01: .rlc(.c),
    0x02: .rlc(.d),
    0x03: .rlc(.e),
    0x04: .rlc(.h),
    0x05: .rlc(.l),
    0x06: .rlc(.hlAddress),
    0x07: .rlc(.a),
    0x08: .rrc(.b),
    0x09: .rrc(.c),
    0x0a: .rrc(.d),
    0x0b: .rrc(.e),
    0x0c: .rrc(.h),
    0x0d: .rrc(.l),
    0x0e: .rrc(.hlAddress),
    0x0f: .rrc(.a),

    0x10: .rl(.b),
    0x11: .rl(.c),
    0x12: .rl(.d),
    0x13: .rl(.e),
    0x14: .rl(.h),
    0x15: .rl(.l),
    0x16: .rl(.hlAddress),
    0x17: .rl(.a),
    0x18: .rr(.b),
    0x19: .rr(.c),
    0x1a: .rr(.d),
    0x1b: .rr(.e),
    0x1c: .rr(.h),
    0x1d: .rr(.l),
    0x1e: .rr(.hlAddress),
    0x1f: .rr(.a),

    0x20: .sla(.b),
    0x21: .sla(.c),
    0x22: .sla(.d),
    0x23: .sla(.e),
    0x24: .sla(.h),
    0x25: .sla(.l),
    0x26: .sla(.hlAddress),
    0x27: .sla(.a),
    0x28: .sra(.b),
    0x29: .sra(.c),
    0x2a: .sra(.d),
    0x2b: .sra(.e),
    0x2c: .sra(.h),
    0x2d: .sra(.l),
    0x2e: .sra(.hlAddress),
    0x2f: .sra(.a),

    0x30: .swap(.b),
    0x31: .swap(.c),
    0x32: .swap(.d),
    0x33: .swap(.e),
    0x34: .swap(.h),
    0x35: .swap(.l),
    0x36: .swap(.hlAddress),
    0x37: .swap(.a),
    0x38: .srl(.b),
    0x39: .srl(.c),
    0x3a: .srl(.d),
    0x3b: .srl(.e),
    0x3c: .srl(.h),
    0x3d: .srl(.l),
    0x3e: .srl(.hlAddress),
    0x3f: .srl(.a),

    0x40: .bit(.b0, .b),
    0x41: .bit(.b0, .c),
    0x42: .bit(.b0, .d),
    0x43: .bit(.b0, .e),
    0x44: .bit(.b0, .h),
    0x45: .bit(.b0, .l),
    0x46: .bit(.b0, .hlAddress),
    0x47: .bit(.b0, .a),
    0x48: .bit(.b1, .b),
    0x49: .bit(.b1, .c),
    0x4a: .bit(.b1, .d),
    0x4b: .bit(.b1, .e),
    0x4c: .bit(.b1, .h),
    0x4d: .bit(.b1, .l),
    0x4e: .bit(.b1, .hlAddress),
    0x4f: .bit(.b1, .a),

    0x50: .bit(.b2, .b),
    0x51: .bit(.b2, .c),
    0x52: .bit(.b2, .d),
    0x53: .bit(.b2, .e),
    0x54: .bit(.b2, .h),
    0x55: .bit(.b2, .l),
    0x56: .bit(.b2, .hlAddress),
    0x57: .bit(.b2, .a),
    0x58: .bit(.b3, .b),
    0x59: .bit(.b3, .c),
    0x5a: .bit(.b3, .d),
    0x5b: .bit(.b3, .e),
    0x5c: .bit(.b3, .h),
    0x5d: .bit(.b3, .l),
    0x5e: .bit(.b3, .hlAddress),
    0x5f: .bit(.b3, .a),

    0x60: .bit(.b4, .b),
    0x61: .bit(.b4, .c),
    0x62: .bit(.b4, .d),
    0x63: .bit(.b4, .e),
    0x64: .bit(.b4, .h),
    0x65: .bit(.b4, .l),
    0x66: .bit(.b4, .hlAddress),
    0x67: .bit(.b4, .a),
    0x68: .bit(.b5, .b),
    0x69: .bit(.b5, .c),
    0x6a: .bit(.b5, .d),
    0x6b: .bit(.b5, .e),
    0x6c: .bit(.b5, .h),
    0x6d: .bit(.b5, .l),
    0x6e: .bit(.b5, .hlAddress),
    0x6f: .bit(.b5, .a),

    0x70: .bit(.b6, .b),
    0x71: .bit(.b6, .c),
    0x72: .bit(.b6, .d),
    0x73: .bit(.b6, .e),
    0x74: .bit(.b6, .h),
    0x75: .bit(.b6, .l),
    0x76: .bit(.b6, .hlAddress),
    0x77: .bit(.b6, .a),
    0x78: .bit(.b7, .b),
    0x79: .bit(.b7, .c),
    0x7a: .bit(.b7, .d),
    0x7b: .bit(.b7, .e),
    0x7c: .bit(.b7, .h),
    0x7d: .bit(.b7, .l),
    0x7e: .bit(.b7, .hlAddress),
    0x7f: .bit(.b7, .a),

    0x80: .res(.b0, .b),
    0x81: .res(.b0, .c),
    0x82: .res(.b0, .d),
    0x83: .res(.b0, .e),
    0x84: .res(.b0, .h),
    0x85: .res(.b0, .l),
    0x86: .res(.b0, .hlAddress),
    0x87: .res(.b0, .a),
    0x88: .res(.b1, .b),
    0x89: .res(.b1, .c),
    0x8a: .res(.b1, .d),
    0x8b: .res(.b1, .e),
    0x8c: .res(.b1, .h),
    0x8d: .res(.b1, .l),
    0x8e: .res(.b1, .hlAddress),
    0x8f: .res(.b1, .a),

    0x90: .res(.b2, .b),
    0x91: .res(.b2, .c),
    0x92: .res(.b2, .d),
    0x93: .res(.b2, .e),
    0x94: .res(.b2, .h),
    0x95: .res(.b2, .l),
    0x96: .res(.b2, .hlAddress),
    0x97: .res(.b2, .a),
    0x98: .res(.b3, .b),
    0x99: .res(.b3, .c),
    0x9a: .res(.b3, .d),
    0x9b: .res(.b3, .e),
    0x9c: .res(.b3, .h),
    0x9d: .res(.b3, .l),
    0x9e: .res(.b3, .hlAddress),
    0x9f: .res(.b3, .a),

    0xa0: .res(.b4, .b),
    0xa1: .res(.b4, .c),
    0xa2: .res(.b4, .d),
    0xa3: .res(.b4, .e),
    0xa4: .res(.b4, .h),
    0xa5: .res(.b4, .l),
    0xa6: .res(.b4, .hlAddress),
    0xa7: .res(.b4, .a),
    0xa8: .res(.b5, .b),
    0xa9: .res(.b5, .c),
    0xaa: .res(.b5, .d),
    0xab: .res(.b5, .e),
    0xac: .res(.b5, .h),
    0xad: .res(.b5, .l),
    0xae: .res(.b5, .hlAddress),
    0xaf: .res(.b5, .a),

    0xb0: .res(.b6, .b),
    0xb1: .res(.b6, .c),
    0xb2: .res(.b6, .d),
    0xb3: .res(.b6, .e),
    0xb4: .res(.b6, .h),
    0xb5: .res(.b6, .l),
    0xb6: .res(.b6, .hlAddress),
    0xb7: .res(.b6, .a),
    0xb8: .res(.b7, .b),
    0xb9: .res(.b7, .c),
    0xba: .res(.b7, .d),
    0xbb: .res(.b7, .e),
    0xbc: .res(.b7, .h),
    0xbd: .res(.b7, .l),
    0xbe: .res(.b7, .hlAddress),
    0xbf: .res(.b7, .a),


    0xc0: .set(.b0, .b),
    0xc1: .set(.b0, .c),
    0xc2: .set(.b0, .d),
    0xc3: .set(.b0, .e),
    0xc4: .set(.b0, .h),
    0xc5: .set(.b0, .l),
    0xc6: .set(.b0, .hlAddress),
    0xc7: .set(.b0, .a),
    0xc8: .set(.b1, .b),
    0xc9: .set(.b1, .c),
    0xca: .set(.b1, .d),
    0xcb: .set(.b1, .e),
    0xcc: .set(.b1, .h),
    0xcd: .set(.b1, .l),
    0xce: .set(.b1, .hlAddress),
    0xcf: .set(.b1, .a),

    0xd0: .set(.b2, .b),
    0xd1: .set(.b2, .c),
    0xd2: .set(.b2, .d),
    0xd3: .set(.b2, .e),
    0xd4: .set(.b2, .h),
    0xd5: .set(.b2, .l),
    0xd6: .set(.b2, .hlAddress),
    0xd7: .set(.b2, .a),
    0xd8: .set(.b3, .b),
    0xd9: .set(.b3, .c),
    0xda: .set(.b3, .d),
    0xdb: .set(.b3, .e),
    0xdc: .set(.b3, .h),
    0xdd: .set(.b3, .l),
    0xde: .set(.b3, .hlAddress),
    0xdf: .set(.b3, .a),

    0xe0: .set(.b4, .b),
    0xe1: .set(.b4, .c),
    0xe2: .set(.b4, .d),
    0xe3: .set(.b4, .e),
    0xe4: .set(.b4, .h),
    0xe5: .set(.b4, .l),
    0xe6: .set(.b4, .hlAddress),
    0xe7: .set(.b4, .a),
    0xe8: .set(.b5, .b),
    0xe9: .set(.b5, .c),
    0xea: .set(.b5, .d),
    0xeb: .set(.b5, .e),
    0xec: .set(.b5, .h),
    0xed: .set(.b5, .l),
    0xee: .set(.b5, .hlAddress),
    0xef: .set(.b5, .a),

    0xf0: .set(.b6, .b),
    0xf1: .set(.b6, .c),
    0xf2: .set(.b6, .d),
    0xf3: .set(.b6, .e),
    0xf4: .set(.b6, .h),
    0xf5: .set(.b6, .l),
    0xf6: .set(.b6, .hlAddress),
    0xf7: .set(.b6, .a),
    0xf8: .set(.b7, .b),
    0xf9: .set(.b7, .c),
    0xfa: .set(.b7, .d),
    0xfb: .set(.b7, .e),
    0xfc: .set(.b7, .h),
    0xfd: .set(.b7, .l),
    0xfe: .set(.b7, .hlAddress),
    0xff: .set(.b7, .a)
  ]
}
