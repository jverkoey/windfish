SECTION "ROM Bank 1B", ROMX[$4000], BANK[$1B]

    db   $C3, $09, $40, $C3, $9E, $4D

toc_1B_4006:
    jp   toc_1B_401E

    db   $21, $00, $D3, $36, $00, $2C, $20, $FB
    db   $3E, $80, $E0, $26, $3E, $77, $E0, $24
    db   $3E, $FF, $E0, $25, $C9

toc_1B_401E:
    ld   hl, $D368
    ldi  a, [hl]
    and  a
    jr   nz, toc_1B_4031

    call toc_1B_4037
toc_1B_4028:
    call toc_1B_4481
    ret


toc_1B_402C:
    clear [$D3CE]
    ret


toc_1B_4031:
    ld   [hl], a
    call toc_1B_411B
    jr   toc_1B_4028

toc_1B_4037:
    ld   de, $D393
    ld   hl, $D378
    ldi  a, [hl]
    cp   $01
    jr   z, .else_1B_4048

    ld   a, [hl]
    cp   $01
    jr   z, .else_1B_4053

    ret


toc_1B_4037.else_1B_4048:
    assign [$D379], $01
    ld   hl, $4060
    jp   toc_1B_406A

toc_1B_4037.else_1B_4053:
    ld   a, [de]
    dec  a
    ld   [de], a
    ret  nz

    clear [$D379]
    ld   hl, $4065
    jr   toc_1B_406A

    db   $3B, $80, $07, $C0, $02, $00, $42, $02
    db   $C0, $04

toc_1B_406A:
    ld   b, $04
    ld   c, $20
toc_1B_406E:
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    dec  b
    jr   nz, toc_1B_406E

    ld   a, [hl]
    ld   [de], a
    ret


    db   $34, $50, $E2, $51, $93, $52, $2C, $53
    db   $05, $54, $58, $57, $F0, $59, $8D, $5A
    db   $7D, $5B, $71, $5C, $09, $5D, $B8, $5D
    db   $08, $5E, $27, $5E, $A7, $5E, $A8, $4A
    db   $0A, $5F, $C1, $5F, $17, $60, $96, $60
    db   $5F, $61, $41, $62, $1E, $4D, $00, $50
    db   $15, $63, $3E, $64, $DF, $64, $EC, $4B
    db   $13, $65, $9C, $6B, $EA, $6B, $01, $4B

toc_1B_40B7:
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


toc_1B_40C6:
    push bc
    ld   c, $30
toc_1B_40C6.loop_1B_40C9:
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    ld   a, c
    cp   $40
    jr   nz, .loop_1B_40C9

    pop  bc
    ret


toc_1B_40D3:
    clear [$D379]
    ld   [$D34F], a
    ld   [$D398], a
    ld   [$D393], a
    ld   [$D3C9], a
    ld   [$D3A3], a
    assign [gbAUD4ENV], $08
    assign [gbAUD4CONSEC], $80
    ret


toc_1B_40EF:
    ld   a, [$D379]
    cp   $0C
    jp   z, toc_1B_4DBC

    cp   $05
    jp   z, toc_1B_4DBC

    cp   $1A
    jp   z, toc_1B_4DBC

    cp   $24
    jp   z, toc_1B_4DBC

    cp   $2A
    jp   z, toc_1B_4DBC

    cp   $2E
    jp   z, toc_1B_4DBC

    cp   $3F
    jp   z, toc_1B_4DBC

    call toc_1B_40D3
    jp   toc_1B_4DBC

toc_1B_411B:
    cp   $FF
    jr   z, toc_1B_40EF

    copyFromTo [$D3CA], [$D3CB]
    ld   a, [hl]
    ld   [$D3CA], a
    cp   $11
    jr   nc, .else_1B_412F

    jr   .toc_1B_4144

toc_1B_411B.else_1B_412F:
    cp   $21
    jr   nc, .else_1B_4136

    jp   toc_1B_402C

toc_1B_411B.else_1B_4136:
    cp   $31
    jr   nc, .else_1B_413D

    jp   toc_1B_402C

toc_1B_411B.else_1B_413D:
    cp   $41
    jp   nc, toc_1B_402C

    add  a, $E0
toc_1B_411B.toc_1B_4144:
    dec  hl
    ldi  [hl], a
    ld   b, a
    assign [$D3CE], $01
    ld   a, b
    ld   [hl], a
    ld   b, a
    ld   hl, $4077
    and  %01111111
    call toc_1B_40B7
    call toc_1B_42AE
    jp   toc_1B_4247

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

toc_1B_421D:
    ld   a, [$D3E7]
    and  a
    jp   z, toc_1B_4481.toc_1B_463D

    clear [gbAUD3ENA]
    ld   [$D3E7], a
    push hl
    ld   a, [$D336]
    ld   l, a
    ld   a, [$D337]
    ld   h, a
    push bc
    ld   c, $30
toc_1B_4236:
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    ld   a, c
    cp   $40
    jr   nz, toc_1B_4236

    assign [gbAUD3ENA], $80
    pop  bc
    pop  hl
    jp   toc_1B_4481.toc_1B_463D

toc_1B_4247:
    ld   a, [$D369]
    ld   hl, $415D
toc_1B_424D:
    dec  a
    jr   z, toc_1B_4258

    inc  hl
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    jr   toc_1B_424D

toc_1B_4258:
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


toc_1B_4275:
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
    jr   z, .else_1B_4299

    inc  c
    cp   $01
    jr   z, .else_1B_4299

    inc  c
    cp   $02
    jr   z, .else_1B_4299

    inc  c
toc_1B_4275.else_1B_4299:
    ld   a, [bc]
    ld   [gbAUDTERM], a
    ret


toc_1B_429D:
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


toc_1B_42A8:
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ldi  a, [hl]
    ld   [de], a
    ret


toc_1B_42AE:
    ifEq [$D379], $05, .else_1B_42D0

    cp   $0C
    jr   z, .else_1B_42D0

    cp   $1A
    jr   z, .else_1B_42D0

    cp   $24
    jr   z, .else_1B_42D0

    cp   $2A
    jr   z, .else_1B_42D0

    cp   $2E
    jr   z, .else_1B_42D0

    cp   $3F
    jr   z, .else_1B_42D0

    call toc_1B_40D3
toc_1B_42AE.else_1B_42D0:
    call toc_1B_4DC9
    ld   de, $D300
    ld   b, $00
    ldi  a, [hl]
    ld   [de], a
    inc  e
    call toc_1B_42A8
    ld   de, $D310
    call toc_1B_42A8
    ld   de, $D320
    call toc_1B_42A8
    ld   de, $D330
    call toc_1B_42A8
    ld   de, $D340
    call toc_1B_42A8
    ld   hl, $D310
    ld   de, $D314
    call toc_1B_429D
    ld   hl, $D320
    ld   de, $D324
    call toc_1B_429D
    ld   hl, $D330
    ld   de, $D334
    call toc_1B_429D
    ld   hl, $D340
    ld   de, $D344
    call toc_1B_429D
    ld   bc, $0410
    ld   hl, $D312
toc_1B_42AE.loop_1B_4320:
    ld   [hl], $01
    ld   a, c
    add  a, l
    ld   l, a
    dec  b
    jr   nz, .loop_1B_4320

    clear [$D31E]
    ld   [$D32E], a
    ld   [$D33E], a
    ret


toc_1B_4333:
    push hl
    ld   a, e
    ld   [$D336], a
    ld   a, d
    ld   [$D337], a
    ld   a, [$D371]
    and  a
    jr   nz, toc_1B_434A

    clear [gbAUD3ENA]
    ld   l, e
    ld   h, d
    call toc_1B_40C6
toc_1B_434A:
    pop  hl
    jr   toc_1B_4377

toc_1B_434D:
    call toc_1B_437D
    call toc_1B_4392
    ld   e, a
    call toc_1B_437D
    call toc_1B_4392
    ld   d, a
    call toc_1B_437D
    call toc_1B_4392
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
    jr   z, toc_1B_4333

toc_1B_4377:
    call toc_1B_437D
    jp   toc_1B_4481.toc_1B_44A3

toc_1B_437D:
    push de
    ldi  a, [hl]
    ld   e, a
    ldd  a, [hl]
    ld   d, a
    inc  de
toc_1B_437D.toc_1B_4383:
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldd  [hl], a
    pop  de
    ret


toc_1B_4389:
    push de
    ldi  a, [hl]
    ld   e, a
    ldd  a, [hl]
    ld   d, a
    inc  de
    inc  de
    jr   toc_1B_437D.toc_1B_4383

toc_1B_4392:
    ldi  a, [hl]
    ld   c, a
    ldd  a, [hl]
    ld   b, a
    ld   a, [bc]
    ld   b, a
    ret


toc_1B_4399:
    pop  hl
    jr   toc_1B_43CD

toc_1B_439C:
    ifNe [$D350], $03, toc_1B_43B3

    ld   a, [$D338]
    bit  7, a
    jr   z, toc_1B_43B3

    ld   a, [hl]
    cp   $06
    jr   nz, toc_1B_43B3

    assign [gbAUD3LEVEL], $40
toc_1B_43B3:
    push hl
    ld   a, l
    add  a, $09
    ld   l, a
    ld   a, [hl]
    and  a
    jr   nz, toc_1B_4399

    ld   a, l
    add  a, $04
    ld   l, a
    bit  7, [hl]
    jr   nz, toc_1B_4399

    pop  hl
    call toc_1B_4670
    push hl
    call toc_1B_46F9
    pop  hl
toc_1B_43CD:
    dec  l
    dec  l
    jp   toc_1B_4481.toc_1B_4650

toc_1B_43D2:
    dec  l
    dec  l
    dec  l
    dec  l
    call toc_1B_4389
toc_1B_43D9:
    ld   a, l
    add  a, $04
    ld   e, a
    ld   d, h
    call toc_1B_429D
    cp   $00
    jr   z, toc_1B_4404

    cp   $FF
    jr   z, toc_1B_43ED

    inc  l
    jp   toc_1B_4481.toc_1B_44A1

toc_1B_43ED:
    dec  l
    push hl
    call toc_1B_4389
    call toc_1B_4392
    ld   e, a
    call toc_1B_437D
    call toc_1B_4392
    ld   d, a
    pop  hl
    ld   a, e
    ldi  [hl], a
    ld   a, d
    ldd  [hl], a
    jr   toc_1B_43D9

toc_1B_4404:
    ld   a, [$D3CA]
    cp   $0F
    jp   z, toc_1B_4757

    cp   $10
    jp   z, toc_1B_4757

    cp   $25
    jp   z, toc_1B_4757

    ld   hl, $D369
    ld   [hl], $00
    call toc_1B_40EF
    ret


toc_1B_441F:
    call toc_1B_437D
    call toc_1B_4392
    ld   [$D301], a
    call toc_1B_437D
    call toc_1B_4392
    ld   [$D302], a
    jr   toc_1B_443C

toc_1B_4433:
    call toc_1B_437D
    call toc_1B_4392
    ld   [$D300], a
toc_1B_443C:
    call toc_1B_437D
    jr   toc_1B_4481.toc_1B_44A3

toc_1B_4441:
    call toc_1B_437D
    call toc_1B_4392
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
    jr   toc_1B_4481.toc_1B_44A3

toc_1B_4465:
    push hl
    ld   a, l
    add  a, $0B
    ld   l, a
    ld   a, [hl]
    dec  [hl]
    ld   a, [hl]
    and  %01111111
    jr   z, toc_1B_447E

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
    jr   toc_1B_4481.toc_1B_44A3

toc_1B_447E:
    pop  hl
    jr   toc_1B_443C

toc_1B_4481:
    ld   hl, $D369
    ld   a, [hl]
    and  a
    ret  z

    ld   a, [$D3CE]
    and  a
    ret  z

    call toc_1B_4275
    assign [$D350], $01
    ld   hl, $D310
toc_1B_4481.toc_1B_4497:
    inc  l
    ldi  a, [hl]
    and  a
    jp   z, toc_1B_43CD

    dec  [hl]
    jp   nz, toc_1B_439C

toc_1B_4481.toc_1B_44A1:
    inc  l
    inc  l
toc_1B_4481.toc_1B_44A3:
    call toc_1B_4392
    cp   $00
    jp   z, toc_1B_43D2

    cp   $9D
    jp   z, toc_1B_434D

    cp   $9E
    jp   z, toc_1B_441F

    cp   $9F
    jp   z, toc_1B_4433

    cp   $9B
    jp   z, toc_1B_4441

    cp   $9C
    jp   z, toc_1B_4465

    cp   $99
    jp   z, toc_1B_4771

    cp   $9A
    jp   z, toc_1B_477C

    cp   $94
    jp   z, toc_1B_48FF

    cp   $97
    jp   z, toc_1B_47B8

    cp   $98
    jp   z, toc_1B_47C7

    cp   $96
    jp   z, toc_1B_4763

    cp   $95
    jp   z, toc_1B_476E

    and  %11110000
    cp   $A0
    jr   nz, .else_1B_453A

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
    and  $F0
    jr   nz, .else_1B_450C

    ld   a, d
    jr   .toc_1B_4531

toc_1B_4481.else_1B_450C:
    ld   e, a
    ld   a, d
    push af
    srl  a
    sla  e
    jr   c, .else_1B_451D

    ld   d, a
    srl  a
    sla  e
    jr   c, .else_1B_451D

    add  a, d
toc_1B_4481.else_1B_451D:
    ld   c, a
    and  a
    jr   nz, .else_1B_4523

    ld   c, $02
toc_1B_4481.else_1B_4523:
    ld   de, $D350
    ld   a, [de]
    dec  a
    ld   e, a
    ld   d, $00
    ld   hl, $D307
    add  hl, de
    ld   [hl], c
    pop  af
toc_1B_4481.toc_1B_4531:
    pop  hl
    dec  l
    ldi  [hl], a
    call toc_1B_437D
    call toc_1B_4392
toc_1B_4481.else_1B_453A:
    ifEq [$D350], $04, .else_1B_4579

    push de
    ld   de, $D3B0
    call toc_1B_4807
    xor  a
    ld   [de], a
    inc  e
    ld   [de], a
    ld   de, $D3B6
    call toc_1B_4807
    inc  e
    xor  a
    ld   [de], a
    ifNe [$D350], $03, .else_1B_4578

    ld   de, $D39E
    ld   a, [de]
    and  a
    jr   z, .else_1B_456A

    ld   a, $01
    ld   [de], a
    clear [$D39F]
toc_1B_4481.else_1B_456A:
    ld   de, $D3D9
    ld   a, [de]
    and  a
    jr   z, .else_1B_4578

    ld   a, $01
    ld   [de], a
    clear [$D3DA]
toc_1B_4481.else_1B_4578:
    pop  de
toc_1B_4481.else_1B_4579:
    ld   c, b
    ld   b, $00
    call toc_1B_437D
    ld   a, [$D350]
    cp   $04
    jp   z, .toc_1B_45BB

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
    jr   z, .else_1B_45B6

    ld   [hl], $00
    ifNot [$D300], .else_1B_45A9

    ld   l, a
    ld   h, $00
    bit  7, l
    jr   z, .else_1B_45A6

    ld   h, $FF
toc_1B_4481.else_1B_45A6:
    add  hl, bc
    ld   b, h
    ld   c, l
toc_1B_4481.else_1B_45A9:
    ld   hl, $4934
    add  hl, bc
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ld   a, [hl]
    ld   [de], a
    pop  hl
    jp   .toc_1B_45EC

toc_1B_4481.else_1B_45B6:
    ld   [hl], $01
    pop  hl
    jr   .toc_1B_45EC

toc_1B_4481.toc_1B_45BB:
    push hl
    ld   a, c
    cp   $FF
    jr   z, .else_1B_45D9

    ld   de, $D346
    ld   hl, $49C6
    add  hl, bc
toc_1B_4481.loop_1B_45C8:
    ldi  a, [hl]
    ld   [de], a
    inc  e
    ld   a, e
    cp   $4B
    jr   nz, .loop_1B_45C8

    ld   c, $20
    ld   hl, $D344
    ld   b, $00
    jr   .toc_1B_461A

toc_1B_4481.else_1B_45D9:
    ld   a, [$D34F]
    bit  7, a
    jp   nz, .else_1B_464B

    assign [$D378], $01
    call toc_1B_4037
    jp   .else_1B_464B

toc_1B_4481.toc_1B_45EC:
    push hl
    ld   b, $00
    ifEq [$D350], $01, .else_1B_4617

    cp   $02
    jr   z, .else_1B_4613

    ld   c, $1A
    ld   a, [$D33F]
    bit  7, a
    jr   nz, .else_1B_4608

    xor  a
    ld   [$ff00+c], a
    ld   a, $80
    ld   [$ff00+c], a
toc_1B_4481.else_1B_4608:
    inc  c
    inc  l
    inc  l
    inc  l
    inc  l
    ldi  a, [hl]
    ld   e, a
    ld   d, $00
    jr   .toc_1B_4621

toc_1B_4481.else_1B_4613:
    ld   c, $16
    jr   .toc_1B_461A

toc_1B_4481.else_1B_4617:
    ld   c, $10
    inc  c
toc_1B_4481.toc_1B_461A:
    inc  l
    inc  l
    ldi  a, [hl]
    ld   e, a
    inc  l
    ldi  a, [hl]
    ld   d, a
toc_1B_4481.toc_1B_4621:
    push hl
    inc  l
    inc  l
    ldi  a, [hl]
    and  a
    jr   z, .else_1B_462A

    ld   e, $08
toc_1B_4481.else_1B_462A:
    inc  l
    inc  l
    ld   [hl], $00
    inc  l
    ld   a, [hl]
    pop  hl
    bit  7, a
    jr   nz, .else_1B_464B

    ld   a, [$D350]
    cp   $03
    jp   z, toc_1B_421D

toc_1B_4481.toc_1B_463D:
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
toc_1B_4481.else_1B_464B:
    pop  hl
    dec  l
    ldd  a, [hl]
    ldd  [hl], a
    dec  l
toc_1B_4481.toc_1B_4650:
    ld   de, $D350
    ld   a, [de]
    cp   $04
    jr   z, .else_1B_4661

    inc  a
    ld   [de], a
    ld   a, $10
    add  a, l
    ld   l, a
    jp   .toc_1B_4497

toc_1B_4481.else_1B_4661:
    incAddr $D31E
    incAddr $D32E
    incAddr $D33E
    ret


toc_1B_466E:
    pop  hl
    ret


toc_1B_4670:
    push hl
    ld   a, l
    add  a, $06
    ld   l, a
    ld   a, [hl]
    and  %00001111
    jr   z, .else_1B_4692

    ld   [$D351], a
    ld   a, [$D350]
    ld   c, $13
    cp   $01
    jr   z, .else_1B_46D4

    ld   c, $18
    cp   $02
    jr   z, .else_1B_46D4

    ld   c, $1D
    cp   $03
    jr   z, .else_1B_46D4

toc_1B_4670.else_1B_4692:
    ld   a, [$D350]
    cp   $04
    jp   z, toc_1B_466E

    ld   de, $D3B6
    call toc_1B_4807
    ld   a, [de]
    and  a
    jp   z, .toc_1B_46BB

    ld   a, [$D350]
    ld   c, $13
    cp   $01
    jp   z, toc_1B_47D0

    ld   c, $18
    cp   $02
    jp   z, toc_1B_47D0

    ld   c, $1D
    jp   toc_1B_47D0

toc_1B_4670.toc_1B_46BB:
    ld   a, [$D350]
    cp   $03
    jp   nz, toc_1B_466E

    ld   a, [$D39E]
    and  a
    jp   nz, toc_1B_4782

    ld   a, [$D3D9]
    and  a
    jp   nz, toc_1B_490A

    jp   toc_1B_466E

toc_1B_4670.else_1B_46D4:
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
    jp   z, toc_1B_481D

    cp   $05
    jp   z, toc_1B_488A

    ld   hl, gbIE
    pop  de
    add  hl, de
    call toc_1B_47F6
    jp   .else_1B_4692

toc_1B_46F9:
    ld   a, [$D31B]
    and  a
    jr   nz, .else_1B_4720

    ifNot [$D317], .else_1B_4720

    and  %00001111
    ld   b, a
    ld   hl, $D307
    ld   a, [$D31E]
    cp   [hl]
    jr   nz, .else_1B_4720

    ld   c, $12
    ld   de, $D31A
    ld   a, [$D31F]
    bit  7, a
    jr   nz, .else_1B_4720

    call toc_1B_4744
toc_1B_46F9.else_1B_4720:
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
    call toc_1B_4744
    ret


toc_1B_4744:
    push bc
    dec  b
    ld   c, b
    ld   b, $00
    ld   hl, $4A85
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


toc_1B_4757:
    clear [$D3CE]
    copyFromTo [hNextDefaultMusicTrack], [$D368]
    jp   toc_1B_401E

toc_1B_4763:
    ld   a, $01
toc_1B_4765:
    ld   [$D3CD], a
    call toc_1B_437D
    jp   toc_1B_4481.toc_1B_44A3

toc_1B_476E:
    xor  a
    jr   toc_1B_4765

toc_1B_4771:
    ld   a, $01
toc_1B_4773:
    ld   [$D39E], a
    call toc_1B_437D
    jp   toc_1B_4481.toc_1B_44A3

toc_1B_477C:
    clear [$D39E]
    jr   toc_1B_4773

toc_1B_4782:
    cp   $02
    jp   z, toc_1B_466E

    ld   bc, $D39F
    call toc_1B_47B4
    ld   c, $1C
    ld   b, $40
    cp   $03
    jr   z, toc_1B_47AF

    ld   b, $60
    cp   $05
    jr   z, toc_1B_47AF

    cp   $0A
    jr   z, toc_1B_47AF

    ld   b, $00
    cp   $07
    jr   z, toc_1B_47AF

    cp   $0D
    jp   nz, toc_1B_466E

    assign [$D39E], $02
toc_1B_47AF:
    ld   a, b
    ld   [$ff00+c], a
    jp   toc_1B_466E

toc_1B_47B4:
    ld   a, [bc]
    inc  a
    ld   [bc], a
    ret


toc_1B_47B8:
    ld   de, $D3B6
    call toc_1B_4807
    ld   a, $01
toc_1B_47C0:
    ld   [de], a
    call toc_1B_437D
    jp   toc_1B_4481.toc_1B_44A3

toc_1B_47C7:
    ld   de, $D3B6
    call toc_1B_4807
    xor  a
    jr   toc_1B_47C0

toc_1B_47D0:
    inc  e
    ld   a, [de]
    and  a
    jr   nz, toc_1B_47E6

    inc  a
    ld   [de], a
    pop  hl
    push hl
    call toc_1B_47EB
toc_1B_47DC:
    ld   hl, $FF9C
    add  hl, de
    call toc_1B_47F6
    jp   toc_1B_466E

toc_1B_47E6:
    call toc_1B_4810
    jr   toc_1B_47DC

toc_1B_47EB:
    ld   a, $07
    add  a, l
    ld   l, a
    ldi  a, [hl]
    ld   e, a
    ld   a, [hl]
    and  %00001111
    ld   d, a
    ret


toc_1B_47F6:
    ld   de, $D3A4
    call toc_1B_4807
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


toc_1B_4807:
    ld   a, [$D350]
    dec  a
    sla  a
    add  a, e
    ld   e, a
    ret


toc_1B_4810:
    ld   de, $D3A4
    call toc_1B_4807
    ld   a, [de]
    ld   l, a
    inc  e
    ld   a, [de]
    ld   d, a
    ld   e, l
    ret


toc_1B_481D:
    pop  de
    ld   de, $D3B0
    call toc_1B_4807
    ld   a, [de]
    inc  a
    ld   [de], a
    inc  e
    cp   $19
    jr   z, toc_1B_485D

    cp   $2D
    jr   z, toc_1B_4856

    ld   a, [de]
    and  a
    jp   z, toc_1B_4670.else_1B_4692

toc_1B_4835:
    dec  e
    ld   a, [de]
    sub  a, $19
    sla  a
    ld   l, a
    ld   h, $00
    ld   de, $4862
    add  hl, de
    ldi  a, [hl]
    ld   d, a
    ld   a, [hl]
    ld   e, a
    pop  hl
    push hl
    push de
    call toc_1B_47EB
    ld   h, d
    ld   l, e
    pop  de
    add  hl, de
    call toc_1B_47F6
    jp   toc_1B_4670.else_1B_4692

toc_1B_4856:
    dec  e
    ld   a, $19
    ld   [de], a
    inc  e
    jr   toc_1B_4835

toc_1B_485D:
    ld   a, $01
    ld   [de], a
    jr   toc_1B_4835

    db   $00, $00, $00, $00, $00, $01, $00, $01
    db   $00, $02, $00, $02, $00, $00, $00, $00
    db   $FF, $FF, $FF, $FF, $FF, $FE, $FF, $FE
    db   $00, $00, $00, $01, $00, $02, $00, $01
    db   $00, $00, $FF, $FF, $FF, $FE, $FF, $FF

toc_1B_488A:
    pop  de
    ld   de, $D3D0
    call toc_1B_4807
    ld   a, [de]
    inc  a
    ld   [de], a
    inc  e
    cp   $21
    jr   z, toc_1B_48B8

toc_1B_4899:
    dec  e
    ld   a, [de]
    sla  a
    ld   l, a
    ld   h, $00
    ld   de, $48BF
    add  hl, de
    ldi  a, [hl]
    ld   d, a
    ld   a, [hl]
    ld   e, a
    pop  hl
    push hl
    push de
    call toc_1B_47EB
    ld   h, d
    ld   l, e
    pop  de
    add  hl, de
    call toc_1B_47F6
    jp   toc_1B_4670.else_1B_4692

toc_1B_48B8:
    dec  e
    ld   a, $01
    ld   [de], a
    inc  e
    jr   toc_1B_4899

    db   $00, $08, $00, $00, $FF, $F8, $00, $00
    db   $00, $0A, $00, $02, $FF, $FA, $00, $02
    db   $00, $0C, $00, $04, $FF, $FC, $00, $04
    db   $00, $0A, $00, $02, $FF, $FA, $00, $02
    db   $00, $08, $00, $00, $FF, $F8, $00, $00
    db   $00, $06, $FF, $FE, $FF, $F6, $FF, $FE
    db   $00, $04, $FF, $FC, $FF, $F4, $FF, $FC
    db   $00, $06, $FF, $FE, $FF, $F6, $FF, $FE

toc_1B_48FF:
    assign [$D3D9], $01
    call toc_1B_437D
    jp   toc_1B_4481.toc_1B_44A3

toc_1B_490A:
    cp   $02
    jp   z, toc_1B_466E

    ld   bc, $D3DA
    call toc_1B_47B4
    ld   c, $1C
    ld   b, $60
    cp   $03
    jp   z, toc_1B_47AF

    ld   b, $40
    cp   $05
    jp   z, toc_1B_47AF

    ld   b, $20
    cp   $06
    jp   nz, toc_1B_466E

    assign [$D3D9], $02
    jp   toc_1B_47AF

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
    db   $60, $80, $01, $02, $04, $08, $10, $20
    db   $06, $0C, $18, $01, $01, $01, $01, $01
    db   $30, $01, $03, $06, $0C, $18, $30, $09
    db   $12, $24, $02, $04, $08, $01, $01, $48
    db   $02, $04, $08, $10, $20, $40, $0C, $18
    db   $30, $02, $05, $03, $01, $01, $60, $03
    db   $05, $0A, $14, $28, $50, $0F, $1E, $3C
    db   $02, $08, $10, $02, $01, $78, $03, $06
    db   $0C, $18, $30, $60, $12, $24, $48, $03
    db   $08, $10, $02, $04, $90, $03, $07, $0E
    db   $1C, $38, $70, $15, $2A, $54, $04, $09
    db   $12, $02, $01, $A8, $04, $08, $10, $20
    db   $40, $80, $18, $30, $60, $04, $02, $01
    db   $01, $00, $C0, $04, $09, $12, $24, $48
    db   $90, $1B, $36, $6C, $05, $0C, $18, $18
    db   $06, $D8, $05, $0A, $14, $28, $50, $A0
    db   $1E, $3C, $78, $05, $01, $01, $01, $01
    db   $F0, $10, $32, $22, $47, $81, $20, $00
    db   $92, $4A, $FF, $FF, $8C, $4A, $9B, $20
    db   $AE, $01, $9C, $00, $00, $22, $44, $55
    db   $66, $66, $88, $88, $AA, $AA, $CC, $CC
    db   $04, $84, $04, $84, $00, $2B, $4A, $B3
    db   $4A, $B7, $4A, $BB, $4A, $BF, $4A, $C3
    db   $4A, $00, $00, $D3, $4A, $00, $00, $E1
    db   $4A, $00, $00, $F3, $4A, $00, $00, $9D
    db   $60, $21, $00, $96, $A2, $5C, $5E, $AA
    db   $60, $62, $64, $AE, $66, $95, $00, $9D
    db   $80, $21, $41, $A2, $4A, $4C, $AA, $4E
    db   $50, $52, $AE, $54, $00, $9D, $42, $6E
    db   $20, $99, $A2, $3C, $3E, $AA, $40, $42
    db   $44, $9A, $A5, $46, $A4, $01, $00, $A3
    db   $01, $AA, $15, $1A, $1A, $9B, $1E, $A0
    db   $15, $9C, $A7, $01, $00, $04, $67, $4A
    db   $0C, $4B, $24, $4B, $2C, $4B, $00, $00
    db   $42, $4B, $7C, $4B, $7C, $4B, $7C, $4B
    db   $7C, $4B, $7C, $4B, $7C, $4B, $7C, $4B
    db   $7C, $4B, $E6, $4B, $FF, $FF, $0C, $4B
    db   $47, $4B, $B1, $4B, $FF, $FF, $24, $4B
    db   $77, $4B, $77, $4B, $77, $4B, $77, $4B
    db   $77, $4B, $77, $4B, $77, $4B, $77, $4B
    db   $E6, $4B, $FF, $FF, $2C, $4B, $9D, $31
    db   $00, $40, $00, $9D, $30, $81, $80, $9B
    db   $08, $A3, $01, $A2, $44, $46, $A3, $4A
    db   $A2, $54, $5C, $A7, $5C, $A1, $58, $56
    db   $A4, $58, $A2, $01, $58, $5C, $5E, $A3
    db   $5C, $58, $A5, $4A, $A4, $7A, $A7, $6C
    db   $A1, $6A, $6C, $A4, $70, $62, $66, $AE
    db   $74, $9C, $00, $9D, $52, $6E, $40, $99
    db   $9B, $02, $A2, $24, $2C, $32, $2C, $9C
    db   $9B, $02, $24, $30, $36, $30, $9C, $24
    db   $2E, $36, $2E, $22, $2E, $34, $2E, $2C
    db   $32, $40, $3A, $3C, $36, $32, $2C, $9B
    db   $02, $28, $2E, $36, $2E, $9C, $9B, $02
    db   $28, $2E, $34, $2E, $9C, $9B, $04, $24
    db   $2C, $32, $2C, $9C, $00, $9D, $61, $00
    db   $80, $A4, $01, $97, $AC, $01, $AD, $2C
    db   $2C, $AC, $2C, $AA, $2C, $98, $AC, $32
    db   $AD, $32, $36, $AC, $3A, $AA, $36, $A3
    db   $32, $40, $3A, $4A, $A4, $40, $AC, $40
    db   $AD, $40, $42, $AC, $40, $AA, $3E, $A4
    db   $38, $A3, $36, $A7, $40, $A4, $40, $A7
    db   $01, $00, $9B, $0B, $A4, $01, $9C, $00
    db   $00, $58, $4A, $F7, $4B, $FF, $4B, $07
    db   $4C, $0F, $4C, $17, $4C, $50, $4C, $FF
    db   $FF, $F9, $4B, $24, $4C, $61, $4C, $FF
    db   $FF, $01, $4C, $31, $4C, $B1, $4C, $FF
    db   $FF, $09, $4C, $3E, $4C, $FA, $4C, $FF
    db   $FF, $11, $4C, $9D, $60, $00, $41, $A7
    db   $01, $A1, $4E, $AA, $01, $AE, $50, $00
    db   $9D, $40, $00, $01, $A7, $01, $A1, $64
    db   $AA, $01, $AE, $66, $00, $9D, $A1, $4C
    db   $20, $A7, $01, $A1, $5A, $AA, $01, $AE
    db   $5C, $00, $A7, $01, $A1, $01, $AA, $01
    db   $A5, $01, $A1, $FF, $A2, $FF, $FF, $A1
    db   $FF, $A2, $FF, $00, $9D, $22, $00, $80
    db   $97, $9B, $20, $A1, $54, $6A, $62, $5C
    db   $78, $70, $6A, $9C, $00, $9D, $81, $00
    db   $40, $A6, $46, $A0, $46, $4A, $A6, $4E
    db   $A1, $4A, $A3, $46, $54, $4E, $5E, $A4
    db   $54, $A6, $54, $A0, $54, $56, $A6, $54
    db   $A1, $52, $A4, $4C, $A3, $4A, $54, $A4
    db   $46, $A5, $01, $01, $01, $9D, $61, $00
    db   $80, $97, $A1, $36, $A6, $36, $A1, $36
    db   $A6, $36, $A1, $36, $A2, $36, $36, $A1
    db   $36, $A2, $36, $98, $00, $8A, $DF, $DA
    db   $86, $31, $01, $36, $86, $8A, $DF, $DA
    db   $86, $31, $01, $36, $86, $9D, $A1, $4C
    db   $20, $97, $9B, $02, $AA, $30, $01, $A0
    db   $01, $A1, $01, $9C, $A6, $01, $AA, $30
    db   $01, $A0, $01, $A1, $01, $9B, $02, $AA
    db   $30, $01, $A0, $01, $9C, $A1, $01, $A3
    db   $01, $9B, $02, $AA, $30, $01, $A0, $01
    db   $A1, $01, $9C, $A6, $01, $AA, $30, $01
    db   $A0, $01, $A1, $01, $9B, $02, $AA, $30
    db   $01, $A0, $01, $9C, $A1, $01, $A6, $01
    db   $AA, $30, $01, $A0, $01, $00, $9B, $07
    db   $A1, $15, $15, $15, $15, $FF, $15, $15
    db   $15, $15, $15, $15, $15, $FF, $15, $15
    db   $1A, $9C, $9B, $02, $FF, $FF, $15, $15
    db   $9C, $FF, $FF, $15, $FF, $15, $FF, $FF
    db   $15, $00, $00, $2B, $4A, $29, $4D, $2F
    db   $4D, $35, $4D, $00, $00, $3B, $4D, $FF
    db   $FF, $29, $4D, $51, $4D, $FF, $FF, $2F
    db   $4D, $87, $4D, $FF, $FF, $35, $4D, $9D
    db   $43, $00, $80, $A7, $4C, $4C, $4C, $4C
    db   $4A, $4A, $4A, $4A, $46, $46, $46, $46
    db   $42, $46, $4A, $50, $00, $9D, $40, $21
    db   $80, $A8, $5A, $A3, $01, $A2, $58, $A3
    db   $5E, $A8, $50, $A2, $01, $A3, $5A, $A2
    db   $42, $A3, $46, $A2, $4A, $A3, $4C, $A2
    db   $4A, $A3, $4C, $A7, $40, $54, $AE, $50
    db   $A2, $01, $00, $44, $44, $44, $42, $00
    db   $00, $00, $00, $44, $44, $44, $42, $00
    db   $00, $00, $00, $9D, $77, $4D, $20, $99
    db   $A7, $4A, $4A, $46, $46, $46, $46, $42
    db   $42, $42, $42, $40, $40, $3E, $3E, $44
    db   $4A, $00, $AF, $EA, $79, $D3, $EA, $4F
    db   $D3, $EA, $98, $D3, $EA, $93, $D3, $EA
    db   $C9, $D3, $EA, $A3, $D3, $EA, $E5, $D3
    db   $3E, $08, $E0, $21, $3E, $80, $E0, $23

toc_1B_4DBC:
    assign [gbAUDTERM], $FF
    assign [$D355], $03
    clear [$D369]
toc_1B_4DC9:
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
    db   $00, $58, $4A, $8C, $4A, $8C, $4A, $0B
    db   $50, $00, $00, $0F, $50, $00, $00, $9D
    db   $82, $6E, $01, $94, $A3, $4A, $A2, $4E
    db   $A3, $52, $A2, $4E, $A7, $4A, $58, $52
    db   $62, $A8, $58, $A3, $58, $A2, $5A, $A3
    db   $58, $A2, $56, $A8, $50, $A7, $4E, $58
    db   $A8, $4A, $9A, $00, $00, $3A, $4A, $3F
    db   $50, $47, $50, $4F, $50, $00, $00, $EC
    db   $6F, $5B, $50, $FF, $FF, $41, $50, $AB
    db   $50, $D9, $50, $FF, $FF, $49, $50, $E1
    db   $6E, $3C, $51, $C2, $6E, $7E, $51, $FF
    db   $FF, $53, $50, $9D, $66, $81, $80, $A5
    db   $01, $A2, $01, $5E, $A1, $5E, $62, $66
    db   $68, $A3, $6C, $01, $01, $A1, $64, $6E
    db   $72, $76, $A3, $7C, $01, $A7, $01, $A1
    db   $64, $68, $A2, $6C, $64, $A3, $5A, $A7
    db   $01, $9B, $02, $A1, $68, $6C, $A2, $6E
    db   $9C, $01, $A7, $01, $9B, $02, $A1, $64
    db   $68, $A2, $6C, $9C, $01, $A7, $01, $A1
    db   $62, $66, $A2, $6A, $A1, $6A, $6C, $70
    db   $74, $76, $7A, $A2, $74, $01, $A8, $01
    db   $A5, $01, $00, $9D, $A0, $84, $80, $A4
    db   $46, $A2, $01, $46, $46, $A1, $46, $46
    db   $9B, $02, $A6, $46, $A1, $42, $A3, $46
    db   $A2, $01, $46, $46, $A1, $46, $46, $9C
    db   $A2, $46, $A1, $3C, $3C, $9B, $02, $A2
    db   $3C, $A1, $3C, $3C, $9C, $A2, $3C, $3C
    db   $00, $9D, $80, $21, $40, $A2, $46, $01
    db   $A7, $3C, $A1, $01, $46, $46, $4A, $4E
    db   $50, $A4, $54, $A2, $01, $54, $54, $A1
    db   $56, $5A, $A4, $5E, $A2, $01, $5E, $5E
    db   $A1, $5A, $56, $A6, $5A, $A1, $56, $A4
    db   $54, $A3, $54, $A6, $50, $A1, $54, $A4
    db   $56, $A2, $54, $50, $A6, $4C, $A1, $50
    db   $A4, $54, $A2, $50, $4C, $A6, $4A, $A1
    db   $4E, $A4, $52, $A3, $58, $9D, $60, $81
    db   $80, $A2, $54, $A1, $46, $46, $A2, $46
    db   $A1, $46, $46, $A3, $46, $01, $A2, $01
    db   $A1, $44, $44, $A2, $44, $A1, $44, $44
    db   $A3, $44, $01, $00, $99, $A3, $4E, $A2
    db   $01, $A1, $2E, $2E, $A2, $2E, $4E, $4E
    db   $A1, $4E, $4E, $A6, $4A, $A1, $4A, $A2
    db   $4A, $A1, $2A, $2A, $A2, $2A, $4A, $4A
    db   $A1, $4A, $4A, $A6, $4C, $A1, $4C, $A2
    db   $4C, $A1, $26, $26, $A2, $26, $4C, $4C
    db   $A1, $4C, $4C, $A2, $4C, $A1, $44, $44
    db   $9B, $02, $A2, $44, $A1, $44, $44, $9C
    db   $A2, $24, $A1, $28, $2C, $00, $99, $9B
    db   $02, $A2, $2E, $A3, $46, $A2, $46, $9C
    db   $9B, $02, $A2, $2A, $A3, $42, $A2, $42
    db   $9C, $9B, $02, $A2, $26, $A3, $3E, $A2
    db   $3E, $9C, $9B, $02, $A2, $34, $A3, $4C
    db   $A2, $4C, $9C, $9B, $02, $A2, $30, $A3
    db   $48, $A2, $48, $9C, $9B, $02, $A2, $2E
    db   $A3, $46, $A2, $46, $9C, $A2, $32, $A3
    db   $4A, $A2, $4A, $32, $4A, $5E, $32, $3C
    db   $9B, $02, $A1, $50, $50, $A2, $50, $9C
    db   $A1, $32, $32, $A2, $32, $A1, $32, $32
    db   $A2, $3C, $9B, $02, $A1, $50, $50, $A2
    db   $50, $9C, $A1, $24, $24, $24, $26, $28
    db   $2C, $00, $00, $1C, $4A, $ED, $51, $0D
    db   $52, $21, $52, $00, $00, $FB, $6E, $A5
    db   $6F, $41, $52, $41, $52, $41, $52, $41
    db   $52, $41, $52, $41, $52, $00, $6F, $AB
    db   $6F, $41, $52, $41, $52, $41, $52, $4B
    db   $52, $FF, $FF, $ED, $51, $05, $6F, $A5
    db   $6F, $55, $52, $5D, $52, $0A, $6F, $AB
    db   $6F, $5D, $52, $7A, $52, $FF, $FF, $0D
    db   $52, $DC, $6E, $A5, $6F, $7D, $52, $7D
    db   $52, $7D, $52, $7D, $52, $7D, $52, $7D
    db   $52, $C2, $6E, $AB, $6F, $7D, $52, $7D
    db   $52, $7D, $52, $88, $52, $FF, $FF, $21
    db   $52, $A7, $22, $A2, $22, $A3, $24, $22
    db   $1E, $18, $00, $A7, $22, $A2, $22, $A3
    db   $24, $22, $1E, $01, $00, $9B, $03, $A8
    db   $01, $9C, $A4, $01, $00, $9B, $02, $A1
    db   $01, $40, $42, $44, $A7, $46, $A2, $3A
    db   $A4, $46, $A1, $01, $44, $46, $44, $A2
    db   $40, $3C, $A7, $40, $A2, $32, $A8, $40
    db   $9C, $00, $A3, $01, $00, $99, $A7, $32
    db   $A2, $32, $A3, $34, $32, $2E, $28, $00
    db   $99, $A7, $32, $A2, $32, $A3, $34, $32
    db   $2E, $01, $00, $00, $58, $4A, $9E, $52
    db   $A4, $52, $AC, $52, $00, $00, $EB, $52
    db   $FF, $FF, $9E, $52, $B6, $52, $BB, $52
    db   $FF, $FF, $A4, $52, $FB, $6F, $27, $53
    db   $BB, $52, $FF, $FF, $AE, $52, $9D, $57
    db   $00, $80, $00, $A2, $78, $7C, $A3, $7E
    db   $01, $01, $A2, $78, $7C, $A3, $7E, $01
    db   $01, $A2, $7C, $78, $6E, $A7, $74, $A3
    db   $78, $01, $A8, $01, $A2, $78, $7C, $A3
    db   $7E, $01, $01, $A2, $78, $7E, $A3, $88
    db   $01, $01, $A2, $86, $82, $A4, $86, $01
    db   $A8, $01, $00, $9D, $37, $00, $80, $A7
    db   $01, $9B, $02, $A2, $40, $4E, $58, $5C
    db   $A3, $60, $01, $9C, $A2, $48, $56, $5C
    db   $6A, $A3, $6E, $01, $A2, $48, $56, $5C
    db   $56, $44, $56, $5C, $56, $9B, $02, $A2
    db   $40, $4E, $58, $5C, $A3, $60, $01, $9C
    db   $A2, $36, $44, $4C, $52, $56, $5C, $64
    db   $6A, $6E, $6A, $6E, $74, $8C, $00, $9D
    db   $A2, $6E, $20, $00, $00, $67, $4A, $37
    db   $53, $3D, $53, $8C, $4A, $00, $00, $43
    db   $53, $FF, $FF, $37, $53, $A5, $53, $FF
    db   $FF, $3D, $53, $9D, $52, $00, $80, $99
    db   $9B, $02, $A2, $40, $4E, $9C, $9B, $02
    db   $40, $52, $9C, $9B, $02, $40, $56, $9C
    db   $9B, $02, $40, $52, $9C, $9B, $02, $40
    db   $4E, $9C, $9B, $02, $40, $50, $9C, $9B
    db   $02, $44, $52, $9C, $4E, $36, $3A, $36
    db   $9B, $02, $32, $40, $9C, $9B, $02, $32
    db   $44, $9C, $9B, $02, $30, $44, $9C, $9B
    db   $02, $3A, $48, $9C, $9B, $02, $2C, $3A
    db   $9C, $2C, $38, $36, $32, $9D, $40, $00
    db   $80, $A4, $36, $32, $9E, $76, $4A, $A4
    db   $30, $A7, $2C, $9D, $52, $00, $80, $A2
    db   $36, $9E, $67, $4A, $00, $9D, $56, $00
    db   $80, $A3, $66, $58, $A7, $5C, $A1, $60
    db   $62, $A2, $66, $66, $58, $58, $A7, $5C
    db   $A1, $60, $62, $A2, $60, $66, $A7, $74
    db   $A2, $70, $74, $70, $66, $A1, $62, $60
    db   $A3, $5C, $9D, $42, $00, $80, $56, $9D
    db   $56, $00, $80, $A1, $01, $60, $62, $66
    db   $A3, $6A, $58, $A7, $56, $A1, $5C, $6A
    db   $A2, $66, $66, $56, $56, $A7, $58, $A1
    db   $58, $56, $A2, $52, $58, $A7, $60, $A2
    db   $5C, $58, $50, $9B, $04, $4E, $66, $9C
    db   $9E, $76, $4A, $9B, $04, $A2, $66, $7E
    db   $9C, $9E, $67, $4A, $00, $00, $3A, $4A
    db   $10, $54, $1E, $54, $2C, $54, $00, $00
    db   $46, $54, $71, $54, $BC, $54, $71, $54
    db   $E9, $54, $FF, $FF, $12, $54, $62, $55
    db   $8F, $55, $C4, $55, $8F, $55, $E8, $55
    db   $FF, $FF, $20, $54, $C2, $6E, $64, $56
    db   $C2, $6E, $8D, $56, $AF, $56, $8D, $56
    db   $DD, $56, $C7, $6E, $EA, $56, $C2, $6E
    db   $F7, $56, $FF, $FF, $30, $54, $9D, $45
    db   $00, $80, $A3, $30, $AA, $30, $30, $30
    db   $A3, $2C, $AA, $2C, $30, $32, $A3, $38
    db   $AA, $38, $38, $38, $A3, $3C, $AA, $3C
    db   $3C, $3C, $9D, $40, $21, $81, $A8, $40
    db   $AA, $3C, $3C, $3C, $A8, $40, $A3, $01
    db   $00, $9D, $45, $00, $80, $A3, $30, $AA
    db   $32, $30, $2C, $A6, $30, $A1, $30, $30
    db   $32, $36, $3A, $A6, $3C, $A1, $40, $40
    db   $44, $48, $4A, $A3, $4E, $AA, $3C, $40
    db   $44, $A6, $46, $A1, $38, $38, $3C, $40
    db   $44, $AA, $46, $01, $46, $46, $44, $40
    db   $46, $01, $3C, $3C, $3C, $38, $3C, $01
    db   $3C, $3C, $38, $3C, $A2, $38, $A1, $38
    db   $36, $A2, $38, $A1, $38, $3C, $A3, $40
    db   $A2, $3C, $38, $00, $A2, $36, $A1, $36
    db   $32, $A2, $36, $A1, $36, $38, $A3, $3C
    db   $A2, $38, $36, $A3, $34, $A2, $34, $A1
    db   $34, $36, $A2, $3A, $A1, $3A, $3C, $40
    db   $44, $46, $4A, $A3, $44, $9D, $40, $21
    db   $41, $AA, $32, $32, $32, $A3, $36, $01
    db   $00, $9D, $45, $00, $80, $AA, $36, $34
    db   $36, $3E, $40, $44, $46, $01, $46, $46
    db   $44, $40, $9D, $70, $21, $80, $A6, $4E
    db   $46, $A2, $40, $A3, $3E, $AA, $3E, $3A
    db   $3E, $AA, $40, $44, $46, $4A, $46, $44
    db   $A3, $46, $01, $9D, $50, $21, $81, $A3
    db   $46, $A7, $40, $A1, $01, $46, $46, $4A
    db   $4E, $50, $AA, $4A, $01, $46, $A4, $44
    db   $A3, $3C, $AA, $40, $01, $36, $A3, $36
    db   $32, $3A, $A2, $40, $A1, $40, $3E, $40
    db   $44, $46, $4A, $A4, $4E, $AA, $4E, $01
    db   $4A, $A4, $46, $A3, $01, $AA, $4A, $01
    db   $50, $A4, $5A, $A3, $01, $01, $AA, $40
    db   $40, $40, $A3, $40, $01, $9D, $40, $21
    db   $40, $01, $AA, $4A, $4A, $4A, $A3, $4E
    db   $01, $00, $9D, $55, $00, $80, $A3, $40
    db   $AA, $40, $36, $40, $A3, $3C, $AA, $3C
    db   $40, $44, $A3, $46, $AA, $46, $40, $46
    db   $A3, $44, $AA, $44, $46, $4A, $9D, $50
    db   $21, $81, $A8, $4E, $AA, $4A, $4A, $4A
    db   $A8, $4E, $AA, $4A, $48, $44, $00, $9D
    db   $65, $00, $80, $A3, $40, $A7, $36, $A1
    db   $01, $40, $40, $44, $48, $4A, $A4, $4E
    db   $AA, $01, $01, $4E, $4E, $50, $54, $A4
    db   $58, $AA, $01, $01, $58, $58, $54, $50
    db   $54, $01, $50, $A4, $4E, $AA, $4E, $50
    db   $4E, $A2, $4A, $A1, $4A, $4E, $A4, $50
    db   $A2, $4E, $4A, $00, $A2, $46, $A1, $46
    db   $4A, $A4, $4E, $A2, $4A, $46, $44, $A1
    db   $44, $48, $A4, $4C, $A3, $52, $A2, $4E
    db   $9D, $60, $21, $01, $AD, $36, $36, $36
    db   $AA, $3A, $3A, $3A, $A3, $3E, $01, $00
    db   $9D, $45, $00, $80, $AA, $46, $44, $46
    db   $4A, $46, $4A, $4E, $01, $4E, $4E, $4A
    db   $46, $9D, $40, $00, $81, $A4, $4E, $66
    db   $A8, $58, $9D, $70, $21, $41, $AA, $4E
    db   $50, $54, $A3, $58, $A7, $4E, $A1, $01
    db   $58, $58, $5C, $5E, $62, $AA, $5C, $01
    db   $54, $A7, $4A, $A1, $4A, $4E, $54, $50
    db   $4E, $4A, $AA, $4E, $01, $40, $A7, $40
    db   $A1, $40, $3E, $40, $44, $46, $4A, $A4
    db   $4E, $A3, $01, $AA, $4E, $4A, $4E, $AA
    db   $5E, $01, $5C, $A3, $58, $AA, $01, $4E
    db   $4E, $4E, $46, $58, $5A, $01, $5E, $A3
    db   $62, $AA, $01, $62, $66, $68, $6C, $68
    db   $A5, $66, $9D, $40, $21, $40, $A2, $01
    db   $AD, $4E, $4E, $4E, $AA, $52, $52, $52
    db   $A3, $56, $01, $00, $99, $A3, $40, $AA
    db   $40, $40, $40, $A3, $3C, $AA, $3C, $3C
    db   $3C, $A3, $38, $AA, $38, $38, $38, $3C
    db   $3C, $3C, $3C, $38, $3C, $9B, $02, $A3
    db   $40, $AA, $40, $40, $40, $A3, $40, $AA
    db   $36, $36, $36, $9C, $00, $A3, $28, $AA
    db   $28, $28, $24, $A3, $28, $28, $24, $AA
    db   $24, $24, $20, $A3, $24, $24, $20, $AA
    db   $20, $20, $1E, $A3, $20, $20, $2E, $AA
    db   $2E, $2E, $2A, $A3, $2E, $2E, $00, $2A
    db   $AA, $2A, $2A, $28, $A3, $2A, $AA, $2A
    db   $2A, $2A, $A3, $28, $AA, $28, $28, $24
    db   $A3, $28, $AA, $28, $28, $28, $9B, $02
    db   $A3, $2C, $AA, $2C, $2C, $2C, $9C, $A3
    db   $36, $AA, $40, $40, $40, $9A, $A3, $44
    db   $99, $A2, $22, $26, $00, $A3, $2A, $AA
    db   $42, $42, $40, $A3, $42, $AA, $42, $42
    db   $42, $00, $9A, $A3, $40, $3E, $A4, $3C
    db   $A3, $3A, $32, $99, $A3, $36, $00, $AA
    db   $36, $4E, $4A, $46, $44, $40, $A3, $44
    db   $40, $01, $20, $AA, $38, $40, $46, $A3
    db   $50, $AA, $20, $20, $20, $A3, $1E, $AA
    db   $36, $3C, $44, $A3, $4E, $AA, $36, $36
    db   $36, $9B, $03, $A3, $28, $AA, $28, $28
    db   $28, $9C, $A6, $28, $28, $A2, $24, $A3
    db   $20, $AA, $20, $28, $2E, $A3, $38, $AA
    db   $20, $20, $20, $A3, $2A, $AA, $2A, $32
    db   $38, $A3, $42, $AA, $2A, $2A, $2A, $A3
    db   $1E, $AA, $4A, $4A, $4A, $A3, $4A, $AA
    db   $1E, $1E, $1E, $A3, $1E, $AA, $58, $58
    db   $58, $5C, $38, $36, $32, $2E, $2C, $00
    db   $00, $3A, $4A, $63, $57, $8D, $57, $A7
    db   $57, $C3, $57, $19, $6F, $D3, $57, $D3
    db   $57, $19, $6F, $F8, $57, $16, $58, $19
    db   $6F, $F8, $57, $A8, $6F, $FB, $6E, $F8
    db   $57, $1E, $6F, $F8, $57, $16, $58, $A5
    db   $6F, $E2, $6F, $19, $6F, $F8, $57, $F8
    db   $57, $FF, $FF, $69, $57, $EC, $6F, $6F
    db   $58, $23, $6F, $8E, $58, $EC, $6F, $EC
    db   $6F, $28, $6F, $8E, $58, $E2, $6F, $EC
    db   $6F, $1B, $59, $FF, $FF, $91, $57, $D6
    db   $6E, $26, $59, $EC, $6E, $33, $59, $7F
    db   $59, $EC, $6F, $F2, $6F, $E2, $6F, $7F
    db   $59, $E2, $6F, $EC, $6F, $EC, $6F, $FF
    db   $FF, $AB, $57, $94, $59, $A1, $59, $B8
    db   $59, $C2, $59, $B8, $59, $D9, $59, $FF
    db   $FF, $C5, $57, $9D, $33, $00, $80, $9B
    db   $04, $A2, $4E, $A1, $4E, $4E, $9C, $9B
    db   $04, $A2, $52, $A1, $52, $52, $9C, $9B
    db   $04, $A2, $54, $A1, $54, $54, $9C, $9B
    db   $04, $A2, $52, $A1, $52, $52, $9C, $00
    db   $9B, $04, $A1, $28, $36, $2E, $36, $9C
    db   $9B, $04, $28, $3A, $32, $3A, $9C, $9B
    db   $04, $28, $3C, $36, $3C, $9C, $9B, $04
    db   $28, $3A, $32, $3A, $9C, $00, $9B, $04
    db   $20, $36, $2E, $36, $9C, $9B, $04, $24
    db   $32, $2C, $32, $9C, $9B, $02, $24, $36
    db   $2E, $36, $9C, $9B, $02, $28, $3A, $32
    db   $3A, $9C, $9B, $04, $2C, $3E, $36, $3E
    db   $9C, $9B, $04, $28, $36, $2E, $36, $9C
    db   $9B, $04, $2A, $38, $32, $38, $9C, $9B
    db   $04, $28, $36, $2E, $36, $9C, $9B, $04
    db   $22, $36, $2E, $36, $9C, $9B, $04, $2A
    db   $38, $32, $38, $9C, $A1, $36, $40, $44
    db   $4A, $A3, $4E, $A4, $01, $9D, $50, $26
    db   $01, $A4, $4E, $4A, $46, $4A, $00, $9D
    db   $40, $26, $41, $A3, $40, $A7, $36, $A2
    db   $40, $A1, $40, $44, $46, $4A, $A5, $4E
    db   $A3, $58, $A7, $4E, $A2, $58, $A1, $58
    db   $5C, $5E, $62, $A5, $66, $00, $A6, $40
    db   $A1, $36, $A7, $36, $A2, $40, $A1, $40
    db   $44, $46, $4A, $A7, $4E, $A1, $52, $54
    db   $A6, $52, $4E, $A2, $4A, $A6, $4E, $A1
    db   $40, $A5, $58, $A2, $01, $4E, $5E, $5C
    db   $5E, $62, $66, $A1, $58, $66, $A3, $70
    db   $A2, $01, $66, $62, $5E, $62, $A1, $54
    db   $62, $A3, $6C, $A2, $01, $62, $5E, $5C
    db   $A6, $5E, $A1, $4E, $A3, $4E, $A2, $01
    db   $AD, $4A, $4E, $4A, $A2, $46, $4A, $A5
    db   $4E, $A6, $40, $A1, $36, $A7, $36, $A2
    db   $40, $A1, $40, $44, $46, $4A, $A7, $4E
    db   $A1, $50, $54, $A6, $50, $4E, $A2, $4A
    db   $A6, $46, $A1, $40, $A7, $4E, $A2, $46
    db   $58, $4E, $A7, $5E, $A2, $5C, $58, $5C
    db   $5E, $62, $A2, $66, $A1, $62, $66, $A3
    db   $68, $A2, $01, $A6, $6C, $68, $66, $5C
    db   $A2, $5E, $A6, $62, $5E, $A2, $5C, $A5
    db   $58, $70, $00, $9D, $56, $00, $80, $9B
    db   $04, $A4, $01, $8C, $9C, $00, $9B, $1F
    db   $A2, $40, $A1, $40, $40, $9C, $01, $1A
    db   $16, $14, $00, $99, $9B, $02, $A3, $28
    db   $A4, $28, $A3, $28, $9C, $28, $A4, $28
    db   $A3, $36, $32, $A4, $32, $A2, $32, $36
    db   $A3, $38, $A4, $38, $A3, $38, $3C, $A4
    db   $3C, $A3, $3C, $2E, $2E, $32, $32, $36
    db   $A4, $36, $A1, $36, $32, $2E, $2C, $A3
    db   $28, $A4, $28, $A3, $28, $2A, $A4, $2A
    db   $A3, $2A, $28, $A4, $28, $A3, $24, $22
    db   $A4, $22, $A3, $22, $2A, $A4, $2A, $A3
    db   $2A, $36, $01, $01, $9A, $1E, $00, $A6
    db   $28, $36, $A2, $28, $A6, $24, $32, $A2
    db   $24, $A6, $20, $2E, $A2, $20, $A6, $24
    db   $32, $A2, $24, $00, $9B, $1F, $A2, $0B
    db   $A1, $0B, $0B, $9C, $15, $15, $15, $15
    db   $00, $9B, $0D, $A2, $15, $A1, $15, $15
    db   $A2, $15, $A1, $15, $15, $A2, $15, $A1
    db   $15, $15, $15, $15, $15, $15, $9C, $00
    db   $A1, $15, $15, $15, $15, $A3, $15, $A4
    db   $01, $00, $9B, $17, $A2, $15, $A1, $15
    db   $15, $A2, $15, $A1, $15, $15, $A2, $15
    db   $A1, $15, $15, $15, $15, $15, $15, $9C
    db   $00, $9B, $0C, $A2, $15, $A1, $15, $15
    db   $A2, $15, $A1, $15, $15, $A2, $15, $A1
    db   $15, $15, $15, $15, $15, $15, $9C, $00
    db   $00, $76, $4A, $FB, $59, $01, $5A, $07
    db   $5A, $00, $00, $0F, $5A, $FF, $FF, $FB
    db   $59, $3F, $5A, $FF, $FF, $01, $5A, $C7
    db   $6E, $7A, $5A, $FF, $FF, $07, $5A, $9D
    db   $44, $00, $80, $98, $9B, $02, $A3, $01
    db   $A2, $46, $A1, $88, $88, $A3, $01, $A2
    db   $44, $A1, $88, $88, $9C, $9D, $24, $00
    db   $80, $A3, $01, $A2, $64, $62, $60, $64
    db   $5E, $60, $5C, $60, $5A, $5C, $58, $56
    db   $A4, $01, $97, $A1, $88, $88, $00, $9D
    db   $50, $84, $00, $A6, $70, $A1, $66, $A2
    db   $60, $58, $A3, $5A, $A1, $68, $62, $5A
    db   $50, $A2, $4E, $A1, $66, $60, $A2, $58
    db   $4E, $54, $A1, $50, $54, $A3, $4E, $9D
    db   $24, $00, $00, $A2, $4C, $4E, $68, $66
    db   $64, $66, $62, $64, $60, $62, $5E, $60
    db   $A1, $5C, $5E, $5A, $5C, $A3, $01, $A7
    db   $01, $00, $9B, $02, $99, $A2, $40, $4C
    db   $56, $4C, $36, $4A, $54, $4A, $9C, $A5
    db   $01, $01, $A7, $01, $00, $00, $49, $4A
    db   $98, $5A, $B2, $5A, $C4, $5A, $D6, $5A
    db   $AB, $6F, $DF, $6F, $32, $6F, $F9, $5A
    db   $2D, $6F, $F9, $5A, $A5, $6F, $E0, $5A
    db   $AB, $6F, $E0, $5A, $E2, $6F, $FF, $FF
    db   $98, $5A, $32, $6F, $21, $5B, $2D, $6F
    db   $28, $5B, $00, $5B, $00, $5B, $E2, $6F
    db   $FF, $FF, $B2, $5A, $C2, $6E, $E2, $6F
    db   $2F, $5B, $45, $5B, $2F, $5B, $45, $5B
    db   $E2, $6F, $FF, $FF, $C4, $5A, $68, $5B
    db   $5A, $5B, $68, $5B, $FF, $FF, $D6, $5A
    db   $9D, $33, $00, $80, $9B, $04, $A1, $58
    db   $56, $54, $52, $50, $4E, $4C, $4A, $48
    db   $4A, $4C, $4E, $50, $52, $54, $56, $9C
    db   $00, $9B, $04, $A1, $46, $44, $9C, $00
    db   $9D, $40, $81, $80, $A7, $58, $A2, $4E
    db   $58, $5C, $60, $66, $A7, $64, $A2, $66
    db   $A4, $68, $A7, $58, $A2, $4E, $58, $5C
    db   $60, $66, $A7, $64, $A2, $66, $A4, $80
    db   $00, $9B, $0C, $A1, $58, $56, $9C, $00
    db   $9B, $04, $A1, $58, $56, $9C, $00, $99
    db   $A3, $28, $A2, $36, $A3, $28, $A2, $28
    db   $2A, $38, $A3, $28, $A2, $36, $A3, $28
    db   $A2, $28, $24, $26, $00, $A3, $28, $A2
    db   $36, $A3, $28, $A2, $28, $2A, $38, $A3
    db   $28, $A2, $36, $A3, $28, $A2, $28, $36
    db   $40, $00, $9B, $08, $A2, $29, $29, $29
    db   $29, $A3, $FF, $A2, $29, $29, $9C, $00
    db   $A3, $29, $A2, $29, $29, $A3, $FF, $A2
    db   $29, $29, $A2, $29, $29, $29, $29, $A3
    db   $FF, $A2, $29, $29, $00, $00, $76, $4A
    db   $88, $5B, $94, $5B, $9C, $5B, $A8, $5B
    db   $E2, $6F, $AE, $5B, $AE, $5B, $BE, $5B
    db   $FF, $FF, $8A, $5B, $D3, $5B, $F4, $5B
    db   $FF, $FF, $96, $5B, $E2, $6F, $EC, $6E
    db   $26, $5C, $44, $5C, $FF, $FF, $9E, $5B
    db   $61, $5C, $FF, $FF, $A8, $5B, $9D, $23
    db   $00, $80, $9B, $20, $A0, $5E, $62, $9C
    db   $9B, $20, $62, $64, $9C, $00, $9B, $20
    db   $5E, $54, $9C, $9B, $20, $5C, $52, $9C
    db   $9B, $20, $5E, $50, $9C, $9B, $20, $5C
    db   $52, $9C, $00, $9D, $81, $82, $00, $A2
    db   $10, $1E, $A1, $24, $A2, $26, $A1, $28
    db   $A7, $01, $A1, $0C, $0E, $A2, $10, $A1
    db   $1E, $A2, $24, $26, $A1, $28, $A7, $01
    db   $A1, $0C, $0E, $00, $9D, $40, $00, $81
    db   $9B, $02, $A4, $58, $4E, $A8, $4E, $A0
    db   $58, $56, $58, $5C, $5E, $5C, $5E, $62
    db   $A6, $66, $68, $A2, $6C, $A8, $70, $A2
    db   $70, $6C, $A6, $68, $62, $A2, $5A, $9C
    db   $9D, $30, $00, $01, $A5, $58, $4E, $50
    db   $52, $54, $54, $56, $56, $00, $99, $A2
    db   $28, $36, $A1, $3C, $A2, $3E, $A1, $40
    db   $A7, $01, $A1, $24, $26, $A2, $28, $A1
    db   $36, $A2, $3C, $3E, $A1, $40, $A7, $01
    db   $A1, $26, $28, $00, $A2, $2A, $38, $A1
    db   $3E, $A2, $40, $A1, $42, $A7, $01, $A1
    db   $26, $28, $A2, $2A, $A1, $38, $A2, $3E
    db   $40, $A1, $42, $A7, $01, $A1, $24, $26
    db   $00, $9B, $04, $A1, $29, $9C, $FF, $9B
    db   $05, $29, $9C, $FF, $9B, $05, $29, $9C
    db   $00, $04, $58, $4A, $7C, $5C, $86, $5C
    db   $8C, $4A, $00, $00, $AE, $6F, $FB, $6F
    db   $8E, $5C, $FF, $FF, $80, $5C, $B3, $6F
    db   $8E, $5C, $FF, $FF, $86, $5C, $A2, $5C
    db   $3C, $4A, $52, $58, $5C, $5E, $40, $4E
    db   $54, $5C, $5E, $62, $44, $52, $58, $70
    db   $6C, $62, $36, $44, $4A, $5E, $5C, $5C
    db   $40, $4E, $54, $58, $5C, $5E, $40, $4C
    db   $54, $5C, $5E, $58, $32, $40, $46, $4C
    db   $54, $52, $4A, $4E, $52, $54, $58, $5C
    db   $3C, $4A, $52, $58, $5C, $5E, $40, $4E
    db   $54, $5C, $5E, $62, $44, $52, $58, $74
    db   $70, $70, $36, $44, $6E, $68, $66, $62
    db   $40, $4E, $54, $5E, $5C, $5C, $32, $40
    db   $46, $58, $5C, $54, $46, $54, $5C, $5E
    db   $74, $70, $44, $52, $58, $5C, $6A, $66
    db   $40, $4E, $54, $58, $66, $64, $32, $40
    db   $46, $4C, $54, $62, $32, $3A, $40, $4A
    db   $52, $A3, $62, $A2, $62, $A7, $7A, $32
    db   $00, $00, $76, $4A, $14, $5D, $22, $5D
    db   $2C, $5D, $38, $5D, $DF, $6F, $A5, $6F
    db   $3E, $5D, $AB, $6F, $3E, $5D, $FF, $FF
    db   $16, $5D, $DF, $6F, $60, $5D, $60, $5D
    db   $FF, $FF, $24, $5D, $DF, $6F, $C2, $6E
    db   $7B, $5D, $7B, $5D, $FF, $FF, $2E, $5D
    db   $A5, $5D, $FF, $FF, $38, $5D, $9D, $44
    db   $00, $80, $A2, $01, $A1, $36, $36, $A2
    db   $34, $A3, $01, $A1, $36, $36, $A2, $38
    db   $A3, $01, $A1, $36, $36, $A2, $34, $A3
    db   $01, $A1, $36, $34, $A2, $36, $01, $00
    db   $9D, $64, $00, $00, $9B, $02, $A2, $40
    db   $36, $A1, $40, $44, $48, $4A, $A2, $4E
    db   $A0, $56, $A1, $58, $A0, $01, $A2, $4E
    db   $01, $9C, $00, $99, $A2, $28, $A1, $40
    db   $40, $A2, $3E, $A1, $36, $36, $A2, $28
    db   $A1, $40, $40, $A2, $42, $A1, $2A, $2A
    db   $A2, $28, $A1, $40, $40, $A2, $3E, $A1
    db   $36, $36, $A2, $28, $A1, $40, $3E, $A2
    db   $40, $A1, $28, $28, $00, $A2, $29, $A1
    db   $29, $29, $A2, $FF, $A1, $29, $29, $A1
    db   $29, $29, $29, $29, $A2, $FF, $1A, $00
    db   $00, $3A, $4A, $C3, $5D, $D3, $5D, $E1
    db   $5D, $00, $00, $F1, $5D, $01, $70, $A5
    db   $6F, $F6, $5D, $A2, $6F, $F6, $5D, $FF
    db   $FF, $C7, $5D, $B8, $6F, $A5, $6F, $F6
    db   $5D, $A2, $6F, $F6, $5D, $FF, $FF, $D3
    db   $5D, $FB, $6F, $E6, $6E, $A5, $6F, $F6
    db   $5D, $A2, $6F, $F6, $5D, $FF, $FF, $E3
    db   $5D, $9D, $44, $00, $80, $00, $A2, $30
    db   $34, $3A, $40, $48, $4C, $52, $58, $60
    db   $64, $6A, $70, $78, $7C, $82, $88, $00
    db   $00, $3A, $4A, $13, $5E, $19, $5E, $1F
    db   $5E, $00, $00, $5B, $50, $FF, $FF, $13
    db   $5E, $D9, $50, $FF, $FF, $19, $5E, $C2
    db   $6E, $7E, $51, $FF, $FF, $1F, $5E, $00
    db   $2B, $4A, $32, $5E, $52, $5E, $5E, $5E
    db   $00, $00, $A5, $6F, $0F, $6F, $6E, $5E
    db   $6E, $5E, $14, $6F, $6E, $5E, $6E, $5E
    db   $A2, $6F, $0F, $6F, $6E, $5E, $6E, $5E
    db   $14, $6F, $6E, $5E, $6E, $5E, $FF, $FF
    db   $32, $5E, $78, $5E, $91, $5E, $78, $5E
    db   $91, $5E, $FF, $FF, $52, $5E, $EC, $6E
    db   $A0, $5E, $A0, $5E, $F6, $6E, $A0, $5E
    db   $A0, $5E, $FF, $FF, $5E, $5E, $9B, $02
    db   $A2, $1C, $20, $20, $9C, $1C, $20, $00
    db   $9D, $70, $21, $40, $A7, $48, $A1, $44
    db   $48, $A7, $4A, $A1, $48, $4A, $A7, $4C
    db   $A1, $5C, $58, $A2, $4C, $64, $A3, $64
    db   $00, $9D, $20, $21, $81, $A2, $4C, $64
    db   $A8, $64, $A2, $64, $7C, $A8, $7C, $00
    db   $99, $A7, $28, $28, $A3, $28, $00, $00
    db   $2B, $4A, $B2, $5E, $BA, $5E, $C2, $5E
    db   $00, $00, $CC, $5E, $D1, $5E, $DB, $5E
    db   $00, $00, $D6, $5E, $DB, $5E, $D1, $5E
    db   $00, $00, $D6, $6E, $04, $70, $DB, $5E
    db   $FB, $6F, $00, $00, $9D, $26, $00, $80
    db   $00, $A3, $01, $A1, $01, $00, $9D, $67
    db   $00, $81, $00, $96, $A1, $70, $6E, $66
    db   $60, $58, $56, $4E, $48, $74, $70, $6A
    db   $62, $5C, $58, $52, $4A, $78, $74, $6E
    db   $66, $60, $5C, $56, $4E, $7A, $78, $70
    db   $6A, $62, $60, $58, $52, $A2, $36, $44
    db   $4A, $4E, $56, $5C, $62, $66, $A8, $7E
    db   $95, $00, $00, $3A, $4A, $15, $5F, $1B
    db   $5F, $21, $5F, $00, $00, $29, $5F, $FF
    db   $FF, $12, $54, $5C, $5F, $FF, $FF, $20
    db   $54, $C2, $6E, $85, $5F, $FF, $FF, $30
    db   $54, $9D, $70, $21, $81, $AA, $01, $36
    db   $40, $A3, $48, $AA, $48, $48, $44, $A3
    db   $48, $AA, $01, $3C, $46, $A3, $4E, $AA
    db   $4E, $4E, $4A, $A3, $4E, $A3, $01, $9B
    db   $02, $A3, $4C, $A2, $01, $A1, $4C, $4C
    db   $9C, $A8, $4A, $9D, $40, $21, $80, $AA
    db   $32, $30, $2C, $00, $9D, $90, $21, $81
    db   $AA, $36, $40, $48, $A8, $4E, $AA, $3C
    db   $46, $4E, $A8, $54, $AA, $4E, $54, $5E
    db   $9B, $02, $A3, $5A, $A2, $01, $A1, $5A
    db   $5A, $9C, $A8, $5C, $9D, $60, $21, $80
    db   $AA, $44, $40, $3E, $00, $99, $AA, $01
    db   $01, $4E, $9A, $A3, $58, $99, $AA, $40
    db   $40, $3C, $9A, $A3, $40, $99, $AA, $01
    db   $01, $54, $9A, $A3, $5E, $99, $AA, $46
    db   $46, $42, $9A, $A3, $46, $01, $99, $AA
    db   $2A, $28, $2A, $34, $32, $34, $3C, $3A
    db   $3C, $42, $4C, $54, $56, $52, $56, $58
    db   $56, $52, $A3, $4E, $AA, $1E, $1E, $1E
    db   $00, $00, $58, $4A, $CC, $5F, $D4, $5F
    db   $8C, $4A, $00, $00, $37, $6F, $DC, $5F
    db   $FF, $FF, $CC, $5F, $3C, $6F, $FE, $5F
    db   $FF, $FF, $D4, $5F, $A2, $32, $3A, $40
    db   $3A, $32, $36, $3E, $44, $30, $36, $3E
    db   $44, $22, $28, $30, $28, $2C, $32, $3A
    db   $32, $1E, $26, $2C, $26, $28, $2C, $32
    db   $36, $28, $30, $36, $3C, $00, $A4, $70
    db   $A2, $01, $6E, $74, $A4, $66, $A2, $01
    db   $70, $58, $5C, $60, $62, $60, $62, $A3
    db   $56, $6A, $A5, $66, $A2, $01, $00, $00
    db   $2B, $4A, $22, $60, $38, $60, $8C, $4A
    db   $00, $00, $59, $60, $65, $60, $4E, $60
    db   $4E, $60, $59, $60, $6A, $60, $4E, $60
    db   $4E, $60, $4E, $60, $FF, $FF, $22, $60
    db   $7E, $60, $8A, $60, $6F, $60, $6F, $60
    db   $7E, $60, $90, $60, $6F, $60, $6F, $60
    db   $6F, $60, $FF, $FF, $38, $60, $9B, $0C
    db   $AD, $01, $01, $01, $01, $9C, $A5, $01
    db   $00, $9D, $40, $41, $80, $9B, $02, $A3
    db   $28, $32, $32, $9C, $00, $A3, $30, $26
    db   $01, $00, $A3, $34, $2A, $01, $00, $9D
    db   $42, $00, $80, $9B, $0C, $AD, $46, $44
    db   $46, $01, $9C, $A5, $01, $00, $9D, $40
    db   $41, $80, $9B, $02, $A3, $30, $3A, $3A
    db   $9C, $00, $A3, $38, $2E, $A3, $01, $00
    db   $A3, $3C, $32, $A3, $01, $00, $00, $49
    db   $4A, $8C, $4A, $A1, $60, $B1, $60, $00
    db   $00, $C1, $60, $D9, $60, $D9, $60, $FA
    db   $60, $B3, $6F, $0F, $61, $01, $70, $00
    db   $00, $CC, $6E, $1D, $61, $29, $61, $D6
    db   $6E, $4C, $61, $59, $61, $0F, $61, $00
    db   $00, $9D, $43, $00, $80, $A4, $01, $A2
    db   $01, $A1, $78, $74, $A2, $78, $A3, $01
    db   $A1, $7A, $78, $A2, $7A, $A3, $01, $01
    db   $00, $9D, $55, $00, $00, $9E, $2B, $4A
    db   $9B, $02, $A1, $66, $68, $66, $64, $62
    db   $64, $62, $64, $9C, $A2, $66, $7E, $66
    db   $A1, $66, $68, $6A, $6C, $6A, $68, $A3
    db   $66, $00, $9D, $35, $00, $40, $9B, $02
    db   $A1, $66, $68, $66, $64, $62, $64, $62
    db   $64, $9C, $A5, $01, $A3, $01, $00, $9E
    db   $3A, $4A, $A0, $7E, $7A, $76, $72, $6E
    db   $6A, $A3, $66, $01, $00, $A4, $01, $A2
    db   $01, $99, $A3, $6C, $01, $6E, $01, $01
    db   $00, $9E, $2B, $4A, $99, $9B, $02, $A2
    db   $40, $4E, $36, $4E, $9C, $9B, $02, $42
    db   $50, $38, $50, $9C, $9B, $02, $46, $54
    db   $3C, $54, $9C, $4A, $58, $40, $58, $4A
    db   $58, $48, $44, $00, $9B, $02, $A2, $40
    db   $4E, $36, $4E, $9C, $A5, $01, $A3, $01
    db   $00, $9E, $3A, $4A, $A1, $01, $00, $00
    db   $49, $4A, $6A, $61, $76, $61, $82, $61
    db   $00, $00, $41, $6F, $8C, $61, $46, $6F
    db   $9A, $61, $9A, $61, $00, $00, $41, $6F
    db   $C8, $61, $46, $6F, $D6, $61, $D6, $61
    db   $00, $00, $F1, $6E, $04, $62, $11, $62
    db   $11, $62, $00, $00, $A4, $01, $A1, $26
    db   $2A, $2E, $30, $34, $01, $34, $01, $A5
    db   $36, $00, $A4, $01, $A2, $34, $38, $3C
    db   $3E, $A7, $42, $A2, $46, $42, $3E, $3C
    db   $38, $A4, $34, $A2, $3C, $3E, $42, $4C
    db   $A7, $54, $A2, $56, $54, $50, $4C, $4A
    db   $A7, $4C, $A1, $42, $42, $9B, $02, $A2
    db   $4C, $A1, $42, $42, $9C, $A5, $4C, $00
    db   $A5, $01, $A1, $40, $44, $48, $4A, $4E
    db   $01, $4E, $01, $A4, $50, $00, $A5, $01
    db   $A2, $4E, $52, $56, $58, $A7, $5C, $A2
    db   $60, $5C, $58, $56, $52, $A4, $4E, $A2
    db   $56, $58, $5C, $66, $A7, $6E, $A2, $70
    db   $6E, $6A, $66, $64, $A7, $66, $A1, $5C
    db   $5C, $9B, $02, $A2, $66, $A1, $5C, $5C
    db   $9C, $A4, $66, $00, $9A, $A1, $24, $28
    db   $2C, $2E, $32, $01, $32, $01, $AE, $34
    db   $00, $A2, $32, $36, $3A, $3C, $A7, $40
    db   $A2, $44, $40, $3C, $3A, $36, $A4, $32
    db   $A2, $3A, $3C, $40, $4A, $A7, $52, $A2
    db   $54, $52, $4E, $4A, $48, $A3, $4A, $A2
    db   $01, $99, $A1, $40, $40, $9B, $02, $A2
    db   $4A, $A1, $40, $40, $9C, $9A, $AE, $4A
    db   $00, $00, $49, $4A, $8C, $4A, $4C, $62
    db   $5C, $62, $00, $00, $6C, $62, $71, $62
    db   $23, $6F, $71, $62, $82, $62, $37, $6F
    db   $BA, $62, $00, $00, $D6, $6E, $C7, $62
    db   $CC, $6E, $C7, $62, $D9, $62, $D6, $6E
    db   $00, $63, $00, $00, $9D, $40, $26, $01
    db   $00, $A1, $90, $A6, $90, $A1, $88, $A6
    db   $88, $A1, $7E, $A6, $7E, $A1, $88, $A6
    db   $88, $00, $A6, $4E, $A1, $4E, $A3, $48
    db   $A6, $4A, $A1, $4A, $A3, $42, $A1, $4E
    db   $A2, $4E, $A1, $52, $4E, $48, $40, $48
    db   $A2, $4A, $90, $A3, $90, $A6, $4E, $A1
    db   $4E, $A3, $48, $A6, $58, $A1, $58, $A3
    db   $50, $A1, $4E, $A2, $4E, $A1, $52, $A2
    db   $4E, $A1, $58, $60, $A2, $62, $90, $A3
    db   $90, $00, $A6, $4E, $A1, $4E, $A3, $48
    db   $A6, $4A, $A1, $4A, $A3, $42, $00, $99
    db   $A1, $8E, $A6, $8E, $A1, $86, $A6, $86
    db   $A1, $7C, $A6, $7C, $A1, $86, $A6, $86
    db   $00, $9B, $02, $A2, $28, $A1, $30, $36
    db   $A2, $1E, $A1, $30, $36, $A2, $2A, $A1
    db   $32, $38, $A2, $20, $A1, $32, $38, $A2
    db   $28, $A1, $30, $36, $A2, $1E, $A1, $30
    db   $36, $A2, $2A, $8E, $8E, $1E, $9C, $00
    db   $A2, $28, $A1, $30, $36, $A2, $1E, $A1
    db   $30, $36, $A2, $2A, $A1, $32, $38, $A2
    db   $20, $A1, $32, $38, $00, $00, $2B, $4A
    db   $20, $63, $3A, $63, $50, $63, $64, $63
    db   $EC, $6F, $2D, $6F, $6E, $63, $4B, $6F
    db   $7F, $63, $0F, $6F, $A5, $6F, $94, $63
    db   $5A, $6F, $A8, $6F, $94, $63, $FF, $FF
    db   $2A, $63, $2D, $6F, $A3, $63, $B2, $63
    db   $4B, $6F, $C1, $63, $50, $6F, $D6, $63
    db   $55, $6F, $D6, $63, $FF, $FF, $44, $63
    db   $C7, $6E, $E5, $63, $E2, $6F, $C2, $6E
    db   $F4, $63, $C2, $6E, $04, $64, $04, $64
    db   $FF, $FF, $5A, $63, $20, $64, $28, $64
    db   $2E, $64, $FF, $FF, $68, $63, $A8, $01
    db   $A1, $46, $48, $5E, $60, $A8, $01, $A1
    db   $48, $4A, $60, $62, $A8, $01, $00, $9B
    db   $05, $A1, $70, $72, $70, $6E, $9C, $70
    db   $6E, $6C, $6A, $68, $66, $64, $62, $60
    db   $5E, $5C, $5A, $00, $9B, $04, $A2, $50
    db   $4A, $4A, $50, $4A, $4A, $50, $4A, $50
    db   $4A, $9C, $00, $A5, $01, $9B, $08, $A1
    db   $1E, $20, $9C, $A3, $1E, $AE, $01, $A5
    db   $01, $00, $A1, $52, $54, $6A, $6C, $A8
    db   $01, $A1, $54, $56, $6C, $6E, $A8, $01
    db   $00, $9B, $05, $A1, $58, $5A, $58, $56
    db   $9C, $58, $56, $54, $52, $50, $4E, $4C
    db   $4A, $48, $46, $44, $42, $00, $9B, $04
    db   $A2, $58, $01, $01, $56, $01, $01, $58
    db   $01, $5A, $01, $9C, $00, $9A, $9B, $10
    db   $A1, $28, $2A, $9C, $99, $A3, $2C, $AE
    db   $01, $A5, $01, $00, $A5, $01, $99, $9B
    db   $04, $A2, $40, $9C, $28, $28, $A1, $28
    db   $28, $2A, $28, $00, $99, $9B, $04, $A1
    db   $4A, $4A, $32, $32, $A2, $32, $A1, $4A
    db   $4A, $32, $32, $A2, $32, $A1, $4A, $4A
    db   $32, $32, $4A, $4A, $32, $32, $9C, $00
    db   $9B, $04, $A5, $01, $9C, $A8, $01, $00
    db   $9B, $04, $A5, $01, $9C, $00, $9B, $02
    db   $A1, $15, $15, $15, $15, $A2, $01, $9C
    db   $9B, $08, $A1, $15, $9C, $00, $00, $67
    db   $4A, $8C, $4A, $49, $64, $53, $64, $5B
    db   $64, $37, $6F, $61, $64, $80, $64, $FF
    db   $FF, $49, $64, $EC, $6E, $B5, $64, $FF
    db   $FF, $53, $64, $D0, $64, $FF, $FF, $5B
    db   $64, $A4, $01, $A7, $01, $AD, $5A, $5E
    db   $5A, $A3, $58, $01, $A7, $01, $A1, $4A
    db   $54, $A3, $4E, $01, $A7, $01, $AD, $42
    db   $46, $42, $A3, $40, $01, $A7, $01, $00
    db   $9D, $40, $21, $01, $AD, $4E, $50, $52
    db   $A6, $54, $A1, $48, $A7, $54, $AD, $52
    db   $54, $52, $A2, $4E, $4A, $A6, $4E, $A1
    db   $40, $A4, $4E, $A2, $01, $AD, $4E, $50
    db   $52, $A6, $54, $A1, $48, $A7, $54, $AD
    db   $52, $54, $52, $A2, $4E, $4A, $A6, $4E
    db   $A1, $40, $A8, $4E, $00, $99, $9B, $04
    db   $A6, $28, $A1, $30, $A2, $36, $28, $2A
    db   $32, $A3, $38, $A6, $28, $A1, $30, $A2
    db   $36, $28, $1E, $2A, $A3, $32, $9C, $00
    db   $9B, $03, $A2, $15, $AD, $15, $15, $15
    db   $9C, $9B, $04, $A1, $15, $9C, $00, $00
    db   $2B, $4A, $EA, $64, $F0, $64, $F6, $64
    db   $00, $00, $50, $6F, $FC, $64, $00, $00
    db   $50, $6F, $03, $65, $00, $00, $EC, $6E
    db   $0A, $65, $00, $00, $A2, $52, $54, $56
    db   $A8, $58, $00, $A2, $5C, $5E, $60, $A8
    db   $62, $00, $99, $A2, $30, $32, $34, $9A
    db   $A8, $36, $00, $00, $58, $4A, $1E, $65
    db   $5A, $65, $A2, $65, $EC, $65, $CB, $6F
    db   $BD, $6F, $44, $66, $49, $66, $5B, $66
    db   $78, $66, $A8, $66, $20, $70, $C6, $66
    db   $04, $67, $09, $67, $07, $70, $1C, $70
    db   $E2, $6F, $1D, $67, $58, $67, $58, $67
    db   $BF, $67, $58, $67, $58, $67, $BF, $67
    db   $58, $67, $58, $67, $FF, $67, $1F, $68
    db   $20, $70, $30, $68, $24, $70, $4D, $68
    db   $00, $00, $CB, $6F, $69, $6F, $5C, $68
    db   $64, $6F, $72, $68, $73, $6F, $5C, $68
    db   $5F, $6F, $86, $68, $99, $68, $6E, $6F
    db   $9E, $68, $20, $70, $B5, $68, $CC, $5E
    db   $01, $70, $09, $67, $FB, $6F, $1C, $70
    db   $E2, $6F, $D1, $68, $0A, $69, $0A, $69
    db   $5C, $69, $0A, $69, $0A, $69, $5C, $69
    db   $0A, $69, $0A, $69, $9C, $69, $B5, $69
    db   $20, $70, $C6, $69, $24, $70, $DB, $69
    db   $00, $00, $CB, $6F, $FB, $6F, $EA, $69
    db   $5C, $68, $EF, $69, $72, $68, $F4, $69
    db   $D6, $6E, $49, $66, $5B, $66, $DF, $6F
    db   $FE, $69, $03, $6A, $20, $70, $2A, $6A
    db   $D6, $6E, $04, $70, $09, $67, $FE, $6F
    db   $1C, $70, $E2, $6F, $51, $6A, $65, $6A
    db   $65, $6A, $C3, $6A, $65, $6A, $65, $6A
    db   $C3, $6A, $65, $6A, $65, $6A, $0D, $6B
    db   $2A, $6B, $20, $70, $36, $6B, $24, $70
    db   $4C, $6B, $00, $00, $D3, $6F, $57, $6B
    db   $20, $70, $5F, $6B, $1C, $70, $67, $6B
    db   $67, $6B, $67, $6B, $67, $6B, $67, $6B
    db   $67, $6B, $67, $6B, $67, $6B, $67, $6B
    db   $67, $6B, $67, $6B, $78, $6B, $78, $6B
    db   $67, $6B, $67, $6B, $67, $6B, $67, $6B
    db   $67, $6B, $67, $6B, $67, $6B, $67, $6B
    db   $78, $6B, $78, $6B, $67, $6B, $67, $6B
    db   $67, $6B, $67, $6B, $67, $6B, $67, $6B
    db   $67, $6B, $67, $6B, $67, $6B, $83, $6B
    db   $20, $70, $83, $6B, $83, $6B, $24, $70
    db   $91, $6B, $00, $00, $9D, $56, $00, $80
    db   $00, $A1, $30, $3E, $44, $4C, $4E, $56
    db   $5C, $64, $66, $64, $5C, $56, $4E, $4C
    db   $44, $3E, $00, $A1, $40, $44, $48, $4E
    db   $58, $5C, $60, $66, $70, $66, $60, $5C
    db   $58, $4E, $48, $44, $40, $44, $48, $4E
    db   $58, $5C, $60, $66, $A3, $70, $01, $00
    db   $9D, $42, $00, $80, $A1, $36, $34, $36
    db   $2C, $30, $34, $36, $3A, $3E, $3A, $3E
    db   $36, $3A, $3E, $40, $44, $9D, $52, $00
    db   $80, $4E, $4C, $4E, $44, $56, $52, $56
    db   $4E, $9D, $62, $00, $80, $5C, $56, $4E
    db   $66, $64, $5E, $56, $52, $A3, $4E, $00
    db   $9D, $60, $21, $80, $A3, $52, $4E, $5C
    db   $A7, $5C, $A3, $60, $A2, $5C, $58, $52
    db   $A3, $56, $A2, $01, $58, $56, $52, $4E
    db   $5C, $A3, $58, $A4, $01, $00, $9D, $52
    db   $00, $80, $A3, $01, $9B, $02, $A1, $44
    db   $4A, $52, $58, $60, $58, $52, $4A, $9C
    db   $9B, $02, $36, $3E, $44, $4A, $52, $4A
    db   $44, $3E, $9C, $40, $44, $48, $4E, $58
    db   $4E, $48, $44, $40, $44, $48, $4E, $58
    db   $4E, $48, $40, $3E, $42, $46, $4C, $56
    db   $5A, $5E, $64, $6E, $64, $5E, $5A, $56
    db   $4C, $46, $3E, $00, $9D, $47, $00, $80
    db   $00, $A1, $1E, $22, $26, $2C, $32, $3A
    db   $3E, $44, $4A, $52, $56, $5C, $62, $6A
    db   $6E, $74, $A4, $7E, $00, $9D, $52, $00
    db   $80, $A4, $01, $A3, $1E, $AA, $1E, $1E
    db   $1E, $9D, $72, $00, $80, $A3, $22, $9B
    db   $06, $AA, $22, $9C, $28, $28, $28, $9D
    db   $92, $00, $80, $A3, $2C, $AA, $2C, $2C
    db   $2C, $A3, $32, $AA, $32, $32, $3A, $A3
    db   $3E, $AA, $36, $36, $36, $A3, $36, $9D
    db   $92, $00, $40, $AA, $36, $3A, $3E, $00
    db   $9D, $90, $21, $41, $A3, $30, $AA, $32
    db   $30, $2C, $30, $01, $30, $32, $36, $3A
    db   $A3, $3C, $AA, $44, $48, $44, $A3, $42
    db   $AA, $3A, $3E, $42, $A3, $44, $AA, $5C
    db   $62, $6A, $70, $38, $3C, $40, $3C, $38
    db   $A3, $36, $AA, $36, $3A, $36, $A3, $32
    db   $01, $9D, $77, $00, $80, $9B, $02, $AA
    db   $52, $56, $58, $9C, $56, $4E, $48, $A3
    db   $4E, $AA, $52, $56, $58, $58, $5C, $58
    db   $56, $4E, $48, $A3, $4E, $9D, $70, $21
    db   $41, $AA, $4A, $4E, $52, $52, $52, $52
    db   $A3, $50, $AA, $50, $54, $50, $A3, $4E
    db   $AA, $4E, $52, $4E, $A4, $4A, $00, $9D
    db   $70, $00, $81, $A5, $01, $01, $A8, $4A
    db   $AA, $4A, $4E, $4A, $A4, $48, $A3, $4A
    db   $4E, $9D, $90, $26, $80, $AA, $50, $01
    db   $54, $A4, $58, $AA, $50, $54, $58, $A8
    db   $58, $AA, $58, $58, $58, $9B, $02, $01
    db   $50, $50, $50, $4E, $50, $9C, $A3, $4E
    db   $9D, $70, $21, $40, $AA, $3A, $01, $3A
    db   $36, $01, $36, $32, $01, $32, $00, $9D
    db   $80, $21, $41, $AA, $46, $44, $46, $4A
    db   $46, $44, $9B, $04, $46, $9C, $44, $46
    db   $4A, $46, $4A, $50, $5A, $62, $68, $5A
    db   $5A, $62, $62, $62, $A3, $60, $00, $9D
    db   $70, $21, $41, $A2, $48, $A1, $48, $48
    db   $A3, $44, $A2, $44, $A1, $46, $4A, $00
    db   $9D, $70, $21, $41, $A3, $50, $A2, $50
    db   $A1, $50, $50, $A2, $5C, $58, $A3, $54
    db   $A3, $60, $A2, $60, $A1, $5C, $60, $A2
    db   $62, $66, $68, $62, $00, $A3, $66, $9D
    db   $A0, $21, $40, $A2, $28, $A1, $28, $28
    db   $A3, $28, $01, $00, $A2, $01, $60, $64
    db   $A8, $66, $A2, $60, $64, $A8, $66, $A2
    db   $64, $60, $56, $A7, $5C, $A5, $60, $A3
    db   $01, $00, $A2, $60, $64, $A8, $66, $A2
    db   $5C, $66, $A8, $70, $A2, $6E, $6A, $A5
    db   $6E, $A4, $01, $A2, $01, $00, $A2, $60
    db   $64, $A8, $66, $A2, $5C, $66, $A8, $70
    db   $A2, $6E, $6A, $9D, $50, $00, $80, $6E
    db   $00, $A5, $6E, $A4, $01, $00, $A8, $01
    db   $A3, $7C, $78, $6E, $A7, $6E, $A5, $70
    db   $A2, $82, $7E, $7C, $78, $6E, $6A, $6E
    db   $78, $70, $A3, $01, $00, $A2, $70, $A4
    db   $74, $A2, $01, $62, $6A, $74, $A8, $6E
    db   $A2, $01, $66, $A5, $78, $A2, $01, $A7
    db   $76, $88, $9D, $60, $00, $80, $A4, $86
    db   $00, $9D, $62, $21, $80, $A3, $01, $01
    db   $26, $AA, $26, $26, $26, $9D, $82, $21
    db   $80, $A3, $28, $AA, $28, $28, $28, $32
    db   $32, $32, $3A, $3A, $3A, $9D, $A2, $21
    db   $80, $A3, $3E, $AA, $3E, $3E, $3E, $A3
    db   $40, $AA, $40, $40, $40, $A3, $44, $AA
    db   $4E, $4E, $4E, $A3, $4E, $AA, $4E, $4E
    db   $4E, $00, $9D, $A0, $21, $41, $A3, $40
    db   $36, $AA, $36, $01, $40, $44, $48, $4A
    db   $A4, $4E, $AA, $01, $4E, $52, $54, $52
    db   $4E, $A4, $4A, $AA, $01, $4A, $4E, $50
    db   $4E, $4A, $A3, $48, $AA, $48, $4A, $48
    db   $A3, $44, $9D, $57, $00, $80, $AA, $01
    db   $70, $74, $9B, $02, $A3, $78, $70, $A4
    db   $7E, $9C, $9D, $A0, $21, $41, $AA, $52
    db   $56, $58, $58, $5C, $60, $A3, $62, $AA
    db   $62, $66, $62, $A3, $60, $AA, $60, $62
    db   $60, $A4, $5C, $00, $9D, $A0, $26, $81
    db   $AA, $58, $01, $5C, $A4, $5E, $AA, $58
    db   $01, $5C, $A3, $5E, $AA, $01, $01, $5E
    db   $A6, $5C, $58, $A2, $4E, $A4, $54, $AE
    db   $58, $AA, $58, $01, $5C, $A4, $5E, $AA
    db   $58, $5C, $5E, $A8, $68, $AA, $68, $66
    db   $5E, $A5, $62, $A3, $62, $9D, $A0, $21
    db   $40, $AA, $4A, $4E, $4A, $48, $4A, $48
    db   $44, $48, $44, $00, $9D, $A0, $21, $41
    db   $A4, $58, $AA, $01, $58, $58, $58, $54
    db   $58, $A4, $5A, $AA, $01, $5E, $62, $66
    db   $68, $6C, $A3, $70, $00, $9D, $A0, $21
    db   $00, $A2, $58, $A1, $4E, $58, $A3, $54
    db   $A2, $54, $A1, $58, $5C, $00, $A3, $5E
    db   $A2, $5E, $A1, $58, $5E, $A3, $62, $A1
    db   $62, $66, $68, $6C, $9D, $A0, $00, $01
    db   $A5, $70, $00, $9D, $A0, $21, $00, $A3
    db   $78, $A2, $40, $A1, $40, $40, $A3, $40
    db   $01, $00, $9D, $A2, $6E, $20, $00, $9D
    db   $92, $6E, $40, $00, $9B, $03, $A5, $01
    db   $9C, $A3, $01, $A6, $01, $00, $A8, $01
    db   $A2, $01, $00, $9D, $42, $6E, $20, $99
    db   $A2, $48, $56, $5C, $66, $A4, $01, $A2
    db   $3A, $48, $4E, $58, $01, $56, $A1, $52
    db   $4E, $4C, $3E, $A2, $48, $56, $5C, $66
    db   $A4, $01, $A2, $3A, $48, $4E, $58, $A3
    db   $01, $00, $A3, $01, $9B, $02, $A2, $2C
    db   $A3, $2C, $A2, $2C, $9C, $9B, $02, $A2
    db   $1E, $A3, $1E, $A2, $1E, $9C, $9B, $02
    db   $A2, $28, $A3, $28, $A2, $28, $9C, $9B
    db   $02, $A2, $26, $A3, $26, $A2, $26, $9C
    db   $00, $9D, $42, $6E, $20, $99, $9B, $06
    db   $A3, $1E, $AA, $1E, $1E, $1E, $9C, $A3
    db   $1E, $1E, $22, $26, $00, $99, $A3, $28
    db   $AA, $28, $28, $24, $A3, $28, $AA, $28
    db   $28, $28, $A3, $24, $AA, $3C, $3C, $3C
    db   $9A, $A3, $3A, $22, $99, $9B, $02, $A3
    db   $2C, $AA, $2C, $2C, $2C, $9C, $A3, $1E
    db   $AA, $1E, $1E, $1E, $9A, $A3, $1E, $20
    db   $99, $AA, $22, $40, $48, $52, $48, $40
    db   $30, $3E, $44, $4E, $44, $3E, $3A, $40
    db   $48, $52, $48, $40, $30, $3E, $44, $4E
    db   $44, $30, $A3, $32, $AA, $32, $32, $32
    db   $A3, $2A, $AA, $2A, $2A, $2A, $1E, $28
    db   $2C, $36, $40, $44, $4E, $36, $3A, $3E
    db   $3A, $36, $00, $38, $58, $5E, $68, $5E
    db   $58, $50, $58, $5E, $68, $5E, $58, $9B
    db   $02, $50, $54, $5C, $62, $5C, $54, $9C
    db   $9B, $02, $4E, $54, $5C, $62, $5C, $54
    db   $9C, $40, $48, $4E, $54, $4E, $48, $40
    db   $48, $4E, $54, $4E, $40, $9B, $02, $99
    db   $AA, $32, $40, $46, $50, $58, $5E, $9A
    db   $A3, $68, $01, $9C, $99, $9B, $02, $AA
    db   $2A, $42, $42, $42, $46, $4A, $9C, $A3
    db   $4E, $1E, $22, $26, $00, $38, $40, $46
    db   $50, $58, $5E, $9A, $A3, $68, $99, $AA
    db   $38, $38, $38, $2A, $32, $38, $42, $4A
    db   $50, $9A, $A3, $72, $99, $AA, $2A, $2A
    db   $2A, $00, $9B, $02, $A2, $28, $1E, $9C
    db   $9B, $02, $24, $1A, $9C, $00, $9B, $02
    db   $A2, $20, $2E, $9C, $9B, $02, $24, $32
    db   $9C, $9B, $02, $28, $1E, $9C, $9B, $02
    db   $2A, $20, $9C, $00, $A3, $28, $A2, $28
    db   $A1, $28, $28, $A3, $28, $01, $00, $9B
    db   $14, $A5, $01, $9C, $A3, $01, $00, $9B
    db   $06, $A5, $01, $9C, $A3, $01, $00, $9B
    db   $03, $A3, $15, $AA, $1A, $1A, $1A, $9C
    db   $AA, $15, $15, $15, $1A, $15, $15, $00
    db   $9B, $08, $AA, $29, $29, $29, $1A, $29
    db   $29, $9C, $00, $9B, $02, $A1, $1A, $1A
    db   $A3, $1A, $9C, $9B, $04, $A1, $1A, $9C
    db   $00, $A3, $1A, $A2, $1A, $A1, $1A, $1A
    db   $A3, $1A, $01, $00, $00, $2B, $4A, $A7
    db   $6B, $B9, $6B, $CB, $6B, $00, $00, $D1
    db   $6B, $D6, $6B, $D6, $6B, $41, $6F, $D6
    db   $6B, $78, $6F, $D6, $6B, $FF, $FF, $32
    db   $5E, $D1, $6B, $E0, $6B, $E0, $6B, $41
    db   $6F, $E0, $6B, $78, $6F, $E0, $6B, $FF
    db   $FF, $52, $5E, $E2, $6F, $FF, $FF, $5E
    db   $5E, $9D, $40, $00, $40, $00, $A1, $34
    db   $36, $34, $32, $30, $2E, $30, $32, $00
    db   $A1, $48, $4A, $48, $46, $44, $42, $44
    db   $46, $00, $00, $49, $4A, $F5, $6B, $15
    db   $6C, $39, $6C, $59, $6C, $E2, $6F, $77
    db   $6C, $81, $6D, $0A, $70, $87, $6F, $7E
    db   $6C, $8C, $6F, $84, $6C, $82, $6F, $8A
    db   $6C, $FB, $6C, $61, $6D, $74, $6D, $79
    db   $6D, $FF, $FF, $10, $70, $E2, $6F, $02
    db   $6D, $81, $6D, $0A, $70, $7D, $6F, $09
    db   $6D, $91, $6F, $28, $6D, $04, $70, $7C
    db   $6D, $48, $6D, $55, $6D, $61, $6D, $04
    db   $70, $74, $6D, $79, $6D, $FF, $FF, $10
    db   $70, $E2, $6F, $96, $6F, $81, $6D, $04
    db   $70, $0A, $70, $9C, $6F, $93, $6D, $B5
    db   $6D, $D6, $6E, $48, $6D, $55, $6D, $61
    db   $6D, $0A, $70, $79, $6D, $FF, $FF, $10
    db   $70, $CB, $6D, $D7, $6D, $D7, $6D, $D7
    db   $6D, $D7, $6D, $EC, $6D, $EC, $6D, $EC
    db   $6D, $EC, $6D, $EC, $6D, $EC, $6D, $16
    db   $6E, $1A, $6E, $FF, $FF, $16, $70, $9D
    db   $10, $00, $81, $A2, $01, $00, $A4, $90
    db   $82, $86, $78, $00, $A4, $90, $82, $86
    db   $01, $00, $9D, $B1, $82, $00, $A2, $10
    db   $10, $9D, $71, $82, $80, $A1, $6E, $60
    db   $6E, $78, $A3, $01, $9D, $B1, $82, $00
    db   $A2, $01, $06, $10, $10, $9D, $71, $82
    db   $80, $A1, $6E, $60, $6E, $78, $A3, $01
    db   $9D, $B1, $82, $00, $A2, $01, $10, $18
    db   $18, $9D, $71, $82, $80, $A1, $6A, $5C
    db   $6A, $6E, $A3, $01, $9D, $B1, $82, $00
    db   $A2, $01, $0E, $18, $18, $9D, $71, $82
    db   $80, $A1, $6A, $5C, $6A, $6E, $9D, $80
    db   $00, $00, $A3, $18, $14, $9D, $A1, $82
    db   $00, $A2, $10, $10, $A4, $01, $A2, $01
    db   $06, $10, $10, $A4, $01, $A3, $10, $9B
    db   $03, $A2, $06, $06, $A4, $01, $A2, $01
    db   $14, $9C, $00, $9D, $26, $00, $00, $A3
    db   $01, $00, $9D, $40, $00, $41, $A2, $01
    db   $00, $9B, $03, $A5, $01, $9C, $A4, $01
    db   $A2, $01, $48, $4C, $A8, $4E, $A2, $48
    db   $4C, $A8, $4E, $A2, $4C, $48, $3E, $A7
    db   $44, $A8, $48, $A2, $01, $A8, $01, $00
    db   $9B, $03, $A1, $60, $5C, $58, $4E, $48
    db   $4E, $58, $5C, $9C, $60, $5C, $58, $4E
    db   $48, $4E, $58, $60, $9B, $02, $5C, $56
    db   $52, $4E, $44, $4E, $52, $56, $9C, $00
    db   $9B, $02, $A1, $64, $5C, $56, $4E, $4C
    db   $4E, $56, $5C, $9C, $00, $9B, $02, $6A
    db   $64, $5C, $56, $52, $56, $5C, $64, $9C
    db   $00, $A1, $06, $14, $1C, $1E, $26, $2C
    db   $34, $36, $3E, $44, $4C, $4E, $56, $5C
    db   $A2, $64, $66, $00, $9D, $77, $00, $80
    db   $00, $A5, $8C, $00, $9D, $40, $00, $80
    db   $00, $A2, $48, $4C, $A8, $4E, $A2, $48
    db   $4C, $A8, $4E, $A2, $4C, $48, $A6, $3E
    db   $A5, $56, $00, $9B, $03, $A5, $01, $9C
    db   $A4, $01, $A2, $01, $A2, $36, $3A, $A4
    db   $3E, $A3, $01, $A2, $36, $3A, $A4, $3E
    db   $A3, $01, $A2, $3A, $A3, $36, $A7, $34
    db   $A4, $36, $A8, $01, $00, $A2, $48, $4C
    db   $A4, $4E, $A3, $01, $A2, $48, $4E, $A4
    db   $58, $A3, $01, $A2, $56, $52, $A5, $56
    db   $A2, $01, $00, $9B, $05, $A5, $01, $9C
    db   $A4, $01, $A2, $01, $A6, $01, $00, $9B
    db   $03, $A2, $15, $A9, $15, $AD, $01, $A9
    db   $15, $AD, $01, $A9, $15, $9C, $9B, $04
    db   $A1, $15, $9C, $00, $A2, $24, $A9, $1A
    db   $AD, $01, $A9, $1A, $AD, $01, $A9, $1A
    db   $A2, $1A, $A9, $1A, $AD, $01, $A9, $1A
    db   $AD, $01, $A9, $1A, $A2, $24, $A9, $15
    db   $AD, $01, $A9, $1A, $AD, $01, $A9, $1A
    db   $9B, $04, $A1, $1A, $9C, $00, $A4, $24
    db   $01, $00, $9B, $04, $A5, $01, $9C, $A7
    db   $01, $00, $66, $66, $66, $66, $66, $66
    db   $66, $66, $00, $00, $00, $00, $00, $00
    db   $00, $00, $88, $88, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $88, $88, $88, $88, $88, $88
    db   $88, $88, $00, $00, $00, $00, $00, $00
    db   $00, $00, $88, $88, $88, $88, $00, $00
    db   $00, $00, $88, $88, $88, $88, $00, $00
    db   $00, $00, $AA, $AA, $AA, $AA, $AA, $AA
    db   $AA, $AA, $00, $00, $00, $00, $00, $00
    db   $00, $00, $06, $9B, $CD, $DE, $EE, $FF
    db   $FF, $FE, $06, $9B, $CD, $DE, $EE, $FF
    db   $FF, $FE, $7F, $FF, $57, $73, $55, $34
    db   $42, $21, $7F, $FF, $57, $73, $55, $34
    db   $42, $21, $33, $33, $33, $33, $00, $00
    db   $00, $00, $33, $33, $33, $33, $00, $00
    db   $00, $00, $11, $11, $11, $11, $00, $00
    db   $00, $00, $11, $11, $11, $11, $00, $00
    db   $00, $00, $44, $44, $44, $44, $00, $00
    db   $00, $00, $44, $44, $44, $44, $00, $00
    db   $00, $00, $9D, $42, $6E, $20, $00, $9D
    db   $42, $6E, $40, $00, $9D, $52, $6E, $21
    db   $00, $9D, $52, $6E, $40, $00, $9D, $52
    db   $6E, $40, $99, $00, $9D, $22, $6E, $20
    db   $00, $9D, $62, $6E, $20, $00, $9D, $B2
    db   $6E, $40, $99, $00, $9D, $32, $6E, $21
    db   $00, $9D, $32, $6E, $25, $00, $9D, $32
    db   $6E, $40, $00, $9D, $42, $00, $80, $00
    db   $9D, $53, $00, $80, $00, $9D, $50, $83
    db   $40, $00, $9D, $60, $81, $80, $00, $9D
    db   $71, $00, $40, $00, $9D, $42, $00, $40
    db   $00, $9D, $33, $00, $40, $00, $9D, $62
    db   $00, $80, $00, $9D, $60, $26, $01, $00
    db   $9D, $60, $26, $81, $00, $9D, $40, $00
    db   $80, $00, $9D, $20, $00, $80, $00, $9D
    db   $43, $00, $80, $00, $9D, $40, $21, $80
    db   $00, $9D, $50, $00, $41, $00, $9D, $60
    db   $21, $41, $00, $9D, $60, $00, $81, $00
    db   $9D, $90, $21, $41, $00, $9D, $B0, $21
    db   $41, $00, $9D, $91, $00, $40, $00, $9D
    db   $50, $26, $80, $00, $9D, $30, $21, $80
    db   $00, $9D, $20, $21, $80, $00, $9D, $60
    db   $26, $80, $00, $9D, $40, $26, $80, $00
    db   $9D, $60, $00, $40, $00, $9D, $A0, $21
    db   $41, $00, $9D, $82, $82, $80, $00, $9D
    db   $77, $00, $80, $00, $9D, $97, $00, $80
    db   $00, $9D, $51, $82, $80, $00, $9D, $82
    db   $6E, $01, $94, $00, $9D, $72, $6E, $01
    db   $94, $00, $9F, $FE, $00, $9F, $00, $00
    db   $9F, $02, $00, $9F, $0A, $00, $9D, $10
    db   $00, $80, $00, $9D, $37, $00, $80, $00
    db   $9D, $43, $83, $80, $00, $9B, $0B, $A5
    db   $01, $9C, $A4, $01, $00, $9B, $11, $A5
    db   $01, $9C, $00, $9B, $09, $A5, $01, $9C
    db   $A4, $01, $00, $9B, $09, $A5, $01, $9C
    db   $A4, $01, $00, $A5, $01, $01, $00, $A5
    db   $01, $00, $A5, $01, $01, $00, $9B, $03
    db   $A5, $01, $9C, $00, $9B, $04, $A5, $01
    db   $9C, $00, $9B, $10, $A5, $01, $9C, $00
    db   $A8, $01, $00, $A6, $01, $00, $A7, $01
    db   $00, $A1, $01, $00, $A2, $01, $00, $A4
    db   $01, $00, $A3, $01, $00, $A5, $01, $00
    db   $DF, $6F, $FF, $FF, $10, $70, $0D, $70
    db   $FF, $FF, $16, $70, $9E, $3A, $4A, $00
    db   $9E, $49, $4A, $00, $9E, $67, $4A, $00
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
