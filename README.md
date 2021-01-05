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

<table>
<tr>
<td colspan="4"><code>cpu_instrs/</code></td>
</tr>
<tr>
<td align="center"><p>✅<br/><code>01-special</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/01-special.png"></td>
<td align="center"><p>✅<br/><code>02-interrupts.gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/02-interrupts.png"></td>
<td align="center"><p>✅<br/><code>03-op sp,hl.gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/03-op%20sp,hl.png"></td>
<td align="center"><p>✅<br/><code>04-op r,imm.gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/04-op%20r,imm.png"></td>
</tr><tr>
<td align="center"><p>✅<br/><code>05-op rp.gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/05-op%20rp.png"></td>
<td align="center"><p>✅<br/><code>06-ld r,r.gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/06-ld%20r,r.png"></td>
<td align="center"><p>✅<br/><code>07-jr,jp,call,ret,rst.gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/07-jr,jp,call,ret,rst.png"></td>
<td align="center"><p>✅<br/><code>08-misc instrs.gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/08-misc%20instrs.png"></td>
</tr><tr>
<td align="center"><p>✅<br/><code>09-op r,r.gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/09-op%20r,r.png"></td>
<td align="center"><p>✅<br/><code>10-bit ops.gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/10-bit%20ops.png"></td>
<td align="center"><p>✅<br/><code>11-op a,(hl).gb</code></p><img src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/11-op%20a,(hl).png"></td>
</tr><tr>
<td colspan="4"><code>interrupt_time/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>instr_timing</code></p><img src="lib/Tests/ROMTests/Resources/blargg/interrupt_time/interrupt_time.png"><br/>🐞<a href="https://github.com/jverkoey/windfish/issues/18">#18</a></td>
</tr><tr>
<td colspan="4"><code>instr_timing/</code></td>
</tr><tr>
<td align="center"><p>✅<br/><code>instr_timing</code></p><img src="lib/Tests/ROMTests/Resources/blargg/instr_timing/instr_timing.png"></td>
</tr><tr>
<td colspan="4"><code>mem_timing/</code></td>
</tr><tr>
<td align="center"><p>✅<br/><code>01-read_timing</code></p><img src="lib/Tests/ROMTests/Resources/blargg/mem_timing/individual/01-read_timing.png"></td>
<td align="center"><p>✅<br/><code>02-write_timing</code></p><img src="lib/Tests/ROMTests/Resources/blargg/mem_timing/individual/02-write_timing.png"></td>
<td align="center"><p>✅<br/><code>03-modify_timing</code></p><img src="lib/Tests/ROMTests/Resources/blargg/mem_timing/individual/03-modify_timing.png"></td>
</tr>
</table>

### [mooneye](https://github.com/Gekkio/mooneye-gb/)

<table>
<tr>
<td colspan="4"><code>acceptance/bits/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>mem_oam</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/bits/mem_oam.png"></td>
<td align="center"><p>✅<br/><code>reg_f</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/bits/reg_f.png"></td>
<td align="center"><p>❌<br/><code>unused_hwio-GS</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/bits/unused_hwio-GS.png"></td>
</tr><tr>
<td colspan="4"><code>acceptance/daa/</code></td>
</tr><tr>
<td align="center"><p>✅<br/><code>daa</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/instr/daa.png"></td>
</tr><tr>
<td colspan="4"><code>acceptance/interrupts/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>ie_push</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/interrupts/ie_push.png"></td>
</tr><tr>
<td colspan="4"><code>acceptance/oam_dma/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>basic</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma/basic.png"></td>
<td align="center"><p>✅<br/><code>reg_read</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma/reg_read.png"></td>
<td align="center"><p>❌<br/><code>sources-GS</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma/sources-GS.png"></td>
</tr><tr>
<td colspan="4"><code>acceptance/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>add_sp_e_timing</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/add_sp_e_timing.png"></td>
<td align="center"><p>✅<br/><code>boot_div-dmgABCmgb</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/boot_div-dmgABCmgb.png"></td>
<td align="center"><p>❌<br/><code>boot_regs-dmg0</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/boot_regs-dmg0.png"></td>
<td align="center"><p>✅<br/><code>boot_regs-dmgABC</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/boot_regs-dmgABC.png"></td>
</tr><tr>
<td align="center"><p>❌<br/><code>call_timing</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/acceptance/call_timing.png"></td>
</tr><tr>
<td colspan="4"><code>emulator-only/mbc1/</code></td>
</tr><tr>
<td align="center"><p>✅<br/><code>bits_bank1</code></p><img src="lib/Tests/ROMTests/Resources/mooneye/emulator-only/mbc1/bits_bank1.png"></td>
</table>

### [Mealybug Tearoom](https://github.com/mattcurrie/mealybug-tearoom-tests)

| Test name | Status | Screenshot |
|:-----|:--------|:----|
| `m3_lcdc_bg_en_change` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_lcdc_bg_en_change.png) |
| `m3_lcdc_bg_en_change` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_lcdc_bg_en_change.png) |
| `m3_scy_change` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_scy_change.png) |
| `m3_wx_4_change` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_wx_4_change.png) |
| `m3_wx_5_change` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_wx_5_change.png) |
| `m3_wx_6_change` | ❌ | ![Test result](lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_wx_6_change.png) |

## Learn more

[Learn more about the Windfish architecture](lib/README.md).
