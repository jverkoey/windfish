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

## Reference material

Technical references:

- [Game Boy: Complete Technical Reference](https://github.com/Gekkio/gb-ctr)
- [Game Boy: Complete Technical Reference (pdf)](https://gekkio.fi/files/gb-docs/gbctr.pdf)
- [Game Boy CPU Manual](https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf)
- [Pan Docs](https://gbdev.io/pandocs/)
- [GameBoy Memory Map](http://gameboy.mongenel.com/dmg/asmmemmap.html)

On accuracy:

- [Mooneye GB: A Gameboy emulator written in Rust](https://gekkio.fi/blog/2015/mooneye-gb-a-gameboy-emulator-written-in-rust/)
- [Nitty Gritty Gameboy Cycle Timing](http://blog.kevtris.org/blogfiles/Nitty%20Gritty%20Gameboy%20VRAM%20Timing.txt)

PPU:

- [Writing an emulator: the first pixel](https://blog.tigris.fr/2019/09/15/writing-an-emulator-the-first-pixel/))

Test ROMs:

- [Mooneye GB](https://github.com/Gekkio/mooneye-gb/tree/master/tests)
- [blargg](https://gbdev.gg8.se/files/roms/blargg-gb-tests/)
- [mealybug-tearoom](https://github.com/mattcurrie/mealybug-tearoom-tests)
- [Gambatte](https://github.com/sinamas/gambatte/tree/master/test/hwtests)
- [Game Boy test ROM do's and don'ts](https://gekkio.fi/blog/2016/game-boy-test-rom-dos-and-donts/)

Open source emulators with both fifo PPU and cycle-accuracy:

- [coffee-gb](https://github.com/trekawek/coffee-gb/tree/master/src/main/java/eu/rekawek/coffeegb)
- [Sameboy](https://github.com/LIJI32/SameBoy)
  - Code can be a bit difficult to follow because cycles can be executed from anywhere and there is some goto/lable magic happening with GB_STATE_MACHINE.

  Other open source emulators:

- [mame](https://github.com/mamedev/mame/tree/30371b5717b3aa88da7f3d19235821f7eca0d429/src/devices/cpu/lr35902)
- [BremuGb](https://github.com/Briensturm/BremuGb/tree/78dfd4bb469637892596017c354a0fd1a74f0855/Src/BremuGb.Lib)
- [SpecBoy](https://github.com/spec-chum/SpecBoy)
- [giibiiadvance](https://github.com/AntonioND/giibiiadvance)

Videos:

- [The Ultimate Game Boy Talk (33c3)](https://www.youtube.com/watch?v=HyzD8pNlpwI&t=29m19s)

## Emulation test matrix

The Windfish emulator is validated against test ROMs in order to ensure consistency + completeness of the implementation.

### [blargg](https://gbdev.gg8.se/files/roms/blargg-gb-tests/)

<table>
<tr>
<td colspan="4"><code>cpu_instrs/</code></td>
</tr>
<tr>
<td align="center"><p>✅<br/><code>01-special</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/01-special.png"></td>
<td align="center"><p>✅<br/><code>02-interrupts.gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/02-interrupts.png"></td>
<td align="center"><p>✅<br/><code>03-op sp,hl.gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/03-op%20sp,hl.png"></td>
<td align="center"><p>✅<br/><code>04-op r,imm.gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/04-op%20r,imm.png"></td>
</tr><tr>
<td align="center"><p>✅<br/><code>05-op rp.gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/05-op%20rp.png"></td>
<td align="center"><p>✅<br/><code>06-ld r,r.gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/06-ld%20r,r.png"></td>
<td align="center"><p>✅<br/><code>07-jr,jp,call,ret,rst.gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/07-jr,jp,call,ret,rst.png"></td>
<td align="center"><p>✅<br/><code>08-misc instrs.gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/08-misc%20instrs.png"></td>
</tr><tr>
<td align="center"><p>✅<br/><code>09-op r,r.gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/09-op%20r,r.png"></td>
<td align="center"><p>✅<br/><code>10-bit ops.gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/10-bit%20ops.png"></td>
<td align="center"><p>✅<br/><code>11-op a,(hl).gb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/cpu_instrs/individual/11-op%20a,(hl).png"></td>
</tr><tr>
<td colspan="4"><code>interrupt_time/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>instr_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/interrupt_time/interrupt_time.png"><br/>🐞<a href="https://github.com/jverkoey/windfish/issues/18">#18</a></td>
</tr><tr>
<td colspan="4"><code>instr_timing/</code></td>
</tr><tr>
<td align="center"><p>✅<br/><code>instr_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/instr_timing/instr_timing.png"></td>
</tr><tr>
<td colspan="4"><code>mem_timing/</code></td>
</tr><tr>
<td align="center"><p>✅<br/><code>01-read_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/mem_timing/individual/01-read_timing.png"></td>
<td align="center"><p>✅<br/><code>02-write_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/mem_timing/individual/02-write_timing.png"></td>
<td align="center"><p>✅<br/><code>03-modify_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/blargg/mem_timing/individual/03-modify_timing.png"></td>
</tr>
</table>

### [mooneye](https://github.com/Gekkio/mooneye-gb/)

<table>
<tr>
<td colspan="4"><code>acceptance/bits/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>mem_oam</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/bits/mem_oam.png"></td>
<td align="center"><p>✅<br/><code>reg_f</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/bits/reg_f.png"></td>
<td align="center"><p>❌<br/><code>unused_hwio-GS</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/bits/unused_hwio-GS.png"></td>
</tr><tr>
<td colspan="4"><code>acceptance/daa/</code></td>
</tr><tr>
<td align="center"><p>✅<br/><code>daa</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/instr/daa.png"></td>
</tr><tr>
<td colspan="4"><code>acceptance/interrupts/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>ie_push</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/interrupts/ie_push.png"></td>
</tr><tr>
<td colspan="4"><code>acceptance/oam_dma/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>basic</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma/basic.png"></td>
<td align="center"><p>✅<br/><code>reg_read</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma/reg_read.png"></td>
<td align="center"><p>❌<br/><code>sources-GS</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma/sources-GS.png"></td>
</tr><tr>
<td colspan="4"><code>acceptance/ppu/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>hblank_ly_scx_timing-GS</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ppu/hblank_ly_scx_timing-GS.png"></td>
<td align="center"><p>❌<br/><code>intr_1_2_timing-GS</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ppu/intr_1_2_timing-GS.png"></td>
<td align="center"><p>❌<br/><code>intr_2_0_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ppu/intr_2_0_timing.png"></td>
<td align="center"><p>❌<br/><code>intr_2_mode0_timing_sprites</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ppu/intr_2_mode0_timing_sprites.png"></td>
</tr><tr>
<td align="center"><p>✅<br/><code>intr_2_mode0_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ppu/intr_2_mode0_timing.png"></td>
<td align="center"><p>✅<br/><code>intr_2_mode3_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ppu/intr_2_mode3_timing.png"></td>
<td align="center"><p>✅<br/><code>intr_2_oam_ok_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ppu/intr_2_oam_ok_timing.png"></td>
<td align="center"><p>❌<br/><code>stat_lyc_onoff</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ppu/stat_lyc_onoff.png"></td>
</tr><tr>
<td align="center"><p>✅<br/><code>vblank_stat_intr-GS</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ppu/vblank_stat_intr-GS.png"></td>
</tr><tr>
<td colspan="4"><code>acceptance/</code></td>
</tr><tr>
<td align="center"><p>❌<br/><code>add_sp_e_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/add_sp_e_timing.png"></td>
<td align="center"><p>✅<br/><code>boot_div-dmgABCmgb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/boot_div-dmgABCmgb.png"></td>
<td align="center"><p>❌<br/><code>boot_regs-dmg0</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/boot_regs-dmg0.png"></td>
<td align="center"><p>✅<br/><code>boot_regs-dmgABC</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/boot_regs-dmgABC.png"></td>
</tr><tr>
<td align="center"><p>❌<br/><code>boot_hwio-dmgABCmgb</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/boot_hwio-dmgABCmgb.png"></td>
<td align="center"><p>❌<br/><code>call_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/call_timing.png"></td>
<td align="center"><p>✅<br/><code>div_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/div_timing.png"></td>
<td align="center"><p>❌<br/><code>ei_sequence</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ei_sequence.png"></td>
</tr><tr>
<td align="center"><p>❌<br/><code>ei_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/ei_timing.png"></td>
<td align="center"><p>❌<br/><code>if_ie_registers</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/if_ie_registers.png"></td>
<td align="center"><p>✅<br/><code>intr_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/intr_timing.png"></td>
<td align="center"><p>❌<br/><code>jp_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/jp_timing.png"></td>
</tr><tr>
<td align="center"><p>✅<br/><code>oam_dma_restart</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma_restart.png"></td>
<td align="center"><p>✅<br/><code>oam_dma_start</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma_start.png"></td>
<td align="center"><p>✅<br/><code>oam_dma_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/oam_dma_timing.png"></td>
<td align="center"><p>✅<br/><code>pop_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/pop_timing.png"></td>
</tr><tr>
<td align="center"><p>❌<br/><code>push_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/push_timing.png"></td>
<td align="center"><p>❌<br/><code>rapid_di_ei</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/rapid_di_ei.png"></td>
<td align="center"><p>❌<br/><code>rst_timing</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/acceptance/rst_timing.png"></td>
</tr><tr>
<td colspan="4"><code>emulator-only/mbc1/</code></td>
</tr><tr>
<td align="center"><p>✅<br/><code>bits_bank1</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mooneye/emulator-only/mbc1/bits_bank1.png"></td>
</tr>
</table>

### [Mealybug Tearoom](https://github.com/mattcurrie/mealybug-tearoom-tests)

<table>
<tr>
<td align="center"><p>❌<br/><code>m3_lcdc_bg_en_change</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_lcdc_bg_en_change.png"></td>
<td align="center"><p>❌<br/><code>m3_lcdc_bg_en_change</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_lcdc_bg_en_change.png"></td>
<td align="center"><p>❌<br/><code>m3_scy_change</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_scy_change.png"></td>
<td align="center"><p>❌<br/><code>m3_wx_4_change</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_wx_4_change.png"></td>
</tr><tr>
<td align="center"><p>❌<br/><code>m3_wx_5_change</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_wx_5_change.png"></td>
<td align="center"><p>❌<br/><code>m3_wx_6_change</code></p><img width="160" src="lib/Tests/ROMTests/Resources/mealybug-tearoom/m3_wx_6_change.png"></td>
</tr>
</table>

## Learn more

[Learn more about the Windfish architecture](lib/README.md).
