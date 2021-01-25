SECTION "ROM Bank 05", ROMX[$4000], BANK[$05]

    db   $70, $00, $70, $20, $72, $00, $72, $20
    db   $74, $00, $76, $00, $78, $00, $7A, $00
    db   $76, $20, $74, $20, $7A, $20, $78, $20
    db   $7C, $00, $7C, $20, $40, $00, $40, $20
    db   $42, $00, $42, $20, $44, $00, $46, $00
    db   $48, $00, $4A, $00, $46, $20, $44, $20
    db   $4A, $20, $48, $20, $4C, $00, $4C, $20
    db   $79, $EA, $54, $D1, $FA, $56, $DB, $FE
    db   $01, $20, $11, $F0, $F6, $21, $E0, $C3
    db   $09, $77, $21, $20, $C2, $09, $70, $21
    db   $30, $C2, $09, $70, $11, $1C, $40, $FA
    db   $56, $DB, $A7, $20, $03, $11, $00, $40
    db   $CD, $3B, $3C, $FA, $24, $C1, $A7, $28
    db   $15, $FA, $56, $DB, $FE, $01, $CA, $A4
    db   $40, $21, $E0, $C3, $09, $F0, $F6, $BE
    db   $CA, $A7, $40, $C3, $A4, $40, $FA, $A8
    db   $C1, $21, $9F, $C1, $B6, $21, $4F, $C1
    db   $B6, $C2, $A4, $40, $FA, $6B, $C1, $FE
    db   $04, $C0, $CD, $D4, $44, $CD, $E2, $08
    db   $FA, $56, $DB, $A7, $20, $03, $CD, $EB
    db   $3B, $CD, $A8, $40, $CD, $5B, $42, $C9
    db   $21, $40, $C4, $09, $7E, $C7

    dw JumpTable_40B2_05 ; 00
    dw JumpTable_40E9_05 ; 01

JumpTable_40B2_05:
    ld   hl, $C200
    add  hl, bc
    ld   a, [hl]
    add  a, $04
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    ld   e, $10
    ld   hl, $D100
JumpTable_40B2_05.loop_05_40C4:
    ldi  [hl], a
    dec  e
    jr   nz, .loop_05_40C4

    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    add  a, $08
    ld   [hl], a
    ld   hl, $C2C0
    add  hl, bc
    ld   [hl], a
    ld   hl, $C310
    add  hl, bc
    sub  a, [hl]
    ld   e, $10
    ld   hl, $D110
JumpTable_40B2_05.loop_05_40DF:
    ldi  [hl], a
    dec  e
    jr   nz, .loop_05_40DF

    ld   hl, $C440
    add  hl, bc
    inc  [hl]
    ret


JumpTable_40E9_05:
    ifNot [$DB56], .else_05_413A

    cp   $80
    jr   z, .else_05_40FD

    copyFromTo [hLinkPositionX], [$FFD7]
    copyFromTo [$FFB3], [$FFD8]
    jr   .toc_05_412C

JumpTable_40E9_05.else_05_40FD:
    ld   a, [hLinkPositionY]
    sub  a, 64
    add  a, 16
    cp   32
    jr   nc, .else_05_412A

    ld   a, [hLinkPositionX]
    sub  a, 136
    add  a, 16
    cp   32
    jr   nc, .else_05_412A

    ifNot [$C133], .else_05_412A

    assign [$D368], $10
    ld   a, $6C
    call toc_01_2185
    assign [$FFF3], $18
    assign [$DB56], $01
JumpTable_40E9_05.else_05_412A:
    jr   .else_05_413A

JumpTable_40E9_05.toc_05_412C:
    ld   a, [$FFD7]
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C2C0
    add  hl, bc
    ld   [hl], a
JumpTable_40E9_05.else_05_413A:
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    ld   [$D150], a
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    ld   [$D151], a
    call toc_05_7A0A
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    dec  [hl]
    push hl
    pop  de
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    ld   [$FFE8], a
    jr   z, .else_05_4163

    xor  a
    ld   [hl], a
    ld   [de], a
JumpTable_40E9_05.else_05_4163:
    call toc_01_3B9E
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_4183_05 ; 00
    dw JumpTable_41D4_05 ; 01
    dw JumpTable_41F1_05 ; 02
    dw JumpTable_4216_05 ; 03
    dw JumpTable_41F1_05 ; 04

    db   $04, $08, $0C, $08, $FC, $F8, $F4, $F8
    db   $F4, $F8, $04, $08, $0C, $08, $FC, $F8

JumpTable_4183_05:
    call toc_01_0891
    jr   z, .else_05_41B4

    call toc_01_088C
    jr   nz, .return_05_41B3

    call toc_01_27ED
    and  %00111111
    add  a, $20
    ld   [hl], a
    call JumpTable_3B8D_00
    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $4173
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $417B
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
JumpTable_4183_05.return_05_41B3:
    ret


JumpTable_4183_05.else_05_41B4:
    call toc_01_0891
    ld   [hl], $28
    ifNot [$DB56], .else_05_41C3

    call toc_05_42A0
    ret


JumpTable_4183_05.else_05_41C3:
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $20
    call JumpTable_3B8D_00
    ld   [hl], $02
    ld   a, $20
    call toc_01_3C25
    ret


JumpTable_41D4_05:
    call toc_01_088C
    jr   nz, .else_05_41DF

    ld   [hl], $20
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_41D4_05.else_05_41DF:
    ifNot [$FFE8], .else_05_41EA

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $10
JumpTable_41D4_05.else_05_41EA:
    call toc_05_79D1
    call toc_05_4230
    ret


JumpTable_41F1_05:
    call toc_01_0891
    jr   z, .else_05_41FF

    call toc_05_79D1
    call toc_05_4230
    dec  e
    jr   z, .else_05_420C

JumpTable_41F1_05.else_05_41FF:
    call toc_01_3DAF
    call JumpTable_3B8D_00
    ld   [hl], $03
    call toc_01_0891
    ld   [hl], $10
JumpTable_41F1_05.else_05_420C:
    ifNot [$DB56], .return_05_4215

    call toc_05_433E
JumpTable_41F1_05.return_05_4215:
    ret


JumpTable_4216_05:
    call toc_01_0891
    jr   nz, .return_05_422F

    call toc_01_27ED
    and  %00111111
    add  a, $30
    ld   [hl], a
    ifNot [$DB56], .else_05_422B

    ld   [hl], $10
JumpTable_4216_05.else_05_422B:
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_4216_05.return_05_422F:
    ret


toc_05_4230:
    ld   e, $01
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, bc
    sub  a, [hl]
    add  a, $20
    cp   $40
    jr   c, .else_05_4246

    ld   a, [$FFEE]
    ld   [hl], a
    inc  e
toc_05_4230.else_05_4246:
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, bc
    sub  a, [hl]
    add  a, $20
    cp   $40
    jr   c, .return_05_425A

    ld   a, [$FFEF]
    ld   [hl], a
    inc  e
toc_05_4230.return_05_425A:
    ret


    db   $CD, $B1, $43, $CD, $07, $44, $FA, $C0
    db   $C3, $5F, $16, $00, $21, $30, $C0, $19
    db   $E5, $D1, $C5, $0E, $05, $F0, $E7, $A9
    db   $1F, $38, $20, $21, $10, $D1, $09, $7E
    db   $12, $13, $21, $00, $D1, $09, $7E, $C6
    db   $04, $12, $13, $FA, $56, $DB, $A7, $3E
    db   $4E, $20, $02, $3E, $7E, $12, $13, $3E
    db   $00, $12, $13, $0D, $20, $D7, $C1, $3E
    db   $03, $CD, $D0, $3D, $C9

toc_05_42A0:
    ld   a, [$DB56]
    cp   $80
    jp   z, .toc_05_4338

    call toc_01_27ED
    ld   d, b
    and  %00000001
    jr   nz, .else_05_42B8

    ld   e, $0F
    assign [$FFD7], $FF
    jr   .toc_05_42C0

toc_05_42A0.else_05_42B8:
    ld   e, $00
    assign [$FFD7], $01
    ld   a, $10
toc_05_42A0.toc_05_42C0:
    ld   [$FFD8], a
toc_05_42A0.loop_05_42C2:
    ld   a, e
    cp   c
    jr   z, .else_05_432C

    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_05_432C

    cp   $01
    jr   z, .else_05_432C

    ld   hl, $C3B0
    add  hl, de
    ld   a, [hl]
    dec  a
    jr   z, .else_05_432C

    push de
    ld   hl, $C3A0
    add  hl, de
    ld   e, [hl]
    call toc_01_37E6
    pop  de
    and  a
    jr   z, .else_05_432C

    ld   hl, $C200
    add  hl, de
    ld   a, [hLinkPositionX]
    sub  a, [hl]
    add  a, 47
    cp   94
    jr   nc, .else_05_432C

    ld   hl, $C210
    add  hl, de
    ld   a, [hLinkPositionY]
    sub  a, [hl]
    add  a, 47
    cp   94
    jr   nc, .else_05_432C

    ld   a, e
    ld   [$D152], a
    ld   a, [hLinkPositionY]
    push af
    ld   a, [hLinkPositionX]
    push af
    ld   a, [hl]
    ld   [hLinkPositionY], a
    ld   hl, $C200
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionX], a
    ld   a, 48
    call toc_01_3C25
    pop  af
    ld   [hLinkPositionX], a
    pop  af
    ld   [hLinkPositionY], a
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $10
    call JumpTable_3B8D_00
    ld   [hl], $04
    ret


toc_05_42A0.else_05_432C:
    ld   hl, $FFD7
    ld   a, e
    add  a, [hl]
    ld   e, a
    ld   hl, $FFD8
    cp   [hl]
    jr   nz, .loop_05_42C2

toc_05_42A0.toc_05_4338:
    call toc_01_0891
    ld   [hl], $10
    ret


toc_05_433E:
    ld   a, [$D152]
    ld   e, a
    ld   d, b
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    ret  z

    ld   hl, $C200
    add  hl, de
    ld   a, [$FFEE]
    sub  a, [hl]
    add  a, $0E
    cp   $1A
    ret  nc

    ld   hl, $C210
    add  hl, de
    ld   a, [$FFEC]
    sub  a, [hl]
    add  a, $10
    cp   $20
    ret  nc

    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $3D
    jr   nz, .else_05_4389

    ld   hl, $C440
    add  hl, de
    ld   a, [hl]
    and  a
    ret  z

    ld   a, [wDialogState]
    and  a
    ret  nz

    call toc_01_0891
    ld   [hl], b
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    ret  nz

    ld   [hl], $80
    ld   a, $15
    jp   toc_01_2185

toc_05_433E.else_05_4389:
    ld   hl, $C420
    add  hl, de
    ld   a, [hl]
    and  a
    ret  nz

    assign [$FFF2], $03
    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $AD
    jr   nz, .else_05_43A9

    ld   hl, $C420
    add  hl, de
    ld   [hl], $18
    ld   hl, $C3D0
    add  hl, de
    inc  [hl]
    ret


toc_05_433E.else_05_43A9:
    push bc
    push de
    pop  bc
    call toc_01_3F7A
    pop  bc
    ret


    db   $21, $00, $C2, $09, $7E, $EA, $00, $D1
    db   $21, $10, $C2, $09, $7E, $21, $10, $C3
    db   $09, $96, $EA, $10, $D1, $11, $00, $D1
    db   $21, $01, $D1, $C5, $0E, $05, $1A, $96
    db   $C6, $07, $FE, $0E, $38, $0A, $CB, $7F
    db   $20, $04, $34, $34, $34, $34, $35, $35
    db   $23, $13, $0D, $20, $E9, $11, $10, $D1
    db   $21, $11, $D1, $0E, $05, $1A, $96, $C6
    db   $07, $FE, $0E, $38, $0A, $CB, $7F, $20
    db   $04, $34, $34, $34, $34, $35, $35, $23
    db   $13, $0D, $20, $E9, $C1, $C9, $FA, $56
    db   $DB, $A7, $C8, $FE, $80, $C8, $F0, $9B
    db   $21, $9A, $FF, $B6, $21, $A3, $FF, $B6
    db   $CA, $D3, $44, $21, $B0, $C2, $09, $7E
    db   $EA, $06, $D1, $21, $C0, $C2, $09, $7E
    db   $EA, $16, $D1, $11, $06, $D1, $21, $05
    db   $D1, $C5, $01, $06, $00, $1A, $96, $C6
    db   $07, $FE, $0E, $38, $13, $CB, $7F, $20
    db   $06, $34, $34, $34, $34, $34, $34, $35
    db   $35, $35, $79, $FE, $01, $20, $01, $04
    db   $2B, $1B, $0D, $20, $E0, $11, $16, $D1
    db   $21, $15, $D1, $0E, $06, $1A, $96, $C6
    db   $07, $FE, $0E, $38, $16, $CB, $7F, $20
    db   $06, $34, $34, $34, $34, $34, $34, $35
    db   $35, $35, $79, $FE, $01, $20, $04, $78
    db   $F6, $02, $47, $2B, $1B, $0D, $20, $DD
    db   $78, $E0, $D7, $C1, $E6, $01, $28, $19
    db   $21, $10, $D1, $1E, $06, $FA, $51, $D1
    db   $96, $28, $07, $CB, $7F, $20, $02, $34
    db   $34, $35, $23, $1D, $20, $EF, $CD, $BE
    db   $44, $F0, $D7, $E6, $02, $28, $2B, $21
    db   $00, $D1, $1E, $06, $FA, $50, $D1, $96
    db   $28, $07, $CB, $7F, $20, $02, $34, $34
    db   $35, $23, $1D, $20, $EF, $FA, $10, $D1
    db   $21, $10, $C3, $09, $86, $21, $10, $C2
    db   $09, $77, $FA, $00, $D1, $21, $00, $C2
    db   $09, $77, $C9, $21, $40, $C2, $09, $7E
    db   $21, $50, $C2, $09, $B6, $C8, $21, $40
    db   $C2, $09, $7E, $57, $CB, $7F, $28, $02
    db   $2F, $3C, $5F, $21, $50, $C2, $09, $7E
    db   $CB, $7F, $28, $02, $2F, $3C, $BB, $30
    db   $0E, $CB, $7A, $20, $04, $1E, $04, $18
    db   $11, $1E, $02, $CD, $13, $45, $C9, $CB
    db   $7E, $28, $05, $3E, $06, $C3, $87, $3B
    db   $1E, $00, $F0, $E7, $1F, $1F, $1F, $E6
    db   $01, $83, $C3, $87, $3B, $50, $00, $52
    db   $00, $54, $00, $56, $00, $52, $20, $50
    db   $20, $56, $20, $54, $20, $21, $60, $C3
    db   $09, $36, $4C, $21, $80, $C3, $09, $7E
    db   $A7, $20, $06, $F0, $F1, $C6, $02, $E0
    db   $F1, $11, $1E, $45, $CD, $3B, $3C, $F0
    db   $EA, $FE, $07, $20, $13, $F0, $E7, $E6
    db   $1F, $20, $04, $3E, $13, $E0, $F3, $F0
    db   $E7, $1F, $1F, $E6, $01, $C3, $87, $3B
    db   $CD, $65, $79, $CD, $EB, $3B, $CD, $E2
    db   $08, $F0, $F0, $FE, $03, $28, $1A, $CD
    db   $0A, $7A, $21, $20, $C3, $09, $35, $21
    db   $10, $C3, $09, $7E, $E6, $80, $E0, $E8
    db   $28, $07, $AF, $77, $21, $20, $C3, $09
    db   $77, $21, $20, $C4, $09, $7E, $A7, $28
    db   $37, $FE, $08, $20, $2B, $FA, $73, $DB
    db   $A7, $28, $1B, $35, $FA, $6B, $C1, $FE
    db   $04, $20, $13, $CD, $ED, $27, $E6, $3F
    db   $20, $07, $3E, $76, $CD, $8E, $21, $18
    db   $05, $3E, $8F, $CD, $97, $21, $21, $B0
    db   $C2, $09, $7E, $FE, $23, $28, $01, $34
    db   $CD, $8D, $3B, $3E, $02, $77, $E0, $F0
    db   $CD, $D5, $3B, $30, $4D, $F0, $F0, $FE
    db   $03, $28, $47, $FA, $9B, $C1, $A7, $20
    db   $41, $FA, $00, $DB, $FE, $03, $20, $08
    db   $F0, $CC, $E6, $20, $20, $0F, $18, $32
    db   $FA, $01, $DB, $FE, $03, $20, $2B, $F0
    db   $CC, $E6, $10, $28, $25, $FA, $CF, $C3
    db   $A7, $20, $1F, $3C, $EA, $CF, $C3, $21
    db   $80, $C2, $09, $36, $07, $21, $90, $C4
    db   $09, $70, $F0, $9E, $EA, $5D, $C1, $CD
    db   $91, $08, $36, $02, $21, $F3, $FF, $36
    db   $02, $C9, $F0, $F0, $C7

    dw JumpTable_462E_05 ; 00
    dw JumpTable_466F_05 ; 01
    dw JumpTable_46BC_05 ; 02
    dw JumpTable_475B_05 ; 03

    db   $00, $04, $06, $04, $00, $FC, $FA, $FC

JumpTable_462E_05:
    xor  a
    call toc_01_3B87
    call toc_01_0891
    jr   nz, .return_05_466E

    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $4626
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   a, e
    and  %00000100
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   hl, $4626
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    call toc_01_0891
    call toc_01_27ED
    and  %00011111
    add  a, $30
    ld   [hl], a
    call JumpTable_3B8D_00
JumpTable_462E_05.return_05_466E:
    ret


JumpTable_466F_05:
    call toc_05_79D1
    call toc_01_3B9E
    ifNot [$FFE8], .else_05_4691

    call toc_01_0891
    jr   nz, .else_05_4686

    ld   [hl], $30
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_466F_05.else_05_4686:
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $05
    ld   hl, $C310
    add  hl, bc
    inc  [hl]
JumpTable_466F_05.else_05_4691:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


    db   $28, $48, $68, $88, $18, $38, $58, $78
    db   $00, $00, $00, $00, $A0, $A0, $A0, $A0
    db   $00, $00, $00, $00, $90, $90, $90, $90
    db   $20, $40, $60, $80, $20, $40, $60, $80

JumpTable_46BC_05:
    ld   hl, $C310
    add  hl, bc
    ld   a, [hFrameCounter]
    xor  c
    and  %00011111
    or   [hl]
    jr   nz, .else_05_46DF

    ld   a, $0C
    call toc_01_3C30
    ld   a, [$FFD7]
    cpl
    inc  a
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ld   a, [$FFD8]
    cpl
    inc  a
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
JumpTable_46BC_05.else_05_46DF:
    call toc_05_79D1
    call toc_01_3B9E
    ld   a, [hFrameCounter]
    rra
    rra
    and  %00000001
    call toc_01_3B87
    call toc_05_7A24
    ld   hl, $C380
    add  hl, bc
    ld   a, e
    xor  %00000001
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    cp   $23
    jr   nz, .return_05_475A

    ld   hl, $DBA5
    ld   a, [hFrameCounter]
    and  %00001111
    or   [hl]
    jr   nz, .return_05_475A

    ld   a, $6C
    ld   e, $07
    call toc_01_3C13
    jr   c, .return_05_475A

    assign [$FFF3], $13
    ld   hl, $C290
    add  hl, de
    ld   [hl], $03
    ld   hl, $C310
    add  hl, de
    ld   [hl], $10
    ld   hl, $C340
    add  hl, de
    ld   [hl], $12
    ld   hl, $C350
    add  hl, de
    ld   [hl], $80
    ld   hl, $C430
    add  hl, de
    ld   [hl], $40
    push bc
    call toc_01_27ED
    and  %00001111
    ld   c, a
    ld   hl, $469C
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $46AC
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    push de
    pop  bc
    ld   a, $18
    call toc_01_3C25
    pop  bc
JumpTable_46BC_05.return_05_475A:
    ret


JumpTable_475B_05:
    call toc_01_3BBF
    call toc_05_79D1
    ld   a, [$FFEE]
    cp   $A9
    jp   nc, toc_05_7A6B

    ld   a, [$FFEC]
    cp   $91
    jp   nc, toc_05_7A6B

    ld   a, [hFrameCounter]
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ld   e, $00
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   z, .else_05_4784

    inc  e
JumpTable_475B_05.else_05_4784:
    ld   hl, $C380
    add  hl, bc
    ld   [hl], e
    jp   toc_01_29C5

    db   $C9, $F0, $00, $60, $00, $F0, $08, $62
    db   $00, $00, $00, $64, $00, $00, $08, $66
    db   $00, $F0, $00, $68, $00, $F0, $08, $6A
    db   $00, $00, $00, $6C, $00, $00, $08, $6E
    db   $00, $F0, $00, $62, $20, $F0, $08, $60
    db   $20, $00, $00, $66, $20, $00, $08, $64
    db   $20, $F0, $00, $68, $00, $F0, $08, $6A
    db   $00, $00, $00, $6C, $00, $00, $08, $6E
    db   $00, $F0, $F1, $17, $17, $17, $17, $E6
    db   $F0, $5F, $50, $21, $8D, $47, $19, $0E
    db   $04, $CD, $26, $3D, $C9, $CD, $CD, $47
    db   $21, $D0, $C3, $09, $34, $7E, $1F, $1F
    db   $1F, $1F, $E6, $03, $CD, $87, $3B, $CD
    db   $09, $54, $F0, $F0, $C7

    dw JumpTable_4803_05 ; 00
    dw JumpTable_4851_05 ; 01
    dw JumpTable_4863_05 ; 02
    dw JumpTable_4898_05 ; 03
    dw JumpTable_4898_05.JumpTable_48C0_05 ; 04

JumpTable_4803_05:
    ld   a, [wDialogState]
    and  a
    jr   nz, .return_05_4844

    ifNot [$DB4B], .else_05_483B

    call toc_05_544C
    ld   a, e
    and  a
    jr   z, .return_05_4844

    ld   hl, $DB00
    ld   a, [hl]
    cp   $0C
    jr   nz, .else_05_482D

    ld   a, [$FFCC]
    and  %00100000
    jr   z, .return_05_4844

    clear [$C1A9]
    ld   [$C1A8], a
    jr   .toc_05_4838

JumpTable_4803_05.else_05_482D:
    inc  hl
    ld   a, [hl]
    cp   $0C
    jr   nz, .else_05_483B

    ld   a, [$FFCC]
    and  %00010000
    ret  z

JumpTable_4803_05.toc_05_4838:
    ld   [hl], b
    jr   .toc_05_4845

JumpTable_4803_05.else_05_483B:
    call toc_05_544C
    ret  nc

    ld   a, $0C
    call toc_01_2197
JumpTable_4803_05.return_05_4844:
    ret


JumpTable_4803_05.toc_05_4845:
    clear [$DB4B]
    call toc_01_0891
    ld   [hl], $04
    jp   JumpTable_3B8D_00

JumpTable_4851_05:
    call toc_01_0891
    ret  nz

    ld   a, $09
    call toc_01_2197
    call toc_01_0891
    ld   [hl], $C0
    call JumpTable_3B8D_00
    ret


JumpTable_4863_05:
    ld   a, [wDialogState]
    and  a
    jr   nz, .return_05_4897

    ld   a, [$C10B]
    and  a
    jr   nz, .else_05_4879

    copyFromTo [hDefaultMusicTrack], [$D368]
    assign [$C10B], INTERACTIVE_MOTION_LOCKED_GRAB_SLASH
JumpTable_4863_05.else_05_4879:
    ld   [hLinkInteractiveMotionBlocked], a
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    inc  [hl]
    inc  [hl]
    inc  [hl]
    call toc_01_0891
    ret  nz

    ld   [$C10B], a
    copyFromTo [hDefaultMusicTrack], [$D368]
    ld   a, $FE
    call toc_01_2197
    call JumpTable_3B8D_00
JumpTable_4863_05.return_05_4897:
    ret


JumpTable_4898_05:
    ld   a, [wDialogState]
    and  a
    ret  nz

    assign [$C1AA], $2A
    assign [$C1A9], $03
    ld   d, $0C
    call toc_05_5261
    ld   a, [$DB4C]
    add  a, $20
    daa
    ld   [$DB4C], a
    assign [$FFA5], $0B
    assign [$FFF2], $01
    call JumpTable_3B8D_00
JumpTable_4898_05.JumpTable_48C0_05:
    ret


    db   $78, $00, $7A, $00, $7A, $20, $78, $20
    db   $7C, $00, $7E, $00, $78, $00, $7A, $00
    db   $70, $00, $72, $00, $74, $00, $76, $00
    db   $76, $20, $74, $20, $72, $20, $70, $20
    db   $5A, $20, $58, $20, $58, $00, $5A, $00
    db   $50, $00, $52, $00, $50, $00, $52, $00
    db   $54, $00, $56, $00, $00, $00, $20, $00
    db   $00, $08, $22, $00, $00, $00, $20, $00
    db   $00, $08, $22, $00, $F1, $FA, $2A, $00
    db   $F1, $02, $2A, $20, $00, $00, $24, $00
    db   $00, $08, $28, $00, $FA, $95, $DB, $FE
    db   $01, $20, $24, $21, $40, $C3, $09, $36
    db   $C4, $21, $D0, $C3, $09, $7E, $21, $F5
    db   $48, $FE, $70, $20, $03, $21, $05, $49
    db   $0E, $04, $CD, $26, $3D, $21, $D0, $C3
    db   $09, $7E, $FE, $70, $C8, $34, $C9, $FA
    db   $A5, $DB, $A7, $C2, $68, $4B, $F0, $F8
    db   $E6, $10, $C2, $6B, $7A, $F0, $F0, $A7
    db   $20, $29, $F0, $E7, $1F, $1F, $1F, $1F
    db   $E6, $01, $CD, $87, $3B, $F0, $99, $FE
    db   $30, $30, $13, $3E, $01, $EA, $0C, $C1
    db   $F0, $E7, $1F, $1F, $1F, $E6, $01, $C6
    db   $02, $CD, $87, $3B, $18, $05, $21, $40
    db   $C4, $09, $70, $11, $C1, $48, $CD, $3B
    db   $3C, $CD, $65, $79, $F0, $F0, $C7

    dw JumpTable_4990_05 ; 00
    dw JumpTable_49C2_05 ; 01
    dw JumpTable_4AEC_05 ; 02
    dw JumpTable_4B32_05 ; 03

JumpTable_4990_05:
    call toc_05_5409
    ifGte [hLinkPositionY], 32, .else_05_49A8

    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_05_49A8

    ld   [hl], $01
    ld   a, $21
    jp   toc_01_2197

JumpTable_4990_05.else_05_49A8:
    call toc_05_544C
    jr   nc, .else_05_49B7

    ld   a, [$C19B]
    and  a
    ret  nz

    ld   a, $0D
    jp   toc_01_2197

JumpTable_4990_05.else_05_49B7:
    ld   hl, $C1AD
    ld   [hl], b
    ret


    db   $00, $04, $05, $06, $07, $01

JumpTable_49C2_05:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    clear [$C19B]
    call toc_05_7A44
    ld   a, e
    xor  DIRECTION_LEFT
    ld   [hLinkDirection], a
    push bc
    call toc_01_087C
    pop  bc
    ld   hl, $C2D0
    add  hl, bc
    ld   e, [hl]
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    add  a, e
    ld   [hl], a
    jr   nc, .else_05_49F1

    ld   hl, $C390
    add  hl, bc
    ld   a, [hl]
    inc  a
    cp   $06
    jr   nz, .else_05_49F0

    xor  a
JumpTable_49C2_05.else_05_49F0:
    ld   [hl], a
JumpTable_49C2_05.else_05_49F1:
    ld   hl, $C390
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $49BC
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    call toc_01_0887
    jr   nz, .else_05_4A49

    ld   a, $02
    call toc_01_3C01
    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   a, [$FFDA]
    ld   hl, $C310
    add  hl, de
    ld   [hl], a
    ld   hl, $C440
    add  hl, de
    ld   [hl], $4C
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $20
    ld   a, $09
    call toc_01_3B87
    ld   hl, $C320
    add  hl, bc
    ld   [hl], b
    call JumpTable_3B8D_00
    ld   a, [$FFF6]
    ld   e, a
    ld   d, b
    ld   hl, $D800
    add  hl, de
    ld   a, [hl]
    or   %00010000
    ld   [hl], a
    assign [$DB48], $01
    ret


JumpTable_49C2_05.else_05_4A49:
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .else_05_4A59

    ld   a, [hl]
    cp   $F0
    jr   nc, .else_05_4A59

    inc  [hl]
JumpTable_49C2_05.else_05_4A59:
    call toc_05_79D1
    call toc_01_3B9E
    call toc_01_0887
    cp   $06
    jr   nc, .else_05_4A97

    ifGte [$FFEF], $30, .else_05_4A70

    ld   [hl], $08
    jr   .else_05_4A97

JumpTable_49C2_05.else_05_4A70:
    ld   hl, $C320
    add  hl, bc
    inc  [hl]
    nop
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_4A85

    and  %10000000
    jr   z, .else_05_4A84

    inc  [hl]
    inc  [hl]
JumpTable_49C2_05.else_05_4A84:
    dec  [hl]
JumpTable_49C2_05.else_05_4A85:
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_4A94

    and  %10000000
    jr   z, .else_05_4A93

    inc  [hl]
    inc  [hl]
JumpTable_49C2_05.else_05_4A93:
    dec  [hl]
JumpTable_49C2_05.else_05_4A94:
    jp   toc_05_7A0A

JumpTable_49C2_05.else_05_4A97:
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00000011
    jr   z, .else_05_4AAC

    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    ld   [hl], a
    assign [$FFF2], $09
JumpTable_49C2_05.else_05_4AAC:
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00001100
    jr   z, .else_05_4AC1

    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    ld   [hl], a
    assign [$FFF2], $09
JumpTable_49C2_05.else_05_4AC1:
    call toc_01_0887
    cp   $60
    jr   nc, .return_05_4AEB

    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .return_05_4AEB

    ld   hl, $C240
    call .toc_05_4AD7
    ld   hl, $C250
JumpTable_49C2_05.toc_05_4AD7:
    add  hl, bc
    ld   a, [hl]
    cp   $30
    jr   z, .return_05_4AEB

    cp   $D0
    jr   z, .return_05_4AEB

    ld   e, $01
    bit  7, a
    jr   z, .else_05_4AE9

    ld   e, $FF
JumpTable_49C2_05.else_05_4AE9:
    add  a, e
    ld   [hl], a
JumpTable_49C2_05.return_05_4AEB:
    ret


JumpTable_4AEC_05:
    call toc_05_7A0A
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   z, .return_05_4B31

    ld   [hl], b
    clear [$C167]
    assign [$FFF2], $23
    call toc_01_27BD
    call toc_01_0891
    ld   [hl], $40
    call toc_05_7A44
    add  a, $08
    call toc_01_3B87
    call toc_05_7A24
    add  a, $12
    cp   $24
    jr   nc, .else_05_4B2E

    call toc_05_7A34
    add  a, $12
    cp   $24
    jr   nc, .else_05_4B2E

    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], $01
JumpTable_4AEC_05.else_05_4B2E:
    call JumpTable_3B8D_00
JumpTable_4AEC_05.return_05_4B31:
    ret


JumpTable_4B32_05:
    call toc_01_0891
    cp   $01
    jr   nz, .else_05_4B3F

    ld   a, $0A
    call toc_01_2197
    ret


JumpTable_4B32_05.else_05_4B3F:
    and  a
    jr   nz, .return_05_4B65

    ld   a, [hFrameCounter]
    and  %00011111
    jr   nz, .else_05_4B50

    call toc_05_7A44
    add  a, 8
    call toc_01_3B87
JumpTable_4B32_05.else_05_4B50:
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_05_4B5B

    call toc_05_5409
JumpTable_4B32_05.else_05_4B5B:
    call toc_05_544C
    jr   nc, .return_05_4B65

    ld   a, $0B
    call toc_01_2197
JumpTable_4B32_05.return_05_4B65:
    ret


    db   $78, $00, $21, $C0, $C2, $09, $7E, $A7
    db   $28, $28, $11, $66, $4B, $CD, $D0, $3C
    db   $CD, $65, $79, $CD, $D1, $79, $CD, $91
    db   $08, $CA, $6B, $7A, $E6, $10, $1E, $01
    db   $28, $02, $1E, $FF, $F0, $E7, $E6, $01
    db   $20, $07, $21, $40, $C2, $09, $7E, $83
    db   $77, $C9, $FA, $73, $DB, $A7, $20, $10
    db   $FA, $67, $DB, $E6, $02, $C2, $6B, $7A
    db   $FA, $0E, $DB, $FE, $04, $D2, $6B, $7A
    db   $FA, $48, $DB, $A7, $20, $07, $FA, $4E
    db   $DB, $A7, $C2, $6B, $7A, $FA, $73, $DB
    db   $A7, $20, $0A, $FA, $48, $DB, $A7, $28
    db   $18, $FE, $01, $20, $14, $21, $00, $C2
    db   $09, $36, $18, $21, $10, $C2, $09, $36
    db   $34, $CD, $BA, $3D, $11, $F1, $48, $18
    db   $14, $CD, $52, $4D, $F0, $E7, $E6, $1F
    db   $20, $08, $CD, $44, $7A, $21, $B0, $C3
    db   $09, $73, $11, $E1, $48, $CD, $3B, $3C
    db   $CD, $65, $79, $CD, $09, $54, $F0, $F0
    db   $C7

    dw JumpTable_4C09_05 ; 00
    dw JumpTable_4C32_05 ; 01
    dw JumpTable_4C48_05 ; 02
    dw JumpTable_4C89_05 ; 03
    dw JumpTable_4D26_05 ; 04

JumpTable_4C09_05:
    ifNot [$DB44], .else_05_4C15

    call JumpTable_3B8D_00
    ld   [hl], $03
    ret


JumpTable_4C09_05.else_05_4C15:
    ifLt [hLinkPositionY], 123, .else_05_4C24

    sub  a, 2
    ld   [hLinkPositionY], a
    ld   a, $00
    jp   toc_01_2197

JumpTable_4C09_05.else_05_4C24:
    call toc_05_544C
    jr   nc, .return_05_4C31

    ld   a, $54
    call toc_01_2197
    call JumpTable_3B8D_00
JumpTable_4C09_05.return_05_4C31:
    ret


JumpTable_4C32_05:
    ld   a, [wDialogState]
    and  a
    jr   nz, .return_05_4C45

    call toc_01_0891
    ld   [hl], $80
    assign [$D368], $10
    call JumpTable_3B8D_00
JumpTable_4C32_05.return_05_4C45:
    ret


    db   $86, $10

JumpTable_4C48_05:
    call toc_01_0891
    jr   nz, .else_05_4C66

    ld   [$C167], a
    ld   d, $04
    call toc_05_5261
    assign [$DB44], $01
    assign [hLinkAnimationState], LINK_ANIMATION_STATE_STANDING_SHIELD_DOWN
    ld   a, $91
    call toc_01_2197
    jp   JumpTable_3B8D_00

JumpTable_4C48_05.else_05_4C66:
    copyFromTo [hLinkPositionX], [$FFEE]
    ld   a, [hLinkPositionY]
    sub  a, 12
    ld   [$FFEC], a
    clear [$FFF1]
    ld   de, $4C46
    call toc_01_3CD0
    call toc_01_3DBA
    assign [hLinkAnimationState], LINK_ANIMATION_STATE_GOT_ITEM
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    assign [hLinkDirection], DIRECTION_DOWN
    ret


JumpTable_4C89_05:
    ifNot [$DB48], .else_05_4CCE

    cp   $01
    jr   z, .else_05_4CB9

    call toc_05_544C
    jr   nc, .else_05_4CAC

    ld   a, [$DB73]
    and  a
    ld   a, $DD
    jr   nz, .else_05_4CB5

    ifNe [$DB0E], $03, .else_05_4CB3

    ld   a, $C5
    call toc_01_2185
JumpTable_4C89_05.else_05_4CAC:
    ld   a, [$DB73]
    and  a
    jr   nz, .else_05_4CE0

    ret


JumpTable_4C89_05.else_05_4CB3:
    ld   a, $C5
JumpTable_4C89_05.else_05_4CB5:
    call toc_01_2185
    ret


JumpTable_4C89_05.else_05_4CB9:
    call toc_05_544C
    jr   nc, .else_05_4CCC

    ld   a, [$DB65]
    bit  1, a
    ld   a, $11
    jr   z, .else_05_4CC9

    ld   a, $10
JumpTable_4C89_05.else_05_4CC9:
    call toc_01_2197
JumpTable_4C89_05.else_05_4CCC:
    jr   .toc_05_4CD9

JumpTable_4C89_05.else_05_4CCE:
    call toc_05_544C
    jr   nc, .return_05_4CD8

    ld   a, $55
    call toc_01_2197
JumpTable_4C89_05.return_05_4CD8:
    ret


JumpTable_4C89_05.toc_05_4CD9:
    ifNe [$DB48], $01, .return_05_4D25

JumpTable_4C89_05.else_05_4CE0:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    add  a, $07
    ld   [hl], a
    jr   nc, .return_05_4D25

    ld   a, $3F
    call toc_01_3C01
    ld   a, [$FFD7]
    add  a, $06
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    sub  a, $03
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2C0
    add  hl, de
    ld   [hl], $01
    ld   hl, $C240
    add  hl, de
    ld   [hl], $FF
    ld   hl, $C250
    add  hl, de
    ld   [hl], $FD
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $30
    ld   hl, $C340
    add  hl, de
    ld   [hl], $C1
    ld   hl, $C350
    add  hl, de
    ld   [hl], $00
JumpTable_4C89_05.return_05_4D25:
    ret


JumpTable_4D26_05:
    ld   a, [wDialogState]
    and  a
    jr   nz, .return_05_4D49

    ld   a, [$C177]
    and  a
    jr   nz, .else_05_4D40

    assign [$DB0E], $04
    assign [$FFA5], $0D
    call toc_01_0898
    jr   .toc_05_4D45

JumpTable_4D26_05.else_05_4D40:
    ld   a, $C9
    call toc_01_2185
JumpTable_4D26_05.toc_05_4D45:
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_4D26_05.return_05_4D49:
    ret


    db   $74, $00, $76, $00, $70, $00, $72, $00
    db   $FA, $48, $DB, $FE, $02, $C0, $FA, $0E
    db   $DB, $FE, $04, $30, $07, $3E, $78, $11
    db   $4A, $4D, $18, $10, $F0, $F8, $E6, $20
    db   $C8, $21, $10, $C2, $09, $36, $4B, $11
    db   $4E, $4D, $3E, $7C, $E0, $EE, $3E, $5C
    db   $E0, $EC, $AF, $E0, $F1, $CD, $3B, $3C
    db   $CD, $BA, $3D, $21, $B0, $C3, $09, $7E
    db   $E0, $F1, $C9, $60, $00, $62, $00, $62
    db   $20, $60, $20, $64, $00, $66, $00, $66
    db   $20, $64, $20, $68, $00, $6A, $00, $6C
    db   $00, $6E, $00, $6A, $20, $68, $20, $6E
    db   $20, $6C, $20, $68, $00, $6A, $00, $6A
    db   $20, $68, $20, $66, $00, $66, $20, $66
    db   $00, $66, $20, $6C, $00, $6E, $00, $6C
    db   $00, $6E, $00, $6E, $20, $6C, $20, $6E
    db   $20, $6C, $20, $60, $00, $62, $00, $64
    db   $00, $64, $20, $62, $20, $60, $20, $08
    db   $08, $08, $09, $0A, $0A, $0A, $09, $08
    db   $F8, $06, $01, $FA, $95, $DB, $FE, $01
    db   $CA, $4E, $4E, $FA, $73, $DB, $A7, $C2
    db   $6B, $7A, $FA, $A5, $DB, $A7, $C2, $1D
    db   $51, $FA, $4E, $DB, $A7, $CA, $6B, $7A
    db   $F0, $F6, $FE, $C0, $38, $02, $18, $0F
    db   $FA, $08, $D8, $E6, $10, $20, $08, $FA
    db   $0E, $DB, $FE, $07, $D2, $6B, $7A, $F0
    db   $E7, $E6, $1F, $20, $20, $21, $80, $C3
    db   $09, $36, $03, $CD, $24, $7A, $C6, $14
    db   $FE, $28, $30, $11, $CD, $34, $7A, $C6
    db   $14, $FE, $28, $30, $08, $CD, $44, $7A
    db   $21, $80, $C3, $09, $73, $CD, $30, $54
    db   $FA, $C8, $C3, $FE, $01, $20, $5E, $CD
    db   $8C, $08, $20, $59, $F0, $E7, $1F, $1F
    db   $1F, $1F, $E6, $07, $5F, $50, $21, $D9
    db   $4D, $19, $7E, $E0, $F1, $F0, $E7, $C6
    db   $10, $E6, $1F, $20, $40, $3E, $C9, $CD
    db   $01, $3C, $38, $39, $F0, $D8, $21, $10
    db   $C2, $19, $D6, $08, $77, $C5, $F0, $E7
    db   $C6, $10, $1F, $1F, $1F, $1F, $1F, $E6
    db   $01, $4F, $21, $E1, $4D, $09, $F0, $D7
    db   $86, $21, $00, $C2, $19, $77, $21, $E3
    db   $4D, $09, $7E, $21, $40, $C2, $19, $77
    db   $21, $50, $C2, $19, $36, $FC, $21, $D0
    db   $C3, $19, $36, $40, $C1, $79, $EA, $0F
    db   $C5, $11, $AD, $4D, $CD, $3B, $3C, $CD
    db   $09, $54, $F0, $F0, $C7

    dw JumpTable_4EC3_05 ; 00
    dw JumpTable_4F84_05 ; 01
    dw JumpTable_4FBD_05 ; 02
    dw JumpTable_508C_05 ; 03
    dw JumpTable_50B8_05 ; 04
    dw JumpTable_510B_05 ; 05

JumpTable_4EC3_05:
    ifGte [$FFF6], $C0, .else_05_4ED0

    ld   a, [$C3C8]
    and  a
    jp   nz, .return_05_4F83

JumpTable_4EC3_05.else_05_4ED0:
    call toc_05_544C
    jp   nc, .return_05_4F83

    ld   a, [$D808]
    and  %00010000
    jr   z, .else_05_4F0A

    ld   hl, $D892
    ld   a, [hl]
    and  %01000000
    jr   nz, .else_05_4EEC

    set  6, [hl]
    ld   a, $94
    jp   toc_01_2185

JumpTable_4EC3_05.else_05_4EEC:
    ld   a, [$DB49]
    and  %00000100
    jr   z, .else_05_4EF8

JumpTable_4EC3_05.toc_05_4EF3:
    ld   a, $95
    jp   toc_01_2185

JumpTable_4EC3_05.else_05_4EF8:
    ld   e, $0B
    ld   hl, $DB00
JumpTable_4EC3_05.loop_05_4EFD:
    ldi  a, [hl]
    cp   $09
    jr   z, .else_05_4F0A

    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_05_4EFD

    jr   .toc_05_4EF3

JumpTable_4EC3_05.else_05_4F0A:
    call toc_01_088C
    ld   [hl], $10
    ld   d, $2F
    ld   e, $03
    ifNot [$DB48], .else_05_4F5E

    ld   e, $06
    cp   $02
    jr   nz, .else_05_4F33

    ld   e, $05
    ifLt [$FFF6], $C0, .else_05_4F33

    push de
    call toc_01_27BD
    pop  de
    ld   hl, $C2D0
    add  hl, bc
    ld   [hl], b
    ld   e, $92
JumpTable_4EC3_05.else_05_4F33:
    push bc
    ld   c, $0B
    ld   hl, $DB00
JumpTable_4EC3_05.loop_05_4F39:
    ldi  a, [hl]
    cp   $09
    jr   nz, .else_05_4F57

    ld   e, $04
    ld   d, $4A
    ld   a, [$DB49]
    and  %00000100
    jr   z, .else_05_4F5D

    ld   e, $05
    ld   d, $2F
    ifLt [$FFF6], $C0, .else_05_4F5D

    ld   e, $92
    jr   .else_05_4F5D

JumpTable_4EC3_05.else_05_4F57:
    dec  c
    ld   a, c
    cp   $FF
    jr   nz, .loop_05_4F39

JumpTable_4EC3_05.else_05_4F5D:
    pop  bc
JumpTable_4EC3_05.else_05_4F5E:
    ld   a, e
    cp   $80
    jr   c, .else_05_4F68

    call toc_01_2185
    jr   .toc_05_4F6B

JumpTable_4EC3_05.else_05_4F68:
    call toc_01_2197
JumpTable_4EC3_05.toc_05_4F6B:
    ifLt [$FFF6], $C0, .else_05_4F7B

    ld   hl, $C2D0
    add  hl, bc
    ld   [hl], b
    push de
    call toc_01_27BD
    pop  de
JumpTable_4EC3_05.else_05_4F7B:
    ld   hl, $C440
    add  hl, bc
    ld   [hl], d
    call JumpTable_3B8D_00
JumpTable_4EC3_05.return_05_4F83:
    ret


JumpTable_4F84_05:
    call toc_05_7965
    ld   hl, $C440
    add  hl, bc
    ld   d, [hl]
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    and  a
    ld   a, d
    jr   nz, .else_05_4FA2

    inc  [hl]
    ld   [$D368], a
    ld   [hDefaultMusicTrack], a
    ld   [$FFBD], a
    ld   hl, $C3C8
    ld   [hl], $01
JumpTable_4F84_05.else_05_4FA2:
    cp   $4A
    jr   nz, .else_05_4FB8

    ld   a, [$DB49]
    and  %00000100
    jr   nz, .else_05_4FB8

    call JumpTable_3B8D_00
    clear [$D210]
    ld   [$D211], a
    ret


JumpTable_4F84_05.else_05_4FB8:
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_4FBD_05:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    push bc
    call toc_01_087C
    pop  bc
    ifNe [$D211], $07, .else_05_4FEB

    ifNe [$D210], $E8, .else_05_4FEB

    ld   a, $16
    call toc_01_2197
    push bc
    call toc_01_087C
    pop  bc
    clear [$D210]
    ld   [$D211], a
    call toc_01_27D2
    jp   JumpTable_3B8D_00

JumpTable_4FBD_05.else_05_4FEB:
    call toc_05_7A44
    ld   a, e
    xor  DIRECTION_LEFT
    ld   [hLinkDirection], a
    ld   a, [$D210]
    add  a, $01
    ld   [$D210], a
    ld   e, a
    ld   a, [$D211]
    adc  $00
    ld   [$D211], a
    ld   d, a
    ifNe [$D211], $07, .else_05_5018

    ifLt [$D210], $E0, .else_05_5018

    clear [$C3C8]
    ret


JumpTable_4FBD_05.else_05_5018:
    ld   hl, $C3C8
    ld   [hl], $01
    ld   a, e
    srl  d
    rra
    srl  d
    rra
    srl  d
    rra
    srl  d
    rra
    cp   $1D
    jr   c, .else_05_5033

    cp   $3B
    jr   nc, .else_05_5033

    inc  [hl]
JumpTable_4FBD_05.else_05_5033:
    cp   $1D
    ret  c

    assign [hLinkAnimationState], LINK_ANIMATION_STATE_STANDING_DOWN
    ld   a, [hFrameCounter]
    ld   e, LINK_ANIMATION_STATE_UNKNOWN_75
    and  %01000000
    jr   z, .else_05_5043

    inc  e
JumpTable_4FBD_05.else_05_5043:
    ld   a, e
    ld   [hLinkAnimationState], a
    ld   a, [hFrameCounter]
    and  %00011111
    jr   nz, .return_05_508B

    ld   a, $C9
    call toc_01_3C01
    jr   c, .return_05_508B

    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, de
    sub  a, 8
    ld   [hl], a
    push bc
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    rra
    and  %00000001
    ld   c, a
    ld   b, d
    ld   hl, $4DE1
    add  hl, bc
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $4DE3
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    pop  bc
    ld   hl, $C250
    add  hl, de
    ld   [hl], $FC
    ld   hl, $C3D0
    add  hl, de
    ld   [hl], $40
JumpTable_4FBD_05.return_05_508B:
    ret


JumpTable_508C_05:
    ld   a, [wDialogState]
    and  a
    jr   nz, .return_05_50B5

    call JumpTable_3B8D_00
    ld   a, [$C177]
    and  a
    jr   nz, .else_05_50A6

    assign [$D368], $10
    call toc_01_0891
    ld   [hl], $80
    ret


JumpTable_508C_05.else_05_50A6:
    ld   a, $15
    call toc_01_2197
    call JumpTable_3B8D_00
    ld   [hl], $01
    ld   hl, $C2D0
    add  hl, bc
    ld   [hl], b
JumpTable_508C_05.return_05_50B5:
    ret


    db   $90, $10

JumpTable_50B8_05:
    call toc_01_0891
    jr   nz, .else_05_50E5

    ld   a, [wDialogState]
    and  a
    ret  nz

    ld   hl, $DB49
    set  2, [hl]
    clear [$DB4A]
    call JumpTable_3B8D_00
    ifLt [$FFF6], $C0, .else_05_50D5

    ld   [hl], b
JumpTable_50B8_05.else_05_50D5:
    ifGte [$FFF6], $C0, .else_05_50E0

    ld   a, $14
    jp   toc_01_2197

JumpTable_50B8_05.else_05_50E0:
    ld   a, $93
    jp   toc_01_2185

JumpTable_50B8_05.else_05_50E5:
    cp   $08
    jr   nz, .else_05_50EF

    dec  [hl]
    ld   a, $13
    call toc_01_2197
JumpTable_50B8_05.else_05_50EF:
    assign [hLinkAnimationState], LINK_ANIMATION_STATE_GOT_ITEM
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    copyFromTo [hLinkPositionX], [$FFEE]
    ld   a, [hLinkPositionY]
    sub  a, 12
    ld   [$FFEC], a
    ld   de, $50B6
    clear [$FFF1]
    call toc_01_3CD0
    ret


JumpTable_510B_05:
    ld   a, [wDialogState]
    and  a
    ret  nz

    call toc_05_544C
    ret  nc

    ld   a, $97
    jp   toc_01_2185

    db   $5C, $00, $5C, $20, $FA, $0E, $DB, $FE
    db   $07, $38, $28, $FA, $FD, $D8, $E6, $30
    db   $C2, $6B, $7A, $21, $10, $C2, $09, $36
    db   $60, $21, $00, $C2, $09, $36, $7A, $11
    db   $19, $51, $CD, $3B, $3C, $CD, $65, $79
    db   $CD, $4C, $54, $30, $05, $3E, $D7, $CD
    db   $85, $21, $C9, $FA, $4E, $DB, $A7, $C2
    db   $6B, $7A, $FA, $44, $DB, $A7, $28, $09
    db   $21, $90, $C2, $09, $3E, $03, $77, $E0
    db   $F0, $F0, $F0, $A7, $20, $22, $CD, $87
    db   $08, $36, $7F, $21, $80, $C3, $09, $36
    db   $01, $21, $00, $C2, $09, $7E, $D6, $08
    db   $77, $21, $10, $C2, $09, $7E, $D6, $08
    db   $77, $EA, $67, $C1, $CD, $8D, $3B, $C9
    db   $F0, $E7, $E6, $1F, $20, $08, $CD, $44
    db   $7A, $21, $80, $C3, $09, $73, $CD, $30
    db   $54, $11, $8D, $4D, $CD, $3B, $3C, $F0
    db   $F0, $3D, $C7

    dw JumpTable_51DE_05 ; 00
    dw JumpTable_5219_05 ; 01
    dw JumpTable_5250_05 ; 02

    db   $40, $00, $42, $00, $42, $20, $40, $20
    db   $44, $00, $46, $00, $48, $00, $4A, $00
    db   $48, $00, $4C, $00, $03, $03, $03, $03
    db   $03, $04, $03, $04, $03, $03, $03, $02
    db   $02, $02, $02, $02, $00, $00, $01, $01
    db   $00, $00, $01, $01, $00, $00, $01, $01
    db   $00, $00, $01, $01

JumpTable_51DE_05:
    call toc_01_0887
    jr   nz, .else_05_51EE

    ld   a, $01
    call toc_01_2197
    ld   [hl], $40
    call JumpTable_3B8D_00
    xor  a
JumpTable_51DE_05.else_05_51EE:
    rra
    rra
    and  %00011111
    ld   e, a
    ld   d, b
    ld   hl, $51BE
    add  hl, de
    ld   a, [hl]
JumpTable_51DE_05.toc_05_51F9:
    ld   [$FFF1], a
    assign [$FFEE], 56
    ld   [hLinkPositionX], a
    assign [$FFEC], 52
    ld   [hLinkPositionY], a
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    assign [hLinkAnimationState], LINK_ANIMATION_STATE_NO_UPDATE
    ld   de, $51AA
    call toc_01_3C3B
    call toc_01_3DBA
    ret


JumpTable_5219_05:
    ld   a, $03
    call JumpTable_51DE_05.toc_05_51F9
    call toc_01_0891
    ld   hl, wDialogState
    or   [hl]
    jr   nz, .return_05_524F

    ld   a, [hPressedButtonsMask]
    and  J_DOWN | J_LEFT | J_RIGHT | J_UP
    jr   z, .return_05_524F

    call JumpTable_3B8D_00
    assign [hLinkPositionZHigh], $01
    assign [$C146], $02
    assign [hLinkPositionZLow], $12
    assign [hLinkPositionXIncrement], 12
    clear [hLinkPositionYIncrement]
    assign [hLinkDirection], DIRECTION_RIGHT
    ld   [hLinkInteractiveMotionBlocked], a
    assign [$C10A], $01
JumpTable_5219_05.return_05_524F:
    ret


JumpTable_5250_05:
    call toc_05_7965
    call toc_05_5409
    call toc_05_544C
    jr   nc, .return_05_5260

    ld   a, $02
    call toc_01_2197
JumpTable_5250_05.return_05_5260:
    ret


toc_05_5261:
    ld   hl, $DB00
    ld   e, $0C
toc_05_5261.loop_05_5266:
    ldi  a, [hl]
    cp   d
    jr   z, .return_05_527D

    dec  e
    jr   nz, .loop_05_5266

    ld   hl, $DB00
toc_05_5261.loop_05_5270:
    ld   a, [hl]
    and  a
    jr   nz, .else_05_5276

    ld   [hl], d
    ret


toc_05_5261.else_05_5276:
    inc  hl
    inc  e
    ld   a, e
    cp   $0C
    jr   nz, .loop_05_5270

toc_05_5261.return_05_527D:
    ret


    db   $60, $00, $62, $00, $62, $20, $60, $20
    db   $64, $00, $66, $00, $66, $20, $64, $20
    db   $68, $00, $6A, $00, $6C, $00, $6E, $00
    db   $6A, $20, $68, $20, $6E, $20, $6C, $20
    db   $FA, $A5, $DB, $A7, $28, $7E, $F0, $E7
    db   $E6, $1F, $20, $08, $CD, $44, $7A, $21
    db   $80, $C3, $09, $73, $CD, $30, $54, $11
    db   $7E, $52, $CD, $3B, $3C, $CD, $65, $79
    db   $CD, $09, $54, $F0, $F0, $C7

    dw JumpTable_52CA_05 ; 00
    dw JumpTable_52DE_05 ; 01
    dw JumpTable_530F_05 ; 02

JumpTable_52CA_05:
    ld   a, [$D477]
    and  a
    jr   nz, JumpTable_530F_05

    call toc_05_544C
    jr   nc, .return_05_52DD

    ld   a, $F0
    call toc_01_2197
    call JumpTable_3B8D_00
JumpTable_52CA_05.return_05_52DD:
    ret


JumpTable_52DE_05:
    ld   a, [wDialogState]
    and  a
    jr   nz, .return_05_5308

    call JumpTable_3B8D_00
    ifNot [$C177], .else_05_52EF

    ld   [hl], b
    ret


JumpTable_52DE_05.else_05_52EF:
    ld   a, [$DB5E]
    sub  a, $00
    ld   a, [$DB5D]
    sbc  $01
    jr   c, .else_05_5309

    assign [$DB92], $64
    assign [$D477], $F1
    call toc_01_2197
JumpTable_52DE_05.return_05_5308:
    ret


JumpTable_52DE_05.else_05_5309:
    ld   [hl], b
    ld   a, $4E
    jp   toc_01_2197

JumpTable_530F_05:
    call toc_05_544C
    jr   nc, .return_05_5319

    ld   a, $F1
    call toc_01_2197
JumpTable_530F_05.return_05_5319:
    ret


    db   $5C, $00, $5C, $20, $5E, $00, $5E, $20
    db   $21, $40, $C4, $09, $FA, $77, $D4, $B6
    db   $20, $2B, $1E, $0F, $50, $7B, $B9, $28
    db   $12, $21, $80, $C2, $19, $7E, $A7, $28
    db   $0A, $21, $A0, $C3, $19, $7E, $FE, $6A
    db   $CA, $6B, $7A, $1D, $7B, $FE, $FF, $20
    db   $E4, $11, $1A, $53, $CD, $3B, $3C, $CD
    db   $65, $79, $C3, $09, $54, $F0, $E7, $1F
    db   $1F, $1F, $1F, $E6, $01, $CD, $87, $3B
    db   $F0, $98, $21, $EE, $FF, $96, $C6, $10
    db   $FE, $20, $30, $18, $F0, $99, $21, $EF
    db   $FF, $96, $C6, $14, $FE, $1C, $30, $0C
    db   $3E, $80, $EA, $AD, $C1, $F0, $98, $21
    db   $00, $C2, $09, $77, $FA, $1F, $C1, $A7
    db   $28, $06, $CD, $8D, $3B, $70, $18, $3B
    db   $F0, $F0, $C7

    dw JumpTable_539B_05 ; 00
    dw JumpTable_53B2_05 ; 01
    dw JumpTable_53D6_05 ; 02

JumpTable_539B_05:
    call toc_05_7A24
    add  a, $08
    cp   $10
    jr   nc, .else_05_53B0

    call toc_05_7A34
    add  a, $09
    cp   $12
    jr   nc, .else_05_53B0

    call JumpTable_3B8D_00
JumpTable_539B_05.else_05_53B0:
    jr   JumpTable_53B2_05.toc_05_53CD

JumpTable_53B2_05:
    copyFromTo [$FFEE], [hLinkPositionX]
    ld   a, [$FFEC]
    sub  a, 5
    ld   [hLinkPositionY], a
    call JumpTable_3B8D_00
    ld   hl, $C440
    add  hl, bc
    ld   [hl], $01
    clear [$D477]
JumpTable_53B2_05.toc_05_53C9:
    assign [hLinkWalksSlow], true
JumpTable_53B2_05.toc_05_53CD:
    call toc_01_3DBA
    ld   de, $531A
    jp   toc_01_3C3B

JumpTable_53D6_05:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    ld   [$C13B], a
    ld   a, [$FFF6]
    ld   hl, $C3E0
    add  hl, bc
    ld   [hl], a
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, bc
    add  a, 5
    ld   [hl], a
    ld   hl, $C310
    add  hl, bc
    ld   [hl], b
    ifNe [$C11C], $02, .else_05_5407

    ld   a, [hLinkPositionZHigh]
    ld   [hl], a
JumpTable_53D6_05.else_05_5407:
    jr   JumpTable_53B2_05.toc_05_53C9

toc_05_5409:
    call toc_01_3BD5
    jr   nc, .return_05_542B

    call toc_01_094A
    call toc_01_093B.toc_01_0942
    ifNot [$C1A6], .return_05_542B

    ld   e, a
    ld   d, b
    ld   hl, $C39F
    add  hl, de
    ld   a, [hl]
    cp   $03
    jr   nz, .return_05_542B

    ld   hl, $C28F
    add  hl, de
    ld   [hl], $00
toc_05_5409.return_05_542B:
    ret


    db   $06, $04, $02, $00, $21, $80, $C3, $09
    db   $5E, $50, $21, $2C, $54, $19, $E5, $21
    db   $D0, $C3, $09, $34, $7E, $1F, $1F, $1F
    db   $1F, $E1, $E6, $01, $B6, $C3, $87, $3B

toc_05_544C:
    ld   e, b
    ld   a, [hLinkPositionY]
    ld   hl, $FFEF
    sub  a, [hl]
    add  a, 20
    cp   40
    jr   nc, .else_05_549D

    ld   a, [hLinkPositionX]
    ld   hl, $FFEE
    sub  a, [hl]
    add  a, 16
    cp   32
    jr   nc, .else_05_549D

    inc  e
    ifEq [$FFEB], $6D, .else_05_5478

    push de
    call toc_05_7A44
    ld   a, [hLinkDirection]
    xor  DIRECTION_LEFT
    cp   e
    pop  de
    jr   nz, .else_05_549D

toc_05_544C.else_05_5478:
    ld   hl, $C1AD
    ld   [hl], $01
    ld   a, [wDialogState]
    ld   hl, $C14F
    or   [hl]
    ld   hl, $C146
    or   [hl]
    ld   hl, $C134
    or   [hl]
    jr   nz, .else_05_549D

    ifNe [$DB9A], $80, .else_05_549D

    ld   a, [$FFCC]
    and  %00010000
    jr   z, .else_05_549D

    scf
    ret


toc_05_544C.else_05_549D:
    and  a
    ret


toc_05_549F:
    call toc_01_0887
    ld   [hl], $C0
    assign [$D202], $18
    ret


    db   $21, $D0, $C2, $09, $7E, $C7

    dw JumpTable_54B8_05 ; 00
    dw JumpTable_5875_05 ; 01
    dw JumpTable_583C_05 ; 02
    dw JumpTable_58BF_05 ; 03

JumpTable_54B8_05:
    call toc_01_3F12
    call toc_05_580E
    ifEq [$FFEA], $05, toc_05_5500

    ld   [$C1C6], a
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    jumptable
    dw JumpTable_54D1_05 ; 00
    dw JumpTable_54DF_05 ; 01

JumpTable_54D1_05:
    call toc_01_0891
    ld   [hl], $FF
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $FF
    jp   JumpTable_628F_05.toc_05_6294

JumpTable_54DF_05:
    call toc_01_0891
    jp   z, .toc_05_54F2

    ld   hl, $C420
    add  hl, bc
    ld   [hl], a
    cp   $80
    jr   nc, .return_05_54F1

    call toc_05_7476
JumpTable_54DF_05.return_05_54F1:
    ret


JumpTable_54DF_05.toc_05_54F2:
    call toc_05_74AD
    ld   hl, $C480
    add  hl, de
    ld   [hl], $08
    ret


    db   $F8, $A8, $08, $F8

toc_05_5500:
    call toc_05_7965
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, toc_05_5554

    and  %00111111
    jr   nz, toc_05_5554

    ld   a, $65
    ld   e, $04
    call toc_01_3C13
    jr   c, toc_05_5586

    ld   hl, $C340
    add  hl, de
    ld   [hl], $02
    ld   hl, $C350
    add  hl, de
    ld   [hl], $80
    ld   hl, $C430
    add  hl, de
    ld   [hl], $40
    ld   hl, $C2D0
    add  hl, de
    ld   [hl], $01
    ld   hl, $C200
    add  hl, de
    ld   a, [$D202]
    ld   [hl], a
    add  a, $20
    ld   [$D202], a
    cp   $A8
    jr   c, toc_05_5546

    assign [$D202], $08
toc_05_5546:
    call toc_01_27ED
    ld   hl, $C3D0
    add  hl, de
    ld   [hl], a
    ld   hl, $C210
    add  hl, de
    ld   [hl], $00
toc_05_5554:
    ld   a, [$D201]
    inc  a
    ld   [$D201], a
    and  %01111111
    jr   nz, toc_05_5586

    ld   a, $65
    ld   e, $04
    call toc_01_3C13
    jr   c, toc_05_5586

    ld   hl, $C340
    add  hl, de
    ld   [hl], $41
    ld   hl, $C2D0
    add  hl, de
    ld   [hl], $02
    ld   a, [$FFD7]
    sub  a, $14
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    sub  a, $04
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
toc_05_5586:
    ld   hl, $C360
    add  hl, bc
    ld   a, [hl]
    cp   $0A
    jr   nc, toc_05_55E7

    ld   a, [$D201]
    add  a, $40
    and  %11111111
    jr   nz, toc_05_55E7

    ld   a, $65
    ld   e, $04
    call toc_01_3C13
    jr   c, toc_05_55E7

    ld   hl, $C4D0
    add  hl, de
    ld   [hl], d
    ld   hl, $C340
    add  hl, de
    ld   [hl], $02
    ld   hl, $C430
    add  hl, de
    ld   [hl], d
    ld   hl, $C360
    add  hl, de
    ld   [hl], d
    ld   hl, $C2D0
    add  hl, de
    ld   [hl], $03
    call toc_01_27ED
    and  %00111111
    add  a, $20
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    push bc
    and  %00000001
    ld   c, a
    ld   hl, $54FC
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $54FE
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $40
    pop  bc
toc_05_55E7:
    call toc_01_08E2
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    inc  [hl]
    rra
    rra
    rra
    rra
    and  %00000001
    ld   hl, $C3B0
    add  hl, bc
    ld   [hl], a
    ld   a, [$FFEE]
    sub  a, $10
    ld   [$FFEE], a
    ld   a, [$FFEC]
    sub  a, $10
    ld   [$FFEC], a
    ld   hl, $C350
    add  hl, bc
    ld   [hl], $00
    call toc_01_3B65
    call toc_01_3BEB
    call toc_01_3DBA
    ld   hl, $C350
    add  hl, bc
    ld   [hl], $14
    call toc_01_3B65
    call toc_01_3BBF
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_562F_05 ; 00
    dw JumpTable_566E_05 ; 01
    dw JumpTable_56A8_05 ; 02

    db   $08, $F8, $60, $18

JumpTable_562F_05:
    call toc_01_0887
    jr   nz, .else_05_5649

    call toc_01_0891
    ld   [hl], $80
    call JumpTable_3B8D_00
    call toc_01_27ED
    and  %00011111
    add  a, $60
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    ret


JumpTable_562F_05.else_05_5649:
    ld   hl, $C380
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $562D
    add  hl, de
    ld   a, [$FFEC]
    cp   [hl]
    jr   nz, .else_05_5660

    ld   a, e
    xor  %00000001
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
JumpTable_562F_05.else_05_5660:
    ld   hl, $562B
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    call toc_05_79D1.toc_05_79D4
    ret


JumpTable_566E_05:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    inc  [hl]
    inc  [hl]
    call toc_01_0891
    cp   $60
    jr   nz, .else_05_5681

    ld   hl, $FFF3
    ld   [hl], $0D
JumpTable_566E_05.else_05_5681:
    jr   nc, .return_05_56A7

    ld   hl, $C240
    add  hl, bc
    ld   [hl], $D0
    call toc_05_79DE
    ifGte [$FFEE], $18, .return_05_56A7

    assign [$C157], $30
    clear [$C158]
    call toc_01_08D7
    ld   hl, $C300
    add  hl, bc
    ld   [hl], $FF
    call JumpTable_3B8D_00
JumpTable_566E_05.return_05_56A7:
    ret


JumpTable_56A8_05:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    inc  [hl]
    ld   a, [$C157]
    and  a
    jr   nz, .return_05_56D5

    ld   hl, $C240
    add  hl, bc
    ld   [hl], $20
    call toc_05_79DE
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [$FFEE]
    cp   [hl]
    jr   c, .return_05_56D5

    call toc_01_0887
    call toc_01_27ED
    and  %00011111
    add  a, $40
    ld   [hl], a
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_56A8_05.return_05_56D5:
    ret


    db   $F0, $F0, $40, $00, $F0, $F8, $42, $00
    db   $F0, $00, $44, $00, $F0, $08, $46, $10
    db   $F0, $10, $48, $10, $F0, $18, $4A, $10
    db   $00, $F0, $4C, $00, $00, $F8, $4E, $00
    db   $00, $00, $50, $10, $00, $08, $52, $10
    db   $00, $10, $54, $10, $00, $18, $56, $10
    db   $00, $20, $58, $10, $10, $F8, $5A, $10
    db   $10, $00, $5C, $10, $10, $08, $5E, $10
    db   $10, $10, $60, $10, $10, $18, $62, $10
    db   $10, $20, $64, $10, $00, $00, $FF, $00
    db   $F0, $F0, $66, $00, $F0, $F8, $42, $00
    db   $F0, $00, $44, $00, $F0, $08, $46, $10
    db   $F0, $10, $48, $10, $F0, $18, $4A, $10
    db   $00, $F0, $68, $00, $00, $F8, $4E, $00
    db   $00, $00, $50, $10, $00, $08, $52, $10
    db   $00, $10, $54, $10, $00, $18, $56, $10
    db   $00, $20, $6A, $10, $10, $F8, $5A, $10
    db   $10, $00, $5C, $10, $10, $08, $5E, $10
    db   $10, $10, $60, $10, $10, $18, $62, $10
    db   $10, $20, $6C, $10, $F0, $18, $4A, $10
    db   $F0, $08, $46, $10, $F0, $10, $48, $10
    db   $F0, $F8, $42, $00, $F0, $00, $44, $00
    db   $F0, $F0, $40, $00, $00, $20, $58, $10
    db   $00, $08, $52, $10, $00, $10, $54, $10
    db   $00, $18, $56, $10, $00, $F8, $4E, $00
    db   $00, $00, $50, $10, $00, $F0, $4C, $00
    db   $10, $20, $64, $10, $10, $10, $60, $10
    db   $10, $18, $62, $10, $10, $00, $5C, $10
    db   $10, $08, $5E, $10, $10, $F8, $5A, $10
    db   $00, $00, $FF, $00, $F0, $18, $4A, $10
    db   $F0, $08, $46, $10, $F0, $10, $48, $10
    db   $F0, $F8, $42, $00, $F0, $00, $44, $00
    db   $F0, $F0, $66, $00, $00, $20, $6A, $10
    db   $00, $08, $52, $10, $00, $10, $54, $10
    db   $00, $18, $56, $10, $00, $F8, $4E, $00
    db   $00, $00, $50, $10, $00, $F0, $68, $00
    db   $10, $20, $6C, $10, $10, $10, $60, $10
    db   $10, $18, $62, $10, $10, $00, $5C, $10
    db   $10, $08, $5E, $10, $10, $F8, $5A, $10

toc_05_580E:
    ld   a, [$FFF1]
    sla  a
    sla  a
    sla  a
    sla  a
    ld   e, a
    sla  a
    sla  a
    add  a, e
    ld   e, a
    ld   d, b
    ld   hl, $56D6
    ld   a, [hFrameCounter]
    and  %00000001
    jr   z, .else_05_582C

    ld   hl, $5772
toc_05_580E.else_05_582C:
    add  hl, de
    ld   c, $13
    call toc_01_3D26
    ld   a, $13
    call toc_01_3DD0
    ret


    db   $72, $00, $72, $20

JumpTable_583C_05:
    ld   de, $5838
    call toc_01_3CD0
    call toc_05_7965
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    and  %00110000
    jr   z, .else_05_5865

    ld   hl, $C250
    add  hl, bc
    ld   [hl], $F8
    call toc_05_79D1.toc_05_79D4
JumpTable_583C_05.else_05_5865:
    ld   a, [$FFEC]
    cp   $10
    jp   c, toc_05_7A6B

    ret


    db   $74, $00, $76, $00, $76, $20, $74, $20

JumpTable_5875_05:
    ld   de, $586D
    call toc_01_3C3B
    call toc_05_7965
    call toc_01_08E2
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    push af
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    call toc_01_3BB4
    pop  af
    ld   e, $FC
    and  %00010000
    jr   z, .else_05_589D

    ld   e, $04
JumpTable_5875_05.else_05_589D:
    ld   hl, $C240
    add  hl, bc
    ld   [hl], e
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $0C
    call toc_05_79D1
    ld   a, [$FFEC]
    cp   $8B
    jp   nc, toc_05_7A6B

    ret


    db   $78, $00, $7A, $00, $7C, $00, $7E, $00
    db   $01, $FF, $08, $F8

JumpTable_58BF_05:
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    cpl
    rra
    rra
    and  %00100000
    ld   [$FFED], a
    ld   de, $58B3
    call toc_01_3C3B
    call toc_05_7965
    call toc_01_08E2
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    call toc_01_3BB4
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .else_05_5909

    ld   hl, $C290
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    ld   e, a
    ld   d, b
    ld   hl, $58BB
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    ld   hl, $58BD
    add  hl, de
    cp   [hl]
    jr   nz, .else_05_5909

    call JumpTable_3B8D_00
JumpTable_58BF_05.else_05_5909:
    call toc_05_79D1
    call toc_01_0891
    jr   nz, .return_05_5918

    ld   a, [$FFEE]
    cp   $A8
    jp   nc, toc_05_7A6B

JumpTable_58BF_05.return_05_5918:
    ret


    db   $07, $00, $0F, $07, $1E, $0F, $3F, $18
    db   $3F, $10, $3F, $14, $3F, $10, $27, $1B
    db   $E0, $00, $F0, $E0, $18, $F0, $8C, $78
    db   $8C, $70, $3F, $C0, $FF, $3E, $EF, $F1
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $03, $00, $07, $03
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $3F, $00, $FF, $3E, $EF, $F1

toc_05_5959:
    ld   hl, $C430
    add  hl, bc
    ld   a, [hl]
    and  %01111111
    ld   [hl], a
    ld   e, $0F
    ld   d, b
toc_05_5959.loop_05_5964:
    ld   hl, $C280
    add  hl, de
    ld   [hl], b
    dec  e
    ld   a, e
    cp   $01
    jr   nz, .loop_05_5964

    ifNot [$D478], .else_05_5998

    call_changebank $05
    call JumpTable_5A16_05.toc_05_5A3F
    ld   hl, $C290
    add  hl, de
    ld   [hl], $07
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $60
    assign [$FFA5], $01
    call JumpTable_3B8D_00
    ld   [hl], $04
    assign [$C210], $C0
    ret


toc_05_5959.else_05_5998:
    assign [$FFA5], $02
    ld   [$D478], a
    call toc_01_0891
    ld   [hl], $80
    ld   e, $0C
    xor  a
    ld   hl, $D790
toc_05_5959.loop_05_59AA:
    ldi  [hl], a
    dec  e
    jr   nz, .loop_05_59AA

    assign [$D205], $02
    assign [$D368], $5C
    ret


    db   $10, $F0, $21, $B0, $C2, $09, $7E, $C7

    dw JumpTable_59C9_05 ; 00
    dw JumpTable_5AAB_05 ; 01
    dw JumpTable_61A3_05 ; 02
    dw JumpTable_6215_05 ; 03

JumpTable_59C9_05:
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_59D7_05 ; 00
    dw JumpTable_5A16_05 ; 01
    dw JumpTable_5A76_05 ; 02
    dw JumpTable_5A7A_05 ; 03
    dw JumpTable_5A8A_05 ; 04

toc_05_59D6:
    ret


JumpTable_59D7_05:
    call toc_05_5A99
    ifNe [$FFEA], $05, toc_05_59D6

    ld   a, $02
JumpTable_59D7_05.loop_05_59E2:
    ld   [$FFE8], a
    ld   a, $63
    call toc_01_3C01
    push bc
    ld   a, [$FFE8]
    ld   c, a
    ld   hl, $59B8
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    sub  a, $10
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    pop  bc
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $02
    ld   a, [$FFE8]
    dec  a
    jr   nz, .loop_05_59E2

    call toc_01_0891
    ld   [hl], $43
    jp   JumpTable_3B8D_00

JumpTable_5A16_05:
    call toc_05_5A99
    call toc_05_7965
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    call toc_01_0891
    and  a
    jr   z, .else_05_5A3A

    cp   $20
    jr   nz, .return_05_5A75

    ld   a, [hLinkPositionY]
    push af
    assign [hLinkPositionY], 16
    ld   a, 186
    call toc_01_2197
    pop  af
    ld   [hLinkPositionY], a
    ret


JumpTable_5A16_05.else_05_5A3A:
    assign [$D368], $54
JumpTable_5A16_05.toc_05_5A3F:
    ld   a, $63
    call toc_01_3C01
    ld   hl, $C360
    add  hl, de
    ld   [hl], $0C
    ld   hl, $C200
    add  hl, de
    ld   [hl], $D0
    ld   hl, $C210
    add  hl, de
    ld   [hl], $18
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $01
    ld   hl, $C240
    add  hl, de
    ld   [hl], $E0
    ld   hl, $C380
    add  hl, de
    ld   [hl], $00
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $80
    call JumpTable_5B2E_05.toc_05_5B62
    call JumpTable_3B8D_00
    ret


JumpTable_5A16_05.return_05_5A75:
    ret


JumpTable_5A76_05:
    call toc_05_5A99
    ret


JumpTable_5A7A_05:
    call toc_05_5A99
    call toc_05_7965
    call toc_05_79D1
    ld   hl, $C250
    add  hl, bc
    inc  [hl]
    inc  [hl]
    ret


JumpTable_5A8A_05:
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $C2
    ret


    db   $7E, $00, $7E, $20, $7E, $40, $7E, $60

toc_05_5A99:
    ld   de, $5A91
    call toc_01_3C3B
    ret


    db   $02, $02, $02, $00, $01, $00, $01, $04
    db   $04, $04, $04

JumpTable_5AAB_05:
    call toc_05_613F
    ld   a, [$FFEA]
    cp   $05
    jp   nz, toc_05_7D8D

    call toc_05_7965
    call toc_01_08E2
    ifEq [$FFF0], $0E, .else_05_5AF7

    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_5AF7

    ld   hl, $C420
    add  hl, bc
    ld   [hl], $50
    call toc_01_3DAF
    call JumpTable_3B8D_00
    ld   [hl], $0E
    assign [$FFF4], $31
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $42
    ld   hl, $C2D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    cp   $08
    jr   nz, .else_05_5AEC

    dec  [hl]
JumpTable_5AAB_05.else_05_5AEC:
    ld   e, a
    ld   d, b
    ld   hl, $5AA0
    add  hl, de
    ld   a, [hl]
    ld   [$D205], a
    ret


JumpTable_5AAB_05.else_05_5AF7:
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_5B18_05 ; 00
    dw JumpTable_5B2E_05 ; 01
    dw JumpTable_5B74_05 ; 02
    dw JumpTable_5B9F_05 ; 03
    dw JumpTable_5BD0_05 ; 04
    dw JumpTable_5BF2_05 ; 05
    dw JumpTable_5C15_05 ; 06
    dw JumpTable_5C5B_05 ; 07
    dw JumpTable_5D33_05 ; 08
    dw JumpTable_5D84_05 ; 09
    dw JumpTable_5E82_05 ; 0A
    dw JumpTable_5EDB_05 ; 0B
    dw JumpTable_5EF1_05 ; 0C
    dw JumpTable_5F62_05 ; 0D
    dw JumpTable_5F73_05 ; 0E

JumpTable_5B18_05:
    call toc_05_79D1
    call toc_01_0891
    jr   nz, .return_05_5B2D

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $20
    ld   a, $FF
    call toc_01_3B87
JumpTable_5B18_05.return_05_5B2D:
    ret


JumpTable_5B2E_05:
    call toc_01_0891
    jr   nz, .return_05_5B66

    xor  a
    call toc_01_3B87
    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    add  a, $14
    ld   [hl], a
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    ld   [hl], a
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    xor  %00000100
    ld   [hl], a
    ld   hl, $C2C0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    cp   $02
    jr   z, .else_05_5B67

    call JumpTable_3B8D_00
    ld   [hl], b
    call toc_01_0891
    ld   [hl], $80
JumpTable_5B2E_05.toc_05_5B62:
    assign [$FFF4], $22
JumpTable_5B2E_05.return_05_5B66:
    ret


JumpTable_5B2E_05.else_05_5B67:
    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $30
    assign [$FFF4], $30
    ret


JumpTable_5B74_05:
    call toc_05_79D1
    call toc_01_0891
    cp   $01
    jr   nz, .else_05_5B83

    ld   hl, $FFF2
    ld   [hl], $30
JumpTable_5B74_05.else_05_5B83:
    and  a
    jr   nz, .return_05_5B9E

    ld   hl, $C240
    add  hl, bc
    inc  [hl]
    jr   nz, .else_05_5B9B

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $40
    incAddr $C29E
    inc  hl
    inc  [hl]
JumpTable_5B74_05.else_05_5B9B:
    call JumpTable_5B9F_05.else_05_5BBF
JumpTable_5B74_05.return_05_5B9E:
    ret


JumpTable_5B9F_05:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    call toc_01_0891
    jr   nz, .else_05_5BBF

    ld   [hl], $28
    assign [$C250], $D0
    assign [$FFF2], $24
    assign [$C240], $12
    incAddr $C290
    call JumpTable_3B8D_00
JumpTable_5B9F_05.else_05_5BBF:
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    and  %00000100
    ld   a, $01
    jr   z, .else_05_5BCC

    inc  a
JumpTable_5B9F_05.else_05_5BCC:
    call toc_01_3B87
    ret


JumpTable_5BD0_05:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    call toc_01_0891
    jr   nz, .else_05_5BEB

    assign [$FFA5], $01
    ld   [hl], $20
    call JumpTable_3B8D_00
    incAddr $C290
    assign [$C210], $C0
JumpTable_5BD0_05.else_05_5BEB:
    jp   JumpTable_5B9F_05.else_05_5BBF

    db   $01, $02, $03, $02

JumpTable_5BF2_05:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    call toc_01_0891
    jr   nz, .else_05_5BFE

    call JumpTable_3B8D_00
JumpTable_5BF2_05.else_05_5BFE:
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    rra
    rra
    rra
    nop
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $5BEE
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ret


JumpTable_5C15_05:
    call toc_05_79D1
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    cp   $D4
    jr   nz, .else_05_5C42

    ld   a, [$FFEE]
    and  %11111000
    cp   $C0
    jr   nz, .else_05_5C32

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $80
    ret


JumpTable_5C15_05.else_05_5C32:
    ld   a, [hFrameCounter]
    and  %00000000
    jr   nz, .else_05_5C3D

    ld   hl, $C250
    add  hl, bc
    dec  [hl]
JumpTable_5C15_05.else_05_5C3D:
    xor  a
    call toc_01_3B87
    ret


JumpTable_5C15_05.else_05_5C42:
    dec  [hl]
    dec  [hl]
    call JumpTable_5BF2_05.else_05_5BFE
    call JumpTable_5BF2_05.else_05_5BFE
    jp   JumpTable_5BF2_05.else_05_5BFE

    db   $F8, $A8, $30, $D0, $30, $70, $DC, $24
    db   $F8, $A8, $20, $E0, $04, $00

JumpTable_5C5B_05:
    call toc_01_0891
    jr   nz, JumpTable_5C6E_05.return_05_5CAF

    ld   a, [$D205]
    jumptable
    dw JumpTable_5C6E_05 ; 00
    dw JumpTable_5CB0_05 ; 01
    dw JumpTable_5CEA_05 ; 02
    dw JumpTable_5CEA_05 ; 03
    dw JumpTable_5CB0_05 ; 04

JumpTable_5C6E_05:
    call toc_01_27ED
    and  %00000011
    ld   [$D205], a
    ld   e, $00
    ifGte [hLinkPositionX], 80, .else_05_5C7F

    inc  e
JumpTable_5C6E_05.else_05_5C7F:
    ld   d, b
    ld   hl, $5C4D
    add  hl, de
    ld   a, [hl]
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    ld   hl, $5C4F
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $5C59
    add  hl, de
    ld   a, [hl]
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
    ld   hl, $C210
    add  hl, bc
    ld   [hl], $00
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $20
    call JumpTable_3B8D_00
    ld   [hl], $08
JumpTable_5C6E_05.return_05_5CAF:
    ret


JumpTable_5CB0_05:
    ld   e, $00
    ifGte [hLinkPositionX], 80, .else_05_5CB9

    inc  e
JumpTable_5CB0_05.else_05_5CB9:
    ld   d, b
    ld   hl, $5C51
    add  hl, de
    ld   a, [hl]
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    ld   hl, $C240
    add  hl, bc
    ld   [hl], b
    ld   hl, $5C59
    add  hl, de
    ld   a, [hl]
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
    ld   hl, $C210
    add  hl, bc
    ld   [hl], $F0
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $10
    call JumpTable_3B8D_00
    ld   [hl], $0B
    call toc_01_0891
    ld   [hl], $30
    ret


JumpTable_5CEA_05:
    call toc_01_27ED
    and  %00000001
    ld   e, a
    ld   d, b
    ld   hl, $5C55
    add  hl, de
    ld   a, [hl]
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    ld   hl, $5C57
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $C250
    add  hl, bc
    ld   [hl], b
    ld   hl, $5C59
    add  hl, de
    ld   a, [hl]
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
    call toc_01_27ED
    and  %00111111
    add  a, $18
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    ifNot [$FF9C], .else_05_5D28

    ld   a, [hLinkPositionY]
    ld   [hl], a
JumpTable_5CEA_05.else_05_5D28:
    call JumpTable_3B8D_00
    ld   [hl], $0D
    call toc_01_0891
    ld   [hl], $70
    ret


JumpTable_5D33_05:
    ld   a, $01
    call toc_01_3B87
    call toc_05_79D1
    ld   hl, $C250
    call .toc_05_5D48
    ld   a, [hl]
    and  a
    jr   z, .else_05_5D55

    ld   hl, $C240
JumpTable_5D33_05.toc_05_5D48:
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_05_5D54

    and  %10000000
    jr   nz, .else_05_5D53

    dec  [hl]
    dec  [hl]
JumpTable_5D33_05.else_05_5D53:
    inc  [hl]
JumpTable_5D33_05.return_05_5D54:
    ret


JumpTable_5D33_05.else_05_5D55:
    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $FF
    ret


    db   $EE, $12, $D0, $30, $10, $F0, $D8, $D4
    db   $D0, $CC, $C8, $C4, $C0, $BC, $28, $2C
    db   $30, $34, $38, $3C, $40, $44, $30, $2E
    db   $2C, $2A, $28, $26, $24, $22, $30, $2E
    db   $2C, $2A, $28, $26, $24, $22

JumpTable_5D84_05:
    call toc_01_0891
    jp   z, .toc_05_5E77

    ld   hl, $C210
    add  hl, bc
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .else_05_5D9D

    ld   a, [hFrameCounter]
    and  %00100000
    jr   z, .else_05_5D9C

    inc  [hl]
    inc  [hl]
JumpTable_5D84_05.else_05_5D9C:
    dec  [hl]
JumpTable_5D84_05.else_05_5D9D:
    call JumpTable_5BF2_05.else_05_5BFE
    call JumpTable_5BF2_05.else_05_5BFE
    ld   a, [$FF9C]
    and  a
    jr   nz, .else_05_5DD1

    ifNot [$C146], .else_05_5DD1

    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    rra
    rra
    and  %00000001
    ld   e, a
    ld   d, b
    ld   hl, $5D60
    add  hl, de
    ld   a, [hl]
    ld   hl, hLinkPositionXIncrement
    sub  a, [hl]
    and  a
    jr   z, .else_05_5DEA

    and  %10000000
    jr   nz, .else_05_5DCD

    inc  [hl]
    inc  [hl]
    inc  [hl]
    inc  [hl]
JumpTable_5D84_05.else_05_5DCD:
    dec  [hl]
    dec  [hl]
    jr   .else_05_5DEA

JumpTable_5D84_05.else_05_5DD1:
    ld   hl, $C380
    add  hl, bc
    ld   e, [hl]
    srl  e
    srl  e
    ld   d, b
    ld   hl, $5D5E
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    push bc
    call toc_01_20D6.toc_01_20E0
    call toc_01_3E49
    pop  bc
JumpTable_5D84_05.else_05_5DEA:
    ld   a, [$D210]
    inc  a
    cp   $22
    jr   c, .else_05_5DF7

    assign [$FFF4], $32
    xor  a
JumpTable_5D84_05.else_05_5DF7:
    ld   [$D210], a
    call toc_01_0891
    cp   $C0
    jr   nc, .return_05_5E76

    ld   a, [hFrameCounter]
    and  %00001111
    jr   nz, .return_05_5E76

    ld   a, $63
    ld   e, $03
    call toc_01_3C13
    jr   c, .return_05_5E76

    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $03
    push bc
    ld   hl, $C380
    add  hl, bc
    ld   c, [hl]
    srl  c
    srl  c
    ld   hl, $5D62
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    add  a, $0C
    ld   [hl], a
    ld   hl, $C3B0
    add  hl, de
    ld   a, c
    xor  %00000001
    ld   [hl], a
    ld   hl, $C380
    add  hl, de
    ld   [hl], a
    sla  c
    sla  c
    sla  c
    call toc_01_27ED
    and  %00000111
    add  a, c
    ld   c, a
    ld   hl, $5D74
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C250
    add  hl, de
    ld   [hl], a
    ld   hl, $5D64
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    pop  bc
    ld   hl, $C340
    add  hl, de
    ld   [hl], $02
    ld   hl, $C430
    add  hl, de
    ld   [hl], $00
    ld   hl, $C4D0
    add  hl, de
    ld   [hl], $02
JumpTable_5D84_05.return_05_5E76:
    ret


JumpTable_5D84_05.toc_05_5E77:
    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $50
    ret


    db   $E0, $20

JumpTable_5E82_05:
    call toc_05_79D1
    call toc_01_0891
    jr   z, .else_05_5EC0

    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    rra
    rra
    and  %00000001
    ld   e, a
    ld   d, b
    ld   hl, $5E80
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    sub  a, [hl]
    and  a
    jr   z, .else_05_5EB0

    and  %10000000
    jr   nz, .else_05_5EA8

    inc  [hl]
    inc  [hl]
JumpTable_5E82_05.else_05_5EA8:
    dec  [hl]
    call JumpTable_5BF2_05.else_05_5BFE
    call JumpTable_5BF2_05.else_05_5BFE
    ret


JumpTable_5E82_05.else_05_5EB0:
    xor  a
    call toc_01_3B87
    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .return_05_5EBF

    ld   hl, $C250
    add  hl, bc
    dec  [hl]
JumpTable_5E82_05.return_05_5EBF:
    ret


JumpTable_5E82_05.else_05_5EC0:
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $02
    call JumpTable_3B8D_00
    ld   [hl], $07
    call toc_01_0891
    ifNe [$D205], $04, .else_05_5ED8

    ld   [hl], $10
    ret


JumpTable_5E82_05.else_05_5ED8:
    ld   [hl], $80
    ret


JumpTable_5EDB_05:
    call toc_05_79D1
    call toc_01_0891
    jr   nz, .else_05_5EEB

    ld   [hl], $30
    call JumpTable_3B8D_00
    call toc_01_3DAF
JumpTable_5EDB_05.else_05_5EEB:
    call JumpTable_5BF2_05.else_05_5BFE
    ret


    db   $E0, $20

JumpTable_5EF1_05:
    call toc_05_79D1
    call toc_01_0891
    jr   nz, .else_05_5F33

    ld   a, [$FFEC]
    cp   $B0
    jp   nc, JumpTable_5E82_05.else_05_5EC0

    ld   a, $01
    call toc_01_3B87
    ld   a, [$C13E]
    and  a
    jr   nz, .return_05_5F32

    call toc_01_3BB4
    ifNot [$C13E], .return_05_5F32

    assign [$C13E], $10
    ld   hl, $C380
    add  hl, bc
    ld   e, [hl]
    srl  e
    srl  e
    ld   d, b
    ld   hl, $5EEF
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    assign [hLinkPositionYIncrement], 240
    ld   hl, hLinkPositionY
    dec  [hl]
JumpTable_5EF1_05.return_05_5F32:
    ret


JumpTable_5EF1_05.else_05_5F33:
    cp   $01
    jr   nz, .else_05_5F51

    ld   hl, $C380
    add  hl, bc
    ld   e, [hl]
    srl  e
    srl  e
    ld   d, b
    ld   hl, $5C53
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $34
JumpTable_5EF1_05.else_05_5F51:
    call JumpTable_5BF2_05.else_05_5BFE
    call toc_01_0891
    cp   $40
    jr   nc, .return_05_5F61

    call JumpTable_5BF2_05.else_05_5BFE
    call JumpTable_5BF2_05.else_05_5BFE
JumpTable_5EF1_05.return_05_5F61:
    ret


JumpTable_5F62_05:
    xor  a
    call toc_01_3B87
    call toc_05_79D1
    call toc_01_3BB4
    call toc_01_0891
    jp   z, JumpTable_5E82_05.else_05_5EC0

    ret


JumpTable_5F73_05:
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_5F8D

    cp   $30
    jr   nc, .return_05_5F8C

    dec  a
    jr   nz, .else_05_5F86

    assign [$FFF4], $31
JumpTable_5F73_05.else_05_5F86:
    call JumpTable_5BF2_05.else_05_5BFE
    call JumpTable_5BF2_05.else_05_5BFE
JumpTable_5F73_05.return_05_5F8C:
    ret


JumpTable_5F73_05.else_05_5F8D:
    call JumpTable_5BF2_05.else_05_5BFE
    call JumpTable_5BF2_05.else_05_5BFE
    call JumpTable_5BF2_05.else_05_5BFE
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    cp   $D0
    jr   z, .else_05_5FA0

    dec  [hl]
JumpTable_5F73_05.else_05_5FA0:
    call toc_05_79D1
    ld   a, [$FFEC]
    and  %11110000
    cp   $C0
    jr   nz, .return_05_5FAE

    jp   JumpTable_5E82_05.else_05_5EC0

JumpTable_5F73_05.return_05_5FAE:
    ret


    db   $00, $00, $40, $00, $00, $08, $42, $00
    db   $00, $10, $44, $00, $F8, $18, $46, $00
    db   $F8, $20, $48, $00, $F8, $28, $4A, $00
    db   $08, $18, $4C, $00, $08, $20, $4E, $00
    db   $08, $28, $50, $00, $00, $30, $52, $00
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $40, $00, $00, $08, $42, $00
    db   $00, $10, $5A, $00, $00, $18, $5C, $00
    db   $00, $20, $5E, $00, $10, $08, $60, $00
    db   $10, $10, $62, $00, $10, $18, $64, $00
    db   $10, $20, $66, $00, $F0, $18, $54, $00
    db   $F0, $20, $56, $00, $F0, $28, $58, $00
    db   $00, $00, $40, $00, $00, $08, $42, $00
    db   $00, $10, $5A, $00, $00, $18, $68, $00
    db   $00, $20, $6A, $00, $10, $08, $60, $00
    db   $10, $10, $62, $00, $10, $18, $64, $00
    db   $10, $20, $66, $00, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $40, $00, $00, $08, $42, $00
    db   $00, $10, $6C, $00, $00, $18, $6E, $00
    db   $00, $20, $70, $00, $10, $08, $60, $00
    db   $10, $10, $72, $00, $10, $18, $74, $00
    db   $10, $20, $76, $00, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $08, $40, $20, $00, $00, $42, $20
    db   $00, $F8, $44, $20, $F8, $F0, $46, $20
    db   $F8, $E8, $48, $20, $F8, $E0, $4A, $20
    db   $08, $F0, $4C, $20, $08, $E8, $4E, $20
    db   $08, $E0, $50, $20, $00, $D8, $52, $20
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $08, $40, $20, $00, $00, $42, $20
    db   $00, $F8, $5A, $20, $00, $F0, $5C, $20
    db   $00, $E8, $5E, $20, $10, $00, $60, $20
    db   $10, $F8, $62, $20, $10, $F0, $64, $20
    db   $10, $E8, $66, $20, $F0, $F0, $54, $20
    db   $F0, $E8, $56, $20, $F0, $E0, $58, $20
    db   $00, $08, $40, $20, $00, $00, $42, $20
    db   $00, $F8, $5A, $20, $00, $F0, $68, $20
    db   $00, $E8, $6A, $20, $10, $00, $60, $20
    db   $10, $F8, $62, $20, $10, $F0, $64, $20
    db   $10, $E8, $66, $20, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $08, $40, $20, $00, $00, $42, $20
    db   $00, $F8, $6C, $20, $00, $F0, $6E, $20
    db   $00, $E8, $70, $20, $10, $00, $60, $20
    db   $10, $F8, $72, $20, $10, $F0, $74, $20
    db   $10, $E8, $76, $20, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $1C, $1C, $08, $0C, $14, $10, $10, $10
    db   $F4, $1C, $08, $0C, $FC, $10, $10, $10

toc_05_613F:
    ld   hl, $C380
    add  hl, bc
    ld   a, [$FFF1]
    add  a, [hl]
    ld   hl, $5FAF
    cp   $04
    jr   c, .else_05_6152

    sub  a, $04
    ld   hl, $606F
toc_05_613F.else_05_6152:
    ld   e, a
    ld   d, b
    sla  e
    sla  e
    sla  e
    sla  e
    ld   a, e
    sla  e
    add  a, e
    ld   e, a
    add  hl, de
    ld   c, $0C
    call toc_01_3D26
    ld   a, $0A
    call toc_01_3DD0
    ld   e, $00
    ifNot [$FFF1], .else_05_6175

    ld   e, $04
toc_05_613F.else_05_6175:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_6181

    ld   a, e
    add  a, $08
    ld   e, a
toc_05_613F.else_05_6181:
    ld   d, b
    ld   hl, $612F
    add  hl, de
    push hl
    pop  de
    push bc
    sla  c
    sla  c
    ld   hl, $D580
    add  hl, bc
    ld   c, $04
toc_05_613F.loop_05_6193:
    ld   a, [de]
    inc  de
    ldi  [hl], a
    dec  c
    jr   nz, .loop_05_6193

    pop  bc
    ret


    db   $7C, $00, $7C, $20, $7C, $40, $7C, $60

JumpTable_61A3_05:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    ld   de, $619B
    call toc_01_3C3B
    call toc_05_7965
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_61C1_05 ; 00
    dw JumpTable_61E6_05 ; 01

JumpTable_61C1_05:
    ld   hl, $C210
    add  hl, bc
    ld   e, $07
    call .toc_05_61D0
    ld   hl, $C200
    add  hl, bc
    ld   e, $00
JumpTable_61C1_05.toc_05_61D0:
    ld   a, [hFrameCounter]
    add  a, e
    ld   d, a
    and  %00000011
    jr   nz, .return_05_61E5

    ld   a, d
    rra
    rra
    rra
    rra
    xor  c
    and  %00000001
    jr   z, .else_05_61E4

    inc  [hl]
    inc  [hl]
JumpTable_61C1_05.else_05_61E4:
    dec  [hl]
JumpTable_61C1_05.return_05_61E5:
    ret


JumpTable_61E6_05:
    call toc_05_79D1
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    cp   $C0
    jr   z, .else_05_61F3

    dec  [hl]
JumpTable_61E6_05.else_05_61F3:
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    cp   $F0
    jr   z, .else_05_61FD

    dec  [hl]
JumpTable_61E6_05.else_05_61FD:
    ld   a, [$FFEE]
    cp   $E0
    jp   nc, toc_05_7A6B

    ret


    db   $7A, $20, $78, $20, $78, $00, $7A, $00
    db   $7A, $60, $78, $60, $78, $40, $7A, $40

JumpTable_6215_05:
    ld   de, $6205
    call toc_01_3C3B
    call toc_05_7965
    call toc_05_79D1
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_6228_05 ; 00
    dw JumpTable_6228_05.JumpTable_6247_05 ; 01

JumpTable_6228_05:
    call toc_01_3BCA
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_6242

    call JumpTable_3B8D_00
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $E0
    ld   hl, $C3B0
    add  hl, bc
    inc  [hl]
    inc  [hl]
JumpTable_6228_05.else_05_6242:
    ld   hl, $C250
    add  hl, bc
    dec  [hl]
JumpTable_6228_05.JumpTable_6247_05:
    ld   a, [$FFEE]
    cp   $A8
    jp   nc, toc_05_7A6B

    ret


toc_05_624F:
    call toc_01_0891
    ld   [hl], $40
    ld   hl, $C3B0
    add  hl, bc
    ld   [hl], $FF
    ld   hl, $C360
    add  hl, bc
    ld   [hl], $FF
    ret


    db   $CD, $0E, $38, $CD, $12, $3F, $21, $B0
    db   $C2, $09, $7E, $A7, $28, $0D, $FE, $01
    db   $CA, $CF, $66, $FE, $02, $CA, $F2, $66
    db   $C3, $46, $67, $CD, $5A, $66, $F0, $EA
    db   $FE, $01, $20, $3F, $21, $C0, $C2, $09
    db   $7E, $C7

    dw JumpTable_628F_05 ; 00
    dw JumpTable_629A_05 ; 01

JumpTable_628F_05:
    call toc_01_0891
    ld   [hl], $FF
JumpTable_628F_05.toc_05_6294:
    ld   hl, $C2C0
    add  hl, bc
    inc  [hl]
    ret


JumpTable_629A_05:
    call toc_01_0891
    jp   z, .toc_05_62AD

    ld   hl, $C420
    add  hl, bc
    ld   [hl], a
    cp   $80
    jr   nc, .return_05_62AC

    call toc_05_7476
JumpTable_629A_05.return_05_62AC:
    ret


JumpTable_629A_05.toc_05_62AD:
    call toc_05_74AD
    ld   hl, $C200
    add  hl, de
    ld   a, [hLinkPositionX]
    ld   [hl], a
    ld   hl, $C210
    add  hl, de
    ld   [hl], $70
    ld   hl, $C310
    add  hl, de
    ld   [hl], $70
    ret


    db   $CD, $65, $79, $CD, $E2, $08, $F0, $F0
    db   $C7

    dw JumpTable_62F7_05 ; 00
    dw JumpTable_633C_05 ; 01
    dw JumpTable_63DF_05 ; 02
    dw JumpTable_6488_05 ; 03
    dw JumpTable_64CE_05 ; 04
    dw JumpTable_3828_00 ; 05

    db   $58, $68, $28, $38, $58, $68, $38, $30
    db   $30, $38, $50, $58, $58, $50, $10, $10
    db   $F0, $F0, $10, $10, $F0, $F0, $FD, $03
    db   $03, $FD, $03, $FD, $FD, $03

JumpTable_62F7_05:
    call toc_01_0891
    jr   nz, .return_05_633B

    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $62D7
    add  hl, de
    ld   a, [hl]
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    ld   hl, $62DF
    add  hl, de
    ld   a, [hl]
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    ld   hl, $62E7
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $62EF
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $18
    assign [$FFF3], $16
    call toc_05_652E
    call JumpTable_3B8D_00
JumpTable_62F7_05.return_05_633B:
    ret


JumpTable_633C_05:
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_6395

    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    cp   $0B
    jr   c, .else_05_6395

    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    cp   $05
    jr   nc, .return_05_6394

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $40
    ld   hl, $C240
    add  hl, bc
    ld   [hl], $18
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $18
    ld   hl, $C320
    add  hl, bc
    ld   [hl], b
    call toc_01_0887
    ld   [hl], $40
    ld   a, [$FFEE]
    add  a, $F8
    ld   [$FFD7], a
    call .toc_05_6383
    ld   a, [$FFEE]
    add  a, $08
    ld   [$FFD7], a
JumpTable_633C_05.toc_05_6383:
    ld   a, [$FFEC]
    sub  a, $10
    ld   [$FFD8], a
    ld   a, $02
    call toc_01_0953
    ld   hl, $C520
    add  hl, de
    ld   [hl], $0F
JumpTable_633C_05.return_05_6394:
    ret


JumpTable_633C_05.else_05_6395:
    call toc_05_79D1
    call toc_05_7A0A
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   z, .else_05_63C2

    ld   [hl], b
    call toc_01_0891
    ld   [hl], $40
    call JumpTable_3B8D_00
    ld   [hl], b
    call toc_05_6566
    call toc_05_652E
    assign [$FFF2], $32
    ld   a, $FF
    jp   toc_01_3B87

JumpTable_633C_05.else_05_63C2:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    cp   $05
    jp   nc, JumpTable_6488_05.else_05_64C1

    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_05_63DE

    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    jp   toc_01_3B87

JumpTable_633C_05.return_05_63DE:
    ret


JumpTable_63DF_05:
    ld   a, $02
    call toc_01_3B87
    call toc_01_0891
    jr   z, .else_05_6400

    and  %00000010
    ld   e, $08
    jr   z, .else_05_63F1

    ld   e, $F8
JumpTable_63DF_05.else_05_63F1:
    ld   hl, $C240
    add  hl, bc
    push hl
    ld   a, [hl]
    push af
    ld   [hl], e
    call toc_05_79DE
    pop  af
    pop  hl
    ld   [hl], a
    ret


JumpTable_63DF_05.else_05_6400:
    call toc_01_3BB4
    call toc_01_0887
    jr   nz, .else_05_641D

    ifGte [$FFEE], $70, .else_05_641D

    ifGte [$FFEC], $50, .else_05_641D

    call toc_01_3DAF
    call JumpTable_3B8D_00
    ld   [hl], $01
    ret


JumpTable_63DF_05.else_05_641D:
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    cp   $08
    jr   nz, .else_05_6448

    ifGte [$FFEE], $70, .else_05_6448

    ifGte [$FFEC], $50, .else_05_6448

    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    cp   $05
    jr   c, .else_05_6448

    call JumpTable_3B8D_00
    call toc_01_3DAF
    call toc_01_0891
    ld   [hl], $80
    ret


JumpTable_63DF_05.else_05_6448:
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    cp   $0B
    jr   nc, .return_05_6487

    call toc_05_79D1
    call toc_01_3B9E
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    push af
    and  %00000011
    jr   z, .else_05_6467

    ld   hl, $C240
    call .toc_05_646F
JumpTable_63DF_05.else_05_6467:
    pop  af
    and  %00001100
    jr   z, .else_05_6474

    ld   hl, $C250
JumpTable_63DF_05.toc_05_646F:
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    ld   [hl], a
JumpTable_63DF_05.else_05_6474:
    ld   a, [hFrameCounter]
    and  %00000111
    jr   nz, .return_05_6487

    copyFromTo [$FFEE], [$FFD7]
    copyFromTo [$FFEC], [$FFD8]
    ld   a, $0A
    call toc_01_0953
JumpTable_63DF_05.return_05_6487:
    ret


JumpTable_6488_05:
    call toc_01_0891
    cp   $40
    jr   c, .else_05_64AF

    jr   nz, .else_05_6498

    assign [$FFF4], $29
    call toc_05_64D4
JumpTable_6488_05.else_05_6498:
    and  %00000010
    ld   e, $10
    jr   z, .else_05_64A0

    ld   e, $F0
JumpTable_6488_05.else_05_64A0:
    ld   hl, $C240
    add  hl, bc
    push hl
    ld   a, [hl]
    push af
    ld   [hl], e
    call toc_05_79DE
    pop  af
    pop  hl
    ld   [hl], a
    ret


JumpTable_6488_05.else_05_64AF:
    and  a
    jr   nz, .else_05_64C1

    call JumpTable_3B8D_00
    ld   [hl], $01
    call toc_01_3DAF
    ld   hl, $C360
    add  hl, bc
    ld   [hl], $08
    ret


JumpTable_6488_05.else_05_64C1:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    add  a, 3
    call toc_01_3B87
    ret


JumpTable_64CE_05:
    ret


    db   $C9, $F8, $08, $F8, $08

toc_05_64D4:
    ld   a, $02
toc_05_64D4.loop_05_64D6:
    ld   [$FFE8], a
    ld   a, $62
    call toc_01_3C01
    jr   c, .else_05_6528

    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $03
    push bc
    ld   a, [$FFE8]
    ld   c, a
    ld   hl, $64CF
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   a, [$FFDA]
    ld   hl, $C310
    add  hl, de
    ld   [hl], a
    ld   hl, $C3B0
    add  hl, de
    ld   a, [$FFE8]
    dec  a
    ld   [hl], a
    ld   hl, $64D1
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $C250
    add  hl, de
    ld   [hl], $04
    pop  bc
    ld   hl, $C320
    add  hl, de
    ld   [hl], $08
    ld   hl, $C340
    add  hl, de
    ld   [hl], $42
toc_05_64D4.else_05_6528:
    ld   a, [$FFE8]
    dec  a
    jr   nz, .loop_05_64D6

    ret


toc_05_652E:
    ld   a, $62
    call toc_01_3C01
    jr   c, .return_05_6555

    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $01
    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $14
    ld   hl, $C340
    add  hl, de
    ld   [hl], $C4
toc_05_652E.return_05_6555:
    ret


    db   $F8, $08, $F8, $08, $FC, $FC, $04, $04
    db   $F4, $0C, $F4, $0C, $F4, $F4, $0C, $0C

toc_05_6566:
    ld   a, $04
toc_05_6566.loop_05_6568:
    ld   [$FFE8], a
    ld   a, $62
    call toc_01_3C01
    jr   c, .else_05_65B4

    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $02
    push bc
    ld   a, [$FFE8]
    ld   c, a
    ld   hl, $6555
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $6559
    add  hl, bc
    ld   a, [$FFD8]
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $655D
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $6561
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C250
    add  hl, de
    ld   [hl], a
    pop  bc
    ld   hl, $C320
    add  hl, de
    ld   [hl], $13
    ld   hl, $C340
    add  hl, de
    ld   [hl], $42
toc_05_6566.else_05_65B4:
    ld   a, [$FFE8]
    dec  a
    jr   nz, .loop_05_6568

    ret


    db   $F0, $F8, $60, $00, $F0, $00, $62, $00
    db   $F0, $08, $64, $00, $F0, $10, $66, $00
    db   $00, $F8, $68, $00, $00, $00, $6A, $00
    db   $00, $08, $6A, $20, $00, $10, $68, $20
    db   $F0, $F8, $66, $20, $F0, $00, $64, $20
    db   $F0, $08, $62, $20, $F0, $10, $60, $20
    db   $00, $F8, $68, $00, $00, $00, $6A, $00
    db   $00, $08, $6A, $20, $00, $10, $68, $20
    db   $00, $F8, $6C, $00, $00, $00, $6E, $00
    db   $00, $08, $6E, $20, $00, $10, $6C, $20
    db   $00, $FC, $7C, $00, $00, $04, $7E, $00
    db   $00, $0C, $7C, $20, $00, $00, $FF, $00
    db   $00, $FC, $7C, $00, $00, $04, $7E, $20
    db   $00, $0C, $7C, $20, $00, $00, $FF, $00
    db   $00, $F8, $74, $00, $00, $00, $76, $00
    db   $00, $08, $76, $20, $00, $10, $74, $20
    db   $00, $F8, $70, $00, $00, $00, $72, $00
    db   $00, $08, $72, $20, $00, $10, $70, $20
    db   $0A, $FB, $26, $00, $0A, $01, $26, $00
    db   $0A, $06, $26, $00, $0A, $0C, $26, $00
    db   $F0, $F1, $FE, $02, $30, $4C, $21, $40
    db   $C3, $09, $7E, $E6, $F0, $F6, $08, $77
    db   $F0, $F1, $17, $17, $17, $17, $17, $E6
    db   $E0, $5F, $50, $21, $BA, $65, $19, $0E
    db   $08, $CD, $26, $3D, $00, $F0, $F1, $FE
    db   $05, $30, $26, $21, $10, $C3, $09, $7E
    db   $3D, $FE, $08, $38, $1C, $21, $40, $C3
    db   $09, $7E, $E6, $F0, $F6, $04, $77, $F0
    db   $EF, $E0, $EC, $AF, $E0, $F1, $21, $4A
    db   $66, $0E, $04, $CD, $26, $3D, $CD, $BA
    db   $3D, $C9, $21, $40, $C3, $09, $7E, $E6
    db   $F0, $F6, $04, $77, $F0, $F1, $3D, $3D
    db   $17, $17, $17, $17, $E6, $F0, $5F, $50
    db   $21, $FA, $65, $19, $0E, $04, $CD, $26
    db   $3D, $CD, $7F, $66, $C9, $CD, $91, $08
    db   $CA, $6B, $7A, $FE, $0A, $3E, $05, $38
    db   $01, $3C, $E0, $F1, $CD, $AC, $66, $C9
    db   $1E, $00, $1E, $60, $1E, $40, $1E, $20
    db   $7A, $00, $7A, $20, $78, $00, $78, $20
    db   $11, $E2, $66, $CD, $3B, $3C, $CD, $65
    db   $79, $CD, $BF, $3B, $F0, $F0, $C7

    dw JumpTable_6705_05 ; 00
    dw JumpTable_672D_05 ; 01

JumpTable_6705_05:
    call toc_05_79D1
    call toc_05_7A0A
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   z, .else_05_6722

    ld   [hl], b
    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $0F
JumpTable_6705_05.else_05_6722:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


JumpTable_672D_05:
    call toc_01_0891
    jp   z, toc_05_7A6B

    rra
    rra
    rra
    and  %00000001
    inc  a
    inc  a
    call toc_01_3B87
    ret


    db   $6C, $00, $6E, $00, $6E, $20, $6C, $20
    db   $11, $3E, $67, $CD, $3B, $3C, $CD, $65
    db   $79, $CD, $D1, $79, $CD, $0A, $7A, $21
    db   $20, $C3, $09, $35, $21, $10, $C3, $09
    db   $7E, $E6, $80, $28, $12, $AF, $77, $CD
    db   $91, $08, $36, $0F, $21, $B0, $C2, $09
    db   $36, $02, $3E, $FF, $CD, $87, $3B, $C9

toc_05_6776:
    ld   hl, $C460
    add  hl, bc
    ld   e, [hl]
    sla  e
    sla  e
    sla  e
    sla  e
    sla  e
    sla  e
    ld   d, b
    ld   hl, $D000
    add  hl, de
    push de
    ld   e, $20
toc_05_6776.loop_05_678F:
    xor  a
    ldi  [hl], a
    dec  e
    ld   a, e
    cp   $00
    jr   nz, .loop_05_678F

    pop  de
    ld   hl, $D100
    add  hl, de
    ld   e, $20
toc_05_6776.loop_05_679E:
    xor  a
    ldi  [hl], a
    dec  e
    ld   a, e
    cp   $00
    jr   nz, .loop_05_679E

    ld   hl, $C250
    add  hl, bc
    ld   [hl], $06
    call toc_01_0891
    ld   [hl], $40
    call toc_01_088C
    ld   [hl], $40
    ld   hl, $C3B0
    add  hl, bc
    ld   [hl], $03
    ret


    db   $06, $FA, $00, $00, $00, $00, $FA, $06
    db   $02, $01, $00, $01, $21, $22, $23, $22
    db   $F0, $F7, $FE, $07, $20, $04, $3E, $10
    db   $E0, $F5, $CD, $9A, $69, $CD, $65, $79
    db   $CD, $12, $3F, $CD, $E2, $08, $CD, $B4
    db   $3B, $F0, $F0, $C7

    dw JumpTable_67EF_05 ; 00
    dw JumpTable_68B5_05 ; 01
    dw JumpTable_690F_05 ; 02

JumpTable_67EF_05:
    call toc_01_0891
    jr   nz, .else_05_67F9

    ld   [hl], $00
    call JumpTable_3B8D_00
JumpTable_67EF_05.else_05_67F9:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    inc  a
    and  %00111111
    ld   [hl], a
    ld   [$FFD7], a
    rra
    rra
    nop
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $67C5
    add  hl, de
    ld   a, [hl]
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    ld   hl, $67C9
    add  hl, de
    ld   a, [hl]
    ld   hl, $C2C0
    add  hl, bc
    ld   [hl], a
    ld   hl, $C460
    add  hl, bc
    ld   e, [hl]
    sla  e
    sla  e
    sla  e
    sla  e
    sla  e
    sla  e
    ld   d, $00
    push de
    ld   hl, $D000
    add  hl, de
    ld   a, [$FFD7]
    ld   e, a
    add  hl, de
    ld   a, [$FFEE]
    ld   [hl], a
    pop  de
    ld   hl, $D100
    add  hl, de
    ld   a, [$FFD7]
    ld   e, a
    add  hl, de
    ld   a, [$FFEC]
    ld   [hl], a
    call toc_05_79D1
    call toc_01_3B9E
    ld   e, $0F
    ld   d, b
JumpTable_67EF_05.loop_05_6854:
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    cp   $05
    jr   nz, .else_05_68B1

    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $02
    jr   nz, .else_05_68B1

    ld   hl, $C2E0
    add  hl, de
    ld   a, [hl]
    cp   $38
    jr   c, .else_05_68B1

    ld   hl, $C200
    add  hl, de
    ld   a, [$FFEE]
    sub  a, [hl]
    add  a, $06
    cp   $0C
    jr   nc, .else_05_68B1

    ld   hl, $C210
    add  hl, de
    ld   a, [$FFEC]
    sub  a, [hl]
    add  a, $06
    cp   $0C
    jr   nc, .else_05_68B1

    ld   hl, $C310
    add  hl, de
    ld   a, [hl]
    and  a
    jr   nz, .else_05_68B1

    ld   hl, $C280
    add  hl, de
    ld   [hl], b
    call JumpTable_3B8D_00
    ld   [hl], $02
    ld   hl, $C300
    add  hl, bc
    ld   [hl], $60
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $0C
    ld   hl, $C440
    add  hl, bc
    inc  [hl]
    assign [$FFF2], $2A
    ret


JumpTable_67EF_05.else_05_68B1:
    dec  e
    jr   nz, .loop_05_6854

    ret


JumpTable_68B5_05:
    call toc_01_0891
    jr   nz, .return_05_68FE

    call toc_01_27ED
    and  %00011111
    add  a, $40
    ld   [hl], a
    call JumpTable_3B8D_00
    ld   [hl], b
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    inc  a
    and  %00000011
    ld   [hl], a
    jr   nz, .else_05_68D6

    call toc_05_7A44
    jr   .toc_05_68DC

JumpTable_68B5_05.else_05_68D6:
    call toc_01_27ED
    and  %00000011
    ld   e, a
JumpTable_68B5_05.toc_05_68DC:
    ld   hl, $FFF1
    xor  [hl]
    and  %00000010
    jr   z, .else_05_68D6

    ld   d, b
    ld   hl, $C3B0
    add  hl, bc
    ld   [hl], e
    ld   hl, $67BD
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $67C1
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
JumpTable_68B5_05.return_05_68FE:
    ret


    db   $F3, $0D, $00, $00, $00, $00, $0D, $F3
    db   $0C, $F4, $00, $00, $00, $00, $F4, $0C

JumpTable_690F_05:
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_05_6922

    call toc_01_0891
    ld   [hl], $30
    call JumpTable_3B8D_00
    ld   [hl], $01
    ret


JumpTable_690F_05.else_05_6922:
    cp   $24
    jr   nz, .else_05_6929

    call toc_01_08D7
JumpTable_690F_05.else_05_6929:
    cp   $04
    jr   nz, .else_05_6949

    ld   a, [$FFF1]
    ld   e, a
    ld   d, b
    ld   hl, $6907
    add  hl, de
    ld   a, [$FFEE]
    add  a, [hl]
    ld   [$FFD7], a
    ld   hl, $690B
    add  hl, de
    ld   a, [$FFEC]
    add  a, [hl]
    ld   [$FFD8], a
    ld   a, $02
    call toc_01_0953
    xor  a
JumpTable_690F_05.else_05_6949:
    cp   $20
    jr   nz, .return_05_6985

    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    cp   $03
    jr   nz, .return_05_6985

    ld   a, $02
    call toc_01_3C01
    jr   c, .return_05_6985

    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $17
    push bc
    ld   hl, $C3B0
    add  hl, bc
    ld   c, [hl]
    ld   hl, $68FF
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $6903
    add  hl, bc
    ld   a, [$FFD8]
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    pop  bc
    call JumpTable_7DBB_05.toc_05_7DC0
JumpTable_690F_05.return_05_6985:
    ret


    db   $66, $20, $64, $20, $64, $00, $66, $00
    db   $62, $00, $62, $20, $60, $00, $60, $20
    db   $68, $00, $68, $20, $CD, $8C, $08, $21
    db   $24, $C1, $B6, $21, $00, $C3, $09, $B6
    db   $C2, $DA, $6B, $F0, $F1, $FE, $02, $20
    db   $09, $CD, $08, $6A, $CD, $C1, $69, $C3
    db   $BA, $3D, $CD, $C1, $69, $CD, $08, $6A
    db   $C3, $BA, $3D, $21, $D0, $C3, $09, $7E
    db   $E0, $D7, $C5, $21, $60, $C4, $09, $5E
    db   $21, $B0, $C2, $09, $4E, $CB, $23, $CB
    db   $23, $CB, $23, $CB, $23, $CB, $23, $CB
    db   $23, $50, $D5, $21, $00, $D0, $19, $F0
    db   $D7, $91, $E6, $3F, $5F, $50, $19, $7E
    db   $E0, $EE, $D1, $21, $00, $D1, $19, $F0
    db   $D7, $91, $E6, $3F, $5F, $50, $19, $7E
    db   $E0, $EC, $C1, $11, $86, $69, $CD, $3B
    db   $3C, $C9, $21, $D0, $C3, $09, $7E, $E0
    db   $D7, $C5, $21, $60, $C4, $09, $5E, $21
    db   $C0, $C2, $09, $4E, $CB, $23, $CB, $23
    db   $CB, $23, $CB, $23, $CB, $23, $CB, $23
    db   $50, $D5, $21, $00, $D0, $19, $F0, $D7
    db   $91, $E6, $3F, $5F, $50, $19, $7E, $E0
    db   $EE, $D1, $21, $00, $D1, $19, $F0, $D7
    db   $91, $E6, $3F, $5F, $50, $19, $7E, $E0
    db   $EC, $C1, $3E, $04, $E0, $F1, $11, $86
    db   $69, $CD, $3B, $3C, $21, $B0, $C3, $09
    db   $7E, $E0, $F1, $C9, $00, $00, $66, $20
    db   $00, $08, $64, $20, $00, $F3, $68, $00
    db   $00, $FB, $68, $20, $00, $00, $64, $00
    db   $00, $08, $66, $00, $00, $0D, $68, $00
    db   $00, $15, $68, $20, $00, $00, $62, $00
    db   $00, $08, $62, $20, $0D, $00, $68, $00
    db   $0D, $08, $68, $20, $00, $00, $60, $00
    db   $00, $08, $60, $20, $F3, $00, $68, $00
    db   $F3, $08, $68, $20, $00, $04, $66, $20
    db   $00, $0C, $64, $20, $F8, $EC, $6C, $00
    db   $F8, $F4, $6A, $00, $F8, $FC, $6A, $20
    db   $F8, $04, $6C, $20, $08, $EC, $6C, $40
    db   $08, $F4, $6E, $40, $08, $FC, $6E, $60
    db   $08, $04, $6C, $60, $00, $FC, $64, $00
    db   $00, $04, $66, $00, $F8, $04, $6C, $00
    db   $F8, $0C, $6A, $00, $F8, $14, $6A, $20
    db   $F8, $1C, $6C, $20, $08, $04, $6C, $40
    db   $08, $0C, $6E, $40, $08, $14, $6E, $60
    db   $08, $1C, $6C, $60, $04, $F8, $6C, $00
    db   $04, $00, $6A, $00, $04, $08, $6A, $20
    db   $04, $10, $6C, $20, $14, $F8, $6C, $40
    db   $14, $00, $6E, $40, $14, $08, $6E, $60
    db   $14, $10, $6C, $60, $FC, $00, $62, $00
    db   $FC, $08, $62, $20, $04, $00, $60, $00
    db   $04, $08, $60, $20, $EC, $F8, $6C, $00
    db   $EC, $00, $6A, $00, $EC, $08, $6A, $20
    db   $EC, $10, $6C, $20, $FC, $F8, $6C, $40
    db   $FC, $00, $6E, $40, $FC, $08, $6E, $60
    db   $FC, $10, $6C, $60, $00, $02, $66, $20
    db   $00, $0A, $64, $20, $FB, $EF, $6C, $00
    db   $FB, $F7, $6E, $00, $FB, $F9, $6E, $20
    db   $FB, $01, $6C, $20, $05, $EF, $6C, $40
    db   $05, $F7, $6E, $40, $05, $F9, $6E, $60
    db   $05, $01, $6C, $60, $00, $FE, $64, $00
    db   $00, $02, $66, $00, $FB, $07, $6C, $00
    db   $FB, $0F, $6E, $00, $FB, $11, $6E, $20
    db   $FB, $19, $6C, $20, $05, $07, $6C, $40
    db   $05, $0F, $6E, $40, $05, $11, $6E, $60
    db   $05, $19, $6C, $60, $07, $FB, $6C, $00
    db   $07, $03, $6E, $00, $07, $05, $6E, $20
    db   $07, $0D, $6C, $20, $11, $FB, $6C, $40
    db   $11, $03, $6E, $40, $11, $05, $6E, $60
    db   $11, $0D, $6C, $60, $FE, $00, $62, $00
    db   $FE, $08, $62, $20, $02, $00, $60, $00
    db   $02, $08, $60, $20, $EF, $FB, $6C, $00
    db   $EF, $03, $6E, $00, $EF, $05, $6E, $20
    db   $EF, $0D, $6C, $20, $F9, $FB, $6C, $40
    db   $F9, $03, $6E, $40, $F9, $05, $6E, $60
    db   $F9, $0D, $6C, $60, $21, $00, $C3, $09
    db   $7E, $FE, $08, $38, $2F, $FE, $28, $30
    db   $2B, $21, $3A, $6B, $FE, $0E, $38, $07
    db   $FE, $22, $30, $03, $21, $9A, $6A, $F0
    db   $F1, $5F, $50, $CB, $23, $CB, $23, $CB
    db   $23, $7B, $CB, $23, $CB, $23, $83, $5F
    db   $19, $0E, $0A, $CD, $26, $3D, $3E, $08
    db   $CD, $D0, $3D, $C9, $F0, $F1, $17, $17
    db   $17, $17, $E6, $F0, $5F, $50, $21, $5A
    db   $6A, $19, $0E, $04, $CD, $26, $3D, $3E
    db   $02, $CD, $D0, $3D, $C9

toc_05_6C2B:
    call toc_01_0891
    ld   [hl], $80
    clear [$D200]
    ld   [$D203], a
    ld   [$D204], a
    ld   hl, $C390
    add  hl, bc
    ld   [hl], $01
    ret


    db   $CD, $0E, $38, $CD, $12, $3F, $CD, $E2
    db   $08, $21, $B0, $C2, $09, $7E, $C7

    dw JumpTable_6C56_05 ; 00
    dw JumpTable_7207_05 ; 01
    dw JumpTable_74F9_05 ; 02

JumpTable_6C56_05:
    ld   a, c
    ld   [$D201], a
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_6C65_05 ; 00
    dw JumpTable_6CA9_05 ; 01
    dw JumpTable_6D95_05 ; 02
    dw JumpTable_700B_05 ; 03

JumpTable_6C65_05:
    call toc_01_0891
    jr   nz, .return_05_6C80

    ld   [hl], $80
    assign [$C157], $FF
    assign [$FFF4], $3E
    ld   [$D3E8], a
    assign [$C158], $04
    call JumpTable_3B8D_00
JumpTable_6C65_05.return_05_6C80:
    ret


    db   $20, $60, $20, $60, $00, $00, $70, $70
    db   $08, $08, $08, $08, $09, $0B, $0B, $0A
    db   $08, $08, $08, $08, $09, $0B, $0B, $0A
    db   $05, $07, $07, $06, $04, $04, $04, $04
    db   $05, $07, $07, $06, $04, $04, $04, $04

JumpTable_6CA9_05:
    assign [hSwordIntersectedAreaX], $38
    add  a, $10
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    assign [hSwordIntersectedAreaY], $30
    add  a, $18
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    call toc_01_0891
    jp   nz, .toc_05_6D48

    ld   [hl], $FF
    clear [$D3E8]
    call JumpTable_3B8D_00
    assign [$D745], $AF
    assign [$D746], $AF
    assign [$D755], $B0
    assign [$D756], $B0
    call toc_01_088C
    ld   [hl], $1F
    call toc_01_0887
    ld   [hl], $B0
    call toc_01_3E64
    ld   hl, $C280
    add  hl, bc
    ld   [hl], $05
    ld   hl, $C200
    add  hl, bc
    ld   a, [hl]
    add  a, $10
    ld   [hl], a
    call toc_01_3E64
    ld   hl, $C280
    add  hl, bc
    ld   [hl], $05
    call toc_01_3E64
    call toc_01_08D7
    ld   hl, $C280
    add  hl, bc
    ld   [hl], $05
    call toc_01_2839
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    ld   hl, $D601
    add  hl, de
    add  a, $1C
    ld   [$D600], a
    call .toc_05_6D2D
    call .toc_05_6D2D
    call .toc_05_6D2D
JumpTable_6CA9_05.toc_05_6D2D:
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    inc  a
    ld   [$FFD0], a
    ldi  [hl], a
    ld   a, $83
    ldi  [hl], a
    ld   a, $76
    ldi  [hl], a
    ld   a, $7E
    ldi  [hl], a
    ld   a, $7E
    ldi  [hl], a
    ld   a, $77
    ldi  [hl], a
    xor  a
    ld   [hl], a
    ret


JumpTable_6CA9_05.toc_05_6D48:
    cp   $40
    jp   nz, .return_05_6D94

    call toc_01_2839
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    ld   hl, $D601
    add  hl, de
    add  a, $1C
    ld   [$D600], a
    call .toc_05_6D62
JumpTable_6CA9_05.toc_05_6D62:
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    inc  a
    ld   [$FFD0], a
    ldi  [hl], a
    ld   a, $83
    ldi  [hl], a
    ld   a, $1C
    ldi  [hl], a
    ld   a, $1E
    ldi  [hl], a
    ld   a, $1C
    ldi  [hl], a
    ld   a, $1E
    ldi  [hl], a
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    inc  a
    ld   [$FFD0], a
    ldi  [hl], a
    ld   a, $83
    ldi  [hl], a
    ld   a, $1D
    ldi  [hl], a
    ld   a, $1F
    ldi  [hl], a
    ld   a, $1D
    ldi  [hl], a
    ld   a, $1F
    ldi  [hl], a
    xor  a
    ld   [hl], a
JumpTable_6CA9_05.return_05_6D94:
    ret


JumpTable_6D95_05:
    ld   hl, $C200
    add  hl, bc
    ld   a, [hl]
    push af
    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    push af
    call JumpTable_700B_05
    pop  af
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    pop  af
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    call toc_01_3DBA
    call toc_01_0891
    jr   nz, .else_05_6DBC

    call JumpTable_3B8D_00
    ret


JumpTable_6D95_05.else_05_6DBC:
    cp   $98
    jr   z, .else_05_6DCD

    cp   $68
    jr   z, .else_05_6DCD

    cp   $38
    jr   z, .else_05_6DCD

    cp   $08
    jp   nz, .return_05_6EA8

JumpTable_6D95_05.else_05_6DCD:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    cp   $04
    jp   z, .return_05_6EA8

    inc  [hl]
    ld   e, a
    ld   d, b
    ld   hl, $6C81
    add  hl, de
    ld   a, [hl]
    ld   [hSwordIntersectedAreaX], a
    ld   hl, $6C85
    add  hl, de
    ld   a, [hl]
    ld   [hSwordIntersectedAreaY], a
    sla  e
    sla  e
    sla  e
    ld   hl, $6C89
    add  hl, de
    push hl
    call toc_01_2839
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    ld   hl, $D601
    add  hl, de
    add  a, $0E
    ld   [$D600], a
    pop  de
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    ldi  [hl], a
    ld   a, $03
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    add  a, $20
    ldi  [hl], a
    ld   a, $03
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    ldi  [hl], a
    xor  a
    ld   [hl], a
    assign [$D713], $D5
    ld   [$D717], a
    assign [$D714], $D6
    ld   [$D718], a
    assign [$D783], $D7
    ld   [$D787], a
    assign [$D784], $D8
    ld   [$D788], a
    ld   a, $5D
    call toc_01_3C01
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $01
    ld   hl, $C200
    add  hl, de
    ld   a, [hSwordIntersectedAreaX]
    add  a, $10
    ld   [hl], a
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    ld   hl, $C210
    add  hl, de
    ld   a, [hSwordIntersectedAreaY]
    add  a, $10
    ld   [hl], a
    ld   hl, $C210
    add  hl, bc
    add  a, $08
    ld   [hl], a
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $2F
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    cp   $03
    ld   a, $00
    jr   c, .else_05_6E97

    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    sub  a, $08
    ld   [hl], a
    ld   a, $01
JumpTable_6D95_05.else_05_6E97:
    ld   hl, $C380
    add  hl, de
    ld   [hl], a
    call toc_01_3E64
    ld   hl, $C280
    add  hl, bc
    ld   [hl], $05
    call toc_01_08D7
JumpTable_6D95_05.return_05_6EA8:
    ret


    db   $D0, $D1, $D4, $D9, $DF, $E6, $EE, $F7
    db   $00, $09, $12, $1A, $21, $27, $2C, $2F
    db   $30, $2F, $2C, $27, $21, $1A, $12, $09
    db   $00, $F7, $EE, $E6, $DF, $D9, $D4, $D1
    db   $D0, $D1, $D4, $D9, $DF, $E6, $EE, $F7
    db   $DA, $DB, $DD, $E1, $E6, $EB, $F2, $F9
    db   $00, $07, $0E, $15, $1A, $1F, $23, $25
    db   $26, $25, $23, $1F, $1A, $15, $0E, $07
    db   $00, $F9, $F2, $EB, $E6, $E1, $DD, $DB
    db   $DA, $DB, $DD, $E1, $E6, $EB, $F2, $F9
    db   $E4, $E5, $E7, $E9, $ED, $F1, $F6, $FB
    db   $00, $05, $0A, $0F, $13, $17, $19, $1B
    db   $1C, $1B, $19, $17, $13, $0F, $0A, $05
    db   $00, $FB, $F6, $F1, $ED, $E9, $E7, $E5
    db   $E4, $E5, $E7, $E9, $ED, $F1, $F6, $FB
    db   $EE, $EF, $F0, $F2, $F4, $F6, $FA, $FD
    db   $00, $03, $06, $0A, $0C, $0E, $10, $11
    db   $12, $11, $10, $0E, $0C, $0A, $06, $03
    db   $00, $FD, $FA, $F6, $F4, $F2, $F0, $EF
    db   $EE, $EF, $F0, $F2, $F4, $F6, $FA, $FD
    db   $F8, $F9, $FA, $FB, $FB, $FC, $FD, $FF
    db   $00, $01, $03, $04, $05, $05, $06, $07
    db   $08, $07, $06, $05, $05, $04, $03, $01
    db   $00, $FF, $FD, $FC, $FB, $FB, $FA, $F9
    db   $F8, $F9, $FA, $FB, $FB, $FC, $FD, $FF
    db   $00, $00, $01, $02, $03, $04, $04, $04
    db   $04, $04, $04, $03, $02, $01, $00, $00
    db   $00, $00, $FF, $FE, $FD, $FC, $FC, $FC
    db   $FC, $FC, $FC, $FD, $FE, $FF, $00, $00
    db   $00, $00, $01, $01, $02, $02, $03, $03
    db   $03, $03, $03, $02, $02, $01, $01, $00
    db   $00, $00, $FF, $FF, $FE, $FE, $FD, $FD
    db   $FD, $FD, $FD, $FE, $FE, $FF, $FF, $00
    db   $00, $00, $01, $01, $01, $02, $02, $02
    db   $02, $02, $02, $02, $01, $01, $01, $00
    db   $00, $00, $FF, $FF, $FF, $FE, $FE, $FE
    db   $FE, $FE, $FE, $FE, $FF, $FF, $FF, $00
    db   $00, $00, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $00, $00
    db   $00, $00, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $00, $00
    db   $49, $6F, $21, $6F, $F9, $6E, $D1, $6E
    db   $A9, $6E, $04, $03, $02, $01, $30, $70
    db   $30, $70, $10, $10, $80, $80, $00, $00
    db   $01, $01

JumpTable_700B_05:
    call toc_01_0887
    ifNot [$D200], .else_05_7016

    ld   [hl], $20
JumpTable_700B_05.else_05_7016:
    ld   a, [hl]
    and  a
    jr   nz, .else_05_7071

    ld   [hl], $2C
    ld   a, $5D
    call toc_01_3C01
    jr   c, .else_05_7071

    ld   hl, $C360
    add  hl, de
    ld   [hl], $FF
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], $FF
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $01
    ld   hl, $C290
    add  hl, de
    ld   [hl], $01
    push bc
    call toc_01_27ED
    and  %00000011
    ld   c, a
    ld   hl, $6FFF
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $C2C0
    add  hl, de
    ld   [hl], a
    ld   hl, $7003
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2D0
    add  hl, de
    ld   [hl], a
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $5F
    ld   hl, $7007
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C380
    add  hl, de
    ld   [hl], a
    pop  bc
JumpTable_700B_05.else_05_7071:
    call toc_01_088C
    jr   z, .else_05_7087

    rra
    rra
    rra
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $6FFB
    add  hl, de
    ld   a, [hl]
    ld   hl, $C2D0
    add  hl, bc
    ld   [hl], a
JumpTable_700B_05.else_05_7087:
    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    and  %00000111
    ld   hl, $D200
    or   [hl]
    jr   nz, .else_05_70A8

    ifNe [$FFF0], $03, .else_05_70A8

    ld   hl, $C390
    add  hl, bc
    ld   e, [hl]
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    add  a, e
    and  %00011111
    ld   [hl], a
JumpTable_700B_05.else_05_70A8:
    ld   a, [$D200]
    and  a
    ld   a, $00
    jr   nz, .else_05_70BA

    ld   hl, $C440
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    rra
    rra
    and  %00011111
JumpTable_700B_05.else_05_70BA:
    ld   [$FFE8], a
    ld   hl, $C200
    add  hl, bc
    ld   [hl], $50
    ld   hl, $C210
    add  hl, bc
    ld   [hl], $48
    ld   a, [$FFE8]
    ld   e, a
    ld   d, b
    ld   hl, $6F71
    add  hl, de
    ld   a, [hl]
    ld   hl, $C2C0
    add  hl, bc
    add  a, [hl]
    and  %00011111
    ld   e, a
    ld   d, b
    push de
    ld   hl, $C2D0
    add  hl, bc
    ld   e, [hl]
    sla  e
    ld   d, b
    ld   hl, $6FF1
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    pop  de
    ld   a, $02
    call .toc_05_71A3
    ld   a, [$FFE8]
    ld   e, a
    ld   d, b
    ld   hl, $6F91
    add  hl, de
    ld   a, [hl]
    ld   hl, $C2C0
    add  hl, bc
    add  a, [hl]
    and  %00011111
    ld   e, a
    ld   d, b
    push de
    ld   hl, $C2D0
    add  hl, bc
    ld   e, [hl]
    dec  e
    ld   a, e
    cp   $F0
    jp   nc, .toc_05_71EA

    sla  e
    ld   d, b
    ld   hl, $6FF1
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    pop  de
    ld   a, $01
    call .toc_05_71A3
    ld   a, [$FFE8]
    ld   e, a
    ld   d, b
    ld   hl, $6FB1
    add  hl, de
    ld   a, [hl]
    ld   hl, $C2C0
    add  hl, bc
    add  a, [hl]
    and  %00011111
    ld   e, a
    ld   d, b
    push de
    ld   hl, $C2D0
    add  hl, bc
    ld   e, [hl]
    dec  e
    dec  e
    ld   a, e
    cp   $F0
    jp   nc, .toc_05_71EA

    sla  e
    ld   d, b
    ld   hl, $6FF1
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    pop  de
    ld   a, $01
    call .toc_05_71A3
    ld   a, [$FFE8]
    ld   e, a
    ld   d, b
    ld   hl, $6FD1
    add  hl, de
    ld   a, [hl]
    ld   hl, $C2C0
    add  hl, bc
    add  a, [hl]
    and  %00011111
    ld   e, a
    ld   d, b
    push de
    ld   hl, $C2D0
    add  hl, bc
    ld   e, [hl]
    dec  e
    dec  e
    dec  e
    ld   a, e
    cp   $F0
    jp   nc, .toc_05_71EA

    sla  e
    ld   d, b
    ld   hl, $6FF1
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    pop  de
    ld   a, $01
    call .toc_05_71A3
    ld   hl, $C2C0
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    push de
    ld   hl, $C2D0
    add  hl, bc
    ld   e, [hl]
    dec  e
    dec  e
    dec  e
    dec  e
    ld   a, e
    cp   $F0
    jp   nc, .toc_05_71EA

    sla  e
    ld   d, b
    ld   hl, $6FF1
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    pop  de
    ld   a, $00
JumpTable_700B_05.toc_05_71A3:
    ld   [$FFF1], a
    add  hl, de
    ld   a, $48
    add  a, [hl]
    ld   [$FFEC], a
    ld   a, l
    add  a, $08
    ld   l, a
    ld   a, h
    adc  $00
    ld   h, a
    ld   a, $50
    add  a, [hl]
    ld   [$FFEE], a
    call toc_05_7200
    ld   a, [hLinkPositionX]
    ld   hl, $FFEE
    sub  a, [hl]
    add  a, 8
    cp   16
    jr   nc, .return_05_71E9

    ld   a, [hLinkPositionY]
    ld   hl, $FFEC
    sub  a, [hl]
    add  a, 8
    cp   16
    jr   nc, .return_05_71E9

    ld   a, [$C11C]
    and  a
    jr   nz, .return_05_71E9

    call toc_01_3B93
    ld   a, $18
    call toc_01_3C30
    copyFromTo [$FFD7], [hLinkPositionYIncrement]
    copyFromTo [$FFD8], [hLinkPositionXIncrement]
JumpTable_700B_05.return_05_71E9:
    ret


JumpTable_700B_05.toc_05_71EA:
    pop  de
    ret


    db   $70, $00, $70, $20, $72, $00, $72, $20
    db   $74, $00, $74, $20, $7C, $00, $7C, $20
    db   $7E, $00, $7E, $20

toc_05_7200:
    ld   de, $71EC
    call toc_01_3C3B
    ret


JumpTable_7207_05:
    call toc_05_78AC
    call toc_05_7965
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_7226_05 ; 00
    dw JumpTable_7285_05 ; 01
    dw JumpTable_7348_05 ; 02
    dw JumpTable_73D5_05 ; 03
    dw JumpTable_7460_05 ; 04

    db   $09, $0A, $0B, $0B, $0B, $0B, $0C, $0D
    db   $0E, $0E, $0E, $0E

JumpTable_7226_05:
    call toc_01_0891
    jp   z, toc_05_7459

    ld   e, a
    cp   $18
    jr   nz, .else_05_7235

    assign [$FFF3], $16
JumpTable_7226_05.else_05_7235:
    ld   a, e
    rra
    rra
    rra
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  a
    ld   hl, $721A
    jr   z, .else_05_724B

    ld   hl, $7220
JumpTable_7226_05.else_05_724B:
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ret


    db   $09, $09, $0A, $0A, $0B, $0B, $0B, $0B
    db   $0B, $0B, $0B, $0B, $0A, $0A, $09, $09
    db   $09, $09, $09, $09, $09, $09, $09, $09
    db   $0C, $0C, $0D, $0D, $0E, $0E, $0E, $0E
    db   $0E, $0E, $0E, $0E, $0D, $0D, $0C, $0C
    db   $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
    db   $18, $D8, $04, $0C

JumpTable_7285_05:
    call toc_01_0891
    jp   z, toc_05_7459

    ld   e, a
    cp   $20
    jr   nz, .else_05_7294

    assign [$FFF3], $16
JumpTable_7285_05.else_05_7294:
    ld   a, e
    rra
    rra
    and  %00011111
    ld   e, a
    ld   d, b
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  a
    ld   hl, $7251
    jr   z, .else_05_72A9

    ld   hl, $7269
JumpTable_7285_05.else_05_72A9:
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    cp   $0B
    jr   z, .else_05_72B7

    cp   $0E
    jp   nz, .return_05_7347

JumpTable_7285_05.else_05_72B7:
    ld   a, [hLinkDirection]
    and  DIRECTION_UP
    jp   z, .return_05_7347

    ld   a, [$C1A6]
    and  a
    jp   z, .return_05_7347

    dec  a
    ld   [$D202], a
    ld   e, a
    ld   d, b
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .return_05_7347

    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $03
    jr   nz, .return_05_7347

    ld   hl, $C200
    add  hl, de
    ld   a, [$FFEE]
    sub  a, [hl]
    add  a, $08
    cp   $10
    jr   nc, .return_05_7347

    ld   hl, $C210
    add  hl, de
    ld   a, [$FFEC]
    sub  a, [hl]
    add  a, $0C
    cp   $18
    jr   nc, .return_05_7347

    ld   a, [$D203]
    inc  a
    ld   [$D203], a
    cp   $04
    jr   c, .else_05_7337

    call toc_01_27ED
    and  %00000001
    jr   nz, .else_05_7337

    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], $02
    call toc_01_0887
    ld   [hl], $30
    ld   hl, $C300
    add  hl, bc
    ld   [hl], $20
    ld   hl, $C380
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $7281
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ld   hl, $7283
    add  hl, de
    ld   a, [hl]
    ld   hl, $C290
    add  hl, bc
    ld   [hl], a
    call toc_05_76A1
    ret


JumpTable_7285_05.else_05_7337:
    call JumpTable_3B8D_00
    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C390
    add  hl, de
    ld   a, [hl]
    cpl
    inc  a
    ld   [hl], a
JumpTable_7285_05.return_05_7347:
    ret


JumpTable_7348_05:
    call toc_05_78D2
    assign [$D200], $01
    ld   a, [$D202]
    ld   e, a
    ld   d, b
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_05_739C

    ld   a, [$DBC7]
    and  a
    jr   nz, .else_05_739C

    ld   hl, $C210
    add  hl, de
    ld   a, [hl]
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C2D0
    add  hl, de
    ld   a, [hl]
    cp   $00
    jr   z, .else_05_7382

    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .else_05_7382

    dec  [hl]
JumpTable_7348_05.else_05_7382:
    ld   a, [hFrameCounter]
    and  %00000111
    jr   nz, .else_05_738C

    assign [$FFF2], $29
JumpTable_7348_05.else_05_738C:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  a
    ld   a, $00
    jr   z, .else_05_7398

    ld   a, $01
JumpTable_7348_05.else_05_7398:
    call toc_01_3B87
    ret


JumpTable_7348_05.else_05_739C:
    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $5F
    ret


    db   $10, $10, $0C, $08, $04, $03, $02, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $01
    db   $03, $1F, $1F, $3F, $3F, $3F, $3F, $3F
    db   $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F
    db   $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F

JumpTable_73D5_05:
    call toc_05_78D2
    assign [$D200], $01
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  a
    ld   a, $08
    jr   z, .else_05_73E9

    ld   a, $0F
JumpTable_73D5_05.else_05_73E9:
    call toc_01_3B87
    ld   a, [hLinkPositionX]
    push af
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    ld   [hLinkPositionX], a
    ld   a, [hLinkPositionY]
    push af
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    ld   [hLinkPositionY], a
    call toc_01_0891
    rra
    rra
    and  %00111111
    ld   e, a
    ld   d, b
    ld   hl, $73A5
    add  hl, de
    ld   a, [hl]
    call toc_01_3C30
    ld   a, [$FFD8]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   a, [$FFD7]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    call toc_05_79D1
    ld   a, [hLinkPositionY]
    ld   hl, $FFEC
    sub  a, [hl]
    add  a, 3
    cp   6
    jr   nc, .else_05_7431

    call toc_05_7459
JumpTable_73D5_05.else_05_7431:
    pop  af
    ld   [hLinkPositionY], a
    pop  af
    ld   [hLinkPositionX], a
    call toc_01_0891
    rra
    rra
    and  %00111111
    ld   e, a
    ld   d, b
    ld   hl, $73BD
    add  hl, de
    ld   a, [hFrameCounter]
    and  [hl]
    jr   nz, .return_05_7458

    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C2D0
    add  hl, de
    ld   a, [hl]
    cp   $04
    jr   z, .return_05_7458

    inc  [hl]
JumpTable_73D5_05.return_05_7458:
    ret


toc_05_7459:
    clear [$D200]
    jp   toc_05_7A6B

JumpTable_7460_05:
    call toc_05_78D2
    call toc_01_0891
    jp   z, toc_05_74AD

    ld   hl, $C420
    add  hl, bc
    ld   [hl], a
    cp   $80
    jr   nc, .return_05_7475

    call toc_05_7476
JumpTable_7460_05.return_05_7475:
    ret


toc_05_7476:
    and  %00000111
    jr   nz, .return_05_7497

    call toc_01_27ED
    and  %00011111
    sub  a, $10
    ld   e, a
    ld   hl, $FFEE
    add  a, [hl]
    ld   [hl], a
    call toc_01_27ED
    and  %00011111
    sub  a, $10
    ld   e, a
    ld   hl, $FFEC
    add  a, [hl]
    ld   [hl], a
    call toc_05_7498
toc_05_7476.return_05_7497:
    ret


toc_05_7498:
    call toc_05_7965.toc_05_796B
    copyFromTo [$FFEE], [$FFD7]
    copyFromTo [$FFEC], [$FFD8]
    ld   a, $02
    call toc_01_0953
    assign [$FFF4], $13
    ret


toc_05_74AD:
    ld   a, $36
    call toc_01_3C01
    jr   toc_05_74C1

toc_05_74B4:
    ld   a, $36
    call toc_01_3C01
    assign [$FFD7], $48
    assign [$FFD8], $10
toc_05_74C1:
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ifNot [$FFF9], toc_05_74DC

    ld   hl, $C250
    add  hl, bc
    ld   [hl], $F0
    jr   toc_05_74E8

toc_05_74DC:
    ld   hl, $C320
    add  hl, de
    ld   [hl], $10
    ld   hl, $C310
    add  hl, de
    ld   [hl], $08
toc_05_74E8:
    call toc_05_7A6B
    ld   hl, $FFF4
    ld   [hl], $1A
    ret


    db   $03, $05, $00, $04, $02, $06, $01, $07

JumpTable_74F9_05:
    call toc_05_7597
    call toc_01_3DBA
    call toc_05_7965
    assign [$D200], $01
    call toc_01_0887
    cp   $10
    jr   nc, .else_05_7549

    and  a
    jr   nz, .else_05_7541

    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C2F0
    add  hl, de
    ld   [hl], $1F
    ld   a, $02
    call toc_01_3C01
    call toc_01_08D7
    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $17
    ld   hl, $C440
    add  hl, de
    ld   [hl], $01
    jp   toc_05_7459

JumpTable_74F9_05.else_05_7541:
    ld   a, [hFrameCounter]
    ld   hl, $C420
    add  hl, bc
    ld   [hl], a
    ret


JumpTable_74F9_05.else_05_7549:
    ld   a, [hFrameCounter]
    and  %00000111
    jr   nz, .else_05_755D

    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C2D0
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_05_755D

    dec  [hl]
JumpTable_74F9_05.else_05_755D:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    inc  a
    and  %01111111
    ld   [hl], a
    ld   e, a
    ld   d, b
    ld   hl, $D000
    add  hl, de
    ld   a, [$FFEE]
    ld   [hl], a
    ld   hl, $D100
    add  hl, de
    ld   a, [$FFEC]
    ld   [hl], a
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_7583

    call toc_05_79D1
    jr   .toc_05_7586

JumpTable_74F9_05.else_05_7583:
    call toc_05_762C
JumpTable_74F9_05.toc_05_7586:
    ld   hl, $C290
    add  hl, bc
    ld   e, [hl]
    srl  e
    ld   d, b
    ld   hl, $74F1
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ret


toc_05_7597:
    ld   a, [$FFF1]
    rla
    rla
    rla
    rla
    rla
    and  %11100000
    ld   e, a
    ld   d, b
    ld   hl, $76AC
    add  hl, de
    ld   c, $08
    call toc_01_3D26
    ld   a, $08
    call toc_01_3DD0
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD7], a
    ld   a, [$FFD7]
    sub  a, $0C
    and  %01111111
    ld   e, a
    ld   d, b
    ld   hl, $D000
    add  hl, de
    ld   a, [hl]
    ld   [$FFEE], a
    ld   hl, $D100
    add  hl, de
    ld   a, [hl]
    ld   [$FFEC], a
    assign [$FFF1], $00
    ld   de, $71EC
    call toc_01_3C3B
    ld   a, [$FFD7]
    sub  a, $18
    and  %01111111
    ld   e, a
    ld   d, b
    ld   hl, $D000
    add  hl, de
    ld   a, [hl]
    ld   [$FFEE], a
    ld   hl, $D100
    add  hl, de
    ld   a, [hl]
    ld   [$FFEC], a
    assign [$FFF1], $00
    ld   de, $71EC
    call toc_01_3C3B
    ld   a, [$FFD7]
    sub  a, $24
    and  %01111111
    ld   e, a
    ld   d, b
    ld   hl, $D000
    add  hl, de
    ld   a, [hl]
    ld   [$FFEE], a
    ld   hl, $D100
    add  hl, de
    ld   a, [hl]
    ld   [$FFEC], a
    assign [$FFF1], $02
    ld   de, $71EC
    call toc_01_3C3B
    ret


    db   $00, $06, $0C, $0E, $10, $0E, $0C, $06
    db   $00, $FA, $F4, $F2, $F0, $F2, $F4, $FA
    db   $00, $06, $0C, $0E

toc_05_762C:
    call toc_05_79D1
    call toc_01_3BBF
    call toc_01_3B9E
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_765A

    call toc_01_27ED
    rra
    jr   c, .else_05_764B

    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    ld   [hl], a
toc_05_762C.else_05_764B:
    ld   hl, $C290
    add  hl, bc
    ld   a, [hl]
    add  a, $08
    and  %00001111
    ld   [hl], a
    call toc_01_0891
    ld   [hl], $10
toc_05_762C.else_05_765A:
    call toc_01_088C
    jr   nz, .else_05_7688

    ld   [hl], $04
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C290
    add  hl, bc
    add  a, [hl]
    and  %00001111
    ld   [hl], a
    ld   hl, $C290
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $7618
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ld   hl, $761C
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
toc_05_762C.else_05_7688:
    call toc_01_0891
    jr   nz, .return_05_76A0

    call toc_01_27ED
    and  %00011111
    add  a, $10
    ld   [hl], a
    call toc_01_27ED
    and  %00000010
    dec  a
    ld   hl, $C2C0
    add  hl, bc
    ld   [hl], a
toc_05_762C.return_05_76A0:
    ret


toc_05_76A1:
    ld   e, $80
    ld   hl, $D100
toc_05_76A1.loop_05_76A6:
    xor  a
    ldi  [hl], a
    dec  e
    jr   nz, .loop_05_76A6

    ret


    db   $F8, $F8, $60, $00, $F8, $00, $62, $00
    db   $F8, $08, $62, $20, $F8, $10, $60, $20
    db   $08, $F8, $64, $00, $08, $00, $66, $00
    db   $08, $08, $66, $20, $08, $10, $64, $20
    db   $F8, $F8, $64, $40, $F8, $00, $66, $40
    db   $F8, $08, $66, $60, $F8, $10, $64, $60
    db   $08, $F8, $60, $40, $08, $00, $62, $40
    db   $08, $08, $62, $60, $08, $10, $60, $60
    db   $F8, $F8, $68, $00, $F8, $00, $6A, $00
    db   $F8, $08, $62, $20, $F8, $10, $60, $20
    db   $08, $F8, $68, $40, $08, $00, $6A, $40
    db   $08, $08, $62, $60, $08, $10, $60, $60
    db   $F8, $F8, $60, $00, $F8, $00, $62, $00
    db   $F8, $08, $6A, $20, $F8, $10, $68, $20
    db   $08, $F8, $60, $40, $08, $00, $62, $40
    db   $08, $08, $6A, $60, $08, $10, $68, $60
    db   $F8, $F8, $60, $00, $F8, $00, $62, $00
    db   $F8, $08, $62, $20, $F8, $10, $60, $20
    db   $08, $F8, $6C, $00, $08, $00, $6E, $00
    db   $08, $08, $62, $60, $08, $10, $60, $60
    db   $F8, $F8, $60, $00, $F8, $00, $62, $00
    db   $F8, $08, $62, $20, $F8, $10, $60, $20
    db   $08, $F8, $60, $40, $08, $00, $62, $40
    db   $08, $08, $6E, $20, $08, $10, $6C, $20
    db   $F8, $F8, $6C, $40, $F8, $00, $6E, $40
    db   $F8, $08, $62, $20, $F8, $10, $60, $20
    db   $08, $F8, $60, $40, $08, $00, $62, $40
    db   $08, $08, $62, $60, $08, $10, $60, $60
    db   $F8, $F8, $60, $00, $F8, $00, $62, $00
    db   $F8, $08, $6E, $60, $F8, $10, $6C, $60
    db   $08, $F8, $60, $40, $08, $00, $62, $40
    db   $08, $08, $62, $60, $08, $10, $60, $60
    db   $F8, $F8, $60, $00, $F8, $00, $62, $00
    db   $F8, $08, $62, $20, $F8, $10, $60, $20
    db   $08, $F8, $78, $00, $08, $00, $7A, $00
    db   $08, $08, $7A, $20, $08, $10, $78, $20
    db   $08, $00, $76, $00, $08, $08, $76, $20
    db   $08, $08, $76, $20, $08, $08, $76, $20
    db   $08, $08, $76, $20, $08, $08, $76, $20
    db   $08, $08, $76, $20, $08, $08, $76, $20
    db   $08, $F8, $64, $00, $08, $00, $66, $00
    db   $08, $08, $66, $20, $08, $10, $64, $20
    db   $08, $F8, $64, $00, $08, $00, $66, $00
    db   $08, $08, $66, $20, $08, $10, $64, $20
    db   $08, $F8, $78, $00, $08, $00, $7A, $00
    db   $08, $08, $7A, $20, $08, $10, $78, $20
    db   $08, $F8, $78, $00, $08, $00, $7A, $00
    db   $08, $08, $7A, $20, $08, $10, $78, $20
    db   $F8, $00, $76, $40, $F8, $08, $76, $60
    db   $F8, $08, $76, $60, $F8, $08, $76, $60
    db   $F8, $08, $76, $60, $F8, $08, $76, $60
    db   $F8, $08, $76, $60, $F8, $08, $76, $60
    db   $F8, $F8, $64, $40, $F8, $00, $66, $40
    db   $F8, $08, $66, $60, $F8, $10, $64, $60
    db   $F8, $F8, $64, $40, $F8, $00, $66, $40
    db   $F8, $08, $66, $60, $F8, $10, $64, $60
    db   $F8, $F8, $78, $40, $F8, $00, $7A, $40
    db   $F8, $08, $7A, $60, $F8, $10, $78, $60
    db   $F8, $F8, $78, $40, $F8, $00, $7A, $40
    db   $F8, $08, $7A, $60, $F8, $10, $78, $60
    db   $08, $F8, $60, $40, $08, $00, $62, $40
    db   $08, $08, $62, $60, $08, $10, $60, $60
    db   $F8, $F8, $78, $40, $F8, $00, $7A, $40
    db   $F8, $08, $7A, $60, $F8, $10, $78, $60

toc_05_78AC:
    ld   a, [$FFF1]
    ld   d, b
    rla
    rl   d
    rla
    rl   d
    rla
    rl   d
    rla
    rl   d
    rla
    rl   d
    and  %11100000
    ld   e, a
    ld   hl, $76AC
    add  hl, de
    ld   c, $08
    call toc_01_3D26
    ld   a, $08
    call toc_01_3DD0
    ret


    db   $F2, $0E

toc_05_78D2:
    ld   a, [hFrameCounter]
    and  %00010000
    ld   a, $03
    jr   z, .else_05_78DB

    inc  a
toc_05_78D2.else_05_78DB:
    ld   [$FFF1], a
    nop
toc_05_78D2.toc_05_78DE:
    ld   hl, $C380
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $78D0
    add  hl, de
    ld   a, [hl]
    ld   hl, $FFEC
    add  a, [hl]
    ld   [hl], a
    cp   $14
    jr   c, .else_05_794A

    cp   $7C
    jr   nc, .else_05_794A

    ld   de, $71EC
    call toc_01_3C3B
    ifGte [$FFF0], $04, .else_05_7948

    ifNot [$FFF1], .else_05_7945

    clear [$FFF1]
    call toc_01_3BEB
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    cp   $16
    jr   nz, .else_05_7945

    incAddr $D204
    ld   a, [hl]
    cp   $08
    jr   nz, .else_05_7945

    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C280
    add  hl, de
    ld   [hl], b
    call JumpTable_3B8D_00
    ld   [hl], $04
    call toc_01_0891
    ld   [hl], $FF
    call toc_01_27D2
    assign [$C5A7], $03
    assign [$D368], $5E
    ld   a, $B5
    call toc_01_2197
toc_05_78D2.else_05_7945:
    call toc_01_3BBF
toc_05_78D2.else_05_7948:
    jr   .toc_05_78DE

toc_05_78D2.else_05_794A:
    call toc_01_3DBA
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .return_05_7964

    ld   hl, $C430
    add  hl, bc
    ld   [hl], $C0
    call toc_01_3BEB
    ld   hl, $C430
    add  hl, bc
    ld   [hl], $80
toc_05_78D2.return_05_7964:
    ret


toc_05_7965:
    ifNe [$FFEA], $05, .else_05_7985

toc_05_7965.toc_05_796B:
    ifEq [wGameMode], GAMEMODE_WORLD_MAP, .else_05_7985

    ld   hl, $C1A8
    ld   a, [wDialogState]
    or   [hl]
    ld   hl, $C14F
    or   [hl]
    jr   nz, .else_05_7985

    ifNot [$C124], .return_05_7986

toc_05_7965.else_05_7985:
    pop  af
toc_05_7965.return_05_7986:
    ret


    db   $21, $10, $C4, $09, $7E, $A7, $28, $41
    db   $3D, $77, $CD, $B8, $3E, $21, $40, $C2
    db   $09, $7E, $F5, $21, $50, $C2, $09, $7E
    db   $F5, $21, $F0, $C3, $09, $7E, $21, $40
    db   $C2, $09, $77, $21, $00, $C4, $09, $7E
    db   $21, $50, $C2, $09, $77, $CD, $D1, $79
    db   $21, $30, $C4, $09, $7E, $E6, $20, $20
    db   $03, $CD, $9E, $3B, $21, $50, $C2, $09
    db   $F1, $77, $21, $40, $C2, $09, $F1, $77
    db   $F1, $C9

toc_05_79D1:
    call toc_05_79DE
toc_05_79D1.toc_05_79D4:
    push bc
    ld   a, c
    add  a, $10
    ld   c, a
    call toc_05_79DE
    pop  bc
    ret


toc_05_79DE:
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_05_7A09

    push af
    swap a
    and  %11110000
    ld   hl, $C260
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, $C200
toc_05_79DE.toc_05_79F6:
    add  hl, bc
    pop  af
    ld   e, $00
    bit  7, a
    jr   z, .else_05_7A00

    ld   e, $F0
toc_05_79DE.else_05_7A00:
    swap a
    and  %00001111
    or   e
    rr   d
    adc  [hl]
    ld   [hl], a
toc_05_79DE.return_05_7A09:
    ret


toc_05_7A0A:
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, toc_05_79DE.return_05_7A09

    push af
    swap a
    and  %11110000
    ld   hl, $C330
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, $C310
    jr   toc_05_79DE.toc_05_79F6

toc_05_7A24:
    ld   e, $00
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, bc
    sub  a, [hl]
    bit  7, a
    jr   z, .else_05_7A32

    inc  e
toc_05_7A24.else_05_7A32:
    ld   d, a
    ret


toc_05_7A34:
    ld   e, $02
    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, bc
    sub  a, [hl]
    bit  7, a
    jr   nz, .else_05_7A42

    inc  e
toc_05_7A34.else_05_7A42:
    ld   d, a
    ret


toc_05_7A44:
    call toc_05_7A24
    ld   a, e
    ld   [$FFD7], a
    ld   a, d
    bit  7, a
    jr   z, .else_05_7A51

    cpl
    inc  a
toc_05_7A44.else_05_7A51:
    push af
    call toc_05_7A34
    ld   a, e
    ld   [$FFD8], a
    ld   a, d
    bit  7, a
    jr   z, .else_05_7A5F

    cpl
    inc  a
toc_05_7A44.else_05_7A5F:
    pop  de
    cp   d
    jr   nc, .else_05_7A67

    ld   a, [$FFD7]
    jr   .toc_05_7A69

toc_05_7A44.else_05_7A67:
    ld   a, [$FFD8]
toc_05_7A44.toc_05_7A69:
    ld   e, a
    ret


toc_05_7A6B:
    ld   hl, $C280
    add  hl, bc
    ld   [hl], b
    ret


    db   $10, $F0, $18, $E8, $00, $F0, $64, $00
    db   $00, $F8, $66, $00, $00, $00, $60, $00
    db   $00, $08, $60, $20, $00, $10, $6A, $20
    db   $00, $18, $68, $20, $00, $F0, $6C, $00
    db   $00, $F8, $6E, $00, $00, $00, $60, $00
    db   $00, $08, $60, $20, $00, $10, $6E, $20
    db   $00, $18, $6C, $20, $00, $F0, $68, $00
    db   $00, $F8, $6A, $00, $00, $00, $60, $00
    db   $00, $08, $60, $20, $00, $10, $66, $20
    db   $00, $18, $64, $20, $00, $F0, $64, $00
    db   $00, $F8, $66, $00, $00, $00, $62, $00
    db   $00, $08, $62, $20, $00, $10, $6A, $20
    db   $00, $18, $68, $20, $00, $F0, $6C, $00
    db   $00, $F8, $6E, $00, $00, $00, $62, $00
    db   $00, $08, $62, $20, $00, $10, $6E, $20
    db   $00, $18, $6C, $20, $00, $F0, $68, $00
    db   $00, $F8, $6A, $00, $00, $00, $62, $00
    db   $00, $08, $62, $20, $00, $10, $66, $20
    db   $00, $18, $64, $20, $FA, $66, $C1, $FE
    db   $01, $20, $0A, $CD, $F5, $7B, $21, $90
    db   $C2, $09, $7E, $E0, $F0, $F0, $F1, $17
    db   $17, $17, $E6, $F8, $4F, $17, $E6, $F0
    db   $81, $5F, $50, $21, $75, $7A, $19, $0E
    db   $06, $CD, $26, $3D, $3E, $06, $CD, $D0
    db   $3D, $F0, $EA, $FE, $05, $C2, $8D, $7D
    db   $CD, $65, $79, $CD, $12, $3F, $CD, $B4
    db   $3B, $CD, $D1, $79, $CD, $9E, $3B, $CD
    db   $E2, $08, $F0, $F0, $C7

    dw JumpTable_7B56_05 ; 00
    dw JumpTable_7B72_05 ; 01
    dw JumpTable_7C83_05 ; 02
    dw JumpTable_7D2B_05 ; 03

JumpTable_7B56_05:
    call toc_01_27ED
    and  %00000001
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    ld   e, a
    ld   d, b
    ld   hl, $7A71
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    call JumpTable_3B8D_00
    ld   [hl], $01
    ret


JumpTable_7B72_05:
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    ret  nz

    call toc_01_088C
    jp   nz, .else_05_7C09

    call toc_01_0891
    jr   z, .else_05_7BA9

    cp   $01
    jr   nz, .else_05_7BBC

    call toc_05_7A24
    ld   d, b
    ld   hl, $7A73
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $C250
    add  hl, bc
    ld   [hl], b
    call toc_01_088C
    call toc_01_27ED
    and  %00111111
    add  a, $60
    ld   [hl], a
    jp   .else_05_7C09

JumpTable_7B72_05.else_05_7BA9:
    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    add  a, $08
    ld   hl, hLinkPositionY
    cp   [hl]
    jp   c, .toc_05_7BD3

    call toc_01_0891
    ld   [hl], $60
JumpTable_7B72_05.else_05_7BBC:
    ld   hl, $C250
    add  hl, bc
    ld   [hl], b
    ld   hl, $C240
    add  hl, bc
    and  %00000100
    jr   nz, .else_05_7BCE

    ld   [hl], $08
    jp   .else_05_7C61

JumpTable_7B72_05.else_05_7BCE:
    ld   [hl], $F8
    jp   .else_05_7C61

JumpTable_7B72_05.toc_05_7BD3:
    ld   hl, $C210
    add  hl, bc
    ld   a, [hLinkPositionY]
    sub  a, [hl]
    cp   40
    jr   nc, .else_05_7C09

    ld   hl, $C480
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_05_7C09

    call toc_01_27ED
    and  %01111111
    add  a, $40
    ld   [hl], a
    and  %00000011
    jr   z, .else_05_7C42

    dec  a
    jr   nz, .else_05_7C09

    call JumpTable_3B8D_00
    ld   [hl], $03
    call toc_01_3DAF
    ld   hl, $C300
    add  hl, bc
    ld   [hl], $40
    ld   a, $01
    call .toc_05_7C80
    ret


JumpTable_7B72_05.else_05_7C09:
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00000011
    jr   z, .else_05_7C2A

    call toc_01_088C
    jr   z, .else_05_7C22

    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    xor  %11110000
    ld   [hl], a
    jp   .else_05_7C61

JumpTable_7B72_05.else_05_7C22:
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    xor  %00000001
    ld   [hl], a
JumpTable_7B72_05.else_05_7C2A:
    call toc_01_088C
    jr   nz, .else_05_7C61

    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    ld   e, a
    ld   d, b
    ld   hl, $7A71
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    jr   .toc_05_7C69

JumpTable_7B72_05.else_05_7C42:
    call toc_01_0891
    ld   [hl], $60
    call toc_01_088C
    ld   [hl], b
    call JumpTable_3B8D_00
    ld   [hl], $02
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], b
    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C2D0
    add  hl, bc
    ld   [hl], a
    jr   .toc_05_7C69

JumpTable_7B72_05.else_05_7C61:
    ld   a, [hFrameCounter]
    and  %00000111
    jr   z, .else_05_7C6F

    jr   .else_05_7C7B

JumpTable_7B72_05.toc_05_7C69:
    ld   a, [hFrameCounter]
    and  %00001111
    jr   nz, .else_05_7C7B

JumpTable_7B72_05.else_05_7C6F:
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    cp   $03
    jr   nz, .else_05_7C7B

    ld   [hl], $00
JumpTable_7B72_05.else_05_7C7B:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
JumpTable_7B72_05.toc_05_7C80:
    jp   toc_01_3B87

JumpTable_7C83_05:
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    and  a
    jp   nz, .toc_05_7CFD

    call toc_01_0891
    cp   $02
    jr   nc, .else_05_7CED

    cp   $00
    jr   z, .else_05_7CC9

    ld   hl, hLinkPositionY
    ld   a, [hl]
    ld   hl, $C390
    add  hl, bc
    ld   [hl], a
    call toc_01_27ED
    and  %00000010
    jr   z, .else_05_7CB3

    call toc_01_3DAF
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $10
    jp   .toc_05_7CB8

JumpTable_7C83_05.else_05_7CB3:
    ld   a, $10
    call toc_01_3C25
JumpTable_7C83_05.toc_05_7CB8:
    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    add  a, $08
    ld   hl, hLinkPositionY
    cp   [hl]
    jp   nc, .toc_05_7D09

    jp   .else_05_7D11

JumpTable_7C83_05.else_05_7CC9:
    ld   hl, $C390
    add  hl, bc
    ld   a, [hl]
    sub  a, $08
    ld   hl, $C210
    add  hl, bc
    cp   [hl]
    jp   nc, .else_05_7D11

    ld   hl, $C2B0
    add  hl, bc
    inc  [hl]
    call toc_01_3DAF
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $F0
    assign [$FFF3], $16
    jp   .else_05_7D11

JumpTable_7C83_05.else_05_7CED:
    ld   hl, $C240
    add  hl, bc
    and  %00000100
    jr   nz, .else_05_7CF9

    ld   [hl], $08
    jr   .else_05_7D11

JumpTable_7C83_05.else_05_7CF9:
    ld   [hl], $F8
    jr   .else_05_7D11

JumpTable_7C83_05.toc_05_7CFD:
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, bc
    cp   [hl]
    jr   c, .else_05_7D11

JumpTable_7C83_05.toc_05_7D09:
    call toc_01_3DAF
    call JumpTable_3B8D_00
    ld   [hl], $01
JumpTable_7C83_05.else_05_7D11:
    ld   a, [hFrameCounter]
    and  %00001111
    jr   nz, .else_05_7D23

    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    cp   $03
    jr   nz, .else_05_7D23

    ld   [hl], $00
JumpTable_7C83_05.else_05_7D23:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    jp   toc_01_3B87

JumpTable_7D2B_05:
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_05_7D34

    ret


JumpTable_7D2B_05.else_05_7D34:
    call toc_01_088C
    cp   $02
    jr   nc, .else_05_7D5B

    cp   $00
    jr   z, .else_05_7D56

    ld   hl, $C350
    add  hl, bc
    ld   [hl], $80
    ld   a, $01
    call toc_01_3B87
    call JumpTable_3B8D_00
    ld   [hl], $01
    ld   hl, $C300
    add  hl, bc
    ld   [hl], $40
    ret


JumpTable_7D2B_05.else_05_7D56:
    call toc_01_088C
    ld   [hl], $30
JumpTable_7D2B_05.else_05_7D5B:
    cp   $18
    jr   nz, .else_05_7D82

    ld   a, $7D
    call toc_01_3C01
    jr   c, .else_05_7D82

    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, de
    inc  [hl]
    push bc
    push de
    pop  bc
    ld   a, $18
    call toc_01_3C25
    pop  bc
JumpTable_7D2B_05.else_05_7D82:
    ld   hl, $C350
    add  hl, bc
    ld   [hl], $00
    ld   a, $04
    jp   toc_01_3B87

toc_05_7D8D:
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    jumptable
    dw JumpTable_7D99_05 ; 00
    dw JumpTable_7DAA_05 ; 01
    dw JumpTable_7DBB_05 ; 02

JumpTable_7D99_05:
    call toc_01_0891
    ld   [hl], $A0
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $FF
JumpTable_7D99_05.toc_05_7DA4:
    ld   hl, $C2C0
    add  hl, bc
    inc  [hl]
    ret


JumpTable_7DAA_05:
    call toc_01_0891
    jr   nz, .return_05_7DBA

    ld   [hl], $C0
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $FF
    call JumpTable_7D99_05.toc_05_7DA4
JumpTable_7DAA_05.return_05_7DBA:
    ret


JumpTable_7DBB_05:
    call toc_01_0891
    jr   nz, .else_05_7DF8

JumpTable_7DBB_05.toc_05_7DC0:
    assign [$FFF4], $1A
    ld   a, [$FFEB]
    cp   $63
    jp   z, toc_05_74B4

    call toc_01_3F7A
    ld   e, $0F
    ld   d, b
JumpTable_7DBB_05.loop_05_7DD1:
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_05_7DE2

    ld   hl, $C430
    add  hl, de
    ld   a, [hl]
    and  %10000000
    jr   nz, .else_05_7DF0

JumpTable_7DBB_05.else_05_7DE2:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_05_7DD1

    clear [$C1CF]
    call toc_01_27BD
    ret


JumpTable_7DBB_05.else_05_7DF0:
    returnIfGte [$FFF7], $05

    jp   .toc_05_7DFC

JumpTable_7DBB_05.else_05_7DF8:
    call toc_05_7476
    ret


JumpTable_7DBB_05.toc_05_7DFC:
    ld   a, [$FFF6]
    ld   e, a
    ld   d, b
    ifGte [$FFF7], $1A, .else_05_7E0B

    cp   $06
    jr   c, .else_05_7E0B

    inc  d
JumpTable_7DBB_05.else_05_7E0B:
    ld   hl, $D900
    add  hl, de
    set  5, [hl]
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
    db   $FF, $FF, $FF, $FF, $FF, $FF
