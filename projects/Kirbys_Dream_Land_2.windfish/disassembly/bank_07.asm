SECTION "ROM Bank 07", ROMX[$4000], BANK[$07]

toc_07_4000:
    assign [$DA3B], $01
    assign [$DA3A], $02
    ld   hl, $DA3C
    ld   bc, $BC00
    ld   [hl], c
    inc  hl
    ld   [hl], b
    xor  a
    ld   hl, $DA30
    ldi  [hl], a
    ld   [hl], a
    ld   [$DA0E], a
    ret


toc_07_401D:
    ld   hl, $D900
.loop_07_4020:
    ld   b, $08
.loop_07_4022:
    rrc  l
    rla
    dec  b
    jr   nz, .loop_07_4022

    ldi  [hl], a
    inc  a
    jr   nz, .loop_07_4020

    ret


    db   $3B, $3D, $FF, $02, $FF, $70, $98, $48
    db   $68, $B8, $BA, $3C, $3B, $FF, $02, $FF
    db   $18, $60, $18, $38, $B9, $B8, $3B, $0C
    db   $FF, $02, $07, $07, $07, $07, $05, $00
    db   $FF, $60, $F8, $68, $A0, $D0, $30, $30
    db   $B0, $F0, $00, $80, $D0, $A8, $F8, $30
    db   $60, $B8, $58, $B8, $E8, $28, $58, $88
    db   $18, $18, $B8, $B8, $80, $50, $50, $00
    db   $00, $44, $98, $44, $38, $50, $50, $60
    db   $50, $30, $70, $28, $70, $40, $60, $30
    db   $48, $60, $58, $30, $38, $30, $68, $50
    db   $50, $68, $50, $68, $38, $38, $68, $50
    db   $38, $68, $40, $60, $64, $68, $3C, $B8
    db   $BB, $BB, $BB, $BB, $BB, $BC, $BC, $BC
    db   $BB, $BC, $BC, $BB, $BB, $BB, $BB, $BB
    db   $BC, $BC, $BB, $BB, $BB, $BB, $BB, $BC
    db   $BC, $BB, $BB, $BB, $BC, $BB, $BC, $BB
    db   $BC, $BC, $3F, $3B, $FF, $02, $FF, $60
    db   $60, $28, $38, $CE, $B8, $40, $3B, $FF
    db   $03, $00, $00, $00, $00, $00, $00, $00
    db   $FF, $98, $98, $60, $48, $58, $38, $CF
    db   $D3, $B8, $41, $3B, $FF, $02, $FF, $88
    db   $60, $68, $38, $D0, $B8

toc_07_40E2:
    ld   hl, $CC00
    ld   a, [$DB5F]
    inc  a
    ld   b, a
    jr   .toc_07_40F3

.loop_07_40EC:
    ldi  a, [hl]
    sub  a, $BD
    cp   $10
    jr   c, .else_07_40F9

.toc_07_40F3:
    dec  b
    jr   nz, .loop_07_40EC

    ld   a, [$DB60]
.else_07_40F9:
    add  a, $24
    ld   e, a
    cbcallNoInterrupts $1E, $6002
    ret


toc_07_4105:
    ifEq [$DB61], $08, .return_07_4120

    ld   a, [$DB60]
    ld   hl, $4121
    add  a, l
    ld   l, a
    jr   nc, .else_07_4117

    inc  h
.else_07_4117:
    ld   e, [hl]
    cbcallNoInterrupts $1E, $606D
.return_07_4120:
    ret


    db   $04, $00, $05, $08, $00, $00, $09

toc_07_4128:
    ld   a, [$DEFF]
    or   a
    ret  nz

    ld   hl, $CC00
    ld   a, [$DB5F]
    inc  a
    ld   b, a
    jr   .toc_07_413C

.loop_07_4137:
    ldi  a, [hl]
    cp   $B2
    jr   z, .else_07_4141

.toc_07_413C:
    dec  b
    jr   nz, .loop_07_4137

    jr   .else_07_4155

.else_07_4141:
    ld   a, [$DB60]
    call toc_01_0663
    ld   hl, $DD63
    and  [hl]
    jr   nz, .else_07_4155

    assign [$DB6F], $12
    ld   e, a
    jr   .else_07_41AD

.else_07_4155:
    ld   a, [$DB73]
    or   a
    ld   a, $FF
    jr   nz, .else_07_417B

    ld   a, [$DB60]
    ld   hl, $41B6
    add  a, a
    add  a, l
    ld   l, a
    jr   nc, .else_07_4169

    inc  h
.else_07_4169:
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   a, [$DB61]
    sub  a, $08
    jr   nc, .else_07_4175

    ld   a, $02
.else_07_4175:
    add  a, l
    ld   l, a
    jr   nc, .else_07_417A

    inc  h
.else_07_417A:
    ld   a, [hl]
.else_07_417B:
    ld   [$DB6F], a
    __ifNotZero [$DB38], .else_07_418A

    clear [$DB38]
    jr   .return_07_41B5

.else_07_418A:
    ld   a, [$DB6F]
    ld   e, a
    ifLt [$DB61], $08, .else_07_41AD

    ld   a, [$A071]
    or   a
    jr   nz, .else_07_41A4

    ld   a, [$DDE4]
    inc  a
    cp   e
    jr   z, .return_07_41B5

    jr   .else_07_41AD

.else_07_41A4:
    ld   hl, $41D8
    add  a, l
    ld   l, a
    jr   nc, .else_07_41AC

    inc  h
.else_07_41AC:
    ld   e, [hl]
.else_07_41AD:
    cbcallNoInterrupts $1F, $4232
.return_07_41B5:
    ret


    db   $C4, $41, $C7, $41, $CA, $41, $CD, $41
    db   $D0, $41, $D3, $41, $D6, $41, $03, $13
    db   $05, $0A, $13, $08, $0C, $13, $1F, $22
    db   $13, $21, $23, $13, $01, $24, $13, $26
    db   $11, $FF, $10, $14, $09, $0B

toc_07_41DC:
    ld   hl, $DB51
    ldi  a, [hl]
    ld   [$DA01], a
    sub  a, $10
    ld   c, a
    ldi  a, [hl]
    ld   b, a
    jr   nc, .else_07_41EB

    dec  b
.else_07_41EB:
    ldi  a, [hl]
    ld   [$DA00], a
    sub  a, $10
    ld   e, a
    ld   d, [hl]
    jr   nc, .else_07_41F6

    dec  d
.else_07_41F6:
    call toc_01_15E3
    push hl
    call toc_01_15FC
    pop  bc
    ld   d, $0D
    ld   e, $0B
    jr   .else_07_421E

.loop_07_4204:
    ld   a, c
    add  a, $10
    ld   c, a
    jr   c, .else_07_4213

    ld   a, l
    add  a, $40
    ld   l, a
    jr   nc, .else_07_421E

    inc  h
    jr   .else_07_421E

.else_07_4213:
    ld   a, [$DB3D]
    add  a, b
    ld   b, a
    ld   h, $98
    ld   a, l
    and  %00011111
    ld   l, a
.else_07_421E:
    push bc
    push hl
    push de
    jr   .toc_07_4236

.loop_07_4223:
    inc  c
    ld   a, c
    and  %00001111
    jr   z, .else_07_422D

    inc  l
    inc  l
    jr   .toc_07_4236

.else_07_422D:
    ld   a, c
    sub  a, $10
    ld   c, a
    inc  b
    ld   a, l
    and  %11100000
    ld   l, a
.toc_07_4236:
    ld   a, [bc]
    push bc
    ld   c, a
    ld   b, $C5
    ld   a, [bc]
    ldi  [hl], a
    inc  b
    ld   a, [bc]
    ld   [hl], a
    inc  b
    ld   a, l
    add  a, $1F
    ld   l, a
    ld   a, [bc]
    ldi  [hl], a
    inc  b
    ld   a, [bc]
    ld   [hl], a
    ld   a, l
    sub  a, $21
    ld   l, a
    pop  bc
    dec  d
    jr   nz, .loop_07_4223

    pop  de
    pop  hl
    pop  bc
    dec  e
    jr   nz, .loop_07_4204

    ret


toc_07_4259:
    ld   hl, $DB51
    ldi  a, [hl]
    ld   [$DA01], a
    sub  a, $10
    ld   c, a
    ldi  a, [hl]
    ld   b, a
    jr   nc, .else_07_4268

    dec  b
.else_07_4268:
    ldi  a, [hl]
    ld   [$DA00], a
    sub  a, $10
    ld   e, a
    ld   d, [hl]
    jr   nc, .else_07_4273

    dec  d
.else_07_4273:
    ld   a, e
    and  %11110000
    ld   h, a
    ld   a, [$DB56]
    sub  a, h
    jr   z, .else_07_4294

    push bc
    push de
    rla
    jr   nc, .else_07_4289

    ld   a, e
    add  a, $A0
    ld   e, a
    jr   nc, .else_07_4289

    inc  d
.else_07_4289:
    ld   a, h
    ld   [$DB56], a
    ld   a, $0D
    call toc_07_42BC
    pop  de
    pop  bc
.else_07_4294:
    ld   a, c
    and  %11110000
    ld   h, a
    ld   a, [$DB55]
    sub  a, h
    jr   z, .return_07_42BB

    rla
    jr   nc, .else_07_42A8

    ld   a, c
    add  a, $B0
    ld   c, a
    jr   nc, .else_07_42A8

    inc  b
.else_07_42A8:
    ld   a, h
    ld   [$DB55], a
    push bc
    ld   bc, $0400
.loop_07_42B0:
    dec  bc
    ld   a, b
    or   c
    jr   nz, .loop_07_42B0

    pop  bc
    ld   a, $0B
    call toc_07_4318
.return_07_42BB:
    ret


toc_07_42BC:
    ld   [$FF84], a
    ld   [hDMARegion], a
    call toc_01_15FC
    push hl
    call toc_01_15E3
    ld   b, h
    ld   c, l
    pop  de
    ld   a, [$DA22]
    ld   l, a
    ld   a, [$DA28]
    ld   h, a
    jr   .toc_07_42E9

.loop_07_42D4:
    ld   [$FF84], a
    inc  c
    ld   a, c
    and  %00001111
    jr   z, .else_07_42E0

    inc  e
    inc  e
    jr   .toc_07_42E9

.else_07_42E0:
    ld   a, c
    sub  a, $10
    ld   c, a
    inc  b
    ld   a, e
    and  %11100000
    ld   e, a
.toc_07_42E9:
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   a, [bc]
    push bc
    ld   c, a
    ld   b, $C5
    ld   a, [bc]
    ldi  [hl], a
    inc  b
    ld   a, [bc]
    ldi  [hl], a
    inc  b
    ld   a, [bc]
    ldi  [hl], a
    inc  b
    ld   a, [bc]
    ldi  [hl], a
    pop  bc
    ld   a, [$FF84]
    dec  a
    jr   nz, .loop_07_42D4

    ld   a, l
    ld   [$DA22], a
    ld   a, [$DA28]
    ld   hl, $DA23
    rra
    jr   nc, .else_07_4313

    ld   hl, $DA24
.else_07_4313:
    ld   a, [hDMARegion]
    add  a, [hl]
    ld   [hl], a
    ret


toc_07_4318:
    ld   [$FF84], a
    ld   [hDMARegion], a
    call toc_01_15FC
    push hl
    call toc_01_15E3
    ld   b, h
    ld   c, l
    pop  de
    ld   a, [$DA22]
    ld   l, a
    ld   a, [$DA28]
    ld   h, a
    jr   .else_07_434C

.loop_07_4330:
    ld   [$FF84], a
    ld   a, c
    add  a, $10
    ld   c, a
    jr   c, .else_07_4341

    ld   a, e
    add  a, $40
    ld   e, a
    jr   nc, .else_07_434C

    inc  d
    jr   .else_07_434C

.else_07_4341:
    ld   a, [$DB3D]
    add  a, b
    ld   b, a
    ld   d, $98
    ld   a, e
    and  %00011111
    ld   e, a
.else_07_434C:
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   a, [bc]
    push bc
    ld   c, a
    ld   b, $C5
    ld   a, [bc]
    ldi  [hl], a
    inc  b
    ld   a, [bc]
    ldi  [hl], a
    inc  b
    ld   a, [bc]
    ldi  [hl], a
    inc  b
    ld   a, [bc]
    ldi  [hl], a
    pop  bc
    ld   a, [$FF84]
    dec  a
    jr   nz, .loop_07_4330

    ld   a, l
    ld   [$DA22], a
    ld   a, [$DA28]
    ld   hl, $DA23
    rra
    jr   nc, .else_07_4376

    ld   hl, $DA24
.else_07_4376:
    ld   a, [hDMARegion]
    add  a, [hl]
    ld   [hl], a
    ret


    db   $C5, $D5, $E5, $CD, $E3, $15, $44, $4D
    db   $E1, $F0, $80, $5F, $18, $0B, $0C, $79
    db   $E6, $0F, $20, $05, $79, $D6, $10, $4F
    db   $04, $2A, $02, $1D, $20, $F0, $F0, $80
    db   $D1, $C1, $C3, $BC, $42

toc_07_43A0:
    ld   hl, $DB51
    ldi  a, [hl]
    sub  a, $10
    ld   c, a
    ldi  a, [hl]
    ld   b, a
    jr   nc, .else_07_43AC

    dec  b
.else_07_43AC:
    ldi  a, [hl]
    sub  a, $10
    ld   e, a
    ld   d, [hl]
    jr   nc, .else_07_43B4

    dec  d
.else_07_43B4:
    ld   a, $0B
.loop_07_43B6:
    push af
    push bc
    push de
    ld   a, $0D
    call toc_07_441E
    pop  hl
    ld   de, $0010
    add  hl, de
    ld   d, h
    ld   e, l
    pop  bc
    pop  af
    dec  a
    jr   nz, .loop_07_43B6

    ret


toc_07_43CB:
    ld   hl, $DB51
    ldi  a, [hl]
    sub  a, $10
    ld   c, a
    ldi  a, [hl]
    ld   b, a
    jr   nc, .else_07_43D7

    dec  b
.else_07_43D7:
    ldi  a, [hl]
    sub  a, $10
    ld   e, a
    ld   d, [hl]
    jr   nc, .else_07_43DF

    dec  d
.else_07_43DF:
    ld   a, e
    and  %11110000
    ld   h, a
    ld   a, [$DB7E]
    sub  a, h
    jr   z, .else_07_4400

    push bc
    push de
    rla
    jr   nc, .else_07_43F5

    ld   a, e
    add  a, $A0
    ld   e, a
    jr   nc, .else_07_43F5

    inc  d
.else_07_43F5:
    ld   a, h
    ld   [$DB7E], a
    ld   a, $0D
    call toc_07_441E
    pop  de
    pop  bc
.else_07_4400:
    ld   a, c
    and  %11110000
    ld   h, a
    ld   a, [$DB7D]
    sub  a, h
    jr   z, .return_07_441D

    rla
    jr   nc, .else_07_4414

    ld   a, c
    add  a, $C0
    ld   c, a
    jr   nc, .else_07_4414

    inc  b
.else_07_4414:
    ld   a, h
    ld   [$DB7D], a
    ld   a, $0B
    call toc_07_4493
.return_07_441D:
    ret


toc_07_441E:
    swap a
    ld   [hDMARegion], a
    ld   a, [$DB3E]
    dec  a
    cp   d
    ret  c

    ld   a, d
    ld   [$FF83], a
    ld   a, e
    and  %11110000
    ld   e, a
    ld   a, c
    and  %11110000
    ld   c, a
.toc_07_4433:
    ld   a, [$DB3D]
    dec  a
    cp   b
    jr   nc, .else_07_4445

    ld   a, [hDMARegion]
    add  a, c
    ret  nc

    ld   [hDMARegion], a
    inc  b
    ld   c, $00
    jr   .toc_07_4433

.else_07_4445:
    ld   a, b
    ld   [$FF82], a
    ld   hl, $CD35
    ld   a, d
    add  a, l
    ld   l, a
    ld   a, b
    rlca
    add  a, [hl]
    ld   l, a
    ld   h, $CD
    ldi  a, [hl]
    ld   d, a
    ld   l, [hl]
    ld   a, [hDMARegion]
    add  a, c
    ld   b, $FF
    jr   c, .else_07_4461

    ld   b, a
    dec  b
    xor  a
.else_07_4461:
    ld   [hDMARegion], a
    inc  d
    jr   .toc_07_4480

.loop_07_4466:
    ld   h, $CB
    ld   a, [hl]
    and  %11110000
    cp   e
    jr   nz, .else_07_447F

    ld   h, $CA
    ld   a, [hl]
    cp   c
    jr   c, .else_07_447F

    scf
    sbc  b
    jr   nc, .else_07_447F

    ld   h, $BB
    ld   a, [hl]
    or   a
    call z, toc_07_4508
.else_07_447F:
    inc  l
.toc_07_4480:
    dec  d
    jr   nz, .loop_07_4466

    ld   a, [hDMARegion]
    or   a
    ret  z

    ld   a, [$FF83]
    ld   d, a
    ld   a, [$FF82]
    ld   b, a
    inc  b
    ld   c, $00
    jp   .toc_07_4433

toc_07_4493:
    swap a
    ld   [hDMARegion], a
    ld   a, [$DB3D]
    dec  a
    cp   b
    ret  c

    ld   a, b
    ld   [$FF82], a
    ld   a, c
    and  %11110000
    ld   c, a
    ld   a, e
    and  %11110000
    ld   e, a
.toc_07_44A8:
    ld   a, [$DB3E]
    dec  a
    cp   d
    jr   nc, .else_07_44BA

    ld   a, [hDMARegion]
    add  a, e
    ret  nc

    ld   [hDMARegion], a
    inc  d
    ld   e, $00
    jr   .toc_07_44A8

.else_07_44BA:
    ld   a, d
    ld   [$FF83], a
    ld   hl, $CD35
    ld   a, d
    add  a, l
    ld   l, a
    ld   a, b
    rlca
    add  a, [hl]
    ld   l, a
    ld   h, $CD
    ldi  a, [hl]
    ld   b, a
    ld   l, [hl]
    ld   a, [hDMARegion]
    add  a, e
    ld   d, $FF
    jr   c, .else_07_44D6

    ld   d, a
    dec  d
    xor  a
.else_07_44D6:
    ld   [hDMARegion], a
    inc  b
    jr   .toc_07_44F5

.loop_07_44DB:
    ld   h, $CA
    ld   a, [hl]
    and  %11110000
    cp   c
    jr   nz, .else_07_44F4

    ld   h, $CB
    ld   a, [hl]
    cp   e
    jr   c, .else_07_44F4

    scf
    sbc  d
    jr   nc, .else_07_44F4

    ld   h, $BB
    ld   a, [hl]
    or   a
    call z, toc_07_4508
.else_07_44F4:
    inc  l
.toc_07_44F5:
    dec  b
    jr   nz, .loop_07_44DB

    ld   a, [hDMARegion]
    or   a
    ret  z

    ld   a, [$FF82]
    ld   b, a
    ld   a, [$FF83]
    ld   d, a
    inc  d
    ld   e, $00
    jp   .toc_07_44A8

toc_07_4508:
    push bc
    push de
    push hl
    ld   h, $CA
    ld   c, [hl]
    ld   h, $CB
    ld   e, [hl]
    ld   a, [$FF82]
    ld   b, a
    ld   a, [$FF83]
    ld   d, a
    ld   h, $CC
    ld   l, [hl]
    ld   h, $7A
    push hl
    ld   a, [hl]
    ld   hl, $A8B2
    call toc_01_07C4
    ld   d, h
    pop  hl
    ld   a, d
    or   a
    jr   z, .else_07_4580

    inc  h
    ld   e, $5C
    ld   a, [hl]
    swap a
    and  %00001111
    ld   [de], a
    ld   e, $5B
    ld   a, [hl]
    and  %00001111
    ld   [de], a
    inc  h
    ld   e, $4C
    ld   a, [hl]
    ld   [de], a
    inc  h
    ld   e, $4A
    ld   a, [hl]
    ld   [de], a
    inc  h
    inc  e
    ld   a, [hl]
    ld   [de], a
    ld   e, $62
    ld   a, $FF
    ld   [de], a
    inc  h
    ld   a, [hl]
    ld   bc, $0005
    ld   hl, $DB7F
    jr   .toc_07_4557

.loop_07_4556:
    add  hl, bc
.toc_07_4557:
    cp   [hl]
    jr   nz, .loop_07_4556

    inc  hl
    ld   e, $46
    ldi  a, [hl]
    ld   [de], a
    ld   e, $18
    ldi  a, [hl]
    ld   [de], a
    dec  e
    ldi  a, [hl]
    ld   [de], a
    dec  e
    ld   a, [hl]
    ld   [de], a
    ld   e, $5E
    ld   a, $08
    ld   [de], a
    inc  e
    ld   [de], a
    ld   e, $60
    xor  a
    ld   [de], a
    inc  e
    ld   [de], a
    pop  hl
    ld   [hl], $01
    ld   e, $49
    ld   a, l
    ld   [de], a
    pop  de
    pop  bc
    ret


.else_07_4580:
    pop  hl
    pop  de
    pop  bc
    ret


toc_07_4584:
    ld   a, [$DB57]
    ld   b, a
    ld   hl, $DBCF
    ld   d, $BB
.loop_07_458D:
    inc  hl
.toc_07_458E:
    ldi  a, [hl]
    or   a
    ret  z

    ldi  a, [hl]
    cp   b
    jr   nz, .loop_07_458D

    ldi  a, [hl]
    ld   e, a
    ld   a, $01
    ld   [de], a
    jr   .toc_07_458E

toc_07_459C:
    inc  e
    ld   hl, $DBD0
    ld   b, h
    ld   c, l
.toc_07_45A2:
    ldi  a, [hl]
    or   a
    jr   z, .else_07_45B7

    cp   e
    jr   nz, .else_07_45AD

    inc  hl
    inc  hl
    jr   .toc_07_45A2

.else_07_45AD:
    ld   [bc], a
    inc  bc
    ldi  a, [hl]
    ld   [bc], a
    inc  bc
    ldi  a, [hl]
    ld   [bc], a
    inc  bc
    jr   .toc_07_45A2

.else_07_45B7:
    xor  a
    ld   [bc], a
    ld   a, c
    ld   [$DCFD], a
    ld   a, b
    ld   [$DCFE], a
    ret


    db   $0F, $4C, $00, $17, $F6, $0D, $10, $51
    db   $0E, $16, $F9, $45, $1A, $47, $42, $47
    db   $5C, $47, $86, $47, $B9, $47, $ED, $47
    db   $6F, $48, $9A, $47, $B4, $46, $BE, $49
    db   $28, $4A, $45, $4A, $DA, $4A, $11, $4B
    db   $5C, $4B, $CA, $47, $92, $4B, $96, $4B
    db   $A0, $4B, $CD, $4B, $D9, $4B, $16, $03
    db   $A4, $0D, $40, $04, $46, $72, $0B, $01
    db   $00, $0D, $11, $46, $05, $03, $0D, $62
    db   $46, $05, $03, $18, $05, $08, $16, $CD
    db   $47, $06, $1E, $45, $12, $E6, $E0, $CB
    db   $37, $1F, $1E, $3A, $12, $21, $58, $46
    db   $85, $6F, $30, $01, $24, $7E, $6F, $17
    db   $9F, $67, $1E, $07, $1A, $85, $12, $1C
    db   $1A, $8C, $12, $1E, $3A, $1A, $21, $5A
    db   $46, $85, $6F, $30, $01, $24, $7E, $6F
    db   $17, $9F, $67, $1E, $04, $1A, $85, $12
    db   $1C, $1A, $8C, $12, $CD, $62, $46, $1E
    db   $3A, $1A, $C6, $0A, $12, $C9, $FA, $FB
    db   $00, $05, $06, $05, $00, $FB, $FA, $FB
    db   $1E, $3A, $1A, $21, $89, $46, $87, $85
    db   $6F, $30, $01, $24, $1E, $0F, $2A, $12
    db   $1C, $7E, $12, $1E, $3A, $1A, $21, $8D
    db   $46, $87, $85, $6F, $30, $01, $24, $1E
    db   $0D, $2A, $12, $1C, $7E, $12, $C9, $00
    db   $FD, $00, $FE, $00, $00, $00, $02, $00
    db   $03, $00, $02, $00, $00, $00, $FE, $00
    db   $FD, $00, $FE, $00, $FE, $80, $FE, $00
    db   $00, $80, $01, $00, $02, $80, $01, $00
    db   $00, $80, $FE, $00, $FE, $80, $FE, $17
    db   $F6, $0D, $03, $A4, $0D, $40, $04, $46
    db   $72, $0B, $01, $00, $0D, $C7, $46, $05
    db   $0C, $18, $05, $04, $16, $CD, $47, $06
    db   $1E, $45, $12, $E6, $E0, $CB, $37, $1F
    db   $21, $D8, $46, $C3, $EC, $46, $00, $FF
    db   $4B, $FF, $00, $00, $B5, $00, $00, $01
    db   $B5, $00, $00, $00, $4B, $FF, $00, $FF
    db   $4B, $FF, $87, $85, $6F, $30, $01, $24
    db   $1E, $0F, $2A, $12, $1C, $2A, $12, $23
    db   $23, $1E, $0D, $2A, $12, $1C, $2A, $12
    db   $C9, $87, $85, $6F, $30, $01, $24, $1E
    db   $0F, $2A, $12, $1C, $2A, $12, $23, $23
    db   $1E, $0D, $2A, $12, $1C, $2A, $12, $C9
    db   $03, $A4, $0D, $40, $04, $89, $76, $0B
    db   $19, $00, $02, $19, $01, $02, $19, $02
    db   $02, $0F, $47, $10, $05, $02, $0F, $47
    db   $00, $19, $03, $02, $19, $04, $02, $19
    db   $05, $02, $0F, $47, $10, $05, $02, $16
    db   $03, $A4, $0D, $40, $04, $89, $76, $0B
    db   $19, $06, $02, $19, $07, $02, $19, $08
    db   $02, $19, $09, $02, $0F, $47, $10, $05
    db   $02, $16, $03, $80, $47, $47, $04, $52
    db   $6F, $0B, $26, $00, $FF, $08, $00, $00
    db   $2A, $F0, $0F, $47, $10, $19, $04, $02
    db   $0F, $47, $00, $05, $02, $19, $05, $02
    db   $0F, $47, $10, $05, $02, $16, $CD, $91
    db   $0C, $C3, $A4, $0D, $03, $A4, $0D, $40
    db   $04, $52, $6F, $0B, $19, $05, $04, $19
    db   $04, $02, $0F, $47, $10, $05, $02, $16
    db   $03, $A4, $0D, $40, $04, $52, $6F, $0B
    db   $26, $00, $01, $08, $80, $FF, $09, $04
    db   $19, $04, $02, $19, $05, $02, $0A, $18
    db   $19, $04, $02, $19, $05, $02, $16, $04
    db   $52, $6F, $0B, $0F, $47, $10, $19, $06
    db   $04, $19, $05, $04, $19, $04, $04, $16
    db   $0F, $47, $10, $04, $83, $77, $0B, $09
    db   $02, $19, $00, $02, $19, $01, $02, $19
    db   $02, $02, $19, $03, $02, $19, $04, $02
    db   $19, $05, $02, $19, $06, $02, $19, $07
    db   $02, $0A, $16, $04, $86, $54, $08, $08
    db   $00, $FF, $0D, $04, $48, $03, $37, $48
    db   $47, $19, $13, $0A, $19, $14, $10, $01
    db   $15, $00, $1E, $04, $CD, $47, $06, $E6
    db   $0F, $D6, $08, $6F, $17, $9F, $67, $1A
    db   $85, $12, $1C, $1A, $8C, $12, $1E, $07
    db   $1A, $D6, $04, $12, $1C, $1A, $DE, $00
    db   $12, $1E, $39, $CD, $47, $06, $E6, $03
    db   $12, $1E, $3A, $3E, $01, $12, $FA, $83
    db   $A0, $1E, $46, $12, $C9, $CD, $A4, $0D
    db   $CD, $B3, $1A, $28, $04, $62, $C3, $BA
    db   $0B, $1E, $3A, $1A, $3D, $12, $C0, $3E
    db   $08, $12, $1E, $39, $1A, $3C, $E6, $03
    db   $12, $21, $67, $48, $87, $85, $6F, $30
    db   $01, $24, $2A, $66, $6F, $1E, $0D, $7D
    db   $12, $1C, $7C, $12, $C9, $80, $00, $20
    db   $00, $80, $FF, $E0, $FF, $04, $86, $54
    db   $08, $0D, $8C, $48, $24, $1F, $03, $A4
    db   $0D, $40, $19, $16, $02, $19, $17, $04
    db   $19, $18, $04, $19, $19, $04, $19, $1A
    db   $04, $16, $1E, $07, $1A, $E6, $F0, $12
    db   $FA, $83, $A0, $1E, $46, $12, $C9, $17
    db   $F6, $0D, $03, $A4, $0D, $40, $04, $52
    db   $6F, $0B, $0F, $3A, $00, $0D, $C9, $48
    db   $05, $03, $19, $07, $03, $0D, $C9, $48
    db   $19, $08, $03, $19, $09, $03, $0D, $C9
    db   $48, $19, $0A, $03, $19, $07, $03, $04
    db   $46, $72, $0B, $19, $00, $08, $16, $1E
    db   $3A, $1A, $21, $E4, $48, $87, $85, $6F
    db   $30, $01, $24, $2A, $66, $6F, $1E, $39
    db   $1A, $CD, $EC, $46, $1E, $3A, $1A, $3C
    db   $12, $C9, $EA, $48, $FE, $48, $12, $49
    db   $00, $FA, $C2, $FB, $00, $00, $3E, $04
    db   $00, $06, $3E, $04, $00, $00, $C2, $FB
    db   $00, $FA, $C2, $FB, $00, $FD, $E1, $FD
    db   $00, $00, $1F, $02, $00, $03, $1F, $02
    db   $00, $00, $E1, $FD, $00, $FD, $E1, $FD
    db   $80, $FE, $F1, $FE, $00, $00, $0F, $01
    db   $80, $01, $0F, $01, $00, $00, $F1, $FE
    db   $80, $FE, $F1, $FE, $17, $F6, $0D, $03
    db   $B5, $49, $47, $04, $52, $6F, $0B, $22
    db   $9A, $49, $07, $10, $39, $0E, $03, $3F
    db   $49, $68, $49, $75, $49, $07, $00, $00
    db   $08, $00, $FE, $29, $00, $2A, $3A, $05
    db   $0A, $07, $80, $00, $08, $80, $FF, $29
    db   $00, $2A, $00, $05, $04, $07, $00, $04
    db   $08, $00, $01, $29, $C0, $2A, $00, $05
    db   $14, $2A, $E0, $05, $28, $16, $07, $00
    db   $FE, $08, $00, $FE, $29, $10, $2A, $30
    db   $05, $28, $16, $07, $00, $04, $08, $00
    db   $FE, $29, $8E, $2A, $36, $05, $0A, $07
    db   $80, $00, $08, $80, $FF, $29, $00, $2A
    db   $00, $05, $04, $07, $00, $FC, $08, $00
    db   $02, $29, $30, $2A, $D0, $05, $32, $16
    db   $19, $01, $03, $19, $02, $03, $19, $0B
    db   $03, $19, $0C, $03, $19, $0D, $03, $19
    db   $0E, $03, $19, $0F, $03, $19, $10, $03
    db   $06, $9A, $49, $CD, $80, $0C, $CD, $91
    db   $0C, $C3, $A4, $0D, $0F, $4C, $01, $0D
    db   $D3, $49, $03, $A4, $0D, $40, $04, $57
    db   $56, $0A, $19, $05, $02, $19, $06, $02
    db   $16, $C5, $62, $CD, $47, $06, $E6, $1F
    db   $5F, $D6, $10, $4F, $17, $9F, $47, $2E
    db   $07, $7E, $81, $22, $7E, $88, $77, $CD
    db   $47, $06, $E6, $1F, $D6, $10, $4F, $17
    db   $9F, $47, $2E, $04, $7E, $81, $22, $7E
    db   $88, $77, $7B, $1F, $1F, $1F, $E6, $03
    db   $04, $06, $00, $20, $04, $06, $04, $EE
    db   $03, $80, $21, $14, $4A, $CD, $EC, $46
    db   $C1, $C9, $00, $FE, $96, $FE, $00, $00
    db   $6A, $01, $00, $02, $6A, $01, $00, $00
    db   $96, $FE, $00, $FE, $96, $FE, $0F, $4C
    db   $01, $04, $B8, $5D, $0A, $0D, $35, $4A
    db   $05, $02, $16, $1E, $48, $1A, $67, $2E
    db   $39, $7E, $1E, $15, $12, $2E, $45, $5D
    db   $7E, $12, $C9, $0F, $4C, $01, $04, $48
    db   $64, $0A, $0D, $52, $4A, $05, $02, $16
    db   $1E, $48, $1A, $67, $2E, $3A, $7E, $1E
    db   $15, $12, $2E, $45, $5D, $7E, $12, $C9
    db   $0F, $4C, $00, $17, $F6, $0D, $03, $A4
    db   $0D, $40, $0D, $93, $4A, $11, $7D, $4A
    db   $04, $46, $72, $0B, $05, $02, $01, $00
    db   $05, $24, $16, $04, $52, $6F, $0B, $05
    db   $02, $09, $03, $19, $07, $03, $19, $08
    db   $03, $19, $09, $03, $19, $0A, $03, $0A
    db   $16, $C5, $1E, $48, $1A, $67, $2E, $3D
    db   $4E, $2D, $46, $2D, $C5, $CD, $47, $06
    db   $E6, $1F, $5F, $7E, $D6, $40, $D6, $0F
    db   $83, $E0, $84, $CD, $1C, $29, $CD, $E0
    db   $28, $F0, $9A, $57, $1E, $0D, $79, $12
    db   $1C, $78, $12, $C1, $F0, $84, $CD, $1E
    db   $29, $CD, $E0, $28, $F0, $9A, $57, $1E
    db   $0F, $79, $12, $1C, $78, $12, $CD, $47
    db   $06, $E6, $03, $1E, $27, $12, $C1, $C9
    db   $17, $42, $03, $20, $00, $00, $21, $00
    db   $00, $24, $40, $03, $84, $4B, $47, $09
    db   $02, $21, $FE, $FF, $05, $02, $21, $01
    db   $00, $05, $02, $0A, $09, $02, $21, $FF
    db   $FF, $05, $02, $21, $01, $00, $05, $02
    db   $0A, $09, $02, $21, $FF, $FF, $05, $02
    db   $21, $00, $00, $05, $02, $0A, $16, $17
    db   $42, $03, $20, $00, $00, $21, $00, $00
    db   $24, $40, $03, $84, $4B, $47, $09, $02
    db   $20, $01, $00, $21, $01, $00, $05, $02
    db   $20, $FE, $FF, $21, $00, $00, $05, $02
    db   $20, $00, $00, $21, $FF, $FF, $05, $02
    db   $20, $02, $00, $21, $00, $00, $05, $02
    db   $20, $FF, $FF, $21, $01, $00, $05, $02
    db   $20, $FF, $FF, $21, $FF, $FF, $05, $02
    db   $20, $01, $00, $21, $FF, $FF, $05, $02
    db   $0A, $16, $17, $42, $03, $20, $00, $00
    db   $21, $00, $00, $03, $84, $4B, $47, $09
    db   $02, $21, $FF, $FF, $05, $02, $21, $01
    db   $00, $05, $02, $0A, $09, $02, $21, $FF
    db   $FF, $05, $02, $21, $00, $00, $05, $02
    db   $0A, $16, $21, $06, $DA, $1E, $07, $1A
    db   $86, $22, $1E, $04, $1A, $86, $77, $C9
    db   $1B, $40, $4E, $03, $26, $40, $FE, $0D
    db   $32, $10, $18, $06, $A7, $4B, $26, $C0
    db   $01, $0D, $32, $10, $E8, $03, $C4, $4B
    db   $47, $04, $52, $6F, $0B, $08, $00, $FD
    db   $2A, $20, $19, $04, $04, $19, $05, $02
    db   $19, $04, $02, $19, $05, $02, $19, $04
    db   $06, $16, $CD, $80, $0C, $CD, $91, $0C
    db   $C3, $A4, $0D, $0D, $D3, $4B, $06, $D9
    db   $4B, $1E, $45, $1A, $2F, $12, $C9, $03
    db   $1D, $4C, $47, $08, $00, $04, $05, $06
    db   $16, $18, $2A, $E0, $26, $40, $02, $0D
    db   $32, $10, $EE, $03, $C4, $4B, $47, $0D
    db   $A5, $1A, $12, $05, $4C, $04, $52, $6F
    db   $0B, $19, $04, $02, $19, $05, $03, $19
    db   $04, $03, $16, $04, $86, $54, $08, $0D
    db   $16, $4C, $19, $14, $02, $19, $15, $03
    db   $19, $14, $03, $16, $FA, $83, $A0, $1E
    db   $46, $12, $C9, $CD, $A4, $0D, $21, $AF
    db   $FF, $3E, $03, $22, $3E, $00, $22, $3E
    db   $00, $22, $CD, $88, $1C, $30, $08, $1E
    db   $07, $01, $E3, $4B, $C3, $46, $08, $C9
    db   $0F, $39, $07, $0F, $3A, $07, $17, $FF
    db   $0D, $10, $5A, $0E, $1E, $51, $4D, $BB
    db   $4D, $FA, $4E, $FA, $4E, $FA, $4E, $FA
    db   $4E, $56, $4E, $FA, $4E, $A4, $4F, $21
    db   $50, $2B, $51, $4B, $52, $C7, $52, $2C
    db   $53, $D4, $53, $09, $54, $29, $54, $9B
    db   $54, $C6, $54, $FD, $51, $A9, $52, $B8
    db   $52, $8C, $55, $B5, $4D, $D2, $55, $DB
    db   $55, $E1, $55, $FB, $55, $AF, $4D, $4D
    db   $4E, $0F, $46, $00, $18, $0F, $4C, $00
    db   $10, $5A, $0E, $1E, $CA, $4C, $CA, $4C
    db   $CA, $4C, $CA, $4C, $CA, $4C, $CA, $4C
    db   $CA, $4C, $CA, $4C, $CA, $4C, $CA, $4C
    db   $CA, $4C, $CA, $4C, $CA, $4C, $CA, $4C
    db   $E5, $4C, $CA, $4C, $CA, $4C, $CA, $4C
    db   $CA, $4C, $CA, $4C, $CA, $4C, $CA, $4C
    db   $CA, $4C, $CA, $4C, $CA, $4C, $CA, $4C
    db   $CA, $4C, $CA, $4C, $CA, $4C, $CA, $4C
    db   $03, $A4, $0D, $40, $04, $52, $6F, $0B
    db   $0F, $47, $10, $19, $06, $04, $19, $05
    db   $04, $19, $04, $04, $16, $18, $29, $00
    db   $06, $EC, $4C, $26, $00, $02, $0D, $32
    db   $10, $F0, $0F, $5A, $06, $0F, $4C, $02
    db   $0F, $39, $10, $0F, $3A, $10, $03, $39
    db   $4D, $47, $24, $11, $0F, $47, $00, $04
    db   $83, $77, $0B, $19, $00, $02, $19, $01
    db   $02, $19, $02, $02, $19, $03, $02, $19
    db   $04, $02, $19, $05, $02, $19, $06, $02
    db   $19, $07, $02, $19, $00, $02, $19, $01
    db   $02, $19, $02, $02, $19, $03, $02, $0F
    db   $47, $10, $19, $04, $02, $19, $05, $02
    db   $19, $06, $02, $19, $07, $02, $16, $CD
    db   $80, $0C, $CD, $A4, $0D, $CD, $97, $4D
    db   $CD, $7F, $19, $30, $09, $1E, $0D, $AF
    db   $12, $1C, $12, $1E, $11, $12, $C9, $0F
    db   $4C, $01, $03, $76, $4D, $47, $04, $52
    db   $6F, $0B, $01, $03, $26, $00, $04, $05
    db   $08, $26, $00, $01, $05, $03, $26, $80
    db   $00, $05, $02, $26, $55, $00, $05, $02
    db   $18, $05, $08, $16, $CD, $A4, $0D, $CD
    db   $90, $4D, $30, $04, $62, $C3, $BA, $0B
    db   $CD, $7F, $19, $30, $08, $1E, $07, $01
    db   $83, $4C, $C3, $46, $08, $C9, $CD, $EA
    db   $1A, $3E, $FF, $18, $06, $CD, $EA, $1A
    db   $FA, $5B, $A0, $EA, $15, $DF, $CD, $8F
    db   $3B, $38, $05, $F0, $9A, $57, $A7, $C9
    db   $F0, $9A, $57, $37, $C9, $0F, $4C, $0A
    db   $06, $C4, $4D, $0F, $4C, $04, $06, $C4
    db   $4D, $0F, $4C, $0A, $0D, $A5, $1A, $12
    db   $05, $4E, $03, $DE, $4D, $47, $04, $52
    db   $6F, $0B, $26, $00, $04, $19, $07, $03
    db   $19, $08, $03, $19, $09, $03, $19, $0A
    db   $03, $06, $CF, $4D, $CD, $A4, $0D, $CD
    db   $90, $4D, $30, $04, $62, $C3, $BA, $0B
    db   $CD, $7F, $19, $30, $15, $1E, $2E, $21
    db   $99, $42, $3E, $1E, $CD, $CF, $05, $F0
    db   $9A, $57, $1E, $07, $01, $83, $4C, $C3
    db   $46, $08, $C9, $18, $03, $1E, $4E, $47
    db   $04, $52, $6F, $0B, $09, $0A, $19, $07
    db   $03, $19, $08, $03, $19, $09, $03, $19
    db   $0A, $03, $0A, $16, $1E, $04, $01, $30
    db   $00, $CD, $35, $0D, $CD, $A4, $0D, $CD
    db   $90, $4D, $30, $04, $62, $C3, $BA, $0B
    db   $CD, $7F, $19, $30, $15, $1E, $2E, $21
    db   $99, $42, $3E, $1E, $CD, $CF, $05, $F0
    db   $9A, $57, $1E, $07, $01, $83, $4C, $C3
    db   $46, $08, $C9, $0F, $4C, $14, $0F, $5A
    db   $06, $06, $5F, $4E, $0F, $4C, $14, $0D
    db   $A5, $1A, $12, $A6, $4E, $03, $85, $4E
    db   $47, $04, $52, $6F, $0B, $26, $00, $04
    db   $19, $01, $03, $19, $02, $03, $19, $0B
    db   $03, $19, $0C, $03, $19, $0D, $03, $19
    db   $0E, $03, $19, $0F, $03, $19, $10, $03
    db   $06, $6A, $4E, $CD, $A4, $0D, $CD, $90
    db   $4D, $CD, $7F, $19, $30, $15, $1E, $26
    db   $21, $99, $42, $3E, $1E, $CD, $CF, $05
    db   $F0, $9A, $57, $1E, $07, $01, $83, $4C
    db   $C3, $46, $08, $C9, $18, $03, $CB, $4E
    db   $47, $04, $52, $6F, $0B, $09, $05, $19
    db   $01, $03, $19, $02, $03, $19, $0B, $03
    db   $19, $0C, $03, $19, $0D, $03, $19, $0E
    db   $03, $19, $0F, $03, $19, $10, $03, $0A
    db   $16, $1E, $04, $01, $30, $00, $CD, $35
    db   $0D, $CD, $A4, $0D, $CD, $90, $4D, $30
    db   $04, $62, $C3, $BA, $0B, $CD, $7F, $19
    db   $30, $15, $1E, $26, $21, $99, $42, $3E
    db   $1E, $CD, $CF, $05, $F0, $9A, $57, $1E
    db   $07, $01, $83, $4C, $C3, $46, $08, $C9
    db   $0F, $4C, $03, $03, $8A, $4F, $47, $04
    db   $68, $59, $0A, $24, $1E, $0D, $23, $4F
    db   $19, $03, $02, $19, $04, $02, $19, $03
    db   $02, $19, $04, $02, $19, $05, $02, $19
    db   $06, $02, $19, $05, $02, $19, $06, $02
    db   $16, $C5, $FA, $70, $A0, $B7, $0E, $00
    db   $28, $02, $0E, $03, $1E, $48, $1A, $67
    db   $2E, $39, $7E, $81, $21, $66, $4F, $87
    db   $85, $6F, $30, $01, $24, $2A, $66, $6F
    db   $2A, $4F, $2A, $47, $1E, $45, $1A, $17
    db   $30, $0A, $79, $2F, $C6, $01, $4F, $78
    db   $2F, $CE, $00, $47, $1E, $0D, $79, $12
    db   $1C, $78, $12, $1C, $2A, $12, $1C, $2A
    db   $12, $1C, $C1, $C9, $72, $4F, $76, $4F
    db   $7A, $4F, $7E, $4F, $82, $4F, $86, $4F
    db   $D0, $01, $28, $FF, $00, $02, $00, $00
    db   $D0, $01, $D8, $00, $74, $00, $CA, $FF
    db   $80, $00, $00, $00, $74, $00, $36, $00
    db   $CD, $A4, $0D, $CD, $97, $4D, $30, $04
    db   $62, $C3, $BA, $0B, $CD, $7F, $19, $30
    db   $08, $1E, $07, $01, $83, $4C, $C3, $46
    db   $08, $C9, $0F, $4C, $05, $03, $07, $50
    db   $47, $04, $1A, $61, $0A, $0D, $A5, $1A
    db   $12, $C1, $4F, $26, $A0, $01, $19, $03
    db   $02, $19, $04, $02, $06, $B8, $4F, $26
    db   $80, $00, $19, $03, $02, $19, $04, $02
    db   $19, $03, $02, $19, $04, $02, $0F, $39
    db   $05, $0F, $3A, $05, $19, $05, $02, $19
    db   $06, $02, $19, $05, $02, $19, $06, $02
    db   $0F, $39, $03, $0F, $3A, $03, $19, $07
    db   $02, $19, $08, $02, $19, $07, $02, $19
    db   $08, $02, $0F, $39, $02, $0F, $3A, $02
    db   $19, $09, $02, $19, $0A, $02, $19, $09
    db   $02, $19, $0A, $02, $16, $CD, $A4, $0D
    db   $CD, $97, $4D, $30, $04, $62, $C3, $BA
    db   $0B, $CD, $7F, $19, $30, $08, $1E, $07
    db   $01, $83, $4C, $C3, $46, $08, $C9, $0F
    db   $4C, $03, $03, $DB, $50, $47, $04, $B6
    db   $55, $0A, $0D, $A5, $1A, $12, $60, $50
    db   $0F, $3B, $00, $26, $00, $04, $05, $08
    db   $26, $00, $03, $05, $08, $26, $80, $01
    db   $05, $08, $26, $80, $00, $05, $08, $03
    db   $B0, $50, $47, $26, $80, $FF, $05, $08
    db   $26, $80, $FE, $05, $08, $26, $00, $FD
    db   $05, $08, $26, $00, $FC, $00, $0F, $3B
    db   $01, $26, $00, $02, $05, $10, $26, $80
    db   $01, $05, $10, $26, $C0, $00, $05, $10
    db   $26, $40, $00, $05, $10, $03, $B0, $50
    db   $47, $26, $C0, $FF, $05, $10, $26, $40
    db   $FF, $05, $10, $26, $80, $FE, $05, $10
    db   $26, $00, $FE, $00, $24, $41, $03, $0C
    db   $51, $47, $0D, $A5, $1A, $12, $A5, $50
    db   $2A, $40, $26, $AB, $FE, $08, $00, $FE
    db   $05, $14, $16, $2A, $10, $26, $56, $FF
    db   $08, $00, $FF, $05, $28, $16, $CD, $A4
    db   $0D, $21, $09, $A0, $5D, $1A, $96, $C6
    db   $08, $FE, $10, $30, $1F, $2E, $0B, $5D
    db   $1A, $96, $C6, $08, $FE, $10, $30, $14
    db   $1E, $0E, $21, $99, $42, $3E, $1E, $CD
    db   $CF, $05, $F0, $9A, $57, $62, $C3, $BA
    db   $0B, $CD, $A4, $0D, $1E, $3B, $1A, $B7
    db   $1E, $15, $FA, $0E, $DA, $20, $05, $E6
    db   $06, $0F, $18, $04, $E6, $0C, $0F, $0F
    db   $C6, $03, $12, $CD, $97, $4D, $30, $04
    db   $62, $C3, $BA, $0B, $CD, $7F, $19, $30
    db   $08, $1E, $07, $01, $8E, $50, $C3, $46
    db   $08, $C9, $CD, $91, $0C, $CD, $94, $0C
    db   $CD, $A4, $0D, $1E, $15, $FA, $0E, $DA
    db   $E6, $0C, $0F, $0F, $C6, $03, $12, $CD
    db   $97, $4D, $30, $04, $62, $C3, $BA, $0B
    db   $C9, $17, $F6, $0D, $0F, $4C, $04, $03
    db   $94, $51, $47, $04, $4C, $5C, $0A, $26
    db   $00, $04, $0F, $09, $C0, $0D, $6C, $51
    db   $22, $61, $51, $07, $19, $03, $02, $19
    db   $04, $03, $19, $05, $02, $19, $06, $03
    db   $19, $07, $02, $19, $08, $03, $19, $09
    db   $02, $19, $0A, $03, $06, $46, $51, $2A
    db   $10, $08, $00, $FF, $05, $20, $2A, $F0
    db   $00, $16, $C5, $62, $2E, $45, $7E, $17
    db   $3E, $E0, $01, $0A, $00, $30, $05, $3E
    db   $20, $01, $F6, $FF, $2E, $11, $77, $2E
    db   $3B, $3E, $80, $22, $71, $2C, $70, $2C
    db   $3E, $80, $22, $3E, $F8, $22, $36, $FF
    db   $C1, $C9, $CD, $C0, $51, $CD, $80, $0C
    db   $CD, $91, $0C, $CD, $A4, $0D, $CD, $CE
    db   $51, $CD, $97, $4D, $21, $09, $A0, $5D
    db   $1A, $96, $C6, $08, $FE, $10, $30, $0D
    db   $3E, $01, $EA, $7C, $A0, $1E, $07, $01
    db   $6B, $51, $C3, $46, $08, $C9, $1E, $03
    db   $62, $2E, $3B, $0E, $06, $2A, $12, $1C
    db   $0D, $20, $FA, $C9, $21, $03, $A0, $1E
    db   $3B, $42, $4D, $0A, $12, $86, $02, $1C
    db   $2C, $0C, $0A, $12, $8E, $02, $1C, $2C
    db   $0C, $0A, $12, $8E, $02, $1C, $2C, $0C
    db   $0A, $12, $86, $02, $1C, $2C, $0C, $0A
    db   $12, $8E, $02, $1C, $2C, $0C, $0A, $12
    db   $8E, $02, $C9, $17, $F6, $0D, $0F, $4C
    db   $04, $03, $3C, $52, $47, $04, $4C, $5C
    db   $0A, $26, $00, $02, $0D, $6C, $51, $22
    db   $21, $52, $07, $2A, $10, $08, $80, $FF
    db   $05, $10, $2A, $F0, $05, $10, $16, $19
    db   $03, $02, $19, $04, $03, $19, $05, $02
    db   $19, $06, $03, $19, $07, $02, $19, $08
    db   $03, $19, $09, $02, $19, $0A, $03, $06
    db   $21, $52, $CD, $C0, $51, $CD, $80, $0C
    db   $CD, $91, $0C, $CD, $A4, $0D, $C3, $CE
    db   $51, $0F, $4C, $04, $03, $72, $52, $47
    db   $04, $C2, $62, $0A, $26, $33, $01, $19
    db   $03, $06, $19, $04, $06, $19, $05, $06
    db   $0F, $3A, $0C, $19, $06, $06, $0F, $3A
    db   $10, $19, $07, $06, $19, $08, $23, $16
    db   $CD, $A4, $0D, $1E, $15, $1A, $FE, $07
    db   $30, $09, $CD, $97, $4D, $30, $27, $62
    db   $C3, $BA, $0B, $62, $01, $00, $00, $11
    db   $F9, $FF, $CD, $D9, $1A, $CD, $9A, $4D
    db   $F5, $62, $01, $00, $00, $11, $07, $00
    db   $CD, $D9, $1A, $CD, $9A, $4D, $30, $03
    db   $F1, $18, $DC, $F1, $38, $D9, $C9, $26
    db   $80, $00, $08, $B7, $FF, $0D, $32, $10
    db   $14, $2A, $F2, $06, $CE, $52, $26, $80
    db   $00, $08, $49, $00, $0D, $32, $10, $14
    db   $2A, $0E, $06, $CE, $52, $26, $80, $00
    db   $0D, $32, $10, $19, $0F, $3C, $00, $0F
    db   $4C, $02, $03, $F7, $52, $47, $04, $0C
    db   $6A, $0A, $19, $03, $01, $19, $04, $02
    db   $19, $05, $03, $19, $06, $02, $19, $07
    db   $01, $19, $08, $02, $19, $09, $03, $19
    db   $0A, $02, $06, $DC, $52, $CD, $91, $0C
    db   $CD, $80, $0C, $CD, $83, $0C, $CD, $A4
    db   $0D, $CD, $97, $4D, $30, $04, $62, $C3
    db   $BA, $0B, $CD, $7F, $19, $30, $08, $1E
    db   $07, $01, $83, $4C, $C3, $46, $08, $CD
    db   $B3, $1A, $20, $0D, $1E, $3C, $1A, $3C
    db   $12, $FE, $10, $38, $04, $62, $C3, $BA
    db   $0B, $C9, $0F, $4C, $02, $03, $C7, $53
    db   $47, $04, $74, $5D, $0A, $0D, $58, $53
    db   $0D, $51, $53, $12, $4D, $53, $09, $02
    db   $19, $02, $01, $19, $03, $01, $0A, $19
    db   $02, $01, $16, $19, $02, $01, $16, $FA
    db   $70, $A0, $1E, $27, $12, $C9, $C5, $1E
    db   $48, $1A, $67, $2E, $39, $46, $1E, $45
    db   $1A, $17, $21, $87, $53, $30, $03, $21
    db   $A7, $53, $78, $87, $85, $6F, $30, $01
    db   $24, $1E, $0F, $2A, $12, $1C, $2A, $12
    db   $01, $0E, $00, $09, $1E, $0D, $2A, $12
    db   $1C, $2A, $12, $C1, $C9, $00, $F8, $9C
    db   $F8, $58, $FA, $F0, $FC, $00, $00, $10
    db   $03, $A8, $05, $64, $07, $00, $00, $10
    db   $03, $A8, $05, $64, $07, $00, $08, $64
    db   $07, $A8, $05, $10, $03, $00, $F8, $9C
    db   $F8, $58, $FA, $F0, $FC, $00, $00, $10
    db   $03, $A8, $05, $64, $07, $00, $00, $F0
    db   $FC, $58, $FA, $9C, $F8, $00, $F8, $9C
    db   $F8, $58, $FA, $F0, $FC, $CD, $A4, $0D
    db   $CD, $97, $4D, $30, $04, $62, $C3, $BA
    db   $0B, $C9, $0F, $4C, $04, $03, $E5, $53
    db   $47, $04, $B9, $63, $0A, $26, $00, $02
    db   $01, $04, $00, $CD, $A4, $0D, $CD, $97
    db   $4D, $30, $08, $1E, $07, $01, $83, $4C
    db   $C3, $46, $08, $CD, $7F, $19, $30, $08
    db   $1E, $07, $01, $DF, $4C, $C3, $46, $08
    db   $F0, $A6, $CB, $4F, $20, $E5, $C9, $0F
    db   $4C, $02, $03, $5C, $54, $47, $04, $ED
    db   $6B, $0A, $08, $00, $04, $0F, $3B, $10
    db   $19, $07, $02, $19, $06, $02, $19, $09
    db   $02, $19, $08, $02, $06, $1A, $54, $0F
    db   $4C, $02, $03, $5C, $54, $47, $04, $ED
    db   $6B, $0A, $08, $00, $04, $0F, $3B, $10
    db   $19, $08, $02, $19, $09, $02, $19, $06
    db   $02, $19, $07, $02, $06, $3A, $54, $03
    db   $8E, $54, $47, $18, $19, $0A, $02, $19
    db   $0B, $02, $19, $0C, $02, $19, $0D, $02
    db   $16, $16, $CD, $A4, $0D, $CD, $97, $4D
    db   $30, $04, $62, $C3, $BA, $0B, $CD, $7F
    db   $19, $30, $08, $1E, $07, $01, $49, $54
    db   $C3, $46, $08, $1E, $3B, $1A, $3D, $20
    db   $04, $62, $C3, $BA, $0B, $12, $CD, $B3
    db   $1A, $20, $08, $1E, $07, $01, $5B, $54
    db   $C3, $46, $08, $C9, $CD, $A4, $0D, $CD
    db   $97, $4D, $30, $04, $62, $C3, $BA, $0B
    db   $C9, $0F, $4C, $08, $03, $AC, $54, $47
    db   $04, $2E, $70, $0A, $01, $00, $26, $00
    db   $04, $00, $CD, $A4, $0D, $CD, $97, $4D
    db   $30, $04, $62, $C3, $BA, $0B, $CD, $7F
    db   $19, $30, $08, $1E, $07, $01, $83, $4C
    db   $C3, $46, $08, $C9, $0F, $4C, $02, $0D
    db   $DF, $54, $03, $65, $55, $47, $04, $E7
    db   $6C, $0A, $19, $07, $04, $19, $08, $04
    db   $19, $09, $04, $16, $16, $C5, $1E, $48
    db   $1A, $67, $2E, $15, $7E, $3D, $2E, $45
    db   $CB, $7E, $28, $04, $D6, $05, $2F, $3C
    db   $E0, $84, $21, $41, $55, $85, $6F, $30
    db   $01, $24, $7E, $4F, $17, $9F, $47, $1E
    db   $04, $1A, $81, $12, $1C, $1A, $88, $12
    db   $F0, $84, $21, $47, $55, $85, $6F, $30
    db   $01, $24, $7E, $4F, $17, $9F, $47, $1E
    db   $07, $1A, $81, $12, $1C, $1A, $88, $12
    db   $F0, $84, $21, $4D, $55, $87, $85, $6F
    db   $30, $01, $24, $1E, $0F, $2A, $12, $1C
    db   $2A, $12, $01, $0A, $00, $09, $1E, $0D
    db   $2A, $12, $1C, $2A, $12, $C1, $C9, $08
    db   $03, $02, $FE, $FD, $F8, $08, $0A, $0F
    db   $0F, $0A, $08, $00, $00, $2D, $01, $E7
    db   $01, $E7, $01, $2D, $01, $00, $00, $00
    db   $02, $9E, $01, $9E, $00, $62, $FF, $62
    db   $FE, $00, $FE, $CD, $A4, $0D, $CD, $97
    db   $4D, $30, $04, $62, $C3, $BA, $0B, $CD
    db   $7F, $19, $30, $08, $1E, $07, $01, $83
    db   $4C, $C3, $46, $08, $CD, $B3, $1A, $20
    db   $08, $1E, $07, $01, $DE, $54, $C3, $46
    db   $08, $C9, $0F, $4C, $0A, $03, $B4, $55
    db   $47, $04, $86, $68, $0D, $18, $22, $A5
    db   $55, $07, $0D, $32, $10, $1C, $05, $10
    db   $29, $00, $00, $19, $0B, $03, $19, $0C
    db   $03, $19, $0D, $03, $19, $0E, $03, $06
    db   $A5, $55, $1E, $3B, $1A, $3C, $12, $E6
    db   $02, $28, $02, $3E, $10, $1E, $47, $12
    db   $CD, $80, $0C, $CD, $A4, $0D, $CD, $90
    db   $4D, $30, $04, $62, $C3, $BA, $0B, $C9
    db   $26, $80, $02, $08, $80, $FE, $06, $E7
    db   $55, $26, $80, $03, $06, $E7, $55, $26
    db   $80, $02, $08, $80, $01, $0F, $4C, $0A
    db   $03, $A4, $0D, $40, $04, $25, $47, $10
    db   $19, $12, $02, $19, $13, $02, $06, $F2
    db   $55, $0F, $4C, $14, $03, $23, $56, $47
    db   $04, $77, $4A, $10, $18, $22, $14, $56
    db   $07, $0D, $32, $10, $40, $05, $08, $29
    db   $00, $00, $19, $07, $03, $19, $08, $03
    db   $19, $07, $03, $19, $06, $03, $06, $14
    db   $56, $CD, $80, $0C, $C3, $A4, $0D, $5A
    db   $6B, $0C, $00, $40, $0C, $70, $6B, $0C
    db   $74, $40, $0C, $05, $6D, $0C, $65, $42
    db   $0C, $57, $6D, $0C, $4D, $43, $0C, $AC
    db   $6F, $0C, $C8, $4A, $0C, $F1, $6E, $0C
    db   $EF, $45, $0C, $6A, $6F, $0C, $FB, $46
    db   $0C, $CD, $6F, $0C, $18, $4B, $0C, $10
    db   $70, $0C, $DD, $4B, $0C, $86, $54, $08
    db   $D1, $47, $0C, $7C, $70, $0C, $2E, $49
    db   $0C, $CC, $70, $0C, $0F, $4A, $0C, $F8
    db   $70, $0C, $74, $4C, $0C, $0E, $71, $0C
    db   $96, $4C, $0C, $45, $71, $0C, $6A, $4D
    db   $0C, $92, $71, $0C, $22, $4E, $0C, $53
    db   $72, $0C, $CE, $4F, $0C, $D0, $74, $0C
    db   $CC, $55, $0C, $45, $73, $0C, $CB, $52
    db   $0C, $21, $75, $0C, $BB, $57, $07, $42
    db   $75, $0C, $BB, $57, $07, $63, $75, $0C
    db   $BB, $57, $07, $78, $75, $0C, $BB, $57
    db   $07, $99, $75, $0C, $8B, $56, $0C, $DE
    db   $75, $0C, $84, $57, $0C, $8E, $77, $0C
    db   $F3, $59, $0C, $CA, $78, $0C, $06, $5C
    db   $0C, $0E, $7A, $0C, $63, $5F, $0C, $3F
    db   $7B, $0C, $BB, $57, $07, $7B, $7B, $0C
    db   $6D, $63, $0C, $DB, $7B, $0C, $31, $63
    db   $0C, $52, $6F, $0B, $BB, $57, $07, $EE
    db   $7B, $0C, $F8, $63, $0C, $1A, $7D, $0C
    db   $44, $67, $0C, $23, $7E, $0C, $F6, $69
    db   $0C, $4F, $7E, $0C, $A1, $6A, $0C, $9F
    db   $72, $0D, $84, $4F, $0D, $E1, $72, $0D
    db   $07, $50, $0D, $7A, $64, $0D, $00, $40
    db   $0D, $86, $68, $0D, $7C, $43, $0D, $E2
    db   $6A, $0D, $49, $47, $0D, $02, $70, $0D
    db   $A7, $4C, $0D, $0D, $73, $0D, $AB, $50
    db   $0D, $7B, $73, $0D, $5A, $51, $0D, $25
    db   $47, $10, $58, $57, $0D, $B4, $51, $10
    db   $6D, $5B, $0D, $00, $52, $10, $49, $5C
    db   $0D, $2C, $52, $10, $CC, $5C, $0D, $06
    db   $53, $10, $42, $5D, $0D, $74, $53, $10
    db   $34, $5E, $0D, $F4, $53, $10, $D9, $5E
    db   $0D, $7B, $54, $10, $78, $5F, $0D, $2C
    db   $55, $10, $42, $60, $0D, $5F, $55, $10
    db   $BB, $60, $0D, $54, $55, $10, $9D, $60
    db   $0D, $6A, $55, $10, $F5, $60, $0D, $79
    db   $77, $0D, $4C, $61, $0D, $E0, $58, $08
    db   $37, $64, $0D, $61, $57, $08, $4B, $64
    db   $0D, $EE, $75, $1A, $28, $70, $1A, $EC
    db   $76, $1A, $D3, $71, $1A, $6D, $76, $1A
    db   $4E, $71, $1A, $BB, $57, $07, $BB, $57
    db   $07, $0D, $77, $1A, $7C, $72, $1A, $18
    db   $77, $1A, $B6, $72, $1A, $33, $79, $1A
    db   $FD, $74, $1A, $A3, $55, $10, $80, $46
    db   $10, $FF

toc_07_57BC:
    ld   de, $D700
    ld   hl, $0000
    jr   .toc_07_57CF

.loop_07_57C4:
    ld   a, e
    add  a, a
    ld   c, a
    ld   a, $00
    adc  $00
    ld   b, a
    inc  bc
    add  hl, bc
    inc  e
.toc_07_57CF:
    ld   a, h
    ld   [de], a
    inc  d
    ld   a, l
    ld   [de], a
    dec  d
    ld   a, e
    inc  a
    jr   nz, .loop_07_57C4

    ret


    db   $7F, $80, $FF, $FF, $FF, $C0, $FC, $83
    db   $F3, $8C, $E7, $98, $EA, $95, $EA, $95
    db   $DA, $A5, $DF, $A0, $DD, $A2, $CF, $B0
    db   $E3, $9C, $C0, $BF, $C1, $BE, $FF, $C0
    db   $FF, $FF, $FF, $FF, $FF, $03, $3F, $C1
    db   $CF, $31, $E7, $19, $F7, $09, $F3, $0D
    db   $FB, $05, $FB, $05, $BB, $45, $B7, $49
    db   $C7, $39, $03, $FD, $83, $7D, $FF, $03
    db   $FF, $FF, $FF, $FF, $FF, $C0, $FE, $81
    db   $FC, $83, $F8, $87, $F8, $87, $F0, $8F
    db   $F1, $8E, $E3, $9C, $E3, $9C, $E7, $98
    db   $E7, $98, $F3, $8C, $F9, $86, $FF, $C0
    db   $FF, $FF, $FF, $FF, $FF, $03, $7F, $81
    db   $3F, $C1, $1F, $E1, $1F, $E1, $0F, $F1
    db   $8F, $71, $C7, $39, $C7, $39, $E7, $19
    db   $E7, $19, $CF, $31, $9F, $61, $FF, $03
    db   $FF, $FF, $FF, $FF, $FF, $C0, $F8, $87
    db   $E0, $9F, $E0, $9F, $F9, $86, $FB, $84
    db   $FC, $83, $FC, $83, $F8, $87, $F1, $8E
    db   $E3, $9C, $C7, $B8, $EF, $90, $FF, $C0
    db   $FF, $FF, $FF, $FF, $FF, $03, $3F, $C1
    db   $0F, $F1, $77, $89, $F7, $09, $F3, $0D
    db   $E3, $1D, $63, $9D, $43, $BD, $83, $7D
    db   $E7, $19, $E7, $19, $FF, $01, $FF, $03
    db   $FF, $FF, $FF, $FF, $FF, $C0, $FF, $80
    db   $F8, $87, $F0, $8F, $E0, $9F, $C0, $BF
    db   $C0, $BF, $C0, $BF, $C0, $BF, $C0, $BF
    db   $E0, $9F, $F0, $8F, $FF, $80, $FF, $C0
    db   $FF, $FF, $FF, $FF, $FF, $03, $FF, $01
    db   $1F, $E1, $0F, $F1, $07, $F9, $03, $FD
    db   $03, $FD, $03, $FD, $03, $FD, $03, $FD
    db   $07, $F9, $0F, $F1, $FF, $01, $FF, $03
    db   $FF, $FF, $FF, $FF, $FF, $C0, $FF, $80
    db   $F1, $8E, $F8, $87, $FC, $83, $FC, $83
    db   $FE, $81, $FE, $81, $FC, $83, $FC, $83
    db   $F8, $87, $F1, $8E, $FF, $80, $FF, $C0
    db   $FF, $FF, $FF, $FF, $FF, $03, $FF, $01
    db   $FF, $01, $7F, $81, $1F, $E1, $0F, $F1
    db   $07, $F9, $07, $F9, $0F, $F1, $1F, $E1
    db   $7F, $81, $FF, $01, $FF, $01, $FF, $03
    db   $FF, $FF, $FF, $FF, $FF, $C0, $FF, $80
    db   $FD, $82, $FD, $82, $FC, $83, $FC, $83
    db   $DC, $A3, $CC, $B3, $C4, $BB, $C0, $BF
    db   $E0, $9F, $E0, $9F, $FF, $80, $FF, $C0
    db   $FF, $FF, $FF, $FF, $FF, $03, $FF, $01
    db   $FF, $01, $FB, $05, $FB, $05, $F3, $0D
    db   $73, $8D, $63, $9D, $23, $DD, $03, $FD
    db   $03, $FD, $03, $FD, $FF, $01, $FF, $03
    db   $FF, $FF, $FF, $FF, $FF, $C0, $FF, $80
    db   $FC, $83, $FC, $83, $F8, $87, $F8, $87
    db   $F0, $8F, $FE, $81, $FE, $81, $FC, $83
    db   $FC, $83, $F9, $86, $FB, $84, $FF, $C0
    db   $FF, $FF, $FF, $FF, $FF, $03, $FF, $01
    db   $0F, $F1, $1F, $E1, $3F, $C1, $7F, $81
    db   $0F, $F1, $1F, $E1, $3F, $C1, $7F, $81
    db   $FF, $01, $FF, $01, $FF, $01, $FF, $03
    db   $FF, $FF, $FF, $FF, $FF, $C0, $FF, $80
    db   $E0, $9F, $C8, $B7, $D1, $AE, $C2, $BD
    db   $C5, $BA, $CB, $B4, $D7, $A8, $CE, $B1
    db   $CD, $B2, $E0, $9F, $FF, $80, $FF, $C0
    db   $FF, $FF, $FF, $FF, $FF, $03, $FF, $01
    db   $07, $F9, $B3, $4D, $73, $8D, $EB, $15
    db   $D3, $2D, $A3, $5D, $43, $BD, $8B, $75
    db   $13, $ED, $07, $F9, $FF, $01, $FF, $03
    db   $FF, $FF, $FF, $FF, $FF, $C0, $F1, $8E
    db   $F4, $8B, $CE, $B1, $DF, $A0, $CE, $B1
    db   $EA, $95, $C1, $BE, $C0, $BF, $D0, $AF
    db   $D8, $A7, $CC, $B3, $E0, $9F, $FF, $C0
    db   $FF, $FF, $FF, $FF, $FF, $03, $07, $F9
    db   $33, $CD, $1B, $E5, $0B, $F5, $03, $FD
    db   $83, $7D, $C7, $39, $E3, $1D, $4B, $B5
    db   $13, $ED, $2F, $D1, $8F, $71, $FF, $03
    db   $FF, $FF, $D5, $21, $4D, $CD, $36, $00
    db   $2C, $FA, $30, $DD, $22, $FA, $31, $DD
    db   $22, $36, $00, $2C, $36, $CF, $FA, $2F
    db   $DD, $6F, $26, $00, $54, $5D, $29, $19
    db   $29, $11, $29, $56, $19, $23, $23, $23
    db   $2A, $EA, $52, $DD, $2A, $EA, $53, $DD
    db   $7E, $EA, $37, $DD, $3E, $01, $EA, $58
    db   $DD, $21, $57, $DD, $3E, $2B, $32, $36
    db   $2C, $21, $35, $DD, $3E, $4E, $22, $36
    db   $DD, $21, $14, $DA, $3E, $51, $22, $36
    db   $2B, $21, $16, $DA, $3E, $51, $22, $36
    db   $2B, $3E, $50, $E0, $45, $EA, $29, $DA
    db   $D1, $C9

toc_07_5A7C:
    ld   hl, $DEDB
    xor  a
    ldi  [hl], a
    ldi  [hl], a
    ld   [hl], a
    ld   hl, $DEE0
    ld   [hl], a
    ld   hl, $DEE1
    ld   [hl], a
    ld   hl, $DEE9
    ld   [hl], a
    ld   hl, $DEEA
    ld   [hl], a
    ld   hl, $DEE3
    ldi  [hl], a
    ldi  [hl], a
    ld   [hl], a
    ld   a, $05
    ld   hl, $DEEB
    ld   [hl], a
    ld   hl, $DEEC
    ld   [hl], a
    ret


    db   $21, $29, $DA, $78, $22, $E0, $45, $79
    db   $77, $21, $16, $DA, $3E, $E0, $22, $36
    db   $02, $3E, $01, $EA, $2B, $DA, $21, $41
    db   $FF, $CB, $F6, $21, $F0, $8F, $01, $10
    db   $00, $3E, $FF, $CD, $2F, $06, $21, $00
    db   $9C, $01, $00, $04, $3E, $FF, $CD, $2F
    db   $06, $3E, $47, $E0, $40, $C9

toc_07_5ADA:
    clear [$DA2B]
    ld   hl, $DA16
    ld   a, $AA
    ldi  [hl], a
    ld   [hl], $02
    ld   hl, $DA14
    ld   a, $AA
    ldi  [hl], a
    ld   [hl], $02
    assign [gbLYC], 127
    ld   [wDesiredLYC], a
    xor  a
    ld   hl, gbSCY
    ldi  [hl], a
    ld   [hl], a
    ld   [$DA01], a
    ld   [$DA00], a
    assign [gbLCDC], LCDCF_BG_DISPLAY | LCDCF_OBJ_16_16 | LCDCF_OBJ_DISPLAY | LCDCF_TILEMAP_9C00
    ret


toc_07_5B06:
    ld   hl, wDesiredLYC
    ld   a, b
    ld   [hl], a
    ld   [gbLYC], a
    ld   hl, $DA16
    ld   a, $0C
    ldi  [hl], a
    ld   [hl], $03
    ld   hl, gbSTAT
    set  6, [hl]
    ret


    db   $3E, $67, $E0, $40, $3E, $58, $E0, $4A
    db   $3E, $07, $E0, $4B, $C9

toc_07_5B28:
    ld   hl, $DA14
    ld   a, $AA
    ldi  [hl], a
    ld   [hl], $02
    ld   hl, $DA16
    ld   a, $AA
    ldi  [hl], a
    ld   [hl], $02
    assign [gbLYC], 127
    ld   [wDesiredLYC], a
    ld   c, $14
    ld   de, $5B5D
    ld   hl, gbBGDAT1
.loop_07_5B47:
    ld   a, [de]
    inc  de
    ldi  [hl], a
    dec  c
    jr   nz, .loop_07_5B47

    ld   hl, $9C20
.loop_07_5B50:
    ld   a, [de]
    inc  de
    ldi  [hl], a
    dec  c
    jr   nz, .loop_07_5B50

    ld   hl, $DEDE
    xor  a
    ldi  [hl], a
    ld   [hl], a
    ret


    db   $7F, $7B, $6F, $6F, $6F, $6F, $6F, $6F
    db   $7F, $67, $67, $67, $67, $67, $67, $67
    db   $7F, $69, $6B, $7F, $7F, $70, $70, $70
    db   $70, $70, $70, $70, $7F, $7C, $70, $70
    db   $7F, $65, $66, $70, $7F, $6A, $6C, $7F

toc_07_5B85:
    ld   hl, $DEDE
    ld   b, [hl]
    bit  7, b
    jp   nz, .else_07_5BBA

    bit  1, b
    call nz, toc_07_5CC6
    bit  2, b
    call nz, toc_07_5E92
    bit  3, b
    call nz, toc_07_5EC8
    bit  5, b
    call nz, toc_07_5E06
    bit  6, b
    call nz, toc_07_5E6A
    ld   hl, $DEDF
    bit  0, [hl]
    jr   nz, .else_07_5BB4

    bit  0, b
    call nz, toc_07_5C6D
    ret


.else_07_5BB4:
    bit  4, b
    call nz, toc_07_5F13
    ret


.else_07_5BBA:
    ifNotZeroAtAddress $DEE9, .else_07_5BC4

    dec  a
    ld   [hl], a
    ret


.else_07_5BC4:
    ld   de, $DEE6
    ld   a, [de]
    ld   l, a
    inc  e
    ld   a, [de]
    ld   h, a
    inc  e
    ld   a, [de]
    jp   cbcallWithoutInterrupts

    db   $C9

toc_07_5BD2:
    ld   hl, $DEDF
    bit  0, [hl]
    call nz, toc_07_5C12
    ld   hl, $DEDF
    bit  1, [hl]
    jr   nz, .else_07_5BE9

    ld   de, $A04C
    ld   hl, $DEE3
    jr   .toc_07_5BEF

.else_07_5BE9:
    ld   de, $A072
    ld   hl, $DEE5
.toc_07_5BEF:
    ld   a, [de]
    cp   [hl]
    ret  z

    jr   nc, .else_07_5C01

    ld   a, [de]
    ld   [hl], a
    ld   hl, $DEEB
    xor  a
    ld   [hl], a
    ld   hl, $DEDE
    set  1, [hl]
    ret


.else_07_5C01:
    ifNotZeroAtAddress $DEEB, .else_07_5C0B

    dec  a
    ld   [hl], a
    ret


.else_07_5C0B:
    ld   a, $05
    ld   [hl], a
    call toc_07_5D36
    ret


toc_07_5C12:
    call toc_07_5C39
    ld   hl, $DEE4
    cp   [hl]
    ret  z

    jr   nc, .else_07_5C28

    ld   [hl], a
    ld   hl, $DEEC
    xor  a
    ld   [hl], a
    ld   hl, $DEDE
    set  4, [hl]
    ret


.else_07_5C28:
    ifNotZeroAtAddress $DEEC, .else_07_5C32

    dec  a
    ld   [hl], a
    ret


.else_07_5C32:
    ld   a, $05
    ld   [hl], a
    call toc_07_5DBB
    ret


toc_07_5C39:
    push bc
    push hl
    xor  a
    ld   b, a
    ld   d, a
    ld   hl, $A085
    ld   a, [hl]
    add  a, a
    jr   nc, .else_07_5C46

    inc  b
.else_07_5C46:
    add  a, a
    rl   b
    ld   l, a
    ld   h, b
    add  a, a
    rl   b
    add  a, l
    ld   c, a
    ld   a, b
    adc  h
    ld   b, a
    ld   hl, $A086
    ld   e, [hl]
    ld   a, c
.toc_07_5C58:
    ld   c, a
    sub  a, e
    jr   nc, .else_07_5C61

    dec  b
    bit  7, b
    jr   nz, .else_07_5C64

.else_07_5C61:
    inc  d
    jr   .toc_07_5C58

.else_07_5C64:
    ld   a, c
    and  a
    ld   a, d
    jr   z, .else_07_5C6A

    inc  a
.else_07_5C6A:
    pop  hl
    pop  bc
    ret


toc_07_5C6D:
    ld   a, $07
    call toc_01_0675
    ret  c

    push bc
    ld   de, $9C21
    ld   a, [$FF92]
    ld   l, a
    ld   h, $C4
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   [hl], $07
    inc  l
    ld   c, $70
    ld   de, $DEDB
    ld   a, [de]
    ld   b, a
    inc  de
    ld   b, a
    swap a
    and  %00001111
    add  a, c
    ld   [hl], a
    inc  l
    ld   a, b
    and  %00001111
    add  a, c
    ld   [hl], a
    inc  l
    ld   a, [de]
    inc  de
    ld   b, a
    swap a
    and  %00001111
    add  a, c
    ld   [hl], a
    inc  l
    ld   a, b
    and  %00001111
    add  a, c
    ld   [hl], a
    inc  l
    ld   a, [de]
    ld   b, a
    swap a
    and  %00001111
    add  a, c
    ld   [hl], a
    inc  l
    ld   a, b
    and  %00001111
    add  a, c
    ld   [hl], a
    inc  l
    ld   a, c
    ld   [hl], a
    inc  l
    ld   a, l
    ld   [$FF92], a
    pop  bc
    ld   hl, $DEDE
    res  0, b
    ld   [hl], b
    ret


toc_07_5CC6:
    ld   a, $07
    call toc_01_0675
    ret  c

    ld   de, $9C01
    ld   a, [$FF92]
    ld   l, a
    ld   h, $C4
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   [hl], $07
    inc  l
    ld   [hl], $7B
    inc  l
    ld   de, $DEDF
    ld   a, [de]
    bit  1, a
    jr   nz, .else_07_5D13

    ld   de, $A04C
    ld   a, [de]
    ld   d, $06
.loop_07_5CEC:
    and  a
    jr   z, .else_07_5CFF

    sub  a, $02
    jr   c, .else_07_5CFB

    ld   [hl], $64
    inc  l
    dec  d
    jr   nz, .loop_07_5CEC

    jr   .else_07_5D09

.else_07_5CFB:
    dec  d
    ld   [hl], $6E
    inc  l
.else_07_5CFF:
    ld   a, d
    and  a
    jr   z, .else_07_5D09

    ld   [hl], $63
    inc  l
    dec  d
    jr   nz, .else_07_5CFF

.else_07_5D09:
    ld   a, l
    ld   [$FF92], a
    ld   hl, $DEDE
    res  1, b
    ld   [hl], b
    ret


.else_07_5D13:
    ld   a, [$A072]
    ld   d, $06
    and  a
    jr   z, .else_07_5D22

.loop_07_5D1B:
    ld   [hl], $64
    inc  l
    dec  d
    dec  a
    jr   nz, .loop_07_5D1B

.else_07_5D22:
    ld   a, d
    and  a
    jr   z, .else_07_5D2C

.loop_07_5D26:
    ld   [hl], $63
    inc  l
    dec  d
    jr   nz, .loop_07_5D26

.else_07_5D2C:
    ld   a, l
    ld   [$FF92], a
    ld   hl, $DEDE
    res  1, b
    ld   [hl], b
    ret


toc_07_5D36:
    ld   a, $07
    call toc_01_0675
    jr   nc, .else_07_5D43

    ld   hl, $DEEB
    ld   [hl], $00
    ret


.else_07_5D43:
    ld   de, $9C01
    ld   a, [$FF92]
    ld   l, a
    ld   h, $C4
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   [hl], $07
    inc  l
    ld   [hl], $7B
    inc  l
    ld   de, $DEDF
    ld   a, [de]
    bit  1, a
    jr   nz, .else_07_5D91

    ld   de, $DEE3
    ld   a, [de]
    inc  a
    inc  a
    ld   [de], a
    ld   d, $06
.loop_07_5D66:
    and  a
    jr   z, .else_07_5D79

    sub  a, $02
    jr   c, .else_07_5D75

    ld   [hl], $64
    inc  l
    dec  d
    jr   nz, .loop_07_5D66

    jr   .else_07_5D83

.else_07_5D75:
    dec  d
    ld   [hl], $6E
    inc  l
.else_07_5D79:
    ld   a, d
    and  a
    jr   z, .else_07_5D83

    ld   [hl], $63
    inc  l
    dec  d
    jr   nz, .else_07_5D79

.else_07_5D83:
    ld   a, l
    ld   [$FF92], a
    ld   e, $12
    cbcallNoInterrupts $1E, $4299
    ret


.else_07_5D91:
    ld   de, $DEE5
    ld   a, [de]
    inc  a
    ld   [de], a
    ld   d, $06
.loop_07_5D99:
    and  a
    jr   z, .else_07_5DA3

    ld   [hl], $64
    inc  l
    dec  a
    dec  d
    jr   nz, .loop_07_5D99

.else_07_5DA3:
    ld   a, d
    and  a
    jr   z, .else_07_5DAD

    ld   [hl], $63
    inc  l
    dec  d
    jr   nz, .else_07_5DA3

.else_07_5DAD:
    ld   a, l
    ld   [$FF92], a
    ld   e, $12
    cbcallNoInterrupts $1E, $4299
    ret


toc_07_5DBB:
    ld   a, $07
    call toc_01_0675
    ret  c

    ld   de, $9C21
    ld   a, [$FF92]
    ld   l, a
    ld   h, $C4
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   [hl], $07
    inc  l
    ld   [hl], $7A
    inc  l
    ld   de, $DEE4
    ld   a, [de]
    inc  a
    ld   [de], a
    ld   d, $06
.loop_07_5DDB:
    and  a
    jr   z, .else_07_5DEE

    sub  a, $02
    jr   c, .else_07_5DEA

    ld   [hl], $6F
    inc  l
    dec  d
    jr   nz, .loop_07_5DDB

    jr   .else_07_5DF8

.else_07_5DEA:
    dec  d
    ld   [hl], $6E
    inc  l
.else_07_5DEE:
    ld   a, d
    and  a
    jr   z, .else_07_5DF8

    ld   [hl], $6D
    inc  l
    dec  d
    jr   nz, .else_07_5DEE

.else_07_5DF8:
    ld   a, l
    ld   [$FF92], a
    ld   e, $12
    cbcallNoInterrupts $1E, $4299
    ret


toc_07_5E06:
    ld   a, $07
    call toc_01_0675
    ret  c

    ld   de, $9C09
    ld   a, [$FF92]
    ld   l, a
    ld   h, $C4
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   [hl], $07
    inc  l
    ld   de, $DEE1
    ld   a, [de]
    and  a
    jr   z, .else_07_5E4B

    ld   [hl], $68
    inc  l
    dec  a
    jr   z, .else_07_5E4E

    ld   [hl], $68
    inc  l
    dec  a
    jr   z, .else_07_5E51

    ld   [hl], $68
    inc  l
    dec  a
    jr   z, .else_07_5E54

    ld   [hl], $68
    inc  l
    dec  a
    jr   z, .else_07_5E57

    ld   [hl], $68
    inc  l
    dec  a
    jr   z, .else_07_5E5A

    ld   [hl], $68
    inc  l
    dec  a
    jr   z, .else_07_5E5D

    ld   [hl], $68
    inc  l
    jr   .toc_07_5E60

.else_07_5E4B:
    ld   [hl], $67
    inc  l
.else_07_5E4E:
    ld   [hl], $67
    inc  l
.else_07_5E51:
    ld   [hl], $67
    inc  l
.else_07_5E54:
    ld   [hl], $67
    inc  l
.else_07_5E57:
    ld   [hl], $67
    inc  l
.else_07_5E5A:
    ld   [hl], $67
    inc  l
.else_07_5E5D:
    ld   [hl], $67
    inc  l
.toc_07_5E60:
    ld   a, l
    ld   [$FF92], a
    ld   hl, $DEDE
    res  5, b
    ld   [hl], b
    ret


toc_07_5E6A:
    ld   a, $01
    call toc_01_0675
    ret  c

    ld   de, $9C2F
    ld   a, [$FF92]
    ld   l, a
    ld   h, $C4
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   [hl], $01
    inc  l
    ld   a, [$DB60]
    inc  a
    ld   e, $70
    add  a, e
    ld   [hl], a
    inc  l
    ld   a, l
    ld   [$FF92], a
    ld   hl, $DEDE
    res  6, b
    ld   [hl], b
    ret


toc_07_5E92:
    ld   a, $03
    call toc_01_0675
    ret  c

    ld   de, $9C29
    ld   a, [$FF92]
    ld   l, a
    ld   h, $C4
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   [hl], $03
    inc  l
    ld   [hl], $7C
    inc  l
    ld   de, $A084
    ld   a, [de]
    ld   d, $70
    ld   e, a
    swap a
    and  %00001111
    add  a, d
    ld   [hl], a
    inc  l
    ld   a, e
    and  %00001111
    add  a, d
    ld   [hl], a
    inc  l
    ld   a, l
    ld   [$FF92], a
    ld   hl, $DEDE
    res  2, b
    ld   [hl], b
    ret


toc_07_5EC8:
    ld   a, $40
    call toc_01_0675
    ret  c

    push bc
    ld   de, $9690
    ld   a, [$FF92]
    ld   c, a
    ld   b, $C4
    ld   a, e
    ld   [bc], a
    inc  c
    ld   a, d
    ld   [bc], a
    inc  c
    ld   a, $40
    ld   [bc], a
    inc  c
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
    __changebank $07
    ld   de, $57DC
    add  hl, de
    ld   d, $40
.loop_07_5F02:
    ldi  a, [hl]
    ld   [bc], a
    inc  c
    dec  d
    jr   nz, .loop_07_5F02

    ld   a, c
    ld   [$FF92], a
    pop  bc
    ld   hl, $DEDE
    res  3, b
    ld   [hl], b
    ret


toc_07_5F13:
    ld   a, $07
    call toc_01_0675
    ret  c

    ld   de, $9C21
    ld   a, [$FF92]
    ld   l, a
    ld   h, $C4
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   [hl], $07
    inc  l
    ld   [hl], $7A
    inc  l
    call toc_07_5C39
    ld   d, $06
.loop_07_5F30:
    and  a
    jr   z, .else_07_5F43

    sub  a, $02
    jr   c, .else_07_5F3F

    ld   [hl], $6F
    inc  l
    dec  d
    jr   nz, .loop_07_5F30

    jr   .else_07_5F4D

.else_07_5F3F:
    dec  d
    ld   [hl], $6E
    inc  l
.else_07_5F43:
    ld   a, d
    and  a
    jr   z, .else_07_5F4D

    ld   [hl], $6D
    inc  l
    dec  d
    jr   nz, .else_07_5F43

.else_07_5F4D:
    ld   a, l
    ld   [$FF92], a
    ld   hl, $DEDE
    res  4, b
    ld   [hl], b
    ret


    db   $21, $EA, $DE, $36, $04, $3E, $07, $CD
    db   $75, $06, $D8, $11, $09, $9C, $F0, $92
    db   $6F, $26, $C4, $73, $2C, $72, $2C, $36
    db   $07, $2C, $36, $68, $2C, $36, $68, $2C
    db   $36, $68, $2C, $36, $68, $2C, $36, $68
    db   $2C, $36, $68, $2C, $36, $68, $2C, $7D
    db   $E0, $92, $21, $E9, $DE, $36, $14, $21
    db   $E6, $DE, $36, $9A, $23, $36, $5F, $23
    db   $36, $07, $C9, $3E, $07, $CD, $75, $06
    db   $D8, $11, $09, $9C, $F0, $92, $6F, $26
    db   $C4, $73, $2C, $72, $2C, $36, $07, $2C
    db   $36, $67, $2C, $36, $67, $2C, $36, $67
    db   $2C, $36, $67, $2C, $36, $67, $2C, $36
    db   $67, $2C, $36, $67, $2C, $7D, $E0, $92
    db   $21, $EA, $DE, $7E, $A7, $CA, $E2, $5F
    db   $3D, $77, $21, $E9, $DE, $36, $0A, $21
    db   $E6, $DE, $36, $5C, $23, $36, $5F, $23
    db   $36, $07, $C9, $21, $DE, $DE, $CB, $BE
    db   $AF, $21, $E9, $DE, $22, $77, $C9

toc_07_5FEE:
    ld   hl, $DF00
    ld   a, $3E
    ldi  [hl], a
    ld   [hl], $06
    plotFromTo $6107, $8000
    memcpyFromTo gbVRAM, $9000, $0800
    plotFromTo $697D, $9800
    ld   a, $0B
    ld   hl, $68A0
    ld   de, $8000
    call toc_01_060D
    ld   a, $09
    ld   hl, $4000
    ld   de, $8100
    ld   bc, $0280
    call toc_01_05BF
    ld   a, $09
    ld   hl, $4280
    ld   de, $8380
    ld   bc, $0220
    call toc_01_05BF
    cbcallNoInterrupts $08, $4000
    ld   a, $F8
    ld   hl, $A0B3
    call toc_01_07C4
    clear [$DF02]
    ld   hl, $CD09
    ld   a, $E4
    ldi  [hl], a
    ld   a, $D0
    ldi  [hl], a
    ld   a, $E4
    ld   [hl], a
    ld   e, $FF
    cbcallNoInterrupts $1E, $4299
    ld   e, $06
    cbcallNoInterrupts $1F, $4232
    call toc_01_1584
    assign [gbLCDC], LCDCF_BG_DISPLAY | LCDCF_OBJ_16_16 | LCDCF_OBJ_DISPLAY | LCDCF_TILEMAP_9C00
    call toc_01_046D
    ld   e, $08
    cbcallNoInterrupts $1E, $6011
    ld   de, $0004
    cbcallNoInterrupts $1A, $4246
    ld   e, $06
    cbcallNoInterrupts $1E, $606D
    ld   a, $20
.loop_07_609A:
    push af
    call toc_01_0496
    cbcallNoInterrupts $00, $086B
    call toc_01_04AE
    call toc_01_0343
    call toc_01_0357
    pop  af
    dec  a
    jr   nz, .loop_07_609A

.loop_07_60B3:
    call toc_01_0496
    cbcallNoInterrupts $00, $086B
    call toc_01_0647
    call toc_01_04AE
    call toc_01_0343
    call toc_01_0357
    ld   a, [$DF02]
    or   a
    jr   nz, .else_07_60E8

    ld   hl, $DF00
    ld   a, [hl]
    sub  a, $01
    ldi  [hl], a
    ld   a, [hl]
    sbc  $00
    ldd  [hl], a
    or   [hl]
    jr   nz, .loop_07_60B3

    cbcallNoInterrupts $08, $5E92
    jr   .toc_07_60EF

.else_07_60E8:
    clear [$DEFF]
    jp   toc_01_0437

.toc_07_60EF:
    ld   e, $00
    cbcallNoInterrupts $1E, $606D
    ld   de, $0004
    cbcallNoInterrupts $1A, $427B
    jp   toc_01_0437

    db   $32, $00, $41, $38, $00, $02, $F9, $00
    db   $39, $41, $00, $3B, $24, $00, $0A, $F8
    db   $00, $D8, $00, $DC, $00, $8C, $00, $FE
    db   $00, $8E, $23, $00, $44, $00, $E0, $01
    db   $00, $FC, $24, $00, $41, $C0, $00, $00
    db   $C3, $41, $00, $C6, $01, $00, $F3, $24
    db   $00, $41, $0C, $00, $00, $EF, $41, $00
    db   $6C, $01, $00, $EF, $28, $00, $03, $8F
    db   $00, $D9, $00, $CB, $00, $69, $06, $36
    db   $00, $B8, $00, $B0, $00, $30, $28, $00
    db   $00, $7D, $41, $00, $CC, $01, $00, $7C
    db   $88, $00, $3E, $00, $E7, $84, $00, $88
    db   $00, $C7, $28, $00, $00, $9B, $C4, $00
    db   $28, $00, $98, $AA, $00, $6E, $06, $6C
    db   $00, $39, $00, $19, $00, $31, $A4, $00
    db   $50, $83, $00, $75, $00, $37, $41, $00
    db   $B6, $CA, $00, $A6, $04, $EC, $00, $6C
    db   $00, $67, $28, $00, $00, $80, $C5, $00
    db   $80, $AE, $00, $2E, $00, $07, $A3, $00
    db   $3E, $45, $00, $03, $24, $00, $0A, $1B
    db   $00, $98, $00, $DB, $00, $7B, $00, $3B
    db   $00, $1B, $88, $00, $B0, $00, $7E, $42
    db   $00, $66, $24, $00, $0A, $60, $00, $F3
    db   $00, $66, $00, $67, $00, $66, $00, $63
    db   $26, $00, $08, $CD, $00, $6F, $00, $EC
    db   $00, $0C, $00, $CC, $A6, $00, $E2, $85
    db   $00, $67, $00, $D9, $A6, $00, $4C, $02
    db   $80, $00, $9E, $42, $00, $B3, $01, $00
    db   $9E, $86, $00, $FE, $03, $06, $00, $05
    db   $00, $C9, $01, $77, $02, $CF, $00, $27
    db   $41, $00, $E7, $01, $00, $27, $86, $00
    db   $9C, $00, $3E, $41, $00, $77, $05, $00
    db   $3F, $00, $07, $00, $06, $24, $00, $04
    db   $7F, $00, $70, $00, $7E, $84, $00, $F2
    db   $00, $7E, $C4, $00, $41, $00, $FC, $23
    db   $EE, $02, $FC, $FC, $E0, $A5, $00, $FD
    db   $00, $00, $27, $EE, $00, $7C, $85, $00
    db   $8D, $0A, $00, $7E, $7E, $F0, $F0, $7C
    db   $7C, $1E, $1E, $FC, $FC, $89, $01, $BC
    db   $00, $FE, $CA, $01, $E6, $01, $FE, $FE
    db   $27, $38, $CB, $01, $D1, $01, $FE, $FE
    db   $C3, $01, $E3, $8B, $01, $AE, $01, $EE
    db   $EE, $31, $00, $00, $01, $CA, $02, $2E
    db   $01, $60, $60, $41, $F0, $90, $01, $01
    db   $01, $CD, $02, $2F, $22, $1C, $02, $14
    db   $1C, $1C, $35, $00, $03, $0F, $0F, $00
    db   $3F, $29, $00, $05, $07, $07, $0C, $0F
    db   $88, $8F, $AB, $02, $24, $05, $40, $C0
    db   $20, $E0, $00, $00, $8D, $02, $70, $29
    db   $00, $00, $FF, $41, $FF, $00, $00, $FF
    db   $89, $02, $26, $05, $82, $83, $67, $E6
    db   $16, $F7, $C5, $02, $3B, $09, $FC, $FC
    db   $03, $FF, $00, $FF, $55, $AA, $AA, $55
    db   $A9, $02, $72, $05, $18, $F8, $54, $AC
    db   $AD, $55, $AD, $02, $60, $01, $98, $F8
    db   $83, $02, $2C, $2B, $03, $83, $02, $EC
    db   $03, $A8, $58, $58, $A8, $41, $F8, $08
    db   $03, $FC, $04, $FC, $84, $89, $02, $47
    db   $01, $0C, $13, $41, $07, $08, $A5, $00
    db   $4E, $03, $20, $50, $60, $90, $41, $E0
    db   $10, $01, $F0, $0C, $A6, $00, $E4, $00
    db   $00, $22, $70, $00, $50, $C3, $03, $39
    db   $0B, $34, $CF, $FD, $02, $7A, $85, $49
    db   $B6, $4B, $B4, $33, $FC, $41, $3F, $30
    db   $07, $58, $DF, $55, $DA, $FA, $75, $7F
    db   $F0, $42, $FF, $60, $0B, $FF, $40, $21
    db   $E1, $62, $A3, $C6, $45, $CD, $4E, $CF
    db   $4C, $41, $8F, $8C, $0B, $8F, $8E, $DD
    db   $DA, $3A, $FD, $BF, $5C, $5F, $BF, $F7
    db   $17, $41, $F3, $13, $01, $FB, $0B, $C6
    db   $02, $CF, $00, $06, $41, $FF, $07, $0B
    db   $FD, $05, $FF, $06, $57, $B6, $AF, $5F
    db   $FB, $0B, $F9, $09, $41, $F8, $08, $41
    db   $F0, $10, $03, $FF, $00, $FF, $01, $43
    db   $FF, $C1, $07, $FF, $C0, $FF, $80, $FF
    db   $03, $FF, $83, $41, $FF, $C3, $03, $7F
    db   $43, $FF, $83, $41, $FD, $05, $1F, $08
    db   $F8, $AC, $54, $55, $AD, $FD, $05, $FF
    db   $07, $FF, $83, $FF, $82, $FF, $80, $3F
    db   $3F, $C7, $FF, $EB, $D7, $D7, $AB, $FE
    db   $82, $FC, $04, $FD, $05, $F9, $09, $42
    db   $FC, $84, $08, $F8, $C8, $FF, $FF, $E0
    db   $FF, $AA, $D5, $D5, $AA, $02, $DF, $05
    db   $C0, $C0, $A0, $67, $51, $B2, $83, $00
    db   $C0, $41, $10, $28, $07, $18, $24, $3C
    db   $C3, $FF, $00, $FE, $01, $41, $03, $04
    db   $05, $07, $08, $0E, $11, $08, $16, $C5
    db   $00, $14, $05, $F8, $06, $FE, $01, $E0
    db   $1E, $41, $60, $90, $41, $20, $50, $03
    db   $00, $20, $0C, $0C, $41, $1E, $12, $00
    db   $0C, $A7, $00, $7D, $02, $C0, $3F, $38
    db   $43, $1F, $18, $01, $1F, $1C, $41, $0F
    db   $0C, $42, $FF, $01, $03, $FE, $02, $FF
    db   $01, $42, $FF, $00, $44, $07, $06, $05
    db   $87, $87, $C3, $43, $E3, $23, $44, $FB
    db   $0B, $42, $FF, $07, $43, $FF, $00, $41
    db   $FF, $04, $41, $FF, $06, $42, $E1, $21
    db   $41, $F1, $11, $01, $F9, $09, $84, $04
    db   $78, $00, $80, $A7, $03, $A2, $42, $FE
    db   $02, $05, $F9, $09, $FD, $05, $FC, $84
    db   $43, $FE, $C2, $03, $FF, $C3, $FF, $80
    db   $43, $FF, $C0, $07, $FF, $C1, $FF, $81
    db   $FE, $82, $F1, $11, $41, $E3, $23, $03
    db   $C3, $43, $83, $83, $25, $03, $84, $02
    db   $AB, $04, $06, $FF, $0E, $FF, $0F, $83
    db   $03, $8A, $03, $FE, $82, $F0, $11, $42
    db   $F8, $08, $09, $F0, $10, $E0, $E0, $C0
    db   $C0, $01, $01, $7E, $81, $41, $3E, $41
    db   $05, $33, $4C, $20, $53, $00, $60, $AD
    db   $02, $2C, $05, $0C, $0C, $1F, $13, $1F
    db   $12, $A7, $02, $85, $83, $03, $32, $09
    db   $C0, $C0, $E0, $20, $40, $A0, $60, $9C
    db   $78, $84, $41, $F0, $08, $05, $78, $84
    db   $40, $BC, $00, $C0, $41, $0F, $0C, $01
    db   $0F, $0E, $88, $04, $60, $83, $04, $7F
    db   $04, $10, $FF, $08, $FF, $0C, $83, $04
    db   $E6, $05, $FB, $0B, $FD, $05, $F3, $13
    db   $84, $04, $78, $00, $03, $84, $04, $50
    db   $02, $81, $D5, $C1, $86, $04, $7A, $84
    db   $04, $A5, $03, $AB, $83, $D4, $C4, $85
    db   $03, $88, $09, $FD, $05, $54, $04, $A8
    db   $88, $F0, $F0, $E0, $E0, $84, $05, $64
    db   $0B, $83, $FF, $83, $D7, $C3, $EC, $E4
    db   $78, $78, $30, $30, $FF, $84, $04, $DF
    db   $05, $AA, $80, $FD, $FC, $FF, $FF, $A3
    db   $01, $BA, $85, $03, $BA, $09, $AB, $0B
    db   $7B, $3B, $E3, $E3, $83, $83, $01, $01
    db   $42, $FE, $82, $41, $FC, $04, $85, $05
    db   $88, $07, $1D, $1D, $3F, $23, $7E, $42
    db   $7F, $41, $84, $03, $AA, $04, $E0, $7F
    db   $60, $FE, $82, $A6, $04, $A4, $02, $41
    db   $FF, $81, $83, $04, $54, $03, $03, $02
    db   $03, $02, $8B, $02, $2E, $A5, $05, $F0
    db   $A9, $02, $50, $01, $0F, $0C, $42, $0F
    db   $08, $03, $E7, $E4, $E3, $A3, $83, $01
    db   $BA, $43, $F0, $10, $03, $E0, $20, $C0
    db   $C0, $91, $02, $1E, $01, $0E, $0F, $CB
    db   $02, $FB, $83, $02, $D8, $89, $05, $C6
    db   $0B, $EF, $EF, $10, $1F, $20, $3F, $EB
    db   $E3, $7C, $7C, $38, $38, $A7, $02, $76
    db   $03, $10, $F0, $F8, $F8, $C5, $02, $ED
    db   $06, $38, $38, $44, $7C, $C4, $FC, $C4
    db   $86, $01, $DB, $03, $0E, $0E, $19, $1F
    db   $41, $31, $3F, $01, $71, $7F, $87, $02
    db   $4A, $01, $26, $3E, $41, $62, $7E, $03
    db   $E2, $FE, $00, $00, $8D, $02, $F0, $84
    db   $02, $EA, $44, $F8, $08, $00, $F8, $C9
    db   $02, $D9, $0D, $1E, $1E, $33, $3F, $21
    db   $3F, $7F, $70, $3A, $38, $1F, $1E, $0F
    db   $0F, $A5, $06, $2A, $07, $1E, $1E, $FE
    db   $02, $AC, $04, $58, $18, $83, $05, $8C
    db   $05, $00, $00, $3C, $3C, $66, $7E, $A9
    db   $02, $86, $41, $08, $0F, $01, $18, $1F
    db   $85, $02, $76, $03, $38, $3F, $40, $7F
    db   $42, $80, $FF, $85, $02, $D4, $01, $1D
    db   $FD, $85, $04, $DF, $02, $40, $FF, $30
    db   $84, $07, $07, $41, $81, $FF, $00, $C0
    db   $41, $FF, $70, $00, $FF, $A3, $06, $5C
    db   $01, $04, $FC, $C7, $03, $E5, $04, $0B
    db   $FB, $60, $7F, $60, $42, $7F, $61, $00
    db   $7F, $A5, $04, $59, $05, $10, $F0, $31
    db   $F1, $E1, $E1, $23, $C1, $00, $63, $41
    db   $E3, $23, $00, $E3, $43, $82, $FE, $42
    db   $01, $FF, $04, $11, $FF, $71, $7F, $70
    db   $44, $7F, $60, $06, $7F, $62, $7F, $E2
    db   $FE, $C2, $FE, $C3, $03, $A7, $87, $07
    db   $68, $01, $02, $03, $43, $06, $07, $01
    db   $04, $07, $41, $0C, $0F, $44, $10, $F0
    db   $01, $20, $E0, $41, $21, $E1, $41, $61
    db   $7F, $02, $41, $7F, $C1, $A6, $05, $66
    db   $05, $88, $FF, $32, $3E, $21, $3F, $C3
    db   $07, $44, $43, $E0, $FF, $01, $42, $7E
    db   $43, $C2, $FE, $05, $42, $FE, $43, $FF
    db   $03, $FF, $A7, $01, $FC, $A7, $07, $66
    db   $C3, $04, $43, $06, $3C, $3F, $3E, $3F
    db   $DF, $DF, $3F, $84, $07, $2F, $0C, $C0
    db   $FF, $F8, $FF, $FC, $FF, $1C, $1F, $0C
    db   $0F, $0E, $0F, $06, $22, $07, $09, $70
    db   $FF, $78, $FF, $38, $FF, $3C, $FF, $2C
    db   $EF, $41, $14, $F7, $04, $0C, $FF, $30
    db   $FF, $38, $42, $FF, $18, $42, $FF, $1C
    db   $86, $05, $64, $02, $40, $FF, $60, $84
    db   $08, $1F, $0C, $3D, $FE, $80, $FF, $E1
    db   $FF, $61, $7F, $E1, $FF, $61, $FF, $21
    db   $A3, $04, $8A, $06, $BF, $4E, $CF, $D0
    db   $DF, $A0, $BF, $C3, $07, $74, $06, $FC
    db   $FF, $1C, $FF, $0C, $FF, $10, $88, $04
    db   $80, $00, $10, $A4, $08, $29, $00, $E2
    db   $41, $FF, $C2, $0D, $FF, $C3, $FF, $43
    db   $FF, $6B, $D7, $74, $EC, $78, $F8, $11
    db   $FF, $10, $A4, $05, $54, $0D, $F0, $FF
    db   $BA, $B5, $3D, $3B, $1E, $1E, $0C, $0F
    db   $8C, $8F, $88, $8F, $42, $98, $9F, $07
    db   $10, $1F, $30, $3F, $27, $E7, $28, $EF
    db   $41, $50, $DF, $08, $58, $DF, $4E, $CF
    db   $3C, $FF, $06, $FF, $08, $8C, $08, $61
    db   $03, $B8, $7F, $E0, $FF, $41, $B0, $BF
    db   $44, $70, $FF, $01, $01, $FF, $A5, $07
    db   $24, $41, $C1, $FF, $07, $E1, $FF, $F5
    db   $EB, $C0, $FF, $E1, $FF, $42, $61, $7F
    db   $01, $41, $7F, $41, $C2, $FE, $02, $04
    db   $FC, $82, $86, $04, $B6, $41, $C3, $FF
    db   $01, $82, $FF, $87, $06, $42, $87, $02
    db   $40, $02, $0C, $FF, $08, $A6, $07, $87
    db   $07, $C0, $FF, $EB, $D5, $F6, $EE, $1C
    db   $FF, $41, $26, $E7, $05, $47, $C6, $47
    db   $C7, $81, $81, $23, $00, $09, $2E, $EF
    db   $17, $F7, $B3, $53, $50, $B0, $E0, $E0
    db   $85, $06, $2A, $06, $EA, $75, $F5, $FA
    db   $7F, $7F, $3F, $88, $02, $6F, $07, $AE
    db   $5D, $5F, $BE, $E7, $E7, $C3, $C3, $87
    db   $02, $74, $07, $BD, $7A, $5E, $DD, $8F
    db   $8F, $06, $06, $27, $00, $01, $70, $F0
    db   $AD, $02, $42, $01, $0C, $0C, $2D, $00
    db   $07, $30, $3F, $3D, $3A, $3F, $3F, $1F
    db   $1F, $A7, $06, $C4, $07, $03, $FE, $57
    db   $AB, $A7, $DF, $FC, $FC, $C7, $02, $ED
    db   $05, $5D, $DA, $DE, $DD, $8F, $8F, $A9
    db   $06, $C0, $05, $75, $FA, $FB, $FD, $9F
    db   $9F, $C7, $06, $87, $07, $00, $00, $BB
    db   $B7, $BF, $BF, $1D, $1D, $89, $09, $06
    db   $01, $C2, $FE, $A5, $07, $86, $08, $D5
    db   $AA, $EA, $D5, $FF, $FF, $7E, $7E, $82
    db   $84, $04, $88, $04, $08, $FF, $70, $BF
    db   $E0, $84, $04, $C2, $03, $7C, $7C, $70
    db   $70, $91, $06, $2D, $01, $07, $08, $42
    db   $03, $04, $01, $06, $09, $83, $02, $89
    db   $0D, $80, $40, $C0, $38, $F0, $08, $C0
    db   $30, $C0, $22, $42, $AD, $07, $05, $CC
    db   $02, $9D, $00, $80, $2D, $00, $01, $0E
    db   $0E, $C3, $09, $0D, $89, $09, $06, $03
    db   $00, $00, $FC, $84, $42, $FE, $02, $07
    db   $FE, $06, $FF, $89, $7F, $79, $06, $06
    db   $A6, $0A, $20, $08, $04, $07, $38, $1F
    db   $20, $07, $18, $03, $0C, $85, $02, $87
    db   $03, $80, $78, $F0, $08, $42, $E0, $10
    db   $85, $02, $F2, $03, $3F, $3F, $7F, $67
    db   $41, $7E, $42, $01, $7E, $66, $85, $09
    db   $16, $00, $FC, $24, $FF, $01, $3F, $3F
    db   $AC, $06, $2A, $00, $C0, $84, $00, $E6
    db   $AE, $0A, $03, $07, $4F, $B0, $07, $68
    db   $05, $0A, $00, $05, $88, $00, $DF, $02
    db   $40, $00, $80, $8F, $0A, $3E, $22, $03
    db   $00, $02, $87, $0A, $AE, $A3, $03, $3A
    db   $AB, $0A, $54, $41, $03, $04, $02, $02
    db   $05, $00, $88, $09, $67, $05, $F0, $08
    db   $10, $E8, $00, $18, $95, $0A, $EA, $23
    db   $00, $01, $BC, $BC, $A4, $02, $40, $D1
    db   $0A, $F3, $0E, $80, $00, $18, $18, $66
    db   $7E, $81, $0F, $0F, $7A, $75, $D5, $AA
    db   $88, $77, $43, $00, $FF, $0A, $FF, $00
    db   $FF, $E0, $5F, $B8, $8F, $74, $03, $FE
    db   $03, $84, $07, $67, $86, $0A, $E0, $84
    db   $0A, $21, $A3, $0B, $14, $01, $08, $0F
    db   $83, $06, $5C, $02, $60, $7F, $C0, $A6
    db   $04, $58, $02, $02, $FE, $04, $C4, $03
    db   $0E, $83, $07, $A8, $C3, $06, $03, $43
    db   $00, $FF, $02, $E0, $FF, $FE, $22, $FF
    db   $00, $FF, $45, $FF, $00, $C3, $03, $EB
    db   $02, $FF, $80, $80, $44, $40, $C0, $83
    db   $05, $0E, $07, $3C, $C3, $3C, $42, $24
    db   $5A, $00, $76, $A8, $0A, $B4, $25, $00
    db   $07, $08, $08, $14, $0C, $12, $1E, $21
    db   $3F, $8D, $06, $2B, $02, $F0, $C0, $20
    db   $41, $00, $FF, $0B, $0E, $FF, $7F, $FF
    db   $E7, $E7, $86, $87, $06, $07, $0C, $0F
    db   $45, $01, $FF, $41, $02, $FE, $C5, $04
    db   $5B, $03, $04, $FC, $0C, $FC, $85, $04
    db   $7F, $89, $05, $0E, $05, $80, $80, $78
    db   $F8, $07, $FF, $CF, $02, $6D, $03, $FE
    db   $FE, $78, $78, $2B, $00, $FF, $E4, $29
    db   $00, $00, $23, $37, $00, $6B, $25, $31
    db   $00, $6F, $31, $00, $AB, $2E, $00, $6F
    db   $41, $00, $B5, $2E, $00, $6F, $51, $62
    db   $BE, $2C, $00, $6D, $61, $01, $00, $6F
    db   $62, $B6, $2B, $00, $00, $22, $6F, $70
    db   $01, $C1, $C2, $2C, $00, $00, $24, $6F
    db   $80, $01, $B9, $BA, $2D, $00, $6F, $90
    db   $00, $C3, $AF, $00, $2A, $01, $A0, $00
    db   $62, $A1, $00, $00, $64, $A4, $03, $00
    db   $00, $A9, $AA, $62, $BB, $2F, $00, $64
    db   $AC, $09, $00, $00, $B1, $B2, $00, $B3
    db   $B4, $00, $C5, $C6, $E4, $31, $00, $63
    db   $1B, $01, $00, $1D, $62, $1F, $00, $1F
    db   $E4, $30, $00, $62, $17, $02, $19, $1A
    db   $0F, $6D, $01, $94, $01, $D0, $66, $10
    db   $E4, $2F, $00, $FF, $21, $6A, $2A, $6A
    db   $33, $6A, $3C, $6A, $45, $6A, $4E, $6A
    db   $53, $6A, $5C, $6A, $65, $6A, $6E, $6A
    db   $77, $6A, $80, $6A, $89, $6A, $92, $6A
    db   $9B, $6A, $A4, $6A, $AD, $6A, $B6, $6A
    db   $BF, $6A, $02, $F8, $00, $30, $00, $F8
    db   $F8, $46, $01, $02, $F8, $00, $12, $00
    db   $F8, $F8, $4C, $01, $02, $F8, $00, $32
    db   $00, $F8, $F8, $4A, $01, $02, $F8, $00
    db   $10, $00, $F8, $F8, $48, $01, $02, $F8
    db   $00, $0A, $00, $F8, $F8, $08, $01, $01
    db   $F8, $00, $16, $01, $02, $F8, $00, $04
    db   $20, $F8, $F8, $0C, $21, $02, $F8, $00
    db   $2E, $00, $F8, $F8, $28, $01, $02, $F8
    db   $00, $36, $00, $F8, $F8, $34, $01, $02
    db   $F8, $00, $0E, $00, $F8, $F8, $06, $01
    db   $02, $F8, $00, $02, $00, $F8, $F8, $00
    db   $01, $02, $F8, $F8, $12, $20, $F8, $00
    db   $4C, $21, $02, $F8, $F8, $32, $20, $F8
    db   $00, $4A, $21, $02, $F8, $F8, $10, $20
    db   $F8, $00, $48, $21, $02, $F8, $F8, $30
    db   $20, $F8, $00, $46, $21, $02, $F8, $F8
    db   $0E, $20, $F8, $00, $06, $21, $02, $F8
    db   $F8, $02, $20, $F8, $00, $00, $21, $02
    db   $F8, $F8, $0A, $20, $F8, $00, $08, $21
    db   $02, $F8, $F8, $04, $00, $F8, $00, $0C
    db   $01, $04, $68, $59, $0A, $03, $0B, $6B
    db   $47, $0F, $3A, $00, $19, $00, $06, $19
    db   $01, $04, $01, $02, $0F, $39, $01, $0F
    db   $3A, $01, $0D, $AF, $0F, $07, $10, $04
    db   $05, $06, $0D, $00, $6B, $06, $E1, $6A
    db   $03, $0B, $6B, $47, $0F, $3A, $00, $19
    db   $01, $04, $19, $00, $06, $1B, $0A, $40
    db   $02, $1E, $39, $1A, $3C, $FE, $03, $38
    db   $01, $AF, $12, $C9, $21, $A8, $7E, $3E
    db   $02, $CD, $CF, $05, $CD, $8B, $37, $CD
    db   $A8, $37, $1E, $3A, $1A, $B7, $28, $0E
    db   $F0, $A5, $E6, $02, $20, $08, $1E, $07
    db   $01, $EF, $6A, $C3, $F4, $37, $C3, $F7
    db   $37, $03, $5D, $6B, $47, $0F, $3A, $00
    db   $04, $36, $5D, $0A, $24, $4D, $19, $00
    db   $06, $19, $01, $03, $19, $00, $03, $19
    db   $01, $08, $0F, $3A, $01, $19, $01, $16
    db   $03, $5D, $6B, $47, $0F, $3A, $00, $19
    db   $00, $05, $1B, $0A, $40, $02, $21, $A8
    db   $7E, $3E, $02, $CD, $CF, $05, $CD, $8B
    db   $37, $CD, $A8, $37, $1E, $15, $1A, $FE
    db   $01, $20, $0B, $3E, $08, $21, $94, $6B
    db   $CD, $AA, $3A, $CD, $E4, $3A, $1E, $3A
    db   $1A, $B7, $28, $0E, $F0, $A5, $E6, $02
    db   $20, $08, $1E, $07, $01, $4F, $6B, $C3
    db   $F4, $37, $C3, $F7, $37, $03, $F4, $00
    db   $0E, $09, $03, $C8, $6B, $47, $04, $74
    db   $5D, $0A, $0F, $39, $00, $09, $08, $24
    db   $1D, $0D, $AF, $0F, $0D, $0A, $05, $19
    db   $00, $02, $0D, $AF, $0F, $0D, $0A, $05
    db   $19, $01, $02, $0D, $C2, $6B, $0A, $1B
    db   $0A, $40, $02, $1E, $39, $1A, $3C, $12
    db   $C9, $21, $A8, $7E, $3E, $02, $CD, $CF
    db   $05, $CD, $8B, $37, $CD, $A8, $37, $C3
    db   $F7, $37, $03, $14, $6C, $47, $0F, $3A
    db   $0F, $0F, $39, $02, $04, $B8, $5D, $0A
    db   $24, $44, $19, $00, $06, $01, $01, $0D
    db   $77, $0F, $0B, $0D, $FA, $6B, $05, $02
    db   $06, $EE, $6B, $1E, $39, $1A, $3C, $FE
    db   $0B, $38, $02, $3E, $02, $12, $C9, $03
    db   $14, $6C, $47, $0F, $3A, $00, $19, $00
    db   $06, $1B, $0A, $40, $02, $21, $A8, $7E
    db   $3E, $02, $CD, $CF, $05, $CD, $8B, $37
    db   $CD, $A8, $37, $1E, $15, $1A, $FE, $01
    db   $20, $0B, $3E, $02, $21, $52, $6C, $CD
    db   $AA, $3A, $CD, $E4, $3A, $1E, $3A, $1A
    db   $3D, $20, $14, $FA, $70, $A0, $B7, $20
    db   $06, $F0, $A5, $E6, $02, $20, $09, $1E
    db   $07, $01, $06, $6C, $C3, $F4, $37, $12
    db   $C3, $F7, $37, $05, $00, $00, $12, $13
    db   $04, $1A, $61, $0A, $03, $77, $6C, $47
    db   $19, $00, $04, $19, $01, $04, $0D, $AF
    db   $0F, $08, $10, $00, $24, $1E, $19, $02
    db   $08, $19, $00, $04, $1B, $10, $53, $02
    db   $21, $E2, $7E, $3E, $02, $CD, $CF, $05
    db   $CD, $88, $6C, $CD, $A8, $37, $C3, $F7
    db   $37, $CD, $8B, $37, $D0, $1E, $3F, $AF
    db   $12, $37, $C9, $03, $A6, $6C, $47, $0F
    db   $3A, $00, $19, $02, $04, $19, $01, $04
    db   $19, $00, $04, $1B, $10, $53, $02, $21
    db   $E2, $7E, $3E, $02, $CD, $CF, $05, $21
    db   $1E, $58, $3E, $02, $CD, $CF, $05, $CD
    db   $65, $37, $30, $08, $1E, $02, $01, $A3
    db   $60, $C3, $F4, $37, $CD, $7C, $37, $30
    db   $08, $1E, $02, $01, $9E, $61, $C3, $F4
    db   $37, $C3, $F7, $37, $04, $C2, $62, $0A
    db   $03, $77, $6C, $47, $19, $00, $04, $19
    db   $01, $04, $24, $55, $0D, $AF, $0F, $0B
    db   $10, $00, $19, $02, $0A, $19, $00, $04
    db   $1B, $10, $53, $02, $03, $20, $6D, $47
    db   $0F, $3A, $00, $04, $4D, $63, $0A, $24
    db   $4D, $19, $00, $04, $19, $01, $02, $19
    db   $00, $02, $19, $01, $08, $0F, $3A, $01
    db   $19, $01, $16, $03, $20, $6D, $47, $0F
    db   $3A, $00, $19, $00, $04, $1B, $10, $53
    db   $02, $21, $E2, $7E, $3E, $02, $CD, $CF
    db   $05, $CD, $88, $6C, $CD, $A8, $37, $1E
    db   $15, $1A, $FE, $01, $20, $0B, $3E, $06
    db   $21, $57, $6D, $CD, $AA, $3A, $CD, $E4
    db   $3A, $1E, $3A, $1A, $B7, $28, $0E, $F0
    db   $A5, $E6, $02, $20, $08, $1E, $07, $01
    db   $12, $6D, $C3, $F4, $37, $C3, $F7, $37
    db   $03, $00, $00, $0C, $0D, $03, $8D, $6D
    db   $47, $0F, $3A, $00, $0D, $AF, $0F, $0E
    db   $10, $00, $0D, $73, $6D, $19, $01, $04
    db   $1B, $10, $53, $02, $FA, $76, $DB, $B7
    db   $C8, $FA, $36, $DA, $B7, $C0, $21, $78
    db   $DB, $2A, $EA, $00, $CD, $2A, $EA, $01
    db   $CD, $7E, $EA, $02, $CD, $C9, $21, $E2
    db   $7E, $3E, $02, $CD, $CF, $05, $CD, $65
    db   $37, $30, $08, $1E, $02, $01, $A3, $60
    db   $C3, $F4, $37, $CD, $7C, $37, $30, $08
    db   $1E, $02, $01, $9E, $61, $C3, $F4, $37
    db   $C3, $F7, $37, $04, $0C, $6A, $0A, $03
    db   $DE, $6D, $47, $24, $3F, $19, $00, $04
    db   $19, $01, $04, $0D, $AF, $0F, $0C, $10
    db   $FD, $0D, $AF, $0F, $14, $10, $F6, $0D
    db   $AF, $0F, $15, $10, $04, $19, $02, $0A
    db   $19, $01, $04, $1B, $40, $67, $02, $21
    db   $1C, $7F, $3E, $02, $CD, $CF, $05, $CD
    db   $8B, $37, $CD, $A8, $37, $C3, $F7, $37
    db   $03, $13, $6E, $47, $04, $29, $65, $0A
    db   $19, $00, $06, $24, $4D, $04, $B5, $6A
    db   $0A, $19, $07, $06, $19, $06, $02, $19
    db   $07, $02, $0F, $3E, $1E, $19, $00, $08
    db   $1B, $40, $67, $02, $21, $1C, $7F, $3E
    db   $02, $CD, $CF, $05, $21, $18, $6D, $3E
    db   $02, $CD, $CF, $05, $CD, $8B, $37, $CD
    db   $A8, $37, $C3, $F7, $37, $0F, $3E, $00
    db   $03, $13, $6E, $47, $04, $B5, $6A, $0A
    db   $19, $07, $06, $04, $29, $65, $0A, $19
    db   $00, $06, $1B, $40, $67, $02, $03, $80
    db   $6E, $47, $0F, $39, $0A, $22, $69, $6E
    db   $07, $04, $ED, $6B, $0A, $19, $00, $02
    db   $19, $01, $02, $19, $04, $02, $19, $05
    db   $02, $19, $02, $02, $19, $03, $02, $06
    db   $54, $6E, $24, $1D, $0D, $AF, $0F, $0F
    db   $03, $10, $05, $04, $24, $1D, $0D, $AF
    db   $0F, $10, $03, $10, $05, $04, $06, $69
    db   $6E, $21, $1C, $7F, $3E, $02, $CD, $CF
    db   $05, $3E, $03, $21, $A9, $6E, $CD, $AA
    db   $3A, $CD, $E4, $3A, $CD, $8B, $37, $CD
    db   $A8, $37, $CD, $AE, $6E, $30, $08, $1E
    db   $02, $01, $40, $67, $C3, $F4, $37, $C3
    db   $F7, $37, $03, $04, $08, $08, $08, $1E
    db   $39, $1A, $B7, $28, $04, $3D, $12, $A7
    db   $C9, $F0, $A5, $E6, $02, $20, $F8, $37
    db   $C9, $10, $50, $0E, $01, $C7, $6E, $16
    db   $04, $46, $72, $0B, $01, $01, $0F, $4A
    db   $01, $0F, $4B, $00, $1B, $9B, $4D, $03
    db   $0F, $47, $00, $10, $71, $0E, $04, $E6
    db   $6E, $8F, $70, $AF, $71, $C0, $72, $0F
    db   $51, $02, $10, $5B, $0E, $07, $FB, $6E
    db   $AD, $6F, $CB, $6F, $E3, $6F, $FD, $6F
    db   $1E, $70, $4C, $70, $01, $20, $09, $04
    db   $0F, $47, $00, $05, $02, $0F, $47, $10
    db   $05, $02, $0A, $24, $3E, $0F, $47, $00
    db   $19, $20, $01, $04, $14, $52, $0A, $19
    db   $01, $01, $04, $40, $4F, $0A, $0F, $47
    db   $10, $19, $20, $01, $04, $14, $52, $0A
    db   $0F, $47, $00, $19, $00, $01, $04, $40
    db   $4F, $0A, $19, $20, $01, $04, $14, $52
    db   $0A, $19, $03, $01, $04, $40, $4F, $0A
    db   $0F, $47, $10, $19, $20, $01, $04, $14
    db   $52, $0A, $0F, $47, $00, $19, $02, $01
    db   $19, $01, $01, $19, $00, $01, $19, $03
    db   $01, $19, $02, $01, $19, $01, $01, $04
    db   $40, $4F, $0A, $0F, $47, $10, $19, $20
    db   $01, $04, $14, $52, $0A, $0F, $47, $00
    db   $19, $00, $01, $04, $40, $4F, $0A, $19
    db   $20, $01, $04, $14, $52, $0A, $19, $03
    db   $01, $22, $70, $70, $07, $04, $40, $4F
    db   $0A, $0F, $47, $10, $19, $20, $02, $04
    db   $14, $52, $0A, $0F, $47, $00, $19, $02
    db   $01, $04, $40, $4F, $0A, $19, $20, $04
    db   $19, $04, $10, $19, $1E, $01, $0D, $77
    db   $0F, $02, $19, $1E, $17, $1D, $04, $78
    db   $52, $0A, $19, $0E, $02, $19, $0F, $02
    db   $19, $10, $02, $19, $11, $02, $19, $12
    db   $06, $19, $13, $02, $0D, $77, $0F, $02
    db   $19, $14, $0A, $1D, $09, $04, $04, $40
    db   $4F, $0A, $19, $00, $04, $04, $48, $55
    db   $0A, $19, $00, $04, $0A, $0D, $77, $0F
    db   $02, $05, $14, $1D, $04, $B6, $55, $0A
    db   $19, $00, $0A, $19, $01, $02, $0D, $AF
    db   $0F, $09, $06, $00, $19, $02, $0A, $0D
    db   $77, $0F, $02, $05, $14, $1D, $04, $03
    db   $56, $0A, $19, $00, $06, $19, $01, $04
    db   $19, $02, $04, $19, $03, $02, $19, $02
    db   $02, $0D, $77, $0F, $02, $19, $03, $10
    db   $19, $02, $04, $19, $01, $04, $1D, $04
    db   $57, $56, $0A, $19, $00, $0A, $09, $03
    db   $0D, $77, $0F, $0A, $19, $01, $02, $0D
    db   $77, $0F, $0A, $19, $02, $02, $0D, $77
    db   $0F, $0A, $19, $03, $02, $0D, $77, $0F
    db   $0A, $19, $04, $02, $0A, $0D, $77, $0F
    db   $02, $19, $00, $14, $1D, $04, $A4, $56
    db   $0A, $19, $00, $05, $09, $03, $19, $01
    db   $02, $19, $02, $02, $19, $03, $02, $19
    db   $04, $02, $19, $05, $02, $19, $06, $02
    db   $0A, $0D, $77, $0F, $02, $19, $00, $0A
    db   $1D, $0D, $92, $0F, $03, $FA, $00, $05
    db   $04, $0D, $92, $0F, $03, $FA, $FC, $05
    db   $04, $0D, $92, $0F, $03, $FA, $04, $05
    db   $04, $0D, $92, $0F, $03, $FA, $00, $00
    db   $10, $5B, $0E, $07, $A1, $70, $D9, $70
    db   $FD, $70, $15, $71, $32, $71, $4C, $71
    db   $7E, $71, $04, $68, $59, $0A, $19, $00
    db   $06, $19, $01, $04, $01, $02, $0F, $39
    db   $01, $0D, $AF, $0F, $07, $10, $04, $05
    db   $06, $0F, $39, $02, $0D, $AF, $0F, $07
    db   $10, $04, $05, $06, $0F, $39, $00, $0D
    db   $AF, $0F, $07, $10, $04, $0D, $77, $0F
    db   $02, $05, $06, $19, $01, $04, $19, $00
    db   $06, $1D, $04, $E5, $59, $0A, $19, $00
    db   $06, $19, $01, $06, $0D, $77, $0F, $02
    db   $09, $02, $19, $02, $04, $19, $03, $04
    db   $19, $04, $04, $19, $05, $04, $0A, $19
    db   $01, $06, $19, $00, $06, $1D, $09, $04
    db   $04, $2C, $57, $0A, $19, $02, $04, $04
    db   $CB, $5A, $0A, $19, $00, $04, $0A, $0D
    db   $77, $0F, $02, $05, $14, $1D, $04, $4C
    db   $5C, $0A, $19, $00, $08, $01, $01, $0D
    db   $AF, $0F, $13, $00, $00, $0D, $77, $0F
    db   $02, $19, $02, $20, $19, $01, $04, $19
    db   $00, $08, $1D, $04, $36, $5D, $0A, $19
    db   $00, $06, $19, $01, $03, $19, $00, $03
    db   $19, $01, $08, $0D, $77, $0F, $02, $05
    db   $14, $19, $00, $05, $1D, $04, $74, $5D
    db   $0A, $0F, $39, $00, $09, $08, $0D, $AF
    db   $0F, $0D, $0A, $05, $19, $00, $02, $0D
    db   $AF, $0F, $0D, $0A, $05, $19, $01, $02
    db   $0D, $78, $71, $0A, $04, $2C, $57, $0A
    db   $01, $02, $0D, $77, $0F, $02, $05, $14
    db   $1D, $1E, $39, $1A, $3C, $12, $C9, $0F
    db   $39, $02, $04, $B8, $5D, $0A, $19, $00
    db   $06, $01, $01, $09, $05, $0D, $77, $0F
    db   $0B, $0D, $A3, $71, $05, $02, $0A, $04
    db   $2C, $57, $0A, $01, $02, $0D, $77, $0F
    db   $02, $05, $14, $1D, $1E, $39, $1A, $3C
    db   $FE, $0B, $38, $02, $3E, $02, $12, $C9
    db   $10, $5B, $0E, $07, $C1, $71, $DD, $71
    db   $FD, $71, $15, $72, $32, $72, $4A, $72
    db   $8B, $72, $04, $1A, $61, $0A, $19, $00
    db   $04, $19, $01, $04, $0D, $AF, $0F, $08
    db   $10, $00, $01, $02, $0D, $77, $0F, $02
    db   $05, $14, $19, $00, $04, $1D, $04, $BB
    db   $61, $0A, $19, $00, $06, $19, $01, $04
    db   $19, $02, $04, $19, $03, $08, $0D, $77
    db   $0F, $02, $05, $14, $19, $02, $04, $19
    db   $01, $04, $19, $00, $04, $1D, $09, $04
    db   $04, $99, $5E, $0A, $19, $02, $04, $04
    db   $3B, $62, $0A, $19, $01, $04, $0A, $0D
    db   $77, $0F, $02, $05, $14, $1D, $04, $C2
    db   $62, $0A, $19, $00, $04, $19, $01, $04
    db   $24, $55, $0D, $AF, $0F, $0B, $10, $00
    db   $0D, $77, $0F, $02, $19, $02, $14, $19
    db   $00, $04, $1D, $04, $4D, $63, $0A, $19
    db   $00, $04, $19, $01, $02, $19, $00, $02
    db   $0D, $77, $0F, $02, $19, $01, $14, $19
    db   $00, $04, $1D, $04, $99, $5E, $0A, $19
    db   $02, $06, $04, $B9, $63, $0A, $19, $00
    db   $04, $0D, $77, $0F, $02, $03, $79, $72
    db   $47, $09, $05, $19, $02, $02, $19, $03
    db   $02, $0A, $0F, $1F, $80, $0D, $82, $72
    db   $0D, $AF, $0F, $0E, $10, $00, $19, $01
    db   $04, $1D, $21, $CF, $5C, $3E, $02, $CD
    db   $CF, $05, $C9, $21, $73, $6D, $3E, $07
    db   $CD, $CF, $05, $C9, $04, $99, $5E, $0A
    db   $01, $02, $0F, $3A, $02, $0D, $77, $0F
    db   $02, $09, $05, $0F, $47, $10, $0D, $77
    db   $0F, $0C, $0D, $B4, $72, $05, $02, $0F
    db   $47, $00, $0D, $77, $0F, $0C, $0D, $B4
    db   $72, $05, $02, $0A, $1D, $1E, $3A, $1A
    db   $3C, $FE, $0B, $38, $02, $3E, $02, $12
    db   $C9, $10, $5B, $0E, $07, $D2, $72, $F6
    db   $72, $29, $73, $3F, $73, $66, $73, $85
    db   $73, $BD, $73, $04, $80, $67, $0A, $19
    db   $02, $06, $0D, $77, $0F, $02, $09, $05
    db   $19, $01, $02, $19, $00, $02, $0A, $19
    db   $02, $02, $19, $00, $02, $19, $02, $02
    db   $19, $01, $02, $19, $02, $06, $1D, $04
    db   $D1, $67, $0A, $19, $08, $04, $19, $09
    db   $02, $19, $08, $02, $0D, $77, $0F, $02
    db   $19, $09, $08, $19, $00, $02, $19, $01
    db   $01, $19, $02, $01, $19, $03, $02, $19
    db   $04, $01, $19, $05, $02, $19, $06, $02
    db   $19, $07, $01, $19, $09, $06, $19, $08
    db   $04, $1D, $04, $2F, $69, $0A, $19, $04
    db   $06, $19, $05, $04, $19, $06, $04, $01
    db   $00, $0D, $77, $0F, $02, $05, $14, $1D
    db   $04, $0C, $6A, $0A, $19, $00, $04, $19
    db   $01, $04, $0D, $77, $0F, $02, $0D, $AF
    db   $0F, $0C, $10, $FD, $0D, $AF, $0F, $14
    db   $10, $F6, $0D, $AF, $0F, $15, $10, $04
    db   $19, $02, $14, $19, $01, $04, $1D, $04
    db   $29, $65, $0A, $19, $00, $06, $04, $B5
    db   $6A, $0A, $19, $07, $06, $19, $06, $02
    db   $19, $07, $02, $0D, $77, $0F, $02, $19
    db   $00, $14, $19, $07, $06, $1D, $04, $ED
    db   $6B, $0A, $0D, $77, $0F, $02, $22, $AA
    db   $73, $07, $09, $02, $19, $00, $02, $19
    db   $01, $02, $19, $04, $02, $19, $05, $02
    db   $19, $02, $02, $19, $03, $02, $0A, $0F
    db   $1C, $80, $1D, $0D, $AF, $0F, $0F, $03
    db   $10, $05, $04, $0D, $AF, $0F, $10, $03
    db   $10, $05, $04, $06, $AA, $73, $04, $E7
    db   $6C, $0A, $0D, $77, $0F, $02, $19, $00
    db   $04, $22, $E8, $73, $07, $19, $01, $0D
    db   $19, $02, $0D, $19, $03, $0D, $19, $04
    db   $0D, $19, $05, $0D, $19, $06, $0D, $0F
    db   $1C, $80, $0D, $F5, $73, $19, $00, $04
    db   $1D, $24, $1E, $0D, $AF, $0F, $12, $00
    db   $00, $05, $06, $06, $E8, $73, $1E, $15
    db   $1A, $FE, $04, $D8, $1E, $45, $1A, $EE
    db   $80, $12, $C9, $01, $02, $00, $FE, $FF
    db   $02, $00, $FE

toc_07_740A:
    ld   h, d
    ld   a, [$A076]
    or   a
    jr   nz, .else_07_7420

    ld   l, $19
    set  5, [hl]
    ld   l, $1C
    set  5, [hl]
    ld   l, $1F
    set  5, [hl]
    call toc_01_0E2C
.else_07_7420:
    ld   bc, $A076
    ld   a, [bc]
    ld   hl, $7402
    add  a, a
    add  a, l
    ld   l, a
    jr   nc, .else_07_742D

    inc  h
.else_07_742D:
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   e, $09
    ld   a, [de]
    add  a, h
    ld   [de], a
    ld   e, $0B
    ld   a, [de]
    add  a, l
    ld   [de], a
    ld   a, [bc]
    inc  a
    ld   [bc], a
    cp   $04
    ret  c

    ld   h, d
    ld   l, $19
    res  5, [hl]
    ld   l, $1C
    res  5, [hl]
    ld   l, $1F
    res  5, [hl]
    ld   l, $6C
    res  0, [hl]
    ret


    db   $CD, $58, $74, $C3, $8B, $74

toc_07_7458:
    ld   a, [$A071]
    ld   hl, $7468
    add  a, l
    ld   l, a
    jr   nc, .else_07_7463

    inc  h
.else_07_7463:
    ld   a, [hl]
    ld   [$DF11], a
    ret


    db   $00, $09, $12, $1B, $CD, $72, $74, $C3
    db   $8B, $74

toc_07_7472:
    ld   a, [$A071]
    ld   hl, $7487
    add  a, l
    ld   l, a
    jr   nc, .else_07_747D

    inc  h
.else_07_747D:
    ld   a, [hl]
    ld   hl, $A05B
    add  a, [hl]
    inc  a
    ld   [$DF11], a
    ret


    db   $01, $0A, $13, $1C, $FA, $11, $DF, $C5
    db   $26, $00, $6F, $44, $4D, $29, $09, $29
    db   $09, $01, $BB, $74, $09, $1E, $65, $2A
    db   $12, $1C, $2A, $12, $1E, $67, $2A, $12
    db   $1C, $2A, $12, $1C, $2A, $12, $1E, $6A
    db   $2A, $12, $1C, $7E, $12, $3E, $01, $1E
    db   $64, $12, $C1, $C9, $00, $81, $00, $40
    db   $09, $80, $02, $80, $83, $80, $42, $09
    db   $20, $02, $80, $83, $A0, $44, $09, $E0
    db   $01, $80, $83, $80, $46, $09, $80, $02
    db   $80, $83, $00, $49, $09, $60, $01, $80
    db   $83, $60, $4A, $09, $A0, $01, $80, $83
    db   $00, $4C, $09, $60, $02, $80, $83, $60
    db   $4E, $09, $60, $01, $80, $83, $C0, $4F
    db   $09, $A0, $01, $00, $81, $60, $51, $09
    db   $C0, $02, $C0, $83, $20, $54, $09, $40
    db   $02, $C0, $83, $60, $56, $09, $00, $02
    db   $C0, $83, $60, $58, $09, $40, $02, $C0
    db   $83, $A0, $5A, $09, $00, $02, $C0, $83
    db   $E0, $5C, $09, $40, $02, $C0, $83, $20
    db   $5F, $09, $C0, $01, $C0, $83, $60, $61
    db   $09, $A0, $01, $C0, $83, $00, $63, $09
    db   $E0, $01, $00, $81, $E0, $64, $09, $C0
    db   $02, $C0, $83, $A0, $67, $09, $40, $02
    db   $C0, $83, $E0, $69, $09, $20, $02, $C0
    db   $83, $00, $6C, $09, $20, $02, $C0, $83
    db   $40, $6E, $09, $40, $02, $C0, $83, $80
    db   $70, $09, $40, $02, $C0, $83, $C0, $72
    db   $09, $80, $01, $C0, $83, $40, $74, $09
    db   $40, $02, $C0, $83, $80, $76, $09, $E0
    db   $01, $00, $81, $60, $78, $09, $00, $03
    db   $00, $84, $00, $40, $0A, $00, $02, $00
    db   $84, $00, $42, $0A, $E0, $01, $00, $84
    db   $00, $44, $0A, $00, $02, $00, $84, $00
    db   $46, $0A, $E0, $01, $00, $84, $00, $48
    db   $0A, $C0, $01, $00, $84, $C0, $49, $0A
    db   $80, $01, $00, $84, $C0, $4B, $0A, $80
    db   $01, $00, $84, $40, $4D, $0A, $00, $02
    db   $00, $81, $00, $40, $0B, $A0, $03, $60
    db   $88, $A0, $43, $0B, $00, $05, $60, $88
    db   $A0, $48, $0B, $80, $05, $60, $88, $20
    db   $4E, $0B, $40, $05, $40, $8A, $A0, $43
    db   $0B, $00, $05, $40, $8A, $A0, $48, $0B
    db   $80, $05, $40, $8A, $20, $4E, $0B, $40
    db   $05, $00, $81, $A0, $43, $0B, $00, $05
    db   $00, $81, $A0, $48, $0B, $80, $05, $00
    db   $81, $20, $4E, $0B, $40, $05, $00, $80
    db   $71, $65, $10, $00, $06, $60, $88, $71
    db   $6B, $10, $A0, $06, $00, $80, $FD, $79
    db   $1A, $C0, $00, $00, $80, $CD, $7A, $1A
    db   $00, $01, $00, $80, $CD, $7B, $1A, $C0
    db   $00, $80, $83, $11, $72, $10, $C0, $00
    db   $C0, $83, $80, $76, $09, $E0, $01, $00
    db   $81, $60, $78, $09, $00, $03, $00, $84
    db   $00, $40, $0A, $00, $02, $00, $84, $00
    db   $42, $0A, $E0, $01, $00, $84, $00, $44
    db   $0A, $00, $02, $00, $84, $00, $46, $0A
    db   $E0, $01, $00, $84, $00, $48, $0A, $C0
    db   $01, $00, $84, $C0, $49, $0A, $80, $01
    db   $00, $84, $C0, $4B, $0A, $80, $01, $00
    db   $84, $40, $4D, $0A, $00, $02, $00, $81
    db   $00, $40, $0B, $A0, $03, $60, $88, $A0
    db   $43, $0B, $00, $05, $60, $88, $A0, $48
    db   $0B, $80, $05, $60, $88, $20, $4E, $0B
    db   $40, $05, $40, $8A, $A0, $43, $0B, $00
    db   $05, $40, $8A, $A0, $48, $0B, $80, $05
    db   $40, $8A, $20, $4E, $0B, $40, $05, $00
    db   $81, $A0, $43, $0B, $00, $05, $00, $81
    db   $A0, $48, $0B, $80, $05, $00, $81, $20
    db   $4E, $0B, $40, $05, $00, $80, $71, $65
    db   $10, $00, $06, $60, $88, $71, $6B, $10
    db   $A0, $06, $00, $80, $FD, $79, $1A, $C0
    db   $00, $00, $80, $CD, $7A, $1A, $00, $01
    db   $00, $80, $CD, $7B, $1A, $C0, $00, $80
    db   $83, $11, $72, $10, $C0, $00, $40, $74
    db   $09, $40, $02, $C0, $83, $80, $76, $09
    db   $E0, $01, $00, $81, $60, $78, $09, $00
    db   $03, $00, $84, $00, $40, $0A, $00, $02
    db   $00, $84, $00, $42, $0A, $E0, $01, $00
    db   $84, $01, $40, $01, $C2, $45, $07, $3A
    db   $4C, $07, $C0, $6E, $07, $09, $54, $03
    db   $37, $54, $03, $E3, $55, $03, $00, $40
    db   $03, $34, $40, $03, $28, $63, $03, $9F
    db   $65, $03, $09, $66, $03, $F1, $44, $03
    db   $0A, $48, $03, $E5, $5B, $03, $CA, $40
    db   $04, $39, $42, $04, $00, $40, $01, $1B
    db   $5F, $03, $EF, $5F, $03, $78, $61, $0E
    db   $00, $68, $03, $7D, $68, $03, $12, $70
    db   $03, $91, $71, $03, $2D, $4B, $05, $8F
    db   $4B, $05, $3C, $4D, $05, $F1, $73, $03
    db   $66, $79, $03, $2C, $43, $1A, $AC, $45
    db   $1A, $BF, $45, $1A, $C8, $45, $1A, $05
    db   $46, $1A, $99, $48, $07, $B1, $46, $07
    db   $26, $49, $07, $2D, $7C, $04, $83, $7D
    db   $04, $DD, $7A, $03, $31, $7D, $03, $2B
    db   $7D, $03, $2C, $7D, $03, $33, $53, $08
    db   $03, $56, $08, $82, $57, $08, $1F, $46
    db   $1A, $1C, $58, $03, $B1, $58, $03, $9F
    db   $40, $05, $C2, $42, $05, $83, $50, $05
    db   $53, $57, $05, $88, $5B, $05, $8F, $5D
    db   $05, $E5, $5D, $05, $8E, $60, $05, $BC
    db   $63, $05, $0D, $65, $05, $8E, $66, $05
    db   $94, $66, $05, $E9, $6A, $05, $21, $6C
    db   $05, $19, $6E, $05, $41, $6F, $05, $F6
    db   $72, $05, $09, $79, $05, $86, $6C, $03
    db   $1E, $63, $0E, $99, $63, $0E, $2E, $6E
    db   $03, $54, $75, $05, $2B, $77, $05, $73
    db   $77, $05, $CD, $77, $05, $26, $78, $05
    db   $98, $67, $1C, $40, $68, $1C, $9C, $68
    db   $1C, $F9, $68, $1C, $F7, $69, $1C, $1E
    db   $6A, $1C, $4A, $6A, $1C, $67, $6A, $1C
    db   $C5, $6A, $1C, $D2, $6B, $1C, $EB, $6B
    db   $1C, $50, $6C, $1C, $6B, $6C, $1C, $90
    db   $6C, $1C, $AB, $6C, $1C, $C6, $6C, $1C
    db   $69, $6D, $1C, $CE, $6D, $1C, $24, $6E
    db   $1C, $5B, $6E, $1C, $B2, $6E, $1C, $23
    db   $6F, $1C, $68, $6F, $1C, $83, $6F, $1C
    db   $A1, $6F, $1C, $15, $71, $1C, $86, $71
    db   $1C, $AB, $71, $1C, $0D, $72, $1C, $2E
    db   $72, $1C, $4F, $72, $1C, $79, $72, $1C
    db   $96, $72, $1C, $2B, $74, $1C, $63, $74
    db   $1C, $94, $74, $1C, $C5, $74, $1C, $30
    db   $75, $1C, $55, $75, $1C, $B6, $75, $1C
    db   $2D, $76, $1C, $B4, $76, $1C, $CA, $5B
    db   $0E, $11, $5C, $0E, $3D, $5C, $0E, $69
    db   $5C, $0E, $DE, $5F, $0E, $95, $5C, $0E
    db   $DA, $5C, $0E, $F8, $5C, $0E, $16, $5D
    db   $0E, $6F, $5D, $0E, $99, $5D, $0E, $BD
    db   $5D, $0E, $E1, $5D, $0E, $05, $5E, $0E
    db   $0C, $61, $0E, $29, $5E, $0E, $94, $5E
    db   $0E, $DF, $5E, $0E, $28, $5F, $0E, $A9
    db   $5F, $0E, $04, $6E, $18, $F7, $74, $18
    db   $1F, $75, $18, $43, $75, $18, $6B, $75
    db   $18, $93, $75, $18, $E1, $75, $18, $8B
    db   $76, $18, $87, $6E, $18, $F6, $72, $18
    db   $E3, $70, $18, $E6, $73, $18, $12, $74
    db   $18, $63, $73, $18, $D6, $71, $18, $E6
    db   $44, $0F, $E3, $47, $0F, $1D, $45, $0F
    db   $54, $45, $0F, $93, $6C, $08, $BE, $6C
    db   $08, $84, $5F, $08, $74, $47, $1A, $E0
    db   $5E, $08, $B5, $60, $08, $62, $4A, $07
    db   $89, $47, $1A, $07, $48, $1A, $6B, $67
    db   $0F, $20, $69, $0F, $16, $6C, $0F, $47
    db   $6C, $0F, $EE, $4E, $1A, $08, $4F, $1A
    db   $1D, $4F, $1A, $37, $4F, $1A, $4C, $4F
    db   $1A, $66, $4F, $1A, $7B, $4F, $1A, $95
    db   $4F, $1A, $B4, $4F, $1A, $21, $51, $1A
    db   $7E, $51, $1A, $DB, $51, $1A, $38, $52
    db   $1A, $95, $52, $1A, $EC, $52, $1A, $43
    db   $53, $1A, $5D, $53, $1A, $77, $53, $1A
    db   $91, $53, $1A, $AB, $53, $1A, $2B, $60
    db   $1A, $5C, $62, $1A, $F6, $69, $1A, $EB
    db   $6E, $1A, $67, $62, $1A, $71, $63, $1A
    db   $AF, $63, $1A, $EC, $64, $1A, $E8, $68
    db   $1A, $40, $69, $1A, $4E, $69, $1A, $87
    db   $41, $06, $C1, $46, $06, $24, $41, $0E
    db   $2C, $49, $0E, $19, $5D, $0F, $44, $5D
    db   $0F, $BE, $5D, $0F, $D0, $5B, $06, $11
    db   $5C, $06, $30, $72, $06, $C8, $40, $1D
    db   $21, $49, $1D, $39, $4D, $1D, $45, $5C
    db   $1D, $C5, $63, $1D, $BF, $74, $1D, $79
    db   $43, $19, $09, $44, $19, $0D, $44, $19
    db   $7F, $44, $19, $37, $44, $19, $13, $45
    db   $19, $48, $45, $19, $50, $4C, $19, $71
    db   $45, $19, $9D, $4C, $19, $B9, $4C, $19
    db   $D5, $4C, $19, $F1, $4C, $19, $0D, $4D
    db   $19, $29, $4D, $19, $45, $4D, $19, $61
    db   $4D, $19, $7D, $4D, $19, $99, $4D, $19
    db   $B5, $4D, $19, $D1, $4D, $19, $ED, $4D
    db   $19, $09, $4E, $19, $25, $4E, $19, $41
    db   $4E, $19, $5D, $4E, $19, $8B, $4E, $19
    db   $ED, $7A, $19, $2C, $66, $0E, $03, $6D
    db   $0E, $E7, $58, $08, $00, $00, $00, $00
    db   $00, $00, $00, $00, $88, $00, $00, $02
    db   $00, $00, $02, $00, $01, $00, $00, $00
    db   $00, $04, $06, $06, $06, $06, $05, $05
    db   $05, $05, $04, $08, $08, $0C, $0E, $0E
    db   $0F, $0F, $11, $12, $12, $12, $12, $09
    db   $09, $0A, $0A, $14, $14, $15, $15, $15
    db   $15, $17, $17, $17, $17, $17, $17, $17
    db   $17, $17, $17, $17, $17, $18, $18, $18
    db   $18, $18, $18, $18, $18, $18, $18, $1C
    db   $1C, $1C, $1C, $1C, $1C, $1E, $1E, $1E
    db   $19, $19, $19, $19, $1B, $1B, $26, $26
    db   $1B, $1B, $26, $26, $17, $28, $28, $28
    db   $28, $30, $30, $26, $26, $26, $26, $26
    db   $26, $32, $A1, $A2, $A5, $A5, $A5, $A5
    db   $A5, $A5, $A5, $A5, $A6, $26, $26, $26
    db   $26, $28, $28, $28, $28, $34, $34, $35
    db   $35, $35, $35, $CA, $CC, $17, $D1, $D4
    db   $36, $36, $36, $36, $37, $37, $39, $39
    db   $D6, $D8, $22, $1E, $1E, $3A, $3A, $3B
    db   $3B, $3D, $3D, $40, $40, $40, $40, $40
    db   $40, $42, $42, $42, $42, $42, $42, $45
    db   $45, $45, $45, $3E, $3E, $3E, $3E, $3F
    db   $3F, $2C, $29, $2E, $2E, $05, $05, $05
    db   $05, $1C, $1C, $1C, $1C, $1C, $1C, $44
    db   $44, $44, $44, $2A, $47, $47, $47, $47
    db   $2D, $BF, $C0, $C3, $C4, $C1, $11, $11
    db   $11, $11, $11, $11, $11, $11, $11, $11
    db   $11, $11, $11, $11, $11, $11, $2B, $C0
    db   $C5, $C0, $09, $08, $C6, $2E, $15, $15
    db   $15, $15, $15, $FF, $FF, $FF, $FF, $FF
    db   $FF, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $02, $00, $80, $00, $00
    db   $00, $00, $00, $10, $01, $11, $00, $10
    db   $01, $11, $00, $00, $00, $00, $00, $10
    db   $00, $00, $00, $00, $10, $01, $11, $00
    db   $10, $00, $01, $00, $10, $00, $10, $00
    db   $10, $00, $10, $01, $11, $02, $12, $03
    db   $13, $04, $14, $05, $15, $00, $10, $01
    db   $11, $02, $12, $03, $13, $04, $14, $00
    db   $10, $01, $01, $02, $12, $01, $02, $03
    db   $00, $10, $01, $11, $00, $10, $00, $10
    db   $01, $11, $01, $11, $06, $00, $10, $20
    db   $31, $00, $10, $02, $12, $03, $13, $04
    db   $14, $00, $00, $00, $00, $01, $02, $03
    db   $04, $05, $06, $07, $00, $05, $15, $06
    db   $16, $01, $11, $21, $31, $00, $10, $00
    db   $10, $01, $11, $00, $00, $FF, $00, $00
    db   $00, $10, $01, $11, $00, $10, $00, $10
    db   $00, $00, $00, $00, $04, $00, $01, $00
    db   $10, $00, $10, $00, $00, $01, $01, $10
    db   $10, $00, $10, $01, $11, $02, $12, $00
    db   $10, $01, $11, $00, $10, $01, $11, $00
    db   $10, $00, $00, $00, $00, $02, $12, $03
    db   $13, $03, $13, $04, $14, $05, $15, $00
    db   $10, $01, $11, $00, $00, $10, $01, $11
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $11, $01, $00, $01, $01, $11
    db   $21, $31, $41, $FF, $FF, $FF, $FF, $FF
    db   $FF, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $20, $00, $02, $00, $80, $00, $88
    db   $00, $01, $00, $10, $04, $08, $00, $08
    db   $00, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $3C, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $FF, $FF, $FF
    db   $FF, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $1E, $1E
    db   $01, $01, $1E, $1E, $01, $00, $00, $00
    db   $00, $01, $01, $1E, $1E, $1E, $1E, $1E
    db   $1E, $3C, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $1E, $1E, $1E
    db   $1E, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $23, $3C, $01, $28, $3C
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $78, $78, $00, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $01, $00, $00, $40, $C0, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $00, $01, $01, $01, $01
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $01, $01, $00, $40, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $80, $00, $00, $00, $00, $80, $00
    db   $20, $00, $00, $00, $00, $80, $00, $10
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $10, $10, $10, $10, $10, $10
    db   $10, $10, $00, $20, $20, $00, $20, $20
    db   $20, $20, $00, $20, $20, $20, $20, $20
    db   $20, $10, $10, $20, $20, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $20
    db   $20, $20, $20, $20, $20, $00, $00, $00
    db   $10, $10, $10, $10, $20, $20, $50, $50
    db   $20, $20, $50, $50, $00, $00, $00, $00
    db   $00, $20, $20, $50, $50, $50, $50, $50
    db   $50, $50, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $50, $50, $50
    db   $50, $00, $00, $00, $00, $20, $20, $20
    db   $20, $20, $20, $00, $00, $00, $50, $50
    db   $20, $20, $20, $20, $10, $10, $50, $50
    db   $00, $00, $00, $00, $00, $15, $15, $10
    db   $10, $75, $75, $10, $10, $10, $10, $10
    db   $10, $00, $00, $00, $00, $00, $00, $20
    db   $20, $20, $20, $05, $05, $10, $10, $20
    db   $20, $00, $00, $00, $00, $10, $10, $10
    db   $10, $20, $20, $20, $20, $20, $20, $10
    db   $10, $10, $10, $00, $20, $20, $20, $20
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $20, $20, $00, $00, $00, $00
    db   $00, $00, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $80, $10, $00, $00, $00, $08, $00
    db   $34, $00, $00, $88, $00, $20, $00, $00
    db   $40, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $05, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $01, $01
    db   $00, $00, $01, $01, $00, $00, $00, $00
    db   $00, $00, $00, $01, $01, $01, $01, $01
    db   $01, $07, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $01, $01, $01
    db   $01, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $05, $10, $00, $02, $12
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $50, $25, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $01, $01, $01, $01, $01, $01, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $84, $00, $C0, $40, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $0B, $00, $00, $00, $00, $01, $01
    db   $01, $01, $0B, $02, $02, $03, $05, $05
    db   $06, $06, $13, $0A, $0A, $0A, $0A, $04
    db   $04, $00, $00, $07, $07, $08, $08, $08
    db   $08, $0C, $0C, $0C, $0C, $0C, $0C, $0C
    db   $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
    db   $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0F
    db   $0F, $0F, $0F, $0F, $0F, $11, $11, $11
    db   $0D, $0D, $0D, $0D, $0E, $0E, $10, $10
    db   $0E, $0E, $12, $12, $0C, $13, $14, $15
    db   $16, $17, $17, $18, $18, $19, $19, $1A
    db   $1A, $1B, $1C, $1F, $1D, $1D, $1D, $1D
    db   $1D, $1D, $1D, $1D, $1D, $20, $20, $21
    db   $21, $13, $14, $15, $16, $22, $22, $23
    db   $23, $23, $23, $26, $27, $0C, $28, $29
    db   $24, $24, $24, $24, $25, $25, $2A, $2A
    db   $2B, $2C, $1F, $11, $11, $2D, $2D, $2E
    db   $2E, $2F, $2F, $30, $30, $30, $30, $30
    db   $30, $31, $31, $32, $32, $33, $33, $34
    db   $34, $34, $34, $35, $35, $36, $36, $37
    db   $37, $1F, $38, $39, $39, $01, $01, $01
    db   $01, $0F, $0F, $0F, $0F, $0F, $0F, $00
    db   $00, $00, $00, $1F, $37, $37, $37, $37
    db   $3A, $3B, $3C, $3D, $0C, $0C, $3E, $3E
    db   $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E
    db   $3E, $3E, $3E, $3E, $3E, $3E, $1F, $3F
    db   $40, $41, $04, $02, $40, $39, $08, $08
    db   $08, $08, $08, $FF, $FF, $FF, $FF, $FF
    db   $FF, $00, $00, $00, $00, $80, $40, $80
    db   $00, $00, $00, $20, $00, $08, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00
