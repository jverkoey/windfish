SECTION "ROM Bank 00", ROM0[$00]

RST_0000:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

RST_0008:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

RST_0010:
    ld   b, b
    nop
    nop
    nop
    nop
    nop
    nop
    nop

RST_0018:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

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
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

VBlankInterrupt:
    push af
    push hl
    push bc
    push de
    jp   vblankHandler

    db   $00

LCDCInterrupt:
    jp   $DA13

    db   $00, $00, $00, $00, $00

TimerOverflowInterrupt:
    push af
    push hl
    push bc
    push de
    jp   toc_01_0333

    db   $00

SerialTransferCompleteInterrupt:
    reti


    db   $00, $00, $00, $00, $00, $00, $00

JoypadTransitionInterrupt:
    reti


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $EF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $FF
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
    db   "KIRBY2", $00, $00, $00, $00, $00, $00, $00, $00, $00

HeaderIsColorGB:
    db   not_color_gameboy

HeaderNewLicenseeCode:
    db   $30, $31

HeaderSGBFlag:
    db   $03

HeaderCartridgeType:
    db   cartridge_mbc1_ram_battery

HeaderROMSize:
    db   romsize_32banks

HeaderRAMSize:
    db   ramsize_1bank_

HeaderDestinationCode:
    db   destination_nonjapanese

HeaderOldLicenseeCode:
    db   $33

HeaderMaskROMVersion:
    db   $00

HeaderComplementCheck:
    db   $93

HeaderGlobalChecksum:
    db   $DC, $99

main:
    di
    changebank $1A
    jp   initialize

vblankHandler:
    __ifNotZero [$FFB5], .else_01_016F

.waitForVBlank:
    ifEq [gbLY], 145, .waitForVBlank

    ld   hl, gbLCDC
    res  7, [hl]
    clear [$FFB5]
    jp   toc_00_022B.toc_01_029F

.else_01_016F:
    _ifGte [wQueuedDMATransfer], 1, .else_01_0193

.passC0ToDMATransfer:
    ld   a, $C0
    jr   z, .startDMATransfer

    inc  a
.startDMATransfer:
    ld   [$FF89], a
    call $FF88
    ld   a, [wQueuedDMATransfer]
    dec  a
    ld   hl, wScrollPosition1
    jr   z, .loadScrollPosition

    ld   hl, wScrollPosition2
.loadScrollPosition:
    ldi  a, [hl]
    ld   [gbSCY], a
    ld   a, [hl]
    ld   [gbSCX], a
.else_01_0193:
    ld   hl, $CD00
    ld   c, $47
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    ld   a, [hl]
    ld   [$ff00+c], a
    ld   a, [$DA27]
    or   a
    jp   z, .else_01_0210

    ld   [$DA25], sp
    ld   de, $001F
    bit  2, a
    jr   z, .else_01_01DD

    bit  0, a
    jr   z, .else_01_01C8

    ld   a, [$DA23]
    ld   sp, $C200
.loop_01_01BB:
    pop  hl
    pop  bc
    ld   [hl], c
    inc  l
    ld   [hl], b
    add  hl, de
    pop  bc
    ld   [hl], c
    inc  l
    ld   [hl], b
    dec  a
    jr   nz, .loop_01_01BB

.else_01_01C8:
    ld   a, [$DA24]
    ld   sp, $C300
.loop_01_01CE:
    pop  hl
    pop  bc
    ld   [hl], c
    inc  l
    ld   [hl], b
    add  hl, de
    pop  bc
    ld   [hl], c
    inc  l
    ld   [hl], b
    dec  a
    jr   nz, .loop_01_01CE

    jr   .toc_01_0207

.else_01_01DD:
    bit  1, a
    jr   z, .else_01_01F4

    ld   a, [$DA24]
    ld   sp, $C300
.loop_01_01E7:
    pop  hl
    pop  bc
    ld   [hl], c
    inc  l
    ld   [hl], b
    add  hl, de
    pop  bc
    ld   [hl], c
    inc  l
    ld   [hl], b
    dec  a
    jr   nz, .loop_01_01E7

.else_01_01F4:
    ld   a, [$DA23]
    ld   sp, $C200
.loop_01_01FA:
    pop  hl
    pop  bc
    ld   [hl], c
    inc  l
    ld   [hl], b
    add  hl, de
    pop  bc
    ld   [hl], c
    inc  l
    ld   [hl], b
    dec  a
    jr   nz, .loop_01_01FA

.toc_01_0207:
    ld   sp, $DA25
    pop  hl
    ld   sp, hl
    clear [$DA27]
.else_01_0210:
    clear [gbLYC]
    ld   hl, $DA14
    ld   a, $A4
    ldi  [hl], a
    ld   [hl], $02
    ld   [$DA18], sp
    ld   sp, $DA1A
    pop  de
    pop  hl
    ld   c, h
    ld   h, $C4
    ld   a, [$FF92]
    ld   b, a
    pop  af
    reti


toc_00_022B:
    ld   a, l
    cp   b
    jr   z, .else_01_023E

.toc_01_022F:
    ld   e, [hl]
    inc  l
    ld   d, [hl]
    inc  l
    ld   c, [hl]
    inc  l
.loop_01_0235:
    ld   a, [hl]
    ld   [de], a
    inc  l
    inc  de
    dec  c
    jr   nz, .loop_01_0235

    jr   toc_00_022B

.else_01_023E:
    di
    cp   b
    jr   z, .else_01_0245

    ei
    jr   .toc_01_022F

.else_01_0245:
    ld   h, c
    ld   bc, $022B
    push bc
    push af
    push hl
    push de
    ld   sp, $DA18
    pop  hl
    ld   sp, hl
    copyFromTo [wDesiredLYC], [gbLYC]
    ld   hl, $DA14
    ld   a, [$DA16]
    ldi  [hl], a
    ld   a, [$DA17]
    ld   [hl], a
    ld   hl, gbLCDC
    __ifNotZero [$DA2B], .else_01_026F

    res  1, [hl]
    jr   .toc_01_0271

.else_01_026F:
    set  1, [hl]
.toc_01_0271:
    mask [gbIF], %11111101
    mask [gbIE], IE_LCDC | IE_PIN1013TRANSITION | IE_SERIALIO | IE_TIMEROVERFLOW | %11100000
    ei
    call $DA10
    clear [wQueuedDMATransfer]
    assign [$DA0C], $01
.toc_01_028A:
    ld   a, [hLastBank]
    push af
    _changebank $00
    call toc_01_2BFD
    pop  af
    call changeBankAndCall.loadBank
    ld   a, [gbIE]
    or   IE_VBLANK
    ld   [gbIE], a
.toc_01_029F:
    pop  de
    pop  bc
    pop  hl
    pop  af
    reti


    db   $61, $F5, $E5, $D5, $18, $A3, $F5, $E5
    db   $C5, $D5, $21, $40, $FF, $CB, $6E, $28
    db   $EA, $06, $0F, $00, $05, $20, $FC, $CB
    db   $8E, $3E, $E4, $E0, $47, $C3, $9F, $02
    db   $F5, $E5, $C5, $D5, $21, $40, $FF, $7E
    db   $CB, $DF, $CB, $8F, $06, $0C, $00, $05
    db   $20, $FC, $77, $AF, $21, $42, $FF, $22
    db   $77, $C3, $9F, $02, $F5, $E5, $C5, $D5
    db   $21, $40, $FF, $7E, $CB, $9F, $CB, $CF
    db   $06, $0C, $00, $05, $20, $FC, $77, $21
    db   $2E, $DA, $2A, $E0, $42, $7E, $E0, $43
    db   $21, $14, $DA, $3E, $C4, $22, $36, $02
    db   $FA, $2A, $DA, $E0, $45, $C3, $9F, $02

toc_00_030C:
    push af
    push hl
    push bc
    push de
    ld   a, [$DA2D]
    ld   hl, gbSCX
    ld   b, $0F
.wait:
    nop
    dec  b
    jr   nz, .wait

    ld   [hl], a
    jp   toc_00_022B.toc_01_029F

    db   $F5, $E5, $C5, $D5, $3E, $00, $21, $43
    db   $FF, $06, $0F, $00, $05, $20, $FC, $77
    db   $C3, $9F, $02

toc_01_0333:
    assign [$DA0D], $01
    ld   a, [gbLCDC]
    bit  7, a
    jp   z, toc_00_022B.toc_01_028A

    jp   toc_00_022B.toc_01_029F

LCDInterruptTrampolineReturn:
    ret


toc_01_0343:
    ld   hl, $DA0C
.toc_01_0346:
    di
    bit  0, [hl]
    jr   nz, .else_01_034F

    halt
    ei
    jr   .toc_01_0346

.else_01_034F:
    ei
    ld   [hl], $00
    incAddr $DA0E
    ret


toc_01_0357:
    copyFromTo [$DA3E], [$FF84]
    ld   a, [$DEED]
    or   a
    jr   nz, .else_01_0369

    ld   b, $01
    ld   hl, $DA3E
    jr   .toc_01_0386

.else_01_0369:
    ld   a, [$DA38]
    or   a
    ret  nz

    ld   b, $02
    ld   a, [gbP1]
    ld   c, a
    jr   .toc_01_037A

.loop_01_0375:
    ld   a, [gbP1]
    cp   c
    jr   z, .else_01_03B2

.toc_01_037A:
    cpl
    and  %00000011
    add  a, a
    add  a, a
    ld   e, a
    ld   d, $00
    ld   hl, $DA3E
    add  hl, de
.toc_01_0386:
    ld   e, [hl]
    assign [gbP1], JOYPAD_BUTTONS
    ld   a, [gbP1]
    ld   a, [gbP1]
    swap a
    and  JOYPAD_BUTTONS | JOYPAD_DIRECTIONS | %11000000
    ld   d, a
    assign [gbP1], JOYPAD_DIRECTIONS
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    ld   a, [gbP1]
    and  %00001111
    or   d
    cpl
    call toc_01_041E
    assign [gbP1], JOYPAD_BUTTONS | JOYPAD_DIRECTIONS
    dec  b
    jr   nz, .loop_01_0375

.else_01_03B2:
    ld   a, [$DA3A]
    or   a
    jp   z, .else_01_03F8

    ld   hl, $DA3C
    ldi  a, [hl]
    ld   b, [hl]
    ld   c, a
    cp   $FE
    jr   nz, .else_01_03CA

    ld   a, b
    cp   $BE
    jr   nz, .else_01_03CA

    dec  bc
    dec  bc
.else_01_03CA:
    ifNe [$DA3A], $02, .else_01_03D1

.else_01_03D1:
    ld   a, [$DA3B]
    dec  a
    jr   nz, .else_01_03E2

    inc  bc
    inc  bc
    inc  bc
    ld   a, [bc]
    dec  bc
    ld   hl, $DA3C
    ld   [hl], c
    inc  hl
    ld   [hl], b
.else_01_03E2:
    ld   [$DA3B], a
    ld   a, [$FFA5]
    ld   e, a
    ld   a, [bc]
    ld   hl, $FFA5
    call toc_01_041E
    ld   b, $04
    ld   hl, $DA42
    ld   c, $A9
    jr   .loop_01_03FF

.else_01_03F8:
    ld   b, $08
    ld   hl, $DA3E
    ld   c, $A5
.loop_01_03FF:
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    dec  b
    jr   nz, .loop_01_03FF

    ld   a, [$FFA5]
    cp   $0F
    ret  nz

    ld   a, [$FFA6]
    cp   $0F
    ret  z

    or   a
    ret  z

    ld   e, $34
    cbcallNoInterrupts $1E, $6002
    jp   main

toc_01_041E:
    ld   d, a
    ldi  [hl], a
    xor  e
    and  d
    ldi  [hl], a
    jr   z, .else_01_0429

    ldi  [hl], a
    ld   [hl], $14
    ret


.else_01_0429:
    inc  hl
    or   [hl]
    jr   z, .else_01_0432

    dec  [hl]
    dec  hl
    ld   [hl], $00
    ret


.else_01_0432:
    ld   [hl], $03
    dec  hl
    ld   [hl], d
    ret


toc_01_0437:
    call toc_01_0496
    call toc_01_04AE
    call toc_01_0343
    ld   d, $01
    cbcallNoInterrupts $1E, $5FEB
    cbcallNoInterrupts $1E, $5DFF
.toc_01_0452:
    assign [$FFB5], $01
.loop_01_0456:
    ld   a, [$FFB5]
    or   a
    jr   nz, .loop_01_0456

    di
    ld   hl, gbIF
    res  0, [hl]
    res  1, [hl]
    assign [gbTIMA], $FF
    assign [gbTAC], $04
    ei
    ret


toc_01_046D:
    call toc_01_0483
    cbcallNoInterrupts $1E, $5DFF
    ld   d, $00
    cbcallNoInterrupts $1E, $5FEB
    ret


toc_01_0483:
    ld   hl, $DA0D
    ld   [hl], $00
.loop_01_0488:
    halt
    bit  0, [hl]
    jr   z, .loop_01_0488

    clear [gbTAC]
    ld   hl, gbLCDC
    set  7, [hl]
    ret


toc_01_0496:
    ld   a, [$DA28]
    ld   de, $DA23
    rra
    jr   nc, .else_01_04A0

    inc  de
.else_01_04A0:
    clear [$DA09]
    ld   [$DA22], a
    ld   [de], a
    ld   hl, $DA06
    ldi  [hl], a
    ld   [hl], a
    ret


toc_01_04AE:
    ld   a, [$DA08]
    ld   c, a
    ld   h, a
    ld   de, $DA0A
    rra
    jr   nc, .else_01_04BA

    inc  de
.else_01_04BA:
    ld   a, [de]
    ld   b, a
    ld   a, [$DA09]
    ld   l, a
    ld   [de], a
    sub  a, b
    jr   nc, .else_01_04CA

    ld   b, a
    xor  a
.loop_01_04C6:
    ldi  [hl], a
    inc  b
    jr   nz, .loop_01_04C6

.else_01_04CA:
    srl  h
    ld   hl, wScrollPosition1
    jr   nc, .else_01_04D4

    ld   hl, wScrollPosition2
.else_01_04D4:
    ld   a, [$DA00]
    ld   b, a
    ld   a, [$DA06]
    add  a, b
    ldi  [hl], a
    ld   a, [$DA01]
    ld   b, a
    ld   a, [$DA07]
    add  a, b
    ldi  [hl], a
    ld   a, [$DA28]
    ld   b, a
    ld   de, $DA23
    rra
    jr   nc, .else_01_04F1

    inc  de
.else_01_04F1:
    ld   a, [de]
    or   a
    jr   z, .else_01_050E

    bit  0, b
    ld   hl, $DA27
    di
    jr   nz, .else_01_0503

    set  0, [hl]
    res  2, [hl]
    jr   .toc_01_0507

.else_01_0503:
    set  1, [hl]
    set  2, [hl]
.toc_01_0507:
    ei
    ld   a, b
    xor  %00000001
    ld   [$DA28], a
.else_01_050E:
    ld   a, c
    and  %00000001
    inc  a
    ld   [wQueuedDMATransfer], a
    ld   a, c
    xor  %00000001
    ld   [$DA08], a
    ret


    db   $FA, $09, $DA, $0F, $0F, $86, $FE, $29
    db   $D0, $1A, $1D, $B7, $28, $08, $3C, $C0
    db   $1A, $FE, $C0, $D8, $18, $04, $1A, $FE
    db   $C0, $D0, $C6, $10, $4F, $1D, $1A, $1D
    db   $B7, $28, $08, $3C, $C0, $1A, $FE, $CC
    db   $D8, $18, $04, $1A, $FE, $CC, $D0, $C6
    db   $08, $47, $23, $FA, $08, $DA, $57, $FA
    db   $09, $DA, $5F, $F0, $93, $17, $38, $2F
    db   $2A, $81, $FE, $A0, $30, $1F, $12, $1C
    db   $2A, $80, $FE, $A8, $30, $1C, $12, $1C
    db   $F0, $94, $86, $23, $12, $1C, $F0, $95
    db   $AE, $23, $12, $1C, $CB, $47, $28, $E0
    db   $7B, $EA, $09, $DA, $C9, $23, $23, $2A
    db   $18, $F2, $1D, $23, $2A, $18, $ED, $2A
    db   $81, $FE, $A0, $30, $24, $12, $1C, $2A
    db   $2F, $D6, $07, $80, $FE, $A8, $30, $1E
    db   $12, $1C, $F0, $94, $86, $23, $12, $1C
    db   $F0, $95, $AE, $EE, $20, $23, $12, $1C
    db   $CB, $47, $28, $DB, $7B, $EA, $09, $DA
    db   $C9, $23, $23, $2A, $18, $F2, $1D, $23
    db   $2A, $18, $ED

toc_01_05BF:
    ld   [hDesiredBankChange], a
    ld   a, [hLastBank]
    push af
    ld   a, [hDesiredBankChange]
    call cbcallWithoutInterrupts.loadBank
    call memcpy
    pop  af
    jr   cbcallWithoutInterrupts.loadBank

cbcallWithoutInterrupts:
    ld   [hDesiredBankChange], a
    ld   a, [hLastBank]
    push af
    ld   a, [hDesiredBankChange]
    call .loadBank
    call toc_01_0620
    pop  af
.loadBank:
    di
    ld   [$2100], a
    ld   [hLastBank], a
    ei
    ret


changeBankAndCall:
    ld   [hDesiredBankChange], a
    ld   a, [hLastBank]
    push af
    ld   a, [hDesiredBankChange]
    call .loadBank
    call toc_01_0620
    pop  af
.loadBank:
    ld   [$2100], a
    ld   [hLastBank], a
    ret


toc_01_05F9:
    di
    ld   a, l
    ld   [wStashL], a
    ld   a, h
    ld   [wStashH], a
    ei
    ret


stashHL:
    ld   a, l
    ld   [wStashL], a
    ld   a, h
    ld   [wStashH], a
    ret


toc_01_060D:
    ld   [hDesiredBankChange], a
    ld   a, [hLastBank]
    push af
    ld   a, [hDesiredBankChange]
    call cbcallWithoutInterrupts.loadBank
    call decompressHAL
    pop  af
    jr   cbcallWithoutInterrupts.loadBank

    db   $CD, $DD, $05

toc_01_0620:
    jp   hl

memcpy:
    inc  b
    inc  c
    jr   .startCopying

.copy:
    ldi  a, [hl]
    ld   [de], a
    inc  de
.startCopying:
    dec  c
    jr   nz, .copy

    dec  b
    jr   nz, .copy

    ret


memset:
    inc  b
    inc  c
    jr   .toc_01_0634

.loop_01_0633:
    ldi  [hl], a
.toc_01_0634:
    dec  c
    jr   nz, .loop_01_0633

    dec  b
    jr   nz, .loop_01_0633

    ret


    db   $CD, $47, $06, $C5, $47, $4B, $CD, $85
    db   $28, $78, $C1, $C9

toc_01_0647:
    push de
    push hl
    ld   hl, $DA30
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   d, h
    ld   e, l
    add  hl, hl
    add  hl, hl
    add  hl, de
    ld   de, $3711
    add  hl, de
    ld   a, l
    ld   [$DA30], a
    ld   a, h
    ld   [$DA31], a
    pop  hl
    pop  de
    ret


toc_01_0663:
    ld   hl, $066D
    add  a, l
    ld   l, a
    jr   nc, .else_01_066B

    inc  h
.else_01_066B:
    ld   a, [hl]
    ret


    db   $01, $02, $04, $08, $10, $20, $40, $80

toc_01_0675:
    push de
    add  a, $03
    ld   e, a
    ld   a, [$FF92]
    ld   d, a
    ld   a, [$DA1C]
    sub  a, d
    dec  a
    cp   e
    pop  de
    ret


    db   $FA, $0F, $DA, $B7, $20, $09, $FA, $39
    db   $DA, $B7, $C8, $AF, $EA, $39, $DA, $21
    db   $33, $DA, $35, $C0, $FA, $34, $DA, $FE
    db   $0C, $28, $20, $5F, $16, $CD, $FA, $38
    db   $DA, $B7, $20, $21, $21, $00, $CD, $1A
    db   $1C, $22, $1A, $1C, $22, $1A, $1C, $77
    db   $7B, $EA, $34, $DA, $FA, $32, $DA, $EA
    db   $33, $DA, $C9, $AF, $EA, $36, $DA, $21
    db   $42, $03, $C3, $04, $06, $FA, $0C, $CD
    db   $B7, $20, $06, $AF, $EA, $38, $DA, $18
    db   $EB, $3D, $EA, $0C, $CD, $20, $14, $FA
    db   $37, $DA, $FE, $FF, $28, $0D, $FE, $01
    db   $3E, $FF, $28, $01, $AF, $21, $00, $CD
    db   $22, $22, $77, $1A, $67, $1C, $7B, $EA
    db   $34, $DA, $F0, $A4, $F5, $3E, $1E, $CD
    db   $F3, $05, $5C, $CD, $0C, $60, $F1, $CD
    db   $F3, $05, $18, $B0

decompressHAL:
    ld   a, e
    ld   [$FF97], a
    ld   a, d
    ld   [$FF98], a
.readCommandByte:
    ld   a, [hl]
    cp   $FF
    ret  z

    and  %11100000
    cp   $E0
    jr   nz, .else_01_0728

.readLongCommand:
    ld   a, [hl]
    add  a, a
    add  a, a
    add  a, a
    and  %11100000
    push af
    ldi  a, [hl]
    and  %00000011
    ld   b, a
    ldi  a, [hl]
    ld   c, a
    inc  bc
    jr   .toc_01_0730

.else_01_0728:
    push af
    ldi  a, [hl]
    and  %00011111
    ld   c, a
    ld   b, $00
    inc  c
.toc_01_0730:
    inc  b
    inc  c
    pop  af
    bit  7, a
    jr   nz, .else_01_077B

    cp   $20
    jr   z, .fill

    cp   $40
    jr   z, .else_01_075B

    cp   $60
    jr   z, .else_01_076E

.copyBytes:
    dec  c
    jr   nz, .else_01_074A

    dec  b
    jp   z, .readCommandByte

.else_01_074A:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    jr   .copyBytes

.fill:
    ldi  a, [hl]
.whilePixelsRemain:
    dec  c
    jr   nz, .paintPixel

    dec  b
    jp   z, .readCommandByte

.paintPixel:
    ld   [de], a
    inc  de
    jr   .whilePixelsRemain

.else_01_075B:
    dec  c
    jr   nz, .else_01_0762

    dec  b
    jp   z, .else_01_076A

.else_01_0762:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ldd  a, [hl]
    ld   [de], a
    inc  de
    jr   .else_01_075B

.else_01_076A:
    inc  hl
    inc  hl
    jr   .readCommandByte

.else_01_076E:
    ldi  a, [hl]
.toc_01_076F:
    dec  c
    jr   nz, .else_01_0776

    dec  b
    jp   z, .readCommandByte

.else_01_0776:
    ld   [de], a
    inc  de
    inc  a
    jr   .toc_01_076F

.else_01_077B:
    push hl
    push af
    ldi  a, [hl]
    ld   l, [hl]
    ld   h, a
    ld   a, [$FF97]
    add  a, l
    ld   l, a
    ld   a, [$FF98]
    adc  h
    ld   h, a
    pop  af
    cp   $80
    jr   z, .else_01_0795

    cp   $A0
    jr   z, .else_01_07A0

    cp   $C0
    jr   z, .else_01_07B2

.else_01_0795:
    dec  c
    jr   nz, .else_01_079B

    dec  b
    jr   z, .else_01_07BE

.else_01_079B:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    jr   .else_01_0795

.else_01_07A0:
    dec  c
    jr   nz, .else_01_07A7

    dec  b
    jp   z, .else_01_07BE

.else_01_07A7:
    ldi  a, [hl]
    push hl
    ld   h, $D9
    ld   l, a
    ld   a, [hl]
    pop  hl
    ld   [de], a
    inc  de
    jr   .else_01_07A0

.else_01_07B2:
    dec  c
    jr   nz, .else_01_07B9

    dec  b
    jp   z, .else_01_07BE

.else_01_07B9:
    ldd  a, [hl]
    ld   [de], a
    inc  de
    jr   .else_01_07B2

.else_01_07BE:
    pop  hl
    inc  hl
    inc  hl
    jp   .readCommandByte

toc_01_07C4:
    ld   [$FF84], a
    push de
    push bc
    ld   b, h
    ld   c, l
    call toc_01_0B94
    jr   nc, .else_01_07D8

    pop  hl
    pop  de
    ld   h, $00
    ld   a, h
    ld   [$DA4A], a
    ret


.else_01_07D8:
    ld   a, h
    ld   [$DA4A], a
    ld   l, $22
    ld   [hl], $42
    inc  l
    ld   [hl], $03
    ld   a, $80
    ld   l, $03
    ld   [hl], a
    ld   l, $06
    ld   [hl], a
    pop  bc
    ld   l, $04
    ld   [hl], c
    inc  l
    ld   [hl], b
    pop  bc
    ld   l, $07
    ld   [hl], c
    inc  l
    ld   [hl], b
    call toc_01_0C06
    ld   a, [$FF84]
    ld   l, $00
    ld   [hl], a
    ld   e, a
    ld   d, $00
    sla  a
    rl   d
    add  a, e
    ld   e, a
    ld   a, $77
    adc  d
    ld   d, a
    xor  a
    ld   l, $0D
    ldi  [hl], a
    ld   [hl], a
    ld   l, $0F
    ldi  [hl], a
    ld   [hl], a
    ld   l, $11
    ldi  [hl], a
    ld   [hl], a
    ld   l, $45
    ldi  [hl], a
    ld   [hl], a
    ld   l, $4A
    ldi  [hl], a
    ld   [hl], a
    ld   a, $FF
    ld   l, $15
    ld   [hl], a
    ld   l, $49
    ld   [hl], a
    ld   l, $48
    ld   [hl], a
    copyFromTo [hLastBank], [$FF84]
    ld   a, $07
    call cbcallWithoutInterrupts.loadBank
    ld   a, [de]
    ld   c, a
    inc  de
    ld   a, [de]
    ld   b, a
    inc  de
    ld   a, [de]
    ld   e, a
    ld   a, [$FF84]
    call cbcallWithoutInterrupts.loadBank
    call toc_01_0855
    ret


    db   $F0, $9A, $67, $7C, $FE, $A0, $D8, $FE
    db   $B3, $D0, $2E, $00, $7E, $3C, $C8

toc_01_0855:
    call toc_01_0C2A
    ld   l, $19
    ld   [hl], e
    inc  l
    ld   [hl], b
    inc  l
    ld   [hl], c
    xor  a
    ld   l, $24
    ld   [hl], a
    ld   l, $47
    ld   [hl], a
    ld   l, $28
    ld   [hl], $39
    ret


toc_01_086B:
    ld   a, [$DA46]
    jr   .toc_01_087F

.loop_01_0870:
    ld   [$FF9A], a
    ld   h, a
    ld   l, $01
    ld   a, [hl]
    ld   [$DA49], a
    call toc_01_08A1
    ld   a, [$DA49]
.toc_01_087F:
    or   a
    jr   nz, .loop_01_0870

    ld   a, [$DA46]
    jr   .toc_01_089D

.loop_01_0887:
    ld   [$FF9A], a
    ld   d, a
    ld   e, $01
    ld   a, [de]
    ld   [$DA49], a
    ld   e, $22
    ld   a, [de]
    ld   l, a
    inc  e
    ld   a, [de]
    ld   h, a
    call toc_01_0620
    ld   a, [$DA49]
.toc_01_089D:
    or   a
    jr   nz, .loop_01_0887

    ret


toc_01_08A1:
    ld   l, $19
    assign [$FF9B], $24
    ld   e, a
.toc_01_08A8:
    ldi  a, [hl]
    ld   b, a
    and  %10100000
    jr   nz, .else_01_08B9

    bit  6, b
    jr   nz, toc_01_08DE

    ld   d, h
    ld   a, [de]
    or   a
    jr   z, .else_01_08C6

    dec  a
    ld   [de], a
.else_01_08B9:
    inc  l
    inc  l
.toc_01_08BB:
    returnIfGte [$FF9B], $26

    inc  a
    ld   [$FF9B], a
    ld   e, a
    jr   .toc_01_08A8

.else_01_08C6:
    ld   a, b
    call cbcallWithoutInterrupts.loadBank
    ldi  a, [hl]
    ld   b, a
    ld   c, [hl]
    push hl
    ld   a, [bc]
    inc  bc
    add  a, a
    ld   h, $3F
    ld   l, a
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    jp   hl

    db   $E1, $71, $2D, $70, $18, $DB

toc_01_08DE:
    ld   a, b
    and  %00011111
    call cbcallWithoutInterrupts.loadBank
    ldi  a, [hl]
    ld   b, a
    ldi  a, [hl]
    push hl
    ld   d, h
    ld   l, a
    ld   h, b
    call toc_01_0620
    pop  hl
    jr   toc_01_08A1.toc_01_08BB

    db   $62, $D5, $CD, $BA, $0B, $D1, $C3, $D8
    db   $08, $F0, $9B, $D6, $24, $6F, $87, $85
    db   $C6, $19, $6F, $62, $CB, $FE, $C3, $D8
    db   $08, $F0, $9B, $5F, $0A, $03, $3D, $12
    db   $C3, $D8, $08, $62, $F0, $9B, $6F, $1E
    db   $27, $1A, $3D, $77, $C3, $D8, $08, $0A
    db   $03, $1E, $15, $12, $C3, $CE, $08, $0A
    db   $03, $1E, $15, $12, $F0, $9B, $5F, $0A
    db   $03, $3D, $12, $C3, $D8, $08, $0A, $03
    db   $5F, $0A, $03, $12, $C3, $CE, $08, $0A
    db   $03, $5F, $1A, $1E, $27, $12, $C3, $CE
    db   $08, $0A, $03, $5F, $62, $2E, $27, $7E
    db   $12, $C3, $CE, $08, $1E, $25, $AF, $12
    db   $62, $2E, $1E, $0A, $03, $32, $0A, $03
    db   $32, $0A, $03, $77, $C3, $CE, $08, $1E
    db   $26, $AF, $12, $62, $62, $2E, $21, $0A
    db   $03, $32, $0A, $03, $32, $0A, $03, $77
    db   $C3, $CE, $08, $1E, $22, $0A, $03, $12
    db   $1C, $0A, $03, $12, $C3, $CE, $08, $62
    db   $2E, $18, $0A, $03, $32, $0A, $03, $32
    db   $0A, $03, $77, $C3, $CE, $08, $0A, $03
    db   $5F, $0A, $47, $4B, $C3, $CE, $08, $0A
    db   $03, $6F, $0A, $03, $67, $F0, $9B, $D6
    db   $24, $5F, $87, $83, $C6, $19, $5F, $0A
    db   $12, $CD, $DD, $05, $44, $4D, $C3, $CE
    db   $08, $1E, $27, $1A, $B7, $20, $09, $0A
    db   $03, $5F, $0A, $47, $4B, $C3, $CE, $08
    db   $03, $03, $C3, $CE, $08, $1E, $27, $1A
    db   $B7, $28, $09, $0A, $03, $5F, $0A, $47
    db   $4B, $C3, $CE, $08, $03, $03, $C3, $CE
    db   $08, $60, $69, $1E, $27, $1A, $BE, $30
    db   $07, $23, $2A, $4F, $46, $C3, $CE, $08
    db   $03, $03, $03, $C3, $CE, $08, $60, $69
    db   $1E, $27, $1A, $BE, $38, $07, $23, $2A
    db   $4F, $46, $C3, $CE, $08, $03, $03, $03
    db   $C3, $CE, $08, $1E, $0D, $0A, $03, $12
    db   $1C, $0A, $03, $12, $C3, $CE, $08, $1E
    db   $0F, $0A, $03, $12, $1C, $0A, $03, $12
    db   $C3, $CE, $08, $AF, $62, $2E, $0D, $22
    db   $77, $2E, $0F, $22, $77, $C3, $CE, $08
    db   $0A, $03, $1E, $11, $12, $C3, $CE, $08
    db   $0A, $03, $1E, $12, $12, $C3, $CE, $08
    db   $0A, $5F, $03, $62, $2E, $28, $7E, $3D
    db   $6F, $70, $2D, $71, $2D, $73, $1E, $28
    db   $7D, $12, $C3, $CE, $08, $62, $2E, $28
    db   $7E, $6F, $35, $28, $07, $2C, $4E, $2C
    db   $46, $C3, $CE, $08, $2C, $2C, $2C, $1E
    db   $28, $7D, $12, $C3, $CE, $08, $62, $2E
    db   $28, $7E, $3D, $6F, $0A, $03, $5F, $0A
    db   $03, $70, $2D, $71, $47, $4B, $1E, $28
    db   $7D, $12, $C3, $CE, $08, $0A, $03, $6F
    db   $0A, $03, $67, $E5, $F0, $9B, $D6, $24
    db   $5F, $87, $83, $C6, $19, $5F, $1A, $E0
    db   $84, $0A, $03, $12, $CD, $DD, $05, $62
    db   $2E, $28, $7E, $3D, $6F, $F0, $84, $32
    db   $70, $2D, $71, $C1, $1E, $28, $7D, $12
    db   $C3, $CE, $08, $62, $2E, $28, $7E, $6F
    db   $4E, $2C, $46, $2C, $1E, $28, $7D, $12
    db   $C3, $CE, $08, $62, $2E, $28, $7E, $6F
    db   $4E, $2C, $46, $2C, $F0, $9B, $D6, $24
    db   $5F, $87, $83, $C6, $19, $5F, $2A, $12
    db   $CD, $DD, $05, $1E, $28, $7D, $12, $C3
    db   $CE, $08, $0A, $03, $6F, $0A, $03, $67
    db   $CD, $20, $06, $C3, $CE, $08, $0A, $03
    db   $6F, $0A, $03, $67, $CD, $20, $06, $F0
    db   $9B, $5F, $1A, $3D, $12, $C3, $D8, $08
    db   $CD, $99, $10, $C3, $CE, $08, $CD, $B6
    db   $10, $C3, $CE, $08, $CD, $18, $10, $C3
    db   $CE, $08, $CD, $C0, $1E, $C3, $CE, $08
    db   $CD, $11, $10, $C3, $CE, $08, $60, $69
    db   $1E, $27, $1A, $BE, $30, $0C, $23, $07
    db   $4F, $06, $00, $09, $2A, $4F, $46, $C3
    db   $CE, $08, $2A, $07, $4F, $06, $00, $09
    db   $44, $4D, $C3, $CE, $08, $C5, $0A, $03
    db   $07, $81, $4F, $30, $01, $04, $62, $2E
    db   $28, $7E, $3D, $6F, $70, $2D, $71, $1E
    db   $28, $7D, $12, $C1, $60, $69, $1E, $27
    db   $1A, $BE, $30, $0C, $23, $07, $4F, $06
    db   $00, $09, $2A, $4F, $46, $C3, $CE, $08
    db   $2A, $07, $4F, $06, $00, $09, $44, $4D
    db   $C3, $CE, $08, $1E, $03, $3E, $80, $12
    db   $1C, $0A, $03, $12, $1C, $0A, $03, $12
    db   $C3, $CE, $08, $1E, $06, $3E, $80, $12
    db   $1C, $0A, $03, $12, $1C, $0A, $03, $12
    db   $C3, $CE, $08

toc_01_0B94:
    __ifNotZero [$DA48], .else_01_0BA8

    ld   h, a
    ld   l, $01
.loop_01_0B9D:
    cp   b
    jr   c, .else_01_0BA3

    cp   c
    jr   c, .else_01_0BAA

.else_01_0BA3:
    ld   h, a
    ld   a, [hl]
    or   a
    jr   nz, .loop_01_0B9D

.else_01_0BA8:
    scf
    ret


.else_01_0BAA:
    cp   h
    jr   nz, .else_01_0BB3

    ld   a, [hl]
    ld   [$DA48], a
    and  a
    ret


.else_01_0BB3:
    ld   d, h
    ld   e, l
    ld   h, a
    ld   a, [hl]
    ld   [de], a
    and  a
    ret


    db   $7C, $FE, $A0, $D8, $FE, $B3, $D0, $2E
    db   $00, $7E, $3C, $C8, $36, $FF, $CD, $2A
    db   $0C, $2E, $01, $7E, $B7, $2E, $02, $20
    db   $05, $11, $47, $DA, $18, $02, $57, $5D
    db   $7E, $12, $B7, $2E, $01, $20, $05, $11
    db   $46, $DA, $18, $02, $57, $5D, $7E, $12
    db   $FA, $49, $DA, $BC, $20, $04, $7E, $EA
    db   $49, $DA, $11, $48, $DA, $1A, $2E, $01
    db   $77, $7C, $12, $2E, $49, $5E, $16, $BB
    db   $AF, $12, $54, $C9

toc_01_0C06:
    ld   de, $DA47
    ld   a, [de]
    ld   l, $02
    ld   [hl], a
    ld   l, $01
    ld   [hl], $00
    or   a
    jr   nz, .else_01_0C1A

    ld   a, h
    ld   [de], a
    ld   [$DA46], a
    ret


.else_01_0C1A:
    ld   b, h
    ld   h, a
    ld   [hl], b
    ld   a, b
    ld   [de], a
    ld   h, a
    ld   a, [$DA49]
    or   a
    ret  nz

    ld   a, h
    ld   [$DA49], a
    ret


toc_01_0C2A:
    ld   l, $1C
    ld   [hl], $80
    ld   l, $1F
    ld   [hl], $80
    ld   l, $25
    ld   [hl], $00
    inc  l
    ld   [hl], $00
    ret


    db   $CD, $48, $0C, $E5, $21, $7D, $74, $3E
    db   $02, $CD, $CF, $05, $E1, $C9, $AF, $E0
    db   $B4, $21, $6C, $A0, $CB, $86, $FA, $54
    db   $A0, $FE, $80, $38, $05, $3E, $60, $EA
    db   $54, $A0, $26, $A0, $C3, $49, $08, $62
    db   $2E, $03, $11, $4B, $DA, $01, $9B, $00
    db   $CD, $21, $06, $F0, $9A, $57, $C9, $1E
    db   $03, $21, $4B, $DA, $01, $9B, $00, $CD
    db   $21, $06, $F0, $9A, $57, $C9, $1E, $11
    db   $1A, $1E, $0D, $4F, $17, $9F, $47, $1A
    db   $81, $12, $1C, $1A, $88, $12, $C9, $1E
    db   $12, $1A, $1E, $0F, $4F, $17, $9F, $47
    db   $1A, $81, $12, $1C, $1A, $88, $12, $C9
    db   $62, $2E, $0E, $3A, $17, $38, $0E, $2A
    db   $91, $3A, $98, $38, $08, $1E, $0C, $C3
    db   $04, $0D, $62, $2E, $0D, $7E, $83, $22
    db   $7E, $CE, $00, $32, $17, $D8, $2A, $91
    db   $7E, $98, $D8, $78, $32, $71, $C9, $79
    db   $2F, $C6, $01, $4F, $78, $2F, $CE, $00
    db   $47, $62, $2E, $0E, $3A, $17, $30, $18
    db   $2A, $91, $3A, $98, $30, $12, $1E, $0C
    db   $C3, $04, $0D, $79, $2F, $C6, $01, $4F
    db   $78, $2F, $CE, $00, $47, $62, $2E, $0D
    db   $7E, $93, $22, $7E, $DE, $00, $32, $17
    db   $D0, $2A, $91, $7E, $98, $D0, $78, $32
    db   $71, $C9, $62, $2E, $0E, $3A, $17, $38
    db   $0C, $7E, $93, $22, $7E, $DE, $00, $77
    db   $D0, $AF, $32, $77, $C9, $7E, $83, $22
    db   $7E, $CE, $00, $77, $D0, $AF, $32, $77
    db   $C9, $62, $2E, $10, $3A, $17, $38, $0E
    db   $2A, $91, $3A, $98, $38, $08, $1E, $0C
    db   $C3, $85, $0D, $62, $2E, $0F, $7E, $83
    db   $22, $7E, $CE, $00, $32, $17, $D8, $2A
    db   $91, $7E, $98, $D8, $78, $32, $71, $C9
    db   $79, $2F, $C6, $01, $4F, $78, $2F, $CE
    db   $00, $47, $62, $2E, $10, $3A, $17, $30
    db   $18, $2A, $91, $3A, $98, $30, $12, $1E
    db   $0C, $C3, $85, $0D, $79, $2F, $C6, $01
    db   $4F, $78, $2F, $CE, $00, $47, $62, $2E
    db   $0F, $7E, $93, $22, $7E, $DE, $00, $32
    db   $17, $D0, $2A, $91, $7E, $98, $D0, $78
    db   $32, $71, $C9, $62, $2E, $10, $3A, $17
    db   $38, $0C, $7E, $93, $22, $7E, $DE, $00
    db   $77, $D0, $AF, $32, $77, $C9, $7E, $83
    db   $22, $7E, $CE, $00, $77, $D0, $AF, $32
    db   $77, $C9, $1E, $0D, $62, $2E, $03, $1A
    db   $86, $22, $1C, $1A, $06, $00, $CB, $7F
    db   $28, $01, $05, $8E, $22, $1C, $78, $8E
    db   $22, $1A, $86, $22, $1C, $1A, $06, $00
    db   $CB, $7F, $28, $01, $05, $8E, $22, $1C
    db   $78, $8E, $77, $C9, $FA, $6C, $A0, $1F
    db   $30, $0A, $3E, $07, $CD, $DD, $05, $CD
    db   $0A, $74, $18, $12, $CD, $2C, $0E, $FA
    db   $5D, $A0, $FE, $00, $20, $08, $3E, $0B
    db   $CD, $DD, $05, $CD, $5B, $78, $C3, $22
    db   $0F, $CD, $67, $34, $CD, $2C, $0E, $C3
    db   $22, $0F, $CD, $7D, $34, $CD, $4B, $0E
    db   $C3, $22, $0F, $CD, $01, $0F, $C3, $22
    db   $0F, $CD, $9D, $0E, $C3, $22, $0F, $3E
    db   $08, $CD, $DD, $05, $CD, $AC, $57, $C9
    db   $3E, $08, $CD, $DD, $05, $CD, $CB, $53
    db   $C9, $3E, $08, $CD, $DD, $05, $CD, $A6
    db   $56, $C9, $1E, $04, $21, $51, $DB, $42
    db   $0E, $09, $1A, $96, $02, $1C, $23, $0C
    db   $1A, $9E, $02, $1C, $1C, $23, $0C, $1A
    db   $96, $02, $1C, $23, $0C, $1A, $9E, $02
    db   $C9, $1E, $04, $21, $51, $DB, $42, $0E
    db   $09, $1A, $96, $02, $E0, $84, $1C, $23
    db   $0C, $1A, $9E, $02, $3C, $FE, $01, $F0
    db   $84, $28, $08, $30, $2D, $FE, $E0, $30
    db   $06, $18, $27, $FE, $C0, $30, $23, $1C
    db   $1C, $23, $0C, $1A, $96, $02, $E0, $84
    db   $1C, $23, $0C, $1A, $9E, $02, $3C, $FE
    db   $01, $F0, $84, $28, $08, $30, $0B, $FE
    db   $E0, $30, $06, $18, $05, $FE, $A0, $30
    db   $01, $C9, $1E, $15, $3E, $FF, $12, $62
    db   $C3, $BA, $0B, $1E, $04, $21, $51, $DB
    db   $42, $0E, $09, $1A, $96, $02, $E0, $84
    db   $1C, $23, $0C, $1A, $9E, $02, $3C, $FE
    db   $01, $F0, $84, $28, $08, $30, $2D, $FE
    db   $E0, $30, $06, $18, $27, $FE, $C0, $30
    db   $23, $1C, $1C, $23, $0C, $1A, $96, $02
    db   $E0, $84, $1C, $23, $0C, $1A, $9E, $02
    db   $3C, $FE, $01, $F0, $84, $28, $08, $30
    db   $0B, $FE, $E0, $30, $06, $18, $05, $FE
    db   $A0, $30, $01, $C9, $1E, $15, $3E, $FF
    db   $12, $62, $D5, $CD, $BA, $0B, $D1, $1E
    db   $48, $1A, $67, $2E, $15, $3E, $FF, $77
    db   $CD, $BA, $0B, $F0, $9A, $57, $C9, $1E
    db   $48, $1A, $67, $1E, $04, $2E, $09, $42
    db   $4D, $1A, $86, $02, $1C, $2C, $0C, $1A
    db   $8E, $02, $1C, $1C, $2C, $0C, $1A, $86
    db   $02, $1C, $2C, $0C, $1A, $8E, $02, $C9
    db   $1E, $15, $1A, $FE, $FF, $C8, $87, $4F
    db   $62, $2E, $16, $2A, $CD, $DD, $05, $2A
    db   $6E, $67, $06, $00, $09, $2A, $66, $6F
    db   $0E, $93, $1E, $45, $1A, $E2, $1C, $0C
    db   $1A, $E2, $1C, $0C, $1A, $E2, $1E, $0C
    db   $D5, $CD, $1C, $05, $D1, $C9, $D5, $60
    db   $69, $2A, $E0, $84, $2A, $47, $2A, $4F
    db   $E5, $CD, $67, $0F, $C1, $D1, $7C, $B7
    db   $C8, $2E, $48, $72, $C9, $62, $2E, $07
    db   $2A, $5F, $56, $D5, $2E, $04, $2A, $5F
    db   $56, $D5, $C3, $CA, $07, $0A, $03, $5F
    db   $D5, $C5, $3E, $01, $E0, $84, $01, $A5
    db   $A2, $CD, $67, $0F, $C1, $D1, $7C, $B7
    db   $C8, $2E, $48, $72, $2E, $51, $73, $C9
    db   $3E, $01, $E0, $84, $21, $34, $DB, $3E
    db   $A5, $22, $36, $A2, $60, $69, $CD, $D0
    db   $0F, $C8, $2E, $51, $F0, $80, $77, $1E
    db   $45, $6B, $1A, $77, $C9, $3E, $02, $E0
    db   $84, $21, $34, $DB, $3E, $A8, $22, $36
    db   $A5, $60, $69, $CD, $D0, $0F, $C8, $2E
    db   $5A, $F0, $80, $77, $1E, $45, $6B, $1A
    db   $77, $2E, $4C, $36, $00, $C9, $2A, $E0
    db   $80, $2A, $E0, $85, $2A, $E0, $86, $D5
    db   $E5, $62, $2E, $45, $7E, $17, $F0, $85
    db   $30, $02, $2F, $3C, $4F, $17, $9F, $47
    db   $2E, $04, $2A, $81, $4F, $2A, $88, $47
    db   $2C, $F0, $86, $5F, $17, $9F, $57, $2A
    db   $83, $5F, $7E, $8A, $57, $21, $34, $DB
    db   $2A, $66, $6F, $CD, $C6, $07, $C1, $D1
    db   $7C, $B7, $C8, $2E, $48, $72, $C9, $CD
    db   $47, $06, $1E, $27, $12, $C9, $1E, $45
    db   $1A, $17, $1E, $0D, $0A, $03, $38, $04
    db   $12, $0A, $18, $08, $2F, $C6, $01, $12
    db   $0A, $2F, $CE, $00, $1C, $03, $12, $C9
    db   $1E, $45, $1A, $17, $1E, $11, $0A, $03
    db   $30, $02, $2F, $3C, $12, $C9, $1E, $07
    db   $18, $02, $1E, $04, $60, $69, $1A, $86
    db   $12, $1C, $23, $1A, $8E, $12, $23, $44
    db   $4D, $C9, $26, $A0, $7C, $BA, $28, $06
    db   $CD, $BA, $0B, $F0, $9A, $57, $24, $7C
    db   $FE, $B3, $20, $F1, $C9, $26, $A0, $7C
    db   $BA, $28, $0C, $2E, $19, $CB, $EE, $2E
    db   $1C, $CB, $EE, $2E, $1F, $CB, $EE, $24
    db   $7C, $FE, $B3, $20, $EB, $C9, $26, $A0
    db   $7C, $BA, $28, $0C, $2E, $19, $CB, $AE
    db   $2E, $1C, $CB, $AE, $2E, $1F, $CB, $AE
    db   $24, $7C, $FE, $B3, $20, $EB, $C9, $0A
    db   $5F, $03, $C5, $21, $99, $42, $3E, $1E
    db   $CD, $CF, $05, $C1, $F0, $9A, $57, $C9
    db   $21, $99, $42, $3E, $1E, $CD, $CF, $05
    db   $F0, $9A, $57, $C9, $0A, $5F, $03, $C5
    db   $21, $32, $42, $3E, $1F, $CD, $CF, $05
    db   $C1, $F0, $9A, $57, $C9, $0A, $EA, $6F
    db   $DB, $18, $EA, $0A, $03, $5F, $C5, $21
    db   $6D, $60, $3E, $1E, $CD, $CF, $05, $C1
    db   $F0, $9A, $57, $C9

toc_01_10DE:
    ld   a, $08
    call cbcallWithoutInterrupts.loadBank
    jp   toc_08_4062

toc_01_10E6:
    ld   e, $09
    cbcallNoInterrupts $1E, $602E
    call toc_01_1126
    call toc_01_1134
    cbcallNoInterrupts $07, $5B28
    ld   hl, $DEDE
    set  2, [hl]
    set  1, [hl]
    set  3, [hl]
    set  5, [hl]
    set  6, [hl]
    ld   a, [$A05B]
    inc  a
    ld   [$DEE0], a
    __ifNotZero [$A071], .else_01_111D

    ld   hl, $DEDF
    set  1, [hl]
.else_01_111D:
    assign [gbWX], $07
    assign [gbWY], $80
    ret


toc_01_1126:
    ld   a, $0B
    call cbcallWithoutInterrupts.loadBank
    ld   hl, $68A0
    ld   de, $8000
    jp   decompressHAL

toc_01_1134:
    ld   a, $0B
    call cbcallWithoutInterrupts.loadBank
    plotFromTo $7122, $9630
    ld   a, $0B
    call cbcallWithoutInterrupts.loadBank
    plotFromTo $720F, $8800
.toc_01_1150:
    ld   a, $0B
    call cbcallWithoutInterrupts.loadBank
    plotFromTo $6D87, $8600
    ret


    db   $3E, $07, $CD, $DD, $05, $18, $30

toc_01_1166:
    cbcallNoInterrupts $02, $747D
    ifEq [$A051], $0D, .else_01_1183

    ld   a, $0B
    call cbcallWithoutInterrupts.loadBank
    ld   hl, $6980
    ld   de, $8000
    jp   decompressHAL

.else_01_1183:
    ld   a, $07
    call cbcallWithoutInterrupts.loadBank
    call toc_07_7458
    call .toc_01_1196
    ld   a, $07
    call cbcallWithoutInterrupts.loadBank
    call toc_07_7472
.toc_01_1196:
    ld   a, [$DF11]
    ld   h, $00
    ld   l, a
    ld   b, h
    ld   c, l
    add  hl, hl
    add  hl, bc
    add  hl, hl
    add  hl, bc
    ld   bc, $74BB
    add  hl, bc
    ldi  a, [hl]
    ld   e, a
    ldi  a, [hl]
    ld   d, a
    ldi  a, [hl]
    ld   c, a
    ldi  a, [hl]
    ld   b, a
    ldi  a, [hl]
    ld   [$FF84], a
    push bc
    ldi  a, [hl]
    ld   c, a
    ld   b, [hl]
    pop  hl
    ld   a, [$FF84]
    call cbcallWithoutInterrupts.loadBank
    jp   memcpy

toc_01_11BE:
    clear [$A082]
    ld   [$FFA5], a
    ld   [$FFA6], a
.loop_01_11C6:
    call toc_01_0496
    ld   a, [$A06C]
    rra
    jr   c, .else_01_11D4

    assign [$A05D], $FF
.else_01_11D4:
    call toc_01_086B
    ld   a, $07
    call cbcallWithoutInterrupts.loadBank
    call toc_07_4259
    ld   a, $07
    call cbcallWithoutInterrupts.loadBank
    call toc_07_43CB
    call toc_01_04AE
    cbcallNoInterrupts $07, $5B85
    cbcallNoInterrupts $07, $5BD2
    call toc_01_0343
    call toc_01_0357
    ld   a, [$A082]
    or   a
    jr   nz, .else_01_1219

    ifEq [$DA3A], $02, .else_01_1219

    ld   a, [$DA3F]
    and  %00001011
    jr   z, .else_01_1219

    assign [$A082], $09
.else_01_1219:
    __ifNotZero [$A082], .loop_01_11C6

    ret


    db   $CD, $64, $15, $01, $0E, $00, $09, $3A
    db   $47, $3A, $6E, $67, $78, $CD, $DD, $05
    db   $11, $04, $A0, $1A, $E6, $F0, $CB, $37
    db   $47, $1C, $1A, $CB, $37, $B0, $47, $1E
    db   $07, $1A, $E6, $F0, $CB, $37, $4F, $1C
    db   $1A, $CB, $37, $B1, $4F, $11, $03, $00
    db   $2A, $B8, $20, $06, $2A, $B9, $20, $03
    db   $18, $0D, $23, $2A, $FE, $20, $30, $FB
    db   $FE, $01, $28, $EC, $19, $18, $E9, $E5
    db   $2A, $FE, $60, $1E, $04, $20, $0A, $21
    db   $76, $42, $3E, $1A, $CD, $CF, $05, $18
    db   $08, $21, $80, $42, $3E, $1A, $CD, $CF
    db   $05, $CD, $37, $04, $E1, $C9

toc_01_1286:
    call toc_01_1564
    ldi  a, [hl]
    ld   [$DB3D], a
    ld   c, a
    ldi  a, [hl]
    ld   [$DB3E], a
    push hl
    ld   b, a
    ld   hl, $CD2D
    ld   a, $B3
    jr   .toc_01_129C

.loop_01_129B:
    add  a, c
.toc_01_129C:
    ldi  [hl], a
    dec  b
    jr   nz, .loop_01_129B

    sla  c
    ld   a, [$DB3E]
    ld   b, a
    ld   hl, $CD35
    ld   a, $3D
    jr   .toc_01_12AE

.loop_01_12AD:
    add  a, c
.toc_01_12AE:
    ldi  [hl], a
    dec  b
    jr   nz, .loop_01_12AD

    pop  hl
    ld   c, $04
    ld   de, $DB45
.loop_01_12B8:
    ldi  a, [hl]
    swap a
    ld   b, a
    and  %11110000
    ld   [de], a
    inc  de
    ld   a, b
    and  %00001111
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop_01_12B8

    push hl
    ld   hl, $DB45
    ld   de, $DB3F
    ldi  a, [hl]
    add  a, $08
    ld   [de], a
    inc  de
    ldi  a, [hl]
    adc  $00
    ld   [de], a
    inc  de
    ldi  a, [hl]
    add  a, $08
    ld   [de], a
    inc  de
    ldi  a, [hl]
    adc  $00
    ld   [de], a
    inc  de
    ldi  a, [hl]
    add  a, $98
    ld   [de], a
    inc  de
    ld   a, [hl]
    adc  $00
    ld   [de], a
    pop  hl
    push hl
    ld   bc, $000A
    add  hl, bc
    ld   de, $B300
    call decompressHAL
    pop  hl
    inc  hl
    inc  hl
    push hl
    ldd  a, [hl]
    ld   b, a
    ldd  a, [hl]
    ld   l, [hl]
    ld   h, a
    ld   a, b
    call cbcallWithoutInterrupts.loadBank
    ld   bc, $0003
    add  hl, bc
    push hl
    ldi  a, [hl]
    ld   [$DB5C], a
    ld   de, $CF00
    call decompressHAL
    ld   c, $05
    ld   hl, $CF00
    ld   de, $C500
.loop_01_131C:
    ld   a, [$DB5C]
    ld   b, a
.loop_01_1320:
    ldi  a, [hl]
    ld   [de], a
    inc  e
    dec  b
    jr   nz, .loop_01_1320

    ld   e, $00
    inc  d
    dec  c
    jr   nz, .loop_01_131C

    pop  hl
    dec  hl
    ldd  a, [hl]
    ld   b, a
    ldd  a, [hl]
    ld   l, [hl]
    ld   h, a
    ld   a, b
    ld   [$DB5A], a
    call cbcallWithoutInterrupts.loadBank
    ldi  a, [hl]
    cpl
    inc  a
    swap a
    ld   d, a
    and  %11110000
    ld   e, a
    ld   a, d
    or   %11110000
    ld   d, a
    ld   a, e
    add  a, $30
    ld   e, a
    ld   a, d
    adc  $96
    ld   d, a
    and  %00001111
    or   e
    swap a
    ld   [$DB59], a
    ld   a, l
    ld   [$DB5B], a
    ld   a, h
    ld   [$DB5C], a
    call decompressHAL
    ld   a, [$DB58]
    call cbcallWithoutInterrupts.loadBank
    pop  hl
    push hl
    ld   bc, $0007
    add  hl, bc
    bit  0, [hl]
    ld   a, $86
    jr   z, .else_01_1388

    ld   a, $0C
    call cbcallWithoutInterrupts.loadBank
    plotFromTo $47D1, $8860
    ld   a, d
    and  %00001111
    or   e
    swap a
.else_01_1388:
    ld   [$DB5E], a
    __ifNotZero [$DB73], .else_01_13A3

    pop  hl
    ld   a, [$DB60]
    ld   hl, $14D0
    add  a, a
    add  a, l
    ld   l, a
    jr   nc, .else_01_139E

    inc  h
.else_01_139E:
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    jr   .toc_01_13AE

.else_01_13A3:
    ld   a, [$DB58]
    call cbcallWithoutInterrupts.loadBank
    pop  hl
    ld   bc, $0003
    add  hl, bc
.toc_01_13AE:
    ldd  a, [hl]
    ld   b, a
    ld   [$DB5D], a
    ldd  a, [hl]
    ld   l, [hl]
    ld   h, a
    ld   a, b
    call cbcallWithoutInterrupts.loadBank
    ld   de, $DB7F
.toc_01_13BD:
    ldi  a, [hl]
    cp   $FF
    jp   z, .else_01_1445

    ld   [$FF84], a
    push hl
    ld   l, a
    ld   h, $00
    ld   [de], a
    inc  de
    ld   a, [$DB5E]
    ld   [de], a
    inc  de
    add  hl, hl
    ld   b, h
    ld   c, l
    add  hl, hl
    add  hl, bc
    ld   bc, $5629
    add  hl, bc
    ld   a, $07
    call cbcallWithoutInterrupts.loadBank
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ifNe [$FF84], $13, .else_01_143B

    cp   $14
    jr   z, .else_01_143B

    cp   $15
    jr   z, .else_01_143B

    cp   $16
    jr   z, .else_01_143B

    cp   $1C
    jr   z, .else_01_143B

    cp   $1F
    jr   z, .else_01_143B

    cp   $3E
    jr   z, .else_01_143B

    push de
    inc  hl
    inc  hl
    ldd  a, [hl]
    ld   b, a
    ldd  a, [hl]
    ld   l, [hl]
    ld   h, a
    ld   a, b
    call cbcallWithoutInterrupts.loadBank
    ifEq [$FF84], $11, .else_01_141F

    ld   de, $8D80
    call decompressHAL
    jr   .toc_01_143A

.else_01_141F:
    ld   a, [$DB5E]
    swap a
    ld   d, a
    and  %11110000
    ld   e, a
    ld   a, d
    and  %00001111
    add  a, $80
    ld   d, a
    call decompressHAL
    ld   a, d
    and  %00001111
    or   e
    swap a
    ld   [$DB5E], a
.toc_01_143A:
    pop  de
.else_01_143B:
    pop  hl
    ld   a, [$DB5D]
    call cbcallWithoutInterrupts.loadBank
    jp   .toc_01_13BD

.else_01_1445:
    ld   a, $FF
    ld   [de], a
    ld   b, $00
    ld   de, $CD3D
.toc_01_144D:
    ldi  a, [hl]
    cp   $FF
    jr   z, .else_01_145C

    ld   [de], a
    ld   c, a
    inc  e
    ld   a, b
    ld   [de], a
    inc  e
    add  a, c
    ld   b, a
    jr   .toc_01_144D

.else_01_145C:
    ld   a, b
    ld   [$DB5F], a
    ld   c, $03
    ld   de, $CA00
.loop_01_1465:
    ld   a, [$DB5F]
    ld   b, a
.loop_01_1469:
    ldi  a, [hl]
    ld   [de], a
    inc  e
    dec  b
    jr   nz, .loop_01_1469

    ld   e, $00
    inc  d
    dec  c
    jr   nz, .loop_01_1465

    memsetWithValue $BB00, $0100, $00
    xor  a
    ld   hl, $DB4F
    ldi  [hl], a
    ldi  [hl], a
    ld   de, $A004
    ld   a, [de]
    inc  e
    sub  a, $50
    ldi  [hl], a
    ld   a, [de]
    inc  e
    sbc  $00
    ldi  [hl], a
    inc  e
    ld   a, [de]
    inc  e
    sub  a, $40
    ldi  [hl], a
    ld   a, [de]
    sbc  $00
    ld   [hl], a
    call toc_01_1513
    ld   hl, $DB51
    ldi  a, [hl]
    and  %11110000
    sub  a, $10
    ld   [$DB55], a
    ld   [$DB7D], a
    inc  hl
    ld   a, [hl]
    and  %11110000
    sub  a, $10
    ld   [$DB56], a
    ld   [$DB7E], a
    memsetWithValue $CD56, $0018, $00
    clear [$DB72]
    ld   [$DB70], a
    ld   [$DB71], a
    ret


    db   $DE, $14, $E1, $14, $E4, $14, $E7, $14
    db   $EA, $14, $ED, $14, $2D, $40, $07, $38
    db   $40, $07, $43, $40, $07, $B7, $40, $07
    db   $C2, $40, $07, $D7, $40, $07, $FA, $5A
    db   $DB, $CD, $DD, $05, $FA, $59, $DB, $CB
    db   $7F, $06, $90, $28, $02, $06, $80, $CB
    db   $37, $57, $E6, $F0, $5F, $7A, $E6, $0F
    db   $80, $57, $21, $5B, $DB, $2A, $66, $6F
    db   $C3, $08, $07

toc_01_1513:
    ld   hl, $DB45
    ldi  a, [hl]
    ld   c, a
    ld   b, [hl]
    ld   hl, $DB51
    ldi  a, [hl]
    sub  a, c
    ld   a, [hl]
    sbc  b
    jr   c, .else_01_1526

    bit  7, [hl]
    jr   z, .else_01_1529

.else_01_1526:
    ld   a, b
    ldd  [hl], a
    ld   [hl], c
.else_01_1529:
    ld   hl, $DB49
    ldi  a, [hl]
    ld   c, a
    ld   b, [hl]
    ld   hl, $DB51
    ldi  a, [hl]
    sub  a, c
    ld   a, [hl]
    sbc  b
    jr   c, .else_01_153B

    ld   a, b
    ldd  [hl], a
    ld   [hl], c
.else_01_153B:
    ld   hl, $DB47
    ldi  a, [hl]
    ld   c, a
    ld   b, [hl]
    ld   hl, $DB53
    ldi  a, [hl]
    sub  a, c
    ld   a, [hl]
    sbc  b
    jr   c, .else_01_154E

    bit  7, [hl]
    jr   z, .else_01_1551

.else_01_154E:
    ld   a, b
    ldd  [hl], a
    ld   [hl], c
.else_01_1551:
    ld   hl, $DB4B
    ldi  a, [hl]
    ld   c, a
    ld   b, [hl]
    ld   hl, $DB53
    ldi  a, [hl]
    sub  a, c
    ld   a, [hl]
    sbc  b
    jr   c, .return_01_1563

    ld   a, b
    ldd  [hl], a
    ld   [hl], c
.return_01_1563:
    ret


toc_01_1564:
    ld   a, $08
    call cbcallWithoutInterrupts.loadBank
    ld   a, [$DB57]
    ld   l, a
    ld   h, $00
    ld   b, h
    ld   c, l
    add  hl, hl
    add  hl, bc
    ld   bc, $511F
    add  hl, bc
    ldd  a, [hl]
    ld   b, a
    ld   [$DB58], a
    ldd  a, [hl]
    ld   l, [hl]
    ld   h, a
    ld   a, b
    call cbcallWithoutInterrupts.loadBank
    ret


toc_01_1584:
    xor  a
    ld   hl, gbSCY
    ldi  [hl], a
    ld   [hl], a
    ld   hl, $DA00
    ldi  [hl], a
    ld   [hl], a
    ld   hl, $DB51
    ldi  [hl], a
    ldi  [hl], a
    ldi  [hl], a
    ld   [hl], a
    ret


    db   $E0, $80, $F0, $A4, $F5, $3E, $07, $CD
    db   $DD, $05, $CD, $7B, $43, $F1, $C3, $DD
    db   $05, $E0, $84, $CD, $E3, $15, $F0, $84
    db   $77, $CD, $FC, $15, $54, $5D, $FA, $22
    db   $DA, $6F, $FA, $28, $DA, $67, $73, $2C
    db   $72, $2C, $F0, $84, $4F, $06, $C5, $0A
    db   $22, $04, $0A, $22, $04, $0A, $22, $04
    db   $0A, $22, $7D, $EA, $22, $DA, $FA, $28
    db   $DA, $21, $23, $DA, $1F, $30, $03, $21
    db   $24, $DA, $34, $C9

toc_01_15E3:
    ld   hl, $CD2D
    ld   a, d
    add  a, l
    ld   l, a
    ld   a, [hl]
    add  a, b
    ld   h, a
    ld   [$FF9D], a
    ld   a, e
    and  %11110000
    ld   l, a
    ld   a, c
    swap a
    and  %00001111
    add  a, l
    ld   l, a
    ld   [$FF9C], a
    ret


toc_01_15FC:
    ld   a, e
    ld   h, $26
    rla
    rl   h
    rla
    rl   h
    and  %11000000
    ld   l, a
    ld   a, c
    rra
    rra
    rra
    and  %00011110
    add  a, l
    ld   l, a
    ret


toc_01_1611:
    ld   [$FF84], a
    ld   hl, $DB62
    add  a, l
    ld   l, a
    jr   nc, .else_01_161B

    inc  h
.else_01_161B:
    ld   e, [hl]
    ld   a, [$FF84]
    ld   hl, $163E
    add  a, l
    ld   l, a
    jr   nc, .else_01_1626

    inc  h
.else_01_1626:
    ld   a, [hl]
    or   e
    inc  a
    ret


toc_01_162A:
    ld   [$FF84], a
    ld   a, e
    call toc_01_0663
    ld   e, a
    ld   a, [$FF84]
    ld   hl, $DB62
    add  a, l
    ld   l, a
    jr   nc, .else_01_163B

    inc  h
.else_01_163B:
    ld   a, [hl]
    and  e
    ret


    db   $F8, $F8, $F8, $F0, $E0, $C0, $80, $FF
    db   $FA, $3D, $DB, $3D, $B8, $38, $0F, $FA
    db   $3E, $DB, $3D, $BA, $38, $08, $CD, $E3
    db   $15, $6E, $26, $C9, $7E, $C9, $AF, $21
    db   $9C, $FF, $22, $77, $3E, $00, $C9, $21
    db   $9C, $FF, $2A, $66, $6F, $B4, $28, $16
    db   $7D, $D6, $10, $6F, $30, $0B, $7A, $B7
    db   $28, $0C, $FA, $3D, $DB, $2F, $3C, $84
    db   $67, $6E, $26, $C9, $7E, $C9, $3E, $00
    db   $C9, $21, $9C, $FF, $2A, $66, $6F, $B4
    db   $28, $17, $7D, $C6, $10, $6F, $30, $0C
    db   $FA, $3E, $DB, $3D, $BA, $28, $0A, $FA
    db   $3D, $DB, $84, $67, $6E, $26, $C9, $7E
    db   $C9, $3E, $00, $C9, $21, $9C, $FF, $2A
    db   $66, $6F, $B4, $28, $17, $2C, $7D, $E6
    db   $0F, $20, $0C, $FA, $3D, $DB, $3D, $B8
    db   $28, $0A, $7D, $D6, $10, $6F, $24, $6E
    db   $26, $C9, $7E, $C9, $3E, $00, $C9, $21
    db   $9C, $FF, $2A, $66, $6F, $B4, $28, $16
    db   $2D, $7D, $E6, $0F, $FE, $0F, $20, $09
    db   $78, $B7, $28, $0A, $7D, $C6, $10, $6F
    db   $25, $6E, $26, $C9, $7E, $C9, $3E, $00
    db   $C9, $CD, $46, $16, $E6, $07, $E0, $9E
    db   $FE, $01, $28, $02, $A7, $C9, $CD, $AA
    db   $16, $E6, $07, $FE, $01, $38, $06, $28
    db   $0D, $FE, $04, $30, $09, $79, $E6, $0F
    db   $6F, $3E, $10, $95, $37, $C9, $A7, $C9
    db   $CD, $46, $16, $E6, $07, $E0, $9E, $21
    db   $2A, $17, $87, $85, $6F, $30, $01, $24
    db   $2A, $66, $6F, $E9, $52, $17, $54, $17
    db   $52, $17, $52, $17, $52, $17, $3A, $17
    db   $52, $17, $44, $17, $79, $E6, $0F, $6F
    db   $7B, $E6, $0F, $95, $37, $C9, $79, $E6
    db   $0F, $6F, $7B, $E6, $0F, $67, $3E, $0F
    db   $94, $95, $37, $C9, $A7, $C9, $CD, $AA
    db   $16, $E6, $07, $21, $66, $17, $87, $85
    db   $6F, $30, $01, $24, $2A, $66, $6F, $E9
    db   $98, $17, $A1, $17, $98, $17, $98, $17
    db   $98, $17, $76, $17, $98, $17, $86, $17
    db   $3E, $05, $E0, $9E, $79, $E6, $0F, $6F
    db   $7B, $E6, $0F, $C6, $10, $95, $37, $C9
    db   $3E, $07, $E0, $9E, $79, $E6, $0F, $6F
    db   $7B, $E6, $0F, $67, $3E, $1F, $94, $95
    db   $37, $C9, $79, $E6, $0F, $6F, $3E, $10
    db   $95, $37, $C9, $A7, $C9, $CD, $46, $16
    db   $E6, $07, $E0, $9E, $FE, $01, $28, $02
    db   $A7, $C9, $CD, $CD, $16, $E6, $07, $FE
    db   $01, $38, $06, $28, $0A, $FE, $04, $30
    db   $06, $79, $E6, $0F, $2F, $37, $C9, $A7
    db   $C9, $CD, $46, $16, $E6, $07, $E0, $9E
    db   $21, $DB, $17, $87, $85, $6F, $30, $01
    db   $24, $2A, $66, $6F, $E9, $03, $18, $05
    db   $18, $03, $18, $03, $18, $EB, $17, $03
    db   $18, $F9, $17, $03, $18, $79, $E6, $0F
    db   $6F, $7B, $E6, $0F, $67, $3E, $0F, $94
    db   $95, $37, $C9, $79, $E6, $0F, $6F, $7B
    db   $E6, $0F, $95, $37, $C9, $A7, $C9, $CD
    db   $CD, $16, $E6, $07, $21, $17, $18, $87
    db   $85, $6F, $30, $01, $24, $2A, $66, $6F
    db   $E9, $46, $18, $4C, $18, $46, $18, $46
    db   $18, $27, $18, $46, $18, $36, $18, $46
    db   $18, $3E, $05, $E0, $9E, $79, $E6, $0F
    db   $6F, $7B, $E6, $0F, $2F, $95, $37, $C9
    db   $3E, $07, $E0, $9E, $79, $E6, $0F, $6F
    db   $7B, $E6, $0F, $D6, $10, $95, $37, $C9
    db   $79, $E6, $0F, $2F, $37, $C9, $A7, $C9
    db   $CD, $46, $16, $E0, $9F, $E6, $07, $E0
    db   $9E, $21, $64, $18, $87, $85, $6F, $30
    db   $01, $24, $2A, $66, $6F, $E9, $8C, $18
    db   $8E, $18, $8E, $18, $8E, $18, $74, $18
    db   $82, $18, $8E, $18, $8E, $18, $79, $E6
    db   $0F, $6F, $7B, $E6, $0F, $67, $3E, $0F
    db   $95, $94, $37, $C9, $7B, $E6, $0F, $67
    db   $79, $E6, $0F, $94, $37, $C9, $A7, $C9
    db   $CD, $65, $16, $E6, $07, $21, $A0, $18
    db   $87, $85, $6F, $30, $01, $24, $2A, $66
    db   $6F, $E9, $B0, $18, $B6, $18, $B0, $18
    db   $B0, $18, $B8, $18, $C7, $18, $B0, $18
    db   $B0, $18, $7B, $E6, $0F, $2F, $37, $C9
    db   $A7, $C9, $3E, $04, $E0, $9E, $7B, $E6
    db   $0F, $67, $79, $E6, $0F, $2F, $94, $37
    db   $C9, $3E, $05, $E0, $9E, $7B, $E6, $0F
    db   $67, $79, $E6, $0F, $D6, $10, $94, $37
    db   $C9, $CD, $46, $16, $E6, $07, $E0, $9E
    db   $21, $EB, $18, $87, $85, $6F, $30, $01
    db   $24, $2A, $66, $6F, $E9, $13, $19, $15
    db   $19, $13, $19, $13, $19, $13, $19, $13
    db   $19, $FB, $18, $05, $19, $7B, $E6, $0F
    db   $67, $79, $E6, $0F, $94, $37, $C9, $79
    db   $E6, $0F, $6F, $7B, $E6, $0F, $67, $3E
    db   $0F, $95, $94, $37, $C9, $A7, $C9, $CD
    db   $87, $16, $E6, $07, $21, $27, $19, $87
    db   $85, $6F, $30, $01, $24, $2A, $66, $6F
    db   $E9, $37, $19, $40, $19, $37, $19, $37
    db   $19, $37, $19, $37, $19, $42, $19, $52
    db   $19, $7B, $E6, $0F, $67, $3E, $10, $94
    db   $37, $C9, $A7, $C9, $3E, $06, $E0, $9E
    db   $7B, $E6, $0F, $67, $79, $E6, $0F, $C6
    db   $10, $94, $37, $C9, $3E, $07, $E0, $9E
    db   $79, $E6, $0F, $6F, $7B, $E6, $0F, $67
    db   $3E, $1F, $95, $94, $37, $C9, $AF, $E0
    db   $AD, $21, $AF, $FF, $3E, $06, $22, $3E
    db   $F9, $22, $3E, $06, $22, $CD, $F6, $1A
    db   $21, $AD, $FF, $38, $02, $CB, $FE, $7E
    db   $C9, $CD, $EA, $1A, $2E, $0F, $2A, $B6
    db   $28, $1D, $CB, $7E, $20, $0A, $CD, $4E
    db   $18, $30, $0E, $07, $38, $32, $18, $09
    db   $CD, $D7, $18, $30, $04, $3D, $07, $30
    db   $27, $F0, $9E, $FE, $01, $28, $21, $F0
    db   $9A, $67, $2E, $0E, $CB, $7E, $20, $0A
    db   $CD, $C7, $17, $30, $0E, $07, $38, $10
    db   $18, $09, $CD, $16, $17, $30, $04, $3D
    db   $07, $30, $05, $F0, $9A, $57, $A7, $C9
    db   $F0, $9A, $57, $37, $C9, $AF, $E0, $AD
    db   $21, $AE, $FF, $3E, $F9, $22, $3E, $06
    db   $22, $3E, $F9, $22, $3E, $06, $22, $CD
    db   $8B, $1D, $30, $05, $21, $AD, $FF, $CB
    db   $EE, $CD, $61, $1B, $21, $AD, $FF, $38
    db   $02, $CB, $FE, $7E, $C9, $AF, $E0, $AD
    db   $21, $AE, $FF, $3E, $F9, $22, $3E, $06
    db   $22, $3E, $F9, $22, $3E, $06, $22, $CD
    db   $8B, $1D, $30, $05, $21, $AD, $FF, $CB
    db   $EE, $CD, $61, $1B, $21, $AD, $FF, $38
    db   $0C, $CB, $FE, $CD, $DA, $1B, $21, $AD
    db   $FF, $38, $02, $CB, $E6, $7E, $C9, $AF
    db   $E0, $AD, $21, $AE, $FF, $3E, $F9, $22
    db   $3E, $06, $22, $3E, $F9, $22, $3E, $06
    db   $22, $3E, $0D, $22, $CD, $C7, $1D, $30
    db   $05, $21, $AD, $FF, $CB, $EE, $1E, $10
    db   $1A, $17, $30, $0C, $CD, $0A, $1C, $21
    db   $AD, $FF, $30, $0E, $CB, $F6, $18, $0A
    db   $CD, $88, $1C, $21, $AD, $FF, $30, $02
    db   $CB, $FE, $7E, $C9, $AF, $E0, $AD, $21
    db   $AE, $FF, $3E, $F9, $22, $3E, $06, $22
    db   $3E, $F9, $22, $3E, $06, $22, $3E, $0D
    db   $22, $CD, $C7, $1D, $30, $05, $21, $AD
    db   $FF, $CB, $EE, $CD, $0A, $1C, $30, $05
    db   $21, $AD, $FF, $CB, $F6, $CD, $88, $1C
    db   $21, $AD, $FF, $30, $02, $CB, $FE, $7E
    db   $C9, $CD, $EA, $1A, $CD, $46, $16, $E6
    db   $7F, $FE, $08, $F0, $9A, $57, $C9, $C5
    db   $CD, $B3, $1A, $1E, $27, $3E, $00, $20
    db   $01, $3C, $12, $C1, $C9, $CD, $EA, $1A
    db   $CD, $46, $16, $E6, $C0, $FE, $80, $F0
    db   $9A, $57, $C9, $62, $AF, $47, $4F, $CB
    db   $7B, $28, $01, $2F, $57, $CD, $D9, $1A
    db   $CD, $46, $16, $E6, $C0, $FE, $80, $F0
    db   $9A, $57, $C9, $2E, $04, $2A, $81, $4F
    db   $7E, $88, $47, $2E, $07, $2A, $83, $5F
    db   $7E, $8A, $57, $C9, $62, $2E, $04, $2A
    db   $4F, $46, $2E, $07, $2A, $5F, $56, $C9
    db   $62, $F0, $AF, $3C, $5F, $17, $9F, $57
    db   $06, $00, $48, $CD, $D9, $1A, $CD, $4E
    db   $18, $38, $46, $CB, $59, $28, $1B, $F0
    db   $B1, $6F, $17, $9F, $67, $09, $44, $4D
    db   $CD, $4E, $18, $30, $2A, $6F, $F0, $9E
    db   $FE, $04, $7D, $38, $2C, $F0, $B1, $85
    db   $18, $27, $F0, $B0, $6F, $17, $9F, $67
    db   $09, $44, $4D, $CD, $4E, $18, $30, $0F
    db   $6F, $F0, $9E, $FE, $04, $7D, $38, $11
    db   $F0, $B0, $2F, $37, $8D, $18, $0A, $F0
    db   $9A, $57, $1E, $4D, $3E, $00, $12, $37
    db   $C9, $3C, $20, $F3, $F0, $9A, $57, $F0
    db   $9E, $1E, $4D, $12, $F0, $9F, $1E, $4E
    db   $12, $A7, $C9, $62, $F0, $AF, $3C, $5F
    db   $17, $9F, $57, $06, $00, $48, $CD, $D9
    db   $1A, $CD, $4E, $18, $38, $46, $CB, $59
    db   $28, $1B, $F0, $B1, $6F, $17, $9F, $67
    db   $09, $44, $4D, $CD, $4E, $18, $30, $2A
    db   $6F, $F0, $9E, $FE, $04, $7D, $38, $2C
    db   $F0, $B1, $85, $18, $27, $F0, $B0, $6F
    db   $17, $9F, $67, $09, $44, $4D, $CD, $4E
    db   $18, $30, $0F, $6F, $F0, $9E, $FE, $04
    db   $7D, $38, $11, $F0, $B0, $2F, $37, $8D
    db   $18, $0A, $F0, $9A, $57, $1E, $4D, $3E
    db   $00, $12, $37, $C9, $3C, $6F, $07, $9F
    db   $47, $F0, $9A, $67, $7D, $2E, $06, $36
    db   $80, $2C, $86, $22, $78, $8E, $77, $F0
    db   $9E, $2E, $4D, $77, $F0, $9F, $2E, $4E
    db   $77, $54, $A7, $C9, $62, $F0, $AF, $3C
    db   $5F, $17, $9F, $57, $2E, $4D, $7E, $FE
    db   $04, $30, $08, $2E, $0E, $CB, $7E, $28
    db   $07, $18, $09, $06, $00, $48, $18, $0A
    db   $F0, $B1, $18, $02, $F0, $B0, $4F, $17
    db   $9F, $47, $CD, $D9, $1A, $CD, $4E, $18
    db   $F0, $9A, $57, $C9, $62, $F0, $AE, $5F
    db   $17, $9F, $57, $06, $00, $48, $CD, $D9
    db   $1A, $CD, $D7, $18, $30, $08, $6F, $3D
    db   $07, $30, $55, $C3, $6D, $1E, $CB, $59
    db   $28, $29, $F0, $B1, $6F, $17, $9F, $67
    db   $09, $44, $4D, $CD, $D7, $18, $D2, $6D
    db   $1E, $6F, $F0, $9E, $FE, $07, $CA, $6D
    db   $1E, $FE, $06, $7D, $20, $06, $F0, $B1
    db   $2F, $37, $8D, $6F, $3D, $07, $30, $28
    db   $C3, $6D, $1E, $F0, $B0, $6F, $17, $9F
    db   $67, $09, $44, $4D, $CD, $D7, $18, $D2
    db   $6D, $1E, $6F, $F0, $9E, $FE, $06, $CA
    db   $6D, $1E, $FE, $07, $7D, $20, $04, $F0
    db   $B0, $85, $6F, $3D, $07, $DA, $6D, $1E
    db   $F0, $9A, $67, $7D, $2E, $06, $36, $80
    db   $2C, $86, $22, $3E, $00, $8E, $77, $54
    db   $37, $C9, $AF, $EA, $7C, $DB, $62, $F0
    db   $AF, $5F, $17, $9F, $57, $06, $00, $48
    db   $CD, $D9, $1A, $CD, $4E, $18, $30, $0E
    db   $6F, $07, $38, $64, $F0, $9A, $57, $1E
    db   $4D, $F0, $9E, $12, $18, $52, $CB, $59
    db   $28, $23, $F0, $B1, $6F, $17, $9F, $67
    db   $09, $44, $4D, $CD, $4E, $18, $30, $38
    db   $6F, $F0, $9E, $FE, $05, $28, $31, $FE
    db   $04, $7D, $20, $04, $F0, $B1, $85, $6F
    db   $07, $38, $67, $18, $23, $F0, $B0, $6F
    db   $17, $9F, $67, $09, $44, $4D, $CD, $4E
    db   $18, $30, $15, $6F, $F0, $9E, $FE, $04
    db   $28, $0E, $FE, $05, $7D, $20, $06, $F0
    db   $B0, $2F, $37, $8D, $6F, $07, $38, $42
    db   $F0, $9A, $67, $57, $2E, $4D, $36, $00
    db   $1E, $4F, $FA, $7C, $DB, $12, $A7, $C9
    db   $3E, $01, $EA, $7C, $DB, $F0, $9A, $67
    db   $4D, $2E, $4D, $7E, $FE, $04, $30, $58
    db   $F0, $9E, $1E, $00, $FE, $04, $38, $3C
    db   $2E, $4F, $CB, $46, $20, $18, $2E, $06
    db   $46, $2E, $0F, $2A, $37, $98, $7E, $DE
    db   $FF, $CB, $7F, $20, $09, $81, $30, $06
    db   $18, $36, $F0, $9A, $67, $4D, $F0, $9E
    db   $FE, $04, $1E, $00, $38, $16, $2E, $03
    db   $46, $2E, $0D, $2A, $28, $08, $37, $98
    db   $7E, $DE, $00, $2F, $18, $05, $37, $98
    db   $7E, $DE, $FF, $5F, $2E, $06, $46, $2E
    db   $0F, $2A, $37, $98, $7E, $DE, $FF, $83
    db   $CB, $7F, $20, $8C, $81, $D2, $F6, $1C
    db   $2E, $06, $36, $80, $2C, $79, $86, $22
    db   $3E, $FF, $8E, $77, $F0, $9E, $2E, $4D
    db   $77, $F0, $9F, $2E, $4E, $77, $2E, $4F
    db   $36, $00, $54, $37, $C9, $62, $2E, $0E
    db   $F0, $AE, $5F, $17, $9F, $57, $CB, $7E
    db   $20, $17, $F0, $B1, $4F, $17, $9F, $47
    db   $CD, $D9, $1A, $CD, $A3, $17, $D2, $6D
    db   $1E, $6F, $07, $DA, $2A, $1E, $C3, $6D
    db   $1E, $F0, $B0, $4F, $17, $9F, $47, $CD
    db   $D9, $1A, $CD, $EF, $16, $D2, $6D, $1E
    db   $6F, $3D, $07, $D2, $4C, $1E, $C3, $6D
    db   $1E, $62, $2E, $0E, $F0, $AE, $5F, $17
    db   $9F, $57, $CB, $7E, $20, $2A, $F0, $B1
    db   $4F, $17, $9F, $47, $CD, $D9, $1A, $CD
    db   $A3, $17, $30, $05, $6F, $07, $DA, $2A
    db   $1E, $F0, $B2, $6F, $17, $9F, $67, $19
    db   $54, $5D, $CD, $A3, $17, $D2, $6D, $1E
    db   $6F, $07, $DA, $2A, $1E, $C3, $6D, $1E
    db   $F0, $B0, $4F, $17, $9F, $47, $CD, $D9
    db   $1A, $CD, $EF, $16, $30, $06, $6F, $3D
    db   $07, $D2, $4C, $1E, $F0, $B2, $6F, $17
    db   $9F, $67, $19, $54, $5D, $CD, $EF, $16
    db   $D2, $6D, $1E, $6F, $3D, $07, $D2, $4C
    db   $1E, $C3, $6D, $1E, $4D, $F0, $9A, $67
    db   $2E, $03, $46, $2E, $0D, $2A, $37, $98
    db   $7E, $DE, $FF, $81, $D2, $6D, $1E, $2E
    db   $03, $36, $80, $2C, $79, $86, $22, $3E
    db   $FF, $8E, $77, $54, $37, $C9, $4D, $F0
    db   $9A, $67, $2E, $03, $46, $2E, $0D, $2A
    db   $37, $98, $7E, $DE, $00, $81, $38, $0F
    db   $2E, $03, $36, $80, $2C, $79, $86, $22
    db   $3E, $00, $8E, $77, $54, $37, $C9, $F0
    db   $9A, $57, $A7, $C9, $1E, $04, $21, $51
    db   $DB, $1A, $96, $4F, $1C, $23, $1A, $9E
    db   $1E, $0A, $12, $1D, $79, $12, $1E, $45
    db   $1A, $07, $1E, $0A, $1A, $38, $18, $07
    db   $DA, $F6, $0D, $0F, $47, $1D, $1A, $D6
    db   $AC, $78, $DE, $00, $DA, $F6, $0D, $1E
    db   $05, $01, $EB, $40, $C3, $46, $08, $07
    db   $D2, $F6, $0D, $1D, $1A, $FE, $F4, $38
    db   $EE, $C3, $F6, $0D, $FF, $02, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $1E, $04, $6B, $26, $A0, $1A
    db   $96, $1C, $2C, $1A, $9E, $1E, $45, $E6
    db   $80, $EE, $C0, $12, $C9, $62, $2E, $12
    db   $7E, $B7, $C8, $2E, $0F, $4F, $07, $9F
    db   $47, $7E, $81, $22, $7E, $88, $77, $C9
    db   $62, $2E, $11, $7E, $B7, $C8, $2E, $0D
    db   $4F, $07, $9F, $47, $7E, $81, $22, $7E
    db   $88, $77, $C9, $1E, $45, $1A, $2F, $3C
    db   $12, $1E, $0D, $1A, $2F, $C6, $01, $12
    db   $1C, $1A, $2F, $CE, $00, $12, $C9, $21
    db   $2C, $DD, $7E, $CB, $57, $C9, $D5, $C5
    db   $1E, $04, $6B, $26, $A0, $1A, $4F, $1C
    db   $1A, $47, $5E, $2C, $56, $79, $93, $78
    db   $9A, $38, $12, $79, $93, $5F, $78, $BA
    db   $28, $04, $3E, $FF, $83, $5F, $7B, $C1
    db   $D1, $B8, $D0, $18, $10, $7B, $91, $4F
    db   $7A, $B8, $28, $04, $3E, $FF, $81, $4F
    db   $79, $C1, $D1, $B8, $D0, $D5, $C5, $1E
    db   $07, $6B, $26, $A0, $1A, $4F, $1C, $1A
    db   $47, $5E, $2C, $56, $79, $93, $78, $9A
    db   $38, $10, $79, $93, $4F, $78, $BA, $28
    db   $04, $3E, $FF, $81, $4F, $79, $C1, $D1
    db   $B9, $C9, $7B, $91, $5F, $78, $BA, $28
    db   $04, $3E, $FF, $83, $5F, $7B, $C1, $D1
    db   $B9, $C9, $C5, $CD, $64, $19, $E6, $80
    db   $1E, $27, $12, $CD, $35, $22, $1E, $40
    db   $12, $C1, $C9, $C5, $CD, $64, $19, $E6
    db   $80, $1E, $27, $12, $C1, $C9, $26, $A0
    db   $6B, $1A, $96, $4F, $2C, $1C, $1A, $9E
    db   $30, $04, $79, $2F, $3C, $4F, $79, $B8
    db   $C9, $1E, $0F, $1A, $2F, $C6, $01, $12
    db   $1C, $1A, $2F, $CE, $00, $12, $C9, $1E
    db   $0D, $1A, $2F, $C6, $01, $12, $1C, $1A
    db   $2F, $CE, $00, $12, $1E, $45, $1A, $2F
    db   $3C, $12, $C9, $0A, $03, $62, $2E, $45
    db   $CB, $7E, $28, $02, $2F, $3C, $6F, $17
    db   $9F, $67, $1E, $04, $1A, $85, $12, $1C
    db   $1A, $8C, $12, $0A, $03, $6F, $17, $9F
    db   $67, $1E, $07, $1A, $85, $12, $1C, $1A
    db   $8C, $12, $C9, $1E, $48, $1A, $67, $1E
    db   $46, $6B, $7E, $12, $C9, $FA, $4A, $DA
    db   $A7, $C8, $67, $1E, $46, $6B, $1A, $77
    db   $C9, $1E, $5E, $0A, $12, $03, $1C, $0A
    db   $12, $03, $1C, $0A, $12, $03, $C9, $CD
    db   $2B, $20, $1E, $27, $30, $04, $3E, $01
    db   $12, $C9, $AF, $12, $C9, $1E, $07, $6B
    db   $26, $A0, $1A, $96, $1C, $2C, $1A, $9E
    db   $C9, $CD, $3D, $20, $C3, $20, $20, $1E
    db   $04, $C3, $2D, $20, $0A, $6F, $03, $0A
    db   $67, $03, $1E, $5C, $1A, $5F, $07, $83
    db   $85, $6F, $30, $01, $24, $1E, $12, $2A
    db   $12, $1E, $39, $2A, $12, $1C, $2A, $12
    db   $C9, $0A, $6F, $03, $0A, $67, $03, $C3
    db   $53, $20, $0A, $6F, $03, $0A, $67, $03
    db   $1E, $5C, $1A, $5F, $87, $83, $85, $30
    db   $01, $24, $6F, $C3, $53, $20, $0A, $6F
    db   $03, $0A, $67, $03, $1E, $0F, $2A, $12
    db   $1E, $3D, $12, $7E, $1C, $12, $1E, $10
    db   $12, $C9, $0A, $6F, $03, $0A, $67, $03
    db   $1E, $5C, $1A, $87, $85, $30, $01, $24
    db   $6F, $1E, $0F, $2A, $12, $1E, $3D, $12
    db   $7E, $1C, $12, $1E, $10, $12, $C9, $0A
    db   $6F, $03, $0A, $67, $03, $1E, $5C, $1A
    db   $5F, $07, $83, $85, $6F, $30, $01, $24
    db   $1E, $0F, $2A, $12, $1C, $2A, $12, $1E
    db   $12, $2A, $12, $C9, $0A, $6F, $03, $0A
    db   $67, $03, $C3, $BE, $20, $0A, $6F, $03
    db   $0A, $67, $03, $C3, $F0, $20, $0A, $6F
    db   $03, $0A, $67, $03, $C3, $E5, $20, $1E
    db   $27, $1A, $87, $85, $6F, $30, $0C, $24
    db   $18, $09, $1E, $5C, $1A, $07, $85, $6F
    db   $30, $01, $24, $1E, $45, $1A, $07, $38
    db   $08, $1E, $0D, $2A, $12, $1C, $2A, $12
    db   $C9, $1E, $0D, $2A, $2F, $C6, $01, $12
    db   $1C, $2A, $2F, $CE, $00, $12, $C9, $0A
    db   $6F, $03, $0A, $67, $03, $1E, $5C, $1A
    db   $85, $6F, $30, $01, $24, $1E, $45, $1A
    db   $07, $1E, $11, $2A, $38, $02, $12, $C9
    db   $2F, $3C, $12, $C9, $0A, $6F, $03, $0A
    db   $67, $03, $18, $15, $0A, $6F, $03, $0A
    db   $67, $03, $1E, $5C, $1A, $5F, $07, $83
    db   $85, $6F, $D2, $64, $21, $24, $C3, $64
    db   $21, $1E, $27, $1A, $5F, $07, $83, $85
    db   $6F, $D2, $64, $21, $24, $C3, $64, $21
    db   $0A, $6F, $03, $0A, $67, $03, $1E, $45
    db   $1A, $07, $30, $14, $1E, $11, $2A, $2F
    db   $3C, $12, $1E, $3B, $2A, $2F, $C6, $01
    db   $12, $1C, $2A, $2F, $CE, $00, $12, $C9
    db   $2A, $1E, $11, $12, $1E, $3B, $2A, $12
    db   $1C, $2A, $12, $C9, $0A, $6F, $03, $0A
    db   $67, $03, $1E, $5C, $1A, $5F, $07, $83
    db   $85, $6F, $D2, $A5, $21, $24, $C3, $A5
    db   $21, $0A, $6F, $03, $0A, $67, $03, $1E
    db   $11, $2A, $12, $1E, $45, $1A, $07, $30
    db   $0E, $1E, $3B, $2A, $2F, $C6, $01, $12
    db   $1C, $2A, $2F, $CE, $00, $12, $C9, $1E
    db   $3B, $2A, $12, $1C, $2A, $12, $C9, $62
    db   $2E, $11, $5E, $2E, $3B, $4E, $2C, $46
    db   $CB, $78, $20, $03, $C3, $B4, $0C, $C3
    db   $EF, $0C, $62, $2E, $12, $5E, $2E, $39
    db   $4E, $2C, $46, $CB, $78, $20, $03, $C3
    db   $35, $0D, $C3, $70, $0D, $62, $2E, $12
    db   $5E, $2E, $39, $4E, $2C, $46, $C3, $35
    db   $0D, $62, $2E, $12, $5E, $2E, $39, $4E
    db   $2C, $46, $C3, $70, $0D, $0A, $03, $C5
    db   $1E, $07, $26, $A0, $6B, $4F, $07, $38
    db   $11, $1A, $81, $4F, $1C, $1A, $CE, $00
    db   $47, $2A, $91, $7E, $98, $30, $11, $AF
    db   $18, $10, $1A, $81, $4F, $1C, $1A, $CE
    db   $FF, $47, $2A, $91, $7E, $98, $30, $EF
    db   $3E, $01, $1E, $27, $12, $C1, $C9, $1E
    db   $4D, $1A, $FE, $04, $28, $06, $FE, $05
    db   $28, $02, $AF, $C9, $3E, $01, $C9, $0A
    db   $6F, $03, $0A, $67, $03, $1E, $5C, $1A
    db   $85, $6F, $30, $01, $24, $1E, $24, $7E
    db   $12, $C9, $1E, $12, $1A, $2F, $3C, $12
    db   $C9, $26, $A0, $2E, $86, $1E, $4C, $1A
    db   $77, $21, $DF, $DE, $CB, $C6, $21, $E4
    db   $DE, $36, $00, $C9, $26, $A0, $1E, $4C
    db   $2E, $85, $1A, $77, $C9, $26, $A0, $AF
    db   $2E, $85, $77, $C9, $21, $DF, $DE, $CB
    db   $86, $21, $DE, $DE, $CB, $C6, $C9, $26
    db   $A5, $0E, $03, $C5, $2E, $00, $7E, $FE
    db   $FF, $28, $1B, $2E, $4C, $7E, $B7, $28
    db   $15, $1E, $04, $06, $28, $CD, $9E, $1F
    db   $30, $0C, $1E, $07, $06, $20, $CD, $9E
    db   $1F, $30, $03, $C1, $37, $C9, $C1, $0D
    db   $C8, $24, $18, $D7, $60, $69, $2A, $E0
    db   $84, $01, $B2, $A8, $2A, $F5, $D5, $E5
    db   $CD, $67, $0F, $C1, $D1, $7C, $B7, $28
    db   $15, $2E, $48, $72, $5D, $7C, $12, $1E
    db   $45, $6B, $1A, $77, $1E, $5C, $6B, $1A
    db   $77, $F1, $2E, $5B, $77, $C9, $F1, $C9
    db   $60, $69, $2A, $E0, $84, $01, $B2, $A8
    db   $2A, $F5, $D5, $E5, $CD, $67, $0F, $C1
    db   $D1, $7C, $B7, $28, $12, $2E, $48, $72
    db   $1E, $45, $6B, $1A, $77, $1E, $5C, $6B
    db   $1A, $77, $F1, $2E, $5B, $77, $C9, $F1
    db   $C9, $21, $84, $FF, $73, $01, $B2, $A8
    db   $C3, $C3, $22, $21, $84, $FF, $73, $01
    db   $B2, $A8, $C3, $EF, $22, $01, $B2, $1E
    db   $CD, $5B, $25, $1E, $41, $1A, $B7, $C0
    db   $CD, $71, $0C, $62, $2E, $60, $36, $3F
    db   $2E, $44, $36, $18, $AF, $C9, $1E, $44
    db   $1A, $CB, $7F, $20, $05, $D6, $01, $12
    db   $38, $18, $CD, $5B, $25, $FA, $2C, $DD
    db   $CB, $4F, $20, $0B, $CB, $47, $20, $02
    db   $AF, $C9, $CD, $61, $0C, $37, $C9, $E1
    db   $37, $C9, $2E, $60, $62, $36, $2D, $18
    db   $E1, $C5, $1E, $08, $01, $10, $64, $CD
    db   $3A, $0C, $F0, $9A, $57, $C1, $C9, $1E
    db   $F8, $CD, $C1, $1A, $C0, $1E, $03, $01
    db   $53, $4D, $CD, $46, $08, $E1, $C9, $CD
    db   $97, $1A, $C0, $1E, $03, $01, $33, $4E
    db   $CD, $46, $08, $E1, $C9, $1E, $48, $1A
    db   $67, $0A, $5F, $03, $0A, $6F, $03, $0A
    db   $03, $C5, $47, $4D, $2E, $00, $7E, $FE
    db   $FF, $28, $03, $CD, $49, $08, $C1, $C9
    db   $1E, $48, $1A, $67, $2E, $21, $0A, $32
    db   $03, $0A, $32, $03, $0A, $77, $03, $C9
    db   $0A, $6F, $03, $0A, $67, $03, $C5, $CD
    db   $CA, $23, $C1, $C9, $1E, $40, $1A, $07
    db   $07, $4F, $1E, $5C, $1A, $07, $81, $85
    db   $6F, $30, $01, $24, $4E, $23, $46, $1E
    db   $45, $1A, $07, $30, $0A, $79, $2F, $C6
    db   $01, $4F, $78, $2F, $CE, $00, $47, $62
    db   $2E, $0D, $71, $2C, $70, $C9, $0A, $6F
    db   $03, $0A, $67, $03, $1E, $5C, $1A, $85
    db   $6F, $30, $01, $24, $7E, $B7, $28, $0E
    db   $FE, $FF, $28, $07, $6F, $1E, $3F, $1A
    db   $BD, $38, $03, $AF, $18, $02, $3E, $01
    db   $1E, $27, $12, $C9, $CD, $50, $0F, $7C
    db   $1E, $27, $12, $C9, $F0, $A4, $F5, $3E
    db   $10, $CD, $DD, $05, $CD, $35, $24, $F1
    db   $CD, $DD, $05, $F0, $9A, $57, $C9, $21
    db   $52, $CD, $2A, $B6, $F0, $92, $4F, $FA
    db   $1C, $DA, $20, $07, $B9, $C0, $2E, $4D
    db   $36, $00, $C9, $91, $3D, $FE, $04, $D8
    db   $D6, $03, $5F, $3A, $B7, $20, $05, $7E
    db   $BB, $30, $01, $5F, $7E, $93, $22, $7E
    db   $DE, $00, $77, $06, $C4, $2E, $4E, $2A
    db   $02, $0C, $2A, $02, $0C, $7B, $02, $E0
    db   $84, $0C, $2A, $66, $6F, $2A, $02, $0C
    db   $1D, $20, $FA, $79, $E0, $92, $11, $4E
    db   $CD, $F0, $84, $4F, $1A, $81, $12, $1C
    db   $1A, $CE, $00, $12, $1C, $7D, $12, $1C
    db   $7C, $12, $C9, $AF, $E0, $AD, $21, $AE
    db   $FF, $0A, $03, $22, $0A, $03, $22, $0A
    db   $03, $22, $0A, $22, $C3, $73, $19, $AF
    db   $E0, $AD, $21, $AE, $FF, $0A, $03, $22
    db   $0A, $03, $22, $0A, $03, $22, $0A, $22
    db   $C3, $DD, $19, $AF, $E0, $AD, $21, $AE
    db   $FF, $0A, $03, $22, $0A, $03, $22, $0A
    db   $03, $22, $0A, $22, $C3, $05, $1A, $AF
    db   $E0, $AD, $21, $AE, $FF, $0A, $5F, $03
    db   $22, $0A, $E0, $80, $03, $22, $0A, $03
    db   $22, $0A, $22, $F0, $80, $93, $22, $C3
    db   $3A, $1A, $1E, $48, $1A, $67, $0A, $03
    db   $E0, $80, $0A, $03, $C5, $4F, $17, $9F
    db   $47, $1E, $07, $6B, $2A, $81, $12, $1C
    db   $7E, $88, $12, $F0, $80, $2E, $45, $CB
    db   $7E, $28, $02, $2F, $3C, $4F, $17, $9F
    db   $47, $1E, $04, $6B, $2A, $81, $12, $1C
    db   $7E, $88, $12, $C1, $C9, $1E, $44, $1A
    db   $CB, $7F, $20, $0A, $D6, $01, $12, $38
    db   $26, $2E, $60, $62, $36, $3F, $CD, $5B
    db   $25, $FA, $2C, $DD, $CB, $4F, $20, $10
    db   $CB, $47, $20, $02, $AF, $C9, $CD, $61
    db   $0C, $21, $12, $DD, $CB, $DE, $37, $C9
    db   $1E, $4C, $AF, $12, $E1, $37, $C9, $21
    db   $12, $DD, $CB, $56, $20, $D8, $2E, $60
    db   $62, $36, $2D, $18, $D1, $AF, $EA, $2C
    db   $DD, $79, $EA, $29, $DD, $78, $EA, $2A
    db   $DD, $CD, $88, $25, $38, $18, $26, $A5
    db   $2E, $00, $7E, $3C, $28, $07, $E5, $CD
    db   $B6, $26, $E1, $38, $09, $24, $7C, $FE
    db   $A8, $20, $EF, $CD, $53, $27, $F0, $9A
    db   $57, $C9, $FA, $5D, $A0, $3C, $28, $6E
    db   $FE, $05, $28, $6A, $FE, $01, $28, $07
    db   $1E, $61, $1A, $CB, $7F, $20, $5F, $1E
    db   $04, $21, $5E, $A0, $1A, $96, $4F, $1C
    db   $2C, $1A, $9E, $28, $09, $3C, $20, $4E
    db   $79, $2F, $3C, $28, $49, $4F, $F0, $A2
    db   $47, $1E, $5E, $1A, $80, $37, $99, $38
    db   $3D, $1E, $07, $2E, $60, $1A, $96, $4F
    db   $1C, $2C, $1A, $9E, $28, $09, $3C, $20
    db   $2D, $79, $2F, $3C, $28, $28, $4F, $F0
    db   $A3, $47, $1E, $5F, $1A, $80, $37, $99
    db   $38, $1C, $FA, $5D, $A0, $21, $F0, $25
    db   $87, $85, $6F, $30, $01, $24, $2A, $66
    db   $6F, $E9, $FE, $25, $82, $26, $A6, $26
    db   $82, $26, $FE, $25, $67, $26, $A7, $C9
    db   $FA, $57, $A0, $CB, $77, $20, $60, $21
    db   $2C, $DD, $CB, $D6, $1E, $60, $1A, $CB
    db   $5F, $20, $54, $21, $55, $A0, $34, $62
    db   $2E, $0D, $AF, $22, $77, $2E, $0F, $22
    db   $77, $2E, $22, $36, $F6, $2C, $36, $0D
    db   $21, $57, $A0, $CB, $FE, $1E, $00, $1A
    db   $FE, $2F, $20, $0F, $21, $57, $A0, $CB
    db   $C6, $3E, $01, $EA, $59, $A0, $1E, $3C
    db   $1A, $18, $1A, $FA, $57, $A0, $1F, $38
    db   $1B, $21, $29, $DD, $2A, $C6, $00, $66
    db   $30, $01, $24, $6F, $7E, $CB, $7F, $20
    db   $0B, $21, $59, $A0, $34, $EA, $58, $A0
    db   $AF, $EA, $5A, $A0, $C3, $4F, $28, $A7
    db   $C9, $1E, $60, $1A, $CB, $4F, $20, $12
    db   $FA, $62, $A0, $47, $1E, $4C, $1A, $90
    db   $DA, $29, $28, $CA, $29, $28, $12, $C3
    db   $20, $28, $A7, $C9, $1E, $60, $1A, $CB
    db   $4F, $20, $1B, $CD, $71, $28, $FA, $45
    db   $A0, $EA, $2B, $DD, $FA, $62, $A0, $47
    db   $1E, $4C, $1A, $90, $DA, $36, $28, $CA
    db   $36, $28, $12, $C3, $20, $28, $A7, $C9
    db   $1E, $60, $1A, $CB, $57, $20, $07, $21
    db   $6C, $A0, $CB, $DE, $18, $CE, $A7, $C9
    db   $2E, $4C, $7E, $B7, $28, $4A, $1E, $60
    db   $1A, $CB, $7F, $20, $43, $1E, $04, $6B
    db   $1A, $96, $4F, $1C, $2C, $1A, $9E, $EA
    db   $2B, $DD, $28, $09, $3C, $20, $31, $79
    db   $2F, $3C, $28, $2C, $4F, $2E, $39, $46
    db   $1E, $5E, $1A, $80, $37, $99, $38, $20
    db   $1E, $07, $6B, $1A, $96, $4F, $1C, $2C
    db   $1A, $9E, $28, $09, $3C, $20, $11, $79
    db   $2F, $3C, $28, $0C, $4F, $2E, $3A, $46
    db   $1E, $5F, $1A, $80, $37, $99, $30, $02
    db   $A7, $C9, $1E, $60, $1A, $CB, $77, $20
    db   $17, $2E, $5A, $7E, $FE, $06, $28, $10
    db   $FE, $0A, $28, $0C, $FE, $16, $28, $08
    db   $1E, $07, $01, $83, $4C, $CD, $49, $08
    db   $1E, $60, $1A, $CB, $67, $20, $D9, $2E
    db   $5A, $7E, $FE, $00, $20, $05, $1A, $CB
    db   $6F, $20, $CD, $1E, $4C, $6B, $1A, $96
    db   $DA, $48, $27, $CA, $48, $27, $12, $C3
    db   $20, $28, $2E, $5A, $7E, $FE, $12, $C2
    db   $36, $28, $C3, $29, $28, $1E, $04, $6B
    db   $26, $A0, $1A, $96, $4F, $1C, $2C, $1A
    db   $9E, $EA, $2B, $DD, $28, $09, $3C, $20
    db   $33, $79, $2F, $3C, $28, $2E, $4F, $F0
    db   $A0, $47, $1E, $5E, $1A, $80, $37, $99
    db   $38, $22, $1E, $07, $21, $54, $CD, $1A
    db   $96, $4F, $1C, $2C, $1A, $9E, $28, $09
    db   $3C, $20, $11, $79, $2F, $3C, $28, $0C
    db   $4F, $F0, $A1, $47, $1E, $5F, $1A, $80
    db   $37, $99, $30, $02, $A7, $C9, $21, $2C
    db   $DD, $CB, $DE, $1E, $61, $1A, $CB, $77
    db   $20, $F2, $CD, $09, $28, $38, $ED, $FA
    db   $5D, $A0, $FE, $01, $28, $E6, $FE, $04
    db   $28, $E2, $FA, $54, $A0, $B7, $C2, $F3
    db   $27, $21, $29, $DD, $2A, $C6, $01, $66
    db   $30, $01, $24, $6F, $7E, $EA, $44, $A0
    db   $B7, $28, $06, $E6, $0F, $47, $CD, $8B
    db   $3A, $3E, $FF, $EA, $5D, $A0, $1E, $01
    db   $01, $C9, $4E, $CD, $48, $0C, $FA, $2B
    db   $DD, $E6, $80, $F6, $40, $EA, $53, $A0
    db   $3E, $01, $EA, $54, $A0, $1E, $60, $1A
    db   $CB, $47, $20, $A0, $1E, $4C, $1A, $D6
    db   $02, $DA, $36, $28, $CA, $36, $28, $12
    db   $C3, $20, $28, $FA, $50, $A0, $FE, $09
    db   $20, $0E, $FA, $56, $A0, $B7, $20, $06
    db   $FA, $55, $A0, $B7, $28, $02, $37, $C9
    db   $A7, $C9, $21, $2C, $DD, $CB, $C6, $06
    db   $08, $18, $28, $21, $2C, $DD, $CB, $CE
    db   $06, $0B, $CD, $51, $28, $D0, $18, $0B
    db   $21, $2C, $DD, $CB, $CE, $06, $05, $CD
    db   $51, $28, $D0, $1E, $4A, $1A, $4F, $1C
    db   $1A, $47, $26, $02, $CD, $E0, $30, $37
    db   $C9, $06, $02, $21, $29, $DD, $2A, $80
    db   $66, $30, $01, $24, $6F, $2A, $4F, $2A
    db   $47, $B1, $28, $0D, $5E, $CD, $46, $08
    db   $FA, $2B, $DD, $2F, $2E, $5D, $77, $37
    db   $C9, $A7, $C9, $21, $6C, $A0, $CB, $46
    db   $C0, $CB, $C6, $21, $76, $A0, $36, $00
    db   $C9, $CB, $7F, $C8, $2F, $3C, $C9, $F5
    db   $AF, $E0, $80, $18, $0F, $F5, $78, $A9
    db   $E0, $80, $78, $CD, $7F, $28, $47, $79
    db   $CD, $7F, $28, $4F, $D5, $E5, $78, $B9
    db   $30, $02, $41, $4F, $26, $D7, $69, $56
    db   $24, $5E, $25, $68, $7E, $24, $6E, $67
    db   $19, $F5, $16, $D8, $78, $91, $5F, $1A
    db   $4F, $15, $1A, $47, $7D, $91, $6F, $7C
    db   $98, $67, $30, $04, $F1, $3F, $18, $01
    db   $F1, $CB, $1C, $CB, $1D, $44, $4D, $F0
    db   $80, $07, $30, $0A, $79, $2F, $C6, $01
    db   $4F, $78, $2F, $CE, $00, $47, $E1, $D1
    db   $F1, $C9, $F5, $E5, $78, $AA, $E0, $81
    db   $CB, $78, $28, $0A, $79, $2F, $C6, $01
    db   $4F, $78, $2F, $CE, $00, $47, $C5, $43
    db   $CD, $85, $28, $69, $60, $01, $80, $00
    db   $09, $6C, $26, $00, $C1, $4B, $CD, $85
    db   $28, $09, $F0, $81, $07, $30, $0A, $7D
    db   $2F, $C6, $01, $6F, $7C, $2F, $CE, $00
    db   $67, $4D, $44, $E1, $F1, $C9, $C6, $40
    db   $E5, $E0, $80, $E6, $7F, $FE, $40, $38
    db   $03, $2F, $C6, $81, $21, $88, $29, $16
    db   $00, $5F, $19, $5E, $16, $00, $F0, $80
    db   $CB, $27, $30, $02, $16, $FF, $E1, $C9

toc_01_293E:
    push af
    clear [$FF87]
    push de
    push hl
    ld   a, b
    cp   c
    jr   nc, .else_01_294A

    ld   b, c
    ld   c, a
.else_01_294A:
    ld   h, $D7
    ld   l, c
    ld   d, [hl]
    inc  h
    ld   e, [hl]
    dec  h
    ld   l, b
    ld   a, [hl]
    inc  h
    ld   l, [hl]
    ld   h, a
    add  hl, de
    push af
    ld   d, $D8
    ld   a, b
    sub  a, c
    ld   e, a
    ld   a, [de]
    ld   c, a
    dec  d
    ld   a, [de]
    ld   b, a
    ld   a, l
    sub  a, c
    ld   l, a
    ld   a, h
    sbc  b
    ld   h, a
    jr   nc, .else_01_296E

    pop  af
    ccf
    jr   .toc_01_296F

.else_01_296E:
    pop  af
.toc_01_296F:
    rr   h
    rr   l
    ld   b, h
    ld   c, l
    ld   a, [$FF87]
    rlca
    jr   nc, .else_01_2984

    ld   a, c
    cpl
    add  a, $01
    ld   c, a
    ld   a, b
    cpl
    adc  $00
    ld   b, a
.else_01_2984:
    pop  hl
    pop  de
    pop  af
    ret


    db   $00, $06, $0D, $13, $19, $1F, $26, $2C
    db   $32, $38, $3E, $44, $4A, $50, $56, $5C
    db   $62, $68, $6D, $73, $79, $7E, $84, $89
    db   $8E, $93, $98, $9D, $A2, $A7, $AC, $B1
    db   $B5, $B9, $BE, $C2, $C6, $CA, $CE, $D1
    db   $D5, $D8, $DC, $DF, $E2, $E5, $E7, $EA
    db   $ED, $EF, $F1, $F3, $F5, $F7, $F8, $FA
    db   $FB, $FC, $FD, $FE, $FF, $FF, $FF, $FF
    db   $FF, $04, $0B, $1B, $34, $59, $1B, $00
    db   $40, $1B, $91, $41, $4D, $07, $0E, $1B
    db   $50, $6B, $1B, $D1, $43, $1B, $04, $48
    db   $54, $1E, $11, $1B, $E3, $61, $1B, $3B
    db   $42, $1B, $2E, $43, $4F, $20, $13, $1B
    db   $67, $76, $1B, $D0, $48, $1B, $06, $4C
    db   $5C, $00, $12, $1C, $00, $40, $1B, $A5
    db   $4C, $1B, $EA, $51, $65, $25, $14, $1C
    db   $90, $4E, $1B, $95, $52, $1B, $CB, $53
    db   $6D, $0F, $15, $1C, $60, $5B, $1B, $78
    db   $54, $1B, $A0, $58, $73, $1D, $0A, $0E
    db   $C3, $4C, $0E, $5A, $59, $0E, $4C, $5B
    db   $77, $1E, $07

toc_01_2A2B:
    ld   a, e
    ld   [$DD2E], a
    add  a, a
    add  a, a
    ld   b, a
    add  a, a
    add  a, b
    ld   bc, $29C9
    add  a, c
    jr   nc, .else_01_2A3B

    inc  b
.else_01_2A3B:
    ld   c, a
    call toc_01_2AF8
    ld   a, [bc]
    inc  bc
    ld   e, a
    push bc
    cbcallNoInterrupts $1F, $4232
    pop  bc
    ld   a, [bc]
    inc  bc
    ld   e, a
    push de
    ld   a, [bc]
    inc  bc
    push bc
    call cbcallWithoutInterrupts.loadBank
    pop  bc
    ld   a, [bc]
    ld   l, a
    inc  bc
    ld   a, [bc]
    ld   h, a
    inc  bc
    ld   de, $8000
    push bc
    call decompressHAL
    pop  bc
    ld   a, [bc]
    inc  bc
    push bc
    call cbcallWithoutInterrupts.loadBank
    pop  bc
    ld   a, [bc]
    ld   l, a
    inc  bc
    ld   a, [bc]
    ld   h, a
    inc  bc
    ld   de, $9000
    push bc
    call decompressHAL
    pop  bc
    ld   a, [bc]
    inc  bc
    push bc
    call cbcallWithoutInterrupts.loadBank
    pop  bc
    ld   a, [bc]
    ld   l, a
    inc  bc
    ld   a, [bc]
    ld   h, a
    inc  bc
    ld   de, $9800
    push bc
    call decompressHAL
    assign [gbLCDC], LCDCF_BG_DISPLAY | LCDCF_OBJ_16_16 | LCDCF_OBJ_DISPLAY | LCDCF_TILEMAP_9C00
    call toc_01_046D
    ld   a, $08
    call cbcallWithoutInterrupts.loadBank
    call toc_08_4000
    pop  bc
    ld   a, [bc]
    ld   h, $A0
    ld   l, $B3
    ld   b, $00
    ld   c, b
    ld   d, c
    ld   e, d
    call toc_01_07C4
    pop  de
    cbcallNoInterrupts $1E, $6011
    ld   a, [$DD2E]
    add  a, $03
    ld   d, a
    ld   e, $04
    cbcallNoInterrupts $1A, $4246
.loop_01_2AC4:
    call toc_01_0496
    call toc_01_086B
    call toc_01_04AE
    call toc_01_0343
    _ifZero [$DD2D], .else_01_2ADC

    _ifZero [$DA46], .loop_01_2AC4

.else_01_2ADC:
    ld   a, [$DD2E]
    add  a, $03
    ld   d, a
    ld   e, $04
    cbcallNoInterrupts $1A, $427B
    call toc_01_0437
    cbcallNoInterrupts $07, $5ADA
    ret


toc_01_2AF8:
    call toc_01_1584
    ld   hl, $DD2D
    ld   [hl], a
    ld   hl, $FFA5
    ld   [hl], a
    assign [$CD09], $E4
    assign [$CD0A], $D0
    assign [$CD0B], $E4
    ret


    db   $FA, $2F, $DD, $3C, $C8, $FA, $4D, $CD
    db   $B7, $C8, $D5, $CD, $35, $24, $D1, $FA
    db   $4D, $CD, $B7, $C0, $3D, $EA, $2F, $DD
    db   $C9, $11, $00, $CF, $CD, $08, $07, $F3
    db   $7B, $D6, $00, $5F, $7A, $DE, $CF, $21
    db   $53, $CD, $32, $73, $3E, $01, $EA, $4D
    db   $CD, $AF, $EA, $58, $DD, $3E, $FF, $E0
    db   $45, $EA, $29, $DA, $18, $32, $F5, $E5
    db   $C5, $D5, $F0, $A4, $EA, $34, $DD, $08
    db   $32, $DD, $21, $14, $DA, $3E, $77, $22
    db   $36, $2B, $3E, $80, $E0, $45, $FA, $37
    db   $DD, $CD, $F3, $05, $31, $35, $DD, $E1
    db   $F9, $C3, $9F, $02, $F5, $E5, $C5, $D5
    db   $F0, $A4, $EA, $37, $DD, $08, $35, $DD
    db   $FA, $34, $DD, $CD, $F3, $05, $31, $32
    db   $DD, $E1, $F9, $C3, $9F, $02, $21, $2D
    db   $DD, $36, $01, $C9

toc_01_2B97:
    ld   hl, $CE8A
    add  hl, bc
    ld   [hl], $24
    xor  a
    ld   hl, $CE92
    add  hl, bc
    ld   [hl], a
    ld   hl, $CE9A
    add  hl, bc
    ld   [hl], a
    ld   hl, $CEA2
    add  hl, bc
    ld   [hl], a
    ld   hl, $CEAA
    add  hl, bc
    ld   [hl], a
    ld   hl, $CEB2
    add  hl, bc
    ld   [hl], a
    ld   hl, $2BF5
    add  hl, bc
    ld   a, [hl]
    ld   hl, $CEBA
    add  hl, bc
    ld   [hl], a
    inc  de
    ld   a, [de]
    ld   hl, $CE5A
    add  hl, bc
    ld   [hl], a
    inc  de
    ld   a, [de]
    ld   hl, $CE62
    add  hl, bc
    ld   [hl], a
    inc  de
    ld   a, [de]
    sra  a
    sra  a
    add  a, $F0
    ld   l, a
    ld   h, $2B
    jr   nc, .else_01_2BDD

    inc  h
.else_01_2BDD:
    ld   a, [hl]
    ld   hl, $CE4A
    add  hl, bc
    ld   [hl], a
    ld   hl, $CE52
    add  hl, bc
    ld   [hl], $01
    ld   hl, $CE82
    add  hl, bc
    ld   [hl], $01
    ret


    db   $00, $05, $FF, $0F, $0A, $10, $20, $30
    db   $40, $50, $60, $70, $80

toc_01_2BFD:
    _changebank $1F
    ld   b, $07
.loop_01_2C04:
    ld   h, $CE
    ld   a, $52
    add  a, b
    ld   l, a
    ifAddressAtHLNotZero .else_01_2C48

    ld   a, b
    cp   $04
    ld   a, $1A
    jr   c, .else_01_2C17

    ld   a, $2E
.else_01_2C17:
    ld   [$FF99], a
    ld   h, $CE
    ld   a, $5A
    add  a, b
    ld   l, a
    push hl
    ld   e, [hl]
    add  a, $08
    ld   l, a
    push hl
    ld   d, [hl]
    push bc
    call toc_01_2C5A
    pop  bc
    pop  hl
    ld   [hl], d
    pop  hl
    ld   [hl], e
    call doCE82PlusB
    ld   h, $CE
    ld   a, $72
    add  a, b
    ld   l, a
    push hl
    ld   e, [hl]
    add  a, $08
    ld   l, a
    push hl
    ld   d, [hl]
    push bc
    call toc_01_2F4B
    pop  bc
    pop  hl
    ld   [hl], d
    pop  hl
    ld   [hl], e
.else_01_2C48:
    ifBEq $04, .else_01_2C52

    _changebank $1E
.else_01_2C52:
    dec  b
    bit  7, b
    jr   z, .loop_01_2C04

    jp   toc_1E_4368

toc_01_2C5A:
    ld   h, $CE
    ld   a, $52
    add  a, b
    ld   l, a
    dec  [hl]
    jr   z, .else_01_2C65

    ret


.toc_01_2C64:
    inc  de
.else_01_2C65:
    ld   h, $CE
    ld   a, [de]
    ld   c, a
    and  %11100000
    cp   $E0
    jp   z, toc_01_2D60

    ld   a, $4A
    add  a, b
    ld   l, a
    ld   a, [hl]
    cp   $0F
    jr   nz, .else_01_2C97

    bit  4, c
    jp   nz, .else_01_2CCA

    ld   a, c
    and  %00001111
    cp   $0F
    jr   z, .else_01_2CB3

    add  a, $D1
    ld   l, a
    ld   h, $30
    jr   nc, .else_01_2C8D

    inc  h
.else_01_2C8D:
    ld   c, [hl]
    ld   a, $12
    call toc_01_30B6.toc_01_30BF
    ld   [hl], c
    jp   .else_01_2CCA

.else_01_2C97:
    ld   a, c
    and  %00011111
    cp   $10
    jr   z, .else_01_2CB3

    bit  4, a
    jr   z, .else_01_2CA4

    or   %11100000
.else_01_2CA4:
    ld   c, a
    ld   a, $8A
    add  a, b
    ld   l, a
    ld   a, [hl]
    add  a, c
    push de
    call toc_01_2EF5
    pop  de
    jp   .else_01_2CCA

.else_01_2CB3:
    call toc_01_2D34
    ld   c, a
    ld   h, $CE
    ld   a, $82
    add  a, b
    ld   l, a
    ifAddressAtHLNotZero .else_01_2CC3

    ld   [hl], $01
.else_01_2CC3:
    ld   a, c
    and  a
    jp   z, .toc_01_2C64

    inc  de
    ret


.else_01_2CCA:
    call toc_01_2D34
    ld   c, a
    ld   h, $CE
    ld   a, $82
    add  a, b
    ld   l, a
    ld   [hl], $FF
    add  a, $10
    ld   l, a
    ifAddressAtHLNotZero .else_01_2CEF

    push bc
    push de
    ld   e, a
    ld   h, $CE
    ld   a, $82
    add  a, b
    ld   l, a
    push hl
    ld   b, e
    call toc_01_293E
    pop  hl
    ld   [hl], b
    pop  de
    pop  bc
.else_01_2CEF:
    push bc
    call toc_01_2CF7
    pop  bc
    jp   .else_01_2CC3

toc_01_2CF7:
    ld   h, $CE
    ld   a, $A2
    add  a, b
    ld   l, a
    ld   a, [hl]
    bit  7, a
    jr   nz, .return_01_2D33

.toc_01_2D02:
    add  a, a
    add  a, a
.toc_01_2D04:
    push de
    add  a, $00
    ld   e, a
    ld   d, $40
    jr   nc, .else_01_2D0D

    inc  d
.else_01_2D0D:
    ld   h, $CE
    ld   a, $72
    add  a, b
    ld   l, a
    ld   a, [de]
    ld   [hl], a
    ld   a, $7A
    add  a, b
    ld   l, a
    inc  de
    ld   a, [de]
    ld   [hl], a
    ld   h, $30
    ld   a, $C7
    add  a, b
    ld   l, a
    jr   nc, .else_01_2D25

    inc  h
.else_01_2D25:
    ld   c, [hl]
    ld   h, $CE
    ld   a, $C2
    add  a, b
    ld   l, a
    ld   [hl], c
    add  a, $A8
    ld   l, a
    ld   [hl], $01
    pop  de
.return_01_2D33:
    ret


toc_01_2D34:
    ld   a, [de]
    and  %11100000
    cp   $C0
    jr   nz, .else_01_2D3F

    inc  de
    ld   a, [de]
    jr   .toc_01_2D56

.else_01_2D3F:
    ld   h, $CE
    ld   a, $AA
    add  a, b
    ld   l, a
    ld   a, [de]
    and  %11100000
    swap a
    srl  a
    add  a, [hl]
    add  a, $15
    ld   l, a
    ld   a, $00
    adc  $DE
    ld   h, a
    ld   a, [hl]
.toc_01_2D56:
    ld   c, a
    ld   h, $CE
    ld   a, $52
    add  a, b
    ld   l, a
    ld   a, c
    ld   [hl], a
    ret


toc_01_2D60:
    ld   a, c
    cp   $F0
    jr   nz, .else_01_2D7D

    inc  de
    ld   h, $CE
    ld   a, $9A
    add  a, b
    ld   l, a
    ld   a, [de]
.toc_01_2D6D:
    swap a
    and  %11110000
    ld   c, a
    ld   a, [hl]
    and  %00001111
    or   c
    ld   [hl], a
    call toc_01_3037.toc_01_3043
    jp   toc_01_2C5A.toc_01_2C64

.else_01_2D7D:
    cp   $F1
    jr   nz, .else_01_2DA1

    inc  de
    ld   a, [de]
    ld   c, a
    ld   h, $CE
    ld   a, $9A
    add  a, b
    ld   l, a
    ld   a, [hl]
    swap a
    and  %00001111
    add  a, c
    bit  7, c
    jr   nz, .else_01_2D9C

    cp   $10
    jr   c, .else_01_2D9F

    ld   a, $0F
    jr   .else_01_2D9F

.else_01_2D9C:
    jr   c, .else_01_2D9F

    xor  a
.else_01_2D9F:
    jr   .toc_01_2D6D

.else_01_2DA1:
    cp   $F2
    jr   nz, .else_01_2DB6

    inc  de
    ld   a, [de]
    add  a, a
    ld   c, a
    add  a, a
    add  a, c
    ld   hl, $CEAA
.toc_01_2DAE:
    ld   c, a
    ld   a, l
    add  a, b
    ld   l, a
    ld   [hl], c
    jp   toc_01_2C5A.toc_01_2C64

.else_01_2DB6:
    cp   $F3
    jr   nz, .else_01_2DCB

    inc  de
    ld   h, $CE
    ld   a, $52
    add  a, b
    ld   l, a
    ld   a, [de]
    ld   [hl], a
    ld   a, $82
    add  a, b
    ld   l, a
    ld   [hl], $FF
    inc  de
    ret


.else_01_2DCB:
    cp   $F4
    jr   nz, .else_01_2DD7

    inc  de
    ld   a, [de]
    ld   hl, $CE92
    jp   .toc_01_2DAE

.else_01_2DD7:
    cp   $F5
    jr   nz, .else_01_2DE3

    inc  de
    ld   a, [de]
    ld   hl, $CE8A
    jp   .toc_01_2DAE

.else_01_2DE3:
    cp   $F6
    jr   nz, .else_01_2DF8

    inc  de
    ld   h, $CE
    ld   a, $A2
    add  a, b
    ld   l, a
    ld   a, [de]
    ld   [hl], a
    bit  7, a
    call nz, toc_01_2CF7.toc_01_2D02
    jp   toc_01_2C5A.toc_01_2C64

.else_01_2DF8:
    cp   $F7
    jr   nz, .else_01_2E04

    inc  de
    ld   a, [de]
    ld   hl, $CEB2
    jp   .toc_01_2DAE

.else_01_2E04:
    cp   $E2
    jr   nz, .else_01_2E1A

    inc  de
    ld   a, [de]
    ld   c, a
    inc  de
    ld   a, [de]
    push de
    ld   d, a
    ld   e, c
    call toc_01_2EF5.toc_01_2F11
    call toc_01_2CF7
    pop  de
    jp   toc_01_2C5A.toc_01_2C64

.else_01_2E1A:
    cp   $E3
    jr   nz, .else_01_2E31

    inc  de
    ld   a, [de]
    push de
    cpl
    inc  a
    ld   e, a
    ld   d, $00
    rla
    jr   nc, .else_01_2E2A

    dec  d
.else_01_2E2A:
    call toc_01_30AA
    pop  de
    jp   toc_01_2C5A.toc_01_2C64

.else_01_2E31:
    cp   $FE
    jr   nz, .else_01_2E6B

    inc  de
    ld   a, [de]
    ld   c, a
    push de
    ld   h, $CE
    ld   a, $4A
    add  a, b
    ld   l, a
    ld   e, [hl]
    srl  e
    srl  e
    ld   d, $00
    ld   hl, $CE42
    add  hl, de
    ld   a, c
    rra
    jr   nc, .else_01_2E50

    set  4, d
.else_01_2E50:
    rra
    jr   nc, .else_01_2E54

    inc  d
.else_01_2E54:
    inc  e
    dec  e
    jr   z, .else_01_2E5D

.loop_01_2E58:
    rlc  d
    dec  e
    jr   nz, .loop_01_2E58

.else_01_2E5D:
    ld   a, b
    cp   $04
    jr   c, .else_01_2E66

    inc  l
    inc  l
    inc  l
    inc  l
.else_01_2E66:
    ld   [hl], d
    pop  de
    jp   toc_01_2C5A.toc_01_2C64

.else_01_2E6B:
    cp   $E1
    jr   nz, .else_01_2E77

    inc  de
    ld   a, [de]
    ld   [$CE00], a
    jp   toc_01_2C5A.toc_01_2C64

.else_01_2E77:
    cp   $FF
    jr   nz, .else_01_2E8B

    ld   h, $CE
    ld   a, $52
    add  a, b
    ld   l, a
    ld   [hl], $00
    add  a, $18
    ld   l, a
    xor  a
    ld   [hl], a
    jp   toc_01_3037

.else_01_2E8B:
    ld   hl, $CEBA
    call toc_01_2E94
    jp   toc_01_2C5A.else_01_2C65

toc_01_2E94:
    ld   a, l
    add  a, b
    ld   l, a
    push hl
    ld   a, $64
    add  a, [hl]
    ld   l, a
    ld   a, $DD
    adc  $00
    ld   h, a
    call toc_01_2EAA
    ld   a, l
    sub  a, $64
    pop  hl
    ld   [hl], a
    ret


toc_01_2EAA:
    ld   a, [de]
    cp   $F8
    jr   nz, .else_01_2EB7

    inc  de
    ld   a, [de]
    ld   c, a
    inc  de
    ld   a, [de]
    ld   d, a
    ld   e, c
    ret


.else_01_2EB7:
    cp   $FA
    jr   nz, .else_01_2ECA

    inc  de
    inc  de
    inc  de
    dec  hl
    ld   [hl], d
    dec  hl
    ld   [hl], e
    dec  de
    ld   a, [de]
    ld   c, a
    dec  de
    ld   a, [de]
    ld   e, a
    ld   d, c
    ret


.else_01_2ECA:
    cp   $FB
    jr   nz, .else_01_2ED3

    ld   e, [hl]
    inc  hl
    ld   d, [hl]
    inc  hl
    ret


.else_01_2ED3:
    cp   $FC
    jr   nz, .else_01_2EE2

    inc  de
    ld   a, [de]
    ld   c, a
    inc  de
    dec  hl
    ld   [hl], d
    dec  hl
    ld   [hl], e
    dec  hl
    ld   [hl], c
    ret


.else_01_2EE2:
    cp   $FD
    jr   nz, .return_01_2EF4

    dec  [hl]
    jr   z, .else_01_2EF0

    inc  hl
    ld   e, [hl]
    inc  hl
    ld   d, [hl]
    dec  hl
    dec  hl
    ret


.else_01_2EF0:
    inc  hl
    inc  hl
    inc  hl
    inc  de
.return_01_2EF4:
    ret


toc_01_2EF5:
    ld   e, a
    ld   a, $B2
    add  a, b
    ld   l, a
    ld   a, [hl]
    add  a, a
    add  a, $CF
    ld   l, a
    ld   a, $00
    adc  $30
    ld   h, a
    ldi  a, [hl]
    rlc  e
    add  a, e
    ld   e, a
    ld   a, [hl]
    adc  $00
    ld   h, a
    ld   l, e
    ldi  a, [hl]
    ld   d, a
    ld   e, [hl]
.toc_01_2F11:
    ld   h, $CE
    ld   a, $4A
    add  a, b
    ld   l, a
    ld   a, [hl]
    cp   $0A
    jr   z, .else_01_2F23

    ld   a, $03
    call toc_01_30B6.toc_01_30BE
    jr   .toc_01_2F2D

.else_01_2F23:
    ld   a, $00
    call toc_01_30B6.toc_01_30BE
    ld   [hl], $80
    inc  l
    inc  l
    inc  l
.toc_01_2F2D:
    ld   a, e
    ldi  [hl], a
    ld   [hl], d
    ret


doCE82PlusB:
    ld   h, $CE
    ld   a, $82
    add  a, b
    ld   l, a
    ld   a, [hl]
    and  a
    ret  z

    cp   $FF
    ret  z

    dec  [hl]
    ret  nz

    ld   a, $A2
    add  a, b
    ld   l, a
    ld   a, [hl]
    add  a, a
    add  a, a
    add  a, $02
    jp   toc_01_2CF7.toc_01_2D04

toc_01_2F4B:
    ld   h, $CE
    ld   a, $6A
    add  a, b
    ld   l, a
    dec  [hl]
    jr   z, .else_01_2F56

    ret


.loop_01_2F55:
    inc  de
.else_01_2F56:
    ld   h, $CE
    ld   a, [de]
    ld   c, a
    and  %11100000
    jr   nz, .else_01_2F69

    ld   a, c
    and  %00011111
    ld   c, a
    ld   a, $6A
    add  a, b
    ld   l, a
    ld   [hl], c
    inc  de
    ret


.else_01_2F69:
    cp   $20
    jr   nz, .else_01_2F86

    push bc
    push de
    call toc_01_309C
    call toc_01_30AA
    pop  de
    pop  bc
.toc_01_2F77:
    ld   a, [de]
    and  %00010000
    jr   z, .loop_01_2F55

    ld   h, $CE
    ld   a, $6A
    add  a, b
    ld   l, a
    ld   [hl], $01
    inc  de
    ret


.else_01_2F86:
    cp   $40
    jr   nz, .else_01_2F90

    ld   a, c
    and  %00001111
    jp   .toc_01_2FAE

.else_01_2F90:
    cp   $60
    jr   nz, .else_01_2FB6

    push de
    call toc_01_309C
    ld   h, $CE
    ld   a, $9A
    add  a, b
    ld   l, a
    ld   a, [hl]
    and  %00001111
    add  a, e
    bit  7, a
    jr   z, .else_01_2FA7

    xor  a
.else_01_2FA7:
    cp   $10
    jr   c, .else_01_2FAD

    ld   a, $0F
.else_01_2FAD:
    pop  de
.toc_01_2FAE:
    push de
    call toc_01_3037
    pop  de
    jp   .toc_01_2F77

.else_01_2FB6:
    cp   $80
    jr   nz, toc_01_300D

    ld   h, $CE
    ld   a, $4A
    add  a, b
    ld   l, a
    ld   a, [hl]
    cp   $0A
    jr   z, .else_01_2FD8

    ld   a, $01
    call toc_01_30B6.toc_01_30BE
    ld   a, c
    rrca
    rrca
    and  %11000000
    ld   c, a
    ld   a, [hl]
    and  %00111111
    or   c
    ld   [hl], a
    jp   .toc_01_2F77

.else_01_2FD8:
    ld   a, c
    and  %00001111
    ld   hl, $CED2
    cp   [hl]
    jr   z, .else_01_2FFE

    push de
    ld   [hl], a
    swap a
    ld   e, a
    ld   d, $00
    ld   hl, $DDE5
    add  hl, de
    clear [gbAUD3ENA]
    call copyHLToFF30
    assign [gbAUD3ENA], $80
    ld   a, [$CE14]
    set  7, a
    ld   [gbAUD3HIGH], a
    pop  de
.else_01_2FFE:
    jp   .toc_01_2F77

copyHLToFF30:
    ld   de, $FF30
    ld   c, $10
.loop:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop

    ret


toc_01_300D:
    cp   $E0
    jr   nz, .return_01_3036

    ld   a, c
    cp   $F0
    jr   nz, .else_01_3022

    inc  de
    ld   a, [de]
    ld   c, a
    ld   a, $00
    call toc_01_30B6
    ld   [hl], c
    jp   toc_01_2F4B.loop_01_2F55

.else_01_3022:
    cp   $FF
    jr   nz, .else_01_302D

    ld   a, $6A
    add  a, b
    ld   l, a
    ld   [hl], $00
    ret


.else_01_302D:
    ld   hl, $CEC2
    call toc_01_2E94
    jp   toc_01_2F4B.else_01_2F56

.return_01_3036:
    ret


toc_01_3037:
    ld   c, a
    ld   h, $CE
    ld   a, $9A
    add  a, b
    ld   l, a
    ld   a, [hl]
    and  %11110000
    or   c
    ld   [hl], a
.toc_01_3043:
    push de
    ld   a, $FF
    sub  a, [hl]
    swap a
    and  %00001111
    ld   e, a
    ld   a, [hl]
    and  %00001111
    sub  a, e
    ld   e, a
    jr   nc, .else_01_3055

    ld   e, $00
.else_01_3055:
    push hl
    ld   hl, $CE01
    ld   a, b
    cp   $04
    jr   c, .else_01_305F

    inc  l
.else_01_305F:
    ld   a, $FF
    sub  a, [hl]
    swap a
    and  %00001111
    ld   d, a
    pop  hl
    ld   a, e
    sub  a, d
    jr   nc, .else_01_306D

    xor  a
.else_01_306D:
    ld   e, a
    ld   a, $4A
    add  a, b
    ld   l, a
    ld   a, [hl]
    cp   $0A
    jr   z, .else_01_3085

    ld   a, $02
    call toc_01_30B6.toc_01_30BE
    swap e
    ld   a, [hl]
    and  %00001111
    or   e
    ld   [hl], a
    pop  de
    ret


.else_01_3085:
    srl  e
    srl  e
    ld   d, $00
    ld   hl, $3098
    add  hl, de
    ld   e, [hl]
    ld   a, $02
    call toc_01_30B6
    ld   [hl], e
    pop  de
    ret


    db   $00, $60, $40, $20

toc_01_309C:
    ld   a, c
    and  %00001111
    ld   d, $00
    bit  3, a
    jr   z, .else_01_30A8

    or   %11110000
    dec  d
.else_01_30A8:
    ld   e, a
    ret


toc_01_30AA:
    ld   a, $03
    call toc_01_30B6
    ld   a, e
    add  a, [hl]
    ldi  [hl], a
    ld   a, d
    adc  [hl]
    ld   [hl], a
    ret


toc_01_30B6:
    push af
    ld   h, $CE
    ld   a, $4A
    add  a, b
    ld   l, a
    pop  af
.toc_01_30BE:
    add  a, [hl]
.toc_01_30BF:
    ld   hl, $FF99
    add  a, [hl]
    ld   l, a
    ld   h, $CE
    ret


    db   $06, $16, $26, $36, $46, $56, $66, $76
    db   $50, $3F, $00, $10, $20, $30, $07, $23
    db   $50, $33, $60, $43, $70, $45, $47, $55
    db   $65, $D5, $69, $50, $1E, $00, $18, $0D
    db   $79, $85, $27, $4F, $78, $8A, $27, $47
    db   $7B, $CE, $00, $27, $5F, $25, $20, $F0
    db   $21, $DD, $DE, $7E, $81, $27, $32, $7E
    db   $88, $27, $32, $7E, $8B, $27, $77, $38
    db   $07, $21, $DE, $DE, $CB, $C6, $D1, $C9
    db   $3E, $99, $22, $22, $77, $1E, $21, $21
    db   $99, $42, $3E, $1E, $CD, $CF, $05, $21
    db   $84, $A0, $7E, $FE, $99, $30, $03, $A7
    db   $3C, $27, $77, $21, $DE, $DE, $CB, $D6
    db   $18, $DA

toc_01_3131:
    clear [$DEDE]
    ld   hl, $9C21
    ld   c, $70
    ld   de, $DEDB
    ld   a, [de]
    ld   b, a
    inc  de
    ld   b, a
    swap a
    and  %00001111
    add  a, c
    ldi  [hl], a
    ld   a, b
    and  %00001111
    add  a, c
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ld   b, a
    swap a
    and  %00001111
    add  a, c
    ldi  [hl], a
    ld   a, b
    and  %00001111
    add  a, c
    ldi  [hl], a
    ld   a, [de]
    ld   b, a
    swap a
    and  %00001111
    add  a, c
    ldi  [hl], a
    ld   a, b
    and  %00001111
    add  a, c
    ldi  [hl], a
    ld   a, c
    ld   [hl], a
    ld   hl, $9C02
    _ifZero [$A071], .else_01_3178

    ld   a, [$DEE3]
    rra
    jr   .toc_01_317B

.else_01_3178:
    ld   a, [$DEE5]
.toc_01_317B:
    ld   d, $06
    and  a
    jr   z, .else_01_3187

.loop_01_3180:
    ld   [hl], $64
    inc  hl
    dec  d
    dec  a
    jr   nz, .loop_01_3180

.else_01_3187:
    ld   a, d
    and  a
    jr   z, .else_01_3191

.loop_01_318B:
    ld   [hl], $63
    inc  hl
    dec  d
    jr   nz, .loop_01_318B

.else_01_3191:
    ld   hl, $9C09
    ld   de, $DEE1
    ld   a, [de]
    and  a
    ld   b, a
    ld   c, $07
    ld   a, $68
.loop_01_319E:
    jr   z, .else_01_31A7

    ldi  [hl], a
    dec  c
    dec  b
    jr   nz, .loop_01_319E

    jr   .toc_01_31AD

.else_01_31A7:
    ld   a, $67
.loop_01_31A9:
    ldi  [hl], a
    dec  c
    jr   nz, .loop_01_31A9

.toc_01_31AD:
    ld   hl, $9C2A
    ld   de, $A084
    ld   a, [de]
    ld   d, $70
    ld   e, a
    swap a
    and  %00001111
    add  a, d
    ldi  [hl], a
    ld   a, e
    and  %00001111
    add  a, d
    ld   [hl], a
    ld   hl, $9C2F
    ld   a, [$DB60]
    inc  a
    ld   e, $70
    add  a, e
    ld   [hl], a
    ld   bc, $9690
    ld   de, $DEE0
    ld   a, [de]
    swap a
    ld   l, a
    and  %00001111
    ld   h, a
    ld   a, l
    and  %11110000
    ld   l, a
    sla  l
    rl   h
    sla  l
    rl   h
    ld   a, [hLastBank]
    push af
    ld   a, $07
    call cbcallWithoutInterrupts.loadBank
    ld   de, $57DC
    add  hl, de
    ld   d, $40
.loop_01_31F4:
    ldi  a, [hl]
    ld   [bc], a
    inc  c
    dec  d
    jr   nz, .loop_01_31F4

    pop  af
    jp   cbcallWithoutInterrupts.loadBank

    db   $0F, $64, $4A, $FF, $00, $0F, $A9, $4C
    db   $E9, $4E, $0F, $B5, $50, $1C, $53, $0F
    db   $A7, $55, $B1, $58, $3E, $01, $EA, $03
    db   $DF, $3E, $E4, $EA, $09, $CD, $3E, $D0
    db   $EA, $0A, $CD, $3E, $90, $EA, $0B, $CD
    db   $CD, $CB, $33, $1E, $15, $21, $32, $42
    db   $3E, $1F, $CD, $CF, $05, $3E, $0F, $CD
    db   $DD, $05, $21, $83, $49, $11, $00, $80
    db   $CD, $08, $07, $01, $FE, $31, $FA, $71
    db   $A0, $57, $87, $87, $82, $81, $4F, $30
    db   $01, $04, $0A, $03, $C5, $CD, $DD, $05
    db   $C1, $0A, $6F, $03, $0A, $67, $03, $C5
    db   $11, $00, $82, $CD, $08, $07, $FA, $71
    db   $A0, $A7, $C1, $28, $0B, $0A, $6F, $03
    db   $0A, $67, $11, $00, $8E, $CD, $08, $07
    db   $3E, $08, $CD, $DD, $05, $CD, $00, $40
    db   $3E, $92, $EA, $5E, $DB, $01, $60, $00
    db   $11, $40, $02, $3E, $CE, $21, $A1, $A0
    db   $CD, $C4, $07, $3E, $0A, $EA, $58, $DB
    db   $CD, $DD, $05, $21, $1C, $78, $CD, $89
    db   $12, $3E, $07, $CD, $DD, $05, $CD, $DC
    db   $41, $3E, $67, $E0, $40, $CD, $6D, $04
    db   $1E, $04, $21, $4E, $42, $3E, $1A, $CD
    db   $CF, $05, $CD, $96, $04, $CD, $6B, $08
    db   $3E, $07, $CD, $DD, $05, $CD, $59, $42
    db   $3E, $07, $CD, $DD, $05, $CD, $CB, $43
    db   $CD, $AE, $04, $21, $85, $5B, $3E, $07
    db   $CD, $CF, $05, $21, $D2, $5B, $3E, $07
    db   $CD, $CF, $05, $CD, $43, $03, $21, $2D
    db   $DD, $7E, $A7, $20, $06, $FA, $46, $DA
    db   $A7, $20, $C7, $1E, $04, $21, $80, $42
    db   $3E, $1A, $CD, $CF, $05, $CD, $37, $04
    db   $C9

toc_01_32FF:
    assign [gbLYC], 255
    ld   [wDesiredLYC], a
    assign [$DF03], $00
    assign [$CD09], $E4
    assign [$CD0A], $E0
    assign [$CD0B], $E4
    call toc_01_33CB
    ld   e, $1C
    cbcallNoInterrupts $1F, $4232
    assign [gbLCDC], LCDCF_BG_DISPLAY | LCDCF_OBJ_16_16 | LCDCF_OBJ_DISPLAY | LCDCF_TILEMAP_9C00
    ld   a, $0F
    call cbcallWithoutInterrupts.loadBank
    plotFromTo $4000, $8000
    ld   a, $08
    call cbcallWithoutInterrupts.loadBank
    call toc_08_4000
    ld   a, $0F
    call cbcallWithoutInterrupts.loadBank
    ld   hl, $6111
    ld   a, [$DB60]
    add  a, a
    add  a, a
    add  a, l
    ld   l, a
    jr   nc, .else_01_3353

    inc  h
.else_01_3353:
    ldi  a, [hl]
    ld   c, a
    ldi  a, [hl]
    ld   b, a
    ldi  a, [hl]
    ld   e, a
    ld   a, [hl]
    ld   d, a
    ld   a, $9A
    ld   hl, $A0A1
    call toc_01_07C4
    call toc_01_34CC
    call toc_01_33D5
    call toc_01_3467
    call toc_01_3492
    ld   a, $07
    call cbcallWithoutInterrupts.loadBank
    call toc_07_41DC
    call toc_01_046D
    ld   a, [$DB60]
    ld   e, a
    cbcallNoInterrupts $1E, $6011
    ld   a, [$DB60]
    add  a, $1B
    ld   d, a
    ld   e, $04
    cbcallNoInterrupts $1A, $4246
.loop_01_3396:
    call toc_01_0496
    call toc_01_086B
    ld   a, $07
    call cbcallWithoutInterrupts.loadBank
    call toc_07_4259
    call toc_01_04AE
    call toc_01_0343
    ld   hl, $DD2D
    ld   a, [hl]
    and  a
    jr   nz, .else_01_33B7

    _ifZero [$DA46], .loop_01_3396

.else_01_33B7:
    ld   a, [$DB60]
    add  a, $1B
    ld   d, a
    ld   e, $04
    cbcallNoInterrupts $1A, $427B
    call toc_01_0437
    ret


toc_01_33CB:
    ld   hl, $DD2D
    xor  a
    ld   [hl], a
    ld   hl, $FFA5
    ld   [hl], a
    ret


toc_01_33D5:
    call toc_01_34A3
    ldi  a, [hl]
    ld   [$DB3D], a
    ld   c, a
    ldi  a, [hl]
    ld   [$DB3E], a
    push hl
    ld   b, a
    ld   hl, $CD2D
    ld   a, $B3
    jr   .toc_01_33EB

.loop_01_33EA:
    add  a, c
.toc_01_33EB:
    ldi  [hl], a
    dec  b
    jr   nz, .loop_01_33EA

    pop  hl
    ld   c, $04
    ld   de, $DB45
.loop_01_33F5:
    ldi  a, [hl]
    swap a
    ld   b, a
    and  %11110000
    ld   [de], a
    inc  de
    ld   a, b
    and  %00001111
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop_01_33F5

    push hl
    ld   bc, $000A
    add  hl, bc
    ld   de, $B300
    call decompressHAL
    pop  hl
    inc  hl
    inc  hl
    ldd  a, [hl]
    ld   b, a
    ldd  a, [hl]
    ld   l, [hl]
    ld   h, a
    ld   a, b
    call cbcallWithoutInterrupts.loadBank
    ld   bc, $0003
    add  hl, bc
    push hl
    ldi  a, [hl]
    ld   [$DB5C], a
    ld   de, $CF00
    call decompressHAL
    ld   c, $05
    ld   hl, $CF00
    ld   de, $C500
.loop_01_3433:
    ld   a, [$DB5C]
    ld   b, a
.loop_01_3437:
    ldi  a, [hl]
    ld   [de], a
    inc  e
    dec  b
    jr   nz, .loop_01_3437

    ld   e, $00
    inc  d
    dec  c
    jr   nz, .loop_01_3433

    pop  hl
    dec  hl
    ldd  a, [hl]
    ld   b, a
    ldd  a, [hl]
    ld   l, [hl]
    ld   h, a
    ld   a, b
    call cbcallWithoutInterrupts.loadBank
    inc  hl
    clear [$DB59]
    _ifZero [$DF03], .else_01_3460

    ld   de, $8800
    call decompressHAL
    ret


.else_01_3460:
    ld   de, $9000
    call decompressHAL
    ret


toc_01_3467:
    ld   de, $A004
    ld   hl, $DB51
    ld   a, [de]
    inc  e
    sub  a, $50
    ldi  [hl], a
    ld   a, [de]
    inc  e
    sbc  $00
    ldi  [hl], a
    xor  a
    ldi  [hl], a
    ld   [hl], a
    jp   toc_01_1513

    db   $21, $51, $DB, $AF, $22, $22, $11, $07
    db   $A0, $1A, $1C, $D6, $40, $22, $1A, $DE
    db   $00, $77, $C3, $13, $15

toc_01_3492:
    ld   hl, $DB51
    ldi  a, [hl]
    and  %11110000
    ld   [$DB55], a
    inc  hl
    ld   a, [hl]
    and  %11110000
    ld   [$DB56], a
    ret


toc_01_34A3:
    ld   a, $0F
    call cbcallWithoutInterrupts.loadBank
    ld   a, [$DB6A]
    and  %01111111
    ld   b, $00
.toc_01_34AF:
    srl  a
    jr   nc, .else_01_34B6

    inc  b
    jr   .toc_01_34AF

.else_01_34B6:
    ld   a, b
    add  a, a
    add  a, b
    ld   hl, $612D
    add  a, l
    ld   l, a
    jr   nc, .else_01_34C1

    inc  h
.else_01_34C1:
    ldi  a, [hl]
    ld   c, a
    ldi  a, [hl]
    ld   b, a
    ld   a, [hl]
    ld   h, b
    ld   l, c
    call cbcallWithoutInterrupts.loadBank
    ret


toc_01_34CC:
    ld   a, [$DD63]
    ld   b, a
    ld   a, $00
.toc_01_34D2:
    ld   hl, $6111
    rr   b
    call c, toc_01_34E0
    inc  a
    cp   $07
    ret  z

    jr   .toc_01_34D2

toc_01_34E0:
    push bc
    push af
    add  a, a
    add  a, a
    add  a, l
    ld   l, a
    jr   nc, .else_01_34E9

    inc  h
.else_01_34E9:
    ldi  a, [hl]
    ld   c, a
    ldi  a, [hl]
    ld   b, a
    ldi  a, [hl]
    ld   e, a
    ld   a, [hl]
    ld   d, a
    ld   a, $9D
    ld   h, $A8
    ld   l, $B2
    call toc_01_07C4
    pop  af
    pop  bc
    ret


    db   $F0, $A4, $F5, $FA, $69, $A0, $CD, $DD
    db   $05, $62, $2E, $6A, $2A, $B6, $F0, $92
    db   $4F, $FA, $1C, $DA, $20, $09, $B9, $20
    db   $4D, $2E, $64, $36, $00, $18, $47, $91
    db   $3D, $FE, $04, $38, $41, $D6, $03, $5F
    db   $3A, $B7, $20, $05, $7E, $BB, $30, $01
    db   $5F, $7E, $93, $22, $7E, $DE, $00, $77
    db   $06, $C4, $2E, $65, $2A, $02, $0C, $2A
    db   $02, $0C, $7B, $02, $E0, $84, $0C, $2A
    db   $66, $6F, $2A, $02, $0C, $1D, $20, $FA
    db   $79, $E0, $92, $1E, $65, $F0, $84, $4F
    db   $1A, $81, $12, $1C, $1A, $CE, $00, $12
    db   $1C, $7D, $12, $1C, $7C, $12, $F1, $CD
    db   $DD, $05, $C9, $0A, $EA, $11, $DF, $03
    db   $21, $8B, $74, $3E, $07, $CD, $CF, $05
    db   $C9, $21, $52, $74, $3E, $07, $CD, $CF
    db   $05, $C9, $21, $6C, $74, $3E, $07, $CD
    db   $CF, $05, $C9, $FA, $71, $A0, $B7, $20
    db   $06, $21, $4C, $A0, $36, $0C, $C9, $21
    db   $72, $A0, $36, $06, $C9, $21, $B4, $FF
    db   $F0, $A6, $B6, $77, $C9, $AF, $E0, $B4
    db   $C9, $FA, $60, $DB, $D6, $02, $1E, $27
    db   $12, $C9, $1E, $07, $1A, $C6, $01, $12
    db   $1C, $1A, $CE, $00, $12, $C9, $1E, $87
    db   $CD, $E2, $35, $FA, $71, $A0, $C5, $21
    db   $DC, $35, $85, $6F, $30, $01, $24, $7E
    db   $4F, $17, $9F, $47, $62, $2E, $8B, $7E
    db   $81, $22, $7E, $88, $77, $C1, $C9, $00
    db   $FC, $FE, $FA, $1E, $03, $AF, $12, $1C
    db   $21, $51, $DB, $0A, $86, $12, $23, $1C
    db   $03, $0A, $8E, $12, $23, $1C, $AF, $12
    db   $1C, $03, $0A, $86, $12, $23, $1C, $03
    db   $0A, $8E, $12, $03, $C9, $F0, $A5, $E6
    db   $30, $28, $0B, $CB, $67, $3E, $40, $20
    db   $02, $3E, $C0, $1E, $45, $12, $C9, $1E
    db   $7D, $1A, $1F, $C9, $FA, $36, $DA, $B7
    db   $20, $08, $F0, $A5, $E6, $40, $28, $02
    db   $37, $C9, $A7, $C9, $F0, $A5, $E6, $80
    db   $28, $17, $FA, $71, $A0, $21, $48, $36
    db   $87, $85, $6F, $30, $01, $24, $2A, $66
    db   $6F, $CD, $20, $06, $CD, $3A, $75, $30
    db   $02, $A7, $C9, $37, $C9, $26, $79, $3C
    db   $79, $52, $79, $F0, $B4, $E6, $02, $28
    db   $0E, $21, $00, $A5, $7E, $FE, $FF, $28
    db   $0B, $24, $7C, $FE, $A8, $20, $F5, $CD
    db   $A2, $35, $A7, $C9, $37, $C9, $F0, $B4
    db   $E6, $02, $28, $15, $FA, $5B, $A0, $FE
    db   $03, $28, $15, $21, $00, $A5, $7E, $FE
    db   $FF, $28, $0B, $24, $7C, $FE, $A8, $20
    db   $F5, $CD, $A2, $35, $A7, $C9, $37, $C9
    db   $21, $00, $A5, $7E, $FE, $FF, $20, $F1
    db   $24, $7C, $FE, $A8, $20, $F5, $18, $EE
    db   $F0, $A5, $E6, $80, $20, $02, $A7, $C9
    db   $62, $1E, $4D, $1A, $FE, $02, $20, $37
    db   $F0, $AF, $3C, $5F, $17, $9F, $57, $F0
    db   $B1, $4F, $17, $9F, $47, $CD, $D9, $1A
    db   $CD, $4E, $18, $30, $06, $F0, $9E, $FE
    db   $02, $20, $19, $F0, $B3, $6F, $17, $9F
    db   $67, $09, $44, $4D, $CD, $4E, $18, $30
    db   $06, $F0, $9E, $FE, $02, $20, $05, $F0
    db   $9A, $57, $37, $C9, $F0, $9A, $57, $A7
    db   $C9, $F0, $A5, $E6, $40, $20, $02, $A7
    db   $C9, $62, $2E, $04, $4E, $2C, $46, $2E
    db   $07, $5E, $2C, $56, $CD, $46, $16, $FE
    db   $10, $28, $16, $FE, $90, $28, $12, $FE
    db   $18, $28, $05, $A7, $F0, $9A, $57, $C9
    db   $FA, $60, $DB, $CD, $11, $16, $B7, $20
    db   $F2, $FA, $4D, $CD, $B7, $20, $EC, $CD
    db   $67, $10, $37, $F0, $9A, $57, $C9, $F0
    db   $A6, $E6, $04, $20, $02, $A7, $C9, $1E
    db   $28, $21, $99, $42, $3E, $1E, $CD, $CF
    db   $05, $F0, $9A, $57, $37, $C9, $1E, $45
    db   $1A, $17, $F0, $A5, $06, $10, $38, $02
    db   $06, $20, $A0, $20, $02, $A7, $C9, $37
    db   $C9, $CD, $47, $38, $1E, $6D, $1A, $BC
    db   $20, $02, $A7, $C9, $37, $C9, $F0, $A5
    db   $E6, $02, $28, $02, $A7, $C9, $37, $C9
    db   $FA, $70, $A0, $B7, $20, $0F, $CD, $B3
    db   $1A, $20, $0A, $1E, $00, $01, $40, $01
    db   $CD, $35, $0D, $37, $C9, $A7, $C9, $FA
    db   $70, $A0, $B7, $20, $02, $A7, $C9, $CD
    db   $B3, $1A, $28, $F9, $37, $C9, $FA, $70
    db   $A0, $B7, $20, $15, $CD, $B3, $1A, $20
    db   $10, $CD, $48, $3A, $CD, $5A, $3C, $1E
    db   $00, $01, $40, $01, $CD, $35, $0D, $37
    db   $C9, $A7, $C9, $FA, $70, $A0, $B7, $20
    db   $02, $A7, $C9, $CD, $B3, $1A, $28, $F9
    db   $CD, $57, $3A, $CD, $5A, $3C, $37, $C9
    db   $F0, $A5, $E6, $41, $20, $02, $A7, $C9
    db   $AF, $EA, $6E, $A0, $37, $C9, $F0, $A5
    db   $06, $00, $E6, $F1, $28, $0C, $06, $02
    db   $CB, $47, $20, $06, $05, $CB, $7F, $20
    db   $01, $04, $1E, $6F, $1A, $B8, $20, $02
    db   $A7, $C9, $78, $12, $37, $C9, $1E, $0F
    db   $1A, $91, $1C, $1A, $98, $3F, $C9, $CD
    db   $46, $08, $3E, $08, $CD, $DD, $05, $C3
    db   $58, $73, $1E, $45, $1A, $EE, $80, $12
    db   $C9, $FA, $5B, $A0, $1E, $27, $3C, $12
    db   $C9, $F0, $A5, $E6, $40, $28, $04, $FA
    db   $70, $A0, $3D, $1E, $27, $12, $C9, $CD
    db   $26, $38, $3E, $00, $17, $1E, $27, $12
    db   $C9, $1E, $45, $1A, $17, $F0, $A5, $38
    db   $06, $CB, $67, $20, $08, $18, $04, $CB
    db   $6F, $20, $02, $A7, $C9, $37, $C9, $CD
    db   $47, $38, $1E, $27, $7C, $12, $1E, $6D
    db   $12, $C9, $1E, $4D, $1A, $FE, $04, $26
    db   $00, $38, $11, $1E, $45, $1A, $20, $07
    db   $24, $17, $30, $08, $24, $18, $05, $24
    db   $17, $38, $01, $24, $1E, $4E, $1A, $E6
    db   $F0, $FE, $70, $C0, $7C, $C6, $03, $67
    db   $C9, $1E, $45, $1A, $17, $F0, $A5, $38
    db   $08, $CB, $67, $28, $16, $5C, $C3, $A2
    db   $0C, $CB, $6F, $28, $0E, $5C, $79, $2F
    db   $C6, $01, $4F, $78, $2F, $CE, $00, $47
    db   $C3, $D3, $0C, $5D, $C3, $04, $0D, $F0
    db   $A5, $E6, $30, $28, $1E, $CB, $67, $1E
    db   $45, $28, $07, $3E, $40, $12, $5C, $C3
    db   $A2, $0C, $3E, $C0, $12, $5C, $79, $2F
    db   $C6, $01, $4F, $78, $2F, $CE, $00, $47
    db   $C3, $D3, $0C, $5D, $C3, $04, $0D, $F0
    db   $A5, $E6, $30, $28, $3B, $CB, $67, $1E
    db   $45, $1A, $28, $11, $17, $38, $06, $F0
    db   $85, $5F, $C3, $A2, $0C, $F0, $86, $5F
    db   $44, $4D, $C3, $A2, $0C, $17, $30, $10
    db   $F0, $85, $5F, $79, $2F, $C6, $01, $4F
    db   $78, $2F, $CE, $00, $47, $C3, $D3, $0C
    db   $F0, $86, $5F, $7D, $2F, $C6, $01, $4F
    db   $7C, $2F, $CE, $00, $47, $C3, $D3, $0C
    db   $1E, $45, $1A, $17, $1E, $0D, $1A, $38
    db   $05, $17, $30, $05, $18, $09, $17, $30
    db   $06, $F0, $80, $5F, $C3, $04, $0D, $F0
    db   $81, $5F, $C3, $04, $0D, $CD, $DF, $76
    db   $18, $08, $CD, $C7, $1D, $18, $03, $CD
    db   $8B, $1D, $30, $13, $1E, $45, $1A, $47
    db   $1E, $0E, $1A, $A8, $17, $38, $06, $1E
    db   $0D, $AF, $12, $1C, $12, $37, $C9, $A7
    db   $C9, $CD, $66, $77, $18, $03, $CD, $0A
    db   $1C, $30, $08, $AF, $1E, $0F, $12, $1C
    db   $12, $37, $C9, $A7, $C9, $CD, $66, $77
    db   $18, $03, $CD, $0A, $1C, $30, $14, $F0
    db   $9E, $FE, $01, $28, $06, $1E, $0D, $AF
    db   $12, $1C, $12, $AF, $1E, $0F, $12, $1C
    db   $12, $37, $C9, $A7, $C9, $CD, $DD, $77
    db   $18, $03, $CD, $88, $1C, $30, $0F, $F0
    db   $9F, $FE, $31, $CC, $63, $3C, $1E, $0F
    db   $AF, $12, $1C, $12, $37, $C9, $A7, $C9
    db   $CD, $DD, $77, $18, $03, $CD, $88, $1C
    db   $30, $23, $F0, $9F, $FE, $31, $CC, $63
    db   $3C, $62, $2E, $10, $3A, $17, $38, $0D
    db   $2A, $D6, $B3, $7E, $DE, $00, $38, $05
    db   $1E, $52, $3E, $02, $12, $1E, $0F, $AF
    db   $12, $1C, $12, $37, $C9, $A7, $C9, $CD
    db   $66, $77, $18, $03, $CD, $0A, $1C, $30
    db   $28, $62, $2E, $10, $3A, $17, $30, $0D
    db   $2A, $D6, $40, $7E, $DE, $FF, $30, $05
    db   $3E, $01, $1E, $52, $12, $F0, $9E, $FE
    db   $01, $28, $06, $1E, $0D, $AF, $12, $1C
    db   $12, $AF, $1E, $0F, $12, $1C, $12, $37
    db   $C9, $A7, $C9, $FA, $58, $A0, $CB, $7F
    db   $26, $00, $20, $09, $24, $FA, $59, $A0
    db   $FE, $02, $38, $01, $24, $1E, $27, $7C
    db   $12, $C9, $FA, $58, $A0, $EA, $5B, $A0
    db   $FA, $5A, $A0, $EA, $5C, $A0, $AF, $EA
    db   $74, $A0, $C9, $1E, $56, $1A, $FE, $02
    db   $30, $01, $AF, $1E, $27, $12, $C9, $FA
    db   $70, $A0, $B7, $20, $1C, $CD, $B3, $1A
    db   $20, $17, $1E, $00, $01, $40, $01, $CD
    db   $35, $0D, $CD, $09, $28, $38, $02, $37
    db   $C9, $3E, $01, $EA, $70, $A0, $CD, $5A
    db   $3C, $A7, $C9, $3E, $0C, $EA, $6E, $A0
    db   $AF, $EA, $6F, $A0, $3E, $01, $EA, $70
    db   $A0, $C9, $AF, $EA, $70, $A0, $C9, $10
    db   $52, $11, $6A, $3A, $0F, $52, $00, $24
    db   $05, $0D, $77, $0F, $00, $0C, $C5, $FA
    db   $71, $A0, $21, $87, $3A, $85, $6F, $30
    db   $01, $24, $7E, $4F, $17, $9F, $47, $62
    db   $2E, $07, $7E, $81, $22, $7E, $88, $77
    db   $C1, $C9, $00, $FC, $FE, $FA, $FA, $71
    db   $A0, $B7, $21, $4C, $A0, $28, $09, $78
    db   $CB, $3F, $CE, $00, $47, $21, $72, $A0
    db   $7E, $90, $77, $30, $02, $AF, $77, $3E
    db   $01, $EA, $54, $A0, $C9, $EA, $62, $A0
    db   $2A, $EA, $5D, $A0, $1E, $45, $1A, $17
    db   $2A, $30, $02, $2F, $3C, $4F, $17, $9F
    db   $47, $1E, $04, $1A, $1C, $81, $EA, $5E
    db   $A0, $1A, $88, $EA, $5F, $A0, $2A, $4F
    db   $17, $9F, $47, $1E, $07, $1A, $1C, $81
    db   $EA, $60, $A0, $1A, $88, $EA, $61, $A0
    db   $2A, $E0, $A2, $7E, $E0, $A3, $C9, $FA
    db   $5B, $A0, $18, $02, $3E, $FF, $EA, $15
    db   $DF, $FA, $5D, $A0, $3C, $20, $02, $A7
    db   $C9, $AF, $EA, $0B, $DF, $21, $A3, $FF
    db   $1E, $60, $1A, $96, $4F, $1C, $1A, $DE
    db   $00, $47, $79, $E6, $F0, $4F, $C5, $1D
    db   $1A, $86, $91, $CB, $37, $E6, $0F, $3C
    db   $EA, $0E, $DF, $2D, $1E, $5E, $1A, $96
    db   $EA, $0F, $DF, $4F, $1C, $1A, $DE, $00
    db   $EA, $10, $DF, $47, $79, $E6, $F0, $4F
    db   $1D, $1A, $86, $91, $CB, $37, $E6, $0F
    db   $3C, $EA, $0C, $DF, $EA, $0D, $DF, $D1
    db   $18, $1C, $21, $0F, $DF, $2A, $4F, $46
    db   $FA, $0C, $DF, $EA, $0D, $DF, $7B, $C6
    db   $10, $5F, $30, $01, $14, $18, $07, $79
    db   $C6, $10, $4F, $30, $01, $04, $CD, $8F
    db   $3B, $30, $05, $3E, $01, $EA, $0B, $DF
    db   $FA, $0D, $DF, $3D, $EA, $0D, $DF, $20
    db   $E6, $FA, $0E, $DF, $3D, $EA, $0E, $DF
    db   $20, $C8, $FA, $0B, $DF, $B7, $20, $05
    db   $F0, $9A, $57, $A7, $C9, $F0, $9A, $57
    db   $CD, $71, $28, $1E, $0F, $CD, $7A, $0F
    db   $37, $C9, $CD, $46, $16, $EA, $13, $DF
    db   $67, $E6, $07, $FE, $01, $20, $56, $7C
    db   $FE, $21, $28, $2C, $FE, $29, $20, $08
    db   $FA, $15, $DF, $3C, $28, $47, $18, $20
    db   $FE, $41, $38, $41, $FE, $79, $30, $3D
    db   $1F, $1F, $1F, $E6, $1F, $D6, $08, $E5
    db   $21, $F4, $3B, $85, $6F, $30, $01, $24
    db   $66, $FA, $15, $DF, $BC, $E1, $20, $25
    db   $C5, $D5, $7D, $E0, $80, $CD, $02, $3C
    db   $F0, $80, $3C, $CD, $A8, $15, $FA, $13
    db   $DF, $FE, $71, $1E, $19, $20, $02, $1E
    db   $53, $21, $99, $42, $3E, $1E, $CD, $CF
    db   $05, $D1, $C1, $37, $C9, $A7, $C9, $06
    db   $01, $02, $03, $04, $05, $00, $CD, $09
    db   $3C, $C8, $36, $10, $C9, $CD, $0E, $3C
    db   $C8, $36, $05, $C9, $21, $B2, $A8, $18
    db   $03, $21, $A5, $A2, $C5, $D5, $7B, $E6
    db   $F0, $F6, $08, $5F, $79, $E6, $F0, $F6
    db   $08, $4F, $3E, $01, $CD, $C4, $07, $7C
    db   $B7, $2E, $51, $D1, $C1, $C9, $62, $2E
    db   $45, $7E, $17, $30, $0A, $79, $2F, $C6
    db   $01, $4F, $78, $2F, $CE, $00, $47, $2E
    db   $0D, $71, $2C, $70, $C9, $FA, $5B, $A0
    db   $3C, $EA, $E0, $DE, $21, $DE, $DE, $CB
    db   $DE, $C9, $0A, $03, $EA, $E0, $DE, $21
    db   $DE, $DE, $CB, $DE, $C9, $01, $60, $3C
    db   $C3, $92, $0F, $07, $00, $00, $06, $08
    db   $21, $56, $CD, $2A, $B7, $28, $06, $2C
    db   $2C, $05, $20, $F7, $C9, $2D, $36, $20
    db   $2C, $F0, $9C, $4F, $22, $F0, $9D, $47
    db   $77, $0A, $3C, $02, $E0, $84, $59, $CB
    db   $31, $CD, $B0, $15, $21, $12, $DF, $34
    db   $F0, $9A, $57, $A7, $C9, $CD, $F8, $2A
    db   $AF, $21, $37, $DF, $22, $77, $1E, $61
    db   $21, $99, $42, $3E, $1E, $CD, $CF, $05
    db   $3E, $18, $CD, $DD, $05, $21, $11, $6B
    db   $11, $00, $90, $CD, $08, $07, $3E, $18
    db   $CD, $DD, $05, $21, $9F, $64, $11, $00
    db   $80, $CD, $08, $07, $21, $30, $DD, $7B
    db   $22, $72, $7B, $D6, $00, $5F, $7A, $DE
    db   $80, $57, $7B, $06, $04, $CB, $3A, $1F
    db   $05, $20, $FA, $EA, $34, $DF, $3E, $18
    db   $CD, $DD, $05, $21, $6B, $6D, $11, $00
    db   $98, $CD, $08, $07, $21, $60, $99, $11
    db   $00, $9C, $01, $E0, $00, $CD, $21, $06
    db   $21, $35, $DF, $3E, $32, $22, $3E, $62
    db   $22, $AF, $77, $21, $1B, $5B, $3E, $07
    db   $CD, $CF, $05, $CD, $6D, $04, $1E, $1D
    db   $21, $11, $60, $3E, $1E, $CD, $CF, $05
    db   $3E, $08, $CD, $DD, $05, $CD, $00, $40
    db   $3E, $8B, $26, $A0, $2E, $B3, $06, $00
    db   $48, $51, $5A, $CD, $C4, $07, $11, $04
    db   $0C, $21, $46, $42, $3E, $1A, $CD, $CF
    db   $05, $CD, $96, $04, $CD, $6B, $08, $CD
    db   $AE, $04, $CD, $43, $03, $FA, $2D, $DD
    db   $A7, $20, $06, $FA, $46, $DA, $A7, $20
    db   $E8, $11, $04, $0C, $21, $7B, $42, $3E
    db   $1A, $CD, $CF, $05, $CD, $37, $04, $21
    db   $DA, $5A, $3E, $07, $CD, $CF, $05, $C9
    db   $21, $35, $DF, $2A, $4F, $7E, $67, $69
    db   $1E, $43, $2A, $12, $2A, $EA, $2F, $DD
    db   $EA, $39, $DF, $F0, $A4, $E5, $F5, $D5
    db   $3E, $07, $CD, $DD, $05, $FA, $39, $DF
    db   $6F, $26, $00, $54, $5D, $29, $19, $29
    db   $11, $29, $56, $19, $D1, $1E, $18, $2A
    db   $12, $1D, $2A, $12, $1D, $7E, $12, $1E
    db   $46, $FA, $34, $DF, $12, $F1, $CD, $DD
    db   $05, $E1, $01, $35, $DF, $7D, $02, $03
    db   $7C, $02, $21, $1C, $5A, $3E, $07, $CD
    db   $CF, $05, $C9, $21, $35, $DF, $2A, $4F
    db   $7E, $67, $69, $2A, $E6, $07, $CB, $37
    db   $17, $01, $00, $9C, $81, $4F, $30, $01
    db   $04, $2A, $81, $4F, $30, $01, $04, $F0
    db   $92, $5F, $16, $C4, $2A, $F5, $CB, $47
    db   $20, $04, $3E, $07, $18, $03, $3E, $0B
    db   $0D, $E0, $4B, $79, $12, $1C, $78, $12
    db   $1C, $F1, $12, $1C, $47, $2A, $12, $1C
    db   $05, $20, $FA, $7B, $E0, $92, $01, $35
    db   $DF, $7D, $02, $03, $7C, $02, $C9, $0C
    db   $21, $46, $42, $3E, $1A, $CD, $F9, $05
    db   $CD, $C0, $04, $CD, $15, $09, $CD, $D8
    db   $04, $CD, $43, $03, $FA, $2C, $DD, $A7
    db   $20, $06, $FA, $46, $DA, $A7, $20, $E8
    db   $11, $04, $0C, $21, $7B, $42, $3E, $1A
    db   $CD, $F9, $05, $CD, $61, $04, $21, $EB
    db   $5A, $3E, $07, $CD, $F9, $05, $C9, $21
    db   $34, $DF, $2A, $4F, $7E, $67, $69, $1E
    db   $43, $2A, $12, $2A, $EA, $2E, $DD, $EA
    db   $38, $DF, $F0, $A4, $E5, $F5, $D5, $3E
    db   $07, $CD, $07, $06, $FA, $38, $DF, $6F
    db   $26, $00, $54, $5D, $29, $19, $29, $11
    db   $3A, $56, $19, $D1, $1E, $18, $2A, $12
    db   $1D, $2A, $12, $1D, $7E, $12, $1E, $46
    db   $FA, $33, $DF, $12, $F1, $CD, $07, $06
    db   $E1, $01, $34, $DF, $7D, $02, $03, $7C
    db   $02, $21, $2D, $5A, $3E, $07, $CD, $F9
    db   $05, $C9, $21, $34, $DF, $2A, $4F, $7E
    db   $67, $69, $2A, $E6, $07, $CB, $37, $17
    db   $01, $00, $9C, $81, $4F, $30, $01, $04
    db   $2A, $81, $4F, $30, $01, $04, $F0, $92
    db   $5F, $16, $C4, $2A, $F5, $CB, $47, $20
    db   $04, $3E, $07, $18, $03, $3E, $0B, $0D
    db   $E0, $4B, $79, $12, $1C, $78, $12, $1C
    db   $F1, $12, $1C, $47, $2A, $12, $1C, $05
    db   $20, $FA, $7B, $E0, $92, $01, $34, $DF
    db   $7D, $02, $03, $7C, $02, $C9, $00, $00
    db   $00, $00, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FA, $08, $20, $09, $59
    db   $09, $6C, $09, $88, $09, $0A, $09, $97
    db   $09, $0C, $0A, $18, $0A, $41, $0A, $56
    db   $0A, $6F, $0A, $B4, $0A, $E3, $0A, $1F
    db   $0B, $37, $09, $40, $09, $BA, $09, $CE
    db   $09, $E2, $09, $F7, $09, $14, $09, $F1
    db   $08, $7C, $09, $24, $0A, $28, $09, $4A
    db   $09, $A0, $09, $86, $0A, $C4, $0A, $3E
    db   $0B, $EF, $0A, $74, $0B, $84, $0B, $55
    db   $09, $68, $09, $01, $0B, $07, $0B, $0D
    db   $0B, $13, $0B, $19, $0B, $31, $0A, $39
    db   $0A, $00, $3B, $00, $AA, $01, $12, $01
    db   $75, $01, $D3, $02, $2B, $02, $7E, $02
    db   $CD, $03, $17, $03, $5D, $03, $A0, $03
    db   $DE, $04, $19, $04, $51, $04, $86, $04
    db   $B8, $04, $E7, $05, $13, $05, $3D, $05
    db   $64, $05, $8A, $05, $AD, $05, $CE, $05
    db   $EE, $06, $0B, $06, $27, $06, $42, $06
    db   $5B, $06, $72, $06, $89, $06, $9E, $06
    db   $B2, $06, $C4, $06, $D6, $06, $E7, $06
    db   $F6, $07, $05, $07, $13, $07, $21, $07
    db   $2D, $07, $39, $07, $44, $07, $4E, $07
    db   $58, $07, $62, $07, $6B, $07, $73, $07
    db   $7B, $07, $82, $07, $89, $07, $90, $07
    db   $96, $07, $9C, $07, $A2, $07, $A7, $07
    db   $AC, $07, $B1, $07, $B5, $07, $B9, $07
    db   $BD, $07, $C1, $07, $C4, $07, $C8, $07
    db   $CB, $07, $CE, $07, $D1, $07, $D3, $07
    db   $D6, $07, $D8, $07, $DA, $07, $DC, $07
    db   $DE, $FF, $FF, $FF, $FF, $FF, $FF, $7F
    db   $FF, $FF, $FF, $FF, $FF, $DF, $FF, $FD
    db   $FF, $FF, $FB, $FF, $BF, $FF, $FF, $FF
    db   $FF, $FF, $00
