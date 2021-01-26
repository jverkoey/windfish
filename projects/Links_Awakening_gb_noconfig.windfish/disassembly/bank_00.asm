SECTION "ROM Bank 00", ROM0[$00]

RST_0000:
    jp   toc_01_2872

    db   $00, $00, $FF, $FF, $FF

RST_0008:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0010:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0018:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0020:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0028:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0030:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0038:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

VBlankInterrupt:
    jp   toc_01_0525

    db   $FF, $FF, $FF, $FF, $FF

LCDCInterrupt:
    jp   toc_01_03E2

    db   $FF, $FF, $FF, $FF, $FF

TimerOverflowInterrupt:
    reti


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

SerialTransferCompleteInterrupt:
    reti


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

JoypadTransitionInterrupt:
    reti


    db   $FF

toc_01_0062:
    ld   hl, $6900
    ld   de, $89A0
    jr   toc_01_0080

toc_01_006A:
    ld   hl, $6930
    ld   de, $89D0
    jr   toc_01_0080

toc_01_0072:
    ld   hl, $49D0
    ld   de, $89D0
    jr   toc_01_0080

toc_01_007A:
    ld   hl, $49A0
    ld   de, $89A0
toc_01_0080:
    ld   bc, $0030
    call toc_01_28C5
    xor  a
    ld   [$FF90], a
    ld   [$FF92], a
toc_01_008B:
    ld   a, $0C
    ld   [$2100], a
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

Boot:
    nop
    jp   toc_01_0150

HeaderLogo:

    db   $CE, $ED, $66, $66, $CC, $0D, $00, $0B
    db   $03, $73, $00, $83, $00, $0C, $00, $0D
    db   $00, $08, $11, $1F, $88, $89, $00, $0E
    db   $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
    db   $BB, $BB, $67, $63, $6E, $0E, $EC, $CC
    db   $DD, $DC, $99, $9F, $BB, $B9, $33, $3E

HeaderTitle:
    db   "ZELDA", $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

HeaderIsColorGB:
    db   not_color_gameboy

HeaderNewLicenseeCode:
    db   $00, $00

HeaderSGBFlag:
    db   not_super_gameboy

HeaderCartridgeType:
    db   cartridge_mbc1_ram_battery

HeaderROMSize:
    db   romsize_32banks

HeaderRAMSize:
    db   ramsize_1bank_

HeaderDestinationCode:
    db   destination_nonjapanese

HeaderOldLicenseeCode:
    db   $01

HeaderMaskROMVersion:
    db   $00

HeaderComplementCheck:
    db   $6C

HeaderGlobalChecksum:
    db   $47, $B7

toc_01_0150:
    call toc_01_2881
    ld   sp, $DFFF
    xor  a
    ld   [gbBGP], a
    ld   [gbOBP0], a
    ld   [gbOBP1], a
    ld   hl, gbVRAM
    ld   bc, $1800
    call toc_01_298A.loop_01_2999
    call toc_01_28A8
    call toc_01_298A
    ld   a, $01
    ld   [$2100], a
    call toc_01_7D19
    call $FFC0
    call toc_01_40CE
    call toc_01_2B6B
    ld   a, STATF_LYC | STATF_LYCF
    ld   [gbSTAT], a
    ld   a, 79
    ld   [gbLYC], a
    ld   a, $01
    ld   [$DBAF], a
    ld   a, IE_VBLANK
    ld   [gbIE], a
    ld   a, $01
    ld   [$2100], a
    call toc_01_460F
    ld   a, $1F
    ld   [$2100], a
    call toc_1F_4000
    ld   a, $18
    ld   [$FFB5], a
    ei
    jp   toc_01_03BD

toc_01_01A6:
    ld   a, $01
    ld   [$FFFD], a
    ld   a, [$C500]
    and  a
    jr   z, toc_01_01BE

    ld   a, [$DB95]
    cp   $0B
    jr   nz, toc_01_01BE

    ld   a, [$FFE7]
    rrca
    and  %10000000
    jr   toc_01_01C4

toc_01_01BE:
    ld   hl, $C156
    ld   a, [$FF97]
    add  a, [hl]
toc_01_01C4:
    ld   [gbSCY], a
    ld   a, [$FF96]
    ld   hl, $C155
    add  a, [hl]
    ld   hl, $C1BF
    add  a, [hl]
    ld   [gbSCX], a
    ld   a, [$D6FE]
    and  a
    jr   nz, toc_01_01DF

    ld   a, [$D6FF]
    cp   $00
    jr   z, toc_01_0209

toc_01_01DF:
    ld   a, [$DB95]
    cp   $09
    jr   z, toc_01_01F5

    cp   $06
    jr   c, toc_01_01F5

    cp   $0B
    jr   nz, toc_01_01FB

    ld   a, [$DB96]
    cp   $07
    jr   nc, toc_01_01FB

toc_01_01F5:
    call toc_01_0844
    call toc_01_0844
toc_01_01FB:
    di
    call toc_01_04A1
    ei
    call toc_01_0844
    call toc_01_0844
    jp   toc_01_03BD

toc_01_0209:
    ld   a, [$D6FD]
    and  LCDCF_BG_CHAR_8000 | LCDCF_BG_DISPLAY | LCDCF_BG_TILE_9C00 | LCDCF_OBJ_16_16 | LCDCF_OBJ_DISPLAY | LCDCF_TILEMAP_9C00 | LCDCF_WINDOW_ON
    ld   e, a
    ld   a, [gbLCDC]
    and  LCDCF_ON
    or   e
    ld   [gbLCDC], a
    ld   hl, $FFE7
    inc  [hl]
    ld   a, [$DB95]
    cp   $00
    jr   nz, toc_01_0230

    ld   a, [$DB96]
    cp   $08
    jr   c, toc_01_0230

    ld   a, $01
    ld   [$2100], a
    call toc_01_6DB7
toc_01_0230:
    ld   a, [$C17F]
    and  a
    jp   z, toc_01_0352

    inc  a
    jr   nz, toc_01_0245

toc_01_023A:
    ld   a, $17
    ld   [$2100], a
    call toc_17_46A6
    jp   toc_01_0352

toc_01_0245:
    inc  a
    jr   z, toc_01_023A

    ld   a, $14
    ld   [$2100], a
    ld   a, [$C180]
    inc  a
    ld   [$C180], a
    cp   $C0
    jr   nz, toc_01_026C

    ld   a, [$C17F]
    cp   $02
    jr   nz, toc_01_0262

    call toc_14_541B
toc_01_0262:
    xor  a
    ld   [$C17F], a
    ld   [$C3CA], a
    jp   toc_01_0352

toc_01_026C:
    cp   $60
    jr   c, toc_01_02BC

    push af
    and  %00000111
    jr   nz, toc_01_0280

    ld   a, [$C3CA]
    cp   $0C
    jr   z, toc_01_02BB

    inc  a
    ld   [$C3CA], a
toc_01_0280:
    ld   a, [$C3CA]
    ld   e, a
    ld   a, [$FFE7]
    and  %00000011
    add  a, e
    ld   e, a
    ld   d, $00
    ld   a, [$C17F]
    cp   $03
    jr   z, toc_01_02A8

    ld   hl, $546A
    add  hl, de
    ld   a, [hl]
    ld   [$DB97], a
    ld   [$DB99], a
    ld   hl, $547A
    add  hl, de
    ld   a, [hl]
    ld   [$DB98], a
    jr   toc_01_02BB

toc_01_02A8:
    ld   hl, $548A
    add  hl, de
    ld   a, [hl]
    ld   [$DB97], a
    ld   [$DB99], a
    ld   hl, $549A
    add  hl, de
    ld   a, [hl]
    ld   [$DB98], a
toc_01_02BB:
    pop  af
toc_01_02BC:
    srl  a
    srl  a
    ld   [$FFD7], a
    ld   a, [$C180]
    nop
    and  %11100000
    ld   e, a
    ld   a, [$C17F]
    cp   $03
    jr   nz, toc_01_02D4

    ld   a, e
    xor  %11100000
    ld   e, a
toc_01_02D4:
    ld   a, e
    ld   [$FFD8], a
    ld   hl, $C17C
    xor  a
    ldi  [hl], a
    ldi  [hl], a
    ldi  [hl], a
toc_01_02DE:
    ld   a, [gbSTAT]
    and  STATF_OAM | STATF_VB
    jr   nz, toc_01_02DE

    ld   d, $00
toc_01_02E6:
    ld   a, [$C17E]
    inc  a
    ld   [$C17E], a
    and  %00000001
    jr   nz, toc_01_02E6

    ld   a, [$C17C]
    add  a, $01
    ld   [$C17C], a
    ld   a, [$C17D]
    adc  $00
    ld   [$C17D], a
    ld   a, [$C17C]
    cp   $58
    jp   z, toc_01_033E

    ld   c, $00
    ld   a, [$C17F]
    cp   $01
    jr   z, toc_01_0313

    inc  c
toc_01_0313:
    ld   hl, $C17C
    ld   a, [$FFD7]
    add  a, [hl]
    and  %00011111
    ld   hl, $FFD8
    or   [hl]
    ld   e, a
    ld   hl, $54AA
    add  hl, de
    ld   a, [$C180]
    and  c
    ld   a, [hl]
    jr   z, toc_01_032D

    cpl
    inc  a
toc_01_032D:
    push af
    ld   hl, $FF96
    add  a, [hl]
    ld   [gbSCX], a
    pop  af
    ld   hl, $FF97
    add  a, [hl]
    ld   [gbSCY], a
    jp   toc_01_02DE

toc_01_033E:
    call toc_01_0844
    ld   a, [$DB97]
    ld   [gbBGP], a
    ld   a, [$DB98]
    ld   [gbOBP0], a
    ld   a, [$DB99]
    ld   [gbOBP1], a
    jr   toc_01_03BD

toc_01_0352:
    ld   a, [$DB9A]
    ld   [gbWY], a
    ld   a, [$DB97]
    ld   [gbBGP], a
    ld   a, [$DB98]
    ld   [gbOBP0], a
    ld   a, [$DB99]
    ld   [gbOBP1], a
    call toc_01_0844
    call toc_01_27FE
    ld   a, [$FF90]
    ld   hl, $FF91
    or   [hl]
    ld   hl, $C10E
    or   [hl]
    jr   nz, toc_01_03BD

    ld   a, [$0003]
    and  a
    jr   z, toc_01_03AA

    ld   a, [$D6FC]
    and  a
    jr   nz, toc_01_038A

    ld   a, [$FFCB]
    and  %00001111
    jr   z, toc_01_03A4

toc_01_038A:
    ld   a, [$FFCC]
    and  %01000000
    jr   z, toc_01_03A4

    ld   a, [$D6FC]
    xor  %00000001
    ld   [$D6FC], a
    jr   nz, toc_01_03BD

    ld   a, [$C17B]
    xor  %00010000
    ld   [$C17B], a
    jr   toc_01_03BD

toc_01_03A4:
    ld   a, [$D6FC]
    and  a
    jr   nz, toc_01_03BD

toc_01_03AA:
    ld   a, $01
    call toc_01_07B9
    call toc_01_5CF0
    call toc_01_0A90
    ld   a, $01
    ld   [$2100], a
    call toc_01_5D03
toc_01_03BD:
    ld   a, $1F
    ld   [$2100], a
    call toc_1F_7F80
    ld   a, $0C
    ld   [$2100], a
    xor  a
    ld   [$FFFD], a
    halt
toc_01_03CE:
    ld   a, [$FFD1]
    and  a
    jr   z, toc_01_03CE

    xor  a
    ld   [$FFD1], a
    jp   toc_01_01A6

    db   $20, $30, $40, $60, $00, $30, $56, $68
    db   $00

toc_01_03E2:
    di
    push af
    push hl
    push de
    ld   a, [$DB95]
    cp   $01
    jr   nz, toc_01_0400

    ld   a, [$DB96]
    cp   $05
    jr   nz, toc_01_03F9

    ld   a, [$D000]
    jr   toc_01_03FB

toc_01_03F9:
    ld   a, [$FF97]
toc_01_03FB:
    ld   [gbSCY], a
    jp   toc_01_0452

toc_01_0400:
    cp   $00
    jr   nz, toc_01_044F

    ld   a, [$C105]
    ld   e, a
    ld   d, $00
    ld   hl, $C100
    add  hl, de
    ld   a, [hl]
    ld   hl, $FF96
    add  a, [hl]
    ld   [gbSCX], a
    ld   a, [$DB96]
    cp   $06
    jr   c, toc_01_042C

    ld   hl, $03DE
    add  hl, de
    ld   a, [hl]
    ld   [gbLYC], a
    ld   a, e
    inc  a
    and  %00000011
    ld   [$C105], a
    jr   toc_01_0452

toc_01_042C:
    ld   hl, $03D9
    add  hl, de
    ld   a, [hl]
    ld   [gbLYC], a
    ld   a, e
    inc  a
    cp   $05
    jr   nz, toc_01_043A

    xor  a
toc_01_043A:
    ld   [$C105], a
    nop
    cp   $04
    jr   nz, toc_01_044D

    ld   a, [$C106]
    ld   [gbSCY], a
    cpl
    inc  a
    add  a, 96
    ld   [gbLYC], a
toc_01_044D:
    jr   toc_01_0452

toc_01_044F:
    xor  a
    ld   [gbSCX], a
toc_01_0452:
    pop  de
    pop  hl
    pop  af
    ei
    reti


    db   $00, $00, $A5, $62, $13, $73, $0F, $6F
    db   $01, $6F, $1E, $70, $54, $71, $51, $D6
    db   $C2, $6E, $93, $73, $59, $75, $C0, $74
    db   $2B, $72, $37, $76, $B7, $76, $00, $78
    db   $0B, $7A, $8A, $7B, $AF, $54, $70, $56
    db   $81, $6E, $10, $53, $65, $63, $CE, $66
    db   $A1, $67, $E5, $68, $34, $6A, $20, $6B
    db   $DD, $6B, $DD, $6B, $73, $5A, $29, $5C
    db   $C8, $5D, $67, $5F, $06, $61, $0E, $58
    db   $AD, $59

toc_01_04A1:
    ld   a, [$D6FE]
    and  a
    jr   z, toc_01_04F5

    push af
    call toc_01_2881
    pop  af
    call toc_01_04B1
    jr   toc_01_0516

toc_01_04B1:
    dec  a
    rst  $00
    db   $6C, $2E, $A8, $28, $6B, $2B, $9F, $2B
    db   $7E, $2C, $C4, $2B, $7E, $2C, $A1, $28
    db   $88, $2D, $22, $05, $01, $2D, $22, $05
    db   $73, $2D, $DB, $37, $98, $28, $C2, $2C
    db   $F0, $2C, $28, $2D, $56, $2D, $1E, $2D
    db   $26, $2A, $A2, $2A, $9D, $2A, $98, $2A
    db   $F7, $2A, $F2, $2A, $BF, $2A, $F2, $2A
    db   $65, $2A, $FA, $29, $17, $2A, $23, $2D
    db   $39, $2D

toc_01_04F5:
    call toc_01_2881
    ld   hl, $0457
    ld   b, $00
    ld   a, [$D6FF]
    sla  a
    ld   c, a
    add  hl, bc
    ld   a, [hl]
    ld   e, a
    inc  hl
    ld   a, [hl]
    ld   d, a
    ld   a, $08
    ld   [$2100], a
    call toc_01_28D8.toc_01_28DE
    ld   a, $0C
    ld   [$2100], a
toc_01_0516:
    xor  a
    ld   [$D6FF], a
    ld   [$D6FE], a
    ld   a, [$D6FD]
    ld   [gbLCDC], a
    ret


    db   $07, $09

toc_01_0525:
    push af
    push bc
    push de
    push hl
    di
    ld   a, [$FFFD]
    and  a
    jp   nz, toc_01_05B6

    ld   a, [$C19F]
    and  %01111111
    jr   z, toc_01_0566

    cp   $01
    jr   z, toc_01_0566

    cp   $05
    jr   nc, toc_01_0548

    call toc_01_21DF
    ld   hl, $C19F
    inc  [hl]
    jr   toc_01_05B6

toc_01_0548:
    cp   $0A
    jr   nz, toc_01_0551

    call toc_01_25A5
    jr   toc_01_05B6

toc_01_0551:
    cp   $0B
    jr   nz, toc_01_0566

    ld   a, [$C172]
    and  a
    jr   z, toc_01_0561

    dec  a
    ld   [$C172], a
    jr   toc_01_0566

toc_01_0561:
    call toc_01_25F9
    jr   toc_01_05B6

toc_01_0566:
    ld   a, [$D6FE]
    and  a
    jr   nz, toc_01_05B6

    ld   a, [$FF90]
    ld   [$FFE8], a
    ld   hl, $FF91
    or   [hl]
    ld   hl, $C10E
    or   [hl]
    jr   z, toc_01_058B

    call toc_01_05C0
    ld   a, [$FFE8]
    cp   $08
    jr   nc, toc_01_0586

toc_01_0583:
    call toc_01_1CCC
toc_01_0586:
    call $FFC0
    jr   toc_01_05B6

toc_01_058B:
    ld   a, [$FFBB]
    and  a
    jr   z, toc_01_05A3

    dec  a
    ld   [$FFBB], a
    ld   e, a
    ld   d, $00
    ld   hl, $0523
    add  hl, de
    ld   a, [hl]
    ld   [$D6F8], a
    call toc_01_1DEE
    jr   toc_01_0583

toc_01_05A3:
    call toc_01_1AA9
    ld   de, $D601
    call toc_01_28D8
    xor  a
    ld   [$D600], a
    ld   [$D601], a
    call $FFC0
toc_01_05B6:
    ei
    pop  hl
    pop  de
    pop  bc
    ld   a, $01
    ld   [$FFD1], a
    pop  af
    reti


toc_01_05C0:
    ld   a, [$FF90]
    and  a
    jp   z, .toc_01_0688

    cp   $07
    jp   z, .toc_01_0760

    cp   $03
    jp   z, toc_01_0062

    cp   $04
    jp   z, toc_01_006A

    cp   $05
    jp   z, toc_01_0072

    cp   $06
    jp   z, toc_01_007A

    cp   $08
    jp   nc, toc_01_0783

    ld   a, [$DBA5]
    and  a
    jr   z, .else_01_0643

    ld   a, [$FF90]
    cp   $02
    jp   z, toc_01_07C9

    ld   a, $0D
    ld   [$2100], a
    ld   a, [$FF92]
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    ld   hl, $9000
    add  hl, bc
    push hl
    pop  de
    ld   hl, $5000
    ld   a, [$FF94]
    add  a, $50
    ld   h, a
    add  hl, bc
    ld   a, [$FFBB]
    and  a
    jr   z, .else_01_062E

    ld   a, [$FF92]
    dec  a
    cp   $02
    jr   c, .else_01_0634

toc_01_05C0.else_01_062E:
    ld   bc, $0040
    call toc_01_28C5
toc_01_05C0.else_01_0634:
    ld   a, [$FF92]
    inc  a
    ld   [$FF92], a
    cp   $04
    jr   nz, .return_01_0642

    xor  a
    ld   [$FF90], a
    ld   [$FF92], a
toc_01_05C0.return_01_0642:
    ret


toc_01_05C0.else_01_0643:
    ld   hl, $2100
    ld   [hl], $0F
    ld   a, [$FF92]
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    ld   hl, $9000
    add  hl, bc
    push hl
    pop  de
    ld   a, [$FF94]
    add  a, $40
    ld   h, a
    ld   l, $00
    add  hl, bc
    ld   bc, $0040
    call toc_01_28C5
    ld   a, [$FF92]
    inc  a
    ld   [$FF92], a
    cp   $08
    jr   nz, .return_01_0687

    xor  a
    ld   [$FF90], a
    ld   [$FF92], a
toc_01_05C0.return_01_0687:
    ret


toc_01_05C0.toc_01_0688:
    ld   a, [$FF91]
    and  a
    jr   z, .else_01_06F4

    ld   a, [$C197]
    ld   e, a
    ld   d, $00
    ld   hl, $C193
    add  hl, de
    ld   a, [hl]
    push af
    and  %00111111
    ld   d, a
    ld   e, $00
    pop  af
    swap a
    rra
    rra
    and  %00000011
    ld   c, a
    ld   b, $00
    ld   hl, $2D84
    add  hl, bc
    ld   a, [hl]
    ld   [$2100], a
    ld   a, [$FF93]
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    ld   hl, $4000
    add  hl, bc
    add  hl, de
    push hl
    ld   a, [$C197]
    ld   d, a
    ld   hl, $8400
    add  hl, bc
    add  hl, de
    push hl
    pop  de
    pop  hl
    ld   bc, $0040
    call toc_01_28C5
    ld   a, [$FF93]
    inc  a
    ld   [$FF93], a
    cp   $04
    jr   nz, .return_01_06F3

    xor  a
    ld   [$FF91], a
    ld   [$FF93], a
toc_01_05C0.return_01_06F3:
    ret


toc_01_05C0.else_01_06F4:
    ld   a, [$C10D]
    ld   e, a
    ld   d, $00
    ld   hl, $C193
    add  hl, de
    ld   a, [hl]
    push af
    and  %00111111
    ld   d, a
    ld   e, $00
    pop  af
    swap a
    rra
    rra
    and  %00000011
    ld   c, a
    ld   b, $00
    ld   hl, $2D84
    add  hl, bc
    ld   a, [hl]
    ld   [$2100], a
    ld   a, [$C10F]
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    ld   hl, $4000
    add  hl, bc
    add  hl, de
    push hl
    ld   a, [$C10D]
    ld   d, a
    ld   hl, $8400
    add  hl, bc
    add  hl, de
    push hl
    pop  de
    pop  hl
    ld   bc, $0040
    call toc_01_28C5
    ld   a, [$C10F]
    inc  a
    ld   [$C10F], a
    cp   $04
    jr   nz, .return_01_075F

    xor  a
    ld   [$C10E], a
    ld   [$C10F], a
toc_01_05C0.return_01_075F:
    ret


toc_01_05C0.toc_01_0760:
    ld   a, $01
    ld   [$2100], a
    call toc_01_7BC5
    jp   toc_01_008B

    db   $60, $69, $A0, $69, $C0, $69, $00, $42
    db   $40, $42, $60, $42, $00, $82, $40, $82
    db   $60, $82, $00, $82, $40, $82, $60, $82

toc_01_0783:
    sub  a, $08
    sla  a
    ld   e, a
    ld   d, $00
    ld   hl, $076B
    add  hl, de
    push hl
    ld   hl, $0777
    add  hl, de
    ld   e, [hl]
    inc  hl
    ld   d, [hl]
    pop  hl
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   a, $0C
    ld   [$2100], a
    ld   bc, $0040
    call toc_01_28C5
    ld   a, [$FF90]
    cp   $0A
    jr   z, toc_01_07B5

    cp   $0D
    jr   z, toc_01_07B5

    ld   a, [$FF90]
    inc  a
    ld   [$FF90], a
    ret


toc_01_07B5:
    xor  a
    ld   [$FF90], a
    ret


toc_01_07B9:
    ld   [$2100], a
    ld   [$DBAF], a
    ret


    db   $F5, $FA, $AF, $DB, $EA, $00, $21, $F1
    db   $C9

toc_01_07C9:
    ld   a, $12
    ld   [$2100], a
    ld   a, [$FF92]
    cp   $08
    jr   c, toc_01_0813

    jr   nz, toc_01_07E3

    ld   a, $02
    ld   [$2100], a
    call toc_02_6BB8
    ld   hl, $FF92
    inc  [hl]
    ret


toc_01_07E3:
    cp   $09
    jr   nz, toc_01_07F4

    ld   a, $02
    ld   [$2100], a
    call toc_02_6B92
    ld   hl, $FF92
    inc  [hl]
    ret


toc_01_07F4:
    cp   $0A
    jr   nz, toc_01_0805

    ld   a, $02
    ld   [$2100], a
    call toc_02_6B6C
    ld   hl, $FF92
    inc  [hl]
    ret


toc_01_0805:
    ld   a, $02
    ld   [$2100], a
    call toc_02_6B46
    xor  a
    ld   [$FF90], a
    ld   [$FF92], a
    ret


toc_01_0813:
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    ld   hl, $8D00
    add  hl, bc
    push hl
    pop  de
    ld   hl, $7E00
    add  hl, bc
    ld   bc, $0040
    call toc_01_28C5
    ld   a, [$FF92]
    inc  a
    ld   [$FF92], a
    ret


toc_01_0844:
    ld   a, $1F
    ld   [$2100], a
    call toc_1F_4006
    ld   a, [$FFF3]
    and  a
    jr   nz, .return_01_0876

    ld   a, [$C10B]
    and  a
    jr   z, .else_01_0866

    cp   $02
    jr   nz, .else_01_0863

    ld   a, [$FFE7]
    and  %00000001
    jr   nz, .return_01_0876

    jr   .else_01_0866

toc_01_0844.else_01_0863:
    call .else_01_0866
toc_01_0844.else_01_0866:
    ld   a, $1B
    ld   [$2100], a
    call toc_1B_4006
    ld   a, $1E
    ld   [$2100], a
    call toc_1E_4006
toc_01_0844.return_01_0876:
    ret


    db   $FF, $FF, $FF, $FF, $FF, $3E, $02, $EA
    db   $00, $21, $CD, $EF, $19, $C3, $C0, $07
    db   $21, $50, $C4, $18, $08, $21, $F0, $C2
    db   $18, $03, $21, $E0, $C2, $09, $7E, $A7
    db   $C9, $3E, $AF, $CD, $01, $3C, $F0, $98
    db   $21, $00, $C2, $19, $77, $F0, $99, $21
    db   $10, $C2, $19, $77, $C9, $3E, $1D, $E0
    db   $F2, $C9, $21, $E1, $45, $18, $03, $21
    db   $E1, $46, $3E, $1C, $EA, $00, $21, $09
    db   $7E, $21, $00, $21, $36, $01, $C9

toc_01_08C6:
    ld   a, $0C
    ld   [$2100], a
    ld   bc, $0040
    call toc_01_28C5
    ld   a, $01
    ld   [$2100], a
    ret


    db   $21, $F4, $FF, $36, $0C, $21, $02, $C5
    db   $36, $04, $C9, $21, $10, $C4, $09, $7E
    db   $A7, $28, $01, $35, $C9, $F5, $FA, $8F
    db   $C1, $A7, $20, $14, $EA, $CF, $C1, $3C
    db   $EA, $8F, $C1, $EA, $A6, $C5, $FA, $9D
    db   $C1, $A7, $20, $04, $3E, $02, $E0, $F2
    db   $F1, $C9, $3E, $30, $E0, $A8, $18, $17
    db   $3E, $30, $E0, $A8, $18, $15, $FA, $01
    db   $D4, $FE, $01, $20, $ED, $FA, $A5, $DB
    db   $A7, $28, $E7, $3E, $01, $E0, $BC, $3E
    db   $06, $E0, $F4, $3E, $03, $EA, $1C, $C1
    db   $AF, $EA, $6B, $C1, $EA, $6C, $C1, $EA
    db   $78, $D4, $A7, $C9, $AF, $EA, $21, $C1
    db   $EA, $22, $C1, $AF, $EA, $4B, $C1, $EA
    db   $4A, $C1, $C9, $F0, $9F, $E0, $98, $F0
    db   $A0, $E0, $99, $C9, $F5, $1E, $0F, $16
    db   $00, $21, $10, $C5, $19, $7E, $A7, $28
    db   $18, $1D, $7B, $FE, $FF, $20, $F2, $21
    db   $C0, $C5, $35, $7E, $FE, $FF, $20, $05
    db   $3E, $0F, $EA, $C0, $C5, $FA, $C0, $C5
    db   $5F, $F1, $21, $10, $C5, $19, $77, $F0
    db   $D8, $21, $40, $C5, $19, $77, $F0, $D7
    db   $21, $30, $C5, $19, $77, $21, $20, $C5
    db   $19, $36, $0F, $C9, $FA, $40, $C1, $D6
    db   $08, $E0, $D7, $FA, $42, $C1, $D6, $08
    db   $E0, $D8, $3E, $07, $E0, $F2, $3E, $05
    db   $C3, $53, $09, $3E, $08, $EA, $00, $21
    db   $FA, $A5, $DB, $A7, $28, $27, $F0, $F6
    db   $5F, $16, $00, $21, $40, $40, $F0, $F7
    db   $FE, $1A, $30, $05, $FE, $06, $38, $01
    db   $24, $19, $F0, $94, $5F, $7E, $BB, $28
    db   $0A, $E0, $94, $FE, $FF, $28, $04, $3E
    db   $01, $E0, $90, $18, $2D, $F0, $F6, $FE
    db   $07, $20, $01, $3C, $57, $CB, $3F, $CB
    db   $3F, $E6, $F8, $5F, $7A, $CB, $3F, $E6
    db   $07, $B3, $5F, $16, $00, $21, $00, $40
    db   $19, $F0, $94, $5F, $7E, $BB, $28, $0A
    db   $FE, $0F, $28, $06, $E0, $94, $3E, $01
    db   $E0, $90, $AF, $E0, $D7, $F0, $F6, $5F
    db   $16, $00, $21, $40, $42, $FA, $A5, $DB
    db   $57, $F0, $F7, $FE, $1A, $30, $05, $FE
    db   $06, $38, $01, $14, $19, $5E, $7A, $A7
    db   $20, $1A, $7B, $FE, $23, $20, $08, $FA
    db   $C9, $D8, $E6, $20, $28, $01, $1C, $7B
    db   $FE, $21, $20, $08, $FA, $FD, $D8, $E6
    db   $20, $28, $01, $1C, $16, $00, $CB, $23
    db   $CB, $12, $CB, $23, $CB, $12, $21, $40
    db   $45, $FA, $A5, $DB, $A7, $28, $03, $21
    db   $88, $47, $19, $16, $00, $01, $93, $C1
    db   $5E, $0A, $BB, $28, $21, $7B, $FE, $FF
    db   $28, $1C, $02, $F0, $D7, $A7, $28, $0B
    db   $7A, $EA, $0D, $C1, $3E, $01, $EA, $0E
    db   $C1, $18, $0B, $3C, $E0, $D7, $7A, $EA
    db   $97, $C1, $3E, $01, $E0, $91, $23, $03
    db   $14, $7A, $FE, $04, $20, $D2, $C3, $C0
    db   $07

toc_01_0A90:
    ld   a, [$DB95]
    cp   $07
    jr   c, .else_01_0ACE

    cp   $0B
    jr   nz, .else_01_0AA2

    ld   a, [$DB96]
    cp   $07
    jr   nz, .else_01_0ACE

toc_01_0A90.else_01_0AA2:
    ld   a, [$C16B]
    cp   $04
    jr   nz, .else_01_0ACE

    ld   a, [$C19F]
    ld   hl, $C167
    or   [hl]
    ld   hl, $C124
    or   [hl]
    jr   nz, .else_01_0ACE

    ld   a, [$FFCB]
    cp   $F0
    jr   nz, .else_01_0ACE

    xor  a
    ld   [$C16B], a
    ld   [$C16C], a
    ld   [$C19F], a
    ld   [$DB96], a
    ld   a, $06
    ld   [$DB95], a
toc_01_0A90.else_01_0ACE:
    ld   a, [$DB95]
    rst  $00
    db   $05, $0B, $08, $0B, $34, $0B, $37, $0B
    db   $3A, $0B, $3D, $0B, $02, $0B, $FC, $0A
    db   $F0, $0A, $F6, $0A, $EA, $0A, $40, $0B
    db   $CD, $BC, $67, $C3, $32, $0C, $CD, $4C
    db   $65, $C3, $32, $0C, $CD, $BB, $5F, $C3
    db   $32, $0C, $CD, $6E, $54, $C3, $32, $0C
    db   $C3, $00, $40, $C3, $3E, $6E, $3E, $17
    db   $CD, $B9, $07, $CD, $2A, $48, $C3, $32
    db   $0C, $3E, $03, $EA, $00, $21, $3E, $17
    db   $F5, $CD, $43, $38, $F1, $C3, $B9, $07
    db   $3E, $03, $EA, $00, $21, $3E, $01, $18
    db   $EF, $3E, $03, $EA, $00, $21, $3E, $02
    db   $18, $E6, $C3, $11, $47, $C3, $4B, $49
    db   $C3, $E6, $4B, $C3, $34, $4E, $3E, $14
    db   $EA, $00, $21, $CD, $26, $53, $CD, $3C
    db   $52, $3E, $01, $CD, $B9, $07, $C3, $1E
    db   $43, $3E, $02, $CD, $B9, $07, $FA, $9F
    db   $C1, $A7, $20, $3C, $21, $B4, $FF, $7E
    db   $A7, $28, $1B, $FA, $9A, $DB, $FE, $80
    db   $20, $14, $FA, $4F, $C1, $A7, $20, $0E
    db   $35, $20, $0B, $3E, $01, $EA, $00, $21
    db   $CD, $A6, $5F, $CD, $C0, $07, $FA, $9F
    db   $C1, $A7, $20, $14, $FA, $BC, $C1, $A7
    db   $28, $0E, $21, $A1, $FF, $36, $02, $3D
    db   $EA, $BC, $C1, $20, $03, $C3, $09, $09
    db   $21, $C7, $DB, $7E, $A7, $28, $01, $35
    db   $F0, $98, $E0, $9F, $F0, $99, $E0, $A0
    db   $21, $A2, $FF, $96, $E0, $B3, $CD, $D5
    db   $5D, $AF, $EA, $40, $C1, $EA, $3C, $C1
    db   $EA, $3B, $C1, $21, $1D, $C1, $CB, $BE
    db   $21, $1E, $C1, $CB, $BE, $CD, $31, $57
    db   $3E, $02, $CD, $B9, $07, $CD, $55, $26
    db   $CD, $40, $0C, $FA, $5C, $C1, $EA, $CF
    db   $C3, $AF, $EA, $4E, $C1, $EA, $4D, $C1
    db   $EA, $A4, $C1, $EA, $5C, $C1, $EA, $AE
    db   $C1, $FA, $44, $C1, $A7, $28, $04, $3D
    db   $EA, $44, $C1, $3E, $19, $CD, $B9, $07
    db   $CD, $97, $76, $CD, $43, $38, $3E, $02
    db   $CD, $B9, $07, $CD, $9A, $52, $21, $01
    db   $D6, $F0, $E7, $E6, $03, $B6, $20, $18
    db   $FA, $1C, $C1, $FE, $02, $30, $11, $0E
    db   $01, $06, $00, $1E, $00, $F0, $E7, $E6
    db   $04, $28, $02, $0D, $1D, $CD, $ED, $61
    db   $3E, $14, $CD, $B9, $07, $CD, $B0, $59
    db   $3E, $0F, $CD, $B9, $07, $CD, $33, $21
    db   $C9, $08, $0E, $99, $28, $EC, $F0, $99
    db   $21, $A2, $FF, $96, $EA, $45, $C1, $FA
    db   $A9, $C1, $A7, $28, $3D, $FA, $9F, $C1
    db   $A7, $20, $25, $21, $AA, $C1, $35, $7E
    db   $FE, $02, $20, $10, $FA, $A9, $C1, $5F
    db   $16, $00, $21, $3A, $0C, $19, $7E, $CD
    db   $97, $21, $3E, $01, $A7, $20, $09, $AF
    db   $EA, $A9, $C1, $EA, $A8, $C1, $18, $12
    db   $FA, $A9, $C1, $EA, $A8, $C1, $3D, $C7
    db   $18, $50, $23, $50, $23, $50, $23, $50
    db   $18, $50, $F0, $CB, $E6, $B0, $20, $4C
    db   $F0, $CB, $E6, $40, $28, $46, $FA, $5F
    db   $D4, $3C, $EA, $5F, $D4, $FE, $04, $38
    db   $3F, $F0, $A1, $FE, $02, $28, $35, $F0
    db   $9D, $FE, $FF, $28, $2F, $FA, $1C, $C1
    db   $FE, $02, $30, $28, $21, $67, $C1, $FA
    db   $9F, $C1, $B6, $20, $1F, $AF, $EA, $6B
    db   $C1, $EA, $6C, $C1, $EA, $96, $DB, $3E
    db   $07, $EA, $95, $DB, $3E, $02, $EA, $00
    db   $21, $CD, $1B, $78, $CD, $CC, $1C, $CD
    db   $43, $38, $F1, $C9, $AF, $EA, $5F, $D4
    db   $F0, $B7, $A7, $28, $03, $3D, $E0, $B7
    db   $F0, $B6, $A7, $28, $03, $3D, $E0, $B6
    db   $FA, $9F, $C1, $A7, $C2, $9B, $14, $FA
    db   $24, $C1, $A7, $C2, $49, $0D, $FA, $1C
    db   $C1, $FE, $07, $28, $2B, $FA, $5A, $DB
    db   $21, $0A, $C5, $B6, $21, $4F, $C1, $B6
    db   $20, $1B, $3E, $07, $EA, $1C, $C1, $3E
    db   $BF, $E0, $B7, $3E, $10, $EA, $CC, $C3
    db   $AF, $EA, $C7, $DB, $E0, $9C, $CD, $D2
    db   $27, $3E, $08, $E0, $F3, $FA, $1C, $C1
    db   $C7, $5F, $0D, $92, $4D, $0E, $49, $B3
    db   $15, $32, $17, $00, $4D, $30, $4F, $57
    db   $0D, $A2, $50, $4F, $0D, $FF, $4E, $CD
    db   $9B, $14, $C3, $CC, $1C, $3E, $19, $CD
    db   $B9, $07, $C3, $A9, $5C, $3E, $01, $CD
    db   $B9, $07, $C3, $84, $41, $3E, $02, $CD
    db   $B9, $07, $CD, $6E, $42, $C9, $FA, $0A
    db   $C5, $21, $67, $C1, $B6, $21, $A4, $C1
    db   $B6, $C0, $FA, $4A, $C1, $A7, $28, $33
    db   $FA, $01, $DB, $FE, $01, $28, $1A, $FA
    db   $00, $DB, $FE, $01, $28, $13, $FA, $01
    db   $DB, $FE, $04, $28, $07, $FA, $00, $DB
    db   $FE, $04, $20, $15, $CD, $34, $0F, $18
    db   $10, $FA, $37, $C1, $3D, $FE, $04, $38
    db   $08, $3E, $05, $EA, $37, $C1, $EA, $6A
    db   $C1, $18, $07, $AF, $EA, $5B, $C1, $EA
    db   $5A, $C1, $FA, $17, $C1, $A7, $C2, $D0
    db   $0E, $FA, $5C, $C1, $A7, $C2, $D0, $0E
    db   $FA, $37, $C1, $A7, $28, $0B, $FE, $03
    db   $20, $07, $FA, $38, $C1, $FE, $03, $30
    db   $06, $F0, $A1, $A7, $C2, $D0, $0E, $FA
    db   $00, $DB, $FE, $08, $20, $0F, $F0, $CB
    db   $E6, $20, $28, $05, $CD, $0C, $14, $18
    db   $04, $AF, $EA, $4B, $C1, $FA, $01, $DB
    db   $FE, $08, $20, $0F, $F0, $CB, $E6, $10
    db   $28, $05, $CD, $0C, $14, $18, $04, $AF
    db   $EA, $4B, $C1, $FA, $01, $DB, $FE, $04
    db   $20, $1A, $FA, $44, $DB, $EA, $5A, $C1
    db   $F0, $CB, $E6, $10, $28, $0E, $FA, $AD
    db   $C1, $FE, $01, $28, $07, $FE, $02, $28
    db   $03, $CD, $34, $0F, $FA, $00, $DB, $FE
    db   $04, $20, $0F, $FA, $44, $DB, $EA, $5A
    db   $C1, $F0, $CB, $E6, $20, $28, $03, $CD
    db   $34, $0F, $F0, $CC, $E6, $20, $28, $0D
    db   $FA, $AD, $C1, $FE, $02, $28, $06, $FA
    db   $00, $DB, $CD, $7F, $0E, $F0, $CC, $E6
    db   $10, $28, $11, $FA, $AD, $C1, $FE, $01
    db   $28, $0A, $FE, $02, $28, $06, $FA, $01
    db   $DB, $CD, $7F, $0E, $F0, $CB, $E6, $20
    db   $28, $06, $FA, $00, $DB, $CD, $05, $0F
    db   $F0, $CB, $E6, $10, $28, $06, $FA, $01
    db   $DB, $CD, $05, $0F, $C9, $4F, $FE, $01
    db   $CA, $2F, $12, $FE, $04, $CA, $D1, $0E
    db   $FE, $02, $CA, $76, $0F, $FE, $03, $CA
    db   $07, $10, $FE, $05, $CA, $79, $10, $FE
    db   $0D, $CA, $0E, $10, $FE, $06, $CA, $FC
    db   $0E, $FE, $0A, $CA, $D1, $11, $FE, $09
    db   $CA, $E6, $41, $FE, $0C, $CA, $51, $11
    db   $FE, $0B, $CA, $DB, $0E, $FE, $07, $20
    db   $15, $21, $37, $C1, $FA, $9B, $C1, $B6
    db   $20, $0C, $FA, $4D, $C1, $FE, $02, $30
    db   $05, $3E, $8E, $EA, $9B, $C1, $C9, $FA
    db   $44, $C1, $A7, $C0, $3E, $16, $E0, $F4
    db   $C9, $FA, $C7, $C1, $21, $46, $C1, $B6
    db   $C0, $CD, $35, $4C, $30, $06, $3E, $07
    db   $E0, $F2, $18, $04, $3E, $0E, $E0, $F4
    db   $3E, $01, $EA, $C7, $C1, $AF, $EA, $C8
    db   $C1, $C9, $FA, $A4, $C1, $A7, $C0, $CD
    db   $3B, $42, $C9, $FE, $01, $C0, $21, $37
    db   $C1, $FA, $AD, $C1, $E6, $03, $B6, $C0
    db   $FA, $60, $C1, $A7, $C0, $AF, $EA, $AC
    db   $C1, $3E, $05, $EA, $37, $C1, $EA, $B0
    db   $C5, $C9, $10, $00, $08, $08, $03, $03
    db   $08, $08, $08, $08, $00, $0D, $08, $08
    db   $03, $04, $3E, $01, $EA, $5B, $C1, $FA
    db   $44, $DB, $EA, $5A, $C1, $F0, $9E, $5F
    db   $16, $00, $21, $24, $0F, $19, $F0, $98
    db   $86, $EA, $40, $C1, $21, $28, $0F, $19
    db   $7E, $EA, $41, $C1, $21, $2C, $0F, $19
    db   $FA, $45, $C1, $86, $EA, $42, $C1, $21
    db   $30, $0F, $19, $7E, $EA, $43, $C1, $AF
    db   $EA, $B0, $C5, $C9, $08, $F8, $00, $00
    db   $00, $00, $FD, $04, $FA, $4E, $C1, $FE
    db   $01, $D0, $FA, $4D, $DB, $A7, $CA, $AC
    db   $08, $D6, $01, $27, $EA, $4D, $DB, $3E
    db   $02, $CD, $EB, $10, $D8, $21, $F0, $C2
    db   $19, $36, $10, $FA, $C0, $C1, $A7, $CA
    db   $AC, $0F, $AF, $EA, $C0, $C1, $FA, $C2
    db   $C1, $4F, $42, $21, $90, $C2, $09, $36
    db   $01, $C9, $3E, $06, $EA, $C0, $C1, $7B
    db   $EA, $C1, $C1, $3E, $0C, $EA, $9B, $C1
    db   $21, $E0, $C2, $19, $36, $A0, $21, $B0
    db   $C3, $19, $72, $21, $80, $C4, $19, $36
    db   $03, $F0, $F9, $A7, $20, $06, $3E, $09
    db   $E0, $F2, $18, $05, $21, $10, $C3, $19
    db   $72, $21, $40, $C2, $19, $72, $21, $50
    db   $C2, $19, $72, $21, $20, $C3, $19, $72
    db   $F0, $9E, $4F, $42, $21, $6E, $0F, $09
    db   $F0, $98, $86, $21, $00, $C2, $19, $77
    db   $21, $72, $0F, $09, $F0, $99, $86, $21
    db   $10, $C2, $19, $77, $C9, $C9, $18, $E8
    db   $00, $E8, $18, $00, $FA, $4D, $C1, $A7
    db   $C0, $3E, $01, $CD, $EB, $10, $D8, $21
    db   $E0, $C2, $19, $36, $28, $0E, $04, $06
    db   $00, $F0, $CB, $CB, $3F, $30, $01, $04
    db   $0D, $20, $F8, $78, $FE, $02, $38, $26
    db   $F0, $CB, $E6, $03, $4F, $06, $00, $21
    db   $07, $10, $09, $7E, $21, $40, $C2, $19
    db   $77, $F0, $CB, $CB, $3F, $CB, $3F, $E6
    db   $03, $4F, $06, $00, $21, $0A, $10, $09
    db   $7E, $21, $50, $C2, $19, $77, $C9, $00
    db   $00, $00, $00, $00, $00, $00, $00, $20
    db   $E0, $00, $00, $00, $00, $E0, $20, $30
    db   $D0, $00, $00, $40, $C0, $00, $00, $00
    db   $00, $D0, $30, $00, $00, $C0, $40, $FA
    db   $4C, $C1, $A7, $C0, $FA, $4D, $C1, $FE
    db   $02, $30, $65, $3E, $10, $EA, $4C, $C1
    db   $FA, $45, $DB, $A7, $CA, $AC, $08, $D6
    db   $01, $27, $EA, $45, $DB, $CD, $83, $12
    db   $3E, $00, $CD, $EB, $10, $D8, $7B, $EA
    db   $C2, $C1, $FA, $C0, $C1, $A7, $28, $13
    db   $FA, $C1, $C1, $4F, $42, $21, $80, $C2
    db   $09, $70, $21, $90, $C2, $19, $36, $01
    db   $AF, $18, $06, $3E, $0A, $E0, $F4, $3E
    db   $06, $EA, $C0, $C1, $F0, $9E, $4F, $06
    db   $00, $FA, $7C, $D4, $FE, $01, $20, $04
    db   $79, $C6, $04, $4F, $21, $69, $10, $09
    db   $7E, $21, $40, $C2, $19, $77, $21, $71
    db   $10, $09, $7E, $21, $50, $C2, $19, $77
    db   $C9, $CD, $01, $3C, $D8, $3E, $0C, $EA
    db   $9B, $C1, $C5, $F0, $9E, $4F, $06, $00
    db   $21, $59, $10, $09, $F0, $98, $86, $21
    db   $00, $C2, $19, $77, $21, $5D, $10, $09
    db   $F0, $99, $86, $21, $10, $C2, $19, $77
    db   $F0, $A2, $3C, $21, $10, $C3, $19, $77
    db   $21, $61, $10, $09, $7E, $21, $40, $C2
    db   $19, $77, $21, $65, $10, $09, $7E, $21
    db   $50, $C2, $19, $77, $F0, $9E, $21, $B0
    db   $C3, $19, $77, $21, $80, $C3, $19, $77
    db   $21, $D0, $C5, $19, $77, $21, $F0, $C4
    db   $19, $36, $01, $C1, $37, $3F, $C9, $0E
    db   $F2, $00, $00, $00, $00, $F4, $0C, $FA
    db   $9B, $C1, $A7, $C0, $FA, $4B, $DB, $A7
    db   $28, $0F, $F0, $A2, $A7, $C0, $3E, $02
    db   $EA, $A9, $C1, $3E, $2A, $EA, $AA, $C1
    db   $C9, $FA, $4C, $DB, $A7, $CA, $AC, $08
    db   $3E, $08, $CD, $01, $3C, $D8, $3E, $05
    db   $E0, $F2, $3E, $0E, $EA, $9B, $C1, $FA
    db   $4C, $DB, $D6, $01, $27, $EA, $4C, $DB
    db   $20, $12, $21, $00, $DB, $7E, $FE, $0C
    db   $20, $02, $36, $00, $23, $7E, $FE, $0C
    db   $20, $02, $36, $00, $C5, $F0, $9E, $4F
    db   $21, $49, $11, $09, $F0, $98, $86, $21
    db   $00, $C2, $19, $77, $21, $4D, $11, $09
    db   $F0, $99, $86, $21, $10, $C2, $19, $77
    db   $F0, $A2, $21, $10, $C3, $19, $77, $21
    db   $E0, $C2, $19, $36, $17, $C1, $C9, $1C
    db   $E4, $00, $00, $00, $00, $E4, $1C, $FA
    db   $30, $C1, $FE, $07, $C8, $FA, $46, $C1
    db   $A7, $C0, $3E, $01, $EA, $46, $C1, $AF
    db   $EA, $52, $C1, $EA, $53, $C1, $3E, $0D
    db   $E0, $F2, $F0, $F9, $A7, $28, $1E, $CD
    db   $0F, $12, $F0, $CB, $E6, $03, $3E, $EA
    db   $28, $02, $3E, $E8, $E0, $9B, $AF, $E0
    db   $A3, $CD, $D6, $20, $3E, $02, $CD, $B9
    db   $07, $CD, $B1, $6F, $C9, $3E, $20, $E0
    db   $A3, $FA, $4A, $C1, $A7, $C8, $F0, $9E
    db   $5F, $50, $21, $C9, $11, $19, $7E, $E0
    db   $9A, $21, $CD, $11, $19, $7E, $E0, $9B
    db   $C9, $02, $14, $15, $18, $FA, $6D, $C1
    db   $21, $21, $C1, $B6, $C0, $3E, $03, $EA
    db   $38, $C1, $3E, $01, $EA, $37, $C1, $EA
    db   $B0, $C5, $AF, $EA, $60, $C1, $EA, $AC
    db   $C1, $CD, $ED, $27, $E6, $03, $5F, $16
    db   $00, $21, $2B, $12, $19, $7E, $E0, $F4
    db   $CD, $83, $12, $FA, $46, $C1, $A7, $20
    db   $06, $CD, $3B, $09, $CD, $95, $14, $FA
    db   $4D, $C1, $A7, $C0, $FA, $A9, $C5, $A7
    db   $C8, $FA, $4E, $DB, $FE, $02, $C0, $3E
    db   $DF, $CD, $EB, $10, $AF, $EA, $9B, $C1
    db   $C9, $F0, $CB, $E6, $0F, $5F, $16, $00
    db   $21, $B3, $48, $19, $7E, $FE, $0F, $28
    db   $02, $E0, $9E, $C9, $16, $FA, $08, $08
    db   $16, $16, $08, $FA, $FA, $FA, $08, $16
    db   $08, $08, $FA, $16, $08, $16, $16, $16
    db   $08, $FA, $FA, $FA, $CD, $B6, $12, $3E
    db   $02, $C3, $B9, $07, $FA, $C4, $C1, $A7
    db   $C0, $FA, $4A, $C1, $A7, $20, $06, $FA
    db   $6A, $C1, $FE, $05, $C8, $FA, $21, $C1
    db   $A7, $28, $07, $FA, $36, $C1, $C6, $04
    db   $18, $02, $F0, $9E, $5F, $16, $00, $21
    db   $96, $12, $19, $F0, $98, $86, $D6, $08
    db   $E6, $F0, $E0, $CE, $CB, $37, $4F, $21
    db   $A2, $12, $19, $F0, $99, $86, $D6, $10
    db   $E6, $F0, $E0, $CD, $B1, $5F, $21, $11
    db   $D7, $19, $7C, $FE, $D7, $C0, $D5, $7E
    db   $E0, $AF, $5F, $FA, $A5, $DB, $57, $CD
    db   $DB, $29, $D1, $FE, $D0, $DA, $17, $13
    db   $FE, $D4, $DA, $C9, $13, $FE, $90, $D2
    db   $C9, $13, $FE, $01, $CA, $C9, $13, $0E
    db   $00, $FA, $A5, $DB, $A7, $F0, $AF, $28
    db   $05, $FE, $DD, $28, $0F, $C9, $0C, $FE
    db   $D3, $28, $09, $FE, $5C, $28, $05, $FE
    db   $0A, $C0, $0E, $FF, $79, $E0, $F1, $CD
    db   $A6, $20, $FA, $4A, $C1, $A7, $20, $10
    db   $FA, $6A, $C1, $FE, $05, $20, $09, $AF
    db   $EA, $22, $C1, $3E, $0C, $EA, $6D, $C1
    db   $3E, $05, $CD, $EB, $10, $38, $22, $AF
    db   $EA, $9B, $C1, $21, $00, $C2, $19, $F0
    db   $CE, $C6, $08, $77, $21, $10, $C2, $19
    db   $F0, $CD, $C6, $10, $77, $21, $B0, $C3
    db   $19, $F0, $F1, $77, $D5, $C1, $CD, $03
    db   $38, $CD, $ED, $27, $E6, $07, $C0, $F0
    db   $AF, $FE, $D3, $C8, $CD, $ED, $27, $1F
    db   $3E, $2E, $30, $02, $3E, $2D, $CD, $01
    db   $3C, $D8, $21, $00, $C2, $19, $F0, $CE
    db   $C6, $08, $77, $21, $10, $C2, $19, $F0
    db   $CD, $C6, $10, $77, $21, $50, $C4, $19
    db   $36, $80, $21, $F0, $C2, $19, $36, $18
    db   $21, $20, $C3, $19, $36, $10, $C9, $12
    db   $EE, $FC, $04, $04, $04, $EE, $12, $4F
    db   $FA, $6D, $C1, $A7, $C8, $F0, $9E, $5F
    db   $16, $00, $21, $C1, $13, $19, $F0, $98
    db   $86, $E0, $D7, $21, $C5, $13, $19, $F0
    db   $99, $86, $E0, $D8, $3E, $04, $EA, $02
    db   $C5, $CD, $A1, $09, $3E, $10, $EA, $C4
    db   $C1, $79, $E6, $F0, $FE, $90, $28, $05
    db   $3E, $07, $E0, $F2, $C9, $3E, $17, $E0
    db   $F4, $C9, $20, $E0, $00, $00, $00, $00
    db   $E0, $20, $F0, $F9, $A7, $28, $09, $F0
    db   $9C, $A7, $C0, $F0, $9E, $E6, $02, $C0
    db   $FA, $4A, $C1, $A7, $C0, $F0, $A2, $21
    db   $46, $C1, $B6, $C0, $FA, $20, $C1, $C6
    db   $02, $EA, $20, $C1, $CD, $5D, $14, $FA
    db   $4B, $C1, $3C, $EA, $4B, $C1, $FE, $20
    db   $C0, $EA, $4A, $C1, $AF, $EA, $21, $C1
    db   $EA, $22, $C1, $F0, $9E, $5F, $16, $00
    db   $21, $04, $14, $19, $7E, $E0, $9A, $21
    db   $08, $14, $19, $7E, $E0, $9B, $AF, $EA
    db   $AC, $C1, $C9, $F0, $E7, $E6, $07, $21
    db   $A2, $FF, $B6, $21, $A1, $FF, $B6, $21
    db   $46, $C1, $B6, $C0, $F0, $98, $E0, $D7
    db   $FA, $81, $C1, $FE, $05, $28, $0F, $3E
    db   $07, $E0, $F4, $F0, $99, $C6, $06, $E0
    db   $D8, $3E, $0B, $C3, $53, $09, $F0, $99
    db   $E0, $D8, $3E, $0E, $E0, $F2, $3E, $0C
    db   $C3, $53, $09, $AF, $E0, $9A, $E0, $9B
    db   $C9, $CD, $FA, $77, $FA, $1C, $C1, $FE
    db   $01, $C8, $FA, $6A, $C1, $A7, $28, $38
    db   $01, $10, $C0, $FA, $45, $C1, $21, $3B
    db   $C1, $86, $E0, $D7, $F0, $98, $E0, $D8
    db   $21, $DA, $FF, $36, $00, $FA, $22, $C1
    db   $FE, $28, $38, $07, $F0, $E7, $17, $17
    db   $E6, $10, $77, $FA, $39, $C1, $67, $FA
    db   $3A, $C1, $6F, $FA, $36, $C1, $E0, $D9
    db   $F0, $99, $FE, $88, $D0, $C3, $40, $15
    db   $FA, $9B, $C1, $F5, $CB, $7F, $CA, $1B
    db   $15, $3E, $02, $CD, $B9, $07, $CD, $4B
    db   $51, $FA, $9B, $C1, $E6, $7F, $FE, $0C
    db   $20, $1F, $21, $9F, $C1, $FA, $24, $C1
    db   $B6, $20, $16, $CD, $83, $12, $3E, $04
    db   $CD, $EB, $10, $38, $0C, $3E, $0D, $E0
    db   $F4, $3E, $02, $CD, $B9, $07, $CD, $C6
    db   $51, $F1, $EA, $9B, $C1, $C9, $08, $06
    db   $0C, $0A, $FF, $04, $0A, $0C, $06, $08
    db   $0A, $0C, $FF, $04, $0C, $0A, $20, $20
    db   $60, $60, $00, $00, $40, $40, $00, $00
    db   $00, $00, $40, $40, $20, $20, $E5, $F0
    db   $D7, $84, $02, $03, $F0, $D8, $85, $02
    db   $03, $21, $20, $15, $F0, $D9, $CB, $27
    db   $5F, $16, $00, $19, $7E, $02, $FE, $FF
    db   $20, $05, $0B, $3E, $F0, $02, $03, $03
    db   $21, $30, $15, $19, $7E, $21, $DA, $FF
    db   $B6, $02, $03, $E1, $F0, $D7, $84, $02
    db   $03, $F0, $D8, $85, $C6, $08, $02, $03
    db   $21, $21, $15, $19, $7E, $02, $03, $21
    db   $31, $15, $19, $7E, $21, $DA, $FF, $B6
    db   $02, $C9, $10, $F0, $08, $08, $0C, $0C
    db   $F0, $10, $F0, $9E, $5F, $16, $00, $21
    db   $8C, $15, $19, $F0, $98, $86, $EA, $79
    db   $C1, $21, $90, $15, $19, $F0, $99, $86
    db   $EA, $7A, $C1, $3E, $02, $EA, $78, $C1
    db   $C9, $CD, $0F, $78, $FA, $C9, $C3, $A7
    db   $28, $07, $AF, $EA, $C9, $C3, $C3, $09
    db   $09, $CD, $76, $17, $AF, $EA, $57, $C1
    db   $3C, $EA, $A8, $C1, $FA, $6B, $C1, $FE
    db   $04, $C2, $2D, $17, $AF, $E0, $96, $E0
    db   $97, $E0, $B4, $1E, $10, $21, $80, $C2
    db   $22, $1D, $20, $FC, $FA, $09, $C5, $A7
    db   $28, $1A, $F5, $3E, $04, $CD, $B9, $07
    db   $F1, $CD, $E3, $79, $21, $6E, $DB, $34
    db   $21, $46, $DB, $34, $3E, $01, $EA, $7E
    db   $D4, $AF, $E0, $9D, $F0, $F9, $E0, $E4
    db   $3E, $0B, $EA, $95, $DB, $AF, $EA, $96
    db   $DB, $EA, $CB, $C3, $E0, $F9, $21, $01
    db   $D4, $FA, $A5, $DB, $E0, $E6, $A7, $20
    db   $2A, $21, $16, $D4, $0E, $00, $F0, $98
    db   $CB, $37, $E6, $0F, $5F, $F0, $99, $D6
    db   $08, $E6, $F0, $B3, $BE, $28, $07, $23
    db   $0C, $79, $FE, $04, $20, $E8, $79, $CB
    db   $27, $CB, $27, $81, $5F, $16, $00, $21
    db   $01, $D4, $19, $E5, $2A, $EA, $A5, $DB
    db   $FE, $02, $20, $0A, $E0, $F9, $3D, $EA
    db   $A5, $DB, $3E, $01, $E0, $9C, $2A, $E0
    db   $F7, $FA, $A5, $DB, $A7, $2A, $E0, $F6
    db   $20, $0B, $F0, $E6, $A7, $28, $04, $AF
    db   $EA, $7C, $D4, $18, $5D, $4F, $3E, $14
    db   $CD, $B9, $07, $E5, $F0, $F7, $CB, $37
    db   $5F, $16, $00, $CB, $23, $CB, $12, $CB
    db   $23, $CB, $12, $21, $00, $42, $19, $F0
    db   $F7, $FE, $06, $20, $0A, $FA, $6B, $DB
    db   $E6, $04, $28, $03, $21, $C0, $44, $1E
    db   $00, $2A, $B9, $28, $06, $1C, $7B, $FE
    db   $40, $20, $F6, $7B, $EA, $AE, $DB, $F0
    db   $E6, $A7, $20, $1D, $AF, $EA, $7C, $D4
    db   $F0, $F7, $FE, $0A, $30, $13, $3E, $02
    db   $CD, $B9, $07, $CD, $9B, $6A, $3E, $30
    db   $E0, $B4, $AF, $EA, $FB, $D6, $EA, $F8
    db   $D6, $E1, $2A, $EA, $9D, $DB, $7E, $EA
    db   $9E, $DB, $E1, $F0, $F9, $A7, $20, $4C
    db   $F0, $E4, $A7, $20, $46, $FA, $A5, $DB
    db   $A7, $28, $29, $F0, $F7, $FE, $0A, $30
    db   $23, $5F, $CB, $27, $CB, $27, $83, $5F
    db   $16, $00, $21, $E5, $53, $19, $3E, $14
    db   $EA, $00, $21, $CD, $16, $17, $D5, $F0
    db   $F7, $5F, $16, $00, $21, $12, $54, $19
    db   $7E, $D1, $12, $C9, $3E, $00, $E0, $D7
    db   $11, $5F, $DB, $2A, $12, $13, $F0, $D7
    db   $3C, $E0, $D7, $FE, $05, $20, $F4, $FA
    db   $AE, $DB, $12, $C9, $AF, $E0, $9E, $C9
    db   $CD, $0F, $78, $FA, $74, $D4, $A7, $28
    db   $15, $AF, $EA, $74, $D4, $3E, $30, $EA
    db   $80, $C1, $3E, $03, $EA, $7F, $C1, $3E
    db   $04, $EA, $6B, $C1, $18, $0A, $CD, $C3
    db   $17, $FA, $6B, $C1, $FE, $04, $20, $1B
    db   $FA, $63, $D4, $FE, $01, $28, $02, $3E
    db   $00, $EA, $1C, $C1, $FA, $7E, $D4, $A7
    db   $28, $09, $AF, $EA, $7E, $D4, $3E, $36
    db   $CD, $97, $21, $C9, $21, $6C, $C1, $34
    db   $FA, $6C, $C1, $E6, $03, $20, $35, $21
    db   $6B, $C1, $7E, $FE, $04, $28, $2D, $34
    db   $AF, $E0, $D7, $F0, $D7, $FE, $03, $28
    db   $23, $21, $97, $DB, $5F, $16, $00, $19
    db   $7E, $4F, $06, $00, $79, $E6, $03, $28
    db   $01, $0D, $CB, $09, $CB, $09, $04, $78
    db   $FE, $04, $20, $F0, $79, $77, $21, $D7
    db   $FF, $34, $18, $D7, $C9, $00, $01, $02
    db   $03, $00, $03, $01, $00, $00, $01, $02
    db   $03, $21, $6C, $C1, $34, $FA, $6C, $C1
    db   $E6, $03, $20, $44, $21, $6B, $C1, $7E
    db   $34, $FE, $04, $28, $DF, $AF, $E0, $D7
    db   $F0, $D7, $FE, $03, $28, $32, $21, $97
    db   $DB, $5F, $16, $00, $19, $7E, $E5, $4F
    db   $06, $00, $F0, $D7, $CB, $27, $CB, $27
    db   $B0, $5F, $21, $B7, $17, $19, $79, $E6
    db   $03, $BE, $28, $01, $0C, $CB, $09, $CB
    db   $09, $04, $78, $FE, $04, $20, $E3, $79
    db   $E1, $77, $21, $D7, $FF, $34, $18, $C8
    db   $C9, $00, $02, $02, $00, $10, $02, $12
    db   $00, $04, $06, $06, $04, $08, $0A, $0C
    db   $0E, $18, $0A, $1C, $0E, $0A, $08, $0E
    db   $0C, $0A, $18, $0E, $1C, $20, $22, $24
    db   $26, $28, $2A, $2A, $28, $30, $32, $20
    db   $22, $34, $36, $24, $26, $38, $3A, $28
    db   $2A, $3A, $38, $2A, $28, $40, $40, $42
    db   $42, $44, $46, $48, $4A, $4C, $4E, $50
    db   $52, $4E, $4C, $52, $50, $80, $02, $82
    db   $00, $84, $86, $88, $8A, $8C, $8E, $90
    db   $92, $94, $96, $98, $9A, $9C, $9E, $9A
    db   $A2, $A4, $08, $A6, $0C, $A8, $AA, $AC
    db   $AE, $B0, $B2, $B4, $B6, $B0, $B2, $B4
    db   $B6, $04, $C0, $06, $C2, $5A, $58, $5E
    db   $5C, $58, $5A, $5C, $5E, $44, $46, $6E
    db   $6E, $40, $40, $56, $56, $7A, $78, $7E
    db   $7C, $78, $7A, $7C, $7E, $74, $76, $76
    db   $74, $70, $72, $72, $70, $CA, $C8, $D6
    db   $D4, $C8, $CA, $D4, $D6, $CC, $CE, $D8
    db   $DA, $C4, $C4, $C6, $C6, $DC, $DC, $DE
    db   $DE, $EA, $EC, $EE, $F0, $F2, $F4, $F6
    db   $F6, $F8, $FA, $E0, $E2, $E4, $E6, $E8
    db   $E8, $10, $12, $14, $16, $18, $1C, $12
    db   $10, $16, $14, $1C, $18, $66, $68, $6A
    db   $6C, $68, $66, $68, $66, $6C, $6A, $66
    db   $68, $60, $60, $62, $62, $64, $64, $62
    db   $62, $64, $64, $60, $60, $54, $54, $3C
    db   $3E, $FE, $FE, $18, $1A, $1C, $1E, $2C
    db   $2E, $B8, $BA, $2E, $2C, $BA, $B8, $BC
    db   $BE, $D0, $D2, $A0, $FC, $FC, $A0, $00
    db   $00, $20, $20, $00, $00, $00, $20, $00
    db   $00, $20, $20, $00, $00, $00, $00, $00
    db   $00, $00, $00, $20, $20, $20, $20, $20
    db   $20, $20, $20, $00, $00, $00, $00, $00
    db   $00, $20, $20, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $20
    db   $20, $20, $20, $00, $20, $00, $20, $00
    db   $00, $00, $00, $00, $00, $00, $00, $20
    db   $20, $20, $20, $00, $00, $00, $20, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $20, $00, $00
    db   $20, $00, $20, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $20, $00, $20, $20, $20, $20, $00
    db   $00, $00, $00, $00, $00, $00, $20, $00
    db   $20, $00, $20, $20, $20, $20, $20, $00
    db   $00, $00, $00, $00, $00, $20, $20, $00
    db   $00, $20, $20, $20, $20, $20, $20, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $20, $00, $20, $00, $20, $00, $20, $00
    db   $00, $00, $00, $00, $00, $00, $20, $00
    db   $00, $00, $00, $00, $00, $00, $20, $00
    db   $00, $00, $00, $00, $00, $20, $20, $20
    db   $20, $20, $20, $00, $00, $00, $00, $60
    db   $60, $20, $20, $20, $20, $40, $40, $00
    db   $20, $00, $20, $00, $20, $40, $60, $40
    db   $60, $40, $60, $00, $20, $00, $00, $00
    db   $20, $00, $00, $00, $00, $00, $00, $00
    db   $00, $20, $20, $20, $20, $00, $00, $00
    db   $00, $00, $00, $20, $20, $FA, $20, $C1
    db   $CB, $2F, $CB, $2F, $CB, $2F, $E6, $01
    db   $57, $F0, $9E, $CB, $27, $B2, $4F, $06
    db   $00, $21, $F6, $48, $FA, $1C, $C1, $FE
    db   $01, $20, $0A, $F0, $9C, $A7, $28, $03
    db   $21, $FE, $48, $18, $4F, $F0, $F9, $A7
    db   $28, $0B, $F0, $9C, $FE, $02, $20, $05
    db   $21, $06, $49, $18, $3F, $FA, $5C, $C1
    db   $FE, $01, $28, $35, $F0, $B2, $A7, $20
    db   $06, $FA, $44, $C1, $A7, $20, $25, $FA
    db   $5A, $C1, $A7, $20, $05, $21, $BE, $48
    db   $18, $22, $21, $C6, $48, $FE, $02, $20
    db   $03, $21, $D6, $48, $FA, $5B, $C1, $A7
    db   $28, $08, $7D, $C6, $08, $6F, $7C, $CE
    db   $00, $67, $18, $08, $21, $E6, $48, $18
    db   $03, $21, $EE, $48, $09, $7E, $E0, $9D
    db   $C9

toc_01_1A6B:
    ld   a, [$D601]
    and  a
    ret  nz

    ld   a, $10
    ld   [$2100], a
    ld   hl, $6500
    ld   de, $9500
    ld   a, [$FFE7]
    and  %00001111
    jr   z, toc_01_1A87

    cp   $08
    ret  nz

    ld   l, $40
    ld   e, l
toc_01_1A87:
    ld   a, [$FFE7]
    and  %00110000
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    sla  c
    rl   b
    sla  c
    rl   b
    add  hl, bc
    ld   bc, $0040
    jp   toc_01_28C5

    db   $20, $60, $A0, $E0, $E0, $E0, $A0, $60

toc_01_1AA9:
    ld   a, [$DB95]
    cp   $09
    jr   z, toc_01_1A6B

    cp   $00
    jr   nz, .else_01_1ADF

    ld   a, [$D601]
    and  a
    jp   nz, .return_01_1ADE

    ld   a, [$FFE7]
    and  %00001111
    cp   $04
    jr   c, .return_01_1ADE

    ld   a, $10
    ld   [$2100], a
    ld   a, [$D006]
    ld   l, a
    ld   a, [$D007]
    ld   h, a
    ld   a, [$D008]
    ld   e, a
    ld   a, [$D009]
    ld   d, a
    ld   bc, $0020
    call toc_01_28C5
toc_01_1AA9.return_01_1ADE:
    ret


toc_01_1AA9.else_01_1ADF:
    ld   a, [$DB95]
    cp   $01
    jr   nz, .else_01_1AEC

    ld   a, [$FFA5]
    and  a
    jr   nz, .else_01_1B1B

    ret


toc_01_1AA9.else_01_1AEC:
    cp   $0B
    jp   c, toc_01_1CCC.return_01_1D14

    ld   a, [$DB9A]
    cp   $80
    jp   nz, toc_01_1CCC.return_01_1D14

    ld   a, [$C14F]
    and  a
    jp   nz, toc_01_1CCC

    ld   hl, $C124
    ld   a, [$D601]
    or   [hl]
    jp   nz, toc_01_1CCC

    ld   a, [$D6F8]
    and  a
    jr   z, .else_01_1B16

    call toc_01_1DEE
    jp   toc_01_1CCC

toc_01_1AA9.else_01_1B16:
    ld   a, [$FFA5]
    and  a
    jr   z, .else_01_1B66

toc_01_1AA9.else_01_1B1B:
    cp   $01
    jp   z, toc_01_3FBD

    cp   $02
    jp   z, toc_01_3FD3

    cp   $03
    jp   z, toc_01_1DCF

    cp   $04
    jp   z, toc_01_1DD6

    cp   $08
    jp   z, toc_01_1D8C

    cp   $09
    jp   z, toc_01_1DBE

    cp   $0A
    jp   z, toc_01_1D54

    cp   $0B
    jp   z, toc_01_1DAD

    cp   $0C
    jp   z, toc_01_1D5C

    cp   $0D
    jp   z, toc_01_1D2D

    cp   $0E
    jr   z, .else_01_1B5E

    cp   $0F
    jp   z, toc_01_1D1C

    cp   $10
    jp   z, toc_01_1D15

    jp   toc_01_1CCC

toc_01_1AA9.else_01_1B5E:
    ld   a, $17
    ld   [$2100], a
    jp   toc_17_4060

toc_01_1AA9.else_01_1B66:
    ld   a, [$FFA6]
    inc  a
    ld   [$FFA6], a
    ld   a, [$FFA4]
    rst  $00
    db   $5A, $1C, $90, $1B, $AA, $1B, $AE, $1B
    db   $CD, $1B, $F1, $1B, $F5, $1B, $10, $1C
    db   $21, $1C, $30, $1C, $3F, $1C, $B6, $1B
    db   $B2, $1B, $4A, $1C, $56, $1C, $4E, $1C
    db   $52, $1C, $F0, $A6, $E6, $07, $C2, $5A
    db   $1C, $3E, $01, $EA, $00, $21, $CD, $62
    db   $5F, $3E, $0C, $EA, $00, $21, $C3, $CC
    db   $1C, $6F, $18, $3B, $26, $6B, $18, $0A
    db   $26, $6C, $18, $06, $26, $73, $18, $02
    db   $26, $6A, $F0, $A6, $E6, $0F, $C2, $5A
    db   $1C, $CD, $43, $1C, $C3, $A7, $1B, $00
    db   $40, $80, $C0, $C0, $C0, $80, $40, $F0
    db   $A6, $E6, $07, $C2, $5A, $1C, $F0, $A6
    db   $1F, $1F, $1F, $E6, $07, $5F, $16, $00
    db   $21, $C5, $1B, $19, $6E, $26, $6D, $11
    db   $C0, $96, $01, $40, $00, $CD, $C5, $28
    db   $C3, $CC, $1C, $26, $6E, $18, $C3, $F0
    db   $A6, $E6, $07, $C2, $5A, $1C, $F0, $A6
    db   $1F, $1F, $1F, $E6, $07, $5F, $16, $00
    db   $21, $C5, $1B, $19, $6E, $26, $6F, $C3
    db   $E5, $1B, $F0, $A6, $3C, $E6, $03, $C2
    db   $CD, $1B, $21, $C0, $DC, $11, $C0, $90
    db   $C3, $E8, $1B, $26, $70, $F0, $A6, $E6
    db   $07, $C2, $5A, $1C, $CD, $43, $1C, $C3
    db   $A7, $1B, $26, $71, $F0, $A6, $E6, $03
    db   $C2, $5A, $1C, $CD, $43, $1C, $C3, $A7
    db   $1B, $26, $72, $18, $EF, $F0, $A7, $C6
    db   $40, $E0, $A7, $C9, $26, $75, $18, $E4
    db   $26, $74, $18, $D1, $26, $77, $18, $CD
    db   $26, $76, $18, $C9, $F0, $9D, $FE, $FF
    db   $CA, $CC, $1C, $21, $13, $18, $CB, $27
    db   $4F, $06, $00, $09, $5E, $E5, $21, $01
    db   $19, $09, $FA, $1D, $C1, $E6, $9F, $B6
    db   $EA, $1D, $C1, $23, $FA, $1E, $C1, $E6
    db   $9F, $B6, $EA, $1E, $C1, $16, $00, $CB
    db   $23, $CB, $12, $CB, $23, $CB, $12, $CB
    db   $23, $CB, $12, $CB, $23, $CB, $12, $21
    db   $00, $58, $19, $E5, $C1, $21, $00, $80
    db   $16, $20, $0A, $03, $22, $15, $20, $FA
    db   $E1, $23, $5E, $16, $00, $CB, $23, $CB
    db   $12, $CB, $23, $CB, $12, $CB, $23, $CB
    db   $12, $CB, $23, $CB, $12, $21, $00, $58
    db   $19, $E5, $C1, $21, $20, $80, $16, $20
    db   $0A, $03, $22, $15, $20, $FA

toc_01_1CCC:
    ld   a, [$FF9D]
    inc  a
    jr   z, .return_01_1D14

    ld   a, [$DBC7]
    rla
    rla
    and  %00010000
    ld   [$C135], a
    ld   hl, $C008
    ld   a, [$C13B]
    ld   c, a
    ld   a, [$C145]
    add  a, c
    cp   $88
    jr   nc, .return_01_1D14

    push af
    ldi  [hl], a
    ld   a, [$C13C]
    ld   c, a
    ld   a, [$FF98]
    add  a, c
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    ld   a, [$C135]
    ld   d, a
    ld   a, [$C11D]
    or   d
    ldi  [hl], a
    pop  af
    ldi  [hl], a
    ld   a, [$FF98]
    add  a, c
    add  a, $08
    ldi  [hl], a
    ld   a, $02
    ldi  [hl], a
    ld   a, [$C135]
    ld   d, a
    ld   a, [$C11E]
    or   d
    ldi  [hl], a
toc_01_1CCC.return_01_1D14:
    ret


toc_01_1D15:
    ld   hl, $4F00
    ld   a, $0E
    jr   toc_01_1D21

toc_01_1D1C:
    ld   a, $12
    ld   hl, $6080
toc_01_1D21:
    ld   [$2100], a
    ld   de, $8400
    ld   bc, $0040
    jp   toc_01_1E4D

toc_01_1D2D:
    ld   a, [$DB0E]
    cp   $02
    jp   c, toc_01_1E50

    sub  a, $02
    ld   d, a
    ld   e, $00
    sra  d
    rr   e
    sra  d
    rr   e
    ld   hl, $4400
    add  hl, de
    ld   de, $89A0
    ld   bc, $0040
    ld   a, $0C
    ld   [$2100], a
    jp   toc_01_1E4D

toc_01_1D54:
    ld   hl, $68C0
    ld   de, $88E0
    jr   toc_01_1DC4

toc_01_1D5C:
    ld   a, $11
    ld   [$2100], a
    ld   a, [$D000]
    swap a
    and  %11110000
    ld   e, a
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    ld   hl, $8D00
    add  hl, de
    push hl
    ld   hl, $5000
toc_01_1D7B:
    add  hl, de
    pop  de
    ld   bc, $0040
    call toc_01_28C5
    xor  a
    ld   [$FFA5], a
    ld   a, $0C
    ld   [$2100], a
    ret


toc_01_1D8C:
    ld   a, $13
    ld   [$2100], a
    ld   a, [$D000]
    swap a
    and  %11110000
    ld   e, a
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    ld   hl, $8D00
    add  hl, de
    push hl
    ld   hl, $4D00
    jr   toc_01_1D7B

toc_01_1DAD:
    ld   hl, $48E0
    ld   de, $88E0
    ld   a, $0C
    ld   [$2100], a
    ld   bc, $0020
    jp   toc_01_1E4D

toc_01_1DBE:
    ld   hl, $68E0
    ld   de, $8CA0
toc_01_1DC4:
    ld   a, $0C
    ld   [$2100], a
    ld   bc, $0020
    jp   toc_01_1E4D

toc_01_1DCF:
    ld   hl, $7F00
    ld   a, $12
    jr   toc_01_1DDB

toc_01_1DD6:
    ld   hl, $4C40
    ld   a, $0D
toc_01_1DDB:
    ld   [$2100], a
    ld   de, $9140
    jp   toc_01_1E4A

    db   $40, $68, $40, $68, $00, $68, $80, $68
    db   $00, $68

toc_01_1DEE:
    ld   hl, $2100
    ld   [hl], $0C
    ld   hl, $FFA1
    ld   [hl], $01
    ld   hl, $D6FB
    ld   e, [hl]
    ld   d, $00
    inc  a
    cp   $03
    jr   nz, .else_01_1E0D

    push af
    ld   a, [$D6FB]
    xor  %00000010
    ld   [$D6FB], a
    pop  af
toc_01_1DEE.else_01_1E0D:
    ld   [$D6F8], a
    cp   $04
    jr   nz, .else_01_1E19

    ld   hl, $1DE4
    jr   .toc_01_1E20

toc_01_1DEE.else_01_1E19:
    cp   $08
    jr   nz, .else_01_1E26

    ld   hl, $1DE8
toc_01_1DEE.toc_01_1E20:
    add  hl, de
    ld   de, $9040
    jr   .toc_01_1E3E

toc_01_1DEE.else_01_1E26:
    cp   $06
    jr   nz, .else_01_1E2F

    ld   hl, $1DE4
    jr   .toc_01_1E3A

toc_01_1DEE.else_01_1E2F:
    cp   $0A
    jr   nz, .else_01_1E47

    xor  a
    ld   [$D6F8], a
    ld   hl, $1DEA
toc_01_1DEE.toc_01_1E3A:
    add  hl, de
    ld   de, $9080
toc_01_1DEE.toc_01_1E3E:
    ld   bc, $0040
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    jp   toc_01_28C5

toc_01_1DEE.else_01_1E47:
    jp   toc_01_1CCC

toc_01_1E4A:
    ld   bc, $0040
toc_01_1E4D:
    call toc_01_28C5
toc_01_1E50:
    xor  a
    ld   [$FFA5], a
    ld   a, $0C
    ld   [$2100], a
    jp   toc_01_1CCC

    db   $0C, $03, $08, $08, $0A, $0A, $05, $10
    db   $36, $38, $3A, $3C, $02, $01, $08, $04
    db   $FC, $04, $00, $00, $00, $00, $04, $00
    db   $CD, $7B, $1E, $3E, $02, $C3, $B9, $07
    db   $21, $4A, $C1, $FA, $5C, $C1, $B6, $21
    db   $A2, $FF, $B6, $21, $1C, $C1, $B6, $C2
    db   $A5, $20, $F0, $9E, $5F, $16, $00, $21
    db   $5B, $1E, $19, $F0, $98, $86, $D6, $08
    db   $E6, $F0, $E0, $CE, $CB, $37, $4F, $21
    db   $5F, $1E, $19, $F0, $99, $86, $D6, $10
    db   $E6, $F0, $E0, $CD, $B1, $5F, $E0, $D8
    db   $21, $11, $D7, $19, $7C, $FE, $D7, $C2
    db   $7C, $20, $7E, $E0, $D7, $5F, $FA, $A5
    db   $DB, $57, $CD, $DB, $29, $E0, $DC, $F0
    db   $D7, $FE, $9A, $28, $40, $F0, $DC, $FE
    db   $00, $CA, $7C, $20, $FE, $01, $28, $1D
    db   $FE, $50, $CA, $7C, $20, $FE, $51, $CA
    db   $7C, $20, $FE, $11, $DA, $7C, $20, $FE
    db   $D4, $D2, $7C, $20, $FE, $D0, $30, $05
    db   $FE, $7C, $D2, $7C, $20, $F0, $D7, $5F
    db   $FE, $6F, $28, $09, $FE, $5E, $28, $05
    db   $FE, $D4, $C2, $A1, $1F, $FA, $A5, $DB
    db   $A7, $7B, $C2, $A1, $1F, $5F, $F0, $9E
    db   $FE, $02, $C2, $FD, $1F, $3E, $02, $EA
    db   $AD, $C1, $F0, $CC, $E6, $30, $CA, $FD
    db   $1F, $7B, $FE, $5E, $3E, $8E, $28, $6B
    db   $7B, $FE, $6F, $28, $2B, $FE, $D4, $28
    db   $27, $FA, $73, $DB, $A7, $28, $08, $3E
    db   $78, $CD, $8E, $21, $C3, $FD, $1F, $FA
    db   $4E, $DB, $A7, $F0, $F6, $20, $06, $1E
    db   $FF, $FE, $A3, $28, $08, $1E, $FC, $FE
    db   $FA, $28, $02, $1E, $FD, $7B, $18, $41
    db   $F0, $F6, $5F, $16, $00, $3E, $14, $EA
    db   $00, $21, $21, $FF, $55, $19, $FA, $49
    db   $DB, $5F, $7E, $FE, $A9, $20, $06, $CB
    db   $43, $28, $02, $3E, $AF, $FE, $AF, $20
    db   $16, $CB, $43, $20, $12, $F0, $CE, $CB
    db   $37, $E6, $0F, $5F, $F0, $CD, $E6, $F0
    db   $B3, $EA, $73, $D4, $C3, $FD, $1F, $FE
    db   $83, $28, $06, $CD, $85, $21, $C3, $FD
    db   $1F, $CD, $97, $21, $18, $5C, $FE, $A0
    db   $20, $58, $FA, $8E, $C1, $E6, $1F, $FE
    db   $0D, $28, $4F, $F0, $9E, $FE, $02, $20
    db   $49, $EA, $AD, $C1, $F0, $CC, $E6, $30
    db   $28, $40, $F0, $F9, $A7, $20, $06, $F0
    db   $9E, $FE, $02, $20, $35, $3E, $14, $EA
    db   $00, $21, $F0, $F6, $5F, $FA, $A5, $DB
    db   $57, $F0, $F7, $FE, $1A, $30, $05, $FE
    db   $06, $38, $01, $14, $21, $00, $45, $19
    db   $7E, $FE, $20, $20, $0B, $FA, $4E, $DB
    db   $FE, $02, $3E, $20, $38, $02, $3E, $1C
    db   $E0, $DF, $3E, $02, $EA, $00, $21, $CD
    db   $BA, $41, $FA, $00, $DB, $FE, $03, $20
    db   $07, $F0, $CB, $E6, $20, $20, $10, $C9
    db   $FA, $01, $DB, $FE, $03, $C2, $A5, $20
    db   $F0, $CB, $E6, $10, $CA, $A5, $20, $3E
    db   $02, $EA, $00, $21, $CD, $5E, $48, $3E
    db   $01, $E0, $A1, $F0, $9E, $5F, $16, $00
    db   $21, $63, $1E, $19, $7E, $E0, $9D, $21
    db   $67, $1E, $19, $F0, $CB, $A6, $28, $41
    db   $21, $6B, $1E, $19, $7E, $EA, $3C, $C1
    db   $21, $6F, $1E, $19, $7E, $EA, $3B, $C1
    db   $21, $9D, $FF, $34, $1E, $08, $FA, $7C
    db   $D4, $FE, $01, $20, $02, $1E, $03, $21
    db   $5F, $C1, $34, $7E, $BB, $38, $19, $AF
    db   $E0, $E5, $F0, $D7, $FE, $8E, $28, $16
    db   $FE, $20, $28, $12, $FA, $A5, $DB, $A7
    db   $20, $06, $F0, $D7, $FE, $5C, $28, $14
    db   $C9, $AF, $EA, $5F, $C1, $C9, $CD, $93
    db   $20, $3E, $14, $EA, $00, $21, $CD, $AA
    db   $55, $C3, $C0, $07, $3E, $01, $E0, $E5
    db   $F0, $D8, $5F, $F0, $D7, $E0, $AF, $CD
    db   $A6, $20, $F0, $9E, $EA, $5D, $C1, $CD
    db   $B1, $20, $C9, $3E, $14, $EA, $00, $21
    db   $CD, $DE, $59, $C3, $C0, $07, $3E, $05
    db   $CD, $EB, $10, $38, $1D, $3E, $02, $E0
    db   $F3, $21, $80, $C2, $19, $36, $07, $21
    db   $B0, $C3, $19, $F0, $E5, $77, $D5, $C1
    db   $1E, $01, $3E, $03, $CD, $B9, $07, $CD
    db   $EF, $57, $C9, $FA, $4F, $C1, $A7, $C0
    db   $0E, $01, $CD, $E4, $20, $0E, $00, $E0
    db   $D7, $06, $00, $21, $9A, $FF, $09, $7E
    db   $F5, $CB, $37, $E6, $F0, $21, $1A, $C1
    db   $09, $86, $77, $CB, $12, $21, $98, $FF
    db   $09, $F1, $1E, $00, $CB, $7F, $28, $02
    db   $1E, $F0, $CB, $37, $E6, $0F, $B3, $CB
    db   $1A, $8E, $77, $C9, $F0, $A3, $F5, $CB
    db   $37, $E6, $F0, $21, $49, $C1, $86, $77
    db   $CB, $12, $21, $A2, $FF, $F1, $1E, $00
    db   $CB, $7F, $28, $02, $1E, $F0, $CB, $37
    db   $E6, $0F, $B3, $CB, $1A, $8E, $77, $C9
    db   $FA, $9F, $C1, $A7, $C8, $5F, $FA, $95
    db   $DB, $FE, $01, $3E, $7E, $20, $02, $3E
    db   $7F, $E0, $E8, $FA, $64, $C1, $A7, $FA
    db   $70, $C1, $20, $04, $FE, $20, $38, $04
    db   $E6, $0F, $F6, $10, $EA, $71, $C1, $7B
    db   $E6, $7F, $3D, $C7, $7D, $21, $C2, $21
    db   $C2, $21, $C2, $21, $53, $22, $20, $23
    db   $59, $23, $B5, $23, $21, $25, $A0, $25
    db   $F4, $25, $95, $22, $1F, $26, $CE, $22
    db   $C3, $21, $3E, $14, $EA, $00, $21, $C3
    db   $24, $59, $CD, $97, $21, $3E, $01, $EA
    db   $12, $C1, $C9, $CD, $97, $21, $3E, $02
    db   $EA, $12, $C1, $C9, $F5, $AF, $EA, $77
    db   $C1, $F1, $EA, $73, $C1, $AF, $EA, $6F
    db   $C1, $EA, $70, $C1, $EA, $64, $C1, $EA
    db   $08, $C1, $EA, $12, $C1, $3E, $0F, $EA
    db   $AB, $C5, $F0, $99, $FE, $48, $1F, $E6
    db   $80, $F6, $01, $EA, $9F, $C1, $C9, $C9
    db   $AF, $EA, $9F, $C1, $3E, $18, $EA, $34
    db   $C1, $C9, $00, $24, $48, $00, $24, $48
    db   $98, $98, $98, $99, $99, $99, $21, $61
    db   $A1, $41, $81, $C1

toc_01_21DF:
    ld   a, [$C19F]
    bit  7, a
    jr   z, .else_01_21EA

    and  %01111111
    add  a, $03
toc_01_21DF.else_01_21EA:
    ld   e, a
    ld   d, $00
    ld   hl, $21CB
    add  hl, de
    ld   a, [hl]
    ld   c, a
    ld   b, $00
    ld   hl, $D500
    add  hl, bc
    push hl
    pop  bc
    ld   hl, $21D7
    add  hl, de
    ld   a, [$C12F]
    add  a, [hl]
    ld   l, a
    ld   [$FFD7], a
    ld   hl, $21D1
    add  hl, de
    ld   a, [$C12E]
    add  a, [hl]
    ld   h, a
    ld   a, [$FFD7]
    ld   l, a
    xor  a
    ld   e, a
    ld   d, a
toc_01_21DF.loop_01_2215:
    ld   a, [hl]
    ld   [bc], a
    inc  bc
    ld   a, l
    add  a, $01
    and  %00011111
    jr   nz, .else_01_2225

    ld   a, l
    and  %11100000
    ld   l, a
    jr   .toc_01_2226

toc_01_21DF.else_01_2225:
    inc  l
toc_01_21DF.toc_01_2226:
    inc  e
    ld   a, e
    cp   $12
    jr   nz, .loop_01_2215

    ld   e, $00
    ld   a, [$FFD7]
    add  a, $20
    ld   [$FFD7], a
    jr   nc, .else_01_2237

    inc  h
toc_01_21DF.else_01_2237:
    ld   l, a
    inc  d
    ld   a, d
    cp   $02
    jr   nz, .loop_01_2215

    ret


    db   $61, $41, $81, $21, $A1, $81, $61, $A1
    db   $41, $C1, $98, $98, $98, $98, $98, $99
    db   $99, $99, $99, $99, $FA, $9F, $C1, $4F
    db   $FA, $6F, $C1, $FE, $05, $28, $32, $CB
    db   $79, $28, $02, $C6, $05, $4F, $06, $00
    db   $1E, $01, $16, $00, $FA, $2E, $C1, $21
    db   $49, $22, $09, $86, $21, $00, $D6, $19
    db   $22, $E5, $FA, $2F, $C1, $21, $3F, $22
    db   $09, $86, $E1, $22, $3E, $51, $22, $F0
    db   $E8, $22, $36, $00, $21, $6F, $C1, $34
    db   $C9

toc_01_2290:
    ld   hl, $C19F
    inc  [hl]
    ret


    db   $FA, $AB, $C1, $A7, $20, $14, $F0, $CC
    db   $E6, $30, $28, $0E, $AF, $EA, $6F, $C1
    db   $FA, $9F, $C1, $E6, $F0, $F6, $0E, $EA
    db   $9F, $C1, $C9, $A1, $21, $81, $41, $61
    db   $C1, $41, $A1, $61, $81, $98, $98, $98
    db   $98, $98, $99, $99, $99, $99, $99, $48
    db   $00, $36, $12, $24, $48, $00, $36, $12
    db   $24, $FA, $9F, $C1, $4F, $FA, $6F, $C1
    db   $FE, $05, $28, $B7, $CB, $79, $28, $02
    db   $C6, $05, $4F, $06, $00, $1E, $01, $16
    db   $00, $FA, $2E, $C1, $21, $BA, $22, $09
    db   $86, $21, $00, $D6, $19, $22, $E5, $FA
    db   $2F, $C1, $21, $B0, $22, $09, $86, $E1
    db   $22, $3E, $11, $22, $E5, $21, $C4, $22
    db   $09, $7E, $4F, $06, $00, $21, $00, $D5
    db   $09, $E5, $C1, $E1, $1E, $12, $0A, $03
    db   $22, $1D, $20, $FA, $36, $00, $21, $6F
    db   $C1, $34, $C9, $3E, $1C, $EA, $00, $21
    db   $FA, $72, $C1, $A7, $28, $05, $3D, $EA
    db   $72, $C1, $C9, $FA, $70, $C1, $E6, $1F
    db   $5F, $16, $00, $0E, $01, $06, $00, $21
    db   $21, $45, $19, $7E, $21, $00, $D6, $09
    db   $22, $E5, $21, $01, $45, $19, $7E, $E1
    db   $22, $3E, $4F, $22, $3E, $FF, $22, $36
    db   $00, $C3, $90, $22, $3E, $1C, $EA, $00
    db   $21, $FA, $9F, $C1, $4F, $FA, $71, $C1
    db   $CB, $79, $28, $02, $C6, $20, $4F, $06
    db   $00, $1E, $01, $16, $00, $FA, $2E, $C1
    db   $21, $61, $45, $09, $86, $21, $00, $D6
    db   $19, $22, $EA, $75, $C1, $E5, $21, $A1
    db   $45, $09, $7E, $E6, $E0, $C6, $20, $5F
    db   $FA, $2F, $C1, $86, $57, $BB, $38, $04
    db   $7A, $D6, $20, $57, $7A, $EA, $76, $C1
    db   $E1, $22, $AF, $22, $E5, $FA, $70, $C1
    db   $E6, $1F, $4F, $21, $41, $45, $09, $7E
    db   $E1, $22, $CD, $90, $22, $C3, $B5, $23
    db   $3E, $1C, $EA, $00, $21, $FA, $70, $C1
    db   $E6, $1F, $4F, $06, $00, $1E, $05, $16
    db   $00, $21, $21, $45, $09, $7E, $21, $00
    db   $D6, $19, $22, $E5, $21, $01, $45, $09
    db   $7E, $E1, $22, $3E, $0F, $22, $E5, $FA
    db   $12, $C1, $57, $FA, $73, $C1, $5F, $CB
    db   $23, $CB, $12, $21, $01, $40, $19, $2A
    db   $5F, $56, $D5, $FA, $73, $C1, $5F, $FA
    db   $12, $C1, $57, $21, $E1, $46, $19, $7E
    db   $E6, $1F, $EA, $00, $21, $E1, $FA, $70
    db   $C1, $5F, $FA, $64, $C1, $57, $19, $2A
    db   $5F, $7E, $EA, $C3, $C3, $CD, $C0, $07
    db   $7B, $E0, $D7, $FE, $FE, $20, $14, $E1
    db   $AF, $EA, $01, $D6, $FA, $9F, $C1, $E6
    db   $F0, $F6, $0D, $EA, $9F, $C1, $3E, $15
    db   $E0, $F2, $C9, $FE, $FF, $20, $15, $E1
    db   $AF, $EA, $01, $D6, $FA, $9F, $C1, $E6
    db   $F0, $F6, $0C, $EA, $9F, $C1, $C9, $55
    db   $49, $4A, $46, $47, $FE, $20, $28, $1F
    db   $F5, $FA, $AB, $C5, $57, $1E, $01, $FE
    db   $0F, $28, $08, $1E, $07, $FE, $19, $28
    db   $02, $1E, $03, $FA, $70, $C1, $C6, $04
    db   $A3, $20, $03, $7A, $E0, $F3, $F1, $16
    db   $00, $FE, $23, $20, $22, $FA, $08, $C1
    db   $5F, $3C, $FE, $05, $20, $01, $AF, $EA
    db   $08, $C1, $21, $4F, $DB, $FA, $6E, $DB
    db   $A7, $28, $03, $21, $44, $24, $19, $7E
    db   $3D, $FE, $FF, $20, $02, $3E, $20, $E0
    db   $D8, $5F, $3E, $1C, $EA, $00, $21, $21
    db   $E1, $45, $19, $5E, $16, $00, $CB, $23
    db   $CB, $12, $CB, $23, $CB, $12, $CB, $23
    db   $CB, $12, $CB, $23, $CB, $12, $CD, $C0
    db   $07, $21, $00, $50, $19, $E5, $C1, $E1
    db   $1E, $10, $0A, $22, $03, $1D, $20, $FA
    db   $36, $00, $E5, $3E, $1C, $EA, $00, $21
    db   $F0, $D8, $5F, $16, $00, $AF, $E1, $A7
    db   $28, $18, $5F, $FA, $75, $C1, $22, $FA
    db   $76, $C1, $D6, $20, $22, $3E, $00, $22
    db   $3E, $C9, $CB, $1B, $38, $01, $3D, $22
    db   $36, $00, $FA, $70, $C1, $C6, $01, $EA
    db   $70, $C1, $FA, $64, $C1, $CE, $00, $EA
    db   $64, $C1, $AF, $EA, $CC, $C1, $FA, $71
    db   $C1, $FE, $1F, $28, $10

toc_01_250A:
    ld   a, [$C19F]
    and  %11110000
    or   %00000110
    ld   [$C19F], a
    ld   a, $00
    ld   [$C172], a
    ret


    db   $C3, $90, $22, $22, $42, $98, $99, $FA
    db   $70, $C1, $E6, $1F, $20, $45, $FA, $C3
    db   $C3, $FE, $FF, $CA, $39, $24, $FE, $FE
    db   $CA, $21, $24, $FA, $CC, $C1, $A7, $20
    db   $07, $3C, $EA, $CC, $C1, $CD, $2B, $24
    db   $CD, $4D, $26, $F0, $CC, $CB, $67, $20
    db   $22, $CB, $6F, $28, $51, $3E, $1C, $EA
    db   $00, $21, $FA, $95, $DB, $FE, $07, $CA
    db   $17, $26, $FA, $73, $C1, $5F, $FA, $12
    db   $C1, $57, $21, $E1, $46, $19, $CB, $7E
    db   $CA, $17, $26, $1E, $00, $FA, $9F, $C1
    db   $E6, $80, $28, $01, $1C, $16, $00, $21
    db   $1F, $25, $19, $FA, $2E, $C1, $86, $EA
    db   $01, $D6, $21, $1D, $25, $19, $FA, $2F
    db   $C1, $86, $EA, $02, $D6, $3E, $4F, $EA
    db   $03, $D6, $F0, $E8, $EA, $04, $D6, $AF
    db   $EA, $05, $D6, $CD, $90, $22, $C9, $62
    db   $82, $98, $99

toc_01_25A5:
    ld   e, $00
    ld   a, [$C19F]
    and  %10000000
    jr   z, .else_01_25AF

    inc  e
toc_01_25A5.else_01_25AF:
    ld   d, $00
    ld   hl, $25A3
    add  hl, de
    ld   a, [$C12E]
    add  a, [hl]
    ld   b, a
    ld   hl, $25A1
toc_01_25A5.toc_01_25BD:
    add  hl, de
    ld   a, [$C12F]
    add  a, [hl]
    ld   c, a
    ld   e, $10
toc_01_25A5.loop_01_25C5:
    ld   a, c
    sub  a, $20
    ld   l, a
    ld   h, b
    ld   a, [bc]
    ld   [hl], a
    push bc
    ld   a, c
    add  a, $20
    ld   c, a
    ld   a, l
    add  a, $20
    ld   l, a
    ld   a, [bc]
    ld   [hl], a
    ld   a, l
    add  a, $20
    ld   l, a
    ld   a, [$FFE8]
    ld   [hl], a
    pop  bc
    inc  bc
    ld   a, c
    and  %00011111
    jr   nz, .else_01_25E9

    ld   a, c
    sub  a, $20
    ld   c, a
toc_01_25A5.else_01_25E9:
    dec  e
    jr   nz, .loop_01_25C5

    ld   a, $08
    ld   [$C172], a
    jp   toc_01_2290

    db   $C9, $42, $62, $98, $99

toc_01_25F9:
    ld   e, $00
    ld   a, [$C19F]
    and  %10000000
    jr   z, .else_01_2603

    inc  e
toc_01_25F9.else_01_2603:
    ld   d, $00
    ld   hl, $25F7
    add  hl, de
    ld   a, [$C12E]
    add  a, [hl]
    ld   b, a
    ld   hl, $25F5
    call toc_01_25A5.toc_01_25BD
    jp   toc_01_250A

    db   $3E, $02, $EA, $77, $C1, $C3, $A1, $22
    db   $F0, $CC, $CB, $6F, $20, $F2, $E6, $10
    db   $C2, $49, $26, $F0, $CC, $E6, $43, $28
    db   $0C, $21, $77, $C1, $7E, $3C, $E6, $01
    db   $77, $3E, $0A, $E0, $F2, $F0, $E7, $E6
    db   $10, $C8, $3E, $17, $EA, $00, $21, $C3
    db   $57, $7B, $CD, $A1, $22, $C9, $3E, $17
    db   $EA, $00, $21, $C3, $07, $7B, $3E, $02
    db   $CD, $B9, $07, $CD, $74, $7B, $C9, $01
    db   $01, $20, $20, $93, $93, $13, $13, $10
    db   $10, $01, $01, $08, $08, $0A, $0A, $01
    db   $FF, $F0, $10, $00, $00, $03, $00, $02
    db   $1E, $C0, $40, $3E, $08, $EA, $00, $21
    db   $CD, $86, $26, $CD, $C0, $07, $C9, $FA
    db   $2B, $C1, $FE, $00, $28, $05, $3D, $EA
    db   $2B, $C1, $C9, $FA, $25, $C1, $4F, $06
    db   $00, $3E, $01, $EA, $2B, $C1, $FA, $2A
    db   $C1, $E0, $D9, $21, $5E, $26, $09, $FA
    db   $27, $C1, $EA, $02, $D6, $86, $CB, $12
    db   $EA, $19, $D6, $FA, $26, $C1, $F6, $98
    db   $EA, $01, $D6, $CB, $1A, $CE, $00, $EA
    db   $18, $D6, $21, $62, $26, $09, $7E, $EA
    db   $03, $D6, $EA, $1A, $D6, $3E, $00, $EA
    db   $2F, $D6, $3E, $EE, $EA, $14, $D6, $EA
    db   $15, $D6, $EA, $16, $D6, $EA, $17, $D6
    db   $EA, $2B, $D6, $EA, $2C, $D6, $EA, $2D
    db   $D6, $EA, $2E, $D6, $06, $D6, $0E, $04
    db   $16, $D6, $1E, $1B, $C5, $D5, $F0, $D9
    db   $4F, $06, $00, $21, $11, $D7, $09, $06
    db   $00, $4E, $CB, $21, $CB, $10, $CB, $21
    db   $CB, $10, $21, $8C, $49, $FA, $A5, $DB
    db   $A7, $28, $03, $21, $60, $4D, $09, $D1
    db   $C1, $FA, $25, $C1, $E6, $02, $28, $0E
    db   $2A, $02, $03, $2A, $02, $03, $2A, $12
    db   $13, $7E, $12, $13, $18, $0C, $2A, $02
    db   $2A, $12, $03, $13, $2A, $02, $7E, $12
    db   $03, $13, $C5, $FA, $25, $C1, $4F, $06
    db   $00, $21, $66, $26, $09, $F0, $D9, $86
    db   $E0, $D9, $C1, $FA, $28, $C1, $3D, $EA
    db   $28, $C1, $20, $A0, $FA, $25, $C1, $4F
    db   $06, $00, $21, $6A, $26, $09, $7E, $EA
    db   $28, $C1, $21, $6E, $26, $09, $FA, $2A
    db   $C1, $86, $EA, $2A, $C1, $21, $76, $26
    db   $09, $FA, $27, $C1, $86, $CB, $1A, $E6
    db   $DF, $EA, $27, $C1, $21, $72, $26, $09
    db   $FA, $26, $C1, $CB, $12, $8E, $E6, $03
    db   $EA, $26, $C1, $FA, $29, $C1, $3D, $EA
    db   $29, $C1, $20, $03, $C3, $97, $27, $C9
    db   $FA, $24, $C1, $3C, $EA, $24, $C1, $C9
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $EA, $68, $D3, $E0, $BF, $3E, $38
    db   $E0, $AB, $AF, $E0, $A8, $C9

toc_01_27B5:
    push hl
    ld   hl, $0000
    ld   [hl], $0A
    pop  hl
    ret


    db   $3E, $02, $EA, $00, $21, $C5, $CD, $46
    db   $41, $C1, $C3, $C0, $07, $3E, $38, $E0
    db   $A8, $AF, $E0, $AB, $C9, $F0, $BC, $A7
    db   $20, $08, $3E, $1F, $EA, $00, $21, $CD
    db   $03, $40, $C3, $C0, $07, $3E, $01, $EA
    db   $00, $21, $CD, $CF, $5B, $C3, $C0, $07
    db   $E5, $F0, $E7, $21, $3D, $C1, $86, $21
    db   $44, $FF, $86, $0F, $EA, $3D, $C1, $E1
    db   $C9

toc_01_27FE:
    ld   a, [$C124]
    and  a
    jr   nz, .return_01_2838

    ld   a, JOYPAD_BUTTONS
    ld   [gbP1], a
    ld   a, [gbP1]
    ld   a, [gbP1]
    cpl
    and  %00001111
    ld   b, a
    ld   a, JOYPAD_DIRECTIONS
    ld   [gbP1], a
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    swap a
    cpl
    and  JOYPAD_BUTTONS | JOYPAD_DIRECTIONS | %11000000
    or   b
    ld   c, a
    ld   a, [$FFCB]
    xor  c
    and  c
    ld   [$FFCC], a
    ld   a, c
    ld   [$FFCB], a
    ld   a, JOYPAD_BUTTONS | JOYPAD_DIRECTIONS
    ld   [gbP1], a
toc_01_27FE.return_01_2838:
    ret


    db   $C5, $F0, $CD, $21, $97, $FF, $86, $E6
    db   $F8, $CB, $3F, $CB, $3F, $CB, $3F, $11
    db   $00, $00, $5F, $21, $00, $98, $06, $20
    db   $19, $05, $20, $FC, $E5, $F0, $CE, $21
    db   $96, $FF, $86, $E1, $E6, $F8, $CB, $3F
    db   $CB, $3F, $CB, $3F, $11, $00, $00, $5F
    db   $19, $7C, $E0, $CF, $7D, $E0, $D0, $C1
    db   $C9

toc_01_2872:
    ld   e, a
    ld   d, $00
    sla  e
    rl   d
    pop  hl
    add  hl, de
    ld   e, [hl]
    inc  hl
    ld   d, [hl]
    push de
    pop  hl
    jp   hl

toc_01_2881:
    ld   a, [gbIE]
    ld   [$FFD2], a
    res  0, a
toc_01_2881.loop_01_2887:
    ld   a, [gbLY]
    cp   145
    jr   nz, .loop_01_2887

    ld   a, [gbLCDC]
    and  LCDCF_BG_CHAR_8000 | LCDCF_BG_DISPLAY | LCDCF_BG_TILE_9C00 | LCDCF_OBJ_16_16 | LCDCF_OBJ_DISPLAY | LCDCF_TILEMAP_9C00 | LCDCF_WINDOW_ON
    ld   [gbLCDC], a
    ld   a, [$FFD2]
    ld   [gbIE], a
    ret


    db   $3E, $01, $CD, $B9, $07, $CD, $F3, $7C
    db   $C9, $3E, $7E, $01, $00, $04, $18, $05

toc_01_28A8:
    ld   a, $7F
    ld   bc, $0800
    ld   d, a
    ld   hl, gbBGDAT0
toc_01_28A8.loop_01_28B1:
    ld   a, d
    ldi  [hl], a
    dec  bc
    ld   a, b
    or   c
    jr   nz, .loop_01_28B1

    ret


    db   $EA, $00, $21, $CD, $C5, $28, $3E, $01
    db   $EA, $00, $21, $C9

toc_01_28C5:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    dec  bc
    ld   a, b
    or   c
    jr   nz, toc_01_28C5

    ret


toc_01_28CE:
    inc  de
    ld   h, a
    ld   a, [de]
    ld   l, a
    inc  de
    ld   a, [de]
    inc  de
    call toc_01_28F2
toc_01_28D8:
    ld   a, [$C124]
    and  a
    jr   nz, .else_01_28ED

toc_01_28D8.toc_01_28DE:
    ld   a, [de]
    and  a
    jr   nz, toc_01_28CE

    ret


toc_01_28D8.loop_01_28E3:
    inc  de
    ld   h, a
    ld   a, [de]
    ld   l, a
    inc  de
    ld   a, [de]
    inc  de
    call toc_01_2948
toc_01_28D8.else_01_28ED:
    ld   a, [de]
    and  a
    jr   nz, .loop_01_28E3

    ret


toc_01_28F2:
    push af
    and  %00111111
    ld   b, a
    inc  b
    pop  af
    rlca
    rlca
    and  %00000011
    jr   z, .else_01_2906

    dec  a
    jr   z, .else_01_291A

    dec  a
    jr   z, .else_01_292E

    jr   .loop_01_293B

toc_01_28F2.else_01_2906:
    ld   a, [de]
    ldi  [hl], a
    ld   a, l
    and  %00011111
    jr   nz, .else_01_2915

    ld   a, l
    sub  a, $20
    ld   l, a
    ld   a, h
    sbc  $00
    ld   h, a
toc_01_28F2.else_01_2915:
    inc  de
    dec  b
    jr   nz, .else_01_2906

    ret


toc_01_28F2.else_01_291A:
    ld   a, [de]
    ldi  [hl], a
    ld   a, l
    and  %00011111
    jr   nz, .else_01_2929

    ld   a, l
    sub  a, $20
    ld   l, a
    ld   a, h
    sbc  $00
    ld   h, a
toc_01_28F2.else_01_2929:
    dec  b
    jr   nz, .else_01_291A

    inc  de
    ret


toc_01_28F2.else_01_292E:
    ld   a, [de]
    ld   [hl], a
    inc  de
    ld   a, b
    ld   bc, $0020
    add  hl, bc
    ld   b, a
    dec  b
    jr   nz, .else_01_292E

    ret


toc_01_28F2.loop_01_293B:
    ld   a, [de]
    ld   [hl], a
    ld   a, b
    ld   bc, $0020
    add  hl, bc
    ld   b, a
    dec  b
    jr   nz, .loop_01_293B

    inc  de
    ret


toc_01_2948:
    push af
    and  %00111111
    ld   b, a
    inc  b
    pop  af
    and  %10000000
    jr   nz, .else_01_296A

toc_01_2948.loop_01_2952:
    ld   a, [de]
    cp   $EE
    jr   z, .else_01_2965

    ldi  [hl], a
    ld   a, l
    and  %00011111
    jr   nz, .else_01_2965

    ld   a, l
    sub  a, $20
    ld   l, a
    ld   a, h
    sbc  $00
    ld   h, a
toc_01_2948.else_01_2965:
    inc  de
    dec  b
    jr   nz, .loop_01_2952

    ret


toc_01_2948.else_01_296A:
    ld   a, [de]
    cp   $EE
    jr   z, .else_01_2970

    ld   [hl], a
toc_01_2948.else_01_2970:
    inc  de
    ld   a, b
    ld   bc, $0020
    add  hl, bc
    ld   b, a
    dec  b
    jr   nz, .else_01_296A

    ret


    db   $01, $00, $16, $18, $16, $01, $00, $13
    db   $18, $11, $01, $2F, $00, $18, $03

toc_01_298A:
    ld   bc, $006D
    ld   hl, $FF90
    call .loop_01_2999
    ld   bc, $1F00
    ld   hl, gbRAM
toc_01_298A.loop_01_2999:
    xor  a
    ldi  [hl], a
    dec  bc
    ld   a, b
    or   c
    jr   nz, .loop_01_2999

    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3E
    db   $14, $EA, $00, $21, $21, $00, $45, $19
    db   $7E, $C3, $C0, $07, $FA, $AC, $C5, $A7
    db   $20, $04, $3E, $2D, $E0, $F4, $C9, $3E
    db   $01, $EA, $00, $21, $CD, $07, $58, $C3
    db   $C0, $07, $3E, $08, $EA, $00, $21, $21
    db   $10, $51, $19, $7E, $C3, $C0, $07, $3E
    db   $08, $EA, $00, $21, $21, $10, $51, $19
    db   $7E, $F5, $3E, $03, $EA, $00, $21, $F1
    db   $C9, $3E, $13, $EA, $00, $21, $21, $00
    db   $68, $11, $00, $90, $01, $00, $08, $CD
    db   $C5, $28, $21, $00, $70, $11, $00, $88
    db   $01, $00, $08, $C3, $C5, $28, $CD, $26
    db   $2A, $11, $00, $84, $21, $00, $76, $01
    db   $00, $01, $C3, $C5, $28, $3E, $13, $EA
    db   $00, $21, $21, $00, $40, $11, $00, $80
    db   $01, $00, $18, $CD, $C5, $28, $3E, $0C
    db   $EA, $00, $21, $21, $E0, $57, $11, $F0
    db   $97, $01, $10, $00, $CD, $C5, $28, $3E
    db   $12, $EA, $00, $21, $21, $00, $75, $11
    db   $00, $80, $01, $40, $00, $CD, $C5, $28
    db   $11, $00, $8D, $21, $00, $75, $01, $00
    db   $02, $C3, $C5, $28, $3E, $0C, $EA, $00
    db   $21, $21, $00, $50, $11, $00, $90, $01
    db   $00, $08, $CD, $C5, $28, $3E, $12, $EA
    db   $00, $21, $21, $00, $60, $11, $00, $80
    db   $01, $00, $08, $CD, $C5, $28, $3E, $0F
    db   $EA, $00, $21, $21, $00, $60, $11, $00
    db   $88, $01, $00, $08, $C3, $C5, $28, $21
    db   $00, $40, $18, $08, $21, $00, $48, $18
    db   $03, $21, $00, $60, $3E, $13, $EA, $00
    db   $21, $11, $00, $80, $01, $00, $08, $CD
    db   $C5, $28, $21, $00, $58, $11, $00, $88
    db   $01, $00, $10, $C3, $C5, $28, $CD, $44
    db   $08, $21, $00, $68, $3E, $10, $CD, $FC
    db   $2A, $CD, $44, $08, $3E, $12, $EA, $00
    db   $21, $21, $00, $66, $11, $00, $80, $01
    db   $80, $00, $CD, $C5, $28, $CD, $44, $08
    db   $3E, $0C, $EA, $00, $21, $21, $20, $42
    db   $11, $00, $81, $01, $20, $00, $C3, $C5
    db   $28, $21, $00, $78, $18, $03, $21, $00
    db   $48, $3E, $13, $EA, $00, $21, $11, $00
    db   $80, $01, $00, $08, $CD, $C5, $28, $3E
    db   $13, $EA, $00, $21, $21, $00, $70, $11
    db   $00, $88, $01, $00, $08, $CD, $C5, $28
    db   $21, $00, $68, $11, $00, $90, $01, $00
    db   $08, $C3, $C5, $28, $C5, $3E, $14, $EA
    db   $00, $21, $21, $00, $42, $F0, $F7, $FE
    db   $0B, $30, $32, $CB, $37, $4F, $06, $00
    db   $CB, $21, $CB, $10, $CB, $21, $CB, $10
    db   $09, $F0, $F7, $FE, $06, $20, $0A, $FA
    db   $6B, $DB, $E6, $04, $28, $03, $21, $C0
    db   $44, $19, $7E, $5F, $16, $00, $F0, $F7
    db   $FE, $1A, $30, $05, $FE, $06, $38, $01
    db   $14, $21, $00, $D9, $19, $CD, $C0, $07
    db   $C1, $C9

toc_01_2B6B:
    ld   a, $0C
    call toc_01_07B9
    ld   hl, $4000
    ld   de, $8000
    ld   bc, $0400
    call toc_01_28C5
    ld   a, $0C
    call toc_01_07B9
    ld   hl, $4800
    ld   de, $8800
    ld   bc, $1000
    call toc_01_28C5
    ld   hl, $47A0
    ld   de, $8E00
    ld   bc, $0020
    call toc_01_28C5
    ld   a, $01
    call toc_01_07B9
    ret


    db   $CD, $6B, $2B, $3E, $0F, $CD, $B9, $07
    db   $21, $00, $40, $11, $00, $88, $01, $00
    db   $04, $CD, $C5, $28, $3E, $0F, $CD, $B9
    db   $07, $21, $00, $50, $11, $00, $90, $01
    db   $00, $08, $C3, $C5, $28, $3E, $01, $CD
    db   $B9, $07, $F0, $F7, $5F, $16, $00, $D5
    db   $21, $64, $7F, $19, $66, $2E, $00, $3E
    db   $0D, $CD, $B9, $07, $11, $00, $91, $01
    db   $00, $01, $CD, $C5, $28, $21, $00, $40
    db   $11, $00, $92, $01, $00, $06, $CD, $C5
    db   $28, $3E, $01, $EA, $00, $21, $D1, $D5
    db   $21, $84, $7F, $19, $66, $2E, $00, $CD
    db   $C0, $07, $11, $00, $92, $01, $00, $02
    db   $CD, $C5, $28, $3E, $0C, $EA, $00, $21
    db   $21, $C0, $47, $11, $C0, $DC, $01, $40
    db   $00, $CD, $C5, $28, $CD, $A1, $2C, $3E
    db   $01, $EA, $00, $21, $D1, $21, $A4, $7F
    db   $19, $66, $2E, $00, $3E, $12, $CD, $B9
    db   $07, $11, $00, $8F, $01, $00, $01, $CD
    db   $C5, $28, $21, $00, $7D, $F0, $F7, $FE
    db   $0A, $38, $08, $3E, $0C, $CD, $B9, $07
    db   $21, $00, $4C, $11, $00, $8C, $01, $00
    db   $03, $CD, $C5, $28, $FA, $4B, $DB, $A7
    db   $28, $03, $CD, $54, $1D, $FA, $A5, $DB
    db   $A7, $28, $06, $F0, $F7, $FE, $0A, $38
    db   $0A, $FA, $15, $DB, $FE, $06, $38, $03
    db   $CD, $BE, $1D, $FA, $0E, $DB, $FE, $02
    db   $38, $04, $3E, $0D, $E0, $A5, $C9, $3E
    db   $0C, $CD, $B9, $07, $21, $00, $52, $11
    db   $00, $92, $01, $00, $06, $CD, $C5, $28
    db   $21, $00, $4C, $11, $00, $8C, $01, $00
    db   $04, $CD, $C5, $28, $CD, $A1, $2C, $C3
    db   $53, $2C, $AF, $E0, $A6, $E0, $A7, $CD
    db   $6B, $1B, $21, $00, $48, $11, $00, $88
    db   $01, $00, $08, $CD, $C5, $28, $21, $00
    db   $42, $11, $00, $82, $01, $00, $01, $CD
    db   $C5, $28, $C9, $3E, $01, $CD, $B9, $07
    db   $21, $31, $7D, $11, $00, $87, $01, $80
    db   $00, $CD, $C5, $28, $3E, $10, $CD, $B9
    db   $07, $21, $00, $54, $11, $00, $80, $01
    db   $00, $06, $CD, $C5, $28, $21, $00, $40
    db   $11, $00, $88, $01, $00, $10, $C3, $C5
    db   $28, $3E, $0F, $CD, $B9, $07, $21, $00
    db   $49, $11, $00, $88, $01, $00, $07, $C3
    db   $C5, $28, $3E, $0C, $CD, $B9, $07, $21
    db   $00, $78, $11, $00, $8F, $01, $00, $08
    db   $CD, $C5, $28, $21, $00, $50, $11, $00
    db   $82, $01, $00, $01, $C3, $C5, $28, $21
    db   $00, $70, $18, $08, $21, $00, $78, $18
    db   $03, $21, $00, $58, $3E, $10, $CD, $B9
    db   $07, $11, $00, $90, $01, $00, $08, $C3
    db   $C5, $28, $3E, $13, $EA, $00, $21, $21
    db   $00, $7C, $11, $00, $8C, $01, $00, $04
    db   $CD, $C5, $28, $21, $00, $68, $11, $00
    db   $90, $01, $00, $04, $C3, $C5, $28, $3E
    db   $10, $CD, $B9, $07, $21, $00, $67, $11
    db   $00, $84, $01, $00, $04, $CD, $C5, $28
    db   $21, $00, $60, $11, $00, $90, $01, $00
    db   $06, $C3, $C5, $28, $3E, $0F, $CD, $B9
    db   $07, $21, $00, $44, $11, $00, $88, $01
    db   $00, $05, $C3, $C5, $28, $00, $11, $0E
    db   $12, $AF, $E0, $D7, $21, $93, $C1, $5F
    db   $16, $00, $19, $A7, $20, $42, $FA, $A5
    db   $DB, $A7, $28, $19, $F0, $F9, $A7, $20
    db   $37, $F0, $F7, $FE, $14, $28, $31, $FE
    db   $0A, $38, $2D, $F0, $F6, $FE, $FD, $28
    db   $27, $FE, $B1, $28, $23, $FA, $56, $DB
    db   $FE, $01, $3E, $A4, $28, $18, $FA, $79
    db   $DB, $A7, $3E, $D8, $20, $10, $FA, $7B
    db   $DB, $A7, $3E, $DD, $20, $08, $FA, $73
    db   $DB, $A7, $28, $04, $3E, $8F, $18, $01
    db   $7E, $F5, $E6, $3F, $47, $0E, $00, $F1
    db   $CB, $37, $1F, $1F, $E6, $03, $5F, $16
    db   $00, $21, $84, $2D, $19, $7E, $EA, $00
    db   $21, $F0, $D7, $57, $1E, $00, $21, $00
    db   $84, $19, $E5, $D1, $21, $00, $40, $09
    db   $01, $00, $01, $CD, $C5, $28, $F0, $D7
    db   $3C, $FE, $04, $C2, $89, $2D, $11, $00
    db   $90, $FA, $A5, $DB, $A7, $28, $3F, $3E
    db   $0D, $EA, $00, $21, $F0, $F9, $A7, $28
    db   $22, $21, $00, $70, $F0, $F7, $FE, $06
    db   $28, $0F, $FE, $0A, $30, $05, $21, $00
    db   $78, $18, $06, $F0, $F6, $FE, $E9, $28
    db   $F5, $11, $00, $90, $01, $00, $08, $CD
    db   $C5, $28, $C9, $21, $00, $50, $F0, $94
    db   $FE, $FF, $28, $09, $C6, $50, $67, $01
    db   $00, $01, $CD, $C5, $28, $C9, $3E, $0F
    db   $EA, $00, $21, $F0, $94, $FE, $0F, $28
    db   $0B, $C6, $40, $67, $2E, $00, $01, $00
    db   $02, $CD, $C5, $28, $C9, $3E, $08, $CD
    db   $B9, $07, $11, $00, $98, $21, $11, $D7
    db   $0E, $80, $D5, $E5, $C5, $7E, $4F, $06
    db   $00, $CB, $21, $CB, $10, $CB, $21, $CB
    db   $10, $21, $8C, $49, $FA, $A5, $DB, $A7
    db   $28, $03, $21, $60, $4D, $09, $2A, $12
    db   $13, $2A, $12, $7B, $C6, $1F, $5F, $7A
    db   $CE, $00, $57, $2A, $12, $13, $7E, $12
    db   $C1, $E1, $D1, $23, $7D, $E6, $0F, $FE
    db   $0B, $20, $06, $7D, $E6, $F0, $C6, $11
    db   $6F, $7B, $C6, $02, $5F, $E6, $1F, $FE
    db   $14, $20, $0A, $7B, $E6, $E0, $C6, $40
    db   $5F, $7A, $CE, $00, $57, $0D, $20, $AA
    db   $3E, $01, $EA, $00, $21, $C3, $C1, $7D
    db   $3E, $01, $E0, $FF, $21, $7F, $D4, $34
    db   $3E, $09, $EA, $00, $21, $AF, $E0, $E6
    db   $EA, $9C, $C1, $EA, $04, $C5, $EA, $C8
    db   $DB, $EA, $C9, $DB, $EA, $A2, $C1, $EA
    db   $C6, $C1, $EA, $FA, $D6, $EA, $0A, $C5
    db   $E0, $AC, $EA, $13, $C1, $EA, $60, $D4
    db   $EA, $BE, $C1, $EA, $0E, $C5, $EA, $C8
    db   $C3, $EA, $A6, $C5, $EA, $62, $D4, $EA
    db   $CD, $C3, $3E, $FF, $EA, $01, $D4, $EA
    db   $0F, $C5, $FA, $A5, $DB, $A7, $28, $69
    db   $3E, $14, $EA, $00, $21, $E0, $E8, $F0
    db   $F7, $FE, $0B, $30, $2B, $21, $00, $42
    db   $CB, $37, $5F, $16, $00, $CB, $23, $CB
    db   $12, $CB, $23, $CB, $12, $19, $F0, $F7
    db   $FE, $06, $20, $0A, $FA, $6B, $DB, $E6
    db   $04, $28, $03, $21, $C0, $44, $FA, $AE
    db   $DB, $5F, $16, $00, $19, $7E, $E0, $F6
    db   $F0, $F6, $4F, $06, $00, $F0, $F7, $FE
    db   $1A, $30, $05, $FE, $06, $38, $01, $04
    db   $21, $00, $40, $09, $7E, $EA, $8E, $C1
    db   $AF, $EA, $8A, $C1, $EA, $8B, $C1, $EA
    db   $90, $C1, $EA, $8F, $C1, $5F, $21, $B5
    db   $DB, $AF, $22, $1C, $7B, $FE, $11, $20
    db   $F8, $F0, $F6, $5F, $16, $00, $21, $00
    db   $D8, $FA, $A5, $DB, $A7, $28, $10, $21
    db   $00, $D9, $F0, $F7, $FE, $1A, $30, $07
    db   $FE, $06, $38, $03, $21, $00, $DA, $19
    db   $F0, $F9, $A7, $7E, $20, $03, $F6, $80
    db   $77, $E0, $F8, $F0, $F6, $4F, $06, $00
    db   $CB, $21, $CB, $10, $FA, $A5, $DB, $A7
    db   $28, $39, $3E, $0A, $EA, $00, $21, $E0
    db   $E8, $F0, $F7, $FE, $1F, $20, $13, $F0
    db   $F6, $FE, $F5, $20, $0D, $FA, $0E, $DB
    db   $FE, $0E, $20, $06, $01, $53, $78, $C3
    db   $7D, $30, $21, $00, $40, $F0, $F7, $FE
    db   $1A, $30, $75, $FE, $06, $38, $71, $3E
    db   $0B, $EA, $00, $21, $E0, $E8, $21, $00
    db   $40, $18, $65, $F0, $F6, $FE, $0E, $20
    db   $0C, $FA, $0E, $D8, $E6, $10, $28, $55
    db   $01, $F0, $47, $18, $5E, $FE, $8C, $20
    db   $0C, $FA, $8C, $D8, $E6, $10, $28, $45
    db   $01, $56, $43, $18, $4E, $FE, $79, $20
    db   $0C, $FA, $79, $D8, $E6, $10, $28, $35
    db   $01, $FD, $64, $18, $3E, $FE, $06, $20
    db   $0C, $FA, $06, $D8, $E6, $10, $28, $25
    db   $01, $96, $44, $18, $2E, $FE, $1B, $20
    db   $0C, $FA, $2B, $D8, $E6, $10, $28, $15
    db   $01, $13, $4C, $18, $1E, $FE, $2B, $20
    db   $0C, $FA, $2B, $D8, $E6, $10, $28, $05
    db   $01, $AC, $50, $18, $0E, $21, $00, $40
    db   $09, $2A, $4F, $7E, $47, $FA, $A5, $DB
    db   $A7, $20, $0B, $F0, $F6, $FE, $80, $38
    db   $05, $3E, $1A, $EA, $00, $21, $0A, $FE
    db   $FE, $28, $4F, $E0, $A4, $03, $FA, $A5
    db   $DB, $A7, $28, $10, $0A, $E6, $0F, $CD
    db   $CF, $36, $0A, $CB, $37, $E6, $0F, $CD
    db   $C9, $37, $18, $04, $0A, $CD, $CF, $36
    db   $03, $0A, $E6, $FC, $FE, $E0, $20, $20
    db   $F0, $E6, $5F, $16, $00, $21, $01, $D4
    db   $19, $0A, $E6, $03, $22, $03, $0A, $22
    db   $03, $0A, $22, $03, $0A, $22, $03, $0A
    db   $22, $7B, $C6, $05, $E0, $E6, $18, $D8
    db   $0A, $FE, $FE, $28, $05, $CD, $DC, $30
    db   $18, $CE, $3E, $01, $EA, $00, $21, $CD
    db   $DE, $7C, $C3, $C0, $07, $AF, $E0, $D7
    db   $0A, $CB, $7F, $28, $07, $CB, $67, $20
    db   $03, $E0, $D7, $03, $03, $F0, $F8, $5F
    db   $FA, $A5, $DB, $A7, $20, $18, $0A, $D6
    db   $F5, $38, $3E, $C7, $38, $33, $25, $34
    db   $45, $34, $EF, $33, $5F, $34, $79, $34
    db   $98, $34, $C2, $34, $DC, $34, $0A, $D6
    db   $EC, $DA, $FD, $31, $C7, $EB, $34, $06
    db   $35, $21, $35, $3C, $35, $55, $35, $68
    db   $35, $7B, $35, $8E, $35, $A3, $35, $D2
    db   $35, $E6, $35, $FA, $35, $0E, $36, $46
    db   $36, $55, $36, $64, $36, $8A, $36, $9E
    db   $36, $C6, $F5, $F5, $57, $FE, $E9, $20
    db   $03, $EA, $0E, $C5, $FE, $5E, $20, $04
    db   $CB, $6B, $20, $65, $FE, $91, $20, $09
    db   $CB, $6B, $28, $05, $F1, $3E, $5E, $57
    db   $F5, $FE, $DC, $20, $09, $CB, $6B, $28
    db   $05, $F1, $3E, $91, $57, $F5, $FE, $D8
    db   $28, $08, $FE, $D9, $28, $04, $FE, $DA
    db   $20, $09, $CB, $63, $28, $05, $F1, $3E
    db   $DB, $57, $F5, $FE, $C2, $20, $09, $CB
    db   $63, $28, $05, $F1, $3E, $E3, $57, $F5
    db   $7A, $FE, $BA, $20, $09, $CB, $53, $28
    db   $05, $F1, $3E, $E1, $57, $F5, $7A, $FE
    db   $D3, $20, $1B, $CB, $63, $28, $17, $F0
    db   $F6, $FE, $75, $28, $0C, $FE, $07, $28
    db   $08, $FE, $AA, $28, $04, $FE, $4A, $20
    db   $05, $F1, $3E, $C6, $57, $F5, $7A, $E0
    db   $E0, $FE, $C2, $28, $20, $FE, $E1, $28
    db   $1C, $FE, $CB, $28, $18, $FE, $BA, $28
    db   $14, $FE, $61, $28, $10, $FE, $C6, $28
    db   $0C, $FE, $C5, $28, $08, $FE, $E2, $28
    db   $04, $FE, $E3, $20, $12, $FA, $9C, $C1
    db   $5F, $3C, $EA, $9C, $C1, $16, $00, $21
    db   $16, $D4, $19, $0B, $0A, $77, $03, $F0
    db   $E0, $FE, $C5, $CA, $AA, $32, $FE, $C6
    db   $CA, $AA, $32, $C3, $FB, $32, $C6, $EC
    db   $E0, $E0, $F5, $FE, $CF, $38, $08, $FE
    db   $D3, $30, $04, $21, $A5, $C1, $34, $FE
    db   $AB, $20, $22, $AF, $EA, $CB, $C3, $F0
    db   $F6, $FE, $C4, $F0, $E0, $28, $16, $21
    db   $C9, $DB, $34, $EA, $CB, $C3, $F5, $FA
    db   $CD, $C3, $C6, $04, $EA, $CD, $C3, $3E
    db   $04, $EA, $6B, $C1, $F1, $FE, $8E, $28
    db   $13, $FE, $AA, $28, $0F, $FE, $DC, $28
    db   $04, $FE, $DB, $20, $0C, $21, $FA, $D6
    db   $36, $02, $18, $05, $21, $FA, $D6, $36
    db   $01, $FE, $3F, $28, $04, $FE, $47, $20
    db   $04, $CB, $53, $20, $0C, $FE, $40, $28
    db   $04, $FE, $48, $20, $08, $CB, $5B, $28
    db   $04, $F1, $3E, $3D, $F5, $FE, $41, $28
    db   $04, $FE, $49, $20, $04, $CB, $4B, $20
    db   $0C, $FE, $42, $28, $04, $FE, $4A, $20
    db   $08, $CB, $43, $28, $04, $F1, $3E, $3E
    db   $F5, $FE, $A1, $20, $08, $CB, $63, $20
    db   $04, $F1, $F0, $E9, $F5, $FE, $BF, $20
    db   $06, $CB, $63, $20, $02, $F1, $C9, $FE
    db   $BE, $28, $08, $FE, $BF, $28, $04, $FE
    db   $CB, $20, $19, $0B, $3E, $01, $E0, $AC
    db   $0A, $E6, $F0, $C6, $10, $E0, $AE, $0A
    db   $CB, $37, $E6, $F0, $C6, $08, $E0, $AD
    db   $03, $C3, $FB, $32, $FE, $D6, $28, $04
    db   $FE, $D5, $20, $08, $CB, $63, $20, $04
    db   $F1, $3E, $21, $F5, $FE, $D7, $28, $04
    db   $FE, $D8, $20, $08, $CB, $63, $20, $04
    db   $F1, $3E, $22, $F5, $F0, $F7, $FE, $0A
    db   $F0, $E0, $38, $04, $FE, $A9, $28, $04
    db   $FE, $DE, $20, $08, $CB, $73, $28, $04
    db   $F1, $3E, $0D, $F5, $FE, $A0, $20, $08
    db   $CB, $63, $28, $04, $F1, $3E, $A1, $F5
    db   $16, $00, $F0, $D7, $A7, $28, $1F, $0B
    db   $0A, $5F, $21, $11, $D7, $19, $F0, $D7
    db   $E6, $0F, $5F, $F1, $57, $7A, $22, $F0
    db   $D7, $E6, $40, $28, $04, $7D, $C6, $0F
    db   $6F, $1D, $20, $F1, $03, $C9, $0B, $0A
    db   $5F, $21, $11, $D7, $19, $F1, $77, $03
    db   $C9, $0B, $0A, $C6, $11, $5F, $E6, $0F
    db   $20, $04, $7B, $D6, $10, $5F, $16, $00
    db   $21, $00, $D7, $19, $F0, $D7, $A7, $28
    db   $19, $E6, $0F, $5F, $CD, $69, $33, $0B
    db   $F0, $D7, $E6, $40, $16, $F1, $28, $02
    db   $16, $0F, $7D, $82, $6F, $1D, $20, $EC
    db   $03, $C9, $7E, $FE, $10, $3E, $25, $38
    db   $02, $C6, $04, $22, $7E, $FE, $10, $3E
    db   $26, $38, $02, $C6, $04, $32, $7D, $C6
    db   $10, $6F, $7E, $FE, $8A, $30, $0A, $FE
    db   $10, $3E, $27, $38, $06, $3E, $2A, $18
    db   $02, $3E, $82, $22, $7E, $FE, $8A, $30
    db   $0A, $FE, $10, $3E, $28, $38, $06, $3E
    db   $29, $18, $02, $3E, $83, $77, $03, $C9
    db   $E5, $D5, $0A, $5F, $16, $00, $19, $D1
    db   $1A, $FE, $E1, $28, $08, $FE, $E2, $28
    db   $04, $FE, $E3, $20, $1A, $F5, $E5, $D5
    db   $7D, $D6, $11, $F5, $FA, $9C, $C1, $5F
    db   $3C, $EA, $9C, $C1, $16, $00, $21, $16
    db   $D4, $19, $F1, $77, $D1, $E1, $F1, $77
    db   $13, $03, $E1, $0A, $A7, $FE, $FF, $20
    db   $C7, $C1, $C9, $00, $01, $02, $10, $11
    db   $12, $FF, $B6, $B7, $66, $67, $E3, $68
    db   $C5, $CD, $FC, $33, $01, $E2, $33, $11
    db   $E9, $33, $C3, $A7, $33, $0B, $0A, $5F
    db   $16, $00, $21, $11, $D7, $19, $C9, $00
    db   $01, $02, $03, $04, $10, $11, $12, $13
    db   $14, $20, $21, $22, $23, $24, $FF, $55
    db   $5A, $5A, $5A, $56, $57, $59, $59, $59
    db   $58, $5B, $E2, $5B, $E2, $5B, $C5, $CD
    db   $FC, $33, $01, $06, $34, $11, $16, $34
    db   $C3, $A7, $33, $00, $01, $02, $10, $11
    db   $12, $20, $21, $22, $FF, $55, $5A, $56
    db   $57, $59, $58, $5B, $E2, $5B, $C5, $CD
    db   $FC, $33, $01, $32, $34, $11, $3C, $34
    db   $C3, $A7, $33, $00, $01, $02, $10, $11
    db   $12, $FF, $A4, $A5, $A6, $A7, $E3, $A8
    db   $C5, $CD, $FC, $33, $01, $52, $34, $11
    db   $59, $34, $C3, $A7, $33, $00, $01, $10
    db   $11, $FF, $BB, $BC, $BD, $BE, $09, $09
    db   $09, $09, $C5, $CD, $FC, $33, $01, $6C
    db   $34, $11, $71, $34, $F0, $F8, $E6, $04
    db   $28, $03, $11, $75, $34, $C3, $A7, $33
    db   $00, $01, $10, $11, $FF, $B6, $B7, $CD
    db   $CE, $C5, $CD, $FC, $33, $01, $8F, $34
    db   $11, $94, $34, $C3, $A7, $33, $00, $01
    db   $02, $10, $11, $12, $1F, $20, $21, $22
    db   $23, $30, $31, $32, $FF, $2B, $2C, $2D
    db   $37, $E8, $38, $0A, $33, $2F, $34, $0A
    db   $0A, $0A, $0A, $C5, $CD, $FC, $33, $01
    db   $A5, $34, $11, $B4, $34, $C3, $A7, $33
    db   $00, $01, $02, $10, $11, $12, $FF, $52
    db   $52, $52, $5B, $E2, $5B, $C5, $CD, $FC
    db   $33, $01, $CF, $34, $11, $D6, $34, $C3
    db   $A7, $33, $2D, $2E, $1E, $00, $CD, $27
    db   $36, $F0, $F8, $E6, $04, $C2, $A3, $35
    db   $C5, $CD, $FC, $33, $01, $C9, $36, $11
    db   $E9, $34, $C3, $A7, $33, $2F, $30, $1E
    db   $01, $CD, $27, $36, $F0, $F8, $E6, $08
    db   $C2, $D2, $35, $C5, $CD, $FC, $33, $01
    db   $C9, $36, $11, $04, $35, $C3, $A7, $33
    db   $31, $32, $1E, $02, $CD, $27, $36, $F0
    db   $F8, $E6, $02, $C2, $E6, $35, $C5, $CD
    db   $FC, $33, $01, $CC, $36, $11, $1F, $35
    db   $C3, $A7, $33, $33, $34, $1E, $03, $CD
    db   $27, $36, $F0, $F8, $E6, $01, $C2, $FA
    db   $35, $C5, $CD, $FC, $33, $01, $CC, $36
    db   $11, $3A, $35, $C3, $A7, $33, $1E, $04
    db   $CD, $27, $36, $FA, $8A, $C1, $F6, $01
    db   $EA, $8A, $C1, $EA, $8B, $C1, $C3, $A3
    db   $35, $1E, $05, $CD, $27, $36, $FA, $8A
    db   $C1, $F6, $02, $EA, $8A, $C1, $EA, $8B
    db   $C1, $C3, $D2, $35, $1E, $06, $CD, $27
    db   $36, $FA, $8A, $C1, $F6, $04, $EA, $8A
    db   $C1, $EA, $8B, $C1, $C3, $E6, $35, $1E
    db   $07, $CD, $27, $36, $FA, $8A, $C1, $F6
    db   $08, $EA, $8A, $C1, $EA, $8B, $C1, $C3
    db   $FA, $35, $43, $44, $3E, $04, $CD, $B5
    db   $35, $C5, $CD, $FC, $33, $01, $C9, $36
    db   $11, $A1, $35, $C3, $A7, $33, $F5, $F0
    db   $F6, $5F, $16, $00, $F0, $F7, $FE, $1A
    db   $30, $05, $FE, $06, $38, $01, $14, $21
    db   $00, $D9, $19, $F1, $B6, $77, $E0, $F8
    db   $C9, $8C, $08, $3E, $08, $CD, $B5, $35
    db   $C5, $CD, $FC, $33, $01, $C9, $36, $11
    db   $D0, $35, $C3, $A7, $33, $09, $0A, $3E
    db   $02, $CD, $B5, $35, $C5, $CD, $FC, $33
    db   $01, $CC, $36, $11, $E4, $35, $C3, $A7
    db   $33, $0B, $0C, $3E, $01, $CD, $B5, $35
    db   $C5, $CD, $FC, $33, $01, $CC, $36, $11
    db   $F8, $35, $C3, $A7, $33, $A4, $A5, $1E
    db   $08, $CD, $27, $36, $F0, $F8, $E6, $04
    db   $C2, $A3, $35, $C5, $CD, $FC, $33, $01
    db   $C9, $36, $11, $0C, $36, $C3, $A7, $33
    db   $16, $00, $21, $F0, $C1, $19, $0B, $0A
    db   $77, $F5, $E6, $F0, $21, $E0, $C1, $19
    db   $77, $F1, $CB, $37, $E6, $F0, $21, $D0
    db   $C1, $19, $77, $03, $C9, $AF, $B0, $C5
    db   $CD, $FC, $33, $01, $CC, $36, $11, $44
    db   $36, $C3, $A7, $33, $B1, $B2, $C5, $CD
    db   $FC, $33, $01, $C9, $36, $11, $53, $36
    db   $C3, $A7, $33, $45, $46, $C5, $CD, $FC
    db   $33, $01, $C9, $36, $11, $62, $36, $C3
    db   $A7, $33, $00, $01, $02, $03, $10, $11
    db   $12, $13, $20, $21, $22, $23, $FF, $B3
    db   $B4, $B4, $B5, $B6, $B7, $B8, $B9, $BA
    db   $BB, $BC, $BD, $3E, $08, $CD, $B5, $35
    db   $C5, $CD, $FC, $33, $01, $71, $36, $11
    db   $7E, $36, $C3, $A7, $33, $C1, $C2, $F0
    db   $F7, $FE, $1A, $30, $13, $FE, $06, $38
    db   $0F, $F0, $F6, $FE, $D3, $20, $09, $FA
    db   $46, $DB, $A7, $28, $03, $C3, $68, $35
    db   $3E, $01, $CD, $B5, $35, $C5, $CD, $FC
    db   $33, $01, $C9, $36, $11, $9C, $36, $C3
    db   $A7, $33, $00, $01, $FF, $00, $10, $FF
    db   $E0, $E9, $16, $80, $21, $11, $D7, $5F
    db   $7D, $E6, $0F, $28, $05, $FE, $0B, $30
    db   $01, $73, $23, $15, $20, $F2, $C9, $3E
    db   $01, $EA, $00, $21, $CD, $61, $5C, $3E
    db   $16, $EA, $00, $21, $AF, $E0, $E4, $F0
    db   $F6, $4F, $06, $00, $CB, $21, $CB, $10
    db   $21, $00, $40, $FA, $A5, $DB, $A7, $28
    db   $3F, $F0, $F7, $FE, $06, $20, $2A, $FA
    db   $6F, $DB, $21, $F6, $FF, $BE, $20, $21
    db   $3E, $A8, $CD, $01, $3C, $FA, $70, $DB
    db   $21, $00, $C2, $19, $77, $FA, $71, $DB
    db   $21, $10, $C2, $19, $77, $CD, $B3, $37
    db   $21, $60, $C4, $19, $36, $FF, $AF, $E0
    db   $E4, $21, $00, $42, $F0, $F7, $FE, $1A
    db   $30, $06, $FE, $06, $38, $02, $24, $24
    db   $09, $2A, $4F, $7E, $47, $0A, $FE, $FF
    db   $28, $05, $CD, $62, $37, $18, $F6, $CD
    db   $C0, $07, $C9, $01, $02, $04, $08, $10
    db   $20, $40, $80, $F0, $E4, $FE, $08, $30
    db   $12, $5F, $16, $00, $21, $5A, $37, $19
    db   $F0, $F6, $5F, $7E, $21, $00, $CF, $19
    db   $A6, $20, $12, $1E, $00, $53, $21, $80
    db   $C2, $19, $7E, $FE, $00, $28, $0D, $1C
    db   $7B, $FE, $10, $20, $F1, $21, $E4, $FF
    db   $34, $03, $03, $C9, $36, $04, $0A, $E6
    db   $F0, $21, $10, $C2, $19, $C6, $10, $77
    db   $0A, $03, $CB, $37, $E6, $F0, $21, $00
    db   $C2, $19, $C6, $08, $77, $21, $A0, $C3
    db   $19, $0A, $03, $77, $3E, $03, $EA, $00
    db   $21, $CD, $52, $65, $3E, $01, $EA, $00
    db   $21, $CD, $0A, $5C, $3E, $16, $EA, $00
    db   $21, $C9, $5F, $3E, $14, $EA, $00, $21
    db   $7B, $C5, $CD, $00, $50, $C1, $F0, $E8
    db   $EA, $00, $21, $C9, $3E, $01, $EA, $00
    db   $21, $CD, $E8, $7E, $C9, $FF, $FF, $3E
    db   $14, $EA, $00, $21, $21, $FF, $56, $19
    db   $7E, $21, $00, $21, $36, $05, $C9, $3E
    db   $19, $CD, $B9, $07, $CD, $C2, $77, $3E
    db   $03, $C3, $B9, $07, $3E, $03, $EA, $00
    db   $21, $CD, $41, $54, $C3, $C0, $07, $3E
    db   $14, $EA, $00, $21, $CD, $64, $59, $C3
    db   $C0, $07, $3E, $01, $CD, $B9, $07, $CD
    db   $6B, $5D, $3E, $02, $C3, $B9, $07, $3E
    db   $03, $EA, $00, $21, $CD, $B0, $48, $C3
    db   $C0, $07, $3E, $14, $EA, $00, $21, $CD
    db   $22, $58, $3E, $03, $EA, $00, $21, $C9
    db   $00, $08, $10, $18, $21, $A7, $C5, $7E
    db   $A7, $28, $07, $35, $20, $04, $3E, $10
    db   $E0, $F3, $FA, $9F, $C1, $A7, $20, $0D
    db   $FA, $11, $C1, $EA, $A8, $C1, $A7, $28
    db   $04, $3D, $EA, $11, $C1, $FA, $1C, $C1
    db   $FE, $07, $C8, $AF, $EA, $C1, $C3, $F0
    db   $F7, $FE, $0A, $F0, $E7, $38, $01, $AF
    db   $E6, $03, $5F, $16, $00, $21, $3F, $38
    db   $19, $7E, $EA, $C0, $C3, $FA, $A0, $C5
    db   $EA, $A1, $C5, $AF, $EA, $A0, $C5, $EA
    db   $0C, $C1, $E0, $B2, $EA, $17, $C1, $EA
    db   $9D, $C1, $EA, $47, $C1, $EA, $A8, $C5
    db   $EA, $5E, $D4, $FA, $9F, $C1, $A7, $20
    db   $03, $EA, $AD, $C1, $3E, $02, $CD, $B9
    db   $07, $CD, $E6, $63, $06, $00, $0E, $0F
    db   $79, $EA, $23, $C1, $21, $80, $C2, $09
    db   $7E, $A7, $28, $05, $E0, $EA, $CD, $DD
    db   $38, $0D, $79, $FE, $FF, $20, $E9, $C9
    db   $3E, $15, $EA, $00, $21, $CD, $00, $40
    db   $3E, $03, $EA, $00, $21, $C9, $21, $A0
    db   $C3, $09, $7E, $E0, $EB, $21, $90, $C2
    db   $09, $7E, $E0, $F0, $21, $B0, $C3, $09
    db   $7E, $E0, $F1, $3E, $19, $CD, $B9, $07
    db   $F0, $EB, $FE, $6A, $20, $05, $F0, $B2
    db   $A7, $20, $06, $F0, $EA, $FE, $07, $20
    db   $08, $CD, $5F, $75, $CD, $BA, $3D, $18
    db   $06, $CD, $BA, $3D, $CD, $5F, $75, $3E
    db   $14, $CD, $B9, $07, $CD, $88, $53, $3E
    db   $03, $CD, $B9, $07, $F0, $EA, $FE, $05
    db   $CA, $45, $39, $C7, $CE, $38, $7E, $55
    db   $90, $4D, $26, $4D, $0A, $49, $45, $39
    db   $BC, $4E, $92, $57, $49, $4E, $CD, $45
    db   $39, $3E, $03, $C3, $B9, $07, $F0, $EB
    db   $5F, $50, $21, $00, $40, $19, $7E, $CD
    db   $B9, $07, $7B, $C7, $4B, $6A, $61, $44
    db   $BF, $66, $61, $7B, $C9, $69, $97, $53
    db   $BE, $52, $E3, $7A, $30, $79, $44, $58
    db   $3D, $6A, $82, $58, $E7, $6A, $CD, $79
    db   $6B, $7E, $47, $75, $04, $5C, $FF, $5B
    db   $04, $5C, $35, $5A, $5E, $78, $7B, $79
    db   $41, $66, $41, $66, $70, $74, $3C, $67
    db   $CE, $4A, $FC, $7C, $D0, $7C, $00, $00
    db   $AB, $4E, $5F, $7F, $5D, $4F, $27, $77
    db   $FB, $65, $B5, $7E, $B4, $50, $1E, $4D
    db   $1E, $4D, $0B, $76, $65, $67, $8B, $5A
    db   $2B, $6C, $E5, $75, $BC, $76, $7F, $5D
    db   $C0, $60, $7D, $61, $D0, $5C, $DC, $5B
    db   $CB, $5B, $B0, $5B, $A0, $5B, $9C, $5A
    db   $39, $5A, $9D, $60, $EE, $5F, $DA, $5D
    db   $92, $5D, $83, $60, $29, $60, $FF, $5F
    db   $E5, $4D, $15, $49, $E1, $47, $01, $68
    db   $68, $5E, $94, $44, $3F, $44, $65, $43
    db   $FD, $40, $C7, $41, $3A, $42, $AD, $42
    db   $00, $00, $95, $53, $00, $00, $79, $76
    db   $2B, $76, $46, $6E, $B3, $7A, $71, $69
    db   $E6, $67, $E6, $67, $59, $5F, $80, $7D
    db   $90, $7C, $E9, $5D, $F7, $5E, $9D, $56
    db   $72, $50, $C1, $49, $09, $40, $41, $6C
    db   $05, $7B, $4D, $69, $CD, $67, $16, $42
    db   $61, $62, $BB, $59, $EF, $5D, $AA, $54
    db   $24, $43, $9F, $54, $58, $74, $C2, $53
    db   $9E, $52, $8B, $5D, $2E, $45, $38, $40
    db   $B4, $6B, $94, $48, $48, $62, $C3, $60
    db   $C3, $60, $48, $62, $BF, $4D, $A4, $4C
    db   $33, $4B, $E8, $5C, $BE, $5A, $4E, $5C
    db   $5C, $5D, $FD, $5E, $DE, $62, $CD, $63
    db   $2A, $64, $C6, $72, $88, $6A, $58, $6C
    db   $D4, $6E, $66, $70, $C9, $71, $39, $73
    db   $19, $7C, $B5, $56, $A1, $53, $07, $51
    db   $49, $50, $49, $50, $BF, $4E, $36, $4F
    db   $92, $4B, $77, $47, $49, $49, $47, $42
    db   $1B, $45, $50, $41, $AD, $70, $20, $40
    db   $FD, $5A, $05, $48, $03, $75, $44, $74
    db   $14, $73, $B4, $71, $5E, $71, $22, $40
    db   $31, $70, $F1, $63, $25, $65, $6D, $66
    db   $FB, $61, $BD, $60, $BD, $60, $98, $61
    db   $54, $5F, $47, $5B, $87, $5D, $7C, $59
    db   $0A, $68, $0A, $68, $7E, $68, $D5, $55
    db   $DC, $53, $C6, $52, $09, $51, $03, $4F
    db   $1C, $75, $88, $4A, $A8, $4C, $A3, $49
    db   $0D, $48, $D3, $44, $72, $42, $2B, $77
    db   $EA, $77, $15, $40, $A8, $6F, $C7, $69
    db   $A7, $64, $62, $63, $7D, $62, $76, $61
    db   $B6, $5E, $00, $40, $F7, $54, $C9, $73
    db   $4E, $73, $1D, $45, $98, $52, $FC, $50
    db   $40, $4E, $F5, $49, $BD, $44, $97, $6B
    db   $57, $49, $13, $6E, $32, $51, $80, $51
    db   $5D, $52, $CA, $51, $58, $5D, $18, $59
    db   $17, $58, $F3, $55, $E8, $56, $C1, $54
    db   $44, $53, $E4, $52, $8A, $51, $9A, $4C
    db   $1C, $4A, $27, $45, $8A, $76, $AC, $78
    db   $58, $4D, $F5, $4B, $BE, $46, $19, $7C
    db   $96, $50, $9A, $40, $47, $75, $08, $05
    db   $08, $05, $08, $0A, $08, $0A, $08, $0A
    db   $08, $0A, $08, $10, $04, $0A, $08, $02
    db   $08, $02, $08, $13, $08, $13, $08, $06
    db   $06, $08, $08, $07, $06, $0A, $08, $06
    db   $10, $30, $08, $07, $04, $0A, $0C, $07
    db   $FC, $04, $10, $10, $0C, $12, $08, $08
    db   $02, $08, $10, $0C, $08, $10, $08, $07
    db   $0C, $08, $08, $08, $02, $08, $21, $50
    db   $C3, $09, $7E, $E6, $7C, $5F, $50, $21
    db   $25, $3B, $19, $E5, $D1, $C5, $CB, $21
    db   $CB, $21, $21, $80, $D5, $09, $0E, $04
    db   $1A, $13, $22, $0D, $20, $FA, $C1, $C9
    db   $21, $B0, $C3, $09, $77, $C9, $21, $90
    db   $C2, $09, $34, $C9, $3E, $02, $EA, $00
    db   $21, $CD, $B5, $78, $C3, $C0, $07, $3E
    db   $03, $EA, $00, $21, $CD, $92, $78, $C3
    db   $C0, $07, $3E, $03, $EA, $00, $21, $CD
    db   $AA, $7C, $C3, $C0, $07, $3E, $03, $EA
    db   $00, $21, $CD, $3D, $6E, $C3, $C0, $07
    db   $3E, $03, $EA, $00, $21, $CD, $87, $6C
    db   $C3, $C0, $07, $3E, $03, $EA, $00, $21
    db   $CD, $F9, $6B, $C3, $C0, $07, $3E, $03
    db   $EA, $00, $21, $CD, $93, $6C, $C3, $C0
    db   $07, $3E, $03, $EA, $00, $21, $CD, $EF
    db   $73, $C3, $C0, $07, $3E, $03, $EA, $00
    db   $21, $CD, $40, $6E, $C3, $C0, $07, $3E
    db   $03, $EA, $00, $21, $CD, $A6, $75, $C3
    db   $C0, $07, $F5, $3E, $03, $EA, $00, $21
    db   $F1, $CD, $F8, $64, $CB, $1D, $CD, $C0
    db   $07, $CB, $15, $C9, $F5, $3E, $03, $EA
    db   $00, $21, $F1, $CD, $FA, $64, $CB, $1D
    db   $CD, $C0, $07, $CB, $15, $C9, $21, $00
    db   $21, $36, $03, $CD, $99, $7E, $C3, $C0
    db   $07, $21, $00, $21, $36, $03, $CD, $17
    db   $7E, $C3, $C0, $07, $F0, $F1, $3C, $C8
    db   $CD, $87, $3D, $D5, $FA, $C0, $C3, $5F
    db   $50, $21, $30, $C0, $19, $E5, $D1, $F0
    db   $EC, $12, $13, $FA, $55, $C1, $4F, $F0
    db   $ED, $E6, $20, $1F, $1F, $21, $EE, $FF
    db   $86, $91, $12, $13, $F0, $F1, $4F, $06
    db   $00, $CB, $21, $CB, $10, $CB, $21, $CB
    db   $10, $E1, $09, $F0, $F5, $4F, $2A, $81
    db   $12, $E6, $0F, $FE, $0F, $20, $05, $1B
    db   $3E, $F0, $12, $13, $13, $2A, $E5, $21
    db   $ED, $FF, $AE, $12, $13, $F0, $EC, $12
    db   $13, $FA, $55, $C1, $4F, $F0, $ED, $E6
    db   $20, $EE, $20, $1F, $1F, $21, $EE, $FF
    db   $91, $86, $12, $13, $E1, $F0, $F5, $4F
    db   $2A, $81, $12, $E6, $0F, $FE, $0F, $20
    db   $05, $1B, $3E, $F0, $12, $13, $13, $7E
    db   $21, $ED, $FF, $AE, $12, $FA, $23, $C1
    db   $4F, $06, $00, $3E, $15, $EA, $00, $21
    db   $CD, $6D, $79, $CD, $A5, $79, $C3, $C0
    db   $07, $F0, $F1, $3C, $C8, $CD, $87, $3D
    db   $D5, $FA, $C0, $C3, $6F, $26, $00, $01
    db   $30, $C0, $09, $E5, $D1, $FA, $23, $C1
    db   $4F, $06, $00, $F0, $F9, $A7, $F0, $EC
    db   $28, $04, $D6, $04, $E0, $EC, $12, $13
    db   $FA, $55, $C1, $67, $F0, $EE, $C6, $04
    db   $94, $12, $13, $F0, $F1, $4F, $06, $00
    db   $CB, $21, $CB, $10, $E1, $09, $2A, $12
    db   $13, $2A, $21, $ED, $FF, $AE, $12, $13
    db   $18, $A3, $3E, $15, $EA, $00, $21, $18
    db   $AA, $E5, $21, $00, $C0, $18, $10, $F0
    db   $F1, $3C, $28, $57, $E5, $FA, $C0, $C3
    db   $5F, $16, $00, $21, $30, $C0, $19, $E5
    db   $D1, $E1, $79, $E0, $D7, $FA, $23, $C1
    db   $4F, $CD, $87, $3D, $F0, $D7, $4F, $F0
    db   $EC, $86, $12, $23, $13, $C5, $FA, $55
    db   $C1, $4F, $F0, $EE, $86, $91, $12, $23
    db   $13, $F0, $F5, $4F, $2A, $F5, $81, $12
    db   $F1, $FE, $FF, $20, $04, $1B, $AF, $12
    db   $13, $C1, $13, $F0, $ED, $AE, $23, $12
    db   $13, $0D, $20, $D3, $FA, $23, $C1, $4F
    db   $3E, $15, $EA, $00, $21, $CD, $6D, $79
    db   $C3, $C0, $07, $FA, $23, $C1, $4F, $C9
    db   $E5, $FA, $24, $C1, $A7, $28, $1F, $F0
    db   $EE, $3D, $FE, $C0, $30, $17, $F0, $EC
    db   $3D, $FE, $88, $30, $10, $21, $20, $C2
    db   $09, $7E, $A7, $20, $08, $21, $30, $C2
    db   $09, $7E, $A7, $28, $01, $F1, $E1, $C9
    db   $21, $40, $C2, $09, $70, $21, $50, $C2
    db   $09, $70, $C9, $21, $00, $C2, $09, $7E
    db   $E0, $EE, $21, $10, $C2, $09, $7E, $E0
    db   $EF, $21, $10, $C3, $09, $96, $E0, $EC
    db   $C9, $21, $00, $21, $36, $15, $CD, $74
    db   $79, $C3, $C0, $07, $21, $00, $21, $36
    db   $04, $CD, $10, $5A, $C3, $C0, $07, $21
    db   $00, $21, $36, $04, $CD, $80, $56, $C3
    db   $C0, $07, $21, $00, $21, $36, $04, $CD
    db   $4D, $50, $C3, $C0, $07, $21, $00, $21
    db   $36, $04, $CD, $B5, $49, $C3, $C0, $07
    db   $21, $00, $21, $36, $04, $CD, $00, $40
    db   $C3, $C0, $07, $21, $00, $21, $36, $05
    db   $CD, $2B, $6C, $C3, $C0, $07, $21, $00
    db   $21, $36, $05, $CD, $76, $67, $C3, $C0
    db   $07, $21, $00, $21, $36, $05, $CD, $4F
    db   $62, $C3, $C0, $07, $21, $00, $21, $36
    db   $05, $CD, $59, $59, $C3, $C0, $07, $21
    db   $00, $21, $36, $05, $CD, $9F, $54, $C3
    db   $C0, $07, $FA, $AF, $DB, $F5, $3E, $02
    db   $CD, $B9, $07, $CD, $B1, $6F, $F1, $C3
    db   $B9, $07, $21, $00, $21, $36, $04, $CD
    db   $5A, $5C, $C3, $C0, $07, $21, $00, $21
    db   $36, $03, $CD, $64, $54, $C3, $C0, $07
    db   $21, $00, $21, $36, $02, $CD, $D1, $5F
    db   $CD, $17, $61, $C3, $C0, $07, $3E, $02
    db   $CD, $B9, $07, $CD, $BA, $41, $3E, $03
    db   $C3, $B9, $07, $21, $00, $21, $36, $02
    db   $CD, $E7, $61, $C3, $C0, $07, $21, $00
    db   $21, $36, $03, $CD, $97, $64, $C3, $C0
    db   $07, $3E, $06, $CD, $B9, $07, $CD, $40
    db   $79, $3E, $03, $C3, $B9, $07, $1E, $10
    db   $21, $80, $C2, $AF, $22, $1D, $20, $FB
    db   $C9, $21, $A0, $C4, $09, $7E, $A7, $C8
    db   $F0, $E7, $A9, $E6, $03, $C0, $F0, $EE
    db   $E0, $D7, $F0, $EC, $E0, $D8, $3E, $08
    db   $CD, $53, $09, $21, $20, $C5, $19, $36
    db   $0F, $C9, $21, $F0, $C3, $09, $7E, $CB
    db   $7F, $28, $02, $2F, $3C, $E0, $D7, $21
    db   $00, $C4, $09, $7E, $CB, $7F, $28, $02
    db   $2F, $3C, $1E, $03, $21, $D7, $FF, $BE
    db   $38, $02, $1E, $0C, $7B, $21, $A0, $C2
    db   $09, $A6, $28, $05, $21, $10, $C4, $09
    db   $70, $C9, $B0, $B4, $B1, $B2, $B3, $B6
    db   $BA, $BC, $B8, $21, $4F, $C1, $FA, $24
    db   $C1, $B6, $C0, $FA, $65, $C1, $A7, $28
    db   $05, $3D, $EA, $65, $C1, $C9, $FA, $BD
    db   $C1, $A7, $C0, $3C, $EA, $BD, $C1, $21
    db   $30, $C4, $09, $7E, $E6, $04, $3E, $19
    db   $28, $02, $3E, $50, $EA, $68, $D3, $E0
    db   $BD, $FA, $6B, $C1, $FE, $04, $C0, $F0
    db   $EB, $FE, $87, $20, $04, $3E, $DA, $18
    db   $1E, $FE, $BC, $20, $04, $3E, $26, $18
    db   $16, $21, $30, $C4, $09, $7E, $E6, $04
    db   $20, $10, $F0, $F7, $FE, $05, $28, $0A
    db   $5F, $50, $21, $09, $3F, $19, $7E, $CD
    db   $97, $21, $C9, $01, $02, $04, $08, $10
    db   $20, $40, $80, $3E, $03, $EA, $13, $C1
    db   $EA, $00, $21, $CD, $2F, $56, $CD, $C0
    db   $07, $21, $60, $C4, $09, $7E, $FE, $FF
    db   $28, $26, $F5, $FA, $B5, $DB, $5F, $50
    db   $3C, $EA, $B5, $DB, $7E, $21, $B6, $DB
    db   $19, $77, $F1, $FE, $08, $30, $11, $5F
    db   $50, $21, $72, $3F, $19, $F0, $F6, $5F
    db   $50, $7E, $21, $00, $CF, $19, $B6, $77
    db   $21, $80, $C2, $09, $70, $C9

toc_01_3FBD:
    ld   a, $05
    ld   [$2100], a
    ld   hl, $5919
    ld   de, $8460
    ld   bc, $0010
    call toc_01_28C5
    ld   hl, $5929
    jr   toc_01_3FE7

toc_01_3FD3:
    ld   a, $05
    ld   [$2100], a
    ld   hl, $5939
    ld   de, $8460
    ld   bc, $0010
    call toc_01_28C5
    ld   hl, $5949
toc_01_3FE7:
    ld   de, $8480
    ld   bc, $0010
    call toc_01_28C5
    xor  a
    ld   [$FFA5], a
    ld   a, $0C
    ld   [$2100], a
    jp   toc_01_1CCC

    db   $FF, $FF, $FF, $FF, $FF
