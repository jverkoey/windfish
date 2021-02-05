SECTION "ROM Bank 19", ROMX[$4000], BANK[$19]

    db   $F0, $00, $48, $00, $F0, $08, $48, $20
    db   $00, $00, $4A, $00, $00, $08, $4A, $20
    db   $F0, $00, $78, $00, $F0, $08, $78, $20
    db   $00, $00, $7A, $00, $00, $08, $7A, $20
    db   $16, $00, $21, $B0, $C2, $09, $7E, $A7
    db   $28, $20, $11, $20, $40, $CD, $D0, $3C
    db   $CD, $9B, $78, $CD, $07, $79, $CD, $40
    db   $79, $21, $20, $C3, $09, $35, $35, $21
    db   $10, $C3, $09, $7E, $E6, $80, $C2, $B0
    db   $79, $C9, $21, $00, $40, $F0, $F7, $FE
    db   $01, $20, $03, $21, $10, $40, $0E, $04
    db   $CD, $26, $3D, $CD, $19, $3D, $CD, $9B
    db   $78, $CD, $E2, $08, $CD, $EB, $3B, $F0
    db   $F0, $C7

    dw JumpTable_4070_19 ; 00

    db   $23, $41, $23, $41

JumpTable_4070_19:
    call toc_01_3B9E
    call toc_19_7800
    call toc_19_795A
    add  a, $10
    cp   $20
    jp   nc, .else_19_411C

    call toc_19_796A
    add  a, $20
    cp   $30
    jp   nc, .else_19_411C

    ifZero [$C19B], .else_19_411C

    ifEq [$DB00], $03, .else_19_40A0

    ld   a, [hPressedButtonsMask]
    and  J_B
    jr   nz, .else_19_40AD

    jr   .else_19_411C

.else_19_40A0:
    ifEq [$DB01], $03, .else_19_411C

    ld   a, [hPressedButtonsMask]
    and  J_A
    jr   z, .else_19_411C

.else_19_40AD:
    _ifZero [$C3CF], .else_19_411C

    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_GRAB_SLASH
    ld   [$C3CF], a
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
    jr   z, .else_19_411C

    ld   hl, $1E6B
    add  hl, de
    ld   a, [hl]
    ld   [$C13C], a
    ld   hl, $1E6F
    add  hl, de
    ld   a, [hl]
    ld   [$C13B], a
    incAddr hLinkAnimationState
    ifEq [$DB43], $02, .else_19_411C

    ld   e, $08
    ifNotZero [$D47C], .else_19_40F4

    ld   e, $03
.else_19_40F4:
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    cp   e
    jr   c, .return_19_4122

    call JumpTable_3B8D_00
    ld   [hl], $02
    ld   hl, $C280
    add  hl, bc
    ld   [hl], $07
    ld   hl, $C490
    add  hl, bc
    ld   [hl], b
    copyFromTo [hLinkDirection], [$C15D]
    call toc_01_0891
    ld   [hl], $02
    ld   hl, $FFF3
    ld   [hl], $02
.else_19_411C:
    ld   hl, $C3D0
    add  hl, bc
    ld   [hl], b
    ret


.return_19_4122:
    ret


    db   $CD, $07, $79, $CD, $40, $79, $CD, $9E
    db   $3B, $21, $20, $C3, $09, $35, $35, $21
    db   $A0, $C2, $09, $7E, $E6, $0F, $20, $09
    db   $21, $10, $C3, $09, $7E, $E6, $80, $28
    db   $25, $CD, $88, $41, $FA, $8E, $C1, $E6
    db   $1F, $FE, $0B, $20, $19, $FA, $0D, $C5
    db   $FE, $35, $38, $04, $FE, $3D, $38, $0B
    db   $FA, $03, $C5, $FE, $35, $38, $07, $FE
    db   $3D, $30, $03, $CD, $EC, $08, $C9, $00
    db   $08, $00, $08, $00, $08, $F8, $F8, $00
    db   $00, $08, $08, $FC, $05, $FA, $06, $FB
    db   $04, $FC, $F8, $FE, $FF, $03, $02, $18
    db   $14, $13, $16, $12, $14, $3E, $00, $E0
    db   $E8, $3E, $9D, $CD, $01, $3C, $38, $54
    db   $21, $B0, $C2, $19, $34, $21, $40, $C3
    db   $19, $36, $C1, $C5, $F0, $E8, $4F, $21
    db   $6A, $41, $09, $F0, $D7, $86, $21, $00
    db   $C2, $19, $77, $21, $70, $41, $09, $F0
    db   $D8, $86, $21, $10, $C2, $19, $77, $F0
    db   $DA, $21, $10, $C3, $19, $77, $21, $76
    db   $41, $09, $7E, $21, $40, $C2, $19, $77
    db   $21, $7C, $41, $09, $7E, $21, $50, $C2
    db   $19, $77, $21, $82, $41, $09, $7E, $21
    db   $20, $C3, $19, $77, $C1, $F0, $E8, $3C
    db   $FE, $06, $20, $A3, $3E, $29, $E0, $F4
    db   $F0, $EE, $E0, $D7, $F0, $EC, $E0, $D8
    db   $3E, $02, $CD, $53, $09, $F0, $EC, $D6
    db   $10, $E0, $D8, $3E, $02, $CD, $53, $09
    db   $C3, $B0, $79, $17, $11, $36, $28, $45
    db   $52, $7A, $64, $93, $A1, $C5, $D4, $28
    db   $0E, $3F, $5D, $FA, $A5, $DB, $A7, $20
    db   $5A, $F0, $F6, $FE, $CE, $C2, $05, $44
    db   $CD, $9B, $78, $FA, $46, $C1, $A7, $C0
    db   $F0, $98, $D6, $50, $C6, $03, $FE, $06
    db   $D0, $F0, $99, $D6, $46, $C6, $04, $FE
    db   $08, $D0, $3E, $01, $EA, $01, $D4, $3E
    db   $1F, $EA, $02, $D4, $3E, $F8, $EA, $03
    db   $D4, $3E, $50, $EA, $04, $D4, $E0, $98
    db   $3E, $48, $EA, $05, $D4, $E0, $99, $3E
    db   $45, $EA, $16, $D4, $3E, $06, $EA, $1C
    db   $C1, $CD, $3B, $09, $EA, $98, $C1, $3E
    db   $51, $EA, $CB, $DB, $3E, $0C, $E0, $F3
    db   $C3, $B0, $79, $3E, $01, $EA, $9D, $C1
    db   $F0, $F7, $5F, $50, $21, $65, $DB, $19
    db   $7E, $E6, $01, $CA, $DE, $42, $CD, $A7
    db   $43, $F0, $F0, $C7

    dw JumpTable_4297_19 ; 00

    db   $A0, $42, $B6, $42, $F3, $42

JumpTable_4297_19:
    call JumpTable_3B8D_00
    assign [$D368], $1B
    ret


    db   $CD, $5A, $79, $C6, $04, $FE, $08, $30
    db   $09, $CD, $6A, $79, $C6, $04, $FE, $08
    db   $38, $03, $CD, $8D, $3B, $C9, $F0, $A2
    db   $A7, $20, $23, $CD, $5A, $79, $C6, $03
    db   $FE, $06, $30, $1A, $CD, $6A, $79, $C6
    db   $03, $FE, $06, $30, $11, $CD, $8D, $3B
    db   $3E, $20, $EA, $C6, $C1, $CD, $91, $08
    db   $36, $50, $3E, $1C, $E0, $F2, $C9, $E4
    db   $E4, $E4, $E4, $94, $94, $94, $94, $54
    db   $54, $54, $54, $00, $00, $00, $00, $00
    db   $03, $01, $02, $CD, $3B, $09, $EA, $94
    db   $DB, $EA, $C7, $DB, $EA, $3E, $C1, $EA
    db   $37, $C1, $EA, $6A, $C1, $EA, $66, $C1
    db   $EA, $A9, $C1, $3C, $EA, $67, $C1, $F0
    db   $EE, $E0, $98, $F0, $EC, $E0, $99, $CD
    db   $91, $08, $20, $37, $21, $01, $D4, $3E
    db   $01, $22, $F0, $F7, $22, $23, $3E, $50
    db   $22, $E5, $F0, $F7, $5F, $CB, $23, $16
    db   $00, $21, $06, $42, $19, $F0, $F6, $BE
    db   $20, $01, $23, $7E, $EA, $03, $D4, $E1
    db   $FE, $64, $3E, $48, $20, $02, $3E, $28
    db   $77, $AF, $EA, $67, $C1, $CD, $B0, $79
    db   $C3, $2A, $09, $21, $A1, $FF, $36, $01
    db   $F5, $F0, $E7, $1F, $1F, $1F, $E6, $03
    db   $5F, $50, $21, $EF, $42, $19, $7E, $E0
    db   $9E, $C5, $CD, $7C, $08, $C1, $21, $40
    db   $C4, $09, $F1, $FE, $40, $30, $0A, $E6
    db   $03, $20, $06, $7E, $FE, $0C, $28, $01
    db   $34, $F0, $E7, $E6, $03, $86, $5F, $50
    db   $21, $DF, $42, $19, $7E, $EA, $97, $DB
    db   $C9, $1E, $00, $1E, $60, $1E, $40, $1E
    db   $20, $F8, $FA, $00, $06, $08, $06, $00
    db   $FA, $F8, $FA, $24, $00, $24, $00, $21
    db   $40, $C3, $09, $36, $C2, $F0, $E7, $1F
    db   $1F, $1F, $E6, $01, $E0, $F1, $11, $91
    db   $43, $CD, $3B, $3C, $21, $40, $C3, $09
    db   $36, $C1, $AF, $E0, $E8, $5F, $CD, $D2
    db   $43, $F0, $E8, $C6, $02, $E6, $07, $20
    db   $F2, $C9, $F0, $E7, $1F, $1F, $1F, $00
    db   $83, $E6, $07, $5F, $50, $21, $9B, $43
    db   $19, $F0, $EE, $86, $E0, $EE, $21, $99
    db   $43, $19, $F0, $EC, $86, $E0, $EC, $11
    db   $A3, $43, $CD, $D0, $3C, $CD, $BA, $3D
    db   $C9, $FA, $FC, $00, $04, $06, $04, $00
    db   $FC, $FA, $FC, $3E, $00, $21, $40, $C3
    db   $09, $36, $C1, $F0, $E7, $17, $17, $E6
    db   $10, $E0, $ED, $F0, $EE, $E0, $E5, $F0
    db   $EC, $E0, $E6, $AF, $E0, $E8, $5F, $CD
    db   $2B, $44, $F0, $E8, $C6, $02, $E6, $07
    db   $20, $F2, $C9, $F0, $E7, $1F, $1F, $1F
    db   $00, $83, $E6, $07, $5F, $50, $21, $FB
    db   $43, $19, $F0, $E5, $86, $E0, $EE, $21
    db   $F9, $43, $19, $F0, $E6, $86, $C6, $04
    db   $E0, $EC, $11, $03, $44, $CD, $D0, $3C
    db   $C9, $38, $10, $38, $30, $A4, $10, $FF
    db   $FF, $38, $50, $38, $70, $FF, $FF, $A4
    db   $30, $3E, $01, $EA, $4D, $C1, $11, $51
    db   $44, $CD, $3B, $3C, $CD, $9B, $78, $CD
    db   $C5, $29, $F0, $E7, $E6, $03, $20, $09
    db   $21, $B0, $C3, $09, $7E, $3C, $E6, $03
    db   $77, $3E, $08, $EA, $9E, $C1, $CD, $F6
    db   $3B, $CD, $07, $79, $CD, $A9, $3B, $CD
    db   $CF, $44, $F0, $F0, $C7

    dw JumpTable_4499_19 ; 00

    db   $BB, $44

JumpTable_4499_19:
    call toc_01_0891
    jr   nz, .else_19_44A7

    ld   a, $08
    call toc_01_3C25
    call JumpTable_3B8D_00
    ret


.else_19_44A7:
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_19_44BA

    call toc_01_0891
    ld   [hl], b
    call toc_19_45A6
    assign [$FFF2], $07
.return_19_44BA:
    ret


    db   $F0, $E7, $E6, $03, $20, $05, $3E, $20
    db   $CD, $25, $3C, $CD, $BF, $3B, $30, $03
    db   $CD, $B0, $79, $C9, $FA, $A5, $DB, $A7
    db   $C0, $F0, $AF, $FE, $D3, $28, $03, $FE
    db   $5C, $C0, $21, $A0, $C2, $09, $70, $F0
    db   $E9, $5F, $50, $CD, $A6, $20, $F0, $CE
    db   $C6, $08, $E0, $D7, $F0, $CD, $C6, $10
    db   $E0, $D8, $3E, $08, $CD, $53, $09, $3E
    db   $13, $E0, $F4, $C9, $00, $00, $08, $20
    db   $00, $08, $06, $20, $00, $00, $06, $00
    db   $00, $08, $08, $00, $00, $04, $04, $40
    db   $FF, $FF, $FF, $FF, $00, $04, $04, $00
    db   $FF, $FF, $FF, $FF, $00, $00, $FC, $04
    db   $01, $01, $00, $00, $21, $4D, $C1, $34
    db   $F0, $F0, $A7, $20, $35, $F0, $9E, $5F
    db   $50, $21, $1F, $45, $19, $F0, $98, $86
    db   $21, $00, $C2, $09, $77, $21, $23, $45
    db   $19, $F0, $99, $86, $21, $10, $C2, $09
    db   $77, $21, $40, $C2, $09, $CB, $26, $21
    db   $50, $C2, $09, $CB, $26, $21, $20, $C4
    db   $09, $36, $FF, $3E, $3B, $E0, $F2, $C3
    db   $8D, $3B, $CD, $B6, $45, $CD, $9B, $78
    db   $3E, $01, $EA, $9E, $C1, $CD, $F6, $3B
    db   $CD, $07, $79, $CD, $A9, $3B, $21, $A0
    db   $C2, $09, $7E, $A7, $20, $22, $F0, $E7
    db   $3C, $E6, $03, $20, $1A, $F0, $EE, $E0
    db   $D7, $F0, $EC, $E0, $D8, $3E, $0D, $CD
    db   $53, $09, $21, $20, $C5, $19, $36, $08
    db   $F0, $F1, $21, $90, $C5, $19, $77, $C9
    db   $CD, $B0, $79

toc_19_45A6:
    copyFromTo [$FFEE], [$FFD7]
    ld   a, [$FFEC]
    add  a, $03
    ld   [$FFD8], a
    ld   a, $05
    call toc_01_0953
    ret


    db   $F0, $F1, $17, $17, $17, $E6, $F8, $5F
    db   $50, $21, $FF, $44, $19, $0E, $02, $CD
    db   $26, $3D, $C9, $60, $00, $62, $00, $62
    db   $20, $60, $20, $64, $00, $66, $00, $66
    db   $20, $64, $20, $68, $00, $6A, $00, $6C
    db   $00, $6E, $00, $6A, $20, $68, $20, $6E
    db   $20, $6C, $20, $21, $40, $C3, $09, $CB
    db   $F6, $CB, $FE, $FA, $0E, $DB, $FE, $0E
    db   $C2, $B0, $79, $21, $00, $C2, $09, $36
    db   $50, $11, $C9, $45, $CD, $3B, $3C, $CD
    db   $32, $78, $F0, $E7, $E6, $3F, $20, $08
    db   $CD, $89, $79, $21, $80, $C3, $09, $73
    db   $CD, $00, $78, $F0, $F0, $C7

    dw JumpTable_4624_19 ; 00

    db   $55, $46, $05, $47, $A9, $46

JumpTable_4624_19:
    call toc_19_789B
    ld   e, b
    ld   a, [hLinkPositionY]
    ld   hl, $FFEF
    sub  a, [hl]
    add  a, 38
    cp   76
    call toc_19_784E.toc_19_7859
    ret  nc

    ifNe [$DB7D], $00, .else_19_4641

    cp   $0D
    jr   nz, .else_19_464A

.else_19_4641:
    ld   a, $21
    call toc_01_218E
    call JumpTable_3B8D_00
    ret


.else_19_464A:
    ld   a, $25
    call toc_01_218E
    call JumpTable_3B8D_00
    ld   [hl], $03
    ret


    db   $CD, $9B, $78, $CD, $8D, $3B, $FA, $77
    db   $C1, $A7, $20, $3A, $FA, $00, $DB, $A7
    db   $28, $34, $FE, $01, $28, $37, $FE, $04
    db   $28, $33, $FE, $03, $28, $2F, $FE, $02
    db   $28, $2B, $FE, $09, $28, $27, $FE, $0C
    db   $28, $23, $FE, $05, $28, $1F, $EA, $7D
    db   $DB, $3E, $0D, $EA, $00, $DB, $21, $B0
    db   $C2, $09, $77, $CD, $91, $08, $36, $80
    db   $3E, $10, $EA, $68, $D3, $C9, $70, $3E
    db   $23, $CD, $8E, $21, $C9, $70, $3E, $27
    db   $CD, $8E, $21, $C9, $CD, $9B, $78, $CD
    db   $8D, $3B, $36, $02, $FA, $77, $C1, $A7
    db   $20, $2B, $21, $00, $DB, $11, $00, $00
    db   $7E, $FE, $0D, $28, $07, $23, $1C, $7B
    db   $FE, $0C, $20, $F4, $FA, $7D, $DB, $77
    db   $21, $B0, $C2, $09, $77, $3E, $0D, $EA
    db   $7D, $DB, $CD, $91, $08, $36, $80, $3E
    db   $10, $EA, $68, $D3, $C9, $70, $3E, $23
    db   $CD, $8E, $21, $C9, $00, $10, $84, $10
    db   $80, $10, $82, $10, $86, $10, $88, $10
    db   $8A, $10, $8C, $10, $98, $10, $90, $10
    db   $92, $10, $96, $10, $8E, $10, $A4, $10
    db   $CD, $91, $08, $20, $05, $CD, $8D, $3B
    db   $70, $C9, $FE, $08, $20, $11, $35, $21
    db   $B0, $C2, $09, $7E, $FE, $0D, $3E, $24
    db   $28, $02, $3E, $26, $CD, $8E, $21, $F0
    db   $98, $E0, $EE, $F0, $99, $D6, $0C, $E0
    db   $EC, $F0, $A2, $21, $10, $C3, $09, $77
    db   $3E, $6C, $E0, $9D, $3E, $02, $E0, $A1
    db   $CD, $3B, $09, $21, $B0, $C2, $09, $7E
    db   $E0, $F1, $11, $E9, $46, $CD, $D0, $3C
    db   $CD, $BA, $3D, $C9, $6A, $20, $68, $20
    db   $6E, $20, $6C, $20, $68, $00, $6A, $00
    db   $6C, $00, $6E, $00, $64, $00, $66, $00
    db   $66, $20, $64, $20, $60, $00, $62, $00
    db   $62, $20, $60, $20, $00, $F4, $0C, $00
    db   $0C, $F4, $F0, $F7, $FE, $1F, $CA, $E9
    db   $45, $11, $51, $47, $CD, $3B, $3C, $CD
    db   $9B, $78, $CD, $BD, $78, $21, $30, $C4
    db   $09, $36, $48, $CD, $89, $79, $21, $80
    db   $C3, $09, $7E, $EE, $01, $BB, $20, $06
    db   $21, $30, $C4, $09, $36, $08, $CD, $B4
    db   $3B, $FA, $33, $C1, $A7, $20, $49, $F0
    db   $CB, $E6, $0F, $28, $43, $E6, $03, $5F
    db   $50, $21, $71, $47, $19, $7E, $21, $40
    db   $C2, $09, $77, $F0, $CB, $1F, $1F, $E6
    db   $03, $5F, $50, $21, $74, $47, $19, $7E
    db   $21, $50, $C2, $09, $77, $CD, $07, $79
    db   $CD, $9E, $3B, $F0, $9E, $EE, $01, $21
    db   $80, $C3, $09, $77, $17, $E6, $06, $5F
    db   $21, $D0, $C3, $09, $34, $7E, $1F, $1F
    db   $1F, $1F, $E6, $01, $B3, $CD, $87, $3B
    db   $C9, $02, $11, $C0, $30, $14, $02, $11
    db   $C1, $50, $14, $02, $0F, $F5, $94, $52
    db   $CD, $9B, $78, $CD, $91, $08, $28, $1A
    db   $FE, $01, $20, $09, $FA, $1C, $C1, $EA
    db   $63, $D4, $CD, $4B, $48, $3E, $02, $E0
    db   $A1, $EA, $67, $C1, $3E, $04, $EA, $3B
    db   $C1, $C9, $FA, $1C, $C1, $FE, $01, $20
    db   $1C, $F0, $9C, $A7, $28, $17, $CD, $5A
    db   $79, $C6, $0C, $FE, $18, $30, $0E, $CD
    db   $6A, $79, $C6, $0C, $FE, $18, $30, $05
    db   $CD, $91, $08, $36, $10, $C9, $11, $00
    db   $48, $F0, $F6, $FE, $EA, $28, $0C, $11
    db   $F6, $47, $F0, $98, $FE, $30, $38, $03
    db   $11, $FB, $47, $21, $01, $D4, $C5, $0E
    db   $05, $1A, $13, $22, $0D, $20, $FA, $C1
    db   $CD, $B0, $79, $F0, $98, $CB, $37, $E6
    db   $0F, $5F, $F0, $99, $D6, $08, $E6, $F0
    db   $B3, $EA, $16, $D4, $C3, $0F, $09, $58
    db   $00, $5A, $00, $58, $00, $5C, $00, $5A
    db   $20, $58, $20, $5C, $20, $58, $20, $21
    db   $60, $C3, $09, $36, $4C, $21, $80, $C3
    db   $09, $7E, $A7, $20, $06, $F0, $F1, $C6
    db   $02, $E0, $F1, $11, $84, $48, $CD, $3B
    db   $3C, $CD, $9B, $78, $CD, $E2, $08, $CD
    db   $40, $79, $21, $20, $C3, $09, $35, $35
    db   $21, $10, $C3, $09, $7E, $E6, $80, $E0
    db   $E8, $28, $06, $70, $21, $20, $C3, $09
    db   $70, $FA, $C8, $C3, $A7, $28, $2D, $21
    db   $40, $C3, $09, $CB, $F6, $FA, $0F, $C5
    db   $5F, $50, $21, $00, $C2, $19, $F0, $EE
    db   $1E, $00, $BE, $38, $01, $1C, $21, $80
    db   $C3, $09, $73, $F0, $E7, $E6, $3F, $20
    db   $06, $21, $20, $C3, $09, $36, $0C, $CD
    db   $B7, $49, $18, $03, $CD, $EB, $3B, $21
    db   $20, $C4, $09, $7E, $A7, $28, $11, $FE
    db   $08, $20, $0D, $CD, $8D, $3B, $3E, $02
    db   $77, $E0, $F0, $CD, $91, $08, $36, $10
    db   $F0, $F0, $FE, $02, $30, $17, $CD, $4E
    db   $78, $30, $12, $FA, $C8, $C3, $A7, $3E
    db   $20, $28, $07, $3E, $96, $CD, $85, $21
    db   $18, $03, $CD, $97, $21, $FA, $C8, $C3
    db   $A7, $C0, $F0, $F0, $C7

    dw JumpTable_4952_19 ; 00

    db   $95, $49, $C2, $49, $E8, $49, $02, $08
    db   $0C, $08, $FE, $F8, $F4, $F8

JumpTable_4952_19:
    xor  a
    call toc_01_3B87
    call toc_01_0891
    jr   nz, .else_19_4992

    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $494A
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
    ld   hl, $494A
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
.else_19_4992:
    jp   toc_19_49B7

    db   $CD, $07, $79, $CD, $9E, $3B, $F0, $E8
    db   $A7, $28, $17, $CD, $91, $08, $20, $07
    db   $36, $30, $CD, $8D, $3B, $70, $C9, $21
    db   $20, $C3, $09, $36, $08, $21, $10, $C3
    db   $09, $34

toc_19_49B7:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


    db   $CD, $91, $08, $20, $17, $CD, $8D, $3B
    db   $3E, $24, $CD, $25, $3C, $21, $20, $C3
    db   $09, $36, $18, $CD, $5A, $79, $21, $80
    db   $C3, $09, $7B, $77, $F0, $E7, $1F, $1F
    db   $E6, $01, $CD, $87, $3B, $C9, $CD, $07
    db   $79, $CD, $9E, $3B, $21, $40, $C3, $09
    db   $36, $52, $CD, $BF, $3B, $21, $40, $C3
    db   $09, $36, $92, $F0, $E8, $A7, $28, $09
    db   $CD, $8D, $3B, $70, $CD, $91, $08, $36
    db   $20, $C9, $60, $78, $78, $60, $40, $28
    db   $28, $40, $20, $38, $58, $78, $78, $58
    db   $38, $20, $21, $B0, $C2, $09, $7E, $A7
    db   $C2, $22, $4B, $79, $EA, $61, $D4, $F0
    db   $F8, $E6, $10, $C2, $B0, $79, $F0, $F0
    db   $C7

    dw JumpTable_4A3D_19 ; 00

    db   $5F, $4A, $6F, $4A, $93, $4A, $C3, $4A

JumpTable_4A3D_19:
    ld   a, [$DB49]
    and  %00000100
    ret  z

    ld   a, [$DB4A]
    cp   $00
    ret  nz

    ld   a, [$C166]
    cp   $01
    ret  nz

    call toc_01_27D2
    call toc_01_0891
    ld   [hl], $30
    clear [$C5A3]
    call JumpTable_3B8D_00
    ret


    db   $3E, $02, $E0, $A1, $EA, $67, $C1, $CD
    db   $91, $08, $20, $03, $CD, $8D, $3B, $C9
    db   $3E, $02, $E0, $A1, $CD, $91, $08, $C0
    db   $21, $D0, $C3, $09, $7E, $34, $FE, $08
    db   $20, $09, $70, $CD, $91, $08, $36, $40
    db   $C3, $8D, $3B, $CD, $C4, $4A, $CD, $91
    db   $08, $36, $20, $C9, $3E, $02, $E0, $A1
    db   $CD, $91, $08, $20, $26, $1E, $41, $21
    db   $67, $DB, $2A, $E6, $02, $28, $06, $1C
    db   $7B, $FE, $47, $20, $F5, $7B, $EA, $68
    db   $D3, $EA, $65, $D4, $3E, $FF, $EA, $66
    db   $C1, $AF, $EA, $10, $D2, $EA, $11, $D2
    db   $CD, $8D, $3B, $C9, $C9, $E0, $E8, $5F
    db   $50, $21, $65, $DB, $19, $7E, $E6, $02
    db   $28, $30, $3E, $DE, $CD, $01, $3C, $D8
    db   $3E, $2B, $E0, $F4, $C5, $F0, $E8, $4F
    db   $21, $0C, $4A, $09, $7E, $21, $00, $C2
    db   $19, $C6, $08, $77, $21, $14, $4A, $09
    db   $7E, $21, $10, $C2, $19, $77, $79, $21
    db   $B0, $C3, $19, $77, $21, $B0, $C2, $19
    db   $34, $C1, $C9, $50, $00, $52, $00, $54
    db   $00, $56, $00, $58, $00, $5A, $00, $5C
    db   $00, $5E, $00, $60, $00, $62, $00, $64
    db   $00, $66, $00, $68, $00, $6A, $00, $6C
    db   $00, $6E, $00, $FE, $02, $CA, $F8, $4B
    db   $F0, $F0, $A7, $20, $45, $FA, $A3, $C5
    db   $FE, $03, $28, $13, $21, $F1, $FF, $F0
    db   $E7, $1F, $1F, $1F, $AE, $E6, $03, $C8
    db   $11, $02, $4B, $CD, $3B, $3C, $C9, $F0
    db   $F1, $FE, $07, $C2, $B0, $79, $1E, $08
    db   $21, $65, $DB, $2A, $E6, $02, $28, $13
    db   $1D, $20, $F8, $F0, $F8, $E6, $10, $C2
    db   $B0, $79, $CD, $91, $08, $36, $A0, $CD
    db   $8D, $3B, $C9, $AF, $EA, $A3, $C5, $C3
    db   $B0, $79, $3E, $02, $E0, $A1, $EA, $67
    db   $C1, $CD, $91, $08, $20, $66, $EA, $55
    db   $C1, $EA, $A3, $C5, $3E, $C1, $EA, $36
    db   $D7, $3E, $CB, $EA, $46, $D7, $3E, $50
    db   $E0, $CE, $3E, $20, $E0, $CD, $CD, $39
    db   $28, $21, $01, $D6, $FA, $00, $D6, $5F
    db   $C6, $07, $EA, $00, $D6, $16, $00, $19
    db   $F0, $CF, $22, $F0, $D0, $22, $3E, $83
    db   $22, $3E, $7F, $22, $3E, $0F, $22, $3E
    db   $7E, $22, $3E, $1F, $22, $F0, $CF, $22
    db   $F0, $D0, $3C, $22, $3E, $83, $22, $3E
    db   $7F, $22, $3E, $0F, $22, $3E, $7E, $22
    db   $3E, $1F, $22, $70, $CD, $D2, $27, $3E
    db   $23, $E0, $F2, $CD, $3E, $4C, $CD, $D7
    db   $08, $C3, $B0, $79, $1E, $01, $E6, $04
    db   $28, $02, $1E, $FF, $7B, $EA, $55, $C1
    db   $C9, $16, $00, $16, $20, $16, $60, $16
    db   $40, $11, $F0, $4B, $CD, $D0, $3C, $CD
    db   $07, $79, $21, $50, $C2, $09, $34, $CD
    db   $91, $08, $EA, $67, $C1, $28, $05, $3E
    db   $02, $E0, $A1, $C9, $21, $06, $D8, $CB
    db   $E6, $7E, $E0, $F8, $C3, $B0, $79, $00
    db   $04, $08, $00, $08, $00, $04, $08, $00
    db   $00, $00, $04, $04, $08, $08, $08, $F0
    db   $FC, $10, $F0, $10, $F0, $04, $10, $F0
    db   $E8, $F0, $F8, $F8, $08, $0C, $08, $AF
    db   $E0, $E8, $3E, $DE, $CD, $01, $3C, $D8
    db   $21, $B0, $C2, $19, $36, $02, $CD, $ED
    db   $27, $E6, $1F, $C6, $30, $21, $E0, $C2
    db   $19, $77, $C5, $F0, $E8, $4F, $21, $1E
    db   $4C, $09, $7E, $21, $00, $C2, $19, $C6
    db   $54, $77, $21, $26, $4C, $09, $7E, $21
    db   $10, $C2, $19, $C6, $3C, $77, $21, $2E
    db   $4C, $09, $7E, $21, $40, $C2, $19, $77
    db   $21, $36, $4C, $09, $7E, $21, $50, $C2
    db   $19, $D6, $08, $77, $C1, $F0, $E8, $3C
    db   $FE, $08, $20, $AC, $C9, $58, $00, $5A
    db   $00, $5A, $20, $F0, $F1, $A7, $28, $08
    db   $11, $92, $4C, $CD, $3B, $3C, $18, $06
    db   $11, $94, $4C, $CD, $D0, $3C, $CD, $9B
    db   $78, $F0, $F0, $C7

    dw JumpTable_4CBF_19 ; 00

    db   $01, $4D, $02, $04, $06, $00, $0A, $08
    db   $0C, $0D

JumpTable_4CBF_19:
    ifNe [wGameMode], GAMEMODE_WORLD_MAP, .else_19_4CCA

    clear [$C5A2]
.else_19_4CCA:
    xor  a
    call toc_01_3B87
    call toc_19_784E
    ret  nc

    ld   e, $00
    ifLt [$FFEE], $20, .else_19_4CE5

    inc  e
    cp   $40
    jr   c, .else_19_4CE5

    inc  e
    cp   $70
    jr   c, .else_19_4CE5

    inc  e
.else_19_4CE5:
    ifLt [$FFEF], $40, .else_19_4CEF

    ld   a, e
    add  a, $04
    ld   e, a
.else_19_4CEF:
    ld   d, b
    ld   hl, $4CB7
    add  hl, de
    ld   a, [hl]
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    call toc_01_218E
    call JumpTable_3B8D_00
    ret


    db   $3E, $01, $CD, $87, $3B, $FA, $9F, $C1
    db   $A7, $C0, $CD, $8D, $3B, $70, $FA, $77
    db   $C1, $A7, $20, $4F, $21, $B0, $C2, $09
    db   $7E, $3C, $5F, $FE, $0E, $20, $26, $FA
    db   $0E, $DB, $FE, $0E, $20, $1F, $F0, $F8
    db   $E6, $20, $20, $0E, $CD, $62, $7A, $CD
    db   $ED, $27, $17, $17, $17, $E6, $18, $EA
    db   $7C, $DB, $FA, $7C, $DB, $1F, $1F, $1F
    db   $E6, $03, $C6, $17, $5F, $7B, $FE, $0D
    db   $20, $15, $AF, $EA, $6B, $C1, $EA, $6C
    db   $C1, $EA, $96, $DB, $3E, $07, $EA, $95
    db   $DB, $3E, $01, $EA, $A2, $C5, $C9, $CD
    db   $8E, $21, $C9, $AF, $C3, $87, $3B, $F0
    db   $F8, $E6, $20, $C2, $B0, $79, $21, $B0
    db   $C2, $09, $7E, $A7, $C2, $00, $4F, $F0
    db   $F0, $C7

    dw JumpTable_4D89_19 ; 00

    db   $CD, $4D, $D7, $4D, $11, $4E, $42, $4E
    db   $60, $00, $62, $00

JumpTable_4D89_19:
    ld   a, c
    ld   [$D201], a
    ld   hl, $C200
    add  hl, bc
    ld   [hl], $50
    call toc_19_4DCD
    ld   a, [$DB49]
    and  %00000001
    ret  z

    ld   a, [$C166]
    cp   $01
    ret  nz

    ld   a, [$DB4A]
    cp   $02
    ret  nz

    ld   a, $DC
    call toc_01_3C01
    ld   hl, $C200
    add  hl, de
    ld   [hl], $94
    ld   hl, $C210
    add  hl, de
    ld   [hl], $D8
    ld   hl, $C2B0
    add  hl, de
    inc  [hl]
    ld   hl, $C340
    add  hl, de
    ld   [hl], $C1
    assign [$D368], $55
    jp   JumpTable_3B8D_00

    db   $C9

toc_19_4DCD:
    ld   de, $4D85
    call toc_01_3C3B
    call toc_19_7800
    ret


    db   $3E, $02, $E0, $A1, $EA, $67, $C1, $CD
    db   $CD, $4D, $CD, $91, $08, $20, $1E, $36
    db   $A0, $CD, $8D, $3B, $3E, $02, $CD, $01
    db   $3C, $21, $00, $C2, $19, $F0, $D7, $77
    db   $21, $10, $C2, $19, $F0, $D8, $77, $21
    db   $E0, $C2, $19, $36, $20, $C9, $F0, $00
    db   $64, $00, $00, $00, $66, $00, $00, $08
    db   $68, $00, $3E, $02, $E0, $A1, $EA, $67
    db   $C1, $21, $05, $4E, $0E, $03, $CD, $26
    db   $3D, $CD, $91, $08, $CA, $30, $4E, $FE
    db   $70, $20, $05, $3E, $10, $EA, $68, $D3
    db   $C9, $F0, $99, $F5, $3E, $10, $E0, $99
    db   $3E, $6D, $CD, $85, $21, $F1, $E0, $99
    db   $C3, $8D, $3B, $3E, $02, $E0, $A1, $EA
    db   $67, $C1, $21, $05, $4E, $0E, $03, $CD
    db   $26, $3D, $FA, $9F, $C1, $A7, $20, $22
    db   $3E, $D5, $CD, $01, $3C, $F0, $D7, $21
    db   $00, $C2, $19, $77, $F0, $D8, $21, $10
    db   $C2, $19, $77, $3E, $01, $EA, $7B, $DB
    db   $AF, $EA, $67, $C1, $CD, $62, $7A, $C3
    db   $B0, $79, $C9, $6A, $00, $6C, $00, $6E
    db   $00, $02, $02, $01, $01, $04, $04, $04
    db   $04, $04, $04, $04, $04, $05, $06, $07
    db   $08, $07, $06, $05, $04, $04, $04, $03
    db   $02, $01, $00, $01, $02, $03, $04, $05
    db   $06, $07, $08, $08, $08, $09, $0A, $0B
    db   $0C, $0C, $0C, $0B, $0A, $09, $08, $07
    db   $06, $05, $04, $05, $06, $07, $08, $09
    db   $0A, $0B, $0B, $0A, $09, $08, $07, $06
    db   $05, $04, $03, $02, $01, $00, $01, $02
    db   $03, $04, $04, $04, $04, $04, $04, $04
    db   $04, $04, $04, $04, $04, $04, $04, $04
    db   $04, $04, $04, $04, $04, $04, $04, $04
    db   $04, $04, $04, $04, $04, $04, $04, $04
    db   $04, $04, $04, $04, $04, $00, $03, $06
    db   $07, $08, $07, $06, $03, $00, $FD, $FA
    db   $F9, $F8, $F9, $FA, $FD, $00, $03, $06
    db   $07, $F0, $E7, $17, $17, $E6, $10, $E0
    db   $ED, $11, $7A, $4E, $CD, $D0, $3C, $CD
    db   $9B, $78, $CD, $91, $08, $28, $14, $FE
    db   $01, $CA, $B0, $79, $1F, $1F, $1F, $E6
    db   $03, $5F, $50, $21, $80, $4E, $19, $7E
    db   $C3, $87, $3B, $3E, $02, $E0, $A1, $EA
    db   $67, $C1, $21, $D0, $C3, $09, $7E, $3C
    db   $77, $E6, $07, $20, $23, $21, $C0, $C2
    db   $09, $34, $7E, $FE, $49, $20, $19, $FA
    db   $01, $D2, $5F, $50, $21, $90, $C2, $19
    db   $34, $21, $20, $C4, $19, $36, $40, $21
    db   $E0, $C2, $19, $36, $80, $C3, $B0, $79
    db   $21, $C0, $C2, $09, $5E, $50, $21, $84
    db   $4E, $19, $5E, $21, $F0, $4E, $19, $7E
    db   $21, $40, $C2, $09, $77, $21, $EC, $4E
    db   $19, $7E, $21, $50, $C2, $09, $77, $CD
    db   $07, $79, $21, $D0, $C3, $09, $7E, $E6
    db   $07, $20, $20, $3E, $DC, $CD, $01, $3C
    db   $D8, $F0, $D7, $21, $00, $C2, $19, $77
    db   $F0, $D8, $21, $10, $C2, $19, $77, $21
    db   $B0, $C2, $19, $36, $01, $21, $E0, $C2
    db   $19, $36, $1F, $C9, $60, $00, $62, $00
    db   $64, $00, $66, $00, $62, $20, $60, $20
    db   $66, $20, $64, $20, $68, $00, $6A, $00
    db   $6C, $00, $6E, $00, $6A, $20, $68, $20
    db   $6E, $20, $6C, $20, $70, $00, $72, $00
    db   $74, $00, $76, $00, $72, $20, $70, $20
    db   $76, $20, $74, $20, $F2, $0E, $21, $40
    db   $C3, $09, $36, $D2, $11, $AB, $4F, $CD
    db   $3B, $3C, $21, $D0, $C2, $09, $7E, $A7
    db   $20, $06, $34, $3E, $57, $EA, $68, $D3
    db   $FA, $6B, $DB, $A7, $C2, $90, $50, $CD
    db   $9B, $78, $CD, $00, $78, $F0, $E7, $E6
    db   $7F, $20, $0A, $CD, $ED, $27, $E6, $02
    db   $21, $80, $C3, $09, $77, $F0, $E7, $1E
    db   $00, $E6, $30, $28, $01, $1C, $21, $80
    db   $C3, $09, $7B, $86, $CD, $87, $3B, $F0
    db   $E7, $E6, $3F, $FE, $0F, $20, $2F, $3E
    db   $08, $CD, $01, $3C, $38, $27, $C5, $21
    db   $80, $C3, $09, $4E, $CB, $39, $21, $DB
    db   $4F, $09, $F0, $D7, $86, $21, $00, $C2
    db   $19, $77, $F0, $D8, $21, $10, $C2, $19
    db   $77, $21, $E0, $C2, $19, $36, $17, $21
    db   $40, $C4, $19, $34, $C1, $C9, $CD, $4E
    db   $78, $30, $0D, $FA, $7B, $DB, $A7, $3E
    db   $8B, $28, $02, $3E, $8C, $CD, $85, $21
    db   $C9, $10, $11, $12, $13, $13, $12, $11
    db   $10, $00, $09, $02, $09, $00, $F7, $FE
    db   $F7, $0C, $09, $0A, $F7, $F4, $F7, $F6
    db   $09, $03, $01, $00, $00, $00, $00, $01
    db   $03, $F0, $F0, $A7, $20, $09, $21, $10
    db   $C2, $09, $36, $50, $CD, $8D, $3B, $1E
    db   $00, $21, $40, $C2, $09, $7E, $E6, $80
    db   $20, $02, $1E, $02, $21, $80, $C3, $09
    db   $73, $F0, $E7, $1F, $1F, $1F, $E6, $07
    db   $5F, $50, $21, $70, $50, $19, $7E, $D6
    db   $03, $21, $10, $C3, $09, $77, $21, $80
    db   $C3, $09, $F0, $E7, $E6, $20, $3E, $04
    db   $20, $02, $3E, $05, $86, $CD, $87, $3B
    db   $F0, $EC, $D6, $10, $E0, $EC, $21, $80
    db   $C3, $09, $F0, $E7, $1F, $1F, $E6, $01
    db   $86, $E0, $F1, $21, $40, $C3, $09, $CB
    db   $A6, $11, $CB, $4F, $CD, $3B, $3C, $CD
    db   $BA, $3D, $CD, $9B, $78, $F0, $E7, $E6
    db   $3F, $20, $22, $CD, $ED, $27, $E6, $01
    db   $20, $1B, $CD, $ED, $27, $E6, $07, $5F
    db   $50, $21, $80, $50, $19, $7E, $21, $40
    db   $C2, $09, $77, $21, $78, $50, $19, $7E
    db   $21, $50, $C2, $09, $77, $F0, $E7, $1F
    db   $1F, $1F, $00, $00, $E6, $07, $5F, $50
    db   $21, $88, $50, $19, $F0, $E7, $A6, $CC
    db   $07, $79, $CD, $9E, $3B, $21, $A0, $C2
    db   $09, $7E, $E6, $03, $28, $08, $21, $40
    db   $C2, $09, $7E, $2F, $3C, $77, $21, $A0
    db   $C2, $09, $7E, $E6, $0C, $28, $08, $21
    db   $50, $C2, $09, $7E, $2F, $3C, $77, $CD
    db   $5A, $79, $C6, $12, $FE, $24, $D0, $CD
    db   $6A, $79, $C6, $10, $FE, $20, $D0, $CD
    db   $91, $08, $C0, $36, $80, $3E, $8D, $CD
    db   $85, $21, $C9, $F0, $00, $78, $00, $F0
    db   $08, $7A, $00, $00, $00, $7C, $00, $00
    db   $08, $7E, $00, $FA, $A5, $DB, $A7, $28
    db   $0F, $F0, $F6, $FE, $E4, $CA, $68, $4D
    db   $FE, $F4, $CA, $68, $4D, $C3, $DD, $4F
    db   $F0, $F8, $E6, $20, $C2, $B0, $79, $F0
    db   $F0, $C7

    dw JumpTable_51AD_19 ; 00

    db   $42, $52

JumpTable_51AD_19:
    call toc_19_789B
    returnIfLt [$DB43], $02

    call toc_19_795A
    add  a, $08
    cp   $10
    jr   nc, .else_19_523C

    call toc_19_796A
    add  a, $10
    cp   $20
    jr   nc, .else_19_523C

    ifNotZero [$C133], .else_19_523C

    ifEq [hLinkDirection], DIRECTION_UP, .else_19_523C

    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    inc  a
    ld   [hl], a
    cp   $18
    ret  nz

    call toc_01_0891
    ld   [hl], $40
    ld   hl, $D746
    ld   [hl], $0C
    ld   hl, $D756
    ld   [hl], $C6
    assign [hSwordIntersectedAreaX], $50
    assign [hSwordIntersectedAreaY], $30
    call toc_01_2839
    ld   hl, $D601
    ld   a, [$D600]
    ld   e, a
    add  a, $0E
    ld   [$D600], a
    ld   d, $00
    add  hl, de
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    ldi  [hl], a
    ld   a, $83
    ldi  [hl], a
    ld   a, $0F
    ldi  [hl], a
    ld   a, $0F
    ldi  [hl], a
    ld   a, $68
    ldi  [hl], a
    ld   a, $77
    ldi  [hl], a
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    inc  a
    ldi  [hl], a
    ld   a, $83
    ldi  [hl], a
    ld   a, $0F
    ldi  [hl], a
    ld   a, $0F
    ldi  [hl], a
    ld   a, $69
    ldi  [hl], a
    ld   a, $4B
    ldi  [hl], a
    ld   [hl], b
    assign [$FFF4], $11
    call JumpTable_3B8D_00
    jr   .toc_19_5242

.else_19_523C:
    ld   hl, $C3D0
    add  hl, bc
    ld   [hl], b
    ret


.toc_19_5242:
    call toc_19_789B
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    ld   [$C167], a
    ld   hl, $517A
    ld   c, $04
    call toc_01_3D26
    call toc_01_0891
    jr   nz, .else_19_52B6

    ld   [$C167], a
    ld   hl, $D736
    ld   [hl], $91
    ld   hl, $D746
    ld   [hl], $5E
    assign [hSwordIntersectedAreaX], $50
    assign [hSwordIntersectedAreaY], $20
    call toc_01_2839
    ld   hl, $D601
    ld   a, [$D600]
    ld   e, a
    add  a, $0E
    ld   [$D600], a
    ld   d, $00
    add  hl, de
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    ldi  [hl], a
    ld   a, $83
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    ld   a, $10
    ldi  [hl], a
    ld   a, $02
    ldi  [hl], a
    ld   a, $12
    ldi  [hl], a
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    inc  a
    ldi  [hl], a
    ld   a, $83
    ldi  [hl], a
    ld   a, $6C
    ldi  [hl], a
    ld   a, $6D
    ldi  [hl], a
    ld   a, $03
    ldi  [hl], a
    ld   a, $13
    ldi  [hl], a
    ld   [hl], b
    assign [$FFF2], $23
    call toc_19_7A62
    jp   toc_19_79B0

.else_19_52B6:
    ld   hl, $C250
    add  hl, bc
    ld   [hl], $FC
    call toc_19_790A
    ret


    db   $F8, $F8, $60, $00, $F8, $00, $62, $00
    db   $F8, $08, $62, $20, $F8, $10, $60, $20
    db   $08, $F8, $60, $40, $08, $00, $62, $40
    db   $08, $08, $62, $60, $08, $10, $60, $60
    db   $00, $04, $08, $04, $F0, $E7, $17, $17
    db   $E6, $10, $E0, $ED, $F0, $E7, $1F, $1F
    db   $1F, $1F, $E6, $03, $5F, $50, $21, $E0
    db   $52, $19, $7E, $E0, $F5, $21, $C0, $52
    db   $0E, $08, $CD, $26, $3D, $CD, $9B, $78
    db   $CD, $BF, $3B, $CD, $07, $79, $CD, $9E
    db   $3B, $21, $A0, $C2, $09, $7E, $E6, $03
    db   $28, $08, $21, $40, $C2, $09, $7E, $2F
    db   $3C, $77, $21, $A0, $C2, $09, $7E, $E6
    db   $0C, $28, $08, $21, $50, $C2, $09, $7E
    db   $2F, $3C, $77, $C9, $7A, $40, $7A, $60
    db   $7A, $50, $7A, $70, $7A, $00, $7A, $20
    db   $7A, $10, $7A, $30, $21, $B0, $C2, $09
    db   $7E, $A7, $C2, $51, $54, $F0, $F0, $C7

    dw JumpTable_5356_19 ; 00

    db   $6A, $53, $C3, $53

JumpTable_5356_19:
    call toc_01_0891
    call toc_01_27ED
    and  %00111111
    add  a, $30
    ld   [hl], a
    jp   JumpTable_3B8D_00

    db   $FF, $01, $FD, $03, $F4, $F4, $CD, $91
    db   $08, $20, $53, $FA, $A1, $C5, $FE, $02
    db   $D0, $21, $50, $C2, $09, $36, $D0, $CD
    db   $8D, $3B, $3E, $01, $E0, $E9, $3E, $DA
    db   $CD, $01, $3C, $D8, $F0, $D8, $21, $10
    db   $C2, $19, $77, $21, $B0, $C2, $19, $36
    db   $02, $C5, $F0, $E9, $4F, $21, $64, $53
    db   $09, $F0, $D7, $86, $21, $00, $C2, $19
    db   $77, $21, $66, $53, $09, $7E, $21, $40
    db   $C2, $19, $77, $21, $68, $53, $09, $7E
    db   $21, $50, $C2, $19, $77, $C1, $F0, $E9
    db   $3D, $FE, $FF, $20, $BF, $C9, $C9, $21
    db   $A0, $C5, $34, $11, $34, $53, $CD, $3B
    db   $3C, $CD, $9B, $78, $CD, $BF, $3B, $CD
    db   $0A, $79, $21, $50, $C2, $09, $34, $1E
    db   $00, $7E, $E6, $80, $20, $02, $1E, $02
    db   $F0, $E7, $1F, $1F, $E6, $01, $83, $CD
    db   $87, $3B, $21, $10, $C2, $09, $7E, $FE
    db   $70, $38, $09, $36, $70, $CD, $8D, $3B
    db   $70, $CD, $7E, $53, $F0, $E7, $A9, $E6
    db   $0F, $C0, $3E, $DA, $CD, $01, $3C, $D8
    db   $F0, $D7, $21, $00, $C2, $19, $77, $F0
    db   $D8, $21, $10, $C2, $19, $77, $21, $E0
    db   $C2, $19, $36, $18, $21, $B0, $C2, $19
    db   $36, $01, $F0, $F1, $17, $E6, $04, $21
    db   $B0, $C3, $19, $77, $C9, $7C, $40, $7C
    db   $60, $7C, $50, $7C, $70, $7E, $40, $7E
    db   $60, $7E, $50, $7E, $70, $7C, $00, $7C
    db   $20, $7C, $10, $7C, $30, $7E, $00, $7E
    db   $20, $7E, $10, $7E, $30, $FE, $02, $28
    db   $2C, $F0, $E7, $A9, $1F, $38, $12, $F0
    db   $E7, $1F, $1F, $E6, $01, $5F, $F0, $F1
    db   $83, $E0, $F1, $11, $31, $54, $CD, $3B
    db   $3C, $CD, $9B, $78, $CD, $91, $08, $CA
    db   $B0, $79, $FE, $08, $20, $06, $21, $B0
    db   $C3, $09, $34, $34, $C9, $11, $49, $54
    db   $CD, $3B, $3C, $F0, $E7, $1F, $1F, $E6
    db   $01, $CD, $87, $3B, $CD, $07, $79, $21
    db   $50, $C2, $09, $34, $7E, $FE, $10, $20
    db   $03, $CD, $B0, $79, $C9, $00, $00, $50
    db   $00, $00, $08, $52, $00, $00, $10, $52
    db   $20, $00, $18, $50, $20, $10, $00, $54
    db   $00, $10, $08, $56, $00, $10, $10, $56
    db   $20, $10, $18, $54, $20, $F0, $F1, $A7
    db   $3E, $00, $28, $02, $3E, $08, $E0, $F5
    db   $21, $A1, $54, $0E, $08, $CD, $26, $3D
    db   $CD, $9B, $78, $CD, $E2, $08, $F0, $F0
    db   $C7

    dw JumpTable_54E3_19 ; 00

    db   $0B, $55, $65, $55

JumpTable_54E3_19:
    call toc_19_7800
    ret  nc

    and  a
    ret  z

    call toc_01_093B
    ld   a, [hLinkPositionXIncrement]
    cpl
    inc  a
    sra  a
    sra  a
    ld   [hLinkPositionXIncrement], a
    assign [hLinkPositionYIncrement], 232
    call toc_01_0891
    ld   [hl], $20
    ld   a, $01
    call toc_01_3B87
    assign [$FFF2], $0B
    jp   JumpTable_3B8D_00

    db   $CD, $91, $08, $FE, $01, $20, $05, $21
    db   $F2, $FF, $36, $08, $A7, $C0, $CD, $0A
    db   $79, $21, $50, $C2, $09, $7E, $FE, $70
    db   $30, $03, $C6, $03, $77, $21, $10, $C2
    db   $09, $7E, $C6, $10, $77, $F0, $EF, $C6
    db   $10, $E0, $EF, $CD, $9E, $3B, $21, $10
    db   $C2, $09, $7E, $D6, $10, $77, $F0, $EF
    db   $D6, $10, $E0, $EF, $21, $A0, $C2, $09
    db   $7E, $A7, $28, $15, $CD, $D7, $08, $CD
    db   $91, $08, $36, $30, $3E, $30, $EA, $57
    db   $C1, $3E, $04, $EA, $58, $C1, $CD, $8D
    db   $3B, $C9, $CD, $DC, $57, $C9, $00, $00
    db   $01, $01, $01, $02, $02, $02, $00, $00
    db   $0F, $0F, $0F, $0E, $0E, $0E, $08, $08
    db   $07, $07, $07, $06, $06, $06, $08, $08
    db   $09, $09, $09, $0A, $0A, $0A, $04, $04
    db   $03, $03, $03, $02, $02, $02, $0C, $0C
    db   $0D, $0D, $0D, $0E, $0E, $0E, $04, $04
    db   $05, $05, $05, $06, $06, $06, $0C, $0C
    db   $0B, $0B, $0B, $0A, $0A, $0A

toc_19_55A9:
    ld   a, [$FFD7]
    rlca
    and  %00000001
    ld   e, a
    ld   a, [$FFD8]
    rlca
    rla
    and  %00000010
    or   e
    rla
    rla
    rla
    and  %00011000
    ld   h, a
    ld   a, [$FFD8]
    bit  7, a
    jr   z, .else_19_55C4

    cpl
    inc  a
.else_19_55C4:
    ld   d, a
    ld   a, [$FFD7]
    bit  7, a
    jr   z, .else_19_55CD

    cpl
    inc  a
.else_19_55CD:
    cp   d
    jr   nc, .else_19_55DD

    sra  a
    sra  a
    add  a, h
    ld   e, a
    ld   d, b
    ld   hl, $5569
    add  hl, de
    ld   a, [hl]
    ret


.else_19_55DD:
    ld   a, d
    sra  a
    sra  a
    add  a, h
    ld   e, a
    ld   d, b
    ld   hl, $5589
    add  hl, de
    ld   a, [hl]
    ret


    db   $5A, $00, $5A, $20, $58, $00, $58, $20
    db   $11, $EB, $55, $CD, $3B, $3C, $CD, $9B
    db   $78, $CD, $E2, $08, $CD, $B4, $3B, $AF
    db   $CD, $87, $3B, $F0, $F0, $C7

    dw JumpTable_5611_19 ; 00

    db   $1B, $56, $41, $56, $7B, $56

JumpTable_5611_19:
    ld   a, [$FFEC]
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    call JumpTable_3B8D_00
    call toc_01_0891
    ret  nz

    call toc_19_795A
    ld   e, a
    add  a, $28
    cp   $50
    jr   nc, .return_19_5640

    ld   a, $01
    call toc_01_3B87
    ld   a, e
    add  a, $18
    cp   $30
    jr   nc, .return_19_5640

    call toc_01_3DAF
    call toc_01_0891
    ld   [hl], $08
    call JumpTable_3B8D_00
.return_19_5640:
    ret


    db   $3E, $01, $CD, $87, $3B, $CD, $91, $08
    db   $FE, $01, $20, $05, $21, $F2, $FF, $36
    db   $08, $A7, $C0, $CD, $0A, $79, $21, $50
    db   $C2, $09, $7E, $FE, $70, $30, $03, $C6
    db   $03, $77, $CD, $9E, $3B, $21, $A0, $C2
    db   $09, $7E, $A7, $28, $0C, $3E, $09, $E0
    db   $F2, $CD, $91, $08, $36, $30, $CD, $8D
    db   $3B, $C9, $CD, $91, $08, $C0, $21, $B0
    db   $C2, $09, $F0, $EC, $BE, $20, $0A, $CD
    db   $8D, $3B, $70, $CD, $91, $08, $36, $20
    db   $C9, $21, $50, $C2, $09, $36, $F8, $CD
    db   $0A, $79, $C9, $00, $00, $70, $00, $00
    db   $08, $72, $00, $00, $10, $72, $20, $00
    db   $18, $70, $20, $10, $00, $74, $00, $10
    db   $08, $76, $00, $10, $10, $76, $20, $10
    db   $18, $74, $20, $FF, $00, $FF, $00, $6E
    db   $00, $7E, $00, $7A, $00, $7A, $20, $7E
    db   $20, $6E, $20, $7E, $20, $7C, $20, $7E
    db   $20, $6C, $20, $78, $00, $78, $20, $6C
    db   $00, $7E, $00, $7C, $00, $7E, $00, $04
    db   $05, $06, $07, $08, $01, $02, $03, $F0
    db   $EC, $C6, $08, $E0, $EC, $F0, $EE, $C6
    db   $08, $E0, $EE, $11, $BC, $56, $CD, $3B
    db   $3C, $CD, $BA, $3D, $21, $9C, $56, $0E
    db   $08, $CD, $26, $3D, $3E, $06, $CD, $D0
    db   $3D, $CD, $9B, $78, $CD, $E2, $08, $CD
    db   $EB, $3B, $CD, $DC, $57, $F0, $F0, $C7

    dw JumpTable_5721_19 ; 00

    db   $2B, $57, $6E, $57, $BA, $57

JumpTable_5721_19:
    ld   a, [$FFEC]
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    call JumpTable_3B8D_00
    call toc_01_0891
    ret  nz

    call toc_19_795A
    add  a, $F8
    ld   e, a
    add  a, $28
    cp   $50
    jr   nc, .else_19_5752

    ld   a, e
    add  a, $18
    cp   $30
    jr   nc, .else_19_5752

    call toc_01_3DAF
    assign [$FFF2], $08
    ld   a, $00
    call toc_01_3B87
    call JumpTable_3B8D_00
    ret


.else_19_5752:
    ld   a, [hFrameCounter]
    and  %00000111
    jr   nz, .return_19_576D

    ld   a, $1F
    call toc_01_3C30
    call toc_19_55A9
    rra
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $56E0
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
.return_19_576D:
    ret


    db   $CD, $0A, $79, $21, $50, $C2, $09, $7E
    db   $FE, $70, $30, $03, $C6, $03, $77, $21
    db   $10, $C2, $09, $7E, $C6, $10, $77, $F0
    db   $EF, $C6, $10, $E0, $EF, $CD, $9E, $3B
    db   $21, $10, $C2, $09, $7E, $D6, $10, $77
    db   $F0, $EF, $D6, $10, $E0, $EF, $21, $A0
    db   $C2, $09, $7E, $A7, $28, $15, $CD, $D7
    db   $08, $CD, $91, $08, $36, $30, $3E, $30
    db   $EA, $57, $C1, $3E, $04, $EA, $58, $C1
    db   $CD, $8D, $3B, $C9, $CD, $91, $08, $C0
    db   $21, $B0, $C2, $09, $F0, $EC, $BE, $20
    db   $0B, $CD, $8D, $3B, $36, $01, $CD, $91
    db   $08, $36, $20, $C9, $21, $50, $C2, $09
    db   $36, $F8, $CD, $0A, $79, $C9, $CD, $D5
    db   $3B, $D0, $CD, $6A, $79, $C6, $08, $CB
    db   $7F, $20, $11, $CD, $93, $3B, $3E, $10
    db   $CD, $30, $3C, $F0, $D7, $E0, $9B, $F0
    db   $D8, $E0, $9A, $C9, $F0, $9B, $E6, $80
    db   $20, $12, $21, $10, $C2, $09, $7E, $D6
    db   $10, $E0, $99, $3E, $02, $E0, $9B, $3E
    db   $01, $EA, $47, $C1, $C9, $5E, $00, $5E
    db   $20, $11, $13, $58, $CD, $3B, $3C, $CD
    db   $9B, $78, $F0, $F0, $C7

    dw JumpTable_5829_19 ; 00

    db   $B3, $58, $B3, $58

JumpTable_5829_19:
    call toc_01_3BD5
    jr   nc, .else_19_585C

    call toc_19_796A
    ld   e, a
    add  a, $03
    cp   $06
    jr   nc, .else_19_583B

    call toc_19_58D7
.else_19_583B:
    ld   a, [hLinkPositionYIncrement]
    and  %10000000
    jr   nz, .else_19_585C

    call toc_19_796A
    add  a, 8
    bit  7, a
    jr   z, .else_19_585C

    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    sub  a, 16
    ld   [hLinkPositionY], a
    assign [hLinkPositionYIncrement], 2
    assign [$C147], $01
.else_19_585C:
    call toc_19_795A
    add  a, $12
    cp   $24
    ret  nc

    call toc_19_796A
    add  a, $12
    cp   $24
    ret  nc

    ld   a, [$C19B]
    and  a
    ret  nz

    ifEq [$DB00], $03, .else_19_587F

    ld   a, [$FFCC]
    and  %00100000
    jr   nz, .else_19_588A

    ret


.else_19_587F:
    ld   a, [$DB01]
    cp   $03
    ret  nz

    ld   a, [$FFCC]
    and  %00010000
    ret  z

.else_19_588A:
    ld   a, [$C3CF]
    and  a
    ret  nz

    inc  a
    ld   [$C3CF], a
    ld   hl, $C280
    add  hl, bc
    ld   [hl], $07
    ld   hl, $C490
    add  hl, bc
    ld   [hl], b
    call toc_01_0891
    ld   [hl], $02
    ld   hl, $FFF3
    ld   [hl], $02
    call JumpTable_3B8D_00
    ld   [hl], $02
    copyFromTo [hLinkDirection], [$C15D]
    ret


    db   $CD, $07, $79, $21, $50, $C2, $09, $7E
    db   $CB, $7F, $20, $04, $FE, $40, $30, $02
    db   $34, $34, $CD, $9E, $3B, $21, $A0, $C2
    db   $09, $7E, $A7, $28, $06, $CD, $64, $3E
    db   $CD, $B0, $79, $C9

toc_19_58D7:
    call toc_01_093B.toc_01_0942
    _ifZero [$C146], .else_19_58F3

    assign [$C13E], $02
    call toc_19_795A
    ld   a, e
    and  a
    ld   a, $10
    jr   z, .else_19_58F0

    ld   a, 240
.else_19_58F0:
    ld   [hLinkPositionXIncrement], a
    ret


.else_19_58F3:
    copyFromTo [hLinkFinalPositionX], [hLinkPositionX]
    ret


    db   $42, $20, $40, $20, $46, $20, $44, $20
    db   $40, $00, $42, $00, $44, $00, $46, $00
    db   $4C, $00, $4C, $20, $4E, $00, $4E, $20
    db   $48, $00, $48, $20, $4A, $00, $4A, $20
    db   $FA, $7B, $DB, $A7, $CA, $B0, $79, $F0
    db   $F6, $21, $E0, $C3, $09, $77, $21, $20
    db   $C2, $09, $70, $21, $30, $C2, $09, $70
    db   $11, $F8, $58, $CD, $3B, $3C, $F0, $EA
    db   $FE, $07, $CA, $78, $5A, $FA, $1C, $C1
    db   $FE, $01, $20, $05, $CD, $3C, $5A, $18
    db   $24, $CD, $40, $79, $21, $20, $C3, $09
    db   $35, $21, $10, $C3, $09, $7E, $E6, $80
    db   $28, $17, $70, $21, $20, $C3, $09, $36
    db   $10, $FA, $46, $C1, $5F, $FA, $4A, $C1
    db   $B3, $28, $02, $36, $20, $CD, $8D, $3B
    db   $70, $CD, $9B, $78, $F0, $F0, $A7, $20
    db   $48, $CD, $89, $79, $CB, $23, $F0, $E7
    db   $1F, $1F, $1F, $E6, $01, $83, $CD, $87
    db   $3B, $CD, $5A, $79, $C6, $12, $FE, $24
    db   $30, $09, $CD, $6A, $79, $C6, $12, $FE
    db   $24, $38, $40, $F0, $E7, $E6, $07, $20
    db   $1A, $FA, $4A, $C1, $A7, $3E, $0C, $28
    db   $02, $3E, $20, $5F, $21, $10, $C3, $09
    db   $7E, $F5, $E5, $70, $7B, $CD, $25, $3C
    db   $E1, $F1, $77, $CD, $07, $79, $C3, $9E
    db   $3B, $21, $40, $C2, $09, $7E, $E6, $80
    db   $28, $02, $34, $34, $35, $21, $50, $C2
    db   $09, $7E, $E6, $80, $28, $02, $34, $34
    db   $35, $18, $E0, $CD, $AF, $3D, $CD, $D5
    db   $3B, $D0, $FA, $9B, $C1, $A7, $C0, $FA
    db   $00, $DB, $FE, $03, $20, $07, $F0, $CC
    db   $E6, $20, $20, $0C, $C9, $FA, $01, $DB
    db   $FE, $03, $C0, $F0, $CC, $E6, $10, $C8
    db   $FA, $1C, $C1, $FE, $02, $D0, $FA, $CF
    db   $C3, $A7, $C0, $EA, $1C, $C1, $3C, $EA
    db   $CF, $C3, $21, $80, $C2, $09, $36, $07
    db   $21, $90, $C4, $09, $70, $CD, $91, $08
    db   $36, $02, $21, $F3, $FF, $36, $02, $CD
    db   $8D, $3B, $36, $01, $3E, $02, $E0, $A2
    db   $EA, $46, $C1, $C9, $06, $07, $08, $09
    db   $09, $08, $07, $06, $21, $20, $C3, $09
    db   $70, $F0, $E7, $1F, $1F, $1F, $E6, $07
    db   $5F, $50, $21, $34, $5A, $19, $5E, $21
    db   $10, $C3, $09, $7E, $93, $C8, $5F, $F0
    db   $E7, $E6, $01, $C0, $7B, $E6, $80, $28
    db   $02, $34, $34, $35, $C9, $0F, $00, $01
    db   $0F, $02, $0F, $0F, $0F, $03, $0F, $0F
    db   $14, $14, $15, $16, $17, $17, $16, $15
    db   $F0, $9E, $17, $E6, $06, $5F, $F0, $E7
    db   $1F, $1F, $E6, $01, $83, $CD, $87, $3B
    db   $3E, $02, $EA, $46, $C1, $AF, $E0, $A3
    db   $F0, $E7, $E6, $03, $20, $1B, $F0, $E7
    db   $1F, $1F, $E6, $07, $5F, $50, $21, $70
    db   $5A, $19, $5E, $21, $A2, $FF, $7E, $93
    db   $28, $07, $E6, $80, $28, $02, $34, $34
    db   $35, $F0, $CB, $E6, $0F, $5F, $50, $21
    db   $65, $5A, $19, $7E, $FE, $0F, $28, $05
    db   $E0, $9E, $EA, $5D, $C1, $FA, $33, $C1
    db   $E6, $03, $28, $03, $AF, $E0, $9B, $FA
    db   $33, $C1, $E6, $0C, $28, $03, $AF, $E0
    db   $9A, $CD, $C5, $29, $C9, $64, $00, $64
    db   $20, $66, $00, $66, $20, $60, $00, $60
    db   $20, $62, $00, $62, $20, $68, $00, $6A
    db   $00, $6C, $00, $6E, $00, $6A, $20, $68
    db   $20, $6E, $20, $6C, $20, $11, $DD, $5A
    db   $CD, $3B, $3C, $CD, $9B, $78, $CD, $07
    db   $79, $CD, $40, $79, $CD, $9E, $3B, $21
    db   $20, $C3, $09, $35, $35, $21, $10, $C3
    db   $09, $7E, $E6, $80, $E0, $E8, $28, $06
    db   $70, $21, $20, $C3, $09, $70, $F0, $F0
    db   $C7

    dw JumpTable_5B45_19 ; 00

    db   $87, $5B, $00, $10, $00, $F0, $0C, $0C
    db   $F4, $F4, $F0, $00, $10, $00, $F4, $0C
    db   $0C, $F4, $00, $06, $02, $04, $00, $06
    db   $02, $04

JumpTable_5B45_19:
    call toc_01_0891
    jr   nz, .else_19_5B7E

    call JumpTable_3B8D_00
    call toc_01_27ED
    and  %00011111
    or   %00010000
    ld   hl, $C320
    add  hl, bc
    ld   [hl], a
    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $5B2D
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $5B35
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ld   hl, $5B3D
    add  hl, de
    ld   a, [hl]
    ld   hl, $C380
    add  hl, bc
    ld   [hl], a
.else_19_5B7E:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    call toc_01_3B87
    ret


    db   $F0, $E8, $A7, $28, $13, $CD, $91, $08
    db   $CD, $ED, $27, $E6, $1F, $C6, $10, $77
    db   $CD, $AF, $3D, $CD, $8D, $3B, $70, $C9
    db   $21, $80, $C3, $09, $7E, $3C, $CD, $87
    db   $3B, $C9, $00, $2C, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $EC, $00
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
    db   $00, $00, $00, $00, $00, $00, $00, $01
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
    db   $00, $00, $00, $00, $00, $00, $95, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00

toc_19_5CA9:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_GRAB_SLASH
    ld   [$C167], a
    call toc_01_1495
    ld   a, [$FF9C]
    jumptable
    dw JumpTable_5CBC_19 ; 00

    db   $CE, $5C, $EC, $5C

JumpTable_5CBC_19:
    _ifZero [$FFB7], .return_19_5CC9

    assign [$FF9C], $01
    assign [$FFF2], $25
.return_19_5CC9:
    ret


    db   $00, $03, $01, $02, $F0, $B7, $A7, $20
    db   $05, $3E, $02, $E0, $9C, $C9, $F0, $E7
    db   $1F, $1F, $E6, $03, $5F, $16, $00, $21
    db   $CA, $5C, $19, $7E, $E0, $9E, $CD, $7C
    db   $08, $C9, $CD, $D8, $5C, $F0, $A2, $C6
    db   $04, $E0, $A2, $FE, $78, $38, $3E, $EA
    db   $C8, $DB, $F0, $F6, $5F, $16, $00, $21
    db   $A9, $5B, $19, $5E, $21, $00, $D8, $19
    db   $7E, $E6, $80, $28, $F2, $7B, $EA, $03
    db   $D4, $AF, $EA, $01, $D4, $EA, $02, $D4
    db   $3E, $70, $EA, $05, $D4, $E0, $99, $3E
    db   $68, $EA, $04, $D4, $E0, $98, $EA, $75
    db   $D4, $3E, $66, $EA, $16, $D4, $CD, $0F
    db   $09, $AF, $EA, $67, $C1, $C9, $42, $20
    db   $40, $20, $46, $20, $44, $20, $40, $00
    db   $42, $00, $44, $00, $46, $00, $48, $00
    db   $4A, $00, $4C, $00, $4E, $00, $10, $11
    db   $12, $13, $13, $12, $11, $10, $FA, $79
    db   $DB, $FE, $01, $C2, $B0, $79, $F0, $F6
    db   $21, $E0, $C3, $09, $77, $21, $20, $C2
    db   $09, $70, $21, $30, $C2, $09, $70, $F0
    db   $E7, $A9, $E6, $01, $20, $06, $11, $38
    db   $5D, $CD, $3B, $3C, $21, $C0, $C2, $09
    db   $7E, $A7, $20, $15, $F0, $E7, $1F, $1F
    db   $1F, $E6, $07, $5F, $50, $21, $50, $5D
    db   $19, $7E, $D6, $04, $21, $10, $C3, $09
    db   $77, $F0, $F0, $A7, $20, $4F, $CD, $89
    db   $79, $7B, $FE, $02, $1E, $04, $28, $05
    db   $CD, $5A, $79, $CB, $23, $F0, $E7, $1F
    db   $1F, $1F, $1F, $E6, $01, $83, $CD, $87
    db   $3B, $CD, $5A, $79, $C6, $18, $FE, $30
    db   $30, $15, $F0, $99, $F5, $C6, $0C, $E0
    db   $99, $CD, $6A, $79, $5F, $F1, $E0, $99
    db   $7B, $C6, $18, $FE, $30, $38, $16, $F0
    db   $E7, $E6, $03, $20, $0D, $FA, $4A, $C1
    db   $A7, $3E, $08, $28, $02, $3E, $18, $CD
    db   $25, $3C, $CD, $07, $79, $FA, $A5, $DB
    db   $A7, $C2, $02, $5F, $FA, $7A, $DB, $A7
    db   $CA, $A1, $5E, $F0, $F6, $FE, $64, $C2
    db   $C7, $5E, $F0, $F0, $C7

    dw JumpTable_5E0D_19 ; 00

    db   $20, $5E, $7D, $5E

JumpTable_5E0D_19:
    call toc_19_789B
    returnIfGte [hLinkPositionX], 60

    returnIfGte [hLinkPositionY], 122

    ld   [$C167], a
    jp   JumpTable_3B8D_00

    db   $3E, $02, $E0, $A1, $F0, $99, $F5, $F0
    db   $98, $F5, $21, $10, $C3, $09, $3E, $60
    db   $96, $E0, $99, $3E, $28, $E0, $98, $3E
    db   $08, $CD, $25, $3C, $CD, $5A, $79, $F5
    db   $7B, $CB, $27, $21, $80, $C3, $09, $77
    db   $F1, $C6, $03, $FE, $06, $30, $21, $CD
    db   $6A, $79, $C6, $0C, $FE, $18, $30, $18
    db   $F1, $E0, $98, $F1, $E0, $99, $3E, $16
    db   $CD, $8E, $21, $3E, $2D, $E0, $F2, $CD
    db   $8D, $3B, $21, $C0, $C2, $09, $34, $C9
    db   $F1, $E0, $98, $F1, $E0, $99, $CD, $07
    db   $79, $CD, $96, $5F, $C9, $3E, $02, $E0
    db   $A1, $CD, $9B, $78, $21, $10, $C3, $09
    db   $35, $20, $12, $AF, $EA, $79, $DB, $EA
    db   $7A, $DB, $EA, $67, $C1, $21, $E3, $D9
    db   $CB, $F6, $C3, $B0, $79, $CD, $96, $5F
    db   $C9, $CD, $9B, $78, $21, $D0, $C2, $09
    db   $7E, $A7, $C0, $F0, $F6, $FE, $F6, $C2
    db   $C7, $5E, $F0, $99, $FE, $40, $D8, $F0
    db   $98, $FE, $78, $D0, $34, $3E, $2D, $E0
    db   $F2, $3E, $13, $CD, $8E, $21, $C9, $CD
    db   $9B, $78, $21, $D0, $C2, $09, $7E, $A7
    db   $C0, $FA, $6B, $C1, $FE, $04, $C0, $F0
    db   $E7, $E6, $01, $C0, $21, $40, $C4, $09
    db   $35, $C0, $CD, $ED, $27, $E6, $03, $21
    db   $C8, $C3, $B6, $C0, $21, $D0, $C2, $09
    db   $34, $3E, $2D, $E0, $F2, $FA, $7A, $DB
    db   $A7, $3E, $11, $28, $02, $3E, $10, $C3
    db   $8E, $21, $CD, $9B, $78, $F0, $F7, $FE
    db   $1E, $C0, $F0, $F6, $FE, $E3, $C0, $F0
    db   $F8, $E6, $20, $C0, $3E, $02, $E0, $A1
    db   $EA, $67, $C1, $F0, $F0, $C7

    dw JumpTable_5F2A_19 ; 00

    db   $42, $5F, $7A, $5F, $A8, $5F, $C4, $5F
    db   $EA, $5F

JumpTable_5F2A_19:
    call toc_01_0891
    ld   [hl], $40
    jp   JumpTable_3B8D_00

    db   $60, $28, $28, $68, $00, $F8, $FC, $08
    db   $F8, $FC, $F8, $02, $04, $02, $04, $00
    db   $CD, $91, $08, $20, $31, $21, $D0, $C3
    db   $09, $5E, $50, $21, $32, $5F, $19, $7E
    db   $21, $E0, $C2, $09, $77, $21, $36, $5F
    db   $19, $7E, $21, $40, $C2, $09, $77, $21
    db   $3A, $5F, $19, $7E, $21, $50, $C2, $09
    db   $77, $21, $3E, $5F, $19, $7E, $21, $80
    db   $C3, $09, $77, $CD, $8D, $3B, $18, $1C
    db   $CD, $91, $08, $20, $14, $36, $50, $CD
    db   $8D, $3B, $21, $D0, $C3, $09, $7E, $3C
    db   $77, $FE, $04, $28, $04, $CD, $8D, $3B
    db   $70, $CD, $07, $79, $21, $80, $C3, $09
    db   $5E, $F0, $E7, $1F, $1F, $1F, $1F, $E6
    db   $01, $83, $CD, $87, $3B, $C9, $CD, $91
    db   $08, $20, $14, $36, $50, $F0, $99, $F5
    db   $3E, $10, $E0, $99, $3E, $14, $CD, $8E
    db   $21, $F1, $E0, $99, $CD, $8D, $3B, $C3
    db   $96, $5F, $CD, $91, $08, $20, $08, $3E
    db   $15, $CD, $8E, $21, $CD, $8D, $3B, $21
    db   $50, $C2, $09, $36, $0A, $21, $40, $C2
    db   $09, $36, $FC, $21, $80, $C3, $09, $36
    db   $02, $CD, $07, $79, $C3, $96, $5F, $C9
    db   $3E, $01, $EA, $7A, $DB, $CD, $62, $7A
    db   $CD, $B0, $79, $C3, $09, $09, $00, $98
    db   $06, $89, $00, $04, $00, $04, $00, $04
    db   $00, $04, $00, $10, $98, $07, $89, $01
    db   $11, $01, $11, $01, $11, $01, $11, $01
    db   $11, $98, $08, $89, $07, $06, $07, $06
    db   $07, $06, $07, $06, $07, $06, $98, $08
    db   $89, $07, $06, $07, $06, $07, $06, $07
    db   $06, $07, $06, $98, $09, $89, $06, $07
    db   $06, $07, $06, $07, $06, $07, $06, $07
    db   $98, $0A, $89, $07, $06, $07, $06, $07
    db   $06, $07, $06, $07, $06, $98, $0B, $89
    db   $06, $07, $06, $07, $06, $07, $06, $07
    db   $06, $07, $98, $0B, $89, $06, $07, $06
    db   $07, $06, $07, $06, $07, $06, $07, $98
    db   $0C, $89, $07, $06, $07, $06, $07, $06
    db   $07, $06, $07, $06, $98, $0D, $89, $06
    db   $07, $06, $07, $06, $07, $06, $07, $06
    db   $07, $98, $0E, $89, $02, $12, $02, $12
    db   $02, $12, $02, $12, $02, $12, $98, $0F
    db   $89, $03, $05, $03, $05, $03, $05, $03
    db   $05, $03, $13, $98, $06, $89, $04, $00
    db   $04, $00, $04, $00, $04, $00, $04, $14
    db   $98, $07, $89, $11, $01, $11, $01, $11
    db   $01, $11, $01, $11, $01, $98, $08, $89
    db   $06, $07, $06, $07, $06, $07, $06, $07
    db   $06, $07, $98, $08, $89, $06, $07, $06
    db   $07, $06, $07, $06, $07, $06, $07, $98
    db   $09, $89, $07, $06, $07, $06, $07, $06
    db   $07, $06, $07, $06, $98, $0A, $89, $06
    db   $07, $06, $07, $06, $07, $06, $07, $06
    db   $07, $98, $0B, $89, $07, $06, $07, $06
    db   $07, $06, $07, $06, $07, $06, $98, $0B
    db   $89, $07, $06, $07, $06, $07, $06, $07
    db   $06, $07, $06, $98, $0C, $89, $06, $07
    db   $06, $07, $06, $07, $06, $07, $06, $07
    db   $98, $0D, $89, $07, $06, $07, $06, $07
    db   $06, $07, $06, $07, $06, $98, $0E, $89
    db   $12, $02, $12, $02, $12, $02, $12, $02
    db   $12, $02, $98, $0F, $89, $05, $03, $05
    db   $03, $05, $03, $05, $03, $05, $15, $95
    db   $60, $F9, $5F, $C9, $60, $2D, $60, $FD
    db   $60, $61, $60, $3E, $02, $E0, $A1, $EA
    db   $67, $C1, $CD, $BE, $63, $F0, $F0, $C7

    dw JumpTable_6158_19 ; 00

    db   $63, $61, $99, $61, $A3, $61, $A8, $61
    db   $DD, $61, $04, $62

JumpTable_6158_19:
    call toc_01_27D2
    call toc_01_0891
    ld   [hl], $FF
    call JumpTable_3B8D_00
    call toc_01_0891
    jr   nz, .else_19_6176

    ld   [wScreenShakeHorizontal], a
    call toc_01_3B87
    assign [$FFF2], $2E
    call JumpTable_3B8D_00
    ret


.else_19_6176:
    cp   $A0
    jr   nz, .else_19_617E

    assign [$FFF4], $1D
.else_19_617E:
    jr   c, .else_19_618C

    and  %00010000
    ld   a, $00
    jr   z, .else_19_6188

    ld   a, $FF
.else_19_6188:
    call toc_01_3B87
    ret


.else_19_618C:
    ld   e, $01
    and  %00000100
    jr   z, .else_19_6194

    ld   e, 254
.else_19_6194:
    ld   a, e
    ld   [wScreenShakeHorizontal], a
    ret


    db   $CD, $91, $08, $A7, $20, $03, $CD, $8D
    db   $3B, $C9, $21, $31, $61, $18, $03, $21
    db   $35, $61, $C5, $E5, $21, $B0, $C2, $09
    db   $7E, $17, $E6, $02, $5F, $50, $E1, $19
    db   $2A, $56, $5F, $0E, $34, $21, $01, $D6
    db   $1B, $1A, $13, $FE, $98, $1A, $20, $08
    db   $F0, $96, $A7, $1A, $28, $02, $C6, $0C
    db   $13, $22, $0D, $20, $EB, $36, $00, $C1
    db   $CD, $8D, $3B, $C9, $21, $39, $61, $CD
    db   $AB, $61, $CD, $91, $08, $36, $18, $21
    db   $B0, $C2, $09, $34, $21, $D0, $C3, $09
    db   $7E, $3C, $77, $FE, $0C, $20, $06, $F0
    db   $BF, $EA, $68, $D3, $C9, $CD, $8D, $3B
    db   $36, $02, $C9, $CD, $62, $7A, $CB, $E6
    db   $AF, $EA, $55, $C1, $EA, $67, $C1, $3E
    db   $02, $E0, $F2, $3E, $E1, $EA, $36, $D7
    db   $3E, $77, $EA, $46, $D7, $3E, $77, $EA
    db   $56, $D7, $CD, $69, $62, $C3, $B0, $79
    db   $98, $4A, $87, $0C, $1C, $64, $66, $0F
    db   $0F, $0F, $0F, $98, $4B, $87, $0D, $1D
    db   $65, $67, $1F, $1F, $1F, $1F, $98, $49
    db   $81, $0B, $1B, $98, $4C, $81, $0E, $1E
    db   $98, $56, $87, $0C, $1C, $64, $66, $0F
    db   $0F, $0F, $0F, $98, $57, $87, $0D, $1D
    db   $65, $67, $1F, $1F, $1F, $1F, $98, $55
    db   $81, $0B, $1B, $98, $58, $81, $0E, $1E
    db   $3E, $20, $EA, $00, $D6, $21, $01, $D6
    db   $11, $29, $62, $F0, $96, $A7, $28, $03
    db   $11, $49, $62, $C5, $0E, $20, $1A, $13
    db   $22, $0D, $20, $FA, $C1, $70, $C9, $50
    db   $5C, $68, $70, $7A, $7E, $58, $32, $38
    db   $38, $40, $44, $50, $20, $20, $20, $20
    db   $20, $1F, $1E, $1F, $20, $20, $20, $20
    db   $20, $03, $03, $04, $04, $05, $05, $06
    db   $01, $01, $02, $02, $03, $03, $C0, $C0
    db   $C0, $C0, $C0, $C0, $C0, $38, $3A, $3B
    db   $44, $4C, $58, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $2F, $30, $30, $30, $30, $30
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $01, $02, $03, $04, $04, $00, $00, $70
    db   $00, $00, $00, $FF, $00, $00, $00, $FF
    db   $00, $00, $00, $FF, $00, $00, $00, $72
    db   $00, $00, $08, $74, $00, $00, $00, $FF
    db   $00, $00, $00, $FF, $00, $00, $00, $76
    db   $00, $00, $08, $78, $00, $00, $10, $7A
    db   $00, $00, $00, $FF, $00, $00, $00, $7C
    db   $00, $00, $08, $7E, $00, $00, $10, $7E
    db   $20, $00, $18, $7C, $20, $00, $00, $7A
    db   $20, $00, $08, $78, $20, $00, $10, $76
    db   $20, $00, $00, $FF, $00, $00, $00, $74
    db   $20, $00, $08, $72, $20, $00, $00, $FF
    db   $00, $00, $00, $FF, $00, $00, $30, $70
    db   $20, $00, $D8, $70, $00, $00, $00, $FF
    db   $00, $00, $00, $FF, $00, $00, $00, $60
    db   $10, $10, $00, $62, $00, $20, $00, $62
    db   $00, $00, $00, $FF, $00, $00, $00, $FF
    db   $00, $00, $00, $FF, $00, $00, $00, $64
    db   $10, $10, $00, $66, $00, $20, $00, $66
    db   $00, $00, $00, $FF, $00, $00, $00, $FF
    db   $00, $00, $00, $FF, $00, $00, $02, $68
    db   $10, $10, $02, $6A, $00, $20, $02, $6A
    db   $00, $00, $05, $68, $30, $10, $05, $6A
    db   $20, $20, $05, $6A, $20, $00, $01, $68
    db   $10, $10, $01, $6A, $00, $20, $01, $6A
    db   $00, $00, $07, $68, $30, $10, $07, $6A
    db   $20, $20, $07, $6A, $20, $00, $00, $68
    db   $10, $10, $00, $6A, $00, $20, $00, $6A
    db   $00, $00, $08, $68, $30, $10, $08, $6A
    db   $20, $20, $08, $6A, $20, $21, $D0, $C3
    db   $09, $5E, $50, $21, $88, $62, $19, $7E
    db   $E0, $EE, $21, $95, $62, $19, $7E, $E0
    db   $EC, $21, $A2, $62, $19, $7E, $17, $17
    db   $17, $17, $E6, $F0, $5F, $50, $21, $D6
    db   $62, $19, $0E, $04, $CD, $26, $3D, $3E
    db   $02, $CD, $D0, $3D, $21, $D0, $C3, $09
    db   $5E, $50, $21, $AF, $62, $19, $7E, $E0
    db   $EE, $21, $BC, $62, $19, $7E, $E0, $EC
    db   $21, $C9, $62, $19, $7E, $17, $17, $17
    db   $E6, $F8, $5F, $17, $E6, $F0, $83, $5F
    db   $50, $21, $46, $63, $19, $0E, $06, $CD
    db   $26, $3D, $3E, $04, $CD, $D0, $3D, $C9
    db   $98, $02, $09, $55, $56, $55, $56, $55
    db   $56, $55, $56, $55, $56, $98, $22, $09
    db   $55, $56, $55, $56, $55, $56, $55, $56
    db   $55, $56, $98, $42, $09, $0C, $0D, $0C
    db   $0D, $0C, $0D, $0C, $0D, $0C, $0D, $98
    db   $62, $09, $0E, $0F, $0E, $0F, $0E, $0F
    db   $0E, $0F, $0E, $0F, $98, $02, $09, $55
    db   $56, $55, $56, $55, $56, $55, $56, $55
    db   $56, $98, $22, $09, $55, $56, $55, $56
    db   $55, $56, $55, $56, $55, $56, $98, $42
    db   $09, $0E, $0F, $0E, $0F, $0E, $0F, $0E
    db   $0F, $0E, $0F, $98, $62, $09, $0F, $0E
    db   $0F, $0E, $0F, $0E, $0F, $0E, $0F, $0E
    db   $98, $02, $09, $55, $56, $55, $56, $55
    db   $56, $55, $56, $55, $56, $98, $22, $09
    db   $0E, $0F, $0E, $0F, $0E, $0F, $0E, $0F
    db   $0E, $0F, $98, $42, $09, $0F, $0E, $0F
    db   $0E, $0F, $0E, $0F, $0E, $0F, $0E, $98
    db   $62, $09, $0E, $0F, $0E, $0F, $0E, $0F
    db   $0E, $0F, $0E, $0F, $98, $02, $09, $0E
    db   $0F, $0E, $0F, $0E, $0F, $0E, $0F, $0E
    db   $0F, $98, $22, $09, $0F, $0E, $0F, $0E
    db   $0F, $0E, $0F, $0E, $0F, $0E, $98, $42
    db   $09, $0E, $0F, $0E, $0F, $0E, $0F, $0E
    db   $0F, $0E, $0F, $98, $62, $09, $0F, $0E
    db   $0F, $0E, $0F, $0E, $0F, $0E, $0F, $0E
    db   $98, $82, $09, $0F, $0E, $0F, $0F, $0F
    db   $0E, $0F, $0E, $0F, $0E, $98, $A2, $09
    db   $0E, $0F, $0E, $0F, $0E, $0F, $0E, $0F
    db   $0E, $0F, $98, $C2, $09, $0F, $0E, $0F
    db   $0E, $0F, $0E, $0F, $0E, $0F, $0E, $98
    db   $E2, $09, $1E, $1E, $1E, $1E, $1E, $1E
    db   $1E, $1E, $1E, $1E, $98, $82, $09, $0E
    db   $0F, $0E, $0F, $0E, $0F, $0E, $0F, $0E
    db   $0F, $98, $A2, $09, $0F, $0E, $0F, $0E
    db   $0F, $0E, $0F, $0E, $0F, $0E, $98, $C2
    db   $09, $1E, $1E, $1E, $1E, $1E, $1E, $1E
    db   $1E, $1E, $1E, $98, $E2, $09, $09, $08
    db   $18, $09, $7E, $7E, $09, $08, $18, $09
    db   $98, $82, $09, $0E, $0F, $0E, $0F, $0E
    db   $0F, $0E, $0F, $0E, $0F, $98, $A2, $09
    db   $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E
    db   $1E, $1E, $98, $C2, $09, $09, $08, $18
    db   $09, $7E, $7E, $09, $08, $18, $09, $98
    db   $E2, $09, $09, $04, $05, $09, $7E, $7E
    db   $09, $04, $05, $09, $98, $82, $09, $1E
    db   $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E
    db   $1E, $98, $A2, $09, $09, $08, $18, $09
    db   $7E, $7E, $09, $08, $18, $09, $98, $C2
    db   $09, $09, $04, $05, $09, $7E, $7E, $09
    db   $04, $05, $09, $98, $E2, $09, $19, $14
    db   $15, $19, $1F, $1F, $19, $14, $15, $19
    db   $21, $64, $55, $64, $89, $64, $BD, $64
    db   $F1, $64, $25, $65, $59, $65, $8D, $65
    db   $F0, $F6, $FE, $0E, $CA, $3D, $61, $3E
    db   $02, $E0, $A1, $EA, $67, $C1, $F0, $F0
    db   $C7

    dw JumpTable_65EA_19 ; 00

    db   $FB, $65, $24, $66, $5F, $66

JumpTable_65EA_19:
    assign [$FFF4], $04
    call toc_01_0891
    ld   [hl], $AC
    call toc_01_088C
    ld   [hl], $AC
    call JumpTable_3B8D_00
    call toc_01_0891
    cp   $A0
    jr   nz, .else_19_6607

    ld   hl, $FFF4
    ld   [hl], $2E
.else_19_6607:
    and  a
    jr   nz, .else_19_6611

    assign [$FFF2], $2F
    call JumpTable_3B8D_00
.else_19_6611:
    ld   e, $01
    and  %00000100
    jr   z, .else_19_6619

    ld   e, 254
.else_19_6619:
    ld   a, e
    ld   [wScreenShakeHorizontal], a
    call toc_01_088C
    ret  nz

    jp   toc_19_6705

    db   $21, $B0, $C2, $09, $7E, $F5, $17, $E6
    db   $06, $5F, $50, $21, $C1, $65, $19, $2A
    db   $56, $5F, $C5, $0E, $34, $21, $01, $D6
    db   $1A, $FE, $98, $20, $09, $F0, $97, $A7
    db   $3E, $98, $28, $02, $3E, $9A, $13, $22
    db   $0D, $20, $ED, $36, $00, $C1, $F1, $FE
    db   $03, $20, $05, $F0, $BF, $EA, $68, $D3
    db   $C3, $8D, $3B, $C5, $21, $B0, $C2, $09
    db   $7E, $17, $E6, $06, $5F, $50, $21, $C9
    db   $65, $19, $2A, $56, $5F, $0E, $34, $21
    db   $01, $D6, $1A, $FE, $98, $20, $09, $F0
    db   $97, $A7, $3E, $98, $28, $02, $3E, $9A
    db   $13, $22, $0D, $20, $ED, $36, $00, $C1
    db   $21, $B0, $C2, $09, $7E, $3C, $77, $FE
    db   $04, $20, $5B, $21, $12, $D7, $3E, $B3
    db   $22, $3E, $B3, $22, $3E, $B3, $22, $3E
    db   $B3, $22, $3E, $B3, $22, $21, $22, $D7
    db   $3E, $B3, $22, $3E, $B3, $22, $3E, $B3
    db   $22, $3E, $B3, $22, $3E, $B3, $22, $21
    db   $32, $D7, $3E, $AD, $22, $3E, $B1, $22
    db   $3E, $E7, $22, $3E, $AD, $22, $3E, $B1
    db   $22, $21, $42, $D7, $3E, $AE, $22, $3E
    db   $B2, $22, $3E, $E3, $22, $3E, $AE, $22
    db   $3E, $B2, $22, $CD, $62, $7A, $CB, $E6
    db   $AF, $EA, $55, $C1, $EA, $67, $C1, $3E
    db   $02, $E0, $F2, $C3, $B0, $79, $CD, $8D
    db   $3B, $36, $01, $CD, $91, $08, $36, $30
    db   $C9, $18, $58, $28, $48, $38, $20, $50
    db   $40

toc_19_6705:
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .return_19_6742

    ld   a, $A7
    call toc_01_3C01
    jr   c, .return_19_6742

    push bc
    call toc_01_27ED
    and  %00000111
    ld   c, a
    ld   hl, $66FD
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    call toc_01_27ED
    and  %00000111
    add  a, $47
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    pop  bc
    ld   hl, $C340
    add  hl, de
    ld   [hl], $C2
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $10
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $01
.return_19_6742:
    ret


    db   $60, $00, $62, $00, $62, $20, $60, $20
    db   $64, $00, $66, $00, $66, $20, $64, $20
    db   $68, $00, $6A, $00, $6C, $00, $6E, $00
    db   $6A, $20, $68, $20, $6E, $20, $6C, $20
    db   $F0, $10, $21, $C0, $C2, $09, $7E, $A7
    db   $C2, $D1, $65, $F0, $F7, $FE, $0A, $20
    db   $10, $F0, $F6, $FE, $97, $28, $04, $FE
    db   $98, $20, $06, $FA, $7F, $DB, $A7, $20
    db   $06, $11, $43, $67, $CD, $3B, $3C, $CD
    db   $9B, $78, $CD, $BD, $78, $CD, $B4, $3B
    db   $CD, $07, $79, $CD, $9E, $3B, $FA, $33
    db   $C1, $A7, $20, $58, $F0, $CB, $E6, $03
    db   $28, $22, $5F, $50, $21, $62, $67, $19
    db   $7E, $21, $40, $C2, $09, $77, $21, $50
    db   $C2, $09, $70, $7B, $E6, $02, $C6, $04
    db   $5F, $F0, $E7, $1F, $1F, $1F, $E6, $01
    db   $83, $C3, $87, $3B, $F0, $CB, $E6, $0F
    db   $28, $2A, $1F, $1F, $2F, $E6, $03, $5F
    db   $50, $21, $62, $67, $19, $7E, $21, $50
    db   $C2, $09, $77, $21, $40, $C2, $09, $70
    db   $7B, $3D, $EE, $01, $CB, $2F, $17, $17
    db   $5F, $F0, $E7, $1F, $1F, $1F, $E6, $01
    db   $83, $C3, $87, $3B, $C3, $AF, $3D, $60
    db   $00, $62, $00, $64, $00, $66, $00, $62
    db   $20, $60, $20, $66, $20, $64, $20, $11
    db   $FA, $67, $CD, $3B, $3C, $CD, $9B, $78
    db   $21, $40, $C2, $09, $7E, $07, $07, $E6
    db   $02, $5F, $F0, $E7, $1F, $1F, $1F, $E6
    db   $01, $B3, $CD, $87, $3B, $CD, $B4, $3B
    db   $F0, $F0, $C7

    dw JumpTable_6834_19 ; 00

    db   $57, $68, $65, $68

JumpTable_6834_19:
    ld   hl, $C240
    ifNe [$FFEB], $AA, .else_19_6840

    ld   hl, $C250
.else_19_6840:
    add  hl, bc
    ld   [hl], $08
    ld   e, $80
    ifNe [$FFEB], $AA, .else_19_684D

    ld   e, $60
.else_19_684D:
    call toc_01_0891
    ld   [hl], e
    call JumpTable_3B8D_00
    ld   [hl], $01
    ret


    db   $CD, $91, $08, $20, $05, $36, $28, $CD
    db   $8D, $3B, $CD, $07, $79, $C9, $CD, $91
    db   $08, $20, $13, $21, $40, $C2, $09, $7E
    db   $2F, $3C, $77, $21, $50, $C2, $09, $7E
    db   $2F, $3C, $77, $C3, $43, $68, $C9, $F0
    db   $F0, $FE, $05, $20, $06, $F0, $ED, $F6
    db   $40, $E0, $ED, $11, $FA, $67, $CD, $3B
    db   $3C, $CD, $9B, $78, $21, $40, $C2, $09
    db   $7E, $07, $07, $E6, $02, $5F, $CD, $BD
    db   $78, $F0, $F0, $FE, $05, $28, $0E, $F0
    db   $E7, $1F, $1F, $1F, $E6, $01, $B3, $CD
    db   $87, $3B, $CD, $B4, $3B, $F0, $F0, $C7

    dw JumpTable_68C3_19 ; 00

    db   $D3, $68, $F1, $68, $25, $69, $3E, $69
    db   $63, $69

JumpTable_68C3_19:
    ld   hl, $C480
    add  hl, bc
    ld   [hl], $03
    ld   a, [$FFEF]
    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], a
    jp   JumpTable_3B8D_00

    db   $CD, $91, $08, $CD, $ED, $27, $E6, $7F
    db   $C6, $30, $77, $CD, $ED, $27, $1E, $F4
    db   $E6, $01, $28, $02, $1E, $0C, $21, $40
    db   $C2, $09, $73, $C3, $8D, $3B, $CD, $91
    db   $08, $20, $14, $21, $50, $C2, $09, $36
    db   $D4, $F0, $EC, $D6, $08, $CD, $8D, $69
    db   $3E, $24, $E0, $F2, $C3, $8D, $3B, $CD
    db   $8C, $08, $20, $10, $CD, $ED, $27, $E6
    db   $3F, $F6, $10, $77, $21, $40, $C2, $09
    db   $7E, $2F, $3C, $77, $CD, $14, $79, $C3
    db   $9E, $3B, $CD, $91, $08, $20, $13, $CD
    db   $0A, $79, $CD, $53, $69, $21, $50, $C2
    db   $09, $34, $7E, $FE, $18, $20, $03, $CD
    db   $8D, $3B, $C9, $21, $B0, $C2, $09, $7E
    db   $21, $10, $C2, $09, $BE, $30, $06, $CD
    db   $8D, $3B, $36, $01, $C9, $CD, $0A, $79
    db   $21, $30, $C4, $09, $CB, $C6, $CD, $9E
    db   $3B, $21, $30, $C4, $09, $CB, $86, $C9
    db   $21, $40, $C3, $09, $CB, $FE, $CB, $F6
    db   $21, $50, $C2, $09, $34, $E5, $21, $70
    db   $C4, $09, $7E, $E1, $A7, $28, $02, $36
    db   $06, $CD, $0A, $79, $F0, $EC, $FE, $70
    db   $38, $CE, $FE, $88, $D2, $B0, $79, $C9
    db   $F0, $EC, $E0, $D8, $F0, $EE, $E0, $D7
    db   $3E, $01, $CD, $53, $09, $3E, $0E, $E0
    db   $F2, $C9, $9A, $10, $9C, $10, $11, $9D
    db   $69, $CD, $3B, $3C, $CD, $40, $79, $21
    db   $20, $C3, $09, $35, $21, $10, $C3, $09
    db   $7E, $E6, $80, $C2, $B0, $79, $C9, $21
    db   $B0, $C2, $09, $7E, $A7, $C2, $A1, $69
    db   $CD, $4A, $6B, $CD, $00, $78, $F0, $F0
    db   $C7

    dw JumpTable_69D4_19 ; 00

    db   $0B, $6A, $26, $6A, $64, $6A

JumpTable_69D4_19:
    call toc_19_784E
    jr   nc, .else_19_69FF

    ld   e, $CD
    ld   a, [$FFF8]
    and  %00100000
    jr   nz, .else_19_69FB

    ld   e, $CC
    ld   a, [$DAFE]
    and  %00100000
    jr   nz, .else_19_69FB

    ld   e, $C6
    ifEq [$DB0E], $03, .else_19_69FB

    ld   a, $C7
    call toc_01_2185
    jp   JumpTable_3B8D_00

.else_19_69FB:
    ld   a, e
    call toc_01_2185
.else_19_69FF:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


    db   $FA, $9F, $C1, $A7, $20, $14, $CD, $8D
    db   $3B, $FA, $77, $C1, $A7, $28, $06, $70
    db   $3E, $C9, $C3, $85, $21, $3E, $C8, $CD
    db   $85, $21, $C9, $FA, $9F, $C1, $A7, $20
    db   $33, $3E, $CD, $CD, $01, $3C, $F0, $D7
    db   $21, $00, $C2, $19, $D6, $02, $77, $F0
    db   $D8, $21, $10, $C2, $19, $77, $21, $B0
    db   $C2, $19, $36, $01, $21, $20, $C3, $19
    db   $36, $20, $21, $40, $C3, $19, $36, $C2
    db   $3E, $24, $E0, $F2, $CD, $91, $08, $36
    db   $C0, $CD, $8D, $3B, $C9, $00, $01, $02
    db   $01, $3E, $02, $E0, $A1, $EA, $67, $C1
    db   $CD, $91, $08, $20, $15, $AF, $EA, $67
    db   $C1, $3E, $04, $EA, $0E, $DB, $3E, $0D
    db   $E0, $A5, $CD, $98, $08, $CD, $8D, $3B
    db   $70, $C9, $FE, $80, $38, $05, $3E, $03
    db   $C3, $87, $3B, $FE, $08, $20, $06, $35
    db   $3E, $CA, $CD, $85, $21, $F0, $E7, $1F
    db   $1F, $1F, $E6, $03, $5F, $50, $21, $60
    db   $6A, $19, $7E, $CD, $87, $3B, $C9, $00
    db   $00, $50, $00, $00, $08, $52, $00, $00
    db   $10, $54, $00, $10, $00, $56, $00, $10
    db   $08, $58, $00, $10, $10, $5A, $00, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
    db   $00, $50, $00, $00, $08, $52, $00, $00
    db   $10, $5C, $00, $10, $00, $56, $00, $10
    db   $08, $58, $00, $10, $10, $5E, $00, $10
    db   $18, $60, $00, $FF, $FF, $FF, $FF, $00
    db   $00, $62, $00, $00, $08, $64, $00, $00
    db   $10, $66, $00, $10, $00, $68, $00, $10
    db   $08, $58, $00, $10, $10, $5E, $00, $10
    db   $10, $60, $00, $FF, $FF, $FF, $FF, $00
    db   $00, $6A, $00, $00, $08, $6C, $00, $00
    db   $10, $6E, $00, $10, $00, $68, $00, $10
    db   $08, $58, $00, $10, $10, $5E, $00, $10
    db   $10, $60, $00, $FF, $FF, $FF, $FF, $10
    db   $00, $74, $00, $10, $08, $76, $00, $10
    db   $10, $74, $00, $10, $18, $76, $00, $00
    db   $10, $74, $00, $00, $18, $76, $00, $00
    db   $00, $74, $00, $00, $08, $76, $00, $F0
    db   $F1, $17, $17, $17, $17, $17, $E6, $E0
    db   $5F, $50, $21, $AA, $6A, $19, $F0, $EE
    db   $C6, $03, $E0, $EE, $0E, $07, $CD, $26
    db   $3D, $3E, $02, $CD, $D0, $3D, $3E, $78
    db   $E0, $EE, $3E, $5C, $E0, $EC, $21, $2A
    db   $6B, $0E, $08, $FA, $0E, $DB, $FE, $04
    db   $20, $02, $0D, $0D, $CD, $26, $3D, $3E
    db   $03, $CD, $D0, $3D, $CD, $BA, $3D, $C9
    db   $08, $04, $70, $00, $08, $0C, $72, $00
    db   $08, $14, $70, $20, $FA, $A5, $DB, $A7
    db   $20, $0E, $21, $40, $C3, $09, $36, $C3
    db   $21, $8B, $6B, $0E, $03, $C3, $26, $3D
    db   $F0, $F6, $FE, $FE, $CA, $BA, $69, $F0
    db   $EE, $FE, $30, $DA, $0D, $6D, $F0, $F0
    db   $A7, $20, $2E, $CD, $8D, $3B, $21, $10
    db   $C2, $09, $36, $48, $21, $00, $C2, $09
    db   $7E, $D6, $04, $77, $3E, $CD, $CD, $01
    db   $3C, $21, $00, $C2, $19, $36, $28, $21
    db   $10, $C2, $19, $36, $28, $21, $B0, $C2
    db   $19, $36, $01, $21, $E0, $C2, $19, $36
    db   $40, $CD, $A3, $6C, $CD, $00, $78, $F0
    db   $F0, $C7

    dw JumpTable_6BFB_19 ; 00

    db   $FC, $6B, $2E, $6C

JumpTable_6BFB_19:
    ret


    db   $CD, $87, $08, $C0, $CD, $4E, $78, $30
    db   $1B, $FA, $0E, $DB, $FE, $0E, $20, $07
    db   $3E, $D8, $CD, $97, $21, $18, $05, $3E
    db   $9B, $CD, $85, $21, $21, $9F, $C1, $CB
    db   $FE, $CD, $8D, $3B, $F0, $E7, $1E, $00
    db   $E6, $20, $28, $01, $1C, $7B, $CD, $87
    db   $3B, $C9, $FA, $9F, $C1, $A7, $20, $05
    db   $CD, $8D, $3B, $36, $01, $CD, $5A, $79
    db   $7B, $C6, $02, $CD, $87, $3B, $C9, $F8
    db   $F8, $5A, $00, $F8, $00, $5C, $00, $F8
    db   $08, $5E, $00, $08, $00, $60, $00, $08
    db   $08, $62, $00, $F8, $10, $5A, $20, $F8
    db   $00, $5E, $20, $F8, $08, $5C, $20, $08
    db   $00, $62, $20, $08, $08, $60, $20, $00
    db   $10, $50, $20, $F8, $00, $54, $20, $F8
    db   $08, $52, $20, $08, $00, $58, $20, $08
    db   $08, $56, $20, $00, $F8, $50, $00, $F8
    db   $00, $52, $00, $F8, $08, $54, $00, $08
    db   $00, $56, $00, $08, $08, $58, $00, $F0
    db   $00, $76, $00, $F0, $08, $76, $20, $00
    db   $00, $78, $00, $00, $08, $78, $20, $F0
    db   $F1, $17, $17, $E6, $FC, $5F, $17, $17
    db   $E6, $F0, $83, $5F, $50, $21, $43, $6C
    db   $19, $F0, $EE, $C6, $04, $E0, $EE, $0E
    db   $05, $CD, $26, $3D, $F0, $EE, $C6, $10
    db   $E0, $EE, $21, $93, $6C, $0E, $04, $CD
    db   $26, $3D, $CD, $00, $78, $F0, $98, $D6
    db   $68, $C6, $04, $FE, $08, $30, $2E, $F0
    db   $99, $D6, $50, $C6, $04, $FE, $08, $30
    db   $24, $F0, $9E, $FE, $02, $20, $1E, $CD
    db   $74, $78, $30, $19, $CD, $87, $08, $20
    db   $14, $3E, $08, $EA, $95, $DB, $AF, $EA
    db   $6B, $C1, $EA, $6C, $C1, $EA, $96, $DB
    db   $CD, $87, $08, $36, $08, $CD, $BA, $3D
    db   $C9, $CD, $91, $08, $28, $04, $3E, $00
    db   $E0, $F1, $CD, $D2, $6D, $CD, $00, $78
    db   $21, $80, $C3, $09, $F0, $E7, $1F, $1F
    db   $1F, $E6, $01, $3C, $86, $CD, $87, $3B
    db   $CD, $6A, $79, $C6, $13, $FE, $26, $30
    db   $11, $CD, $5A, $79, $C6, $13, $FE, $26
    db   $30, $08, $7B, $CB, $27, $21, $80, $C3
    db   $09, $77, $CD, $4E, $78, $30, $22, $21
    db   $D0, $C3, $09, $7E, $34, $E6, $01, $28
    db   $12, $1E, $AF, $CD, $ED, $27, $E6, $3F
    db   $28, $0B, $1E, $FB, $CD, $ED, $27, $E6
    db   $07, $28, $02, $1E, $FA, $7B, $CD, $97
    db   $21, $C9, $F4, $00, $64, $00, $F4, $08
    db   $66, $00, $04, $00, $68, $00, $04, $08
    db   $6A, $00, $FF, $FF, $FF, $FF, $04, $F8
    db   $70, $00, $F4, $00, $6C, $00, $F4, $08
    db   $6E, $00, $04, $00, $72, $00, $04, $08
    db   $74, $00, $04, $F8, $7A, $00, $F4, $00
    db   $6C, $00, $F4, $08, $6E, $00, $04, $00
    db   $7C, $00, $04, $08, $74, $00, $04, $10
    db   $70, $20, $F4, $00, $6E, $20, $F4, $08
    db   $6C, $20, $04, $00, $74, $20, $04, $08
    db   $72, $20, $04, $10, $7A, $20, $F4, $00
    db   $6E, $20, $F4, $08, $6C, $20, $04, $00
    db   $74, $20, $04, $08, $7C, $20, $F0, $F1
    db   $17, $17, $E6, $FC, $5F, $17, $17, $E6
    db   $F0, $83, $5F, $50, $21, $6E, $6D, $19
    db   $0E, $05, $CD, $26, $3D, $C9, $00, $06
    db   $0C, $13, $19, $20, $26, $2C, $33, $39
    db   $00, $00, $00, $00, $00, $00, $40, $43
    db   $46, $49, $4C, $4F, $52, $55, $58, $5C
    db   $00, $00, $00, $00, $00, $00, $60, $60
    db   $60, $60, $60, $60, $60, $60, $60, $21
    db   $B0, $C2, $09, $7E, $FE, $02, $CA, $77
    db   $74, $A7, $C2, $CA, $70, $F0, $98, $FE
    db   $38, $30, $12, $FE, $20, $38, $0E, $21
    db   $1E, $C1, $CB, $FE, $FE, $24, $38, $05
    db   $21, $1D, $C1, $CB, $FE, $FA, $0F, $DB
    db   $A7, $C8, $5F, $50, $21, $EA, $6D, $19
    db   $7E, $E0, $E8, $F0, $F8, $E6, $10, $CD
    db   $AD, $6F, $F0, $F0, $C7

    dw JumpTable_6E61_19 ; 00

    db   $76, $6E, $83, $6E, $BC, $6E, $23, $6F
    db   $5A, $6F, $5B, $6F, $98, $6F

JumpTable_6E61_19:
    ifLt [hLinkPositionX], 60, .return_19_6E75

    call toc_01_1495
    call toc_01_093B
    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $58
.return_19_6E75:
    ret


    db   $3E, $01, $EA, $67, $C1, $FA, $46, $C1
    db   $A7, $CA, $8D, $3B, $C9, $3E, $02, $E0
    db   $A1, $CD, $91, $08, $C0, $21, $D0, $C3
    db   $09, $F0, $E8, $96, $30, $07, $F0, $E8
    db   $77, $CD, $8D, $3B, $C9, $5F, $F0, $E7
    db   $E6, $03, $20, $19, $CD, $ED, $27, $E6
    db   $01, $20, $12, $7B, $1F, $1F, $1F, $1F
    db   $E6, $0F, $A7, $20, $02, $3E, $01, $86
    db   $77, $3E, $06, $E0, $F3, $C9, $3E, $02
    db   $E0, $A1, $EA, $67, $C1, $FA, $0F, $DB
    db   $FE, $20, $38, $20, $CD, $91, $08, $36
    db   $40, $CD, $8D, $3B, $CD, $1C, $75, $21
    db   $C0, $C2, $09, $36, $01, $3E, $56, $EA
    db   $68, $D3, $AF, $EA, $67, $C1, $CD, $8C
    db   $08, $36, $3F, $C9, $21, $E9, $DA, $FE
    db   $05, $20, $10, $CB, $6E, $20, $20, $CD
    db   $8D, $3B, $36, $06, $3E, $23, $E0, $F2
    db   $C3, $E0, $6E, $FE, $10, $20, $10, $CB
    db   $76, $20, $0C, $CD, $8D, $3B, $36, $06
    db   $3E, $23, $E0, $F2, $C3, $E0, $6E, $3E
    db   $1D, $E0, $F2, $CD, $8D, $3B, $36, $05
    db   $AF, $EA, $67, $C1, $C9, $3E, $02, $E0
    db   $A1, $EA, $67, $C1, $CD, $91, $08, $FE
    db   $3E, $20, $05, $21, $F2, $FF, $36, $23
    db   $A7, $20, $20, $3E, $CF, $CD, $01, $3C
    db   $21, $00, $C2, $19, $36, $50, $21, $10
    db   $C2, $19, $36, $48, $21, $B0, $C2, $19
    db   $36, $01, $21, $E0, $C2, $19, $36, $4F
    db   $CD, $8D, $3B, $C9, $C9, $CD, $8C, $08
    db   $20, $37, $CD, $8D, $3B, $3E, $CF, $CD
    db   $01, $3C, $21, $00, $C2, $19, $36, $50
    db   $21, $10, $C2, $19, $36, $48, $21, $B0
    db   $C2, $19, $36, $02, $21, $E0, $C2, $19
    db   $36, $14, $3E, $02, $CD, $01, $3C, $21
    db   $00, $C2, $19, $36, $50, $21, $10, $C2
    db   $19, $36, $48, $21, $E0, $C2, $19, $36
    db   $20, $C9, $C9, $50, $00, $50, $20, $3C
    db   $00, $3C, $20, $3A, $00, $3A, $20, $1E
    db   $00, $1E, $60, $1E, $10, $1E, $70, $21
    db   $C0, $C2, $09, $7E, $A7, $20, $29, $3E
    db   $88, $E0, $EE, $3E, $80, $E0, $EC, $11
    db   $99, $6F, $CD, $3B, $3C, $21, $D0, $C3
    db   $09, $7E, $5F, $3E, $80, $93, $E0, $EC
    db   $11, $99, $6F, $CD, $3B, $3C, $F0, $EC
    db   $C6, $10, $E0, $EC, $FE, $80, $38, $F0
    db   $CD, $8C, $08, $28, $26, $1F, $1F, $1F
    db   $E6, $03, $E0, $F1, $21, $D0, $C3, $09
    db   $7E, $5F, $3E, $80, $93, $E0, $EC, $3E
    db   $78, $E0, $EE, $11, $9D, $6F, $CD, $3B
    db   $3C, $3E, $98, $E0, $EE, $11, $9D, $6F
    db   $CD, $3B, $3C, $C9, $D8, $E8, $7C, $40
    db   $D8, $F0, $7C, $20, $E8, $E8, $7C, $00
    db   $E8, $F0, $7C, $60, $F8, $F8, $7C, $00
    db   $F8, $00, $7C, $60, $08, $08, $7C, $00
    db   $08, $10, $7C, $60, $18, $18, $7C, $00
    db   $18, $20, $7C, $60, $28, $18, $7C, $40
    db   $28, $20, $7C, $20, $D8, $F8, $7C, $00
    db   $D8, $00, $7C, $60, $E8, $08, $7C, $00
    db   $E8, $10, $7C, $60, $F8, $08, $7C, $40
    db   $F8, $10, $7C, $20, $08, $F8, $7C, $40
    db   $08, $00, $7C, $20, $18, $F8, $7C, $00
    db   $18, $00, $7C, $60, $28, $08, $7C, $00
    db   $28, $10, $7C, $60, $D8, $08, $7C, $40
    db   $D8, $10, $7C, $20, $E8, $F8, $7C, $40
    db   $E8, $00, $7C, $20, $F8, $F8, $7C, $00
    db   $F8, $00, $7C, $60, $08, $08, $7C, $00
    db   $08, $10, $7C, $60, $18, $08, $7C, $40
    db   $18, $10, $7C, $20, $28, $F8, $7C, $40
    db   $28, $00, $7C, $20, $D8, $18, $7C, $00
    db   $D8, $20, $7C, $60, $E8, $18, $7C, $40
    db   $E8, $20, $7C, $20, $F8, $08, $7C, $40
    db   $F8, $10, $7C, $20, $08, $F8, $7C, $40
    db   $08, $00, $7C, $20, $18, $E8, $7C, $40
    db   $18, $F0, $7C, $20, $28, $E8, $7C, $00
    db   $28, $F0, $7C, $60, $F0, $F0, $C7

    dw JumpTable_70DD_19 ; 00

    db   $04, $71, $63, $71, $35, $72, $71, $72
    db   $A7, $72, $C1, $72, $3B, $73

JumpTable_70DD_19:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    ld   [$C167], a
    call toc_01_0891
    jr   z, .else_19_70FC

    cp   $30
    ret  c

    sub  a, $30
    rra
    rra
    rra
    and  %00000011
    ld   [$FFF1], a
    ld   de, $6F9D
    call toc_01_3C3B
    ret


.else_19_70FC:
    call toc_01_0891
    ld   [hl], $A0
    jp   JumpTable_3B8D_00

    db   $3E, $02, $E0, $A1, $EA, $67, $C1, $CD
    db   $91, $08, $20, $09, $36, $FF, $3E, $1E
    db   $E0, $F3, $CD, $8D, $3B, $CD, $91, $08
    db   $E6, $04, $1E, $E4, $28, $02, $1E, $84
    db   $7B, $EA, $97, $DB, $F0, $E7, $E6, $07
    db   $20, $0C, $3E, $33, $E0, $F4, $CD, $ED
    db   $27, $E6, $03, $CD, $87, $3B, $F0, $E7
    db   $21, $20, $C4, $09, $77, $F0, $F1, $17
    db   $17, $17, $17, $E6, $F0, $5F, $17, $E6
    db   $E0, $83, $5F, $50, $21, $0A, $70, $19
    db   $0E, $0C, $CD, $26, $3D, $3E, $0A, $CD
    db   $D0, $3D, $C9, $7A, $00, $7A, $20, $3E
    db   $02, $E0, $A1, $EA, $67, $C1, $CD, $19
    db   $71, $CD, $91, $08, $20, $08, $CD, $87
    db   $08, $36, $28, $C3, $8D, $3B, $FE, $50
    db   $30, $0D, $21, $15, $72, $0E, $08, $CD
    db   $26, $3D, $3E, $06, $C3, $D0, $3D, $AF
    db   $E0, $F1, $11, $5F, $71, $CD, $3B, $3C
    db   $C9, $F8, $00, $6E, $00, $F8, $08, $6E
    db   $20, $F8, $00, $6E, $00, $F8, $08, $6E
    db   $20, $08, $00, $70, $00, $08, $08, $70
    db   $20, $08, $00, $70, $00, $08, $08, $70
    db   $20, $F8, $F8, $68, $00, $F8, $00, $6A
    db   $00, $F8, $08, $6A, $20, $F8, $10, $68
    db   $20, $08, $00, $6C, $00, $08, $08, $6C
    db   $20, $08, $00, $6C, $00, $08, $08, $6C
    db   $20, $F8, $F8, $62, $00, $F8, $00, $64
    db   $00, $F8, $08, $64, $20, $F8, $10, $62
    db   $20, $08, $00, $66, $00, $08, $08, $66
    db   $20, $08, $00, $66, $00, $08, $08, $66
    db   $20, $F8, $F8, $5A, $00, $F8, $00, $5C
    db   $00, $F8, $08, $5C, $20, $F8, $10, $5A
    db   $20, $08, $F8, $5E, $00, $08, $00, $60
    db   $00, $08, $08, $60, $20, $08, $10, $5E
    db   $20, $F8, $F8, $56, $00, $F8, $00, $58
    db   $00, $F8, $08, $58, $20, $F8, $10, $56
    db   $20, $08, $F8, $56, $40, $08, $00, $58
    db   $40, $08, $08, $58, $60, $08, $10, $56
    db   $60, $3E, $02, $E0, $A1, $EA, $67, $C1
    db   $F0, $E7, $E6, $0F, $F6, $20, $21, $20
    db   $C4, $09, $77, $CD, $87, $08, $20, $03
    db   $C3, $8D, $3B, $1F, $1F, $E6, $0F, $FE
    db   $04, $38, $02, $3E, $04, $17, $17, $17
    db   $17, $17, $E6, $E0, $5F, $50, $21, $95
    db   $71, $19, $0E, $08, $CD, $26, $3D, $3E
    db   $06, $CD, $D0, $3D, $C9, $3E, $02, $E0
    db   $A1, $EA, $67, $C1, $CD, $EB, $74, $CD
    db   $0A, $79, $21, $50, $C2, $09, $34, $7E
    db   $E6, $80, $20, $1E, $21, $10, $C2, $09
    db   $7E, $FE, $70, $38, $15, $36, $70, $3E
    db   $17, $E0, $F4, $21, $50, $C2, $09, $7E
    db   $FE, $04, $DA, $8D, $3B, $2F, $3C, $CB
    db   $2F, $77, $C9, $AF, $EA, $67, $C1, $CD
    db   $EB, $74, $CD, $D5, $3B, $30, $0D, $CD
    db   $8D, $3B, $3E, $0F, $EA, $68, $D3, $CD
    db   $91, $08, $36, $FF, $C9, $CD, $91, $08
    db   $E6, $08, $1E, $E4, $28, $02, $1E, $84
    db   $7B, $EA, $97, $DB, $CD, $91, $08, $20
    db   $2A, $36, $20, $3E, $10, $EA, $68, $D3
    db   $3E, $9F, $CD, $97, $21, $FA, $E9, $DA
    db   $F6, $10, $EA, $E9, $DA, $E0, $F8, $3E
    db   $02, $EA, $4E, $DB, $3E, $FF, $EA, $93
    db   $DB, $AF, $EA, $0F, $DB, $EA, $67, $C1
    db   $CD, $8D, $3B, $F0, $98, $21, $00, $C2
    db   $09, $D6, $04, $77, $F0, $99, $21, $10
    db   $C2, $09, $D6, $13, $77, $CD, $BA, $3D
    db   $F0, $A2, $21, $10, $C3, $09, $77, $3E
    db   $6B, $E0, $9D, $3E, $02, $E0, $A1, $3E
    db   $03, $E0, $9E, $AF, $EA, $37, $C1, $EA
    db   $6A, $C1, $EA, $22, $C1, $EA, $21, $C1
    db   $CD, $48, $74, $CD, $E6, $74, $C9, $CD
    db   $E6, $74, $FA, $9F, $C1, $A7, $20, $03
    db   $CD, $B0, $79, $C9, $00, $04, $72, $00
    db   $E0, $04, $72, $00, $00, $F0, $78, $20
    db   $00, $F8, $78, $40, $00, $10, $78, $60
    db   $00, $18, $78, $00, $F0, $E8, $76, $20
    db   $F0, $F0, $76, $40, $F0, $18, $76, $60
    db   $F0, $20, $76, $00, $E8, $F4, $74, $20
    db   $E8, $14, $74, $00, $F8, $04, $72, $00
    db   $D8, $04, $72, $00, $FC, $E8, $78, $20
    db   $FC, $F0, $78, $40, $FC, $18, $78, $60
    db   $FC, $20, $78, $00, $E8, $E0, $76, $20
    db   $E8, $E8, $76, $40, $E8, $20, $76, $60
    db   $E8, $28, $76, $00, $E0, $F0, $74, $20
    db   $E0, $18, $74, $00, $00, $00, $74, $20
    db   $00, $08, $74, $00, $F0, $04, $72, $00
    db   $D0, $04, $72, $00, $F8, $E0, $78, $20
    db   $F8, $E8, $78, $40, $F8, $20, $78, $60
    db   $F8, $28, $78, $00, $E0, $D8, $76, $20
    db   $E0, $E0, $76, $40, $E0, $28, $76, $60
    db   $E0, $30, $76, $00, $D8, $EC, $74, $20
    db   $D8, $1C, $74, $00, $F8, $FC, $74, $20
    db   $F8, $0C, $74, $00, $00, $F8, $76, $20
    db   $00, $00, $76, $40, $00, $08, $76, $60
    db   $00, $10, $76, $00, $E4, $04, $72, $00
    db   $00, $F8, $78, $20, $00, $00, $78, $40
    db   $00, $08, $78, $60, $00, $10, $78, $00
    db   $F4, $F0, $76, $20, $F4, $F8, $76, $40
    db   $F4, $10, $76, $60, $F4, $18, $76, $00
    db   $EC, $F8, $74, $20, $EC, $10, $74, $00
    db   $F0, $D8, $78, $20, $F0, $E0, $78, $40
    db   $F0, $28, $78, $60, $F0, $30, $78, $00
    db   $CC, $E8, $74, $20, $CC, $20, $74, $00
    db   $48, $73, $78, $73, $B0, $73, $F8, $73
    db   $0C, $0E, $12, $11, $F0, $EC, $D6, $00
    db   $E0, $EC, $F0, $E7, $1F, $1F, $00, $F5
    db   $E6, $03, $5F, $50, $21, $44, $74, $19
    db   $4E, $F1, $17, $E6, $06, $5F, $50, $21
    db   $3C, $74, $19, $2A, $66, $6F, $CD, $26
    db   $3D, $3E, $10, $CD, $D0, $3D, $C9, $7E
    db   $00, $7E, $20, $CD, $91, $08, $C0, $11
    db   $73, $74, $CD, $3B, $3C, $CD, $0A, $79
    db   $21, $50, $C2, $09, $34, $7E, $E6, $80
    db   $20, $37, $21, $10, $C2, $09, $7E, $FE
    db   $70, $38, $2E, $36, $70, $21, $50, $C2
    db   $09, $70, $CD, $D5, $3B, $30, $22, $3E
    db   $01, $E0, $F3, $CD, $B0, $79, $21, $E9
    db   $DA, $FA, $0F, $DB, $FE, $05, $20, $04
    db   $CB, $EE, $18, $02, $CB, $F6, $C6, $01
    db   $27, $EA, $0F, $DB, $3E, $EF, $CD, $97
    db   $21, $C9, $F8, $00, $52, $00, $F8, $08
    db   $52, $20, $08, $00, $54, $00, $08, $08
    db   $54, $20, $F8, $00, $54, $40, $F8, $08
    db   $54, $60, $08, $00, $52, $40, $08, $08
    db   $52, $60, $21, $D6, $74, $18, $03, $21
    db   $C6, $74, $0E, $04, $CD, $26, $3D, $3E
    db   $02, $CD, $D0, $3D, $C9, $98, $50, $8D
    db   $6C, $6E, $6C, $6E, $6C, $6E, $6C, $6E
    db   $6C, $6E, $6C, $6E, $6C, $6E, $98, $51
    db   $8D, $6D, $6F, $6D, $6F, $6D, $6F, $6D
    db   $6F, $6D, $6F, $6D, $6F, $6D, $6F, $00
    db   $C5, $0E, $23, $3E, $22, $EA, $00, $D6
    db   $21, $01, $D6, $11, $F9, $74, $1A, $13
    db   $22, $0D, $20, $FA, $C1, $3E, $89, $EA
    db   $29, $D7, $EA, $39, $D7, $EA, $49, $D7
    db   $EA, $59, $D7, $EA, $69, $D7, $EA, $79
    db   $D7, $EA, $89, $D7, $C9, $FC, $04, $00
    db   $00, $FF, $00, $00, $00, $00, $00, $04
    db   $FC, $00, $00, $00, $FF, $0C, $18, $24
    db   $30, $3C, $48

toc_19_755F:
    ifGte [wRoomTransitionState], 3, .else_19_7567

    ret


.else_19_7567:
    ld   a, [$C125]
    ld   e, a
    ld   d, $00
    ld   hl, $7549
    add  hl, de
    ld   a, [hl]
    ld   [$FFD7], a
    ld   hl, $754D
    add  hl, de
    ld   a, [hl]
    ld   [$FFD8], a
    ld   hl, $7551
    add  hl, de
    ld   a, [hl]
    ld   [$FFD9], a
    ld   hl, $7555
    add  hl, de
    ld   a, [hl]
    ld   [$FFDA], a
    ld   hl, $C200
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    rl   d
    ld   [hl], a
    ld   hl, $C220
    add  hl, bc
    ld   a, [$FFD8]
    rr   d
    adc  [hl]
    ld   [hl], a
    ld   hl, $C210
    add  hl, bc
    ld   a, [$FFD9]
    add  a, [hl]
    rl   d
    ld   [hl], a
    ld   hl, $C230
    add  hl, bc
    ld   a, [$FFDA]
    rr   d
    adc  [hl]
    ld   [hl], a
    ifEq [$FFEB], $7F, .else_19_75CA

    ld   hl, $C440
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   [hl], a
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [$FFD9]
    add  a, [hl]
    ld   [hl], a
    jp   .else_19_766F

.else_19_75CA:
    cp   $87
    jr   nz, .else_19_760A

    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    cp   $02
    jp   z, .else_19_766F

    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    ld   [$FFE6], a
    ld   a, $06
.loop_19_75E1:
    ld   [$FFE8], a
    ld   e, a
    ld   d, b
    ld   hl, $7558
    add  hl, de
    push hl
    ld   a, [$FFE6]
    sub  a, [hl]
    ld   e, a
    ld   d, b
    ld   hl, $D000
    add  hl, de
    ld   a, [$FFD7]
    add  a, [hl]
    ld   [hl], a
    ld   a, [$FFE6]
    pop  hl
    sub  a, [hl]
    ld   e, a
    ld   d, b
    ld   hl, $D100
    add  hl, de
    ld   a, [$FFD9]
    add  a, [hl]
    ld   [hl], a
    ld   a, [$FFE8]
    dec  a
    jr   nz, .loop_19_75E1

.else_19_760A:
    cp   $C1
    jr   nz, .else_19_762E

    ifNotZero [$DB73], .else_19_766F

    ld   e, $10
    ld   hl, $D155
.loop_19_7619:
    ld   a, [$FFD7]
    add  a, [hl]
    ldi  [hl], a
    dec  e
    jr   nz, .loop_19_7619

    ld   e, $10
    ld   hl, $D175
.loop_19_7625:
    ld   a, [$FFD9]
    add  a, [hl]
    ldi  [hl], a
    dec  e
    jr   nz, .loop_19_7625

    jr   .else_19_766F

.else_19_762E:
    cp   $69
    jr   z, .else_19_765F

    cp   $B0
    jr   z, .else_19_765F

    cp   $6D
    jr   nz, .else_19_766F

    ifEq [$DB56], $01, .else_19_7647

    ld   a, [hFrameCounter]
    and  %00000111
    jr   z, .else_19_766F

.else_19_7647:
    ld   e, $06
    ld   hl, $D100
.loop_19_764C:
    ld   a, [$FFD7]
    add  a, [hl]
    ldi  [hl], a
    dec  e
    jr   nz, .loop_19_764C

    ld   e, $06
    ld   hl, $D110
.loop_19_7658:
    ld   a, [$FFD9]
    add  a, [hl]
    ldi  [hl], a
    dec  e
    jr   nz, .loop_19_7658

.else_19_765F:
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   [hl], a
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [$FFD9]
    add  a, [hl]
    ld   [hl], a
.else_19_766F:
    ld   a, [$FFF6]
    ld   hl, $C3E0
    add  hl, bc
    cp   [hl]
    jr   z, .return_19_7696

    ld   hl, $C200
    add  hl, bc
    ld   a, [hl]
    cp   $A0
    jr   nc, .else_19_768C

    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    sub  a, $10
    cp   $78
    jr   c, .return_19_7696

.else_19_768C:
    ld   a, [$FFEB]
    cp   $A7
    ret  z

    ld   hl, $C280
    add  hl, bc
    ld   [hl], b
.return_19_7696:
    ret


toc_19_7697:
    ifNotZero [$C1A5], JumpTable_76B0_19.return_19_76CC

    _ifZero [wDialogState], JumpTable_76B0_19.return_19_76CC

    ld   a, [hFrameCounter]
    and  %00000011
    jumptable
    dw JumpTable_76B0_19 ; 00

    db   $CD, $76, $EA, $76, $F6, $76

JumpTable_76B0_19:
    ld   hl, $DCCF
    ld   de, $DCCF
    ldd  a, [hl]
    push af
    ldd  a, [hl]
    push af
    ld   c, $07
.loop_19_76BC:
    ldd  a, [hl]
    ld   [de], a
    dec  de
    ldd  a, [hl]
    ld   [de], a
    dec  de
    dec  c
    jr   nz, .loop_19_76BC

    pop  hl
    pop  bc
    ld   a, b
    ld   [de], a
    dec  de
    ld   a, h
    ld   [de], a
.return_19_76CC:
    ret


    db   $21, $D0, $DC, $11, $D0, $DC, $2A, $F5
    db   $2A, $F5, $0E, $07, $2A, $12, $13, $2A
    db   $12, $13, $0D, $20, $F7, $E1, $C1, $78
    db   $12, $13, $7C, $12, $C9, $21, $E0, $DC
    db   $1E, $10, $CB, $06, $23, $1D, $20, $FA
    db   $C9, $21, $F0, $DC, $1E, $10, $CB, $0E
    db   $23, $1D, $20, $FA, $C9, $FD, $FC, $16
    db   $00, $FC, $0C, $16, $00, $0E, $FB, $16
    db   $00, $0C, $0D, $16, $00, $FB, $FD, $16
    db   $00, $FA, $0B, $16, $00, $0B, $FC, $16
    db   $00, $09, $0C, $16, $00, $FD, $FE, $16
    db   $00, $FC, $0A, $16, $00, $0B, $FD, $16
    db   $00, $08, $0A, $16, $00, $FF, $00, $16
    db   $00, $00, $08, $16, $00, $0A, $FF, $16
    db   $00, $08, $09, $16, $00, $02, $FC, $28
    db   $00, $FB, $04, $28, $60, $05, $06, $28
    db   $00, $01, $0A, $28, $20, $01, $FF, $28
    db   $00, $F9, $04, $28, $60, $08, $06, $28
    db   $00, $02, $07, $28, $20, $00, $00, $28
    db   $20, $F8, $02, $28, $60, $04, $04, $28
    db   $20, $0A, $07, $28, $20, $FE, $01, $28
    db   $20, $04, $01, $28, $60, $04, $05, $28
    db   $20, $0C, $07, $28, $20, $FD, $00, $28
    db   $20, $04, $FE, $28, $60, $08, $08, $28
    db   $20, $0E, $09, $28, $20, $FC, $FF, $28
    db   $00, $04, $FA, $28, $40, $08, $09, $28
    db   $20, $0F, $0A, $28, $00, $FB, $FE, $28
    db   $00, $03, $F9, $28, $40, $08, $0C, $28
    db   $00, $11, $0B, $28, $00, $FA, $FD, $28
    db   $00, $01, $F7, $28, $40, $09, $0D, $28
    db   $00, $0F, $0C, $28, $00, $F0, $F1, $FE
    db   $FF, $28, $18, $FE, $01, $28, $14, $F0
    db   $D7, $E6, $0C, $CB, $27, $CB, $27, $5F
    db   $50, $21, $02, $77, $19, $0E, $04, $CD
    db   $26, $3D, $C9, $3C, $20, $07, $E0, $F1
    db   $F0, $E7, $A9, $1F, $D8, $F0, $D7, $E6
    db   $1C, $EE, $1C, $CB, $27, $CB, $27, $5F
    db   $50, $21, $42, $77, $19, $0E, $04, $CD
    db   $26, $3D, $C9

toc_19_7800:
    call toc_01_3BD5
    jr   nc, .else_19_782C

    call toc_01_094A
    ifNotZero [$C1A6], .else_19_781F

    ld   e, a
    ld   d, b
    ld   hl, $C39F
    add  hl, de
    ld   a, [hl]
    cp   $03
    jr   nz, .else_19_781F

    ld   hl, $C28F
    add  hl, de
    ld   [hl], $00
.else_19_781F:
    ld   a, [$C14A]
    ld   e, a
    call toc_01_093B.toc_01_0942
    call toc_01_1495
    ld   a, e
    scf
    ret


.else_19_782C:
    and  a
    ret


    db   $06, $04, $02, $00, $21, $80, $C3, $09
    db   $5E, $50, $21, $2E, $78, $19, $E5, $21
    db   $D0, $C3, $09, $34, $7E, $1F, $1F, $1F
    db   $1F, $E1, $E6, $01, $B6, $C3, $87, $3B

toc_19_784E:
    ld   e, b
    ld   a, [hLinkPositionY]
    ld   hl, $FFEF
    sub  a, [hl]
    add  a, 20
    cp   40
.toc_19_7859:
    jr   nc, .else_19_7899

    ld   a, [hLinkPositionX]
    ld   hl, $FFEE
    sub  a, [hl]
    add  a, 16
    cp   32
    jr   nc, .else_19_7899

    inc  e
    push de
    call toc_19_7989
    ld   a, [hLinkDirection]
    xor  DIRECTION_LEFT
    cp   e
    pop  de
    jr   nz, .else_19_7899

    ld   hl, $C1AD
    ld   [hl], $01
    ld   a, [wDialogState]
    ld   hl, $C14F
    or   [hl]
    ld   hl, $C146
    or   [hl]
    ld   hl, $C134
    or   [hl]
    jr   nz, .else_19_7899

    ifEq [wWYStash], 128, .else_19_7899

    ld   a, [$FFCC]
    and  %00010000
    jr   z, .else_19_7899

    scf
    ret


.else_19_7899:
    and  a
    ret


toc_19_789B:
    ifEq [$FFEA], $05, .else_19_78BB

    ifNe [wGameMode], GAMEMODE_WORLD_MAP, .else_19_78BB

    ld   hl, $C1A8
    ld   a, [wDialogState]
    or   [hl]
    ld   hl, $C14F
    or   [hl]
    jr   nz, .else_19_78BB

    ifNotZero [wRoomTransitionState], .return_19_78BC

.else_19_78BB:
    pop  af
.return_19_78BC:
    ret


    db   $21, $10, $C4, $09, $7E, $A7, $28, $41
    db   $3D, $77, $CD, $B8, $3E, $21, $40, $C2
    db   $09, $7E, $F5, $21, $50, $C2, $09, $7E
    db   $F5, $21, $F0, $C3, $09, $7E, $21, $40
    db   $C2, $09, $77, $21, $00, $C4, $09, $7E
    db   $21, $50, $C2, $09, $77, $CD, $07, $79
    db   $21, $30, $C4, $09, $7E, $E6, $20, $20
    db   $03, $CD, $9E, $3B, $21, $50, $C2, $09
    db   $F1, $77, $21, $40, $C2, $09, $F1, $77
    db   $F1, $C9, $CD, $14, $79

toc_19_790A:
    push bc
    ld   a, c
    add  a, $10
    ld   c, a
    call toc_19_7914
    pop  bc
    ret


toc_19_7914:
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_19_793F

    push af
    swap a
    and  %11110000
    ld   hl, $C260
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, $C200
    add  hl, bc
    pop  af
    ld   e, $00
    bit  7, a
    jr   z, .else_19_7936

    ld   e, $F0
.else_19_7936:
    swap a
    and  %00001111
    or   e
    rr   d
    adc  [hl]
    ld   [hl], a
.return_19_793F:
    ret


    db   $21, $20, $C3, $09, $7E, $A7, $28, $F7
    db   $F5, $CB, $37, $E6, $F0, $21, $30, $C3
    db   $09, $86, $77, $CB, $12, $21, $10, $C3
    db   $18, $D2

toc_19_795A:
    ld   e, $00
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, bc
    sub  a, [hl]
    bit  7, a
    jr   z, .else_19_7968

    inc  e
.else_19_7968:
    ld   d, a
    ret


toc_19_796A:
    ld   e, $02
    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, bc
    sub  a, [hl]
    bit  7, a
    jr   nz, .else_19_7978

    inc  e
.else_19_7978:
    ld   d, a
    ret


    db   $1E, $02, $F0, $99, $21, $EC, $FF, $96
    db   $CB, $7F, $20, $01, $1C, $57, $C9

toc_19_7989:
    call toc_19_795A
    ld   a, e
    ld   [$FFD7], a
    ld   a, d
    bit  7, a
    jr   z, .else_19_7996

    cpl
    inc  a
.else_19_7996:
    push af
    call toc_19_796A
    ld   a, e
    ld   [$FFD8], a
    ld   a, d
    bit  7, a
    jr   z, .else_19_79A4

    cpl
    inc  a
.else_19_79A4:
    pop  de
    cp   d
    jr   nc, .else_19_79AC

    ld   a, [$FFD7]
    jr   .toc_19_79AE

.else_19_79AC:
    ld   a, [$FFD8]
.toc_19_79AE:
    ld   e, a
    ret


toc_19_79B0:
    ld   hl, $C280
    add  hl, bc
    ld   [hl], b
    ret


    db   $21, $C0, $C2, $09, $7E, $C7, $C2, $79
    db   $D3, $79, $E4, $79, $CD, $91, $08, $36
    db   $A0, $21, $20, $C4, $09, $36, $FF, $21
    db   $C0, $C2, $09, $34, $C9, $CD, $91, $08
    db   $20, $0B, $36, $C0, $21, $20, $C4, $09
    db   $36, $FF, $CD, $CD, $79, $C9, $CD, $91
    db   $08, $20, $09, $CD, $D7, $08, $CD, $BD
    db   $27, $C3, $7A, $3F, $CD, $F6, $79, $C9
    db   $E6, $07, $20, $1D, $CD, $ED, $27, $E6
    db   $1F, $D6, $10, $5F, $21, $EE, $FF, $86
    db   $77, $CD, $ED, $27, $E6, $1F, $D6, $14
    db   $5F, $21, $EC, $FF, $86, $77, $CD, $18
    db   $7A, $C9, $CD, $A1, $78, $F0, $EE, $E0
    db   $D7, $F0, $EC, $E0, $D8, $3E, $02, $CD
    db   $53, $09, $3E, $13, $E0, $F4, $C9, $3E
    db   $36, $CD, $01, $3C, $F0, $D7, $21, $00
    db   $C2, $19, $77, $F0, $D8, $21, $10, $C2
    db   $19, $77, $F0, $F9, $A7, $28, $08, $21
    db   $50, $C2, $09, $36, $F0, $18, $0C, $21
    db   $20, $C3, $19, $36, $10, $21, $10, $C3
    db   $19, $36, $08, $CD, $B0, $79, $21, $F4
    db   $FF, $36, $1A, $C9

toc_19_7A62:
    ld   hl, $D800
    ld   a, [$FFF6]
    ld   e, a
    ld   a, [$DBA5]
    ld   d, a
    ifGte [$FFF7], $1A, .else_19_7A77

    cp   $06
    jr   c, .else_19_7A77

    inc  d
.else_19_7A77:
    add  hl, de
    ld   a, [hl]
    or   %00100000
    ld   [hl], a
    ld   [$FFF8], a
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
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
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
