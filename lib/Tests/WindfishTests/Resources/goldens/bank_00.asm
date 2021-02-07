SECTION "ROM Bank 00", ROM0[$00]

RST_0000:
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0008:
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0010:
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0018:
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0020:
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

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
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

RST_0038:
    ret


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

    jp   toc_01_0153

    db   $FF, $FF, $FF, $FF, $FF

    reti


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

    reti


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

    reti


    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

    reti


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
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF

    nop
    jp   toc_01_0150

    db   $CE, $ED, $66, $66, $CC, $0D, $00, $0B
    db   $03, $73, $00, $83, $00, $0C, $00, $0D
    db   $00, $08, $11, $1F, $88, $89, $00, $0E
    db   $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
    db   $BB, $BB, $67, $63, $6E, $0E, $EC, $CC
    db   $DD, $DC, $99, $9F, $BB, $B9, $33, $3E

    db   "2048-gb    XXXX"

    db   $00

    db   $58, $58

    db   $FF

    db   $03

    db   $00, $01, $01

    db   $33, $FF, $5D, $83, $67

toc_01_0150:
    jp   toc_01_047D

toc_01_0153:
    push af
    push bc
    push de
    push hl
    ld   a, [$FF96]
    and  a
    jr   z, .else_01_0164

    call toc_01_0179
    xor  a
    ld   [$FF96], a
    jr   .toc_01_0167

.else_01_0164:
    call toc_01_02BB
.toc_01_0167:
    call $FF80
    call toc_01_03AD
    ld   hl, $FFF0
    inc  [hl]
    call toc_01_03FE
    pop  hl
    pop  de
    pop  bc
    pop  af
    reti


toc_01_0179:
    ld   [$CFFE], sp
    ld   sp, $C016
    ld   hl, $9822
    ld   b, $06
.loop_01_0184:
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    ld   de, $0010
    add  hl, de
    add  sp, $04
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    ld   de, $0010
    add  hl, de
    add  sp, $04
    dec  b
    jr   nz, .loop_01_0184

    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    ld   de, $0010
    add  hl, de
    add  sp, $04
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
.loop_01_021B:
    ld   a, [$FF41]
    and  %00000011
    and  a
    jr   nz, .loop_01_021B

    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    ld   de, $0010
    add  hl, de
    add  sp, $04
.loop_01_0246:
    ld   a, [$FF41]
    and  %00000011
    and  a
    jr   nz, .loop_01_0246

    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
.loop_01_026B:
    ld   a, [$FF41]
    and  %00000011
    and  a
    jr   nz, .loop_01_026B

    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    ld   de, $0010
    add  hl, de
    add  sp, $04
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
.loop_01_0296:
    ld   a, [$FF41]
    and  %00000011
    and  a
    jr   nz, .loop_01_0296

    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    pop  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldi  [hl], a
    ld   a, [$CFFE]
    ld   l, a
    ld   a, [$CFFF]
    ld   h, a
    ld   sp, hl
    ret


toc_01_02BB:
    ld   hl, $C154
    ld   de, $9A20
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ld   a, [hl]
    ld   [de], a
    ret


toc_01_02FD:
    xor  a
    ld   [$FF0F], a
    ld   a, [$FFFF]
    ld   b, a
    res  0, a
    ld   [$FFFF], a
.loop_01_0307:
    ld   a, [$FF44]
    cp   $91
    jr   nz, .loop_01_0307

    ld   a, [$FF40]
    and  %01111111
    ld   [$FF40], a
    ld   a, b
    ld   [$FFFF], a
    ret


toc_01_0317:
    ld   a, [$FF40]
    set  7, a
    ld   [$FF40], a
    ret


toc_01_031E:
    ld   a, $E4
    ld   [$FF47], a
    call toc_01_0356
.toc_01_0325:
    ld   a, $A4
    ld   [$FF47], a
    call toc_01_0356
    ld   a, $54
    ld   [$FF47], a
    call toc_01_0356
    ld   a, $00
    ld   [$FF47], a
    jp   toc_01_0356

toc_01_033A:
    ld   a, $00
    ld   [$FF47], a
    call toc_01_0356
    ld   a, $54
    ld   [$FF47], a
    call toc_01_0356
    ld   a, $A4
    ld   [$FF47], a
    call toc_01_0356
    ld   a, $E4
    ld   [$FF47], a
    jp   toc_01_0356

toc_01_0356:
    ld   b, $04
    jp   .loop_01_035B

.loop_01_035B:
    halt
    nop
    dec  b
    jr   nz, .loop_01_035B

    ret


toc_01_0361:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    dec  bc
    ld   a, c
    or   b
    jr   nz, toc_01_0361

    ret


    db   $2A, $12, $13, $3C, $C8, $18, $F9, $22
    db   $3C, $B8, $20, $FB, $C9

toc_01_0377:
    ldi  [hl], a
    dec  b
    jr   nz, toc_01_0377

    ret


toc_01_037C:
    cp   c
    ret  c

    sub  a, c
    jr   toc_01_037C

toc_01_0381:
    ld   [hl], d
    inc  hl
    ld   [hl], e
    ld   c, a
    ld   a, e
    add  a, $08
    ld   e, a
    ld   a, c
    inc  hl
    ldi  [hl], a
    inc  a
    inc  a
    ld   [hl], $00
    inc  hl
    dec  b
    jr   nz, toc_01_0381

    ret


toc_01_0395:
    xor  a
    ld   hl, $C200
    ld   b, $A0
    call toc_01_0377
    ret


toc_01_039F:
    ld   hl, $C000
    ld   bc, $0168
.loop_01_03A5:
    xor  a
    ldi  [hl], a
    dec  bc
    ld   a, b
    or   c
    jr   nz, .loop_01_03A5

    ret


toc_01_03AD:
    ld   a, [$FFF8]
    ld   [$FFF9], a
    ld   a, $20
    ld   c, $00
    ld   [$FF00], a
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    cpl
    and  %00001111
    swap a
    ld   b, a
    ld   a, $10
    ld   [$FF00], a
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    ld   a, [$FF00]
    cpl
    and  %00001111
    or   b
    ld   [$FFF8], a
    ld   a, $30
    ld   [$FF00], a
    ld   a, [$FFF8]
    ld   b, a
    ld   a, [$FFF9]
    xor  %11111111
    and  b
    ld   [$FFFA], a
    ld   a, [$FFF8]
    cp   $0F
    ret  nz

    jp   toc_01_0150

    db   $C9

toc_01_03FE:
    ld   a, [$FF04]
    ld   b, a
    ld   a, [$FFF1]
    xor  b
    ld   [$FFF1], a
    ret


toc_01_0407:
    halt
    nop
    ld   a, [$FFFA]
    and  %00001001
    jr   z, toc_01_0407

    ret


toc_01_0410:
    ld   c, $80
    ld   b, $0A
    ld   hl, $041E
.loop_01_0417:
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    dec  b
    jr   nz, .loop_01_0417

    ret


    db   $3E, $C2, $E0, $46, $3E, $28, $3D, $20
    db   $FD, $C9

toc_01_0428:
    ld   a, $0A
    ld   [RST_0000], a
    xor  a
    ld   [$6000], a
    ld   [$4000], a
    ret


toc_01_0435:
    xor  a
    ld   [$6000], a
    ld   [RST_0000], a
    ret


toc_01_043D:
    call toc_01_0428
    ld   hl, $A000
    ldi  a, [hl]
    cp   $20
    jr   nz, toc_01_0435

    ldi  a, [hl]
    cp   $48
    jr   nz, toc_01_0435

    ldi  a, [hl]
    ld   [$FFB3], a
    ldi  a, [hl]
    ld   [$FFB4], a
    ldi  a, [hl]
    ld   [$FFB5], a
    ldi  a, [hl]
    ld   [$FFBA], a
    ldi  a, [hl]
    ld   [$FFBB], a
    jp   toc_01_0435

toc_01_045F:
    call toc_01_0428
    ld   hl, $A000
    ld   a, $20
    ldi  [hl], a
    ld   a, $48
    ldi  [hl], a
    ld   a, [$FFB3]
    ldi  [hl], a
    ld   a, [$FFB4]
    ldi  [hl], a
    ld   a, [$FFB5]
    ldi  [hl], a
    ld   a, [$FFBA]
    ldi  [hl], a
    ld   a, [$FFBB]
    ldi  [hl], a
    jp   toc_01_0435

toc_01_047D:
    di
    ld   a, $E4
    ld   [$FF47], a
    ld   a, $D0
    ld   [$FF48], a
    xor  a
    ld   [$FF43], a
    ld   [$FF42], a
    ld   a, $C7
    ld   [$FF40], a
    ei
    call toc_01_02FD
    ld   hl, $C000
    ld   l, [hl]
    ld   a, [hl]
    push af
    ld   hl, $C000
.loop_01_049C:
    ld   a, $00
    ldi  [hl], a
    ld   a, h
    cp   $E0
    jr   nz, .loop_01_049C

    pop  af
    ld   sp, $DFFE
    push af
    ld   hl, $FF80
.loop_01_04AC:
    ld   a, $00
    ldi  [hl], a
    ld   a, h
    cp   $00
    jr   nz, .loop_01_04AC

    pop  af
    ld   [$FFF1], a
    call toc_01_0410
    ld   a, $01
    ld   [$FF97], a
    ld   hl, $2587
    ld   de, $9000
    ld   bc, $0800
    call toc_01_0361
    ld   hl, $2D87
    ld   de, $8800
    ld   bc, $0100
    call toc_01_0361
    ld   hl, $0531
    ld   de, $C000
    ld   bc, $0154
    call toc_01_0361
    call toc_01_0179
    call toc_01_043D
    call toc_01_0317
    ld   [$FFFF], a
    ld   a, $01
    ld   [$FFFF], a
    ei
    halt
    nop
    xor  a
    ld   [$FF97], a
    call toc_01_0407
    call toc_01_031E
    call toc_01_039F
    call toc_01_02FD
    ld   hl, $0D07
    ld   de, $9000
    ld   bc, $0800
    call toc_01_0361
    ld   hl, $1507
    ld   de, $8800
    ld   bc, $0800
    call toc_01_0361
    ld   hl, $1D87
    ld   de, $8000
    ld   bc, $0800
    call toc_01_0361
    ld   a, $01
    ld   [$FF96], a
    call toc_01_0317
    jp   toc_01_0C41

    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $0F, $01, $02, $03, $04, $05
    db   $06, $07, $08, $09, $0A, $0B, $0C, $0D
    db   $0E, $00, $00, $00, $00, $00, $10, $11
    db   $12, $13, $14, $15, $16, $17, $18, $19
    db   $1A, $1B, $1C, $1D, $1E, $1F, $00, $00
    db   $00, $00, $20, $21, $22, $23, $24, $25
    db   $26, $27, $28, $29, $2A, $2B, $2C, $2D
    db   $2E, $2F, $00, $00, $00, $00, $30, $31
    db   $32, $33, $34, $35, $36, $37, $38, $39
    db   $3A, $3B, $3C, $3D, $3E, $3F, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $7E, $7F, $00
    db   $00, $00, $00, $00, $00, $00, $40, $41
    db   $42, $43, $44, $45, $46, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $47, $48, $49, $4A
    db   $4B, $4C, $4D, $4E, $4F, $50, $51, $52
    db   $53, $54, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $55, $56, $57, $58, $59, $5A
    db   $5B, $5C, $5D, $86, $87, $88, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $5E, $5F, $60, $61, $62, $63, $64, $65
    db   $66, $67, $68, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $69, $6A
    db   $6B, $6C, $6D, $6E, $6F, $70, $71, $72
    db   $73, $74, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $75, $76, $77, $78
    db   $79, $7A, $7B, $7C, $7D, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $80
    db   $81, $82, $83, $84, $85, $00, $00, $00
    db   $00, $00, $00, $00, $B8, $D8, $90, $18
    db   $FB, $0E, $00, $B8, $38, $04, $90, $0C
    db   $18, $F9, $79, $C9, $01, $00, $02, $00
    db   $04, $00, $08, $00, $16, $00, $32, $00
    db   $64, $00, $28, $01, $56, $02, $12, $05
    db   $24, $10, $48, $20, $96, $40, $92, $81

toc_01_06B1:
    push hl
    push de
    ld   hl, $0695
    ld   e, a
    ld   d, $00
    add  hl, de
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   [$FFB7], a
    ld   a, h
    ld   [$FFB6], a
    push hl
    pop  de
    ld   hl, $FFB2
    ld   a, [hl]
    add  a, e
    daa
    ldd  [hl], a
    ld   a, [hl]
    adc  d
    daa
    ldd  [hl], a
    jr   nc, .else_01_06D3

    inc  [hl]
.else_01_06D3:
    ld   hl, $FFB0
    ld   de, $FFB3
    ld   a, [de]
    cp   [hl]
    jr   z, .else_01_06E1

    jr   nc, .else_01_0706

    jr   c, .else_01_06F5

.else_01_06E1:
    inc  de
    inc  hl
    ld   a, [de]
    cp   [hl]
    jr   z, .else_01_06EB

    jr   nc, .else_01_0706

    jr   c, .else_01_06F5

.else_01_06EB:
    inc  de
    inc  hl
    ld   a, [de]
    cp   [hl]
    jr   z, .else_01_0706

    jr   nc, .else_01_0706

    jr   c, .else_01_06F5

.else_01_06F5:
    ld   de, $FFB5
    ld   hl, $FFB2
    ldd  a, [hl]
    ld   [de], a
    dec  de
    ldd  a, [hl]
    ld   [de], a
    dec  de
    ld   a, [hl]
    ld   [de], a
    call toc_01_045F
.else_01_0706:
    pop  de
    pop  hl
    ret


    db   $78, $A7, $20, $04, $79, $FE, $0A, $D8
    db   $79, $D6, $0A, $4F, $30, $F2, $05, $18
    db   $EF, $D5, $11, $00, $00, $78, $A7, $20
    db   $05, $79, $FE, $0A, $38, $0A, $79, $D6
    db   $0A, $4F, $30, $01, $05, $13, $18, $ED
    db   $D5, $C1, $D1, $C9

toc_01_0735:
    ld   a, [de]
    swap a
    and  %00001111
    add  a, $E8
    ldi  [hl], a
    ld   a, [de]
    and  %00001111
    add  a, $E8
    ldi  [hl], a
    inc  de
    ret


toc_01_0745:
    call toc_01_0735
    call toc_01_0735
    call toc_01_0735
    ret


    db   $C5, $CD, $09, $07, $79, $87, $C6, $60
    db   $32, $C1, $CD, $1A, $07, $C9, $1A, $4F
    db   $13, $1A, $47, $CD, $4F, $07, $CD, $4F
    db   $07, $CD, $4F, $07, $CD, $4F, $07, $C9

toc_01_076F:
    ld   hl, $C154
    ld   a, $E0
    ldi  [hl], a
    inc  a
    ldi  [hl], a
    inc  a
    ldi  [hl], a
    ld   hl, $C15D
    ld   a, $E3
    ldi  [hl], a
    inc  a
    ldi  [hl], a
    inc  a
    ldi  [hl], a
    inc  a
    ldi  [hl], a
    inc  a
    ldi  [hl], a
    ld   hl, $C157
    ld   de, $FFB0
    call toc_01_0745
    ld   hl, $C162
    ld   de, $FFB3
    call toc_01_0745
    ret


    db   $00, $00, $10, $11, $12, $13, $10, $11
    db   $12, $13, $10, $11, $12, $13, $10, $11
    db   $12, $13, $00, $00, $00, $00, $14, $15
    db   $16, $17, $14, $15, $16, $17, $14, $15
    db   $16, $17, $14, $15, $16, $17, $00, $00
    db   $00, $00, $18, $19, $1A, $1B, $18, $19
    db   $1A, $1B, $18, $19, $1A, $1B, $18, $19
    db   $1A, $1B, $00, $00, $00, $00, $1C, $1D
    db   $1E, $1F, $1C, $1D, $1E, $1F, $1C, $1D
    db   $1E, $1F, $1C, $1D, $1E, $1F, $00, $00
    db   $00, $00, $10, $11, $12, $13, $10, $11
    db   $12, $13, $10, $11, $12, $13, $10, $11
    db   $12, $13, $00, $00, $00, $00, $14, $15
    db   $16, $17, $14, $15, $16, $17, $14, $15
    db   $16, $17, $14, $15, $16, $17, $00, $00
    db   $00, $00, $18, $19, $1A, $1B, $18, $19
    db   $1A, $1B, $18, $19, $1A, $1B, $18, $19
    db   $1A, $1B, $00, $00, $00, $00, $1C, $1D
    db   $1E, $1F, $1C, $1D, $1E, $1F, $1C, $1D
    db   $1E, $1F, $1C, $1D, $1E, $1F, $00, $00
    db   $00, $00, $10, $11, $12, $13, $10, $11
    db   $12, $13, $10, $11, $12, $13, $10, $11
    db   $12, $13, $00, $00, $00, $00, $14, $15
    db   $16, $17, $14, $15, $16, $17, $14, $15
    db   $16, $17, $14, $15, $16, $17, $00, $00
    db   $00, $00, $18, $19, $1A, $1B, $18, $19
    db   $1A, $1B, $18, $19, $1A, $1B, $18, $19
    db   $1A, $1B, $00, $00, $00, $00, $1C, $1D
    db   $1E, $1F, $1C, $1D, $1E, $1F, $1C, $1D
    db   $1E, $1F, $1C, $1D, $1E, $1F, $00, $00
    db   $00, $00, $10, $11, $12, $13, $10, $11
    db   $12, $13, $10, $11, $12, $13, $10, $11
    db   $12, $13, $00, $00, $00, $00, $14, $15
    db   $16, $17, $14, $15, $16, $17, $14, $15
    db   $16, $17, $14, $15, $16, $17, $00, $00
    db   $00, $00, $18, $19, $1A, $1B, $18, $19
    db   $1A, $1B, $18, $19, $1A, $1B, $18, $19
    db   $1A, $1B, $00, $00, $00, $00, $1C, $1D
    db   $1E, $1F, $1C, $1D, $1E, $1F, $1C, $1D
    db   $1E, $1F, $1C, $1D, $1E, $1F, $00, $00
    db   $21, $00, $C9, $F0, $A8, $CB, $37, $C6
    db   $0C, $6F, $2A, $CB, $7F, $20, $34, $2A
    db   $CB, $7F, $20, $2F, $2A, $CB, $7F, $20
    db   $2A, $2A, $CB, $7F, $20, $25, $F0, $A9
    db   $A7, $20, $1E, $21, $00, $C9, $F0, $A8
    db   $CB, $37, $C6, $08, $6F, $2A, $CB, $7F
    db   $20, $11, $2A, $CB, $7F, $20, $0C, $2A
    db   $CB, $7F, $20, $07, $2A, $CB, $7F, $20
    db   $02, $AF, $C9, $3E, $01, $C9, $14, $00
    db   $EC, $FF, $FF, $FF, $01, $00

toc_01_0928:
    ld   a, [$FFA9]
    add  a, a
    ld   hl, $0920
    ld   d, $00
    ld   e, a
    add  hl, de
    ldi  a, [hl]
    ld   [$FFA4], a
    ld   a, [hl]
    ld   [$FFA5], a
    ld   hl, $079A
    ld   de, $C014
    ld   bc, $0140
    di
    call toc_01_0361
    ld   bc, $0000
    ld   a, [$FFA6]
    and  a
    jr   z, .else_01_0957

    ld   de, $C900
    ld   a, [$FFA8]
    swap a
    ld   e, a
    jr   .toc_01_095A

.else_01_0957:
    ld   de, $C800
.toc_01_095A:
    ld   hl, $C016
    dec  de
.loop_01_095E:
    inc  de
    ld   a, [de]
    res  7, a
    and  a
    jr   z, .else_01_09D2

    inc  a
    sla  a
    sla  a
    sla  a
    sla  a
    push af
    push bc
    push de
    ld   a, [de]
    bit  7, a
    jr   z, .else_01_0986

    ld   a, [$FFA7]
    and  a
    jr   z, .else_01_0986

    ld   b, a
    ld   a, [$FFA4]
    ld   e, a
    ld   a, [$FFA5]
    ld   d, a
.loop_01_0982:
    add  hl, de
    dec  b
    jr   nz, .loop_01_0982

.else_01_0986:
    pop  de
    pop  bc
    pop  af
    ld   c, $04
.loop_01_098B:
    ldi  [hl], a
    inc  a
    ldi  [hl], a
    inc  a
    ldi  [hl], a
    inc  a
    ldi  [hl], a
    inc  a
    push bc
    ld   bc, $0010
    add  hl, bc
    pop  bc
    dec  c
    jr   nz, .loop_01_098B

    push bc
    ld   bc, $FFB4
    add  hl, bc
    pop  bc
    push af
    push bc
    push de
    ld   a, [de]
    bit  7, a
    jr   z, .else_01_09BD

    ld   a, [$FFA7]
    and  a
    jr   z, .else_01_09BD

    ld   b, a
    ld   a, [$FFA4]
    cpl
    ld   e, a
    ld   a, [$FFA5]
    cpl
    ld   d, a
.loop_01_09B8:
    add  hl, de
    inc  hl
    dec  b
    jr   nz, .loop_01_09B8

.else_01_09BD:
    pop  de
    pop  bc
    pop  af
.toc_01_09C0:
    inc  b
    ld   a, b
    cp   $10
    jr   z, .else_01_09D8

    and  %00000011
    jr   nz, .loop_01_095E

    push bc
    ld   bc, $0040
    add  hl, bc
    pop  bc
    jr   .loop_01_095E

.else_01_09D2:
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    jr   .toc_01_09C0

.else_01_09D8:
    ei
    ret


toc_01_09DA:
    ld   a, $01
    ld   [$FFB8], a
    ld   a, $94
    ld   [$FF47], a
    xor  a
    ld   b, $0A
    ld   de, $4034
    ld   hl, $C200
    call toc_01_0381
    ld   a, $30
    ld   b, $06
    ld   de, $6444
    ld   hl, $C228
    call toc_01_0381
    ret


toc_01_09FC:
    ld   a, $02
    ld   [$FFB8], a
    ld   hl, $FFBA
    ldi  a, [hl]
    ld   d, a
    ld   a, [hl]
    ld   e, a
    inc  de
    ld   a, e
    ldd  [hl], a
    ld   a, d
    ld   [hl], a
    call toc_01_045F
    ld   a, $94
    ld   [$FF47], a
    ld   a, $14
    ld   b, $09
    ld   de, $4038
    ld   hl, $C200
    call toc_01_0381
    ld   a, $30
    ld   b, $06
    ld   de, $6444
    ld   hl, $C224
    call toc_01_0381
    ret


toc_01_0A2E:
    ld   a, [$FFB9]
    and  a
    ret  nz

    ld   hl, $C800
    ld   b, $10
.loop_01_0A37:
    ldi  a, [hl]
    cp   $0B
    ret  z

    dec  b
    jr   nz, .loop_01_0A37

    ld   a, $01
    and  a
    ret


toc_01_0A42:
    ret


    db   $3E, $D0, $E0, $48, $11, $B6, $FF, $21
    db   $F5, $CF, $CD, $5D, $07, $3E, $74, $77
    db   $E5, $D1, $06, $05, $0E, $28, $21, $00
    db   $C2, $3E, $94, $22, $79, $22, $1A, $22
    db   $13, $AF, $22, $79, $C6, $08, $4F, $05
    db   $20, $EF, $3E, $01, $E0, $AA, $C9

toc_01_0A72:
    ret


toc_01_0A73:
    ld   b, $10
.loop_01_0A75:
    res  7, [hl]
    inc  hl
    dec  b
    jr   nz, .loop_01_0A75

    ret


toc_01_0A7C:
    push de
    ld   hl, $C880
    ld   de, $C900
    ld   a, [$FFA3]
    inc  a
    ld   [$FFA3], a
    dec  a
    swap a
    ld   e, a
    ld   bc, $0010
    call toc_01_0361
    ld   hl, $C800
    ld   de, $C880
    ld   bc, $0010
    call toc_01_0361
    ld   hl, $C880
    call toc_01_0A73
    pop  de
    ret


    db   $04, $FC, $FF, $01, $01, $01, $04, $04
    db   $08, $04, $01, $02

toc_01_0AB2:
    ld   a, [$FFA0]
    ld   hl, $0AA6
    ld   d, $00
    ld   e, a
    add  hl, de
    ld   a, [hl]
    ld   [$FFA1], a
    ld   a, [$FFA0]
    ld   hl, $0AAA
    ld   d, $00
    ld   e, a
    add  hl, de
    ld   a, [hl]
    ld   [$FFA2], a
    ret


toc_01_0ACB:
    ld   [$FFA0], a
    call toc_01_0B8A
    ret  z

    call toc_01_0A7C
    xor  a
    ld   [$FFA3], a
    ld   [$FFB6], a
    ld   [$FFB7], a
    call toc_01_0AB2
.toc_01_0ADE:
    ld   a, [$FFA0]
    ld   hl, $0AAE
    ld   d, $00
    ld   e, a
    add  hl, de
    ld   a, [hl]
    ld   hl, $C800
    add  a, l
    ld   l, a
    ld   c, $01
    ld   e, $00
.toc_01_0AF1:
    ld   a, [hl]
    and  a
    jr   z, .else_01_0B07

    ld   b, a
    ld   a, [$FFA1]
    add  a, l
    ld   l, a
    ld   a, [hl]
    and  a
    jr   z, .else_01_0B28

    cp   b
    jr   z, .else_01_0B3B

.loop_01_0B01:
    ld   a, [$FFA1]
    ld   d, a
    ld   a, l
    sub  a, d
    ld   l, a
.else_01_0B07:
    inc  c
    ld   a, c
    and  %00000011
    jr   z, .else_01_0B15

    ld   a, [$FFA1]
    ld   d, a
    ld   a, l
    sub  a, d
    ld   l, a
    jr   .toc_01_0AF1

.else_01_0B15:
    ld   a, c
    cp   $10
    jr   z, .else_01_0B58

    inc  c
    ld   a, [$FFA1]
    ld   d, a
    ld   a, l
    add  a, d
    add  a, d
    ld   l, a
    ld   a, [$FFA2]
    add  a, l
    ld   l, a
    jr   .toc_01_0AF1

.else_01_0B28:
    ld   [hl], b
    ld   a, [$FFA1]
    ld   d, a
    ld   a, l
    sub  a, d
    ld   l, a
    xor  a
    ld   [hl], a
    set  7, l
    set  7, [hl]
    res  7, l
    ld   e, $01
    jr   .else_01_0B07

.else_01_0B3B:
    bit  7, [hl]
    jr   nz, .loop_01_0B01

    inc  [hl]
    ld   a, [hl]
    set  7, [hl]
    call toc_01_06B1
    ld   a, [$FFA1]
    ld   d, a
    ld   a, l
    sub  a, d
    ld   l, a
    xor  a
    ld   [hl], a
    set  7, l
    set  7, [hl]
    res  7, l
    ld   e, $01
    jr   .else_01_0B07

.else_01_0B58:
    call toc_01_0A7C
    ld   a, e
    and  a
    jr   z, .else_01_0B64

    ld   e, $00
    jp   .toc_01_0ADE

.else_01_0B64:
    ld   a, [$FFA0]
    ld   [$FFA9], a
    ld   a, $01
    ld   [$FFA6], a
    ld   [$FF96], a
    xor  a
    ld   [$FFA7], a
    ld   [$FFA8], a
    ld   hl, $C800
    call toc_01_0A73
    call toc_01_0C0B
    call toc_01_0BDF
    call z, toc_01_09DA
    call toc_01_0A2E
    call z, toc_01_09FC
    xor  a
    ret


toc_01_0B8A:
    ld   [$FFA0], a
    call toc_01_0AB2
    ld   a, [$FFA0]
    ld   hl, $0AAE
    ld   d, $00
    ld   e, a
    add  hl, de
    ld   a, [hl]
    ld   hl, $C800
    add  a, l
    ld   l, a
    ld   c, $01
.toc_01_0BA0:
    ld   a, [hl]
    and  a
    jr   z, .else_01_0BB6

    ld   b, a
    ld   a, [$FFA1]
    add  a, l
    ld   l, a
    ld   a, [hl]
    and  a
    jr   z, toc_01_0BD9

    cp   b
    jr   z, toc_01_0BD9

    ld   a, [$FFA1]
    ld   d, a
    ld   a, l
    sub  a, d
    ld   l, a
.else_01_0BB6:
    inc  c
    ld   a, c
    and  %00000011
    jr   z, .else_01_0BC4

    ld   a, [$FFA1]
    ld   d, a
    ld   a, l
    sub  a, d
    ld   l, a
    jr   .toc_01_0BA0

.else_01_0BC4:
    ld   a, c
    cp   $10
    jr   z, toc_01_0BDD

    inc  c
    ld   a, [$FFA1]
    ld   d, a
    ld   a, l
    add  a, d
    add  a, d
    ld   l, a
    ld   a, [$FFA2]
    add  a, l
    ld   l, a
    jr   .toc_01_0BA0

    db   $AF, $C9

toc_01_0BD9:
    ld   a, $01
    and  a
    ret


toc_01_0BDD:
    xor  a
    ret


toc_01_0BDF:
    ld   a, $00
    call toc_01_0B8A
    ret  nz

    ld   a, $01
    call toc_01_0B8A
    ret  nz

    ld   a, $02
    call toc_01_0B8A
    ret  nz

    ld   a, $03
    call toc_01_0B8A
    ret


toc_01_0BF7:
    ld   a, $00
    jp   toc_01_0ACB

toc_01_0BFC:
    ld   a, $01
    jp   toc_01_0ACB

toc_01_0C01:
    ld   a, $02
    jp   toc_01_0ACB

toc_01_0C06:
    ld   a, $03
    jp   toc_01_0ACB

toc_01_0C0B:
    call toc_01_03FE
    cp   $19
    jr   c, .else_01_0C16

    ld   d, $01
    jr   .toc_01_0C18

.else_01_0C16:
    ld   d, $02
.toc_01_0C18:
    ld   b, $10
    ld   c, $00
    ld   hl, $C800
.toc_01_0C1F:
    ldi  a, [hl]
    and  a
    jr   nz, .else_01_0C24

    inc  c
.else_01_0C24:
    dec  b
    jr   z, .else_01_0C29

    jr   .toc_01_0C1F

.else_01_0C29:
    ld   a, c
    and  a
    ret  z

    call toc_01_03FE
    call toc_01_037C
    inc  a
    ld   b, a
    ld   hl, $C800
.loop_01_0C37:
    ldi  a, [hl]
    and  a
    jr   nz, .loop_01_0C37

    dec  b
    jr   nz, .loop_01_0C37

    dec  hl
    ld   [hl], d
    ret


toc_01_0C41:
    xor  a
    ld   [$FFB0], a
    ld   [$FFB1], a
    ld   [$FFB2], a
    ld   [$FFB8], a
    ld   hl, $C800
    ld   b, $10
    call toc_01_0377
    call toc_01_0395
    call toc_01_0C0B
    call toc_01_0C0B
    ld   a, $01
    ld   [$FF96], a
    ld   a, $E4
    ld   [$FF47], a
    call toc_01_0928
    call toc_01_076F
    call toc_01_033A
.loop_01_0C6C:
    halt
    nop
    ld   a, [$FFA6]
    and  a
    jr   z, .else_01_0CAC

    ld   hl, $FFFA
    ld   a, [hl]
    swap a
    and  %00001111
    and  a
    jr   nz, .else_01_0C9C

    ld   a, $01
    ld   [$FF96], a
    call toc_01_0928
    ld   a, [$FFA7]
    inc  a
    ld   [$FFA7], a
    cp   $04
    jr   nz, .loop_01_0C6C

    xor  a
    ld   [$FFA7], a
    ld   a, [$FFA8]
    inc  a
    ld   [$FFA8], a
    ld   b, a
    ld   a, [$FFA3]
    cp   b
    jr   nz, .loop_01_0C6C

.else_01_0C9C:
    xor  a
    ld   [$FFA6], a
    call toc_01_0928
    call toc_01_076F
    call toc_01_0A42
    ld   a, $01
    ld   [$FF96], a
.else_01_0CAC:
    call toc_01_0A72
    ld   a, [$FFB8]
    and  a
    jr   nz, .else_01_0CD2

    ld   hl, $FFFA
    ld   a, [hl]
    ld   [hl], $00
    swap a
    bit  3, a
    call nz, toc_01_0BF7
    bit  2, a
    call nz, toc_01_0BFC
    bit  1, a
    call nz, toc_01_0C01
    bit  0, a
    call nz, toc_01_0C06
    jr   .loop_01_0C6C

.else_01_0CD2:
    call toc_01_0928
    call toc_01_076F
    ld   a, $01
    ld   [$FF96], a
.loop_01_0CDC:
    halt
    nop
    ld   a, [$FFFA]
    and  %00000100
    jr   nz, .else_01_0CF0

    ld   a, [$FFFA]
    and  %00001001
    jr   z, .loop_01_0CDC

    call toc_01_031E.toc_01_0325
    jp   toc_01_0C41

.else_01_0CF0:
    ld   a, [$FFB8]
    cp   $02
    jr   nz, .loop_01_0CDC

    xor  a
    ld   [$FFB8], a
    ld   a, $01
    ld   [$FFB9], a
    call toc_01_0395
    ld   a, $E4
    ld   [$FF47], a
    jp   .loop_01_0C6C

    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $63, $9C, $14, $FF, $14
    db   $EF, $24, $DF, $44, $FB, $73, $8C, $00
    db   $FF, $00, $FF, $08, $FF, $99, $EE, $A8
    db   $FF, $BD, $CB, $89, $7E, $08, $F7, $00
    db   $FF, $00, $FF, $C0, $3F, $20, $DF, $C0
    db   $3F, $2D, $F3, $21, $DE, $C0, $3F, $01
    db   $FF, $00, $FF, $08, $FF, $08, $FF, $EE
    db   $39, $29, $FF, $E9, $3E, $2E, $D1, $C0
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $00, $FF, $00, $FF, $3F, $C0, $3F, $C0
    db   $3F, $C0, $3F, $C0, $3F, $C0, $3F, $C0
    db   $00, $FF, $00, $FF, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $00, $FF, $00, $FF, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $00, $FF, $00, $FF, $FC, $03, $FC, $03
    db   $FC, $03, $FC, $03, $FC, $03, $FC, $03
    db   $3F, $C0, $3F, $C0, $3F, $C0, $3F, $C0
    db   $3F, $C0, $3F, $C0, $3F, $C0, $3F, $C0
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FC, $03, $FC, $03, $FC, $03, $FC, $03
    db   $FC, $03, $FC, $03, $FC, $03, $FC, $03
    db   $3F, $C0, $3F, $C0, $3F, $C0, $3F, $C0
    db   $3F, $C0, $3F, $C0, $3F, $C0, $3F, $C0
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FC, $03, $FC, $03, $FC, $03, $FC, $03
    db   $FC, $03, $FC, $03, $FC, $03, $FC, $03
    db   $3F, $C0, $3F, $C0, $3F, $C0, $3F, $C0
    db   $3F, $C0, $3F, $C0, $00, $FF, $00, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $00, $FF, $00, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $00, $FF, $00, $FF
    db   $FC, $03, $FC, $03, $FC, $03, $FC, $03
    db   $FC, $03, $FC, $03, $00, $FF, $00, $FF
    db   $7F, $FF, $80, $80, $80, $80, $80, $80
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $FF, $FF, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $FF, $FF, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $FE, $FF, $01, $01, $03, $01, $03, $01
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $0B, $07, $0F, $1F, $1F, $3F, $38, $3C
    db   $30, $38, $00, $00, $00, $00, $00, $00
    db   $A0, $C0, $E0, $F0, $F8, $F0, $30, $78
    db   $38, $38, $38, $38, $30, $78, $78, $F0
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $00, $01, $01, $03, $03, $07, $07, $0F
    db   $0E, $1F, $1F, $3F, $3F, $3F, $3F, $3F
    db   $E0, $F0, $C0, $E0, $80, $C0, $00, $80
    db   $00, $00, $F8, $F8, $F8, $F8, $F8, $F8
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $80, $80, $80, $80, $BF, $80, $7F, $FF
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $FF, $00, $FF, $FF
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $FF, $00, $FF, $FF
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $03, $01, $07, $01, $FF, $01, $FE, $FF
    db   $7F, $FF, $80, $80, $80, $80, $80, $80
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $FF, $FF, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $FF, $FF, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $FE, $FF, $01, $01, $03, $01, $03, $01
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $00, $00, $03, $01, $01, $03, $07, $03
    db   $03, $07, $0F, $07, $06, $0F, $1F, $0E
    db   $00, $00, $C0, $C0, $80, $C0, $C0, $80
    db   $00, $80, $80, $00, $70, $70, $70, $70
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $0C, $1E, $3E, $1C, $1F, $3F, $3F, $3F
    db   $3F, $3F, $00, $00, $00, $00, $00, $00
    db   $70, $70, $70, $70, $FC, $FC, $FC, $FC
    db   $FC, $FC, $70, $70, $70, $70, $70, $70
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $80, $80, $80, $80, $80, $80, $80, $80
    db   $80, $80, $80, $80, $BF, $80, $7F, $FF
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $FF, $00, $FF, $FF
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $FF, $00, $FF, $FF
    db   $03, $01, $03, $01, $03, $01, $03, $01
    db   $03, $01, $07, $01, $FF, $01, $FE, $FF
    db   $7F, $FF, $80, $80, $9F, $80, $BF, $80
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $FF, $FF, $00, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $FF, $00, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FE, $FF, $03, $01, $FD, $03, $FD, $03
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $FF, $00, $F9, $07, $EF, $1F, $FF, $1F
    db   $DD, $3E, $DF, $3C, $FD, $1E, $EF, $1F
    db   $FF, $00, $9F, $E0, $F7, $F8, $FF, $F8
    db   $BB, $7C, $FB, $3C, $BF, $78, $F7, $F8
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $F7, $0F, $EF, $1F, $DD, $3E, $FF, $3C
    db   $FD, $3E, $DF, $3F, $EF, $1F, $F3, $0F
    db   $EF, $F0, $F7, $F8, $BB, $7C, $FF, $3C
    db   $BF, $7C, $FB, $FC, $F7, $F8, $CF, $F0
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $BF, $80, $BF, $80, $C0, $BF, $7F, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $00, $FF, $FF, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $00, $FF, $FF, $FF
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $FD, $03, $F9, $07, $01, $FF, $FE, $FF
    db   $7F, $FF, $80, $80, $9F, $80, $BF, $80
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $FF, $FF, $00, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $FF, $00, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FE, $FF, $03, $01, $FD, $03, $FD, $03
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $BF, $80, $BF, $80, $BE, $81, $BD, $83
    db   $BF, $83, $BF, $80, $BF, $80, $BF, $80
    db   $FF, $00, $7F, $F0, $FF, $F0, $FF, $F0
    db   $FE, $F1, $FF, $71, $FF, $71, $FF, $71
    db   $FF, $00, $DD, $3E, $7F, $FF, $FF, $FF
    db   $DD, $E3, $FF, $C0, $DC, $FF, $FF, $FF
    db   $FD, $03, $FD, $03, $7D, $83, $FD, $83
    db   $FD, $83, $FD, $03, $FD, $03, $7D, $83
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $FF, $71, $FF, $71, $FF, $71, $FF, $71
    db   $FF, $71, $FE, $71, $FF, $70, $FF, $70
    db   $FF, $FF, $DD, $E3, $FF, $C1, $FF, $C1
    db   $DD, $E3, $FF, $FF, $7F, $FF, $DD, $3E
    db   $BD, $C3, $FD, $C3, $FD, $C3, $FD, $C3
    db   $FD, $C3, $BD, $C3, $7D, $83, $FD, $03
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $BF, $80, $BF, $80, $C0, $BF, $7F, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $00, $FF, $FF, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $00, $FF, $FF, $FF
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $FD, $03, $F9, $07, $01, $FF, $FE, $FF
    db   $7F, $FF, $80, $80, $9F, $80, $BF, $80
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $FF, $FF, $00, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $FF, $00, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FE, $FF, $03, $01, $FD, $03, $FD, $03
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $BF, $80, $BF, $87, $BF, $87, $BF, $87
    db   $BF, $80, $BF, $80, $BE, $81, $BF, $81
    db   $FF, $00, $FF, $FE, $FF, $FE, $FF, $FE
    db   $BB, $7C, $77, $F8, $EF, $F0, $FD, $FE
    db   $EE, $1F, $BF, $7F, $7F, $FF, $EE, $F1
    db   $DF, $E0, $FF, $00, $FE, $01, $FD, $03
    db   $FD, $03, $BD, $C3, $FD, $C3, $DD, $E3
    db   $FD, $E3, $FD, $E3, $DD, $E3, $FD, $C3
    db   $BF, $81, $BF, $80, $BF, $80, $BF, $80
    db   $BF, $80, $BF, $87, $BF, $87, $BF, $87
    db   $FE, $FF, $F7, $0F, $FF, $07, $FF, $07
    db   $F7, $0F, $FE, $FF, $FD, $FE, $F3, $FC
    db   $FB, $07, $F7, $0F, $EE, $1F, $DD, $3E
    db   $BB, $7C, $7F, $FF, $FF, $FF, $FF, $FF
    db   $BD, $C3, $7D, $83, $FD, $03, $FD, $03
    db   $FD, $03, $FD, $E3, $FD, $E3, $FD, $E3
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $BF, $80, $BF, $80, $C0, $BF, $7F, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $00, $FF, $FF, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $00, $FF, $FF, $FF
    db   $FD, $03, $FD, $03, $FD, $03, $FD, $03
    db   $FD, $03, $F9, $07, $01, $FF, $FE, $FF
    db   $7F, $FF, $FF, $80, $E0, $9F, $C0, $BF
    db   $C0, $BF, $C0, $BF, $C0, $BF, $C0, $BF
    db   $FF, $FF, $FF, $00, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $FF, $FF, $FF, $00, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $FE, $FF, $FD, $03, $03, $FF, $03, $FF
    db   $03, $FF, $03, $FF, $03, $FF, $03, $FF
    db   $C0, $BF, $C1, $BE, $C4, $B8, $C0, $B8
    db   $C9, $B0, $C0, $B1, $C1, $B0, $C0, $B0
    db   $00, $FF, $10, $0F, $04, $03, $00, $03
    db   $10, $E3, $00, $FF, $18, $07, $04, $03
    db   $00, $FF, $00, $F8, $09, $F0, $00, $F1
    db   $12, $E1, $00, $E3, $24, $C2, $00, $C6
    db   $03, $FF, $03, $FF, $03, $FF, $03, $FF
    db   $03, $FF, $03, $FF, $03, $3F, $03, $3F
    db   $C0, $B0, $C1, $B0, $C0, $B1, $C0, $B1
    db   $C1, $B0, $C8, $B0, $C4, $B8, $C1, $BE
    db   $02, $01, $10, $E1, $00, $F1, $00, $F1
    db   $10, $E1, $02, $01, $04, $03, $10, $0F
    db   $48, $86, $00, $8E, $80, $00, $00, $00
    db   $00, $00, $00, $FE, $00, $FE, $00, $FE
    db   $03, $3F, $03, $3F, $03, $0F, $03, $0F
    db   $03, $0F, $03, $3F, $03, $3F, $03, $3F
    db   $C0, $BF, $C0, $BF, $C0, $BF, $C0, $BF
    db   $C0, $BF, $C0, $BF, $BF, $FF, $7F, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $03, $FF, $03, $FF, $03, $FF, $03, $FF
    db   $03, $FF, $07, $FF, $FF, $FF, $FE, $FF
    db   $7F, $FF, $FF, $80, $E0, $9F, $C0, $BF
    db   $C0, $BF, $C0, $BF, $C0, $BF, $C0, $BF
    db   $FF, $FF, $FF, $00, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $FF, $FF, $FF, $00, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $FE, $FF, $FD, $03, $03, $FF, $03, $FF
    db   $03, $FF, $03, $FF, $03, $FF, $03, $FF
    db   $C0, $BF, $C0, $BF, $C0, $BF, $C2, $BC
    db   $C4, $B8, $C0, $B8, $C0, $BE, $C0, $BE
    db   $00, $FF, $00, $FF, $00, $FF, $08, $70
    db   $10, $60, $05, $62, $00, $7F, $01, $7E
    db   $00, $FF, $00, $FF, $00, $FF, $88, $70
    db   $50, $20, $04, $23, $04, $23, $13, $20
    db   $03, $FF, $03, $FF, $03, $FF, $43, $3F
    db   $23, $1F, $83, $1F, $83, $1F, $23, $1F
    db   $C0, $BE, $C0, $BE, $C0, $BE, $C0, $BE
    db   $C0, $BE, $C0, $BE, $C0, $BF, $C0, $BF
    db   $02, $7C, $04, $78, $09, $70, $12, $61
    db   $00, $60, $00, $60, $00, $FF, $00, $FF
    db   $48, $30, $93, $60, $04, $E3, $04, $E3
    db   $10, $20, $08, $30, $00, $FF, $00, $FF
    db   $43, $3F, $23, $1F, $83, $1F, $83, $1F
    db   $23, $1F, $43, $3F, $03, $FF, $03, $FF
    db   $C0, $BF, $C0, $BF, $C0, $BF, $C0, $BF
    db   $C0, $BF, $C0, $BF, $BF, $FF, $7F, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $03, $FF, $03, $FF, $03, $FF, $03, $FF
    db   $03, $FF, $07, $FF, $FF, $FF, $FE, $FF
    db   $7F, $FF, $FF, $80, $E0, $9F, $C0, $BF
    db   $C0, $BF, $C0, $BF, $C0, $BF, $C0, $BF
    db   $FF, $FF, $FF, $00, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $FF, $FF, $FF, $00, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $FE, $FF, $FD, $03, $03, $FF, $03, $FF
    db   $03, $FF, $03, $FF, $03, $FF, $03, $FF
    db   $C0, $BF, $C0, $BF, $C0, $BF, $C4, $B8
    db   $C8, $B0, $C2, $B1, $C0, $BF, $C0, $BF
    db   $00, $FF, $00, $FF, $00, $FF, $40, $30
    db   $20, $10, $80, $13, $00, $93, $80, $10
    db   $00, $FF, $00, $FF, $00, $FF, $02, $1C
    db   $00, $18, $0A, $F1, $00, $F3, $42, $30
    db   $03, $FF, $03, $FF, $03, $FF, $43, $3F
    db   $03, $1F, $43, $9F, $03, $FF, $43, $3F
    db   $C1, $BE, $C2, $BC, $C4, $B8, $C9, $B0
    db   $C0, $B0, $C0, $B0, $C0, $BF, $C0, $BF
    db   $20, $10, $40, $3F, $80, $7F, $00, $FF
    db   $00, $10, $00, $10, $00, $FF, $00, $FF
    db   $20, $10, $02, $91, $00, $93, $8A, $11
    db   $20, $18, $42, $3C, $00, $FF, $00, $FF
    db   $13, $0F, $43, $8F, $03, $CF, $43, $8F
    db   $13, $0F, $43, $3F, $03, $FF, $03, $FF
    db   $C0, $BF, $C0, $BF, $C0, $BF, $C0, $BF
    db   $C0, $BF, $C0, $BF, $BF, $FF, $7F, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $00, $FF, $00, $FF, $00, $FF, $00, $FF
    db   $00, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $03, $FF, $03, $FF, $03, $FF, $03, $FF
    db   $03, $FF, $07, $FF, $FF, $FF, $FE, $FF
    db   $7F, $FF, $80, $FF, $9F, $FF, $BF, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FE, $FF, $03, $FF, $F9, $FF, $FD, $FF
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $B8, $F8
    db   $B8, $F8, $B9, $F9, $B9, $F9, $B8, $F8
    db   $FF, $FF, $FF, $FF, $FF, $FF, $0E, $0F
    db   $0C, $0E, $FC, $FC, $FF, $FF, $1F, $3F
    db   $FF, $FF, $FF, $FF, $FF, $FF, $38, $3C
    db   $30, $38, $31, $33, $3F, $3F, $3F, $3F
    db   $FD, $FF, $FD, $FF, $FD, $FF, $3D, $7F
    db   $1D, $3F, $1D, $9F, $9D, $9F, $1D, $9F
    db   $B8, $F8, $BF, $FF, $BF, $FF, $BF, $FF
    db   $B8, $F8, $B8, $F8, $BF, $FF, $BF, $FF
    db   $0F, $1F, $CF, $CF, $CF, $CF, $8F, $CF
    db   $0F, $1F, $1F, $3F, $FF, $FF, $FF, $FF
    db   $3E, $3F, $3C, $3E, $38, $3C, $30, $39
    db   $30, $30, $30, $30, $FF, $FF, $FF, $FF
    db   $1D, $3F, $3D, $7F, $7D, $FF, $FD, $FF
    db   $1D, $1F, $1D, $1F, $FD, $FF, $FD, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $BF, $FF, $9F, $FF, $C0, $FF, $7F, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $FD, $FF, $F9, $FF, $03, $FF, $FE, $FF
    db   $7F, $FF, $80, $FF, $9F, $FF, $BF, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FE, $FF, $03, $FF, $F9, $FF, $FD, $FF
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $B1, $F9
    db   $A1, $F1, $A1, $E1, $B9, $F9, $B9, $F9
    db   $FF, $FF, $FF, $FF, $FF, $FF, $83, $C7
    db   $11, $BB, $39, $39, $39, $39, $39, $39
    db   $FF, $FF, $FF, $FF, $FF, $FF, $87, $8F
    db   $23, $77, $F3, $F3, $F2, $F3, $E2, $F6
    db   $FD, $FF, $FD, $FF, $FD, $FF, $9D, $9F
    db   $1D, $BF, $3D, $3F, $0D, $4F, $4D, $4F
    db   $B9, $F9, $B9, $F9, $B9, $F9, $B9, $F9
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $39, $39, $39, $39, $11, $BB, $83, $C7
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $C4, $EE, $8C, $DC, $1F, $BF, $03, $03
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $4D, $CF, $05, $07, $CD, $CF, $CD, $CF
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $BF, $FF, $9F, $FF, $C0, $FF, $7F, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $FD, $FF, $F9, $FF, $03, $FF, $FE, $FF
    db   $7F, $FF, $80, $FF, $9F, $FF, $BF, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FE, $FF, $03, $FF, $F9, $FF, $FD, $FF
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $B0, $F1
    db   $A4, $EE, $BE, $FE, $BE, $FE, $BC, $FE
    db   $FF, $FF, $FF, $FF, $FF, $FF, $C1, $E3
    db   $08, $DD, $1C, $1C, $1C, $1C, $1C, $9C
    db   $FF, $FF, $FF, $FF, $FF, $FF, $E6, $E7
    db   $C6, $EE, $CE, $CE, $82, $D2, $92, $93
    db   $FD, $FF, $FD, $FF, $FD, $FF, $05, $0F
    db   $05, $67, $65, $67, $65, $67, $05, $0F
    db   $B8, $FD, $B1, $FB, $A3, $F7, $A0, $E0
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $9C, $9C, $9C, $9C, $88, $DD, $41, $63
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $12, $B2, $00, $00, $F2, $F2, $F2, $F3
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $65, $67, $65, $67, $05, $67, $05, $0F
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $BF, $FF, $9F, $FF, $C0, $FF, $7F, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $FD, $FF, $F9, $FF, $03, $FF, $FE, $FF
    db   $7F, $FF, $80, $FF, $9F, $FF, $BF, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FE, $FF, $03, $FF, $F9, $FF, $FD, $FF
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $B9, $F9
    db   $B1, $FB, $B3, $F3, $A0, $F4, $A4, $E4
    db   $FF, $FF, $FF, $FF, $FF, $FF, $C1, $E3
    db   $88, $DD, $9C, $9C, $9C, $9C, $9C, $9C
    db   $FF, $FF, $FF, $FF, $FF, $FF, $07, $87
    db   $02, $33, $32, $32, $32, $32, $02, $82
    db   $FD, $FF, $FD, $FF, $FD, $FF, $0D, $8F
    db   $3D, $3F, $7D, $7F, $7D, $7F, $05, $0F
    db   $A4, $EC, $A0, $E0, $BC, $FC, $BC, $FC
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $9C, $9C, $1C, $1C, $88, $DD, $C1, $E3
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $F2, $F2, $F2, $F2, $E2, $E6, $87, $8F
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $65, $67, $65, $67, $05, $67, $05, $0F
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $BF, $FF, $BF, $FF, $BF, $FF, $BF, $FF
    db   $BF, $FF, $9F, $FF, $C0, $FF, $7F, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $FF, $FF, $FF
    db   $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
    db   $FD, $FF, $F9, $FF, $03, $FF, $FE, $FF
    db   $FF, $38, $C7, $41, $BE, $22, $DF, $12
    db   $EF, $0A, $F5, $71, $8E, $00, $FF, $00
    db   $FF, $00, $FF, $99, $67, $25, $FF, $25
    db   $FF, $25, $DB, $99, $66, $00, $FF, $00
    db   $FF, $00, $FF, $98, $67, $24, $FF, $3C
    db   $E3, $20, $DF, $1C, $E3, $00, $FF, $00
    db   $FF, $8A, $FD, $88, $FF, $FA, $8F, $8A
    db   $FF, $8A, $FF, $8A, $75, $00, $FF, $00
    db   $FF, $04, $FF, $74, $9F, $97, $FC, $94
    db   $FF, $F4, $1F, $14, $EB, $E0, $1F, $00
    db   $FF, $00, $FF, $06, $F9, $08, $FF, $8C
    db   $F3, $82, $FF, $8E, $71, $00, $FF, $00
    db   $FF, $00, $FF, $66, $99, $89, $FF, $89
    db   $FF, $89, $76, $66, $99, $00, $FF, $00
    db   $FF, $00, $FF, $66, $D9, $49, $FF, $4F
    db   $F8, $48, $F7, $47, $B8, $00, $FF, $00
    db   $FF, $1C, $F7, $36, $FF, $36, $FF, $36
    db   $FF, $36, $FF, $36, $DD, $1C, $E3, $00
    db   $FF, $0C, $FF, $1C, $EF, $0C, $FF, $0C
    db   $FF, $0C, $FF, $0C, $FF, $1E, $E1, $00
    db   $FF, $1C, $F7, $36, $CF, $06, $FD, $0C
    db   $FB, $18, $F7, $30, $FF, $3E, $C1, $00
    db   $FF, $3C, $C7, $06, $FF, $06, $FD, $1C
    db   $E7, $06, $FF, $06, $FD, $3C, $C3, $00
    db   $FF, $0C, $FF, $1C, $FF, $3C, $EF, $6C
    db   $FF, $7E, $8D, $0C, $FF, $0C, $F3, $00
    db   $FF, $3E, $F1, $30, $FF, $30, $FF, $3C
    db   $C7, $06, $FF, $06, $FD, $3C, $C3, $00
    db   $FF, $0E, $F9, $18, $F7, $30, $FF, $3C
    db   $F7, $36, $FF, $36, $DD, $1C, $E3, $00
    db   $FF, $3E, $C7, $06, $FD, $0C, $FF, $0C
    db   $FB, $18, $FF, $18, $FF, $18, $E7, $00
    db   $FF, $1C, $F7, $36, $FF, $36, $DD, $1C
    db   $F7, $36, $FF, $36, $DD, $1C, $E3, $00
    db   $FF, $1C, $F7, $36, $FF, $36, $DF, $1E
    db   $E7, $06, $FD, $0C, $FB, $38, $C7, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $00, $00, $00, $00, $00, $00, $0F, $00
    db   $3F, $07, $3F, $1F, $7F, $18, $7C, $30
    db   $79, $30, $79, $30, $7D, $30, $7F, $38
    db   $7F, $1F, $3F, $0F, $1F, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $E0, $00
    db   $E0, $C0, $E0, $C0, $EF, $00, $0F, $07
    db   $EF, $07, $EF, $C0, $FF, $C7, $FF, $CC
    db   $FF, $CF, $FF, $C7, $EF, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $DF, $00, $FF, $8F
    db   $FF, $CF, $FF, $CC, $FF, $CC, $FF, $CC
    db   $FF, $CC, $FF, $CC, $FF, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $FC, $00, $FF, $F8
    db   $FF, $FC, $FF, $CC, $FF, $CC, $FF, $CC
    db   $FF, $CC, $FF, $CC, $FE, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $FC, $00, $FE, $78
    db   $FE, $FC, $FE, $CC, $FE, $FC, $FE, $C0
    db   $FE, $FC, $FE, $7C, $FE, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $0F, $00, $1F, $07
    db   $3F, $0F, $3F, $18, $3D, $18, $3F, $18
    db   $3F, $0F, $1F, $07, $0F, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $BD, $00, $FD, $18
    db   $FF, $98, $FF, $CD, $FF, $CD, $FF, $CD
    db   $FF, $87, $CF, $07, $8F, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $EF, $00, $FF, $C7
    db   $FF, $CF, $FF, $8C, $DF, $8F, $DF, $8C
    db   $DF, $0F, $9F, $07, $8F, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $DF, $00, $FF, $8F
    db   $FF, $CF, $FF, $CC, $FE, $CC, $FE, $0C
    db   $FE, $CC, $FE, $CC, $FE, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $78, $00
    db   $78, $30, $78, $30, $F8, $30, $F8, $B0
    db   $F8, $B0, $F8, $30, $78, $00, $78, $30
    db   $78, $30, $78, $30, $78, $00, $00, $00
    db   $00, $00, $3C, $00, $3E, $18, $3F, $0C
    db   $1F, $0E, $1F, $06, $0F, $03, $07, $03
    db   $07, $01, $03, $01, $03, $01, $03, $01
    db   $03, $01, $03, $00, $00, $00, $00, $00
    db   $00, $00, $3C, $00, $7C, $18, $FC, $30
    db   $F9, $70, $FB, $60, $F7, $C1, $E7, $C3
    db   $E7, $83, $C7, $83, $C7, $83, $C7, $81
    db   $C3, $80, $C1, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $F9, $00, $FD, $F0, $FF, $F8, $FF, $9C
    db   $FF, $0C, $FF, $0C, $FF, $9C, $FF, $F8
    db   $FD, $F0, $F8, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $EF, $00, $EF, $C6, $EF, $C6, $EF, $C6
    db   $EF, $C6, $EF, $C6, $FF, $C6, $FF, $FE
    db   $FF, $7E, $FF, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $1E, $00, $1F, $0C, $1F, $0C, $1F, $06
    db   $0F, $06, $0F, $07, $0F, $03, $07, $03
    db   $07, $03, $07, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $FF, $00, $FF, $66, $FF, $E6, $FF, $EC
    db   $FE, $EC, $FE, $BC, $FE, $B8, $FC, $B8
    db   $FC, $18, $BC, $00, $00, $00, $00, $00
    db   $78, $00, $78, $30, $78, $30, $78, $30
    db   $7B, $00, $7B, $31, $7B, $31, $7B, $31
    db   $7B, $31, $7B, $31, $7B, $31, $7B, $31
    db   $7B, $31, $7B, $00, $00, $00, $00, $00
    db   $00, $00, $01, $00, $01, $00, $01, $00
    db   $FD, $00, $FF, $F8, $FF, $FC, $FF, $8C
    db   $DF, $8C, $DF, $8C, $DF, $8C, $DF, $8C
    db   $DF, $8C, $DF, $00, $00, $00, $00, $00
    db   $00, $00, $E0, $00, $E0, $C0, $E0, $C0
    db   $E0, $C0, $E0, $C0, $E0, $C0, $E0, $C0
    db   $E0, $C0, $E0, $00, $E0, $C0, $E0, $C0
    db   $E0, $C0, $E0, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $3F, $3F, $7F, $7F, $FF, $FF
    db   $FF, $FF, $FF, $F8, $FF, $FE, $FF, $FE
    db   $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF
    db   $FF, $FF, $FF, $FF, $7F, $7F, $3F, $3F
    db   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $3F, $FF, $CB, $FF, $DD
    db   $FF, $DD, $FF, $DD, $FF, $DE, $FF, $FE
    db   $FF, $F9, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $B8, $FF, $7F
    db   $FF, $7C, $FF, $7B, $FF, $FC, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $E2, $FF, $5B
    db   $FF, $5B, $FF, $5A, $FF, $63, $FF, $FB
    db   $FF, $C7, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $F7, $FF, $FF, $FF, $34, $FF, $D5
    db   $FF, $15, $FF, $D5, $FF, $15, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $FC, $FC, $FE, $FE, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $7F, $FF, $BF
    db   $FF, $BF, $FF, $BF, $FF, $BF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FE, $FE, $FC, $FC
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $3F, $3F, $7F, $7F, $FF, $FF
    db   $FF, $FF, $FF, $F1, $FF, $F6, $FF, $EF
    db   $FF, $EF, $FF, $EF, $FF, $F6, $FF, $F1
    db   $FF, $FF, $FF, $FF, $7F, $7F, $3F, $3F
    db   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $CE
    db   $FF, $B6, $FF, $B6, $FF, $B6, $FF, $CE
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FB, $FF, $30
    db   $FF, $DB, $FF, $DB, $FF, $DB, $FF, $D8
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $BF, $FF, $FF, $FF, $B1
    db   $FF, $B6, $FF, $B6, $FF, $B6, $FF, $B6
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $DB
    db   $FF, $DB, $FF, $DB, $FF, $DB, $FF, $E3
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $FC, $FC, $FE, $FE, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $9F
    db   $FF, $6F, $FF, $0F, $FF, $7F, $FF, $8F
    db   $FF, $FF, $FF, $FF, $FE, $FE, $FC, $FC
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $1C, $1C, $36, $36, $36, $36, $36, $36
    db   $36, $36, $36, $36, $1C, $1C, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $0C, $0C, $1C, $1C, $0C, $0C, $0C, $0C
    db   $0C, $0C, $0C, $0C, $1E, $1E, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $1C, $1C, $36, $36, $06, $06, $0C, $0C
    db   $18, $18, $30, $30, $3E, $3E, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $3C, $3C, $06, $06, $06, $06, $1C, $1C
    db   $06, $06, $06, $06, $3C, $3C, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $0C, $0C, $1C, $1C, $3C, $3C, $6C, $6C
    db   $7E, $7E, $0C, $0C, $0C, $0C, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $3E, $3E, $30, $30, $30, $30, $3C, $3C
    db   $06, $06, $06, $06, $3C, $3C, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $0E, $0E, $18, $18, $30, $30, $3C, $3C
    db   $36, $36, $36, $36, $1C, $1C, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $3E, $3E, $06, $06, $0C, $0C, $0C, $0C
    db   $18, $18, $18, $18, $18, $18, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $1C, $1C, $36, $36, $36, $36, $1C, $1C
    db   $36, $36, $36, $36, $1C, $1C, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $1C, $1C, $36, $36, $36, $36, $1E, $1E
    db   $06, $06, $0C, $0C, $38, $38, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $04, $04, $04, $04, $1F, $1F
    db   $04, $04, $04, $04, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $01, $00
    db   $FC, $FC, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $7F, $00, $3E, $00, $9E, $80, $DC, $C0
    db   $FF, $00, $FF, $00, $FF, $00, $C0, $00
    db   $1F, $1F, $7F, $7F, $FF, $FF, $FF, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $3F, $00
    db   $8F, $80, $E7, $E0, $F7, $F0, $F3, $F0
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FE, $00, $FC, $00, $F9, $01
    db   $FF, $00, $FF, $00, $FF, $00, $81, $00
    db   $3D, $3C, $7D, $7C, $FD, $FC, $FD, $FC
    db   $FF, $00, $FF, $00, $FF, $00, $F8, $00
    db   $F3, $03, $C7, $07, $DF, $1F, $9F, $1F
    db   $FF, $00, $FF, $00, $FF, $00, $03, $00
    db   $F8, $F8, $FE, $FE, $FF, $FF, $FF, $FF
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $7F, $00, $7F, $00, $3F, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $F0, $00, $C7, $07, $DF, $1F, $DF, $1F
    db   $DF, $1F, $DF, $1F, $DF, $1F, $DF, $1F
    db   $7F, $00, $7F, $00, $7F, $00, $7F, $00
    db   $7F, $00, $7F, $00, $7F, $00, $7F, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FE, $00
    db   $F8, $00, $F3, $03, $E7, $07, $EF, $0F
    db   $E7, $07, $F2, $02, $F8, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $8F, $8F, $27, $07, $F7, $07, $E7, $07
    db   $EF, $0F, $CF, $0F, $9F, $1F, $3F, $3F
    db   $DD, $C1, $DD, $C1, $D9, $C1, $DB, $C3
    db   $DB, $C3, $9B, $83, $BB, $83, $3B, $03
    db   $F9, $F9, $F0, $F0, $E6, $E0, $EF, $E0
    db   $EF, $E0, $EF, $E0, $EF, $E0, $EF, $E0
    db   $FB, $F8, $F9, $F8, $7D, $7C, $7D, $7C
    db   $7D, $7C, $7D, $7C, $7D, $7C, $7C, $7C
    db   $F3, $03, $E7, $07, $CF, $0F, $DF, $1F
    db   $9E, $1E, $BC, $3C, $3D, $3C, $79, $78
    db   $FD, $FC, $FD, $FC, $FD, $FC, $7D, $7C
    db   $7D, $7C, $7D, $7C, $7D, $7C, $7D, $7C
    db   $BF, $3F, $BE, $3E, $BE, $3E, $BE, $3E
    db   $BF, $3F, $9F, $1F, $CF, $0F, $CF, $0F
    db   $1F, $1F, $4F, $0F, $EF, $0F, $4F, $0F
    db   $1F, $1F, $FE, $FE, $FC, $FC, $FF, $FF
    db   $BF, $80, $BF, $80, $BF, $80, $BF, $80
    db   $3F, $00, $7F, $00, $60, $00, $2F, $0F
    db   $FF, $00, $FF, $00, $FF, $00, $FE, $00
    db   $FE, $00, $FC, $00, $01, $01, $F9, $F9
    db   $F0, $00, $87, $07, $3F, $3F, $7F, $7F
    db   $FF, $FF, $FC, $FC, $F9, $F8, $F3, $F0
    db   $03, $00, $F8, $F8, $FE, $FE, $FE, $FE
    db   $FE, $FE, $3E, $3E, $BE, $3E, $BE, $3E
    db   $DF, $1F, $DF, $1F, $DF, $1F, $DF, $1F
    db   $DF, $1F, $DF, $1F, $DF, $1F, $DF, $1F
    db   $01, $00, $7C, $7C, $FF, $FF, $FF, $FF
    db   $FF, $FF, $0F, $0F, $67, $07, $73, $03
    db   $FF, $00, $7F, $00, $3F, $00, $9F, $80
    db   $DF, $C0, $CF, $C0, $EF, $E0, $EF, $E0
    db   $FE, $00, $FC, $00, $FD, $01, $F9, $01
    db   $FB, $03, $F3, $03, $F7, $07, $F7, $07
    db   $7E, $7E, $FC, $FC, $F9, $F8, $FB, $F8
    db   $F3, $F0, $E0, $E0, $FF, $FF, $FF, $FF
    db   $7B, $03, $FB, $03, $FB, $03, $FB, $03
    db   $F9, $01, $0D, $01, $EC, $E0, $EE, $E0
    db   $EF, $E0, $EF, $E0, $EF, $E0, $E6, $E0
    db   $F0, $F0, $F9, $F9, $FF, $FF, $FF, $FF
    db   $7C, $7C, $7C, $7C, $7C, $7C, $7C, $7C
    db   $F8, $F8, $FA, $F8, $F3, $F0, $F7, $F0
    db   $F8, $F8, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $00, $00, $FF, $00, $FF, $00
    db   $7C, $7C, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $7C, $7C, $7D, $7C, $7D, $7C
    db   $1F, $1F, $3F, $3F, $3E, $3E, $3E, $3E
    db   $3E, $3E, $3F, $3F, $9F, $1F, $DF, $1F
    db   $FF, $FF, $1F, $1F, $47, $07, $F7, $07
    db   $67, $07, $0F, $0F, $FF, $FF, $FF, $FF
    db   $AF, $8F, $8F, $8F, $CF, $CF, $C0, $C0
    db   $DF, $C0, $DF, $C0, $9F, $80, $BF, $80
    db   $F9, $F9, $F9, $F9, $F9, $F9, $01, $01
    db   $FD, $01, $FC, $00, $FE, $00, $FF, $00
    db   $F7, $F0, $F7, $F0, $F7, $F0, $F3, $F0
    db   $F8, $F8, $FF, $FF, $7F, $7F, $7F, $7F
    db   $BE, $3E, $BE, $3E, $BE, $3E, $BE, $3E
    db   $3E, $3E, $FE, $FE, $FE, $FE, $FE, $FE
    db   $DF, $1F, $DF, $1F, $DF, $1F, $DF, $1F
    db   $DF, $1F, $DF, $1F, $DF, $1F, $DF, $1F
    db   $7B, $03, $7B, $03, $7B, $03, $73, $03
    db   $67, $07, $0F, $0F, $FF, $FF, $FF, $FF
    db   $EF, $E0, $EF, $E0, $EF, $E0, $EF, $E0
    db   $EF, $E0, $CF, $C0, $DF, $C0, $9F, $80
    db   $F7, $07, $F7, $07, $F0, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $FF, $FF, $FF, $00, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $EE, $E0, $EF, $E0, $0F, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $7F, $7F, $1F, $1F, $C0, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $E7, $E0, $8F, $80, $3F, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $7D, $7C, $7D, $7C, $01, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $CF, $0F, $E1, $01, $FC, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $FF, $FC, $FC, $01, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $3F, $00, $7F, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FE, $00
    db   $FE, $00, $FE, $00, $FE, $00, $FE, $00
    db   $1F, $1F, $C0, $00, $1F, $00, $40, $40
    db   $FF, $FF, $FF, $FF, $FF, $FF, $3F, $3F
    db   $BE, $BE, $3E, $3E, $3E, $3E, $7C, $7C
    db   $FD, $FC, $F9, $F8, $F3, $F0, $C7, $C0
    db   $DF, $1F, $C7, $07, $F0, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $FF, $F8, $F8, $03, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $3F, $00, $7F, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $70, $FF, $48, $FF, $49
    db   $FF, $72, $FF, $42, $FF, $41, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $02, $FF, $9B
    db   $FF, $52, $FF, $52, $FF, $91, $FF, $00
    db   $FF, $00, $FF, $10, $FF, $10, $FF, $1C
    db   $FF, $12, $FF, $12, $FF, $1C, $FF, $00
    db   $FF, $00, $FF, $01, $FF, $02, $FF, $A2
    db   $FF, $A1, $FF, $40, $FF, $43, $FF, $80
    db   $FF, $00, $FF, $80, $FF, $00, $FF, $33
    db   $FF, $8A, $FF, $9A, $FF, $3A, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $8E
    db   $FF, $52, $FF, $52, $FF, $4E, $FF, $02
    db   $FF, $00, $FF, $04, $FF, $00, $FF, $94
    db   $FF, $94, $FF, $94, $FF, $74, $FF, $00
    db   $FF, $00, $FF, $68, $FF, $48, $FF, $4E
    db   $FF, $49, $FF, $49, $FF, $49, $FF, $60
    db   $FF, $00, $FF, $00, $FF, $48, $FF, $6D
    db   $FF, $49, $FF, $49, $FF, $25, $FF, $01
    db   $FF, $00, $FF, $01, $FF, $01, $FF, $CA
    db   $FF, $22, $FF, $22, $FF, $CC, $FF, $04
    db   $FF, $00, $FF, $20, $FF, $20, $FF, $4D
    db   $FF, $50, $FF, $4C, $FF, $99, $FF, $80
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $9C
    db   $FF, $52, $FF, $D2, $FF, $D2, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $74
    db   $FF, $94, $FF, $94, $FF, $73, $FF, $10
    db   $FF, $00, $FF, $20, $FF, $00, $FF, $A3
    db   $FF, $A2, $FF, $A2, $FF, $AA, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $49
    db   $FF, $4A, $FF, $49, $FF, $3B, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $20, $FF, $B7
    db   $FF, $27, $FF, $A4, $FF, $13, $FF, $00
    db   $FF, $00, $FF, $0A, $FF, $0A, $FF, $3A
    db   $FF, $4A, $FF, $4A, $FF, $39, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $63
    db   $FF, $94, $FF, $93, $FF, $60, $FF, $07
    db   $FF, $00, $FF, $20, $FF, $00, $FF, $A6
    db   $FF, $A8, $FF, $A8, $FF, $A6, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $39
    db   $FF, $25, $FF, $25, $FF, $A4, $FF, $00
    db   $FF, $00, $FF, $06, $FF, $12, $FF, $DA
    db   $FF, $D2, $FF, $12, $FF, $CA, $FF, $06
    db   $FF, $00, $FF, $72, $FF, $20, $FF, $22
    db   $FF, $22, $FF, $22, $FF, $22, $FF, $00
    db   $FF, $00, $FF, $80, $FF, $80, $FF, $B8
    db   $FF, $B8, $FF, $A0, $FF, $58, $FF, $00
    db   $FF, $00, $FF, $02, $FF, $04, $FF, $76
    db   $FF, $94, $FF, $74, $FF, $14, $FF, $E0
    db   $FF, $00, $FF, $02, $FF, $02, $FF, $A3
    db   $FF, $42, $FF, $42, $FF, $A3, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $94
    db   $FF, $54, $FF, $48, $FF, $88, $FF, $10
    db   $FF, $00, $FF, $40, $FF, $40, $FF, $73
    db   $FF, $4B, $FF, $4A, $FF, $71, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $AA
    db   $FF, $AA, $FF, $2A, $FF, $94, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $CD
    db   $FF, $29, $FF, $69, $FF, $E8, $FF, $00
    db   $FF, $00, $FF, $04, $FF, $0A, $FF, $CC
    db   $FF, $CD, $FF, $0B, $FF, $C7, $FF, $00
    db   $FF, $00, $FF, $68, $FF, $48, $FF, $4E
    db   $FF, $49, $FF, $49, $FF, $49, $FF, $60
    db   $FF, $00, $FF, $00, $FF, $48, $FF, $6D
    db   $FF, $49, $FF, $49, $FF, $25, $FF, $01
    db   $FF, $00, $FF, $01, $FF, $01, $FF, $CA
    db   $FF, $22, $FF, $22, $FF, $CC, $FF, $04
    db   $FF, $00, $FF, $28, $FF, $28, $FF, $4E
    db   $FF, $49, $FF, $49, $FF, $8E, $FF, $80
    db   $FF, $00, $FF, $02, $FF, $02, $FF, $3B
    db   $FF, $4A, $FF, $3A, $FF, $0B, $FF, $70
    db   $FF, $00, $FF, $04, $FF, $04, $FF, $87
    db   $FF, $44, $FF, $44, $FF, $97, $FF, $00
    db   $FF, $00, $FF, $20, $FF, $00, $FF, $2C
    db   $FF, $A9, $FF, $A9, $FF, $28, $FF, $00
    db   $FF, $00, $FF, $02, $FF, $02, $FF, $CE
    db   $FF, $12, $FF, $12, $FF, $CE, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $19
    db   $FF, $25, $FF, $25, $FF, $99, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $9D
    db   $FF, $25, $FF, $1D, $FF, $06, $FF, $3A
    db   $FF, $00, $FF, $E0, $FF, $A0, $FF, $20
    db   $FF, $20, $FF, $20, $FF, $20, $FF, $60
    db   $FF, $00, $FF, $38, $FF, $44, $FF, $45
    db   $FF, $45, $FF, $45, $FF, $39, $FF, $00
    db   $FF, $00, $FF, $20, $FF, $00, $FF, $A7
    db   $FF, $29, $FF, $27, $FF, $21, $FF, $0E
    db   $FF, $00, $FF, $40, $FF, $00, $FF, $5C
    db   $FF, $52, $FF, $52, $FF, $52, $FF, $00
    db   $FF, $00, $FF, $08, $FF, $08, $FF, $C8
    db   $FF, $28, $FF, $68, $FF, $E4, $FF, $00
    db   $FF, $00, $FF, $80, $FF, $80, $FF, $E5
    db   $FF, $95, $FF, $92, $FF, $E2, $FF, $04
    db   $FF, $00, $FF, $0E, $FF, $10, $FF, $10
    db   $FF, $12, $FF, $12, $FF, $0E, $FF, $00
    db   $FF, $00, $FF, $08, $FF, $08, $FF, $CE
    db   $FF, $29, $FF, $69, $FF, $EE, $FF, $00
    db   $FF, $00, $FF, $08, $FF, $00, $FF, $6B
    db   $FF, $4B, $FF, $4A, $FF, $49, $FF, $00
    db   $FF, $00, $FF, $20, $FF, $20, $FF, $AE
    db   $FF, $AE, $FF, $28, $FF, $96, $FF, $00
    db   $FF, $00, $FF, $1D, $FF, $20, $FF, $21
    db   $FF, $21, $FF, $21, $FF, $1D, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $69
    db   $FF, $49, $FF, $49, $FF, $47, $FF, $00
    db   $FF, $00, $FF, $54, $FF, $50, $FF, $54
    db   $FF, $54, $FF, $54, $FF, $2C, $FF, $00
    db   $FF, $00, $FF, $68, $FF, $48, $FF, $4E
    db   $FF, $49, $FF, $49, $FF, $49, $FF, $60
    db   $FF, $00, $FF, $00, $FF, $48, $FF, $6D
    db   $FF, $49, $FF, $49, $FF, $25, $FF, $01
    db   $FF, $00, $FF, $01, $FF, $01, $FF, $CA
    db   $FF, $22, $FF, $22, $FF, $CC, $FF, $04
    db   $FF, $00, $FF, $20, $FF, $20, $FF, $47
    db   $FF, $49, $FF, $47, $FF, $81, $FF, $8E
    db   $FF, $00, $FF, $40, $FF, $10, $FF, $58
    db   $FF, $50, $FF, $50, $FF, $4A, $FF, $00
    db   $FF, $00, $FF, $80, $FF, $00, $FF, $99
    db   $FF, $A5, $FF, $A5, $FF, $9A, $FF, $02
    db   $FF, $00, $FF, $98, $FF, $A5, $FF, $05
    db   $FF, $09, $FF, $11, $FF, $3C, $FF, $00
    db   $FF, $00, $FF, $C2, $FF, $26, $FF, $2A
    db   $FF, $2F, $FF, $22, $FF, $C2, $FF, $00
    db   $FF, $00, $FF, $36, $FF, $4A, $FF, $32
    db   $FF, $4A, $FF, $4A, $FF, $32, $FF, $06
    db   $C0, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $3F, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $70, $FF, $4B, $FF, $4A
    db   $FF, $72, $FF, $42, $FF, $42, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $31, $FF, $4A
    db   $FF, $7B, $FF, $40, $FF, $3B, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $98, $FF, $20
    db   $FF, $B8, $FF, $88, $FF, $30, $FF, $00
    db   $FF, $00, $FF, $74, $FF, $87, $FF, $44
    db   $FF, $24, $FF, $14, $FF, $E3, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $73, $FF, $0A
    db   $FF, $3A, $FF, $4A, $FF, $3A, $FF, $00
    db   $FF, $00, $FF, $44, $FF, $74, $FF, $44
    db   $FF, $44, $FF, $40, $FF, $34, $FF, $00
    db   $FF, $00, $FF, $1C, $FF, $21, $FF, $21
    db   $FF, $25, $FF, $25, $FF, $1C, $FF, $00
    db   $FF, $00, $FF, $E4, $FF, $16, $FF, $16
    db   $FF, $15, $FF, $15, $FF, $E4, $FF, $00
    db   $FF, $00, $FF, $4E, $FF, $C8, $FF, $CC
    db   $FF, $48, $FF, $48, $FF, $48, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db   $FF, $00, $FF, $00, $FF, $00, $FF, $00
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
    db   $FF
