SECTION "ROM Bank 00", ROM0[$00]

RST_0000:
    jp   JumpTable

DEBUG_TOOL1:
    db   false

DEBUG_TOOL2:
    db   false

DEBUG_TOOL3:
    db   $FF

    db   $FF, $FF

RST_0008:
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0010:
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0018:
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0020:
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0028:
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0030:
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0038:
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

VBlankInterrupt:
    jp   vblank

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
    jr   toc_01_007A.toc_01_0080

toc_01_006A:
    ld   hl, $6930
    ld   de, $89D0
    jr   toc_01_007A.toc_01_0080

toc_01_0072:
    ld   hl, $49D0
    ld   de, $89D0
    jr   toc_01_007A.toc_01_0080

toc_01_007A:
    ld   hl, $49A0
    ld   de, $89A0
toc_01_007A.toc_01_0080:
    ld   bc, $0030
    call copyHLToDE
    clear [hNeedsUpdatingBGTiles]
    ld   [hBGTilesLoadingStage], a
toc_01_007A.toc_01_008B:
    changebank $0C
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
    jp   main

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

main:
    call setupLCD
    ld   sp, $DFFF
    clear [gbBGP]
    ld   [gbOBP0], a
    ld   [gbOBP1], a
    ld   hl, gbVRAM
    ld   bc, $1800
    call clearBGTiles.clearRegion
    call initializeBGDAT0
    call clearBGTiles
    changebank $01
    call copyDMARoutine
    call $FFC0
    call toc_01_40C2.resetHardware
    call JumpTable_2B6B_00
    assign [gbSTAT], STATF_LYC | STATF_LYCF
    assign [gbLYC], 79
    assign [wCurrentBank], $01
    assign [gbIE], IE_VBLANK
    changebank $01
    call verifySaveFiles
    changebank $1F
    call toc_1F_4000
    assign [hButtonsInactiveDelay], 24
    ei
    jp   .else_01_03BD

main.toc_01_01A6:
    assign [hIsRenderingFrame], true
    ifNot [$C500], .else_01_01BE

    ifNe [wGameMode], GAMEMODE_WORLD, .else_01_01BE

    ld   a, [hFrameCounter]
    rrca
    and  %10000000
    jr   .toc_01_01C4

main.else_01_01BE:
    ld   hl, $C156
    ld   a, [hBaseScrollY]
    add  a, [hl]
main.toc_01_01C4:
    ld   [gbSCY], a
    ld   a, [hBaseScrollX]
    ld   hl, $C155
    add  a, [hl]
    ld   hl, $C1BF
    add  a, [hl]
    ld   [gbSCX], a
    ld   a, [wTileMapToLoad]
    and  a
    jr   nz, .else_01_01DF

    ifEq [$D6FF], $00, .else_01_0209

main.else_01_01DF:
    ifEq [wGameMode], GAMEMODE_MARIN_BEACH, .else_01_01F5

    cp   GAMEMODE_FILE_SAVE
    jr   c, .else_01_01F5

    cp   GAMEMODE_WORLD
    jr   nz, .else_01_01FB

    ifGte [$DB96], $07, .else_01_01FB

main.else_01_01F5:
    call toc_01_0844
    call toc_01_0844
main.else_01_01FB:
    di
    call LoadMapData
    ei
    call toc_01_0844
    call toc_01_0844
    jp   .else_01_03BD

main.else_01_0209:
    ld   a, [wLCDCStash]
    and  LCDCF_BG_CHAR_8000 | LCDCF_BG_DISPLAY | LCDCF_BG_TILE_9C00 | LCDCF_OBJ_16_16 | LCDCF_OBJ_DISPLAY | LCDCF_TILEMAP_9C00 | LCDCF_WINDOW_ON
    ld   e, a
    ld   a, [gbLCDC]
    and  LCDCF_ON
    or   e
    ld   [gbLCDC], a
    incAddr hFrameCounter
    ifNe [wGameMode], GAMEMODE_INTRO, .else_01_0230

    ifLt [$DB96], $08, .else_01_0230

    changebank $01
    call toc_01_6DB7
main.else_01_0230:
    ifNotZero [$C17F], .else_01_0352

    inc  a
    jr   nz, .else_01_0245

main.toc_01_023A:
    changebank $17
    call toc_17_46A6
    jp   .else_01_0352

main.else_01_0245:
    inc  a
    jr   z, .toc_01_023A

    changebank $14
    ld   a, [$C180]
    inc  a
    ld   [$C180], a
    cp   $C0
    jr   nz, .else_01_026C

    ifNe [$C17F], $02, .else_01_0262

    call toc_14_541B
main.else_01_0262:
    clear [$C17F]
    ld   [$C3CA], a
    jp   .else_01_0352

main.else_01_026C:
    cp   $60
    jr   c, .else_01_02BC

    push af
    and  %00000111
    jr   nz, .else_01_0280

    ifEq [$C3CA], $0C, .else_01_02BB

    inc  a
    ld   [$C3CA], a
main.else_01_0280:
    ld   a, [$C3CA]
    ld   e, a
    ld   a, [hFrameCounter]
    and  %00000011
    add  a, e
    ld   e, a
    ld   d, $00
    ifEq [$C17F], $03, .else_01_02A8

    ld   hl, $546A
    add  hl, de
    ld   a, [hl]
    ld   [$DB97], a
    ld   [$DB99], a
    ld   hl, $547A
    add  hl, de
    ld   a, [hl]
    ld   [$DB98], a
    jr   .else_01_02BB

main.else_01_02A8:
    ld   hl, $548A
    add  hl, de
    ld   a, [hl]
    ld   [$DB97], a
    ld   [$DB99], a
    ld   hl, $549A
    add  hl, de
    ld   a, [hl]
    ld   [$DB98], a
main.else_01_02BB:
    pop  af
main.else_01_02BC:
    srl  a
    srl  a
    ld   [$FFD7], a
    ld   a, [$C180]
    nop
    and  %11100000
    ld   e, a
    ifNe [$C17F], $03, .else_01_02D4

    ld   a, e
    xor  %11100000
    ld   e, a
main.else_01_02D4:
    ld   a, e
    ld   [$FFD8], a
    ld   hl, $C17C
    xor  a
    ldi  [hl], a
    ldi  [hl], a
    ldi  [hl], a
main.loop_01_02DE:
    ld   a, [gbSTAT]
    and  STATF_OAM | STATF_VB
    jr   nz, .loop_01_02DE

    ld   d, $00
main.loop_01_02E6:
    ld   a, [$C17E]
    inc  a
    ld   [$C17E], a
    and  %00000001
    jr   nz, .loop_01_02E6

    ld   a, [$C17C]
    add  a, $01
    ld   [$C17C], a
    ld   a, [$C17D]
    adc  $00
    ld   [$C17D], a
    ld   a, [$C17C]
    cp   $58
    jp   z, .else_01_033E

    ld   c, $00
    ifEq [$C17F], $01, .else_01_0313

    inc  c
main.else_01_0313:
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
    jr   z, .else_01_032D

    cpl
    inc  a
main.else_01_032D:
    push af
    ld   hl, hBaseScrollX
    add  a, [hl]
    ld   [gbSCX], a
    pop  af
    ld   hl, hBaseScrollY
    add  a, [hl]
    ld   [gbSCY], a
    jp   .loop_01_02DE

main.else_01_033E:
    call toc_01_0844
    copyFromTo [$DB97], [gbBGP]
    copyFromTo [$DB98], [gbOBP0]
    copyFromTo [$DB99], [gbOBP1]
    jr   .else_01_03BD

main.else_01_0352:
    copyFromTo [wWYStash], [gbWY]
    copyFromTo [$DB97], [gbBGP]
    copyFromTo [$DB98], [gbOBP0]
    copyFromTo [$DB99], [gbOBP1]
    call toc_01_0844
    call toc_01_27FE
    ld   a, [hNeedsUpdatingBGTiles]
    ld   hl, hNeedsUpdatingEnemiesTiles
    or   [hl]
    ld   hl, $C10E
    or   [hl]
    jr   nz, .else_01_03BD

    ifNot [DEBUG_TOOL1], .else_01_03AA

    ld   a, [$D6FC]
    and  a
    jr   nz, .else_01_038A

    ld   a, [hPressedButtonsMask]
    and  J_DOWN | J_LEFT | J_RIGHT | J_UP
    jr   z, .else_01_03A4

main.else_01_038A:
    ld   a, [$FFCC]
    and  %01000000
    jr   z, .else_01_03A4

    ld   a, [$D6FC]
    xor  %00000001
    ld   [$D6FC], a
    jr   nz, .else_01_03BD

    ld   a, [$C17B]
    xor  %00010000
    ld   [$C17B], a
    jr   .else_01_03BD

main.else_01_03A4:
    ld   a, [$D6FC]
    and  a
    jr   nz, .else_01_03BD

main.else_01_03AA:
    call_changebank $01
    call toc_01_5CF0
    call toc_01_0A90
    changebank $01
    call toc_01_5D03
main.else_01_03BD:
    changebank $1F
    call toc_1F_7F80
    changebank $0C
    clear [hIsRenderingFrame]
    halt
main.loop_01_03CE:
    ifNot [hNeedsRenderingFrame], .loop_01_03CE

    clear [hNeedsRenderingFrame]
    jp   .toc_01_01A6

    db   $20, $30, $40, $60, $00, $30, $56, $68
    db   $00

toc_01_03E2:
    di
    push af
    push hl
    push de
    ifNe [wGameMode], GAMEMODE_CREDITS, .else_01_0400

    ifNe [$DB96], $05, .else_01_03F9

    ld   a, [$D000]
    jr   .toc_01_03FB

toc_01_03E2.else_01_03F9:
    ld   a, [hBaseScrollY]
toc_01_03E2.toc_01_03FB:
    ld   [gbSCY], a
    jp   .toc_01_0452

toc_01_03E2.else_01_0400:
    cp   $00
    jr   nz, .else_01_044F

    ld   a, [wLCDSectionIndex]
    ld   e, a
    ld   d, $00
    ld   hl, wScrollXOffsetForSection
    add  hl, de
    ld   a, [hl]
    ld   hl, hBaseScrollX
    add  a, [hl]
    ld   [gbSCX], a
    ifLt [$DB96], $06, .else_01_042C

    ld   hl, $03DE
    add  hl, de
    ld   a, [hl]
    ld   [gbLYC], a
    ld   a, e
    inc  a
    and  %00000011
    ld   [wLCDSectionIndex], a
    jr   .toc_01_0452

toc_01_03E2.else_01_042C:
    ld   hl, $03D9
    add  hl, de
    ld   a, [hl]
    ld   [gbLYC], a
    ld   a, e
    inc  a
    cp   $05
    jr   nz, .else_01_043A

    xor  a
toc_01_03E2.else_01_043A:
    ld   [wLCDSectionIndex], a
    nop
    cp   $04
    jr   nz, .else_01_044D

    copyFromTo [wIntroBGYOffset], [gbSCY]
    cpl
    inc  a
    add  a, 96
    ld   [gbLYC], a
toc_01_03E2.else_01_044D:
    jr   .toc_01_0452

toc_01_03E2.else_01_044F:
    clear [gbSCX]
toc_01_03E2.toc_01_0452:
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

LoadMapData:
    ifNot [wTileMapToLoad], toc_01_04F5

    push af
    call setupLCD
    pop  af
    call toc_01_04B1
    jr   toc_01_04F5.toc_01_0516

toc_01_04B1:
    dec  a
    jumptable
    dw JumpTable_2E6C_00 ; 00
    dw initializeBGDAT0 ; 01
    dw JumpTable_2B6B_00 ; 02
    dw JumpTable_2B9F_00 ; 03
    dw JumpTable_2C7E_00 ; 04
    dw JumpTable_2BC4_00 ; 05
    dw JumpTable_2C7E_00 ; 06
    dw JumpTable_28A1_00 ; 07
    dw JumpTable_2D88_00 ; 08
    dw toc_01_04F5.JumpTable_0522_00 ; 09
    dw JumpTable_2D01_00 ; 0A
    dw toc_01_04F5.JumpTable_0522_00 ; 0B
    dw JumpTable_2D73_00 ; 0C
    dw JumpTable_37DB_00 ; 0D
    dw JumpTable_2898_00 ; 0E
    dw JumpTable_2CC2_00 ; 0F
    dw JumpTable_2CF0_00 ; 10
    dw JumpTable_2D28_00 ; 11
    dw JumpTable_2D56_00 ; 12
    dw JumpTable_2D1E_00 ; 13
    dw JumpTable_2A26_00 ; 14
    dw JumpTable_2AA2_00 ; 15
    dw JumpTable_2A9D_00 ; 16
    dw JumpTable_2A98_00 ; 17
    dw JumpTable_2AF7_00 ; 18
    dw JumpTable_2AF2_00 ; 19
    dw JumpTable_2ABF_00 ; 1A
    dw JumpTable_2AF2_00 ; 1B
    dw JumpTable_2A65_00 ; 1C
    dw JumpTable_29FA_00 ; 1D
    dw JumpTable_2A17_00 ; 1E
    dw JumpTable_2D23_00 ; 1F
    dw JumpTable_2D39_00 ; 20

toc_01_04F5:
    call setupLCD
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
    changebank $08
    call toc_01_28CE.toc_01_28DE
    changebank $0C
toc_01_04F5.toc_01_0516:
    clear [$D6FF]
    ld   [wTileMapToLoad], a
    copyFromTo [wLCDCStash], [gbLCDC]
toc_01_04F5.JumpTable_0522_00:
    ret


    db   $07, $09

vblank:
    push af
    push bc
    push de
    push hl
    di
    ld   a, [hIsRenderingFrame]
    and  a
    jp   nz, .else_01_05B6

    ld   a, [wDialogState]
    and  %01111111
    jr   z, .else_01_0566

    cp   %00000001
    jr   z, .else_01_0566

    cp   %00000101
    jr   nc, .else_01_0548

    call toc_01_21DF
    incAddr wDialogState
    jr   .else_01_05B6

vblank.else_01_0548:
    cp   $0A
    jr   nz, .else_01_0551

    call toc_01_25A5
    jr   .else_01_05B6

vblank.else_01_0551:
    cp   $0B
    jr   nz, .else_01_0566

    ifNot [$C172], .else_01_0561

    dec  a
    ld   [$C172], a
    jr   .else_01_0566

vblank.else_01_0561:
    call toc_01_25F9
    jr   .else_01_05B6

vblank.else_01_0566:
    ld   a, [wTileMapToLoad]
    and  a
    jr   nz, .else_01_05B6

    copyFromTo [hNeedsUpdatingBGTiles], [$FFE8]
    ld   hl, hNeedsUpdatingEnemiesTiles
    or   [hl]
    ld   hl, $C10E
    or   [hl]
    jr   z, .else_01_058B

    call toc_01_05C0
    ifGte [$FFE8], $08, .else_01_0586

vblank.toc_01_0583:
    call JumpTable_1C5A_00.else_01_1CCC
vblank.else_01_0586:
    call $FFC0
    jr   .else_01_05B6

vblank.else_01_058B:
    ifNot [$FFBB], .else_01_05A3

    dec  a
    ld   [$FFBB], a
    ld   e, a
    ld   d, $00
    ld   hl, $0523
    add  hl, de
    ld   a, [hl]
    ld   [$D6F8], a
    call toc_01_1DEE
    jr   .toc_01_0583

vblank.else_01_05A3:
    call toc_01_1AA9
    ld   de, $D601
    call toc_01_28CE.toc_01_28D8
    clear [$D600]
    ld   [$D601], a
    call $FFC0
vblank.else_01_05B6:
    ei
    pop  hl
    pop  de
    pop  bc
    assign [hNeedsRenderingFrame], true
    pop  af
    reti


toc_01_05C0:
    ifNotZero [hNeedsUpdatingBGTiles], .else_01_0688

    cp   $07
    jp   z, .else_01_0760

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

    ifNot [$DBA5], .else_01_0643

    ld   a, [hNeedsUpdatingBGTiles]
    cp   UPDATE_BG_TILES_DUNGEON_MINIMAP
    jp   z, toc_01_07C9

    changebank $0D
    ld   a, [hBGTilesLoadingStage]
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
    ld   a, [hWorldTileset]
    add  a, $50
    ld   h, a
    add  hl, bc
    ifNot [$FFBB], .else_01_062E

    ld   a, [hBGTilesLoadingStage]
    dec  a
    cp   $02
    jr   c, .else_01_0634

toc_01_05C0.else_01_062E:
    ld   bc, $0040
    call copyHLToDE
toc_01_05C0.else_01_0634:
    ld   a, [hBGTilesLoadingStage]
    inc  a
    ld   [hBGTilesLoadingStage], a
    cp   $04
    jr   nz, .return_01_0642

    clear [hNeedsUpdatingBGTiles]
    ld   [hBGTilesLoadingStage], a
toc_01_05C0.return_01_0642:
    ret


toc_01_05C0.else_01_0643:
    ld   hl, $2100
    ld   [hl], $0F
    ld   a, [hBGTilesLoadingStage]
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
    ld   a, [hWorldTileset]
    add  a, $40
    ld   h, a
    ld   l, $00
    add  hl, bc
    ld   bc, $0040
    call copyHLToDE
    ld   a, [hBGTilesLoadingStage]
    inc  a
    ld   [hBGTilesLoadingStage], a
    cp   $08
    jr   nz, .return_01_0687

    clear [hNeedsUpdatingBGTiles]
    ld   [hBGTilesLoadingStage], a
toc_01_05C0.return_01_0687:
    ret


toc_01_05C0.else_01_0688:
    ifNot [hNeedsUpdatingEnemiesTiles], .else_01_06F4

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
    ld   a, [hEnemiesTilesLoadingStage]
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
    call copyHLToDE
    ld   a, [hEnemiesTilesLoadingStage]
    inc  a
    ld   [hEnemiesTilesLoadingStage], a
    cp   $04
    jr   nz, .return_01_06F3

    clear [hNeedsUpdatingEnemiesTiles]
    ld   [hEnemiesTilesLoadingStage], a
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
    call copyHLToDE
    ld   a, [$C10F]
    inc  a
    ld   [$C10F], a
    cp   $04
    jr   nz, .return_01_075F

    clear [$C10E]
    ld   [$C10F], a
toc_01_05C0.return_01_075F:
    ret


toc_01_05C0.else_01_0760:
    changebank $01
    call toc_01_7BC5
    jp   toc_01_007A.toc_01_008B

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
    changebank $0C
    ld   bc, $0040
    call copyHLToDE
    ifEq [hNeedsUpdatingBGTiles], $0A, .else_01_07B5

    cp   $0D
    jr   z, .else_01_07B5

    ld   a, [hNeedsUpdatingBGTiles]
    inc  a
    ld   [hNeedsUpdatingBGTiles], a
    ret


toc_01_0783.else_01_07B5:
    clear [hNeedsUpdatingBGTiles]
    ret


toc_01_07B9:
    ld   [$2100], a
    ld   [wCurrentBank], a
    ret


toc_01_07C0:
    push af
    copyFromTo [wCurrentBank], [$2100]
    pop  af
    ret


toc_01_07C9:
    changebank $12
    ifLt [hBGTilesLoadingStage], $08, .else_01_0813

    jr   nz, .else_01_07E3

    changebank $02
    call toc_02_6BB8
    incAddr hBGTilesLoadingStage
    ret


toc_01_07C9.else_01_07E3:
    cp   $09
    jr   nz, .else_01_07F4

    changebank $02
    call toc_02_6B92
    incAddr hBGTilesLoadingStage
    ret


toc_01_07C9.else_01_07F4:
    cp   $0A
    jr   nz, .else_01_0805

    changebank $02
    call toc_02_6B6C
    incAddr hBGTilesLoadingStage
    ret


toc_01_07C9.else_01_0805:
    changebank $02
    call toc_02_6B46
    clear [hNeedsUpdatingBGTiles]
    ld   [hBGTilesLoadingStage], a
    ret


toc_01_07C9.else_01_0813:
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
    call copyHLToDE
    ld   a, [hBGTilesLoadingStage]
    inc  a
    ld   [hBGTilesLoadingStage], a
    ret


toc_01_0844:
    changebank $1F
    call toc_1F_4006
    ld   a, [$FFF3]
    and  a
    jr   nz, .return_01_0876

    ifNot [$C10B], .else_01_0866

    cp   $02
    jr   nz, .else_01_0863

    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .return_01_0876

    jr   .else_01_0866

toc_01_0844.else_01_0863:
    call .else_01_0866
toc_01_0844.else_01_0866:
    changebank $1B
    call toc_1B_4006
    changebank $1E
    call toc_1E_4006
toc_01_0844.return_01_0876:
    ret


    db   $FF, $FF, $FF, $FF, $FF

toc_01_087C:
    changebank $02
    call toc_01_19EF
    jp   toc_01_07C0

toc_01_0887:
    ld   hl, $C450
    jr   toc_01_0891.toc_01_0894

toc_01_088C:
    ld   hl, $C2F0
    jr   toc_01_0891.toc_01_0894

toc_01_0891:
    ld   hl, $C2E0
toc_01_0891.toc_01_0894:
    add  hl, bc
    ld   a, [hl]
    and  a
    ret


toc_01_0898:
    ld   a, $AF
    call toc_01_3C01
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ret


toc_01_08AC:
    assign [$FFF2], $1D
    ret


    db   $21, $E1, $45, $18, $03, $21, $E1, $46
    db   $3E, $1C, $EA, $00, $21, $09, $7E, $21
    db   $00, $21, $36, $01, $C9

toc_01_08C6:
    changebank $0C
    ld   bc, $0040
    call copyHLToDE
    changebank $01
    ret


toc_01_08D7:
    ld   hl, $FFF4
    ld   [hl], $0C
    ld   hl, $C502
    ld   [hl], $04
    ret


toc_01_08E2:
    ld   hl, $C410
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_01_08EB

    dec  [hl]
toc_01_08E2.return_01_08EB:
    ret


toc_01_08EC:
    push af
    ld   a, [$C18F]
    and  a
    jr   nz, .else_01_0907

    ld   [$C1CF], a
    inc  a
    ld   [$C18F], a
    ld   [$C5A6], a
    ld   a, [$C19D]
    and  a
    jr   nz, .else_01_0907

    assign [$FFF2], $02
toc_01_08EC.else_01_0907:
    pop  af
    ret


toc_01_0909:
    assign [hMusicFadeOutTimer], 48
    jr   toc_01_0915.toc_01_0926

toc_01_090F:
    assign [hMusicFadeOutTimer], 48
    jr   toc_01_0915.toc_01_092A

toc_01_0915:
    ifNe [$D401], $01, toc_01_0909

    ifNot [$DBA5], toc_01_0909

    assign [$FFBC], $01
toc_01_0915.toc_01_0926:
    assign [$FFF4], $06
toc_01_0915.toc_01_092A:
    assign [$C11C], $03
    clear [$C16B]
    ld   [$C16C], a
    ld   [$D478], a
    and  a
    ret


toc_01_093B:
    clear [$C121]
    ld   [$C122], a
toc_01_093B.toc_01_0942:
    clear [$C14B]
    ld   [$C14A], a
    ret


toc_01_094A:
    copyFromTo [hLinkFinalPositionX], [hLinkPositionX]
    copyFromTo [hLinkFinalPositionY], [hLinkPositionY]
    ret


toc_01_0953:
    push af
    ld   e, $0F
    ld   d, $00
toc_01_0953.loop_01_0958:
    ld   hl, $C510
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_01_0978

    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_01_0958

    ld   hl, $C5C0
    dec  [hl]
    ld   a, [hl]
    cp   $FF
    jr   nz, .else_01_0974

    assign [$C5C0], $0F
toc_01_0953.else_01_0974:
    ld   a, [$C5C0]
    ld   e, a
toc_01_0953.else_01_0978:
    pop  af
    ld   hl, $C510
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C540
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD7]
    ld   hl, $C530
    add  hl, de
    ld   [hl], a
    ld   hl, $C520
    add  hl, de
    ld   [hl], $0F
    ret


toc_01_0993:
    ld   a, [$C140]
    sub  a, $08
    ld   [$FFD7], a
    ld   a, [$C142]
    sub  a, $08
    ld   [$FFD8], a
toc_01_0993.toc_01_09A1:
    assign [$FFF2], $07
    ld   a, $05
    jp   toc_01_0953

toc_01_09AA:
    changebank $08
    ifNot [$DBA5], .else_01_09DC

    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    ld   hl, $4040
    ifGte [$FFF7], $1A, .else_01_09C8

    cp   $06
    jr   c, .else_01_09C8

    inc  h
toc_01_09AA.else_01_09C8:
    add  hl, de
    ld   a, [hWorldTileset]
    ld   e, a
    ld   a, [hl]
    cp   e
    jr   z, .else_01_09DA

    ld   [hWorldTileset], a
    cp   $FF
    jr   z, .else_01_09DA

    assign [hNeedsUpdatingBGTiles], UPDATE_BG_TILES_WORLD
toc_01_09AA.else_01_09DA:
    jr   .else_01_0A09

toc_01_09AA.else_01_09DC:
    ifNe [$FFF6], $07, .else_01_09E3

    inc  a
toc_01_09AA.else_01_09E3:
    ld   d, a
    srl  a
    srl  a
    and  %11111000
    ld   e, a
    ld   a, d
    srl  a
    and  %00000111
    or   e
    ld   e, a
    ld   d, $00
    ld   hl, $4000
    add  hl, de
    ld   a, [hWorldTileset]
    ld   e, a
    ld   a, [hl]
    cp   e
    jr   z, .else_01_0A09

    cp   $0F
    jr   z, .else_01_0A09

    ld   [hWorldTileset], a
    assign [hNeedsUpdatingBGTiles], UPDATE_BG_TILES_WORLD
toc_01_09AA.else_01_0A09:
    clear [$FFD7]
    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    ld   hl, $4240
    ld   a, [$DBA5]
    ld   d, a
    ifGte [$FFF7], $1A, .else_01_0A23

    cp   $06
    jr   c, .else_01_0A23

    inc  d
toc_01_09AA.else_01_0A23:
    add  hl, de
    ld   e, [hl]
    ld   a, d
    and  a
    jr   nz, .else_01_0A43

    ld   a, e
    cp   $23
    jr   nz, .else_01_0A36

    ld   a, [$D8C9]
    and  %00100000
    jr   z, .else_01_0A36

    inc  e
toc_01_09AA.else_01_0A36:
    ld   a, e
    cp   $21
    jr   nz, .else_01_0A43

    ld   a, [$D8FD]
    and  %00100000
    jr   z, .else_01_0A43

    inc  e
toc_01_09AA.else_01_0A43:
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    ld   hl, $4540
    ifNot [$DBA5], .else_01_0A59

    ld   hl, $4788
toc_01_09AA.else_01_0A59:
    add  hl, de
    ld   d, $00
    ld   bc, $C193
toc_01_09AA.loop_01_0A5F:
    ld   e, [hl]
    ld   a, [bc]
    cp   e
    jr   z, .else_01_0A85

    ld   a, e
    cp   $FF
    jr   z, .else_01_0A85

    ld   [bc], a
    ifNot [$FFD7], .else_01_0A7A

    ld   a, d
    ld   [$C10D], a
    assign [$C10E], $01
    jr   .else_01_0A85

toc_01_09AA.else_01_0A7A:
    inc  a
    ld   [$FFD7], a
    ld   a, d
    ld   [$C197], a
    assign [hNeedsUpdatingEnemiesTiles], true
toc_01_09AA.else_01_0A85:
    inc  hl
    inc  bc
    inc  d
    ld   a, d
    cp   $04
    jr   nz, .loop_01_0A5F

    jp   toc_01_07C0

toc_01_0A90:
    ifLt [wGameMode], GAMEMODE_WORLD_MAP, .else_01_0ACE

    cp   GAMEMODE_WORLD
    jr   nz, .else_01_0AA2

    ifNe [$DB96], $07, .else_01_0ACE

toc_01_0A90.else_01_0AA2:
    ifNe [$C16B], $04, .else_01_0ACE

    ld   a, [wDialogState]
    ld   hl, $C167
    or   [hl]
    ld   hl, $C124
    or   [hl]
    jr   nz, .else_01_0ACE

    ifNe [hPressedButtonsMask], J_A | J_B | J_SELECT | J_START, .else_01_0ACE

    clear [$C16B]
    ld   [$C16C], a
    ld   [wDialogState], a
    ld   [$DB96], a
    assign [wGameMode], GAMEMODE_FILE_SAVE
toc_01_0A90.else_01_0ACE:
    ld   a, [wGameMode]
    jumptable
    dw JumpTable_0B05_00 ; 00
    dw JumpTable_0B08_00 ; 01
    dw JumpTable_0B34_00 ; 02
    dw JumpTable_0B37_00 ; 03
    dw JumpTable_0B3A_00 ; 04
    dw JumpTable_0B3D_00 ; 05
    dw JumpTable_0B02_00 ; 06
    dw JumpTable_0AFC_00 ; 07
    dw JumpTable_0AF0_00 ; 08
    dw JumpTable_0AF6_00 ; 09
    dw JumpTable_0AEA_00 ; 0A
    dw JumpTable_0B40_00 ; 0B

JumpTable_0AEA_00:
    call toc_01_67BC
    jp   JumpTable_0B53_00.toc_01_0C32

JumpTable_0AF0_00:
    call toc_01_654C
    jp   JumpTable_0B53_00.toc_01_0C32

JumpTable_0AF6_00:
    call toc_01_5FBB
    jp   JumpTable_0B53_00.toc_01_0C32

JumpTable_0AFC_00:
    call toc_01_546E
    jp   JumpTable_0B53_00.toc_01_0C32

JumpTable_0B02_00:
    jp   toc_01_4000

JumpTable_0B05_00:
    jp   toc_01_6E3E

JumpTable_0B08_00:
    call_changebank $17
    call toc_17_482A
    jp   JumpTable_0B53_00.toc_01_0C32

    db   $3E, $03, $EA, $00, $21, $3E, $17

toc_01_0B1A:
    push af
    call toc_01_3843
    pop  af
    jp   toc_01_07B9

toc_01_0B22:
    changebank $03
    ld   a, $01
    jr   toc_01_0B1A

toc_01_0B2B:
    changebank $03
    ld   a, $02
    jr   toc_01_0B1A

JumpTable_0B34_00:
    jp   toc_01_4711

JumpTable_0B37_00:
    jp   toc_01_494B

JumpTable_0B3A_00:
    jp   toc_01_4BE6

JumpTable_0B3D_00:
    jp   toc_01_4E34

JumpTable_0B40_00:
    changebank $14
    call toc_14_5326
    call toc_14_523C
    call_changebank $01
    jp   toc_01_431E

JumpTable_0B53_00:
    call_changebank $02
    ld   a, [wDialogState]
    and  a
    jr   nz, .else_01_0B9A

    ld   hl, $FFB4
    ld   a, [hl]
    and  a
    jr   z, .else_01_0B80

    ifNe [wWYStash], 128, .else_01_0B80

    ld   a, [$C14F]
    and  a
    jr   nz, .else_01_0B80

    dec  [hl]
    jr   nz, .else_01_0B80

    changebank $01
    call toc_01_5FA6
    call toc_01_07C0
JumpTable_0B53_00.else_01_0B80:
    ld   a, [wDialogState]
    and  a
    jr   nz, .else_01_0B9A

    ifNot [$C1BC], .else_01_0B9A

    ld   hl, hLinkInteractiveMotionBlocked
    ld   [hl], $02
    dec  a
    ld   [$C1BC], a
    jr   nz, .else_01_0B9A

    jp   toc_01_0909

JumpTable_0B53_00.else_01_0B9A:
    ld   hl, $DBC7
    ld   a, [hl]
    and  a
    jr   z, .else_01_0BA2

    dec  [hl]
JumpTable_0B53_00.else_01_0BA2:
    copyFromTo [hLinkPositionX], [hLinkFinalPositionX]
    copyFromTo [hLinkPositionY], [hLinkFinalPositionY]
    ld   hl, hLinkPositionZHigh
    sub  a, [hl]
    ld   [$FFB3], a
    call $5DD5
    clear [$C140]
    ld   [$C13C], a
    ld   [$C13B], a
    ld   hl, $C11D
    res  7, [hl]
    ld   hl, $C11E
    res  7, [hl]
    call $5731
    call_changebank $02
    call toc_01_2655
    call toc_01_0C40
    copyFromTo [$C15C], [$C3CF]
    clear [$C14E]
    ld   [$C14D], a
    ld   [$C1A4], a
    ld   [$C15C], a
    ld   [$C1AE], a
    ifNot [$C144], .else_01_0BF5

    dec  a
    ld   [$C144], a
JumpTable_0B53_00.else_01_0BF5:
    call_changebank $19
    call toc_19_7697
    call toc_01_3843
    call_changebank $02
    call toc_02_529A
    ld   hl, $D601
    ld   a, [hFrameCounter]
    and  %00000011
    or   [hl]
    jr   nz, .else_01_0C2A

    ifGte [$C11C], $02, .else_01_0C2A

    ld   c, $01
    ld   b, $00
    ld   e, $00
    ld   a, [hFrameCounter]
    and  %00000100
    jr   z, .else_01_0C27

    dec  c
    dec  e
JumpTable_0B53_00.else_01_0C27:
    call toc_02_61E7.loop_02_61ED
JumpTable_0B53_00.else_01_0C2A:
    call_changebank $14
    call toc_14_59B0
JumpTable_0B53_00.toc_01_0C32:
    call_changebank $0F
    call toc_01_2133
    ret


    db   $08, $0E, $99, $28, $EC

toc_01_0C40:
    ld   a, [hLinkPositionY]
    ld   hl, hLinkPositionZHigh
    sub  a, [hl]
    ld   [$C145], a
    ifNot [$C1A9], toc_01_0C8C

    ld   a, [wDialogState]
    and  a
    jr   nz, .else_01_0C7A

    ld   hl, $C1AA
    dec  [hl]
    ld   a, [hl]
    cp   $02
    jr   nz, .else_01_0C6E

    ld   a, [$C1A9]
    ld   e, a
    ld   d, $00
    ld   hl, $0C3A
    add  hl, de
    ld   a, [hl]
    call toc_01_2197
    ld   a, $01
toc_01_0C40.else_01_0C6E:
    and  a
    jr   nz, .else_01_0C7A

    clear [$C1A9]
    ld   [$C1A8], a
    jr   toc_01_0C8C

toc_01_0C40.else_01_0C7A:
    copyFromTo [$C1A9], [$C1A8]
    dec  a
    jumptable
    dw JumpTable_5018_01 ; 00
    dw JumpTable_5018_01.JumpTable_5023_01 ; 01
    dw JumpTable_5018_01.JumpTable_5023_01 ; 02
    dw JumpTable_5018_01.JumpTable_5023_01 ; 03
    dw JumpTable_5018_01 ; 04

toc_01_0C8C:
    ld   a, [hPressedButtonsMask]
    and  J_A | J_B | J_START
    jr   nz, .else_01_0CDE

    ld   a, [hPressedButtonsMask]
    and  J_SELECT
    jr   z, .else_01_0CDE

    ld   a, [$D45F]
    inc  a
    ld   [$D45F], a
    cp   $04
    jr   c, .else_01_0CE2

    ifEq [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING, .else_01_0CDE

    ifEq [hLinkAnimationState], LINK_ANIMATION_STATE_NO_UPDATE, .else_01_0CDE

    ifGte [$C11C], $02, .else_01_0CDE

    ld   hl, $C167
    ld   a, [wDialogState]
    or   [hl]
    jr   nz, .else_01_0CDE

    clear [$C16B]
    ld   [$C16C], a
    ld   [$DB96], a
    assign [wGameMode], GAMEMODE_WORLD_MAP
    changebank $02
    call toc_02_77FA.else_02_781B
    call JumpTable_1C5A_00.else_01_1CCC
    call toc_01_3843
    pop  af
    ret


toc_01_0C8C.else_01_0CDE:
    clear [$D45F]
toc_01_0C8C.else_01_0CE2:
    ifNot [$FFB7], .else_01_0CEA

    dec  a
    ld   [$FFB7], a
toc_01_0C8C.else_01_0CEA:
    ifNot [$FFB6], .else_01_0CF2

    dec  a
    ld   [$FFB6], a
toc_01_0C8C.else_01_0CF2:
    ld   a, [wDialogState]
    and  a
    jp   nz, toc_01_149B

    ld   a, [$C124]
    and  a
    jp   nz, toc_01_0D49

    ifEq [$C11C], $07, .else_01_0D32

    ld   a, [$DB5A]
    ld   hl, $C50A
    or   [hl]
    ld   hl, $C14F
    or   [hl]
    jr   nz, .else_01_0D2F

    assign [$C11C], $07
    assign [$FFB7], $BF
    assign [$C3CC], $10
    clear [$DBC7]
    ld   [$FF9C], a
    call toc_01_27D2
    assign [$FFF3], $08
toc_01_0C8C.else_01_0D2F:
    ld   a, [$C11C]
toc_01_0C8C.else_01_0D32:
    jumptable
    dw JumpTable_0D5F_00 ; 00
    dw $4D92 ; 01
    dw JumpTable_490A_03.JumpTable_490E_03 ; 02
    dw JumpTable_15B3_00 ; 03
    dw JumpTable_1732_00 ; 04
    dw JumpTable_4D00_03 ; 05
    dw $4F30 ; 06
    dw JumpTable_0D57_00 ; 07
    dw JumpTable_50A2_03 ; 08
    dw JumpTable_0D4F_00 ; 09
    dw JumpTable_4EBC_03.JumpTable_4EFF_03 ; 0A

toc_01_0D49:
    call toc_01_149B
    jp   JumpTable_1C5A_00.else_01_1CCC

JumpTable_0D4F_00:
    call_changebank $19
    jp   toc_19_5CA9

JumpTable_0D57_00:
    call_changebank $01
    jp   toc_01_4184

JumpTable_0D5F_00:
    call_changebank $02
    call toc_02_426E
    ret


toc_01_0D68:
    ld   a, [$C50A]
    ld   hl, $C167
    or   [hl]
    ld   hl, $C1A4
    or   [hl]
    ret  nz

    ifNot [$C14A], .else_01_0DAD

    ifEq [$DB01], $01, .else_01_0D9B

    ifEq [$DB00], $01, .else_01_0D9B

    ifEq [$DB01], $04, .else_01_0D96

    ifNe [$DB00], $04, .else_01_0DAB

toc_01_0D68.else_01_0D96:
    call toc_01_0F34
    jr   .else_01_0DAB

toc_01_0D68.else_01_0D9B:
    ld   a, [$C137]
    dec  a
    cp   $04
    jr   c, .else_01_0DAB

    assign [$C137], $05
    ld   [$C16A], a
toc_01_0D68.else_01_0DAB:
    jr   .toc_01_0DB4

toc_01_0D68.else_01_0DAD:
    clear [$C15B]
    ld   [$C15A], a
toc_01_0D68.toc_01_0DB4:
    ld   a, [$C117]
    and  a
    jp   nz, toc_01_0E7F.return_01_0ED0

    ld   a, [$C15C]
    and  a
    jp   nz, toc_01_0E7F.return_01_0ED0

    ifNot [$C137], .else_01_0DD3

    cp   $03
    jr   nz, .else_01_0DD3

    ifGte [$C138], $03, .else_01_0DD9

toc_01_0D68.else_01_0DD3:
    ld   a, [hLinkInteractiveMotionBlocked]
    and  a
    jp   nz, toc_01_0E7F.return_01_0ED0

toc_01_0D68.else_01_0DD9:
    ifNe [$DB00], $08, .else_01_0DEF

    ld   a, [hPressedButtonsMask]
    and  J_B
    jr   z, .else_01_0DEB

    call toc_01_140C
    jr   .else_01_0DEF

toc_01_0D68.else_01_0DEB:
    clear [$C14B]
toc_01_0D68.else_01_0DEF:
    ifNe [$DB01], $08, .else_01_0E05

    ld   a, [hPressedButtonsMask]
    and  J_A
    jr   z, .else_01_0E01

    call toc_01_140C
    jr   .else_01_0E05

toc_01_0D68.else_01_0E01:
    clear [$C14B]
toc_01_0D68.else_01_0E05:
    ifNe [$DB01], $04, .else_01_0E26

    copyFromTo [$DB44], [$C15A]
    ld   a, [hPressedButtonsMask]
    and  J_A
    jr   z, .else_01_0E26

    ifEq [$C1AD], $01, .else_01_0E26

    cp   $02
    jr   z, .else_01_0E26

    call toc_01_0F34
toc_01_0D68.else_01_0E26:
    ifNe [$DB00], $04, .else_01_0E3C

    copyFromTo [$DB44], [$C15A]
    ld   a, [hPressedButtonsMask]
    and  J_B
    jr   z, .else_01_0E3C

    call toc_01_0F34
toc_01_0D68.else_01_0E3C:
    ld   a, [$FFCC]
    and  %00100000
    jr   z, .else_01_0E4F

    ifEq [$C1AD], $02, .else_01_0E4F

    ld   a, [$DB00]
    call toc_01_0E7F
toc_01_0D68.else_01_0E4F:
    ld   a, [$FFCC]
    and  %00010000
    jr   z, .else_01_0E66

    ifEq [$C1AD], $01, .else_01_0E66

    cp   $02
    jr   z, .else_01_0E66

    ld   a, [$DB01]
    call toc_01_0E7F
toc_01_0D68.else_01_0E66:
    ld   a, [hPressedButtonsMask]
    and  J_B
    jr   z, .else_01_0E72

    ld   a, [$DB00]
    call toc_01_0F05
toc_01_0D68.else_01_0E72:
    ld   a, [hPressedButtonsMask]
    and  J_A
    jr   z, .return_01_0E7E

    ld   a, [$DB01]
    call toc_01_0F05
toc_01_0D68.return_01_0E7E:
    ret


toc_01_0E7F:
    ld   c, a
    cp   $01
    jp   z, toc_01_122F

    cp   $04
    jp   z, .else_01_0ED1

    cp   $02
    jp   z, toc_01_0F76

    cp   $03
    jp   z, toc_01_1007

    cp   $05
    jp   z, toc_01_1079

    cp   $0D
    jp   z, toc_01_100E

    cp   $06
    jp   z, .else_01_0EFC

    cp   $0A
    jp   z, toc_01_11D1

    cp   $09
    jp   z, $41E6

    cp   $0C
    jp   z, toc_01_1151

    cp   $0B
    jp   z, .else_01_0EDB

    cp   $07
    jr   nz, .return_01_0ED0

    ld   hl, $C137
    ld   a, [$C19B]
    or   [hl]
    jr   nz, .return_01_0ED0

    ifGte [$C14D], $02, .return_01_0ED0

    assign [$C19B], $8E
toc_01_0E7F.return_01_0ED0:
    ret


toc_01_0E7F.else_01_0ED1:
    ld   a, [$C144]
    and  a
    ret  nz

    assign [$FFF4], $16
    ret


toc_01_0E7F.else_01_0EDB:
    ld   a, [$C1C7]
    ld   hl, $C146
    or   [hl]
    ret  nz

    call $4C35
    jr   nc, .else_01_0EEE

    assign [$FFF2], $07
    jr   .toc_01_0EF2

toc_01_0E7F.else_01_0EEE:
    assign [$FFF4], $0E
toc_01_0E7F.toc_01_0EF2:
    assign [$C1C7], $01
    clear [$C1C8]
    ret


toc_01_0E7F.else_01_0EFC:
    ld   a, [$C1A4]
    and  a
    ret  nz

    call $423B
    ret


toc_01_0F05:
    cp   $01
    ret  nz

    ld   hl, $C137
    ld   a, [$C1AD]
    and  %00000011
    or   [hl]
    ret  nz

    ld   a, [$C160]
    and  a
    ret  nz

    clear [$C1AC]
    assign [$C137], $05
    ld   [$C5B0], a
    ret


    db   $10, $00, $08, $08, $03, $03, $08, $08
    db   $08, $08, $00, $0D, $08, $08, $03, $04

toc_01_0F34:
    assign [$C15B], $01
    copyFromTo [$DB44], [$C15A]
toc_01_0F34.toc_01_0F3F:
    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, $00
    ld   hl, $0F24
    add  hl, de
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   [$C140], a
    ld   hl, $0F28
    add  hl, de
    ld   a, [hl]
    ld   [$C141], a
    ld   hl, $0F2C
    add  hl, de
    ld   a, [$C145]
    add  a, [hl]
    ld   [$C142], a
    ld   hl, $0F30
    add  hl, de
    ld   a, [hl]
    ld   [$C143], a
    clear [$C5B0]
    ret


    db   $08, $F8, $00, $00, $00, $00, $FD, $04

toc_01_0F76:
    returnIfGte [$C14E], $01

    ifNotZero [$DB4D], toc_01_08AC

    sub  a, $01
    daa
    ld   [$DB4D], a
    ld   a, $02
    call toc_01_10EB
    ret  c

    ld   hl, $C2F0
    add  hl, de
    ld   [hl], $10
    ifNotZero [$C1C0], .else_01_0FAC

    clear [$C1C0]
    ld   a, [$C1C2]
    ld   c, a
    ld   b, d
    ld   hl, $C290
    add  hl, bc
    ld   [hl], $01
    ret


toc_01_0F76.else_01_0FAC:
    assign [$C1C0], $06
    ld   a, e
    ld   [$C1C1], a
    assign [$C19B], $0C
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $A0
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], d
    ld   hl, $C480
    add  hl, de
    ld   [hl], $03
    ld   a, [$FFF9]
    and  a
    jr   nz, .else_01_0FD6

    assign [$FFF2], $09
    jr   .toc_01_0FDB

toc_01_0F76.else_01_0FD6:
    ld   hl, $C310
    add  hl, de
    ld   [hl], d
toc_01_0F76.toc_01_0FDB:
    ld   hl, $C240
    add  hl, de
    ld   [hl], d
    ld   hl, $C250
    add  hl, de
    ld   [hl], d
    ld   hl, $C320
    add  hl, de
    ld   [hl], d
    ld   a, [hLinkDirection]
    ld   c, a
    ld   b, d
    ld   hl, $0F6E
    add  hl, bc
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $0F72
    add  hl, bc
    ld   a, [hLinkPositionY]
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ret


toc_01_1007:
    ret


    db   $18, $E8, $00, $E8, $18, $00

toc_01_100E:
    ld   a, [$C14D]
    and  a
    ret  nz

    ld   a, $01
    call toc_01_10EB
    ret  c

    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $28
    ld   c, $04
    ld   b, $00
    ld   a, [hPressedButtonsMask]
toc_01_100E.loop_01_1025:
    srl  a
    jr   nc, .else_01_102A

    inc  b
toc_01_100E.else_01_102A:
    dec  c
    jr   nz, .loop_01_1025

    ld   a, b
    cp   $02
    jr   c, .return_01_1058

    ld   a, [hPressedButtonsMask]
    and  J_LEFT | J_RIGHT
    ld   c, a
    ld   b, $00
    ld   hl, $1007
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   a, [hPressedButtonsMask]
    srl  a
    srl  a
    and  J_LEFT | J_RIGHT
    ld   c, a
    ld   b, $00
    ld   hl, $100A
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C250
    add  hl, de
    ld   [hl], a
toc_01_100E.return_01_1058:
    ret


    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $20, $E0, $00, $00, $00, $00, $E0, $20
    db   $30, $D0, $00, $00, $40, $C0, $00, $00
    db   $00, $00, $D0, $30, $00, $00, $C0, $40

toc_01_1079:
    ld   a, [$C14C]
    and  a
    ret  nz

    ifGte [$C14D], $02, .return_01_10EA

    assign [$C14C], $10
    ifNotZero [$DB45], toc_01_08AC

    sub  a, $01
    daa
    ld   [$DB45], a
    call toc_01_1283
    ld   a, $00
    call toc_01_10EB
    ret  c

    ld   a, e
    ld   [$C1C2], a
    ifNot [$C1C0], .else_01_10BD

    ld   a, [$C1C1]
    ld   c, a
    ld   b, d
    ld   hl, $C280
    add  hl, bc
    ld   [hl], b
    ld   hl, $C290
    add  hl, de
    ld   [hl], $01
    xor  a
    jr   .toc_01_10C3

toc_01_1079.else_01_10BD:
    assign [$FFF4], $0A
    ld   a, $06
toc_01_1079.toc_01_10C3:
    ld   [$C1C0], a
    ld   a, [hLinkDirection]
    ld   c, a
    ld   b, $00
toc_01_1079.toc_01_10CB:
    ifNe [$D47C], $01, .else_01_10D6

    ld   a, c
    add  a, $04
    ld   c, a
toc_01_1079.else_01_10D6:
    ld   hl, $1069
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $1071
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C250
    add  hl, de
    ld   [hl], a
toc_01_1079.return_01_10EA:
    ret


toc_01_10EB:
    call toc_01_3C01
    ret  c

    assign [$C19B], $0C
    push bc
    ld   a, [hLinkDirection]
    ld   c, a
    ld   b, $00
    ld   hl, $1059
    add  hl, bc
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $105D
    add  hl, bc
    ld   a, [hLinkPositionY]
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   a, [hLinkPositionZHigh]
    inc  a
    ld   hl, $C310
    add  hl, de
    ld   [hl], a
    ld   hl, $1061
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $1065
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C250
    add  hl, de
    ld   [hl], a
    ld   a, [hLinkDirection]
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], a
    ld   hl, $C380
    add  hl, de
    ld   [hl], a
    ld   hl, $C5D0
    add  hl, de
    ld   [hl], a
    ld   hl, $C4F0
    add  hl, de
    ld   [hl], $01
    pop  bc
    scf
    ccf
    ret


    db   $0E, $F2, $00, $00, $00, $00, $F4, $0C

toc_01_1151:
    ld   a, [$C19B]
    and  a
    ret  nz

    ifNot [$DB4B], .else_01_116B

    ld   a, [hLinkPositionZHigh]
    and  a
    ret  nz

    assign [$C1A9], $02
    assign [$C1AA], $2A
    ret


toc_01_1151.else_01_116B:
    ifNotZero [$DB4C], toc_01_08AC

    ld   a, $08
    call toc_01_3C01
    ret  c

    assign [$FFF2], $05
    assign [$C19B], $0E
    ld   a, [$DB4C]
    sub  a, $01
    daa
    ld   [$DB4C], a
    jr   nz, .else_01_119E

    ld   hl, $DB00
    ld   a, [hl]
    cp   $0C
    jr   nz, .else_01_1196

    ld   [hl], $00
toc_01_1151.else_01_1196:
    inc  hl
    ld   a, [hl]
    cp   $0C
    jr   nz, .else_01_119E

    ld   [hl], $00
toc_01_1151.else_01_119E:
    push bc
    ld   a, [hLinkDirection]
    ld   c, a
    ld   hl, $1149
    add  hl, bc
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $114D
    add  hl, bc
    ld   a, [hLinkPositionY]
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   a, [hLinkPositionZHigh]
    ld   hl, $C310
    add  hl, de
    ld   [hl], a
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $17
    pop  bc
    ret


    db   $1C, $E4, $00, $00, $00, $00, $E4, $1C

toc_01_11D1:
    ld   a, [$C130]
    cp   $07
    ret  z

    ld   a, [$C146]
    and  a
    ret  nz

    assign [$C146], $01
    clear [$C152]
    ld   [$C153], a
    assign [$FFF2], $0D
    ifNot [$FFF9], .else_01_120F

    call .else_01_120F
    ld   a, [hPressedButtonsMask]
    and  J_LEFT | J_RIGHT
    ld   a, $EA
    jr   z, .else_01_11FE

    ld   a, 232
toc_01_11D1.else_01_11FE:
    ld   [hLinkPositionYIncrement], a
    clear [hLinkPositionZLow]
    call toc_01_20D6
    call_changebank $02
    call toc_02_6FB1
    ret


toc_01_11D1.else_01_120F:
    assign [hLinkPositionZLow], $20
    ld   a, [$C14A]
    and  a
    ret  z

    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, b
    ld   hl, $11C9
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    ld   hl, $11CD
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionYIncrement], a
    ret


    db   $02, $14, $15, $18

toc_01_122F:
    ld   a, [$C16D]
    ld   hl, $C121
    or   [hl]
    ret  nz

    assign [$C138], $03
    assign [$C137], $01
    ld   [$C5B0], a
    clear [$C160]
    ld   [$C1AC], a
    call toc_01_27ED
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $122B
    add  hl, de
    ld   a, [hl]
    ld   [$FFF4], a
    call toc_01_1283
    ld   a, [$C146]
    and  a
    jr   nz, .else_01_1269

    call toc_01_093B
    call toc_01_1495
toc_01_122F.else_01_1269:
    ld   a, [$C14D]
    and  a
    ret  nz

    ld   a, [$C5A9]
    and  a
    ret  z

    ld   a, [$DB4E]
    cp   $02
    ret  nz

    ld   a, $DF
    call toc_01_10EB
    clear [$C19B]
    ret


toc_01_1283:
    ld   a, [hPressedButtonsMask]
    and  J_DOWN | J_LEFT | J_RIGHT | J_UP
    ld   e, a
    ld   d, $00
    ld   hl, $48B3
    add  hl, de
    ld   a, [hl]
    cp   DIRECTION_KEEP
    jr   z, .return_01_1295

    ld   [hLinkDirection], a
toc_01_1283.return_01_1295:
    ret


    db   $16, $FA, $08, $08, $16, $16, $08, $FA
    db   $FA, $FA, $08, $16, $08, $08, $FA, $16
    db   $08, $16, $16, $16, $08, $FA, $FA, $FA

toc_01_12AE:
    call toc_01_12B6
    ld   a, $02
    jp   toc_01_07B9

toc_01_12B6:
    ld   a, [$C1C4]
    and  a
    ret  nz

    ld   a, [$C14A]
    and  a
    jr   nz, .else_01_12C7

    ld   a, [$C16A]
    cp   $05
    ret  z

toc_01_12B6.else_01_12C7:
    ifNot [$C121], .else_01_12D4

    ld   a, [$C136]
    add  a, $04
    jr   .toc_01_12D6

toc_01_12B6.else_01_12D4:
    ld   a, [hLinkDirection]
toc_01_12B6.toc_01_12D6:
    ld   e, a
    ld   d, $00
    ld   hl, $1296
    add  hl, de
    ld   a, [hLinkPositionX]
    add  a, [hl]
    sub  a, 8
    and  %11110000
    ld   [hSwordIntersectedAreaX], a
    swap a
    ld   c, a
    ld   hl, $12A2
    add  hl, de
    ld   a, [hLinkPositionY]
    add  a, [hl]
    sub  a, 16
    and  %11110000
    ld   [hSwordIntersectedAreaY], a
    or   c
    ld   e, a
    ld   hl, $D711
    add  hl, de
    ld   a, h
    cp   $D7
    ret  nz

    push de
    ld   a, [hl]
    ld   [hObjectUnderEntity], a
    ld   e, a
    ld   a, [$DBA5]
    ld   d, a
    call toc_01_29DB
    pop  de
    cp   $D0
    jp   c, .else_01_1317

    cp   $D4
    jp   c, toc_01_13C9

toc_01_12B6.else_01_1317:
    cp   $90
    jp   nc, toc_01_13C9

    cp   $01
    jp   z, toc_01_13C9

    ld   c, $00
    ld   a, [$DBA5]
    and  a
    ld   a, [hObjectUnderEntity]
    jr   z, .else_01_1330

    cp   221
    jr   z, .else_01_133E

    ret


toc_01_12B6.else_01_1330:
    inc  c
    cp   $D3
    jr   z, .else_01_133E

    cp   $5C
    jr   z, .else_01_133E

    cp   $0A
    ret  nz

    ld   c, $FF
toc_01_12B6.else_01_133E:
    ld   a, c
    ld   [$FFF1], a
    call toc_01_20A6
    ld   a, [$C14A]
    and  a
    jr   nz, .else_01_135A

    ifNe [$C16A], $05, .else_01_135A

    clear [$C122]
    assign [$C16D], $0C
toc_01_12B6.else_01_135A:
    ld   a, $05
    call toc_01_10EB
    jr   c, .else_01_1383

    clear [$C19B]
    ld   hl, $C200
    add  hl, de
    ld   a, [hSwordIntersectedAreaX]
    add  a, $08
    ld   [hl], a
    ld   hl, $C210
    add  hl, de
    ld   a, [hSwordIntersectedAreaY]
    add  a, $10
    ld   [hl], a
    ld   hl, $C3B0
    add  hl, de
    ld   a, [$FFF1]
    ld   [hl], a
    push de
    pop  bc
    call toc_01_3803
toc_01_12B6.else_01_1383:
    call toc_01_27ED
    and  %00000111
    ret  nz

    ld   a, [hObjectUnderEntity]
    cp   211
    ret  z

    call toc_01_27ED
    rra
    ld   a, $2E
    jr   nc, .else_01_1398

    ld   a, $2D
toc_01_12B6.else_01_1398:
    call toc_01_3C01
    ret  c

    ld   hl, $C200
    add  hl, de
    ld   a, [hSwordIntersectedAreaX]
    add  a, $08
    ld   [hl], a
    ld   hl, $C210
    add  hl, de
    ld   a, [hSwordIntersectedAreaY]
    add  a, $10
    ld   [hl], a
    ld   hl, $C450
    add  hl, de
    ld   [hl], $80
    ld   hl, $C2F0
    add  hl, de
    ld   [hl], $18
    ld   hl, $C320
    add  hl, de
    ld   [hl], $10
    ret


    db   $12, $EE, $FC, $04, $04, $04, $EE, $12

toc_01_13C9:
    ld   c, a
    ld   a, [$C16D]
    and  a
    ret  z

    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, $00
    ld   hl, $13C1
    add  hl, de
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   [$FFD7], a
    ld   hl, $13C5
    add  hl, de
    ld   a, [hLinkPositionY]
    add  a, [hl]
    ld   [$FFD8], a
    assign [$C502], $04
    call toc_01_0993.toc_01_09A1
    assign [$C1C4], $10
    ld   a, c
    and  %11110000
    cp   $90
    jr   z, .else_01_13FF

    assign [$FFF2], $07
    ret


toc_01_13C9.else_01_13FF:
    assign [$FFF4], $17
    ret


    db   $20, $E0, $00, $00, $00, $00, $E0, $20

toc_01_140C:
    ifNot [$FFF9], .else_01_141A

    ld   a, [$FF9C]
    and  a
    ret  nz

    ld   a, [hLinkDirection]
    and  DIRECTION_UP
    ret  nz

toc_01_140C.else_01_141A:
    ld   a, [$C14A]
    and  a
    ret  nz

    ld   a, [hLinkPositionZHigh]
    ld   hl, $C146
    or   [hl]
    ret  nz

    ld   a, [$C120]
    add  a, $02
    ld   [$C120], a
    call toc_01_145D
    ld   a, [$C14B]
    inc  a
    ld   [$C14B], a
    cp   $20
    ret  nz

    ld   [$C14A], a
    clear [$C121]
    ld   [$C122], a
    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, $00
    ld   hl, $1404
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    ld   hl, $1408
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionYIncrement], a
    clear [$C1AC]
    ret


toc_01_145D:
    ld   a, [hFrameCounter]
    and  %00000111
    ld   hl, hLinkPositionZHigh
    or   [hl]
    ld   hl, hLinkInteractiveMotionBlocked
    or   [hl]
    ld   hl, $C146
    or   [hl]
    ret  nz

    copyFromTo [hLinkPositionX], [$FFD7]
    ifEq [$C181], $05, .else_01_1488

    assign [$FFF4], $07
    ld   a, [hLinkPositionY]
    add  a, 6
    ld   [$FFD8], a
    ld   a, $0B
    jp   toc_01_0953

toc_01_145D.else_01_1488:
    copyFromTo [hLinkPositionY], [$FFD8]
    assign [$FFF2], $0E
    ld   a, $0C
    jp   toc_01_0953

toc_01_1495:
    clear [hLinkPositionXIncrement]
    ld   [hLinkPositionYIncrement], a
    ret


toc_01_149B:
    call $77FA
toc_01_149B.toc_01_149E:
    ld   a, [$C11C]
    cp   $01
    ret  z

    ifNot [$C16A], .else_01_14E2

    ld   bc, $C010
    ld   a, [$C145]
    ld   hl, $C13B
    add  a, [hl]
    ld   [$FFD7], a
    copyFromTo [hLinkPositionX], [$FFD8]
    ld   hl, $FFDA
    ld   [hl], $00
    ifLt [$C122], $28, .else_01_14CD

    ld   a, [hFrameCounter]
    rla
    rla
    and  %00010000
    ld   [hl], a
toc_01_149B.else_01_14CD:
    loadHL [$C139], [$C13A]
    copyFromTo [$C136], [$FFD9]
    returnIfGte [hLinkPositionY], 136

    jp   toc_01_1540

toc_01_149B.else_01_14E2:
    ld   a, [$C19B]
    push af
    bit  7, a
    jp   z, .else_01_151B

    call_changebank $02
    call toc_02_514B
    ld   a, [$C19B]
    and  %01111111
    cp   $0C
    jr   nz, .else_01_151B

    ld   hl, wDialogState
    ld   a, [$C124]
    or   [hl]
    jr   nz, .else_01_151B

    call toc_01_1283
    ld   a, $04
    call toc_01_10EB
    jr   c, .else_01_151B

    assign [$FFF4], $0D
    call_changebank $02
    call toc_02_51C6
toc_01_149B.else_01_151B:
    pop  af
    ld   [$C19B], a
    ret


    db   $08, $06, $0C, $0A, $FF, $04, $0A, $0C
    db   $06, $08, $0A, $0C, $FF, $04, $0C, $0A
    db   $20, $20, $60, $60, $00, $00, $40, $40
    db   $00, $00, $00, $00, $40, $40, $20, $20

toc_01_1540:
    push hl
    ld   a, [$FFD7]
    add  a, h
    ld   [bc], a
    inc  bc
    ld   a, [$FFD8]
    add  a, l
    ld   [bc], a
    inc  bc
    ld   hl, $1520
    ld   a, [$FFD9]
    sla  a
    ld   e, a
    ld   d, $00
    add  hl, de
    ld   a, [hl]
    ld   [bc], a
    cp   $FF
    jr   nz, .else_01_1561

    dec  bc
    ld   a, $F0
    ld   [bc], a
    inc  bc
toc_01_1540.else_01_1561:
    inc  bc
    ld   hl, $1530
    add  hl, de
    ld   a, [hl]
    ld   hl, $FFDA
    or   [hl]
    ld   [bc], a
    inc  bc
    pop  hl
    ld   a, [$FFD7]
    add  a, h
    ld   [bc], a
    inc  bc
    ld   a, [$FFD8]
    add  a, l
    add  a, $08
    ld   [bc], a
    inc  bc
    ld   hl, $1521
    add  hl, de
    ld   a, [hl]
    ld   [bc], a
    inc  bc
    ld   hl, $1531
    add  hl, de
    ld   a, [hl]
    ld   hl, $FFDA
    or   [hl]
    ld   [bc], a
    ret


    db   $10, $F0, $08, $08, $0C, $0C, $F0, $10

toc_01_1594:
    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, $00
    ld   hl, $158C
    add  hl, de
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   [$C179], a
    ld   hl, $1590
    add  hl, de
    ld   a, [hLinkPositionY]
    add  a, [hl]
    ld   [$C17A], a
    assign [$C178], $02
    ret


JumpTable_15B3_00:
    call toc_01_780F
    ifNot [$C3C9], .else_01_15C3

    clear [$C3C9]
    jp   toc_01_0909

JumpTable_15B3_00.else_01_15C3:
    call toc_01_1776
    clear [$C157]
    inc  a
    ld   [$C1A8], a
    ld   a, [$C16B]
    cp   $04
    jp   nz, .return_01_172D

    clear [hBaseScrollX]
    ld   [hBaseScrollY], a
    ld   [$FFB4], a
    ld   e, $10
    ld   hl, $C280
JumpTable_15B3_00.loop_01_15E2:
    ldi  [hl], a
    dec  e
    jr   nz, .loop_01_15E2

    ifNot [$C509], .else_01_1606

    push af
    call_changebank $04
    pop  af
    call toc_04_792F.toc_04_79E3
    incAddr $DB6E
    incAddr $DB46
    assign [$D47E], $01
    clear [hLinkAnimationState]
JumpTable_15B3_00.else_01_1606:
    copyFromTo [$FFF9], [$FFE4]
    assign [wGameMode], GAMEMODE_WORLD
    clear [$DB96]
    ld   [$C3CB], a
    ld   [$FFF9], a
    ld   hl, $D401
    copyFromTo [$DBA5], [$FFE6]
    and  a
    jr   nz, .else_01_164D

    ld   hl, $D416
    ld   c, $00
JumpTable_15B3_00.loop_01_1628:
    ld   a, [hLinkPositionX]
    swap a
    and  %00001111
    ld   e, a
    ld   a, [hLinkPositionY]
    sub  a, 8
    and  %11110000
    or   e
    cp   [hl]
    jr   z, .else_01_1640

    inc  hl
    inc  c
    ld   a, c
    cp   $04
    jr   nz, .loop_01_1628

JumpTable_15B3_00.else_01_1640:
    ld   a, c
    sla  a
    sla  a
    add  a, c
    ld   e, a
    ld   d, $00
    ld   hl, $D401
    add  hl, de
JumpTable_15B3_00.else_01_164D:
    push hl
    ldi  a, [hl]
    ld   [$DBA5], a
    cp   $02
    jr   nz, .else_01_1660

    ld   [$FFF9], a
    dec  a
    ld   [$DBA5], a
    assign [$FF9C], $01
JumpTable_15B3_00.else_01_1660:
    ldi  a, [hl]
    ld   [$FFF7], a
    ld   a, [$DBA5]
    and  a
    ldi  a, [hl]
    ld   [$FFF6], a
    jr   nz, .else_01_1677

    ifNot [$FFE6], .else_01_1675

    clear [$D47C]
JumpTable_15B3_00.else_01_1675:
    jr   .toc_01_16D4

JumpTable_15B3_00.else_01_1677:
    ld   c, a
    call_changebank $14
    push hl
    ld   a, [$FFF7]
    swap a
    ld   e, a
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    ld   hl, $4200
    add  hl, de
    ifNe [$FFF7], $06, .else_01_16A1

    ld   a, [$DB6B]
    and  %00000100
    jr   z, .else_01_16A1

    ld   hl, $44C0
JumpTable_15B3_00.else_01_16A1:
    ld   e, $00
JumpTable_15B3_00.loop_01_16A3:
    ldi  a, [hl]
    cp   c
    jr   z, .else_01_16AD

    inc  e
    ld   a, e
    cp   $40
    jr   nz, .loop_01_16A3

JumpTable_15B3_00.else_01_16AD:
    ld   a, e
    ld   [$DBAE], a
    ld   a, [$FFE6]
    and  a
    jr   nz, .else_01_16D3

    clear [$D47C]
    ifGte [$FFF7], $0A, .else_01_16D3

    call_changebank $02
    call toc_02_6A9B
    assign [$FFB4], $30
    clear [$D6FB]
    ld   [$D6F8], a
JumpTable_15B3_00.else_01_16D3:
    pop  hl
JumpTable_15B3_00.toc_01_16D4:
    ldi  a, [hl]
    ld   [$DB9D], a
    ld   a, [hl]
    ld   [$DB9E], a
    pop  hl
    ld   a, [$FFF9]
    and  a
    jr   nz, .else_01_172E

    ld   a, [$FFE4]
    and  a
    jr   nz, .return_01_172D

    ifNot [$DBA5], .else_01_1716

    ifGte [$FFF7], $0A, .else_01_1716

    ld   e, a
    sla  a
    sla  a
    add  a, e
    ld   e, a
    ld   d, $00
    ld   hl, $53E5
    add  hl, de
    changebank $14
    call .else_01_1716
    push de
    ld   a, [$FFF7]
    ld   e, a
    ld   d, $00
    ld   hl, $5412
    add  hl, de
    ld   a, [hl]
    pop  de
    ld   [de], a
    ret


JumpTable_15B3_00.else_01_1716:
    assign [$FFD7], $00
    ld   de, $DB5F
JumpTable_15B3_00.loop_01_171D:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ld   a, [$FFD7]
    inc  a
    ld   [$FFD7], a
    cp   $05
    jr   nz, .loop_01_171D

    ld   a, [$DBAE]
    ld   [de], a
JumpTable_15B3_00.return_01_172D:
    ret


JumpTable_15B3_00.else_01_172E:
    clear [hLinkDirection]
    ret


JumpTable_1732_00:
    call toc_01_780F
    ifNot [$D474], .else_01_1750

    clear [$D474]
    assign [$C180], $30
    assign [$C17F], $03
    assign [$C16B], $04
    jr   .toc_01_175A

JumpTable_1732_00.else_01_1750:
    call toc_01_17C3
    ifNe [$C16B], $04, .return_01_1775

JumpTable_1732_00.toc_01_175A:
    ifEq [$D463], $01, .else_01_1763

    ld   a, $00
JumpTable_1732_00.else_01_1763:
    ld   [$C11C], a
    ifNot [$D47E], .return_01_1775

    clear [$D47E]
    ld   a, $36
    call toc_01_2197
JumpTable_1732_00.return_01_1775:
    ret


toc_01_1776:
    incAddr $C16C
    ld   a, [$C16C]
    and  %00000011
    jr   nz, .return_01_17B6

    ld   hl, $C16B
    ld   a, [hl]
    cp   $04
    jr   z, .return_01_17B6

    inc  [hl]
    clear [$FFD7]
toc_01_1776.toc_01_178D:
    ifEq [$FFD7], $03, .return_01_17B6

    ld   hl, $DB97
    ld   e, a
    ld   d, $00
    add  hl, de
    ld   a, [hl]
    ld   c, a
    ld   b, $00
toc_01_1776.loop_01_179E:
    ld   a, c
    and  %00000011
    jr   z, .else_01_17A4

    dec  c
toc_01_1776.else_01_17A4:
    rrc  c
    rrc  c
    inc  b
    ld   a, b
    cp   $04
    jr   nz, .loop_01_179E

    ld   a, c
    ld   [hl], a
    incAddr $FFD7
    jr   .toc_01_178D

toc_01_1776.return_01_17B6:
    ret


    db   $00, $01, $02, $03, $00, $03, $01, $00
    db   $00, $01, $02, $03

toc_01_17C3:
    incAddr $C16C
    ld   a, [$C16C]
    and  %00000011
    jr   nz, .return_01_1812

    ld   hl, $C16B
    ld   a, [hl]
    inc  [hl]
    cp   $04
    jr   z, toc_01_1776.return_01_17B6

    clear [$FFD7]
toc_01_17C3.toc_01_17DA:
    ifEq [$FFD7], $03, .return_01_1812

    ld   hl, $DB97
    ld   e, a
    ld   d, $00
    add  hl, de
    ld   a, [hl]
    push hl
    ld   c, a
    ld   b, $00
toc_01_17C3.loop_01_17EC:
    ld   a, [$FFD7]
    sla  a
    sla  a
    or   b
    ld   e, a
    ld   hl, $17B7
    add  hl, de
    ld   a, c
    and  %00000011
    cp   [hl]
    jr   z, .else_01_17FF

    inc  c
toc_01_17C3.else_01_17FF:
    rrc  c
    rrc  c
    inc  b
    ld   a, b
    cp   $04
    jr   nz, .loop_01_17EC

    ld   a, c
    pop  hl
    ld   [hl], a
    incAddr $FFD7
    jr   .toc_01_17DA

toc_01_17C3.return_01_1812:
    ret


    db   $00, $02, $02, $00, $10, $02, $12, $00
    db   $04, $06, $06, $04, $08, $0A, $0C, $0E
    db   $18, $0A, $1C, $0E, $0A, $08, $0E, $0C
    db   $0A, $18, $0E, $1C, $20, $22, $24, $26
    db   $28, $2A, $2A, $28, $30, $32, $20, $22
    db   $34, $36, $24, $26, $38, $3A, $28, $2A
    db   $3A, $38, $2A, $28, $40, $40, $42, $42
    db   $44, $46, $48, $4A, $4C, $4E, $50, $52
    db   $4E, $4C, $52, $50, $80, $02, $82, $00
    db   $84, $86, $88, $8A, $8C, $8E, $90, $92
    db   $94, $96, $98, $9A, $9C, $9E, $9A, $A2
    db   $A4, $08, $A6, $0C, $A8, $AA, $AC, $AE
    db   $B0, $B2, $B4, $B6, $B0, $B2, $B4, $B6
    db   $04, $C0, $06, $C2, $5A, $58, $5E, $5C
    db   $58, $5A, $5C, $5E, $44, $46, $6E, $6E
    db   $40, $40, $56, $56, $7A, $78, $7E, $7C
    db   $78, $7A, $7C, $7E, $74, $76, $76, $74
    db   $70, $72, $72, $70, $CA, $C8, $D6, $D4
    db   $C8, $CA, $D4, $D6, $CC, $CE, $D8, $DA
    db   $C4, $C4, $C6, $C6, $DC, $DC, $DE, $DE
    db   $EA, $EC, $EE, $F0, $F2, $F4, $F6, $F6
    db   $F8, $FA, $E0, $E2, $E4, $E6, $E8, $E8
    db   $10, $12, $14, $16, $18, $1C, $12, $10
    db   $16, $14, $1C, $18, $66, $68, $6A, $6C
    db   $68, $66, $68, $66, $6C, $6A, $66, $68
    db   $60, $60, $62, $62, $64, $64, $62, $62
    db   $64, $64, $60, $60, $54, $54, $3C, $3E
    db   $FE, $FE, $18, $1A, $1C, $1E, $2C, $2E
    db   $B8, $BA, $2E, $2C, $BA, $B8, $BC, $BE
    db   $D0, $D2, $A0, $FC, $FC, $A0, $00, $00
    db   $20, $20, $00, $00, $00, $20, $00, $00
    db   $20, $20, $00, $00, $00, $00, $00, $00
    db   $00, $00, $20, $20, $20, $20, $20, $20
    db   $20, $20, $00, $00, $00, $00, $00, $00
    db   $20, $20, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $20, $20
    db   $20, $20, $00, $20, $00, $20, $00, $00
    db   $00, $00, $00, $00, $00, $00, $20, $20
    db   $20, $20, $00, $00, $00, $20, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $20, $00, $00, $20
    db   $00, $20, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $20, $00, $20, $20, $20, $20, $00, $00
    db   $00, $00, $00, $00, $00, $20, $00, $20
    db   $00, $20, $20, $20, $20, $20, $00, $00
    db   $00, $00, $00, $00, $20, $20, $00, $00
    db   $20, $20, $20, $20, $20, $20, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $20
    db   $00, $20, $00, $20, $00, $20, $00, $00
    db   $00, $00, $00, $00, $00, $20, $00, $00
    db   $00, $00, $00, $00, $00, $20, $00, $00
    db   $00, $00, $00, $00, $20, $20, $20, $20
    db   $20, $20, $00, $00, $00, $00, $60, $60
    db   $20, $20, $20, $20, $40, $40, $00, $20
    db   $00, $20, $00, $20, $40, $60, $40, $60
    db   $40, $60, $00, $20, $00, $00, $00, $20
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $20, $20, $20, $20, $00, $00, $00, $00
    db   $00, $00, $20, $20

toc_01_19EF:
    ld   a, [$C120]
    sra  a
    sra  a
    sra  a
    and  %00000001
    ld   d, a
    ld   a, [hLinkDirection]
    sla  a
    or   d
    ld   c, a
    ld   b, $00
    ld   hl, $48F6
    ifNe [$C11C], $01, .else_01_1A17

    ifNot [$FF9C], .else_01_1A15

    ld   hl, $48FE
toc_01_19EF.else_01_1A15:
    jr   .toc_01_1A66

toc_01_19EF.else_01_1A17:
    ifNot [$FFF9], .else_01_1A27

    ifNe [$FF9C], $02, .else_01_1A27

    ld   hl, $4906
    jr   .toc_01_1A66

toc_01_19EF.else_01_1A27:
    ifEq [$C15C], $01, .else_01_1A63

    ld   a, [hLinkWalksSlow]
    and  a
    jr   nz, .else_01_1A39

    ld   a, [$C144]
    and  a
    jr   nz, .else_01_1A5E

toc_01_19EF.else_01_1A39:
    ld   a, [$C15A]
    and  a
    jr   nz, .else_01_1A44

    ld   hl, $48BE
    jr   .toc_01_1A66

toc_01_19EF.else_01_1A44:
    ld   hl, $48C6
    cp   $02
    jr   nz, .else_01_1A4E

    ld   hl, $48D6
toc_01_19EF.else_01_1A4E:
    ifNot [$C15B], .else_01_1A5C

    ld   a, l
    add  a, $08
    ld   l, a
    ld   a, h
    adc  $00
    ld   h, a
toc_01_19EF.else_01_1A5C:
    jr   .toc_01_1A66

toc_01_19EF.else_01_1A5E:
    ld   hl, $48E6
    jr   .toc_01_1A66

toc_01_19EF.else_01_1A63:
    ld   hl, $48EE
toc_01_19EF.toc_01_1A66:
    add  hl, bc
    ld   a, [hl]
    ld   [hLinkAnimationState], a
    ret


toc_01_1A6B:
    ld   a, [$D601]
    and  a
    ret  nz

    changebank $10
    ld   hl, $6500
    ld   de, $9500
    ld   a, [hFrameCounter]
    and  %00001111
    jr   z, .else_01_1A87

    cp   8
    ret  nz

    ld   l, $40
    ld   e, l
toc_01_1A6B.else_01_1A87:
    ld   a, [hFrameCounter]
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
    jp   copyHLToDE

    db   $20, $60, $A0, $E0, $E0, $E0, $A0, $60

toc_01_1AA9:
    ifEq [wGameMode], GAMEMODE_MARIN_BEACH, toc_01_1A6B

    cp   GAMEMODE_INTRO
    jr   nz, .else_01_1ADF

    ld   a, [$D601]
    and  a
    jp   nz, .return_01_1ADE

    ld   a, [hFrameCounter]
    and  %00001111
    cp   4
    jr   c, .return_01_1ADE

    changebank $10
    ld   a, [$D006]
    ld   l, a
    ld   a, [$D007]
    ld   h, a
    ld   a, [$D008]
    ld   e, a
    ld   a, [$D009]
    ld   d, a
    ld   bc, $0020
    call copyHLToDE
toc_01_1AA9.return_01_1ADE:
    ret


toc_01_1AA9.else_01_1ADF:
    ifNe [wGameMode], GAMEMODE_CREDITS, .else_01_1AEC

    ld   a, [$FFA5]
    and  a
    jr   nz, .else_01_1B1B

    ret


toc_01_1AA9.else_01_1AEC:
    cp   $0B
    jp   c, JumpTable_1C5A_00.return_01_1D14

    ld   a, [wWYStash]
    cp   128
    jp   nz, JumpTable_1C5A_00.return_01_1D14

    ld   a, [$C14F]
    and  a
    jp   nz, JumpTable_1C5A_00.else_01_1CCC

    ld   hl, $C124
    ld   a, [$D601]
    or   [hl]
    jp   nz, JumpTable_1C5A_00.else_01_1CCC

    ifNot [$D6F8], .else_01_1B16

    call toc_01_1DEE
    jp   JumpTable_1C5A_00.else_01_1CCC

toc_01_1AA9.else_01_1B16:
    ifNot [$FFA5], .else_01_1B66

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

    jp   JumpTable_1C5A_00.else_01_1CCC

toc_01_1AA9.else_01_1B5E:
    changebank $17
    jp   toc_17_4060

toc_01_1AA9.else_01_1B66:
    ld   a, [hAnimatedTilesFrameCount]
    inc  a
    ld   [hAnimatedTilesFrameCount], a
toc_01_1AA9.toc_01_1B6B:
    ld   a, [hAnimatedTilesGroup]
    jumptable
    dw JumpTable_1C5A_00 ; 00
    dw JumpTable_1B90_00 ; 01
    dw JumpTable_1BAA_00 ; 02
    dw JumpTable_1BAE_00 ; 03
    dw JumpTable_1BCD_00 ; 04
    dw JumpTable_1BF1_00 ; 05
    dw JumpTable_1BF5_00 ; 06
    dw JumpTable_1C10_00 ; 07
    dw JumpTable_1C21_00 ; 08
    dw JumpTable_1C30_00 ; 09
    dw JumpTable_1C3F_00 ; 0A
    dw JumpTable_1BB6_00 ; 0B
    dw JumpTable_1BB2_00 ; 0C
    dw JumpTable_1C4A_00 ; 0D
    dw JumpTable_1C56_00 ; 0E
    dw JumpTable_1C4E_00 ; 0F
    dw JumpTable_1C52_00 ; 10

JumpTable_1B90_00:
    ld   a, [hAnimatedTilesFrameCount]
    and  %00000111
    jp   nz, JumpTable_1C5A_00

    changebank $01
    call toc_01_5F62
    changebank $0C
    jp   JumpTable_1C5A_00.else_01_1CCC

toc_01_1BA7:
    ld   l, a
    jr   JumpTable_1BCD_00.toc_01_1BE5

JumpTable_1BAA_00:
    ld   h, $6B
    jr   JumpTable_1BB6_00.toc_01_1BB8

JumpTable_1BAE_00:
    ld   h, $6C
    jr   JumpTable_1BB6_00.toc_01_1BB8

JumpTable_1BB2_00:
    ld   h, $73
    jr   JumpTable_1BB6_00.toc_01_1BB8

JumpTable_1BB6_00:
    ld   h, $6A
JumpTable_1BB6_00.toc_01_1BB8:
    ld   a, [hAnimatedTilesFrameCount]
    and  %00001111
    jp   nz, JumpTable_1C5A_00

    call toc_01_1C43
    jp   toc_01_1BA7

    db   $00, $40, $80, $C0, $C0, $C0, $80, $40

JumpTable_1BCD_00:
    ld   a, [hAnimatedTilesFrameCount]
    and  %00000111
    jp   nz, JumpTable_1C5A_00

    ld   a, [hAnimatedTilesFrameCount]
    rra
    rra
    rra
    and  %00000111
    ld   e, a
    ld   d, $00
    ld   hl, $1BC5
    add  hl, de
    ld   l, [hl]
    ld   h, $6D
JumpTable_1BCD_00.toc_01_1BE5:
    ld   de, $96C0
JumpTable_1BCD_00.toc_01_1BE8:
    ld   bc, $0040
    call copyHLToDE
    jp   JumpTable_1C5A_00.else_01_1CCC

JumpTable_1BF1_00:
    ld   h, $6E
    jr   JumpTable_1BB6_00.toc_01_1BB8

JumpTable_1BF5_00:
    ld   a, [hAnimatedTilesFrameCount]
    and  %00000111
    jp   nz, JumpTable_1C5A_00

    ld   a, [hAnimatedTilesFrameCount]
    rra
    rra
    rra
    and  %00000111
    ld   e, a
    ld   d, $00
    ld   hl, $1BC5
    add  hl, de
    ld   l, [hl]
    ld   h, $6F
    jp   JumpTable_1BCD_00.toc_01_1BE5

JumpTable_1C10_00:
    ld   a, [hAnimatedTilesFrameCount]
    inc  a
    and  %00000011
    jp   nz, JumpTable_1BCD_00

    ld   hl, $DCC0
    ld   de, $90C0
    jp   JumpTable_1BCD_00.toc_01_1BE8

JumpTable_1C21_00:
    ld   h, $70
JumpTable_1C21_00.toc_01_1C23:
    ld   a, [hAnimatedTilesFrameCount]
    and  %00000111
    jp   nz, JumpTable_1C5A_00

    call toc_01_1C43
    jp   toc_01_1BA7

JumpTable_1C30_00:
    ld   h, $71
JumpTable_1C30_00.toc_01_1C32:
    ld   a, [hAnimatedTilesFrameCount]
    and  %00000011
    jp   nz, JumpTable_1C5A_00

    call toc_01_1C43
    jp   toc_01_1BA7

JumpTable_1C3F_00:
    ld   h, $72
    jr   JumpTable_1C30_00.toc_01_1C32

toc_01_1C43:
    ld   a, [hAnimatedTilesDataOffset]
    add  a, $40
    ld   [hAnimatedTilesDataOffset], a
    ret


JumpTable_1C4A_00:
    ld   h, $75
    jr   JumpTable_1C30_00.toc_01_1C32

JumpTable_1C4E_00:
    ld   h, $74
    jr   JumpTable_1C21_00.toc_01_1C23

JumpTable_1C52_00:
    ld   h, $77
    jr   JumpTable_1C21_00.toc_01_1C23

JumpTable_1C56_00:
    ld   h, $76
    jr   JumpTable_1C21_00.toc_01_1C23

JumpTable_1C5A_00:
    ld   a, [hLinkAnimationState]
    cp   LINK_ANIMATION_STATE_NO_UPDATE
    jp   z, .else_01_1CCC

    ld   hl, $1813
    sla  a
    ld   c, a
    ld   b, $00
    add  hl, bc
    ld   e, [hl]
    push hl
    ld   hl, $1901
    add  hl, bc
    ld   a, [$C11D]
    and  %10011111
    or   [hl]
    ld   [$C11D], a
    inc  hl
    ld   a, [$C11E]
    and  %10011111
    or   [hl]
    ld   [$C11E], a
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    ld   hl, $5800
    add  hl, de
    push hl
    pop  bc
    ld   hl, gbVRAM
    ld   d, $20
JumpTable_1C5A_00.loop_01_1CA0:
    ld   a, [bc]
    inc  bc
    ldi  [hl], a
    dec  d
    jr   nz, .loop_01_1CA0

    pop  hl
    inc  hl
    ld   e, [hl]
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    ld   hl, $5800
    add  hl, de
    push hl
    pop  bc
    ld   hl, $8020
    ld   d, $20
JumpTable_1C5A_00.loop_01_1CC6:
    ld   a, [bc]
    inc  bc
    ldi  [hl], a
    dec  d
    jr   nz, .loop_01_1CC6

JumpTable_1C5A_00.else_01_1CCC:
    ld   a, [hLinkAnimationState]
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
    ld   a, [hLinkPositionX]
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
    ld   a, [hLinkPositionX]
    add  a, c
    add  a, 8
    ldi  [hl], a
    ld   a, $02
    ldi  [hl], a
    ld   a, [$C135]
    ld   d, a
    ld   a, [$C11E]
    or   d
    ldi  [hl], a
JumpTable_1C5A_00.return_01_1D14:
    ret


toc_01_1D15:
    ld   hl, $4F00
    ld   a, $0E
    jr   toc_01_1D1C.toc_01_1D21

toc_01_1D1C:
    ld   a, $12
    ld   hl, $6080
toc_01_1D1C.toc_01_1D21:
    ld   [$2100], a
    ld   de, $8400
    ld   bc, $0040
    jp   toc_01_1E4A.toc_01_1E4D

toc_01_1D2D:
    ld   a, [$DB0E]
    cp   $02
    jp   c, toc_01_1E4A.toc_01_1E50

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
    changebank $0C
    jp   toc_01_1E4A.toc_01_1E4D

toc_01_1D54:
    ld   hl, $68C0
    ld   de, $88E0
    jr   toc_01_1DBE.toc_01_1DC4

toc_01_1D5C:
    changebank $11
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
toc_01_1D5C.toc_01_1D7B:
    add  hl, de
    pop  de
    ld   bc, $0040
    call copyHLToDE
    clear [$FFA5]
    changebank $0C
    ret


toc_01_1D8C:
    changebank $13
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
    jr   toc_01_1D5C.toc_01_1D7B

toc_01_1DAD:
    ld   hl, $48E0
    ld   de, $88E0
    changebank $0C
    ld   bc, $0020
    jp   toc_01_1E4A.toc_01_1E4D

toc_01_1DBE:
    ld   hl, $68E0
    ld   de, $8CA0
toc_01_1DBE.toc_01_1DC4:
    changebank $0C
    ld   bc, $0020
    jp   toc_01_1E4A.toc_01_1E4D

toc_01_1DCF:
    ld   hl, $7F00
    ld   a, $12
    jr   toc_01_1DD6.toc_01_1DDB

toc_01_1DD6:
    ld   hl, $4C40
    ld   a, $0D
toc_01_1DD6.toc_01_1DDB:
    ld   [$2100], a
    ld   de, $9140
    jp   toc_01_1E4A

    db   $40, $68, $40, $68, $00, $68, $80, $68
    db   $00, $68

toc_01_1DEE:
    ld   hl, $2100
    ld   [hl], $0C
    ld   hl, hLinkInteractiveMotionBlocked
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

    clear [$D6F8]
    ld   hl, $1DEA
toc_01_1DEE.toc_01_1E3A:
    add  hl, de
    ld   de, $9080
toc_01_1DEE.toc_01_1E3E:
    ld   bc, $0040
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    jp   copyHLToDE

toc_01_1DEE.else_01_1E47:
    jp   JumpTable_1C5A_00.else_01_1CCC

toc_01_1E4A:
    ld   bc, $0040
toc_01_1E4A.toc_01_1E4D:
    call copyHLToDE
toc_01_1E4A.toc_01_1E50:
    clear [$FFA5]
    changebank $0C
    jp   JumpTable_1C5A_00.else_01_1CCC

    db   $0C, $03, $08, $08, $0A, $0A, $05, $10
    db   $36, $38, $3A, $3C, $02, $01, $08, $04
    db   $FC, $04, $00, $00, $00, $00, $04, $00

toc_01_1E73:
    call toc_01_1E7B
    ld   a, $02
    jp   toc_01_07B9

toc_01_1E7B:
    ld   hl, $C14A
    ld   a, [$C15C]
    or   [hl]
    ld   hl, hLinkPositionZHigh
    or   [hl]
    ld   hl, $C11C
    or   [hl]
    jp   nz, .return_01_20A5

    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, $00
    ld   hl, $1E5B
    add  hl, de
    ld   a, [hLinkPositionX]
    add  a, [hl]
    sub  a, 8
    and  %11110000
    ld   [hSwordIntersectedAreaX], a
    swap a
    ld   c, a
    ld   hl, $1E5F
    add  hl, de
    ld   a, [hLinkPositionY]
    add  a, [hl]
    sub  a, 16
    and  %11110000
    ld   [hSwordIntersectedAreaY], a
    or   c
    ld   e, a
    ld   [$FFD8], a
    ld   hl, $D711
    add  hl, de
    ld   a, h
    cp   $D7
    jp   nz, .else_01_207C

    ld   a, [hl]
    ld   [$FFD7], a
    ld   e, a
    ld   a, [$DBA5]
    ld   d, a
    call toc_01_29DB
    ld   [$FFDC], a
    ifEq [$FFD7], $9A, .else_01_1F10

    ld   a, [$FFDC]
    cp   $00
    jp   z, .else_01_207C

    cp   $01
    jr   z, .else_01_1EF8

    cp   $50
    jp   z, .else_01_207C

    cp   $51
    jp   z, .else_01_207C

    cp   $11
    jp   c, .else_01_207C

    cp   $D4
    jp   nc, .else_01_207C

    cp   $D0
    jr   nc, .else_01_1EF8

    cp   $7C
    jp   nc, .else_01_207C

toc_01_1E7B.else_01_1EF8:
    ld   a, [$FFD7]
    ld   e, a
    cp   $6F
    jr   z, .else_01_1F08

    cp   $5E
    jr   z, .else_01_1F08

    cp   $D4
    jp   nz, .else_01_1FA1

toc_01_1E7B.else_01_1F08:
    ld   a, [$DBA5]
    and  a
    ld   a, e
    jp   nz, .else_01_1FA1

toc_01_1E7B.else_01_1F10:
    ld   e, a
    ld   a, [hLinkDirection]
    cp   DIRECTION_UP
    jp   nz, .else_01_1FFD

    assign [$C1AD], $02
    ld   a, [$FFCC]
    and  %00110000
    jp   z, .else_01_1FFD

    ld   a, e
    cp   $5E
    ld   a, $8E
    jr   z, .else_01_1F96

    ld   a, e
    cp   $6F
    jr   z, .else_01_1F5B

    cp   $D4
    jr   z, .else_01_1F5B

    ifNot [$DB73], .else_01_1F42

    ld   a, $78
    call toc_01_218E
    jp   .else_01_1FFD

toc_01_1E7B.else_01_1F42:
    ld   a, [$DB4E]
    and  a
    ld   a, [$FFF6]
    jr   nz, .else_01_1F50

    ld   e, $FF
    cp   $A3
    jr   z, .else_01_1F58

toc_01_1E7B.else_01_1F50:
    ld   e, $FC
    cp   $FA
    jr   z, .else_01_1F58

    ld   e, $FD
toc_01_1E7B.else_01_1F58:
    ld   a, e
    jr   .else_01_1F9C

toc_01_1E7B.else_01_1F5B:
    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    changebank $14
    ld   hl, $55FF
    add  hl, de
    ld   a, [$DB49]
    ld   e, a
    ld   a, [hl]
    cp   $A9
    jr   nz, .else_01_1F78

    bit  0, e
    jr   z, .else_01_1F78

    ld   a, $AF
toc_01_1E7B.else_01_1F78:
    cp   $AF
    jr   nz, .else_01_1F92

    bit  0, e
    jr   nz, .else_01_1F92

    ld   a, [hSwordIntersectedAreaX]
    swap a
    and  %00001111
    ld   e, a
    ld   a, [hSwordIntersectedAreaY]
    and  %11110000
    or   e
    ld   [$D473], a
    jp   .else_01_1FFD

toc_01_1E7B.else_01_1F92:
    cp   $83
    jr   z, .else_01_1F9C

toc_01_1E7B.else_01_1F96:
    call toc_01_2185
    jp   .else_01_1FFD

toc_01_1E7B.else_01_1F9C:
    call toc_01_2197
    jr   .else_01_1FFD

toc_01_1E7B.else_01_1FA1:
    cp   $A0
    jr   nz, .else_01_1FFD

    ld   a, [$C18E]
    and  %00011111
    cp   $0D
    jr   z, .else_01_1FFD

    ifNe [hLinkDirection], DIRECTION_UP, .else_01_1FFD

    ld   [$C1AD], a
    ld   a, [$FFCC]
    and  %00110000
    jr   z, .else_01_1FFD

    ld   a, [$FFF9]
    and  a
    jr   nz, .else_01_1FC8

    ifNe [hLinkDirection], DIRECTION_UP, .else_01_1FFD

toc_01_1E7B.else_01_1FC8:
    changebank $14
    ld   a, [$FFF6]
    ld   e, a
    ld   a, [$DBA5]
    ld   d, a
    ifGte [$FFF7], $1A, .else_01_1FDF

    cp   $06
    jr   c, .else_01_1FDF

    inc  d
toc_01_1E7B.else_01_1FDF:
    ld   hl, $4500
    add  hl, de
    ld   a, [hl]
    cp   $20
    jr   nz, .else_01_1FF3

    ld   a, [$DB4E]
    cp   $02
    ld   a, $20
    jr   c, .else_01_1FF3

    ld   a, $1C
toc_01_1E7B.else_01_1FF3:
    ld   [$FFDF], a
    changebank $02
    call toc_02_41BA
toc_01_1E7B.else_01_1FFD:
    ifNe [$DB00], $03, .else_01_200B

    ld   a, [hPressedButtonsMask]
    and  J_B
    jr   nz, .else_01_201A

    ret


toc_01_1E7B.else_01_200B:
    ld   a, [$DB01]
    cp   $03
    jp   nz, .return_01_20A5

    ld   a, [hPressedButtonsMask]
    and  J_A
    jp   z, .return_01_20A5

toc_01_1E7B.else_01_201A:
    changebank $02
    call toc_02_4738.else_02_485E
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_GRAB_SLASH
    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, $00
    ld   hl, $1E63
    add  hl, de
    ld   a, [hl]
    ld   [hLinkAnimationState], a
    ld   hl, $1E67
    add  hl, de
    ld   a, [hPressedButtonsMask]
    and  [hl]
    jr   z, .else_01_207C

    ld   hl, $1E6B
    add  hl, de
    ld   a, [hl]
    ld   [$C13C], a
    ld   hl, $1E6F
    add  hl, de
    ld   a, [hl]
    ld   [$C13B], a
    incAddr hLinkAnimationState
    ld   e, $08
    ifNe [$D47C], $01, .else_01_205A

    ld   e, $03
toc_01_1E7B.else_01_205A:
    incAddr $C15F
    ld   a, [hl]
    cp   e
    jr   c, .return_01_207B

    clear [$FFE5]
    ifEq [$FFD7], $8E, .else_01_2081

    cp   $20
    jr   z, .else_01_2081

    ld   a, [$DBA5]
    and  a
    jr   nz, .return_01_207B

    ifEq [$FFD7], $5C, .else_01_208F

toc_01_1E7B.return_01_207B:
    ret


toc_01_1E7B.else_01_207C:
    clear [$C15F]
    ret


toc_01_1E7B.else_01_2081:
    call .toc_01_2093
    changebank $14
    call toc_14_55AA
    jp   toc_01_07C0

toc_01_1E7B.else_01_208F:
    assign [$FFE5], $01
toc_01_1E7B.toc_01_2093:
    ld   a, [$FFD8]
    ld   e, a
    copyFromTo [$FFD7], [hObjectUnderEntity]
    call toc_01_20A6
    copyFromTo [hLinkDirection], [$C15D]
    call toc_01_20B1
toc_01_1E7B.return_01_20A5:
    ret


toc_01_20A6:
    changebank $14
    call toc_14_59DE
    jp   toc_01_07C0

toc_01_20B1:
    ld   a, $05
    call toc_01_10EB
    jr   c, .return_01_20D5

    assign [$FFF3], $02
    ld   hl, $C280
    add  hl, de
    ld   [hl], $07
    ld   hl, $C3B0
    add  hl, de
    ld   a, [$FFE5]
    ld   [hl], a
    push de
    pop  bc
    ld   e, $01
    call_changebank $03
    call toc_03_57EF
toc_01_20B1.return_01_20D5:
    ret


toc_01_20D6:
    ld   a, [$C14F]
    and  a
    ret  nz

    ld   c, $01
    call .toc_01_20E4
toc_01_20D6.toc_01_20E0:
    ld   c, $00
    ld   [$FFD7], a
toc_01_20D6.toc_01_20E4:
    ld   b, $00
    ld   hl, hLinkPositionXIncrement
    add  hl, bc
    ld   a, [hl]
    push af
    swap a
    and  %11110000
    ld   hl, $C11A
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, hLinkPositionX
    add  hl, bc
    pop  af
    ld   e, $00
    bit  7, a
    jr   z, .else_01_2105

    ld   e, $F0
toc_01_20D6.else_01_2105:
    swap a
    and  %00001111
    or   e
    rr   d
    adc  [hl]
    ld   [hl], a
    ret


toc_01_210F:
    ld   a, [hLinkPositionZLow]
    push af
    swap a
    and  %11110000
    ld   hl, $C149
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, hLinkPositionZHigh
    pop  af
    ld   e, $00
    bit  7, a
    jr   z, .else_01_2129

    ld   e, $F0
toc_01_210F.else_01_2129:
    swap a
    and  %00001111
    or   e
    rr   d
    adc  [hl]
    ld   [hl], a
    ret


toc_01_2133:
    ld   a, [wDialogState]
    and  a
    ret  z

    ld   e, a
    ld   a, [wGameMode]
    cp   GAMEMODE_CREDITS
    ld   a, $7E
    jr   nz, .else_01_2144

    ld   a, $7F
toc_01_2133.else_01_2144:
    ld   [$FFE8], a
    ld   a, [$C164]
    and  a
    ld   a, [$C170]
    jr   nz, .else_01_2153

    cp   $20
    jr   c, .else_01_2157

toc_01_2133.else_01_2153:
    and  %00001111
    or   %00010000
toc_01_2133.else_01_2157:
    ld   [$C171], a
    ld   a, e
    and  %01111111
    dec  a
    jumptable
    dw JumpTable_217D_00 ; 00
    dw JumpTable_21C2_00 ; 01
    dw JumpTable_21C2_00 ; 02
    dw JumpTable_21C2_00 ; 03
    dw JumpTable_2253_00 ; 04
    dw JumpTable_2320_00 ; 05
    dw JumpTable_2359_00 ; 06
    dw JumpTable_23B5_00 ; 07
    dw JumpTable_2521_00 ; 08
    dw JumpTable_2521_00.JumpTable_25A0_00 ; 09
    dw JumpTable_25F4_00 ; 0A
    dw JumpTable_2295_00 ; 0B
    dw JumpTable_261F_00 ; 0C
    dw JumpTable_22CE_00 ; 0D
    dw JumpTable_21C3_00 ; 0E

JumpTable_217D_00:
    changebank $14
    jp   toc_14_5924

toc_01_2185:
    call toc_01_2197
    assign [$C112], $01
    ret


toc_01_218E:
    call toc_01_2197
    assign [$C112], $02
    ret


toc_01_2197:
    push af
    clear [$C177]
    pop  af
    ld   [$C173], a
    clear [$C16F]
    ld   [$C170], a
    ld   [$C164], a
    ld   [wNameIndex], a
    ld   [$C112], a
    assign [$C5AB], $0F
    ld   a, [hLinkPositionY]
    cp   72
    rra
    and  %10000000
    or   %00000001
    ld   [wDialogState], a
    ret


JumpTable_21C2_00:
    ret


JumpTable_21C3_00:
    clear [wDialogState]
    assign [$C134], $18
    ret


    db   $00, $24, $48, $00, $24, $48, $98, $98
    db   $98, $99, $99, $99, $21, $61, $A1, $41
    db   $81, $C1

toc_01_21DF:
    ld   a, [wDialogState]
    bit  7, a
    jr   z, .else_01_21EA

    and  %01111111
    add  a, %00000011
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
    db   $99, $99, $99, $99

JumpTable_2253_00:
    ld   a, [wDialogState]
    ld   c, a
    ifEq [$C16F], $05, .else_01_2290

    bit  7, c
    jr   z, .else_01_2264

    add  a, $05
JumpTable_2253_00.else_01_2264:
    ld   c, a
    ld   b, $00
    ld   e, $01
    ld   d, $00
    ld   a, [$C12E]
    ld   hl, $2249
    add  hl, bc
    add  a, [hl]
    ld   hl, $D600
    add  hl, de
    ldi  [hl], a
    push hl
    ld   a, [$C12F]
    ld   hl, $223F
    add  hl, bc
    add  a, [hl]
    pop  hl
    ldi  [hl], a
    ld   a, $51
    ldi  [hl], a
    ld   a, [$FFE8]
    ldi  [hl], a
    ld   [hl], $00
    incAddr $C16F
    ret


JumpTable_2253_00.else_01_2290:
    incAddr wDialogState
    ret


JumpTable_2295_00:
    ld   a, [$C1AB]
    and  a
    jr   nz, .return_01_22AF

    ld   a, [$FFCC]
    and  %00110000
    jr   z, .return_01_22AF

JumpTable_2295_00.toc_01_22A1:
    clear [$C16F]
    ld   a, [wDialogState]
    and  %11110000
    or   %00001110
    ld   [wDialogState], a
JumpTable_2295_00.return_01_22AF:
    ret


    db   $A1, $21, $81, $41, $61, $C1, $41, $A1
    db   $61, $81, $98, $98, $98, $98, $98, $99
    db   $99, $99, $99, $99, $48, $00, $36, $12
    db   $24, $48, $00, $36, $12, $24

JumpTable_22CE_00:
    ld   a, [wDialogState]
    ld   c, a
    ifEq [$C16F], $05, JumpTable_2253_00.else_01_2290

    bit  7, c
    jr   z, .else_01_22DF

    add  a, $05
JumpTable_22CE_00.else_01_22DF:
    ld   c, a
    ld   b, $00
    ld   e, $01
    ld   d, $00
    ld   a, [$C12E]
    ld   hl, $22BA
    add  hl, bc
    add  a, [hl]
    ld   hl, $D600
    add  hl, de
    ldi  [hl], a
    push hl
    ld   a, [$C12F]
    ld   hl, $22B0
    add  hl, bc
    add  a, [hl]
    pop  hl
    ldi  [hl], a
    ld   a, $11
    ldi  [hl], a
    push hl
    ld   hl, $22C4
    add  hl, bc
    ld   a, [hl]
    ld   c, a
    ld   b, $00
    ld   hl, $D500
    add  hl, bc
    push hl
    pop  bc
    pop  hl
    ld   e, $12
JumpTable_22CE_00.loop_01_2313:
    ld   a, [bc]
    inc  bc
    ldi  [hl], a
    dec  e
    jr   nz, .loop_01_2313

    ld   [hl], $00
    incAddr $C16F
    ret


JumpTable_2320_00:
    changebank $1C
    ifNot [$C172], .else_01_2330

    dec  a
    ld   [$C172], a
    ret


JumpTable_2320_00.else_01_2330:
    ld   a, [$C170]
    and  %00011111
    ld   e, a
    ld   d, $00
    ld   c, $01
    ld   b, $00
    ld   hl, $4521
    add  hl, de
    ld   a, [hl]
    ld   hl, $D600
    add  hl, bc
    ldi  [hl], a
    push hl
    ld   hl, $4501
    add  hl, de
    ld   a, [hl]
    pop  hl
    ldi  [hl], a
    ld   a, $4F
    ldi  [hl], a
    ld   a, $FF
    ldi  [hl], a
    ld   [hl], $00
    jp   JumpTable_2253_00.else_01_2290

JumpTable_2359_00:
    changebank $1C
    ld   a, [wDialogState]
    ld   c, a
    ld   a, [$C171]
    bit  7, c
    jr   z, .else_01_236B

    add  a, $20
JumpTable_2359_00.else_01_236B:
    ld   c, a
    ld   b, $00
    ld   e, $01
    ld   d, $00
    ld   a, [$C12E]
    ld   hl, $4561
    add  hl, bc
    add  a, [hl]
    ld   hl, $D600
    add  hl, de
    ldi  [hl], a
    ld   [$C175], a
    push hl
    ld   hl, $45A1
    add  hl, bc
    ld   a, [hl]
    and  %11100000
    add  a, $20
    ld   e, a
    ld   a, [$C12F]
    add  a, [hl]
    ld   d, a
    cp   e
    jr   c, .else_01_2399

    ld   a, d
    sub  a, $20
    ld   d, a
JumpTable_2359_00.else_01_2399:
    ld   a, d
    ld   [$C176], a
    pop  hl
    ldi  [hl], a
    xor  a
    ldi  [hl], a
    push hl
    ld   a, [$C170]
    and  %00011111
    ld   c, a
    ld   hl, $4541
    add  hl, bc
    ld   a, [hl]
    pop  hl
    ldi  [hl], a
    call JumpTable_2253_00.else_01_2290
    jp   JumpTable_23B5_00

JumpTable_23B5_00:
    changebank $1C
    ld   a, [$C170]
    and  %00011111
    ld   c, a
    ld   b, $00
    ld   e, $05
    ld   d, $00
    ld   hl, $4521
    add  hl, bc
    ld   a, [hl]
    ld   hl, $D600
    add  hl, de
    ldi  [hl], a
    push hl
    ld   hl, $4501
    add  hl, bc
    ld   a, [hl]
    pop  hl
    ldi  [hl], a
    ld   a, $0F
    ldi  [hl], a
    push hl
    ld   a, [$C112]
    ld   d, a
    ld   a, [$C173]
    ld   e, a
    sla  e
    rl   d
    ld   hl, $4001
    add  hl, de
    ldi  a, [hl]
    ld   e, a
    ld   d, [hl]
    push de
    ld   a, [$C173]
    ld   e, a
    ld   a, [$C112]
    ld   d, a
    ld   hl, $46E1
    add  hl, de
    ld   a, [hl]
    and  %00011111
    ld   [$2100], a
    pop  hl
    ld   a, [$C170]
    ld   e, a
    ld   a, [$C164]
    ld   d, a
    add  hl, de
    ldi  a, [hl]
    ld   e, a
    ld   a, [hl]
    ld   [$C3C3], a
    call toc_01_07C0
    ld   a, e
    ld   [$FFD7], a
    cp   $FE
    jr   nz, .else_01_2430

    pop  hl
    clear [$D601]
JumpTable_23B5_00.toc_01_2421:
    ld   a, [wDialogState]
    and  %11110000
    or   %00001101
    ld   [wDialogState], a
JumpTable_23B5_00.toc_01_242B:
    assign [$FFF2], $15
    ret


JumpTable_23B5_00.else_01_2430:
    cp   $FF
    jr   nz, toc_01_2449

    pop  hl
    clear [$D601]
JumpTable_23B5_00.toc_01_2439:
    ld   a, [wDialogState]
    and  %11110000
    or   %00001100
    ld   [wDialogState], a
    ret


    db   $55, $49, $4A, $46, $47

toc_01_2449:
    cp   $20
    jr   z, .else_01_246C

    push af
    ld   a, [$C5AB]
    ld   d, a
    ld   e, $01
    cp   $0F
    jr   z, .else_01_2460

    ld   e, $07
    cp   $19
    jr   z, .else_01_2460

    ld   e, $03
toc_01_2449.else_01_2460:
    ld   a, [$C170]
    add  a, $04
    and  e
    jr   nz, .else_01_246B

    ld   a, d
    ld   [$FFF3], a
toc_01_2449.else_01_246B:
    pop  af
toc_01_2449.else_01_246C:
    ld   d, $00
    cp   $23
    jr   nz, .else_01_2494

    ld   a, [wNameIndex]
    ld   e, a
    inc  a
    cp   5
    jr   nz, .else_01_247C

    xor  a
toc_01_2449.else_01_247C:
    ld   [wNameIndex], a
    ld   hl, $DB4F
    ifNot [$DB6E], .else_01_248B

    ld   hl, $2444
toc_01_2449.else_01_248B:
    add  hl, de
    ld   a, [hl]
    dec  a
    cp   $FF
    jr   nz, .else_01_2494

    ld   a, $20
toc_01_2449.else_01_2494:
    ld   [$FFD8], a
    ld   e, a
    changebank $1C
    ld   hl, $45E1
    add  hl, de
    ld   e, [hl]
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    call toc_01_07C0
    ld   hl, $5000
    add  hl, de
    push hl
    pop  bc
    pop  hl
    ld   e, $10
toc_01_2449.loop_01_24BF:
    ld   a, [bc]
    ldi  [hl], a
    inc  bc
    dec  e
    jr   nz, .loop_01_24BF

    ld   [hl], $00
    push hl
    changebank $1C
    ld   a, [$FFD8]
    ld   e, a
    ld   d, $00
    xor  a
    pop  hl
    and  a
    jr   z, .else_01_24EF

    ld   e, a
    ld   a, [$C175]
    ldi  [hl], a
    ld   a, [$C176]
    sub  a, $20
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    ld   a, $C9
    rr   e
    jr   c, .else_01_24EC

    dec  a
toc_01_2449.else_01_24EC:
    ldi  [hl], a
    ld   [hl], $00
toc_01_2449.else_01_24EF:
    ld   a, [$C170]
    add  a, $01
    ld   [$C170], a
    ld   a, [$C164]
    adc  $00
    ld   [$C164], a
    clear [$C1CC]
    ifEq [$C171], $1F, .else_01_251A

toc_01_2449.toc_01_250A:
    ld   a, [wDialogState]
    and  %11110000
    or   %00000110
    ld   [wDialogState], a
    assign [$C172], $00
    ret


toc_01_2449.else_01_251A:
    jp   JumpTable_2253_00.else_01_2290

    db   $22, $42, $98, $99

JumpTable_2521_00:
    ld   a, [$C170]
    and  %00011111
    jr   nz, .else_01_256D

    ld   a, [$C3C3]
    cp   $FF
    jp   z, JumpTable_23B5_00.toc_01_2439

    cp   $FE
    jp   z, JumpTable_23B5_00.toc_01_2421

    ld   a, [$C1CC]
    and  a
    jr   nz, .else_01_2542

    inc  a
    ld   [$C1CC], a
    call JumpTable_23B5_00.toc_01_242B
JumpTable_2521_00.else_01_2542:
    call toc_01_264D
    ld   a, [$FFCC]
    bit  4, a
    jr   nz, .else_01_256D

    bit  5, a
    jr   z, .JumpTable_25A0_00

    changebank $1C
    ld   a, [wGameMode]
    cp   GAMEMODE_WORLD_MAP
    jp   z, toc_01_2617

    ld   a, [$C173]
    ld   e, a
    ld   a, [$C112]
    ld   d, a
    ld   hl, $46E1
    add  hl, de
    bit  7, [hl]
    jp   z, toc_01_2617

JumpTable_2521_00.else_01_256D:
    ld   e, $00
    ld   a, [wDialogState]
    and  %10000000
    jr   z, .else_01_2577

    inc  e
JumpTable_2521_00.else_01_2577:
    ld   d, $00
    ld   hl, $251F
    add  hl, de
    ld   a, [$C12E]
    add  a, [hl]
    ld   [$D601], a
    ld   hl, $251D
    add  hl, de
    ld   a, [$C12F]
    add  a, [hl]
    ld   [$D602], a
    assign [$D603], $4F
    copyFromTo [$FFE8], [$D604]
    clear [$D605]
    call JumpTable_2253_00.else_01_2290
JumpTable_2521_00.JumpTable_25A0_00:
    ret


    db   $62, $82, $98, $99

toc_01_25A5:
    ld   e, $00
    ld   a, [wDialogState]
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

    assign [$C172], $08
    jp   JumpTable_2253_00.else_01_2290

JumpTable_25F4_00:
    ret


    db   $42, $62, $98, $99

toc_01_25F9:
    ld   e, $00
    ld   a, [wDialogState]
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
    jp   toc_01_2449.toc_01_250A

toc_01_2617:
    assign [$C177], $02
    jp   JumpTable_2295_00.toc_01_22A1

JumpTable_261F_00:
    ld   a, [$FFCC]
    bit  5, a
    jr   nz, toc_01_2617

    and  %00010000
    jp   nz, .else_01_2649

    ld   a, [$FFCC]
    and  %01000011
    jr   z, .else_01_263C

    ld   hl, $C177
    ld   a, [hl]
    inc  a
    and  %00000001
    ld   [hl], a
    assign [$FFF2], $0A
JumpTable_261F_00.else_01_263C:
    ld   a, [hFrameCounter]
    and  %00010000
    ret  z

    changebank $17
    jp   toc_17_7B57

JumpTable_261F_00.else_01_2649:
    call JumpTable_2295_00.toc_01_22A1
    ret


toc_01_264D:
    changebank $17
    jp   toc_17_7B07

toc_01_2655:
    call_changebank $02
    call toc_02_7B74
    ret


    db   $01, $01, $20, $20, $93, $93, $13, $13
    db   $10, $10, $01, $01, $08, $08, $0A, $0A
    db   $01, $FF, $F0, $10, $00, $00, $03, $00
    db   $02, $1E, $C0, $40

toc_01_267A:
    changebank $08
    call toc_01_2686
    call toc_01_07C0
    ret


toc_01_2686:
    ifEq [$C12B], $00, .else_01_2692

    dec  a
    ld   [$C12B], a
    ret


toc_01_2686.else_01_2692:
    ld   a, [$C125]
    ld   c, a
    ld   b, $00
    assign [$C12B], $01
    copyFromTo [$C12A], [$FFD9]
    ld   hl, $265E
    add  hl, bc
    copyFromTo [$C127], [$D602]
    add  a, [hl]
    rl   d
    ld   [$D619], a
    ld   a, [$C126]
    or   %10011000
    ld   [$D601], a
    rr   d
    adc  $00
    ld   [$D618], a
    ld   hl, $2662
    add  hl, bc
    ld   a, [hl]
    ld   [$D603], a
    ld   [$D61A], a
    assign [$D62F], $00
    assign [$D614], $EE
    ld   [$D615], a
    ld   [$D616], a
    ld   [$D617], a
    ld   [$D62B], a
    ld   [$D62C], a
    ld   [$D62D], a
    ld   [$D62E], a
    ld   b, $D6
    ld   c, $04
    ld   d, $D6
    ld   e, $1B
toc_01_2686.loop_01_26F3:
    push bc
    push de
    ld   a, [$FFD9]
    ld   c, a
    ld   b, $00
    ld   hl, $D711
    add  hl, bc
    ld   b, $00
    ld   c, [hl]
    sla  c
    rl   b
    sla  c
    rl   b
    ld   hl, $498C
    ifNot [$DBA5], .else_01_2715

    ld   hl, $4D60
toc_01_2686.else_01_2715:
    add  hl, bc
    pop  de
    pop  bc
    ld   a, [$C125]
    and  %00000010
    jr   z, .else_01_272D

    ldi  a, [hl]
    ld   [bc], a
    inc  bc
    ldi  a, [hl]
    ld   [bc], a
    inc  bc
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ld   a, [hl]
    ld   [de], a
    inc  de
    jr   .toc_01_2739

toc_01_2686.else_01_272D:
    ldi  a, [hl]
    ld   [bc], a
    ldi  a, [hl]
    ld   [de], a
    inc  bc
    inc  de
    ldi  a, [hl]
    ld   [bc], a
    ld   a, [hl]
    ld   [de], a
    inc  bc
    inc  de
toc_01_2686.toc_01_2739:
    push bc
    ld   a, [$C125]
    ld   c, a
    ld   b, $00
    ld   hl, $2666
    add  hl, bc
    ld   a, [$FFD9]
    add  a, [hl]
    ld   [$FFD9], a
    pop  bc
    ld   a, [$C128]
    dec  a
    ld   [$C128], a
    jr   nz, .loop_01_26F3

    ld   a, [$C125]
    ld   c, a
    ld   b, $00
    ld   hl, $266A
    add  hl, bc
    ld   a, [hl]
    ld   [$C128], a
    ld   hl, $266E
    add  hl, bc
    ld   a, [$C12A]
    add  a, [hl]
    ld   [$C12A], a
    ld   hl, $2676
    add  hl, bc
    ld   a, [$C127]
    add  a, [hl]
    rr   d
    and  %11011111
    ld   [$C127], a
    ld   hl, $2672
    add  hl, bc
    ld   a, [$C126]
    rl   d
    adc  [hl]
    and  %00000011
    ld   [$C126], a
    ld   a, [$C129]
    dec  a
    ld   [$C129], a
    jr   nz, .return_01_2796

    jp   .toc_01_2797

toc_01_2686.return_01_2796:
    ret


toc_01_2686.toc_01_2797:
    ld   a, [$C124]
    inc  a
    ld   [$C124], a
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF

toc_01_27A8:
    ld   [$D368], a
    ld   [hNextDefaultMusicTrack], a
    assign [hMusicFadeInTimer], 56
    clear [hMusicFadeOutTimer]
    ret


enableRAM:
    push hl
    ld   hl, $0000
    ld   [hl], $0A
    pop  hl
    ret


toc_01_27BD:
    changebank $02
    push bc
    call toc_02_4146
    pop  bc
    jp   toc_01_07C0

toc_01_27CA:
    assign [hMusicFadeOutTimer], 56
    clear [hMusicFadeInTimer]
    ret


toc_01_27D2:
    ld   a, [$FFBC]
    and  a
    jr   nz, .else_01_27DF

    changebank $1F
    call toc_1F_4003
toc_01_27D2.else_01_27DF:
    jp   toc_01_07C0

toc_01_27E2:
    changebank $01
    call toc_01_5BCF
    jp   toc_01_07C0

toc_01_27ED:
    push hl
    ld   a, [hFrameCounter]
    ld   hl, $C13D
    add  a, [hl]
    ld   hl, gbLY
    add  a, [hl]
    rrca
    ld   [$C13D], a
    pop  hl
    ret


toc_01_27FE:
    ld   a, [$C124]
    and  a
    jr   nz, .return_01_2838

    assign [gbP1], JOYPAD_BUTTONS
    ld   a, [gbP1]
    ld   a, [gbP1]
    cpl
    and  %00001111
    ld   b, a
    assign [gbP1], JOYPAD_DIRECTIONS
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
    ld   a, [hPressedButtonsMask]
    xor  c
    and  c
    ld   [$FFCC], a
    ld   a, c
    ld   [hPressedButtonsMask], a
    assign [gbP1], JOYPAD_BUTTONS | JOYPAD_DIRECTIONS
toc_01_27FE.return_01_2838:
    ret


toc_01_2839:
    push bc
    ld   a, [hSwordIntersectedAreaY]
    ld   hl, hBaseScrollY
    add  a, [hl]
    and  %11111000
    srl  a
    srl  a
    srl  a
    ld   de, $0000
    ld   e, a
    ld   hl, gbBGDAT0
    ld   b, $20
toc_01_2839.loop_01_2851:
    add  hl, de
    dec  b
    jr   nz, .loop_01_2851

    push hl
    ld   a, [hSwordIntersectedAreaX]
    ld   hl, hBaseScrollX
    add  a, [hl]
    pop  hl
    and  %11111000
    srl  a
    srl  a
    srl  a
    ld   de, $0000
    ld   e, a
    add  hl, de
    ld   a, h
    ld   [$FFCF], a
    ld   a, l
    ld   [$FFD0], a
    pop  bc
    ret


JumpTable:
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

setupLCD:
    copyFromTo [gbIE], [hIEStash]
    res  0, a
setupLCD.waitForVBlank:
    ifNe [gbLY], 145, .waitForVBlank

    mask [gbLCDC], LCDCF_BG_CHAR_8000 | LCDCF_BG_DISPLAY | LCDCF_BG_TILE_9C00 | LCDCF_OBJ_16_16 | LCDCF_OBJ_DISPLAY | LCDCF_TILEMAP_9C00 | LCDCF_WINDOW_ON
    copyFromTo [hIEStash], [gbIE]
    ret


JumpTable_2898_00:
    call_changebank $01
    call toc_01_7CF3
    ret


JumpTable_28A1_00:
    ld   a, $7E
    ld   bc, $0400
    jr   initializeBGDAT0.setRegion

initializeBGDAT0:
    ld   a, $7F
    ld   bc, $0800
initializeBGDAT0.setRegion:
    ld   d, a
    ld   hl, gbBGDAT0
initializeBGDAT0.loopSetRegion:
    ld   a, d
    ldi  [hl], a
    dec  bc
    ld   a, b
    or   c
    jr   nz, .loopSetRegion

    ret


toc_01_28B9:
    ld   [$2100], a
    call copyHLToDE
    changebank $01
    ret


copyHLToDE:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    dec  bc
    ld   a, b
    or   c
    jr   nz, copyHLToDE

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
toc_01_28CE.toc_01_28D8:
    ld   a, [$C124]
    and  a
    jr   nz, .else_01_28ED

toc_01_28CE.toc_01_28DE:
    ld   a, [de]
    and  a
    jr   nz, toc_01_28CE

    ret


toc_01_28CE.loop_01_28E3:
    inc  de
    ld   h, a
    ld   a, [de]
    ld   l, a
    inc  de
    ld   a, [de]
    inc  de
    call toc_01_2948
toc_01_28CE.else_01_28ED:
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


    db   $01, $00, $16, $18, $16

toc_01_2980:
    ld   bc, $1300
    jr   clearBGTiles.clearRAM

toc_01_2985:
    ld   bc, $002F
    jr   clearBGTiles.toc_01_298D

clearBGTiles:
    ld   bc, $006D
clearBGTiles.toc_01_298D:
    ld   hl, hNeedsUpdatingBGTiles
    call .clearRegion
    ld   bc, $1F00
clearBGTiles.clearRAM:
    ld   hl, gbRAM
clearBGTiles.clearRegion:
    xor  a
    ldi  [hl], a
    dec  bc
    ld   a, b
    or   c
    jr   nz, .clearRegion

    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

toc_01_29B8:
    changebank $14
    ld   hl, $4500
    add  hl, de
    ld   a, [hl]
    jp   toc_01_07C0

toc_01_29C5:
    ld   a, [$C5AC]
    and  a
    jr   nz, .return_01_29CF

    assign [$FFF4], $2D
toc_01_29C5.return_01_29CF:
    ret


toc_01_29D0:
    changebank $01
    call toc_01_5807
    jp   toc_01_07C0

toc_01_29DB:
    changebank $08
    ld   hl, $5110
    add  hl, de
    ld   a, [hl]
    jp   toc_01_07C0

toc_01_29E8:
    changebank $08
    ld   hl, $5110
    add  hl, de
    ld   a, [hl]
    push af
    changebank $03
    pop  af
    ret


JumpTable_29FA_00:
    changebank $13
    ld   hl, $6800
    ld   de, $9000
    ld   bc, $0800
    call copyHLToDE
    ld   hl, $7000
    ld   de, $8800
    ld   bc, $0800
    jp   copyHLToDE

JumpTable_2A17_00:
    call JumpTable_2A26_00
    ld   de, $8400
    ld   hl, $7600
    ld   bc, $0100
    jp   copyHLToDE

JumpTable_2A26_00:
    changebank $13
    ld   hl, $4000
    ld   de, $8000
    ld   bc, $1800
    call copyHLToDE
    changebank $0C
    ld   hl, $57E0
    ld   de, $97F0
    ld   bc, $0010
    call copyHLToDE
    changebank $12
    ld   hl, $7500
    ld   de, $8000
    ld   bc, $0040
    call copyHLToDE
    ld   de, $8D00
    ld   hl, $7500
    ld   bc, $0200
    jp   copyHLToDE

JumpTable_2A65_00:
    changebank $0C
    ld   hl, $5000
    ld   de, $9000
    ld   bc, $0800
    call copyHLToDE
    changebank $12
    ld   hl, $6000
    ld   de, $8000
    ld   bc, $0800
    call copyHLToDE
    changebank $0F
    ld   hl, $6000
    ld   de, $8800
    ld   bc, $0800
    jp   copyHLToDE

JumpTable_2A98_00:
    ld   hl, $4000
    jr   JumpTable_2AA2_00.toc_01_2AA5

JumpTable_2A9D_00:
    ld   hl, $4800
    jr   JumpTable_2AA2_00.toc_01_2AA5

JumpTable_2AA2_00:
    ld   hl, $6000
JumpTable_2AA2_00.toc_01_2AA5:
    changebank $13
    ld   de, $8000
    ld   bc, $0800
    call copyHLToDE
    ld   hl, $5800
    ld   de, $8800
    ld   bc, $1000
    jp   copyHLToDE

JumpTable_2ABF_00:
    call toc_01_0844
    ld   hl, $6800
    ld   a, $10
    call JumpTable_2AF7_00.toc_01_2AFC
    call toc_01_0844
    changebank $12
    ld   hl, $6600
    ld   de, $8000
    ld   bc, $0080
    call copyHLToDE
    call toc_01_0844
    changebank $0C
    ld   hl, $4220
    ld   de, $8100
    ld   bc, $0020
    jp   copyHLToDE

JumpTable_2AF2_00:
    ld   hl, $7800
    jr   JumpTable_2AF7_00.toc_01_2AFA

JumpTable_2AF7_00:
    ld   hl, $4800
JumpTable_2AF7_00.toc_01_2AFA:
    ld   a, $13
JumpTable_2AF7_00.toc_01_2AFC:
    ld   [$2100], a
    ld   de, $8000
    ld   bc, $0800
    call copyHLToDE
    changebank $13
    ld   hl, $7000
    ld   de, $8800
    ld   bc, $0800
    call copyHLToDE
    ld   hl, $6800
    ld   de, $9000
    ld   bc, $0800
    jp   copyHLToDE

toc_01_2B25:
    push bc
    changebank $14
    ld   hl, $4200
    ifGte [$FFF7], $0B, .else_01_2B66

    swap a
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    sla  c
    rl   b
    add  hl, bc
    ifNe [$FFF7], $06, .else_01_2B52

    ld   a, [$DB6B]
    and  %00000100
    jr   z, .else_01_2B52

    ld   hl, $44C0
toc_01_2B25.else_01_2B52:
    add  hl, de
    ld   a, [hl]
    ld   e, a
    ld   d, $00
    ifGte [$FFF7], $1A, .else_01_2B62

    cp   $06
    jr   c, .else_01_2B62

    inc  d
toc_01_2B25.else_01_2B62:
    ld   hl, $D900
    add  hl, de
toc_01_2B25.else_01_2B66:
    call toc_01_07C0
    pop  bc
    ret


JumpTable_2B6B_00:
    call_changebank $0C
    ld   hl, $4000
    ld   de, $8000
    ld   bc, $0400
    call copyHLToDE
    call_changebank $0C
    ld   hl, $4800
    ld   de, $8800
    ld   bc, $1000
    call copyHLToDE
    ld   hl, $47A0
    ld   de, $8E00
    ld   bc, $0020
    call copyHLToDE
    call_changebank $01
    ret


JumpTable_2B9F_00:
    call JumpTable_2B6B_00
    call_changebank $0F
    ld   hl, $4000
    ld   de, $8800
    ld   bc, $0400
    call copyHLToDE
    call_changebank $0F
    ld   hl, $5000
    ld   de, $9000
    ld   bc, $0800
    jp   copyHLToDE

JumpTable_2BC4_00:
    call_changebank $01
    ld   a, [$FFF7]
    ld   e, a
    ld   d, $00
    push de
    ld   hl, $7F64
    add  hl, de
    ld   h, [hl]
    ld   l, $00
    call_changebank $0D
    ld   de, $9100
    ld   bc, $0100
    call copyHLToDE
    ld   hl, $4000
    ld   de, $9200
    ld   bc, $0600
    call copyHLToDE
    changebank $01
    pop  de
    push de
    ld   hl, $7F84
    add  hl, de
    ld   h, [hl]
    ld   l, $00
    call toc_01_07C0
    ld   de, $9200
    ld   bc, $0200
    call copyHLToDE
    changebank $0C
    ld   hl, $47C0
    ld   de, $DCC0
    ld   bc, $0040
    call copyHLToDE
    call toc_01_2CA1
    changebank $01
    pop  de
    ld   hl, $7FA4
    add  hl, de
    ld   h, [hl]
    ld   l, $00
    call_changebank $12
    ld   de, $8F00
    ld   bc, $0100
    call copyHLToDE
    ld   hl, $7D00
    ifLt [$FFF7], $0A, .else_01_2C4A

    call_changebank $0C
    ld   hl, $4C00
JumpTable_2BC4_00.else_01_2C4A:
    ld   de, $8C00
    ld   bc, $0300
    call copyHLToDE
JumpTable_2BC4_00.toc_01_2C53:
    ifNot [$DB4B], .else_01_2C5C

    call toc_01_1D54
JumpTable_2BC4_00.else_01_2C5C:
    ifNot [$DBA5], .else_01_2C68

    ifLt [$FFF7], $0A, .else_01_2C72

JumpTable_2BC4_00.else_01_2C68:
    ifLt [$DB15], $06, .else_01_2C72

    call toc_01_1DBE
JumpTable_2BC4_00.else_01_2C72:
    ifLt [$DB0E], $02, .return_01_2C7D

    assign [$FFA5], $0D
JumpTable_2BC4_00.return_01_2C7D:
    ret


JumpTable_2C7E_00:
    call_changebank $0C
    ld   hl, $5200
    ld   de, $9200
    ld   bc, $0600
    call copyHLToDE
    ld   hl, $4C00
    ld   de, $8C00
    ld   bc, $0400
    call copyHLToDE
    call toc_01_2CA1
    jp   JumpTable_2BC4_00.toc_01_2C53

toc_01_2CA1:
    clear [hAnimatedTilesFrameCount]
    ld   [hAnimatedTilesDataOffset], a
    call toc_01_1AA9.toc_01_1B6B
    ld   hl, $4800
    ld   de, $8800
    ld   bc, $0800
    call copyHLToDE
    ld   hl, $4200
    ld   de, $8200
    ld   bc, $0100
    call copyHLToDE
    ret


JumpTable_2CC2_00:
    call_changebank $01
    ld   hl, $7D31
    ld   de, $8700
    ld   bc, $0080
    call copyHLToDE
    call_changebank $10
    ld   hl, $5400
    ld   de, $8000
    ld   bc, $0600
    call copyHLToDE
    ld   hl, $4000
    ld   de, $8800
    ld   bc, $1000
    jp   copyHLToDE

JumpTable_2CF0_00:
    call_changebank $0F
    ld   hl, $4900
    ld   de, $8800
    ld   bc, $0700
    jp   copyHLToDE

JumpTable_2D01_00:
    call_changebank $0C
    ld   hl, $7800
    ld   de, $8F00
    ld   bc, $0800
    call copyHLToDE
    ld   hl, $5000
    ld   de, $8200
    ld   bc, $0100
    jp   copyHLToDE

JumpTable_2D1E_00:
    ld   hl, $7000
    jr   JumpTable_2D28_00.toc_01_2D2B

JumpTable_2D23_00:
    ld   hl, $7800
    jr   JumpTable_2D28_00.toc_01_2D2B

JumpTable_2D28_00:
    ld   hl, $5800
JumpTable_2D28_00.toc_01_2D2B:
    call_changebank $10
    ld   de, $9000
    ld   bc, $0800
    jp   copyHLToDE

JumpTable_2D39_00:
    changebank $13
    ld   hl, $7C00
    ld   de, $8C00
    ld   bc, $0400
    call copyHLToDE
    ld   hl, $6800
    ld   de, $9000
    ld   bc, $0400
    jp   copyHLToDE

JumpTable_2D56_00:
    call_changebank $10
    ld   hl, $6700
    ld   de, $8400
    ld   bc, $0400
    call copyHLToDE
    ld   hl, $6000
    ld   de, $9000
    ld   bc, $0600
    jp   copyHLToDE

JumpTable_2D73_00:
    call_changebank $0F
    ld   hl, $4400
    ld   de, $8800
    ld   bc, $0500
    jp   copyHLToDE

    db   $00, $11, $0E, $12

JumpTable_2D88_00:
    xor  a
JumpTable_2D88_00.loop_01_2D89:
    ld   [$FFD7], a
    ld   hl, $C193
    ld   e, a
    ld   d, $00
    add  hl, de
    and  a
    jr   nz, .else_01_2DD7

    ifNot [$DBA5], .else_01_2DB4

    ld   a, [$FFF9]
    and  a
    jr   nz, .else_01_2DD7

    ifEq [$FFF7], $14, .else_01_2DD7

    cp   $0A
    jr   c, .else_01_2DD7

    ifEq [$FFF6], $FD, .else_01_2DD7

    cp   $B1
    jr   z, .else_01_2DD7

JumpTable_2D88_00.else_01_2DB4:
    ld   a, [$DB56]
    cp   $01
    ld   a, $A4
    jr   z, .else_01_2DD5

    ld   a, [$DB79]
    and  a
    ld   a, $D8
    jr   nz, .else_01_2DD5

    ld   a, [$DB7B]
    and  a
    ld   a, $DD
    jr   nz, .else_01_2DD5

    ifNot [$DB73], .else_01_2DD7

    ld   a, $8F
JumpTable_2D88_00.else_01_2DD5:
    jr   .toc_01_2DD8

JumpTable_2D88_00.else_01_2DD7:
    ld   a, [hl]
JumpTable_2D88_00.toc_01_2DD8:
    push af
    and  %00111111
    ld   b, a
    ld   c, $00
    pop  af
    swap a
    rra
    rra
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $2D84
    add  hl, de
    ld   a, [hl]
    ld   [$2100], a
    ld   a, [$FFD7]
    ld   d, a
    ld   e, $00
    ld   hl, $8400
    add  hl, de
    push hl
    pop  de
    ld   hl, $4000
    add  hl, bc
    ld   bc, $0100
    call copyHLToDE
    ld   a, [$FFD7]
    inc  a
    cp   $04
    jp   nz, .loop_01_2D89

    ld   de, $9000
    ifNot [$DBA5], .else_01_2E55

    changebank $0D
    ifNot [$FFF9], .else_01_2E42

    ld   hl, $7000
    ifEq [$FFF7], $06, .else_01_2E38

    cp   $0A
    jr   nc, .else_01_2E32

JumpTable_2D88_00.loop_01_2E2D:
    ld   hl, $7800
    jr   .else_01_2E38

JumpTable_2D88_00.else_01_2E32:
    ifEq [$FFF6], $E9, .loop_01_2E2D

JumpTable_2D88_00.else_01_2E38:
    ld   de, $9000
    ld   bc, $0800
    call copyHLToDE
    ret


JumpTable_2D88_00.else_01_2E42:
    ld   hl, $5000
    ifEq [hWorldTileset], $FF, .return_01_2E54

    add  a, $50
    ld   h, a
    ld   bc, $0100
    call copyHLToDE
JumpTable_2D88_00.return_01_2E54:
    ret


JumpTable_2D88_00.else_01_2E55:
    changebank $0F
    ifEq [hWorldTileset], $0F, .return_01_2E6B

    add  a, $40
    ld   h, a
    ld   l, $00
    ld   bc, $0200
    call copyHLToDE
JumpTable_2D88_00.return_01_2E6B:
    ret


JumpTable_2E6C_00:
    call_changebank $08
    ld   de, $9800
    ld   hl, $D711
    ld   c, $80
JumpTable_2E6C_00.loop_01_2E79:
    push de
    push hl
    push bc
    ld   a, [hl]
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    sla  c
    rl   b
    ld   hl, $498C
    ifNot [$DBA5], .else_01_2E94

    ld   hl, $4D60
JumpTable_2E6C_00.else_01_2E94:
    add  hl, bc
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ldi  a, [hl]
    ld   [de], a
    ld   a, e
    add  a, $1F
    ld   e, a
    ld   a, d
    adc  $00
    ld   d, a
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ld   a, [hl]
    ld   [de], a
    pop  bc
    pop  hl
    pop  de
    inc  hl
    ld   a, l
    and  %00001111
    cp   $0B
    jr   nz, .else_01_2EB8

    ld   a, l
    and  %11110000
    add  a, $11
    ld   l, a
JumpTable_2E6C_00.else_01_2EB8:
    ld   a, e
    add  a, $02
    ld   e, a
    and  %00011111
    cp   $14
    jr   nz, .else_01_2ECC

    ld   a, e
    and  %11100000
    add  a, $40
    ld   e, a
    ld   a, d
    adc  $00
    ld   d, a
JumpTable_2E6C_00.else_01_2ECC:
    dec  c
    jr   nz, .loop_01_2E79

    changebank $01
    jp   toc_01_7DC1

toc_01_2ED7:
    assign [gbIE], IE_VBLANK
    incAddr $D47F
    changebank $09
    clear [$FFE6]
    ld   [$C19C], a
    ld   [$C504], a
    ld   [$DBC8], a
    ld   [$DBC9], a
    ld   [$C1A2], a
    ld   [$C1C6], a
    ld   [$D6FA], a
    ld   [$C50A], a
    ld   [$FFAC], a
    ld   [$C113], a
    ld   [$D460], a
    ld   [$C1BE], a
    ld   [$C50E], a
    ld   [$C3C8], a
    ld   [$C5A6], a
    ld   [$D462], a
    ld   [$C3CD], a
    assign [$D401], $FF
    ld   [$C50F], a
    ifNot [$DBA5], .else_01_2F90

    changebank $14
    ld   [$FFE8], a
    ifGte [$FFF7], $0B, .else_01_2F5F

    ld   hl, $4200
    swap a
    ld   e, a
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    add  hl, de
    ifNe [$FFF7], $06, .else_01_2F55

    ld   a, [$DB6B]
    and  %00000100
    jr   z, .else_01_2F55

    ld   hl, $44C0
toc_01_2ED7.else_01_2F55:
    ld   a, [$DBAE]
    ld   e, a
    ld   d, $00
    add  hl, de
    ld   a, [hl]
    ld   [$FFF6], a
toc_01_2ED7.else_01_2F5F:
    ld   a, [$FFF6]
    ld   c, a
    ld   b, $00
    ifGte [$FFF7], $1A, .else_01_2F6F

    cp   $06
    jr   c, .else_01_2F6F

    inc  b
toc_01_2ED7.else_01_2F6F:
    ld   hl, $4000
    add  hl, bc
    ld   a, [hl]
    ld   [$C18E], a
    clear [$C18A]
    ld   [$C18B], a
    ld   [$C190], a
    ld   [$C18F], a
    ld   e, a
    ld   hl, $DBB5
toc_01_2ED7.loop_01_2F88:
    xor  a
    ldi  [hl], a
    inc  e
    ld   a, e
    cp   $11
    jr   nz, .loop_01_2F88

toc_01_2ED7.else_01_2F90:
    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    ld   hl, $D800
    ifNot [$DBA5], .else_01_2FAE

    ld   hl, $D900
    ifGte [$FFF7], $1A, .else_01_2FAE

    cp   $06
    jr   c, .else_01_2FAE

    ld   hl, $DA00
toc_01_2ED7.else_01_2FAE:
    add  hl, de
    ld   a, [$FFF9]
    and  a
    ld   a, [hl]
    jr   nz, .else_01_2FB8

    or   %10000000
    ld   [hl], a
toc_01_2ED7.else_01_2FB8:
    ld   [$FFF8], a
    ld   a, [$FFF6]
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    ifNot [$DBA5], .else_01_3002

    changebank $0A
    ld   [$FFE8], a
    ifNe [$FFF7], $1F, .else_01_2FE9

    ifNe [$FFF6], $F5, .else_01_2FE9

    ifNe [$DB0E], $0E, .else_01_2FE9

    ld   bc, $7853
    jp   .else_01_307D

toc_01_2ED7.else_01_2FE9:
    ld   hl, $4000
    ifGte [$FFF7], $1A, .else_01_3067

    cp   $06
    jr   c, .else_01_3067

    changebank $0B
    ld   [$FFE8], a
    ld   hl, $4000
    jr   .else_01_3067

toc_01_2ED7.else_01_3002:
    ifNe [$FFF6], $0E, .else_01_3014

    ld   a, [$D80E]
    and  %00010000
    jr   z, .else_01_3064

    ld   bc, $47F0
    jr   .toc_01_3072

toc_01_2ED7.else_01_3014:
    cp   $8C
    jr   nz, .else_01_3024

    ld   a, [$D88C]
    and  %00010000
    jr   z, .else_01_3064

    ld   bc, $4356
    jr   .toc_01_3072

toc_01_2ED7.else_01_3024:
    cp   $79
    jr   nz, .else_01_3034

    ld   a, [$D879]
    and  %00010000
    jr   z, .else_01_3064

    ld   bc, $64FD
    jr   .toc_01_3072

toc_01_2ED7.else_01_3034:
    cp   $06
    jr   nz, .else_01_3044

    ld   a, [$D806]
    and  %00010000
    jr   z, .else_01_3064

    ld   bc, $4496
    jr   .toc_01_3072

toc_01_2ED7.else_01_3044:
    cp   $1B
    jr   nz, .else_01_3054

    ld   a, [$D82B]
    and  %00010000
    jr   z, .else_01_3064

    ld   bc, $4C13
    jr   .toc_01_3072

toc_01_2ED7.else_01_3054:
    cp   $2B
    jr   nz, .else_01_3064

    ld   a, [$D82B]
    and  %00010000
    jr   z, .else_01_3064

    ld   bc, $50AC
    jr   .toc_01_3072

toc_01_2ED7.else_01_3064:
    ld   hl, $4000
toc_01_2ED7.else_01_3067:
    add  hl, bc
    ldi  a, [hl]
    ld   c, a
    ld   a, [hl]
    ld   b, a
    ld   a, [$DBA5]
    and  a
    jr   nz, .else_01_307D

toc_01_2ED7.toc_01_3072:
    ifLt [$FFF6], $80, .else_01_307D

    changebank $1A
toc_01_2ED7.else_01_307D:
    ld   a, [bc]
    cp   $FE
    jr   z, .else_01_30D1

    ld   [hAnimatedTilesGroup], a
    inc  bc
    ifNot [$DBA5], .else_01_309B

    ld   a, [bc]
    and  %00001111
    call toc_01_36CF
    ld   a, [bc]
    swap a
    and  %00001111
    call toc_01_37C9
    jr   .toc_01_309F

toc_01_2ED7.else_01_309B:
    ld   a, [bc]
    call toc_01_36CF
toc_01_2ED7.toc_01_309F:
    inc  bc
    ld   a, [bc]
    and  %11111100
    cp   $E0
    jr   nz, .else_01_30C7

    ld   a, [$FFE6]
    ld   e, a
    ld   d, $00
    ld   hl, $D401
    add  hl, de
    ld   a, [bc]
    and  %00000011
    ldi  [hl], a
    inc  bc
    ld   a, [bc]
    ldi  [hl], a
    inc  bc
    ld   a, [bc]
    ldi  [hl], a
    inc  bc
    ld   a, [bc]
    ldi  [hl], a
    inc  bc
    ld   a, [bc]
    ldi  [hl], a
    ld   a, e
    add  a, $05
    ld   [$FFE6], a
    jr   .toc_01_309F

toc_01_2ED7.else_01_30C7:
    ld   a, [bc]
    cp   $FE
    jr   z, .else_01_30D1

    call toc_01_30DC
    jr   .toc_01_309F

toc_01_2ED7.else_01_30D1:
    changebank $01
    call toc_01_7CDE
    jp   toc_01_07C0

toc_01_30DC:
    clear [$FFD7]
    ld   a, [bc]
    bit  7, a
    jr   z, .else_01_30EB

    bit  4, a
    jr   nz, .else_01_30EB

    ld   [$FFD7], a
    inc  bc
toc_01_30DC.else_01_30EB:
    inc  bc
    ld   a, [$FFF8]
    ld   e, a
    ld   a, [$DBA5]
    and  a
    jr   nz, toc_01_310D

    ld   a, [bc]
    sub  a, $F5
    jr   c, toc_01_3138

    jumptable
    dw JumpTable_3338_00 ; 00
    dw JumpTable_3425_00 ; 01
    dw JumpTable_3445_00 ; 02
    dw JumpTable_33EF_00 ; 03
    dw JumpTable_345F_00 ; 04
    dw JumpTable_3479_00 ; 05
    dw JumpTable_3498_00 ; 06
    dw JumpTable_34C2_00 ; 07
    dw JumpTable_34DC_00 ; 08

toc_01_310D:
    ld   a, [bc]
    sub  a, $EC
    jp   c, toc_01_31FD

    jumptable
    dw JumpTable_34EB_00 ; 00
    dw JumpTable_3506_00 ; 01
    dw JumpTable_3521_00 ; 02
    dw JumpTable_353C_00 ; 03
    dw JumpTable_3555_00 ; 04
    dw JumpTable_3568_00 ; 05
    dw JumpTable_357B_00 ; 06
    dw JumpTable_358E_00 ; 07
    dw JumpTable_35A3_00 ; 08
    dw JumpTable_35D2_00 ; 09
    dw JumpTable_35E6_00 ; 0A
    dw JumpTable_35FA_00 ; 0B
    dw JumpTable_360E_00 ; 0C
    dw JumpTable_3646_00 ; 0D
    dw JumpTable_3655_00 ; 0E
    dw JumpTable_3664_00 ; 0F
    dw JumpTable_368A_00 ; 10
    dw JumpTable_369E_00 ; 11

toc_01_3138:
    add  a, $F5
    push af
    ld   d, a
    cp   $E9
    jr   nz, .else_01_3143

    ld   [$C50E], a
toc_01_3138.else_01_3143:
    cp   $5E
    jr   nz, .else_01_314B

    bit  5, e
    jr   nz, .else_01_31B0

toc_01_3138.else_01_314B:
    cp   $91
    jr   nz, .else_01_3158

    bit  5, e
    jr   z, .else_01_3158

    pop  af
    ld   a, $5E
    ld   d, a
    push af
toc_01_3138.else_01_3158:
    cp   $DC
    jr   nz, .else_01_3165

    bit  5, e
    jr   z, .else_01_3165

    pop  af
    ld   a, $91
    ld   d, a
    push af
toc_01_3138.else_01_3165:
    cp   $D8
    jr   z, .else_01_3171

    cp   $D9
    jr   z, .else_01_3171

    cp   $DA
    jr   nz, .else_01_317A

toc_01_3138.else_01_3171:
    bit  4, e
    jr   z, .else_01_317A

    pop  af
    ld   a, $DB
    ld   d, a
    push af
toc_01_3138.else_01_317A:
    cp   $C2
    jr   nz, .else_01_3187

    bit  4, e
    jr   z, .else_01_3187

    pop  af
    ld   a, $E3
    ld   d, a
    push af
toc_01_3138.else_01_3187:
    ld   a, d
    cp   $BA
    jr   nz, .else_01_3195

    bit  2, e
    jr   z, .else_01_3195

    pop  af
    ld   a, $E1
    ld   d, a
    push af
toc_01_3138.else_01_3195:
    ld   a, d
    cp   $D3
    jr   nz, .else_01_31B5

    bit  4, e
    jr   z, .else_01_31B5

    ifEq [$FFF6], $75, .else_01_31B0

    cp   $07
    jr   z, .else_01_31B0

    cp   $AA
    jr   z, .else_01_31B0

    cp   $4A
    jr   nz, .else_01_31B5

toc_01_3138.else_01_31B0:
    pop  af
    ld   a, $C6
    ld   d, a
    push af
toc_01_3138.else_01_31B5:
    ld   a, d
    ld   [$FFE0], a
    cp   $C2
    jr   z, .else_01_31DC

    cp   $E1
    jr   z, .else_01_31DC

    cp   $CB
    jr   z, .else_01_31DC

    cp   $BA
    jr   z, .else_01_31DC

    cp   $61
    jr   z, .else_01_31DC

    cp   $C6
    jr   z, .else_01_31DC

    cp   $C5
    jr   z, .else_01_31DC

    cp   $E2
    jr   z, .else_01_31DC

    cp   $E3
    jr   nz, .else_01_31EE

toc_01_3138.else_01_31DC:
    ld   a, [$C19C]
    ld   e, a
    inc  a
    ld   [$C19C], a
    ld   d, $00
    ld   hl, $D416
    add  hl, de
    dec  bc
    ld   a, [bc]
    ld   [hl], a
    inc  bc
toc_01_3138.else_01_31EE:
    ld   a, [$FFE0]
    cp   $C5
    jp   z, toc_01_31FD.else_01_32AA

    cp   $C6
    jp   z, toc_01_31FD.else_01_32AA

    jp   toc_01_31FD.else_01_32FB

toc_01_31FD:
    add  a, $EC
    ld   [$FFE0], a
    push af
    cp   $CF
    jr   c, .else_01_320E

    cp   $D3
    jr   nc, .else_01_320E

    incAddr $C1A5
toc_01_31FD.else_01_320E:
    cp   $AB
    jr   nz, .else_01_3234

    clear [$C3CB]
    ld   a, [$FFF6]
    cp   $C4
    ld   a, [$FFE0]
    jr   z, .else_01_3234

    incAddr $DBC9
    ld   [$C3CB], a
    push af
    ld   a, [$C3CD]
    add  a, $04
    ld   [$C3CD], a
    assign [$C16B], $04
    pop  af
toc_01_31FD.else_01_3234:
    cp   $8E
    jr   z, .else_01_324B

    cp   $AA
    jr   z, .else_01_324B

    cp   $DC
    jr   z, .else_01_3244

    cp   $DB
    jr   nz, .else_01_3250

toc_01_31FD.else_01_3244:
    ld   hl, $D6FA
    ld   [hl], $02
    jr   .else_01_3250

toc_01_31FD.else_01_324B:
    ld   hl, $D6FA
    ld   [hl], $01
toc_01_31FD.else_01_3250:
    cp   $3F
    jr   z, .else_01_3258

    cp   $47
    jr   nz, .else_01_325C

toc_01_31FD.else_01_3258:
    bit  2, e
    jr   nz, .else_01_3268

toc_01_31FD.else_01_325C:
    cp   $40
    jr   z, .else_01_3264

    cp   $48
    jr   nz, .else_01_326C

toc_01_31FD.else_01_3264:
    bit  3, e
    jr   z, .else_01_326C

toc_01_31FD.else_01_3268:
    pop  af
    ld   a, $3D
    push af
toc_01_31FD.else_01_326C:
    cp   $41
    jr   z, .else_01_3274

    cp   $49
    jr   nz, .else_01_3278

toc_01_31FD.else_01_3274:
    bit  1, e
    jr   nz, .else_01_3284

toc_01_31FD.else_01_3278:
    cp   $42
    jr   z, .else_01_3280

    cp   $4A
    jr   nz, .else_01_3288

toc_01_31FD.else_01_3280:
    bit  0, e
    jr   z, .else_01_3288

toc_01_31FD.else_01_3284:
    pop  af
    ld   a, $3E
    push af
toc_01_31FD.else_01_3288:
    cp   $A1
    jr   nz, .else_01_3294

    bit  4, e
    jr   nz, .else_01_3294

    pop  af
    ld   a, [$FFE9]
    push af
toc_01_31FD.else_01_3294:
    cp   $BF
    jr   nz, .else_01_329E

    bit  4, e
    jr   nz, .else_01_329E

    pop  af
    ret


toc_01_31FD.else_01_329E:
    cp   $BE
    jr   z, .else_01_32AA

    cp   $BF
    jr   z, .else_01_32AA

    cp   $CB
    jr   nz, .else_01_32C3

toc_01_31FD.else_01_32AA:
    dec  bc
    assign [$FFAC], $01
    ld   a, [bc]
    and  %11110000
    add  a, $10
    ld   [$FFAE], a
    ld   a, [bc]
    swap a
    and  %11110000
    add  a, $08
    ld   [$FFAD], a
    inc  bc
    jp   .else_01_32FB

toc_01_31FD.else_01_32C3:
    cp   $D6
    jr   z, .else_01_32CB

    cp   $D5
    jr   nz, .else_01_32D3

toc_01_31FD.else_01_32CB:
    bit  4, e
    jr   nz, .else_01_32D3

    pop  af
    ld   a, $21
    push af
toc_01_31FD.else_01_32D3:
    cp   $D7
    jr   z, .else_01_32DB

    cp   $D8
    jr   nz, .else_01_32E3

toc_01_31FD.else_01_32DB:
    bit  4, e
    jr   nz, .else_01_32E3

    pop  af
    ld   a, $22
    push af
toc_01_31FD.else_01_32E3:
    ld   a, [$FFF7]
    cp   $0A
    ld   a, [$FFE0]
    jr   c, .else_01_32EF

    cp   $A9
    jr   z, .else_01_32F3

toc_01_31FD.else_01_32EF:
    cp   $DE
    jr   nz, .else_01_32FB

toc_01_31FD.else_01_32F3:
    bit  6, e
    jr   z, .else_01_32FB

    pop  af
    ld   a, $0D
    push af
toc_01_31FD.else_01_32FB:
    cp   $A0
    jr   nz, .else_01_3307

    bit  4, e
    jr   z, .else_01_3307

    pop  af
    ld   a, $A1
    push af
toc_01_31FD.else_01_3307:
    ld   d, $00
    ifNot [$FFD7], .else_01_332D

    dec  bc
    ld   a, [bc]
    ld   e, a
    ld   hl, $D711
    add  hl, de
    ld   a, [$FFD7]
    and  %00001111
    ld   e, a
    pop  af
    ld   d, a
toc_01_31FD.loop_01_331C:
    ld   a, d
    ldi  [hl], a
    ld   a, [$FFD7]
    and  %01000000
    jr   z, .else_01_3328

    ld   a, l
    add  a, $0F
    ld   l, a
toc_01_31FD.else_01_3328:
    dec  e
    jr   nz, .loop_01_331C

    inc  bc
    ret


toc_01_31FD.else_01_332D:
    dec  bc
    ld   a, [bc]
    ld   e, a
    ld   hl, $D711
    add  hl, de
    pop  af
    ld   [hl], a
    inc  bc
    ret


JumpTable_3338_00:
    dec  bc
    ld   a, [bc]
    add  a, $11
    ld   e, a
    and  %00001111
    jr   nz, .else_01_3345

    ld   a, e
    sub  a, $10
    ld   e, a
JumpTable_3338_00.else_01_3345:
    ld   d, $00
    ld   hl, $D700
    add  hl, de
    ifNot [$FFD7], .else_01_3369

    and  %00001111
    ld   e, a
JumpTable_3338_00.loop_01_3353:
    call .else_01_3369
    dec  bc
    ld   a, [$FFD7]
    and  %01000000
    ld   d, $F1
    jr   z, .else_01_3361

    ld   d, $0F
JumpTable_3338_00.else_01_3361:
    ld   a, l
    add  a, d
    ld   l, a
    dec  e
    jr   nz, .loop_01_3353

    inc  bc
    ret


JumpTable_3338_00.else_01_3369:
    ld   a, [hl]
    cp   $10
    ld   a, $25
    jr   c, .else_01_3372

    add  a, $04
JumpTable_3338_00.else_01_3372:
    ldi  [hl], a
    ld   a, [hl]
    cp   $10
    ld   a, $26
    jr   c, .else_01_337C

    add  a, $04
JumpTable_3338_00.else_01_337C:
    ldd  [hl], a
    ld   a, l
    add  a, $10
    ld   l, a
    ld   a, [hl]
    cp   $8A
    jr   nc, .else_01_3390

    cp   $10
    ld   a, $27
    jr   c, .else_01_3392

    ld   a, $2A
    jr   .else_01_3392

JumpTable_3338_00.else_01_3390:
    ld   a, $82
JumpTable_3338_00.else_01_3392:
    ldi  [hl], a
    ld   a, [hl]
    cp   $8A
    jr   nc, .else_01_33A2

    cp   $10
    ld   a, $28
    jr   c, .else_01_33A4

    ld   a, $29
    jr   .else_01_33A4

JumpTable_3338_00.else_01_33A2:
    ld   a, $83
JumpTable_3338_00.else_01_33A4:
    ld   [hl], a
    inc  bc
    ret


toc_01_33A7:
    push hl
    push de
    ld   a, [bc]
    ld   e, a
    ld   d, $00
    add  hl, de
    pop  de
    ld   a, [de]
    cp   $E1
    jr   z, .else_01_33BC

    cp   $E2
    jr   z, .else_01_33BC

    cp   $E3
    jr   nz, .else_01_33D6

toc_01_33A7.else_01_33BC:
    push af
    push hl
    push de
    ld   a, l
    sub  a, $11
    push af
    ld   a, [$C19C]
    ld   e, a
    inc  a
    ld   [$C19C], a
    ld   d, $00
    ld   hl, $D416
    add  hl, de
    pop  af
    ld   [hl], a
    pop  de
    pop  hl
    pop  af
toc_01_33A7.else_01_33D6:
    ld   [hl], a
    inc  de
    inc  bc
    pop  hl
    ld   a, [bc]
    and  a
    cp   $FF
    jr   nz, toc_01_33A7

    pop  bc
    ret


    db   $00, $01, $02, $10, $11, $12, $FF, $B6
    db   $B7, $66, $67, $E3, $68

JumpTable_33EF_00:
    push bc
    call toc_01_33FC
    ld   bc, $33E2
    ld   de, $33E9
    jp   toc_01_33A7

toc_01_33FC:
    dec  bc
    ld   a, [bc]
    ld   e, a
    ld   d, $00
    ld   hl, $D711
    add  hl, de
    ret


    db   $00, $01, $02, $03, $04, $10, $11, $12
    db   $13, $14, $20, $21, $22, $23, $24, $FF
    db   $55, $5A, $5A, $5A, $56, $57, $59, $59
    db   $59, $58, $5B, $E2, $5B, $E2, $5B

JumpTable_3425_00:
    push bc
    call toc_01_33FC
    ld   bc, $3406
    ld   de, $3416
    jp   toc_01_33A7

    db   $00, $01, $02, $10, $11, $12, $20, $21
    db   $22, $FF, $55, $5A, $56, $57, $59, $58
    db   $5B, $E2, $5B

JumpTable_3445_00:
    push bc
    call toc_01_33FC
    ld   bc, $3432
    ld   de, $343C
    jp   toc_01_33A7

    db   $00, $01, $02, $10, $11, $12, $FF, $A4
    db   $A5, $A6, $A7, $E3, $A8

JumpTable_345F_00:
    push bc
    call toc_01_33FC
    ld   bc, $3452
    ld   de, $3459
    jp   toc_01_33A7

    db   $00, $01, $10, $11, $FF, $BB, $BC, $BD
    db   $BE, $09, $09, $09, $09

JumpTable_3479_00:
    push bc
    call toc_01_33FC
    ld   bc, $346C
    ld   de, $3471
    ld   a, [$FFF8]
    and  %00000100
    jr   z, .else_01_348C

    ld   de, $3475
JumpTable_3479_00.else_01_348C:
    jp   toc_01_33A7

    db   $00, $01, $10, $11, $FF, $B6, $B7, $CD
    db   $CE

JumpTable_3498_00:
    push bc
    call toc_01_33FC
    ld   bc, $348F
    ld   de, $3494
    jp   toc_01_33A7

    db   $00, $01, $02, $10, $11, $12, $1F, $20
    db   $21, $22, $23, $30, $31, $32, $FF, $2B
    db   $2C, $2D, $37, $E8, $38, $0A, $33, $2F
    db   $34, $0A, $0A, $0A, $0A

JumpTable_34C2_00:
    push bc
    call toc_01_33FC
    ld   bc, $34A5
    ld   de, $34B4
    jp   toc_01_33A7

    db   $00, $01, $02, $10, $11, $12, $FF, $52
    db   $52, $52, $5B, $E2, $5B

JumpTable_34DC_00:
    push bc
    call toc_01_33FC
    ld   bc, $34CF
    ld   de, $34D6
    jp   toc_01_33A7

    db   $2D, $2E

JumpTable_34EB_00:
    ld   e, $00
    call toc_01_3627
    ld   a, [$FFF8]
    and  %00000100
    jp   nz, JumpTable_35A3_00

    push bc
    call toc_01_33FC
    ld   bc, $36C9
    ld   de, $34E9
    jp   toc_01_33A7

    db   $2F, $30

JumpTable_3506_00:
    ld   e, $01
    call toc_01_3627
    ld   a, [$FFF8]
    and  %00001000
    jp   nz, JumpTable_35D2_00

    push bc
    call toc_01_33FC
    ld   bc, $36C9
    ld   de, $3504
    jp   toc_01_33A7

    db   $31, $32

JumpTable_3521_00:
    ld   e, $02
    call toc_01_3627
    ld   a, [$FFF8]
    and  %00000010
    jp   nz, JumpTable_35E6_00

    push bc
    call toc_01_33FC
    ld   bc, $36CC
    ld   de, $351F
    jp   toc_01_33A7

    db   $33, $34

JumpTable_353C_00:
    ld   e, $03
    call toc_01_3627
    ld   a, [$FFF8]
    and  %00000001
    jp   nz, JumpTable_35FA_00

    push bc
    call toc_01_33FC
    ld   bc, $36CC
    ld   de, $353A
    jp   toc_01_33A7

JumpTable_3555_00:
    ld   e, $04
    call toc_01_3627
    ld   a, [$C18A]
    or   %00000001
    ld   [$C18A], a
    ld   [$C18B], a
    jp   JumpTable_35A3_00

JumpTable_3568_00:
    ld   e, $05
    call toc_01_3627
    ld   a, [$C18A]
    or   %00000010
    ld   [$C18A], a
    ld   [$C18B], a
    jp   JumpTable_35D2_00

JumpTable_357B_00:
    ld   e, $06
    call toc_01_3627
    ld   a, [$C18A]
    or   %00000100
    ld   [$C18A], a
    ld   [$C18B], a
    jp   JumpTable_35E6_00

JumpTable_358E_00:
    ld   e, $07
    call toc_01_3627
    ld   a, [$C18A]
    or   %00001000
    ld   [$C18A], a
    ld   [$C18B], a
    jp   JumpTable_35FA_00

    db   $43, $44

JumpTable_35A3_00:
    ld   a, $04
    call toc_01_35B5
    push bc
    call toc_01_33FC
    ld   bc, $36C9
    ld   de, $35A1
    jp   toc_01_33A7

toc_01_35B5:
    push af
    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    ifGte [$FFF7], $1A, .else_01_35C6

    cp   $06
    jr   c, .else_01_35C6

    inc  d
toc_01_35B5.else_01_35C6:
    ld   hl, $D900
    add  hl, de
    pop  af
    or   [hl]
    ld   [hl], a
    ld   [$FFF8], a
    ret


    db   $8C, $08

JumpTable_35D2_00:
    ld   a, $08
    call toc_01_35B5
    push bc
    call toc_01_33FC
    ld   bc, $36C9
    ld   de, $35D0
    jp   toc_01_33A7

    db   $09, $0A

JumpTable_35E6_00:
    ld   a, $02
    call toc_01_35B5
    push bc
    call toc_01_33FC
    ld   bc, $36CC
    ld   de, $35E4
    jp   toc_01_33A7

    db   $0B, $0C

JumpTable_35FA_00:
    ld   a, $01
    call toc_01_35B5
    push bc
    call toc_01_33FC
    ld   bc, $36CC
    ld   de, $35F8
JumpTable_35FA_00.toc_01_3609:
    jp   toc_01_33A7

    db   $A4, $A5

JumpTable_360E_00:
    ld   e, $08
    call toc_01_3627
    ld   a, [$FFF8]
    and  %00000100
    jp   nz, JumpTable_35A3_00

    push bc
    call toc_01_33FC
    ld   bc, $36C9
    ld   de, $360C
    jp   toc_01_33A7

toc_01_3627:
    ld   d, $00
    ld   hl, $C1F0
    add  hl, de
    dec  bc
    ld   a, [bc]
    ld   [hl], a
    push af
    and  %11110000
    ld   hl, $C1E0
    add  hl, de
    ld   [hl], a
    pop  af
    swap a
    and  %11110000
    ld   hl, $C1D0
    add  hl, de
    ld   [hl], a
    inc  bc
    ret


    db   $AF, $B0

JumpTable_3646_00:
    push bc
    call toc_01_33FC
    ld   bc, $36CC
    ld   de, $3644
    jp   toc_01_33A7

    db   $B1, $B2

JumpTable_3655_00:
    push bc
    call toc_01_33FC
    ld   bc, $36C9
    ld   de, $3653
    jp   toc_01_33A7

    db   $45, $46

JumpTable_3664_00:
    push bc
    call toc_01_33FC
    ld   bc, $36C9
    ld   de, $3662
    jp   toc_01_33A7

    db   $00, $01, $02, $03, $10, $11, $12, $13
    db   $20, $21, $22, $23, $FF, $B3, $B4, $B4
    db   $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC
    db   $BD

JumpTable_368A_00:
    ld   a, $08
    call toc_01_35B5
    push bc
    call toc_01_33FC
    ld   bc, $3671
    ld   de, $367E
    jp   toc_01_33A7

    db   $C1, $C2

JumpTable_369E_00:
    ifGte [$FFF7], $1A, .else_01_36B7

    cp   $06
    jr   c, .else_01_36B7

    ifNe [$FFF6], $D3, .else_01_36B7

    ifNot [$DB46], .else_01_36B7

    jp   JumpTable_3568_00

JumpTable_369E_00.else_01_36B7:
    ld   a, $01
    call toc_01_35B5
    push bc
    call toc_01_33FC
    ld   bc, $36C9
    ld   de, $369C
    jp   toc_01_33A7

    db   $00, $01, $FF, $00, $10, $FF

toc_01_36CF:
    ld   [$FFE9], a
    ld   d, $80
    ld   hl, $D711
    ld   e, a
toc_01_36CF.loop_01_36D7:
    ld   a, l
    and  %00001111
    jr   z, .else_01_36E1

    cp   $0B
    jr   nc, .else_01_36E1

    ld   [hl], e
toc_01_36CF.else_01_36E1:
    inc  hl
    dec  d
    jr   nz, .loop_01_36D7

    ret


toc_01_36E6:
    changebank $01
    call toc_01_5C61
    changebank $16
    clear [$FFE4]
    ld   a, [$FFF6]
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    ld   hl, $4000
    ifNot [$DBA5], .else_01_3747

    ifNe [$FFF7], $06, .else_01_3738

    ld   a, [$DB6F]
    ld   hl, $FFF6
    cp   [hl]
    jr   nz, .else_01_3738

    ld   a, $A8
    call toc_01_3C01
    ld   a, [$DB70]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$DB71]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    call toc_01_3762.toc_01_37B3
    ld   hl, $C460
    add  hl, de
    ld   [hl], $FF
    clear [$FFE4]
toc_01_36E6.else_01_3738:
    ld   hl, $4200
    ifGte [$FFF7], $1A, .else_01_3747

    cp   $06
    jr   c, .else_01_3747

    inc  h
    inc  h
toc_01_36E6.else_01_3747:
    add  hl, bc
    ldi  a, [hl]
    ld   c, a
    ld   a, [hl]
    ld   b, a
toc_01_36E6.toc_01_374C:
    ld   a, [bc]
    cp   $FF
    jr   z, .else_01_3756

    call toc_01_3762
    jr   .toc_01_374C

toc_01_36E6.else_01_3756:
    call toc_01_07C0
    ret


    db   $01, $02, $04, $08, $10, $20, $40, $80

toc_01_3762:
    ifGte [$FFE4], $08, .else_01_377A

    ld   e, a
    ld   d, $00
    ld   hl, $375A
    add  hl, de
    ld   a, [$FFF6]
    ld   e, a
    ld   a, [hl]
    ld   hl, $CF00
    add  hl, de
    and  [hl]
    jr   nz, .else_01_378C

toc_01_3762.else_01_377A:
    ld   e, $00
    ld   d, e
toc_01_3762.loop_01_377D:
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    cp   $00
    jr   z, .else_01_3793

    inc  e
    ld   a, e
    cp   $10
    jr   nz, .loop_01_377D

toc_01_3762.else_01_378C:
    incAddr $FFE4
    inc  bc
    inc  bc
    ret


toc_01_3762.else_01_3793:
    ld   [hl], $04
    ld   a, [bc]
    and  %11110000
    ld   hl, $C210
    add  hl, de
    add  a, $10
    ld   [hl], a
    ld   a, [bc]
    inc  bc
    swap a
    and  %11110000
    ld   hl, $C200
    add  hl, de
    add  a, $08
    ld   [hl], a
    ld   hl, $C3A0
    add  hl, de
    ld   a, [bc]
    inc  bc
    ld   [hl], a
toc_01_3762.toc_01_37B3:
    changebank $03
    call toc_03_6552
    changebank $01
    call toc_01_5C0A
    changebank $16
    ret


toc_01_37C9:
    ld   e, a
    changebank $14
    ld   a, e
    push bc
    call toc_14_5000
    pop  bc
    copyFromTo [$FFE8], [$2100]
    ret


JumpTable_37DB_00:
    changebank $01
    call toc_01_7EE8
    ret


    db   $FF, $FF

toc_01_37E6:
    changebank $14
    ld   hl, $56FF
    add  hl, de
    ld   a, [hl]
    ld   hl, $2100
    ld   [hl], $05
    ret


    db   $3E, $19, $CD, $B9, $07, $CD, $C2, $77
    db   $3E, $03, $C3, $B9, $07

toc_01_3803:
    changebank $03
    call toc_03_5441
    jp   toc_01_07C0

toc_01_380E:
    changebank $14
    call toc_14_5964
    jp   toc_01_07C0

toc_01_3819:
    call_changebank $01
    call toc_01_5D6B
    ld   a, $02
    jp   toc_01_07B9

    db   $3E, $03

JumpTable_3828_00:
    ld   [$2100], a
    call toc_01_48B0
    jp   toc_01_07C0

toc_01_3831:
    changebank $14
    call toc_14_5822
    changebank $03
    ret


    db   $00, $08, $10, $18

toc_01_3843:
    ld   hl, $C5A7
    ld   a, [hl]
    and  a
    jr   z, .else_01_3851

    dec  [hl]
    jr   nz, .else_01_3851

    assign [$FFF3], $10
toc_01_3843.else_01_3851:
    ld   a, [wDialogState]
    and  a
    jr   nz, .else_01_3864

    copyFromTo [$C111], [$C1A8]
    and  a
    jr   z, .else_01_3864

    dec  a
    ld   [$C111], a
toc_01_3843.else_01_3864:
    ld   a, [$C11C]
    cp   $07
    ret  z

    clear [$C3C1]
    ld   a, [$FFF7]
    cp   $0A
    ld   a, [hFrameCounter]
    jr   c, .else_01_3877

    xor  a
toc_01_3843.else_01_3877:
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $383F
    add  hl, de
    ld   a, [hl]
    ld   [$C3C0], a
    copyFromTo [$C5A0], [$C5A1]
    clear [$C5A0]
    ld   [$C10C], a
    ld   [hLinkWalksSlow], a
    ld   [$C117], a
    ld   [$C19D], a
    ld   [$C147], a
    ld   [$C5A8], a
    ld   [$D45E], a
    ld   a, [wDialogState]
    and  a
    jr   nz, .else_01_38AB

    ld   [$C1AD], a
toc_01_3843.else_01_38AB:
    call_changebank $02
    call toc_02_63E6
    ld   b, $00
    ld   c, $0F
toc_01_3843.loop_01_38B7:
    ld   a, c
    ld   [$C123], a
    ld   hl, $C280
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_01_38C8

    ld   [$FFEA], a
    call toc_01_38DD
toc_01_3843.else_01_38C8:
    dec  c
    ld   a, c
    cp   $FF
    jr   nz, .loop_01_38B7

toc_01_3843.JumpTable_38CE_00:
    ret


toc_01_38CF:
    changebank $15
    call toc_15_4000
    changebank $03
    ret


toc_01_38DD:
    ld   hl, $C3A0
    add  hl, bc
    ld   a, [hl]
    ld   [$FFEB], a
    ld   hl, $C290
    add  hl, bc
    ld   a, [hl]
    ld   [$FFF0], a
    ld   hl, $C3B0
    add  hl, bc
    ld   a, [hl]
    ld   [$FFF1], a
    call_changebank $19
    ifNe [$FFEB], $6A, .else_01_3902

    ld   a, [hLinkWalksSlow]
    and  a
    jr   nz, .else_01_3908

toc_01_38DD.else_01_3902:
    ifNe [$FFEA], $07, .else_01_3910

toc_01_38DD.else_01_3908:
    call toc_19_755F
    call toc_01_3DBA
    jr   .toc_01_3916

toc_01_38DD.else_01_3910:
    call toc_01_3DBA
    call $755F
toc_01_38DD.toc_01_3916:
    call_changebank $14
    call toc_14_5388
    call_changebank $03
    ld   a, [$FFEA]
    cp   $05
    jp   z, JumpTable_3945_00

    jumptable
    dw toc_01_3843.JumpTable_38CE_00 ; 00
    dw JumpTable_557E_03 ; 01
    dw JumpTable_4D90_03 ; 02
    dw $4D26 ; 03
    dw JumpTable_490A_03 ; 04
    dw JumpTable_3945_00 ; 05
    dw JumpTable_4EBC_03 ; 06
    dw JumpTable_5792_03 ; 07
    dw JumpTable_4E49_03 ; 08

toc_01_393D:
    call JumpTable_3945_00
    ld   a, $03
    jp   toc_01_07B9

JumpTable_3945_00:
    ld   a, [$FFEB]
    ld   e, a
    ld   d, b
    ld   hl, $4000
    add  hl, de
    ld   a, [hl]
    call toc_01_07B9
    ld   a, e
    jumptable
    db   $4B, $6A, $61, $44, $BF, $66, $61, $7B
    db   $C9, $69, $97, $53, $BE, $52, $E3, $7A
    db   $30, $79, $44, $58, $3D, $6A, $82, $58
    db   $E7, $6A, $CD, $79, $6B, $7E, $47, $75
    db   $04, $5C, $FF, $5B, $04, $5C, $35, $5A
    db   $5E, $78, $7B, $79, $41, $66, $41, $66
    db   $70, $74, $3C, $67, $CE, $4A, $FC, $7C
    db   $D0, $7C, $00, $00, $AB, $4E, $5F, $7F
    db   $5D, $4F, $27, $77, $FB, $65, $B5, $7E
    db   $B4, $50, $1E, $4D, $1E, $4D, $0B, $76
    db   $65, $67, $8B, $5A, $2B, $6C, $E5, $75
    db   $BC, $76, $7F, $5D, $C0, $60, $7D, $61
    db   $D0, $5C, $DC, $5B, $CB, $5B, $B0, $5B
    db   $A0, $5B, $9C, $5A, $39, $5A, $9D, $60
    db   $EE, $5F, $DA, $5D, $92, $5D, $83, $60
    db   $29, $60, $FF, $5F, $E5, $4D, $15, $49
    db   $E1, $47, $01, $68, $68, $5E, $94, $44
    db   $3F, $44, $65, $43, $FD, $40, $C7, $41
    db   $3A, $42, $AD, $42, $00, $00, $95, $53
    db   $00, $00, $79, $76, $2B, $76, $46, $6E
    db   $B3, $7A, $71, $69, $E6, $67, $E6, $67
    db   $59, $5F, $80, $7D, $90, $7C, $E9, $5D
    db   $F7, $5E, $9D, $56, $72, $50, $C1, $49
    db   $09, $40, $41, $6C, $05, $7B, $4D, $69
    db   $CD, $67, $16, $42, $61, $62, $BB, $59
    db   $EF, $5D, $AA, $54, $24, $43, $9F, $54
    db   $58, $74, $C2, $53, $9E, $52, $8B, $5D
    db   $2E, $45, $38, $40, $B4, $6B, $94, $48
    db   $48, $62, $C3, $60, $C3, $60, $48, $62
    db   $BF, $4D, $A4, $4C, $33, $4B, $E8, $5C
    db   $BE, $5A, $4E, $5C, $5C, $5D, $FD, $5E
    db   $DE, $62, $CD, $63, $2A, $64, $C6, $72
    db   $88, $6A, $58, $6C, $D4, $6E, $66, $70
    db   $C9, $71, $39, $73, $19, $7C, $B5, $56
    db   $A1, $53, $07, $51, $49, $50, $49, $50
    db   $BF, $4E, $36, $4F, $92, $4B, $77, $47
    db   $49, $49, $47, $42, $1B, $45, $50, $41
    db   $AD, $70, $20, $40, $FD, $5A, $05, $48
    db   $03, $75, $44, $74, $14, $73, $B4, $71
    db   $5E, $71, $22, $40, $31, $70, $F1, $63
    db   $25, $65, $6D, $66, $FB, $61, $BD, $60
    db   $BD, $60, $98, $61, $54, $5F, $47, $5B
    db   $87, $5D, $7C, $59, $0A, $68, $0A, $68
    db   $7E, $68, $D5, $55, $DC, $53, $C6, $52
    db   $09, $51, $03, $4F, $1C, $75, $88, $4A
    db   $A8, $4C, $A3, $49, $0D, $48, $D3, $44
    db   $72, $42, $2B, $77, $EA, $77, $15, $40
    db   $A8, $6F, $C7, $69, $A7, $64, $62, $63
    db   $7D, $62, $76, $61, $B6, $5E, $00, $40
    db   $F7, $54, $C9, $73, $4E, $73, $1D, $45
    db   $98, $52, $FC, $50, $40, $4E, $F5, $49
    db   $BD, $44, $97, $6B, $57, $49, $13, $6E
    db   $32, $51, $80, $51, $5D, $52, $CA, $51
    db   $58, $5D, $18, $59, $17, $58, $F3, $55
    db   $E8, $56, $C1, $54, $44, $53, $E4, $52
    db   $8A, $51, $9A, $4C, $1C, $4A, $27, $45
    db   $8A, $76, $AC, $78, $58, $4D, $F5, $4B
    db   $BE, $46, $19, $7C, $96, $50, $9A, $40
    db   $47, $75, $08, $05, $08, $05, $08, $0A
    db   $08, $0A, $08, $0A, $08, $0A, $08, $10
    db   $04, $0A, $08, $02, $08, $02, $08, $13
    db   $08, $13, $08, $06, $06, $08, $08, $07
    db   $06, $0A, $08, $06, $10, $30, $08, $07
    db   $04, $0A, $0C, $07, $FC, $04, $10, $10
    db   $0C, $12, $08, $08, $02, $08, $10, $0C
    db   $08, $10, $08, $07, $0C, $08, $08, $08
    db   $02, $08

toc_01_3B65:
    ld   hl, $C350
    add  hl, bc
    ld   a, [hl]
    and  %01111100
    ld   e, a
    ld   d, b
    ld   hl, $3B25
    add  hl, de
    push hl
    pop  de
    push bc
    sla  c
    sla  c
    ld   hl, $D580
    add  hl, bc
    ld   c, $04
toc_01_3B65.loop_01_3B7F:
    ld   a, [de]
    inc  de
    ldi  [hl], a
    dec  c
    jr   nz, .loop_01_3B7F

    pop  bc
    ret


toc_01_3B87:
    ld   hl, $C3B0
    add  hl, bc
    ld   [hl], a
    ret


JumpTable_3B8D_00:
    ld   hl, $C290
    add  hl, bc
    inc  [hl]
    ret


toc_01_3B93:
    changebank $02
    call toc_02_77FA.else_02_78B5
    jp   toc_01_07C0

toc_01_3B9E:
    changebank $03
    call toc_03_7892
    jp   toc_01_07C0

    db   $3E, $03, $EA, $00, $21, $CD, $AA, $7C
    db   $C3, $C0, $07

toc_01_3BB4:
    changebank $03
    call toc_03_6E3D
    jp   toc_01_07C0

toc_01_3BBF:
    changebank $03
    call toc_03_6C87
    jp   toc_01_07C0

toc_01_3BCA:
    changebank $03
    call toc_03_6BF9
    jp   toc_01_07C0

toc_01_3BD5:
    changebank $03
    call toc_03_6C87.toc_03_6C93
    jp   toc_01_07C0

    db   $3E, $03, $EA, $00, $21, $CD, $EF, $73
    db   $C3, $C0, $07

toc_01_3BEB:
    changebank $03
    call toc_03_6E3D.toc_03_6E40
    jp   toc_01_07C0

toc_01_3BF6:
    changebank $03
    call toc_03_75A6
    jp   toc_01_07C0

toc_01_3C01:
    push af
    changebank $03
    pop  af
    call toc_03_64F8
    rr   l
    call toc_01_07C0
    rl   l
    ret


toc_01_3C13:
    push af
    changebank $03
    pop  af
    call toc_03_64F8.toc_03_64FA
    rr   l
    call toc_01_07C0
    rl   l
    ret


toc_01_3C25:
    ld   hl, $2100
    ld   [hl], $03
    call toc_03_7E99
    jp   toc_01_07C0

toc_01_3C30:
    ld   hl, $2100
    ld   [hl], $03
    call toc_03_7E17
    jp   toc_01_07C0

toc_01_3C3B:
    ld   a, [$FFF1]
    inc  a
    ret  z

    call toc_01_3D87
    push de
    ld   a, [$C3C0]
    ld   e, a
    ld   d, b
    ld   hl, $C030
    add  hl, de
    push hl
    pop  de
    ld   a, [$FFEC]
    ld   [de], a
    inc  de
    ld   a, [$C155]
    ld   c, a
    ld   a, [$FFED]
    and  %00100000
    rra
    rra
    ld   hl, $FFEE
    add  a, [hl]
    sub  a, c
    ld   [de], a
    inc  de
    ld   a, [$FFF1]
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    sla  c
    rl   b
    pop  hl
    add  hl, bc
    ld   a, [$FFF5]
    ld   c, a
    ldi  a, [hl]
    add  a, c
    ld   [de], a
    and  %00001111
    cp   $0F
    jr   nz, .else_01_3C83

    dec  de
    ld   a, $F0
    ld   [de], a
    inc  de
toc_01_3C3B.else_01_3C83:
    inc  de
    ldi  a, [hl]
    push hl
    ld   hl, $FFED
    xor  [hl]
    ld   [de], a
    inc  de
    ld   a, [$FFEC]
    ld   [de], a
    inc  de
    ld   a, [$C155]
    ld   c, a
    ld   a, [$FFED]
    and  %00100000
    xor  %00100000
    rra
    rra
    ld   hl, $FFEE
    sub  a, c
    add  a, [hl]
    ld   [de], a
    inc  de
    pop  hl
    ld   a, [$FFF5]
    ld   c, a
    ldi  a, [hl]
    add  a, c
    ld   [de], a
    and  %00001111
    cp   $0F
    jr   nz, .else_01_3CB5

    dec  de
    ld   a, $F0
    ld   [de], a
    inc  de
toc_01_3C3B.else_01_3CB5:
    inc  de
    ld   a, [hl]
    ld   hl, $FFED
    xor  [hl]
    ld   [de], a
toc_01_3C3B.toc_01_3CBC:
    ld   a, [$C123]
    ld   c, a
    ld   b, $00
    changebank $15
    call toc_15_796D
    call toc_15_79A5
    jp   toc_01_07C0

toc_01_3CD0:
    ld   a, [$FFF1]
    inc  a
    ret  z

    call toc_01_3D87
    push de
    ld   a, [$C3C0]
    ld   l, a
    ld   h, $00
    ld   bc, $C030
    add  hl, bc
    push hl
    pop  de
    ld   a, [$C123]
    ld   c, a
    ld   b, $00
    ld   a, [$FFF9]
    and  a
    ld   a, [$FFEC]
    jr   z, .else_01_3CF5

    sub  a, $04
    ld   [$FFEC], a
toc_01_3CD0.else_01_3CF5:
    ld   [de], a
    inc  de
    ld   a, [$C155]
    ld   h, a
    ld   a, [$FFEE]
    add  a, $04
    sub  a, h
    ld   [de], a
    inc  de
    ld   a, [$FFF1]
    ld   c, a
    ld   b, $00
    sla  c
    rl   b
    pop  hl
    add  hl, bc
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ldi  a, [hl]
    ld   hl, $FFED
    xor  [hl]
    ld   [de], a
    inc  de
    jr   toc_01_3C3B.toc_01_3CBC

    db   $3E, $15, $EA, $00, $21, $18, $AA, $E5
    db   $21, $00, $C0, $18, $10

toc_01_3D26:
    ld   a, [$FFF1]
    inc  a
    jr   z, .else_01_3D82

    push hl
    ld   a, [$C3C0]
    ld   e, a
    ld   d, $00
    ld   hl, $C030
    add  hl, de
    push hl
    pop  de
    pop  hl
    ld   a, c
    ld   [$FFD7], a
    ld   a, [$C123]
    ld   c, a
    call toc_01_3D87
    ld   a, [$FFD7]
    ld   c, a
toc_01_3D26.loop_01_3D46:
    ld   a, [$FFEC]
    add  a, [hl]
    ld   [de], a
    inc  hl
    inc  de
    push bc
    ld   a, [$C155]
    ld   c, a
    ld   a, [$FFEE]
    add  a, [hl]
    sub  a, c
    ld   [de], a
    inc  hl
    inc  de
    ld   a, [$FFF5]
    ld   c, a
    ldi  a, [hl]
    push af
    add  a, c
    ld   [de], a
    pop  af
    cp   $FF
    jr   nz, .else_01_3D68

    dec  de
    xor  a
    ld   [de], a
    inc  de
toc_01_3D26.else_01_3D68:
    pop  bc
    inc  de
    ld   a, [$FFED]
    xor  [hl]
    inc  hl
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop_01_3D46

    ld   a, [$C123]
    ld   c, a
    changebank $15
    call toc_15_796D
    jp   toc_01_07C0

toc_01_3D26.else_01_3D82:
    ld   a, [$C123]
    ld   c, a
    ret


toc_01_3D87:
    push hl
    ifNot [$C124], .else_01_3DAD

    ld   a, [$FFEE]
    dec  a
    cp   $C0
    jr   nc, .else_01_3DAC

    ld   a, [$FFEC]
    dec  a
    cp   $88
    jr   nc, .else_01_3DAC

    ld   hl, $C220
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_01_3DAC

    ld   hl, $C230
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_01_3DAD

toc_01_3D87.else_01_3DAC:
    pop  af
toc_01_3D87.else_01_3DAD:
    pop  hl
    ret


toc_01_3DAF:
    ld   hl, $C240
    add  hl, bc
    ld   [hl], b
    ld   hl, $C250
    add  hl, bc
    ld   [hl], b
    ret


toc_01_3DBA:
    ld   hl, $C200
    add  hl, bc
    ld   a, [hl]
    ld   [$FFEE], a
    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    ld   [$FFEF], a
    ld   hl, $C310
    add  hl, bc
    sub  a, [hl]
    ld   [$FFEC], a
    ret


toc_01_3DD0:
    ld   hl, $2100
    ld   [hl], $15
    call toc_15_796D.toc_15_7974
    jp   toc_01_07C0

JumpTable_3DDB_00:
    ld   hl, $2100
    ld   [hl], $04
    call toc_04_5A10
    jp   toc_01_07C0

JumpTable_3DE6_00:
    ld   hl, $2100
    ld   [hl], $04
    call toc_04_5680
    jp   toc_01_07C0

JumpTable_3DF1_00:
    ld   hl, $2100
    ld   [hl], $04
    call toc_04_504D
    jp   toc_01_07C0

JumpTable_3DFC_00:
    ld   hl, $2100
    ld   [hl], $04
    call toc_04_49B5
    jp   toc_01_07C0

JumpTable_3E07_00:
    ld   hl, $2100
    ld   [hl], $04
    call toc_04_4000
    jp   toc_01_07C0

JumpTable_3E12_00:
    ld   hl, $2100
    ld   [hl], $05
    call toc_05_6C2B
    jp   toc_01_07C0

JumpTable_3E1D_00:
    ld   hl, $2100
    ld   [hl], $05
    call toc_05_6776
    jp   toc_01_07C0

JumpTable_3E28_00:
    ld   hl, $2100
    ld   [hl], $05
    call toc_05_624F
    jp   toc_01_07C0

JumpTable_3E33_00:
    ld   hl, $2100
    ld   [hl], $05
    call toc_05_5959
    jp   toc_01_07C0

JumpTable_3E3E_00:
    ld   hl, $2100
    ld   [hl], $05
    call toc_05_549F
    jp   toc_01_07C0

toc_01_3E49:
    ld   a, [wCurrentBank]
    push af
    call_changebank $02
    call toc_02_6FB1
    pop  af
    jp   toc_01_07B9

    db   $21, $00, $21, $36, $04, $CD, $5A, $5C
    db   $C3, $C0, $07

toc_01_3E64:
    ld   hl, $2100
    ld   [hl], $03
    call toc_03_5464
    jp   toc_01_07C0

toc_01_3E6F:
    ld   hl, $2100
    ld   [hl], $02
    call toc_02_5FD1
    call toc_02_6117
    jp   toc_01_07C0

toc_01_3E7D:
    call_changebank $02
    call toc_02_41BA
    ld   a, $03
    jp   toc_01_07B9

toc_01_3E8A:
    ld   hl, $2100
    ld   [hl], $02
    call toc_02_61E7
    jp   toc_01_07C0

toc_01_3E95:
    ld   hl, $2100
    ld   [hl], $03
    call JumpTable_6472_03.toc_03_6497
    jp   toc_01_07C0

toc_01_3EA0:
    call_changebank $06
    call toc_06_7940
    ld   a, $03
    jp   toc_01_07B9

toc_01_3EAD:
    ld   e, $10
    ld   hl, $C280
toc_01_3EAD.loop_01_3EB2:
    xor  a
    ldi  [hl], a
    dec  e
    jr   nz, .loop_01_3EB2

    ret


toc_01_3EB8:
    ld   hl, $C4A0
    add  hl, bc
    ld   a, [hl]
    and  a
    ret  z

    ld   a, [hFrameCounter]
    xor  c
    and  %00000011
    ret  nz

    copyFromTo [$FFEE], [$FFD7]
    copyFromTo [$FFEC], [$FFD8]
    ld   a, $08
    call toc_01_0953
    ld   hl, $C520
    add  hl, de
    ld   [hl], $0F
    ret


toc_01_3ED9:
    ld   hl, $C3F0
    add  hl, bc
    ld   a, [hl]
    bit  7, a
    jr   z, .else_01_3EE4

    cpl
    inc  a
toc_01_3ED9.else_01_3EE4:
    ld   [$FFD7], a
    ld   hl, $C400
    add  hl, bc
    ld   a, [hl]
    bit  7, a
    jr   z, .else_01_3EF1

    cpl
    inc  a
toc_01_3ED9.else_01_3EF1:
    ld   e, $03
    ld   hl, $FFD7
    cp   [hl]
    jr   c, .else_01_3EFB

    ld   e, $0C
toc_01_3ED9.else_01_3EFB:
    ld   a, e
    ld   hl, $C2A0
    add  hl, bc
    and  [hl]
    jr   z, .return_01_3F08

    ld   hl, $C410
    add  hl, bc
    ld   [hl], b
toc_01_3ED9.return_01_3F08:
    ret


    db   $B0, $B4, $B1, $B2, $B3, $B6, $BA, $BC
    db   $B8

toc_01_3F12:
    ld   hl, $C14F
    ld   a, [$C124]
    or   [hl]
    ret  nz

    ifNot [$C165], .else_01_3F25

    dec  a
    ld   [$C165], a
    ret


toc_01_3F12.else_01_3F25:
    ld   a, [$C1BD]
    and  a
    ret  nz

    inc  a
    ld   [$C1BD], a
    ld   hl, $C430
    add  hl, bc
    ld   a, [hl]
    and  %00000100
    ld   a, $19
    jr   z, .else_01_3F3B

    ld   a, $50
toc_01_3F12.else_01_3F3B:
    ld   [$D368], a
    ld   [$FFBD], a
    ld   a, [$C16B]
    cp   $04
    ret  nz

    ifNe [$FFEB], $87, .else_01_3F50

    ld   a, $DA
    jr   .toc_01_3F6E

toc_01_3F12.else_01_3F50:
    cp   $BC
    jr   nz, .else_01_3F58

    ld   a, $26
    jr   .toc_01_3F6E

toc_01_3F12.else_01_3F58:
    ld   hl, $C430
    add  hl, bc
    ld   a, [hl]
    and  %00000100
    jr   nz, .return_01_3F71

    ifEq [$FFF7], $05, .return_01_3F71

    ld   e, a
    ld   d, b
    ld   hl, $3F09
    add  hl, de
    ld   a, [hl]
toc_01_3F12.toc_01_3F6E:
    call toc_01_2197
toc_01_3F12.return_01_3F71:
    ret


    db   $01, $02, $04, $08, $10, $20, $40, $80

toc_01_3F7A:
    assign [$C113], $03
    ld   [$2100], a
    call $562F
    call toc_01_07C0
    ld   hl, $C460
    add  hl, bc
    ld   a, [hl]
    cp   $FF
    jr   z, .else_01_3FB7

    push af
    ld   a, [$DBB5]
    ld   e, a
    ld   d, b
    inc  a
    ld   [$DBB5], a
    ld   a, [hl]
    ld   hl, $DBB6
    add  hl, de
    ld   [hl], a
    pop  af
toc_01_3F7A.toc_01_3FA2:
    cp   $08
    jr   nc, .else_01_3FB7

    ld   e, a
    ld   d, b
    ld   hl, $3F72
    add  hl, de
    ld   a, [$FFF6]
    ld   e, a
    ld   d, b
    ld   a, [hl]
    ld   hl, $CF00
    add  hl, de
    or   [hl]
    ld   [hl], a
toc_01_3F7A.else_01_3FB7:
    ld   hl, $C280
    add  hl, bc
    ld   [hl], b
    ret


toc_01_3FBD:
    changebank $05
    ld   hl, $5919
    ld   de, $8460
    ld   bc, $0010
    call copyHLToDE
    ld   hl, $5929
    jr   toc_01_3FD3.toc_01_3FE7

toc_01_3FD3:
    changebank $05
    ld   hl, $5939
    ld   de, $8460
    ld   bc, $0010
    call copyHLToDE
    ld   hl, $5949
toc_01_3FD3.toc_01_3FE7:
    ld   de, $8480
    ld   bc, $0010
    call copyHLToDE
    clear [$FFA5]
    changebank $0C
    jp   JumpTable_1C5A_00.else_01_1CCC

    db   $FF, $FF, $FF, $FF, $FF
