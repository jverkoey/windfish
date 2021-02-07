; BUTTON [Bitmask] [Binary]
J_RIGHT EQU %00000001
J_LEFT EQU %00000010
J_UP EQU %00000100
J_DOWN EQU %00001000
J_A EQU %00010000
J_B EQU %00100000
J_SELECT EQU %01000000
J_START EQU %10000000

; HW_AUDIO_ENABLE [Bitmask] [Binary]
HW_AUDIO_ENABLE EQU %10000000

; HW_CARTRIDGETYPE [Enumerated] [Hex]
cartridge_romonly EQU $00
cartridge_mbc1 EQU $01
cartridge_mbc1_ram EQU $02
cartridge_mbc1_ram_battery EQU $03
cartridge_mbc2 EQU $05
cartridge_mbc2_battery EQU $06
cartridge_rom_ram EQU $08
cartridge_rom_ram_battery EQU $09

; HW_COLORGAMEBOY [Enumerated] [Hex]
not_color_gameboy EQU $00
is_color_gameboy EQU $80

; HW_DESTINATIONCODE [Enumerated] [Hex]
destination_japanese EQU $00
destination_nonjapanese EQU $01

; HW_IE [Bitmask] [Binary]
IE_VBLANK EQU %00000001
IE_LCDC EQU %00000010
IE_TIMEROVERFLOW EQU %00000100
IE_SERIALIO EQU %00001000
IE_PIN1013TRANSITION EQU %00010000

; HW_RAMSIZE [Enumerated] [Hex]
ramsize_none EQU $00
ramsize_1bank EQU $01
ramsize_1bank_ EQU $02
ramsize_4banks EQU $03
ramsize_16banks EQU $04

; HW_ROMSIZE [Enumerated] [Hex]
romsize_2banks EQU $00
romsize_4banks EQU $01
romsize_8banks EQU $02
romsize_16banks EQU $03
romsize_32banks EQU $04
romsize_64banks EQU $05
romsize_128banks EQU $06
romsize_72banks EQU $52
romsize_80banks EQU $53
romsize_96banks EQU $54

; HW_SUPERGAMEBOY [Enumerated] [Hex]
not_super_gameboy EQU $00
is_super_gameboy EQU $80

; JOYPAD [Bitmask] [Binary]
JOYPAD_DIRECTIONS EQU %00010000
JOYPAD_BUTTONS EQU %00100000

; LCDCF [Bitmask] [Binary]
LCDCF_OFF EQU %00000000
LCDCF_ON EQU %10000000
LCDCF_TILEMAP_9C00 EQU %01000000
LCDCF_WINDOW_ON EQU %00100000
LCDCF_BG_CHAR_8000 EQU %00010000
LCDCF_BG_TILE_9C00 EQU %00001000
LCDCF_OBJ_16_16 EQU %00000100
LCDCF_OBJ_DISPLAY EQU %00000010
LCDCF_BG_DISPLAY EQU %00000001

; LR35902_INSTRUCTION [Enumerated] [Hex]
INSTRUCTION_jp_imm16 EQU $C3

; STATF [Bitmask] [Binary]
STATF_LYC EQU %01000000
STATF_MODE10 EQU %00100000
STATF_MODE01 EQU %00010000
STATF_MODE00 EQU %00001000
STATF_LYCF EQU %00000100
STATF_OAM EQU %00000010
STATF_VB EQU %00000001
STATF_HB EQU %00000000

; binary [Any] [Binary]

; bool [Enumerated] [Decimal]
false EQU 0
true EQU 1

; decimal [Any] [Decimal]

; hex [Any] [Hex]