# Windfish

Windfish is a disassembler for Gameboy ROMs that can generate [RBGDS](https://github.com/gbdev/rgbds)-compatible assembly code.

## Background

This project was initiated to support [archaelogical efforts](https://kemenaran.winosx.com/posts/category-disassembling-links-awakening) aimed at understanding the implementation details behind Link's Awakening for the original Gameboy. The project has since grown to be a general disassembler for Gameboy ROMs.

The name "Windfish" is a reference to the main focus of the Link's Awakening storyline.

## Overview

The core design principle of the Windfish disassembler is to maximize legibility of generated assembly code with minimal configuration.

Windfish supports several powerful features for disassembling Gameboy ROMs, including:

- **Control-flow disassembly**: Able to follow branches in control flow in order to distinguish code from binary data.
- **Memory bank awareness**: Bank changes are monitored so that jumps to 0x4000-0x7999 memory regions can move to the correct bank.
- **Regions**: Text, image (2bpp, 1bpp), and data regions can be registered enabling a rich representation of the disassembly in KoholintIsland. 
- **Data types**: Custom datatypes can be registered and, when detected, automatically referenced in the generated assembly to improve code readability.
- **Globals**: Global variables can be registered and referred to within the generated assembly.
- **Macros**: Common assembly patterns can be registered and, when detected, generated as RGBDS macros.
- **Scope awareness**: Contiguous blocks of scope are inferred during disassembly.

## KoholintIsland

![The Koholint Island frontend for Windfish](docs/koholintisland.png)

The Windfish disassembler is best invoked through the KoholintIsland front-end application.

## Emulation test matrix

The Windfish emulator is validated against test ROMs in order to ensure consistency + completeness of the implementation.

### [blargg](https://gbdev.gg8.se/files/roms/blargg-gb-tests/)

| Test name | Status | Screenshot |
|:-----|:--------|:---|
| `01-special` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/01-special.png) |
| `02-interrupts.gb` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/02-interrupts.png) |
| `03-op sp,hl.gb` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/03-op%20sp,hl.png) |
| `04-op r,imm.gb` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/04-op%20r,imm.png) |
| `05-op rp.gb` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/05-op%20rp.png) |
| `06-ld r,r.gb` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/06-ld%20r,r.png) |
| `07-jr,jp,call,ret,rst.gb` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/07-jr,jp,call,ret,rst.png) |
| `08-misc instrs.gb` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/08-misc%20instrs.png) |
| `09-op r,r.gb` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/09-op%20r,r.png) |
| `10-bit ops.gb` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/10-bit%20ops.png) |
| `11-op a,(hl).gb` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/11-op%20a,(hl).png) |

### [mooneye](https://github.com/Gekkio/mooneye-gb/)

| Test name | Status | Screenshot |
|:-----|:--------|:----|
| `acceptance/bits/mem_oam` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/bits/mem_oam.png) |
| `acceptance/bits/reg_f` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/bits/reg_f.png) |
| `acceptance/bits/unused_hwio-GS` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/bits/unused_hwio-GS.png) |
| `acceptance/instr/daa` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/instr/daa.png) |
| `acceptance/interrupts/ie_push` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/interrupts/ie_push.png) |
| `acceptance/oam_dma/basic` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma/basic.png) |
| `acceptance/oam_dma/reg_read` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma/reg_read.png) |
| `acceptance/oam_dma/sources-GS` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma/sources-GS.png) |
| `acceptance/add_sp_e_timing` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/add_sp_e_timing.png) |
| `acceptance/boot_regs-dmg0` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/boot_regs-dmg0.png) |
| `acceptance/boot_regs-dmgABC` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/boot_regs-dmgABC.png) |
| `acceptance/call_timing` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/acceptance/call_timing.png) |
| `emulator-only/mbc1/bits_bank1` | ✅ | ![Test result](lib/Tests/ROMTests/Resources/mooneye/emulator-only/mbc1/bits_bank1.png) |

## Learn more

[Learn more about the Windfish architecture](lib/README.md).
