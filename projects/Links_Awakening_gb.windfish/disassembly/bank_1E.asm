SECTION "ROM Bank 1E", ROMX[$4000], BANK[$1E]

    db   $C3, $09, $40, $C3, $FA, $4C

toc_1E_4006:
    jp   toc_1E_401E

    db   $21, $00, $D3, $36, $00, $2C, $20, $FB
    db   $3E, $80, $E0, $26, $3E, $77, $E0, $24
    db   $3E, $FF, $E0, $25, $C9

toc_1E_401E:
    ld   hl, $D368
    ldi  a, [hl]
    and  a
    jr   nz, .else_1E_4039

    call toc_1E_403F
.toc_1E_4028:
    call toc_1E_457C
.toc_1E_402B:
    clear [$D360]
    ld   [$D368], a
    ld   [$D370], a
    ld   [$D378], a
    ret


.else_1E_4039:
    ld   [hl], a
    call toc_1E_4163
    jr   .toc_1E_4028

toc_1E_403F:
    ld   de, $D393
    ld   hl, $D378
    ldi  a, [hl]
    cp   $01
    jr   z, .else_1E_4050

    ld   a, [hl]
    cp   $01
    jr   z, .else_1E_405B

    ret


.else_1E_4050:
    assign [$D379], $01
    ld   hl, $4068
    jp   toc_1E_4072

.else_1E_405B:
    ld   a, [de]
    dec  a
    ld   [de], a
    ret  nz

    clear [$D379]
    ld   hl, $406D
    jr   toc_1E_4072

    db   $3B, $80, $07, $C0, $02, $00, $42, $02
    db   $C0, $04

toc_1E_4072:
    ld   b, $04
    ld   c, $20
.loop_1E_4076:
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    dec  b
    jr   nz, .loop_1E_4076

    ld   a, [hl]
    ld   [de], a
    ret


    db   $09, $52, $56, $56, $6A, $5E, $74, $59
    db   $AE, $5A, $A7, $5C, $B3, $5D, $EE, $5E
    db   $3C, $5F, $00, $50, $64, $60, $C2, $60
    db   $23, $61, $A9, $62, $75, $64, $A5, $72
    db   $10, $66, $36, $66, $BF, $52, $62, $66
    db   $A6, $7B, $77, $67, $2E, $4B, $F1, $72
    db   $3F, $73, $9E, $73, $16, $74, $A8, $74
    db   $46, $75, $92, $75, $00, $76, $3D, $77
    db   $00, $70, $2C, $70, $F0, $70, $58, $71
    db   $A6, $71, $D4, $71, $3C, $72, $D3, $78
    db   $23, $4B, $93, $76, $0E, $63, $79, $69
    db   $DF, $69, $21, $6A, $09, $6C, $33, $4C
    db   $6A, $5E, $74, $59, $B7, $66, $80, $6C
    db   $05, $7A, $5A, $7A, $28, $7B, $7B, $65
    db   $28, $7C, $C9, $58, $9C, $67, $49, $6C
    db   $AC, $52, $FF, $7C, $4B, $7D, $04, $7E

toc_1E_40FF:
    inc  e
    dec  a
    sla  a
    ld   c, a
    ld   b, $00
    add  hl, bc
    ld   c, [hl]
    inc  hl
    ld   b, [hl]
    ld   l, c
    ld   h, b
    ld   a, h
    ret


toc_1E_410E:
    push bc
    ld   c, $30
.loop_1E_4111:
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    ld   a, c
    cp   $40
    jr   nz, .loop_1E_4111

    pop  bc
    ret


toc_1E_411B:
    clear [$D379]
    ld   [$D34F], a
    ld   [$D398], a
    ld   [$D393], a
    ld   [$D3C9], a
    ld   [$D3A3], a
    assign [gbAUD4ENV], $08
    assign [gbAUD4CONSEC], $80
    ret


toc_1E_4137:
    ld   a, [$D379]
    cp   $05
    jp   z, toc_1E_4D18

    cp   $0C
    jp   z, toc_1E_4D18

    cp   $1A
    jp   z, toc_1E_4D18

    cp   $24
    jp   z, toc_1E_4D18

    cp   $2A
    jp   z, toc_1E_4D18

    cp   $2E
    jp   z, toc_1E_4D18

    cp   $3F
    jp   z, toc_1E_4D18

    call toc_1E_411B
    jp   toc_1E_4D18

toc_1E_4163:
    ld   b, a
    ifZero [$D3CE], toc_1E_401E.toc_1E_402B

    ld   a, b
    cp   $FF
    jr   z, toc_1E_4137

    cp   $11
    jr   nc, .else_1E_4177

    jp   toc_1E_401E.toc_1E_402B

.else_1E_4177:
    cp   $21
    jr   nc, .else_1E_417F

    add  a, $F0
    jr   .toc_1E_418E

.else_1E_417F:
    cp   $31
    jr   nc, .else_1E_4187

    add  a, $F0
    jr   .toc_1E_418E

.else_1E_4187:
    cp   $41
    jp   c, toc_1E_401E.toc_1E_402B

    add  a, $E0
.toc_1E_418E:
    dec  hl
    ldi  [hl], a
    ldd  [hl], a
    copyFromTo [$D3CA], [$D3CB]
    ldi  a, [hl]
    ld   [$D3CA], a
    ld   b, a
    ld   hl, $407F
    and  %01111111
    call toc_1E_40FF
    call toc_1E_43BB
    jp   toc_1E_4354

    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00
    db   $01, $00, $FF, $FF, $00, $00, $01, $00
    db   $FF, $FF, $00, $00, $01, $00, $FF, $FF
    db   $00, $00, $01, $00, $FF, $FF, $00, $00

toc_1E_432A:
    _ifNotZero [$D3E7], toc_1E_457C.toc_1E_473A

    clear [gbAUD3ENA]
    ld   [$D3E7], a
    push hl
    ld   a, [$D336]
    ld   l, a
    ld   a, [$D337]
    ld   h, a
    push bc
    ld   c, $30
.loop_1E_4343:
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    ld   a, c
    cp   $40
    jr   nz, .loop_1E_4343

    assign [gbAUD3ENA], $80
    pop  bc
    pop  hl
    jp   toc_1E_457C.toc_1E_473A

toc_1E_4354:
    ld   a, [$D369]
    ld   hl, $41AA
.toc_1E_435A:
    dec  a
    jr   z, .else_1E_4365

    inc  hl
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    jr   .toc_1E_435A

.else_1E_4365:
    ld   bc, $D355
    ldi  a, [hl]
    ld   [bc], a
    inc  c
    xor  a
    ld   [bc], a
    inc  c
    ldi  a, [hl]
    ld   [bc], a
    inc  c
    xor  a
    ld   [bc], a
    inc  c
    ldi  a, [hl]
    ld   [bc], a
    ld   [gbAUDTERM], a
    inc  c
    ldi  a, [hl]
    ld   [bc], a
    inc  c
    ldi  a, [hl]
    ld   [bc], a
    inc  c
    ldi  a, [hl]
    ld   [bc], a
    ret


toc_1E_4382:
    ld   hl, $D355
    ldi  a, [hl]
    cp   $01
    ret  z

    inc  [hl]
    ldi  a, [hl]
    cp   [hl]
    ret  nz

    dec  l
    ld   [hl], $00
    inc  l
    inc  l
    inc  [hl]
    ldi  a, [hl]
    and  %00000011
    ld   c, l
    ld   b, h
    and  a
    jr   z, .else_1E_43A6

    inc  c
    cp   $01
    jr   z, .else_1E_43A6

    inc  c
    cp   $02
    jr   z, .else_1E_43A6

    inc  c
.else_1E_43A6:
    ld   a, [bc]
    ld   [gbAUDTERM], a
    ret


toc_1E_43AA:
    ldi  a, [hl]
    ld   c, a
    ld   a, [hl]
    ld   b, a
    ld   a, [bc]
    ld   [de], a
    inc  e
    inc  bc
    ld   a, [bc]
    ld   [de], a
    ret


toc_1E_43B5:
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    ret


toc_1E_43BB:
    ifEq [$D379], $05, .else_1E_43DD

    cp   $0C
    jr   z, .else_1E_43DD

    cp   $1A
    jr   z, .else_1E_43DD

    cp   $24
    jr   z, .else_1E_43DD

    cp   $2A
    jr   z, .else_1E_43DD

    cp   $2E
    jr   z, .else_1E_43DD

    cp   $3F
    jr   z, .else_1E_43DD

    call toc_1E_411B
.else_1E_43DD:
    call toc_1E_4D18.toc_1E_4D25
    ld   de, $D300
    ld   b, $00
    ldi  a, [hl]
    ld   [de], a
    inc  e
    call toc_1E_43B5
    ld   de, $D310
    call toc_1E_43B5
    ld   de, $D320
    call toc_1E_43B5
    ld   de, $D330
    call toc_1E_43B5
    ld   de, $D340
    call toc_1E_43B5
    ld   hl, $D310
    ld   de, $D314
    call toc_1E_43AA
    ld   hl, $D320
    ld   de, $D324
    call toc_1E_43AA
    ld   hl, $D330
    ld   de, $D334
    call toc_1E_43AA
    ld   hl, $D340
    ld   de, $D344
    call toc_1E_43AA
    ld   bc, $0410
    ld   hl, $D312
.loop_1E_442D:
    ld   [hl], $01
    ld   a, c
    add  a, l
    ld   l, a
    dec  b
    jr   nz, .loop_1E_442D

    clear [$D31E]
    ld   [$D32E], a
    ld   [$D33E], a
    ret


toc_1E_4440:
    push hl
    _ifZero [$D371], .else_1E_444F

    clear [gbAUD3ENA]
    ld   l, e
    ld   h, d
    call toc_1E_410E
.else_1E_444F:
    pop  hl
    jr   toc_1E_4452.toc_1E_447C

toc_1E_4452:
    call toc_1E_4482
    call toc_1E_4497
    ld   e, a
    call toc_1E_4482
    call toc_1E_4497
    ld   d, a
    call toc_1E_4482
    call toc_1E_4497
    ld   c, a
    inc  l
    inc  l
    ld   [hl], e
    inc  l
    ld   [hl], d
    inc  l
    ld   [hl], c
    dec  l
    dec  l
    dec  l
    dec  l
    push hl
    ld   hl, $D350
    ld   a, [hl]
    pop  hl
    cp   $03
    jr   z, toc_1E_4440

.toc_1E_447C:
    call toc_1E_4482
    jp   toc_1E_457C.toc_1E_45A0

toc_1E_4482:
    push de
    ldi  a, [hl]
    ld   e, a
    ldd  a, [hl]
    ld   d, a
    inc  de
.toc_1E_4488:
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldd  [hl], a
    pop  de
    ret


toc_1E_448E:
    push de
    ldi  a, [hl]
    ld   e, a
    ldd  a, [hl]
    ld   d, a
    inc  de
    inc  de
    jr   toc_1E_4482.toc_1E_4488

toc_1E_4497:
    ldi  a, [hl]
    ld   c, a
    ldd  a, [hl]
    ld   b, a
    ld   a, [bc]
    ld   b, a
    ret


toc_1E_449E:
    pop  hl
    jr   toc_1E_44A1.toc_1E_44D2

toc_1E_44A1:
    ifNe [$D350], $03, .else_1E_44B8

    ld   a, [$D338]
    bit  7, a
    jr   z, .else_1E_44B8

    ld   a, [hl]
    cp   $06
    jr   nz, .else_1E_44B8

    assign [gbAUD3LEVEL], $40
.else_1E_44B8:
    push hl
    ld   a, l
    add  a, $09
    ld   l, a
    ld   a, [hl]
    and  a
    jr   nz, toc_1E_449E

    ld   a, l
    add  a, $04
    ld   l, a
    bit  7, [hl]
    jr   nz, toc_1E_449E

    pop  hl
    call toc_1E_476D
    push hl
    call toc_1E_47F1
    pop  hl
.toc_1E_44D2:
    dec  l
    dec  l
    jp   toc_1E_457C.toc_1E_474D

toc_1E_44D7:
    dec  l
    dec  l
    dec  l
    dec  l
    call toc_1E_448E
.toc_1E_44DE:
    ld   a, l
    add  a, $04
    ld   e, a
    ld   d, h
    call toc_1E_43AA
    cp   $00
    jr   z, .else_1E_4509

    cp   $FF
    jr   z, .else_1E_44F2

    inc  l
    jp   toc_1E_457C.toc_1E_459E

.else_1E_44F2:
    dec  l
    push hl
    call toc_1E_448E
    call toc_1E_4497
    ld   e, a
    call toc_1E_4482
    call toc_1E_4497
    ld   d, a
    pop  hl
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldd  [hl], a
    jr   .toc_1E_44DE

.else_1E_4509:
    ld   a, [$D3CA]
    cp   $15
    jp   z, toc_1E_484F

    ld   hl, $D369
    ld   [hl], $00
    call toc_1E_4137
    ret


toc_1E_451A:
    call toc_1E_4482
    call toc_1E_4497
    ld   [$D301], a
    call toc_1E_4482
    call toc_1E_4497
    ld   [$D302], a
    jr   toc_1E_452E.toc_1E_4537

toc_1E_452E:
    call toc_1E_4482
    call toc_1E_4497
    ld   [$D300], a
.toc_1E_4537:
    call toc_1E_4482
    jr   toc_1E_457C.toc_1E_45A0

toc_1E_453C:
    call toc_1E_4482
    call toc_1E_4497
    push hl
    ld   a, l
    add  a, $0B
    ld   l, a
    ld   c, [hl]
    ld   a, b
    or   c
    ld   [hl], a
    ld   b, h
    ld   c, l
    dec  c
    dec  c
    pop  hl
    ldi  a, [hl]
    ld   e, a
    ldd  a, [hl]
    ld   d, a
    inc  de
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldd  [hl], a
    ld   a, d
    ld   [bc], a
    dec  c
    ld   a, e
    ld   [bc], a
    jr   toc_1E_457C.toc_1E_45A0

toc_1E_4560:
    push hl
    ld   a, l
    add  a, $0B
    ld   l, a
    ld   a, [hl]
    dec  [hl]
    ld   a, [hl]
    and  %01111111
    jr   z, .else_1E_4579

    ld   b, h
    ld   c, l
    dec  c
    dec  c
    dec  c
    pop  hl
    ld   a, [bc]
    ldi  [hl], a
    inc  c
    ld   a, [bc]
    ldd  [hl], a
    jr   toc_1E_457C.toc_1E_45A0

.else_1E_4579:
    pop  hl
    jr   toc_1E_452E.toc_1E_4537

toc_1E_457C:
    ld   hl, $D369
    ld   a, [hl]
    and  a
    ret  z

    ifZero [$D3CE], toc_1E_401E.toc_1E_402B

    call toc_1E_4382
    assign [$D350], $01
    ld   hl, $D310
.toc_1E_4594:
    inc  l
    ldi  a, [hl]
    and  a
    jp   z, toc_1E_44A1.toc_1E_44D2

    dec  [hl]
    jp   nz, toc_1E_44A1

.toc_1E_459E:
    inc  l
    inc  l
.toc_1E_45A0:
    call toc_1E_4497
    cp   $00
    jp   z, toc_1E_44D7

    cp   $9D
    jp   z, toc_1E_4452

    cp   $9E
    jp   z, toc_1E_451A

    cp   $9F
    jp   z, toc_1E_452E

    cp   $9B
    jp   z, toc_1E_453C

    cp   $9C
    jp   z, toc_1E_4560

    cp   $99
    jp   z, toc_1E_4869

    cp   $9A
    jp   z, toc_1E_4874

    cp   $94
    jp   z, toc_1E_48B3

    cp   $97
    jp   z, toc_1E_48E8

    cp   $98
    jp   z, toc_1E_48F7

    cp   $96
    jp   z, toc_1E_485B

    cp   $95
    jp   z, toc_1E_4866

    and  %11110000
    cp   $A0
    jr   nz, .else_1E_4637

    ld   a, b
    and  %00001111
    ld   c, a
    ld   b, $00
    push hl
    ld   de, $D301
    ld   a, [de]
    ld   l, a
    inc  e
    ld   a, [de]
    ld   h, a
    add  hl, bc
    ld   a, [hl]
    pop  hl
    push hl
    ld   d, a
    inc  l
    inc  l
    inc  l
    ld   a, [hl]
    and  %11110000
    jr   nz, .else_1E_4609

    ld   a, d
    jr   .toc_1E_462E

.else_1E_4609:
    ld   e, a
    ld   a, d
    push af
    srl  a
    sla  e
    jr   c, .else_1E_461A

    ld   d, a
    srl  a
    sla  e
    jr   c, .else_1E_461A

    add  a, d
.else_1E_461A:
    ld   c, a
    and  a
    jr   nz, .else_1E_4620

    ld   c, $02
.else_1E_4620:
    ld   de, $D350
    ld   a, [de]
    dec  a
    ld   e, a
    ld   d, $00
    ld   hl, $D307
    add  hl, de
    ld   [hl], c
    pop  af
.toc_1E_462E:
    pop  hl
    dec  l
    ldi  [hl], a
    call toc_1E_4482
    call toc_1E_4497
.else_1E_4637:
    ifEq [$D350], $04, .else_1E_4676

    push de
    ld   de, $D3B0
    call toc_1E_4937
    xor  a
    ld   [de], a
    inc  e
    ld   [de], a
    ld   de, $D3B6
    call toc_1E_4937
    inc  e
    xor  a
    ld   [de], a
    ifNe [$D350], $03, .else_1E_4675

    ld   de, $D39E
    ld   a, [de]
    and  a
    jr   z, .else_1E_4667

    ld   a, $01
    ld   [de], a
    clear [$D39F]
.else_1E_4667:
    ld   de, $D3D9
    ld   a, [de]
    and  a
    jr   z, .else_1E_4675

    ld   a, $01
    ld   [de], a
    clear [$D3DA]
.else_1E_4675:
    pop  de
.else_1E_4676:
    ld   c, b
    ld   b, $00
    call toc_1E_4482
    ld   a, [$D350]
    cp   $04
    jp   z, .else_1E_46B8

    push hl
    ld   a, l
    add  a, $05
    ld   l, a
    ld   e, l
    ld   d, h
    inc  l
    inc  l
    ld   a, c
    cp   $01
    jr   z, .else_1E_46B3

    ld   [hl], $00
    ifNotZero [$D300], .else_1E_46A6

    ld   l, a
    ld   h, $00
    bit  7, l
    jr   z, .else_1E_46A3

    ld   h, $FF
.else_1E_46A3:
    add  hl, bc
    ld   b, h
    ld   c, l
.else_1E_46A6:
    ld   hl, $49BA
    add  hl, bc
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ld   a, [hl]
    ld   [de], a
    pop  hl
    jp   .toc_1E_46E9

.else_1E_46B3:
    ld   [hl], $01
    pop  hl
    jr   .toc_1E_46E9

.else_1E_46B8:
    push hl
    ld   a, c
    cp   $FF
    jr   z, .else_1E_46D6

    ld   de, $D346
    ld   hl, $4A4C
    add  hl, bc
.loop_1E_46C5:
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ld   a, e
    cp   $4B
    jr   nz, .loop_1E_46C5

    ld   c, $20
    ld   hl, $D344
    ld   b, $00
    jr   .toc_1E_4717

.else_1E_46D6:
    ld   a, [$D34F]
    bit  7, a
    jp   nz, .else_1E_4748

    assign [$D378], $01
    call toc_1E_403F
    jp   .else_1E_4748

.toc_1E_46E9:
    push hl
    ld   b, $00
    ifEq [$D350], $01, .else_1E_4714

    cp   $02
    jr   z, .else_1E_4710

    ld   c, $1A
    ld   a, [$D33F]
    bit  7, a
    jr   nz, .else_1E_4705

    xor  a
    ld   [$ff00+c], a
    ld   a, $80
    ld   [$ff00+c], a
.else_1E_4705:
    inc  c
    inc  l
    inc  l
    inc  l
    inc  l
    ldi  a, [hl]
    ld   e, a
    ld   d, $00
    jr   .toc_1E_471E

.else_1E_4710:
    ld   c, $16
    jr   .toc_1E_4717

.else_1E_4714:
    ld   c, $10
    inc  c
.toc_1E_4717:
    inc  l
    inc  l
    ldi  a, [hl]
    ld   e, a
    inc  l
    ldi  a, [hl]
    ld   d, a
.toc_1E_471E:
    push hl
    inc  l
    inc  l
    ldi  a, [hl]
    and  a
    jr   z, .else_1E_4727

    ld   e, $08
.else_1E_4727:
    inc  l
    inc  l
    ld   [hl], $00
    inc  l
    ld   a, [hl]
    pop  hl
    bit  7, a
    jr   nz, .else_1E_4748

    ld   a, [$D350]
    cp   $03
    jp   z, toc_1E_432A

.toc_1E_473A:
    ld   a, d
    or   b
    ld   [$ff00+c], a
    inc  c
    ld   a, e
    ld   [$ff00+c], a
    inc  c
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    ld   a, [hl]
    or   %10000000
    ld   [$ff00+c], a
.else_1E_4748:
    pop  hl
    dec  l
    ldd  a, [hl]
    ldd  [hl], a
    dec  l
.toc_1E_474D:
    ld   de, $D350
    ld   a, [de]
    cp   $04
    jr   z, .else_1E_475E

    inc  a
    ld   [de], a
    ld   a, $10
    add  a, l
    ld   l, a
    jp   .toc_1E_4594

.else_1E_475E:
    incAddr $D31E
    incAddr $D32E
    incAddr $D33E
    ret


toc_1E_476B:
    pop  hl
    ret


toc_1E_476D:
    push hl
    ld   a, l
    add  a, $06
    ld   l, a
    ld   a, [hl]
    and  %00001111
    jr   z, .else_1E_478F

    ld   [$D351], a
    ld   a, [$D350]
    ld   c, $13
    cp   $01
    jr   z, .else_1E_47D1

    ld   c, $18
    cp   $02
    jr   z, .else_1E_47D1

    ld   c, $1D
    cp   $03
    jr   z, .else_1E_47D1

.else_1E_478F:
    ld   a, [$D350]
    cp   $04
    jp   z, toc_1E_476B

    ld   de, $D3B6
    call toc_1E_4937
    ld   a, [de]
    and  a
    jp   z, .else_1E_47B8

    ld   a, [$D350]
    ld   c, $13
    cp   $01
    jp   z, toc_1E_4900

    ld   c, $18
    cp   $02
    jp   z, toc_1E_4900

    ld   c, $1D
    jp   toc_1E_4900

.else_1E_47B8:
    ld   a, [$D350]
    cp   $03
    jp   nz, toc_1E_476B

    ifZero [$D39E], toc_1E_487D

    ifZero [$D3D9], toc_1E_48BE

    jp   toc_1E_476B

.else_1E_47D1:
    inc  l
    ldi  a, [hl]
    ld   e, a
    ld   a, [hl]
    and  %00001111
    ld   d, a
    push de
    ld   a, l
    add  a, $04
    ld   l, a
    ld   b, [hl]
    ld   a, [$D351]
    cp   $01
    jp   z, toc_1E_494D

    ld   hl, gbIE
    pop  de
    add  hl, de
    call toc_1E_4926
    jp   .else_1E_478F

toc_1E_47F1:
    _ifZero [$D31B], .else_1E_4818

    ifNotZero [$D317], .else_1E_4818

    and  %00001111
    ld   b, a
    ld   hl, $D307
    ld   a, [$D31E]
    cp   [hl]
    jr   nz, .else_1E_4818

    ld   c, $12
    ld   de, $D31A
    ld   a, [$D31F]
    bit  7, a
    jr   nz, .else_1E_4818

    call toc_1E_483C
.else_1E_4818:
    ld   a, [$D32B]
    and  a
    ret  nz

    ld   a, [$D327]
    and  a
    ret  z

    and  %00001111
    ld   b, a
    ld   hl, $D308
    ld   a, [$D32E]
    cp   [hl]
    ret  nz

    ld   a, [$D32F]
    bit  7, a
    ret  nz

    ld   c, $17
    ld   de, $D32A
    call toc_1E_483C
    ret


toc_1E_483C:
    push bc
    dec  b
    ld   c, b
    ld   b, $00
    ld   hl, $4B10
    add  hl, bc
    ld   a, [hl]
    pop  bc
    ld   [$ff00+c], a
    inc  c
    inc  c
    ld   a, [de]
    or   %10000000
    ld   [$ff00+c], a
    ret


toc_1E_484F:
    clear [$D3CE]
    copyFromTo [hNextDefaultMusicTrack], [$D368]
    jp   toc_1E_401E

toc_1E_485B:
    ld   a, $01
.toc_1E_485D:
    ld   [$D3CD], a
    call toc_1E_4482
    jp   toc_1E_457C.toc_1E_45A0

toc_1E_4866:
    xor  a
    jr   toc_1E_485B.toc_1E_485D

toc_1E_4869:
    ld   a, $01
.toc_1E_486B:
    ld   [$D39E], a
    call toc_1E_4482
    jp   toc_1E_457C.toc_1E_45A0

toc_1E_4874:
    clear [$D3D9]
    ld   [$D3DA], a
    jr   toc_1E_4869.toc_1E_486B

toc_1E_487D:
    cp   $02
    jp   z, toc_1E_476B

    ld   bc, $D39F
    call toc_1E_48AF
    ld   c, $1C
    ld   b, $40
    cp   $03
    jr   z, .else_1E_48AA

    ld   b, $60
    cp   $05
    jr   z, .else_1E_48AA

    cp   $0A
    jr   z, .else_1E_48AA

    ld   b, $00
    cp   $07
    jr   z, .else_1E_48AA

    cp   $0D
    jp   nz, toc_1E_476B

    assign [$D39E], $02
.else_1E_48AA:
    ld   a, b
    ld   [$ff00+c], a
    jp   toc_1E_476B

toc_1E_48AF:
    ld   a, [bc]
    inc  a
    ld   [bc], a
    ret


toc_1E_48B3:
    assign [$D3D9], $01
    call toc_1E_4482
    jp   toc_1E_457C.toc_1E_45A0

toc_1E_48BE:
    cp   $02
    jp   z, toc_1E_476B

    ld   bc, $D3DA
    call toc_1E_48AF
    ld   c, $1C
    ld   b, $60
    cp   $03
    jp   z, toc_1E_487D.else_1E_48AA

    ld   b, $40
    cp   $05
    jp   z, toc_1E_487D.else_1E_48AA

    ld   b, $20
    cp   $06
    jp   nz, toc_1E_476B

    assign [$D3D9], $02
    jp   toc_1E_487D.else_1E_48AA

toc_1E_48E8:
    ld   de, $D3B6
    call toc_1E_4937
    ld   a, $01
.toc_1E_48F0:
    ld   [de], a
    call toc_1E_4482
    jp   toc_1E_457C.toc_1E_45A0

toc_1E_48F7:
    ld   de, $D3B6
    call toc_1E_4937
    xor  a
    jr   toc_1E_48E8.toc_1E_48F0

toc_1E_4900:
    inc  e
    ld   a, [de]
    and  a
    jr   nz, .else_1E_4916

    inc  a
    ld   [de], a
    pop  hl
    push hl
    call toc_1E_491B
.toc_1E_490C:
    ld   hl, $FF9C
    add  hl, de
    call toc_1E_4926
    jp   toc_1E_476B

.else_1E_4916:
    call toc_1E_4940
    jr   .toc_1E_490C

toc_1E_491B:
    ld   a, $07
    add  a, l
    ld   l, a
    ldi  a, [hl]
    ld   e, a
    ld   a, [hl]
    and  %00001111
    ld   d, a
    ret


toc_1E_4926:
    ld   de, $D3A4
    call toc_1E_4937
    ld   a, l
    ld   [$ff00+c], a
    ld   [de], a
    inc  c
    inc  e
    ld   a, h
    and  %00001111
    ld   [$ff00+c], a
    ld   [de], a
    ret


toc_1E_4937:
    ld   a, [$D350]
    dec  a
    sla  a
    add  a, e
    ld   e, a
    ret


toc_1E_4940:
    ld   de, $D3A4
    call toc_1E_4937
    ld   a, [de]
    ld   l, a
    inc  e
    ld   a, [de]
    ld   d, a
    ld   e, l
    ret


toc_1E_494D:
    pop  de
    ld   de, $D3B0
    call toc_1E_4937
    ld   a, [de]
    inc  a
    ld   [de], a
    inc  e
    cp   $19
    jr   z, .else_1E_498D

    cp   $2D
    jr   z, .else_1E_4986

    ld   a, [de]
    and  a
    jp   z, toc_1E_476D.else_1E_478F

.toc_1E_4965:
    dec  e
    ld   a, [de]
    sub  a, $19
    sla  a
    ld   l, a
    ld   h, $00
    ld   de, $4992
    add  hl, de
    ldi  a, [hl]
    ld   d, a
    ld   a, [hl]
    ld   e, a
    pop  hl
    push hl
    push de
    call toc_1E_491B
    ld   h, d
    ld   l, e
    pop  de
    add  hl, de
    call toc_1E_4926
    jp   toc_1E_476D.else_1E_478F

.else_1E_4986:
    dec  e
    ld   a, $19
    ld   [de], a
    inc  e
    jr   .toc_1E_4965

.else_1E_498D:
    ld   a, $01
    ld   [de], a
    jr   .toc_1E_4965

    db   $00, $00, $00, $00, $00, $01, $00, $01
    db   $00, $02, $00, $02, $00, $00, $00, $00
    db   $FF, $FF, $FF, $FF, $FF, $FE, $FF, $FE
    db   $00, $00, $00, $01, $00, $02, $00, $01
    db   $00, $00, $FF, $FF, $FF, $FE, $FF, $FF
    db   $00, $0F, $2C, $00, $9C, $00, $06, $01
    db   $6B, $01, $C9, $01, $23, $02, $77, $02
    db   $C6, $02, $12, $03, $56, $03, $9B, $03
    db   $DA, $03, $16, $04, $4E, $04, $83, $04
    db   $B5, $04, $E5, $04, $11, $05, $3B, $05
    db   $63, $05, $89, $05, $AC, $05, $CE, $05
    db   $ED, $05, $0A, $06, $27, $06, $42, $06
    db   $5B, $06, $72, $06, $89, $06, $9E, $06
    db   $B2, $06, $C4, $06, $D6, $06, $E7, $06
    db   $F7, $06, $06, $07, $14, $07, $21, $07
    db   $2D, $07, $39, $07, $44, $07, $4F, $07
    db   $59, $07, $62, $07, $6B, $07, $74, $07
    db   $7B, $07, $83, $07, $8A, $07, $90, $07
    db   $97, $07, $9D, $07, $A2, $07, $A7, $07
    db   $AC, $07, $B1, $07, $B6, $07, $BA, $07
    db   $BE, $07, $C1, $07, $C5, $07, $C8, $07
    db   $CB, $07, $CE, $07, $D1, $07, $D4, $07
    db   $D6, $07, $D9, $07, $DB, $07, $DD, $07
    db   $DF, $07, $00, $00, $00, $00, $00, $C0
    db   $09, $00, $38, $34, $C0, $19, $00, $38
    db   $33, $C0, $46, $00, $13, $10, $C0, $23
    db   $00, $20, $40, $80, $51, $00, $20, $07
    db   $80, $A1, $00, $00, $18, $80, $F2, $00
    db   $00, $18, $80, $81, $00, $3A, $10, $C0
    db   $80, $00, $00, $10, $C0, $57, $00, $00
    db   $60, $80, $10, $00, $00, $10, $80, $01
    db   $02, $04, $08, $10, $20, $06, $0C, $18
    db   $01, $01, $01, $01, $01, $30, $01, $03
    db   $06, $0C, $18, $30, $09, $12, $24, $02
    db   $04, $08, $01, $01, $48, $02, $04, $08
    db   $10, $20, $40, $0C, $18, $30, $02, $05
    db   $03, $01, $01, $60, $03, $05, $0A, $14
    db   $28, $50, $0F, $1E, $3C, $02, $08, $10
    db   $02, $01, $78, $03, $06, $0C, $18, $30
    db   $60, $12, $24, $48, $03, $08, $10, $02
    db   $04, $90, $03, $07, $0E, $1C, $38, $70
    db   $15, $2A, $54, $04, $09, $12, $02, $01
    db   $A8, $04, $08, $10, $20, $40, $80, $18
    db   $30, $60, $04, $02, $01, $01, $00, $C0
    db   $04, $09, $12, $24, $48, $90, $1B, $36
    db   $6C, $05, $0C, $18, $18, $06, $D8, $05
    db   $0A, $14, $28, $50, $A0, $1E, $3C, $78
    db   $05, $01, $01, $01, $01, $F0, $10, $32
    db   $22, $47, $60, $20, $00, $1D, $4B, $FF
    db   $FF, $17, $4B, $9B, $20, $AE, $01, $9C
    db   $00, $00, $C5, $4A, $3B, $4B, $43, $4B
    db   $4B, $4B, $53, $4B, $00, $C5, $4A, $39
    db   $4B, $41, $4B, $49, $4B, $51, $4B, $59
    db   $4B, $60, $4B, $FF, $FF, $3B, $4B, $82
    db   $4B, $92, $4B, $FF, $FF, $43, $4B, $14
    db   $4C, $19, $4C, $FF, $FF, $4B, $4B, $25
    db   $4C, $2A, $4C, $FF, $FF, $53, $4B, $A5
    db   $01, $A8, $01, $AA, $01, $00, $9D, $10
    db   $00, $80, $9B, $04, $A1, $7C, $76, $6E
    db   $64, $9C, $9B, $04, $7E, $78, $70, $66
    db   $9C, $9B, $04, $7C, $76, $6E, $64, $9C
    db   $9B, $04, $78, $72, $6A, $60, $9C, $00
    db   $9D, $60, $81, $41, $AA, $01, $56, $60
    db   $6A, $60, $66, $A5, $64, $A3, $01, $00
    db   $9D, $34, $00, $00, $9B, $03, $A1, $7C
    db   $76, $6E, $64, $9C, $9D, $43, $00, $00
    db   $7C, $76, $6E, $64, $9D, $62, $00, $00
    db   $7E, $78, $70, $66, $9D, $43, $00, $00
    db   $7E, $78, $70, $66, $9D, $34, $00, $00
    db   $9B, $02, $7E, $78, $70, $66, $9C, $9B
    db   $02, $7C, $76, $6E, $64, $9C, $9D, $43
    db   $00, $00, $7C, $76, $6E, $64, $9D, $62
    db   $00, $00, $7C, $76, $6E, $64, $9D, $82
    db   $00, $00, $78, $72, $6A, $60, $9D, $62
    db   $00, $00, $78, $72, $6A, $60, $9D, $43
    db   $00, $00, $9B, $02, $78, $72, $6A, $60
    db   $9C, $00, $66, $66, $66, $66, $00, $00
    db   $00, $00, $66, $66, $66, $66, $00, $00
    db   $00, $00, $00, $22, $44, $55, $66, $66
    db   $88, $88, $AA, $AA, $CC, $CC, $04, $84
    db   $04, $84, $A5, $01, $A8, $01, $00, $9D
    db   $F4, $4B, $20, $99, $9B, $20, $A2, $04
    db   $1C, $9C, $00, $A5, $01, $A8, $01, $00
    db   $9B, $20, $A2, $1A, $A1, $1A, $1A, $9C
    db   $00, $02, $B6, $4A, $3E, $4C, $4C, $4C
    db   $60, $4C, $66, $4C, $6C, $4C, $82, $4C
    db   $94, $4C, $A6, $4C, $94, $4C, $FF, $FF
    db   $40, $4C, $73, $4C, $82, $4C, $78, $4C
    db   $94, $4C, $7D, $4C, $A6, $4C, $78, $4C
    db   $94, $4C, $FF, $FF, $4C, $4C, $B8, $4C
    db   $FF, $FF, $60, $4C, $EB, $4C, $FF, $FF
    db   $66, $4C, $9D, $43, $00, $03, $A0, $01
    db   $00, $9D, $43, $00, $00, $00, $9D, $71
    db   $00, $00, $00, $9D, $91, $00, $00, $00
    db   $9B, $02, $A1, $48, $4C, $4E, $A6, $5C
    db   $A1, $48, $4C, $4E, $A6, $5A, $A3, $01
    db   $9C, $00, $9B, $02, $A1, $4C, $50, $52
    db   $A6, $60, $A1, $4C, $50, $52, $A6, $5E
    db   $A3, $01, $9C, $00, $9B, $02, $A1, $50
    db   $54, $56, $A6, $64, $A1, $50, $54, $56
    db   $A6, $62, $A3, $01, $9C, $00, $9D, $04
    db   $4C, $20, $99, $9B, $02, $A2, $30, $18
    db   $18, $30, $18, $18, $30, $18, $9C, $9B
    db   $02, $34, $1C, $1C, $34, $1C, $1C, $34
    db   $1C, $9C, $9B, $02, $38, $20, $20, $38
    db   $20, $20, $38, $20, $9C, $9B, $02, $34
    db   $1C, $1C, $34, $1C, $1C, $34, $1C, $9C
    db   $00, $9B, $02, $A1, $1A, $1A, $1A, $A6
    db   $1A, $9C, $A1, $1A, $15, $15, $15, $00
    db   $AF, $EA, $79, $D3, $EA, $4F, $D3, $EA
    db   $98, $D3, $EA, $93, $D3, $EA, $C9, $D3
    db   $EA, $A3, $D3, $EA, $E5, $D3, $3E, $08
    db   $E0, $21, $3E, $80, $E0, $23

toc_1E_4D18:
    assign [gbAUDTERM], %11111111
    assign [$D355], $03
    clear [$D369]
.toc_1E_4D25:
    clear [$D361]
    ld   [$D371], a
    ld   [$D31F], a
    ld   [$D32F], a
    ld   [$D33F], a
    ld   [$D39E], a
    ld   [$D39F], a
    ld   [$D3D9], a
    ld   [$D3DA], a
    ld   [$D3B6], a
    ld   [$D3B7], a
    ld   [$D3B8], a
    ld   [$D3B9], a
    ld   [$D3BA], a
    ld   [$D3BB], a
    ld   [$D394], a
    ld   [$D395], a
    ld   [$D396], a
    ld   [$D390], a
    ld   [$D391], a
    ld   [$D392], a
    ld   [$D3C6], a
    ld   [$D3C7], a
    ld   [$D3C8], a
    ld   [$D3A0], a
    ld   [$D3A1], a
    ld   [$D3A2], a
    ld   [$D3CD], a
    ld   [$D3D6], a
    ld   [$D3D7], a
    ld   [$D3D8], a
    ld   [$D3DC], a
    ld   [$D3E7], a
    ld   [$D3E2], a
    ld   [$D3E3], a
    ld   [$D3E4], a
    assign [gbAUD1ENV], $08
    ld   [gbAUD2ENV], a
    assign [gbAUD1HIGH], $80
    ld   [gbAUD2HIGH], a
    clear [gbAUD1SWEEP]
    ld   [gbAUD3ENA], a
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
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $E3, $4A, $0B
    db   $50, $2F, $50, $53, $50, $00, $00, $13
    db   $6E, $6F, $50, $AC, $6E, $A1, $50, $A8
    db   $6E, $22, $6E, $A8, $50, $09, $6E, $2A
    db   $6D, $47, $51, $47, $51, $15, $6D, $B0
    db   $6E, $10, $6D, $09, $6E, $51, $51, $E3
    db   $51, $00, $00, $B7, $50, $AC, $6E, $FF
    db   $6D, $ED, $50, $A8, $6E, $F2, $50, $CD
    db   $6D, $47, $51, $09, $6E, $47, $51, $15
    db   $6D, $B0, $6E, $BE, $6D, $51, $51, $2D
    db   $6D, $18, $6E, $E3, $51, $00, $00, $63
    db   $6E, $00, $51, $AC, $6E, $31, $51, $A8
    db   $6E, $54, $6E, $38, $51, $72, $6E, $27
    db   $6D, $47, $51, $77, $6E, $47, $51, $FF
    db   $FF, $30, $6D, $9B, $02, $A2, $12, $2A
    db   $12, $18, $30, $9C, $16, $2E, $16, $1C
    db   $34, $16, $2E, $14, $2C, $9B, $02, $A2
    db   $12, $2A, $12, $18, $30, $9C, $1A, $32
    db   $1A, $20, $38, $1A, $32, $18, $30, $9B
    db   $02, $16, $2E, $16, $1C, $34, $9C, $22
    db   $3A, $22, $28, $40, $00, $A2, $16, $2E
    db   $16, $1C, $34, $00, $A2, $22, $3A, $22
    db   $28, $40, $A2, $2E, $46, $2E, $34, $4C
    db   $A5, $01, $00, $9D, $97, $86, $80, $A7
    db   $42, $A4, $34, $A6, $01, $A1, $38, $3A
    db   $3E, $A3, $40, $A4, $58, $A7, $01, $42
    db   $A4, $34, $A6, $01, $A1, $38, $3A, $4C
    db   $A3, $4A, $A4, $48, $A7, $01, $9D, $B7
    db   $86, $80, $A7, $46, $A4, $38, $A6, $01
    db   $A1, $3E, $40, $42, $A3, $44, $A7, $5C
    db   $00, $A3, $32, $A7, $4A, $00, $9D, $89
    db   $86, $81, $A3, $48, $A7, $60, $A8, $80
    db   $01, $A2, $01, $00, $9B, $02, $A2, $04
    db   $1C, $04, $0A, $22, $9C, $08, $20, $08
    db   $0E, $26, $08, $20, $06, $1E, $9B, $02
    db   $04, $1C, $04, $0A, $22, $9C, $0C, $24
    db   $0C, $12, $2A, $0C, $24, $0A, $22, $9B
    db   $02, $08, $20, $08, $0E, $26, $9C, $14
    db   $2C, $14, $1A, $32, $00, $A2, $08, $20
    db   $08, $0E, $26, $00, $A2, $14, $2C, $14
    db   $1A, $32, $A2, $20, $38, $20, $26, $3E
    db   $A5, $01, $00, $A1, $48, $50, $54, $5C
    db   $60, $68, $6C, $74, $00, $A3, $3C, $2E
    db   $01, $A1, $2E, $32, $36, $38, $A3, $01
    db   $38, $2A, $A1, $2A, $2E, $32, $36, $A2
    db   $01, $6C, $5E, $24, $16, $5E, $A1, $5E
    db   $62, $66, $A6, $68, $A2, $68, $5A, $20
    db   $12, $5A, $A1, $5A, $5E, $62, $66, $A2
    db   $01, $84, $76, $3C, $2E, $76, $A1, $76
    db   $7A, $7E, $A6, $80, $A2, $80, $72, $38
    db   $2A, $72, $A1, $72, $76, $7A, $7E, $A2
    db   $38, $66, $58, $38, $20, $58, $A1, $58
    db   $5C, $5E, $62, $A2, $36, $62, $54, $6C
    db   $A1, $36, $3C, $44, $4A, $4E, $54, $5C
    db   $62, $A2, $32, $5E, $50, $32, $4A, $50
    db   $A1, $50, $54, $58, $5C, $A2, $2E, $5C
    db   $4E, $66, $A1, $2E, $36, $3C, $44, $46
    db   $4E, $54, $5C, $A2, $2A, $58, $A1, $4A
    db   $50, $58, $62, $A2, $26, $54, $A1, $46
    db   $A0, $01, $A1, $4C, $A0, $01, $A1, $54
    db   $A0, $01, $A1, $5E, $A4, $01, $00, $9E
    db   $D4, $4A, $A1, $32, $3C, $46, $9B, $02
    db   $0C, $01, $01, $9C, $3C, $40, $44, $46
    db   $4A, $01, $0C, $3C, $46, $50, $0C, $01
    db   $01, $0C, $01, $46, $50, $5A, $01, $0C
    db   $0C, $01, $0C, $01, $00, $00, $D4, $4A
    db   $14, $52, $1E, $52, $26, $52, $2E, $52
    db   $15, $6D, $E1, $6D, $53, $52, $FF, $FF
    db   $16, $52, $31, $6E, $34, $52, $FF, $FF
    db   $1E, $52, $63, $6E, $74, $52, $FF, $FF
    db   $26, $52, $93, $52, $FF, $FF, $2E, $52
    db   $A2, $46, $01, $A7, $3C, $A1, $46, $01
    db   $46, $4A, $4E, $50, $A4, $54, $01, $A2
    db   $5E, $01, $A7, $54, $A1, $5E, $01, $5E
    db   $62, $66, $68, $A4, $6C, $01, $00, $A2
    db   $2A, $01, $A7, $20, $A1, $2A, $01, $2A
    db   $2E, $32, $38, $3E, $A6, $01, $A5, $01
    db   $A2, $42, $01, $A3, $38, $A1, $42, $38
    db   $32, $2A, $2E, $A6, $01, $A8, $01, $00
    db   $9B, $02, $99, $A2, $16, $16, $01, $16
    db   $9C, $9B, $02, $12, $12, $01, $12, $9C
    db   $9B, $02, $0E, $0E, $01, $0E, $9C, $9B
    db   $02, $12, $12, $01, $12, $9C, $00, $9B
    db   $07, $A2, $1A, $A1, $1A, $1A, $9C, $9B
    db   $04, $1A, $9C, $9B, $06, $A2, $1A, $A1
    db   $1A, $1A, $9C, $9B, $08, $1A, $9C, $00
    db   $00, $E3, $4A, $17, $4B, $B7, $52, $17
    db   $4B, $00, $00, $2C, $6E, $DA, $53, $FF
    db   $FF, $B7, $52, $00, $A7, $4A, $F0, $52
    db   $CA, $52, $9A, $53, $BE, $53, $E1, $6D
    db   $CE, $53, $A0, $6E, $15, $6D, $AC, $6E
    db   $27, $6D, $EB, $6D, $98, $54, $D7, $54
    db   $D7, $54, $D7, $54, $DE, $54, $98, $54
    db   $D7, $54, $D7, $54, $D7, $54, $DE, $54
    db   $FF, $FF, $3B, $55, $7C, $6E, $D2, $6D
    db   $11, $54, $A0, $6E, $15, $6D, $AC, $6E
    db   $27, $6D, $40, $6E, $2A, $54, $3B, $54
    db   $2A, $6D, $3B, $54, $40, $6E, $50, $54
    db   $3B, $54, $40, $6E, $61, $54, $3B, $54
    db   $40, $6E, $2A, $54, $3B, $54, $2A, $6D
    db   $3B, $54, $40, $6E, $50, $54, $3B, $54
    db   $40, $6E, $61, $54, $3B, $54, $91, $6E
    db   $40, $6E, $72, $54, $3B, $54, $2A, $6D
    db   $3B, $54, $F0, $6D, $7C, $6E, $AB, $54
    db   $94, $6E, $AB, $54, $8E, $6E, $BA, $54
    db   $7C, $6E, $F0, $6D, $C2, $54, $40, $6E
    db   $2A, $54, $3B, $54, $2A, $6D, $3B, $54
    db   $40, $6E, $50, $54, $3B, $54, $40, $6E
    db   $61, $54, $3B, $54, $40, $6E, $2A, $54
    db   $3B, $54, $2A, $6D, $3B, $54, $40, $6E
    db   $50, $54, $3B, $54, $40, $6E, $61, $54
    db   $3B, $54, $91, $6E, $40, $6E, $72, $54
    db   $3B, $54, $2A, $6D, $3B, $54, $F0, $6D
    db   $7C, $6E, $AB, $54, $94, $6E, $AB, $54
    db   $8E, $6E, $BA, $54, $7C, $6E, $E1, $6D
    db   $C2, $54, $FF, $FF, $31, $55, $54, $6E
    db   $1D, $54, $A0, $6E, $15, $6D, $AC, $6E
    db   $27, $6D, $59, $6E, $82, $54, $F3, $54
    db   $54, $6E, $08, $55, $59, $6E, $82, $54
    db   $F3, $54, $54, $6E, $08, $55, $FF, $FF
    db   $45, $55, $18, $55, $A0, $6E, $2D, $60
    db   $AC, $6E, $1D, $55, $20, $55, $FF, $FF
    db   $C8, $53, $A2, $4E, $4C, $4A, $48, $4E
    db   $50, $52, $54, $A3, $01, $00, $9B, $06
    db   $A0, $48, $46, $9C, $9B, $0A, $46, $44
    db   $9C, $9D, $68, $00, $81, $9B, $06, $44
    db   $42, $9C, $9B, $0A, $42, $40, $9C, $9D
    db   $A8, $00, $81, $9B, $06, $A0, $4C, $4A
    db   $9C, $9B, $0A, $4A, $48, $9C, $9D, $78
    db   $00, $81, $9B, $06, $48, $46, $9C, $9B
    db   $0A, $46, $44, $9C, $00, $A2, $54, $52
    db   $50, $4E, $54, $56, $58, $5A, $A3, $01
    db   $00, $99, $A2, $5A, $58, $56, $54, $5A
    db   $5C, $5E, $60, $A3, $01, $00, $A1, $40
    db   $44, $01, $A5, $46, $A7, $01, $A1, $40
    db   $44, $01, $46, $A2, $01, $4C, $00, $9D
    db   $92, $00, $C0, $A1, $10, $01, $10, $28
    db   $01, $1A, $1C, $01, $10, $01, $12, $01
    db   $12, $04, $01, $00, $A1, $01, $A2, $5E
    db   $A1, $01, $5E, $01, $A9, $5E, $A0, $01
    db   $A4, $5E, $A2, $01, $00, $A1, $01, $A2
    db   $64, $A1, $01, $64, $01, $A9, $64, $A0
    db   $01, $A4, $64, $A2, $01, $00, $A1, $40
    db   $44, $01, $A5, $46, $A4, $01, $A1, $01
    db   $40, $44, $46, $50, $4E, $00, $9B, $14
    db   $99, $A1, $32, $32, $01, $32, $4A, $01
    db   $3C, $3E, $01, $32, $01, $34, $01, $34
    db   $26, $01, $9C, $00, $A1, $04, $9B, $7F
    db   $02, $9C, $A1, $04, $9B, $7F, $02, $9C
    db   $A1, $04, $9B, $3F, $02, $9C, $00, $A1
    db   $52, $52, $52, $50, $A3, $01, $A1, $4E
    db   $01, $01, $4C, $A3, $01, $00, $A1, $52
    db   $52, $52, $50, $A8, $01, $00, $A1, $46
    db   $46, $01, $46, $01, $46, $01, $50, $01
    db   $50, $A2, $50, $97, $A1, $01, $36, $2C
    db   $24, $98, $00, $A1, $10, $9B, $0F, $0E
    db   $9C, $00, $A1, $3C, $3C, $01, $3C, $01
    db   $3C, $01, $3C, $01, $46, $A2, $46, $97
    db   $A1, $01, $2C, $24, $1E, $98, $00, $9B
    db   $03, $A1, $3E, $3E, $01, $3E, $56, $01
    db   $48, $4A, $01, $3E, $01, $40, $01, $40
    db   $32, $01, $9C, $00, $A1, $32, $32, $01
    db   $32, $01, $32, $01, $3C, $01, $3C, $3C
    db   $01, $A3, $01, $00, $A5, $01, $A3, $01
    db   $00, $A6, $01, $00, $9B, $02, $A1, $1A
    db   $1A, $1A, $15, $9C, $1A, $1A, $15, $1A
    db   $1A, $1A, $1A, $1A, $00, $51, $55, $51
    db   $55, $61, $55, $FF, $FF, $FE, $52, $7C
    db   $55, $7C, $55, $A8, $55, $FF, $FF, $D6
    db   $52, $59, $6E, $EC, $55, $EC, $55, $15
    db   $56, $FF, $FF, $A6, $53, $9D, $C4, $83
    db   $80, $A1, $04, $9B, $1F, $02, $9C, $0A
    db   $9B, $1F, $08, $9C, $00, $A1, $10, $9B
    db   $0D, $0E, $9C, $10, $12, $9B, $0F, $14
    db   $9C, $10, $9B, $0E, $0E, $9C, $10, $12
    db   $9B, $07, $14, $9C, $16, $A4, $01, $00
    db   $9D, $84, $86, $80, $9B, $02, $A1, $10
    db   $10, $01, $10, $28, $01, $1A, $1C, $01
    db   $10, $01, $12, $01, $12, $04, $01, $9C
    db   $9B, $02, $16, $16, $01, $16, $2E, $01
    db   $20, $22, $01, $16, $01, $18, $01, $18
    db   $0C, $01, $9C, $00, $A1, $1C, $1C, $01
    db   $1C, $34, $01, $26, $2A, $01, $1C, $9B
    db   $02, $01, $1E, $9C, $12, $01, $22, $22
    db   $01, $22, $3A, $01, $2C, $2E, $01, $22
    db   $9B, $02, $01, $24, $9C, $18, $01, $1C
    db   $1C, $01, $1C, $34, $01, $26, $2A, $01
    db   $1C, $9B, $02, $01, $1E, $9C, $12, $01
    db   $A2, $22, $22, $3A, $A1, $24, $26, $01
    db   $26, $A6, $3E, $A1, $26, $0E, $26, $00
    db   $9B, $02, $99, $A1, $32, $32, $01, $32
    db   $4A, $01, $3C, $3E, $01, $32, $01, $34
    db   $01, $34, $26, $01, $9C, $9B, $02, $38
    db   $38, $01, $38, $50, $01, $42, $44, $01
    db   $38, $01, $3A, $01, $3A, $2E, $01, $9C
    db   $00, $A1, $3E, $3E, $01, $3E, $56, $01
    db   $48, $4C, $01, $3E, $01, $40, $01, $40
    db   $34, $01, $44, $44, $01, $44, $5C, $01
    db   $4E, $50, $01, $44, $01, $46, $01, $46
    db   $3A, $01, $3E, $3E, $01, $3E, $56, $01
    db   $48, $4C, $01, $3E, $01, $40, $01, $40
    db   $34, $01, $A2, $44, $44, $5C, $A1, $46
    db   $48, $01, $48, $A6, $60, $A1, $48, $30
    db   $48, $00, $00, $F2, $4A, $61, $56, $6D
    db   $56, $93, $56, $00, $00, $E1, $6D, $A7
    db   $56, $20, $6D, $20, $6D, $FF, $FF, $45
    db   $57, $9B, $6D, $BC, $56, $45, $6E, $C7
    db   $56, $9B, $6D, $D2, $56, $BC, $56, $45
    db   $6E, $C7, $56, $9B, $6D, $D2, $56, $27
    db   $6E, $E3, $56, $9B, $6D, $D2, $56, $82
    db   $6D, $ED, $56, $FF, $FF, $5F, $57, $59
    db   $6E, $F9, $56, $F9, $56, $54, $6E, $35
    db   $57, $59, $6E, $24, $57, $24, $57, $FF
    db   $FF, $91, $57, $9B, $10, $A5, $01, $9C
    db   $A3, $01, $A1, $0C, $18, $24, $30, $3C
    db   $48, $54, $60, $A5, $01, $A3, $01, $00
    db   $9B, $02, $A2, $6A, $70, $6E, $74, $AE
    db   $01, $9C, $00, $A1, $3A, $40, $3E, $44
    db   $A4, $50, $01, $A8, $01, $00, $A8, $01
    db   $A2, $01, $A1, $78, $76, $9B, $0D, $A0
    db   $78, $76, $9C, $78, $A3, $01, $00, $A1
    db   $6A, $70, $78, $76, $A5, $7E, $A8, $01
    db   $00, $A3, $01, $9B, $0D, $A0, $78, $76
    db   $9C, $78, $A5, $01, $00, $99, $A2, $0A
    db   $01, $A4, $01, $A6, $01, $A1, $0A, $0A
    db   $A6, $01, $A8, $01, $A2, $0A, $0A, $A4
    db   $01, $A6, $01, $A1, $0A, $A2, $0A, $01
    db   $A8, $01, $A2, $0A, $01, $A4, $01, $A6
    db   $01, $A1, $0A, $A2, $0A, $01, $A8, $01
    db   $99, $A2, $0A, $0A, $A4, $01, $A6, $01
    db   $A1, $0A, $0A, $0A, $A8, $01, $A2, $0A
    db   $00, $9A, $A1, $0A, $10, $18, $16, $A5
    db   $1E, $A4, $01, $A1, $20, $18, $10, $0A
    db   $00, $36, $6E, $B1, $57, $40, $6E, $DB
    db   $57, $9B, $6D, $B4, $6E, $08, $58, $E1
    db   $6D, $A7, $56, $20, $6D, $20, $6D, $FF
    db   $FF, $61, $56, $36, $6E, $14, $58, $40
    db   $6E, $3E, $58, $B4, $6E, $15, $6D, $9B
    db   $6D, $BC, $56, $45, $6E, $C7, $56, $9B
    db   $6D, $D2, $56, $BC, $56, $45, $6E, $C7
    db   $56, $9B, $6D, $D2, $56, $27, $6E, $E3
    db   $56, $9B, $6D, $D2, $56, $82, $6D, $ED
    db   $56, $FF, $FF, $6D, $56, $63, $6E, $6B
    db   $58, $54, $6E, $9B, $58, $B4, $6E, $15
    db   $6D, $59, $6E, $F9, $56, $F9, $56, $54
    db   $6E, $35, $57, $59, $6E, $24, $57, $24
    db   $57, $FF, $FF, $93, $56, $A2, $18, $1C
    db   $A4, $1E, $A3, $01, $A2, $18, $1C, $A7
    db   $1E, $A2, $28, $26, $18, $A4, $1C, $AE
    db   $01, $A2, $18, $1C, $A4, $1E, $A3, $01
    db   $A2, $18, $1C, $A7, $1E, $A2, $26, $30
    db   $2E, $A4, $2E, $01, $A5, $01, $00, $A1
    db   $30, $32, $A4, $34, $A2, $01, $A1, $30
    db   $32, $34, $A6, $01, $A3, $40, $A1, $3E
    db   $3C, $48, $4A, $A4, $4C, $A1, $4E, $01
    db   $48, $4A, $4C, $4E, $A2, $01, $A3, $58
    db   $A1, $56, $54, $52, $54, $56, $48, $4A
    db   $01, $A7, $01, $00, $A7, $01, $A1, $78
    db   $76, $9B, $09, $A0, $78, $76, $9C, $00
    db   $A2, $22, $26, $A4, $28, $A3, $01, $A2
    db   $22, $26, $A7, $28, $A2, $32, $30, $22
    db   $A4, $24, $AE, $01, $A2, $22, $26, $A4
    db   $28, $A3, $01, $A2, $22, $26, $A7, $28
    db   $A2, $30, $3A, $38, $A4, $36, $01, $A5
    db   $01, $00, $A1, $3A, $3C, $A4, $3E, $A2
    db   $01, $A1, $3A, $3C, $3E, $A6, $01, $A3
    db   $4A, $A1, $48, $46, $52, $54, $A4, $56
    db   $A1, $58, $01, $52, $54, $56, $58, $A2
    db   $01, $A3, $4A, $A1, $60, $5E, $6A, $6C
    db   $6E, $60, $62, $01, $A7, $01, $00, $9B
    db   $02, $99, $A2, $0A, $0A, $A8, $01, $9C
    db   $9B, $02, $A2, $06, $06, $A8, $01, $9C
    db   $9B, $02, $A2, $0A, $0A, $01, $0A, $01
    db   $0A, $A1, $0A, $0A, $0A, $0A, $9C, $9B
    db   $02, $A2, $1A, $1A, $01, $1A, $01, $1A
    db   $A1, $1A, $1A, $1A, $1A, $9C, $00, $9B
    db   $04, $A1, $0A, $9C, $22, $9B, $07, $0A
    db   $9C, $9B, $04, $0A, $9C, $22, $9B, $07
    db   $0A, $9C, $9B, $04, $0A, $9C, $22, $9B
    db   $07, $0A, $9C, $9B, $04, $0A, $9C, $22
    db   $9B, $07, $0A, $9C, $22, $24, $26, $18
    db   $1A, $01, $A7, $01, $00, $00, $C5, $4A
    db   $D4, $58, $EE, $58, $0C, $59, $00, $00
    db   $27, $6D, $78, $6D, $18, $59, $21, $59
    db   $18, $59, $09, $6E, $29, $59, $31, $59
    db   $31, $59, $31, $59, $31, $59, $FF, $FF
    db   $D6, $58, $09, $6E, $18, $59, $21, $59
    db   $C3, $6D, $18, $59, $29, $59, $A5, $6D
    db   $31, $59, $31, $59, $C3, $6D, $31, $59
    db   $09, $6E, $31, $59, $FF, $FF, $EE, $58
    db   $54, $6E, $6E, $59, $39, $59, $61, $59
    db   $FF, $FF, $0C, $59, $9B, $04, $A2, $48
    db   $4C, $54, $58, $9C, $00, $9B, $04, $44
    db   $48, $50, $54, $9C, $00, $9B, $04, $4A
    db   $4E, $56, $5A, $9C, $00, $9B, $02, $4C
    db   $50, $56, $5C, $9C, $00, $99, $A7, $18
    db   $A2, $18, $A5, $01, $A7, $01, $A2, $16
    db   $A7, $14, $A2, $14, $A5, $01, $A7, $01
    db   $A2, $14, $A7, $0A, $A2, $0A, $A5, $01
    db   $A7, $01, $A2, $0A, $02, $02, $01, $02
    db   $A5, $01, $A7, $01, $00, $9B, $04, $A2
    db   $04, $9C, $AE, $01, $01, $A4, $01, $A2
    db   $18, $00, $9B, $0C, $A5, $01, $9C, $00
    db   $00, $B6, $4A, $17, $4B, $7F, $59, $2F
    db   $5A, $00, $00, $13, $6E, $7C, $6E, $47
    db   $5A, $51, $5A, $1D, $6E, $94, $6E, $47
    db   $5A, $51, $5A, $FA, $6D, $8B, $6E, $47
    db   $5A, $88, $6E, $47, $5A, $E6, $6D, $85
    db   $6E, $47, $5A, $20, $6D, $7C, $6E, $13
    db   $6E, $7C, $6E, $47, $5A, $51, $5A, $1D
    db   $6E, $94, $6E, $47, $5A, $51, $5A, $FA
    db   $6D, $8B, $6E, $47, $5A, $88, $6E, $47
    db   $5A, $E6, $6D, $85, $6E, $47, $5A, $20
    db   $6D, $7C, $6E, $9B, $6D, $77, $5A, $8C
    db   $6D, $7E, $5A, $91, $6D, $84, $5A, $9B
    db   $6D, $84, $5A, $84, $5A, $82, $6D, $84
    db   $5A, $9B, $6D, $8A, $5A, $8C, $6D, $90
    db   $5A, $91, $6D, $84, $5A, $9B, $6D, $84
    db   $5A, $84, $5A, $82, $6D, $84, $5A, $94
    db   $6E, $9B, $6D, $77, $5A, $8C, $6D, $7E
    db   $5A, $91, $6D, $84, $5A, $9B, $6D, $84
    db   $5A, $84, $5A, $82, $6D, $84, $5A, $9B
    db   $6D, $8A, $5A, $8C, $6D, $90, $5A, $91
    db   $6D, $84, $5A, $9B, $6D, $84, $5A, $84
    db   $5A, $82, $6D, $84, $5A, $7C, $6E, $B9
    db   $6D, $3F, $5A, $27, $6E, $96, $5A, $FF
    db   $FF, $7F, $59, $5E, $6E, $6A, $5A, $9F
    db   $5A, $59, $6E, $3F, $5A, $96, $5A, $FF
    db   $FF, $2F, $5A, $A2, $18, $1C, $1E, $14
    db   $18, $1A, $00, $A3, $30, $34, $36, $A4
    db   $44, $18, $A3, $01, $00, $30, $34, $36
    db   $A4, $42, $18, $A3, $01, $30, $34, $36
    db   $A4, $40, $18, $A3, $01, $30, $34, $36
    db   $A4, $42, $18, $A3, $01, $00, $9B, $18
    db   $99, $A3, $18, $18, $A5, $01, $A3, $01
    db   $18, $9C, $00, $9B, $0C, $A1, $24, $2C
    db   $9C, $00, $9B, $04, $24, $2C, $9C, $00
    db   $9B, $04, $22, $2A, $9C, $00, $9B, $0C
    db   $20, $28, $9C, $00, $9B, $04, $20, $28
    db   $9C, $00, $A2, $01, $AE, $0C, $A5, $01
    db   $A7, $01, $00, $9B, $08, $99, $A3, $18
    db   $18, $01, $18, $01, $A4, $30, $A3, $18
    db   $9C, $00, $00, $B6, $4A, $B9, $5A, $D5
    db   $5A, $B1, $5B, $00, $00, $82, $6D, $DF
    db   $5B, $9B, $6D, $DF, $5B, $DF, $5B, $00
    db   $5C, $8C, $6D, $0B, $5C, $0B, $5C, $0B
    db   $5C, $7C, $6E, $0B, $5C, $FF, $FF, $B9
    db   $5A, $82, $6D, $2F, $5C, $2F, $5C, $9B
    db   $6D, $2F, $5C, $82, $6D, $2F, $5C, $82
    db   $6D, $35, $5C, $35, $5C, $9B, $6D, $35
    db   $5C, $82, $6D, $35, $5C, $82, $6D, $3A
    db   $5C, $3A, $5C, $9B, $6D, $3A, $5C, $82
    db   $6D, $3A, $5C, $82, $6D, $3F, $5C, $3F
    db   $5C, $9B, $6D, $3F, $5C, $82, $6D, $3F
    db   $5C, $82, $6D, $2F, $5C, $9B, $6D, $2F
    db   $5C, $8C, $6D, $2F, $5C, $82, $6D, $2F
    db   $5C, $82, $6D, $35, $5C, $9B, $6D, $35
    db   $5C, $8C, $6D, $35, $5C, $82, $6D, $35
    db   $5C, $82, $6D, $3A, $5C, $9B, $6D, $3A
    db   $5C, $8C, $6D, $3A, $5C, $82, $6D, $3A
    db   $5C, $82, $6D, $3F, $5C, $9B, $6D, $3F
    db   $5C, $8C, $6D, $3F, $5C, $82, $6D, $3F
    db   $5C, $82, $6D, $2F, $5C, $9B, $6D, $2F
    db   $5C, $8C, $6D, $2F, $5C, $82, $6D, $2F
    db   $5C, $82, $6D, $35, $5C, $9B, $6D, $35
    db   $5C, $8C, $6D, $35, $5C, $82, $6D, $35
    db   $5C, $82, $6D, $3A, $5C, $9B, $6D, $3A
    db   $5C, $8C, $6D, $3A, $5C, $82, $6D, $3A
    db   $5C, $82, $6D, $3F, $5C, $9B, $6D, $3F
    db   $5C, $8C, $6D, $3F, $5C, $82, $6D, $3F
    db   $5C, $82, $6D, $44, $5C, $8C, $6D, $44
    db   $5C, $9B, $6D, $49, $5C, $8C, $6D, $49
    db   $5C, $20, $6D, $20, $6D, $9B, $6D, $4E
    db   $5C, $94, $6E, $4E, $5C, $20, $6D, $20
    db   $6D, $FF, $FF, $D5, $5A, $67, $5D, $15
    db   $6D, $20, $6D, $20, $6D, $20, $6D, $63
    db   $6E, $5E, $5C, $72, $6E, $8D, $5C, $6D
    db   $6E, $A1, $5C, $72, $6E, $8D, $5C, $6D
    db   $6E, $A1, $5C, $18, $6D, $6D, $6E, $96
    db   $5C, $77, $6E, $A1, $5C, $18, $6D, $FF
    db   $FF, $B1, $5B, $A5, $01, $A3, $01, $9B
    db   $04, $A2, $54, $9C, $AE, $01, $9B, $04
    db   $A2, $52, $9C, $AE, $01, $9B, $04, $A2
    db   $58, $9C, $AE, $01, $9B, $04, $A2, $56
    db   $9C, $A3, $01, $00, $A8, $01, $A2, $01
    db   $5E, $A8, $01, $A2, $01, $60, $00, $9B
    db   $03, $A2, $02, $08, $04, $0C, $9C, $9D
    db   $A2, $83, $C0, $02, $08, $04, $0C, $9D
    db   $C2, $83, $C0, $02, $08, $04, $0C, $9D
    db   $81, $83, $C0, $9B, $03, $02, $08, $04
    db   $0C, $9C, $00, $9B, $04, $A2, $60, $9C
    db   $00, $9B, $04, $5E, $9C, $00, $9B, $04
    db   $64, $9C, $00, $9B, $04, $62, $9C, $00
    db   $9B, $04, $6A, $9C, $00, $9B, $04, $6C
    db   $9C, $00, $A2, $30, $34, $36, $44, $A5
    db   $01, $A2, $01, $42, $34, $42, $A5, $01
    db   $01, $00, $99, $A2, $18, $1C, $1E, $2C
    db   $AE, $01, $A2, $18, $1C, $1E, $2A, $AE
    db   $01, $A2, $1C, $20, $22, $30, $AE, $01
    db   $A2, $1C, $20, $22, $2E, $AE, $01, $A2
    db   $26, $2A, $2C, $3A, $A4, $01, $A2, $28
    db   $2C, $2E, $3C, $9B, $09, $A4, $01, $9C
    db   $00, $A3, $01, $A2, $60, $64, $66, $74
    db   $A3, $01, $A5, $01, $9B, $03, $A2, $5A
    db   $60, $5E, $62, $9C, $00, $A2, $5A, $60
    db   $5E, $62, $00, $00, $D4, $4A, $B2, $5C
    db   $00, $5D, $2C, $5D, $00, $00, $09, $6E
    db   $6D, $5D, $13, $6E, $6D, $5D, $CD, $6D
    db   $6D, $5D, $13, $6E, $6D, $5D, $87, $6D
    db   $75, $5D, $09, $6E, $6D, $5D, $6D, $5D
    db   $18, $6D, $24, $6D, $24, $6D, $2D, $6D
    db   $09, $6E, $6D, $5D, $13, $6E, $6D, $5D
    db   $CD, $6D, $6D, $5D, $13, $6E, $6D, $5D
    db   $87, $6D, $86, $5D, $0E, $6E, $6D, $5D
    db   $13, $6E, $6D, $5D, $CD, $6D, $6D, $5D
    db   $24, $6D, $24, $6D, $0E, $6E, $98, $5D
    db   $FF, $FF, $B2, $5C, $45, $6E, $36, $5D
    db   $13, $6E, $4D, $5D, $09, $6E, $6D, $5D
    db   $13, $6E, $6D, $5D, $09, $6E, $6D, $5D
    db   $2D, $6D, $2D, $6D, $09, $6E, $6D, $5D
    db   $0E, $6E, $6D, $5D, $13, $6E, $6D, $5D
    db   $2D, $6D, $2D, $6D, $FF, $FF, $00, $5D
    db   $5E, $6E, $36, $5D, $67, $5D, $FF, $FF
    db   $2C, $5D, $A4, $18, $A3, $1C, $1E, $A5
    db   $16, $9B, $04, $01, $9C, $A4, $18, $A3
    db   $1C, $1E, $A5, $24, $9B, $04, $01, $9C
    db   $00, $A4, $60, $A3, $64, $66, $A4, $74
    db   $5E, $A3, $62, $64, $A4, $72, $6E, $A3
    db   $72, $74, $A4, $82, $70, $A3, $74, $76
    db   $A4, $84, $00, $9B, $09, $A5, $01, $9C
    db   $00, $AA, $48, $54, $56, $60, $56, $54
    db   $00, $A1, $01, $AD, $01, $A3, $01, $74
    db   $72, $01, $74, $72, $A4, $01, $A2, $74
    db   $72, $00, $A1, $01, $AD, $01, $01, $A3
    db   $01, $7A, $78, $01, $7A, $78, $A4, $01
    db   $A2, $7A, $78, $00, $A0, $01, $01, $9B
    db   $03, $A3, $48, $3C, $9C, $9B, $03, $46
    db   $3A, $9C, $9B, $03, $3E, $32, $9C, $9B
    db   $06, $40, $34, $9C, $AE, $01, $00, $00
    db   $B6, $4A, $BE, $5D, $C6, $5D, $17, $4B
    db   $00, $00, $09, $6E, $D6, $5D, $FF, $FF
    db   $BE, $5D, $0E, $6E, $20, $5E, $13, $6E
    db   $4D, $5E, $CD, $6D, $5F, $5E, $FF, $FF
    db   $C6, $5D, $A3, $01, $A2, $48, $4C, $4E
    db   $5C, $01, $6C, $6C, $A4, $01, $A2, $01
    db   $48, $4C, $4E, $5A, $01, $6A, $6A, $A4
    db   $01, $A2, $01, $4C, $50, $52, $60, $01
    db   $70, $70, $A4, $01, $A2, $01, $4C, $50
    db   $52, $5E, $01, $6E, $6E, $A4, $01, $A2
    db   $01, $56, $5A, $5C, $6A, $01, $76, $A3
    db   $01, $A2, $58, $5C, $5E, $6C, $01, $78
    db   $A3, $01, $A2, $60, $64, $84, $82, $80
    db   $7E, $AE, $01, $00, $A2, $48, $4C, $4E
    db   $5C, $A7, $01, $A2, $78, $A4, $78, $A2
    db   $48, $4C, $4E, $5A, $A7, $01, $A2, $76
    db   $A4, $76, $A2, $4C, $50, $52, $60, $A7
    db   $01, $A2, $7C, $A4, $7C, $A2, $4C, $50
    db   $52, $5E, $A7, $01, $A2, $7A, $A4, $7A
    db   $00, $A2, $56, $5A, $5C, $6A, $A7, $01
    db   $A2, $82, $58, $5C, $5E, $6C, $A7, $01
    db   $A2, $84, $00, $60, $64, $66, $8C, $8A
    db   $88, $86, $84, $AE, $01, $00, $00, $E3
    db   $4A, $89, $5E, $75, $5E, $93, $5E, $00
    db   $00, $AA, $6D, $9B, $5E, $AF, $6D, $AD
    db   $5E, $B4, $6D, $BE, $5E, $AF, $6D, $CF
    db   $5E, $FF, $FF, $75, $5E, $10, $6D, $7D
    db   $6D, $9B, $5E, $FF, $FF, $8B, $5E, $54
    db   $6E, $E0, $5E, $FF, $FF, $93, $5E, $A2
    db   $2C, $26, $20, $1A, $14, $0E, $08, $04
    db   $02, $08, $0E, $14, $1A, $20, $26, $2C
    db   $00, $2E, $26, $20, $1A, $16, $0E, $08
    db   $04, $02, $08, $0E, $16, $1A, $20, $26
    db   $2E, $00, $30, $26, $20, $1A, $18, $0E
    db   $08, $04, $02, $08, $0E, $18, $1A, $20
    db   $26, $30, $00, $2E, $26, $20, $1A, $16
    db   $0E, $08, $04, $02, $08, $0E, $16, $1A
    db   $20, $26, $2E, $00, $99, $A8, $01, $A2
    db   $01, $02, $02, $01, $A8, $01, $A5, $01
    db   $01, $00, $00, $D4, $4A, $F9, $5E, $05
    db   $5F, $00, $00, $00, $00, $10, $6D, $7D
    db   $6D, $19, $5F, $19, $5F, $FF, $FF, $FB
    db   $5E, $09, $6E, $19, $5F, $0E, $6E, $2B
    db   $5F, $13, $6E, $19, $5F, $22, $6E, $2B
    db   $5F, $FF, $FF, $0D, $5F, $A1, $48, $44
    db   $3E, $38, $30, $2C, $26, $20, $18, $20
    db   $26, $2C, $30, $38, $3E, $44, $00, $4C
    db   $48, $44, $3E, $38, $30, $2C, $26, $20
    db   $26, $2C, $34, $3E, $44, $4C, $50, $00
    db   $00, $98, $4A, $47, $5F, $5D, $5F, $77
    db   $5F, $8B, $5F, $4F, $6E, $03, $60, $C8
    db   $6D, $9D, $5F, $27, $6E, $BC, $5F, $C8
    db   $6D, $9D, $5F, $20, $6D, $FF, $FF, $47
    db   $5F, $4F, $6E, $F1, $5F, $C8, $6D, $C7
    db   $5F, $27, $6E, $E6, $5F, $8E, $6E, $C8
    db   $6D, $C7, $5F, $20, $6D, $7C, $6E, $FF
    db   $FF, $5D, $5F, $15, $6D, $5E, $6E, $15
    db   $60, $59, $6E, $22, $60, $5E, $6E, $15
    db   $60, $20, $6D, $FF, $FF, $77, $5F, $2D
    db   $60, $30, $60, $30, $60, $48, $60, $30
    db   $60, $30, $60, $53, $60, $FF, $FF, $8B
    db   $5F, $9B, $02, $A2, $22, $22, $22, $20
    db   $A4, $01, $A7, $1E, $1C, $A3, $01, $9C
    db   $9B, $02, $A2, $26, $26, $26, $24, $A4
    db   $01, $A7, $22, $20, $A3, $01, $9C, $00
    db   $A7, $48, $46, $A2, $48, $4A, $4C, $A1
    db   $4E, $01, $00, $9B, $02, $A2, $30, $30
    db   $30, $2E, $A4, $01, $A7, $2C, $2A, $A3
    db   $01, $9C, $9B, $02, $A2, $34, $34, $34
    db   $32, $A4, $01, $A7, $30, $2E, $A3, $01
    db   $9C, $00, $A7, $52, $50, $A2, $52, $54
    db   $56, $A1, $58, $01, $00, $A1, $6C, $6A
    db   $68, $66, $64, $62, $60, $5E, $5C, $5A
    db   $58, $56, $54, $52, $50, $4E, $00, $A1
    db   $66, $64, $62, $60, $5E, $5C, $5A, $58
    db   $56, $54, $52, $50, $4E, $4C, $4A, $48
    db   $00, $9B, $10, $99, $A2, $18, $0E, $9C
    db   $9B, $10, $04, $1C, $9C, $00, $9A, $A7
    db   $32, $30, $A2, $32, $34, $36, $99, $38
    db   $00, $A5, $01, $00, $9B, $04, $A2, $15
    db   $15, $FF, $01, $9C, $9B, $02, $15, $15
    db   $FF, $15, $9C, $1A, $FF, $15, $FF, $9B
    db   $04, $FF, $9C, $00, $9B, $02, $FF, $1A
    db   $1A, $9C, $9B, $04, $FF, $9C, $00, $1A
    db   $1A, $01, $15, $15, $01, $FF, $FF, $9B
    db   $04, $15, $9C, $9B, $04, $1A, $9C, $00
    db   $00, $A7, $4A, $6F, $60, $79, $60, $7F
    db   $60, $00, $00, $09, $6E, $24, $6D, $27
    db   $6D, $87, $60, $00, $00, $CD, $6D, $87
    db   $60, $00, $00, $77, $6E, $27, $6D, $87
    db   $60, $00, $00, $9B, $02, $A1, $90, $8A
    db   $82, $7C, $78, $72, $6A, $64, $60, $5A
    db   $52, $4C, $48, $42, $3A, $34, $8E, $88
    db   $82, $7A, $76, $70, $6A, $62, $5E, $58
    db   $52, $4A, $46, $40, $3A, $32, $9C, $2E
    db   $28, $22, $1A, $16, $10, $0A, $02, $A6
    db   $48, $56, $5C, $64, $01, $A2, $60, $A1
    db   $68, $6E, $A5, $78, $01, $00, $00, $C5
    db   $4A, $CD, $60, $D9, $60, $17, $4B, $00
    db   $00, $09, $6E, $03, $60, $10, $6D, $E3
    db   $60, $FF, $FF, $D3, $60, $09, $6E, $9D
    db   $6E, $F1, $5F, $FF, $FF, $D3, $60, $A2
    db   $28, $30, $36, $3E, $A3, $6E, $01, $A2
    db   $60, $28, $30, $36, $60, $64, $66, $6A
    db   $26, $34, $A3, $6A, $5C, $74, $A2, $52
    db   $4C, $44, $3E, $3A, $34, $2C, $26, $22
    db   $28, $30, $36, $A3, $66, $01, $A2, $58
    db   $22, $28, $30, $58, $5C, $60, $64, $1E
    db   $2C, $A3, $64, $56, $6E, $A2, $4C, $44
    db   $3E, $36, $34, $2C, $26, $1E, $00, $00
    db   $A7, $4A, $2E, $61, $34, $61, $48, $61
    db   $00, $00, $54, $61, $FF, $FF, $2E, $61
    db   $8F, $61, $E3, $60, $7C, $6E, $9D, $61
    db   $96, $61, $E2, $61, $7C, $6E, $26, $62
    db   $FF, $FF, $34, $61, $68, $6E, $67, $62
    db   $6D, $6E, $67, $62, $FF, $FF, $48, $61
    db   $9D, $32, $83, $80, $9B, $04, $A2, $48
    db   $01, $48, $48, $9C, $9B, $04, $44, $01
    db   $44, $44, $9C, $9B, $04, $40, $01, $40
    db   $40, $9C, $9B, $04, $3E, $01, $3E, $3E
    db   $9C, $9B, $04, $30, $01, $30, $30, $9C
    db   $9B, $04, $2C, $01, $2C, $2C, $9C, $9B
    db   $07, $2E, $01, $2E, $2E, $9C, $2C, $01
    db   $2C, $2C, $00, $9D, $67, $86, $80, $9F
    db   $E8, $00, $9D, $47, $86, $80, $9F, $E8
    db   $00, $A2, $10, $18, $1E, $26, $A3, $56
    db   $A2, $58, $5C, $A3, $60, $A2, $10, $1E
    db   $28, $30, $5C, $58, $5C, $06, $1E, $58
    db   $A3, $56, $A2, $52, $4E, $06, $0E, $14
    db   $1E, $A4, $4E, $A2, $0C, $16, $1A, $1E
    db   $54, $5E, $62, $A3, $66, $A2, $16, $0C
    db   $24, $2E, $3C, $62, $5E, $A7, $62, $A2
    db   $70, $0A, $16, $1A, $28, $A7, $6E, $A2
    db   $7A, $08, $14, $1A, $26, $00, $A2, $28
    db   $30, $36, $3E, $A3, $6E, $01, $A2, $60
    db   $28, $30, $36, $01, $86, $78, $90, $A2
    db   $8C, $4C, $4E, $52, $A3, $56, $A2, $58
    db   $A4, $5C, $A2, $3E, $3A, $34, $3E, $44
    db   $3A, $40, $48, $4E, $A3, $4E, $01, $A2
    db   $40, $22, $28, $30, $40, $44, $48, $4C
    db   $30, $34, $36, $3E, $A3, $4E, $A2, $52
    db   $A7, $56, $A2, $01, $48, $4E, $56, $58
    db   $5C, $00, $A4, $48, $A2, $10, $18, $1E
    db   $26, $28, $30, $36, $3E, $48, $4C, $4E
    db   $52, $A7, $44, $A2, $5C, $26, $2C, $30
    db   $34, $36, $6E, $66, $74, $8C, $26, $2C
    db   $36, $A7, $76, $A2, $8E, $3C, $46, $4A
    db   $A3, $4E, $A2, $16, $0C, $24, $2E, $3C
    db   $4A, $46, $A7, $4A, $A2, $58, $22, $24
    db   $28, $2E, $A7, $56, $A2, $62, $38, $3E
    db   $44, $4A, $00, $9B, $04, $99, $A2, $40
    db   $01, $40, $40, $9C, $9B, $04, $3E, $01
    db   $3E, $3E, $9C, $9B, $04, $3A, $01, $3A
    db   $3A, $9C, $9B, $04, $30, $01, $30, $30
    db   $9C, $9B, $04, $28, $01, $28, $28, $9C
    db   $9B, $04, $26, $01, $26, $26, $9C, $9B
    db   $04, $24, $01, $24, $24, $9C, $9B, $02
    db   $22, $01, $22, $22, $9C, $9B, $02, $20
    db   $01, $20, $20, $9C, $00, $00, $B6, $4A
    db   $B4, $62, $D0, $62, $17, $4B, $00, $00
    db   $7D, $6D, $10, $6D, $F2, $62, $09, $6E
    db   $F2, $62, $04, $63, $2D, $6D, $A8, $6E
    db   $7D, $6D, $47, $51, $47, $51, $47, $51
    db   $20, $6D, $00, $00, $F0, $6D, $F2, $62
    db   $E1, $6D, $94, $6E, $F2, $62, $13, $6E
    db   $7C, $6E, $04, $63, $22, $6E, $A8, $6E
    db   $47, $51, $CD, $6D, $47, $51, $0E, $6E
    db   $47, $51, $20, $6D, $00, $00, $A1, $2E
    db   $34, $3C, $44, $46, $4C, $54, $5C, $2C
    db   $32, $3A, $42, $44, $42, $3A, $32, $00
    db   $A1, $38, $3E, $46, $4E, $50, $56, $5E
    db   $66, $00, $00, $D4, $4A, $19, $63, $29
    db   $63, $55, $63, $00, $00, $A0, $6D, $C7
    db   $63, $3B, $6E, $E7, $63, $A0, $6D, $18
    db   $64, $FF, $FF, $19, $63, $AA, $6D, $65
    db   $63, $AA, $6D, $65, $63, $AA, $6D, $8B
    db   $63, $AA, $6D, $65, $63, $AA, $6D, $65
    db   $63, $AA, $6D, $65, $63, $AA, $6D, $8B
    db   $63, $AF, $6D, $A9, $63, $AA, $6D, $8B
    db   $63, $AF, $6D, $A9, $63, $FF, $FF, $29
    db   $63, $6D, $6E, $33, $64, $6D, $6E, $54
    db   $64, $6D, $6E, $5A, $64, $FF, $FF, $55
    db   $63, $A2, $02, $0E, $04, $0C, $01, $04
    db   $9D, $92, $00, $C0, $02, $0E, $04, $0C
    db   $01, $04, $9D, $B2, $00, $C0, $02, $0E
    db   $04, $0C, $01, $04, $9D, $92, $00, $C0
    db   $02, $0E, $04, $0C, $01, $04, $00, $9B
    db   $02, $02, $0E, $04, $0C, $01, $04, $9C
    db   $9D, $92, $00, $C0, $02, $0E, $04, $0C
    db   $01, $04, $9D, $B2, $00, $C0, $02, $0E
    db   $04, $0C, $01, $04, $00, $02, $0E, $04
    db   $0C, $01, $04, $9D, $92, $00, $C0, $02
    db   $0E, $04, $0C, $01, $04, $9D, $62, $00
    db   $C0, $9B, $02, $02, $0E, $04, $0C, $01
    db   $04, $9C, $00, $AE, $01, $01, $9B, $02
    db   $A1, $32, $32, $32, $32, $34, $32, $A2
    db   $32, $AE, $01, $A8, $01, $A2, $01, $4A
    db   $A1, $32, $32, $A7, $01, $A5, $01, $AE
    db   $01, $9C, $00, $A1, $01, $50, $54, $56
    db   $64, $A3, $5E, $A1, $5E, $62, $01, $AE
    db   $01, $A4, $01, $A1, $68, $62, $5E, $5C
    db   $AE, $01, $A9, $2C, $A0, $01, $A1, $2C
    db   $A7, $01, $A5, $01, $A1, $62, $5E, $52
    db   $50, $A5, $01, $01, $A4, $01, $A2, $30
    db   $A1, $32, $01, $00, $A1, $2C, $2C, $2C
    db   $2C, $2E, $2C, $A2, $2C, $AE, $01, $A5
    db   $01, $A1, $22, $22, $22, $22, $24, $22
    db   $A2, $22, $A5, $01, $AE, $01, $00, $99
    db   $AE, $01, $01, $9B, $02, $A1, $2E, $2E
    db   $2E, $2E, $30, $2E, $A2, $2E, $AE, $01
    db   $A8, $01, $A2, $01, $46, $A1, $2E, $2E
    db   $A7, $01, $AE, $01, $A5, $01, $9C, $00
    db   $9B, $0C, $A8, $01, $9C, $00, $A1, $24
    db   $24, $24, $24, $26, $24, $24, $01, $A5
    db   $01, $AE, $01, $A1, $1A, $1A, $1A, $1A
    db   $34, $1A, $1A, $01, $A5, $01, $AE, $01
    db   $00, $00, $B6, $4A, $80, $64, $B4, $64
    db   $17, $4B, $17, $4B, $7F, $6E, $0E, $6E
    db   $C0, $64, $C0, $64, $13, $6E, $C0, $64
    db   $D7, $64, $E0, $64, $E9, $64, $0E, $6E
    db   $F2, $64, $13, $6E, $FB, $64, $1D, $6E
    db   $04, $65, $13, $6E, $0D, $65, $0E, $6E
    db   $16, $65, $13, $6E, $1F, $65, $1D, $6E
    db   $28, $65, $42, $65, $FF, $FF, $88, $64
    db   $20, $6D, $20, $6D, $2C, $6E, $4B, $65
    db   $FF, $FF, $B8, $64, $A3, $28, $32, $30
    db   $32, $38, $32, $30, $32, $00, $9B, $02
    db   $A2, $28, $32, $30, $32, $38, $32, $30
    db   $32, $9C, $00, $2A, $32, $30, $32, $38
    db   $32, $30, $32, $00, $2A, $36, $32, $36
    db   $3C, $36, $32, $36, $00, $28, $38, $36
    db   $38, $40, $38, $36, $38, $00, $32, $38
    db   $36, $38, $42, $38, $36, $38, $00, $2A
    db   $36, $32, $36, $3C, $36, $32, $36, $00
    db   $2E, $36, $32, $36, $3C, $36, $32, $36
    db   $00, $2E, $38, $36, $38, $40, $38, $36
    db   $38, $00, $2A, $38, $36, $38, $42, $38
    db   $36, $38, $00, $2C, $36, $32, $36, $3E
    db   $36, $32, $36, $00, $28, $36, $32, $36
    db   $40, $36, $32, $36, $00, $30, $36, $3C
    db   $42, $48, $4E, $54, $5A, $58, $54, $4E
    db   $48, $40, $3C, $36, $30, $00, $30, $36
    db   $3C, $42, $48, $4E, $54, $5A, $00, $9B
    db   $02, $A3, $4A, $4E, $AE, $50, $9C, $A5
    db   $4E, $48, $AE, $4A, $A4, $01, $A3, $4A
    db   $4E, $AE, $50, $A3, $4E, $50, $A5, $54
    db   $A4, $01, $A3, $46, $4E, $A5, $54, $A4
    db   $5A, $AE, $58, $A4, $01, $A5, $54, $54
    db   $56, $56, $58, $58, $01, $01, $00, $00
    db   $E3, $4A, $86, $65, $BA, $65, $17, $4B
    db   $00, $00, $24, $6D, $7D, $6D, $CA, $64
    db   $D7, $64, $D7, $64, $E0, $64, $E0, $64
    db   $E9, $64, $E9, $64, $F2, $64, $F2, $64
    db   $FB, $64, $FB, $64, $04, $65, $04, $65
    db   $0D, $65, $0D, $65, $16, $65, $16, $65
    db   $1F, $65, $1F, $65, $28, $65, $28, $65
    db   $31, $65, $FF, $FF, $88, $65, $0E, $6E
    db   $CA, $64, $D7, $64, $13, $6E, $D7, $64
    db   $CD, $6D, $E0, $64, $FA, $6D, $E0, $64
    db   $13, $6E, $E9, $64, $0E, $6E, $E9, $64
    db   $F2, $64, $13, $6E, $F2, $64, $CD, $6D
    db   $FB, $64, $0E, $6E, $FB, $64, $09, $6E
    db   $04, $65, $0E, $6E, $04, $65, $13, $6E
    db   $0D, $65, $09, $6E, $0D, $65, $0E, $6E
    db   $16, $65, $13, $6E, $16, $65, $CD, $6D
    db   $1F, $65, $FA, $6D, $1F, $65, $28, $65
    db   $E6, $6D, $28, $65, $CD, $6D, $31, $65
    db   $FF, $FF, $BA, $65, $00, $E3, $4A, $17
    db   $4B, $1B, $66, $17, $4B, $00, $00, $F5
    db   $6D, $25, $66, $20, $6D, $FF, $FF, $1B
    db   $66, $A2, $02, $0E, $0C, $A7, $01, $A6
    db   $01, $A1, $02, $A2, $02, $0E, $A1, $0C
    db   $18, $00, $00, $B6, $4A, $41, $66, $4D
    db   $66, $17, $4B, $00, $00, $09, $6E, $24
    db   $6D, $10, $6D, $53, $66, $FF, $FF, $47
    db   $66, $CD, $6D, $FF, $FF, $47, $66, $A3
    db   $32, $46, $58, $66, $70, $01, $A3, $2E
    db   $42, $54, $62, $6C, $01, $00, $00, $C5
    db   $4A, $6D, $66, $7B, $66, $17, $4B, $00
    db   $00, $09, $6E, $10, $6D, $85, $66, $9B
    db   $66, $AB, $66, $FF, $FF, $75, $66, $0E
    db   $6E, $85, $66, $8F, $66, $FF, $FF, $7F
    db   $66, $A1, $8E, $8C, $84, $7C, $76, $74
    db   $6C, $64, $00, $9B, $03, $A7, $74, $01
    db   $9C, $A2, $74, $74, $A4, $01, $00, $A4
    db   $01, $A6, $01, $9B, $02, $A7, $54, $01
    db   $9C, $A2, $54, $54, $A4, $01, $00, $9B
    db   $03, $A7, $54, $01, $9C, $A2, $54, $54
    db   $A4, $01, $00, $00, $C5, $4A, $C2, $66
    db   $D4, $66, $E6, $66, $00, $00, $7D, $6D
    db   $10, $6D, $F6, $66, $A4, $6E, $09, $6E
    db   $45, $67, $A8, $6E, $FF, $FF, $C2, $66
    db   $A0, $6D, $F6, $66, $10, $6D, $A4, $6E
    db   $BE, $6D, $19, $67, $A8, $6E, $FF, $FF
    db   $D4, $66, $10, $6D, $18, $6D, $A4, $6E
    db   $68, $6E, $00, $67, $A8, $6E, $FF, $FF
    db   $E6, $66, $A1, $8E, $8C, $84, $7C, $76
    db   $74, $6C, $64, $00, $9B, $02, $A3, $01
    db   $A6, $88, $A1, $01, $AE, $01, $01, $01
    db   $A5, $01, $9C, $A3, $01, $A6, $88, $A1
    db   $01, $AE, $01, $01, $00, $9D, $61, $86
    db   $80, $9B, $02, $A3, $64, $68, $6A, $82
    db   $A5, $01, $A3, $01, $80, $7C, $6A, $A5
    db   $01, $9C, $A3, $64, $68, $6A, $01, $01
    db   $68, $64, $58, $5E, $64, $A8, $01, $A3
    db   $68, $6A, $6E, $70, $88, $AE, $01, $01
    db   $00, $9B, $04, $A2, $54, $5C, $4C, $52
    db   $54, $52, $4C, $44, $9C, $9B, $04, $52
    db   $58, $48, $50, $52, $58, $60, $68, $9C
    db   $9B, $04, $50, $58, $46, $4C, $50, $4C
    db   $46, $40, $9C, $9B, $03, $52, $58, $48
    db   $50, $52, $58, $60, $68, $9C, $52, $58
    db   $48, $50, $00, $00, $C5, $4A, $82, $67
    db   $8A, $67, $17, $4B, $00, $00, $09, $6E
    db   $D6, $5D, $FF, $FF, $82, $67, $13, $6E
    db   $9A, $6E, $FF, $FF, $92, $67, $20, $5E
    db   $4D, $5E, $5F, $5E, $FF, $FF, $92, $67
    db   $00, $D4, $4A, $A7, $67, $FD, $67, $D3
    db   $67, $00, $00, $10, $6D, $78, $6D, $DB
    db   $68, $DB, $68, $DB, $68, $DB, $68, $DB
    db   $68, $DB, $68, $78, $6D, $DB, $68, $DB
    db   $68, $7D, $6D, $97, $68, $78, $6D, $DB
    db   $68, $C4, $68, $20, $6D, $20, $6D, $20
    db   $6D, $20, $6D, $FF, $FF, $A9, $67, $73
    db   $69, $68, $6E, $56, $68, $6D, $6E, $56
    db   $68, $68, $6E, $25, $68, $77, $6E, $25
    db   $68, $68, $6E, $39, $68, $6D, $6E, $66
    db   $68, $68, $6E, $73, $68, $6D, $6E, $7F
    db   $68, $77, $6E, $8B, $68, $FF, $FF, $D3
    db   $67, $09, $6E, $FC, $68, $FC, $68, $FC
    db   $68, $FC, $68, $FC, $68, $FC, $68, $09
    db   $6E, $FC, $68, $FC, $68, $97, $68, $FC
    db   $68, $0E, $6E, $C4, $68, $09, $6E, $35
    db   $69, $78, $6D, $65, $69, $FF, $FF, $FD
    db   $67, $A3, $50, $64, $62, $6E, $A4, $01
    db   $A2, $01, $64, $62, $50, $A3, $4E, $60
    db   $5E, $6C, $A5, $01, $00, $A3, $4C, $5C
    db   $5A, $6A, $A5, $01, $A3, $4A, $5A, $58
    db   $68, $A5, $01, $A3, $48, $58, $56, $66
    db   $A5, $01, $A3, $4A, $5A, $58, $68, $A5
    db   $01, $00, $99, $A3, $4C, $5C, $5A, $6A
    db   $A5, $01, $A3, $4A, $5A, $58, $68, $A5
    db   $01, $00, $9A, $A2, $30, $34, $36, $44
    db   $48, $4C, $4E, $5C, $A5, $01, $00, $A2
    db   $30, $34, $36, $42, $48, $4C, $4E, $5A
    db   $A5, $01, $00, $A2, $34, $38, $3A, $48
    db   $4C, $50, $52, $60, $A5, $01, $00, $A2
    db   $34, $38, $3A, $46, $4C, $50, $52, $5E
    db   $A5, $01, $00, $9B, $02, $A2, $01, $38
    db   $3C, $38, $3C, $A7, $01, $9C, $9B, $02
    db   $A2, $01, $36, $3C, $36, $3C, $A7, $01
    db   $9C, $9B, $02, $A2, $01, $38, $3C, $3E
    db   $46, $A7, $01, $9C, $9B, $02, $A2, $01
    db   $36, $3C, $3E, $4E, $A7, $01, $9C, $00
    db   $9B, $02, $3E, $36, $3E, $40, $46, $48
    db   $46, $44, $9C, $9B, $02, $32, $38, $40
    db   $42, $48, $4A, $48, $42, $9C, $00, $A2
    db   $44, $4C, $4A, $4C, $9D, $20, $00, $80
    db   $9B, $03, $A2, $44, $4C, $4A, $4C, $9C
    db   $9B, $03, $42, $48, $4A, $48, $9C, $9D
    db   $10, $00, $80, $42, $48, $4A, $48, $00
    db   $A2, $44, $4C, $4A, $4C, $9D, $37, $00
    db   $80, $44, $4C, $4A, $4C, $9D, $53, $00
    db   $80, $44, $4C, $4A, $4C, $9D, $64, $00
    db   $80, $44, $4C, $4A, $4C, $9D, $53, $00
    db   $80, $42, $48, $4A, $48, $9D, $37, $00
    db   $80, $42, $48, $4A, $48, $9D, $27, $00
    db   $80, $9B, $02, $42, $48, $4A, $48, $9C
    db   $00, $A2, $01, $30, $34, $36, $44, $48
    db   $4C, $4E, $60, $64, $66, $74, $A4, $01
    db   $A2, $01, $30, $34, $36, $42, $48, $4C
    db   $4E, $60, $64, $66, $72, $A4, $01, $A2
    db   $01, $34, $38, $3A, $48, $4C, $50, $52
    db   $64, $68, $6A, $78, $A4, $01, $A2, $01
    db   $00, $34, $38, $3A, $46, $4C, $50, $52
    db   $64, $68, $6A, $76, $A4, $01, $00, $9B
    db   $18, $A5, $01, $9C, $00, $00, $D4, $4A
    db   $84, $69, $8E, $69, $98, $69, $00, $00
    db   $FF, $6D, $A2, $69, $4A, $6E, $B4, $69
    db   $00, $00, $FF, $6D, $B7, $69, $4A, $6E
    db   $C9, $69, $00, $00, $54, $6E, $CC, $69
    db   $59, $6E, $DA, $69, $00, $00, $A1, $01
    db   $A4, $01, $A3, $1C, $20, $A8, $22, $A3
    db   $01, $22, $26, $A7, $2A, $A2, $2E, $00
    db   $AE, $1A, $00, $A1, $01, $A4, $01, $A3
    db   $2E, $30, $A8, $34, $A3, $01, $34, $38
    db   $A7, $3A, $A2, $3E, $00, $AE, $42, $00
    db   $9B, $02, $99, $A1, $0E, $9A, $A5, $0E
    db   $A3, $0E, $A6, $01, $9C, $00, $A1, $01
    db   $AE, $14, $00, $00, $E3, $4A, $EA, $69
    db   $F4, $69, $FE, $69, $00, $00, $7D, $6D
    db   $10, $6D, $08, $6A, $FF, $FF, $F8, $69
    db   $87, $6D, $08, $6A, $12, $6A, $FF, $FF
    db   $30, $6D, $18, $6D, $77, $6E, $1C, $6A
    db   $FF, $FF, $30, $6D, $A1, $80, $78, $72
    db   $6A, $68, $60, $5A, $50, $00, $A1, $54
    db   $5C, $62, $6A, $6C, $74, $7A, $82, $00
    db   $99, $A2, $54, $54, $00, $00, $D4, $4A
    db   $54, $6A, $2C, $6A, $7C, $6A, $00, $00
    db   $A0, $6D, $9B, $6A, $A5, $6A, $B0, $6E
    db   $96, $6D, $A8, $6A, $10, $6D, $7D, $6D
    db   $08, $6A, $24, $6D, $2D, $6D, $96, $6A
    db   $78, $6B, $A0, $6D, $28, $6B, $09, $6E
    db   $40, $6B, $27, $6D, $FF, $FF, $32, $6A
    db   $7D, $6D, $10, $6D, $9B, $6A, $2D, $6D
    db   $B0, $6E, $22, $6B, $87, $6D, $08, $6A
    db   $20, $6D, $20, $6D, $20, $6D, $20, $6D
    db   $10, $6D, $7D, $6D, $28, $6B, $27, $6D
    db   $2D, $6D, $10, $6D, $FF, $FF, $5C, $6A
    db   $18, $6D, $24, $6D, $6D, $6E, $B0, $6E
    db   $10, $6D, $67, $5D, $46, $6B, $15, $6D
    db   $2D, $6D, $18, $6D, $24, $6D, $FF, $FF
    db   $80, $6A, $9D, $C2, $83, $C0, $00, $A1
    db   $44, $48, $4C, $50, $56, $5C, $60, $64
    db   $00, $68, $6E, $00, $9D, $B1, $83, $80
    db   $A6, $01, $64, $68, $6A, $9D, $81, $83
    db   $80, $A2, $3E, $42, $44, $4C, $52, $A1
    db   $01, $9D, $B1, $83, $80, $A6, $64, $68
    db   $6A, $9D, $81, $83, $80, $A2, $30, $3E
    db   $44, $4C, $50, $9D, $B1, $83, $80, $68
    db   $64, $5A, $60, $9D, $81, $83, $80, $3A
    db   $42, $64, $50, $A7, $01, $A2, $34, $3C
    db   $42, $48, $4C, $9D, $B1, $83, $80, $64
    db   $68, $6A, $9D, $81, $83, $80, $A2, $3E
    db   $42, $44, $4C, $52, $9D, $B1, $83, $80
    db   $60, $6A, $74, $9D, $81, $83, $80, $A2
    db   $30, $3E, $44, $4C, $56, $9D, $B1, $83
    db   $80, $72, $6E, $72, $9D, $81, $83, $80
    db   $A2, $3A, $42, $48, $50, $52, $5A, $60
    db   $68, $78, $01, $90, $01, $00, $9B, $11
    db   $A4, $01, $9C, $00, $A1, $1C, $22, $2A
    db   $30, $38, $3A, $42, $48, $50, $48, $42
    db   $3A, $38, $30, $2A, $22, $18, $26, $2C
    db   $34, $3E, $44, $00, $4C, $56, $60, $A9
    db   $01, $00, $A9, $01, $A3, $01, $A3, $80
    db   $7C, $72, $A7, $72, $A4, $74, $A7, $01
    db   $A3, $86, $82, $72, $A7, $72, $A3, $74
    db   $A2, $01, $A3, $74, $A3, $78, $01, $A2
    db   $66, $6C, $78, $A4, $72, $A7, $01, $A2
    db   $6A, $A4, $7C, $01, $A2, $01, $A7, $7A
    db   $8C, $A3, $8A, $00, $9D, $C2, $83, $C0
    db   $A3, $80, $7C, $72, $A2, $72, $9D, $72
    db   $00, $80, $26, $34, $9D, $C2, $83, $C0
    db   $74, $9D, $72, $00, $80, $A1, $3E, $42
    db   $44, $4C, $56, $5A, $5C, $6A, $34, $42
    db   $50, $60, $9D, $C2, $83, $C0, $A3, $86
    db   $82, $72, $A2, $72, $9D, $72, $00, $80
    db   $3E, $4C, $9D, $C2, $83, $C0, $74, $9D
    db   $72, $00, $80, $A1, $56, $5A, $5C, $64
    db   $9D, $C2, $83, $C0, $A3, $74, $78, $9D
    db   $72, $00, $80, $A1, $4E, $54, $5A, $60
    db   $9D, $C2, $83, $C0, $A2, $66, $6C, $78
    db   $72, $9D, $72, $00, $80, $A1, $01, $52
    db   $5A, $60, $6A, $72, $78, $7E, $A3, $82
    db   $9D, $C2, $83, $C0, $A2, $6A, $7C, $9D
    db   $72, $00, $80, $A1, $2C, $34, $3A, $42
    db   $44, $4C, $52, $5A, $4C, $52, $5A, $5C
    db   $52, $5A, $5C, $64, $9D, $C2, $83, $C0
    db   $A7, $7A, $8C, $A3, $8A, $00, $C5, $4A
    db   $14, $6C, $1E, $6C, $26, $6C, $00, $00
    db   $9B, $6D, $40, $6C, $2A, $6D, $FF, $FF
    db   $22, $6C, $B9, $6D, $2E, $6C, $38, $6C
    db   $00, $00, $6D, $6E, $10, $6D, $FF, $FF
    db   $20, $6C, $A1, $52, $5A, $60, $68, $6A
    db   $72, $78, $80, $00, $A3, $01, $A1, $8A
    db   $90, $01, $01, $00, $9B, $02, $A1, $3A
    db   $42, $48, $42, $9C, $00, $00, $B6, $4A
    db   $54, $6C, $66, $6C, $17, $4B, $00, $00
    db   $E1, $6D, $03, $6D, $F0, $6D, $03, $6D
    db   $03, $6D, $E1, $6D, $03, $6D, $FF, $FF
    db   $54, $6C, $9B, $6D, $E9, $6C, $8C, $6D
    db   $9D, $6E, $E9, $6C, $94, $6E, $E9, $6C
    db   $9B, $6D, $97, $6E, $E9, $6C, $7C, $6E
    db   $FF, $FF, $66, $6C, $00, $B6, $4A, $8B
    db   $6C, $A5, $6C, $D3, $6C, $E1, $6C, $E1
    db   $6D, $03, $6D, $F0, $6D, $03, $6D, $FF
    db   $6D, $03, $6D, $03, $6D, $03, $6D, $03
    db   $6D, $03, $6D, $A0, $6E, $FF, $FF, $47
    db   $5F, $9B, $6D, $E9, $6C, $8C, $6D, $9D
    db   $6E, $E9, $6C, $EB, $6D, $94, $6E, $E9
    db   $6C, $97, $6E, $E9, $6C, $8C, $6D, $7C
    db   $6E, $F6, $6C, $B9, $6D, $9D, $6E, $F6
    db   $6C, $EB, $6D, $94, $6E, $F6, $6C, $7C
    db   $6E, $A0, $6E, $FF, $FF, $5D, $5F, $20
    db   $6D, $20, $6D, $20, $6D, $15, $6D, $A0
    db   $6E, $FF, $FF, $77, $5F, $0A, $6D, $A0
    db   $6E, $FF, $FF, $8B, $5F, $9B, $02, $A1
    db   $06, $0C, $12, $1A, $1E, $24, $2A, $32
    db   $9C, $00, $9B, $02, $A1, $1E, $24, $2A
    db   $32, $36, $3C, $42, $4A, $9C, $00, $99
    db   $A2, $06, $06, $A8, $01, $00, $9B, $07
    db   $A5, $01, $9C, $00, $A1, $01, $A9, $01
    db   $00, $A5, $01, $00, $A4, $01, $00, $A5
    db   $01, $A8, $01, $00, $A5, $01, $01, $00
    db   $A2, $01, $00, $A6, $01, $00, $A1, $01
    db   $00, $A0, $01, $00, $15, $6D, $FF, $FF
    db   $30, $6D, $99, $00, $FF, $FF, $FF, $FF
    db   $00, $00, $00, $00, $FF, $FF, $FF, $FF
    db   $00, $00, $00, $00, $FF, $FF, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $99, $99, $99, $99
    db   $00, $00, $00, $00, $99, $99, $99, $99
    db   $00, $00, $00, $00, $44, $44, $44, $44
    db   $00, $00, $00, $00, $44, $44, $44, $44
    db   $00, $00, $00, $00, $9D, $10, $00, $80
    db   $00, $9D, $20, $00, $80, $00, $9D, $24
    db   $83, $C0, $00, $9D, $46, $86, $80, $00
    db   $9D, $81, $83, $C0, $00, $9D, $A2, $83
    db   $C0, $00, $9D, $91, $83, $80, $00, $9D
    db   $52, $83, $C0, $00, $9D, $62, $00, $80
    db   $00, $9D, $82, $00, $80, $00, $9D, $62
    db   $00, $C0, $00, $9D, $92, $00, $C0, $00
    db   $9D, $B2, $00, $C0, $00, $9D, $C1, $83
    db   $00, $00, $9D, $45, $00, $80, $00, $9D
    db   $53, $00, $80, $00, $9D, $93, $00, $00
    db   $00, $9D, $64, $00, $80, $00, $9D, $84
    db   $86, $80, $00, $9D, $B4, $86, $80, $00
    db   $9D, $E4, $86, $80, $00, $9D, $75, $86
    db   $80, $00, $9D, $A5, $00, $80, $00, $9D
    db   $F5, $86, $80, $00, $9D, $A5, $86, $80
    db   $00, $9D, $A5, $46, $80, $00, $9D, $85
    db   $00, $80, $00, $9D, $E7, $86, $80, $00
    db   $9D, $17, $00, $80, $00, $9D, $27, $00
    db   $80, $00, $9D, $37, $00, $80, $00, $9D
    db   $47, $00, $80, $00, $9D, $86, $00, $C0
    db   $00, $9D, $66, $00, $80, $00, $9D, $87
    db   $00, $80, $00, $9D, $48, $00, $80, $00
    db   $9D, $38, $00, $81, $00, $9D, $48, $86
    db   $80, $00, $9D, $48, $00, $00, $00, $9D
    db   $58, $00, $00, $00, $9D, $A8, $86, $C0
    db   $00, $9D, $88, $00, $00, $00, $9D, $1F
    db   $00, $00, $00, $9D, $5F, $00, $80, $00
    db   $9D, $38, $6D, $20, $00, $9D, $48, $6D
    db   $20, $00, $9D, $48, $6D, $40, $00, $9D
    db   $58, $6D, $20, $00, $9D, $58, $6D, $40
    db   $00, $9D, $58, $6D, $60, $00, $9D, $68
    db   $6D, $40, $00, $9D, $68, $6D, $60, $00
    db   $9F, $00, $00, $9F, $18, $00, $9F, $16
    db   $00, $9F, $0E, $00, $9F, $0C, $00, $9F
    db   $0A, $00, $9F, $08, $00, $9F, $06, $00
    db   $9F, $04, $00, $9F, $02, $00, $9F, $D0
    db   $00, $9F, $FE, $00, $9E, $98, $4A, $00
    db   $9E, $A7, $4A, $00, $9E, $C5, $4A, $00
    db   $9E, $D4, $4A, $00, $9E, $E3, $4A, $00
    db   $9E, $F2, $4A, $00, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $00, $D4, $4A, $0B
    db   $70, $17, $4B, $13, $70, $00, $00, $1D
    db   $70, $97, $70, $C0, $70, $00, $00, $26
    db   $70, $97, $70, $91, $70, $C0, $70, $00
    db   $00, $9D, $20, $00, $81, $A2, $01, $A9
    db   $01, $00, $9D, $0F, $73, $01, $94, $00
    db   $00, $D4, $4A, $37, $70, $3F, $70, $43
    db   $70, $00, $00, $4D, $70, $97, $70, $C0
    db   $70, $00, $00, $58, $70, $00, $00, $89
    db   $70, $97, $70, $91, $70, $C0, $70, $00
    db   $00, $9D, $20, $00, $81, $A2, $01, $A9
    db   $01, $AE, $01, $00, $9D, $47, $00, $80
    db   $96, $9B, $0A, $A3, $74, $66, $6A, $78
    db   $9C, $9B, $02, $6E, $60, $66, $6E, $70
    db   $60, $6A, $70, $9C, $74, $62, $6A, $74
    db   $7A, $68, $6E, $74, $70, $60, $66, $70
    db   $6A, $5E, $64, $76, $9B, $02, $74, $66
    db   $6A, $78, $9C, $95, $00, $9D, $0F, $73
    db   $01, $AE, $01, $94, $00, $9D, $E1, $72
    db   $01, $94, $00, $96, $A2, $01, $30, $34
    db   $A8, $36, $A2, $30, $34, $A8, $36, $A2
    db   $34, $30, $26, $A7, $2C, $A5, $30, $A3
    db   $01, $A2, $30, $34, $A8, $36, $A2, $2C
    db   $36, $A8, $40, $A2, $3E, $3A, $A5, $3E
    db   $01, $A2, $01, $00, $A3, $01, $64, $60
    db   $56, $A7, $56, $A5, $58, $A2, $6A, $66
    db   $64, $60, $56, $52, $56, $60, $A7, $58
    db   $A2, $58, $A4, $5C, $A2, $01, $4A, $52
    db   $5C, $A8, $56, $A2, $01, $4E, $A8, $60
    db   $A7, $01, $5E, $70, $6E, $01, $A4, $01
    db   $A5, $01, $95, $00, $00, $D4, $4A, $3F
    db   $70, $FB, $70, $43, $70, $00, $00, $07
    db   $71, $14, $71, $23, $71, $23, $71, $33
    db   $71, $00, $00, $9D, $71, $82, $80, $96
    db   $9B, $04, $A2, $4E, $56, $64, $5C, $9C
    db   $9B, $04, $52, $58, $66, $60, $9C, $9B
    db   $04, $4E, $56, $64, $60, $9C, $00, $9B
    db   $02, $A2, $48, $4E, $60, $56, $9C, $9B
    db   $02, $48, $52, $60, $58, $9C, $00, $9B
    db   $02, $44, $4A, $58, $52, $9C, $9B, $02
    db   $44, $4A, $56, $50, $9C, $9B, $02, $40
    db   $48, $56, $4E, $9C, $9B, $02, $40, $46
    db   $52, $4C, $9C, $9B, $04, $4E, $56, $64
    db   $5C, $9C, $95, $00, $00, $D4, $4A, $63
    db   $71, $FB, $70, $43, $70, $00, $00, $6D
    db   $71, $76, $71, $76, $71, $8A, $71, $00
    db   $00, $9D, $87, $00, $80, $96, $A5, $8C
    db   $8C, $00, $9D, $87, $00, $80, $A5, $8C
    db   $8C, $9D, $37, $00, $80, $9B, $02, $A3
    db   $74, $66, $6A, $78, $9C, $00, $9D, $76
    db   $00, $80, $9B, $02, $A4, $90, $86, $90
    db   $88, $9C, $8C, $88, $86, $8C, $90, $88
    db   $8E, $88, $9D, $87, $00, $80, $A5, $8C
    db   $8C, $00, $00, $D4, $4A, $63, $71, $FB
    db   $70, $43, $70, $B1, $71, $B5, $71, $00
    db   $00, $9B, $0A, $A1, $1F, $1F, $1F, $1F
    db   $A2, $1F, $A3, $24, $A2, $1F, $A3, $24
    db   $A1, $1F, $1F, $1F, $1F, $A3, $24, $A1
    db   $1F, $1F, $1F, $1F, $A3, $24, $9C, $00
    db   $00, $D4, $4A, $DF, $71, $EF, $71, $43
    db   $70, $B1, $71, $6D, $71, $76, $71, $76
    db   $71, $37, $72, $23, $71, $23, $71, $33
    db   $71, $00, $00, $F7, $71, $04, $72, $13
    db   $72, $00, $00, $9D, $19, $45, $40, $96
    db   $9B, $02, $A3, $1E, $2C, $26, $2C, $9C
    db   $9B, $02, $22, $30, $28, $30, $9C, $9B
    db   $02, $1E, $2C, $26, $2C, $9C, $00, $9B
    db   $02, $A3, $18, $26, $1E, $26, $18, $28
    db   $22, $28, $9C, $2C, $22, $1A, $22, $2C
    db   $20, $1A, $20, $28, $1E, $18, $1E, $28
    db   $1C, $16, $1C, $9B, $02, $1E, $2C, $26
    db   $2C, $9C, $00, $9D, $61, $82, $80, $00
    db   $00, $D4, $4A, $FB, $70, $47, $72, $43
    db   $70, $53, $72, $6D, $71, $76, $71, $76
    db   $71, $7D, $72, $13, $72, $00, $00, $82
    db   $72, $82, $72, $82, $72, $82, $72, $82
    db   $72, $82, $72, $82, $72, $82, $72, $82
    db   $72, $82, $72, $95, $72, $82, $72, $95
    db   $72, $82, $72, $82, $72, $82, $72, $82
    db   $72, $82, $72, $82, $72, $82, $72, $00
    db   $00, $9D, $19, $45, $40, $00, $9B, $03
    db   $A2, $1A, $A9, $15, $AD, $01, $A9, $15
    db   $AD, $01, $A9, $15, $9C, $A2, $1A, $1A
    db   $00, $9B, $02, $A1, $1F, $1F, $1F, $1F
    db   $A2, $1F, $A3, $24, $A2, $1F, $A3, $24
    db   $00, $00, $E3, $4A, $17, $4B, $B0, $72
    db   $B6, $72, $00, $00, $BA, $72, $C8, $72
    db   $00, $00, $C3, $72, $00, $00, $9D, $20
    db   $00, $41, $A1, $01, $A0, $01, $00, $9D
    db   $E1, $72, $01, $94, $A2, $60, $64, $A8
    db   $66, $A2, $60, $64, $A4, $66, $A2, $64
    db   $A6, $60, $A3, $56, $AE, $6E, $9A, $9B
    db   $20, $A5, $01, $9C, $00, $01, $35, $66
    db   $53, $10, $02, $46, $8A, $01, $35, $66
    db   $53, $10, $02, $46, $8A, $00, $F2, $4A
    db   $17, $4B, $FC, $72, $02, $73, $00, $00
    db   $06, $73, $24, $73, $00, $00, $1F, $73
    db   $00, $00, $9D, $20, $00, $41, $A1, $01
    db   $A0, $01, $00, $06, $9B, $CD, $DE, $EE
    db   $FF, $FF, $FE, $06, $9B, $CD, $DE, $EE
    db   $FF, $FF, $FE, $9D, $0F, $73, $01, $94
    db   $A1, $30, $34, $A4, $36, $A3, $01, $A1
    db   $30, $34, $A2, $36, $34, $A6, $30, $A3
    db   $26, $A2, $01, $A5, $3E, $9B, $20, $AE
    db   $01, $9C, $00, $00, $D4, $4A, $17, $4B
    db   $4A, $73, $54, $73, $00, $00, $5A, $73
    db   $5A, $73, $6A, $73, $FF, $FF, $BB, $78
    db   $80, $73, $FF, $FF, $BB, $78, $9D, $81
    db   $00, $80, $A1, $74, $66, $6A, $78, $9D
    db   $A6, $00, $80, $A4, $74, $00, $9D, $82
    db   $00, $80, $A2, $74, $66, $A6, $6A, $9D
    db   $85, $00, $80, $A3, $78, $9D, $A6, $00
    db   $80, $AE, $74, $00, $9D, $0C, $75, $23
    db   $99, $9B, $02, $A1, $6A, $5C, $60, $6E
    db   $A4, $6A, $9C, $A2, $6A, $5C, $A6, $60
    db   $A3, $6E, $AE, $6A, $9B, $20, $AE, $01
    db   $9C, $00, $18, $98, $4A, $17, $4B, $A9
    db   $73, $AF, $73, $00, $00, $B3, $73, $D1
    db   $73, $00, $00, $CC, $73, $00, $00, $9D
    db   $10, $00, $80, $A3, $01, $A1, $01, $00
    db   $46, $79, $98, $64, $43, $10, $01, $34
    db   $46, $79, $98, $64, $43, $10, $01, $34
    db   $9D, $BC, $73, $20, $99, $A3, $62, $60
    db   $58, $52, $A6, $4A, $48, $4A, $52, $58
    db   $AB, $60, $58, $52, $4A, $A2, $48, $4A
    db   $52, $58, $60, $58, $52, $4A, $48, $4A
    db   $52, $58, $9B, $02, $5E, $56, $50, $48
    db   $46, $48, $50, $56, $9C, $58, $50, $4A
    db   $42, $40, $42, $4A, $50, $AB, $54, $4C
    db   $46, $3E, $A6, $3C, $3E, $A3, $46, $4C
    db   $AA, $01, $A2, $50, $9B, $20, $AE, $01
    db   $9C, $00, $00, $B6, $4A, $21, $74, $27
    db   $74, $2D, $74, $00, $00, $33, $74, $FF
    db   $FF, $BB, $78, $58, $74, $FF, $FF, $BB
    db   $78, $8C, $74, $FF, $FF, $BB, $78, $9D
    db   $81, $00, $80, $A1, $01, $A2, $6E, $9D
    db   $C1, $00, $80, $A2, $6E, $A6, $01, $A4
    db   $01, $9D, $A2, $00, $80, $A2, $01, $A3
    db   $64, $6A, $74, $6A, $78, $9D, $A7, $00
    db   $80, $AE, $8C, $00, $9D, $61, $00, $80
    db   $A2, $6E, $9D, $A1, $00, $80, $A2, $6E
    db   $9D, $E5, $00, $80, $A8, $6E, $9D, $A2
    db   $00, $80, $A3, $60, $66, $6E, $72, $6E
    db   $82, $9D, $A7, $00, $80, $AE, $86, $00
    db   $66, $00, $66, $00, $66, $00, $66, $00
    db   $66, $00, $66, $00, $66, $00, $66, $00
    db   $9D, $7C, $74, $23, $99, $A1, $64, $64
    db   $64, $64, $A8, $64, $A2, $56, $5A, $5C
    db   $78, $64, $6A, $68, $60, $64, $6E, $78
    db   $82, $AE, $7C, $00, $00, $C5, $4A, $17
    db   $4B, $B3, $74, $CF, $74, $00, $00, $D3
    db   $74, $EC, $74, $D3, $74, $FE, $74, $D3
    db   $74, $FE, $74, $D3, $74, $EC, $74, $D3
    db   $74, $FE, $74, $D3, $74, $05, $75, $40
    db   $75, $00, $00, $1C, $75, $00, $00, $9D
    db   $21, $00, $80, $A1, $78, $9D, $41, $00
    db   $80, $A1, $78, $9D, $71, $00, $80, $A1
    db   $78, $9D, $A1, $00, $80, $A1, $78, $00
    db   $9D, $A1, $00, $80, $A2, $78, $9D, $C3
    db   $00, $80, $A3, $78, $9D, $82, $00, $80
    db   $A2, $78, $9D, $D2, $00, $80, $A3, $78
    db   $00, $9D, $E3, $00, $80, $AE, $78, $00
    db   $00, $0C, $00, $0C, $00, $0C, $00, $0C
    db   $06, $06, $06, $06, $06, $06, $06, $06
    db   $9D, $0C, $75, $20, $99, $9B, $02, $A1
    db   $86, $86, $86, $86, $A2, $86, $A3, $86
    db   $A2, $86, $A3, $86, $A1, $86, $86, $86
    db   $86, $A3, $86, $A1, $86, $86, $86, $86
    db   $A3, $86, $9C, $9A, $9B, $20, $AE, $01
    db   $9C, $00, $00, $E3, $4A, $17, $4B, $51
    db   $75, $59, $75, $00, $00, $5F, $75, $7D
    db   $75, $FF, $FF, $BB, $78, $78, $75, $FF
    db   $FF, $BB, $78, $9D, $20, $00, $80, $A2
    db   $01, $A9, $01, $00, $88, $88, $88, $84
    db   $00, $00, $00, $00, $88, $88, $88, $84
    db   $00, $00, $00, $00, $9D, $68, $75, $00
    db   $94, $A2, $48, $4C, $A8, $4E, $A2, $48
    db   $4C, $A3, $4E, $4C, $48, $A0, $01, $A3
    db   $3E, $A1, $01, $A5, $56, $00, $00, $D4
    db   $4A, $17, $4B, $9D, $75, $17, $4B, $AD
    db   $75, $B5, $75, $B5, $75, $CB, $75, $B5
    db   $75, $B5, $75, $CB, $75, $FF, $FF, $BB
    db   $78, $E2, $75, $E2, $75, $FA, $75, $00
    db   $00, $9D, $A1, $00, $80, $97, $A2, $36
    db   $9D, $61, $00, $80, $A9, $2C, $AD, $01
    db   $A9, $2C, $AD, $01, $A9, $2C, $00, $A1
    db   $2C, $9D, $A1, $00, $80, $A1, $36, $9D
    db   $61, $00, $80, $A1, $2C, $2C, $9D, $A1
    db   $00, $80, $A2, $36, $36, $00, $9B, $02
    db   $A2, $FF, $A9, $15, $AD, $01, $A9, $15
    db   $AD, $01, $A9, $15, $9C, $A1, $15, $FF
    db   $15, $15, $A2, $FF, $FF, $00, $9B, $20
    db   $AE, $01, $9C, $00, $00, $D4, $4A, $0B
    db   $76, $17, $76, $21, $76, $00, $00, $27
    db   $76, $34, $76, $4A, $76, $5D, $76, $FF
    db   $FF, $0D, $76, $30, $76, $4A, $76, $5D
    db   $76, $FF, $FF, $17, $76, $8A, $76, $FF
    db   $FF, $0D, $76, $9D, $20, $00, $80, $A1
    db   $01, $A9, $01, $00, $9D, $60, $21, $80
    db   $A2, $01, $60, $64, $A8, $66, $A2, $60
    db   $64, $A8, $66, $A2, $64, $60, $56, $A7
    db   $5C, $A5, $60, $A3, $01, $00, $A2, $60
    db   $64, $A8, $66, $A2, $5C, $66, $A8, $70
    db   $A2, $6E, $6A, $A5, $6E, $01, $A7, $01
    db   $00, $A3, $7C, $78, $6E, $A7, $6E, $A5
    db   $70, $A2, $82, $7E, $7C, $78, $6E, $6A
    db   $6E, $78, $A7, $70, $A2, $70, $A4, $74
    db   $A2, $01, $62, $6A, $74, $A8, $6E, $A2
    db   $01, $66, $A5, $78, $A2, $01, $A7, $76
    db   $88, $86, $01, $A5, $01, $00, $9D, $68
    db   $6D, $60, $A3, $01, $A1, $01, $00, $00
    db   $D4, $4A, $9E, $76, $AE, $76, $B8, $76
    db   $00, $00, $BE, $76, $14, $71, $14, $71
    db   $23, $71, $23, $71, $33, $71, $FF, $FF
    db   $A0, $76, $30, $76, $C7, $76, $5D, $76
    db   $FF, $FF, $AE, $76, $EB, $76, $FF, $FF
    db   $B8, $76, $9D, $19, $42, $40, $A7, $01
    db   $A2, $01, $00, $A2, $30, $34, $A8, $36
    db   $A2, $2C, $36, $A8, $40, $A2, $3E, $3A
    db   $AE, $3E, $A4, $01, $A7, $01, $00, $01
    db   $37, $9A, $BB, $BB, $BB, $A6, $21, $01
    db   $37, $9A, $BB, $BB, $BB, $A6, $21, $9D
    db   $DB, $76, $40, $9B, $08, $A5, $01, $9C
    db   $A8, $01, $A3, $6A, $66, $A6, $5C, $A1
    db   $01, $A7, $5C, $A8, $60, $A3, $01, $A1
    db   $70, $01, $6E, $01, $6A, $01, $66, $01
    db   $5C, $01, $58, $01, $5C, $01, $66, $01
    db   $A6, $60, $01, $A2, $60, $A7, $62, $A3
    db   $01, $A1, $52, $01, $58, $01, $62, $01
    db   $A4, $5C, $A7, $01, $A2, $56, $A8, $66
    db   $A7, $01, $A3, $64, $A2, $01, $A3, $5E
    db   $A2, $01, $A3, $5C, $A4, $01, $A5, $01
    db   $00, $00, $01, $4B, $48, $77, $4C, $77
    db   $50, $77, $54, $77, $58, $77, $00, $00
    db   $A3, $77, $00, $00, $27, $78, $00, $00
    db   $8C, $78, $00, $00, $9D, $62, $00, $00
    db   $A1, $1E, $22, $24, $A6, $26, $A1, $26
    db   $28, $2A, $A6, $2C, $A1, $2C, $30, $32
    db   $34, $A3, $36, $97, $3C, $98, $9D, $41
    db   $00, $80, $9B, $06, $A2, $78, $A1, $7E
    db   $A2, $74, $7E, $78, $7E, $A1, $78, $A2
    db   $74, $7E, $9C, $9D, $61, $00, $40, $A6
    db   $70, $A1, $70, $6C, $A2, $74, $70, $70
    db   $A1, $70, $A2, $6C, $74, $88, $88, $84
    db   $A7, $88, $97, $A3, $2C, $98, $00, $9D
    db   $81, $00, $40, $A1, $3E, $40, $42, $A6
    db   $44, $A1, $44, $46, $48, $A6, $4A, $A1
    db   $4A, $4E, $52, $54, $A4, $56, $AE, $01
    db   $97, $A1, $01, $A2, $4A, $A1, $4A, $A2
    db   $40, $A1, $30, $30, $98, $A6, $30, $A1
    db   $30, $2C, $A2, $32, $30, $30, $A1, $30
    db   $A2, $2C, $32, $A6, $30, $A1, $30, $2C
    db   $A2, $32, $A2, $30, $97, $4A, $A1, $4A
    db   $A2, $40, $A1, $30, $30, $98, $A6, $36
    db   $A1, $36, $32, $A2, $3A, $36, $36, $A1
    db   $36, $A2, $32, $3A, $A6, $36, $A1, $36
    db   $32, $A2, $3A, $A2, $36, $97, $4A, $A1
    db   $4A, $A2, $40, $A1, $30, $30, $98, $A6
    db   $10, $A1, $10, $0C, $A2, $14, $10, $10
    db   $A1, $10, $A2, $0C, $14, $10, $10, $0C
    db   $A7, $10, $9D, $A1, $00, $80, $97, $A3
    db   $3C, $98, $00, $9D, $0F, $73, $20, $99
    db   $A1, $4E, $52, $54, $A6, $56, $A1, $56
    db   $58, $5A, $A6, $5C, $A1, $5C, $60, $62
    db   $64, $A4, $66, $9B, $02, $A6, $28, $A1
    db   $28, $24, $A2, $2C, $28, $28, $A1, $28
    db   $A2, $24, $2C, $A6, $28, $A1, $28, $24
    db   $A2, $2C, $28, $A6, $01, $A3, $01, $9C
    db   $A6, $30, $A1, $30, $2C, $A2, $32, $30
    db   $30, $A1, $30, $A2, $2C, $32, $A6, $30
    db   $A1, $30, $2C, $A2, $32, $30, $A6, $01
    db   $A3, $01, $A6, $40, $A1, $40, $3C, $A2
    db   $44, $40, $40, $A1, $40, $A2, $3C, $44
    db   $40, $40, $3C, $A7, $40, $A3, $01, $00
    db   $A5, $01, $A3, $01, $FF, $9B, $06, $A1
    db   $1A, $15, $15, $1A, $15, $15, $FF, $1A
    db   $1A, $15, $15, $1A, $15, $15, $FF, $FF
    db   $9C, $A6, $FF, $A1, $FF, $FF, $A2, $FF
    db   $FF, $FF, $A1, $FF, $A2, $FF, $FF, $FF
    db   $FF, $FF, $A7, $FF, $A3, $FF, $00, $C1
    db   $78, $FF, $FF, $BB, $78, $9B, $20, $AE
    db   $01, $9C, $00, $CD, $78, $FF, $FF, $C7
    db   $78, $9B, $20, $AE, $01, $9C, $00, $00
    db   $D4, $4A, $DE, $78, $E4, $78, $EA, $78
    db   $00, $00, $F2, $78, $FF, $FF, $DE, $78
    db   $60, $79, $FF, $FF, $E4, $78, $B7, $79
    db   $BE, $79, $FF, $FF, $EC, $78, $9D, $42
    db   $82, $80, $9B, $02, $A2, $40, $4E, $5C
    db   $60, $A4, $01, $A2, $40, $52, $60, $62
    db   $A4, $01, $9C, $A2, $40, $4E, $5C, $60
    db   $A4, $01, $A2, $40, $4C, $5C, $5E, $A4
    db   $01, $A2, $44, $52, $60, $62, $A4, $01
    db   $A2, $42, $48, $4E, $54, $52, $A7, $01
    db   $A2, $44, $4C, $52, $58, $A4, $01, $A2
    db   $4A, $50, $56, $5C, $A4, $01, $A2, $48
    db   $4E, $56, $5C, $A4, $01, $A2, $48, $4E
    db   $56, $58, $A4, $01, $A2, $44, $4A, $52
    db   $58, $A4, $01, $A2, $44, $4C, $52, $58
    db   $A4, $01, $A2, $48, $4E, $56, $4E, $46
    db   $4C, $52, $4C, $44, $4A, $52, $4A, $44
    db   $4A, $50, $4A, $00, $9D, $50, $44, $80
    db   $9B, $02, $A4, $66, $58, $5C, $A3, $01
    db   $A2, $60, $62, $9C, $A3, $60, $66, $A4
    db   $74, $A3, $01, $70, $74, $70, $66, $A2
    db   $62, $60, $A4, $5C, $01, $A2, $01, $60
    db   $62, $66, $A4, $6A, $58, $56, $A3, $01
    db   $A2, $5C, $6A, $A4, $66, $56, $58, $A3
    db   $01, $A2, $58, $56, $A3, $52, $58, $A4
    db   $60, $A3, $01, $5C, $58, $50, $A4, $4E
    db   $AE, $01, $00, $11, $11, $11, $10, $00
    db   $00, $00, $00, $11, $11, $11, $10, $00
    db   $00, $00, $00, $9D, $A7, $79, $20, $A2
    db   $01, $00, $9B, $02, $A4, $66, $58, $5C
    db   $A3, $01, $A2, $60, $62, $9C, $A3, $60
    db   $66, $A7, $74, $01, $A3, $70, $74, $70
    db   $66, $A2, $62, $60, $A7, $5C, $A4, $01
    db   $A2, $01, $01, $60, $62, $66, $A4, $6A
    db   $58, $A7, $56, $01, $A2, $5C, $6A, $A4
    db   $66, $56, $A7, $58, $01, $A2, $58, $56
    db   $A3, $52, $58, $A7, $60, $01, $A3, $5C
    db   $58, $50, $A7, $4E, $A2, $01, $AE, $01
    db   $00, $00, $C5, $4A, $10, $7A, $24, $7A
    db   $2A, $7A, $00, $00, $3E, $7A, $32, $7A
    db   $43, $7A, $32, $7A, $48, $7A, $32, $7A
    db   $43, $7A, $32, $7A, $FF, $FF, $10, $7A
    db   $4D, $7A, $FF, $FF, $24, $7A, $B7, $79
    db   $51, $7A, $FF, $FF, $2C, $7A, $9B, $02
    db   $AC, $7C, $7E, $9C, $9B, $02, $82, $84
    db   $9C, $00, $9D, $10, $00, $00, $00, $9D
    db   $20, $00, $00, $00, $9D, $30, $00, $00
    db   $00, $9D, $1A, $81, $40, $9B, $20, $A2
    db   $62, $6C, $76, $78, $9C, $00, $00, $F2
    db   $4A, $65, $7A, $71, $7A, $17, $4B, $00
    db   $00, $7B, $7A, $87, $7A, $16, $7B, $1F
    db   $7B, $FF, $FF, $69, $7A, $82, $7A, $87
    db   $7A, $1B, $7B, $FF, $FF, $75, $7A, $9D
    db   $42, $00, $80, $A1, $01, $00, $9D, $81
    db   $00, $80, $00, $A5, $01, $A2, $01, $97
    db   $A0, $2E, $30, $3E, $40, $46, $40, $38
    db   $30, $32, $34, $3C, $44, $4A, $44, $3C
    db   $34, $36, $38, $40, $48, $4E, $48, $40
    db   $38, $3A, $3C, $44, $4C, $52, $4C, $44
    db   $3C, $3E, $40, $48, $50, $56, $50, $48
    db   $40, $42, $44, $4C, $54, $5A, $54, $4C
    db   $44, $46, $48, $50, $58, $5E, $58, $50
    db   $48, $4A, $4C, $54, $5C, $62, $5C, $54
    db   $4C, $4E, $50, $58, $60, $66, $60, $58
    db   $50, $52, $54, $5C, $64, $6A, $64, $5C
    db   $54, $9B, $02, $56, $58, $60, $68, $6E
    db   $68, $60, $58, $56, $50, $48, $40, $48
    db   $50, $9C, $56, $58, $60, $68, $6E, $68
    db   $60, $58, $68, $60, $58, $56, $60, $58
    db   $56, $50, $58, $56, $50, $48, $56, $50
    db   $48, $40, $50, $48, $40, $38, $48, $40
    db   $3E, $38, $40, $3E, $38, $30, $A5, $28
    db   $98, $00, $9D, $10, $00, $80, $00, $9D
    db   $1A, $81, $40, $9B, $20, $AA, $62, $6C
    db   $76, $78, $9C, $00, $0E, $B6, $4A, $33
    db   $7B, $39, $7B, $3F, $7B, $00, $00, $45
    db   $7B, $FF, $FF, $33, $7B, $61, $7B, $FF
    db   $FF, $39, $7B, $90, $7B, $FF, $FF, $3F
    db   $7B, $9D, $62, $00, $40, $9B, $20, $A3
    db   $32, $A2, $3A, $A3, $40, $A2, $48, $A8
    db   $44, $A3, $2C, $A2, $36, $A3, $3C, $A2
    db   $44, $A8, $40, $9C, $00, $9D, $50, $21
    db   $80, $AE, $01, $01, $A8, $58, $A3, $01
    db   $A2, $4E, $A3, $52, $A2, $40, $A5, $44
    db   $A2, $01, $A3, $52, $A2, $5C, $A8, $58
    db   $A3, $01, $A2, $4E, $A3, $52, $A2, $40
    db   $A5, $44, $A2, $01, $A3, $40, $A2, $52
    db   $AE, $4A, $01, $00, $9D, $F4, $4B, $40
    db   $9B, $20, $A5, $01, $A1, $5C, $01, $A7
    db   $74, $A5, $01, $A1, $58, $01, $A7, $70
    db   $9C, $00, $00, $E3, $4A, $B1, $7B, $B7
    db   $7B, $BD, $7B, $C3, $7B, $C9, $7B, $FF
    db   $FF, $F9, $5E, $E0, $7B, $FF, $FF, $05
    db   $5F, $06, $7C, $FF, $FF, $BB, $78, $1A
    db   $7C, $FF, $FF, $C7, $78, $9D, $80, $81
    db   $00, $96, $A1, $52, $5C, $66, $60, $6A
    db   $74, $9D, $80, $00, $00, $A4, $6E, $01
    db   $9E, $D4, $4A, $00, $9D, $40, $81, $40
    db   $A1, $42, $4C, $56, $50, $5A, $64, $9D
    db   $40, $00, $40, $A4, $5E, $01, $9E, $D4
    db   $4A, $00, $AA, $AA, $AA, $A8, $00, $00
    db   $00, $00, $AA, $AA, $AA, $A8, $00, $00
    db   $00, $00, $9D, $F6, $7B, $20, $99, $A1
    db   $30, $3A, $44, $3E, $48, $52, $9A, $A4
    db   $4C, $01, $9E, $D4, $4A, $00, $9B, $06
    db   $A1, $1A, $9C, $9B, $10, $A0, $15, $9C
    db   $9E, $D4, $4A, $00, $00, $C5, $4A, $33
    db   $7C, $3B, $7C, $17, $4B, $41, $7C, $47
    db   $7C, $4E, $7C, $FF, $FF, $35, $7C, $93
    db   $7C, $FF, $FF, $3B, $7C, $F9, $7C, $FF
    db   $FF, $41, $7C, $9D, $10, $00, $80, $A1
    db   $01, $00, $AC, $90, $86, $8E, $84, $8C
    db   $82, $8A, $80, $88, $7E, $86, $78, $84
    db   $76, $82, $74, $80, $72, $AC, $86, $78
    db   $84, $76, $82, $74, $80, $72, $AD, $7C
    db   $7A, $72, $6C, $68, $64, $62, $5A, $54
    db   $50, $AD, $64, $62, $5A, $54, $50, $AE
    db   $01, $AD, $7A, $72, $AD, $7A, $72, $A5
    db   $01, $01, $AD, $62, $64, $72, $6C, $62
    db   $64, $72, $6C, $A5, $01, $01, $00, $9D
    db   $39, $00, $00, $AC, $90, $86, $8E, $84
    db   $8C, $82, $8A, $80, $88, $7E, $86, $78
    db   $84, $76, $82, $74, $80, $72, $9D, $20
    db   $00, $40, $AC, $86, $78, $84, $76, $82
    db   $74, $80, $72, $9D, $29, $00, $00, $AD
    db   $7C, $7A, $72, $6C, $68, $64, $62, $5A
    db   $54, $50, $9D, $20, $00, $40, $AD, $64
    db   $62, $5A, $54, $50, $AE, $01, $9D, $29
    db   $00, $00, $AD, $7A, $72, $9D, $20, $00
    db   $40, $AD, $7A, $72, $A5, $01, $01, $9D
    db   $29, $00, $00, $AD, $62, $64, $72, $6C
    db   $9D, $20, $00, $40, $AD, $62, $64, $72
    db   $6C, $A5, $01, $01, $00, $9B, $20, $A3
    db   $38, $9C, $00, $00, $C5, $4A, $0A, $7D
    db   $12, $7D, $17, $4B, $00, $00, $28, $7D
    db   $36, $7D, $FF, $FF, $0C, $7D, $33, $7D
    db   $3C, $7D, $36, $7D, $41, $7D, $36, $7D
    db   $46, $7D, $36, $7D, $41, $7D, $36, $7D
    db   $FF, $FF, $14, $7D, $9D, $20, $00, $43
    db   $A7, $01, $A1, $01, $A0, $01, $00, $A7
    db   $01, $00, $A1, $20, $22, $20, $22, $00
    db   $9D, $20, $00, $40, $00, $9D, $30, $00
    db   $40, $00, $9D, $40, $00, $40, $00, $00
    db   $A7, $4A, $56, $7D, $5E, $7D, $66, $7D
    db   $00, $00, $6E, $7D, $84, $7D, $FF, $FF
    db   $58, $7D, $7A, $7D, $84, $7D, $FF, $FF
    db   $60, $7D, $F8, $7D, $84, $7D, $FF, $FF
    db   $68, $7D, $9D, $10, $00, $40, $A5, $01
    db   $01, $A8, $01, $AA, $01, $00, $9D, $20
    db   $00, $00, $A5, $01, $01, $A8, $01, $00
    db   $A1, $8E, $8A, $88, $80, $7A, $76, $72
    db   $70, $68, $62, $5E, $5A, $58, $50, $4A
    db   $46, $42, $40, $38, $32, $2E, $2A, $2E
    db   $32, $38, $40, $42, $46, $4A, $50, $58
    db   $5A, $5E, $62, $68, $70, $72, $76, $7A
    db   $80, $88, $8A, $8E, $8A, $86, $80, $78
    db   $76, $72, $6E, $68, $60, $5E, $5A, $56
    db   $50, $48, $46, $42, $3E, $38, $30, $34
    db   $38, $3E, $42, $46, $48, $34, $50, $56
    db   $5A, $5E, $60, $34, $68, $6E, $72, $76
    db   $76, $72, $6C, $64, $62, $5E, $5A, $54
    db   $4C, $4A, $46, $42, $3C, $34, $32, $2E
    db   $32, $34, $3C, $42, $46, $4A, $4C, $54
    db   $5A, $5E, $62, $64, $6C, $72, $76, $7A
    db   $7C, $84, $8A, $00, $9D, $A7, $79, $20
    db   $A5, $01, $01, $A8, $01, $A3, $01, $00
    db   $00, $D4, $4A, $0F, $7E, $17, $7E, $1F
    db   $7E, $27, $7E, $2F, $7E, $70, $7E, $FF
    db   $FF, $11, $7E, $3A, $7E, $96, $7E, $FF
    db   $FF, $19, $7E, $55, $7E, $FE, $7E, $FF
    db   $FF, $21, $7E, $60, $7E, $76, $7F, $FF
    db   $FF, $29, $7E, $9D, $60, $00, $41, $A7
    db   $01, $AA, $4E, $AE, $50, $00, $9D, $40
    db   $00, $01, $A7, $01, $AA, $64, $AE, $66
    db   $00, $8A, $DF, $DA, $86, $31, $01, $36
    db   $86, $8A, $DF, $DA, $86, $31, $01, $36
    db   $86, $9D, $45, $7E, $20, $A7, $01, $AA
    db   $5A, $AE, $5C, $00, $A7, $01, $AA, $01
    db   $A5, $01, $A1, $FF, $A2, $FF, $FF, $A1
    db   $FF, $A2, $FF, $00, $9D, $41, $00, $80
    db   $9B, $07, $A6, $82, $82, $A3, $82, $A2
    db   $82, $A3, $82, $9C, $9D, $61, $00, $80
    db   $97, $A2, $44, $A6, $44, $A1, $44, $44
    db   $A3, $44, $A2, $44, $A1, $44, $A2, $44
    db   $98, $00, $9D, $60, $21, $41, $A3, $46
    db   $A7, $3C, $A1, $01, $46, $46, $4A, $4C
    db   $50, $A8, $54, $AA, $54, $56, $5A, $AD
    db   $01, $A8, $5E, $AA, $5E, $5A, $56, $AD
    db   $01, $A6, $5A, $A1, $56, $A4, $54, $A3
    db   $54, $A2, $50, $A1, $50, $54, $A4, $56
    db   $A2, $54, $50, $A2, $4C, $A1, $4C, $50
    db   $A4, $54, $A2, $50, $4C, $A2, $4A, $A1
    db   $4A, $4E, $A4, $52, $A3, $58, $9D, $62
    db   $00, $40, $A2, $54, $A6, $54, $A1, $54
    db   $54, $A3, $54, $A2, $54, $A1, $54, $A2
    db   $54, $00, $00, $11, $22, $33, $44, $55
    db   $67, $89, $00, $00, $00, $05, $00, $00
    db   $00, $05, $9D, $EE, $7E, $20, $99, $A2
    db   $5E, $A1, $4C, $A2, $54, $5E, $5C, $4C
    db   $54, $5C, $A1, $4C, $A2, $5A, $A1, $4C
    db   $A2, $54, $5A, $58, $4C, $54, $58, $A1
    db   $4C, $A2, $56, $A1, $46, $A2, $4C, $56
    db   $5A, $4A, $50, $5A, $A1, $4A, $A2, $5A
    db   $A1, $4C, $A2, $54, $5A, $5A, $A1, $4C
    db   $54, $A2, $5A, $A1, $4C, $54, $5A, $A2
    db   $56, $A1, $48, $A2, $50, $56, $50, $3E
    db   $48, $50, $A1, $52, $A2, $54, $A1, $46
    db   $A2, $4C, $54, $5E, $A1, $4C, $54, $A2
    db   $5E, $A1, $5C, $5E, $60, $A2, $62, $A1
    db   $52, $A2, $58, $62, $5E, $52, $58, $5E
    db   $A1, $58, $A2, $5C, $A6, $5C, $A1, $5C
    db   $5C, $A3, $5C, $A2, $5C, $A1, $5C, $A2
    db   $5C, $00, $9B, $07, $A1, $15, $15, $1A
    db   $15, $15, $15, $FF, $15, $15, $15, $1A
    db   $15, $15, $15, $1A, $FF, $9C, $A2, $FF
    db   $A6, $FF, $A1, $FF, $FF, $A3, $FF, $A2
    db   $FF, $A1, $FF, $A2, $FF, $00, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF
