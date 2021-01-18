SECTION "ROM Bank 02", ROMX[$4000], BANK[$02]

    db   $06, $06, $06, $06, $06, $06, $06, $06
    db   $06, $06, $06, $06, $06, $06, $06, $06
    db   $06, $06, $06, $06, $06, $06, $06, $06
    db   $06, $06, $06, $06, $06, $06, $06, $06
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $09, $09, $09, $09, $05, $05, $05, $05
    db   $05, $05, $05, $05, $08, $08, $08, $08
    db   $09, $09, $09, $09, $05, $05, $05, $05
    db   $05, $05, $05, $05, $08, $08, $08, $08
    db   $09, $09, $09, $09, $05, $05, $05, $05
    db   $05, $05, $05, $05, $08, $08, $08, $08
    db   $09, $09, $09, $09, $05, $05, $05, $05
    db   $05, $05, $05, $05, $08, $08, $08, $08
    db   $09, $04, $04, $04, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $04, $04, $04, $04, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $04, $04, $04, $04, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $04, $04, $04, $04, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05, $05, $0B, $0B, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05, $05, $0B, $0B, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05, $05, $05, $05, $05, $05
    db   $14, $15, $16, $17, $4B, $58, $5B, $5A
    db   $12, $26, $26, $26, $26, $26, $07, $02
    db   $0A, $26, $0A, $53, $13, $3E, $1F, $00
    db   $00, $00, $00, $00, $00, $0A, $48, $26
    db   $00, $00, $01, $00, $01, $00, $00, $01
    db   $00, $00, $01, $01, $01, $00, $01, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $01, $00, $01, $00

toc_02_4146:
    ifNot [$FFBC], .else_02_414F

    clear [$FFBC]
    ret


toc_02_4146.else_02_414F:
    ld   d, $1D
    ld   a, [$DB4E]
    and  a
    jp   z, .else_02_418C

    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    ld   hl, $4000
    add  hl, de
    ld   d, [hl]
    ld   a, d
    clear [hNextMusicTrackToFadeInto]
    ifNot [$DBA5], .else_02_418C

    ld   d, $18
    ld   a, [$D46C]
    and  a
    jr   nz, .else_02_4190

    ld   a, [$FFF7]
    ld   e, a
    ld   d, $00
    ld   hl, $4100
    add  hl, de
    ld   d, [hl]
    ifNot [$FFF9], .else_02_4190

    ld   a, e
    cp   $0A
    jr   nc, .else_02_4190

    ld   a, $21
    jr   .toc_02_4191

toc_02_4146.else_02_418C:
    clear [$D46C]
toc_02_4146.else_02_4190:
    ld   a, d
toc_02_4146.toc_02_4191:
    ld   e, a
    ld   d, $00
    ld   [hDefaultMusicTrack], a
    call toc_01_27A8
    ld   a, e
    cp   $25
    jr   nc, .else_02_41A6

    ld   hl, $4120
    add  hl, de
    ld   a, [hl]
    and  a
    jr   nz, .return_02_41B9

toc_02_4146.else_02_41A6:
    ifNot [$D47C], .return_02_41B9

    assign [$D368], $49
    ld   [$FFBD], a
    ld   [hNextDefaultMusicTrack], a
    clear [$C1CF]
toc_02_4146.return_02_41B9:
    ret


toc_02_41BA:
    push bc
    ld   a, $07
    call toc_01_3C01
    jr   c, .else_02_41E4

    ld   hl, $C280
    add  hl, de
    dec  [hl]
    ld   a, [hSwordIntersectedAreaX]
    and  %11110000
    add  a, $08
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [hSwordIntersectedAreaY]
    and  %11110000
    add  a, $10
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C3B0
    add  hl, de
    ld   a, [$FFDF]
    ld   [hl], a
toc_02_41BA.else_02_41E4:
    pop  bc
    ret


toc_02_41E6:
    ld   hl, $C146
    ld   a, [$C166]
    or   [hl]
    jr   nz, toc_02_4231

    ld   [$C5A4], a
    ld   [$C5A5], a
    call toc_01_094A
    ld   a, [$DB49]
    and  %00000111
    jr   z, toc_02_4228

    ifEq [$DB4A], $01, toc_02_4214

    cp   $02
    jr   z, toc_02_421E

    assign [$C166], $DC
    assign [$FFF3], $09
    ret


toc_02_4214:
    assign [$C166], $D0
    assign [$FFF3], $0B
    ret


toc_02_421E:
    assign [$C166], $BB
    assign [$FFF3], $0A
    ret


toc_02_4228:
    assign [$C166], $D0
    assign [$FFF3], $15
toc_02_4231:
    ret


    db   $C9, $30, $D0, $00, $00, $00, $00, $D0
    db   $30

toc_02_423B:
    ld   a, [$C146]
    and  a
    jr   nz, .return_02_426D

    ld   a, $03
    call toc_01_10EB
    jr   c, .return_02_426D

    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $2A
    ld   hl, $C3B0
    add  hl, de
    xor  a
    ld   [hl], a
    ld   a, [hLinkDirection]
    ld   c, a
    ld   b, $00
    ld   hl, $4233
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $4237
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C250
    add  hl, de
    ld   [hl], a
toc_02_423B.return_02_426D:
    ret


toc_02_426E:
    ifNot [$C14C], .else_02_4278

    dec  a
    ld   [$C14C], a
toc_02_426E.else_02_4278:
    ifNot [$C1C4], .else_02_4282

    dec  a
    ld   [$C1C4], a
toc_02_426E.else_02_4282:
    ifNot [$C1C0], .else_02_428C

    dec  a
    ld   [$C1C0], a
toc_02_426E.else_02_428C:
    call toc_02_4353
    ifNot [$C16E], .else_02_4299

    dec  a
    ld   [$C16E], a
toc_02_426E.else_02_4299:
    ifNe [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING, .else_02_42AE

    clear [hLinkInteractiveMotionBlocked]
    ld   [hLinkPositionXIncrement], a
    ld   [hLinkPositionYIncrement], a
    ld   [hLinkPositionZLow], a
    call toc_02_49C5
    jp   toc_02_77FA

toc_02_426E.else_02_42AE:
    call toc_01_19EF
    clear [hLinkInteractiveMotionBlocked]
    call toc_01_1E73
    call toc_01_0D68
    call toc_02_4497
    call toc_02_4331
    call toc_02_4738
    call toc_02_4AF8
    call toc_01_149B
    call toc_02_431F
    call toc_02_49C5
    ld   a, [$C124]
    and  a
    jr   nz, .return_02_42FC

    copyFromTo [$C137], [$C16A]
    cp   $05
    jr   nz, .else_02_42FD

    ld   a, [$C14A]
    and  a
    jr   nz, .else_02_431A

    clear [$C137]
    ifEq [$C122], $28, .return_02_42FC

    inc  a
    ld   [$C122], a
    cp   $28
    jr   nz, .return_02_42FC

    assign [$FFF2], $04
toc_02_426E.return_02_42FC:
    ret


toc_02_426E.else_02_42FD:
    ifEq [$C1AD], $01, .else_02_431A

    ifNe [$C122], $28, .else_02_431A

    ld   a, [$C16E]
    and  a
    jr   nz, .return_02_431E

    assign [$C121], $20
    assign [$FFF4], $03
toc_02_426E.else_02_431A:
    clear [$C122]
toc_02_426E.return_02_431E:
    ret


toc_02_431F:
    ifLt [$C15C], $02, .return_02_432C

    ld   [hLinkAnimationState], a
    assign [hLinkInteractiveMotionBlocked], $01
toc_02_431F.return_02_432C:
    ret


    db   $11, $10, $0F, $0E

toc_02_4331:
    ld   a, [$C19B]
    and  %01111111
    jr   z, .else_02_434E

    ld   a, [$C19B]
    dec  a
    ld   [$C19B], a
    and  %01111111
    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, $00
    ld   hl, $432D
    add  hl, de
    ld   a, [hl]
    ld   [hLinkAnimationState], a
    ret


toc_02_4331.else_02_434E:
    clear [$C19B]
    ret


toc_02_4353:
    ifNot [$FFF9], .else_02_4362

    ld   a, [$C17B]
    and  a
    jr   nz, .else_02_4362

    call toc_02_6BEF
    ret


toc_02_4353.else_02_4362:
    copyFromTo [$DBAE], [$D46B]
    call toc_02_446A
    ld   a, [hLinkPositionZHigh]
    and  a
    jr   nz, .else_02_4376

    ld   a, [hLinkInteractiveMotionBlocked]
    and  a
    jp   nz, .else_02_445C

toc_02_4353.else_02_4376:
    ifNot [$C14A], .else_02_43A9

    ld   a, [$FFCC]
    and  %00001111
    jr   z, .else_02_438E

    ld   e, a
    ld   d, $00
    ld   hl, $48B3
    add  hl, de
    ld   a, [hLinkDirection]
    cp   [hl]
    jr   nz, .else_02_439B

toc_02_4353.else_02_438E:
    ld   a, [$C120]
    add  a, $02
    ld   [$C120], a
    call toc_01_145D
    jr   .else_02_440A

toc_02_4353.else_02_439B:
    ld   [$C19A], a
    ld   a, [$C199]
    add  a, $0C
    ld   [$C199], a
    call toc_01_093B
toc_02_4353.else_02_43A9:
    ld   a, [$C146]
    and  a
    jr   nz, .else_02_440A

    ld   e, $00
    ifNe [$D47C], $01, .else_02_43BA

    ld   e, $10
toc_02_4353.else_02_43BA:
    ld   a, [hPressedButtonsMask]
    and  %00001111
    or   e
    ld   e, a
    ld   d, $00
    ld   hl, $4873
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    ld   hl, $4893
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionYIncrement], a
    ifNot [$C17B], .else_02_43E0

    ld   hl, hLinkPositionXIncrement
    sla  [hl]
    ld   hl, hLinkPositionYIncrement
    sla  [hl]
toc_02_4353.else_02_43E0:
    ld   a, e
    and  %00001111
    ld   e, a
    jr   z, .else_02_43FF

    incAddr $C120
    ld   hl, $48B3
    add  hl, de
    ld   a, [hl]
    cp   $0F
    jr   z, .else_02_440A

    ld   e, a
    ld   a, [$C16E]
    and  a
    ld   a, e
    jr   nz, .else_02_43FD

    ld   [hLinkDirection], a
toc_02_4353.else_02_43FD:
    jr   .else_02_440A

toc_02_4353.else_02_43FF:
    ld   a, [$C14B]
    and  a
    jr   nz, .else_02_440A

    assign [$C120], $07
toc_02_4353.else_02_440A:
    ld   e, $03
    ld   a, [$C117]
    and  a
    jr   nz, .else_02_4448

    ld   e, $01
    ifNot [$C15C], .else_02_4427

    ifNe [$C5A8], $D5, .else_02_4427

    ld   a, [$C146]
    and  a
    jr   nz, .else_02_4448

toc_02_4353.else_02_4427:
    ld   a, [hLinkWalksSlow]
    and  a
    jr   nz, .else_02_4448

    ld   hl, $C11F
    ld   a, [hl]
    and  a
    jr   z, .else_02_4454

    cp   $07
    jr   nz, .else_02_444F

    ld   a, [$C17B]
    and  a
    jr   nz, .else_02_4454

    ld   e, $01
    ifLt [$C1BB], $18, .else_02_4448

    ld   e, $07
toc_02_4353.else_02_4448:
    ld   a, [hFrameCounter]
    and  e
    jr   nz, .else_02_445C

    jr   .else_02_4454

toc_02_4353.else_02_444F:
    ld   a, [hFrameCounter]
    and  [hl]
    jr   z, .return_02_4469

toc_02_4353.else_02_4454:
    ld   a, [$C14F]
    and  a
    ret  nz

    call toc_01_20D6
toc_02_4353.else_02_445C:
    copyFromTo [$C11F], [$C130]
    clear [$C11F]
    call toc_02_6FB1
toc_02_4353.return_02_4469:
    ret


toc_02_446A:
    ifNot [$C13E], .return_02_4490

    dec  a
    ld   [$C13E], a
    call toc_01_20D6
    call toc_02_6FB1
    ifNot [$C133], .else_02_448C

    and  %00000011
    jr   z, .else_02_4489

    clear [hLinkPositionYIncrement]
    jr   .else_02_448C

toc_02_446A.else_02_4489:
    clear [hLinkPositionXIncrement]
toc_02_446A.else_02_448C:
    pop  af
    call toc_01_149B
toc_02_446A.return_02_4490:
    ret


    db   $00, $F0, $10, $00, $FF, $01

toc_02_4497:
    ld   a, [$C146]
    and  a
    jp   z, .return_02_4556

    ld   a, [$FFF9]
    and  a
    jp   nz, .return_02_4556

    call toc_01_210F
    ld   a, [hLinkPositionZLow]
    sub  a, $02
    ld   [hLinkPositionZLow], a
    assign [$C120], $FF
    ld   a, [$C10A]
    ld   hl, $C14A
    or   [hl]
    jr   nz, .else_02_450D

    ld   a, [$D475]
    and  a
    jr   nz, .else_02_44C8

    ifNe [$C1AD], $80, .else_02_44CD

toc_02_4497.else_02_44C8:
    call toc_01_1495
    jr   .else_02_450D

toc_02_4497.else_02_44CD:
    ld   a, [hPressedButtonsMask]
    and  %00000011
    jr   z, .else_02_44EC

    ld   e, a
    ld   d, $00
    ld   hl, $6BE9
    add  hl, de
    ld   a, [hLinkPositionXIncrement]
    sub  a, [hl]
    jr   z, .else_02_44EC

    ld   e, $01
    bit  7, a
    jr   nz, .else_02_44E7

    ld   e, $FF
toc_02_4497.else_02_44E7:
    ld   a, [hLinkPositionXIncrement]
    add  a, e
    ld   [hLinkPositionXIncrement], a
toc_02_4497.else_02_44EC:
    ld   a, [hPressedButtonsMask]
    rra
    rra
    and  %00000011
    jr   z, .else_02_450D

    ld   e, a
    ld   d, $00
    ld   hl, $4491
    add  hl, de
    ld   a, [hLinkPositionYIncrement]
    sub  a, [hl]
    jr   z, .else_02_450D

    ld   e, $01
    bit  7, a
    jr   nz, .else_02_4508

    ld   e, $FF
toc_02_4497.else_02_4508:
    ld   a, [hLinkPositionYIncrement]
    add  a, e
    ld   [hLinkPositionYIncrement], a
toc_02_4497.else_02_450D:
    ifNot [hLinkPositionZHigh], .else_02_4516

    and  %10000000
    jr   z, .return_02_4556

toc_02_4497.else_02_4516:
    call toc_01_093B.toc_01_0942
    ld   [hLinkPositionZHigh], a
    ld   [$C149], a
    ld   [hLinkPositionZLow], a
    ld   [$C146], a
    ld   [$C152], a
    ld   [$C153], a
    ld   [$C10A], a
    ifGte [hLinkPositionY], 136, .return_02_4556

    call toc_02_77FA.toc_02_787D
    ifEq [$FFB8], $61, .return_02_4556

    ifEq [$C181], $05, .else_02_4557

    cp   $07
    jr   z, .return_02_4556

    cp   $0B
    jr   z, .return_02_4556

    cp   $50
    jr   z, .return_02_4556

    cp   $51
    jr   z, .return_02_4556

    assign [$FFF4], $07
toc_02_4497.return_02_4556:
    ret


toc_02_4497.else_02_4557:
    copyFromTo [hLinkPositionY], [$FFD8]
    copyFromTo [hLinkPositionX], [$FFD7]
    assign [$FFF2], $0E
    ld   a, $0C
    call toc_01_0953
    ret


    db   $00, $00, $08, $06, $00, $06, $00, $00
    db   $08, $0A, $00, $0A, $00, $00, $08, $10
    db   $00, $10, $00, $00, $08, $08, $00, $08
    db   $00, $00, $05, $0A, $00, $0A, $00, $00
    db   $05, $0A, $00, $0A, $00, $00, $05, $08
    db   $00, $08, $00, $00, $05, $08, $00, $08
    db   $00, $00, $08, $08, $00, $08, $00, $00
    db   $08, $08, $00, $08, $00, $00, $08, $08
    db   $00, $08, $00, $00, $08, $08, $00, $08
    db   $00, $00, $05, $08, $00, $08, $00, $00
    db   $05, $08, $00, $08, $00, $00, $05, $08
    db   $00, $08, $00, $00, $05, $08, $00, $08
    db   $00, $06, $07, $00, $01, $00, $00, $06
    db   $05, $04, $03, $04, $00, $00, $07, $06
    db   $05, $06, $00, $04, $03, $02, $01, $02
    db   $00, $18, $19, $11, $11, $FF, $00, $16
    db   $17, $10, $10, $FF, $00, $14, $15, $0F
    db   $0F, $FF, $00, $12, $13, $0E, $0E, $FF
    db   $00, $00, $0D, $13, $10, $0B, $00, $F8
    db   $F3, $ED, $F0, $F5, $00, $10, $0D, $F8
    db   $F5, $F8, $00, $F0, $F3, $00, $0C, $00
    db   $00, $F0, $F3, $00, $0C, $00, $00, $F0
    db   $F3, $00, $0C, $00, $00, $F8, $F3, $F0
    db   $F3, $F5, $00, $00, $0D, $10, $0D, $0D
    db   $00, $00, $00, $03, $03, $00, $00, $00
    db   $00, $FD, $FD, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $FD
    db   $FD, $00, $00, $00, $00, $03, $03, $00
    db   $03, $03, $08, $01, $01, $01, $01, $61
    db   $62, $63, $00, $5E, $5F, $60, $00, $67
    db   $68, $69, $00, $64, $65, $66, $00, $00
    db   $03, $01, $02, $03, $02, $03, $02, $03
    db   $02, $03, $04, $03, $04, $03, $02, $03
    db   $04, $03, $04, $03, $02, $03, $04, $03
    db   $04, $03, $04, $03, $04, $03, $04, $03
    db   $02, $03, $04, $00, $02, $02, $01, $01
    db   $03, $03, $00, $01, $02, $02, $00, $00
    db   $03, $03, $01, $02, $00, $00, $03, $03
    db   $01, $01, $02, $03, $01, $01, $02, $02
    db   $00, $00, $03

toc_02_46B4:
    dec  a
    ld   [$C121], a
    ld   hl, hLinkInteractiveMotionBlocked
    ld   [hl], $01
    srl  a
    srl  a
    ld   e, a
    ld   d, $00
    ld   a, [hLinkDirection]
    sla  a
    sla  a
    sla  a
    add  a, e
    ld   e, a
    ld   hl, $4674
    add  hl, de
    ld   a, [hl]
    ld   [$C137], a
    ld   hl, $4694
    add  hl, de
    ld   a, [hLinkDirection]
    push af
    ld   a, [hl]
    ld   [hLinkDirection], a
    call toc_02_4738.toc_02_47D4
    pop  af
    ld   [hLinkDirection], a
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, toc_02_46F0

    ld   hl, $C121
    dec  [hl]
toc_02_46F0:
    ld   a, [$C121]
    and  a
    jp   z, toc_02_4738.toc_02_485E

    rla
    jp   c, toc_02_4738.toc_02_485E

    ld   a, [hLinkPositionX]
    add  a, $08
    ld   [$C140], a
    assign [$C141], $18
    ld   [$C143], a
    ld   a, [$C145]
    add  a, $08
    ld   [$C142], a
    ld   [$C5B0], a
    ret


toc_02_4716:
    dec  a
    ld   [$C16D], a
    jp   z, toc_02_4738.toc_02_485E

    ld   hl, $C16E
    ld   [hl], $04
    ld   a, [$C14A]
    and  a
    jr   nz, toc_02_472C

    assign [hLinkInteractiveMotionBlocked], $01
toc_02_472C:
    assign [$C137], $03
    jp   toc_02_4738.toc_02_47D4

toc_02_4734:
    call toc_02_4738.toc_02_47D4
toc_02_4737:
    ret


toc_02_4738:
    ifNot [$D475], .else_02_474F

    ld   a, [hFrameCounter]
    rra
    rra
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $4670
    add  hl, de
    ld   a, [hl]
    ld   [hLinkDirection], a
    ret


toc_02_4738.else_02_474F:
    ifNe [$C146], $01, .else_02_478C

    ld   a, [$C3CF]
    ld   hl, $C137
    or   [hl]
    jr   nz, .else_02_478C

    ld   a, [hLinkDirection]
    rla
    rla
    and  %00001100
    ld   c, a
    ld   b, $00
    ifGte [$C152], $03, .else_02_478C

    ld   e, a
    ld   d, $00
    ld   hl, $4660
    add  hl, de
    add  hl, bc
    ld   a, [hl]
    ld   [hLinkAnimationState], a
    ld   a, [$C153]
    inc  a
    ld   [$C153], a
    and  %00000111
    jr   nz, .else_02_478C

    ld   a, [$C152]
    inc  a
    ld   [$C152], a
toc_02_4738.else_02_478C:
    ld   a, [$C121]
    and  a
    jp   nz, toc_02_46B4

    ld   a, [$C16D]
    and  a
    jp   nz, toc_02_4716

    ifNot [$C137], toc_02_4737

    ld   hl, $C16E
    ld   [hl], $04
    ifGte [$C137], $05, toc_02_4734

    ld   a, [$C14A]
    and  a
    jr   nz, .else_02_47B6

    assign [hLinkInteractiveMotionBlocked], $01
toc_02_4738.else_02_47B6:
    ld   a, [$C138]
    and  a
    jr   nz, .else_02_47D0

    ld   a, [$C137]
    inc  a
    ld   [$C137], a
    cp   $04
    jp   z, .toc_02_485E

    ld   c, a
    ld   b, $00
    ld   hl, $4658
    add  hl, bc
    ld   a, [hl]
toc_02_4738.else_02_47D0:
    dec  a
    ld   [$C138], a
toc_02_4738.toc_02_47D4:
    ld   hl, $C137
    ld   a, [hLinkDirection]
    ld   e, a
    sla  a
    sla  a
    add  a, e
    add  a, e
    add  a, [hl]
    ld   c, a
    ld   b, $00
    ld   hl, $45C9
    add  hl, bc
    ld   a, [hl]
    ld   [$C136], a
    ld   hl, $45E1
    add  hl, bc
    ld   a, [hl]
    cp   $FF
    jr   z, .else_02_47F7

    ld   [hLinkAnimationState], a
toc_02_4738.else_02_47F7:
    ld   hl, $45F9
    add  hl, bc
    ld   a, [hl]
    ld   [$C13A], a
    ld   hl, $4611
    add  hl, bc
    ld   a, [hl]
    ld   [$C139], a
    ld   hl, $4629
    add  hl, bc
    ld   a, [hl]
    ld   [$C13C], a
    ld   hl, $4641
    add  hl, bc
    ld   a, [hl]
    ld   [$C13B], a
    ld   hl, $4569
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_02_485A

    ifNot [$C15B], .else_02_482B

    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .else_02_485A

toc_02_4738.else_02_482B:
    ld   a, [$C13A]
    add  a, [hl]
    ld   hl, hLinkPositionX
    add  a, [hl]
    ld   [$C140], a
    ld   hl, $4581
    add  hl, bc
    ld   a, [hl]
    ld   [$C141], a
    ld   a, [$C139]
    ld   hl, $4599
    add  hl, bc
    add  a, [hl]
    ld   hl, $C145
    add  a, [hl]
    ld   [$C142], a
    ld   hl, $45B1
    add  hl, bc
    ld   a, [hl]
    ld   [$C143], a
    assign [$C5B0], $01
toc_02_4738.else_02_485A:
    call toc_01_12AE
    ret


toc_02_4738.toc_02_485E:
    clear [$C1AC]
    ld   a, [$C14A]
    and  a
    jr   nz, .return_02_4872

    clear [$C137]
    ld   [$C16A], a
    ld   [$C121], a
toc_02_4738.return_02_4872:
    ret


    db   $00, $10, $F0, $00, $00, $0C, $F4, $00
    db   $00, $0C, $F4, $00, $00, $00, $00, $00
    db   $00, $14, $EC, $00, $00, $0F, $F1, $00
    db   $00, $0F, $F1, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $F0, $F4, $F4, $00
    db   $10, $0C, $0C, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $EC, $F1, $F1, $00
    db   $14, $0F, $0F, $00, $00, $00, $00, $00
    db   $0F, $00, $01, $0F, $02, $0F, $0F, $0F
    db   $03, $0F, $0F, $0A, $0B, $06, $07, $04
    db   $05, $00, $01, $2C, $2D, $06, $07, $34
    db   $35, $22, $23, $2A, $2B, $28, $29, $30
    db   $31, $24, $25, $2E, $2F, $06, $07, $34
    db   $35, $22, $23, $2A, $2B, $28, $29, $32
    db   $33, $26, $27, $20, $21, $1E, $1F, $1C
    db   $1D, $1A, $1B, $3E, $3F, $40, $41, $42
    db   $43, $44, $45, $46, $47, $48, $49, $4A
    db   $4B, $4C, $4D, $4E, $4F, $4E, $4F, $4E
    db   $4F, $4E, $4F, $5B, $5C, $58, $59, $5B
    db   $5C, $58, $59, $3E, $02, $EA, $C4, $C1
    db   $F0, $9C, $A7, $20, $40, $F0, $99, $C6
    db   $10, $E0, $99, $E0, $A0, $F0, $A2, $C6
    db   $10, $E0, $A2, $3E, $FF, $E0, $9B, $AF
    db   $E0, $9A, $F0, $99, $C6, $08, $E0, $99
    db   $E0, $A0, $F0, $A2, $C6, $08, $E0, $A2
    db   $CD, $80, $71, $F0, $AF, $FE, $E1, $28
    db   $E2, $FE, $61, $28, $06, $FA, $33, $C1
    db   $A7, $20, $D8, $3E, $01, $E0, $9C, $F0
    db   $99, $D6, $03, $E0, $99, $CD, $A4, $44
    db   $F0, $A2, $A7, $20, $04, $AF, $EA, $1C
    db   $C1, $3E, $01, $EA, $46, $C1, $CD, $68
    db   $0D, $CD, $38, $47, $FA, $37, $C1, $EA
    db   $6A, $C1, $CD, $9B, $14, $C9, $01, $00
    db   $01, $00, $00, $01, $00, $01, $01, $01
    db   $00, $00, $00, $00, $01, $01, $01, $00
    db   $01, $00, $00, $01, $00, $01, $01, $01
    db   $00, $00, $00, $00, $01, $01, $00, $01
    db   $01, $01, $01, $00, $01, $01, $01, $01
    db   $00, $01, $01, $01, $01, $00, $01, $00
    db   $00, $00, $00, $01, $00, $00, $00, $00
    db   $01, $00, $00, $00, $00, $01, $00, $01
    db   $01, $00, $01, $00, $00, $01, $08, $F8
    db   $06, $01

toc_02_49C5:
    ld   a, [$C166]
    and  a
    ret  z

    ld   hl, hLinkInteractiveMotionBlocked
    ld   [hl], $02
    cp   $FF
    jr   nz, .else_02_4A2B

    ld   a, [$D210]
    add  a, $01
    ld   [$D210], a
    ld   a, [$D211]
    adc  $00
    ld   [$D211], a
    cp   $08
    jr   nz, .else_02_4A02

    ifNe [$D210], $D0, .else_02_4A02

    clear [$C166]
    ld   [$C167], a
    assign [$C5A3], $03
    ld   a, [$D465]
    cp   $47
    ret  z

    jr   .toc_02_4A1B

toc_02_49C5.else_02_4A02:
    ifEq [$D465], $47, .else_02_4A29

    ld   a, [$FFCC]
    and  %00110000
    jr   z, .else_02_4A29

    clear [$C166]
    ld   [$C167], a
    assign [$C5A3], $03
toc_02_49C5.toc_02_4A1B:
    ld   a, [$D461]
    ld   e, a
    ld   d, b
    ld   hl, $C290
    add  hl, de
    ld   [hl], $00
    jp   toc_01_27BD

toc_02_49C5.else_02_4A29:
    jr   .else_02_4A80

toc_02_49C5.else_02_4A2B:
    call toc_01_1495
    call toc_01_093B
    ld   hl, $C166
    dec  [hl]
    jr   nz, .else_02_4A80

    ifNot [$DB73], .else_02_4A51

    ifEq [$DB4A], $01, .else_02_4A61

    ld   a, [$DBA5]
    and  a
    jr   nz, .else_02_4A61

    ld   a, $77
    call toc_01_218E
    jr   .else_02_4A61

toc_02_49C5.else_02_4A51:
    ld   a, [$DB49]
    and  a
    jr   nz, .else_02_4A61

    ld   a, $8E
    call toc_01_2197
    clear [$C167]
    ret


toc_02_49C5.else_02_4A61:
    clear [$C167]
    ifNe [$DB4A], $01, .return_02_4A7F

    assign [$C17F], $02
    clear [$C180]
    ld   [$C16B], a
    ld   [$C16C], a
    assign [$FFF2], $2C
toc_02_49C5.return_02_4A7F:
    ret


toc_02_49C5.else_02_4A80:
    ld   a, [$C5A4]
    inc  a
    ld   [$C5A4], a
    cp   $38
    jr   c, .else_02_4A97

    clear [$C5A4]
    ld   a, [$C5A5]
    xor  $01
    ld   [$C5A5], a
toc_02_49C5.else_02_4A97:
    ld   a, [$C5A5]
    ld   e, $75
    and  a
    jr   nz, .else_02_4AA0

    inc  e
toc_02_49C5.else_02_4AA0:
    ld   a, e
    ld   [hLinkAnimationState], a
    assign [$C167], $02
    ld   [$C111], a
    returnIfLt [$C166], $10

    ifNe [$C5A4], $14, .return_02_4AEF

    ld   a, $C9
    call toc_01_3C01
    jr   c, .return_02_4AEF

    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, de
    sub  a, $08
    ld   [hl], a
    ld   a, [$C5A5]
    ld   c, a
    ld   b, d
    ld   hl, $49C1
    add  hl, bc
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $49C3
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $C250
    add  hl, de
    ld   [hl], $FC
    ld   hl, $C3D0
    add  hl, de
    ld   [hl], $40
toc_02_49C5.return_02_4AEF:
    ret


    db   $71, $72, $6F, $70, $73, $74, $6D, $6E

toc_02_4AF8:
    ifNot [$C1C7], .return_02_4B6E

    ifNe [$FFF7], $08, .else_02_4B13

    ifNe [$D219], $02, .else_02_4B13

    call toc_01_0F34.toc_01_0F3F
    assign [$C5B0], $01
toc_02_4AF8.else_02_4B13:
    ld   hl, hLinkInteractiveMotionBlocked
    ld   [hl], $01
    call toc_01_1495
    ld   [$C137], a
    ld   [$C121], a
    ld   [$C122], a
    ld   a, [$C1C8]
    inc  a
    ld   [$C1C8], a
    cp   $10
    jr   nz, .else_02_4B34

    push af
    call toc_02_4B77
    pop  af
toc_02_4AF8.else_02_4B34:
    cp   $18
    jr   nz, .else_02_4B58

    ifNe [$C1C7], $02, .else_02_4B50

    ifNot [$DB73], .else_02_4B50

    ld   a, [wDialogState]
    and  a
    jr   nz, .else_02_4B50

    ld   a, $79
    call toc_01_218E
toc_02_4AF8.else_02_4B50:
    clear [$C1C7]
    ld   [$C1AC], a
    ret


toc_02_4AF8.else_02_4B58:
    rra
    rra
    rra
    rra
    and  %00000001
    ld   e, a
    ld   a, [hLinkDirection]
    sla  a
    add  a, e
    ld   e, a
    ld   d, $00
    ld   hl, $4AF0
    add  hl, de
    ld   a, [hl]
    ld   [hLinkAnimationState], a
toc_02_4AF8.return_02_4B6E:
    ret


    db   $14, $FC, $08, $08, $0A, $0A, $FC, $14

toc_02_4B77:
    call toc_02_4C35
    jr   c, .return_02_4B84

    assign [$C1C7], $02
    call toc_02_4B85
toc_02_4B77.return_02_4B84:
    ret


toc_02_4B85:
    ld   a, [$FFD8]
    ld   e, a
    ld   d, $00
    ld   hl, $D711
    add  hl, de
    ld   [hl], $CC
    call toc_01_2839
    ld   hl, $D601
    ld   a, [$D600]
    ld   e, a
    add  a, $0A
    ld   [$D600], a
    ld   d, $00
    add  hl, de
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    ldi  [hl], a
    ld   a, $81
    ldi  [hl], a
    ifNot [$DBA5], .else_02_4BC8

    ld   a, $04
    ldi  [hl], a
    ld   a, $06
    ldi  [hl], a
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    inc  a
    ldi  [hl], a
    ld   a, $81
    ldi  [hl], a
    ld   a, $05
    ldi  [hl], a
    ld   a, $07
    jr   .toc_02_4BDD

toc_02_4B85.else_02_4BC8:
    ld   a, $6A
    ldi  [hl], a
    ld   a, $7A
    ldi  [hl], a
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    inc  a
    ldi  [hl], a
    ld   a, $81
    ldi  [hl], a
    ld   a, $6B
    ldi  [hl], a
    ld   a, $7B
toc_02_4B85.toc_02_4BDD:
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    call toc_01_27ED
    and  %00000111
    jr   nz, .return_02_4C34

    call toc_01_27ED
    rra
    ld   a, $2E
    jr   nc, .else_02_4BF2

    ld   a, $2D
toc_02_4B85.else_02_4BF2:
    call toc_01_3C01
    jr   c, .return_02_4C34

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
    ld   [hl], $20
    push de
    pop  bc
    ld   a, $0C
    call toc_01_3C25
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
toc_02_4B85.return_02_4C34:
    ret


toc_02_4C35:
    ld   a, [$C15C]
    ld   hl, hLinkPositionZHigh
    or   [hl]
    ld   hl, $C11C
    or   [hl]
    ld   hl, $FFF9
    or   [hl]
    jp   nz, .else_02_4CAA

    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, $00
    ld   hl, $4B6F
    add  hl, de
    ld   a, [hLinkPositionX]
    add  a, [hl]
    sub  a, $08
    and  %11110000
    ld   [hSwordIntersectedAreaX], a
    swap a
    ld   c, a
    ld   hl, $4B73
    add  hl, de
    ld   a, [hLinkPositionY]
    add  a, [hl]
    sub  a, $10
    and  %11110000
    ld   [hSwordIntersectedAreaY], a
    or   c
    ld   e, a
    ld   [$FFD8], a
    ld   hl, $D711
    add  hl, de
    ld   a, h
    cp   $D7
    jp   nz, .else_02_4CAA

    ld   a, [hl]
    ld   [$FFD7], a
    ld   e, a
    ld   a, [$DBA5]
    ld   d, a
    call toc_01_29DB
    cp   $00
    jr   nz, .else_02_4CAA

    ld   a, d
    and  a
    jr   nz, .else_02_4CA2

    ifEq [$FFD7], $0C, .else_02_4CAA

    cp   $0D
    jr   z, .else_02_4CAA

    cp   $0C
    jr   z, .else_02_4CAA

    cp   $0D
    jr   z, .else_02_4CAA

    cp   $B9
    jr   z, .else_02_4CAA

    jr   .toc_02_4CA8

toc_02_4C35.else_02_4CA2:
    ifNe [$FFD7], $05, .else_02_4CAA

toc_02_4C35.toc_02_4CA8:
    and  a
    ret


toc_02_4C35.else_02_4CAA:
    scf
    ret


toc_02_4CAC:
    copyFromTo [$FFD7], [hSwordIntersectedAreaX]
    swap a
    and  %00001111
    ld   e, a
    copyFromTo [$FFD8], [hSwordIntersectedAreaY]
    and  %11110000
    or   e
    ld   e, a
    ld   d, $00
    ld   hl, $D711
    add  hl, de
    ld   [hl], $AE
    call toc_01_2839
    ld   hl, $D601
    ld   a, [$D600]
    ld   e, a
    add  a, $0A
    ld   [$D600], a
    ld   d, $00
    add  hl, de
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    ldi  [hl], a
    ld   a, $81
    ldi  [hl], a
    ld   a, $76
    ldi  [hl], a
    ld   a, $77
    ldi  [hl], a
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    inc  a
    ldi  [hl], a
    ld   a, $81
    ldi  [hl], a
    ld   a, $76
    ldi  [hl], a
    ld   a, $77
    ldi  [hl], a
    ld   [hl], $00
    ret


    db   $50, $51, $52, $53, $53, $54, $52, $3E
    db   $10, $E0, $99, $3E, $50, $E0, $98, $EA
    db   $67, $C1, $FA, $98, $C1, $1F, $1F, $1F
    db   $E6, $07, $5F, $16, $00, $21, $F9, $4C
    db   $19, $7E, $E0, $9D, $FA, $98, $C1, $3C
    db   $EA, $98, $C1, $FE, $38, $38, $0C, $3E
    db   $FB, $E0, $99, $3E, $02, $E0, $9E, $3E
    db   $04, $E0, $9D, $FA, $98, $C1, $FE, $48
    db   $20, $16, $3E, $02, $EA, $25, $C1, $3E
    db   $01, $EA, $24, $C1, $AF, $EA, $98, $C1
    db   $EA, $67, $C1, $3E, $00, $EA, $1C, $C1
    db   $C9, $00, $08, $F8, $00, $00, $06, $FA
    db   $00, $00, $06, $FA, $00, $00, $00, $00
    db   $00, $00, $10, $F0, $00, $00, $0C, $F4
    db   $00, $00, $0C, $F4, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $F8, $FA, $FA
    db   $00, $08, $06, $06, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $F0, $F4, $F4
    db   $00, $10, $0C, $0C, $00, $00, $00, $00
    db   $00, $FA, $7B, $C1, $A7, $28, $06, $3E
    db   $00, $EA, $1C, $C1, $C9, $CD, $3B, $09
    db   $E0, $A2, $EA, $46, $C1, $EA, $9B, $C1
    db   $EA, $37, $C1, $EA, $6A, $C1, $EA, $6D
    db   $C1, $21, $9F, $C1, $F0, $A1, $B6, $CA
    db   $C9, $4D, $CD, $95, $14, $F0, $A1, $A7
    db   $28, $03, $AF, $E0, $A1, $C3, $EF, $19
    db   $F0, $CC, $E6, $20, $28, $13, $F0, $9C
    db   $EE, $01, $E0, $9C, $28, $0B, $3E, $A0
    db   $E0, $B7, $F0, $99, $D6, $03, $CD, $1D
    db   $57, $FA, $83, $C1, $A7, $28, $06, $3D
    db   $EA, $83, $C1, $18, $0F, $F0, $CC, $E6
    db   $10, $28, $09, $3E, $0F, $E0, $F2, $3E
    db   $20, $EA, $83, $C1, $F0, $E7, $E6, $01
    db   $20, $5E, $F0, $CB, $E6, $0F, $5F, $16
    db   $00, $21, $52, $4D, $FA, $83, $C1, $FE
    db   $10, $38, $03, $21, $62, $4D, $19, $7E
    db   $21, $9A, $FF, $96, $28, $07, $34, $CB
    db   $7F, $28, $02, $35, $35, $21, $72, $4D
    db   $FA, $83, $C1, $FE, $10, $38, $03, $21
    db   $82, $4D, $19, $7E, $21, $9B, $FF, $96
    db   $28, $07, $34, $CB, $7F, $28, $02, $35
    db   $35, $F0, $9A, $B6, $21, $9C, $FF, $B6
    db   $28, $06, $21, $20, $C1, $34, $18, $05
    db   $3E, $03, $EA, $20, $C1, $21, $B3, $48
    db   $19, $7E, $FE, $0F, $28, $02, $E0, $9E
    db   $CD, $EF, $19, $F0, $A1, $A7, $28, $05
    db   $AF, $E0, $A1, $18, $03, $CD, $54, $44
    db   $CD, $FA, $77, $F0, $9C, $A7, $28, $5C
    db   $F0, $B7, $A7, $20, $02, $E0, $9C, $F0
    db   $F7, $A7, $28, $0C, $FE, $1F, $20, $4D
    db   $F0, $F6, $FE, $F2, $20, $46, $18, $06
    db   $F0, $F6, $FE, $78, $20, $3E, $F0, $99
    db   $D6, $50, $C6, $08, $FE, $10, $30, $5D
    db   $F0, $98, $D6, $58, $C6, $08, $FE, $10
    db   $30, $53, $21, $F8, $FF, $CB, $6E, $20
    db   $23, $CB, $EE, $3E, $35, $CD, $01, $3C
    db   $38, $1A, $F0, $98, $21, $00, $C2, $19
    db   $77, $F0, $99, $21, $10, $C2, $19, $77
    db   $21, $10, $C3, $19, $36, $03, $21, $40
    db   $C3, $19, $CB, $A6, $C9, $F0, $F6, $FE
    db   $8D, $20, $22, $F0, $99, $D6, $50, $C6
    db   $08, $FE, $10, $30, $18, $F0, $98, $D6
    db   $58, $C6, $08, $FE, $10, $30, $0E, $F0
    db   $98, $EA, $04, $D4, $FA, $1C, $C1, $EA
    db   $63, $D4, $C3, $09, $09, $C9, $3E, $01
    db   $E0, $A1, $CD, $D6, $20, $CD, $0F, $21
    db   $F0, $98, $E6, $F0, $FE, $E0, $28, $05
    db   $F0, $A2, $FE, $78, $D8, $CD, $0F, $09
    db   $CD, $95, $14, $E0, $A2, $E0, $A3, $3E
    db   $70, $EA, $C8, $DB, $C9, $55, $56, $57
    db   $57, $FF, $FF, $FF, $FF, $FF, $FF, $3E
    db   $01, $EA, $67, $C1, $FA, $98, $C1, $3C
    db   $EA, $98, $C1, $1F, $1F, $1F, $1F, $00
    db   $E6, $0F, $FE, $06, $28, $0B, $5F, $16
    db   $00, $21, $26, $4F, $19, $7E, $E0, $9D
    db   $C9, $AF, $EA, $3E, $C1, $EA, $21, $C1
    db   $EA, $22, $C1, $CD, $11, $51, $FA, $A5
    db   $DB, $A7, $20, $22, $F0, $F6, $FE, $01
    db   $28, $0C, $FE, $95, $28, $08, $FE, $2C
    db   $28, $04, $FE, $EC, $20, $10, $3E, $09
    db   $EA, $1C, $C1, $3E, $40, $E0, $B7, $AF
    db   $E0, $9C, $3D, $E0, $9D, $C9, $FA, $CB
    db   $DB, $FE, $50, $28, $38, $FE, $FF, $28
    db   $1F, $FA, $01, $D4, $FE, $02, $20, $08
    db   $F0, $99, $EA, $04, $D4, $AF, $18, $17
    db   $F0, $98, $E6, $F0, $C6, $08, $EA, $04
    db   $D4, $F0, $99, $E6, $F0, $EA, $05, $D4
    db   $3E, $01, $EA, $75, $D4, $3E, $70, $EA
    db   $C8, $DB, $CD, $95, $14, $E0, $A3, $EA
    db   $46, $C1, $C3, $0F, $09, $FA, $A5, $DB
    db   $A7, $20, $06, $F0, $F6, $FE, $1E, $28
    db   $DF, $F0, $F7, $FE, $0A, $20, $30, $F0
    db   $F6, $FE, $7A, $28, $0C, $FE, $7B, $28
    db   $08, $FE, $7C, $28, $04, $FE, $7D, $20
    db   $1E, $3E, $00, $21, $01, $D4, $22, $3E
    db   $00, $22, $3E, $1A, $22, $3E, $68, $22
    db   $3E, $56, $22, $3E, $24, $EA, $C8, $DB
    db   $3E, $03, $E0, $9E, $C3, $0F, $09, $CD
    db   $F4, $50, $FA, $94, $DB, $C6, $04, $EA
    db   $94, $DB, $AF, $EA, $67, $C1, $C9, $FA
    db   $AA, $C1, $FE, $2E, $20, $04, $3E, $17
    db   $E0, $F2, $CD, $3B, $09, $EA, $6A, $C1
    db   $EA, $37, $C1, $EA, $3E, $C1, $CD, $9B
    db   $14, $CD, $0F, $21, $F0, $A3, $D6, $02
    db   $E0, $A3, $F0, $A2, $E6, $80, $28, $08
    db   $AF, $E0, $A2, $EA, $49, $C1, $E0, $A3
    db   $3E, $6B, $E0, $9D, $01, $10, $C0, $F0
    db   $99, $21, $A2, $FF, $96, $21, $3B, $C1
    db   $86, $D6, $10, $E0, $D7, $FA, $A9, $C1
    db   $FE, $01, $28, $24, $F0, $D7, $C6, $02
    db   $02, $03, $F0, $98, $C6, $00, $02, $FA
    db   $A9, $C1, $1E, $AE, $FE, $05, $28, $08
    db   $FE, $04, $1E, $8E, $20, $02, $1E, $8C
    db   $03, $7B, $02, $3E, $10, $03, $02, $C9
    db   $F0, $98, $D6, $08, $E0, $D8, $F0, $E7
    db   $17, $17, $E6, $10, $E0, $DA, $AF, $67
    db   $6F, $3E, $06, $E0, $D9, $CD, $40, $15
    db   $C9, $CD, $3B, $09, $CD, $95, $14, $F0
    db   $B7, $A7, $20, $2D, $EA, $67, $C1, $F0
    db   $9C, $FE, $06, $20, $08, $FA, $94, $DB
    db   $C6, $04, $EA, $94, $DB, $AF, $E0, $9C
    db   $FA, $A5, $DB, $A7, $20, $10, $F0, $F6
    db   $FE, $2B, $20, $0A, $3E, $48, $EA, $B1
    db   $DB, $3E, $30, $EA, $B2, $DB, $C3, $F4
    db   $50, $1E, $FF, $F0, $B7, $FE, $30, $38
    db   $0E, $1E, $4E, $FE, $40, $38, $08, $20
    db   $04, $3E, $03, $E0, $F3, $1E, $4C, $7B
    db   $E0, $9D, $C9, $3E, $40, $EA, $C7, $DB
    db   $FA, $B1, $DB, $E0, $98, $E0, $9F, $FA
    db   $B2, $DB, $E0, $99, $E0, $A0, $21, $A2
    db   $FF, $96, $EA, $45, $C1, $CD, $45, $4D
    db   $F0, $AC, $A7, $28, $04, $3E, $01, $E0
    db   $AC, $C9, $0D, $F3, $00, $FF, $08, $F8
    db   $0C, $F5, $00, $00, $F3, $0E, $F3, $F3
    db   $FC, $00, $06, $08, $08, $06, $04, $FF
    db   $FF, $04, $04, $FF, $FF, $04, $06, $08
    db   $08, $06, $00, $00, $20, $20, $20, $00
    db   $00, $40, $20, $00, $00, $20, $00, $00
    db   $20, $20

toc_02_514B:
    ld   a, [$C19B]
    and  %01111111
    cp   $08
    ld   a, [hLinkDirection]
    jr   c, .else_02_5158

    add  a, $04
toc_02_514B.else_02_5158:
    ld   e, a
    ld   d, $00
    ld   hl, $5123
    add  hl, de
    ld   a, [hl]
    ld   [$FFD7], a
    ld   hl, $511B
    add  hl, de
    ld   a, [hl]
    ld   [$FFD8], a
    sla  e
    ld   hl, $512B
    add  hl, de
    ldi  a, [hl]
    ld   [$FFD9], a
    ld   a, [hl]
    ld   [$FFDA], a
    ld   hl, $513B
    add  hl, de
    ldi  a, [hl]
    ld   [$FFDB], a
    ld   a, [hl]
    ld   [$FFDC], a
    ld   de, $C010
    ld   bc, $C014
    ld   a, [$C145]
    ld   hl, $C13B
    add  a, [hl]
    ld   hl, $FFD7
    add  a, [hl]
    ld   [hl], a
    ifEq [$FFD9], $FF, .else_02_5199

    ld   a, [hl]
    ld   [de], a
toc_02_514B.else_02_5199:
    ifEq [$FFDA], $FF, .else_02_51A1

    ld   a, [hl]
    ld   [bc], a
toc_02_514B.else_02_51A1:
    inc  de
    inc  bc
    ld   a, [$FFD8]
    ld   hl, hLinkPositionX
    add  a, [hl]
    ld   [de], a
    add  a, $08
    ld   [bc], a
    inc  de
    inc  bc
    ld   a, [$FFD9]
    ld   [de], a
    ld   a, [$FFDA]
    ld   [bc], a
    inc  de
    inc  bc
    ld   a, [$FFDB]
    ld   [de], a
    ld   a, [$FFDC]
    ld   [bc], a
    ret


    db   $04, $FC, $FC, $04, $04, $04, $FC, $04

toc_02_51C6:
    ld   a, [hLinkDirection]
    ld   c, a
    ld   b, $00
    ld   hl, $51BE
    add  hl, bc
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $51C2
    add  hl, bc
    ld   a, [hLinkPositionY]
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], d
    jp   toc_01_10CB

toc_02_51EB:
    push bc
    push de
    ifEq [$FFE8], $40, .else_02_5236

    ifNot [$DBD0], .else_02_5258

    dec  a
    ld   [$DBD0], a
    call toc_01_27E2
    call toc_02_525B
    call toc_02_5987
    ld   a, [hl]
    or   $40
    ld   [hl], a
    ld   [$FFF8], a
    ld   a, [$FFDB]
    and  %11110000
    ld   [hSwordIntersectedAreaX], a
    swap a
    ld   e, a
    ld   a, [$FFDC]
    and  %11110000
    ld   [hSwordIntersectedAreaY], a
    or   e
    ld   e, a
    ld   d, $00
    call toc_01_20A6
    ld   a, [hSwordIntersectedAreaX]
    add  a, $08
    ld   [$FFD7], a
    ld   a, [hSwordIntersectedAreaY]
    add  a, $10
    ld   [$FFD8], a
    ld   a, $02
    call toc_01_0953
    jp   .else_02_5258

toc_02_51EB.else_02_5236:
    ld   a, $06
    call toc_01_3C01
    jr   c, .else_02_5258

    ld   hl, $C280
    add  hl, de
    dec  [hl]
    ld   a, [$FFDB]
    and  %11110000
    add  a, $08
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFDC]
    and  %11110000
    add  a, $10
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
toc_02_51EB.else_02_5258:
    pop  de
    pop  bc
    ret


toc_02_525B:
    assign [$FFF4], $04
    ret


toc_02_5260:
    push bc
    ld   a, [$FFF7]
    cp   $0A
    ld   a, $30
    jr   c, .else_02_526B

    ld   a, $3C
toc_02_5260.else_02_526B:
    call toc_01_3C01
    jr   c, .else_02_5282

    ld   hl, $C200
    add  hl, de
    ld   [hl], $28
    ld   hl, $C210
    add  hl, de
    ld   [hl], $3C
    ld   hl, $C310
    add  hl, de
    ld   [hl], $70
toc_02_5260.else_02_5282:
    pop  bc
    ret


    db   $30, $33, $81, $01, $28, $56, $68, $87
    db   $B3, $E6, $0A, $01, $01, $04, $00, $01
    db   $02, $03, $04, $05, $06, $07

toc_02_529A:
    clear [$D900]
    ld   [$DA00], a
    ifNot [$C134], .else_02_52AB

    dec  a
    ld   [$C134], a
toc_02_529A.else_02_52AB:
    ld   a, [hPressedButtonsMask]
    and  %00100000
    jr   z, toc_02_52ED

    ld   a, [$FFCC]
    and  %01000000
    jr   toc_02_52ED

    db   $3E, $01, $EA, $01, $D4, $FA, $79, $D4
    db   $5F, $3C, $FE, $0B, $38, $01, $AF, $EA
    db   $79, $D4, $16, $00, $21, $84, $52, $19
    db   $7E, $EA, $03, $D4, $21, $8F, $52, $19
    db   $7E, $EA, $02, $D4, $3E, $50, $EA, $04
    db   $D4, $3E, $70, $EA, $05, $D4, $21, $F2
    db   $FF, $36, $02, $C3, $09, $09

toc_02_52ED:
    ld   b, $00
    ld   c, $0F
toc_02_52F1:
    ld   a, c
    ld   [$C123], a
    ld   hl, $C510
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, toc_02_5300

    call toc_02_535D
toc_02_5300:
    dec  c
    ld   a, c
    cp   $FF
    jr   nz, toc_02_52F1

    ld   a, [$C124]
    and  a
    jr   nz, toc_02_5332

    ifNot [$FFAC], toc_02_5332

    cp   $01
    jr   nz, toc_02_5333

    ld   hl, $FFAD
    ld   a, [hLinkPositionX]
    sub  a, [hl]
    add  a, $06
    cp   12
    jr   nc, toc_02_532D

    ld   hl, $FFAE
    ld   a, [hLinkPositionY]
    sub  a, [hl]
    add  a, $06
    cp   12
    jr   c, toc_02_5332

toc_02_532D:
    ld   a, [$FFAC]
    inc  a
    ld   [$FFAC], a
toc_02_5332:
    ret


toc_02_5333:
    ld   a, [hLinkPositionZHigh]
    and  a
    jr   nz, toc_02_535C

    ld   hl, $FFAD
    ld   a, [hLinkPositionX]
    sub  a, [hl]
    add  a, $05
    cp   10
    jr   nc, toc_02_535C

    ld   hl, $FFAE
    ld   a, [hLinkPositionY]
    sub  a, [hl]
    add  a, $05
    cp   10
    jr   nc, toc_02_535C

    ld   a, [$C15C]
    and  a
    jr   nz, toc_02_535C

    call toc_01_0915
    clear [$FFAC]
toc_02_535C:
    ret


toc_02_535D:
    push af
    ld   a, [$C124]
    and  a
    jr   nz, .else_02_5372

    ld   hl, $C520
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_02_5375

    dec  a
    ld   [hl], a
    ld   [$FFD7], a
    jr   nz, .else_02_5375

toc_02_535D.else_02_5372:
    call toc_02_56C5.else_02_56DB
toc_02_535D.else_02_5375:
    pop  af
    dec  a
    jumptable
    dw JumpTable_5619_02 ; 00
    dw JumpTable_5699_02 ; 01
    dw JumpTable_5699_02 ; 02
    dw JumpTable_5699_02 ; 03
    dw JumpTable_55E1_02 ; 04
    dw JumpTable_55A7_02 ; 05
    dw JumpTable_5550_02 ; 06
    dw JumpTable_5538_02 ; 07
    dw JumpTable_543D_02 ; 08
    dw JumpTable_5402_02 ; 09
    dw JumpTable_550A_02 ; 0A
    dw JumpTable_5611_02 ; 0B
    dw JumpTable_53D2_02 ; 0C

    db   $00, $00, $08, $20, $00, $08, $06, $20
    db   $00, $00, $06, $00, $00, $08, $08, $00
    db   $00, $04, $04, $40, $00, $04, $04, $40
    db   $00, $04, $04, $00, $00, $04, $04, $00
    db   $00, $00, $08, $30, $00, $08, $06, $30
    db   $00, $00, $06, $10, $00, $08, $08, $10
    db   $00, $04, $04, $50, $00, $04, $04, $50
    db   $00, $04, $04, $10, $00, $04, $04, $10

JumpTable_53D2_02:
    ld   a, [hFrameCounter]
    xor  c
    and  %00000001
    ret  z

    call toc_02_56C5
    ld   hl, $C590
    add  hl, bc
    ld   a, [hl]
    rla
    rla
    rla
    and  %11111000
    ld   e, a
    ld   d, b
    ld   hl, $5392
    ld   a, [hFrameCounter]
    and  %00000010
    jr   z, .else_02_53F3

    ld   hl, $53B2
JumpTable_53D2_02.else_02_53F3:
    jp   JumpTable_5619_02.toc_02_562E

    db   $F8, $00, $08, $10, $6C, $6E, $6E, $6C
    db   $00, $00, $20, $20

JumpTable_5402_02:
    call toc_02_56C5
    ld   a, [$C3C0]
    ld   e, a
    ld   d, $00
    ld   hl, $C030
    add  hl, de
    push hl
    pop  de
    push bc
    ld   c, $04
JumpTable_5402_02.loop_02_5414:
    ld   a, [$FFD8]
    ld   [de], a
    inc  de
    ld   a, [$FFD9]
    ld   hl, $53F5
    add  hl, bc
    add  a, [hl]
    ld   [de], a
    inc  de
    ld   hl, $53F9
    add  hl, bc
    ld   a, [hl]
    ld   [de], a
    inc  de
    ld   hl, $53FD
    add  hl, bc
    ld   a, [hl]
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop_02_5414

    pop  bc
    ld   a, $04
    call toc_02_56EA
    ret


    db   $7E, $1F, $0C, $1F

JumpTable_543D_02:
    assign [hLinkInteractiveMotionBlocked], $02
    ld   [$C167], a
    clear [$C155]
    ifGte [$FFD7], $02, .else_02_5452

    ld   hl, $C167
    ld   [hl], b
JumpTable_543D_02.else_02_5452:
    cp   $DE
    jr   nz, .else_02_545B

    call toc_02_525B
    ld   a, $DE
JumpTable_543D_02.else_02_545B:
    cp   $A0
    jr   nz, .else_02_5464

    ld   hl, $FFF4
    ld   [hl], $2A
JumpTable_543D_02.else_02_5464:
    cp   $0A
    jr   nz, .else_02_546F

    assign [$C5AF], $50
    ld   a, $0A
JumpTable_543D_02.else_02_546F:
    cp   $20
    jr   c, .else_02_5483

    cp   $9C
    ret  nc

    ld   e, $01
    and  %00000100
    jr   z, .else_02_547E

    ld   e, $FE
JumpTable_543D_02.else_02_547E:
    ld   a, e
    ld   [$C155], a
    ret


JumpTable_543D_02.else_02_5483:
    and  %00001111
    cp   $08
    jp   nz, .return_02_54F9

    ld   a, [$FFD7]
    rra
    rra
    rra
    and  %00000010
    ld   e, a
    ld   d, b
    ld   hl, $5439
    add  hl, de
    ldi  a, [hl]
    ld   [$FFD7], a
    ld   a, [hl]
    ld   [$FFD8], a
    assign [hSwordIntersectedAreaX], $60
    ld   a, [$FFF6]
    cp   $B5
    ld   a, $10
    jr   nz, .else_02_54AF

    assign [hSwordIntersectedAreaX], $60
    ld   a, $10
JumpTable_543D_02.else_02_54AF:
    ld   [hSwordIntersectedAreaY], a
    call toc_01_2839
    ld   a, [$D600]
    ld   e, a
    ld   d, b
    ld   hl, $D601
    add  hl, de
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    ldi  [hl], a
    ld   a, $41
    ldi  [hl], a
    ld   a, [$FFD7]
    ldi  [hl], a
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    add  a, $20
    ldi  [hl], a
    ld   a, $41
    ldi  [hl], a
    ld   a, [$FFD8]
    ldi  [hl], a
    ld   [hl], b
    ld   a, e
    add  a, $08
    ld   [$D600], a
    ld   hl, $C520
    add  hl, bc
    ld   a, [hl]
    cp   $08
    jr   nz, .return_02_54F9

    ld   hl, $D727
    ifNe [$FFF6], $B5, .else_02_54F3

    ld   hl, $D727
JumpTable_543D_02.else_02_54F3:
    ld   [hl], $E3
    assign [$FFF2], $23
JumpTable_543D_02.return_02_54F9:
    ret


    db   $00, $04, $24, $00, $00, $04, $24, $00
    db   $00, $00, $1E, $00, $00, $08, $1E, $60

JumpTable_550A_02:
    call toc_02_56C5
    ld   a, [$FFD7]
    and  %00001000
    ld   d, $00
    ld   e, a
    ld   hl, $54FA
    ld   a, [$C14A]
    and  a
    jp   nz, JumpTable_5619_02.toc_02_562E

    add  hl, de
    ld   de, $C000
    call toc_02_5649
    jp   toc_02_5649

    db   $00, $00, $1E, $00, $00, $08, $1E, $60
    db   $00, $00, $30, $00, $00, $08, $30, $60

JumpTable_5538_02:
    call toc_02_56C5
    ld   a, [$FFD7]
    and  %00001000
    ld   d, $00
    ld   e, a
    ld   hl, $5528
    jp   JumpTable_5619_02.toc_02_562E

    db   $01, $FF, $01, $FF, $01, $01, $FF, $FF

JumpTable_5550_02:
    ifLt [$FFD7], $0A, .else_02_5572

    ld   hl, $C590
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $5548
    add  hl, de
    ld   a, [hl]
    ld   hl, $C530
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    ld   hl, $554C
    add  hl, de
    ld   a, [hl]
    ld   hl, $C540
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
JumpTable_5550_02.else_02_5572:
    call toc_02_56C5
    push bc
    ld   c, $3A
    ifGte [$FFD7], $07, .else_02_5580

    ld   c, $3C
JumpTable_5550_02.else_02_5580:
    ld   a, [$C3C0]
    ld   e, a
    ld   d, $00
    ld   hl, $C030
    add  hl, de
    ld   a, [$FFD8]
    ldi  [hl], a
    ld   a, [$FFD9]
    ldi  [hl], a
    ld   a, c
    ldi  [hl], a
    xor  a
    ldi  [hl], a
    ld   a, [$FFD8]
    ldi  [hl], a
    ld   a, [$FFD9]
    add  a, $08
    ldi  [hl], a
    ld   a, c
    ldi  [hl], a
    ld   [hl], $20
    pop  bc
    ld   a, $02
    call toc_02_56EA
    ret


JumpTable_55A7_02:
    call toc_02_56C5
    ld   a, [$C3C0]
    ld   e, a
    ld   d, $00
    ld   hl, $C030
    add  hl, de
    ld   a, [$FFD8]
    ldi  [hl], a
    ld   a, [$FFD9]
    ldi  [hl], a
    ld   a, $24
    ldi  [hl], a
    ld   a, [hFrameCounter]
    xor  c
    rl   a
    rl   a
    rl   a
    rl   a
    and  %00010000
    ld   [hl], a
    ld   a, $01
    call toc_02_56EA
    ret


    db   $00, $FF, $3C, $00, $00, $07, $3C, $20
    db   $00, $FF, $3A, $00, $00, $07, $3A, $20

JumpTable_55E1_02:
    call toc_02_56C5
    ld   a, [$FFD7]
    and  %00001000
    ld   d, $00
    ld   e, a
    ld   hl, $55D1
    jp   JumpTable_5619_02.toc_02_562E

    db   $F6, $FE, $18, $00, $F8, $0A, $18, $20
    db   $FC, $00, $18, $00, $FE, $08, $18, $20
    db   $00, $FA, $18, $00, $00, $0E, $18, $20
    db   $02, $FC, $18, $00, $02, $0C, $18, $20

JumpTable_5611_02:
    call toc_02_56C5
    ld   hl, $5601
    jr   JumpTable_5619_02.toc_02_5627

JumpTable_5619_02:
    call toc_02_56C5
    ld   a, [$C1A7]
    cp   $02
    jp   z, toc_02_566C

    ld   hl, $55F1
JumpTable_5619_02.toc_02_5627:
    ld   a, [$FFD7]
    and  %00001000
    ld   e, a
    ld   d, $00
JumpTable_5619_02.toc_02_562E:
    add  hl, de
    push hl
    ld   a, [$C3C0]
    ld   e, a
    ld   d, $00
    ld   hl, $C030
    add  hl, de
    push hl
    pop  de
    pop  hl
    call toc_02_5649
    call toc_02_5649
    ld   a, $02
    call toc_02_56EA
    ret


toc_02_5649:
    ld   a, [$FFD8]
    add  a, [hl]
    ld   [de], a
    inc  hl
    inc  de
    ld   a, [$FFD9]
    add  a, [hl]
    ld   [de], a
    inc  hl
    inc  de
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ldi  a, [hl]
    ld   [de], a
    inc  de
    ret


    db   $00, $00, $7A, $00, $00, $08, $7A, $20
    db   $00, $00, $78, $00, $00, $08, $78, $20

toc_02_566C:
    ld   a, [$FFD7]
    and  %00001000
    ld   d, $00
    ld   e, a
    ld   hl, $565C
    jp   JumpTable_5619_02.toc_02_562E

    db   $00, $00, $32, $00, $00, $08, $32, $20
    db   $00, $00, $32, $00, $00, $08, $32, $20
    db   $00, $00, $30, $00, $00, $08, $30, $20
    db   $00, $00, $30, $00, $00, $08, $30, $20

JumpTable_5699_02:
    call toc_02_56C5
    ifNe [$FFD7], $04, .else_02_56B0

    ld   hl, $C510
    add  hl, bc
    ld   a, [hl]
    cp   $03
    jr   nz, .else_02_56B0

    call toc_02_5C92
    jr   .else_02_56B7

JumpTable_5699_02.else_02_56B0:
    cp   $04
    jr   nz, .else_02_56B7

    call toc_02_5D00
JumpTable_5699_02.else_02_56B7:
    ld   a, [$FFD7]
    rla
    and  %00011000
    ld   d, $00
    ld   e, a
    ld   hl, $5679
    jp   JumpTable_5619_02.toc_02_562E

toc_02_56C5:
    ld   hl, $C540
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD8], a
    cp   $88
    jr   nc, .else_02_56DB

    ld   hl, $C530
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD9], a
    cp   $A8
    jr   c, .return_02_56E1

toc_02_56C5.else_02_56DB:
    ld   hl, $C510
    add  hl, bc
    xor  a
    ld   [hl], a
toc_02_56C5.return_02_56E1:
    ret


    db   $00, $08, $10, $18, $20, $28, $30, $38

toc_02_56EA:
    sla  a
    sla  a
    ld   e, a
    ld   a, [$C3C0]
    add  a, e
    cp   $60
    jr   c, .else_02_56F9

    sub  a, $60
toc_02_56EA.else_02_56F9:
    ld   [$C3C0], a
    ld   a, [$C3C1]
    add  a, e
    ld   [$C3C1], a
    cp   $60
    jr   c, .return_02_571A

    ld   a, [hFrameCounter]
    ld   hl, $C123
    add  a, [hl]
    and  %00000111
    ld   e, a
    ld   d, $00
    ld   hl, $56E2
    add  hl, de
    ld   a, [hl]
    ld   [$C3C0], a
toc_02_56EA.return_02_571A:
    ret


toc_02_571B:
    ld   a, [hLinkPositionY]
toc_02_571B.toc_02_571D:
    ld   [$FFD8], a
    copyFromTo [hLinkPositionX], [$FFD7]
    assign [$FFF2], $0E
    ld   a, $01
    call toc_01_0953
    ret


    db   $FE, $FD, $FB, $F7

toc_02_5731:
    ld   hl, wDialogState
    ld   a, [$C124]
    or   [hl]
    ld   hl, $C14F
    or   [hl]
    jr   nz, .return_02_575D

    ifNot [$DBA5], .return_02_575D

    call toc_02_5B15
    ifNot [$C188], .else_02_575E

    cp   $02
    assign [hLinkInteractiveMotionBlocked], $01
    jr   z, .else_02_575A

    call toc_02_5871
    jr   .return_02_575D

toc_02_5731.else_02_575A:
    call toc_02_59E1
toc_02_5731.return_02_575D:
    ret


toc_02_5731.else_02_575E:
    ifNot [$C18C], .else_02_5793

    ld   e, $03
    ld   a, [$C18A]
    ld   c, a
toc_02_5731.loop_02_576A:
    inc  e
    ld   a, e
    cp   $08
    jr   z, .else_02_578E

    srl  c
    jr   nc, .loop_02_576A

    ld   d, $00
    ld   hl, $5729
    add  hl, de
    ld   a, [$C18A]
    and  [hl]
    ld   [$C18A], a
    ld   a, e
    ld   [$C189], a
    clear [$DBAC]
    inc  a
    ld   [$C188], a
    ret


toc_02_5731.else_02_578E:
    clear [$C18C]
    ret


toc_02_5731.else_02_5793:
    ld   a, [$C18D]
    and  a
    jr   nz, .else_02_579A

    ret


toc_02_5731.else_02_579A:
    ld   e, $03
    ld   a, [$C18B]
    ld   c, a
toc_02_5731.loop_02_57A0:
    inc  e
    ld   a, e
    cp   $08
    jr   z, .else_02_57C5

    srl  c
    jr   nc, .loop_02_57A0

    ld   d, $00
    ld   hl, $5729
    add  hl, de
    ld   a, [$C18B]
    and  [hl]
    ld   [$C18B], a
    ld   a, e
    ld   [$C189], a
    assign [$C188], $02
    clear [$DBAC]
    ret


toc_02_5731.else_02_57C5:
    clear [$C18D]
    ret


    db   $50, $51, $13, $12, $11, $10, $42, $43
    db   $45, $13, $55, $11, $12, $46, $10, $56
    db   $58, $59, $13, $12, $11, $10, $4A, $4B
    db   $4D, $13, $5D, $11, $12, $4E, $10, $5E
    db   $02, $03, $13, $12, $11, $10, $13, $12
    db   $11, $10, $13, $12, $12, $13, $10, $11
    db   $12, $13, $10, $11, $11, $10, $13, $12
    db   $11, $10, $13, $12, $12, $13, $10, $11
    db   $12, $13, $10, $11, $11, $10, $13, $12
    db   $08, $08, $00, $00, $08, $08, $00, $00
    db   $08, $08, $08, $00, $00, $08, $08, $00
    db   $00, $08, $00, $00, $08, $08, $00, $00
    db   $08, $08, $00, $08, $08, $10, $10, $08
    db   $08, $10, $10, $08, $00, $00, $00, $00
    db   $00, $00, $00, $00, $01, $01, $10, $10
    db   $01, $01, $10, $10, $43, $8C, $09, $0B
    db   $43, $8C, $09, $0B, $44, $08, $0A, $0C
    db   $44, $08, $0A, $0C, $04, $08, $02, $01
    db   $04, $08, $02, $01, $04, $F8, $08, $FF
    db   $01, $F8, $08, $FF, $01, $F8, $08, $04
    db   $01, $02, $08, $04, $01, $02, $08

toc_02_5871:
    ld   e, $00
    ld   d, e
    ld   c, e
    ld   b, e
    clear [$FFE3]
    ld   [$FFE5], a
    ld   a, [$C189]
    ld   c, a
    and  a
    jr   z, .else_02_588B

    xor  a
toc_02_5871.loop_02_5883:
    add  a, $04
    ld   e, a
    ld   d, $00
    dec  c
    jr   nz, .loop_02_5883

toc_02_5871.else_02_588B:
    ld   hl, $5812
    ld   a, [$C189]
    ld   c, a
    ld   b, $00
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C1D0
    add  hl, bc
    add  a, [hl]
    ld   [hSwordIntersectedAreaX], a
toc_02_5871.toc_02_589D:
    ld   hl, $5824
    ld   a, [$FFE3]
    ld   c, a
    add  hl, bc
    ld   a, [$C189]
    ld   c, a
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C1E0
    add  hl, bc
    add  a, [hl]
    ld   [hSwordIntersectedAreaY], a
    push de
    call toc_01_2839
    pop  de
    ifNot [$FFE3], .else_02_58BD

    inc  de
    inc  de
toc_02_5871.else_02_58BD:
    ld   a, [$D600]
    ld   c, a
    ld   b, $00
    add  a, $05
    ld   [$D600], a
    ld   hl, $D601
    add  hl, bc
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    ldi  [hl], a
    ld   a, $01
    ldi  [hl], a
    push hl
    ld   hl, $57CA
    add  hl, de
    ld   a, [hl]
    pop  hl
    ldi  [hl], a
    push hl
    ld   hl, $57CB
    add  hl, de
    ld   a, [hl]
    pop  hl
    ld   [hl], a
    ld   a, [$FFE3]
    and  a
    jr   nz, .else_02_58F1

    assign [$FFE3], $09
    jp   .toc_02_589D

toc_02_5871.else_02_58F1:
    xor  a
    inc  hl
    ld   [hl], a
    ld   a, [$DBAC]
    add  a, $01
    ld   [$DBAC], a
    ifGte [$DBAC], $08, .else_02_5904

    ret


toc_02_5871.else_02_5904:
    ld   a, [$FFE5]
    and  a
    jr   nz, .else_02_5919

    clear [$FFE3]
    ld   a, e
    add  a, $24
    ld   e, a
    ld   d, $00
    ld   [$FFE5], a
    dec  de
    dec  de
    jp   .toc_02_589D

toc_02_5871.else_02_5919:
    clear [$C188]
    ld   [$C1A8], a
    clear [$FFE5]
    ld   a, [$C189]
    ld   c, a
    ld   b, $00
    ld   hl, $C1F0
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD7], a
    ld   a, c
    and  %00000111
    ld   c, a
toc_02_5871.toc_02_5934:
    ld   hl, $5836
    add  hl, bc
    ld   a, [hl]
    ld   hl, $FFD7
    add  a, [hl]
    ld   e, a
    ld   d, $00
    ld   hl, $5846
    add  hl, bc
    ld   a, [hl]
    ld   hl, $D711
    add  hl, de
    ld   [hl], a
    ld   a, [$FFE5]
    and  a
    jr   nz, .else_02_5957

    ld   a, c
    add  a, $08
    ld   [$FFE5], a
    ld   c, a
    jr   .toc_02_5934

toc_02_5871.else_02_5957:
    call toc_02_5987
    push hl
    pop  bc
    ld   a, [$C189]
    ld   e, a
    ld   d, $00
    ld   hl, $5856
    add  hl, de
    ld   a, [bc]
    or   [hl]
    ld   [bc], a
    ld   [$FFF8], a
    ld   hl, $585F
    add  hl, de
    ld   a, [$DBAE]
    add  a, [hl]
    ld   e, a
    call toc_01_2B25
    push hl
    pop  bc
    ld   a, [$C189]
    ld   e, a
    ld   d, $00
    ld   hl, $5868
    add  hl, de
    ld   a, [bc]
    or   [hl]
    ld   [bc], a
    ret


toc_02_5987:
    ld   hl, $D800
    ld   a, [$FFF6]
    ld   e, a
    ld   a, [$DBA5]
    ld   d, a
    and  a
    jr   z, .else_02_599F

    ifGte [$FFF7], $1A, .else_02_599F

    cp   $06
    jr   c, .else_02_599F

    inc  d
toc_02_5987.else_02_599F:
    add  hl, de
    ret


    db   $58, $59, $13, $12, $11, $10, $4A, $4B
    db   $4D, $13, $5D, $11, $12, $4E, $10, $5E
    db   $40, $41, $58, $59, $4A, $4B, $52, $53
    db   $44, $4D, $54, $5D, $4E, $47, $5E, $57
    db   $08, $08, $00, $00, $08, $08, $00, $00
    db   $00, $00, $08, $08, $08, $08, $10, $10
    db   $00, $00, $00, $00, $01, $01, $10, $10
    db   $35, $37, $39, $3B, $36, $38, $3A, $3C

toc_02_59E1:
    ld   e, $00
    ld   d, e
    ld   c, e
    ld   b, e
    clear [$FFE3]
    ld   [$FFE4], a
    ld   [$FFE5], a
    ld   a, [$C189]
    sub  a, $04
    jr   z, .else_02_59FE

    ld   c, a
    xor  a
toc_02_59E1.loop_02_59F6:
    add  a, $04
    ld   e, a
    ld   d, $00
    dec  c
    jr   nz, .loop_02_59F6

toc_02_59E1.else_02_59FE:
    ld   hl, $59BD
    ld   a, [$C189]
    ld   c, a
    ld   b, $00
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C1D0
    add  hl, bc
    add  a, [hl]
    ld   [hSwordIntersectedAreaX], a
toc_02_59E1.toc_02_5A10:
    ld   hl, $59C5
    ld   a, [$FFE3]
    ld   c, a
    add  hl, bc
    ld   a, [$C189]
    ld   c, a
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C1E0
    add  hl, bc
    add  a, [hl]
    ld   [hSwordIntersectedAreaY], a
    ld   a, [$DBB2]
    sub  a, $10
    ld   hl, hSwordIntersectedAreaY
    sub  a, [hl]
    add  a, $10
    cp   $20
    jr   nc, .else_02_5A4C

    ld   a, [$DBB1]
    sub  a, $08
    ld   hl, hSwordIntersectedAreaX
    sub  a, [hl]
    add  a, $10
    cp   $20
    jr   nc, .else_02_5A4C

    copyFromTo [hLinkPositionX], [$DBB1]
    copyFromTo [hLinkPositionY], [$DBB2]
toc_02_59E1.else_02_5A4C:
    push de
    call toc_01_2839
    pop  de
    ifNot [$FFE3], .else_02_5A58

    inc  de
    inc  de
toc_02_59E1.else_02_5A58:
    ld   a, [$D600]
    ld   c, a
    ld   b, $00
    add  a, $05
    ld   [$D600], a
    ld   hl, $D601
    add  hl, bc
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    ldi  [hl], a
    ld   a, $01
    ldi  [hl], a
    push hl
    ld   hl, $59A1
    add  hl, de
    ld   a, [hl]
    pop  hl
    ldi  [hl], a
    push hl
    ld   hl, $59A2
    add  hl, de
    ld   a, [hl]
    pop  hl
    ld   [hl], a
    ld   a, [$FFE3]
    and  a
    jr   nz, .else_02_5A8C

    assign [$FFE3], $04
    jp   .toc_02_5A10

toc_02_59E1.else_02_5A8C:
    xor  a
    inc  hl
    ld   [hl], a
    ld   a, [$DBAC]
    add  a, $01
    ld   [$DBAC], a
    ifGte [$DBAC], $08, .else_02_5A9F

    ret


toc_02_59E1.else_02_5A9F:
    ld   a, [$FFE5]
    and  a
    jr   nz, .else_02_5AB4

    clear [$FFE3]
    ld   a, e
    add  a, $10
    ld   e, a
    ld   d, $00
    ld   [$FFE5], a
    dec  de
    dec  de
    jp   .toc_02_5A10

toc_02_59E1.else_02_5AB4:
    clear [$C188]
    ld   [$C1A8], a
    clear [$FFE5]
    ld   a, [$C189]
    sub  a, $04
    ld   c, a
    ld   b, $00
    ld   hl, $C1F4
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD7], a
toc_02_59E1.toc_02_5ACD:
    ld   hl, $59D1
    add  hl, bc
    ld   a, [hl]
    ld   hl, $FFD7
    add  a, [hl]
    ld   e, a
    ld   d, $00
    ld   hl, $59D9
    add  hl, bc
    ld   a, [hl]
    ld   hl, $D711
    add  hl, de
    ld   [hl], a
    ld   a, [$FFE5]
    and  a
    jr   nz, .else_02_5AF0

    ld   a, c
    add  a, $04
    ld   [$FFE5], a
    ld   c, a
    jr   .toc_02_5ACD

toc_02_59E1.else_02_5AF0:
    ld   hl, $D800
    ifNot [$DBA5], .else_02_5AFC

    ld   hl, $D900
toc_02_59E1.else_02_5AFC:
    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    add  hl, de
    push hl
    ld   a, [$C189]
    ld   e, a
    ld   d, $00
    ld   hl, $5856
    add  hl, de
    ld   a, [hl]
    cpl
    pop  hl
    and  [hl]
    ld   [hl], a
    ld   [$FFF8], a
    ret


toc_02_5B15:
    ld   a, [$C18E]
    and  a
    jp   z, JumpTable_5BAF_02.return_02_5BC8

    call toc_02_5D3F
    ld   a, [$C18E]
    and  %11100000
    srl  a
    srl  a
    srl  a
    srl  a
    srl  a
    jumptable
    dw JumpTable_5D63_02 ; 00
    dw JumpTable_5BDF_02.JumpTable_5BED_02 ; 01
    dw JumpTable_5B3F_02 ; 02
    dw JumpTable_5C69_02 ; 03
    dw JumpTable_5BC9_02 ; 04
    dw JumpTable_5BAF_02 ; 05
    dw JumpTable_5BDF_02 ; 06
    dw JumpTable_5B88_02 ; 07

JumpTable_5B3F_02:
    call toc_02_5B75
    ld   c, $0F
    ld   b, $00
JumpTable_5B3F_02.loop_02_5B46:
    ld   hl, $C340
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   nz, .else_02_5B6E

    ld   hl, $C280
    add  hl, bc
    ld   a, [hl]
    cp   $05
    jr   c, .else_02_5B6E

    ld   [hl], $01
    ld   hl, $C480
    add  hl, bc
    ld   [hl], $1F
    ld   hl, $C340
    add  hl, bc
    ld   a, [hl]
    and  %11110000
    or   $02
    ld   [hl], a
    assign [$FFF4], $13
JumpTable_5B3F_02.else_02_5B6E:
    dec  c
    ld   a, c
    cp   $FF
    jr   nz, .loop_02_5B46

    ret


toc_02_5B75:
    ld   a, [$FFF8]
    and  %00010000
    jr   nz, .else_02_5B86

    ifNot [$C18F], .else_02_5B86

    clear [$C18E]
    ret


toc_02_5B75.else_02_5B86:
    pop  af
    ret


JumpTable_5B88_02:
    call toc_02_5B75
    ld   a, $2F
    call toc_01_3C01
    ld   hl, $C200
    add  hl, de
    ld   [hl], $88
    ld   hl, $C210
    add  hl, de
    ld   [hl], $30
    ld   hl, $C450
    add  hl, de
    ld   [hl], $80
    assign [$FFD7], $88
    assign [$FFD8], $30
    ld   a, $02
    jp   JumpTable_5BAF_02.toc_02_5BBC

JumpTable_5BAF_02:
    call toc_02_5B75
    assign [$FFD7], $88
    assign [$FFD8], $20
    ld   a, $04
JumpTable_5BAF_02.toc_02_5BBC:
    call toc_01_0953
    call toc_02_5987
    ld   a, [hl]
    or   $10
    ld   [hl], a
    ld   [$FFF8], a
JumpTable_5BAF_02.return_02_5BC8:
    ret


JumpTable_5BC9_02:
    call toc_02_5B75
    ifNe [$FFF6], $69, .else_02_5BDB

    call toc_02_5987
    ld   a, [hl]
    or   $10
    ld   [hl], a
    ld   [$FFF8], a
JumpTable_5BC9_02.else_02_5BDB:
    call toc_02_5260
    ret


JumpTable_5BDF_02:
    ld   a, [$FFF7]
    ld   e, a
    ld   d, $00
    ld   hl, $DB65
    add  hl, de
    ld   a, [hl]
    and  %00000001
    jr   nz, .return_02_5C3C

JumpTable_5BDF_02.JumpTable_5BED_02:
    ld   a, [$C190]
    and  a
    jr   nz, .else_02_5BF6

    call toc_02_5C3D
JumpTable_5BDF_02.else_02_5BF6:
    ifNot [$C18F], .return_02_5C3C

    ifNe [$C18E], $C1, .else_02_5C2A

    ld   a, [$FFF7]
    ld   e, a
    ld   d, $00
    ld   hl, $DB65
    add  hl, de
    ld   a, [hl]
    or   $01
    ld   [hl], a
    ld   d, $00
    ld   a, [$FFF6]
    ld   e, a
    ld   hl, $D900
    ifGte [$FFF7], $1A, .else_02_5C23

    cp   $06
    jr   c, .else_02_5C23

    inc  d
JumpTable_5BDF_02.else_02_5C23:
    add  hl, de
    set  5, [hl]
    assign [$FFF2], $1B
JumpTable_5BDF_02.else_02_5C2A:
    ifNot [$C190], .return_02_5C3C

    clear [$C18E]
    assign [$C18C], $01
    call toc_02_525B
JumpTable_5BDF_02.return_02_5C3C:
    ret


toc_02_5C3D:
    ld   a, [hLinkPositionX]
    sub  a, $11
    cp   126
    jr   nc, .return_02_5C64

    ld   a, [hLinkPositionY]
    sub  a, $16
    cp   94
    jr   nc, .return_02_5C64

    ld   a, [$C18F]
    and  a
    jr   nz, .return_02_5C64

    assign [$C18D], $01
    ld   [$C190], a
    assign [$C111], $04
    assign [$FFF4], $10
toc_02_5C3D.return_02_5C64:
    ret


    db   $60, $70, $61, $71

JumpTable_5C69_02:
    call toc_02_5B75
    assign [$FFD7], $88
    ld   a, [hLinkPositionY]
    sub  a, $30
    add  a, $08
    cp   16
    jr   nc, .else_02_5C88

    ld   a, [hLinkPositionX]
    sub  a, $88
    add  a, $10
    cp   32
    jr   nc, .else_02_5C88

    ld   a, $40
    jr   .toc_02_5C8A

JumpTable_5C69_02.else_02_5C88:
    ld   a, $30
JumpTable_5C69_02.toc_02_5C8A:
    ld   [$FFD8], a
    ld   a, $03
    call toc_01_0953
    ret


toc_02_5C92:
    ld   a, [hLinkPositionY]
    sub  a, $30
    add  a, $08
    cp   16
    jr   nc, .else_02_5CAA

    ld   a, [hLinkPositionX]
    sub  a, $88
    add  a, $10
    cp   32
    jr   nc, .else_02_5CAA

    ld   a, $30
    jr   .toc_02_5CAC

toc_02_5C92.else_02_5CAA:
    ld   a, $20
toc_02_5C92.toc_02_5CAC:
    ld   [hSwordIntersectedAreaY], a
    assign [hSwordIntersectedAreaX], $80
    swap a
    and  %00001111
    ld   e, a
    ld   a, [hSwordIntersectedAreaY]
    and  %11110000
    or   e
    ld   e, a
    ld   d, $00
    ld   hl, $D711
    add  hl, de
    ld   a, $A0
    ld   [hl], a
    call toc_01_2839
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    ld   hl, $D601
    add  hl, de
    add  a, $0A
    ld   [$D600], a
    ld   de, $5C65
toc_02_5C92.toc_02_5CDB:
    ld   a, [$FFCF]
    ldi  [hl], a
    ld   a, [$FFD0]
    ldi  [hl], a
    ld   a, $81
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
    inc  a
    ldi  [hl], a
    ld   a, $81
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    ldi  [hl], a
    xor  a
    ld   [hl], a
    ret


    db   $6A, $7A, $6B, $7B

toc_02_5D00:
    assign [$FFAC], $01
    assign [hSwordIntersectedAreaY], $10
    add  a, $10
    ld   [$FFAE], a
    assign [hSwordIntersectedAreaX], $80
    add  a, $08
    ld   [$FFAD], a
    swap a
    and  %00001111
    ld   e, a
    ld   a, [hSwordIntersectedAreaY]
    and  %11110000
    or   e
    ld   e, a
    ld   d, $00
    ld   hl, $D711
    add  hl, de
    ld   a, $BE
    ld   [hl], a
    call toc_01_2839
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    ld   hl, $D601
    add  hl, de
    add  a, $0A
    ld   [$D600], a
    ld   de, $5CFC
    jr   toc_02_5C92.toc_02_5CDB

toc_02_5D3F:
    and  %00011111
    ld   [$FFD7], a
    dec  a
    jumptable
    dw JumpTable_5D9C_02 ; 00
    dw JumpTable_5D63_02 ; 01
    dw JumpTable_5D81_02 ; 02
    dw JumpTable_5D63_02 ; 03
    dw JumpTable_5D78_02 ; 04
    dw JumpTable_5D89_02 ; 05
    dw JumpTable_5D63_02 ; 06
    dw JumpTable_5D9C_02 ; 07
    dw JumpTable_5D63_02 ; 08
    dw JumpTable_5D64_02 ; 09
    dw JumpTable_5D63_02 ; 0A
    dw JumpTable_5D63_02 ; 0B
    dw JumpTable_5D63_02 ; 0C
    dw JumpTable_5D63_02 ; 0D
    dw JumpTable_5D63_02 ; 0E

JumpTable_5D63_02:
    ret


JumpTable_5D64_02:
    ifNe [$FFF7], $06, .else_02_5D6F

    ld   a, [$DAE8]
    jr   .toc_02_5D72

JumpTable_5D64_02.else_02_5D6F:
    ld   a, [$D9FF]
JumpTable_5D64_02.toc_02_5D72:
    and  %00100000
    jp   nz, toc_01_08EC

    ret


JumpTable_5D78_02:
    ld   a, [$C1A2]
    cp   $02
    jp   z, toc_01_08EC

    ret


JumpTable_5D81_02:
    ld   a, [$C1CB]
    and  a
    jp   nz, toc_01_08EC

    ret


JumpTable_5D89_02:
    ld   c, $00
    ld   hl, $DBB6
JumpTable_5D89_02.loop_02_5D8E:
    ldi  a, [hl]
    cp   c
    jr   nz, .return_02_5D9B

    inc  c
    ld   a, c
    cp   $03
    jr   nz, .loop_02_5D8E

    call toc_01_08EC
JumpTable_5D89_02.return_02_5D9B:
    ret


JumpTable_5D9C_02:
    ld   c, $0F
    ld   b, $00
JumpTable_5D9C_02.loop_02_5DA0:
    ld   hl, $C280
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_02_5DB1

    ld   hl, $C430
    add  hl, bc
    ld   a, [hl]
    and  %00000010
    jr   z, .return_02_5DCC

JumpTable_5D9C_02.else_02_5DB1:
    dec  c
    ld   a, c
    cp   $FF
    jr   nz, .loop_02_5DA0

    ifNe [$FFD7], $08, .else_02_5DC9

    ifNot [$D460], .return_02_5DCC

    ld   a, [$C113]
    and  a
    jr   nz, .return_02_5DCC

JumpTable_5D9C_02.else_02_5DC9:
    jp   toc_01_08EC

JumpTable_5D9C_02.return_02_5DCC:
    ret


toc_02_5DCD:
    ld   a, [de]
    cp   [hl]
    jr   c, .else_02_5DD3

    ld   a, [hl]
    ld   [de], a
toc_02_5DCD.else_02_5DD3:
    inc  hl
    ret


toc_02_5DD5:
    ld   hl, $DB76
    ld   de, $DB4C
    call toc_02_5DCD
    ld   de, $DB4D
    call toc_02_5DCD
    ld   de, $DB45
    call toc_02_5DCD
    returnIfGte [$C11C], $02

    ld   a, [wDialogState]
    and  a
    jp   nz, .else_02_5EDC

    ld   a, [$C124]
    and  a
    jp   nz, .return_02_5EF1

    ld   a, [$C14F]
    and  a
    jp   nz, .toc_02_5E83

    ld   a, [hPressedButtonsMask]
    and  %01000000
    jp   nz, .toc_02_5EC8

    ld   a, [$FFCC]
    and  %10000000
    jp   z, .toc_02_5EC8

    ifEq [$DB9A], $00, .else_02_5E2E

    ld   a, [$C167]
    and  a
    jp   nz, .toc_02_5EC8

    ld   a, [hLinkInteractiveMotionBlocked]
    cp   INTERACTIVE_MOTION_LOCKED_TALKING
    jp   z, .toc_02_5EC8

    ld   a, [hLinkAnimationState]
    inc  a
    jp   z, .toc_02_5EC8

toc_02_5DD5.else_02_5E2E:
    ld   a, [$C1B5]
    ld   hl, $C1B8
    or   [hl]
    ld   hl, $C1B9
    or   [hl]
    jp   nz, .toc_02_5EC8

toc_02_5DD5.toc_02_5E3C:
    assign [$C14F], $01
    ld   [$C151], a
    assign [$FFF2], $12
    ld   a, [$C150]
    cpl
    inc  a
    ld   [$C150], a
    and  %10000000
    jr   z, .else_02_5E79

    assign [$FFF2], $11
    clear [$C151]
    assign [$C154], $0B
    ld   a, [$DBA5]
    and  a
    ld   a, $07
    jr   z, .else_02_5E76

    ld   a, [$FFF7]
    cp   $08
    ld   a, $07
    jr   nc, .else_02_5E76

    call toc_02_6A9B
    ld   a, $02
toc_02_5DD5.else_02_5E76:
    ld   [hNeedsUpdatingBGTiles], a
    ret


toc_02_5DD5.else_02_5E79:
    assign [hVolumeRight], $07
    assign [hVolumeLeft], $70
    pop  af
    ret


toc_02_5DD5.toc_02_5E83:
    ld   a, [$C151]
    and  a
    jr   nz, .else_02_5EA4

    ld   a, [$D601]
    and  a
    jr   nz, .else_02_5E96

    call toc_02_631F
    incAddr $C151
toc_02_5DD5.else_02_5E96:
    pop  af
toc_02_5DD5.toc_02_5E97:
    call toc_02_77FA.else_02_781B
    call toc_01_149B.toc_01_149E
    call JumpTable_1C56_00.toc_01_1CCC
    call toc_01_0B2B
    ret


toc_02_5DD5.else_02_5EA4:
    call toc_02_5EF2
    ld   a, [$C150]
    ld   hl, $DB9A
    add  a, [hl]
    ld   [hl], a
    cp   $80
    jr   z, .else_02_5EBF

    cp   $00
    jr   nz, .else_02_5EC5

    assign [hVolumeRight], $03
    assign [hVolumeLeft], $30
toc_02_5DD5.else_02_5EBF:
    clear [$C14F]
    jr   .toc_02_5EC8

toc_02_5DD5.else_02_5EC5:
    call .toc_02_5E97
toc_02_5DD5.toc_02_5EC8:
    ifEq [$DB9A], $80, .else_02_5EDC

    ld   a, [$C14F]
    and  a
    jr   nz, .else_02_5EDB

    call toc_02_645E
    call toc_02_63F0
toc_02_5DD5.else_02_5EDB:
    pop  af
toc_02_5DD5.else_02_5EDC:
    ld   a, [wDialogState]
    and  %01111111
    jr   z, .else_02_5EEB

    cp   $0C
    jr   z, .else_02_5EEB

    cp   $0D
    jr   nz, .return_02_5EF1

toc_02_5DD5.else_02_5EEB:
    call toc_02_5F09
    call toc_02_601A
toc_02_5DD5.return_02_5EF1:
    ret


toc_02_5EF2:
    ifEq [$C154], $01, .return_02_5F08

    ld   c, a
    ld   b, $00
    dec  a
    ld   e, a
    call toc_02_61E7.toc_02_61ED
    ld   a, [$C154]
    dec  a
    ld   [$C154], a
toc_02_5EF2.return_02_5F08:
    ret


toc_02_5F09:
    ld   hl, $D600
    ld   a, [hFrameCounter]
    and  %00000001
    or   [hl]
    ret  nz

    ld   hl, $C3CE
    ld   a, [hl]
    and  a
    jr   z, .else_02_5F1B

    dec  [hl]
    ret


toc_02_5F09.else_02_5F1B:
    ld   hl, $DB8F
    ld   a, [$DB90]
    or   [hl]
    jr   z, .else_02_5F74

    assign [$FFF3], $05
    ld   a, [$DB90]
    ld   e, a
    ld   a, [$DB8F]
    sla  e
    rla
    sla  e
    rla
    sla  e
    rla
    inc  a
    cp   $0A
    jr   c, .else_02_5F3F

    ld   a, $09
toc_02_5F09.else_02_5F3F:
    ld   e, a
    ld   a, [$DB90]
    sub  a, e
    ld   [$DB90], a
    ld   a, [hl]
    sbc  $00
    ld   [hl], a
    ld   a, [$DB5E]
    add  a, e
    daa
    ld   [$DB5E], a
    ld   a, [$DB5D]
    adc  $00
    daa
    ld   [$DB5D], a
    cp   $10
    jr   c, .else_02_5F71

    assign [$DB5D], $09
    assign [$DB5E], $99
    clear [$DB8F]
    ld   [$DB90], a
toc_02_5F09.else_02_5F71:
    call toc_02_5FD1
toc_02_5F09.else_02_5F74:
    ld   hl, $DB91
    ld   a, [$DB92]
    or   [hl]
    jr   z, .return_02_5FD0

    assign [$FFF3], $05
    ld   a, [$DB92]
    ld   e, a
    ld   a, [$DB91]
    sla  e
    rla
    sla  e
    rla
    sla  e
    rla
    inc  a
    cp   $0A
    jr   c, .else_02_5F98

    ld   a, $09
toc_02_5F09.else_02_5F98:
    ld   e, a
    ld   a, [$DB92]
    sub  a, e
    ld   [$DB92], a
    ld   a, [hl]
    sbc  $00
    ld   [hl], a
    ld   a, [$DB5E]
    ld   hl, $DB5D
    or   [hl]
    jr   z, .return_02_5FD0

    ld   a, [$DB5E]
    sub  a, e
    daa
    ld   [$DB5E], a
    ld   a, [$DB5D]
    sbc  $00
    daa
    ld   [$DB5D], a
    jr   nc, .else_02_5FCD

    clear [$DB5D]
    ld   [$DB5E], a
    ld   [$DB91], a
    ld   [$DB92], a
toc_02_5F09.else_02_5FCD:
    call toc_02_5FD1
toc_02_5F09.return_02_5FD0:
    ret


toc_02_5FD1:
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    add  a, $06
    ld   [$D600], a
    ld   hl, $D601
    add  hl, de
    ld   a, $9C
    ldi  [hl], a
    ld   a, $2A
    ldi  [hl], a
    ld   a, $02
    ldi  [hl], a
    push hl
    ld   a, [$DB5D]
    and  %00001111
    ld   e, a
    add  a, $B0
    pop  hl
    ldi  [hl], a
    push hl
    ld   a, [$DB5E]
    swap a
    and  %00001111
    add  a, $B0
    pop  hl
    ldi  [hl], a
    push hl
    ld   a, [$DB5E]
    and  %00001111
    add  a, $B0
    pop  hl
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    ret


    db   $05, $05, $05, $09, $09, $09, $11, $11
    db   $11, $19, $19, $19

toc_02_601A:
    clear [$C163]
    ld   a, [$DB5B]
    ld   e, a
    ld   d, $00
    ld   hl, $600B
    add  hl, de
    ld   a, [$DB5A]
    cp   [hl]
    jr   nc, .else_02_6045

    assign [$C163], $01
    ld   a, [$C110]
    dec  a
    cp   $FF
    jr   nz, .else_02_6042

    ld   a, $30
    ld   hl, $FFF3
    ld   [hl], $04
toc_02_601A.else_02_6042:
    ld   [$C110], a
toc_02_601A.else_02_6045:
    ld   a, [hFrameCounter]
    and  %00000001
    jr   z, .return_02_60A5

    ld   a, [$D600]
    and  a
    jr   nz, .return_02_60A5

    ifNot [$DB93], .else_02_6088

    dec  a
    ld   [$DB93], a
    ifLt [$DB5B], $0F, .else_02_6064

    ld   a, $0E
toc_02_601A.else_02_6064:
    sla  a
    sla  a
    sla  a
    ld   e, a
    ld   a, [$DB5A]
    cp   e
    jr   nz, .else_02_6077

    clear [$DB93]
    jr   .else_02_6088

toc_02_601A.else_02_6077:
    inc  a
    ld   [$DB5A], a
    and  %00000111
    cp   $06
    jr   nz, .else_02_6085

    assign [$FFF3], $06
toc_02_601A.else_02_6085:
    jp   toc_02_6117

toc_02_601A.else_02_6088:
    ifNot [$DB94], .return_02_60A5

    dec  a
    ld   [$DB94], a
    ifNot [$DB5A], .else_02_609C

    dec  a
    ld   [$DB5A], a
toc_02_601A.else_02_609C:
    call toc_02_6117
    ifNot [$DB5A], .else_02_60A6

toc_02_601A.return_02_60A5:
    ret


toc_02_601A.else_02_60A6:
    ifNot [$DB0D], .return_02_6101

    dec  a
    ld   [$DB0D], a
    assign [$DB5A], $08
    ld   a, [$DB93]
    add  a, $80
    ld   [$DB93], a
    assign [$DBC7], $A0
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    add  a, $04
    ld   [$D600], a
    ld   hl, $D601
    add  hl, de
    ld   a, $9C
    ldi  [hl], a
    ld   a, $93
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    ld   a, [$DB0D]
    add  a, $B0
    cp   $B0
    jr   z, .else_02_60E7

    ldi  [hl], a
    xor  a
    ld   [hl], a
    ret


toc_02_601A.else_02_60E7:
    ld   a, $7F
    ldi  [hl], a
    ld   a, $9C
    ldi  [hl], a
    ld   a, $72
    ldi  [hl], a
    ld   a, $C1
    ldi  [hl], a
    ld   a, $7F
    ldi  [hl], a
    xor  a
    ld   [hl], a
    ld   a, [$D600]
    add  a, $04
    ld   [$D600], a
    ret


toc_02_601A.return_02_6101:
    ret


    db   $9C, $0D, $06, $7F, $7F, $7F, $7F, $7F
    db   $7F, $7F, $9C, $2D, $06, $7F, $7F, $7F
    db   $7F, $7F, $7F, $7F, $00

toc_02_6117:
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    add  a, $14
    ld   [$D600], a
    ld   hl, $D601
    add  hl, de
    push de
    ld   bc, $6102
    ld   e, $15
toc_02_6117.loop_02_612C:
    ld   a, [bc]
    inc  bc
    ldi  [hl], a
    dec  e
    jr   nz, .loop_02_612C

    nop
    nop
    nop
    nop
    pop  de
    ld   hl, $D604
    add  hl, de
    ld   c, $00
    ifNot [$DB5A], .else_02_6165

    ld   [$FFD7], a
toc_02_6117.toc_02_6145:
    ld   a, [$FFD7]
    sub  a, $08
    ld   [$FFD7], a
    jr   c, .else_02_615C

    ld   a, $A9
    ldi  [hl], a
    inc  c
    ld   a, c
    cp   $07
    jr   nz, .else_02_615A

    ld   a, l
    add  a, $03
    ld   l, a
toc_02_6117.else_02_615A:
    jr   .toc_02_6145

toc_02_6117.else_02_615C:
    add  a, $08
    jr   z, .else_02_6165

    ld   a, $CE
    ldi  [hl], a
    jr   .toc_02_616E

toc_02_6117.else_02_6165:
    ld   a, [$DB5B]
    cp   c
    jr   z, .return_02_617A

    ld   a, $CD
    ldi  [hl], a
toc_02_6117.toc_02_616E:
    inc  c
    ld   a, c
    cp   $07
    jr   nz, .else_02_6178

    ld   a, l
    add  a, $03
    ld   l, a
toc_02_6117.else_02_6178:
    jr   .else_02_6165

toc_02_6117.return_02_617A:
    ret


    db   $7F, $7F, $7F, $7F, $7F, $7F, $84, $7F
    db   $7F, $85, $BA, $7F, $80, $7F, $7F, $81
    db   $7F, $7F, $82, $7F, $7F, $83, $BA, $7F
    db   $86, $7F, $7F, $87, $BA, $7F, $88, $7F
    db   $7F, $89, $7F, $7F, $8A, $7F, $7F, $8B
    db   $7F, $7F, $8C, $7F, $7F, $8D, $7F, $7F
    db   $98, $7F, $7F, $99, $7F, $7F, $90, $7F
    db   $7F, $91, $7F, $7F, $92, $7F, $7F, $93
    db   $7F, $7F, $96, $7F, $7F, $97, $7F, $7F
    db   $8E, $7F, $7F, $8F, $7F, $7F, $A4, $7F
    db   $7F, $A5, $7F, $7F, $9C, $01, $9C, $06
    db   $9C, $61, $9C, $65, $9C, $C1, $9C, $C5
    db   $9D, $21, $9D, $25, $9D, $81, $9D, $85
    db   $9D, $E1, $9D, $E5

toc_02_61E7:
    ld   c, $01
    ld   b, $00
    ld   e, $FF
toc_02_61E7.toc_02_61ED:
    ld   a, [DEBUG_TOOL2]
    and  a
    ret  nz

    push de
    push bc
    ld   hl, $DB00
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD8], a
    sla  a
    ld   e, a
    sla  a
    add  a, e
    ld   [$FFD7], a
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    ld   hl, $D601
    add  hl, de
    add  a, $0C
    ld   [$D600], a
    push hl
    sla  c
    ld   hl, $61CF
    add  hl, bc
    push hl
    pop  de
    pop  hl
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, $02
    ldi  [hl], a
    ld   a, [$FFD7]
    ld   c, a
    push hl
    ld   hl, $617B
    add  hl, bc
    push hl
    pop  de
    pop  hl
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    pop  bc
    push bc
    push hl
    sla  c
    ld   hl, $61CF
    add  hl, bc
    push hl
    pop  de
    pop  hl
    inc  de
    inc  hl
    ld   a, [de]
    add  a, $20
    ld   [hl], a
    dec  de
    dec  hl
    ld   a, [de]
    inc  de
    inc  de
    adc  $00
    ldi  [hl], a
    inc  hl
    ld   a, $02
    ldi  [hl], a
    ld   a, [$FFD7]
    ld   c, a
    push hl
    ld   hl, $617E
    add  hl, bc
    push hl
    pop  de
    pop  hl
    ld   a, [de]
    inc  de
    ldi  [hl], a
    call toc_02_6273
    xor  a
    ld   [hl], a
    pop  bc
    pop  de
    dec  c
    ld   a, c
    cp   e
    jp   nz, .toc_02_61ED

    ret


toc_02_6273:
    ifEq [$FFD8], $09, .else_02_62B5

    cp   $0C
    jr   z, .else_02_62AA

    dec  a
    jr   z, .else_02_629D

    dec  a
    jr   z, .else_02_62CF

    dec  a
    jr   z, .else_02_6293

    dec  a
    jr   z, .else_02_6298

    dec  a
    jr   z, .else_02_62CA

toc_02_6273.loop_02_628C:
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ret


toc_02_6273.else_02_6293:
    ld   a, [$DB43]
    jr   .toc_02_62A0

toc_02_6273.else_02_6298:
    ld   a, [$DB44]
    jr   .toc_02_62A0

toc_02_6273.else_02_629D:
    ld   a, [$DB4E]
toc_02_6273.toc_02_62A0:
    add  a, $B0
    ld   c, a
    ld   a, [de]
    inc  de
    ldi  [hl], a
    ld   a, c
    inc  de
    ldi  [hl], a
    ret


toc_02_6273.else_02_62AA:
    ld   a, [$DB4B]
    and  a
    jr   nz, .loop_02_628C

    ld   a, [$DB4C]
    jr   .toc_02_62D2

toc_02_6273.else_02_62B5:
    ld   a, [$DB49]
    and  a
    jp   z, .loop_02_628C

    ld   a, [$DB4A]
    inc  a
    swap a
    call .toc_02_62D2
    dec  hl
    ld   [hl], $7F
    inc  hl
    ret


toc_02_6273.else_02_62CA:
    ld   a, [$DB45]
    jr   .toc_02_62D2

toc_02_6273.else_02_62CF:
    ld   a, [$DB4D]
toc_02_6273.toc_02_62D2:
    push af
    and  %00001111
    add  a, $B0
    ld   c, a
    pop  af
    swap a
    and  %00001111
    add  a, $B0
    ldi  [hl], a
    ld   a, c
    ldi  [hl], a
    ret


    db   $9C, $6A, $83, $94, $95, $C0, $C1, $9C
    db   $6C, $83, $A0, $A1, $C2, $C3, $9C, $6E
    db   $83, $9A, $9B, $C4, $C5, $9C, $6F, $81
    db   $9C, $9D, $9C, $B0, $81, $C6, $C7, $9C
    db   $71, $81, $9E, $9F, $9C, $B2, $81, $CA
    db   $CB, $9C, $92, $01, $7F, $7F, $9C, $D3
    db   $00, $7F, $00, $03, $0A, $11, $22, $05
    db   $0C, $13, $1D, $27

toc_02_631F:
    ld   hl, $D601
    ld   bc, $62E3
    ld   e, $33
toc_02_631F.loop_02_6327:
    ld   a, [bc]
    inc  bc
    ldi  [hl], a
    dec  e
    jr   nz, .loop_02_6327

    ld   de, $DB0C
    ld   bc, $0000
toc_02_631F.loop_02_6333:
    ld   a, c
    cp   $02
    jr   nz, .else_02_633F

    ld   a, [$DB7F]
    and  a
    ld   a, c
    jr   nz, .else_02_635F

toc_02_631F.else_02_633F:
    cp   $04
    jr   nz, .else_02_6357

    ifNot [$DBA5], .else_02_6354

    ifGte [$FFF7], $0A, .else_02_6354

    ld   de, $DBCC
    jr   .else_02_6357

toc_02_631F.else_02_6354:
    ld   de, $DB11
toc_02_631F.else_02_6357:
    ld   a, [de]
    cp   $FF
    jr   z, .else_02_635F

    and  a
    jr   nz, .else_02_637E

toc_02_631F.else_02_635F:
    push de
    ld   hl, $6316
    add  hl, bc
    ld   e, [hl]
    ld   d, $00
    ld   hl, $D601
    add  hl, de
    ld   a, $7F
    ldi  [hl], a
    ldi  [hl], a
    ld   a, c
    cp   $02
    jr   nz, .else_02_637D

    inc  hl
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    ld   a, $7F
    ldi  [hl], a
    ld   [hl], a
toc_02_631F.else_02_637D:
    pop  de
toc_02_631F.else_02_637E:
    inc  de
    inc  c
    ld   a, c
    cp   $09
    jr   nz, .loop_02_6333

    ld   hl, $D601
    ld   de, $002C
    add  hl, de
    ifNot [$DB0F], .else_02_63A0

    ld   e, a
    swap a
    and  %00001111
    add  a, $B0
    ldi  [hl], a
    ld   a, e
    and  %00001111
    add  a, $B0
    ldi  [hl], a
toc_02_631F.else_02_63A0:
    ld   hl, $D601
    ld   de, $0031
    add  hl, de
    ifNot [$DBA5], .else_02_63BB

    ifGte [$FFF7], $0A, .else_02_63BB

    ifNot [$DBD0], .else_02_63C8

    jr   .toc_02_63C5

toc_02_631F.else_02_63BB:
    ifNot [$DB15], .else_02_63C8

    cp   $06
    jr   nc, .else_02_63C8

toc_02_631F.toc_02_63C5:
    add  a, $B0
    ld   [hl], a
toc_02_631F.else_02_63C8:
    assign [$D600], $32
    ret


    db   $0F, $37, $0F, $2F, $0F, $2F, $0F, $2F
    db   $0F, $2F, $0F, $2F, $0E, $0E, $26, $26
    db   $3E, $3E, $56, $56, $6E, $6E, $86, $86

toc_02_63E6:
    returnIfLt [$DB97], $E4

    ld   d, $02
    jr   toc_02_63F0.toc_02_63F2

toc_02_63F0:
    ld   d, $0C
toc_02_63F0.toc_02_63F2:
    ld   hl, $DB00
    ld   e, $00
toc_02_63F0.loop_02_63F7:
    ldi  a, [hl]
    cp   $01
    jr   z, .else_02_6402

    inc  e
    ld   a, e
    cp   d
    jr   nz, .loop_02_63F7

    ret


toc_02_63F0.else_02_6402:
    ld   d, $00
    ld   hl, $63CE
    add  hl, de
    ld   a, [hl]
    ld   [$FFD7], a
    ld   hl, $63DA
    add  hl, de
    ld   a, [hl]
    ld   [$FFD8], a
    ld   a, [$D47C]
    dec  a
    jr   nz, .else_02_6444

    ld   a, [hFrameCounter]
    and  %00001000
    jr   nz, .else_02_6444

    ld   a, [$C3C0]
    ld   e, a
    ld   d, $00
    ld   hl, $C030
    add  hl, de
    ifNot [$C1B5], .else_02_6431

    ld   hl, $C09C
toc_02_63F0.else_02_6431:
    ld   a, [$DB9A]
    push hl
    ld   hl, $FFD8
    add  a, [hl]
    pop  hl
    ldi  [hl], a
    ld   a, [$FFD7]
    ldi  [hl], a
    ld   a, $04
    ldi  [hl], a
    ld   a, $50
    ldi  [hl], a
toc_02_63F0.else_02_6444:
    ld   a, $01
    call toc_01_3DD0
    ret


    db   $07, $27, $07, $27, $07, $27, $07, $27
    db   $07, $27, $28, $28, $40, $40, $58, $58
    db   $70, $70, $88, $88

toc_02_645E:
    ifNot [$DBA5], .else_02_64B8

    ld   a, [$FFF7]
    cp   $08
    jp   nc, .toc_02_64BB

    ld   a, [$D46B]
    and  %11111000
    add  a, $58
    ld   h, a
    ld   a, [$D46B]
    rla
    rla
    rla
    and  %00111000
    add  a, $57
    ld   l, a
    ld   a, [$DBB0]
    and  %00100000
    jr   z, .else_02_6492

    ld   a, [$D46B]
    and  %00111000
    cp   $20
    jr   nc, .else_02_6492

    ld   a, h
    sub  a, $08
    ld   h, a
toc_02_645E.else_02_6492:
    ld   a, [$DBB0]
    and  %00010000
    jr   z, .else_02_64A6

    ld   a, [$D46B]
    and  %00000111
    cp   $04
    jr   c, .else_02_64A6

    ld   a, l
    add  a, $08
    ld   l, a
toc_02_645E.else_02_64A6:
    ld   a, h
    ld   [gbRAM], a
    ld   a, l
    ld   [$C001], a
    assign [$C002], $3F
    ld   a, [hFrameCounter]
    rla
    and  %00010000
toc_02_645E.else_02_64B8:
    ld   [$C003], a
toc_02_645E.toc_02_64BB:
    call toc_02_6505
    call toc_02_6742
    ld   a, [$C159]
    inc  a
    ld   [$C159], a
    and  %00010000
    jr   nz, .return_02_64FC

    ld   a, [$DBA3]
    ld   e, a
    ld   d, $00
    ld   hl, $6454
    add  hl, de
    ld   a, [hl]
    ld   [$C004], a
    ld   [$C008], a
    ld   hl, $644A
    add  hl, de
    ld   a, [hl]
    ld   [$C005], a
    add  a, $20
    ld   [$C009], a
    assign [$C006], $BE
    ld   [$C00A], a
    assign [$C007], $30
    assign [$C00B], $10
toc_02_645E.return_02_64FC:
    ret


    db   $00, $01, $FF, $00, $00, $FE, $02, $00

toc_02_6505:
    copyFromTo [$DBA3], [$C1B6]
    ld   a, [$C1B8]
    ld   hl, $C1B9
    or   [hl]
    jr   nz, .else_02_655E

    ld   a, [$C1B5]
    and  a
    jr   nz, .else_02_653A

    ld   a, [$FFCC]
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $64FD
    add  hl, de
    ld   a, [$DBA3]
    add  a, [hl]
    ld   [$DBA3], a
    cp   $0A
    jr   c, .else_02_653A

    rla
    ld   a, $00
    jr   nc, .else_02_6537

    ld   a, $09
toc_02_6505.else_02_6537:
    ld   [$DBA3], a
toc_02_6505.else_02_653A:
    ld   a, [$FFCC]
    srl  a
    srl  a
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $6501
    add  hl, de
    ld   a, [$DBA3]
    add  a, [hl]
    ld   [$DBA3], a
    cp   $0A
    jr   c, .else_02_655E

    rla
    ld   a, $00
    jr   nc, .else_02_655B

    ld   a, $09
toc_02_6505.else_02_655B:
    ld   [$DBA3], a
toc_02_6505.else_02_655E:
    ld   a, [hPressedButtonsMask]
    and  %00001111
    jr   z, .else_02_656E

    ld   a, [$C1B5]
    and  a
    jr   nz, .else_02_656E

    clear [$C159]
toc_02_6505.else_02_656E:
    ifNot [$C1B5], .else_02_658A

    ld   a, [$C1B8]
    ld   hl, $C1B9
    or   [hl]
    jr   nz, .else_02_658A

    ld   a, [$FFCC]
    and  %10000000
    jr   z, .else_02_658A

    assign [$C1BA], $01
    jr   .else_02_65B7

toc_02_6505.else_02_658A:
    ld   a, [$DBA3]
    ld   hl, $C1B6
    cp   [hl]
    jr   z, .else_02_65C6

    ld   hl, $FFF2
    ld   [hl], $0A
    ld   e, a
    ld   d, $00
    ld   hl, $DB02
    add  hl, de
    ld   a, [hl]
    cp   $09
    jr   nz, .else_02_65B7

    ifNot [$DB49], .else_02_65B7

    assign [hNeedsUpdatingBGTiles], $08
    assign [$C1B8], $10
    ld   a, $01
    jr   .toc_02_65C3

toc_02_6505.else_02_65B7:
    ifNot [$C1B5], .else_02_65C6

    assign [$C1B9], $10
    xor  a
toc_02_6505.toc_02_65C3:
    ld   [$C1B5], a
toc_02_6505.else_02_65C6:
    ld   hl, $C1B9
    ld   a, [$C1B8]
    or   [hl]
    jp   nz, .return_02_667B

    ld   a, [$FFCC]
    and  %00010000
    jr   z, .else_02_661E

    ld   a, [$DB01]
    push af
    ld   hl, $DB02
    ld   a, [$DBA3]
    ld   c, a
    ld   b, $00
    add  hl, bc
    ld   a, [hl]
    ld   [$DB01], a
    pop  af
    ld   [hl], a
    cp   $09
    jr   nz, .else_02_6604

    ifNot [$DB49], .else_02_6604

    assign [hNeedsUpdatingBGTiles], $08
    assign [$C1B8], $10
    assign [$C1B5], $01
    jr   .else_02_6613

toc_02_6505.else_02_6604:
    ifNot [$C1B5], .else_02_6613

    clear [$C1B5]
    assign [$C1B9], $10
toc_02_6505.else_02_6613:
    ld   c, $01
    ld   b, $00
    ld   e, $00
    call toc_02_61E7.toc_02_61ED
    jr   .toc_02_666A

toc_02_6505.else_02_661E:
    ld   a, [$FFCC]
    and  %00100000
    jr   z, .return_02_667B

    ld   a, [$DB00]
    push af
    ld   hl, $DB02
    ld   a, [$DBA3]
    ld   c, a
    ld   b, $00
    add  hl, bc
    ld   a, [hl]
    ld   [$DB00], a
    pop  af
    ld   [hl], a
    cp   $09
    jr   nz, .else_02_6652

    ifNot [$DB49], .else_02_6652

    assign [$C1B8], $10
    assign [hNeedsUpdatingBGTiles], $08
    assign [$C1B5], $01
    jr   .else_02_6661

toc_02_6505.else_02_6652:
    ifNot [$C1B5], .else_02_6661

    clear [$C1B5]
    assign [$C1B9], $10
toc_02_6505.else_02_6661:
    ld   c, $00
    ld   b, $00
    ld   e, $FF
    call toc_02_61E7.toc_02_61ED
toc_02_6505.toc_02_666A:
    assign [$FFF2], $13
    ld   a, [$DBA3]
    add  a, $02
    ld   c, a
    ld   b, $00
    dec  a
    ld   e, a
    call toc_02_61E7.toc_02_61ED
toc_02_6505.return_02_667B:
    ret


    db   $F8, $F0, $22, $00, $F8, $F8, $22, $20
    db   $F8, $00, $24, $00, $F8, $08, $24, $20
    db   $F8, $10, $26, $00, $F8, $18, $26, $20
    db   $08, $F0, $20, $00, $08, $F8, $20, $00
    db   $08, $00, $20, $00, $08, $08, $20, $00
    db   $08, $10, $20, $00, $08, $18, $20, $00
    db   $FB, $F4, $20, $00, $FB, $FC, $20, $20
    db   $FB, $00, $20, $00, $FB, $08, $20, $20
    db   $FB, $0C, $20, $00, $FB, $14, $20, $20
    db   $05, $F4, $20, $00, $05, $FC, $20, $00
    db   $05, $00, $20, $00, $05, $08, $20, $00
    db   $05, $0C, $20, $00, $05, $14, $20, $00
    db   $FD, $F8, $20, $00, $FD, $10, $20, $20
    db   $FD, $00, $20, $00, $FD, $08, $20, $20
    db   $FD, $08, $20, $00, $FD, $10, $20, $20
    db   $03, $F8, $20, $00, $03, $10, $20, $00
    db   $03, $00, $20, $00, $03, $08, $20, $00
    db   $03, $08, $20, $00, $03, $10, $20, $00
    db   $00, $00, $20, $00, $00, $08, $20, $20
    db   $00, $00, $20, $00, $00, $08, $20, $20
    db   $00, $00, $20, $00, $00, $08, $20, $20
    db   $00, $00, $20, $00, $00, $08, $20, $00
    db   $00, $00, $20, $00, $00, $08, $20, $00
    db   $00, $00, $20, $00, $00, $08, $20, $00
    db   $50, $60, $70, $04, $02, $01

toc_02_6742:
    ifNot [$C1B9], .else_02_6764

    dec  a
    ld   [$C1B9], a
    jr   nz, .else_02_6761

    ld   hl, hNeedsUpdatingBGTiles
    ld   [hl], $0B
    ifNot [$C1BA], .return_02_6760

    clear [$C1BA]
    jp   toc_02_5DD5.toc_02_5E3C

toc_02_6742.return_02_6760:
    ret


toc_02_6742.else_02_6761:
    cpl
    jr   .toc_02_676E

toc_02_6742.else_02_6764:
    ifNot [$C1B8], .else_02_6774

    dec  a
    ld   [$C1B8], a
toc_02_6742.toc_02_676E:
    rra
    rra
    and  %00000011
    jr   .toc_02_677D

toc_02_6742.else_02_6774:
    ld   a, [$C1B5]
    and  a
    jp   z, .return_02_684A

    ld   a, $00
toc_02_6742.toc_02_677D:
    ld   [$C1B7], a
    ld   a, [$C1B7]
    ld   d, $00
    sla  a
    sla  a
    sla  a
    sla  a
    ld   e, a
    sla  a
    add  a, e
    ld   e, a
    ld   hl, $667C
    add  hl, de
    ld   de, $C018
    ld   c, $0C
    ld   b, $04
toc_02_6742.loop_02_679D:
    ldi  a, [hl]
    add  a, $30
    ld   [de], a
    inc  de
    ldi  a, [hl]
    add  a, $60
    ld   [de], a
    inc  de
    ldi  a, [hl]
    ld   [de], a
    inc  de
    cp   $22
    jr   z, .else_02_67B8

    cp   $24
    jr   z, .else_02_67BC

    cp   $26
    jr   z, .else_02_67C0

    jr   .else_02_67CD

toc_02_6742.else_02_67B8:
    ld   b, $04
    jr   .toc_02_67C2

toc_02_6742.else_02_67BC:
    ld   b, $02
    jr   .toc_02_67C2

toc_02_6742.else_02_67C0:
    ld   b, $01
toc_02_6742.toc_02_67C2:
    ld   a, [$DB49]
    and  b
    jr   nz, .else_02_67CD

    dec  de
    ld   a, $20
    ld   [de], a
    inc  de
toc_02_6742.else_02_67CD:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop_02_679D

    ifNe [$C1B7], $00, .return_02_684A

    ld   a, [$FFCC]
    and  %01000001
    jr   z, .else_02_67F8

toc_02_6742.loop_02_67E0:
    ld   hl, $DB4A
    ld   a, [hl]
    inc  a
    cp   $03
    jr   nz, .else_02_67EA

    xor  a
toc_02_6742.else_02_67EA:
    ld   [hl], a
    ld   e, a
    ld   d, $00
    ld   hl, $673F
    add  hl, de
    ld   a, [$DB49]
    and  [hl]
    jr   z, .loop_02_67E0

toc_02_6742.else_02_67F8:
    ld   a, [$FFCC]
    and  %00000010
    jr   z, .else_02_6817

toc_02_6742.loop_02_67FE:
    ld   hl, $DB4A
    ld   a, [hl]
    dec  a
    cp   $80
    jr   c, .else_02_6809

    ld   a, $02
toc_02_6742.else_02_6809:
    ld   [hl], a
    ld   e, a
    ld   d, $00
    ld   hl, $673F
    add  hl, de
    ld   a, [$DB49]
    and  [hl]
    jr   z, .loop_02_67FE

toc_02_6742.else_02_6817:
    ld   a, [$DB4A]
    ld   a, [$FFCC]
    and  %01000011
    jr   z, .else_02_6823

    call toc_02_6505.toc_02_666A
toc_02_6742.else_02_6823:
    ld   hl, $C010
    ld   a, $38
    ldi  [hl], a
    push hl
    ld   a, [$DB4A]
    ld   e, a
    ld   d, $00
    ld   hl, $673C
    add  hl, de
    ld   a, [hl]
    pop  hl
    ldi  [hl], a
    push af
    ld   a, $28
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    ld   a, $38
    ldi  [hl], a
    pop  af
    add  a, $08
    ldi  [hl], a
    ld   a, $28
    ldi  [hl], a
    ld   [hl], $20
toc_02_6742.return_02_684A:
    ret


    db   $7D, $7D, $7D, $7D, $7D, $7D, $7D, $7D
    db   $7D, $7D, $7D, $7D, $7D, $7D, $7D, $7D
    db   $7D, $7D, $7D, $7D, $7D, $7D, $EF, $7D
    db   $7D, $EF, $EF, $EF, $7D, $7D, $EE, $7D
    db   $ED, $7D, $EF, $ED, $EF, $ED, $EF, $7D
    db   $EF, $EF, $ED, $ED, $EF, $EF, $EF, $7D
    db   $EF, $7D, $EF, $ED, $ED, $7D, $7D, $7D
    db   $7D, $ED, $EF, $EF, $7D, $7D, $7D, $7D
    db   $7D, $7D, $7D, $7D, $7D, $7D, $7D, $7D
    db   $7D, $ED, $ED, $ED, $EF, $EF, $EF, $7D
    db   $7D, $7D, $ED, $7D, $7D, $ED, $7D, $7D
    db   $7D, $EF, $EF, $7D, $7D, $EF, $EE, $7D
    db   $7D, $EF, $7D, $7D, $7D, $7D, $EF, $7D
    db   $7D, $ED, $7D, $7D, $7D, $7D, $EF, $7D
    db   $7D, $EF, $EF, $EF, $EF, $EF, $EF, $7D
    db   $7D, $7D, $ED, $ED, $ED, $ED, $7D, $7D
    db   $EF, $EF, $ED, $EF, $7D, $7D, $7D, $7D
    db   $ED, $EF, $ED, $ED, $7D, $7D, $7D, $7D
    db   $EF, $EF, $EF, $EF, $7D, $7D, $EF, $7D
    db   $7D, $ED, $EF, $7D, $7D, $EF, $EF, $EF
    db   $7D, $ED, $7D, $7D, $7D, $7D, $EF, $7D
    db   $7D, $ED, $ED, $7D, $7D, $7D, $EF, $7D
    db   $7D, $ED, $7D, $7D, $7D, $7D, $EE, $7D
    db   $7D, $EF, $ED, $7D, $7D, $7D, $EF, $EF
    db   $7D, $7D, $7D, $7D, $7D, $7D, $7D, $7D
    db   $7D, $7D, $7D, $ED, $EF, $7D, $7D, $7D
    db   $7D, $EF, $7D, $EF, $EF, $7D, $ED, $7D
    db   $7D, $EE, $EF, $ED, $EF, $ED, $EF, $7D
    db   $7D, $EF, $ED, $ED, $EF, $EF, $ED, $7D
    db   $7D, $7D, $EF, $EF, $EF, $ED, $7D, $7D
    db   $7D, $7D, $ED, $EF, $ED, $ED, $7D, $7D
    db   $7D, $7D, $7D, $EF, $ED, $7D, $7D, $7D
    db   $7D, $EF, $EF, $EF, $ED, $EF, $7D, $7D
    db   $7D, $7D, $7D, $EE, $7D, $EF, $ED, $7D
    db   $7D, $EF, $EF, $EF, $EF, $EF, $ED, $ED
    db   $7D, $7D, $7D, $7D, $7D, $EF, $EF, $EF
    db   $7D, $7D, $7D, $EF, $EF, $EF, $EF, $7D
    db   $7D, $7D, $ED, $EF, $EF, $EF, $7D, $7D
    db   $7D, $7D, $7D, $ED, $EF, $EF, $7D, $7D
    db   $7D, $7D, $7D, $7D, $ED, $EF, $ED, $EF
    db   $7D, $7D, $7D, $7D, $7D, $7D, $7D, $7D
    db   $ED, $7D, $7D, $7D, $7D, $7D, $7D, $ED
    db   $EF, $ED, $7D, $EF, $EF, $7D, $ED, $EF
    db   $EF, $ED, $EF, $EF, $EE, $EF, $ED, $EF
    db   $ED, $EF, $7D, $EF, $EF, $7D, $EF, $EF
    db   $7D, $EF, $ED, $EF, $EF, $EF, $EF, $7D
    db   $7D, $ED, $ED, $7D, $7D, $EF, $ED, $7D
    db   $7D, $EF, $EF, $EF, $EF, $EF, $EF, $7D
    db   $7D, $ED, $ED, $7D, $7D, $7D, $7D, $7D
    db   $EF, $EF, $EF, $EF, $7D, $EE, $EF, $7D
    db   $EF, $EF, $EF, $ED, $7D, $EF, $EF, $7D
    db   $EF, $ED, $EF, $EF, $7D, $7D, $7D, $7D
    db   $ED, $EF, $EF, $ED, $7D, $EF, $ED, $7D
    db   $EF, $EF, $EF, $EF, $EF, $EF, $EF, $ED
    db   $ED, $EF, $EF, $EF, $EF, $EF, $EF, $EF
    db   $EF, $EF, $EF, $EF, $7D, $EF, $EF, $7D
    db   $7D, $7D, $7D, $EF, $EF, $7D, $7D, $7D
    db   $ED, $7D, $7D, $EE, $ED, $7D, $7D, $ED
    db   $EF, $EF, $ED, $EF, $EF, $ED, $EF, $EF
    db   $7D, $ED, $EF, $EF, $EF, $EF, $EF, $7D
    db   $7D, $ED, $EF, $EF, $EF, $EF, $EF, $7D
    db   $EF, $ED, $EF, $ED, $EF, $EF, $EF, $EF
    db   $EF, $ED, $EF, $EF, $EF, $ED, $EF, $EF
    db   $ED, $7D, $7D, $EF, $EF, $7D, $7D, $ED
    db   $7D, $ED, $ED, $7D, $7D, $7D, $7D, $7D
    db   $EF, $EF, $EF, $EF, $7D, $7D, $7D, $7D
    db   $EF, $EF, $EF, $ED, $7D, $7D, $7D, $7D
    db   $EF, $ED, $EF, $EF, $7D, $7D, $7D, $7D
    db   $ED, $EF, $EF, $ED, $7D, $EF, $ED, $7D
    db   $EF, $EF, $EF, $EF, $EF, $EE, $EF, $EF
    db   $EF, $EF, $EF, $EF, $EF, $EF, $EF, $EF
    db   $EF, $EF, $EF, $EF, $7D, $EF, $EF, $7D
    db   $00, $02, $03, $07, $05, $0A, $0B, $0F
    db   $04, $08, $09, $0E, $06, $0C, $0D, $01

toc_02_6A9B:
    ld   a, [$FFF6]
    cp   $E8
    ret  z

    ld   hl, $684B
    ld   a, [$FFF7]
    swap a
    ld   e, a
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    add  hl, de
    ifNe [$FFF7], $06, .else_02_6AC3

    ld   a, [$DB6B]
    and  %00000100
    jr   z, .else_02_6AC3

    ld   hl, $6A4B
toc_02_6A9B.else_02_6AC3:
    ld   de, $D480
    ld   bc, $0040
    call toc_01_28C5
    ld   d, $00
    ld   e, $00
toc_02_6A9B.toc_02_6AD0:
    ld   hl, $D480
    add  hl, de
    ld   a, [hl]
    cp   $7D
    jr   z, .else_02_6B3E

    cp   $ED
    jr   z, .else_02_6AE1

    cp   $EE
    jr   nz, .else_02_6AE9

toc_02_6A9B.else_02_6AE1:
    ld   a, [$DBCD]
    and  a
    jr   nz, .else_02_6AF4

    ld   [hl], $EF
toc_02_6A9B.else_02_6AE9:
    ld   a, [$DBCC]
    and  a
    jr   nz, .else_02_6AF4

    ld   [hl], $7D
    jp   .else_02_6B3E

toc_02_6A9B.else_02_6AF4:
    push de
    call toc_01_2B25
    push de
    pop  bc
    pop  de
    ld   a, [hl]
    bit  7, a
    jr   z, .else_02_6B3E

    ld   a, [hl]
    and  %00001111
    ld   c, a
    ld   b, $00
    ld   hl, $6A8B
    add  hl, bc
    ld   a, [hl]
    inc  a
    add  a, $CF
    ld   c, a
    ld   hl, $D480
    add  hl, de
    ld   a, [hl]
    cp   $EE
    jr   z, .else_02_6B1C

    cp   $ED
    jr   nz, .else_02_6B31

toc_02_6A9B.else_02_6B1C:
    push de
    push af
    call toc_01_2B25
    pop  af
    ld   e, $20
    cp   $ED
    jr   nz, .else_02_6B2A

    ld   e, $10
toc_02_6A9B.else_02_6B2A:
    ld   a, [hl]
    and  e
    pop  de
    cp   $00
    jr   z, .else_02_6B3E

toc_02_6A9B.else_02_6B31:
    ld   hl, $D480
    add  hl, de
    ld   [hl], c
    ld   a, [$DBCC]
    and  a
    jr   nz, .else_02_6B3E

    ld   [hl], $7D
toc_02_6A9B.else_02_6B3E:
    inc  e
    ld   a, e
    cp   $40
    jp   nz, .toc_02_6AD0

    ret


toc_02_6B46:
    ld   a, [$DBB0]
    and  %00110000
    swap a
    jumptable
    dw JumpTable_6B56_02 ; 00
    dw JumpTable_6B5B_02 ; 01
    dw JumpTable_6B60_02 ; 02
    dw JumpTable_6B65_02 ; 03

JumpTable_6B56_02:
    ld   hl, $9D2E
    jr   JumpTable_6B65_02.toc_02_6B68

JumpTable_6B5B_02:
    ld   hl, $9D2F
    jr   JumpTable_6B65_02.toc_02_6B68

JumpTable_6B60_02:
    ld   hl, $9D0E
    jr   JumpTable_6B65_02.toc_02_6B68

JumpTable_6B65_02:
    ld   hl, $9D0F
JumpTable_6B65_02.toc_02_6B68:
    ld   e, $04
    jr   toc_02_6BB8.toc_02_6BBD

toc_02_6B6C:
    ld   a, [$DBB0]
    and  %00110000
    swap a
    jumptable
    dw JumpTable_6B7C_02 ; 00
    dw JumpTable_6B81_02 ; 01
    dw JumpTable_6B86_02 ; 02
    dw JumpTable_6B8B_02 ; 03

JumpTable_6B7C_02:
    ld   hl, $9DAE
    jr   JumpTable_6B8B_02.toc_02_6B8E

JumpTable_6B81_02:
    ld   hl, $9DAF
    jr   JumpTable_6B8B_02.toc_02_6B8E

JumpTable_6B86_02:
    ld   hl, $9DAE
    jr   JumpTable_6B8B_02.toc_02_6B8E

JumpTable_6B8B_02:
    ld   hl, $9DAF
JumpTable_6B8B_02.toc_02_6B8E:
    ld   e, $24
    jr   toc_02_6BB8.toc_02_6BBD

toc_02_6B92:
    ld   a, [$DBB0]
    and  %00110000
    swap a
    jumptable
    dw JumpTable_6BA2_02 ; 00
    dw JumpTable_6BA7_02 ; 01
    dw JumpTable_6BAC_02 ; 02
    dw JumpTable_6BB1_02 ; 03

JumpTable_6BA2_02:
    ld   hl, $9D2A
    jr   JumpTable_6BB1_02.toc_02_6BB4

JumpTable_6BA7_02:
    ld   hl, $9D2A
    jr   JumpTable_6BB1_02.toc_02_6BB4

JumpTable_6BAC_02:
    ld   hl, $9D0A
    jr   JumpTable_6BB1_02.toc_02_6BB4

JumpTable_6BB1_02:
    ld   hl, $9D0A
JumpTable_6BB1_02.toc_02_6BB4:
    ld   e, $00
    jr   toc_02_6BB8.toc_02_6BBD

toc_02_6BB8:
    ld   hl, $9DAA
    ld   e, $20
toc_02_6BB8.toc_02_6BBD:
    ld   c, $00
    ld   d, c
toc_02_6BB8.loop_02_6BC0:
    push hl
    ld   hl, $D480
    add  hl, de
    ld   a, [hl]
    pop  hl
    ld   [hl], a
    inc  e
    inc  c
    ld   a, c
    cp   $10
    jr   z, .return_02_6BE2

    inc  hl
    and  %00000011
    jr   nz, .loop_02_6BC0

    ld   a, e
    add  a, $04
    ld   e, a
    ld   a, l
    add  a, $1C
    ld   l, a
    ld   a, $00
    adc  h
    ld   h, a
    jr   .loop_02_6BC0

toc_02_6BB8.return_02_6BE2:
    ret


    db   $00, $08, $F8, $00, $F0, $10, $00, $10
    db   $F0, $FF, $00, $01

toc_02_6BEF:
    ld   a, [$C146]
    and  a
    jr   nz, .else_02_6BFF

    ifEq [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_GRAB_SLASH, .return_02_6C1B

    cp   INTERACTIVE_MOTION_LOCKED_TALKING
    jr   z, .return_02_6C1B

toc_02_6BEF.else_02_6BFF:
    ifNot [$C13E], .else_02_6C1C

    dec  a
    ld   [$C13E], a
    call toc_01_20D6
    call toc_02_6FB1
    ifEq [$FF9C], $02, .return_02_6C1B

    ld   a, [hLinkPositionYIncrement]
    add  a, $03
    ld   [hLinkPositionYIncrement], a
toc_02_6BEF.return_02_6C1B:
    ret


toc_02_6BEF.else_02_6C1C:
    ld   a, [$FF9C]
    jumptable
    dw JumpTable_6D3A_02 ; 00
    dw JumpTable_6CDA_02 ; 01
    dw JumpTable_6C48_02 ; 02

    db   $00, $08, $F8, $00, $00, $06, $FA, $00
    db   $00, $06, $FA, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $F8, $FA, $FA, $00
    db   $08, $06, $06, $00, $00, $00, $00, $00
    db   $00, $00, $01

JumpTable_6C48_02:
    ifNe [$FFF7], $07, .else_02_6C63

    call toc_02_77FA.else_02_79D9
    ld   a, [$DB94]
    add  a, $04
    ld   [$DB94], a
    assign [$FFF3], $03
    assign [$DBC7], $80
    ret


JumpTable_6C48_02.else_02_6C63:
    ld   a, [$DB0C]
    and  a
    jp   z, toc_02_77FA.else_02_79D9

    ld   hl, hLinkDirection
    res  1, [hl]
    call toc_01_093B.toc_01_0942
    ld   [$C146], a
    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .else_02_6CA6

    ld   a, [hPressedButtonsMask]
    and  %00001111
    ld   e, a
    ld   d, $00
    ld   hl, $6C25
    add  hl, de
    ld   a, [hl]
    ld   hl, hLinkPositionXIncrement
    sub  a, [hl]
    jr   z, .else_02_6C94

    inc  [hl]
    bit  7, a
    jr   z, .else_02_6C94

    dec  [hl]
    dec  [hl]
JumpTable_6C48_02.else_02_6C94:
    ld   hl, $6C35
    add  hl, de
    ld   a, [hl]
    ld   hl, hLinkPositionYIncrement
    sub  a, [hl]
    jr   z, .else_02_6CA6

    inc  [hl]
    bit  7, a
    jr   z, .else_02_6CA6

    dec  [hl]
    dec  [hl]
JumpTable_6C48_02.else_02_6CA6:
    incAddr $C120
    ld   a, [hPressedButtonsMask]
    and  %00000011
    jr   z, .else_02_6CBA

    ld   e, a
    ld   d, $00
    ld   hl, $6C45
    add  hl, de
    ld   a, [hl]
    ld   [hLinkDirection], a
JumpTable_6C48_02.else_02_6CBA:
    call toc_01_20D6
    call toc_02_6FB1
    ld   a, [$C14F]
    and  a
    ret  nz

    ifEq [$FFD7], $B0, .else_02_6CD6

    cp   $B1
    jr   nz, .else_02_6CD3

    ld   a, $01
    jr   .toc_02_6CD4

JumpTable_6C48_02.else_02_6CD3:
    xor  a
JumpTable_6C48_02.toc_02_6CD4:
    ld   [$FF9C], a
JumpTable_6C48_02.else_02_6CD6:
    call JumpTable_6D3A_02.return_02_6E8F
    ret


JumpTable_6CDA_02:
    call toc_01_093B.toc_01_0942
    ld   [$C146], a
    ld   [$C153], a
    ld   [$C152], a
    ld   a, [hPressedButtonsMask]
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $6BE3
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    ld   a, [hPressedButtonsMask]
    rra
    rra
    and  %00000011
    ld   e, a
    ld   hl, $6BE6
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionYIncrement], a
    assign [hLinkDirection], $02
    ld   a, [hPressedButtonsMask]
    and  %00001111
    jr   z, .else_02_6D10

    incAddr $C120
JumpTable_6CDA_02.else_02_6D10:
    call toc_01_20D6
    call toc_02_6FB1
    ld   a, [$C14F]
    and  a
    ret  nz

    ifEq [$FFD7], $B1, .else_02_6D2C

    cp   $B0
    jr   nz, .else_02_6D29

    ld   a, $02
    jr   .toc_02_6D2A

JumpTable_6CDA_02.else_02_6D29:
    xor  a
JumpTable_6CDA_02.toc_02_6D2A:
    ld   [$FF9C], a
JumpTable_6CDA_02.else_02_6D2C:
    call JumpTable_6D3A_02.return_02_6E8F
    ld   a, [$C133]
    and  %00001000
    jr   z, .return_02_6D39

    clear [$FF9C]
JumpTable_6CDA_02.return_02_6D39:
    ret


JumpTable_6D3A_02:
    ifNe [$FFF7], $06, .else_02_6D5D

    ifNe [$FFF6], $F8, .else_02_6D5D

    ld   a, [$C146]
    and  a
    jr   nz, .else_02_6D5D

    ld   a, [hLinkPositionX]
    sub  a, $46
    add  a, $04
    cp   8
    jr   nc, .else_02_6D5D

    ld   a, [$FFCC]
    and  %00000100
    jp   nz, toc_01_0909

JumpTable_6D3A_02.else_02_6D5D:
    ifNot [$C14A], .else_02_6D85

    ld   a, [$FFCC]
    and  %00001111
    jr   nz, .else_02_6D77

    ld   a, [$C120]
    add  a, $02
    ld   [$C120], a
    call toc_01_145D
    jp   .else_02_6E14

JumpTable_6D3A_02.else_02_6D77:
    ld   [$C19A], a
    ld   a, [$C199]
    add  a, $0C
    ld   [$C199], a
    call toc_01_093B
JumpTable_6D3A_02.else_02_6D85:
    ld   a, [$C147]
    and  a
    jr   nz, .else_02_6DCD

    ld   a, [$C133]
    and  %00001000
    jr   nz, .else_02_6DCD

    ld   a, [$C146]
    and  a
    jr   nz, .else_02_6D9D

    assign [$C146], $01
JumpTable_6D3A_02.else_02_6D9D:
    assign [$C120], $0A
    ifNot [hLinkPositionXIncrement], .else_02_6DAC

    rlca
    and  %00000001
    ld   [hLinkDirection], a
JumpTable_6D3A_02.else_02_6DAC:
    ld   a, [hPressedButtonsMask]
    and  %00000011
    jr   z, .else_02_6DCB

    ld   e, a
    ld   d, $00
    ld   hl, $6BE9
    add  hl, de
    ld   a, [hLinkPositionXIncrement]
    sub  a, [hl]
    jr   z, .else_02_6DCB

    ld   e, $01
    bit  7, a
    jr   nz, .else_02_6DC6

    ld   e, $FF
JumpTable_6D3A_02.else_02_6DC6:
    ld   a, [hLinkPositionXIncrement]
    add  a, e
    ld   [hLinkPositionXIncrement], a
JumpTable_6D3A_02.else_02_6DCB:
    jr   .else_02_6E14

JumpTable_6D3A_02.else_02_6DCD:
    ifNot [$C146], .else_02_6DE3

    assign [$FFF4], $07
    call toc_01_093B.toc_01_0942
    ld   [$C146], a
    ld   [$C152], a
    ld   [$C153], a
JumpTable_6D3A_02.else_02_6DE3:
    ld   a, [hPressedButtonsMask]
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $6BE9
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    ld   hl, $6BEC
    add  hl, de
    ld   a, [hl]
    cp   $FF
    jr   z, .else_02_6E0A

    ld   e, a
    ld   a, [$C16E]
    and  a
    jr   nz, .else_02_6E04

    ld   a, e
    ld   [hLinkDirection], a
JumpTable_6D3A_02.else_02_6E04:
    incAddr $C120
    jr   .else_02_6E14

JumpTable_6D3A_02.else_02_6E0A:
    ld   a, [$C14B]
    and  a
    jr   nz, .else_02_6E14

    clear [$C120]
JumpTable_6D3A_02.else_02_6E14:
    ld   a, [$C137]
    and  a
    jr   nz, .else_02_6E1F

    ld   a, [hLinkInteractiveMotionBlocked]
    and  a
    jr   nz, .else_02_6E35

JumpTable_6D3A_02.else_02_6E1F:
    call toc_01_20D6
    ld   hl, hLinkDirection
    ld   a, [hPressedButtonsMask]
    and  %00001111
    cp   $04
    jr   nz, .else_02_6E2F

    ld   [hl], $02
JumpTable_6D3A_02.else_02_6E2F:
    cp   $08
    jr   nz, .else_02_6E35

    ld   [hl], $03
JumpTable_6D3A_02.else_02_6E35:
    call toc_02_6FB1
    ld   a, [$C14F]
    and  a
    ret  nz

    ifEq [$FFD7], $B1, .else_02_6E63

    cp   $B0
    jr   nz, .else_02_6E6D

    ld   a, [$C133]
    and  a
    jr   nz, .else_02_6E5F

    ld   a, [$DBC7]
    and  a
    jr   nz, .else_02_6E58

    ld   a, $02
    call toc_02_571B
JumpTable_6D3A_02.else_02_6E58:
    assign [hLinkPositionYIncrement], $04
    clear [hLinkPositionXIncrement]
JumpTable_6D3A_02.else_02_6E5F:
    ld   a, $02
    jr   .toc_02_6E6B

JumpTable_6D3A_02.else_02_6E63:
    ld   a, [hPressedButtonsMask]
    and  %00001100
    jr   z, .else_02_6E6D

    ld   a, $01
JumpTable_6D3A_02.toc_02_6E6B:
    ld   [$FF9C], a
JumpTable_6D3A_02.else_02_6E6D:
    ld   hl, hLinkPositionYIncrement
    ld   a, [hl]
    sub  a, $40
    and  %10000000
    jr   z, .return_02_6E8F

    inc  [hl]
    ld   a, [hLinkPositionYIncrement]
    and  %10000000
    jr   z, .else_02_6E8E

    ld   e, $20
    ifEq [$DB00], $0A, .else_02_6E89

    ld   e, $10
JumpTable_6D3A_02.else_02_6E89:
    ld   a, [hPressedButtonsMask]
    and  e
    jr   nz, .return_02_6E8F

JumpTable_6D3A_02.else_02_6E8E:
    inc  [hl]
JumpTable_6D3A_02.return_02_6E8F:
    ret


    db   $01, $02, $04, $08, $10, $0B, $05, $08
    db   $08, $08, $08, $08, $04, $10, $0B

toc_02_6E9F:
    ld   c, $04
    ld   b, $00
    call toc_02_6F6B
    copyFromTo [$FFD8], [$FFD7]
    clear [$C133]
    ld   c, $00
    ifNot [hLinkPositionXIncrement], .else_02_6EDB

    and  %10000000
    jr   z, .else_02_6EBA

    inc  c
toc_02_6E9F.else_02_6EBA:
    call toc_02_6F6B
    ifNe [hObjectUnderEntity], 138, .else_02_6ED2

    ld   a, [$C5A6]
    and  a
    jr   nz, .else_02_6ED2

    inc  a
    ld   [$C5A6], a
    ld   a, $51
    call toc_01_2197
toc_02_6E9F.else_02_6ED2:
    ifNe [hObjectUnderEntity], 255, .else_02_6EDB

    call toc_02_6F6B.else_02_6FA5
toc_02_6E9F.else_02_6EDB:
    ld   c, $02
    ld   a, [hLinkPositionYIncrement]
    and  a
    and  %10000000
    jr   nz, .else_02_6EE5

    inc  c
toc_02_6E9F.else_02_6EE5:
    call toc_02_6F6B
    ld   a, [hLinkPositionYIncrement]
    and  %10000000
    jr   nz, .else_02_6F0A

    ld   a, [hPressedButtonsMask]
    and  %00001000
    jr   nz, .else_02_6F0A

    ld   a, [$FFE9]
    and  %00001111
    cp   $03
    jr   nc, .else_02_6F0A

    ifEq [hObjectUnderEntity], 98, .else_02_6F11

    cp   100
    jr   z, .else_02_6F11

    cp   102
    jr   z, .else_02_6F11

toc_02_6E9F.else_02_6F0A:
    ld   a, [$C133]
    and  %00001000
    jr   z, .else_02_6F24

toc_02_6E9F.else_02_6F11:
    ld   a, [$C133]
    or   $08
    ld   [$C133], a
    clear [hLinkPositionYIncrement]
    ld   a, [hLinkPositionY]
    and  %11110000
    add  a, $00
    ld   [hLinkPositionY], a
toc_02_6E9F.else_02_6F24:
    ld   a, [$C133]
    and  %00000100
    jr   z, .else_02_6F2F

    copyFromTo [hLinkFinalPositionY], [hLinkPositionY]
toc_02_6E9F.else_02_6F2F:
    ld   a, [$C133]
    and  %00000011
    jr   z, .return_02_6F6A

    copyFromTo [hLinkFinalPositionX], [hLinkPositionX]
    ifNot [$C14A], .return_02_6F6A

    call toc_01_093B
    ld   a, [hLinkPositionXIncrement]
    cpl
    inc  a
    sra  a
    sra  a
    ld   [hLinkPositionXIncrement], a
    assign [hLinkPositionYIncrement], $E8
    call toc_01_20D6
    call toc_02_6FB1
    assign [$C157], $20
    ld   a, [hLinkDirection]
    and  %00000010
    sla  a
    ld   [$C158], a
    assign [$FFF2], $0B
    ret


toc_02_6E9F.return_02_6F6A:
    ret


toc_02_6F6B:
    ld   hl, $6E95
    add  hl, bc
    ld   a, [hLinkPositionX]
    sub  a, $08
    add  a, [hl]
    swap a
    and  %00001111
    ld   e, a
    ld   hl, $6E9A
    add  hl, bc
    ld   a, [hLinkPositionY]
    add  a, [hl]
    sub  a, $10
    ld   [$FFE9], a
    and  %11110000
    or   e
    ld   e, a
    ld   d, $00
    ld   hl, $D711
    ld   a, h
    add  hl, de
    ld   h, a
    ld   a, [hl]
    ld   [hObjectUnderEntity], a
    ld   e, a
    ld   a, [$DBA5]
    ld   d, a
    call toc_01_29DB
    ld   [$FFD8], a
    cp   $60
    jr   z, .else_02_6FA5

    cp   $01
    jr   nz, .return_02_6FB0

toc_02_6F6B.else_02_6FA5:
    ld   hl, $6E90
    add  hl, bc
    ld   a, [$C133]
    or   [hl]
    ld   [$C133], a
toc_02_6F6B.return_02_6FB0:
    ret


toc_02_6FB1:
    ld   a, [wDialogState]
    ld   hl, $C14F
    or   [hl]
    ret  nz

    ifNe [$FFF7], $1F, .else_02_6FD5

    ifNot [$FFF9], .else_02_6FD5

    ifEq [$FFF6], $EB, .else_02_6FCE

    cp   $EC
    jr   nz, .else_02_6FD5

toc_02_6FB1.else_02_6FCE:
    ld   a, [hLinkPositionY]
    cp   44
    jp   c, toc_01_0909

toc_02_6FB1.else_02_6FD5:
    ld   e, $02
    ifLt [hLinkPositionY], 12, .else_02_6FF2

    inc  e
    cp   132
    jr   nc, .else_02_6FF2

    ld   e, $01
    ifLt [hLinkPositionX], 4, .else_02_704F

    dec  e
    cp   156
    jr   nc, .else_02_704F

    jp   .else_02_7142

toc_02_6FB1.else_02_6FF2:
    ld   a, [$FFF9]
    and  a
    jr   nz, .else_02_700D

    ld   a, [$FFF7]
    cp   $1F
    jp   nz, .else_02_7098

    ld   a, [$FFF6]
    cp   $F5
    jp   z, toc_01_0909

    cp   $F2
    jp   nz, .else_02_7098

    jp   toc_01_0909

toc_02_6FB1.else_02_700D:
    ld   a, [$FFF6]
    cp   $E8
    jp   z, .else_02_7098

    cp   $F8
    jp   z, .else_02_7098

    cp   $FD
    jr   z, .else_02_703C

    cp   $A3
    jp   z, toc_01_0909

    cp   $C0
    jp   z, toc_01_0909

    cp   $C1
    jp   z, toc_01_0909

    cp   $FF
    jr   nz, .else_02_7046

    ifGte [hLinkPositionY], 80, .else_02_703C

    ifNot [$C280], .else_02_7098

toc_02_6FB1.else_02_703C:
    copyFromTo [hLinkFinalPositionY], [hLinkPositionY]
    clear [hLinkPositionYIncrement]
    jp   .else_02_7142

toc_02_6FB1.else_02_7046:
    ifEq [$FF9C], $02, .else_02_7098

    jp   toc_01_0909

toc_02_6FB1.else_02_704F:
    copyFromTo [hLinkFinalPositionX], [hLinkPositionX]
    clear [hLinkPositionXIncrement]
    ifNot [$FFF9], .else_02_7098

    ld   a, [$FFF6]
    cp   $F5
    jp   z, toc_01_090F

    cp   $FD
    jp   z, toc_01_090F

    cp   $E9
    jp   z, toc_01_0909

    cp   $E8
    jp   z, .else_02_7142

    cp   $F8
    jp   z, .else_02_7142

    cp   $EF
    jp   z, .else_02_7142

    cp   $FF
    jp   z, .else_02_7142

    cp   $C0
    jr   nz, .else_02_708D

    ld   a, [hLinkPositionX]
    cp   48
    jp   c, .else_02_7142

    jr   .else_02_7098

toc_02_6FB1.else_02_708D:
    cp   $C1
    jr   nz, .else_02_7098

    ld   a, [hLinkPositionX]
    cp   80
    jp   nc, .else_02_7142

toc_02_6FB1.else_02_7098:
    call toc_01_094A
    ld   a, [$C181]
    cp   $50
    jp   z, .else_02_7146

    cp   $51
    jp   z, .else_02_7146

    ld   a, [$C11F]
    cp   $07
    jp   z, .else_02_7146

    ld   a, [$C11C]
    cp   $06
    jp   z, .else_02_7146

    ld   a, [$FFF9]
    and  a
    jr   nz, .else_02_70C4

    ld   a, [$C146]
    and  a
    jp   nz, .else_02_7146

toc_02_6FB1.else_02_70C4:
    ld   a, [$C14A]
    and  a
    jr   nz, .else_02_70D0

    ld   a, [$C16D]
    and  a
    jr   nz, .else_02_7146

toc_02_6FB1.else_02_70D0:
    ld   a, [$C13E]
    ld   hl, $C157
    or   [hl]
    jr   nz, .else_02_7146

    ifGte [hLinkPositionY], 136, .else_02_7108

    ld   a, [$C14A]
    ld   hl, $FFF9
    or   [hl]
    ld   hl, hLinkWalksSlow
    or   [hl]
    jr   nz, .else_02_7108

    ld   a, [hPressedButtonsMask]
    and  %00001111
    jr   z, .else_02_7146

    and  %00000011
    jr   z, .else_02_70FA

    dec  a
    cp   e
    jr   z, .else_02_7108

toc_02_6FB1.else_02_70FA:
    ld   a, [hPressedButtonsMask]
    rra
    rra
    and  %00000011
    jr   z, .else_02_7146

    dec  a
    add  a, $02
    cp   e
    jr   nz, .else_02_7146

toc_02_6FB1.else_02_7108:
    ifNe [$FFF6], $E8, .else_02_7120

    ifEq [$FFF7], $1F, .else_02_7120

    ifNot [$DBA5], .else_02_7120

    clear [$C1BF]
    ld   [gbSCX], a
toc_02_6FB1.else_02_7120:
    ld   a, e
    ld   [$C125], a
    assign [$C124], $01
    clear [$C14B]
    ld   [$C121], a
    ld   [$C14A], a
    ifLt [hLinkPositionY], 136, .else_02_7142

    assign [$C146], $02
    assign [hLinkPositionZHigh], $08
toc_02_6FB1.else_02_7142:
    call toc_02_7180
    ret


toc_02_6FB1.else_02_7146:
    call toc_01_1495
    ld   [$C13E], a
    call toc_02_7180
toc_02_6FB1.return_02_714F:
    ret


    db   $06, $09, $0B, $0B, $06, $09, $04, $04
    db   $06, $06, $09, $0C, $0F, $0F, $09, $0C
    db   $04, $00, $02, $06, $01, $02, $04, $08
    db   $01, $02, $04, $08, $02, $02, $00, $00
    db   $03, $03, $01, $01, $00, $01, $FF, $00
    db   $10, $F0, $00, $00, $00, $00, $F0, $10

toc_02_7180:
    ld   hl, $C10A
    ld   a, [$C17B]
    or   [hl]
    jr   nz, toc_02_6FB1.return_02_714F

    ifNot [$FFF9], .else_02_7192

    call toc_02_6E9F
    ret


toc_02_7180.else_02_7192:
    clear [$C133]
    ifEq [hLinkPositionYIncrement], 0, toc_02_721A

    ld   e, $03
    rla
    ld   bc, $7160
    jr   nc, .else_02_71A6

    dec  e
    inc  bc
toc_02_7180.else_02_71A6:
    ld   a, e
    ld   [$FFE3], a
    ld   e, $02
    ld   a, [bc]
    ld   c, a
    ld   b, $00
toc_02_7180.loop_02_71AF:
    push de
    push bc
    call toc_02_726A
    pop  bc
    pop  de
    inc  bc
    dec  e
    jr   nz, .loop_02_71AF

    ld   a, [hLinkPositionYIncrement]
    and  %10000000
    jr   nz, toc_02_7203

    ld   a, [$DBA5]
    and  a
    jr   nz, toc_02_7203

    ifNe [hObjectUnderEntity], 233, toc_02_7203

    ifNot [$DB0C], toc_02_7203

    ifEq [$C5A8], $D5, toc_02_7203

    ifEq [$C11C], $02, toc_02_721A

    assign [$FFF2], $08
    jr   toc_02_71E6.toc_02_71F2

toc_02_71E6:
    assign [$FFF2], $08
toc_02_71E6.toc_02_71EA:
    ld   a, [hLinkPositionX]
    and  %11110000
    add  a, $08
    ld   [hLinkPositionX], a
toc_02_71E6.toc_02_71F2:
    assign [$C11C], $02
    clear [$FF9C]
    ld   a, [hLinkPositionY]
    sub  a, $08
    ld   [hLinkPositionY], a
    jp   toc_01_093B.toc_01_0942

toc_02_7203:
    ld   a, [$C133]
    and  %00000011
    jr   z, toc_02_721A

    ld   e, a
    ld   d, $00
    ld   hl, $7174
    add  hl, de
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   [hLinkPositionX], a
    copyFromTo [hLinkFinalPositionY], [hLinkPositionY]
toc_02_721A:
    ifEq [hLinkPositionXIncrement], 0, toc_02_7259

    ld   e, $00
    rla
    ld   bc, $7162
    jr   nc, toc_02_722A

    inc  e
    inc  bc
toc_02_722A:
    ld   a, e
    ld   [$FFE3], a
    ld   e, $02
    ld   a, [bc]
    ld   c, a
    ld   b, $00
toc_02_7233:
    push de
    push bc
    call toc_02_726A
    pop  bc
    pop  de
    inc  bc
    dec  e
    jr   nz, toc_02_7233

    ld   a, [$C133]
    and  %00001100
    jr   z, toc_02_7259

    srl  a
    srl  a
    ld   e, a
    ld   d, $00
    ld   hl, $7174
    add  hl, de
    ld   a, [hLinkPositionY]
    add  a, [hl]
    ld   [hLinkPositionY], a
    copyFromTo [hLinkFinalPositionX], [hLinkPositionX]
toc_02_7259:
    ld   a, [$C133]
    and  a
    jr   nz, toc_02_7262

    ld   [$C1C3], a
toc_02_7262:
    call toc_02_7769
    ret


    db   $01, $02, $04, $08

toc_02_726A:
    ld   hl, $7150
    add  hl, bc
    ld   a, [hLinkPositionX]
    sub  a, $08
    add  a, [hl]
    ld   [$FFDB], a
    swap a
    and  %00001111
    ld   e, a
    ld   hl, $7158
    add  hl, bc
    ld   a, [hLinkPositionY]
    add  a, [hl]
    sub  a, $10
    ld   [$FFDC], a
    and  %11110000
    or   e
    ld   e, a
    ld   [$FFE9], a
    ld   d, $00
    ld   hl, $D711
    ld   a, h
    add  hl, de
    ld   h, a
    ld   a, [hl]
    ld   [hObjectUnderEntity], a
    ld   e, a
    ld   a, [$DBA5]
    ld   d, a
    call toc_01_29DB
    ld   [$FFE4], a
    and  a
    jp   z, .toc_02_771C

    cp   $01
    jp   z, .else_02_75B1

    cp   $02
    jp   z, .toc_02_759A

    cp   $03
    jp   z, .toc_02_74F9

    cp   $10
    jp   z, .toc_02_74DA

    cp   $04
    jp   z, .toc_02_7577

    cp   $30
    jp   z, .else_02_75B1

    cp   $60
    jp   z, .else_02_75B1

    cp   $0A
    jp   z, .toc_02_759A

    cp   $FF
    jp   z, .toc_02_771C

    cp   $E0
    jp   z, .toc_02_771C

    cp   $F0
    jp   nc, .toc_02_771C

    cp   $C0
    jp   nz, .toc_02_7383

    ld   a, [hLinkDirection]
    cp   DIRECTION_UP
    jp   nz, .toc_02_7379

    ld   a, [$FFF8]
    bit  4, a
    jp   nz, .toc_02_7379

    ifNe [$FFF6], $0E, .else_02_72FB

    ld   a, [$DB14]
    ld   e, $33
    jr   .toc_02_7304

toc_02_726A.else_02_72FB:
    cp   $8C
    jr   nz, .else_02_7321

    ld   a, [$DB13]
    ld   e, $34
toc_02_726A.toc_02_7304:
    and  a
    jr   z, .else_02_737C

    ifNe [$FFF6], $8C, .else_02_7312

    call toc_01_27D2
    jr   .toc_02_7315

toc_02_726A.else_02_7312:
    call toc_02_525B
toc_02_726A.toc_02_7315:
    ld   a, $28
    call toc_01_3C01
    ld   hl, $C2C0
    add  hl, de
    inc  [hl]
    jr   .toc_02_736A

toc_02_726A.else_02_7321:
    cp   $2B
    jr   nz, .else_02_733C

    ld   a, [$DB12]
    and  a
    ld   e, $32
    jr   z, .else_02_737C

    call toc_01_27D2
    ld   a, $5F
    call toc_01_3C01
    ld   hl, $C440
    add  hl, de
    dec  [hl]
    jr   .toc_02_736A

toc_02_726A.else_02_733C:
    cp   $B5
    jr   nz, .else_02_734B

    ld   a, [$DB15]
    cp   $06
    ld   e, $31
    jr   nz, .else_02_737C

    jr   .toc_02_7353

toc_02_726A.else_02_734B:
    ld   a, [$DB11]
    and  a
    ld   e, $30
    jr   z, .else_02_737C

toc_02_726A.toc_02_7353:
    copyFromTo [hLinkPositionY], [$FFD8]
    copyFromTo [hLinkPositionX], [$FFD7]
    ld   a, $09
    call toc_01_0953
    ld   [hl], $DF
    assign [$C111], $DF
    call toc_01_27D2
toc_02_726A.toc_02_736A:
    ld   hl, $D800
    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    add  hl, de
    ld   a, [hl]
    or   $10
    ld   [hl], a
    ld   [$FFF8], a
toc_02_726A.toc_02_7379:
    jp   .else_02_75B1

toc_02_726A.else_02_737C:
    ld   a, e
    call toc_02_77C4
    jp   .else_02_75B1

toc_02_726A.toc_02_7383:
    ifNe [hObjectUnderEntity], 219, .else_02_7391

    ld   a, [$C11C]
    cp   $01
    jp   z, .else_02_75B1

toc_02_726A.else_02_7391:
    ld   a, [$FFE4]
    cp   $D0
    jp   c, .toc_02_741D

    cp   $D4
    jp   nc, .toc_02_741D

    sub  a, $D0
    ld   e, a
    ld   a, [$DBA5]
    and  a
    jr   nz, .else_02_73C3

    ld   a, e
    cp   $00
    jr   nz, .else_02_73B6

    ld   a, [$FFDB]
    and  %00001111
    cp   $08
    jp   c, .toc_02_771C

    jr   .else_02_73C3

toc_02_726A.else_02_73B6:
    cp   $01
    jr   nz, .else_02_73C3

    ld   a, [$FFDB]
    and  %00001111
    cp   $08
    jp   nc, .toc_02_771C

toc_02_726A.else_02_73C3:
    ld   d, $00
    ld   a, [hLinkDirection]
    cp   e
    jp   nz, .else_02_7416

    ld   a, [$C13E]
    ld   hl, $C121
    or   [hl]
    ld   hl, $D45E
    or   [hl]
    jr   nz, .else_02_7416

    ld   a, [$C14A]
    and  a
    jr   nz, .else_02_73F3

    ld   hl, $7266
    add  hl, de
    ld   a, [hPressedButtonsMask]
    and  [hl]
    jr   z, .else_02_7416

    ld   a, [$C191]
    inc  a
    ld   [$C191], a
    cp   $0C
    jp   c, .else_02_75B1

toc_02_726A.else_02_73F3:
    call toc_01_093B.toc_01_0942
    ld   hl, $7178
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    ld   hl, $717C
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionYIncrement], a
    assign [hLinkPositionZLow], $1C
    assign [$C146], $01
    assign [$C10A], $01
    assign [$FFF2], $08
toc_02_726A.else_02_7416:
    clear [$C191]
    jp   .else_02_75B1

toc_02_726A.toc_02_741D:
    cp   $90
    jp   c, .toc_02_749D

    cp   $99
    jp   nc, .else_02_75B1

    sub  a, $90
    ld   e, a
    ld   d, $00
    bit  1, a
    jr   nz, .else_02_7441

    ld   hl, $C1D0
    add  hl, de
    ld   e, [hl]
    ld   a, [hLinkPositionX]
    sub  a, e
    sub  a, $0C
    cp   8
    jp   nc, .else_02_75B1

    jr   .toc_02_7450

toc_02_726A.else_02_7441:
    ld   hl, $C1E0
    add  hl, de
    ld   e, [hl]
    ld   a, [hLinkPositionY]
    sub  a, e
    sub  a, $14
    cp   8
    jp   nc, .else_02_75B1

toc_02_726A.toc_02_7450:
    ld   a, [$C188]
    and  a
    jp   nz, .else_02_75B1

    ifGte [$FFE4], $94, .else_02_746A

    ld   a, [$DBD0]
    and  a
    jp   z, .else_02_75B1

    dec  a
    ld   [$DBD0], a
    jr   .else_02_7485

toc_02_726A.else_02_746A:
    cp   $98
    jr   z, .else_02_7477

    ifNot [$C18E], .else_02_7485

    jp   .else_02_75B1

toc_02_726A.else_02_7477:
    ld   a, [$DBCF]
    and  a
    jr   nz, .else_02_7485

    ld   a, $07
    call toc_02_77BE
    jp   .else_02_75B1

toc_02_726A.else_02_7485:
    ld   a, [$FFE4]
    sub  a, $90
    ld   [$C189], a
    clear [$DBAC]
    inc  a
    ld   [$C188], a
    call toc_01_27E2
    call toc_02_525B
    jp   .else_02_75B1

toc_02_726A.toc_02_749D:
    cp   $7C
    jp   c, .toc_02_771C

    push af
    jr   z, .else_02_74A9

    cp   $7D
    jr   nz, .else_02_74AC

toc_02_726A.else_02_74A9:
    call toc_02_7723
toc_02_726A.else_02_74AC:
    pop  af
    cp   $90
    jp   nc, .toc_02_771C

    sub  a, $7C
    sla  a
    sla  a
    ld   e, a
    ld   d, $00
    ld   hl, $4979
    add  hl, de
    ld   a, [$FFDB]
    rra
    rra
    rra
    and  %00000001
    ld   e, a
    ld   a, [$FFDC]
    rra
    rra
    and  %00000010
    or   e
    ld   e, a
    ld   d, $00
    add  hl, de
    ld   a, [hl]
    and  a
    jp   nz, .else_02_75B1

    jp   .toc_02_771C

toc_02_726A.toc_02_74DA:
    ld   a, [$C11C]
    cp   $02
    jp   z, .else_02_770F

    ld   a, [$C5A8]
    cp   $D5
    jp   z, .else_02_770F

    ld   a, [$FFDC]
    and  %00001111
    cp   $08
    jp   c, .toc_02_771C

    call toc_02_71E6
    jp   .else_02_770F

toc_02_726A.toc_02_74F9:
    ld   a, [$C15C]
    and  a
    jp   nz, .else_02_770F

    ld   a, [$FFDC]
    and  %00001111
    cp   $06
    jp   nc, .toc_02_75A4

    ld   a, [$DBA5]
    and  a
    jr   nz, .else_02_7566

    ifEq [$DB79], $01, .else_02_751C

    ifNot [$DB73], .else_02_7566

toc_02_726A.else_02_751C:
    ifEq [$FFF6], $D3, .else_02_753E

    cp   $24
    jr   z, .else_02_753E

    cp   $B5
    jr   z, .else_02_753E

    cp   $2B
    jr   z, .else_02_753E

    cp   $D9
    jr   z, .else_02_753E

    cp   $AC
    jr   z, .else_02_753E

    cp   $8C
    jr   z, .else_02_753E

    cp   $0E
    jr   nz, .else_02_7566

toc_02_726A.else_02_753E:
    ifNe [$DB79], $01, .else_02_754D

    ld   a, $12
    call toc_02_77C4
    jp   .else_02_770F

toc_02_726A.else_02_754D:
    clear [$DB47]
    assign [$C3C9], $98
    call toc_01_2185
    ld   a, [$C163]
    inc  a
    ld   [$DB10], a
    call toc_01_0915.toc_01_092A
    jp   .else_02_770F

toc_02_726A.else_02_7566:
    ld   a, [$C13E]
    and  a
    jp   nz, .else_02_770F

    ld   a, [$DBA5]
    and  a
    jp   nz, toc_01_0915

    jp   toc_01_0909

toc_02_726A.toc_02_7577:
    ld   a, [$D6F9]
    and  a
    jp   nz, .toc_02_771C

    ifLt [hObjectUnderEntity], 219, .else_02_75B1

    cp   221
    jr   nc, .else_02_75B1

    sub  a, $DB
    ld   e, a
    ld   d, $00
    ld   hl, $7B35
    add  hl, de
    ld   a, [$D6FB]
    xor  [hl]
    jr   nz, .else_02_75B1

    jp   .toc_02_771C

toc_02_726A.toc_02_759A:
    ld   hl, $C11F
    ld   [hl], $01
    cp   $0A
    jp   z, .toc_02_771C

toc_02_726A.toc_02_75A4:
    ld   a, [$FFDB]
    and  %00001111
    cp   $06
    jr   c, .else_02_75B1

    cp   $0B
    jp   c, .toc_02_771C

toc_02_726A.else_02_75B1:
    ifNe [hObjectUnderEntity], 105, .else_02_75C8

    ld   hl, $FFE3
    ld   a, [hLinkDirection]
    cp   [hl]
    jr   nz, .else_02_75C5

    ld   a, [$C15B]
    and  a
    jr   nz, .else_02_75C8

toc_02_726A.else_02_75C5:
    call toc_02_77FA.else_02_78B5
toc_02_726A.else_02_75C8:
    ld   hl, $FFE3
    ld   a, [hLinkDirection]
    cp   [hl]
    jr   nz, .else_02_7634

    ld   a, [$C13E]
    ld   hl, $C146
    or   [hl]
    jr   nz, .else_02_7634

    ld   a, [$DBA5]
    and  a
    ld   a, [hObjectUnderEntity]
    jr   z, .else_02_760B

    ld   e, $8A
    cp   169
    jr   z, .else_02_7626

    ld   e, $8B
    cp   79
    jr   z, .else_02_75F5

    cp   78
    jr   z, .else_02_75F5

    cp   136
    jr   nz, .else_02_75FD

toc_02_726A.else_02_75F5:
    ld   a, [$C14A]
    and  a
    jr   nz, .else_02_7634

    jr   .else_02_7626

toc_02_726A.else_02_75FD:
    cp   $DE
    jr   nz, .else_02_760B

    ld   a, [$DBD0]
    and  a
    jr   nz, .else_02_7634

    ld   e, $8C
    jr   .else_02_7626

toc_02_726A.else_02_760B:
    cp   $20
    jr   nz, .else_02_7634

    ifEq [$DB01], $03, .else_02_7634

    ifEq [$DB00], $03, .else_02_7634

    ld   a, [$DB66]
    and  %00000010
    jr   nz, .else_02_7634

    ld   e, $8D
toc_02_726A.else_02_7626:
    ld   a, [$C5A6]
    and  a
    jr   nz, .else_02_7634

    inc  a
    ld   [$C5A6], a
    ld   a, e
    call toc_02_77BE
toc_02_726A.else_02_7634:
    ld   a, [$C14A]
    and  a
    jr   nz, .else_02_766A

    ifNe [$C16A], $05, .else_02_766A

    ld   hl, $716C
    add  hl, bc
    ld   a, [hLinkDirection]
    cp   [hl]
    jp   nz, .else_02_770F

    ld   a, [$C1C3]
    inc  a
    ld   [$C1C3], a
    cp   $0C
    jp   c, .else_02_770F

    clear [$C1C3]
    clear [$C121]
    ld   [$C122], a
    assign [$C16D], $0C
    jp   .else_02_770F

toc_02_726A.else_02_766A:
    ld   a, [$C15B]
    and  a
    jr   nz, .else_02_7675

    assign [$C144], $03
toc_02_726A.else_02_7675:
    ld   a, [$FFF7]
    and  a
    ld   a, [hObjectUnderEntity]
    jr   z, .else_02_76DB

    cp   136
    jr   z, .else_02_7689

    cp   78
    jr   z, .else_02_7689

    cp   79
    jp   nz, .else_02_76DB

toc_02_726A.else_02_7689:
    ld   a, [$C14A]
    and  a
    jp   z, .else_02_770F

    ld   a, [$FFDB]
    and  %11110000
    ld   [hSwordIntersectedAreaX], a
    ld   a, [$FFDC]
    and  %11110000
    ld   [hSwordIntersectedAreaY], a
    ld   a, [$FFE9]
    ld   e, a
    ld   d, $00
    call toc_01_20A6
    ld   a, $05
    call toc_01_3C01
    jr   c, .else_02_770F

    ld   hl, $C200
    add  hl, de
    ld   a, [$FFE9]
    swap a
    and  %11110000
    add  a, $08
    ld   [hl], a
    ld   hl, $C210
    add  hl, de
    ld   a, [$FFE9]
    and  %11110000
    add  a, $10
    ld   [hl], a
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], d
    ld   hl, $FFF4
    ld   [hl], $09
    ld   hl, $C2F0
    add  hl, de
    ld   [hl], $0F
    ld   hl, $C340
    add  hl, de
    ld   [hl], $C4
    jr   .toc_02_771C

toc_02_726A.else_02_76DB:
    ld   e, $20
    cp   $C5
    jr   nz, .else_02_76E9

    ifNot [$DBA5], .else_02_76F9

    jr   .else_02_770F

toc_02_726A.else_02_76E9:
    ifNot [$DBA5], .else_02_770F

    ifEq [hObjectUnderEntity], 222, .else_02_76FB

    cp   167
    jr   nz, .else_02_770F

toc_02_726A.else_02_76F9:
    ld   e, $40
toc_02_726A.else_02_76FB:
    ld   a, [$C191]
    inc  a
    ld   [$C191], a
    cp   e
    jr   c, .else_02_770F

    ld   a, e
    ld   [$FFE8], a
    clear [$C191]
    call toc_02_51EB
toc_02_726A.else_02_770F:
    ld   hl, $7164
    add  hl, bc
    ld   a, [$C133]
    or   [hl]
    ld   [$C133], a
    scf
    ret


toc_02_726A.toc_02_771C:
    clear [$C191]
    scf
    ccf
    ret


toc_02_7723:
    ifEq [hObjectUnderEntity], 177, .else_02_772D

    cp   178
    jr   nz, .else_02_774F

toc_02_7723.else_02_772D:
    ld   a, [$FFDC]
    and  %00001111
    cp   $06
    jr   nc, .return_02_7768

    assign [$FFF2], $0C
    assign [$C11C], $05
    call toc_01_1495
    ld   [$DBC7], a
    ld   [$C198], a
    ld   [hLinkPositionZHigh], a
    ld   [hLinkPositionZLow], a
    call toc_01_093B
    ret


toc_02_7723.else_02_774F:
    cp   $C1
    jr   z, .else_02_775F

    cp   $C2
    jr   z, .else_02_775F

    cp   $BB
    jr   z, .else_02_775F

    cp   $BC
    jr   nz, .return_02_7768

toc_02_7723.else_02_775F:
    ld   a, [$FFDC]
    and  %00001111
    cp   $0C
    jp   nc, toc_01_0909

toc_02_7723.return_02_7768:
    ret


toc_02_7769:
    ifNot [$C14A], .return_02_77BD

    ifNe [wCurrentBank], $02, .return_02_77BD

    ld   a, [$C133]
    and  %00000011
    cp   $03
    jr   z, .else_02_7788

    ld   a, [$C133]
    and  %00001100
    cp   $0C
    jr   nz, .return_02_77BD

toc_02_7769.else_02_7788:
    call toc_01_093B
    ld   a, [hLinkPositionXIncrement]
    cpl
    inc  a
    sra  a
    sra  a
    ld   [hLinkPositionXIncrement], a
    ld   a, [hLinkPositionYIncrement]
    cpl
    inc  a
    sra  a
    sra  a
    ld   [hLinkPositionYIncrement], a
    assign [hLinkPositionZLow], $18
    assign [$C146], $02
    assign [$C157], $20
    ld   a, [hLinkDirection]
    and  %00000010
    sla  a
    ld   [$C158], a
    assign [$FFF2], $0B
    call toc_01_1594
toc_02_7769.return_02_77BD:
    ret


toc_02_77BE:
    call toc_01_2197
    jp   toc_01_1495

toc_02_77C4:
    call toc_01_218E
    jp   toc_01_1495

    db   $08, $F8, $00, $00, $00, $00, $F8, $08

toc_02_77D2:
    ld   a, [hLinkPositionX]
    and  %11110000
    ld   [$FFD7], a
    swap a
    ld   e, a
    ld   a, [hLinkPositionY]
    sub  a, $04
    and  %11110000
    ld   [$FFD8], a
    or   e
    ld   e, a
    ld   [$FFFA], a
    ld   d, $00
    ld   hl, $D711
    ld   a, h
    add  hl, de
    ld   h, a
    ld   a, [$DBA5]
    ld   d, a
    ld   a, [hl]
    ld   [$FFB8], a
    ld   [hObjectUnderEntity], a
    ld   e, a
    ret


toc_02_77FA:
    ifNe [$C11C], $01, .else_02_7809

    ld   a, [$C13B]
    add  a, $04
    ld   [$C13B], a
toc_02_77FA.else_02_7809:
    ifNot [$C1A4], .else_02_7847

    ld   hl, $C146
    ld   a, [$C14A]
    or   [hl]
    jr   nz, .else_02_781B

    call toc_01_1495
toc_02_77FA.else_02_781B:
    call toc_02_77D2
    ld   c, $04
    ifEq [$D463], $01, .else_02_7842

    ld   c, $FC
    ld   a, [$D6F9]
    and  a
    jr   nz, .else_02_7842

    call toc_01_29DB
    ld   c, $02
    cp   $05
    jr   z, .else_02_7842

    cp   $09
    jr   z, .else_02_7842

    cp   $08
    jr   nz, .return_02_7846

    ld   c, $FD
toc_02_77FA.else_02_7842:
    ld   a, c
    ld   [$C13B], a
toc_02_77FA.return_02_7846:
    ret


toc_02_77FA.else_02_7847:
    copyFromTo [$FFFA], [$FFFB]
    ld   a, [$C17B]
    and  a
    ret  nz

    ifNot [hLinkPositionZHigh], .else_02_7872

    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .return_02_7871

    ld   hl, gbRAM
    ld   a, [hLinkPositionY]
    add  a, $0B
    cp   136
    jr   nc, .return_02_7871

    ldi  [hl], a
    ld   a, [hLinkPositionX]
    add  a, $04
    ldi  [hl], a
    ld   a, $26
    ldi  [hl], a
    ld   [hl], $00
toc_02_77FA.return_02_7871:
    ret


toc_02_77FA.else_02_7872:
    clear [$D475]
    ifEq [$C11C], $02, .return_02_7871

toc_02_77FA.toc_02_787D:
    ld   a, [$C124]
    ld   hl, wDialogState
    or   [hl]
    jp   nz, .else_02_7980

    call toc_02_77D2
    ld   c, a
    ld   a, [$DBA5]
    and  a
    jr   nz, .else_02_7899

    ld   a, c
    cp   $61
    jp   z, .toc_02_796A

    jr   .else_02_78A7

toc_02_77FA.else_02_7899:
    ld   a, c
    cp   $4C
    jr   nz, .else_02_78A7

    ld   a, [hLinkPositionY]
    dec  a
    and  %00001111
    cp   $0C
    jr   nc, .else_02_78B5

toc_02_77FA.else_02_78A7:
    call toc_01_29DB
    ld   [$C181], a
    and  a
    jp   z, .else_02_7A5C

    cp   $E0
    jr   nz, .else_02_78F5

toc_02_77FA.else_02_78B5:
    ld   a, [$DBC7]
    and  a
    jr   nz, .return_02_78F4

    call toc_01_093B
    ld   a, [hLinkPositionXIncrement]
    cpl
    inc  a
    ld   [hLinkPositionXIncrement], a
    ld   a, [hLinkPositionYIncrement]
    cpl
    inc  a
    ld   [hLinkPositionYIncrement], a
    assign [$C146], $02
    ld   a, [$FFF9]
    and  a
    jr   nz, .else_02_78DE

    assign [hLinkPositionZLow], $10
    ld   a, [hLinkPositionZHigh]
    add  a, $02
    ld   [hLinkPositionZHigh], a
toc_02_77FA.else_02_78DE:
    assign [$C13E], $10
    assign [$DBC7], $30
    ld   a, [$DB94]
    add  a, $04
    ld   [$DB94], a
    assign [$FFF3], $03
toc_02_77FA.return_02_78F4:
    ret


toc_02_77FA.else_02_78F5:
    ld   a, [$C181]
    cp   $FF
    jp   z, .else_02_7A5C

    cp   $F0
    jr   c, .else_02_7904

    jp   toc_02_7E6E

toc_02_77FA.else_02_7904:
    cp   $51
    jr   z, .else_02_790C

    cp   $50
    jr   nz, .else_02_7980

toc_02_77FA.else_02_790C:
    call toc_01_093B
    assign [$C11F], $07
    incAddr $C1BB
    ld   hl, $C17B
    ld   a, [hFrameCounter]
    and  %00000011
    or   [hl]
    jr   nz, .return_02_797F

    ld   a, [hLinkPositionX]
    sub  a, $08
    ld   hl, $FFD7
    sub  a, [hl]
    bit  7, a
    ld   a, $FF
    jr   z, .else_02_7932

    ld   a, $01
toc_02_77FA.else_02_7932:
    ld   hl, hLinkPositionX
    add  a, [hl]
    ld   [hl], a
    ld   a, [$FFD8]
    add  a, $10
    ld   hl, hLinkPositionY
    sub  a, [hl]
    bit  7, a
    ld   a, $FF
    jr   nz, .else_02_7947

    ld   a, $01
toc_02_77FA.else_02_7947:
    ld   hl, hLinkPositionY
    add  a, [hl]
    ld   [hl], a
    ld   a, [hLinkPositionX]
    sub  a, $08
    add  a, $02
    and  %00001111
    cp   $04
    jr   nc, .return_02_797F

    ld   a, [hLinkPositionY]
    sub  a, $10
    add  a, $02
    and  %00001111
    cp   $04
    jr   nc, .return_02_797F

    ld   a, [hLinkPositionY]
    add  a, $03
    ld   [hLinkPositionY], a
toc_02_77FA.toc_02_796A:
    assign [$C11C], $06
    call toc_01_093B
    ld   [$C198], a
    copyFromTo [$C181], [$DBCB]
    assign [$FFF3], $0C
toc_02_77FA.return_02_797F:
    ret


toc_02_77FA.else_02_7980:
    ld   hl, gbRAM
    ifNe [$C181], $08, .else_02_7995

    ld   a, [$C13B]
    add  a, $FD
    ld   [$C13B], a
    jp   .else_02_7A5C

toc_02_77FA.else_02_7995:
    cp   $09
    jr   nz, .else_02_79A4

    ld   a, [$C13B]
    add  a, $02
    ld   [$C13B], a
    jp   .else_02_7A5C

toc_02_77FA.else_02_79A4:
    cp   $0B
    jr   z, .else_02_79AC

    cp   $07
    jr   nz, .else_02_7A10

toc_02_77FA.else_02_79AC:
    ifNot [hLinkWalksSlow], .else_02_79B4

    jp   toc_02_7EAA

toc_02_77FA.else_02_79B4:
    ifEq [$C1AD], $80, .else_02_7A10

    ifEq [$C11C], $08, .return_02_7A0F

    cp   $01
    jr   z, .return_02_7A0F

    ld   a, [hLinkPositionY]
    add  a, $FE
    call toc_02_571B.toc_02_571D
    ifEq [hObjectUnderEntity], 6, .else_02_79D9

    ld   a, [$DB0C]
    and  a
    jr   nz, .else_02_79F2

toc_02_77FA.else_02_79D9:
    assign [$FFB7], $50
    assign [$C11C], $08
    copyFromTo [hObjectUnderEntity], [$FF9C]
    ld   a, [hLinkPositionY]
    add  a, $02
    ld   [hLinkPositionY], a
    assign [$C167], $01
    ret


toc_02_77FA.else_02_79F2:
    assign [$C11C], $01
    clear [$FF9C]
    call toc_01_1495
    ld   a, [hLinkDirection]
    ld   e, a
    ld   d, b
    ld   hl, $77CA
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    ld   hl, $77CE
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionYIncrement], a
toc_02_77FA.return_02_7A0F:
    ret


toc_02_77FA.else_02_7A10:
    cp   $06
    jp   z, toc_02_7B37

    cp   $05
    jr   nz, .else_02_7A5C

    ld   a, [hLinkPositionY]
    add  a, $0C
    ldi  [hl], a
    ld   a, [hLinkPositionX]
    add  a, $00
    ldi  [hl], a
    ld   a, $1C
    ldi  [hl], a
    ld   a, [hFrameCounter]
    rla
    rla
    and  %00010000
    push af
    ldi  [hl], a
    ld   a, [hLinkPositionY]
    add  a, $0C
    ldi  [hl], a
    ld   a, [hLinkPositionX]
    add  a, $08
    ldi  [hl], a
    ld   a, $1C
    ldi  [hl], a
    pop  af
    or   $20
    ld   [hl], a
    assign [$C11F], $03
    ld   a, [hFrameCounter]
    and  %00001111
    jr   nz, .else_02_7A54

    ld   a, [hPressedButtonsMask]
    and  %00001111
    jr   z, .else_02_7A54

    assign [$FFF2], $0E
toc_02_77FA.else_02_7A54:
    ld   a, [$C13B]
    add  a, $02
    ld   [$C13B], a
toc_02_77FA.else_02_7A5C:
    clear [$C1BB]
    ifNe [$C11C], $01, .else_02_7A6C

    assign [$C11C], $00
toc_02_77FA.else_02_7A6C:
    ifNe [$C181], $04, .else_02_7AA3

    ifLt [hObjectUnderEntity], 219, .else_02_7AA3

    cp   221
    jr   nc, .else_02_7AA3

    sub  a, $DB
    ld   e, a
    ld   d, $00
    ld   hl, $7B35
    add  hl, de
    ld   a, [$D6FB]
    xor  [hl]
    jr   z, .else_02_7AA3

    ld   a, [$D6F8]
    ld   e, a
    ld   d, $00
    ld   hl, $7B29
    add  hl, de
    ld   a, [$C13B]
    add  a, [hl]
    ld   [$C13B], a
    assign [$D6F9], $01
    ret


toc_02_77FA.else_02_7AA3:
    ifNot [$D6F9], .else_02_7AB1

    assign [$FFF4], $07
    clear [$D6F9]
toc_02_77FA.else_02_7AB1:
    ld   a, [$DBA5]
    and  a
    jp   z, .return_02_7B28

    ld   a, [$C124]
    and  a
    jr   nz, .return_02_7B28

    ifNe [hObjectUnderEntity], 170, .else_02_7AF6

    ld   a, [$C1CB]
    and  a
    jr   nz, .else_02_7AF6

    ld   a, [$C1CA]
    inc  a
    ld   [$C1CA], a
    cp   $18
    jr   nz, .else_02_7AED

    assign [$C1CB], $60
    assign [$FFF3], $0E
    assign [$FFA5], $03
    ifNe [$FFF6], $C3, .else_02_7AED

    ld   hl, $D879
    set  4, [hl]
toc_02_77FA.else_02_7AED:
    ld   a, [$C13B]
    add  a, $FD
    ld   [$C13B], a
    ret


toc_02_77FA.else_02_7AF6:
    clear [$C1CA]
    ld   a, [$FFFA]
    ld   hl, $FFFB
    cp   [hl]
    ld   hl, $C1C9
    jr   nz, .else_02_7B26

    ifNe [hObjectUnderEntity], 223, .else_02_7B26

    ld   a, [hLinkInteractiveMotionBlocked]
    ld   e, a
    ld   a, [$C1A9]
    ld   d, a
    ld   a, [wDialogState]
    or   e
    or   d
    jr   nz, .else_02_7B26

    inc  [hl]
    ld   a, [hl]
    cp   %00101000
    jr   c, .return_02_7B28

    assign [$FFF4], $2B
    jp   toc_02_4CAC

toc_02_77FA.else_02_7B26:
    ld   [hl], $00
toc_02_77FA.return_02_7B28:
    ret


    db   $FC, $FF, $FF, $FE, $FE, $FE, $FD, $FD
    db   $FD, $FC, $FC, $FC, $00, $02

toc_02_7B37:
    ld   a, [hLinkPositionY]
    add  a, $08
    ldi  [hl], a
    ld   a, [hLinkPositionX]
    add  a, $FF
    ldi  [hl], a
    ld   a, $1A
    ldi  [hl], a
    ld   a, [$C120]
    rla
    rla
    and  %00100000
    push af
    ldi  [hl], a
    ld   a, [hLinkPositionY]
    add  a, $08
    ldi  [hl], a
    ld   a, [hLinkPositionX]
    add  a, $07
    ldi  [hl], a
    ld   a, $1A
    ldi  [hl], a
    pop  af
    xor  $20
    ld   [hl], a
    assign [$C11F], $03
    ret


    db   $C6, $3A, $00, $00, $00, $00, $3A, $C6
    db   $04, $FC, $00, $00, $00, $00, $FC, $04

toc_02_7B74:
    ld   a, [$C124]
    cp   $00
    jp   z, toc_02_7C5D

    push af
    cp   $03
    jp   c, .toc_02_7C50

    ld   a, [$C125]
    ld   c, a
    ld   b, $00
    ld   hl, $7B64
    add  hl, bc
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    ld   hl, $7B68
    add  hl, bc
    ld   a, [hl]
    ld   [hLinkPositionYIncrement], a
    push bc
    call toc_01_20D6
    pop  bc
    ld   hl, $7B6C
    add  hl, bc
    ld   a, [hBaseScrollX]
    add  a, [hl]
    ld   [hBaseScrollX], a
    ld   hl, $7B70
    add  hl, bc
    ld   a, [hBaseScrollY]
    add  a, [hl]
    ld   [hBaseScrollY], a
    ld   hl, $C12D
    cp   [hl]
    jp   nz, .toc_02_7C50

    ld   a, [hBaseScrollX]
    ld   hl, $C12C
    cp   [hl]
    jp   nz, .toc_02_7C50

    pop  af
    ifNot [hNextMusicTrackToFadeInto], .else_02_7BC9

    call toc_01_27A8
    clear [hNextMusicTrackToFadeInto]
toc_02_7B74.else_02_7BC9:
    call toc_01_1495
    ld   [hLinkPositionZLow], a
    ld   [$C124], a
    copyFromTo [hLinkPositionX], [$DBB1]
    copyFromTo [hLinkPositionY], [$DBB2]
    ifNe [$C125], $03, .else_02_7C06

    assign [hLinkPositionYIncrement], $01
    call toc_02_7180
    ifEq [hObjectUnderEntity], 219, .else_02_7C06

    cp   220
    jr   z, .else_02_7C06

    cp   225
    jr   z, .else_02_7BFD

    ifNot [$C133], .else_02_7C06

toc_02_7B74.else_02_7BFD:
    ld   a, [$C17B]
    and  a
    jr   nz, .else_02_7C06

    call toc_02_71E6.toc_02_71EA
toc_02_7B74.else_02_7C06:
    ifNot [$C169], .else_02_7C12

    ld   [$FFF2], a
    clear [$C169]
toc_02_7B74.else_02_7C12:
    call toc_01_3819
    assign [hAnimatedTilesFrameCount], $FF
    ld   a, [$DBA5]
    and  a
    ret  z

    ld   d, a
    ifGte [$FFF7], $1A, .else_02_7C2A

    cp   $06
    jr   c, .else_02_7C2A

    inc  d
toc_02_7B74.else_02_7C2A:
    ld   a, [$FFF6]
    ld   e, a
    call toc_01_29B8
    cp   $1A
    jr   z, .else_02_7C40

    cp   $19
    jr   z, .else_02_7C40

    ld   a, [$C18E]
    and  %11100000
    cp   $80
    ret  nz

toc_02_7B74.else_02_7C40:
    ld   a, [$DBCD]
    and  a
    ret  z

    ld   a, [$FFF8]
    and  %00010000
    ret  nz

    assign [$D462], $0C
    ret


toc_02_7B74.toc_02_7C50:
    pop  af
    dec  a
    jumptable
    dw JumpTable_7C7E_02 ; 00
    dw JumpTable_7DA1_02 ; 01
    dw JumpTable_7DE2_02 ; 02
    dw JumpTable_7E59_02 ; 03
    dw JumpTable_7E5D_02 ; 04

toc_02_7C5D:
    ret


    db   $01, $01, $02, $00, $00, $02, $01, $02
    db   $00, $02, $02, $00, $02, $02, $00, $02
    db   $01, $02, $00, $02, $01, $02, $00, $02
    db   $00, $00, $00, $00, $02, $02, $02, $02

JumpTable_7C7E_02:
    ld   a, [$C125]
    ld   c, a
    ld   b, $00
    ifNot [$DBA5], .else_02_7CED

    ifGte [$FFF7], $0B, .else_02_7CED

    cp   $08
    jr   nz, .else_02_7CC8

    ifNe [$FFF6], $71, .else_02_7CC8

    ld   a, c
    cp   $03
    jr   z, .else_02_7CC8

    ld   a, [$DB7C]
    ld   e, a
    ld   d, $00
    ld   hl, $7C5E
    add  hl, de
    ld   a, [$C5AA]
    ld   e, a
    inc  a
    ld   [$C5AA], a
    add  hl, de
    ld   a, c
    cp   [hl]
    jr   z, .else_02_7CBD

    clear [$C5AA]
    jp   .else_02_7D25

JumpTable_7C7E_02.else_02_7CBD:
    ld   a, e
    cp   $07
    jp   nz, .else_02_7D25

    assign [$C169], $02
JumpTable_7C7E_02.else_02_7CC8:
    clear [$C5AA]
    ld   hl, $7DDE
    add  hl, bc
    ld   a, c
    cp   $02
    jr   nz, .else_02_7CE7

    ifNe [$FFF7], $05, .else_02_7CE7

    ifNe [$DBAE], $1D, .else_02_7CE7

    assign [$DBAE], $35
JumpTable_7C7E_02.else_02_7CE7:
    ld   a, [hl]
    ld   hl, $DBAE
    jr   .toc_02_7D0C

JumpTable_7C7E_02.else_02_7CED:
    ifNot [$C10C], .else_02_7D04

    ld   a, c
    cp   $02
    jr   nz, .else_02_7D04

    assign [$C169], $1E
    ld   a, $63
    ld   hl, $FFF6
    jr   .toc_02_7D0D

JumpTable_7C7E_02.else_02_7D04:
    ld   hl, $7DDA
    add  hl, bc
    ld   a, [hl]
    ld   hl, $FFF6
JumpTable_7C7E_02.toc_02_7D0C:
    add  a, [hl]
JumpTable_7C7E_02.toc_02_7D0D:
    ld   [hl], a
    cp   $41
    jr   nz, .else_02_7D25

    ld   a, c
    cp   $02
    jr   nz, .else_02_7D25

    ld   hl, $D841
    bit  6, [hl]
    jr   nz, .else_02_7D25

    set  6, [hl]
    assign [$C169], $02
JumpTable_7C7E_02.else_02_7D25:
    call toc_01_2ED7
    call toc_01_36E6
    call JumpTable_1C56_00.toc_01_1CCC
    call toc_01_149B
    ifNot [$C1CF], .else_02_7D4C

    clear [$C1CF]
    ld   a, [$D47C]
    and  a
    ld   a, [hDefaultMusicTrack]
    jr   z, .else_02_7D45

    ld   a, $49
JumpTable_7C7E_02.else_02_7D45:
    ld   [hNextMusicTrackToFadeInto], a
    call toc_01_27CA
    jr   .else_02_7D99

JumpTable_7C7E_02.else_02_7D4C:
    ld   a, [$DBA5]
    and  a
    jr   nz, .else_02_7D99

    ifNot [$DB4E], .else_02_7D99

    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    ld   hl, $4000
    add  hl, de
    ld   a, [hl]
    ld   hl, hDefaultMusicTrack
    cp   [hl]
    jr   z, .else_02_7D99

    ld   c, a
    cp   $25
    jr   nc, .else_02_7D77

    ld   b, $00
    ld   hl, $4120
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_02_7D8D

JumpTable_7C7E_02.else_02_7D77:
    ifNot [$D47C], .else_02_7D90

    ifEq [$FFBD], $49, .else_02_7D96

    call .else_02_7D90
    assign [hNextMusicTrackToFadeInto], $49
    ld   [$FFBD], a
    ret


JumpTable_7C7E_02.else_02_7D8D:
    ld   a, c
    ld   [$FFBD], a
JumpTable_7C7E_02.else_02_7D90:
    ld   a, c
    ld   [hNextMusicTrackToFadeInto], a
    call toc_01_27CA
JumpTable_7C7E_02.else_02_7D96:
    ld   a, c
    ld   [hDefaultMusicTrack], a
JumpTable_7C7E_02.else_02_7D99:
    ld   a, [$C124]
    inc  a
    ld   [$C124], a
    ret


JumpTable_7DA1_02:
    call toc_01_09AA
    ifNe [$D6FA], $02, .else_02_7DAF

    assign [$FFBB], $02
JumpTable_7DA1_02.else_02_7DAF:
    jp   JumpTable_7C7E_02.else_02_7D99

    db   $00, $00, $02, $02, $14, $0C, $00, $00
    db   $00, $00, $03, $02, $14, $1E, $C0, $00
    db   $08, $08, $0A, $0A, $0A, $0A, $08, $08
    db   $00, $09, $70, $00, $40, $40, $02, $02
    db   $A0, $60, $00, $00, $00, $00, $80, $80
    db   $01, $FF, $F0, $10, $01, $FF, $F8, $08

JumpTable_7DE2_02:
    ld   a, [$C125]
    ld   c, a
    ld   b, $00
    ld   hl, $7DD2
    add  hl, bc
    ld   a, [$C12C]
    add  a, [hl]
    ld   [$C12C], a
    ld   hl, $7DD6
    add  hl, bc
    ld   a, [$C12D]
    add  a, [hl]
    ld   [$C12D], a
    ld   hl, $7DBE
    add  hl, bc
    ld   a, [$C12F]
    add  a, [hl]
    rl   d
    and  %11011111
    ld   [$C127], a
    ld   hl, $7DBA
    add  hl, bc
    ld   a, [$C12E]
    rr   d
    adc  [hl]
    and  %00000011
    ld   [$C126], a
    ld   hl, $7DB6
    add  hl, bc
    ld   a, [$C12F]
    add  a, [hl]
    rl   d
    and  %11011111
    ld   [$C12F], a
    ld   hl, $7DB2
    add  hl, bc
    ld   a, [$C12E]
    rr   d
    adc  [hl]
    and  %00000011
    ld   [$C12E], a
    ld   hl, $7DC2
    add  hl, bc
    ld   a, [hl]
    ld   [$C128], a
    ld   hl, $7DC6
    add  hl, bc
    ld   a, [hl]
    ld   [$C129], a
    ld   hl, $7DCA
    add  hl, bc
    ld   a, [hl]
    ld   [$C12A], a
    clear [$C12B]
    jp   JumpTable_7C7E_02.else_02_7D99

JumpTable_7E59_02:
    call toc_01_267A
    ret


JumpTable_7E5D_02:
    ret


    db   $00, $00, $FF, $01, $01, $FF, $01, $FF
    db   $01, $FF, $00, $00, $01, $01, $FF, $FF

toc_02_7E6E:
    ld   a, [hFrameCounter]
    and  %00000011
    ld   hl, $C167
    or   [hl]
    ld   hl, hLinkInteractiveMotionBlocked
    or   [hl]
    ld   hl, $C1A9
    or   [hl]
    ret  nz

    ld   a, [$C181]
    sub  a, $F0
    ld   e, a
    ld   d, $00
    ld   hl, $7E5E
    add  hl, de
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   [hLinkPositionX], a
    ld   hl, $7E66
    add  hl, de
    ld   a, [hLinkPositionY]
    add  a, [hl]
    ld   [hLinkPositionY], a
    ret


    db   $FC, $FA, $F8, $F6, $0C, $00, $00, $F4
    db   $00, $00, $00, $00, $00, $F4, $0C, $00

toc_02_7EAA:
    ld   a, [hFrameCounter]
    and  %00000000
    ld   hl, $C124
    or   [hl]
    ld   hl, $C1A9
    or   [hl]
    ld   hl, hLinkInteractiveMotionBlocked
    or   [hl]
    ld   hl, wDialogState
    or   [hl]
    ld   hl, $C14F
    or   [hl]
    jr   nz, toc_02_7EFD

    ld   e, $01
    ifNe [hObjectUnderEntity], 14, toc_02_7EE4

    ifEq [$FFF6], $3E, toc_02_7EE7

    inc  e
    cp   $3D
    jr   z, toc_02_7EE7

    inc  e
    cp   $3C
    jr   z, toc_02_7EE7

    cp   $3F
    jr   nz, toc_02_7EFD

    ld   e, $00
    jr   toc_02_7EE7

toc_02_7EE4:
    sub  a, $E7
    ld   e, a
toc_02_7EE7:
    ld   d, $00
    ld   hl, $7E9A
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionXIncrement], a
    ld   hl, $7EA2
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionYIncrement], a
    call toc_01_20D6
    call toc_02_7180
toc_02_7EFD:
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
    db   $FF, $FF
