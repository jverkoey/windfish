SECTION "ROM Bank 06", ROMX[$4000], BANK[$06]

    db   $50, $00, $52, $00, $54, $00, $56, $00
    db   $50, $00, $52, $00, $54, $00, $56, $00
    db   $58, $00, $5A, $00, $5C, $00, $5E, $00
    db   $5A, $20, $58, $20, $5E, $20, $5C, $20
    db   $3E, $21, $E0, $EC, $11, $00, $40, $CD
    db   $3B, $3C, $CD, $DF, $64, $F0, $E7, $E6
    db   $1F, $20, $08, $CD, $BE, $65, $21, $80
    db   $C3, $09, $73, $CD, $70, $64, $21, $B0
    db   $C2, $09, $7E, $A7, $20, $03, $CD, $49
    db   $64, $F0, $F0, $C7

    dw JumpTable_4056_06 ; 00
    dw JumpTable_4068_06 ; 01
    dw JumpTable_40C7_06 ; 02
    dw JumpTable_40DA_06 ; 03
    dw JumpTable_40EC_06 ; 04

JumpTable_4056_06:
    call JumpTable_3B8D_00
    returnIfLt [$DB15], $06

    ld   [hl], $04
    ld   hl, $C200
    add  hl, bc
    ld   [hl], $58
    ret


JumpTable_4068_06:
    call toc_06_648C
    jr   nc, .return_06_40C6

    ifNot [$DB56], .else_06_4078

    ld   e, $2D
    jp   .else_06_40C2

JumpTable_4068_06.else_06_4078:
    ld   a, [$FFF8]
    and  %00010000
    jr   z, .else_06_4084

    ld   a, [$DB15]
    and  a
    jr   nz, .else_06_40A1

JumpTable_4068_06.else_06_4084:
    ld   a, [$FFF8]
    or   $10
    ld   [$FFF8], a
    ld   [$DAC7], a
    ld   a, $3A
    call toc_01_2185
    ifGte [$DB55], $02, .else_06_409E

    assign [$DB55], $02
JumpTable_4068_06.else_06_409E:
    jp   JumpTable_3B8D_00

JumpTable_4068_06.else_06_40A1:
    ld   e, $3F
    cp   $05
    jr   c, .else_06_40C2

    call JumpTable_3B8D_00
    ld   [hl], $03
    call toc_01_0891
    ld   [hl], $20
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], $01
    assign [$DB15], $FF
    assign [$FFA5], $09
    ld   e, $3D
JumpTable_4068_06.else_06_40C2:
    ld   a, e
    call toc_01_2185
JumpTable_4068_06.return_06_40C6:
    ret


JumpTable_40C7_06:
    ld   a, [$C177]
    and  a
    ld   a, $3B
    jr   z, .else_06_40D1

    ld   a, $3C
JumpTable_40C7_06.else_06_40D1:
    call toc_01_2185
    call JumpTable_3B8D_00
    ld   [hl], $01
    ret


JumpTable_40DA_06:
    call toc_01_0891
    jr   nz, .else_06_40E2

    call JumpTable_3B8D_00
JumpTable_40DA_06.else_06_40E2:
    ld   hl, $C240
    add  hl, bc
    ld   [hl], $F8
    call toc_06_6558
    ret


JumpTable_40EC_06:
    call toc_06_648C
    jr   nc, .else_06_40FF

    ld   a, [$DB15]
    cp   $06
    ld   a, $3E
    jr   z, .else_06_40FC

    ld   a, $3D
JumpTable_40EC_06.else_06_40FC:
    call toc_01_2185
JumpTable_40EC_06.else_06_40FF:
    ld   a, [$FF98]
    sub  a, $78
    add  a, $02
    cp   $04
    jr   nc, .return_06_412B

    ld   a, [$FF99]
    sub  a, $20
    add  a, $05
    cp   $0A
    jr   nc, .return_06_412B

    ld   hl, $D401
    ld   a, $01
    ldi  [hl], a
    ld   a, $11
    ldi  [hl], a
    ld   a, $D8
    ldi  [hl], a
    ld   a, $88
    ldi  [hl], a
    ld   a, $70
    ldi  [hl], a
    call toc_06_65E5
    jp   toc_01_0909

JumpTable_40EC_06.return_06_412B:
    ret


    db   $FF, $00, $FF, $20, $70, $00, $70, $20
    db   $72, $00, $72, $20, $74, $00, $76, $00
    db   $76, $20, $74, $20, $28, $38, $58, $58
    db   $78, $88, $28, $88, $40, $70, $20, $50
    db   $70, $40, $40, $40, $F0, $F8, $E6, $10
    db   $C2, $E5, $65, $21, $E0, $C4, $09, $36
    db   $3C, $21, $60, $C4, $09, $36, $FF, $11
    db   $2C, $41, $CD, $3B, $3C, $CD, $DF, $64
    db   $CD, $E2, $08, $F0, $F0, $C7

    dw JumpTable_417C_06 ; 00
    dw JumpTable_4184_06 ; 01
    dw JumpTable_41BF_06 ; 02
    dw JumpTable_41D4_06 ; 03
    dw JumpTable_422D_06 ; 04

JumpTable_417C_06:
    call toc_01_0891
    ld   [hl], $40
    jp   JumpTable_3B8D_00

JumpTable_4184_06:
    call toc_01_0891
    jr   nz, .return_06_41BE

    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $4140
    add  hl, de
    ld   a, [hl]
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    ld   hl, $4148
    add  hl, de
    ld   a, [hl]
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    call toc_06_659E
    add  a, $20
    cp   $40
    jr   nc, .else_06_41B6

    call toc_06_65AE
    add  a, $20
    cp   $40
    jr   c, .return_06_41BE

JumpTable_4184_06.else_06_41B6:
    call toc_01_0891
    ld   [hl], $18
    call JumpTable_3B8D_00
JumpTable_4184_06.return_06_41BE:
    ret


JumpTable_41BF_06:
    call toc_01_0891
    jr   nz, .else_06_41C9

    ld   [hl], $30
    jp   JumpTable_3B8D_00

JumpTable_41BF_06.else_06_41C9:
    cp   $0C
    ld   a, $01
    jr   nc, .else_06_41D0

    inc  a
JumpTable_41BF_06.else_06_41D0:
    call toc_01_3B87
    ret


JumpTable_41D4_06:
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_06_4222

    ld   [hl], $10
    call JumpTable_3B8D_00
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .return_06_4221

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
    ld   hl, $C310
    add  hl, de
    ld   [hl], $04
JumpTable_41D4_06.toc_06_4202:
    ld   hl, $C320
    add  hl, de
    ld   [hl], $18
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $40
    ld   hl, $C440
    add  hl, de
    ld   [hl], $01
    push bc
    push de
    pop  bc
    ld   a, $10
    call toc_01_3C25
    pop  bc
    assign [$FFF2], $08
JumpTable_41D4_06.return_06_4221:
    ret


JumpTable_41D4_06.else_06_4222:
    and  %00100000
    ld   a, $03
    jr   nz, .else_06_4229

    inc  a
JumpTable_41D4_06.else_06_4229:
    call toc_01_3B87
    ret


JumpTable_422D_06:
    call toc_01_0891
    jr   nz, .else_06_423C

    call JumpTable_3B8D_00
    ld   [hl], b
    ld   a, $FF
    call toc_01_3B87
    ret


JumpTable_422D_06.else_06_423C:
    cp   $08
    ld   a, $01
    jr   c, .else_06_4243

    inc  a
JumpTable_422D_06.else_06_4243:
    call toc_01_3B87
    ret


    db   $CD, $C6, $44, $CD, $DF, $64, $CD, $01
    db   $65, $CD, $84, $65, $21, $20, $C3, $09
    db   $35, $35, $35, $21, $10, $C3, $09, $7E
    db   $E6, $80, $E0, $E8, $28, $06, $70, $21
    db   $20, $C3, $09, $70, $F0, $F0, $C7

    dw JumpTable_4278_06 ; 00
    dw JumpTable_42D7_06 ; 01
    dw JumpTable_4321_06 ; 02
    dw JumpTable_43D4_06 ; 03
    dw JumpTable_4438_06 ; 04

JumpTable_4278_06:
    call toc_01_0891
    jr   nz, .else_06_42AF

    call toc_01_3DAF
    call toc_01_0887
    jr   nz, .else_06_42A1

    call toc_06_659E
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    cp   e
    jr   nz, .else_06_42A1

    call JumpTable_3B8D_00
    ld   [hl], $02
    call toc_01_0891
    ld   [hl], $FF
    assign [$FFF4], $3B
    ret


JumpTable_4278_06.else_06_42A1:
    call toc_01_0891
    call toc_01_27ED
    and  %00011111
    add  a, $10
    ld   [hl], a
    call JumpTable_3B8D_00
JumpTable_4278_06.else_06_42AF:
    ifNot [$FFE8], .else_06_42BA

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $10
JumpTable_4278_06.else_06_42BA:
    call toc_06_654B
    call toc_01_3B9E
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    rla
    and  %00000110
    call toc_01_3B87
    call toc_01_3BB4
    ret


    db   $08, $F8, $08, $F8, $F8, $F8, $08, $08

JumpTable_42D7_06:
    call toc_01_0891
    jr   nz, .else_06_431E

    call toc_01_27ED
    and  %00011111
    add  a, $20
    ld   [hl], a
    call JumpTable_3B8D_00
    ld   [hl], b
    call toc_01_27ED
    bit  2, a
    jr   z, .else_06_42F3

    and  %00000011
    jr   .toc_06_4303

JumpTable_42D7_06.else_06_42F3:
    call toc_06_659E
    push de
    call toc_06_65AE
    ld   a, e
    and  %00000011
    dec  a
    dec  a
    sla  a
    pop  de
    or   e
JumpTable_42D7_06.toc_06_4303:
    ld   e, a
    ld   hl, $C380
    add  hl, bc
    ld   [hl], e
    ld   d, b
    ld   hl, $42CF
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $42D3
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
JumpTable_42D7_06.else_06_431E:
    jp   JumpTable_4278_06.else_06_42AF

JumpTable_4321_06:
    call toc_01_3BEB
    call toc_01_0891
    jr   nz, .else_06_4339

JumpTable_4321_06.toc_06_4329:
    call JumpTable_3B8D_00
    ld   [hl], b
    call toc_01_0887
    call toc_01_27ED
    and  %00011111
    add  a, $08
    ld   [hl], a
    ret


JumpTable_4321_06.else_06_4339:
    assign [$D3E6], $01
    ld   hl, $C320
    add  hl, bc
    ld   [hl], b
    ld   a, [$FFE7]
    and  %00000011
    jr   nz, .else_06_4359

    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    sub  a, $0C
    jr   z, .else_06_4359

    and  %10000000
    jr   z, .else_06_4358

    inc  [hl]
    inc  [hl]
JumpTable_4321_06.else_06_4358:
    dec  [hl]
JumpTable_4321_06.else_06_4359:
    ifEq [$FF9D], $FF, .else_06_43C6

    call toc_06_659E
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    cp   e
    jr   nz, .else_06_43C6

    call toc_06_659E
    add  a, $40
    cp   $80
    jr   nc, .else_06_43C6

    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    push hl
    push af
    ld   a, [$FFEC]
    ld   [hl], a
    call toc_06_65AE
    ld   e, a
    pop  af
    pop  hl
    ld   [hl], a
    ld   a, e
    add  a, $30
    cp   $60
    jr   nc, .else_06_43C6

    ld   a, $08
    call toc_01_3C30
    ld   a, [$FFD7]
    cpl
    inc  a
    ld   [$FF9B], a
    ld   a, [$FFD8]
    cpl
    inc  a
    ld   [$FF9A], a
    push bc
    call toc_01_20D6
    call toc_01_3E49
    pop  bc
    ld   hl, $FFEE
    ld   a, [$FF98]
    sub  a, [hl]
    add  a, $04
    cp   $08
    jr   nc, .else_06_43C6

    ld   hl, $FFEC
    ld   a, [$FF99]
    sub  a, [hl]
    add  a, $04
    cp   $08
    jr   nc, .else_06_43C6

    call toc_01_0891
    ld   [hl], $80
    call JumpTable_3B8D_00
JumpTable_4321_06.else_06_43C6:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    rla
    and  %00000110
    or   $01
    call toc_01_3B87
    ret


JumpTable_43D4_06:
    call toc_01_0891
    jr   z, .else_06_4404

    ifNot [$FFE8], .else_06_43F1

    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_06_43F1

    inc  [hl]
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $0C
    assign [$FFF2], $09
JumpTable_43D4_06.else_06_43F1:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    add  a, $08
    call toc_01_3B87
    assign [$FF9D], $FF
    assign [$FFA1], $02
    ret


JumpTable_43D4_06.else_06_4404:
    ld   [hl], $0C
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], b
    clear [$FF9B]
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    ld   a, $18
    jr   z, .else_06_441B

    ld   a, $E8
JumpTable_43D4_06.else_06_441B:
    ld   [$FF9A], a
    assign [$FFA3], $10
    assign [$DBC7], $20
    assign [$C146], $02
    assign [$DB94], $02
    assign [$FFF2], $08
    call JumpTable_3B8D_00
    ret


JumpTable_4438_06:
    call toc_01_0891
    jp   z, JumpTable_4321_06.toc_06_4329

    ld   hl, $C320
    add  hl, bc
    ld   [hl], b
    jp   JumpTable_4321_06.else_06_43C6

    db   $62, $20, $60, $20, $68, $20, $66, $20
    db   $60, $00, $62, $00, $66, $00, $68, $00
    db   $62, $20, $60, $20, $68, $20, $66, $20
    db   $60, $00, $62, $00, $66, $00, $68, $00
    db   $00, $FC, $62, $20, $00, $04, $6A, $20
    db   $00, $0C, $64, $20, $00, $FC, $64, $00
    db   $00, $04, $6A, $00, $00, $0C, $62, $00
    db   $00, $FC, $62, $20, $00, $04, $6A, $20
    db   $00, $0C, $64, $20, $00, $FC, $64, $00
    db   $00, $04, $6A, $00, $00, $0C, $62, $00
    db   $00, $0E, $24, $00, $F8, $18, $24, $00
    db   $08, $18, $24, $00, $FE, $13, $24, $00
    db   $03, $13, $24, $00, $03, $13, $FF, $00
    db   $00, $FA, $24, $00, $F8, $F0, $24, $00
    db   $08, $F0, $24, $00, $FE, $F5, $24, $00
    db   $03, $F5, $24, $00, $03, $F5, $FF, $00
    db   $F0, $F1, $FE, $08, $30, $37, $11, $46
    db   $44, $CD, $3B, $3C, $F0, $F0, $FE, $02
    db   $20, $2A, $21, $80, $C3, $09, $7E, $17
    db   $E6, $02, $5F, $F0, $E7, $1F, $1F, $1F
    db   $E6, $01, $B3, $17, $17, $E6, $FC, $5F
    db   $17, $E6, $F8, $83, $5F, $50, $21, $96
    db   $44, $19, $0E, $03, $CD, $26, $3D, $3E
    db   $03, $CD, $D0, $3D, $C9, $D6, $08, $17
    db   $17, $E6, $FC, $5F, $CB, $27, $83, $5F
    db   $50, $21, $66, $44, $19, $0E, $03, $CD
    db   $26, $3D, $C3, $19, $3D, $21, $40, $C4
    db   $09, $7E, $A7, $C2, $99, $47, $79, $EA
    db   $02, $D2, $21, $D0, $C2, $09, $7E, $A7
    db   $20, $21, $34, $3E, $92, $CD, $01, $3C
    db   $7B, $EA, $01, $D2, $F0, $D8, $C6, $10
    db   $21, $10, $C2, $19, $77, $F0, $D7, $C6
    db   $30, $21, $00, $C2, $19, $77, $21, $40
    db   $C4, $19, $34, $CD, $7F, $47, $CD, $12
    db   $3F, $F0, $EA, $FE, $05, $C2, $CB, $53
    db   $CD, $DF, $64, $CD, $01, $65, $CD, $B4
    db   $3B, $CD, $84, $65, $21, $20, $C3, $09
    db   $35, $35, $35, $21, $10, $C3, $09, $7E
    db   $E6, $80, $E0, $E8, $28, $06, $70, $21
    db   $20, $C3, $09, $70, $F0, $F0, $C7

    dw JumpTable_458F_06 ; 00
    dw JumpTable_4615_06 ; 01
    dw JumpTable_4683_06 ; 02
    dw JumpTable_46DE_06 ; 03
    dw JumpTable_472B_06 ; 04

JumpTable_458F_06:
    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C290
    add  hl, de
    ld   a, [hl]
    cp   $00
    jr   nz, .else_06_45F4

    ld   a, [$FF98]
    push af
    ld   a, [$FF99]
    push af
    ld   hl, $C200
    add  hl, de
    ld   a, [hl]
    ld   [$FF98], a
    ld   hl, $C210
    add  hl, de
    ld   a, [hl]
    ld   [$FF99], a
    ld   a, $10
    call toc_01_3C25
    call toc_06_654B
    call toc_01_3B9E
    call toc_06_659E
    ld   hl, $C380
    add  hl, bc
    ld   [hl], e
    add  a, $0C
    cp   $18
    jr   nc, .else_06_45EC

    call toc_06_65AE
    add  a, $0C
    cp   $18
    jr   nc, .else_06_45EC

    call JumpTable_3B8D_00
    ld   [hl], $02
    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C290
    add  hl, de
    ld   [hl], $01
    call toc_01_0891
    ld   [hl], $1F
    assign [$FFF3], $1C
JumpTable_458F_06.else_06_45EC:
    pop  af
    ld   [$FF99], a
    pop  af
    ld   [$FF98], a
    jr   .toc_06_45F7

JumpTable_458F_06.else_06_45F4:
    call JumpTable_3B8D_00
JumpTable_458F_06.toc_06_45F7:
    ifNot [$FFE8], .else_06_4602

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $10
JumpTable_458F_06.else_06_4602:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    call toc_01_3B87
    ret


    db   $0C, $F4, $0C, $F4, $FC, $FC, $04, $04

JumpTable_4615_06:
    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C290
    add  hl, de
    ld   a, [hl]
    cp   $00
    jr   nz, .else_06_4627

    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_4615_06.else_06_4627:
    call toc_01_0891
    jr   nz, .else_06_4651

    call toc_01_27ED
    and  %00011111
    add  a, $10
    ld   [hl], a
    and  %00000011
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
    ld   e, a
    ld   d, b
    ld   hl, $460D
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $4611
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
JumpTable_4615_06.else_06_4651:
    call toc_06_654B
    call toc_01_3B9E
    call JumpTable_458F_06.toc_06_45F7
    ld   a, [$FFE7]
    and  %00001000
    jr   z, .return_06_4662

    inc  [hl]
    inc  [hl]
JumpTable_4615_06.return_06_4662:
    ret


    db   $00, $02, $04, $06, $08, $0A, $0C, $0E
    db   $00, $FE, $FC, $FA, $F8, $F6, $F4, $F2
    db   $F0, $F1, $F2, $F4, $F6, $F8, $FA, $FE
    db   $F0, $F1, $F2, $F4, $F6, $F8, $FA, $FE

JumpTable_4683_06:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    rla
    rla
    rla
    and  %00001000
    ld   e, a
    call toc_01_0891
    jr   nz, .else_06_469B

    ld   [hl], $20
    call JumpTable_3B8D_00
    ret


JumpTable_4683_06.else_06_469B:
    rra
    rra
    and  %00000111
    or   e
JumpTable_4683_06.toc_06_46A0:
    push bc
    ld   c, a
    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   a, [$FFEE]
    ld   hl, $4663
    add  hl, bc
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $4673
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    pop  bc
    ld   hl, $C310
    add  hl, bc
    add  a, [hl]
    ld   hl, $C310
    add  hl, de
    ld   [hl], a
    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    add  a, $02
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
JumpTable_4683_06.toc_06_46D1:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    or   $02
    call toc_01_3B87
    ret


JumpTable_46DE_06:
    xor  a
    call JumpTable_4683_06.toc_06_46A0
    call toc_01_0891
    jr   nz, .else_06_4711

    ld   [hl], $20
    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C290
    add  hl, de
    ld   [hl], $04
    push bc
    push de
    pop  bc
    ld   a, $20
    call toc_01_3C25
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $18
    pop  bc
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $20
    assign [$FFF2], $08
    call JumpTable_3B8D_00
    ret


JumpTable_46DE_06.else_06_4711:
    call JumpTable_458F_06.toc_06_45F7
    ld   a, $04
    call toc_01_3C25
    call toc_06_659E
    ld   hl, $C380
    add  hl, bc
    ld   [hl], e
    call JumpTable_4683_06.toc_06_46D1
    call toc_06_654B
    call toc_01_3B9E
    ret


JumpTable_472B_06:
    call toc_01_0891
    jr   nz, .else_06_4734

    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_472B_06.else_06_4734:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    call toc_01_3B87
    ret


    db   $00, $FC, $64, $20, $00, $04, $62, $20
    db   $00, $0C, $60, $20, $F0, $FC, $6C, $20
    db   $00, $FC, $60, $00, $00, $04, $62, $00
    db   $00, $0C, $64, $00, $F0, $0C, $6C, $00
    db   $00, $FC, $6A, $20, $00, $04, $68, $20
    db   $00, $0C, $66, $20, $F0, $FC, $6C, $00
    db   $00, $FC, $66, $00, $00, $04, $68, $00
    db   $00, $0C, $6A, $00, $F0, $0C, $6C, $20
    db   $F0, $F1, $17, $17, $17, $17, $E6, $F0
    db   $5F, $50, $21, $3F, $47, $19, $0E, $04
    db   $CD, $26, $3D, $C3, $19, $3D, $6E, $00
    db   $6E, $20, $21, $40, $C3, $09, $36, $92
    db   $21, $D0, $C5, $09, $36, $FF, $11, $95
    db   $47, $CD, $3B, $3C, $CD, $DF, $64, $CD
    db   $E2, $08, $CD, $EB, $3B, $CD, $4B, $65
    db   $CD, $84, $65, $21, $20, $C3, $09, $35
    db   $35, $21, $10, $C3, $09, $7E, $E0, $E9
    db   $E6, $80, $E0, $E8, $28, $25, $70, $21
    db   $20, $C3, $09, $7E, $CB, $2F, $2F, $FE
    db   $07, $30, $03, $AF, $18, $04, $3E, $09
    db   $E0, $F2, $77, $21, $40, $C2, $09, $CB
    db   $2E, $CB, $2E, $21, $50, $C2, $09, $CB
    db   $2E, $CB, $2E, $CD, $9E, $3B, $F0, $F0
    db   $C7

    dw JumpTable_4802_06 ; 00
    dw JumpTable_486B_06 ; 01
    dw JumpTable_486C_06 ; 02
    dw JumpTable_486D_06 ; 03
    dw JumpTable_48F5_06 ; 04

JumpTable_4802_06:
    ld   a, [$FFE9]
    dec  a
    and  %10000000
    jr   z, .else_06_481E

    ld   hl, $C250
    call .toc_06_4812
    ld   hl, $C240
JumpTable_4802_06.toc_06_4812:
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_06_481E

    and  %10000000
    jr   z, .else_06_481D

    inc  [hl]
    inc  [hl]
JumpTable_4802_06.else_06_481D:
    dec  [hl]
JumpTable_4802_06.else_06_481E:
    call toc_01_3BD5
    jr   nc, .return_06_486A

    ld   a, [$C19B]
    and  a
    jr   nz, .return_06_486A

    ifNe [$DB00], $03, .else_06_4838

    ld   a, [$FFCC]
    and  %00100000
    jr   nz, .else_06_4845

    jr   .return_06_486A

JumpTable_4802_06.else_06_4838:
    ifNe [$DB01], $03, .return_06_486A

    ld   a, [$FFCC]
    and  %00010000
    jr   z, .return_06_486A

JumpTable_4802_06.else_06_4845:
    ld   a, [$C3CF]
    and  a
    jr   nz, .return_06_486A

    call JumpTable_3B8D_00
    ld   [hl], $02
    ld   hl, $C280
    add  hl, bc
    ld   [hl], $07
    ld   hl, $C490
    add  hl, bc
    ld   [hl], b
    copyFromTo [$FF9E], [$C15D]
    call toc_01_0891
    ld   [hl], $02
    ld   hl, $FFF3
    ld   [hl], $02
JumpTable_4802_06.return_06_486A:
    ret


JumpTable_486B_06:
    ret


JumpTable_486C_06:
    ret


JumpTable_486D_06:
    ld   a, [$D202]
    ld   e, a
    ld   d, b
    ld   hl, $C200
    add  hl, de
    ld   a, [$FFEE]
    sub  a, [hl]
    add  a, $0C
    cp   $18
    jp   nc, .else_06_48F3

    ld   hl, $C210
    add  hl, de
    ld   a, [$FFEC]
    sub  a, [hl]
    add  a, $0C
    cp   $18
    jr   nc, .else_06_48F3

    ld   hl, $C410
    add  hl, de
    ld   [hl], $10
    ld   hl, $C420
    add  hl, de
    ld   [hl], $20
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    push hl
    ld   hl, $C3F0
    add  hl, de
    ld   [hl], a
    pop  hl
    cpl
    inc  a
    sra  a
    ld   [hl], a
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    push hl
    ld   hl, $C400
    add  hl, de
    ld   [hl], a
    pop  hl
    cpl
    inc  a
    sra  a
    ld   [hl], a
    assign [$FFF3], $07
    ld   hl, $C360
    add  hl, de
    ld   a, [hl]
    sub  a, $02
    ld   [hl], a
    dec  a
    and  %10000000
    jr   z, .else_06_48EF

    ld   hl, $C280
    add  hl, de
    ld   [hl], $01
    ld   hl, $C280
    add  hl, bc
    ld   [hl], $01
    ld   hl, $C480
    add  hl, bc
    ld   [hl], $1F
    ld   hl, $C340
    add  hl, bc
    ld   a, [hl]
    ld   [hl], $04
    ld   hl, $C430
    add  hl, bc
    res  7, [hl]
    assign [$FFF3], $10
JumpTable_486D_06.else_06_48EF:
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_486D_06.else_06_48F3:
    jr   JumpTable_48F5_06.toc_06_4904

JumpTable_48F5_06:
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $12
    call toc_01_3BBF
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $92
JumpTable_48F5_06.toc_06_4904:
    ld   a, [$FFE8]
    and  a
    jr   nz, .else_06_4924

    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_06_4928

    and  %00000011
    jr   z, .else_06_491A

    ld   hl, $C240
    jr   .toc_06_491D

JumpTable_48F5_06.else_06_491A:
    ld   hl, $C250
JumpTable_48F5_06.toc_06_491D:
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    sra  a
    ld   [hl], a
JumpTable_48F5_06.else_06_4924:
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_48F5_06.return_06_4928:
    ret


    db   $74, $00, $76, $00, $76, $20, $74, $20
    db   $70, $00, $72, $00, $72, $20, $70, $20
    db   $78, $00, $7A, $00, $7A, $20, $78, $20
    db   $7C, $00, $7E, $00, $7E, $20, $7C, $20
    db   $21, $60, $C3, $09, $36, $20, $11, $29
    db   $49, $CD, $3B, $3C, $CD, $DF, $64, $CD
    db   $E2, $08, $CD, $4B, $65, $CD, $9E, $3B
    db   $F0, $F0, $C7

    dw JumpTable_496A_06 ; 00
    dw JumpTable_49BD_06 ; 01
    dw JumpTable_49EE_06 ; 02

JumpTable_496A_06:
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_06_497A

    ld   [hl], $20
    call toc_01_3DAF
    call JumpTable_3B8D_00
JumpTable_496A_06.else_06_497A:
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
JumpTable_496A_06.toc_06_497F:
    ld   hl, $C380
    add  hl, bc
    ld   a, [$FFE7]
    and  %00001111
    jr   nz, .else_06_498E

    ld   a, [hl]
    inc  a
    and  %00000011
    ld   [hl], a
JumpTable_496A_06.else_06_498E:
    ld   e, [hl]
    sla  e
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    rra
    rra
    rra
    and  %00000001
    or   e
    call toc_01_3B87
    ld   hl, $C410
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_06_49B4

    call JumpTable_3B8D_00
    ld   [hl], $02
    call toc_01_0891
    ld   [hl], $40
    call toc_01_3DAF
JumpTable_496A_06.return_06_49B4:
    ret


    db   $0C, $F4, $00, $00, $00, $00, $F4, $0C

JumpTable_49BD_06:
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_06_49EC

    call toc_01_27ED
    and  %00011111
    add  a, $20
    ld   [hl], a
    call JumpTable_3B8D_00
    ld   [hl], b
    call toc_01_27ED
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $49B5
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $49B9
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
JumpTable_49BD_06.else_06_49EC:
    jr   JumpTable_496A_06.toc_06_497F

JumpTable_49EE_06:
    ld   hl, $C460
    add  hl, bc
    ld   a, [hl]
    and  a
    jp   nz, .return_06_4AC1

    ld   [$FFD7], a
    ld   e, $0F
    ld   d, b
JumpTable_49EE_06.loop_06_49FC:
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_06_4A23

    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $90
    jr   nz, .else_06_4A23

    ld   hl, $C290
    add  hl, de
    ld   a, [hl]
    cp   $02
    jr   nz, .else_06_4A23

    ld   hl, $C2E0
    add  hl, de
    ld   a, [hl]
    and  a
    jr   nz, .else_06_4A23

    ld   a, [$FFD7]
    inc  a
    ld   [$FFD7], a
JumpTable_49EE_06.else_06_4A23:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_06_49FC

    ld   a, [$FFD7]
    cp   $03
    jp   nz, .return_06_4AC1

    push bc
    ld   c, b
    ld   e, $0F
    ld   d, b
JumpTable_49EE_06.loop_06_4A35:
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_06_4A51

    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $90
    jr   nz, .else_06_4A51

    ld   hl, $C380
    add  hl, de
    ld   a, [hl]
    ld   hl, $FFD9
    add  hl, bc
    ld   [hl], a
    inc  bc
JumpTable_49EE_06.else_06_4A51:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_06_4A35

    pop  bc
    call toc_01_08AC
    ld   e, $00
    ld   a, [$FFD9]
    ld   hl, $FFDA
    cp   [hl]
    jr   nz, .else_06_4A7C

    inc  hl
    cp   [hl]
    jr   nz, .else_06_4A7C

    ld   e, $FF
    cp   $02
    jr   nc, .else_06_4A7C

    ld   hl, $FFF2
    ld   [hl], $02
    ld   e, $2D
    cp   $01
    jr   nz, .else_06_4A7C

    ld   e, $2E
JumpTable_49EE_06.else_06_4A7C:
    ld   a, e
    ld   [$FFE8], a
    ld   e, $0F
    ld   d, b
JumpTable_49EE_06.loop_06_4A82:
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_06_4ABB

    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $90
    jr   nz, .else_06_4ABB

    ld   a, [$FFE8]
    and  a
    jr   nz, .else_06_4A9F

    ld   hl, $C290
    add  hl, de
    ld   [hl], d
    jr   .else_06_4ABB

JumpTable_49EE_06.else_06_4A9F:
    ld   hl, $C4E0
    add  hl, de
    ld   [hl], a
    ld   hl, $C480
    add  hl, de
    ld   [hl], $1F
    ld   hl, $C280
    add  hl, de
    ld   [hl], $01
    ld   hl, $C340
    add  hl, de
    ld   [hl], $04
    ld   hl, $FFF4
    ld   [hl], $13
JumpTable_49EE_06.else_06_4ABB:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_06_4A82

JumpTable_49EE_06.return_06_4AC1:
    ret


    db   $4A, $00, $4C, $00, $4C, $20, $4A, $20
    db   $4E, $00, $4E, $20, $11, $C2, $4A, $CD
    db   $3B, $3C, $CD, $DF, $64, $CD, $01, $65
    db   $CD, $B4, $3B, $F0, $F0, $C7

    dw JumpTable_4AE8_06 ; 00
    dw JumpTable_4AF1_06 ; 01
    dw JumpTable_4B2D_06 ; 02
    dw JumpTable_4B54_06 ; 03

JumpTable_4AE8_06:
    call toc_01_0891
    jr   nz, .return_06_4AF0

    call JumpTable_3B8D_00
JumpTable_4AE8_06.return_06_4AF0:
    ret


JumpTable_4AF1_06:
    ld   a, [$FFE7]
    xor  c
    and  %00000011
    jr   nz, .else_06_4AFD

    ld   a, $08
    call toc_01_3C25
JumpTable_4AF1_06.else_06_4AFD:
    call toc_06_659E
    add  a, $1C
    cp   $38
    jr   nc, .else_06_4B1D

    call toc_06_65AE
    add  a, $1C
    cp   $38
    jr   nc, .else_06_4B1D

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $28
    ld   a, $10
    call toc_01_3C25
    call JumpTable_3B8D_00
JumpTable_4AF1_06.else_06_4B1D:
    call toc_06_654B
    call toc_01_3B9E
    ld   a, [$FFE7]
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


JumpTable_4B2D_06:
    call toc_06_654B
    call toc_01_3B9E
    call toc_06_6584
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    dec  [hl]
    ld   a, [hl]
    cp   $02
    jr   nc, .else_06_4B4E

    ld   [hl], $C0
    call toc_01_0891
    ld   [hl], $10
    call toc_01_3DAF
    call JumpTable_3B8D_00
JumpTable_4B2D_06.else_06_4B4E:
    ld   a, $02
    call toc_01_3B87
    ret


JumpTable_4B54_06:
    call toc_01_0891
    jr   nz, .return_06_4B8D

    call toc_06_6584
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_06_4B68

    and  %10000000
    jr   z, .return_06_4B8D

JumpTable_4B54_06.else_06_4B68:
    ld   [hl], b
    call toc_01_0891
    ld   [hl], $20
    call JumpTable_3B8D_00
    ld   [hl], b
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    ld   [hl], b
    bit  7, a
    jr   z, .return_06_4B8D

    cp   $D0
    jr   nc, .return_06_4B8D

    copyFromTo [$FFEE], [$FFD7]
    ld   a, [$FFEC]
    add  a, $0C
    ld   [$FFD8], a
    call toc_01_0993.toc_01_09A1
JumpTable_4B54_06.return_06_4B8D:
    ret


    db   $00, $03, $01, $02, $21, $B0, $C2, $09
    db   $7E, $A7, $C2, $A4, $4E, $21, $D0, $C2
    db   $09, $7E, $A7, $20, $0D, $34, $21, $60
    db   $C3, $09, $36, $08, $21, $40, $C4, $09
    db   $36, $01, $CD, $0E, $38, $CD, $7F, $4E
    db   $F0, $EA, $FE, $05, $C2, $CB, $53, $CD
    db   $DF, $64, $CD, $12, $3F, $CD, $E2, $08
    db   $CD, $BF, $3B, $CD, $4B, $65, $FA, $46
    db   $C1, $A7, $20, $27, $21, $30, $C4, $09
    db   $36, $C4, $F0, $F0, $A7, $20, $19, $21
    db   $80, $C3, $09, $5E, $50, $21, $8E, $4B
    db   $19, $7E, $F5, $CD, $BE, $65, $F1, $BB
    db   $28, $06, $21, $30, $C4, $09, $36, $84
    db   $CD, $EB, $3B, $F0, $F0, $C7

    dw JumpTable_4C38_06 ; 00
    dw JumpTable_4D55_06 ; 01

    db   $14, $00, $EC, $00, $00, $14, $00, $EC
    db   $06, $07, $00, $01, $04, $05, $02, $03
    db   $10, $10, $F4, $0C, $F0, $F0, $F4, $0C
    db   $F4, $0C, $10, $10, $F4, $0C, $F0, $F0
    db   $80, $80, $80, $7F, $7F, $7F, $80, $7F
    db   $80, $7F, $80, $80, $80, $7F, $7F, $7F
    db   $00, $02, $00, $01, $01, $03, $02, $03

JumpTable_4C38_06:
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_06_4C68

    call toc_06_4C72
    call JumpTable_3B8D_00
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C390
    add  hl, bc
    ld   [hl], a
    call toc_01_0891
    ld   [hl], $58
    call toc_01_27ED
    and  %00000001
    jr   nz, .else_06_4C64

    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    ld   [hl], a
JumpTable_4C38_06.else_06_4C64:
    call toc_01_3DAF
    ret


JumpTable_4C38_06.else_06_4C68:
    call toc_01_0891
    jr   z, toc_06_4C72

    cp   $01
    jr   z, toc_06_4C9D

    ret


toc_06_4C72:
    ld   hl, $C200
    add  hl, bc
    ld   a, [hl]
    cp   $20
    jr   c, .else_06_4C91

    cp   $80
    jr   nc, .else_06_4C91

    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    cp   $28
    jr   c, .else_06_4C8C

    cp   $68
    jr   c, toc_06_4CAB

toc_06_4C72.else_06_4C8C:
    ld   a, [$FFEF]
    ld   [hl], a
    jr   .toc_06_4C94

toc_06_4C72.else_06_4C91:
    ld   a, [$FFEE]
    ld   [hl], a
toc_06_4C72.toc_06_4C94:
    call toc_01_0891
    ld   [hl], $15
    call toc_01_3DAF
    ret


toc_06_4C9D:
    ld   hl, $C440
    add  hl, bc
    ld   e, [hl]
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    add  a, e
    and  %00000011
    ld   [hl], a
toc_06_4CAB:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    ld   e, a
    ld   d, b
    ld   hl, $4C00
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $4C04
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    sla  e
    ld   a, [$FFE7]
    rra
    rra
    rra
    and  %00000001
    or   e
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $4C08
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ld   a, [$FFE7]
    and  %00001111
    jr   nz, .return_06_4D54

    assign [$FFF4], $2F
    ld   a, $01
toc_06_4CAB.loop_06_4CE8:
    ld   [$FFE8], a
    ld   a, $8E
    call toc_01_3C01
    jr   c, .return_06_4D54

    push bc
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    sla  a
    ld   hl, $FFE8
    or   [hl]
    ld   c, a
    ld   hl, $4C10
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $4C18
    add  hl, bc
    ld   a, [$FFD8]
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $4C20
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $4C28
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C250
    add  hl, de
    ld   [hl], a
    ld   hl, $4C30
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $01
    ld   hl, $C340
    add  hl, de
    ld   [hl], $C2
    ld   hl, $C430
    add  hl, de
    ld   [hl], $00
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $0C
    pop  bc
    ld   a, [$FFE8]
    dec  a
    cp   $FF
    jr   nz, .loop_06_4CE8

toc_06_4CAB.return_06_4D54:
    ret


JumpTable_4D55_06:
    call toc_01_0891
    jr   nz, .else_06_4D6B

    ld   hl, $C390
    add  hl, bc
    ld   a, [hl]
    xor  $02
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_4D55_06.else_06_4D6B:
    and  %00000011
    jr   nz, .else_06_4D78

    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    inc  a
    and  %00000011
    ld   [hl], a
JumpTable_4D55_06.else_06_4D78:
    call toc_06_4CAB
    call toc_01_3DAF
    ret


    db   $F8, $F8, $60, $00, $F8, $00, $62, $00
    db   $F8, $08, $62, $20, $F8, $10, $60, $20
    db   $08, $F8, $64, $00, $08, $00, $66, $00
    db   $08, $08, $66, $20, $08, $10, $64, $20
    db   $FA, $F8, $60, $00, $FA, $00, $62, $00
    db   $FA, $08, $62, $20, $FA, $10, $60, $20
    db   $08, $F8, $64, $00, $08, $00, $66, $00
    db   $08, $08, $66, $20, $08, $10, $64, $20
    db   $F8, $F8, $64, $40, $F8, $00, $66, $40
    db   $F8, $08, $66, $60, $F8, $10, $64, $60
    db   $08, $F8, $60, $40, $08, $00, $62, $40
    db   $08, $08, $62, $60, $08, $10, $60, $60
    db   $F8, $F8, $64, $40, $F8, $00, $66, $40
    db   $F8, $08, $66, $60, $F8, $10, $64, $60
    db   $06, $F8, $60, $40, $06, $00, $62, $40
    db   $06, $08, $62, $60, $06, $10, $60, $60
    db   $F8, $F8, $68, $00, $F8, $00, $6A, $00
    db   $F8, $08, $62, $20, $F8, $10, $60, $20
    db   $08, $F8, $68, $40, $08, $00, $6A, $40
    db   $08, $08, $62, $60, $08, $10, $60, $60
    db   $F8, $F8, $68, $00, $F8, $00, $6A, $00
    db   $F8, $06, $62, $20, $F8, $0E, $60, $20
    db   $08, $F8, $68, $40, $08, $00, $6A, $40
    db   $08, $06, $62, $60, $08, $0E, $60, $60
    db   $F8, $F8, $60, $00, $F8, $00, $62, $00
    db   $F8, $08, $6A, $20, $F8, $10, $68, $20
    db   $08, $F8, $60, $40, $08, $00, $62, $40
    db   $08, $08, $6A, $60, $08, $10, $68, $60
    db   $F8, $FA, $60, $00, $F8, $02, $62, $00
    db   $F8, $08, $6A, $20, $F8, $10, $68, $20
    db   $08, $FA, $60, $40, $08, $02, $62, $40
    db   $08, $08, $6A, $60, $08, $10, $68, $60
    db   $F0, $F1, $17, $17, $17, $17, $17, $E6
    db   $E0, $5F, $50, $21, $7F, $4D, $19, $0E
    db   $08, $CD, $26, $3D, $C9, $6C, $00, $6E
    db   $00, $6E, $20, $6C, $20, $6C, $40, $6E
    db   $40, $6E, $60, $6C, $60, $11, $94, $4E
    db   $CD, $3B, $3C, $CD, $DF, $64, $CD, $91
    db   $08, $CA, $E5, $65, $FE, $06, $20, $03
    db   $CD, $4B, $65, $C9, $F8, $10, $FA, $10
    db   $F0, $F0, $A7, $20, $11, $21, $00, $C2
    db   $09, $7E, $C6, $08, $77, $21, $10, $C3
    db   $09, $36, $10, $C3, $8D, $3B, $11, $BB
    db   $4E, $CD, $3B, $3C, $CD, $DF, $64, $F0
    db   $BA, $FE, $02, $28, $2C, $A7, $28, $1A
    db   $21, $D0, $C3, $09, $34, $7E, $FE, $0A
    db   $20, $0F, $70, $3E, $11, $E0, $F4, $21
    db   $10, $C3, $09, $7E, $FE, $20, $30, $01
    db   $34, $C9, $21, $10, $C3, $09, $7E, $A7
    db   $28, $24, $F0, $E7, $E6, $0F, $20, $01
    db   $35, $7E, $FE, $04, $30, $17, $CD, $D5
    db   $3B, $30, $1B, $3E, $08, $EA, $3E, $C1
    db   $3E, $10, $CD, $30, $3C, $F0, $D7, $E0
    db   $9B, $F0, $D8, $E0, $9A, $C9, $CD, $D5
    db   $3B, $30, $03, $CD, $4E, $64, $C9, $F0
    db   $F0, $A7, $C2, $D5, $4E, $21, $10, $C2
    db   $09, $7E, $C6, $08, $77, $21, $10, $C3
    db   $09, $36, $10, $C3, $8D, $3B, $44, $00
    db   $44, $20, $46, $00, $46, $20, $64, $00
    db   $64, $20, $66, $00, $66, $20, $11, $4D
    db   $4F, $F0, $F7, $FE, $0A, $20, $03, $11
    db   $55, $4F, $CD, $3B, $3C, $CD, $DF, $64
    db   $CD, $01, $65, $CD, $B4, $3B, $CD, $4B
    db   $65, $CD, $9E, $3B, $F0, $E7, $1F, $1F
    db   $1F, $E6, $01, $CD, $87, $3B, $F0, $E7
    db   $A9, $E6, $03, $20, $44, $CD, $ED, $27
    db   $A9, $E6, $07, $C6, $04, $CD, $30, $3C
    db   $F0, $D7, $21, $50, $C2, $CD, $C4, $4F
    db   $21, $A0, $C2, $09, $7E, $E6, $0C, $28
    db   $05, $21, $50, $C2, $09, $70, $F0, $D8
    db   $21, $40, $C2, $CD, $C4, $4F, $21, $A0
    db   $C2, $09, $7E, $E6, $03, $28, $05, $21
    db   $40, $C2, $09, $70, $C9, $09, $96, $28
    db   $08, $CB, $7F, $28, $03, $35, $18, $01
    db   $34, $C9, $FF, $00, $FF, $20, $3A, $00
    db   $3A, $20, $3C, $00, $3C, $20, $3C, $00
    db   $3C, $20, $58, $78, $78, $28, $28, $28
    db   $78, $58, $28, $78, $28, $78, $28, $78
    db   $58, $58, $28, $78, $28, $78, $40, $30
    db   $50, $50, $30, $30, $50, $40, $50, $30
    db   $50, $50, $30, $30, $40, $40, $50, $30
    db   $30, $50, $F2, $00, $3A, $00, $F2, $08
    db   $3A, $20, $0E, $00, $3A, $00, $0E, $08
    db   $3A, $20, $F6, $0A, $3A, $00, $F6, $12
    db   $3A, $20, $0A, $F6, $3A, $00, $0A, $FE
    db   $3A, $20, $00, $0E, $3A, $00, $00, $16
    db   $3A, $20, $00, $F2, $3A, $00, $00, $FA
    db   $3A, $20, $0A, $0A, $3A, $00, $0A, $12
    db   $3A, $20, $F6, $F6, $3A, $00, $F6, $FE
    db   $3A, $20, $F0, $F0, $A7, $28, $1B, $CD
    db   $91, $08, $CA, $E5, $65, $17, $17, $E6
    db   $30, $5F, $50, $21, $09, $50, $19, $0E
    db   $04, $CD, $26, $3D, $3E, $02, $CD, $D0
    db   $3D, $C9, $CD, $DF, $64, $F0, $EB, $FE
    db   $8A, $20, $0F, $F0, $E7, $1F, $1F, $E6
    db   $03, $CD, $87, $3B, $11, $D1, $4F, $CD
    db   $3B, $3C, $21, $D0, $C3, $09, $F0, $B9
    db   $5F, $CB, $27, $CB, $27, $83, $86, $5F
    db   $50, $21, $E1, $4F, $19, $7E, $21, $00
    db   $C2, $09, $77, $21, $F5, $4F, $19, $7E
    db   $21, $10, $C2, $09, $77, $CD, $BA, $3D
    db   $21, $B0, $C2, $09, $F0, $B8, $BE, $28
    db   $47, $FE, $8D, $20, $43, $CD, $D5, $3B
    db   $30, $39, $21, $D0, $C3, $09, $7E, $FE
    db   $04, $20, $08, $CD, $E5, $65, $CD, $EC
    db   $08, $18, $2D, $34, $3E, $13, $E0, $F2
    db   $3E, $8A, $CD, $01, $3C, $38, $1A, $F0
    db   $D7, $21, $00, $C2, $19, $77, $F0, $D8
    db   $21, $10, $C2, $19, $77, $C5, $D5, $C1
    db   $CD, $8D, $3B, $CD, $91, $08, $36, $18
    db   $C1, $18, $05, $21, $D0, $C3, $09, $70
    db   $F0, $B8, $21, $B0, $C2, $09, $77, $C9
    db   $08, $F8, $00, $00, $00, $00, $F8, $08
    db   $CD, $8C, $53, $AF, $EA, $67, $C1, $F0
    db   $EA, $FE, $05, $C2, $CB, $53, $CD, $DF
    db   $64, $CD, $12, $3F, $CD, $01, $65, $CD
    db   $8C, $08, $28, $03, $CD, $01, $53, $F0
    db   $F0, $FE, $04, $30, $14, $21, $20, $C4
    db   $09, $7E, $FE, $03, $20, $0B, $CD, $8D
    db   $3B, $36, $05, $CD, $91, $08, $36, $20
    db   $C9, $F0, $F0, $C7

    dw JumpTable_51C4_06 ; 00
    dw JumpTable_514F_06 ; 01
    dw JumpTable_51F9_06 ; 02
    dw JumpTable_521C_06 ; 03
    dw JumpTable_528C_06 ; 04
    dw JumpTable_530D_06 ; 05

JumpTable_514F_06:
    call toc_01_3BB4
    call toc_01_0891
    jr   z, .else_06_516A

    cp   $0A
    jr   nz, .else_06_5166

    call toc_06_65BE
    ld   hl, $C380
    add  hl, bc
    ld   a, e
    cp   [hl]
    jr   nz, .else_06_5166

JumpTable_514F_06.else_06_5166:
    call toc_01_3B9E
    ret


JumpTable_514F_06.else_06_516A:
    ld   hl, $C2D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    cp   $02
    jr   nz, .else_06_5187

    ld   [hl], b
    call toc_01_27ED
    and  %00000001
    jr   nz, .else_06_5187

    call JumpTable_3B8D_00
    ld   [hl], $02
    call toc_01_0891
    ld   [hl], $30
    ret


JumpTable_514F_06.else_06_5187:
    call toc_01_0891
    call toc_01_27ED
    and  %00011111
    or   $20
    ld   [hl], a
    call JumpTable_3B8D_00
    ld   [hl], b
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    inc  a
    and  %00000011
    ld   [hl], a
    cp   $00
    jr   nz, .else_06_51A8

    call toc_06_65BE
    jr   .toc_06_51AB

JumpTable_514F_06.else_06_51A8:
    call toc_01_27ED
JumpTable_514F_06.toc_06_51AB:
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $50FF
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $5103
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ret


JumpTable_51C4_06:
    call toc_01_3BB4
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00001111
    jr   nz, .else_06_51D5

    call toc_01_0891
    jr   nz, .else_06_51E3

JumpTable_51C4_06.else_06_51D5:
    call toc_01_27ED
    and  %00001111
    or   $10
    ld   [hl], a
    call JumpTable_3B8D_00
    call toc_01_3DAF
JumpTable_51C4_06.else_06_51E3:
    call toc_06_654B
    call toc_01_3B9E
JumpTable_51C4_06.toc_06_51E9:
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


JumpTable_51F9_06:
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_06_520B

    ld   [hl], $20
    call JumpTable_3B8D_00
    ld   a, $18
    call toc_01_3C25
JumpTable_51F9_06.else_06_520B:
    call JumpTable_51C4_06.toc_06_51E9
    call JumpTable_51C4_06.toc_06_51E9
    ld   a, [$FFE7]
    and  %00001111
    jr   nz, .return_06_521B

    assign [$FFF2], $20
JumpTable_51F9_06.return_06_521B:
    ret


JumpTable_521C_06:
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_06_5228

    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_521C_06.else_06_5228:
    call toc_06_654B
    call toc_01_3B9E
    call toc_06_659E
    add  a, $18
    cp   $30
    jr   nc, .else_06_5253

    call toc_06_65AE
    add  a, $18
    cp   $30
    jr   nc, .else_06_5253

    ifNe [$C11C], $00, .else_06_5253

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $4F
    assign [$FFF3], $16
JumpTable_521C_06.else_06_5253:
    ld   a, [$FFE7]
    and  %00000111
    jr   nz, .else_06_5268

    copyFromTo [$FFEE], [$FFD7]
    ld   a, [$FFEC]
    add  a, $0A
    ld   [$FFD8], a
    ld   a, $0B
    call toc_01_0953
JumpTable_521C_06.else_06_5268:
    jr   JumpTable_51F9_06.else_06_520B

    db   $00, $00, $00, $00, $01, $01, $01, $01
    db   $00, $00, $EF, $EF, $EF, $EF, $EF, $EF
    db   $EF, $EF, $F3, $F7, $FB, $00, $15, $15
    db   $15, $15, $15, $14, $14, $14, $10, $08
    db   $04, $00

JumpTable_528C_06:
    call toc_01_0891
    jr   nz, .else_06_5296

    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_528C_06.else_06_5296:
    cp   $20
    jr   nz, .else_06_52CA

    assign [$FF9B], $20
    ld   a, [$FF98]
    cp   $50
    ld   a, $E0
    jr   nc, .else_06_52A8

    ld   a, $20
JumpTable_528C_06.else_06_52A8:
    ld   [$FF9A], a
    assign [$FFA3], $10
    assign [$C146], $02
    assign [$FFF2], $08
    assign [$DB94], $08
    copyFromTo [$FFEE], [$FF98]
    copyFromTo [$FFEF], [$FF99]
    call toc_01_088C
    ld   [hl], $50
    ret


JumpTable_528C_06.else_06_52CA:
    rra
    rra
    rra
    and  %00001111
    ld   e, a
    ld   d, b
    ld   hl, $526A
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    call toc_01_0891
    cp   $20
    jr   c, .return_06_530C

    sub  a, $20
    rra
    rra
    and  %00001111
    ld   e, a
    ld   d, b
    ld   hl, $5274
    add  hl, de
    ld   a, [$FFEE]
    add  a, [hl]
    ld   [$FF98], a
    ld   hl, $5280
    add  hl, de
    ld   a, [hl]
    ld   [$FFA2], a
    assign [$C146], $02
    copyFromTo [$FFEF], [$FF99]
    assign [$FFA1], $01
    assign [$FF9D], $6A
    ld   [$C167], a
JumpTable_528C_06.return_06_530C:
    ret


JumpTable_530D_06:
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_06_531A

    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_530D_06.else_06_531A:
    ld   e, $00
    cp   $10
    jr   c, .else_06_5321

    inc  e
JumpTable_530D_06.else_06_5321:
    cp   $10
    jr   nz, .else_06_5347

    ld   a, $02
    call toc_01_3C01
    jr   c, .else_06_5347

    ld   a, [$FFD7]
    sub  a, $0C
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    sub  a, $00
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C310
    add  hl, de
    ld   [hl], $10
    jp   JumpTable_41D4_06.toc_06_4202

JumpTable_530D_06.else_06_5347:
    ld   a, e
    call toc_01_3B87
    ret


    db   $F4, $F8, $60, $00, $F4, $00, $62, $00
    db   $F4, $08, $64, $00, $F4, $10, $66, $00
    db   $04, $F8, $68, $00, $04, $00, $6A, $00
    db   $04, $08, $6C, $00, $04, $10, $6E, $00
    db   $F4, $F8, $66, $20, $F4, $00, $64, $20
    db   $F4, $08, $62, $20, $F4, $10, $60, $20
    db   $04, $F8, $6E, $20, $04, $00, $6C, $20
    db   $04, $08, $6A, $20, $04, $10, $68, $20
    db   $F0, $F1, $17, $17, $17, $17, $17, $E6
    db   $E0, $5F, $50, $21, $4C, $53, $19, $0E
    db   $08, $CD, $26, $3D, $C9, $21, $60, $C4
    db   $09, $36, $FF, $21, $E0, $C4, $09, $36
    db   $30, $21, $60, $C3, $09, $7E, $FE, $08
    db   $30, $0C, $1E, $02, $FE, $04, $30, $02
    db   $1E, $03, $7B, $CD, $87, $3B, $CD, $80
    db   $56, $F0, $EA, $FE, $05, $28, $5D, $21
    db   $C0, $C2, $09, $7E, $C7

    dw JumpTable_53D9_06 ; 00
    dw JumpTable_53E8_06 ; 01
    dw JumpTable_53F9_06 ; 02
    dw JumpTable_5427_06 ; 03

JumpTable_53D9_06:
    call toc_01_0891
    ld   [hl], $A0
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $FF
    call JumpTable_56F6_06.toc_06_5701
    ret


JumpTable_53E8_06:
    call toc_01_0891
    jr   nz, .return_06_53F8

    ld   [hl], $C0
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $FF
    call JumpTable_56F6_06.toc_06_5701
JumpTable_53E8_06.return_06_53F8:
    ret


JumpTable_53F9_06:
    call toc_01_0891
    jr   nz, .else_06_5423

    assign [$FFF4], $1A
    call toc_01_27BD
    call toc_01_3F7A
    ld   a, [$FFEB]
    cp   $88
    ret  z

    ifEq [$FFEB], $89, .else_06_541B

    cp   $8E
    jr   z, .else_06_541B

    cp   $92
    jr   nz, .else_06_5420

JumpTable_53F9_06.else_06_541B:
    returnIfGte [$FFF7], $06

JumpTable_53F9_06.else_06_5420:
    jp   JumpTable_6C96_06.toc_06_6CB4

JumpTable_53F9_06.else_06_5423:
    call toc_06_6FFC
    ret


JumpTable_5427_06:
    ret


    db   $CD, $DF, $64, $CD, $12, $3F, $CD, $EB
    db   $3B, $CD, $49, $64, $CD, $84, $65, $21
    db   $20, $C3, $09, $35, $35, $21, $10, $C3
    db   $09, $7E, $E6, $80, $E0, $E8, $28, $06
    db   $70, $21, $20, $C3, $09, $70, $CD, $8C
    db   $08, $28, $08, $3E, $02, $E0, $A1, $3E
    db   $6A, $E0, $9D, $21, $60, $C3, $09, $7E
    db   $21, $B0, $C2, $09, $BE, $77, $CA, $D8
    db   $54, $FE, $08, $30, $6B, $FE, $04, $30
    db   $29, $21, $D0, $C3, $09, $7E, $FE, $02
    db   $30, $5E, $34, $3E, $05, $CD, $01, $3C
    db   $38, $56, $F0, $D7, $21, $00, $C2, $19
    db   $3D, $77, $E0, $D7, $F0, $D8, $21, $DA
    db   $FF, $96, $21, $10, $C2, $19, $D6, $10
    db   $18, $26, $21, $D0, $C3, $09, $7E, $FE
    db   $01, $30, $35, $34, $3E, $05, $CD, $01
    db   $3C, $38, $2D, $F0, $D7, $21, $00, $C2
    db   $19, $C6, $07, $77, $E0, $D7, $F0, $D8
    db   $21, $DA, $FF, $96, $21, $10, $C2, $19
    db   $77, $E0, $D8, $21, $F0, $C2, $19, $36
    db   $0F, $21, $40, $C3, $19, $36, $C4, $3E
    db   $02, $CD, $53, $09, $3E, $29, $E0, $F4
    db   $F0, $F0, $C7

    dw JumpTable_54EB_06 ; 00
    dw JumpTable_5509_06 ; 01
    dw JumpTable_551E_06 ; 02
    dw JumpTable_554F_06 ; 03
    dw JumpTable_5588_06 ; 04
    dw JumpTable_55A3_06 ; 05
    dw JumpTable_55B8_06 ; 06
    dw JumpTable_55E2_06 ; 07

JumpTable_54EB_06:
    call toc_01_08E2
    call toc_06_659E
    add  a, $20
    cp   $40
    jr   nc, .return_06_5508

    call toc_06_65AE
    add  a, $20
    cp   $40
    jr   nc, .return_06_5508

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $30
JumpTable_54EB_06.return_06_5508:
    ret


JumpTable_5509_06:
    call toc_01_08E2
    call toc_01_0891
    jr   nz, .else_06_5516

    ld   [hl], $80
    call JumpTable_3B8D_00
JumpTable_5509_06.else_06_5516:
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


JumpTable_551E_06:
    call toc_01_08E2
    call toc_01_0891
    jr   nz, .else_06_553E

    ld   [hl], $50
    call JumpTable_3B8D_00
    ld   hl, $C340
    add  hl, bc
    res  7, [hl]
    ld   hl, $C350
    add  hl, bc
    res  7, [hl]
    ld   hl, $C430
    add  hl, bc
    res  6, [hl]
    ret


JumpTable_551E_06.else_06_553E:
    ld   e, $08
    and  %00000100
    jr   z, .else_06_5546

    ld   e, $F8
JumpTable_551E_06.else_06_5546:
    ld   hl, $C240
    add  hl, bc
    ld   [hl], e
    call toc_06_6558
    ret


JumpTable_554F_06:
    call toc_06_6501
    call toc_01_0891
    jr   nz, .else_06_5565

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $30
    call JumpTable_3B8D_00
    assign [$FFF2], $24
    ret


JumpTable_554F_06.else_06_5565:
    ifNot [$FFE8], .else_06_5584

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $0C
    ld   hl, $C360
    add  hl, bc
    ld   a, [hl]
    cp   $05
    ld   a, $08
    jr   nc, .else_06_557D

    ld   a, $0C
JumpTable_554F_06.else_06_557D:
    call toc_01_3C25
    assign [$FFF2], $20
JumpTable_554F_06.else_06_5584:
    call toc_06_654B
    ret


JumpTable_5588_06:
    call toc_06_6501
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    and  %11111110
    jr   nz, .else_06_559F

    call toc_01_0891
    ld   [hl], $10
    call toc_01_3DAF
    call JumpTable_3B8D_00
JumpTable_5588_06.else_06_559F:
    call toc_06_654B
    ret


JumpTable_55A3_06:
    call toc_06_6501
    call toc_01_0891
    ld   a, $00
    jr   nz, .else_06_55B2

    call JumpTable_3B8D_00
    ld   a, $B0
JumpTable_55A3_06.else_06_55B2:
    ld   hl, $C320
    add  hl, bc
    ld   [hl], a
    ret


JumpTable_55B8_06:
    call toc_06_6501
    ifNot [$FFE8], .return_06_55E1

    assign [$C157], $30
    assign [$C158], $04
    assign [$FFF2], $0B
    call toc_01_0891
    ld   [hl], $30
    ld   a, [$C146]
    and  a
    jr   nz, .else_06_55DE

    call toc_01_088C
    ld   [hl], $40
JumpTable_55B8_06.else_06_55DE:
    call JumpTable_3B8D_00
JumpTable_55B8_06.return_06_55E1:
    ret


JumpTable_55E2_06:
    call toc_06_6501
    call toc_01_0891
    jr   nz, .return_06_55EF

    call JumpTable_3B8D_00
    ld   [hl], $02
JumpTable_55E2_06.return_06_55EF:
    ret


    db   $F4, $F8, $70, $00, $F4, $00, $72, $00
    db   $F4, $08, $72, $20, $F4, $10, $70, $20
    db   $04, $F8, $74, $00, $04, $00, $76, $00
    db   $04, $08, $7A, $00, $04, $10, $7A, $20
    db   $F4, $F8, $70, $00, $F4, $00, $78, $00
    db   $F4, $08, $78, $20, $F4, $10, $70, $20
    db   $04, $F8, $74, $00, $04

toc_06_5625:
    nop
    halt
    nop
    inc  b
    ld   [toc_01_007A], sp
    inc  b
    db   $10

    ld   a, d
toc_06_562F:
    jr   nz, toc_06_5625

    ld   hl, sp+$70
    nop
    db   $F4

    nop
    ld   [hl], d
    nop
    db   $F4

    ld   [$2072], sp
    db   $F4, $10

    ld   [hl], b
    jr   nz, .else_06_5645

    ld   hl, sp+$74
    nop
    inc  b
toc_06_562F.else_06_5645:
    nop
    halt
    nop
    inc  b
    ld   [$2076], sp
    inc  b
    db   $10

    ld   [hl], h
    jr   nz, .else_06_5645

    ld   hl, sp+$7C
    nop
    db   $F4

    nop
    ld   a, [hl]
    nop
    db   $F4

    ld   [$207E], sp
    db   $F4, $10

    ld   a, h
    jr   nz, .else_06_5665

    ld   hl, sp+$74
    nop
    inc  b
toc_06_562F.else_06_5665:
    nop
    halt
    nop
    inc  b
    ld   [$2076], sp
    inc  b
    db   $10

    ld   [hl], h
    jr   nz, .else_06_567D

    ei
    ld   h, $00
    inc  c
    ld   bc, $0026
    inc  c
    rlca
    ld   h, $00
    inc  c
toc_06_562F.else_06_567D:
    dec  c
    ld   h, $00
    ld   a, [$FFF1]
    rla
    rla
    rla
    rla
    rla
    and  %11100000
    ld   e, a
    ld   d, b
    ld   hl, $55F0
    add  hl, de
    ld   c, $08
    call toc_01_3D26
    ld   a, $04
    call toc_01_3DD0
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_06_56AD

    copyFromTo [$FFEF], [$FFEC]
    ld   hl, $5670
    ld   c, $04
    call toc_01_3D26
toc_06_562F.else_06_56AD:
    jp   toc_01_3DBA

    db   $00, $04, $FC, $08, $F8, $21, $D0, $C2
    db   $09, $7E, $FE, $02, $CA, $5C, $5A, $FE
    db   $00, $20, $1B, $34, $3E, $50, $E0, $B0
    db   $21, $10, $C3, $09, $36, $FF, $CD, $91
    db   $08, $36, $50, $1E, $00, $3E, $FF, $21
    db   $00, $D2, $22, $1D, $20, $FC, $CD, $9C
    db   $59, $F0, $EA, $FE, $01, $C2, $95, $57
    db   $21, $C0, $C2, $09, $7E, $C7

    dw JumpTable_56F6_06 ; 00
    dw JumpTable_5707_06 ; 01
    dw JumpTable_5718_06 ; 02
    dw JumpTable_5794_06 ; 03

JumpTable_56F6_06:
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $FF
    call toc_01_0891
    ld   [hl], $60
JumpTable_56F6_06.toc_06_5701:
    ld   hl, $C2C0
    add  hl, bc
    inc  [hl]
    ret


JumpTable_5707_06:
    call toc_01_0891
    jr   nz, .return_06_5717

    ld   [hl], $CF
    call JumpTable_56F6_06.toc_06_5701
    ld   hl, $C440
    add  hl, bc
    ld   [hl], $05
JumpTable_5707_06.return_06_5717:
    ret


JumpTable_5718_06:
    call toc_01_0891
    jr   nz, .else_06_5757

    call toc_01_27BD
    ld   a, $30
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
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], $02
    ld   hl, $C320
    add  hl, de
    ld   [hl], $10
    ld   hl, $C2F0
    add  hl, de
    ld   [hl], $10
    call toc_06_65E5
    copyFromTo [$FFEE], [$FFD7]
    ld   a, [$FFEC]
    jr   .toc_06_5788

JumpTable_5718_06.else_06_5757:
    and  %00011111
    jr   nz, .return_06_5793

    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C440
    add  hl, bc
    ld   e, [hl]
    dec  [hl]
    ld   d, b
    ld   hl, $5996
    add  hl, de
    sub  a, [hl]
    ld   e, a
    ld   d, b
    ld   hl, $D000
    add  hl, de
    ld   a, [hl]
    ld   [$FFD7], a
    ld   hl, $D200
    add  hl, de
    ld   a, [hl]
    and  %10000000
    jr   nz, .return_06_5793

    push hl
    ld   hl, $D100
    add  hl, de
    ld   a, [hl]
    pop  hl
    sub  a, [hl]
    ld   [hl], $FF
JumpTable_5718_06.toc_06_5788:
    ld   [$FFD8], a
    ld   a, $02
    call toc_01_0953
    assign [$FFF4], $13
JumpTable_5718_06.return_06_5793:
    ret


JumpTable_5794_06:
    ret


    db   $CD, $DF, $64, $CD, $12, $3F, $CD, $8C
    db   $08, $28, $53, $E6, $0F, $20, $4F, $3E
    db   $02, $E0, $E8, $3E, $87, $CD, $01, $3C
    db   $38, $44, $C5, $F0, $E8, $4F, $21, $B0
    db   $C3, $19, $E6, $02, $77, $FA, $CD, $C1
    db   $21, $B0, $56, $09, $86, $21, $00, $C2
    db   $19, $77, $21, $B2, $56, $09, $7E, $21
    db   $40, $C2, $19, $77, $FA, $CE, $C1, $C6
    db   $00, $21, $10, $C2, $19, $77, $21, $50
    db   $C2, $19, $36, $F0, $21, $D0, $C2, $19
    db   $36, $02, $21, $40, $C3, $19, $36, $C1
    db   $C1, $F0, $E8, $3D, $20, $B3, $CD, $1F
    db   $5A, $CD, $E2, $08, $F0, $F0, $FE, $02
    db   $38, $22, $21, $D0, $C3, $09, $7E, $34
    db   $E6, $FF, $5F, $50, $21, $00, $D0, $19
    db   $F0, $EE, $77, $21, $00, $D1, $19, $F0
    db   $EF, $77, $21, $10, $C3, $09, $7E, $21
    db   $00, $D2, $19, $77, $F0, $F0, $C7

    dw JumpTable_5840_06 ; 00
    dw JumpTable_5877_06 ; 01
    dw JumpTable_58BD_06 ; 02
    dw JumpTable_58DD_06 ; 03
    dw JumpTable_5907_06 ; 04
    dw JumpTable_5972_06 ; 05
    dw JumpTable_3828_00 ; 06
    dw JumpTable_5840_06.JumpTable_5848_06 ; 07

    db   $68, $78, $88, $28, $30, $40, $50, $60
    db   $70, $30, $40, $50

JumpTable_5840_06:
    call toc_01_0891
    jr   nz, .return_06_5876

    call toc_01_0891
JumpTable_5840_06.JumpTable_5848_06:
    ld   [hl], $18
    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $5830
    add  hl, de
    ld   a, [hl]
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   hl, $5838
    add  hl, de
    ld   a, [hl]
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    ld   hl, $C310
    add  hl, bc
    ld   [hl], b
    call toc_01_3DBA
    call JumpTable_3B8D_00
JumpTable_5840_06.return_06_5876:
    ret


JumpTable_5877_06:
    call toc_01_0891
    jr   nz, .else_06_58AF

    ld   [hl], $20
    ld   a, [$FF98]
    push af
    ld   a, [$FF99]
    push af
    assign [$FF98], $58
    assign [$FF99], $50
    ld   a, $08
    call toc_01_3C25
    pop  af
    ld   [$FF99], a
    pop  af
    ld   [$FF98], a
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $08
    copyFromTo [$FFEE], [$C1CD]
    copyFromTo [$FFEF], [$C1CE]
    call toc_01_088C
    ld   [hl], $61
    call JumpTable_3B8D_00
JumpTable_5877_06.else_06_58AF:
    ld   a, [$FFE7]
    rra
    rra
    rra
    rra
    and  %00000001
    add  a, $05
    call toc_01_3B87
    ret


JumpTable_58BD_06:
    call toc_01_0891
    jr   nz, .else_06_58D3

    call toc_01_27ED
    and  %00011111
    add  a, $20
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], $20
    call JumpTable_3B8D_00
JumpTable_58BD_06.else_06_58D3:
    call toc_06_654B
    call toc_06_6584
    call toc_01_3BB4
    ret


JumpTable_58DD_06:
    call toc_01_0891
    jr   nz, .else_06_58E7

    ld   [hl], $80
    call JumpTable_3B8D_00
JumpTable_58DD_06.else_06_58E7:
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    inc  [hl]
    ld   a, [hl]
    bit  0, a
    jr   nz, .else_06_58FD

    ld   hl, $C320
    add  hl, bc
    and  %00100000
    jr   nz, .else_06_58FC

    inc  [hl]
    inc  [hl]
JumpTable_58DD_06.else_06_58FC:
    dec  [hl]
JumpTable_58DD_06.else_06_58FD:
    call toc_06_654B
    call toc_06_6584
    call toc_01_3BB4
    ret


JumpTable_5907_06:
    call toc_01_0891
    jr   nz, .else_06_5913

    ld   [hl], $60
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_5907_06.else_06_5913:
    cp   $78
    jr   nz, .else_06_592A

    copyFromTo [$FFEE], [$C1CD]
    copyFromTo [$FFEF], [$C1CE]
    call toc_01_088C
    ld   [hl], $60
    assign [$FFF4], $23
JumpTable_5907_06.else_06_592A:
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    sub  a, $F4
    and  %10000000
    jr   nz, .else_06_5936

    dec  [hl]
JumpTable_5907_06.else_06_5936:
    ld   a, [$FFE7]
    and  %00000111
    jr   nz, .else_06_595A

    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_06_594B

    and  %10000000
    jr   z, .else_06_594A

    inc  [hl]
    inc  [hl]
JumpTable_5907_06.else_06_594A:
    dec  [hl]
JumpTable_5907_06.else_06_594B:
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_06_595A

    and  %10000000
    jr   z, .else_06_5959

    inc  [hl]
    inc  [hl]
JumpTable_5907_06.else_06_5959:
    dec  [hl]
JumpTable_5907_06.else_06_595A:
    call toc_06_654B
    call toc_06_6584
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   nz, .else_06_596C

    call toc_01_3BB4
JumpTable_5907_06.else_06_596C:
    ld   a, $02
    call toc_01_3B87
    ret


JumpTable_5972_06:
    ld   [hl], d
    nop
    ld   [hl], h
    nop
    ld   [hl], h
    jr   nz, toc_06_59EB

    jr   nz, toc_06_59EB

    nop
    ld   [hl], b
    jr   nz, @+$72

    ld   b, b
    ld   [hl], b
    ld   h, b
    halt
    nop
    halt
    jr   nz, toc_06_5A01

    nop
    ld   a, d
    ld   h, b
    ld   a, d
    ld   b, b
    ld   a, d
    jr   nz, @+$7A

    nop
    ld   a, b
    ld   h, b
    ld   a, b
    ld   b, b
    ld   a, b
    jr   nz, toc_06_59A3

    jr   @+$26

    db   $30, $3C, $48, $21, $10, $C3, $09, $7E
    db   $E6, $80

toc_06_59A3:
    jr   nz, toc_06_59AB

    ld   de, $5972
    call toc_01_3C3B
toc_06_59AB:
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD7], a
    ld   a, [$FFE7]
    and  %00000001
    jr   z, toc_06_59C0

    assign [$FFE9], $06
    ld   a, $00
    jr   toc_06_59C6

toc_06_59C0:
    assign [$FFE9], $FF
    ld   a, $05
toc_06_59C6:
    ld   [$FFE8], a
    ld   e, a
    ld   d, b
    ld   hl, $5996
    add  hl, de
    ld   a, [$FFD7]
    sub  a, [hl]
    and  %11111111
    ld   e, a
    ld   d, $00
    ld   hl, $D000
    add  hl, de
    ld   a, [hl]
    ld   [$FFEE], a
    ld   hl, $D100
    add  hl, de
    ld   a, [hl]
    ld   [$FFEF], a
    ld   hl, $D200
    add  hl, de
    sub  a, [hl]
    ld   [$FFEC], a
toc_06_59EB:
    ld   a, [hl]
    and  %10000000
    jr   nz, toc_06_5A09

    ld   a, [$FFE8]
    cp   $05
    ld   a, $04
    jr   nz, toc_06_5A01

    ld   a, [$FFE7]
    rra
    rra
    rra
    and  %00000001
    add  a, $07
toc_06_5A01:
    ld   [$FFF1], a
    ld   de, $5972
    call toc_01_3C3B
toc_06_5A09:
    ld   e, $FF
    ld   a, [$FFE7]
    and  %00000001
    jr   z, toc_06_5A13

    ld   e, $01
toc_06_5A13:
    ld   hl, $FFE9
    ld   a, [$FFE8]
    add  a, e
    cp   [hl]
    jr   nz, toc_06_59C6

    jp   toc_01_3DBA

    db   $21, $40, $C2, $09, $7E, $57, $CB, $7F
    db   $28, $02, $2F, $3C, $5F, $21, $50, $C2
    db   $09, $7E, $CB, $7F, $28, $02, $2F, $3C
    db   $BB, $30, $0C, $CB, $7A, $20, $04, $3E
    db   $01, $18, $0E, $3E, $00, $18, $0A, $CB
    db   $7E, $20, $04, $3E, $02, $18, $02, $3E
    db   $03, $CD, $87, $3B, $C9, $7C, $20, $7E
    db   $20, $7C, $00, $7E, $00, $11, $54, $5A
    db   $CD, $D0, $3C, $CD, $DF, $64, $CD, $4B
    db   $65, $21, $50, $C2, $09, $34, $7E, $A7
    db   $20, $05, $21, $B0, $C3, $09, $34, $FE
    db   $10, $20, $03, $CD, $E5, $65, $C9, $70
    db   $00, $72, $00, $74, $00, $76, $00, $72
    db   $20, $70, $20, $76, $20, $74, $20, $00
    db   $00, $02, $00, $04, $00, $06, $00, $02
    db   $20, $00, $20, $06, $20, $04, $20, $78
    db   $00, $7A, $00, $7C, $00, $7E, $00, $7A
    db   $20, $78, $20, $7E, $20, $7C, $20, $10
    db   $00, $12, $00, $14, $00, $16, $00, $12
    db   $20, $10, $20, $16, $20, $14, $20, $FA
    db   $9F, $C1, $A7, $28, $1F, $FA, $73, $C1
    db   $FE, $82, $28, $18, $CD, $9E, $65, $21
    db   $80, $C3, $09, $73, $CD, $AF, $3D, $FA
    db   $70, $C1, $1E, $00, $E6, $06, $28, $01
    db   $1C, $7B, $E0, $F1, $21, $80, $C3, $09
    db   $7E, $A7, $20, $06, $F0, $F1, $C6, $02
    db   $E0, $F1, $11, $7E, $5A, $21, $B0, $C2
    db   $09, $7E, $A7, $20, $0D, $F0, $F6, $FE
    db   $B2, $20, $0A, $FA, $0E, $DB, $FE, $03
    db   $38, $03, $11, $9E, $5A, $FA, $95, $DB
    db   $FE, $01, $20, $06, $F0, $F1, $C6, $04
    db   $E0, $F1, $CD, $3B, $3C, $CD, $DF, $64
    db   $CD, $E2, $08, $CD, $84, $65, $21, $20
    db   $C3, $09, $35, $35, $21, $10, $C3, $09
    db   $7E, $E6, $80, $E0, $E8, $28, $07, $AF
    db   $77, $21, $20, $C3, $09, $77, $F0, $F0
    db   $FE, $02, $30, $2B, $CD, $8C, $64, $30
    db   $26, $1E, $23, $F0, $F6, $FE, $B2, $20
    db   $17, $1E, $80, $FA, $0E, $DB, $FE, $02
    db   $20, $07, $CD, $8D, $3B, $36, $02, $1E
    db   $81, $7B, $CD, $85, $21, $C3, $A3, $5B
    db   $7B, $CD, $97, $21, $CD, $A3, $5B, $F0
    db   $F0, $C7

    dw JumpTable_5BBE_06 ; 00
    dw JumpTable_5C01_06 ; 01
    dw JumpTable_5B79_06 ; 02
    dw JumpTable_5BA8_06 ; 03

JumpTable_5B79_06:
    ld   a, [wDialogState]
    and  a
    jr   nz, .return_06_5BA7

    ld   a, [$C177]
    and  a
    jr   nz, .else_06_5B9A

    assign [$DB0E], $03
    assign [$FFA5], $0D
    ld   a, $83
    call toc_01_2185
    call .toc_06_5BA3
    call JumpTable_3B8D_00
    ret


JumpTable_5B79_06.else_06_5B9A:
    call JumpTable_3B8D_00
    ld   [hl], b
    ld   a, $84
    call toc_01_2185
JumpTable_5B79_06.toc_06_5BA3:
    assign [$FFF3], $18
JumpTable_5B79_06.return_06_5BA7:
    ret


JumpTable_5BA8_06:
    ld   a, [wDialogState]
    and  a
    jr   nz, .return_06_5BB5

    call toc_01_0898
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_5BA8_06.return_06_5BB5:
    ret


    db   $02, $08, $0C, $08, $FE, $F8, $F4, $F8

JumpTable_5BBE_06:
    xor  a
    call toc_01_3B87
    call toc_01_0891
    jr   nz, .else_06_5BFE

    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $5BB6
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
    ld   hl, $5BB6
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
JumpTable_5BBE_06.else_06_5BFE:
    jp   JumpTable_5C01_06.else_06_5C23

JumpTable_5C01_06:
    call toc_06_654B
    call toc_01_3B9E
    ifNot [$FFE8], .else_06_5C23

    call toc_01_0891
    jr   nz, .else_06_5C18

    ld   [hl], $30
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_5C01_06.else_06_5C18:
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $08
    ld   hl, $C310
    add  hl, bc
    inc  [hl]
JumpTable_5C01_06.else_06_5C23:
    ld   a, [$FFE7]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


    db   $60, $00, $62, $00, $62, $20, $60, $20
    db   $64, $00, $66, $00, $66, $20, $64, $20
    db   $68, $00, $6A, $00, $6C, $00, $6E, $00
    db   $6A, $20, $68, $20, $6E, $20, $6C, $20
    db   $CD, $91, $08, $FE, $01, $20, $06, $70
    db   $3E, $FF, $EA, $93, $DB, $F0, $E7, $E6
    db   $1F, $20, $08, $CD, $BE, $65, $21, $80
    db   $C3, $09, $73, $CD, $70, $64, $11, $2E
    db   $5C, $CD, $3B, $3C, $FA, $56, $DB, $FE
    db   $80, $20, $23, $CD, $84, $65, $21, $20
    db   $C3, $09, $35, $35, $21, $10, $C3, $09
    db   $7E, $A7, $28, $04, $E6, $80, $28, $0E
    db   $70, $21, $20, $C3, $09, $70, $F0, $E7
    db   $E6, $3F, $20, $02, $36, $10, $CD, $DF
    db   $64, $F0, $EF, $E0, $EC, $CD, $49, $64
    db   $CD, $BA, $3D, $CD, $8C, $64, $30, $2F
    db   $1E, $30, $FA, $66, $DB, $E6, $02, $28
    db   $14, $FA, $56, $DB, $FE, $01, $20, $0D
    db   $AF, $EA, $56, $DB, $CD, $91, $08, $36
    db   $10, $1E, $2F, $18, $0E, $FA, $56, $DB
    db   $A7, $28, $08, $1E, $31, $FE, $01, $20
    db   $02, $1E, $32, $7B, $CD, $DE, $5C, $C9
    db   $7B, $CD, $85, $21, $21, $9F, $C1, $CB
    db   $FE, $C9, $CD, $33, $5D, $CD, $DF, $64
    db   $F0, $E7, $1F, $1F, $1F, $1F, $1F, $E6
    db   $01, $CD, $87, $3B, $CD, $49, $64, $CD
    db   $8C, $64, $30, $10, $FA, $55, $DB, $A7
    db   $20, $05, $3E, $01, $EA, $55, $DB, $3E
    db   $40, $CD, $85, $21, $C9, $F0, $00, $70
    db   $00, $F0, $08, $72, $00, $00, $00, $74
    db   $00, $00, $08, $76, $00, $F0, $00, $78
    db   $00, $F0, $08, $7A, $00, $00, $00, $7C
    db   $00, $00, $08, $7E, $00, $F0, $F1, $17
    db   $17, $17, $17, $E6, $F0, $5F, $50, $21
    db   $13, $5D, $19, $0E, $04, $CD, $26, $3D
    db   $3E, $04, $CD, $D0, $3D, $C9, $50, $00
    db   $52, $00, $54, $00, $56, $00, $52, $20
    db   $50, $20, $56, $20, $54, $20, $F0, $F6
    db   $FE, $58, $20, $13, $F0, $F8, $E6, $10
    db   $C2, $E5, $65, $21, $60, $C4, $09, $36
    db   $FF, $21, $E0, $C4, $09, $36, $3C, $21
    db   $80, $C3, $09, $7E, $A7, $20, $06, $F0
    db   $F1, $C6, $02, $E0, $F1, $11, $4C, $5D
    db   $CD, $3B, $3C, $F0, $F0, $A7, $20, $0E
    db   $21, $10, $C2, $09, $7E, $D6, $04, $77
    db   $CD, $8D, $3B, $7E, $E0, $F0, $CD, $DF
    db   $64, $CD, $01, $65, $F0, $F0, $3D, $C7

    dw JumpTable_5DAE_06 ; 00
    dw JumpTable_5E14_06 ; 01
    dw JumpTable_5E2F_06 ; 02
    dw JumpTable_5E7F_06 ; 03

JumpTable_5DAE_06:
    ifNe [$FFF6], $58, .else_06_5DEE

    ld   a, [$C50C]
    ld   e, a
    ld   d, b
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .return_06_5E13

    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $05
    jr   nz, .return_06_5E13

    ld   hl, $C2F0
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .return_06_5E13

    ld   hl, $C200
    add  hl, de
    ld   a, [$FFEE]
    sub  a, [hl]
    add  a, $10
    cp   $20
    jr   nc, .return_06_5E13

    ld   hl, $C210
    add  hl, de
    ld   a, [$FFEC]
    sub  a, [hl]
    add  a, $28
    cp   $50
    jr   nc, .return_06_5E13

    jr   .toc_06_5E05

JumpTable_5DAE_06.else_06_5DEE:
    call toc_06_659E
    ld   hl, $C380
    add  hl, bc
    ld   [hl], e
    add  a, $18
    cp   $30
    jr   nc, .return_06_5E13

    call toc_06_65AE
    add  a, $30
    cp   $60
    jr   nc, .return_06_5E13

JumpTable_5DAE_06.toc_06_5E05:
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $12
    call toc_01_0891
    ld   [hl], $22
    call JumpTable_3B8D_00
JumpTable_5DAE_06.return_06_5E13:
    ret


JumpTable_5E14_06:
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_06_5E21

    ld   [hl], $30
    jp   JumpTable_3B8D_00

JumpTable_5E14_06.else_06_5E21:
    call toc_01_3DAF
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $08
    call toc_06_6584
    jr   JumpTable_5E2F_06.toc_06_5E6F

JumpTable_5E2F_06:
    call toc_01_3BB4
    call toc_01_0891
    jp   z, JumpTable_3B8D_00

    and  %00000001
    jr   nz, .else_06_5E69

    ld   a, $20
    call toc_01_3C30
    ld   a, [$FFD7]
    ld   hl, $C250
    add  hl, bc
    sub  a, [hl]
    and  %10000000
    jr   nz, .else_06_5E4E

    inc  [hl]
    inc  [hl]
JumpTable_5E2F_06.else_06_5E4E:
    dec  [hl]
    ld   a, [$FFD8]
    ld   hl, $C240
    add  hl, bc
    sub  a, [hl]
    and  %10000000
    jr   nz, .else_06_5E5C

    inc  [hl]
    inc  [hl]
JumpTable_5E2F_06.else_06_5E5C:
    dec  [hl]
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
JumpTable_5E2F_06.else_06_5E69:
    call toc_06_654B
    call toc_06_5E7B
JumpTable_5E2F_06.toc_06_5E6F:
    call toc_06_5E7B
    ld   a, [hl]
    rra
    rra
    rra
    and  %00000001
    jp   toc_01_3B87

toc_06_5E7B:
    call toc_01_29C5
    ret


JumpTable_5E7F_06:
    call toc_01_3BB4
    ld   a, [$FFE7]
    and  %00000011
    jr   nz, .else_06_5EB9

    ld   a, $20
    call toc_01_3C30
    ld   a, [$FFD7]
    cpl
    inc  a
    ld   hl, $C250
    add  hl, bc
    sub  a, [hl]
    and  %10000000
    jr   nz, .else_06_5E9C

    inc  [hl]
    inc  [hl]
JumpTable_5E7F_06.else_06_5E9C:
    dec  [hl]
    ld   a, [$FFD8]
    cpl
    inc  a
    ld   hl, $C240
    add  hl, bc
    sub  a, [hl]
    and  %10000000
    jr   nz, .else_06_5EAC

    inc  [hl]
    inc  [hl]
JumpTable_5E7F_06.else_06_5EAC:
    dec  [hl]
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
JumpTable_5E7F_06.else_06_5EB9:
    call JumpTable_5E2F_06.else_06_5E69
JumpTable_5E7F_06.toc_06_5EBC:
    ld   a, [$FFEC]
    cp   $88
    jp   nc, toc_06_65E5

    ld   a, [$FFEE]
    cp   $A8
    jp   nc, toc_06_65E5

    ret


    db   $F8, $00, $64, $00, $F8, $08, $66, $00
    db   $08, $00, $68, $00, $08, $08, $6A, $00
    db   $F8, $00, $60, $00, $F8, $08, $62, $00
    db   $08, $00, $68, $00, $08, $08, $6A, $00
    db   $F8, $00, $66, $20, $F8, $08, $64, $20
    db   $08, $00, $6A, $20, $08, $08, $68, $20
    db   $A0, $10, $CD, $91, $08, $28, $2D, $F0
    db   $98, $E0, $EE, $FA, $45, $C1, $D6, $10
    db   $E0, $EC, $3E, $6C, $E0, $9D, $3E, $02
    db   $E0, $A1, $3E, $03, $E0, $9E, $AF, $EA
    db   $37, $C1, $EA, $6A, $C1, $EA, $22, $C1
    db   $EA, $21, $C1, $11, $FB, $5E, $CD, $D0
    db   $3C, $CD, $BA, $3D, $1E, $00, $F0, $98
    db   $FE, $30, $38, $08, $1E, $01, $FE, $60
    db   $38, $02, $1E, $02, $7B, $E0, $F1, $17
    db   $17, $17, $17, $E6, $F0, $5F, $50, $21
    db   $CB, $5E, $19, $F0, $EC, $D6, $04, $E0
    db   $EC, $0E, $04, $CD, $26, $3D, $3E, $04
    db   $CD, $D0, $3D, $CD, $BA, $3D, $CD, $DF
    db   $64, $CD, $49, $64, $F0, $F0, $C7

    dw JumpTable_5F82_06 ; 00
    dw JumpTable_5FA8_06 ; 01
    dw JumpTable_5FE5_06 ; 02
    dw JumpTable_6070_06 ; 03
    dw JumpTable_6079_06 ; 04

toc_06_5F74:
    ld   a, [$FF99]
    ld   hl, $FFEF
    sub  a, [hl]
    add  a, $28
    cp   $50
    call toc_06_648C.toc_06_6497
    ret


JumpTable_5F82_06:
    call toc_06_5F74
    jr   nc, .return_06_5FA7

    ld   a, $17
    call toc_01_2197
    ld   hl, wDialogState
    set  7, [hl]
    ld   a, [$D415]
    and  %00000001
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    ifNe [$DB75], $07, .else_06_5FA4

    inc  [hl]
    inc  [hl]
JumpTable_5F82_06.else_06_5FA4:
    call JumpTable_3B8D_00
JumpTable_5F82_06.return_06_5FA7:
    ret


JumpTable_5FA8_06:
    call toc_06_5F74
    ret  nc

    ld   a, [$DB0D]
    and  a
    jr   nz, .else_06_5FCA

    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    ld   a, $18
    jr   z, .else_06_5FBF

    ld   a, $19
JumpTable_5FA8_06.else_06_5FBF:
    call toc_01_2197
    ld   hl, wDialogState
    set  7, [hl]
    jp   JumpTable_3B8D_00

JumpTable_5FA8_06.else_06_5FCA:
    ld   a, $1C
    call toc_01_2197
    ld   hl, wDialogState
    set  7, [hl]
    ret


    db   $28, $42, $07, $07, $00, $00, $00, $00
    db   $1C, $2A, $07, $07, $00, $00, $00, $00

JumpTable_5FE5_06:
    ld   a, [wDialogState]
    and  a
    jp   nz, .return_06_606F

    ld   a, [$C177]
    and  a
    jr   nz, .else_06_6061

    ld   hl, $C2B0
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $5FD9
    add  hl, de
    ld   a, [hl]
    ld   hl, $5FD5
    add  hl, de
    ld   e, [hl]
    ld   d, a
    ld   a, [$DB5E]
    sub  a, e
    ld   a, [$DB5D]
    sbc  d
    jr   nc, .else_06_6011

    ld   a, $1B
    jr   .toc_06_6063

JumpTable_5FE5_06.else_06_6011:
    ld   a, [$DB75]
    inc  a
    and  %00000111
    ld   [$DB75], a
    jr   nz, .else_06_6029

    ld   a, $1E
    call toc_01_2197
    ld   hl, wDialogState
    set  7, [hl]
    jp   JumpTable_3B8D_00

JumpTable_5FE5_06.else_06_6029:
    ld   hl, $C2B0
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $5FDD
    add  hl, de
    ld   a, [$DB92]
    add  a, [hl]
    ld   [$DB92], a
    rl   a
    ld   hl, $5FE1
    add  hl, de
    rr   a
    ld   a, [$DB91]
    adc  [hl]
    ld   [$DB91], a
    incAddr $DB0D
    ld   a, $1A
    call .toc_06_6063
    call JumpTable_3B8D_00
    ld   [hl], $04
    call toc_01_0891
    ld   [hl], $20
    assign [$FFF2], $01
    ret


JumpTable_5FE5_06.else_06_6061:
    ld   a, $1D
JumpTable_5FE5_06.toc_06_6063:
    call toc_01_2197
    ld   hl, wDialogState
    set  7, [hl]
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_5FE5_06.return_06_606F:
    ret


JumpTable_6070_06:
    ld   a, [wDialogState]
    and  a
    jr   nz, .return_06_6078

    jr   JumpTable_5FE5_06.else_06_6029

JumpTable_6070_06.return_06_6078:
    ret


JumpTable_6079_06:
    call toc_01_0891
    ret  nz

    ld   a, [wDialogState]
    and  a
    jr   nz, .else_06_609C

    ld   a, [$C5A9]
    and  a
    jr   nz, .else_06_6098

    assign [$DB93], $FF
    ld   a, $9A
    call toc_01_2185
    ld   hl, wDialogState
    set  7, [hl]
JumpTable_6079_06.else_06_6098:
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_6079_06.else_06_609C:
    assign [$FFA1], $02
    ret


    db   $70, $00, $72, $00, $72, $20, $70, $20
    db   $74, $00, $76, $00, $76, $20, $74, $20
    db   $78, $00, $7A, $00, $7C, $00, $7E, $00
    db   $7A, $20, $78, $20, $7E, $20, $7C, $20
    db   $3E, $00, $21, $B0, $C2, $09, $7E, $A7
    db   $28, $1B, $11, $C1, $60, $CD, $D0, $3C
    db   $CD, $DF, $64, $CD, $4B, $65, $CD, $84
    db   $65, $21, $20, $C3, $09, $35, $CD, $91
    db   $08, $CA, $E5, $65, $C9, $FA, $56, $DB
    db   $FE, $80, $C2, $A8, $61, $FA, $95, $DB
    db   $FE, $01, $CA, $A8, $61, $11, $A1, $60
    db   $CD, $3B, $3C, $CD, $AE, $65, $7B, $3D
    db   $E6, $02, $EE, $02, $5F, $F0, $E7, $1F
    db   $1F, $1F, $E6, $01, $83, $CD, $87, $3B
    db   $21, $D0, $C2, $09, $7E, $C7

    dw JumpTable_611D_06 ; 00
    dw JumpTable_6135_06 ; 01
    dw JumpTable_616C_06 ; 02

JumpTable_611D_06:
    call toc_06_64DF
    ld   hl, $C2C0
    add  hl, bc
    ld   [hl], $30
    assign [$D368], $0E
    ld   [$FFB0], a
    ld   [$FFBD], a
JumpTable_611D_06.toc_06_612F:
    ld   hl, $C2D0
    add  hl, bc
    inc  [hl]
    ret


JumpTable_6135_06:
    call toc_06_64DF
    call toc_06_65AE
    add  a, $20
    cp   $40
    jr   c, .else_06_6148

    ld   hl, $C2C0
    add  hl, bc
    dec  [hl]
    jr   nz, .else_06_615C

JumpTable_6135_06.else_06_6148:
    ld   a, [$C16B]
    cp   $04
    ret  nz

    ifNe [$FFEB], $71, .else_06_6159

    ld   a, $20
    call toc_01_218E
JumpTable_6135_06.else_06_6159:
    jp   JumpTable_611D_06.toc_06_612F

JumpTable_6135_06.else_06_615C:
    ld   a, $08
    call toc_01_3C25
    call toc_06_654B
    assign [$FFA1], $02
    ld   [$C167], a
    ret


JumpTable_616C_06:
    clear [$C167]
    copyFromTo [$FFEF], [$FFEC]
    call toc_06_6449
    call toc_01_3DBA
    call toc_06_648C
    jr   nc, .else_06_6184

    ld   a, $20
    call toc_01_218E
JumpTable_616C_06.else_06_6184:
    call toc_06_6584
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_06_6199

    and  %10000000
    jr   z, .return_06_61A7

JumpTable_616C_06.else_06_6199:
    ld   [hl], b
    ld   hl, $C320
    add  hl, bc
    ld   [hl], b
    ld   a, [$FFE7]
    and  %00011111
    jr   nz, .return_06_61A7

    ld   [hl], $10
JumpTable_616C_06.return_06_61A7:
    ret


    db   $21, $80, $C3, $09, $F0, $F1, $B6, $E0
    db   $F1, $11, $B1, $60, $CD, $3B, $3C, $CD
    db   $DF, $64, $CD, $6A, $62, $CD, $84, $65
    db   $21, $20, $C3, $09, $35, $21, $10, $C3
    db   $09, $7E, $E6, $80, $E0, $E8, $28, $07
    db   $AF, $77, $21, $20, $C3, $09, $77, $F0
    db   $F0, $C7

    dw JumpTable_61DE_06 ; 00
    dw JumpTable_6224_06 ; 01

JumpTable_61DE_06:
    call toc_01_0891
    jr   nz, .return_06_6223

    ld   [hl], $80
    call JumpTable_3B8D_00
    ld   a, $01
    call toc_01_3B87
    ld   a, $71
    call toc_01_3C01
    jr   c, .return_06_6223

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
    ld   [hl], $01
    ld   hl, $C320
    add  hl, de
    ld   [hl], $10
    ld   a, [$FFEB]
    cp   $71
    ld   a, $14
    jr   z, .else_06_6218

    ld   a, $EC
JumpTable_61DE_06.else_06_6218:
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $24
JumpTable_61DE_06.return_06_6223:
    ret


JumpTable_6224_06:
    call toc_01_0891
    jr   nz, .else_06_6230

    ld   [hl], $60
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_6224_06.else_06_6230:
    cp   $60
    jr   nc, .return_06_6247

    cp   $40
    jr   nc, .else_06_6243

    ifNot [$FFE8], .else_06_6243

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $08
JumpTable_6224_06.else_06_6243:
    xor  a
    call toc_01_3B87
JumpTable_6224_06.return_06_6247:
    ret


    db   $F0, $F6, $FE, $92, $20, $08, $FA, $0E
    db   $DB, $FE, $07, $DA, $E5, $65, $11, $A1
    db   $60, $CD, $3B, $3C, $CD, $DF, $64, $F0
    db   $E7, $1F, $1F, $1F, $1F, $E6, $01, $CD
    db   $87, $3B, $F0, $EF, $E0, $EC, $CD, $49
    db   $64, $CD, $BA, $3D, $CD, $8C, $64, $30
    db   $64, $FA, $74, $DB, $A7, $28, $05, $3E
    db   $23, $C3, $85, $21, $FA, $73, $DB, $A7
    db   $28, $05, $3E, $21, $C3, $85, $21, $F0
    db   $F6, $FE, $92, $20, $0C, $FA, $FD, $D8
    db   $E6, $30, $20, $05, $3E, $20, $C3, $85
    db   $21, $FA, $66, $DB, $E6, $02, $28, $12
    db   $FA, $BE, $DA, $E6, $10, $20, $0B, $F0
    db   $F6, $FE, $83, $20, $05, $3E, $22, $C3
    db   $85, $21, $21, $7E, $DB, $7E, $F5, $3C
    db   $FE, $04, $20, $01, $AF, $77, $FA, $65
    db   $DB, $E6, $02, $20, $06, $F1, $C6, $18
    db   $C3, $85, $21, $F1, $F0, $EB, $D6, $70
    db   $C6, $1C, $CD, $85, $21, $C9, $CD, $A3
    db   $63, $CD, $DF, $64, $CD, $E2, $08, $CD
    db   $EB, $3B, $CD, $49, $64, $F0, $F0, $C7

    dw JumpTable_62F6_06 ; 00
    dw JumpTable_62FE_06 ; 01
    dw JumpTable_6312_06 ; 02

JumpTable_62F6_06:
    call toc_01_0891
    ld   [hl], $C0
    jp   JumpTable_3B8D_00

JumpTable_62FE_06:
    call toc_01_0891
    jr   nz, .else_06_6308

    ld   [hl], $50
    call JumpTable_3B8D_00
JumpTable_62FE_06.else_06_6308:
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


JumpTable_6312_06:
    call toc_01_0891
    jr   nz, .else_06_631B

    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_6312_06.else_06_631B:
    cp   $4A
    jr   nz, .else_06_633D

    ld   a, $7D
    call toc_01_3C01
    jr   c, .else_06_633D

    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    push bc
    push de
    pop  bc
    ld   a, $0C
    call toc_01_3C25
    pop  bc
JumpTable_6312_06.else_06_633D:
    ld   a, $02
    call toc_01_3B87
    ret


    db   $F8, $F8, $70, $00, $F8, $00, $72, $00
    db   $F8, $08, $72, $20, $F8, $10, $70, $20
    db   $08, $F8, $74, $00, $08, $00, $76, $00
    db   $08, $08, $76, $20, $08, $10, $74, $20
    db   $F9, $F9, $70, $00, $F9, $01, $72, $00
    db   $F9, $07, $72, $20, $F9, $0F, $70, $20
    db   $07, $F9, $74, $00, $07, $01, $76, $00
    db   $07, $07, $76, $20, $07, $0F, $74, $20
    db   $F8, $F8, $78, $00, $F8, $00, $7A, $00
    db   $F8, $08, $7A, $20, $F8, $10, $78, $20
    db   $08, $F8, $7C, $00, $08, $00, $7E, $00
    db   $08, $08, $7E, $20, $08, $10, $7C, $20
    db   $F0, $F1, $17, $17, $17, $17, $17, $E6
    db   $E0, $5F, $50, $21, $43, $63, $19, $0E
    db   $08, $CD, $26, $3D, $3E, $08, $CD, $D0
    db   $3D, $C9, $1E, $00, $1E, $60, $1E, $40
    db   $1E, $20, $32, $00, $32, $20, $30, $00
    db   $30, $20, $21, $60, $C3, $09, $36, $30
    db   $21, $B0, $C2, $09, $7E, $A7, $28, $08
    db   $F0, $E7, $17, $17, $E6, $10, $E0, $ED
    db   $11, $BD, $63, $CD, $3B, $3C, $CD, $91
    db   $08, $28, $0E, $3D, $CA, $E5, $65, $1F
    db   $1F, $1F, $E6, $01, $C6, $02, $C3, $87
    db   $3B, $21, $10, $C4, $09, $7E, $FE, $02
    db   $38, $06, $CD, $91, $08, $36, $10, $C9
    db   $70, $CD, $DF, $64, $F0, $E7, $1F, $1F
    db   $1F, $E6, $01, $CD, $87, $3B, $CD, $B4
    db   $3B, $CD, $4B, $65, $C3, $BC, $5E, $50
    db   $00, $50, $20, $52, $00, $52, $20, $11
    db   $22, $64, $CD, $3B, $3C, $CD, $DF, $64
    db   $CD, $E2, $08, $CD, $EB, $3B, $CD, $49
    db   $64, $F0, $E7, $58, $E6, $30, $28, $01
    db   $1C, $7B, $CD, $87, $3B, $C9

toc_06_6449:
    call toc_01_3BD5
    jr   nc, .return_06_646B

    call toc_01_094A
    call toc_01_093B.toc_01_0942
    ifNot [$C1A6], .return_06_646B

    ld   e, a
    ld   d, b
    ld   hl, $C39F
    add  hl, de
    ld   a, [hl]
    cp   $03
    jr   nz, .return_06_646B

    ld   hl, $C28F
    add  hl, de
    ld   [hl], $00
toc_06_6449.return_06_646B:
    ret


    db   $06, $04, $02, $00, $21, $80, $C3, $09
    db   $5E, $50, $21, $6C, $64, $19, $E5, $21
    db   $D0, $C3, $09, $34, $7E, $1F, $1F, $1F
    db   $1F, $E1, $E6, $01, $B6, $C3, $87, $3B

toc_06_648C:
    ld   e, b
    ld   a, [$FF99]
    ld   hl, $FFEF
    sub  a, [hl]
    add  a, $14
    cp   $28
toc_06_648C.toc_06_6497:
    jr   nc, .else_06_64DD

    ld   a, [$FF98]
    ld   hl, $FFEE
    sub  a, [hl]
    add  a, $10
    cp   $20
    jr   nc, .else_06_64DD

    inc  e
    ifEq [$FFEB], $78, .else_06_64B8

    push de
    call toc_06_65BE
    ld   a, [$FF9E]
    xor  $01
    cp   e
    pop  de
    jr   nz, .else_06_64DD

toc_06_648C.else_06_64B8:
    ld   hl, $C1AD
    ld   [hl], $01
    ld   a, [wDialogState]
    ld   hl, $C14F
    or   [hl]
    ld   hl, $C146
    or   [hl]
    ld   hl, $C134
    or   [hl]
    jr   nz, .else_06_64DD

    ifNe [$DB9A], $80, .else_06_64DD

    ld   a, [$FFCC]
    and  %00010000
    jr   z, .else_06_64DD

    scf
    ret


toc_06_648C.else_06_64DD:
    and  a
    ret


toc_06_64DF:
    ifNe [$FFEA], $05, .else_06_64FF

toc_06_64DF.toc_06_64E5:
    ifEq [wGameMode], GAMEMODE_MINI_MAP, .else_06_64FF

    ld   hl, $C1A8
    ld   a, [wDialogState]
    or   [hl]
    ld   hl, $C14F
    or   [hl]
    jr   nz, .else_06_64FF

    ifNot [$C124], .return_06_6500

toc_06_64DF.else_06_64FF:
    pop  af
toc_06_64DF.return_06_6500:
    ret


toc_06_6501:
    ld   hl, $C410
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_06_654A

    dec  a
    ld   [hl], a
    call toc_01_3EB8
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    push af
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    push af
    ld   hl, $C3F0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $C400
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    call toc_06_654B
    ld   hl, $C430
    add  hl, bc
    ld   a, [hl]
    and  %00100000
    jr   nz, .else_06_653D

    call toc_01_3B9E
toc_06_6501.else_06_653D:
    ld   hl, $C250
    add  hl, bc
    pop  af
    ld   [hl], a
    ld   hl, $C240
    add  hl, bc
    pop  af
    ld   [hl], a
    pop  af
toc_06_6501.return_06_654A:
    ret


toc_06_654B:
    call toc_06_6558
    push bc
    ld   a, c
    add  a, $10
    ld   c, a
    call toc_06_6558
    pop  bc
    ret


toc_06_6558:
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_06_6583

    push af
    swap a
    and  %11110000
    ld   hl, $C260
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, $C200
toc_06_6558.toc_06_6570:
    add  hl, bc
    pop  af
    ld   e, $00
    bit  7, a
    jr   z, .else_06_657A

    ld   e, $F0
toc_06_6558.else_06_657A:
    swap a
    and  %00001111
    or   e
    rr   d
    adc  [hl]
    ld   [hl], a
toc_06_6558.return_06_6583:
    ret


toc_06_6584:
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, toc_06_6558.return_06_6583

    push af
    swap a
    and  %11110000
    ld   hl, $C330
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, $C310
    jr   toc_06_6558.toc_06_6570

toc_06_659E:
    ld   e, $00
    ld   a, [$FF98]
    ld   hl, $C200
    add  hl, bc
    sub  a, [hl]
    bit  7, a
    jr   z, .else_06_65AC

    inc  e
toc_06_659E.else_06_65AC:
    ld   d, a
    ret


toc_06_65AE:
    ld   e, $02
    ld   a, [$FF99]
    ld   hl, $C210
    add  hl, bc
    sub  a, [hl]
    bit  7, a
    jr   nz, .else_06_65BC

    inc  e
toc_06_65AE.else_06_65BC:
    ld   d, a
    ret


toc_06_65BE:
    call toc_06_659E
    ld   a, e
    ld   [$FFD7], a
    ld   a, d
    bit  7, a
    jr   z, .else_06_65CB

    cpl
    inc  a
toc_06_65BE.else_06_65CB:
    push af
    call toc_06_65AE
    ld   a, e
    ld   [$FFD8], a
    ld   a, d
    bit  7, a
    jr   z, .else_06_65D9

    cpl
    inc  a
toc_06_65BE.else_06_65D9:
    pop  de
    cp   d
    jr   nc, .else_06_65E1

    ld   a, [$FFD7]
    jr   .toc_06_65E3

toc_06_65BE.else_06_65E1:
    ld   a, [$FFD8]
toc_06_65BE.toc_06_65E3:
    ld   e, a
    ret


toc_06_65E5:
    ld   hl, $C280
    add  hl, bc
    ld   [hl], b
    ret


    db   $6A, $20, $68, $20, $68, $00, $6A, $00
    db   $6C, $40, $6C, $60, $6C, $00, $6C, $20
    db   $F0, $E7, $17, $17, $E6, $10, $E0, $ED
    db   $11, $EB, $65, $CD, $3B, $3C, $CD, $DF
    db   $64, $CD, $CA, $3B, $CD, $4B, $65, $CD
    db   $A9, $3B, $21, $A0, $C2, $09, $7E, $A7
    db   $28, $03, $CD, $E5, $65, $C9, $5C, $00
    db   $5C, $20, $5C, $10, $5C, $30, $00, $10
    db   $00, $F0, $00, $F0, $00, $10, $10, $00
    db   $F0, $00, $10, $00, $F0, $00, $01, $08
    db   $02, $04, $01, $04, $02, $08, $3E, $01
    db   $E0, $BE, $F0, $E7, $1F, $E6, $01, $E0
    db   $F1, $11, $21, $66, $CD, $3B, $3C, $CD
    db   $DF, $64, $CD, $01, $65, $CD, $BF, $3B
    db   $CD, $4B, $65, $CD, $D8, $66, $21, $B0
    db   $C2, $09, $7E, $5F, $50, $21, $C0, $C2
    db   $09, $86, $5F, $21, $39, $66, $19, $E5
    db   $21, $A0, $C2, $09, $7E, $E1, $A6, $20
    db   $15, $CD, $91, $08, $20, $1B, $21, $A0
    db   $C2, $09, $7E, $E6, $0F, $20, $1F, $CD
    db   $91, $08, $36, $09, $18, $18, $21, $B0
    db   $C2, $09, $34, $7E, $E6, $03, $77, $18
    db   $0D, $FE, $06, $20, $09, $21, $B0, $C2
    db   $09, $35, $7E, $E6, $03, $77, $21, $B0
    db   $C2, $09, $7E, $5F, $50, $21, $C0, $C2
    db   $09, $86, $5F, $21, $29, $66, $19, $7E
    db   $21, $50, $C2, $09, $77, $21, $B0, $C2
    db   $09, $7E, $5F, $50, $21, $C0, $C2, $09
    db   $86, $5F, $21, $31, $66, $19, $7E, $21
    db   $40, $C2, $09, $77, $C9, $21, $40, $C2
    db   $09, $7E, $F5, $36, $01, $21, $50, $C2
    db   $09, $7E, $F5, $36, $01, $CD, $9E, $3B
    db   $21, $A0, $C2, $09, $7E, $F5, $21, $40
    db   $C2, $09, $36, $FF, $21, $50, $C2, $09
    db   $36, $FF, $CD, $9E, $3B, $21, $A0, $C2
    db   $09, $F1, $B6, $77, $F1, $21, $50, $C2
    db   $09, $77, $F1, $21, $40, $C2, $09, $77
    db   $C9, $42, $00, $42, $20, $40, $00, $40
    db   $20, $62, $00, $62, $20, $60, $00, $60
    db   $20, $00, $05, $0A, $0D, $0E, $0D, $0A
    db   $05, $00, $FB, $F6, $F3, $F2, $F3, $F6
    db   $FB, $00, $05, $0A, $0D, $0C, $04, $08
    db   $00, $11, $14, $67, $F0, $F7, $FE, $0A
    db   $20, $03, $11, $1C, $67, $CD, $3B, $3C
    db   $CD, $DF, $64, $CD, $01, $65, $CD, $B4
    db   $3B, $F0, $F0, $C7

    dw JumpTable_675B_06 ; 00
    dw JumpTable_679B_06 ; 01

JumpTable_675B_06:
    call toc_01_0891
    jp   nz, JumpTable_679B_06.else_06_67F2

    call toc_06_659E
    add  a, $20
    cp   $40
    jp   nc, JumpTable_679B_06.else_06_67F2

    call toc_06_65AE
    add  a, $20
    cp   $40
    jp   nc, JumpTable_679B_06.else_06_67F2

    call toc_06_65BE
    ld   d, $00
    ld   hl, $6738
    add  hl, de
    ld   a, [hl]
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    call toc_01_0891
    call toc_01_27ED
    and  %00111111
    add  a, $50
    ld   [hl], a
    ld   hl, $C2C0
    add  hl, bc
    ld   [hl], $01
    call JumpTable_3B8D_00
    jp   JumpTable_679B_06.else_06_67F2

JumpTable_679B_06:
    call toc_06_654B
    call toc_01_3B9E
    call toc_01_0891
    jr   nz, .else_06_67AE

    ld   [hl], $20
    call JumpTable_3B8D_00
    ld   [hl], b
    jr   .else_06_67F2

JumpTable_679B_06.else_06_67AE:
    ld   hl, $C2D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    cp   $0A
    jr   c, .else_06_67F2

    ld   [hl], b
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C2B0
    add  hl, bc
    add  a, [hl]
    and  %00001111
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $6724
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ld   hl, $6728
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    call toc_01_27ED
    and  %00011111
    jr   nz, .else_06_67F2

    call toc_01_27ED
    and  %00000010
    dec  a
    ld   hl, $C2C0
    add  hl, bc
    ld   [hl], a
JumpTable_679B_06.else_06_67F2:
    ifNot [$FFF0], .else_06_67FE

    ld   a, [$FFE7]
    rra
    rra
    rra
    and  %00000001
JumpTable_679B_06.else_06_67FE:
    jp   toc_01_3B87

    db   $79, $EA, $01, $C5, $F0, $F6, $FE, $64
    db   $20, $0E, $FA, $E3, $D9, $E6, $40, $C8
    db   $FA, $69, $DB, $E6, $02, $C2, $E5, $65
    db   $F0, $F6, $FE, $AC, $20, $07, $F0, $F8
    db   $E6, $10, $CA, $E5, $65, $F0, $F6, $FE
    db   $41, $20, $09, $FA, $11, $DB, $A7, $C8
    db   $CD, $8C, $08, $C0, $F0, $F6, $FE, $EE
    db   $20, $06, $FA, $12, $DB, $A7, $18, $68
    db   $F0, $F6, $FE, $D2, $28, $13, $FE, $36
    db   $20, $14, $FA, $66, $DB, $A7, $C2, $E5
    db   $65, $FA, $56, $DB, $FE, $01, $C2, $E5
    db   $65, $FA, $65, $DB, $18, $48, $F0, $F6
    db   $FE, $08, $20, $10, $FA, $6C, $DB, $E6
    db   $02, $C2, $E5, $65, $FA, $08, $D8, $E6
    db   $10, $C8, $18, $37, $FE, $9D, $20, $05
    db   $FA, $69, $DB, $18, $29, $FE, $06, $20
    db   $08, $FA, $06, $D8, $E6, $10, $C8, $18
    db   $22, $FE, $B6, $20, $05, $FA, $67, $DB
    db   $18, $14, $FE, $17, $28, $04, $FE, $9C
    db   $20, $05, $FA, $6A, $DB, $18, $07, $FE
    db   $16, $20, $08, $FA, $66, $DB, $E6, $02
    db   $CA, $E5, $65, $F0, $F6, $FE, $D2, $28
    db   $0E, $FE, $16, $28, $0A, $FE, $36, $28
    db   $06, $F0, $F0, $FE, $00, $28, $03, $CD
    db   $5A, $6A, $F0, $E7, $E6, $B0, $3E, $00
    db   $20, $01, $3C, $CD, $87, $3B, $FA, $24
    db   $C1, $A7, $C0, $F0, $F0, $C7

    dw JumpTable_68E1_06 ; 00
    dw JumpTable_693C_06 ; 01
    dw JumpTable_6982_06 ; 02
    dw JumpTable_69B1_06 ; 03
    dw JumpTable_69DB_06 ; 04

JumpTable_68E1_06:
    ifNe [$FFF6], $F2, .else_06_68FB

    assign [$FFB0], $1D
    returnIfLt [$FF99], $44

    ld   a, [$FF98]
    sub  a, $58
    add  a, $18
    cp   $30
    ret  nc

    jr   .toc_06_6902

JumpTable_68E1_06.else_06_68FB:
    ld   a, [$DB4E]
    and  a
    jp   z, toc_06_65E5

JumpTable_68E1_06.toc_06_6902:
    ld   a, [$FFB0]
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    assign [$D368], $22
    ld   [$FFB0], a
    ld   [$FFBD], a
    ifEq [$FFF6], $16, .else_06_6920

    cp   $36
    jr   z, .else_06_6920

    cp   $D2
    jr   nz, .else_06_6926

JumpTable_68E1_06.else_06_6920:
    call JumpTable_3B8D_00
    ld   [hl], $02
    ret


JumpTable_68E1_06.else_06_6926:
    ld   hl, $C310
    add  hl, bc
    ld   [hl], $20
    ld   hl, $C240
    add  hl, bc
    ld   [hl], $18
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $10
    call JumpTable_3B8D_00
    ret


JumpTable_693C_06:
    call toc_06_65BE
    ld   a, e
    xor  $01
    ld   [$FF9E], a
    assign [$FFA1], $02
    assign [$C111], $05
    call JumpTable_69B1_06.else_06_69CD
    call toc_06_654B
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_06_695F

    call JumpTable_3B8D_00
    ret


JumpTable_693C_06.else_06_695F:
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $FC
    call toc_06_6584
    call toc_01_29C5
    ld   a, [$FFE7]
    and  %00000011
    jr   nz, .return_06_6981

    ld   a, $00
    ld   hl, $C250
    call JumpTable_69DB_06.toc_06_6A36
    ld   a, $00
    ld   hl, $C240
    call JumpTable_69DB_06.toc_06_6A36
JumpTable_693C_06.return_06_6981:
    ret


JumpTable_6982_06:
    call toc_06_64DF
    call toc_06_6449
    ld   a, [$C16B]
    cp   $04
    ret  nz

    ld   a, [$C17B]
    and  a
    ret  nz

    ifNe [$FFF6], $06, .else_06_69A0

    ld   a, $CD
    call toc_01_2197
    jr   .toc_06_69A3

JumpTable_6982_06.else_06_69A0:
    call toc_01_29D0
JumpTable_6982_06.toc_06_69A3:
    assign [$C5AB], $19
    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $10
    ret


JumpTable_69B1_06:
    call toc_06_64DF
    ifEq [$FFF6], $06, .else_06_69C2

    call toc_01_0891
    jr   nz, .else_06_69CD

    call JumpTable_3B8D_00
JumpTable_69B1_06.else_06_69C2:
    ld   a, [$FFF6]
    ld   e, a
    ld   d, b
    ld   hl, $D800
    add  hl, de
    set  5, [hl]
    ret


JumpTable_69B1_06.else_06_69CD:
    assign [$FFA1], $02
    ld   a, [$FFE7]
    rra
    rra
    and  %00000010
    call toc_01_3B87
    ret


JumpTable_69DB_06:
    call toc_06_64DF
    call JumpTable_69B1_06.else_06_69CD
    call toc_06_654B
    call JumpTable_5E7F_06.toc_06_5EBC
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $04
    call toc_06_6584
    ld   hl, $C280
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_06_6A10

    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    ld   [$D368], a
    ld   [$FFB0], a
    ifNot [$D47C], .return_06_6A0F

    assign [$D368], $49
    ld   [$FFBD], a
JumpTable_69DB_06.return_06_6A0F:
    ret


JumpTable_69DB_06.else_06_6A10:
    ld   a, [$FFE7]
    and  %00000111
    jr   nz, .else_06_6A1A

    assign [$FFF4], $05
JumpTable_69DB_06.else_06_6A1A:
    ld   a, [$FFE7]
    and  %00000001
    jr   nz, .return_06_6A41

    ld   a, $20
    call toc_01_3C30
    ld   a, [$FFD7]
    cpl
    inc  a
    ld   hl, $C250
    call .toc_06_6A36
    ld   a, [$FFD8]
    cpl
    inc  a
    ld   hl, $C240
JumpTable_69DB_06.toc_06_6A36:
    add  hl, bc
    sub  a, [hl]
    jr   z, .return_06_6A41

    bit  7, a
    jr   z, .else_06_6A40

    dec  [hl]
    dec  [hl]
JumpTable_69DB_06.else_06_6A40:
    inc  [hl]
JumpTable_69DB_06.return_06_6A41:
    ret


    db   $78, $00, $78, $20, $7A, $00, $7A, $20
    db   $00, $F8, $7C, $00, $00, $00, $7E, $00
    db   $00, $08, $7E, $20, $00, $10, $7C, $20
    db   $F0, $F1, $FE, $02, $30, $06, $11, $42
    db   $6A, $C3, $3B, $3C, $21, $4A, $6A, $0E
    db   $04, $CD, $26, $3D, $3E, $04, $CD, $D0
    db   $3D, $F0, $F6, $FE, $08, $28, $04, $CD
    db   $19, $3D, $C9, $21, $40, $C3, $09, $CB
    db   $A6, $C9, $50, $00, $52, $00, $F0, $EC
    db   $D6, $05, $E0, $EC, $11, $84, $6A, $CD
    db   $3B, $3C, $CD, $DF, $64, $CD, $8C, $64
    db   $D0, $1E, $FD, $F0, $F6, $FE, $A9, $CA
    db   $98, $6B, $1E, $41, $FA, $A9, $DA, $E6
    db   $20, $CA, $98, $6B, $1E, $46, $FA, $65
    db   $DB, $E6, $02, $CA, $98, $6B, $1E, $42
    db   $FA, $56, $DB, $FE, $80, $CA, $98, $6B
    db   $1E, $43, $FA, $66, $DB, $E6, $02, $CA
    db   $98, $6B, $1E, $44, $FA, $56, $DB, $FE
    db   $01, $CA, $9E, $6B, $1E, $44, $FA, $55
    db   $DB, $FE, $02, $C2, $98, $6B, $1E, $45
    db   $FA, $0E, $DB, $FE, $05, $DA, $98, $6B
    db   $1E, $47, $FA, $15, $DB, $FE, $05, $DA
    db   $98, $6B, $1E, $48, $CA, $98, $6B, $FE
    db   $06, $C2, $98, $6B, $1E, $49, $FA, $67
    db   $DB, $E6, $02, $CA, $98, $6B, $1E, $4A
    db   $FA, $12, $DB, $A7, $CA, $98, $6B, $1E
    db   $40, $FA, $68, $DB, $E6, $02, $CA, $9E
    db   $6B, $FA, $79, $DB, $A7, $28, $09, $1E
    db   $4B, $FA, $E3, $D9, $E6, $40, $28, $6E
    db   $1E, $4C, $FA, $69, $DB, $E6, $02, $28
    db   $65, $1E, $45, $FA, $49, $DB, $E6, $01
    db   $CA, $9E, $6B, $1E, $4D, $FA, $6A, $DB
    db   $E6, $02, $28, $52, $1E, $4E, $FA, $7B
    db   $DB, $A7, $28, $0B, $1E, $46, $FA, $14
    db   $DB, $A7, $CA, $9E, $6B, $1E, $41, $FA
    db   $6B, $DB, $E6, $02, $20, $07, $7B, $FE
    db   $4E, $28, $33, $18, $37, $1E, $4F, $FA
    db   $10, $D8, $E6, $30, $28, $28, $1E, $48
    db   $FA, $6C, $DB, $E6, $02, $28, $25, $1E
    db   $42, $FA, $06, $D8, $E6, $30, $28, $1C
    db   $1E, $43, $FA, $74, $DA, $E6, $40, $28
    db   $13, $1E, $47, $FA, $4E, $DB, $FE, $02
    db   $38, $0A, $1E, $48, $18, $06, $7B, $CD
    db   $85, $21, $18, $04, $7B, $CD, $8E, $21
    db   $21, $A9, $DA, $CB, $EE, $C9, $5E, $00
    db   $5E, $40, $04, $FC, $03, $FD, $02, $FE
    db   $05, $FA, $F0, $F1, $FE, $01, $20, $06
    db   $F0, $EC, $D6, $00, $E0, $EC, $11, $A8
    db   $6B, $CD, $D0, $3C, $CD, $DF, $64, $79
    db   $CB, $27, $CB, $27, $CB, $27, $21, $E7
    db   $FF, $86, $E0, $F0, $1F, $1F, $1F, $E6
    db   $01, $CD, $87, $3B, $CD, $4B, $65, $F0
    db   $F0, $E6, $1F, $20, $16, $CD, $ED, $27
    db   $E6, $07, $5F, $50, $21, $AC, $6B, $19
    db   $7E, $21, $B0, $C2, $09, $86, $21, $40
    db   $C2, $09, $77, $F0, $F0, $C6, $10, $E6
    db   $1F, $20, $16, $CD, $ED, $27, $E6, $07
    db   $5F, $50, $21, $AC, $6B, $19, $7E, $21
    db   $C0, $C2, $09, $86, $21, $50, $C2, $09
    db   $77, $F0, $F0, $E6, $3F, $20, $36, $F0
    db   $98, $F5, $F0, $99, $F5, $FA, $0F, $C5
    db   $FE, $FF, $28, $10, $5F, $50, $21, $00
    db   $C2, $19, $7E, $E0, $98, $21, $10, $C2
    db   $19, $7E, $E0, $99, $3E, $02, $CD, $30
    db   $3C, $F1, $E0, $99, $F1, $E0, $98, $F0
    db   $D7, $21, $C0, $C2, $09, $77, $F0, $D8
    db   $21, $B0, $C2, $09, $77, $C9, $79, $EA
    db   $02, $D2, $F0, $F7, $FE, $07, $20, $04
    db   $3E, $10, $E0, $F5, $CD, $6C, $6E, $CD
    db   $12, $3F, $CD, $0E, $38, $F0, $EA, $FE
    db   $05, $28, $55, $21, $30, $C4, $09, $36
    db   $80, $21, $B0, $C2, $09, $7E, $C7

    dw JumpTable_6C85_06 ; 00
    dw JumpTable_6C96_06 ; 01

JumpTable_6C85_06:
    call toc_01_0891
    ld   [hl], $FF
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $FF
    ld   hl, $C2B0
    add  hl, bc
    inc  [hl]
    ret


JumpTable_6C96_06:
    call toc_01_0891
    jp   z, .toc_06_6CA9

    ld   hl, $C420
    add  hl, bc
    ld   [hl], a
    cp   $80
    jr   nc, .return_06_6CA8

    call toc_06_6FFC
JumpTable_6C96_06.return_06_6CA8:
    ret


JumpTable_6C96_06.toc_06_6CA9:
    call toc_01_27BD
    call toc_01_3F7A
    ld   a, [$FFF7]
    cp   $07
    ret  z

JumpTable_6C96_06.toc_06_6CB4:
    ld   a, [$FFF6]
    ld   e, a
    ld   d, b
    ifGte [$FFF7], $1A, .else_06_6CC3

    cp   $06
    jr   c, .else_06_6CC3

    inc  d
JumpTable_6C96_06.else_06_6CC3:
    ld   hl, $D900
    add  hl, de
    set  5, [hl]
    ret


    db   $CD, $DF, $64, $CD, $01, $65, $CD, $B4
    db   $3B, $21, $60, $C3, $09, $7E, $E0, $E9
    db   $21, $40, $C2, $09, $7E, $A7, $28, $0D
    db   $1E, $00, $E6, $80, $20, $02, $1E, $03
    db   $21, $80, $C3, $09, $73, $CD, $84, $65
    db   $21, $20, $C3, $09, $35, $35, $00, $00
    db   $21, $10, $C3, $09, $7E, $E6, $80, $E0
    db   $E8, $28, $0F, $70, $21, $20, $C3, $09
    db   $7E, $70, $FE, $F2, $30, $04, $3E, $20
    db   $E0, $F2, $F0, $F0, $C7

    dw JumpTable_6D1F_06 ; 00
    dw JumpTable_6D60_06 ; 01
    dw JumpTable_6D91_06 ; 02
    dw JumpTable_6D9A_06 ; 03

JumpTable_6D1F_06:
    call toc_01_0891
    jr   nz, .return_06_6D5F

    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C200
    add  hl, de
    ld   a, [$FFEE]
    sub  a, [hl]
    ld   e, $08
    bit  7, a
    jr   nz, .else_06_6D38

    ld   e, $F8
JumpTable_6D1F_06.else_06_6D38:
    ld   hl, $C240
    add  hl, bc
    ld   [hl], e
    add  a, $10
    cp   $20
    jr   nc, .else_06_6D4C

    call toc_01_0891
    ld   [hl], $18
    call JumpTable_3B8D_00
    ret


JumpTable_6D1F_06.else_06_6D4C:
    call toc_06_6558
    ifNot [$FFE8], .else_06_6D5A

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $0C
JumpTable_6D1F_06.else_06_6D5A:
    ld   a, $01
    call toc_01_3B87
JumpTable_6D1F_06.return_06_6D5F:
    ret


JumpTable_6D60_06:
    call toc_01_0891
    jr   nz, .return_06_6D90

    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  a
    ld   a, $10
    jr   nz, .else_06_6D71

    ld   a, $F0
JumpTable_6D60_06.else_06_6D71:
    push af
    ld   a, [$D201]
    ld   e, a
    ld   d, b
    ld   hl, $C240
    add  hl, de
    pop  af
    ld   [hl], a
    ld   hl, $C290
    add  hl, de
    ld   [hl], $01
    call toc_01_0891
    ld   [hl], $20
    call JumpTable_3B8D_00
    ld   a, $00
    call toc_01_3B87
JumpTable_6D60_06.return_06_6D90:
    ret


JumpTable_6D91_06:
    call toc_01_0891
    jr   nz, .return_06_6D99

    call JumpTable_3B8D_00
JumpTable_6D91_06.return_06_6D99:
    ret


JumpTable_6D9A_06:
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    cp   $08
    ld   a, $01
    jr   c, .else_06_6DA6

    inc  a
JumpTable_6D9A_06.else_06_6DA6:
    call toc_01_3B87
    call toc_01_0891
    cp   $01
    jr   z, .else_06_6DC0

    cp   $00
    jp   nz, .return_06_6E0B

    ifNot [$FFE8], .else_06_6DF0

    call toc_01_0891
    ld   [hl], $10
    ret


JumpTable_6D9A_06.else_06_6DC0:
    ld   e, $10
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $19
    ifGte [$FFE9], $05, .else_06_6DD2

    ld   e, $14
    ld   [hl], $16
JumpTable_6D9A_06.else_06_6DD2:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  a
    ld   a, e
    jr   nz, .else_06_6DDD

    cpl
    inc  a
JumpTable_6D9A_06.else_06_6DDD:
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   a, [$FFEC]
    cp   $50
    ld   a, e
    jr   c, .else_06_6DEB

    cpl
    inc  a
JumpTable_6D9A_06.else_06_6DEB:
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
JumpTable_6D9A_06.else_06_6DF0:
    call toc_06_654B
    call toc_01_3B9E
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00000011
    jr   z, .return_06_6E0B

    call JumpTable_3B8D_00
    ld   [hl], b
    call toc_01_0891
    ld   [hl], $08
    call toc_01_3DAF
JumpTable_6D9A_06.return_06_6E0B:
    ret


    db   $00, $F8, $60, $00, $00, $00, $62, $00
    db   $00, $08, $64, $00, $F0, $00, $6E, $20
    db   $00, $F8, $66, $00, $00, $00, $68, $00
    db   $00, $08, $6A, $00, $F0, $00, $6E, $00
    db   $00, $F8, $66, $00, $00, $00, $68, $00
    db   $00, $08, $6A, $00, $F0, $06, $6E, $20
    db   $00, $00, $64, $20, $00, $08, $62, $20
    db   $00, $10, $60, $20, $F0, $08, $6E, $00
    db   $00, $00, $6A, $20, $00, $08, $68, $20
    db   $00, $10, $66, $20, $F0, $08, $6E, $20
    db   $00, $00, $6A, $20, $00, $08, $68, $20
    db   $00, $10, $66, $20, $F0, $02, $6E, $00
    db   $21, $80, $C3, $09, $F0, $F1, $86, $17
    db   $17, $17, $17, $E6, $F0, $5F, $50, $21
    db   $0C, $6E, $19, $0E, $04, $CD, $26, $3D
    db   $3E, $04, $CD, $D0, $3D, $21, $10, $C3
    db   $09, $7E, $A7, $28, $34, $F0, $E7, $E6
    db   $01, $20, $2E, $FA, $C0, $C3, $5F, $50
    db   $21, $30, $C0, $19, $F0, $EF, $C6, $0C
    db   $22, $F0, $EE, $C6, $02, $22, $3E, $26
    db   $22, $3E, $00, $22, $F0, $EF, $C6, $0C
    db   $22, $F0, $EE, $C6, $04, $22, $3E, $26
    db   $22, $3E, $00, $22, $3E, $02, $CD, $D0
    db   $3D, $C9, $6C, $00, $6C, $20, $6C, $40
    db   $6C, $60, $70, $60, $50, $40, $30, $20
    db   $F0, $F7, $FE, $07, $20, $04, $3E, $10
    db   $E0, $F5, $F0, $F8, $E6, $20, $C2, $E5
    db   $65, $79, $EA, $01, $D2, $CD, $DB, $6F
    db   $CD, $DF, $64, $FA, $02, $D2, $5F, $50
    db   $21, $80, $C2, $19, $7E, $FE, $01, $C8
    db   $A7, $20, $3A, $CD, $91, $08, $20, $34
    db   $36, $03, $21, $B0, $C2, $09, $F0, $EE
    db   $E0, $D7, $5E, $34, $7E, $FE, $06, $20
    db   $18, $CD, $E5, $65, $21, $60, $C4, $09
    db   $5E, $50, $21, $72, $3F, $19, $F0, $F6
    db   $5F, $50, $7E, $21, $00, $CF, $19, $B6
    db   $77, $50, $21, $CE, $6E, $19, $7E, $E0
    db   $D8, $C3, $29, $70, $C9, $CD, $E2, $08
    db   $F0, $A2, $A7, $20, $03, $CD, $B4, $3B
    db   $CD, $58, $65, $CD, $9E, $3B, $21, $40
    db   $C2, $09, $7E, $A7, $28, $25, $CB, $7F
    db   $28, $02, $2F, $3C, $1E, $04, $FE, $08
    db   $30, $02, $1E, $08, $FE, $04, $30, $02
    db   $1E, $10, $FE, $02, $30, $02, $1E, $20
    db   $50, $F0, $E7, $A3, $28, $01, $14, $7A
    db   $CD, $87, $3B, $F0, $F0, $C7

    dw JumpTable_6F80_06 ; 00
    dw JumpTable_6F81_06 ; 01
    dw JumpTable_6FB5_06 ; 02

JumpTable_6F80_06:
    ret


JumpTable_6F81_06:
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00000011
    jr   z, .else_06_6FA4

    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    sra  a
    cpl
    inc  a
    ld   [hl], a
    assign [$C157], $20
    clear [$C158]
    assign [$FFF2], $0B
    call JumpTable_3B8D_00
JumpTable_6F81_06.else_06_6FA4:
    ld   a, [$D210]
    inc  a
    cp   $09
    jr   c, .else_06_6FB1

    assign [$FFF3], $1A
    xor  a
JumpTable_6F81_06.else_06_6FB1:
    ld   [$D210], a
    ret


JumpTable_6FB5_06:
    ld   a, [$FFE7]
    and  %00000111
    jr   nz, .return_06_6FCA

    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_06_6FCB

    and  %10000000
    jr   z, .else_06_6FC9

    inc  [hl]
    inc  [hl]
JumpTable_6FB5_06.else_06_6FC9:
    dec  [hl]
JumpTable_6FB5_06.return_06_6FCA:
    ret


JumpTable_6FB5_06.else_06_6FCB:
    call JumpTable_3B8D_00
    ld   [hl], b
    call toc_01_0891
    ld   [hl], $50
    ret


    db   $80, $70, $60, $50, $40, $30, $3E, $20
    db   $E0, $EC, $11, $C6, $6E, $CD, $3B, $3C
    db   $F0, $EC, $C6, $10, $E0, $EC, $21, $B0
    db   $C2, $09, $5E, $50, $21, $D5, $6F, $19
    db   $BE, $20, $E7, $CD, $BA, $3D, $C9

toc_06_6FFC:
    and  %00000111
    jr   nz, .return_06_701D

    call toc_01_27ED
    and  %00011111
    sub  a, $10
    ld   e, a
    ld   hl, $FFEE
    add  a, [hl]
    ld   [hl], a
    call toc_01_27ED
    and  %00011111
    sub  a, $14
    ld   e, a
    ld   hl, $FFEC
    add  a, [hl]
    ld   [hl], a
    call toc_06_701E
toc_06_6FFC.return_06_701D:
    ret


toc_06_701E:
    call toc_06_64DF.toc_06_64E5
    copyFromTo [$FFEE], [$FFD7]
    copyFromTo [$FFEC], [$FFD8]
    ld   a, $02
    call toc_01_0953
    assign [$FFF4], $13
    ret


    db   $3E, $36, $CD, $01, $3C, $F0, $D7, $21
    db   $00, $C2, $19, $77, $F0, $D8, $21, $10
    db   $C2, $19, $77, $F0, $F9, $A7, $28, $08
    db   $21, $50, $C2, $09, $36, $F0, $18, $0C
    db   $21, $20, $C3, $19, $36, $10, $21, $10
    db   $C3, $19, $36, $08, $CD, $E5, $65, $CD
    db   $D7, $08, $C9, $F0, $F0, $C7

    dw JumpTable_706F_06 ; 00
    dw JumpTable_70CE_06 ; 01
    dw JumpTable_716D_06 ; 02

JumpTable_706F_06:
    call toc_06_659E
    add  a, $0E
    cp   $1C
    jr   nc, .return_06_70BD

    call toc_06_65AE
    add  a, $0C
    cp   $18
    jr   nc, .return_06_70BD

    ld   a, [$FF9E]
    and  a
    jr   nz, .return_06_70BD

    ifNot [$C133], .return_06_70BD

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $A0
    assign [$FFA2], $01
    assign [$C146], $02
    assign [$FFA3], $12
    assign [$FF9A], $0C
    clear [$FF9B]
    assign [$FF9E], $00
    assign [$C10A], $01
    assign [$D368], $1E
    clear [$C16B]
    ld   [$C16C], a
JumpTable_706F_06.return_06_70BD:
    ret


    db   $50, $00, $52, $00, $54, $00, $56, $00
    db   $98, $42, $98, $50, $99, $90, $99, $82

JumpTable_70CE_06:
    ld   a, [$C146]
    and  a
    jp   nz, .return_06_716C

    call toc_01_0891
    jr   nz, .else_06_70EC

    assign [$C17F], $01
    clear [$C180]
    assign [$C3CA], $08
    call JumpTable_3B8D_00
    xor  a
JumpTable_70CE_06.else_06_70EC:
    push af
    cp   $80
    jr   nc, .else_06_7144

    push af
    and  %00011111
    jr   nz, .else_06_7107

    ifEq [$C16B], $02, .else_06_7107

    assign [$C16C], $03
    push bc
    call toc_01_1776
    pop  bc
JumpTable_70CE_06.else_06_7107:
    pop  af
    and  %00001111
    jr   nz, .else_06_7144

    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    cp   $04
    jr   z, .else_06_7144

    ld   a, [$D600]
    ld   e, a
    ld   d, b
    add  a, $05
    ld   [$D600], a
    ld   hl, $D601
    add  hl, de
    push hl
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    inc  [hl]
    sla  a
    ld   e, a
    ld   d, b
    ld   hl, $70C6
    add  hl, de
    push hl
    pop  de
    pop  hl
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    ldi  [hl], a
    ld   a, $01
    ldi  [hl], a
    ld   a, $64
    ldi  [hl], a
    ld   a, $65
    ldi  [hl], a
    ld   [hl], b
JumpTable_70CE_06.else_06_7144:
    pop  af
    ld   e, $00
    cp   $80
    jr   c, .else_06_714C

    inc  e
JumpTable_70CE_06.else_06_714C:
    ld   a, e
JumpTable_70CE_06.toc_06_714D:
    ld   [$FFF1], a
    assign [$FFEE], $58
    ld   [$FF98], a
    assign [$FFEC], $44
    ld   [$FF99], a
    assign [$FFA1], $02
    assign [$FF9D], $FF
    ld   de, $70BE
    call toc_01_3C3B
    call toc_01_3DBA
JumpTable_70CE_06.return_06_716C:
    ret


JumpTable_716D_06:
    xor  a
    call JumpTable_70CE_06.toc_06_714D
    ld   a, [$C17F]
    and  a
    jr   nz, .return_06_7192

    clear [$FF9D]
    ld   hl, $D401
    ld   a, $01
    ldi  [hl], a
    ld   a, [$FFF7]
    ldi  [hl], a
    ld   a, $CE
    ldi  [hl], a
    ld   a, $50
    ldi  [hl], a
    ld   a, $7C
    ld   [hl], a
    call toc_06_65E5
    jp   toc_01_0915.toc_01_092A

JumpTable_716D_06.return_06_7192:
    ret


    db   $F0, $FC, $50, $00, $F0, $04, $52, $00
    db   $F0, $0C, $54, $00, $00, $FC, $56, $00
    db   $00, $04, $58, $00, $00, $0C, $5A, $00
    db   $F0, $FC, $50, $00, $F0, $04, $52, $00
    db   $F0, $0C, $54, $00, $00, $FC, $5C, $00
    db   $00, $04, $58, $00, $00, $0C, $5E, $00
    db   $A8, $10, $01, $FF, $18, $E8, $21, $D0
    db   $C2, $09, $7E, $A7, $CA, $35, $72, $21
    db   $80, $C2, $FA, $01, $D2, $5F, $50, $19
    db   $7E, $A7, $CA, $E5, $65, $FA, $02, $D2
    db   $E0, $F1, $11, $C3, $71, $CD, $D0, $3C
    db   $F0, $E7, $E6, $01, $20, $40, $21, $B0
    db   $C2, $09, $5E, $50, $21, $C5, $71, $19
    db   $7E, $21, $40, $C2, $09, $86, $77, $21
    db   $C7, $71, $19, $BE, $20, $08, $21, $B0
    db   $C2, $09, $7E, $EE, $01, $77, $21, $C0
    db   $C2, $09, $5E, $50, $21, $C5, $71, $19
    db   $7E, $21, $50, $C2, $09, $86, $77, $21
    db   $C7, $71, $19, $BE, $20, $08, $21, $C0
    db   $C2, $09, $7E, $EE, $01, $77, $CD, $4B
    db   $65, $C9, $21, $93, $71, $F0, $E7, $E6
    db   $08, $28, $03, $21, $AB, $71, $0E, $06
    db   $CD, $26, $3D, $3E, $06, $CD, $D0, $3D
    db   $CD, $19, $3D, $1E, $FE, $21, $D0, $C3
    db   $09, $34, $7E, $E6, $40, $28, $02, $1E
    db   $02, $21, $20, $C3, $09, $73, $CD, $84
    db   $65, $CD, $DF, $64, $F0, $F0, $C7

    dw JumpTable_7270_06 ; 00
    dw JumpTable_729A_06 ; 01
    dw JumpTable_7306_06 ; 02

JumpTable_7270_06:
    clear [$D202]
    ld   a, c
    ld   [$D201], a
    ld   a, [$FF98]
    sub  a, $50
    add  a, $08
    cp   $10
    jr   nc, .return_06_7299

    ld   a, [$FF99]
    sub  a, $58
    add  a, $08
    cp   $10
    jr   nc, .return_06_7299

    call JumpTable_3B8D_00
    call toc_01_0887
    ld   [hl], $48
    ld   a, $24
    call toc_01_2197
JumpTable_7270_06.return_06_7299:
    ret


JumpTable_729A_06:
    call toc_01_0887
    jr   nz, .else_06_72AC

    call toc_01_0891
    ld   [hl], $48
    call JumpTable_3B8D_00
    assign [$FFF2], $26
    ret


JumpTable_729A_06.else_06_72AC:
    assign [$FFA1], $02
    assign [$FFF2], $1A
    call toc_06_64DF
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_06_72CF

    ld   [hl], $01
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    cp   $04
    jr   c, .else_06_72CF

    assign [$DB93], $04
JumpTable_729A_06.else_06_72CF:
    call toc_01_088C
    jr   nz, .return_06_7305

    ld   [hl], $13
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    cp   $0A
    jr   z, .return_06_7305

    inc  [hl]
    ld   a, $84
    call toc_01_3C01
    jr   c, .return_06_7305

    ld   hl, $C2D0
    add  hl, de
    ld   [hl], $01
    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    add  a, $00
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    sub  a, $0E
    ld   [hl], a
    ld   hl, $C240
    add  hl, de
    ld   [hl], $E8
JumpTable_729A_06.return_06_7305:
    ret


JumpTable_7306_06:
    call toc_01_0891
    jp   z, toc_06_65E5

    ld   a, [$FFE7]
    and  %00000010
    ld   a, $00
    jr   z, .else_06_7316

    ld   a, $FF
JumpTable_7306_06.else_06_7316:
    ld   [$D202], a
    call toc_01_3B87
    assign [$FFA1], $02
    ret


    db   $68, $00, $6A, $00, $64, $00, $66, $00
    db   $6C, $00, $6E, $00, $6A, $20, $68, $20
    db   $66, $20, $64, $20, $6E, $20, $6C, $20
    db   $21, $80, $C3, $09, $F0, $F1, $86, $E0
    db   $F1, $21, $40, $C2, $09, $7E, $A7, $28
    db   $0D, $E6, $80, $3E, $00, $20, $02, $3E
    db   $03, $21, $80, $C3, $09, $77, $11, $21
    db   $73, $CD, $3B, $3C, $CD, $DF, $64, $FA
    db   $A5, $DB, $A7, $CA, $67, $74, $CD, $84
    db   $65, $21, $20, $C3, $09, $35, $21, $10
    db   $C3, $09, $7E, $E6, $80, $E0, $E8, $28
    db   $06, $70, $21, $10, $C3, $09, $70, $F0
    db   $F0, $C7

    dw JumpTable_7391_06 ; 00
    dw JumpTable_73D7_06 ; 01
    dw JumpTable_7407_06 ; 02

    db   $02, $06, $08, $06, $FE, $FA, $F8, $FA

JumpTable_7391_06:
    call toc_06_742A
    xor  a
    call toc_01_3B87
    call toc_01_0891
    jr   nz, .else_06_73D4

    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $7389
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
    ld   hl, $7389
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    call toc_01_0891
    call toc_01_27ED
    and  %00011111
    add  a, $20
    ld   [hl], a
    call JumpTable_3B8D_00
JumpTable_7391_06.else_06_73D4:
    jp   JumpTable_73D7_06.else_06_73FC

JumpTable_73D7_06:
    call toc_06_742A
    call toc_06_654B
    call toc_01_3B9E
    ifNot [$FFE8], .else_06_73FC

    call toc_01_0891
    jr   nz, .else_06_73F1

    ld   [hl], $30
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_73D7_06.else_06_73F1:
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $08
    ld   hl, $C310
    add  hl, bc
    inc  [hl]
JumpTable_73D7_06.else_06_73FC:
    ld   a, [$FFE7]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


JumpTable_7407_06:
    call toc_06_654B
    call toc_01_3B9E
    ld   a, [$FFE7]
    and  %00000001
    jr   nz, .else_06_7418

    ld   hl, $C320
    add  hl, bc
    inc  [hl]
JumpTable_7407_06.else_06_7418:
    ifNot [$FFE8], .else_06_7421

    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_7407_06.else_06_7421:
    ld   a, [$FFE7]
    rra
    and  %00000010
    call toc_01_3B87
    ret


toc_06_742A:
    ifNe [$C137], $02, .return_06_7466

    call toc_06_659E
    add  a, $18
    cp   $30
    jr   nc, .return_06_7466

    call toc_06_65AE
    add  a, $18
    cp   $30
    jr   nc, .return_06_7466

    call JumpTable_3B8D_00
    ld   [hl], $02
    ld   a, $10
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
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $0C
    pop  af
toc_06_742A.return_06_7466:
    ret


    db   $C9, $70, $00, $70, $20, $72, $00, $72
    db   $20, $FA, $66, $C1, $FE, $01, $20, $2B
    db   $FA, $49, $DB, $E6, $04, $28, $24, $FA
    db   $4A, $DB, $A7, $20, $1E, $F0, $EA, $FE
    db   $01, $28, $18, $21, $80, $C4, $09, $36
    db   $1F, $21, $80, $C2, $09, $36, $01, $21
    db   $40, $C3, $09, $36, $04, $21, $F4, $FF
    db   $36, $13, $C9, $11, $68, $74, $CD, $3B
    db   $3C, $CD, $DF, $64, $CD, $01, $65, $CD
    db   $4B, $65, $21, $10, $C4, $09, $36, $01
    db   $E5, $CD, $9E, $3B, $E1, $70, $CD, $B4
    db   $3B, $F0, $F0, $E6, $01, $C7

    dw JumpTable_74D5_06 ; 00
    dw JumpTable_751A_06 ; 01

    db   $08, $08, $F8, $F8, $04, $FC, $FC, $04
    db   $FC, $04, $08, $F8

JumpTable_74D5_06:
    ld   hl, $C3B0
    add  hl, bc
    ld   [hl], $01
    call toc_01_0891
    jr   nz, .return_06_7519

    call JumpTable_3B8D_00
    call toc_01_27ED
    and  %00000111
    add  a, $10
    ld   hl, $C320
    add  hl, bc
    ld   [hl], a
    call toc_01_27ED
    and  %00000111
    cp   $06
    jr   c, .else_06_74FF

    ld   a, $0A
    call toc_01_3C25
    jr   .toc_06_7515

JumpTable_74D5_06.else_06_74FF:
    ld   e, a
    ld   d, b
    ld   hl, $74C9
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $74CF
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
JumpTable_74D5_06.toc_06_7515:
    xor  a
    call toc_01_3B87
JumpTable_74D5_06.return_06_7519:
    ret


JumpTable_751A_06:
    call toc_06_6584
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   z, .return_06_753E

    xor  a
    ld   [hl], a
    call JumpTable_3B8D_00
    call toc_01_0891
    call toc_01_27ED
    and  %00001111
    add  a, $18
    ld   [hl], a
    call toc_01_3DAF
JumpTable_751A_06.return_06_753E:
    ret


    db   $60, $00, $62, $00, $64, $00, $66, $00
    db   $11, $3F, $75, $CD, $3B, $3C, $CD, $DF
    db   $64, $CD, $01, $65, $AF, $E0, $E8, $CD
    db   $EB, $3B, $CD, $D5, $3B, $30, $0D, $3E
    db   $01, $E0, $E8, $F0, $F0, $FE, $02, $30
    db   $03, $CD, $4A, $09, $CD, $4B, $65, $CD
    db   $9E, $3B, $F0, $F0, $C7

    dw JumpTable_757A_06 ; 00
    dw JumpTable_758E_06 ; 01
    dw JumpTable_75C4_06 ; 02

JumpTable_757A_06:
    ifNot [$FFE8], .return_06_758D

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $30
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $18
JumpTable_757A_06.return_06_758D:
    ret


JumpTable_758E_06:
    call toc_01_0891
    jr   nz, .else_06_75AC

    call JumpTable_3B8D_00
    ld   hl, $C340
    add  hl, bc
    res  7, [hl]
    ld   hl, $C350
    add  hl, bc
    res  7, [hl]
    ld   hl, $C430
    add  hl, bc
    res  6, [hl]
    call toc_01_3DAF
    ret


JumpTable_758E_06.else_06_75AC:
    ld   e, $08
    and  %00000100
    jr   z, .else_06_75B4

    ld   e, $F8
JumpTable_758E_06.else_06_75B4:
    ld   hl, $C240
    add  hl, bc
    ld   [hl], e
    ret


    db   $F8, $FA, $00, $06, $08, $06, $00, $FA
    db   $F8, $FA

JumpTable_75C4_06:
    call toc_01_0891
    jr   nz, .else_06_75E9

    call toc_01_27ED
    and  %00111111
    add  a, $20
    ld   [hl], a
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $75BC
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $75BA
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
JumpTable_75C4_06.else_06_75E9:
    ld   a, [$FFE7]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


    db   $50, $00, $50, $20, $20, $E0, $00, $00
    db   $F8, $08, $00, $00, $00, $00, $E0, $20
    db   $00, $00, $08, $F8, $30, $20, $3E, $01
    db   $E0, $BE, $11, $F5, $75, $CD, $3B, $3C
    db   $CD, $DF, $64, $CD, $E2, $08, $CD, $B4
    db   $3B, $F0, $F0, $C7

    dw JumpTable_7629_06 ; 00
    dw JumpTable_763A_06 ; 01
    dw JumpTable_769D_06 ; 02
    dw JumpTable_76BE_06 ; 03

JumpTable_7629_06:
    ld   a, [$FFEE]
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    ld   a, [$FFEC]
    ld   hl, $C2C0
    add  hl, bc
    ld   [hl], a
    jp   JumpTable_3B8D_00

JumpTable_763A_06:
    call toc_01_0891
    jr   nz, .return_06_7694

    call toc_01_3DAF
    call toc_06_65AE
    add  a, $12
    cp   $24
    jr   nc, .else_06_7662

    call toc_06_659E
    ld   d, b
    ld   hl, $75F9
    add  hl, de
    ld   a, [hl]
    ld   hl, $C380
    add  hl, bc
    ld   [hl], e
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   e, $18
    jr   .toc_06_7680

JumpTable_763A_06.else_06_7662:
    call toc_06_659E
    add  a, $12
    cp   $24
    jr   nc, .return_06_7694

    call toc_06_65AE
    ld   d, b
    ld   hl, $7601
    add  hl, de
    ld   a, [hl]
    ld   hl, $C380
    add  hl, bc
    ld   [hl], e
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ld   e, $10
JumpTable_763A_06.toc_06_7680:
    call toc_01_0891
    ld   [hl], e
    call toc_01_3B9E
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00001111
    jr   z, .else_06_7695

    call toc_01_0891
    ld   [hl], b
JumpTable_763A_06.return_06_7694:
    ret


JumpTable_763A_06.else_06_7695:
    assign [$FFF4], $0A
    call JumpTable_3B8D_00
    ret


JumpTable_769D_06:
    call toc_06_654B
    call toc_01_0891
    jr   nz, .else_06_76B1

JumpTable_769D_06.loop_06_76A5:
    assign [$FFF2], $07
    call toc_01_0891
    ld   [hl], $20
    jp   JumpTable_3B8D_00

JumpTable_769D_06.else_06_76B1:
    call toc_01_3B9E
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00001111
    jr   nz, .loop_06_76A5

    ret


JumpTable_76BE_06:
    call toc_01_0891
    jr   nz, .return_06_7702

    ld   hl, $C380
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $75FD
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $7605
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    call toc_06_654B
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, bc
    cp   [hl]
    jr   nz, .return_06_7702

    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, bc
    cp   [hl]
    jr   nz, .return_06_7702

    call toc_01_0891
    ld   [hl], $20
    call JumpTable_3B8D_00
    ld   [hl], $01
JumpTable_76BE_06.return_06_7702:
    ret


    db   $6E, $00, $6E, $20, $66, $20, $64, $20
    db   $64, $00, $66, $00, $62, $00, $62, $20
    db   $60, $00, $60, $20, $08, $F8, $00, $00
    db   $00, $00, $F8, $08, $20, $E0, $00, $00
    db   $00, $00, $E0, $20, $11, $03, $77, $CD
    db   $3B, $3C, $CD, $DF, $64, $CD, $01, $65
    db   $CD, $4B, $65, $CD, $9E, $3B, $21, $90
    db   $C2, $09, $7E, $C7

    dw JumpTable_7747_06 ; 00
    dw JumpTable_775F_06 ; 01
    dw JumpTable_778F_06 ; 02
    dw JumpTable_77BD_06 ; 03

JumpTable_7747_06:
    ld   hl, $C2E0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_06_775D

    call JumpTable_3B8D_00
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], $01
    call toc_01_088C
    ld   [hl], $20
JumpTable_7747_06.else_06_775D:
    jr   JumpTable_775F_06.toc_06_777E

JumpTable_775F_06:
    call toc_01_088C
    jr   nz, .else_06_7779

    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C290
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    ld   hl, $C2E0
    add  hl, bc
    ld   [hl], $30
    call toc_06_7839
    ret


JumpTable_775F_06.else_06_7779:
    ld   a, [hl]
    and  %00000010
    jr   nz, .else_06_7787

JumpTable_775F_06.toc_06_777E:
    ld   a, $FF
    call toc_01_3B87
    call toc_06_7839
    ret


JumpTable_775F_06.else_06_7787:
    xor  a
    call toc_01_3B87
    call toc_06_7839
    ret


JumpTable_778F_06:
    xor  a
    call toc_01_3B87
    call toc_01_088C
    cp   $02
    jr   nc, .else_06_77B9

    ld   a, [hl]
    cp   $01
    jr   z, .else_06_77A5

    ld   [hl], $18
    call toc_06_7839
    ret


JumpTable_778F_06.else_06_77A5:
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C290
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    cp   $01
    jr   nz, .else_06_77B9

    call toc_01_088C
    ld   [hl], $20
JumpTable_778F_06.else_06_77B9:
    call toc_06_7839
    ret


JumpTable_77BD_06:
    call toc_01_3BB4
    call toc_01_088C
    cp   $28
    jr   z, .else_06_77ED

    cp   $02
    jr   nc, .else_06_7831

    ld   a, [hl]
    cp   $01
    jr   z, .else_06_77E1

    ld   [hl], $40
    call toc_06_65BE
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
    inc  a
    ld   hl, $C3B0
    add  hl, bc
    ld   [hl], a
    ret


JumpTable_77BD_06.else_06_77E1:
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], $FF
    ld   hl, $C290
    add  hl, bc
    dec  [hl]
    ret


JumpTable_77BD_06.else_06_77ED:
    ld   a, $22
    call toc_01_3C01
    jr   c, .else_06_7831

    push bc
    ld   a, [$FFD9]
    ld   hl, $C380
    add  hl, de
    ld   [hl], a
    ld   c, a
    ld   hl, $7717
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $771B
    add  hl, bc
    ld   a, [$FFD8]
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $771F
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $7723
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C250
    add  hl, de
    ld   [hl], a
    pop  bc
    ld   a, [$FFD9]
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], a
JumpTable_77BD_06.else_06_7831:
    ld   hl, $C340
    add  hl, bc
    ld   a, $02
    ld   [hl], a
    ret


toc_06_7839:
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $42
    ret


    db   $00, $D8, $60, $00, $00, $E0, $60, $20
    db   $00, $28, $60, $00, $00, $30, $60, $20
    db   $D8, $00, $62, $00, $D8, $08, $62, $20
    db   $28, $00, $62, $00, $28, $08, $62, $20
    db   $F0, $F0, $6A, $00, $F0, $F8, $6A, $60
    db   $F0, $10, $6A, $40, $F0, $18, $6A, $20
    db   $10, $F0, $6A, $40, $10, $F8, $6A, $20
    db   $10, $10, $6A, $00, $10, $18, $6A, $60
    db   $00, $E8, $60, $00, $00, $F0, $60, $20
    db   $00, $18, $60, $00, $00, $20, $60, $20
    db   $E8, $00, $62, $00, $E8, $08, $62, $20
    db   $18, $00, $62, $00, $18, $08, $62, $20
    db   $F0, $F0, $FF, $00, $F0, $F8, $FF, $00
    db   $F0, $10, $FF, $00, $F0, $18, $FF, $00
    db   $10, $F0, $FF, $00, $10, $F8, $FF, $00
    db   $10, $10, $FF, $00, $10, $18, $FF, $00
    db   $E0, $E0, $68, $00, $E0, $E8, $68, $60
    db   $20, $E0, $68, $40, $20, $E8, $68, $20
    db   $E0, $20, $68, $40, $E0, $28, $68, $20
    db   $20, $20, $68, $00, $20, $28, $68, $60
    db   $00, $F0, $64, $00, $00, $F8, $64, $20
    db   $F0, $00, $66, $00, $F0, $08, $66, $20
    db   $00, $10, $64, $00, $00, $18, $64, $20
    db   $10, $00, $66, $00, $10, $08, $66, $20
    db   $E8, $E8, $68, $00, $E8, $F0, $68, $60
    db   $18, $E8, $68, $40, $18, $F0, $68, $20
    db   $E8, $18, $68, $40, $E8, $20, $68, $20
    db   $18, $18, $68, $00, $18, $20, $68, $60
    db   $00, $F0, $FF, $00, $00, $F8, $FF, $20
    db   $F0, $00, $FF, $00, $F0, $08, $FF, $20
    db   $00, $10, $FF, $00, $00, $18, $FF, $20
    db   $10, $00, $FF, $00, $10, $08, $FF, $20

toc_06_7940:
    call toc_06_64DF
    ld   a, [$FFE7]
    rra
    rra
    rra
    and  %00000011
    ld   e, a
    ld   d, b
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    sla  e
    rl   d
    ld   hl, $7840
    add  hl, de
    ld   c, $10
    call toc_01_3D26
    ld   a, $10
    call toc_01_3DD0
    ret


    db   $5A, $00, $5A, $20, $5A, $10, $5A, $30
    db   $11, $73, $79, $CD, $3B, $3C, $CD, $DF
    db   $64, $CD, $01, $65, $CD, $B4, $3B, $CD
    db   $4B, $65, $CD, $9E, $3B, $21, $A0, $C2
    db   $09, $7E, $E6, $03, $20, $07, $7E, $E6
    db   $0C, $20, $0C, $18, $12, $21, $40, $C2
    db   $09, $7E, $2F, $3C, $77, $18, $08, $21
    db   $50, $C2, $09, $7E, $2F, $3C, $77, $F0
    db   $E7, $1F, $1F, $1F, $E6, $01, $CD, $87
    db   $3B, $C9, $58, $00, $58, $20, $5A, $00
    db   $5A, $20, $10, $F0, $10, $F0, $10, $10
    db   $F0, $F0, $11, $BD, $79, $CD, $3B, $3C
    db   $CD, $DF, $64, $CD, $01, $65, $CD, $B4
    db   $3B, $CD, $4B, $65, $CD, $9E, $3B, $21
    db   $A0, $C2, $09, $7E, $E6, $03, $28, $03
    db   $CD, $83, $7A, $7E, $E6, $0C, $28, $03
    db   $CD, $88, $7A, $F0, $F0, $A7, $20, $2D
    db   $21, $10, $C3, $09, $7E, $E6, $80, $28
    db   $1B, $AF, $77, $CD, $AF, $3D, $21, $90
    db   $C2, $09, $34, $CD, $91, $08, $CD, $ED
    db   $27, $E6, $3F, $C6, $10, $77, $3E, $01
    db   $CD, $87, $3B, $C9, $CD, $84, $65, $21
    db   $20, $C3, $09, $35, $C9, $21, $D0, $C3
    db   $09, $34, $7E, $E6, $10, $CB, $3F, $CB
    db   $3F, $CB, $3F, $CB, $3F, $CD, $87, $3B
    db   $A7, $20, $44, $CD, $91, $08, $20, $3F
    db   $CD, $ED, $27, $E6, $07, $C6, $10, $21
    db   $20, $C3, $09, $77, $CD, $84, $65, $CD
    db   $ED, $27, $E6, $03, $5F, $50, $21, $C5
    db   $79, $19, $7E, $21, $40, $C2, $09, $77
    db   $21, $C9, $79, $19, $7E, $21, $50, $C2
    db   $09, $77, $CD, $ED, $27, $E6, $01, $28
    db   $05, $3E, $14, $CD, $25, $3C, $21, $90
    db   $C2, $09, $AF, $77, $CD, $87, $3B, $C9
    db   $21, $40, $C2, $18, $04, $21, $40, $C2
    db   $09, $7E, $2F, $3C, $CB, $2F, $77, $C9
    db   $62, $20, $60, $20, $66, $20, $64, $20
    db   $60, $00, $62, $00, $64, $00, $66, $00
    db   $68, $00, $68, $20, $6A, $00, $6A, $20
    db   $6E, $20, $6C, $20, $6C, $00, $6E, $00
    db   $11, $93, $7A, $CD, $3B, $3C, $CD, $DF
    db   $64, $CD, $01, $65, $CD, $4B, $65, $CD
    db   $BC, $5E, $F0, $F0, $C7

    dw JumpTable_7ACC_06 ; 00
    dw JumpTable_7B4B_06 ; 01

JumpTable_7ACC_06:
    ld   a, [$C1A2]
    and  a
    jp   nz, .toc_06_7B45

    call toc_01_0891
    jr   nz, .else_06_7B1B

    call toc_01_088C
    jr   nz, .else_06_7B2C

    ifEq [$C137], $03, .else_06_7B04

    call toc_01_27ED
    xor  c
    and  %00000111
    add  a, $06
    call toc_01_3C30
    ld   a, [$FFD7]
    ld   hl, $C250
    call toc_06_7B86
    ld   a, [$FFD8]
    ld   hl, $C240
    call toc_06_7B86
    call toc_01_3BBF
    jr   .else_06_7B33

JumpTable_7ACC_06.else_06_7B04:
    call toc_06_659E
    add  a, $24
    cp   $48
    jr   nc, .else_06_7B33

    call toc_06_65AE
    add  a, $24
    cp   $48
    jr   nc, .else_06_7B33

    call toc_01_0891
    ld   [hl], $20
JumpTable_7ACC_06.else_06_7B1B:
    call toc_01_3DAF
    call toc_06_7BBD
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_06_7B44

    call toc_06_7B99
JumpTable_7ACC_06.else_06_7B2C:
    call toc_01_3DAF
    call toc_06_7BBD
    ret


JumpTable_7ACC_06.else_06_7B33:
    call toc_06_659E
    sla  e
    ld   a, [$FFE7]
    rra
    rra
    rra
    rra
    and  %00000001
    add  a, e
    call toc_01_3B87
JumpTable_7ACC_06.return_06_7B44:
    ret


JumpTable_7ACC_06.toc_06_7B45:
    call JumpTable_3B8D_00
    ld   [hl], $01
    ret


JumpTable_7B4B_06:
    ifNot [$C1A2], .else_06_7B81

    ld   hl, $C360
    add  hl, bc
    ld   [hl], $01
    call toc_01_3BB4
    ld   a, $04
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
    ld   a, [$FFE7]
    rra
    rra
    rra
    rra
    and  %00000001
    add  a, $04
    ld   hl, $C3B0
    add  hl, bc
    ld   [hl], a
    ret


JumpTable_7B4B_06.else_06_7B81:
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


toc_06_7B86:
    add  hl, bc
    sub  a, [hl]
    jr   z, .return_06_7B98

    bit  7, a
    jr   z, .else_06_7B94

    dec  [hl]
    dec  [hl]
    dec  [hl]
    dec  [hl]
    jr   .return_06_7B98

toc_06_7B86.else_06_7B94:
    inc  [hl]
    inc  [hl]
    inc  [hl]
    inc  [hl]
toc_06_7B86.return_06_7B98:
    ret


toc_06_7B99:
    call toc_01_088C
    ld   [hl], $20
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], $00
    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    sub  a, $48
    ld   e, a
    ld   a, $48
    sub  a, e
    ld   [hl], a
    ld   hl, $C200
    add  hl, bc
    ld   a, [hl]
    sub  a, $50
    ld   e, a
    ld   a, $50
    sub  a, e
    ld   [hl], a
    ret


toc_06_7BBD:
    ld   a, [$FFE7]
    rra
    rra
    and  %00000001
    jr   z, .else_06_7BD4

    call toc_06_659E
    srl  e
    jr   c, .else_06_7BD0

    ld   a, $06
    jr   .toc_06_7BD6

toc_06_7BBD.else_06_7BD0:
    ld   a, $07
    jr   .toc_06_7BD6

toc_06_7BBD.else_06_7BD4:
    ld   a, $FF
toc_06_7BBD.toc_06_7BD6:
    call toc_01_3B87
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], b
    call toc_01_0891
    cp   $01
    jr   nz, .return_06_7BEA

    ld   hl, $C2B0
    add  hl, bc
    inc  [hl]
toc_06_7BBD.return_06_7BEA:
    ret


    db   $A6, $10, $8E, $10, $80, $10, $A6, $10
    db   $A9, $10, $2A, $40, $2A, $60, $00, $FC
    db   $22, $00, $00, $0C, $22, $20, $00, $FC
    db   $22, $40, $00, $0C, $22, $60, $0F, $0F
    db   $10, $11, $11, $11, $10, $0F, $00, $00
    db   $01, $02, $02, $02, $01, $00, $21, $09
    db   $7C, $F0, $F9, $A7, $28, $03, $21, $11
    db   $7C, $F0, $E7, $1F, $1F, $1F, $E6, $07
    db   $5F, $50, $19, $7E, $21, $10, $C3, $09
    db   $77, $F0, $F1, $FE, $05, $20, $08, $11
    db   $E1, $7B, $CD, $3B, $3C, $18, $06, $11
    db   $EB, $7B, $CD, $D0, $3C, $F0, $E7, $E6
    db   $08, $5F, $50, $21, $F9, $7B, $19, $0E
    db   $02, $CD, $26, $3D, $3E, $01, $CD, $D0
    db   $3D, $CD, $BA, $3D, $CD, $DF, $64, $F0
    db   $F9, $A7, $20, $06, $F0, $A2, $FE, $0C
    db   $38, $3A, $CD, $D5, $3B, $30, $35, $CD
    db   $88, $3F, $CD, $E5, $65, $3E, $01, $E0
    db   $F3, $F0, $F1, $C7

    dw JumpTable_7CA2_06 ; 00
    dw JumpTable_7CA8_06 ; 01
    dw JumpTable_7CB9_06 ; 02
    dw JumpTable_7CA2_06 ; 03
    dw JumpTable_7C8B_06 ; 04
    dw JumpTable_7C98_06 ; 05

JumpTable_7C8B_06:
    ld   a, [$DB93]
    add  a, $18
    jr   nc, .else_06_7C94

    ld   a, $FF
JumpTable_7C8B_06.else_06_7C94:
    ld   [$DB93], a
    ret


JumpTable_7C98_06:
    ld   a, [$DB45]
    add  a, $10
    daa
    ld   [$DB45], a
    ret


JumpTable_7CA2_06:
    assign [$DB90], $0A
    ret


JumpTable_7CA8_06:
    ld   d, $0C
    call toc_01_3E95
    assign [$FFA5], $0B
    ld   hl, $DB76
    ld   de, $DB4C
    jr   JumpTable_7CB9_06.toc_06_7CBF

JumpTable_7CB9_06:
    ld   hl, $DB77
    ld   de, $DB4D
JumpTable_7CB9_06.toc_06_7CBF:
    ld   a, [de]
    cp   [hl]
    jr   nc, .return_06_7CCB

    add  a, $10
    daa
    cp   [hl]
    jr   c, .else_06_7CCA

    ld   a, [hl]
JumpTable_7CB9_06.else_06_7CCA:
    ld   [de], a
JumpTable_7CB9_06.return_06_7CCB:
    ret


    db   $56, $00, $56, $20, $CD, $DC, $7C, $11
    db   $CC, $7C, $CD, $D0, $3C, $C3, $05, $7D
    db   $F0, $F7, $FE, $0A, $C0, $F0, $F6, $FE
    db   $97, $28, $03, $FE, $98, $C0, $FA, $7F
    db   $DB, $A7, $C8, $3E, $FF, $E0, $F1, $C9
    db   $52, $00, $52, $20, $54, $00, $54, $20
    db   $CD, $DC, $7C, $11, $F4, $7C, $CD, $3B
    db   $3C, $21, $AE, $C1, $34, $CD, $DF, $64
    db   $CD, $84, $65, $21, $20, $C3, $09, $35
    db   $35, $35, $21, $10, $C3, $09, $7E, $E6
    db   $80, $E0, $E8, $28, $06, $70, $21, $20
    db   $C3, $09, $70, $F0, $EB, $FE, $1B, $20
    db   $61, $21, $20, $C4, $09, $7E, $FE, $08
    db   $20, $58, $70, $21, $60, $C4, $09, $7E
    db   $E5, $F5, $21, $A0, $C3, $09, $36, $1C
    db   $CD, $26, $38, $F1, $E1, $77, $21, $00
    db   $C2, $09, $7E, $D6, $04, $77, $CD, $AF
    db   $3D, $21, $10, $C4, $09, $70, $21, $20
    db   $C3, $09, $36, $20, $3E, $1C, $CD, $01
    db   $3C, $38, $27, $21, $60, $C4, $09, $7E
    db   $21, $60, $C4, $19, $77, $F0, $D7, $C6
    db   $08, $21, $00, $C2, $19, $77, $F0, $D8
    db   $21, $10, $C2, $19, $77, $F0, $DA, $21
    db   $10, $C3, $19, $77, $21, $20, $C3, $19
    db   $36, $20, $CD, $01, $65, $21, $00, $C3
    db   $09, $7E, $A7, $20, $12, $F0, $F0, $E6
    db   $01, $21, $B0, $C3, $09, $77, $3D, $20
    db   $06, $21, $00, $C3, $09, $36, $08, $F0
    db   $F0, $FE, $04, $28, $0B, $21, $80, $C4
    db   $09, $7E, $A7, $20, $03, $CD, $B4, $3B
    db   $F0, $F0, $C7

    dw JumpTable_7DFC_06 ; 00
    dw JumpTable_7DC9_06 ; 01
    dw JumpTable_7E0F_06 ; 02
    dw JumpTable_7E3C_06 ; 03
    dw JumpTable_7E49_06 ; 04

JumpTable_7DC9_06:
    call toc_01_0891
    jr   nz, .else_06_7DE6

    ld   [hl], $10
    call toc_01_3DAF
    call toc_01_27ED
    and  %00001111
    jr   nz, .else_06_7DE2

    call toc_01_0891
    ld   [hl], $50
    jp   JumpTable_3B8D_00

JumpTable_7DC9_06.else_06_7DE2:
    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_7DC9_06.else_06_7DE6:
    call toc_06_654B
    call toc_01_088C
    ret  nz

    ld   hl, $C410
    add  hl, bc
    ld   [hl], $02
    call toc_01_3B9E
    ld   hl, $C410
    add  hl, bc
    ld   [hl], b
    ret


JumpTable_7DFC_06:
    call JumpTable_7DC9_06.else_06_7DE6
    call toc_01_0891
    jr   nz, .return_06_7E0E

    ld   [hl], $07
    call JumpTable_3B8D_00
    ld   a, $04
    call toc_01_3C25
JumpTable_7DFC_06.return_06_7E0E:
    ret


JumpTable_7E0F_06:
    call toc_01_0891
    jr   nz, .else_06_7E23

    call JumpTable_3B8D_00
    ld   a, $10
    call toc_01_3C25
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $20
    ret


JumpTable_7E0F_06.else_06_7E23:
    call toc_01_0891
    ld   hl, $C240
    add  hl, bc
    and  %00000100
    jr   nz, .else_06_7E32

    ld   [hl], $08
    jr   .toc_06_7E34

JumpTable_7E0F_06.else_06_7E32:
    ld   [hl], $F8
JumpTable_7E0F_06.toc_06_7E34:
    ld   hl, $C250
    add  hl, bc
    ld   [hl], b
    jp   JumpTable_7DC9_06.else_06_7DE6

JumpTable_7E3C_06:
    call JumpTable_7DC9_06.else_06_7DE6
    ifNot [$FFE8], .return_06_7E48

    call JumpTable_3B8D_00
    ld   [hl], b
JumpTable_7E3C_06.return_06_7E48:
    ret


JumpTable_7E49_06:
    call toc_01_0891
    jr   nz, .else_06_7E6A

    ld   hl, $C480
    add  hl, bc
    ld   [hl], $30
    ld   a, $10
    call toc_01_3C25
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $20
    ld   hl, $C310
    add  hl, bc
    inc  [hl]
    call JumpTable_3B8D_00
    ld   [hl], $03
    ret


JumpTable_7E49_06.else_06_7E6A:
    push af
    rra
    and  %00000111
    sub  a, $04
    ld   e, a
    ld   a, [$FF98]
    sub  a, e
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    pop  af
    rra
    rra
    and  %00000111
    sub  a, $04
    ld   e, a
    ld   a, [$FF99]
    sub  a, e
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    ld   a, [$FFA2]
    ld   hl, $C310
    add  hl, bc
    ld   [hl], a
    assign [$C117], $01
    call toc_01_3B9E
    ifNot [$FFCC], .return_06_7EAC

    call .toc_06_7EA6
    call .toc_06_7EA6
    call .toc_06_7EA6
JumpTable_7E49_06.toc_06_7EA6:
    call toc_01_0891
    jr   z, .return_06_7EAC

    dec  [hl]
JumpTable_7E49_06.return_06_7EAC:
    ret


    db   $7C, $00, $7C, $20, $7E, $00, $7E, $20
    db   $11, $AD, $7E, $CD, $3B, $3C, $CD, $DF
    db   $64, $CD, $01, $65, $21, $D0, $C2, $09
    db   $7E, $C7

    dw JumpTable_7ECB_06 ; 00
    dw JumpTable_7EE5_06 ; 01

JumpTable_7ECB_06:
    call toc_01_0887
    jr   nz, .else_06_7EDF

    call toc_01_3BBF
    jr   nc, .else_06_7EDF

    ld   hl, $C2D0
    add  hl, bc
    inc  [hl]
    ld   hl, $C3D0
    add  hl, bc
    ld   [hl], b
JumpTable_7ECB_06.else_06_7EDF:
    call toc_01_3BEB
    jp   toc_06_7F77

JumpTable_7EE5_06:
    ld   a, [$FFCC]
    and  %00110000
    jr   z, .else_06_7F00

    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    cp   $08
    jr   c, .else_06_7F00

    call toc_01_0887
    ld   [hl], $15
    ld   hl, $C2D0
    add  hl, bc
    ld   [hl], b
    ret


JumpTable_7EE5_06.else_06_7F00:
    assign [$FF9D], $FF
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_06_7F2E

    ld   hl, $DB00
    ld   e, b
JumpTable_7EE5_06.loop_06_7F10:
    ld   a, [hl]
    cp   $04
    jr   nz, .else_06_7F27

    ifGte [$DB44], $02, .else_06_7F2E

    ld   [hl], b
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [$DB44]
    ld   [hl], a
    jr   .else_06_7F2E

JumpTable_7EE5_06.else_06_7F27:
    inc  hl
    inc  e
    ld   a, e
    cp   $02
    jr   nz, .loop_06_7F10

JumpTable_7EE5_06.else_06_7F2E:
    ld   a, [$C11C]
    cp   $00
    ret  nz

    copyFromTo [$FFEE], [$FF98]
    copyFromTo [$FFEF], [$FF99]
    clear [$C146]
    ld   [$FFA2], a
    call toc_06_7FDF
    call toc_06_7FDF
    ret


    db   $74, $00, $76, $00, $76, $20, $74, $20
    db   $44, $00, $46, $00, $46, $20, $44, $20
    db   $00, $08, $F8, $00, $F8, $08, $11, $49
    db   $7F, $F0, $F7, $FE, $07, $20, $03, $11
    db   $51, $7F, $CD, $3B, $3C, $CD, $DF, $64
    db   $CD, $E2, $08, $CD, $B4, $3B

toc_06_7F77:
    call toc_06_654B
    call toc_01_3B9E
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00000011
    jr   nz, toc_06_7F95

    ld   a, [hl]
    and  %00001100
    jr   z, toc_06_7F9D

    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    xor  $F0
    ld   [hl], a
    jr   toc_06_7F9D

toc_06_7F95:
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    xor  $F0
    ld   [hl], a
toc_06_7F9D:
    ld   hl, $C290
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, toc_06_7FAC

    call toc_01_27ED
    and  %00111111
    jr   nz, toc_06_7FD9

toc_06_7FAC:
    xor  a
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    call toc_01_27ED
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $7F59
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    and  a
    jr   nz, toc_06_7FD9

    call toc_01_27ED
    and  %00000001
    add  a, $04
    ld   e, a
    ld   d, b
    ld   hl, $7F59
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
toc_06_7FD9:
    ld   hl, $C290
    add  hl, bc
    xor  a
    ld   [hl], a
toc_06_7FDF:
    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    inc  [hl]
    rra
    rra
    rra
    rra
    and  %00000001
    jp   toc_01_3B87

    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF
