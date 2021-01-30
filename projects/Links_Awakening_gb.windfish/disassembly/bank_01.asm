SECTION "ROM Bank 01", ROMX[$4000], BANK[$01]

toc_01_4000:
    ld   a, [$DB96]
    jumptable
    dw JumpTable_4010_01 ; 00
    dw JumpTable_4041_01 ; 01
    dw JumpTable_404D_01 ; 02
    dw JumpTable_4065_01 ; 03
    dw JumpTable_4073_01 ; 04
    dw JumpTable_55FD_01 ; 05

JumpTable_4010_01:
    call JumpTable_1C56_00.else_01_1CCC
    call toc_01_0B22
    call toc_01_1776
    ifNe [$C16B], $04, .return_01_4040

    assign [hVolumeRight], $03
    assign [hVolumeLeft], $30
    call JumpTable_4434_01.toc_01_4445
    clear [$C1BF]
    ld   [$C14F], a
    ld   [$C1B8], a
    ld   [$C1B9], a
    ld   [$C1B5], a
    assign [wTileMapToLoad], $0F
JumpTable_4010_01.return_01_4040:
    ret


JumpTable_4041_01:
    assign [wTileMapToLoad], $0D
    clear [$C13F]
    jp   JumpTable_4434_01.toc_01_4445

JumpTable_404D_01:
    assign [$D6FF], $0D
    assign [$DB9A], $FF
    clear [hBaseScrollX]
    ld   [hBaseScrollY], a
    ld   [$C16B], a
    ld   [$C16C], a
    jp   JumpTable_4434_01.toc_01_4445

JumpTable_4065_01:
    call toc_01_17C3
    ifNe [$C16B], $04, .return_01_4072

    call JumpTable_4434_01.toc_01_4445
JumpTable_4065_01.return_01_4072:
    ret


JumpTable_4073_01:
    call toc_01_40EB
    ld   a, [$FFCC]
    and  %10110000
    jr   z, toc_01_40CE.toc_01_40E8

    assign [$FFF2], $13
    ifEq [$C13F], $01, toc_01_40C2

    call JumpTable_4434_01.toc_01_4445
    clear [$C16B]
    ld   [$C16C], a
    ifNot [$DBA5], .return_01_409E

    clear [$C50A]
    ld   [$C116], a
JumpTable_4073_01.return_01_409E:
    ret


    db   $AF, $EA, $98, $DB, $EA, $99, $DB, $E0
    db   $48, $E0, $49, $EA, $97, $DB, $E0, $47
    db   $F0, $98, $EA, $9D, $DB, $F0, $99, $EA
    db   $9E, $DB, $CD, $2A, $51, $3E, $80, $EA
    db   $C7, $DB, $C9

toc_01_40C2:
    call toc_01_27D2
    call toc_01_5B94
    call toc_01_2985
    call toc_01_5F1A
toc_01_40CE:
    assign [gbLCDC], LCDCF_BG_DISPLAY | LCDCF_OBJ_16_16 | LCDCF_OBJ_DISPLAY | LCDCF_ON | LCDCF_TILEMAP_9C00
    ld   [$D6FD], a
    assign [gbWX], $07
    assign [$DB9A], $80
    ld   [gbWY], a
    assign [hVolumeRight], $07
    assign [hVolumeLeft], $70
toc_01_40CE.toc_01_40E8:
    ret


    db   $48, $58

toc_01_40EB:
    ld   hl, $C13F
    call toc_01_6E2D
    ld   a, [$FFCC]
    and  %01001100
    jr   z, .else_01_40FC

    ld   a, [hl]
    inc  a
    and  %00000001
    ld   [hl], a
toc_01_40EB.else_01_40FC:
    ld   e, [hl]
    ld   d, $00
    ld   hl, $40E9
    add  hl, de
    ld   a, [hl]
    ld   hl, $C018
    ldi  [hl], a
    ld   a, $24
    ldi  [hl], a
    ld   a, $BE
    ldi  [hl], a
    ld   [hl], $00
    ret


    db   $F0, $B7, $A7, $C2, $7D, $41, $1E, $70
    db   $3E, $00, $E0, $47, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $1D, $20, $DB, $1E, $30, $3E
    db   $40, $E0, $47, $1D, $20, $F9, $1E, $30
    db   $3E, $80, $E0, $47, $1D, $20, $F9, $1E
    db   $FF, $3E, $C0, $E0, $47, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $1D
    db   $20, $E7, $1E, $30, $3E, $80, $E0, $47
    db   $1D, $20, $F9, $1E, $30, $3E, $40, $E0
    db   $47, $1D, $20, $F9, $AF, $EA, $97, $DB
    db   $E0, $47, $C9

toc_01_4184:
    ld   a, [$FF9C]
    jumptable
    dw JumpTable_41C5_01 ; 00
    dw JumpTable_4249_01 ; 01
    dw JumpTable_4253_01 ; 02
    dw JumpTable_427F_01 ; 03
    dw JumpTable_428E_01 ; 04

    db   $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A
    db   $6A, $6A, $00, $00, $00, $0A, $04, $06
    db   $00, $0A, $04, $06, $00, $0A, $04, $06
    db   $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C
    db   $1C, $1C, $1B, $1A, $19, $18, $17, $16
    db   $15, $14, $13, $12, $11, $10, $10, $10
    db   $10, $10, $10, $10

JumpTable_41C5_01:
    clear [$C155]
    ld   [$C156], a
    ld   a, [$FFB7]
    and  a
    jr   nz, .else_01_4219

    assign [$FFB7], $10
    assign [$FF9C], $01
    assign [wTileMapToLoad], $0F
    assign [hLinkAnimationState], LINK_ANIMATION_STATE_NO_UPDATE
    ld   a, [$DB57]
    add  a, $01
    daa
    ld   [$DB57], a
    ld   a, [$DB58]
    adc  $00
    daa
    ld   [$DB58], a
    cp   $10
    jr   c, .else_01_4202

    assign [$DB57], $99
    assign [$DB58], $09
JumpTable_41C5_01.else_01_4202:
    clear [$C1BF]
    ld   [$D415], a
    ld   [$D47C], a
    ld   [$D47A], a
    ld   [$C3CB], a
    ld   [$C3CC], a
    ld   [$C3CD], a
    ret


JumpTable_41C5_01.else_01_4219:
    rra
    rra
    rra
    and  %00111111
    ld   e, a
    ld   d, $00
    ld   hl, $4191
    add  hl, de
    ld   a, [hl]
    ld   [hLinkAnimationState], a
    ld   a, [$FFB7]
    rra
    rra
    rra
    and  %00011111
    ld   e, a
    ld   hl, $41A9
    add  hl, de
    ld   a, [hl]
    ld   [$C3CD], a
    assign [$C3CB], $01
    assign [$DB98], $1C
    copyFromTo [$DB97], [$DB99]
    ret


JumpTable_4249_01:
    assign [wTileMapToLoad], $0D
    incAddr $FF9C
    ret


JumpTable_4253_01:
    assign [$DB97], $E4
    assign [$D6FF], $0A
    assign [$DB9A], $FF
    clear [hBaseScrollX]
    ld   [hBaseScrollY], a
    incAddr $FF9C
    call toc_01_27E2
    ret


    db   $00, $FE, $FD, $FE, $00, $02, $03, $02
    db   $00, $04, $08, $0C, $10, $0C, $08, $04

JumpTable_427F_01:
    ld   a, [$FFB7]
    and  a
    jr   nz, .return_01_428D

    incAddr $FF9C
    assign [$D368], $03
JumpTable_427F_01.return_01_428D:
    ret


JumpTable_428E_01:
    call toc_01_42E6
    ld   a, [$FFCC]
    and  %10110000
    jr   z, .return_01_42E2

    ifEq [$C13F], $01, .else_01_42DC

    cp   $00
    jr   z, .else_01_42A7

    ld   [$DBD1], a
    jr   .toc_01_42AA

JumpTable_428E_01.else_01_42A7:
    call toc_01_5B94
JumpTable_428E_01.toc_01_42AA:
    xor  a
    ld   hl, $C280
    ld   e, $10
JumpTable_428E_01.loop_01_42B0:
    ldi  [hl], a
    dec  e
    jr   nz, .loop_01_42B0

    ld   [$DB98], a
    ld   [$DB99], a
    ld   [gbOBP0], a
    ld   [gbOBP1], a
    ld   [$DB97], a
    ld   [gbBGP], a
    ld   [$D6FB], a
    ld   [$D475], a
    copyFromTo [hLinkPositionX], [$DB9D]
    copyFromTo [hLinkPositionY], [$DB9E]
    call toc_01_512A
    assign [$DBC7], $80
    ret


JumpTable_428E_01.else_01_42DC:
    call toc_01_5B94
    call toc_01_5F1A
JumpTable_428E_01.return_01_42E2:
    ret


    db   $50, $60, $70

toc_01_42E6:
    ld   hl, $C13F
    call toc_01_6E2D
    ld   a, [$FFCC]
    and  %01001000
    jr   z, .else_01_42FA

    ld   a, [hl]
    inc  a
    cp   $03
    jr   nz, .else_01_42F9

    xor  a
toc_01_42E6.else_01_42F9:
    ld   [hl], a
toc_01_42E6.else_01_42FA:
    ld   a, [$FFCC]
    and  %00000100
    jr   z, .else_01_4309

    ld   a, [hl]
    dec  a
    cp   $FF
    jr   nz, .else_01_4308

    ld   a, $02
toc_01_42E6.else_01_4308:
    ld   [hl], a
toc_01_42E6.else_01_4309:
    ld   e, [hl]
    ld   d, $00
    ld   hl, $42E3
    add  hl, de
    ld   a, [hl]
    ld   hl, $C018
    ldi  [hl], a
    ld   a, $24
    ldi  [hl], a
    ld   a, $BE
    ldi  [hl], a
    ld   [hl], $00
    ret


toc_01_431E:
    ld   a, [$DB96]
    jumptable
    dw JumpTable_433F_01 ; 00
    dw JumpTable_43B3_01 ; 01
    dw JumpTable_4434_01 ; 02
    dw JumpTable_444A_01 ; 03
    dw JumpTable_4468_01 ; 04
    dw JumpTable_446F_01 ; 05
    dw JumpTable_4476_01 ; 06
    dw JumpTable_0B53_00 ; 07

    db   $00, $00, $00, $00, $00, $00, $30, $00
    db   $00, $00, $00, $00, $00

JumpTable_433F_01:
    call toc_01_27D2
    call JumpTable_4434_01.toc_01_4445
    ifNot [$DBA5], .else_01_439C

    ld   a, [$FFF7]
    ld   e, a
    sla  a
    sla  a
    add  a, e
    ld   e, a
    ld   d, $00
    ld   hl, $DB16
    add  hl, de
    ld   de, $DBCC
    ld   c, $05
JumpTable_433F_01.loop_01_435F:
    ld   a, [$FFF7]
    cp   $0A
    ifEq [$FFF7], $08, .else_01_436B

    jr   c, .else_01_436E

JumpTable_433F_01.else_01_436B:
    xor  a
    jr   z, .else_01_436F

JumpTable_433F_01.else_01_436E:
    ldi  a, [hl]
JumpTable_433F_01.else_01_436F:
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop_01_435F

    ld   a, [$FFF7]
    ld   e, a
    ld   d, $00
    ld   hl, $4332
    add  hl, de
    ld   a, [hl]
    ld   [$DBB0], a
    ld   a, e
    cp   $08
    jr   z, .else_01_43AD

    cp   $0A
    jr   nc, .else_01_43AD

    cp   $06
    jr   nz, .else_01_4393

    ld   a, [$FFF9]
    and  a
    jr   nz, .else_01_43AD

JumpTable_433F_01.else_01_4393:
    call toc_01_5357
    assign [$D6FF], $07
    ret


JumpTable_433F_01.else_01_439C:
    assign [$D6FF], $02
    call toc_01_27ED
    ld   hl, hFrameCounter
    or   [hl]
    and  %00000011
    ld   [$FFB9], a
    ret


JumpTable_433F_01.else_01_43AD:
    assign [$D6FF], $09
    ret


JumpTable_43B3_01:
    call toc_01_2980
    clear [$C11C]
    call JumpTable_4434_01.toc_01_4445
    copyFromTo [$DB9D], [hLinkPositionX]
    ld   [$DBB1], a
    copyFromTo [$DB9E], [hLinkPositionY]
    ld   [$DBB2], a
    copyFromTo [$DBC8], [hLinkPositionZHigh]
    and  a
    jr   z, .else_01_43DA

    assign [$C146], $02
JumpTable_43B3_01.else_01_43DA:
    assign [$C125], $04
    call toc_01_2ED7
    call toc_01_36E6
    call toc_01_5D6B
    assign [hAnimatedTilesFrameCount], 255
    ifNot [$DBA5], .else_01_4426

    ld   d, a
    ifGte [$FFF7], $1A, .else_01_43FE

    cp   $06
    jr   c, .else_01_43FE

    inc  d
JumpTable_43B3_01.else_01_43FE:
    ld   a, [$FFF6]
    ld   e, a
    call toc_01_29B8
    cp   $1A
    jr   z, .else_01_4415

    cp   $19
    jr   z, .else_01_4415

    ld   a, [$C18E]
    and  %11100000
    cp   $80
    jr   nz, .else_01_4426

JumpTable_43B3_01.else_01_4415:
    ifNot [$DBCD], .else_01_4426

    ld   a, [$FFF8]
    and  %00010000
    jr   nz, .else_01_4426

    assign [$D462], $0C
JumpTable_43B3_01.else_01_4426:
    ld   a, [$DBA5]
    and  a
    ld   a, $06
    jr   nz, .else_01_4430

    ld   a, $07
JumpTable_43B3_01.else_01_4430:
    ld   [wTileMapToLoad], a
    ret


JumpTable_4434_01:
    assign [hWorldTileset], $0F
    call toc_01_09AA
    clear [hNeedsUpdatingBGTiles]
    ld   [hNeedsUpdatingEnemiesTiles], a
    assign [wTileMapToLoad], $09
JumpTable_4434_01.toc_01_4445:
    incAddr $DB96
    ret


JumpTable_444A_01:
    assign [wTileMapToLoad], $01
    ifNot [$D6FA], .else_01_4464

    assign [$D6F8], $05
    ifNot [$C1CB], .else_01_4464

    assign [$FFA5], $03
JumpTable_444A_01.else_01_4464:
    call JumpTable_4434_01.toc_01_4445
    ret


JumpTable_4468_01:
    call toc_01_3E6F
    call JumpTable_4434_01.toc_01_4445
    ret


JumpTable_446F_01:
    call toc_01_3E8A
    call JumpTable_4434_01.toc_01_4445
    ret


JumpTable_4476_01:
    call JumpTable_55FD_01.toc_01_5643
    ld   a, [gbLCDC]
    or   LCDCF_WINDOW_ON
    ld   [$D6FD], a
    ld   [gbLCDC], a
    call JumpTable_4434_01.toc_01_4445
    copyFromTo [$C11C], [$D463]
    assign [$C11C], $04
    clear [$C16B]
    ld   [$C16C], a
    ifNot [$C3CB], .else_01_44B2

    copyFromTo [$C5AD], [$DB97]
    assign [$DB98], $1C
    assign [$DB99], $E4
    assign [$C16B], $04
JumpTable_4476_01.else_01_44B2:
    jp   toc_01_27BD

    db   $F0, $CC, $E6, $90, $CA, $CB, $45

toc_01_44BC:
    ld   [$D47B], a
    call toc_01_27B5
    copyFromTo [$A454], [$DB80]
    call toc_01_27B5
    copyFromTo [$A455], [$DB81]
    call toc_01_27B5
    copyFromTo [$A456], [$DB82]
    call toc_01_27B5
    copyFromTo [$A457], [$DB83]
    call toc_01_27B5
    copyFromTo [$A458], [$DB84]
    call toc_01_27B5
    copyFromTo [$A45F], [$DC06]
    call toc_01_27B5
    copyFromTo [$A460], [$DC09]
    call toc_01_27B5
    copyFromTo [$A45C], [$DC00]
    call toc_01_27B5
    copyFromTo [$A45D], [$DC01]
    call toc_01_27B5
    copyFromTo [$A7D9], [$DB85]
    call toc_01_27B5
    copyFromTo [$A7DA], [$DB86]
    call toc_01_27B5
    copyFromTo [$A7DB], [$DB87]
    call toc_01_27B5
    copyFromTo [$A7DC], [$DB88]
    call toc_01_27B5
    copyFromTo [$A7DD], [$DB89]
    call toc_01_27B5
    copyFromTo [$A7E4], [$DC07]
    call toc_01_27B5
    copyFromTo [$A7E5], [$DC0A]
    call toc_01_27B5
    copyFromTo [$A7E1], [$DC02]
    call toc_01_27B5
    copyFromTo [$A7E2], [$DC03]
    call toc_01_27B5
    copyFromTo [$AB5E], [$DB8A]
    call toc_01_27B5
    copyFromTo [$AB5F], [$DB8B]
    call toc_01_27B5
    copyFromTo [$AB60], [$DB8C]
    call toc_01_27B5
    copyFromTo [$AB61], [$DB8D]
    call toc_01_27B5
    copyFromTo [$AB62], [$DB8E]
    call toc_01_27B5
    copyFromTo [$AB69], [$DC08]
    call toc_01_27B5
    copyFromTo [$AB6A], [$DC0B]
    call toc_01_27B5
    copyFromTo [$AB66], [$DC04]
    call toc_01_27B5
    copyFromTo [$AB67], [$DC05]
    assign [wGameMode], GAMEMODE_FILE_SELECT
    clear [$DB96]
    clear [hBaseScrollY]
    ld   [hBaseScrollX], a
    assign [$DB97], $00
    ld   [$DB98], a
    ld   [$DB99], a
    ret


    db   $01, $02, $03, $04, $05, $06, $07, $08
    db   $09, $0A, $0B, $0C, $01, $01, $01, $01
    db   $00, $01, $01, $01, $01, $00, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $02
    db   $01, $01, $01, $01, $03, $01, $01, $01
    db   $01, $04, $01, $01, $01, $01, $05, $01
    db   $01, $01, $01, $06, $01, $01, $01, $01
    db   $07, $01, $01, $01, $01, $08, $01, $01
    db   $01, $01, $09

toc_01_460F:
    ld   de, $0000
    call toc_01_46DD
    ld   de, $0385
    call toc_01_46DD
    ld   de, $070A
    call toc_01_46DD
    if   [DEBUG_TOOL1], .return_01_46DC

    ld   e, $00
    ld   d, $00
    ld   bc, $A405
toc_01_460F.loop_01_462F:
    ld   hl, $45CC
    add  hl, de
    ldi  a, [hl]
    ld   [bc], a
    inc  bc
    inc  e
    ld   a, e
    cp   $43
    jr   nz, .loop_01_462F

    assign [$A453], $01
    assign [$A449], $01
    assign [$A448], $02
    ld   hl, $A46A
    ld   e, $09
    ld   a, $02
toc_01_460F.loop_01_4652:
    ldi  [hl], a
    dec  e
    jr   nz, .loop_01_4652

    assign [$A452], $60
    ld   [$A47D], a
    ld   [$A47C], a
    ld   [$A44A], a
    assign [$A47B], $40
    ld   [$A451], a
    assign [$A44C], $89
    assign [$A414], $00
    assign [$A44E], $07
    assign [$A462], $05
    assign [$A463], $09
    assign [$A44D], $01
    assign [$A45F], $50
    assign [$A460], $0A
    assign [$A454], $5B
    assign [$A455], $46
    assign [$A456], $4D
    assign [$A457], $45
    assign [$A458], $42
    assign [$A45C], $00
    ld   [$A45D], a
    assign [$A45B], $00
    ld   [$A464], a
    assign [$A465], $00
    assign [$A466], $92
    assign [$A467], $48
    assign [$A468], $62
    ld   hl, $A105
    ld   a, $80
    ld   e, $00
toc_01_460F.loop_01_46D8:
    ldi  [hl], a
    dec  e
    jr   nz, .loop_01_46D8

toc_01_460F.return_01_46DC:
    ret


toc_01_46DD:
    ld   c, $01
    ld   b, $05
    ld   hl, $A100
    add  hl, de
toc_01_46DD.loop_01_46E5:
    call toc_01_27B5
    ldi  a, [hl]
    cp   c
    jr   nz, .else_01_46F3

    inc  c
    inc  c
    dec  b
    jr   nz, .loop_01_46E5

    jr   .return_01_4710

toc_01_46DD.else_01_46F3:
    ld   hl, $A100
    add  hl, de
    ld   a, $01
toc_01_46DD.loop_01_46F9:
    call toc_01_27B5
    ldi  [hl], a
    inc  a
    inc  a
    cp   $0B
    jr   c, .loop_01_46F9

    ld   de, $0380
toc_01_46DD.loop_01_4706:
    call toc_01_27B5
    xor  a
    ldi  [hl], a
    dec  de
    ld   a, e
    or   d
    jr   nz, .loop_01_4706

toc_01_46DD.return_01_4710:
    ret


toc_01_4711:
    call toc_01_5B6E
    ld   a, [$DB96]
    jumptable
    db   $2C, $47, $38, $47, $40, $47, $49, $47
    db   $4F, $47, $92, $47, $F6, $47, $28, $48
    db   $DE, $48, $48, $49, $3E, $04, $EA, $FE
    db   $D6, $AF, $EA, $00, $D0, $C3, $45, $44
    db   $3E, $08, $EA, $FE, $D6, $C3, $45, $44
    db   $CD, $4D, $4C, $CD, $66, $4C, $C3, $45
    db   $44, $CD, $7E, $4C, $C3, $45, $44, $FA
    db   $A7, $DB, $E6, $01, $28, $0E, $FA, $00
    db   $DC, $67, $FA, $01, $DC, $6F, $11, $E7
    db   $98, $CD, $ED, $4D, $FA, $A7, $DB, $E6
    db   $02, $28, $0E, $FA, $02, $DC, $67, $FA
    db   $03, $DC, $6F, $11, $47, $99, $CD, $ED
    db   $4D, $FA, $A7, $DB, $E6, $04, $28, $0E
    db   $FA, $04, $DC, $67, $FA, $05, $DC, $6F
    db   $11, $A7, $99, $CD, $ED, $4D, $C3, $45
    db   $44, $C9, $C3, $14, $4C, $D5, $FA, $00
    db   $D6, $5F, $16, $00, $21, $01, $D6, $19
    db   $C6, $10, $EA, $00, $D6, $78, $22, $79
    db   $22, $3E, $04, $22, $D1, $D5, $3E, $05
    db   $E0, $D7, $1A, $A7, $3E, $7E, $28, $0C
    db   $1A, $3D, $C5, $E5, $4F, $06, $00, $CD
    db   $B1, $08, $E1, $C1, $22, $13, $F0, $D7
    db   $3D, $20, $E5, $78, $22, $79, $D6, $20
    db   $22, $3E, $04, $22, $D1, $3E, $05, $E0
    db   $D7, $1A, $A7, $18, $03, $3D, $E6, $C0
    db   $3E, $7E, $18, $08, $1A, $E6, $80, $3E
    db   $C8, $28, $01, $3C, $22, $13, $F0, $D7
    db   $3D, $20, $E4, $AF, $77, $C9, $FA, $7B
    db   $D4, $A7, $28, $09, $AF, $EA, $7B, $D4
    db   $3E, $11, $EA, $68, $D3, $FA, $A7, $DB
    db   $A7, $3E, $03, $28, $02, $3E, $04, $EA
    db   $FF, $D6, $3E, $E4, $EA, $97, $DB, $3E
    db   $1C, $EA, $98, $DB, $3E, $E4, $EA, $99
    db   $DB, $C3, $45, $44, $3B, $53, $6B, $83
    db   $CD, $2D, $6E, $F0, $CC, $E6, $90, $28
    db   $03, $C3, $45, $44, $F0, $CC, $E6, $4C
    db   $28, $2A, $0E, $02, $FA, $A7, $DB, $A7
    db   $28, $01, $0C, $F0, $CC, $CB, $77, $20
    db   $04, $CB, $57, $20, $0C, $FA, $A6, $DB
    db   $C6, $01, $0C, $B9, $38, $0B, $AF, $18
    db   $08, $FA, $A6, $DB, $D6, $01, $30, $01
    db   $79, $EA, $A6, $DB, $FA, $A6, $DB, $FE
    db   $03, $20, $2D, $F0, $CC, $E6, $03, $28
    db   $0B, $CD, $33, $6E, $FA, $00, $D0, $EE
    db   $01, $EA, $00, $D0, $F0, $E7, $E6, $10
    db   $20, $16, $FA, $00, $D0, $A7, $3E, $2C
    db   $28, $02, $3E, $64, $21, $08, $C0, $36
    db   $88, $23, $22, $3E, $BE, $22, $AF, $77
    db   $FA, $A6, $DB, $5F, $16, $00, $21, $24
    db   $48, $19, $F0, $E7, $E6, $08, $28, $1B
    db   $7E, $21, $00, $C0, $F5, $22, $3E, $18

toc_01_48B0:
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    pop  af
    ldi  [hl], a
    ld   a, $20
    ldi  [hl], a
    ld   a, $02
    ldi  [hl], a
    ld   a, $00
    ld   [hl], a
    ret


    db   $7E, $21, $00, $C0, $F5, $22, $3E, $18
    db   $22, $3E, $02, $22, $3E, $20, $22, $F1
    db   $22, $3E, $20, $22, $3E, $00, $22, $3E
    db   $20, $77, $C9, $FA, $A6, $DB, $FE, $03
    db   $28, $3D, $FA, $A6, $DB, $5F, $CB, $27
    db   $CB, $27, $83, $5F, $16, $00, $0E, $05
    db   $21, $80, $DB, $19, $2A, $A7, $20, $11
    db   $0D, $20, $F9, $AF, $EA, $96, $DB, $3E
    db   $03, $EA, $95, $DB, $3E, $13, $E0, $F2
    db   $C9, $CD, $07, $49, $3E, $00, $EA, $97
    db   $DB, $EA, $98, $DB, $EA, $99, $DB, $3E
    db   $05, $EA, $FE, $D6, $C3, $45, $44, $AF
    db   $EA, $96, $DB, $FA, $00, $D0, $A7, $3E
    db   $04, $28, $02, $3E, $05, $EA, $95, $DB
    db   $C3, $07, $49, $05, $A4, $8A, $A7, $0F
    db   $AB, $05, $A1, $8A, $A4, $0F, $A8, $00
    db   $A1, $85, $A4, $0A, $A8, $C3, $2A, $51

toc_01_494B:
    ld   a, [$DB96]
    jumptable
    db   $55, $49, $68, $49, $86, $49, $CD, $45
    db   $44, $3E, $08, $EA, $FE, $D6, $AF, $EA
    db   $A8, $DB, $EA, $A9, $DB, $EA, $AA, $DB
    db   $C9, $3E, $05, $EA, $FF, $D6, $21, $01
    db   $D6, $3E, $98, $22, $3E, $48, $22, $AF
    db   $22, $FA, $A6, $DB, $C6, $AB, $22, $AF
    db   $77, $C3, $45, $44, $00, $05, $0A, $FA
    db   $A6, $DB, $5F, $16, $00, $21, $83, $49
    db   $19, $5E, $21, $80, $DB, $19, $E5, $D1
    db   $01, $49, $98, $CD, $95, $47, $F0, $CC
    db   $E6, $80, $28, $71, $CD, $07, $49, $FA
    db   $A6, $DB, $CB, $27, $5F, $16, $00, $21
    db   $36, $49, $19, $2A, $66, $6F, $E5, $11
    db   $4F, $00, $19, $E5, $FA, $A6, $DB, $5F
    db   $CB, $27, $CB, $27, $83, $5F, $16, $00
    db   $21, $80, $DB, $19, $2A, $FE, $5B, $20
    db   $19, $2A, $FE, $46, $20, $14, $2A, $FE
    db   $4D, $20, $0F, $2A, $FE, $45, $20, $0A
    db   $2A, $FE, $42, $20, $05, $3E, $60, $EA
    db   $68, $D3, $21, $80, $DB, $19, $C1, $1E
    db   $05, $CD, $B5, $27, $2A, $02, $03, $1D
    db   $20, $F7, $E1, $E5, $11, $5A, $00, $19
    db   $36, $18, $E1, $E5, $11, $5B, $00, $19
    db   $36, $03, $E1, $11, $57, $00, $19, $AF
    db   $22, $77, $C3, $BF, $44, $CD, $E0, $4A
    db   $CD, $75, $4B, $C9, $38, $38, $38, $38
    db   $38, $38, $38, $38, $38, $38, $38, $38
    db   $38, $38, $38, $38, $48, $48, $48, $48
    db   $48, $48, $48, $48, $48, $48, $48, $48
    db   $48, $48, $48, $48, $58, $58, $58, $58
    db   $58, $58, $58, $58, $58, $58, $58, $58
    db   $58, $58, $58, $58, $68, $68, $68, $68
    db   $68, $68, $68, $68, $68, $68, $68, $68
    db   $68, $68, $68, $68, $14, $1C, $24, $2C
    db   $34, $3C, $44, $4C, $54, $5C, $64, $6C
    db   $74, $7C, $84, $8C, $14, $1C, $24, $2C
    db   $34, $3C, $44, $4C, $54, $5C, $64, $6C
    db   $74, $7C, $84, $8C, $14, $1C, $24, $2C
    db   $34, $3C, $44, $4C, $54, $5C, $64, $6C
    db   $74, $7C, $84, $8C, $14, $1C, $24, $2C
    db   $34, $3C, $44, $4C, $54, $5C, $64, $6C
    db   $74, $7C, $84, $8C, $4C, $54, $5C, $64
    db   $6C, $42, $43, $44, $45, $46, $47, $48
    db   $00, $00, $62, $63, $64, $65, $66, $67
    db   $68, $49, $4A, $4B, $4C, $4D, $4E, $4F
    db   $00, $00, $69, $6A, $6B, $6C, $6D, $6E
    db   $6F, $50, $51, $52, $53, $54, $55, $56
    db   $00, $00, $70, $71, $72, $73, $74, $75
    db   $76, $57, $58, $59, $5A, $5B, $00, $00
    db   $00, $00, $77, $78, $79, $7A, $7B, $00
    db   $00, $F0, $CC, $E0, $D7, $F0, $D7, $E6
    db   $0C, $20, $42, $F0, $D7, $E6, $03, $20
    db   $1C, $F0, $CB, $21, $82, $C1, $E6, $0F
    db   $20, $04, $AF, $77, $18, $0D, $7E, $3C
    db   $77, $FE, $18, $20, $06, $36, $15, $F0
    db   $CB, $18, $D8, $18, $42, $CD, $33, $6E
    db   $CB, $4F, $20, $0C, $FA, $A9, $DB, $C6
    db   $01, $FE, $40, $38, $2D, $AF, $18, $2A
    db   $FA, $A9, $DB, $D6, $01, $FE, $FF, $20
    db   $21, $3E, $3F, $18, $1D, $CD, $33, $6E
    db   $CB, $57, $28, $0B, $FA, $A9, $DB, $D6
    db   $10, $30, $0F, $C6, $40, $18, $0B, $FA
    db   $A9, $DB, $C6, $10, $FE, $40, $38, $02
    db   $D6, $40, $EA, $A9, $DB, $18, $00, $FA
    db   $A9, $DB, $21, $5B, $4A, $4F, $06, $00
    db   $09, $5E, $FA, $A9, $DB, $21, $1B, $4A
    db   $4F, $06, $00, $09, $56, $21, $00, $C0
    db   $7A, $C6, $0B, $22, $7B, $C6, $04, $22
    db   $3E, $E0, $22, $AF, $77, $C9, $F0, $CC
    db   $E6, $30, $28, $27, $CB, $6F, $20, $13
    db   $CD, $07, $49, $CD, $C5, $4B, $FA, $AA
    db   $DB, $C6, $01, $FE, $05, $38, $11, $3E
    db   $04, $18, $0D, $CD, $07, $49, $FA, $AA
    db   $DB, $D6, $01, $FE, $FF, $20, $01, $AF
    db   $EA, $AA, $DB, $FA, $AA, $DB, $21, $9B
    db   $4A, $4F, $06, $00, $09, $5E, $F0, $E7
    db   $E6, $10, $28, $11, $21, $04, $C0, $3E
    db   $18, $C6, $0B, $22, $7B, $C6, $04, $22
    db   $3E, $E0, $22, $AF, $77, $C9, $FA, $A9
    db   $DB, $4F, $06, $00, $21, $A0, $4A, $09
    db   $7E, $5F, $FA, $A6, $DB, $4F, $CB, $27
    db   $CB, $27, $81, $4F, $21, $80, $DB, $09
    db   $FA, $AA, $DB, $4F, $09, $73, $C9

toc_01_4BE6:
    call toc_01_5B6E
    ld   a, [$DB96]
    jumptable
    db   $FD, $4B, $0C, $4C, $14, $4C, $20, $4C
    db   $29, $4C, $2F, $4C, $AE, $4C, $13, $4D
    db   $3E, $08, $EA, $FE, $D6, $AF, $EA, $A6
    db   $DB, $EA, $00, $D0, $C3, $45, $44, $3E
    db   $06, $EA, $FF, $D6, $C3, $45, $44, $CD
    db   $32, $4C, $CD, $3B, $4C, $CD, $44, $4C
    db   $C3, $45, $44, $CD, $4D, $4C, $CD, $66
    db   $4C, $C3, $45, $44, $CD, $7E, $4C, $C3
    db   $45, $44, $C3, $4F, $47, $01, $C5, $98
    db   $11, $80, $DB, $C3, $95, $47, $01, $25
    db   $99, $11, $85, $DB, $C3, $95, $47, $01
    db   $85, $99, $11, $8A, $DB, $C3, $95, $47
    db   $FA, $A7, $DB, $E6, $01, $28, $11, $3E
    db   $00, $E0, $DB, $FA, $06, $DC, $E0, $D9
    db   $FA, $09, $DC, $E0, $DA, $C3, $01, $5B
    db   $C9, $FA, $A7, $DB, $E6, $02, $28, $F8
    db   $3E, $01, $E0, $DB, $FA, $07, $DC, $E0
    db   $D9, $FA, $0A, $DC, $E0, $DA, $C3, $01
    db   $5B, $FA, $A7, $DB, $E6, $04, $28, $E0
    db   $3E, $02, $E0, $DB, $FA, $08, $DC, $E0
    db   $D9, $FA, $0B, $DC, $E0, $DA, $C3, $01
    db   $5B, $98, $A5, $44, $7E, $98, $C5, $44
    db   $7E, $99, $05, $44, $7E, $99, $25, $44
    db   $7E, $99, $65, $44, $7E, $99, $85, $44
    db   $7E, $CD, $2D, $6E, $F0, $CC, $E6, $48
    db   $28, $09, $FA, $A6, $DB, $3C, $E6, $03
    db   $EA, $A6, $DB, $F0, $CC, $E6, $04, $28
    db   $0D, $FA, $A6, $DB, $3D, $FE, $FF, $20
    db   $02, $3E, $03, $EA, $A6, $DB, $F0, $CC
    db   $E6, $90, $28, $36, $FA, $A6, $DB, $FE
    db   $03, $20, $03, $C3, $BF, $44, $CD, $07
    db   $49, $CD, $45, $44, $18, $12, $99, $E4
    db   $0D, $7E, $7E, $10, $14, $08, $13, $7E
    db   $7E, $7E, $7E, $0E, $0A, $7E, $7E, $00
    db   $21, $01, $D6, $11, $EB, $4C, $0E, $11
    db   $1A, $13, $22, $0D, $79, $FE, $FF, $20
    db   $F7, $C9, $CD, $98, $48, $C9, $F0, $CC
    db   $CB, $6F, $20, $2D, $E6, $90, $28, $64
    db   $FA, $00, $D0, $A7, $CA, $BF, $44, $CD
    db   $07, $49, $FA, $A6, $DB, $CB, $27, $5F
    db   $16, $00, $21, $3C, $49, $19, $2A, $66
    db   $6F, $11, $80, $03, $CD, $B5, $27, $AF
    db   $22, $1B, $7B, $B2, $20, $F6, $C3, $BF
    db   $44, $CD, $8D, $4D, $CD, $63, $4D, $21
    db   $96, $DB, $35, $C9, $99, $E4, $0D, $11
    db   $04, $13, $14, $11, $0D, $7E, $13, $0E
    db   $7E, $0C, $04, $0D, $14, $00, $FA, $00
    db   $D6, $5F, $C6, $11, $EA, $00, $D6, $16
    db   $00, $21, $01, $D6, $19, $11, $51, $4D
    db   $0E, $11, $1A, $13, $22, $0D, $79, $FE
    db   $FF, $20, $F7, $C9, $CD, $B4, $4D, $CD
    db   $98, $48, $F0, $E7, $E6, $10, $28, $0A
    db   $FA, $A6, $DB, $C7, $32, $4C, $3B, $4C
    db   $44, $4C, $FA, $A6, $DB, $17, $17, $17
    db   $E6, $F8, $5F, $16, $00, $21, $96, $4C
    db   $19, $11, $01, $D6, $0E, $08, $2A, $12
    db   $13, $0D, $20, $FA, $AF, $12, $C9, $F0
    db   $CC, $E6, $43, $28, $0B, $CD, $33, $6E
    db   $FA, $00, $D0, $EE, $01, $EA, $00, $D0
    db   $F0, $E7, $E6, $10, $20, $17, $FA, $00
    db   $D0, $5F, $3E, $28, $1D, $20, $02, $3E
    db   $6C, $21, $0C, $C0, $36, $88, $23, $22
    db   $3E, $BE, $22, $AF, $77, $C9, $B0, $B1
    db   $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9
    db   $E5, $FA, $00, $D6, $4F, $C6, $06, $EA
    db   $00, $D6, $06, $00, $21, $01, $D6, $09
    db   $7A, $22, $7B, $22, $3E, $02, $22, $C1
    db   $E5, $79, $E6, $0F, $5F, $16, $00, $21
    db   $E3, $4D, $19, $7E, $E1, $22, $E5, $78
    db   $E6, $F0, $CB, $37, $5F, $16, $00, $21
    db   $E3, $4D, $19, $7E, $E1, $22, $E5, $78
    db   $E6, $0F, $5F, $16, $00, $21, $E3, $4D
    db   $19, $7E, $E1, $22, $AF, $77, $C9

toc_01_4E34:
    ld   a, [$DB96]
    jumptable
    db   $46, $4E, $5B, $4E, $63, $4E, $81, $4E
    db   $9F, $4E, $65, $4F, $6F, $50, $3E, $08
    db   $EA, $FE, $D6, $AF, $EA, $A6, $DB, $EA
    db   $00, $D0, $EA, $01, $D0, $EA, $02, $D0
    db   $C3, $45, $44, $3E, $0C, $EA, $FF, $D6
    db   $C3, $45, $44, $01, $C4, $98, $11, $80
    db   $DB, $CD, $95, $47, $01, $24, $99, $11
    db   $85, $DB, $CD, $95, $47, $01, $84, $99
    db   $11, $8A, $DB, $CD, $95, $47, $C3, $45
    db   $44, $01, $CD, $98, $11, $80, $DB, $CD
    db   $95, $47, $01, $2D, $99, $11, $85, $DB
    db   $CD, $95, $47, $01, $8D, $99, $11, $8A
    db   $DB, $CD, $95, $47, $C3, $45, $44, $CD
    db   $2D, $6E, $F0, $CC, $E6, $48, $28, $09
    db   $FA, $01, $D0, $3C, $E6, $03, $EA, $01
    db   $D0, $F0, $CC, $E6, $04, $28, $0D, $FA
    db   $01, $D0, $3D, $FE, $FF, $20, $02, $3E
    db   $03, $EA, $01, $D0, $F0, $CC, $E6, $90
    db   $28, $0E, $FA, $01, $D0, $FE, $03, $CA
    db   $BF, $44, $CD, $45, $44, $CD, $07, $49
    db   $FA, $01, $D0, $5F, $16, $00, $21, $24
    db   $48, $19, $F0, $E7, $E6, $08, $7E, $21
    db   $00, $C0, $28, $17, $F5, $22, $3E, $10
    db   $22, $3E, $00, $22, $3E, $00, $22, $F1
    db   $22, $3E, $18, $22, $3E, $02, $22, $3E
    db   $00, $77, $C9, $F5, $22, $3E, $10, $22
    db   $3E, $02, $22, $3E, $20, $22, $F1, $22
    db   $3E, $18, $22, $3E, $00, $22, $3E, $20
    db   $77, $C9, $FA, $01, $D0, $5F, $16, $00
    db   $21, $24, $48, $19, $7E, $21, $00, $C0
    db   $C6, $05, $22, $3E, $14, $22, $3E, $BE
    db   $22, $3E, $00, $77, $C9, $98, $A4, $44
    db   $7E, $98, $C4, $44, $7E, $99, $04, $44
    db   $7E, $99, $24, $44, $7E, $99, $64, $44
    db   $7E, $99, $84, $44, $7E, $98, $AD, $44
    db   $7E, $98, $CD, $44, $7E, $99, $0D, $44
    db   $7E, $99, $2D, $44, $7E, $99, $6D, $44
    db   $7E, $99, $8D, $44, $7E, $CD, $2D, $6E
    db   $F0, $CC, $E6, $48, $28, $09, $FA, $02
    db   $D0, $3C, $E6, $03, $EA, $02, $D0, $F0
    db   $CC, $E6, $04, $28, $0D, $FA, $02, $D0
    db   $3D, $FE, $FF, $20, $02, $3E, $03, $EA
    db   $02, $D0, $CD, $1A, $4F, $F0, $CC, $CB
    db   $6F, $28, $07, $21, $96, $DB, $35, $C3
    db   $D5, $4F, $E6, $90, $28, $11, $FA, $02
    db   $D0, $FE, $03, $CA, $BF, $44, $CD, $07
    db   $49, $CD, $45, $44, $C3, $FD, $4C, $CD
    db   $FB, $4F, $F0, $E7, $E6, $10, $28, $1D
    db   $FA, $01, $D0, $17, $17, $17, $E6, $F8
    db   $5F, $16, $00, $21, $35, $4F, $19, $11
    db   $01, $D6, $0E, $08, $2A, $12, $13, $0D
    db   $20, $FA, $AF, $12, $C9, $FA, $01, $D0
    db   $FE, $01, $28, $0D, $FE, $02, $28, $12
    db   $01, $C4, $98, $11, $80, $DB, $C3, $95
    db   $47, $01, $24, $99, $11, $85, $DB, $C3
    db   $95, $47, $01, $84, $99, $11, $8A, $DB
    db   $C3, $95, $47, $FA, $02, $D0, $5F, $16
    db   $00, $21, $24, $48, $19, $FA, $02, $D0
    db   $FE, $03, $CA, $49, $50, $F0, $E7, $E6
    db   $08, $28, $1B, $7E, $21, $08, $C0, $F5

JumpTable_5018_01:
    ldi  [hl], a
    ld   a, $58
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    ld   a, $00
    ldi  [hl], a
    pop  af
JumpTable_5018_01.JumpTable_5023_01:
    ldi  [hl], a
    ld   a, $60
    ldi  [hl], a
    ld   a, $02
    ldi  [hl], a
    ld   a, $00
    ld   [hl], a
    ret


    db   $7E, $21, $08, $C0, $F5, $22, $3E, $58
    db   $22, $3E, $02, $22, $3E, $20, $22, $F1
    db   $22, $3E, $60, $22, $3E, $00, $22, $3E
    db   $20, $77, $C9, $F0, $E7, $E6, $08, $7E
    db   $21, $08, $C0, $C3, $EA, $4E, $FA, $02
    db   $D0, $5F, $16, $00, $21, $24, $48, $19
    db   $7E, $21, $08, $C0, $C6, $05, $22, $3E
    db   $5C, $22, $3E, $BE, $22, $3E, $00, $77
    db   $C9, $CD, $1A, $4F, $CD, $54, $50, $CD
    db   $B4, $4D, $F0, $CC, $E6, $90, $28, $3D
    db   $FA, $00, $D0, $A7, $CA, $BF, $44, $CD
    db   $07, $49, $FA, $01, $D0, $CB, $27, $5F
    db   $16, $00, $21, $42, $49, $19, $4E, $23
    db   $46, $FA, $02, $D0, $CB, $27, $5F, $16
    db   $00, $21, $42, $49, $19, $7E, $23, $66
    db   $6F, $11, $85, $03, $CD, $B5, $27, $0A
    db   $03, $CD, $B5, $27, $22, $1B, $7B, $B2
    db   $20, $F2, $C3, $BF, $44, $F0, $CC, $CB
    db   $6F, $28, $0E, $21, $96, $DB, $35, $AF
    db   $EA, $00, $D0, $CD, $63, $4D, $C3, $F5
    db   $50, $CD, $B2, $4F, $F0, $E7, $E6, $10
    db   $28, $1D, $FA, $02, $D0, $17, $17, $17
    db   $E6, $F8, $5F, $16, $00, $21, $4D, $4F
    db   $19, $11, $09, $D6, $0E, $08, $2A, $12
    db   $13, $0D, $20, $FA, $AF, $12, $C9, $FA
    db   $02, $D0, $FE, $01, $28, $0D, $FE, $02
    db   $28, $12, $01, $CD, $98, $11, $80, $DB
    db   $C3, $95, $47, $01, $2D, $99, $11, $85
    db   $DB, $C3, $95, $47, $01, $8D, $99, $11
    db   $8A, $DB, $C3, $95, $47, $18, $18, $18
    db   $18, $18, $18, $28, $28, $28, $28, $38
    db   $38, $38, $38, $50

toc_01_512A:
    clear [$FFF9]
    ld   a, [$DB5A]
    and  a
    jr   nz, .else_01_5141

    ld   a, [$DB5B]
    ld   e, a
    ld   d, $00
    ld   hl, $511B
    add  hl, de
    ld   a, [hl]
    ld   [$DB5A], a
toc_01_512A.else_01_5141:
    ld   hl, $DBD1
    ld   a, [hl]
    ld   [hl], $00
    and  a
    jr   nz, .else_01_516A

    ld   a, [$DBA6]
    sla  a
    ld   e, a
    ld   d, $00
    ld   hl, $493C
    add  hl, de
    ld   c, [hl]
    inc  hl
    ld   b, [hl]
    ld   hl, $D800
    ld   de, $0380
toc_01_512A.loop_01_515F:
    call toc_01_27B5
    ld   a, [bc]
    inc  bc
    ldi  [hl], a
    dec  de
    ld   a, e
    or   d
    jr   nz, .loop_01_515F

toc_01_512A.else_01_516A:
    assign [wGameMode], GAMEMODE_WORLD
    clear [$DB96]
    clear [$C11C]
    ld   [$FF9C], a
    ld   [$DB93], a
    ld   [$DB94], a
    ld   [$DB90], a
    ld   [$DB8F], a
    ld   [$DB92], a
    ld   [$DB91], a
    ld   a, [$DB6F]
    and  a
    jr   nz, .else_01_51A0

    assign [$DB6F], $16
    assign [$DB70], $50
    assign [$DB71], $27
toc_01_512A.else_01_51A0:
    ifNot [$DB62], .else_01_51DD

    ld   [$DB9D], a
    copyFromTo [$DB63], [$DB9E]
    copyFromTo [$DB61], [$FFF6]
    ld   [$DB9C], a
    copyFromTo [$DB60], [$FFF7]
    copyFromTo [$DB64], [$DBAE]
    clear [$FFF9]
    ld   a, [$DB5F]
    and  %00000001
    ld   [$DBA5], a
    jr   z, .else_01_51D7

    assign [hLinkAnimationState], LINK_ANIMATION_STATE_STANDING_UP
    assign [hLinkDirection], DIRECTION_UP
toc_01_512A.else_01_51D7:
    assign [$D6FF], $02
    ret


toc_01_512A.else_01_51DD:
    assign [$DB78], $30
    assign [$DB77], $30
    assign [$DB76], $20
    assign [$DB9C], $A3
    ld   [$FFF6], a
    assign [$DBA5], $01
    assign [$FFF7], $10
    assign [$DB9D], $50
    assign [$DB9E], $60
    clear [hLinkAnimationState]
    assign [hLinkDirection], DIRECTION_DOWN
    assign [$DB6F], $16
    assign [$DB70], $50
    assign [$DB71], $27
    jr   .else_01_51D7

    db   $9D, $9D, $9D, $FF, $9D, $9D, $9D, $FF
    db   $9D, $9D, $9C, $FF, $9D, $9D, $9C, $FF
    db   $32, $32, $09, $FF, $2E, $2E, $09, $FF
    db   $8A, $32, $E9, $FF, $8A, $2E, $E9, $FF
    db   $C8, $C8, $00, $FF, $C8, $C8, $00, $FF
    db   $48, $C8, $00, $FF, $48, $C8, $00, $FF
    db   $7F, $7F, $BA, $FF, $7F, $7F, $BA, $FF
    db   $7F, $7F, $BA, $FF, $7F, $7F, $BA, $FF
    db   $00, $00, $00, $FF, $00, $00, $00, $FF
    db   $9D, $9D, $FF, $00, $9D, $9D, $9D, $FF
    db   $9D, $9C, $FF, $00, $9D, $9C, $9C, $FF
    db   $9D, $9D, $9C, $9C, $FF, $00, $00, $00
    db   $00, $00, $00, $9D, $9D, $9C, $9C, $9C
    db   $9C, $FF, $00, $00, $00, $00, $9D, $9D
    db   $9C, $9C, $9D, $9D, $9C, $9C, $FF, $00
    db   $00, $9D, $9D, $9C, $9C, $9D, $9D, $9C
    db   $9C, $9C, $9C, $FF, $00, $00, $00, $FF
    db   $00, $00, $00, $FF, $0D, $12, $FF, $00
    db   $0D, $11, $12, $FF, $92, $F2, $FF, $00
    db   $92, $F1, $F2, $FF, $8D, $92, $ED, $F2
    db   $FF, $00, $00, $00, $00, $00, $00, $8D
    db   $92, $ED, $F2, $F1, $F2, $FF, $00, $00
    db   $00, $00, $8D, $92, $ED, $F2, $91, $92
    db   $F1, $F2, $FF, $00, $00, $8D, $92, $ED
    db   $F2, $91, $92, $EC, $ED, $F1, $F2, $FF
    db   $00, $00, $00, $FF, $00, $00, $00, $FF
    db   $E8, $E9, $FF, $00, $E8, $EC, $E8, $FF
    db   $E8, $E9, $FF, $00, $E8, $EC, $E8, $FF
    db   $E8, $EA, $E9, $EB, $FF, $00, $00, $00
    db   $00, $00, $00, $E8, $EA, $E9, $EB, $EC
    db   $E8, $FF, $00, $00, $00, $00, $E8, $EA
    db   $E9, $EB, $EC, $E8, $EC, $E9, $FF, $00
    db   $00, $E8, $EA, $E9, $EB, $EC, $E8, $EC
    db   $EA, $EC, $E9, $FF, $9D, $9C, $0A, $EA
    db   $9C, $E9, $49, $7F, $9D, $09, $49, $7F
    db   $9D, $29, $49, $7F, $9D, $49, $49, $7F
    db   $9D, $69, $49, $7F, $9D, $89, $49, $7F
    db   $9D, $A9, $49, $7F, $9D, $C9, $49, $7F
    db   $9D, $E9, $49, $7F, $9E, $09, $49, $7F
    db   $00

toc_01_5357:
    ld   hl, $532E
    ld   de, $D650
    ld   c, $29
toc_01_5357.loop_01_535F:
    ldi  a, [hl]
    inc  de
    ld   [de], a
    dec  c
    jr   nz, .loop_01_535F

    push de
    clear [$FFD7]
    ld   [$FFD8], a
    ld   [$FFD9], a
    ld   [$FFDA], a
    ld   c, a
    ld   b, a
    ld   e, a
    ld   d, a
    ld   a, [$DBB0]
    swap a
    and  %00000011
    ld   e, a
    and  a
    jr   z, .else_01_5389

toc_01_5357.loop_01_537E:
    ld   a, c
    add  a, $04
    ld   c, a
    dec  e
    ld   a, e
    and  a
    jr   nz, .loop_01_537E

    ld   b, $00
toc_01_5357.else_01_5389:
    pop  hl
toc_01_5357.loop_01_538A:
    push hl
    ld   hl, $521E
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD7], a
    ld   hl, $522E
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD8], a
    ld   hl, $523E
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD9], a
    ld   hl, $524E
    add  hl, bc
    ld   a, [hl]
    ld   [$FFDA], a
    pop  hl
    call toc_01_5461
    push hl
    ld   hl, $521E
    inc  bc
    add  hl, bc
    ld   a, [hl]
    pop  hl
    inc  hl
    cp   $FF
    jr   nz, .loop_01_538A

    xor  a
    ld   [hl], a
    clear [$FFD7]
    ld   [$FFD8], a
    ld   [$FFD9], a
    ld   [$FFDA], a
    ld   c, a
    ld   b, a
    ld   e, a
    ld   d, a
    ld   a, [$DBB0]
    swap a
    and  %00000011
    ld   e, a
    and  a
    jr   z, .else_01_5430

toc_01_5357.loop_01_53D2:
    ld   b, $00
    ld   a, c
    add  a, $08
    ld   c, a
    dec  e
    ld   a, e
    and  a
    jr   nz, .loop_01_53D2

    ld   a, [$DBB0]
    and  %00000011
    jr   z, .else_01_5406

    ld   a, [$DBB0]
    and  %00110000
    cp   $30
    jr   z, .else_01_53F5

    ld   a, c
    add  a, $04
    ld   c, a
    ld   b, $00
    jr   .else_01_5406

toc_01_5357.else_01_53F5:
    ld   a, [$DBB0]
    and  %00000011
    ld   e, a
toc_01_5357.loop_01_53FB:
    ld   b, $00
    ld   a, c
    add  a, $0B
    ld   c, a
    dec  e
    ld   a, e
    and  a
    jr   nz, .loop_01_53FB

toc_01_5357.else_01_5406:
    push hl
    ld   hl, $525E
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD7], a
    ld   hl, $52A2
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD8], a
    clear [$FFD9]
    ld   hl, $52E6
    add  hl, bc
    ld   a, [hl]
    ld   [$FFDA], a
    pop  hl
    call toc_01_5461
    push hl
    ld   hl, $525E
    inc  bc
    add  hl, bc
    ld   a, [hl]
    pop  hl
    inc  hl
    cp   $FF
    jr   nz, .else_01_5406

toc_01_5357.else_01_5430:
    xor  a
    ld   b, a
    ld   c, a
    ld   a, [$DBB0]
    bit  5, a
    jr   z, .else_01_543B

    inc  bc
toc_01_5357.else_01_543B:
    push hl
    ld   hl, $532A
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD7], a
    ld   hl, $532C
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD8], a
    assign [$FFD9], $01
    ld   a, [$FFF7]
    add  a, $B1
    ld   [$FFDA], a
    pop  hl
    call toc_01_5461
    push hl
    pop  hl
    inc  hl
    ld   a, $7F
    ldi  [hl], a
    xor  a
    ld   [hl], a
    ret


toc_01_5461:
    ld   a, [$FFD7]
    ldi  [hl], a
    ld   a, [$FFD8]
    ldi  [hl], a
    ld   a, [$FFD9]
    ldi  [hl], a
    ld   a, [$FFDA]
    ld   [hl], a
    ret


toc_01_546E:
    clear [$C3C0]
    ld   a, [$DB96]
    jumptable
    db   $82, $54, $FE, $54, $07, $55, $10, $55
    db   $21, $55, $FD, $55, $CD, $CC, $1C, $CD
    db   $22, $0B, $CD, $76, $17, $FA, $6B, $C1
    db   $FE, $04, $20, $6B, $3E, $03, $E0, $A9
    db   $3E, $30, $E0, $AA, $CD, $45, $44, $AF
    db   $EA, $6B, $C1, $EA, $6C, $C1, $E0, $96
    db   $EA, $BF, $C1, $E0, $97, $EA, $4F, $C1
    db   $EA, $B2, $C1, $EA, $B3, $C1, $FA, $54
    db   $DB, $EA, $B4, $DB, $5F, $16, $00, $21
    db   $07, $57, $19, $7E, $A7, $28, $1E, $CB
    db   $37, $E6, $07, $3C, $FE, $01, $20, $15
    db   $FA, $A2, $C5, $A7, $3E, $00, $20, $0D
    db   $21, $00, $D8, $19, $7E, $E6, $20, $3E
    db   $00, $28, $02, $3E, $01, $EA, $B1, $C1
    db   $FA, $B4, $DB, $EA, $B4, $C1, $F0, $40
    db   $E6, $DF, $EA, $FD, $D6, $E0, $40, $CD
    db   $36, $56, $3E, $08, $EA, $FF, $D6, $C9
    db   $3E, $0B, $EA, $FE, $D6, $CD, $45, $44
    db   $C9, $3E, $0E, $EA, $FE, $D6, $CD, $45
    db   $44, $C9, $CD, $C3, $17, $FA, $6B, $C1
    db   $FE, $04, $20, $06, $CD, $45, $44, $CD
    db   $07, $49, $C9, $FA, $9F, $C1, $A7, $C2
    db   $F0, $55, $F0, $CC, $E6, $10, $28, $66
    db   $FA, $B4, $DB, $5F, $16, $00, $21, $07
    db   $57, $19, $7E, $A7, $28, $23, $5F, $E6
    db   $F0, $20, $15, $FA, $A2, $C5, $A7, $20
    db   $18, $D5, $FA, $B4, $DB, $5F, $21, $00
    db   $D8, $19, $D1, $7E, $E6, $20, $28, $09
    db   $16, $00, $21, $B7, $56, $19, $7E, $18
    db   $23, $FA, $B4, $DB, $FE, $24, $28, $04
    db   $FE, $34, $20, $04, $3E, $76, $18, $14
    db   $1F, $E6, $07, $5F, $FA, $B4, $DB, $1F
    db   $1F, $E6, $38, $B3, $5F, $16, $00, $21
    db   $77, $56, $19, $7E, $CD, $97, $21, $FA
    db   $B4, $DB, $FE, $70, $3E, $01, $30, $02
    db   $3E, $81, $EA, $9F, $C1, $C9, $FA, $03
    db   $00, $A7, $28, $3D, $F0, $CB, $FE, $60
    db   $20, $37, $3E, $0B, $EA, $95, $DB, $CD
    db   $09, $09, $3E, $00, $EA, $01, $D4, $EA
    db   $02, $D4, $FA, $B4, $DB, $EA, $03, $D4
    db   $3E, $48, $EA, $04, $D4, $3E, $52, $EA
    db   $05, $D4, $F0, $98, $CB, $37, $E6, $0F
    db   $5F, $F0, $99, $D6, $08, $E6, $F0, $B3
    db   $EA, $16, $D4, $3E, $07, $EA, $96, $DB
    db   $C9, $1E, $40, $FA, $03, $00, $A7, $20
    db   $02, $1E, $60, $F0, $CC, $A3, $28, $0A
    db   $AF, $EA, $6B, $C1, $EA, $6C, $C1, $CD
    db   $45, $44, $CD, $56, $56, $CD, $1F, $58
    db   $CD, $F7, $59, $C9, $CD, $50, $67

JumpTable_55FD_01:
    call toc_01_1776
    ifNe [$C16B], $04, .return_01_5655

    clear [$C50A]
    ld   [$C116], a
    ld   [hBaseScrollX], a
    ld   [hBaseScrollY], a
    ld   [$C167], a
    assign [hVolumeRight], $07
    assign [hVolumeLeft], $70
    assign [wGameMode], GAMEMODE_WORLD
    ld   [$FFBC], a
    assign [$DB96], $02
    ld   a, [$DBA5]
    and  a
    ld   a, $06
    jr   nz, .else_01_5633

    ld   a, $07
JumpTable_55FD_01.else_01_5633:
    ld   [wTileMapToLoad], a
    ld   hl, $C124
    ld   e, $00
JumpTable_55FD_01.loop_01_563B:
    xor  a
    ldi  [hl], a
    inc  e
    ld   a, e
    cp   $0C
    jr   nz, .loop_01_563B

JumpTable_55FD_01.toc_01_5643:
    assign [$DB9A], $80
    assign [gbWX], $06
    assign [$C150], $08
    clear [$C14F]
JumpTable_55FD_01.return_01_5655:
    ret


    db   $21, $9C, $C0, $FA, $54, $DB, $1F, $E6
    db   $78, $C6, $18, $22, $FA, $54, $DB, $CB
    db   $37, $1F, $E6, $78, $C6, $18, $22, $36
    db   $3E, $23, $F0, $E7, $17, $E6, $10, $77
    db   $C9, $6C, $6C, $6C, $6B, $6C, $6C, $6C
    db   $6C, $76, $76, $79, $79, $79, $79, $79
    db   $79, $6A, $6A, $72, $7A, $78, $78, $71
    db   $71, $6A, $6A, $72, $70, $78, $78, $71
    db   $71, $6A, $6E, $69, $69, $69, $69, $77
    db   $71, $6E, $6E, $69, $69, $69, $69, $77
    db   $77, $7B, $7B, $6D, $62, $74, $74, $6F
    db   $68, $73, $73, $73, $74, $74, $74, $75
    db   $68, $00, $D9, $C0, $C1, $C2, $C3, $C4
    db   $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC
    db   $CD, $00, $56, $57, $58, $59, $5A, $5B
    db   $5C, $5D, $00, $00, $00, $00, $00, $00
    db   $00, $00, $7C, $67, $00, $00, $80, $65
    db   $00, $64, $88, $00, $00, $00, $00, $00
    db   $00, $00, $5E, $5F, $7F, $7E, $7D, $82
    db   $84, $85, $86, $87, $81, $66, $83, $5E
    db   $63, $00, $61, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $3E
    db   $00, $0E, $00, $39, $00, $00, $00, $17
    db   $00, $18, $3D, $00, $00, $00, $00, $06
    db   $0C, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $12, $00, $00
    db   $00, $07, $00, $00, $14, $00, $00, $00
    db   $00, $33, $3D, $00, $00, $00, $00, $05
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $29, $00, $03, $00, $00, $00, $25, $00
    db   $00, $00, $00, $00, $3D, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $0D, $22, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $02, $21, $3B, $36, $00, $00, $00
    db   $00, $3D, $00, $37, $00, $16, $00, $00
    db   $00, $00, $00, $00, $26, $00, $00, $00
    db   $00, $00, $00, $00, $09, $0B, $09, $00
    db   $00, $00, $35, $3C, $00, $3D, $00, $00
    db   $00, $00, $00, $00, $00, $0A, $00, $00
    db   $00, $3A, $34, $3D, $28, $00, $13, $07
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $04, $11, $00, $00, $38
    db   $00, $00, $15, $00, $3D, $00, $00, $00
    db   $00, $00, $00, $00, $41, $00, $00, $00
    db   $00, $3D, $00, $00, $00, $00, $00, $08
    db   $00, $00, $00, $01, $00, $00, $00, $3F
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00

toc_01_5807:
    ld   a, [$FFF6]
    ld   e, a
    ld   d, $00
    ld   hl, $5707
    add  hl, de
    ld   e, [hl]
    ld   hl, $56B7
    add  hl, de
    ld   a, [hl]
    jp   toc_01_2197

    db   $00, $01, $FF, $00, $F0, $10, $FA, $B4
    db   $DB, $E0, $D7, $FA, $B3, $C1, $21, $B2
    db   $C1, $B6, $21, $9F, $C1, $B6, $C2, $ED
    db   $58, $F0, $CB, $4F, $21, $82, $C1, $E6
    db   $0F, $20, $04, $AF, $77, $18, $0B, $7E
    db   $3C, $77, $FE, $18, $20, $04, $36, $15
    db   $18, $03, $F0, $CC, $4F, $79, $E6, $03
    db   $5F, $16, $00, $21, $19, $58, $19, $FA
    db   $B4, $DB, $57, $E6, $F0, $5F, $7A, $86
    db   $E6, $0F, $B3, $EA, $B4, $DB, $79, $1F
    db   $1F, $E6, $03, $5F, $16, $00, $21, $1C
    db   $58, $19, $FA, $B4, $DB, $86, $21, $D7
    db   $FF, $EA, $B4, $DB, $BE, $28, $6D, $5F
    db   $16, $00, $21, $00, $D8, $19, $FA, $A2
    db   $C5, $A7, $20, $16, $7E, $E6, $FF, $20
    db   $11, $FA, $7B, $C1, $A7, $20, $0B, $3E
    db   $09, $E0, $F2, $F0, $D7, $EA, $B4, $DB
    db   $18, $4A, $CD, $33, $6E, $21, $07, $57
    db   $19, $7E, $A7, $28, $30, $CB, $37, $E6
    db   $07, $3C, $4F, $FE, $01, $20, $0F, $FA
    db   $A2, $C5, $A7, $20, $20, $21, $00, $D8
    db   $19, $7E, $E6, $20, $28, $17, $FA, $B1
    db   $C1, $A7, $20, $05, $3E, $10, $EA, $B2
    db   $C1, $79, $EA, $B1, $C1, $FA, $B4, $DB
    db   $EA, $B4, $C1, $18, $0F, $FA, $B1, $C1
    db   $A7, $28, $09, $AF, $EA, $B1, $C1, $3E
    db   $10, $EA, $B3, $C1, $21, $80, $C0, $FA
    db   $B4, $DB, $1F, $E6, $78, $C6, $14, $5F
    db   $FA, $B4, $DB, $CB, $37, $1F, $E6, $78
    db   $C6, $14, $57, $7B, $22, $7A, $22, $36
    db   $F0, $23, $36, $00, $23, $7B, $22, $7A
    db   $C6, $08, $22, $36, $F0, $23, $36, $20
    db   $F0, $E7, $E6, $10, $20, $3B, $21, $88
    db   $C0, $7B, $C6, $04, $22, $7A, $C6, $F6
    db   $22, $3E, $F6, $22, $3E, $00, $22, $7B
    db   $C6, $04, $22, $7A, $C6, $13, $22, $3E
    db   $F6, $22, $3E, $20, $22, $7B, $C6, $F6
    db   $22, $7A, $C6, $04, $22, $3E, $F8, $22
    db   $3E, $00, $22, $7B, $C6, $0B, $22, $7A
    db   $C6, $04, $22, $3E, $F8, $22, $3E, $40
    db   $22, $C9, $F8, $F8, $F2, $00, $F8, $00
    db   $F4, $00, $F8, $08, $F4, $20, $F8, $10
    db   $F2, $20, $08, $F8, $F2, $40, $08, $00
    db   $F4, $40, $08, $08, $F4, $60, $08, $10
    db   $F2, $60, $FA, $FA, $F2, $00, $FA, $02
    db   $F4, $00, $FA, $06, $F4, $20, $FA, $0E
    db   $F2, $20, $06, $FA, $F2, $40, $06, $02
    db   $F4, $40, $06, $06, $F4, $60, $06, $0E
    db   $F2, $60, $FC, $FC, $F2, $00, $FC, $04
    db   $F4, $00, $FC, $04, $F4, $20, $FC, $0C
    db   $F2, $20, $04, $FC, $F2, $40, $04, $04
    db   $F4, $40, $04, $04, $F4, $60, $04, $0C
    db   $F2, $60, $FE, $FE, $F2, $00, $FE, $04
    db   $F4, $00, $FE, $04, $F4, $20, $FE, $0A
    db   $F2, $20, $02, $FE, $F2, $40, $02, $04
    db   $F4, $40, $02, $04, $F4, $60, $02, $0A
    db   $F2, $60, $20, $00, $22, $00, $24, $00
    db   $26, $00, $28, $00, $2A, $00, $2C, $00
    db   $2E, $00, $2C, $00, $2E, $00, $28, $78
    db   $28, $78, $28, $28, $78, $78, $FA, $40
    db   $C3, $F5, $CD, $03, $5A, $F1, $EA, $40
    db   $C3, $C9, $FA, $B3, $C1, $A7, $28, $07
    db   $3D, $EA, $B3, $C1, $2F, $18, $0A, $FA
    db   $B2, $C1, $A7, $28, $0A, $3D, $EA, $B2
    db   $C1, $1F, $1F, $E6, $03, $18, $09, $FA
    db   $B1, $C1, $A7, $CA, $C1, $5A, $3E, $00
    db   $EA, $B0, $C1, $E0, $F1, $3E, $00, $EA
    db   $C0, $C3, $3E, $08, $EA, $40, $C3, $3E
    db   $00, $EA, $23, $C1, $E0, $ED, $1E, $00
    db   $FA, $B4, $C1, $FE, $70, $38, $02, $1E
    db   $02, $E6, $0F, $FE, $08, $30, $01, $1C
    db   $16, $00, $21, $EF, $59, $19, $7E, $E0
    db   $EE, $21, $F3, $59, $19, $7E, $E0, $EC
    db   $FA, $B0, $C1, $17, $17, $17, $17, $17
    db   $E6, $E0, $5F, $16, $00, $21, $5B, $59
    db   $19, $3E, $08, $EA, $C0, $C3, $AF, $E0
    db   $F5, $0E, $08, $CD, $26, $3D, $FA, $B0
    db   $C1, $FE, $00, $20, $3B, $FA, $B1, $C1
    db   $3D, $FE, $80, $30, $33, $E0, $F1, $11
    db   $30, $C0, $F0, $EC, $12, $13, $F0, $EE
    db   $12, $13, $F0, $F1, $4F, $06, $00, $CB
    db   $21, $CB, $10, $CB, $21, $CB, $10, $21
    db   $DB, $59, $09, $2A, $12, $13, $2A, $12
    db   $13, $F0, $EC, $12, $13, $F0, $EE, $C6
    db   $08, $12, $13, $2A, $12, $13, $7E, $12
    db   $C9, $98, $CB, $06, $7E, $7E, $7E, $7E
    db   $7E, $7E, $7E, $98, $EB, $06, $7E, $7E
    db   $7E, $7E, $7E, $7E, $7E, $00, $99, $2B
    db   $06, $7E, $7E, $7E, $7E, $7E, $7E, $7E
    db   $99, $4B, $06, $7E, $7E, $7E, $7E, $7E
    db   $7E, $7E, $00, $99, $8B, $06, $7E, $7E
    db   $7E, $7E, $7E, $7E, $7E, $99, $AB, $06
    db   $7E, $7E, $7E, $7E, $7E, $7E, $7E, $00
    db   $FA, $00, $D6, $5F, $16, $00, $C6, $14
    db   $EA, $00, $D6, $21, $01, $D6, $19, $D5
    db   $01, $C2, $5A, $F0, $DB, $A7, $28, $0A
    db   $01, $D7, $5A, $FE, $01, $28, $03, $01
    db   $EC, $5A, $1E, $15, $0A, $03, $22, $1D
    db   $20, $FA, $D1, $21, $04, $D6, $19, $0E
    db   $00, $F0, $D9, $A7, $28, $22, $E0, $D7
    db   $F0, $D7, $D6, $08, $E0, $D7, $38, $0F
    db   $3E, $AE, $22, $0C, $79, $FE, $07, $20
    db   $04, $7D, $C6, $03, $6F, $18, $E9, $C6
    db   $08, $28, $05, $3E, $AE, $22, $18, $08
    db   $F0, $DA, $B9, $28, $0F, $3E, $AE, $22
    db   $0C, $79, $FE, $07, $20, $04, $7D, $C6
    db   $03, $6F, $18, $EC, $C9

toc_01_5B6E:
    xor  a
    ld   de, $DBA7
    ld   [de], a
    ld   b, $01
    ld   c, $00
    ld   hl, $DB80
toc_01_5B6E.loop_01_5B7A:
    ldi  a, [hl]
    and  a
    jr   z, .else_01_5B81

    ld   a, [de]
    or   b
    ld   [de], a
toc_01_5B6E.else_01_5B81:
    inc  c
    ld   a, c
    cp   $05
    jr   nz, .else_01_5B89

    ld   b, $02
toc_01_5B6E.else_01_5B89:
    cp   $0A
    jr   nz, .else_01_5B8F

    ld   b, $04
toc_01_5B6E.else_01_5B8F:
    cp   $0F
    jr   nz, .loop_01_5B7A

    ret


toc_01_5B94:
    ld   a, [$DB5A]
    and  a
    jr   nz, .else_01_5BA8

    ld   a, [$DB5B]
    ld   e, a
    ld   d, $00
    ld   hl, $511B
    add  hl, de
    ld   a, [hl]
    ld   [$DB5A], a
toc_01_5B94.else_01_5BA8:
    call toc_01_27E2
    ld   a, [$DBA6]
    sla  a
    ld   e, a
    ld   d, $00
    ld   hl, $493C
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   bc, $D800
    ld   de, $0380
toc_01_5B94.loop_01_5BC0:
    call toc_01_27B5
    ld   a, [bc]
    inc  bc
    call toc_01_27B5
    ldi  [hl], a
    dec  de
    ld   a, e
    or   d
    jr   nz, .loop_01_5BC0

    ret


toc_01_5BCF:
    push bc
    ifNot [$DBA5], .else_01_5BF4

    ifGte [$FFF7], $0A, .else_01_5BF4

    ld   e, a
    sla  a
    sla  a
    add  a, e
    ld   e, a
    ld   d, $00
    ld   hl, $DB16
    add  hl, de
    ld   de, $DBCC
    ld   c, $05
toc_01_5BCF.loop_01_5BEE:
    ld   a, [de]
    inc  de
    ldi  [hl], a
    dec  c
    jr   nz, .loop_01_5BEE

toc_01_5BCF.else_01_5BF4:
    pop  bc
    ret


    db   $A0, $60, $00, $00, $00, $00, $FF, $00
    db   $00, $00, $00, $00, $80, $80, $00, $00
    db   $00, $FF, $00, $00

toc_01_5C0A:
    ld   hl, $C460
    add  hl, de
    ld   a, [$FFE4]
    ld   [hl], a
    inc  a
    ld   [$FFE4], a
    push bc
    ld   a, [$C125]
    ld   c, a
    ld   b, $00
    ld   hl, $5BF6
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD7], a
    ld   hl, $5BFB
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD8], a
    ld   hl, $5C00
    add  hl, bc
    ld   a, [hl]
    ld   [$FFD9], a
    ld   hl, $5C05
    add  hl, bc
    ld   a, [hl]
    ld   [$FFDA], a
    ld   hl, $C200
    add  hl, de
    ld   a, [$FFD7]
    add  a, [hl]
    ld   [hl], a
    rr   c
    ld   hl, $C220
    add  hl, de
    ld   a, [$FFD8]
    rl   c
    adc  [hl]
    ld   [hl], a
    ld   hl, $C210
    add  hl, de
    ld   a, [$FFD9]
    add  a, [hl]
    ld   [hl], a
    rr   c
    ld   hl, $C230
    add  hl, de
    ld   a, [$FFDA]
    rl   c
    adc  [hl]
    ld   [hl], a
    pop  bc
    ret


toc_01_5C61:
    ld   c, $06
    ld   a, [$FFF6]
    ld   hl, $CE81
toc_01_5C61.loop_01_5C68:
    cp   [hl]
    jr   z, .return_01_5C8C

    inc  hl
    dec  c
    jr   nz, .loop_01_5C68

    ld   a, [$CE80]
    inc  a
    cp   $06
    jr   nz, .else_01_5C78

    xor  a
toc_01_5C61.else_01_5C78:
    ld   [$CE80], a
    ld   e, a
    ld   d, $00
    ld   hl, $CE81
    add  hl, de
    ld   e, [hl]
    ld   a, [$FFF6]
    ld   [hl], a
    ld   hl, $CF00
    add  hl, de
    ld   [hl], $00
toc_01_5C61.return_01_5C8C:
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
    db   $FF, $FF, $FF

toc_01_5CF0:
    ld   hl, $0000
    ld   [hl], $FF
    ld   b, $28
    xor  a
    ld   hl, gbRAM
toc_01_5CF0.loop_01_5CFB:
    ldi  [hl], a
    inc  hl
    inc  hl
    inc  hl
    dec  b
    jr   nz, .loop_01_5CFB

    ret


toc_01_5D03:
    ifNot [$C14F], .else_01_5D22

    ld   hl, gbRAM
    ld   a, [$DB9A]
    add  a, $08
    ld   d, a
    ld   e, $28
toc_01_5D03.loop_01_5D14:
    ld   a, [hl]
    cp   d
    jr   c, .else_01_5D1A

    ld   [hl], $00
toc_01_5D03.else_01_5D1A:
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    dec  e
    jr   nz, .loop_01_5D14

    ret


toc_01_5D03.else_01_5D22:
    ld   a, [$DB9A]
    and  a
    ret  z

    ld   a, [wDialogState]
    and  a
    ret  z

    ld   d, $3E
    ld   a, [wDialogState]
    and  %10000000
    jr   z, .else_01_5D37

    ld   d, $58
toc_01_5D03.else_01_5D37:
    ld   e, $1F
    ld   hl, $C024
toc_01_5D03.loop_01_5D3C:
    ld   a, [hl]
    cp   d
    ld   a, [wDialogState]
    bit  7, a
    jr   nz, .else_01_5D46

    ccf
toc_01_5D03.else_01_5D46:
    jr   c, .else_01_5D63

    ifNe [$C173], $4F, .else_01_5D61

    ld   a, [$C112]
    and  a
    jr   nz, .else_01_5D61

    inc  hl
    inc  hl
    ldd  a, [hl]
    dec  hl
    cp   $9A
    jr   c, .else_01_5D61

    cp   $A0
    jr   c, .else_01_5D63

toc_01_5D03.else_01_5D61:
    ld   [hl], $00
toc_01_5D03.else_01_5D63:
    inc  hl
    inc  hl
    inc  hl
    inc  hl
    dec  e
    jr   nz, .loop_01_5D3C

    ret


toc_01_5D6B:
    ifNot [$DBA5], .else_01_5D8B

    ld   a, [$FFF9]
    and  a
    ret  nz

    ld   a, [$FFF7]
    cp   $16
    ret  z

    cp   $14
    ret  z

    cp   $13
    ret  z

    cp   $0A
    ret  c

    ld   a, [$FFF6]
    cp   $FD
    ret  z

    cp   $B1
    ret  z

toc_01_5D6B.else_01_5D8B:
    ifNe [$DB7B], $01, .else_01_5DCC

    ld   e, $0F
    ld   d, $00
toc_01_5D6B.loop_01_5D96:
    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $D5
    jr   nz, .else_01_5DA8

    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_01_5DA8

    ld   [hl], d
toc_01_5D6B.else_01_5DA8:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_01_5D96

    ld   a, $D5
    call toc_01_3C01
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [hLinkPositionZHigh]
    ld   hl, $C310
    add  hl, de
    ld   [hl], a
    ld   a, [hLinkPositionY]
    ld   hl, $C13B
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
toc_01_5D6B.else_01_5DCC:
    ifEq [$DB79], $01, .else_01_5DFB

    cp   $02
    jr   nz, .else_01_5E37

    ld   a, [$DBA5]
    and  a
    jr   nz, .else_01_5E37

    ifLt [$FFF6], $40, .else_01_5E37

    ld   a, [$DB68]
    and  %00000010
    jr   z, .else_01_5E37

    ifLt [$DB43], $02, .else_01_5DF4

    xor  a
    jr   .toc_01_5DF6

toc_01_5D6B.else_01_5DF4:
    ld   a, $01
toc_01_5D6B.toc_01_5DF6:
    ld   [$DB79], a
    jr   .else_01_5E37

toc_01_5D6B.else_01_5DFB:
    ld   e, $0F
    ld   d, $00
toc_01_5D6B.loop_01_5DFF:
    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $D4
    jr   nz, .else_01_5E11

    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_01_5E11

    ld   [hl], d
toc_01_5D6B.else_01_5E11:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_01_5DFF

    ld   a, $D4
    call toc_01_3C01
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [hLinkPositionY]
    ld   hl, $C13B
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, de
    inc  [hl]
    assign [$FFF2], $2D
toc_01_5D6B.else_01_5E37:
    if   [$DB73], toc_01_5ED7

    ld   e, $0F
    ld   d, $00
toc_01_5D6B.loop_01_5E42:
    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $C1
    jr   nz, .else_01_5E54

    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_01_5E54

    ld   [hl], d
toc_01_5D6B.else_01_5E54:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_01_5E42

    ld   a, $C1
    call toc_01_3C01
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $D155
    call toc_01_5ED0
    ld   a, [hLinkPositionY]
    ld   hl, $C13B
    add  a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $D175
    call toc_01_5ED0
    ld   a, [hLinkPositionZHigh]
    ld   hl, $C310
    add  hl, de
    ld   [hl], a
    ld   hl, $D195
    call toc_01_5ED0
    ld   hl, $C440
    add  hl, de
    ld   [hl], $01
    ld   hl, $C2F0
    add  hl, de
    ld   [hl], $0C
    ifNe [$FFF6], $A4, .else_01_5EAF

    ifNe [$FFF7], $11, .else_01_5EAF

    assign [$FFF2], $08
    ld   [$C167], a
    ld   hl, $C300
    add  hl, de
    ld   [hl], $79
toc_01_5D6B.else_01_5EAF:
    ld   a, [hLinkDirection]
    ld   hl, $D1B5
    call toc_01_5ED0
    ifNot [$DB10], .return_01_5ECF

    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, de
    add  a, 32
    ld   [hl], a
    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, de
    add  a, 16
    ld   [hl], a
toc_01_5D6B.return_01_5ECF:
    ret


toc_01_5ED0:
    ld   c, $10
toc_01_5ED0.loop_01_5ED2:
    ldi  [hl], a
    dec  c
    jr   nz, .loop_01_5ED2

    ret


toc_01_5ED7:
    ld   a, [$FFF6]
    cp   $A7
    ret  z

    ifNe [$DB56], $01, toc_01_5F19

    ld   e, $0F
    ld   d, $00
toc_01_5EE7:
    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $6D
    jr   nz, toc_01_5EF9

    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, toc_01_5EF9

    ld   [hl], d
toc_01_5EF9:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, toc_01_5EE7

    ld   a, $6D
    call toc_01_3C01
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   a, [hLinkPositionZHigh]
    ld   hl, $C310
    add  hl, de
    ld   [hl], a
toc_01_5F19:
    ret


toc_01_5F1A:
    call toc_01_27D2
    clear [wGameMode]
    ld   [$DB96], a
    ld   [$DB98], a
    ld   [$DB99], a
    ld   [$DB97], a
    ld   [gbBGP], a
    ld   [gbOBP0], a
    ld   [gbOBP1], a
    ld   [hBaseScrollY], a
    ld   [hBaseScrollX], a
    ld   [$D6FB], a
    ld   [$D6F8], a
    assign [hButtonsInactiveDelay], 24
    ret


    db   $00, $57, $10, $57, $20, $57, $30, $57
    db   $40, $57, $50, $57, $60, $57, $70, $57
    db   $80, $57, $90, $57, $00, $58, $10, $58
    db   $20, $58, $30, $58, $40, $58, $50, $58

toc_01_5F62:
    ld   a, [$C109]
    and  %00001111
    sla  a
    ld   e, a
    ld   d, $00
    ld   hl, $5F42
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   de, $96D0
    ld   bc, $0010
    ld   a, $0F
    call toc_01_28B9
    ld   a, [$C109]
    swap a
    and  %00001111
    sla  a
    ld   e, a
    ld   d, $00
    ld   hl, $5F42
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   de, $96C0
    ld   bc, $0010
    ld   a, $0F
    call toc_01_28B9
    assign [$9909], $6C
    inc  a
    ld   [$990A], a
    ret


toc_01_5FA6:
    ifNe [$C11C], $00, .return_01_5FBA

    ld   a, [$C17B]
    and  a
    jr   nz, .return_01_5FBA

    ld   a, [$FFF7]
    add  a, $56
    call toc_01_2197
toc_01_5FA6.return_01_5FBA:
    ret


toc_01_5FBB:
    ld   a, [wDialogState]
    and  a
    jr   nz, .else_01_5FCB

    ifNot [$C3C7], .else_01_5FCB

    dec  a
    ld   [$C3C7], a
toc_01_5FBB.else_01_5FCB:
    ifNot [$C3C4], .else_01_5FD5

    dec  a
    ld   [$C3C4], a
toc_01_5FBB.else_01_5FD5:
    ld   a, [$DB96]
    jumptable
    db   $F5, $5F, $17, $60, $23, $60, $5A, $61
    db   $8D, $61, $A8, $61, $C6, $61, $DD, $61
    db   $EF, $61, $06, $62, $18, $62, $46, $62
    db   $5D, $62, $FD, $55, $3E, $01, $EA, $67
    db   $C1, $CD, $76, $17, $FA, $6B, $C1, $FE
    db   $04, $20, $12, $CD, $45, $44, $AF, $EA
    db   $BF, $C1, $CD, $36, $56, $CD, $75, $62
    db   $3E, $0F, $EA, $FE, $D6, $C9, $3E, $13
    db   $EA, $FE, $D6, $AF, $EA, $3F, $C1, $C3
    db   $45, $44, $3E, $13, $EA, $FF, $D6, $3E
    db   $FF, $EA, $9A, $DB, $AF, $E0, $96, $EA
    db   $6B, $C1, $EA, $6C, $C1, $3E, $90, $E0
    db   $97, $3E, $40, $EA, $14, $C1, $3E, $A0
    db   $EA, $66, $D4, $3E, $E0, $EA, $40, $C5
    db   $3E, $00, $EA, $30, $C5, $3E, $01, $EA
    db   $10, $C5, $3E, $0C, $EA, $60, $C5, $3E
    db   $08, $EA, $50, $C5, $3E, $00, $EA, $20
    db   $C5, $EA, $00, $D2, $3E, $20, $EA, $41
    db   $C5, $3E, $A0, $EA, $31, $C5, $3E, $01
    db   $EA, $11, $C5, $3E, $08, $EA, $61, $C5
    db   $3E, $F8, $EA, $51, $C5, $3E, $40, $EA
    db   $21, $C5, $3E, $24, $EA, $01, $D2, $3E
    db   $48, $EA, $42, $C5, $3E, $30, $EA, $32
    db   $C5, $3E, $02, $EA, $12, $C5, $3E, $00
    db   $EA, $62, $C5, $3E, $00, $EA, $52, $C5
    db   $3E, $00, $EA, $22, $C5, $3E, $02, $EA
    db   $02, $D2, $3E, $3C, $EA, $43, $C5, $3E
    db   $40, $EA, $33, $C5, $3E, $02, $EA, $13
    db   $C5, $3E, $00, $EA, $63, $C5, $3E, $00
    db   $EA, $53, $C5, $3E, $00, $EA, $23, $C5
    db   $3E, $00, $EA, $03, $D2, $3E, $40, $EA
    db   $44, $C5, $3E, $50, $EA, $34, $C5, $3E
    db   $02, $EA, $14, $C5, $3E, $00, $EA, $64
    db   $C5, $3E, $00, $EA, $54, $C5, $3E, $00
    db   $EA, $24, $C5, $3E, $00, $EA, $04, $D2
    db   $3E, $3C, $EA, $45, $C5, $3E, $60, $EA
    db   $35, $C5, $3E, $02, $EA, $15, $C5, $3E
    db   $00, $EA, $65, $C5, $3E, $00, $EA, $55
    db   $C5, $3E, $00, $EA, $25, $C5, $3E, $00
    db   $EA, $05, $D2, $3E, $44, $EA, $46, $C5
    db   $3E, $68, $EA, $36, $C5, $3E, $02, $EA
    db   $16, $C5, $3E, $00, $EA, $66, $C5, $3E
    db   $00, $EA, $56, $C5, $3E, $00, $EA, $26
    db   $C5, $3E, $00, $EA, $06, $D2, $C3, $45
    db   $44, $00, $00, $00, $00, $40, $40, $40
    db   $40, $94, $94, $94, $94, $E4, $E4, $E4
    db   $E4, $00, $00, $00, $00, $04, $04, $04
    db   $04, $18, $18, $18, $18, $1C, $1C, $1C
    db   $1C, $F0, $E7, $E6, $07, $20, $0E, $FA
    db   $C5, $C3, $3C, $EA, $C5, $C3, $FE, $0C
    db   $20, $03, $CD, $45, $44, $F0, $E7, $E6
    db   $03, $5F, $FA, $C5, $C3, $83, $5F, $16
    db   $00, $21, $3A, $61, $19, $7E, $EA, $97
    db   $DB, $EA, $99, $DB, $21, $4A, $61, $19
    db   $7E, $EA, $98, $DB, $F0, $E7, $E6, $03
    db   $20, $11, $F0, $97, $3C, $E0, $97, $FE
    db   $00, $20, $08, $3E, $80, $EA, $C7, $C3
    db   $CD, $45, $44, $CD, $8C, $62, $C9, $CD
    db   $8C, $62, $FA, $9F, $C1, $A7, $20, $0F
    db   $FA, $C7, $C3, $A7, $20, $08, $3E, $D8
    db   $CD, $3C, $65, $CD, $45, $44, $C9, $3E
    db   $02, $EA, $C4, $C3, $C9, $CD, $8C, $62
    db   $FA, $9F, $C1, $A7, $20, $0D, $3E, $80
    db   $EA, $C4, $C3, $3E, $C0, $EA, $C7, $C3
    db   $CD, $45, $44, $C9, $CD, $8C, $62, $FA
    db   $C7, $C3, $A7, $20, $08, $3E, $D9, $CD
    db   $3C, $65, $C3, $45, $44, $C9, $CD, $8C
    db   $62, $FA, $9F, $C1, $A7, $20, $0D, $3E
    db   $80, $EA, $C4, $C3, $3E, $C0, $EA, $C7
    db   $C3, $CD, $45, $44, $C9, $CD, $8C, $62
    db   $FA, $C7, $C3, $A7, $20, $08, $3E, $DA
    db   $CD, $3C, $65, $C3, $45, $44, $C9, $CD
    db   $8C, $62, $FA, $9F, $C1, $A7, $20, $1F
    db   $FA, $77, $C1, $A7, $20, $09, $3E, $DB
    db   $CD, $3C, $65, $CD, $45, $44, $C9, $3E
    db   $DE, $CD, $3C, $65, $3E, $05, $EA, $96
    db   $DB, $3E, $05, $EA, $C7, $C3, $C9, $3E
    db   $02, $EA, $C4, $C3, $C9, $CD, $8C, $62
    db   $FA, $9F, $C1, $A7, $20, $0D, $3E, $DC
    db   $CD, $3C, $65, $3E, $30, $EA, $C7, $C3
    db   $CD, $45, $44, $C9, $CD, $8C, $62, $3E
    db   $02, $EA, $C4, $C3, $FA, $C7, $C3, $A7
    db   $C0, $CD, $D2, $27, $CD, $0F, $66, $3E
    db   $01, $EA, $73, $DB, $1E, $10, $21, $10
    db   $C5, $AF, $22, $1D, $20, $FC, $C9, $40
    db   $00, $40, $20, $46, $00, $48, $00, $42
    db   $00, $44, $00, $CD, $0C, $63, $FA, $14
    db   $C1, $3C, $FE, $A0, $20, $05, $3E, $0F
    db   $E0, $F4, $AF, $EA, $14, $C1, $FA, $66
    db   $D4, $A7, $20, $0E, $3E, $21, $E0, $F2
    db   $CD, $ED, $27, $E6, $7F, $C6, $60, $EA
    db   $66, $D4, $3D, $EA, $66, $D4, $F0, $97
    db   $3D, $FE, $C0, $D8, $11, $80, $62, $FA
    db   $C4, $C3, $A7, $28, $07, $FE, $60, $30
    db   $03, $11, $84, $62, $3E, $7C, $E0, $EC
    db   $3E, $58, $E0, $EE, $21, $30, $C0, $CD
    db   $E9, $62, $3E, $48, $E0, $EE, $11, $88
    db   $62, $21, $38, $C0, $CD, $E9, $62, $C9
    db   $C5, $F0, $97, $4F, $F0, $EC, $91, $E0
    db   $E8, $22, $F0, $EE, $22, $1A, $13, $22
    db   $1A, $13, $22, $F0, $EC, $91, $22, $F0
    db   $EE, $C6, $08, $22, $1A, $13, $22, $1A
    db   $77, $C1, $C9, $0E, $08, $06, $00, $21
    db   $10, $C5, $09, $7E, $A7, $28, $1C, $F5
    db   $21, $30, $C5, $09, $7E, $E0, $EE, $21
    db   $40, $C5, $09, $7E, $E0, $EC, $21, $20
    db   $C5, $09, $7E, $A7, $28, $01, $35, $F1
    db   $CD, $3B, $63, $0D, $79, $FE, $FF, $20
    db   $D6, $C9, $3D, $C7, $D1, $63, $5B, $64
    db   $4D, $63, $51, $63, $55, $63, $59, $63
    db   $5D, $63, $61, $63, $50, $00, $50, $20
    db   $52, $00, $52, $20, $54, $00, $54, $20
    db   $56, $00, $56, $20, $58, $00, $58, $20
    db   $5A, $00, $5A, $20, $03, $03, $03, $03
    db   $03, $03, $03, $03, $03, $03, $04, $05
    db   $00, $01, $02, $03, $04, $05, $00, $01
    db   $02, $03, $04, $05, $00, $01, $02, $03
    db   $04, $05, $00, $01, $02, $03, $04, $05
    db   $00, $01, $02, $03, $04, $05, $00, $01
    db   $02, $03, $03, $03, $03, $03, $03, $03
    db   $03, $03, $03, $03, $03, $03, $03, $03
    db   $03, $03, $03, $03, $04, $05, $00, $01
    db   $02, $03, $04, $05, $00, $01, $02, $03
    db   $04, $05, $00, $01, $02, $03, $04, $05
    db   $00, $01, $02, $03, $04, $05, $00, $01
    db   $02, $03, $04, $05, $00, $01, $02, $03
    db   $04, $05, $00, $01, $02, $03, $04, $05
    db   $21, $20, $C5, $09, $7E, $A7, $C0, $21
    db   $10, $D2, $09, $7E, $3C, $77, $FE, $06
    db   $38, $06, $70, $21, $00, $D2, $09, $34
    db   $21, $00, $D2, $09, $5E, $50, $21, $65
    db   $63, $19, $5E, $CB, $23, $50, $21, $41
    db   $63, $19, $2A, $56, $5F, $D5, $21, $40
    db   $C0, $79, $17, $17, $17, $E6, $78, $5F
    db   $50, $19, $D1, $CD, $E9, $62, $CD, $06
    db   $65, $F0, $E7, $E6, $07, $20, $0A, $21
    db   $60, $C5, $09, $7E, $FE, $FB, $28, $01
    db   $35, $F0, $E8, $FE, $F0, $38, $0D, $21
    db   $60, $C5, $09, $7E, $E6, $80, $C8, $21
    db   $10, $C5, $09, $70, $C9, $3E, $64, $42
    db   $64, $46, $64, $4A, $64, $4C, $00, $4C
    db   $20, $4E, $00, $4E, $20, $5C, $00, $5C
    db   $20, $5E, $00, $5E, $20, $01, $FF, $01
    db   $FF, $FE, $02, $01, $FF, $4C, $52, $58
    db   $5C, $60, $21, $60, $C5, $09, $7E, $1E
    db   $03, $E6, $80, $28, $10, $21, $00, $D2
    db   $09, $F0, $E7, $E6, $07, $20, $05, $7E
    db   $3C, $E6, $03, $77, $5E, $CB, $23, $50
    db   $21, $36, $64, $19, $2A, $56, $5F, $D5
    db   $21, $40, $C0, $79, $17, $17, $17, $E6
    db   $78, $5F, $50, $19, $D1, $CD, $E9, $62
    db   $CD, $06, $65, $79, $CB, $27, $CB, $27
    db   $CB, $27, $CB, $27, $5F, $F0, $E7, $83
    db   $E0, $E9, $E6, $3F, $20, $11, $CD, $ED
    db   $27, $E6, $07, $5F, $50, $21, $4E, $64
    db   $19, $7E, $21, $50, $C5, $09, $77, $F0
    db   $E9, $C6, $40, $E6, $3F, $20, $11, $CD
    db   $ED, $27, $E6, $07, $5F, $50, $21, $4E
    db   $64, $19, $7E, $21, $60, $C5, $09, $77
    db   $21, $90, $C5, $09, $7E, $3C, $77, $FE
    db   $13, $38, $29, $70, $21, $54, $64, $09
    db   $56, $21, $30, $C5, $09, $7E, $92, $1E
    db   $01, $E6, $80, $20, $02, $1E, $FF, $7E
    db   $83, $77, $21, $40, $C5, $09, $7E, $D6
    db   $48, $1E, $01, $E6, $80, $20, $02, $1E
    db   $FF, $7E, $83, $77, $C9, $CD, $13, $65
    db   $C5, $79, $C6, $10, $4F, $CD, $13, $65
    db   $C1, $C9, $21, $50, $C5, $09, $7E, $F5
    db   $CB, $37, $E6, $F0, $21, $70, $C5, $09
    db   $86, $77, $CB, $12, $21, $30, $C5, $09
    db   $F1, $1E, $00, $CB, $7F, $28, $02, $1E
    db   $F0, $CB, $37, $E6, $0F, $B3, $CB, $1A
    db   $8E, $77, $C9, $5F, $F0, $99, $F5, $3E
    db   $60, $E0, $99, $7B, $CD, $85, $21, $F1
    db   $E0, $99, $C9

toc_01_654C:
    ld   a, [$DB96]
    jumptable
    db   $64, $65, $91, $65, $AE, $65, $E0, $65
    db   $F6, $65, $FD, $55, $1A, $66, $3E, $66
    db   $7B, $66, $FA, $55, $3E, $01, $EA, $67
    db   $C1, $CD, $76, $17, $FA, $6B, $C1, $FE
    db   $04, $20, $1D, $CD, $36, $56, $F0, $F7
    db   $FE, $06, $28, $08, $3E, $03, $E0, $A9
    db   $3E, $30, $E0, $AA, $CD, $45, $44, $AF
    db   $EA, $BF, $C1, $3E, $0F, $EA, $FE, $D6
    db   $C9, $1E, $21, $F0, $F7, $FE, $06, $28
    db   $0A, $F0, $F6, $FE, $DD, $1E, $12, $20
    db   $02, $1E, $20, $7B, $EA, $FE, $D6, $AF
    db   $EA, $3F, $C1, $C3, $45, $44, $1E, $24
    db   $F0, $F7, $FE, $06, $28, $0A, $F0, $F6
    db   $FE, $DD, $1E, $12, $20, $02, $1E, $23
    db   $7B, $EA, $FF, $D6, $3E, $FF, $EA, $9A
    db   $DB, $AF, $E0, $96, $E0, $97, $EA, $6B
    db   $C1, $EA, $6C, $C1, $1E, $08, $21, $10
    db   $D2, $22, $1D, $20, $FC, $C3, $45, $44
    db   $CD, $50, $67, $CD, $C3, $17, $FA, $6B
    db   $C1, $FE, $04, $20, $08, $CD, $45, $44
    db   $3E, $80, $EA, $10, $D2, $C9, $F0, $F7
    db   $FE, $06, $20, $09, $CD, $50, $67, $3E
    db   $06, $EA, $96, $DB, $C9, $F0, $CC, $E6
    db   $B0, $28, $0E, $3E, $13, $E0, $F2, $CD
    db   $45, $44, $AF, $EA, $6B, $C1, $EA, $6C
    db   $C1, $C9, $CD, $50, $67, $FA, $10, $D2
    db   $3D, $EA, $10, $D2, $20, $0B, $EA, $56
    db   $C1, $3E, $20, $EA, $10, $D2, $C3, $45
    db   $44, $1E, $00, $E6, $04, $28, $02, $1E
    db   $FE, $7B, $EA, $56, $C1, $C9, $CD, $50
    db   $67, $CD, $91, $66, $FA, $10, $D2, $3D
    db   $EA, $10, $D2, $20, $2D, $CD, $D7, $08
    db   $3E, $30, $EA, $10, $D2, $3E, $30, $EA
    db   $14, $D2, $3E, $18, $EA, $15, $D2, $FA
    db   $11, $D2, $C6, $08, $EA, $11, $D2, $FA
    db   $13, $D2, $3C, $EA, $13, $D2, $FE, $04
    db   $20, $08, $3E, $80, $EA, $10, $D2, $CD
    db   $45, $44, $C9, $CD, $50, $67, $CD, $91
    db   $66, $21, $10, $D2, $35, $C0, $CD, $45
    db   $44, $AF, $EA, $6B, $C1, $EA, $6C, $C1
    db   $C9, $AF, $EA, $56, $C1, $FA, $15, $D2
    db   $A7, $28, $10, $3D, $EA, $15, $D2, $1E
    db   $FE, $E6, $04, $28, $02, $1E, $00, $7B
    db   $EA, $56, $C1, $C9, $14, $14, $10, $10
    db   $0C, $0C, $00, $00, $CC, $10, $00, $08
    db   $CE, $10, $00, $10, $DC, $10, $00, $18
    db   $CC, $30, $10, $00, $DE, $10, $10, $08
    db   $E0, $10, $10, $10, $E2, $10, $10, $18
    db   $DE, $30, $20, $00, $E4, $10, $20, $08
    db   $E6, $10, $20, $10, $E8, $10, $20, $18
    db   $E4, $30, $30, $00, $DE, $10, $30, $08
    db   $E0, $10, $30, $10, $E0, $30, $30, $18
    db   $DE, $30, $40, $00, $DE, $10, $40, $08
    db   $E0, $10, $40, $10, $E0, $30, $40, $18
    db   $DE, $30, $48, $08, $F0, $00, $48, $10
    db   $F2, $00, $48, $18, $F4, $00, $48, $20
    db   $F4, $20, $48, $28, $F2, $20, $48, $30
    db   $F0, $20, $48, $08, $F6, $00, $48, $10
    db   $F8, $00, $48, $18, $FA, $00, $48, $20
    db   $FA, $20, $48, $28, $F8, $20, $48, $30
    db   $F6, $20, $48, $08, $FC, $00, $48, $10
    db   $FE, $00, $48, $18, $EE, $00, $48, $20
    db   $EE, $20, $48, $28, $FE, $20, $48, $30
    db   $FC, $20, $02, $67, $1A, $67, $32, $67
    db   $F0, $F7, $FE, $06, $C0, $AF, $E0, $F1
    db   $E0, $ED, $E0, $F5, $3E, $38, $E0, $EE
    db   $FA, $56, $C1, $5F, $3E, $20, $93, $E0
    db   $EC, $FA, $14, $D2, $A7, $28, $27, $3D
    db   $EA, $14, $D2, $F0, $E7, $E6, $07, $FA
    db   $12, $D2, $20, $06, $3C, $FE, $03, $20
    db   $01, $AF, $EA, $12, $D2, $17, $E6, $06
    db   $5F, $50, $21, $4A, $67, $19, $2A, $66
    db   $6F, $0E, $06, $CD, $20, $3D, $3E, $48
    db   $E0, $EE, $FA, $56, $C1, $5F, $FA, $11
    db   $D2, $C6, $20, $93, $E0, $EC, $FA, $13
    db   $D2, $5F, $16, $00, $21, $AC, $66, $19
    db   $4E, $AF, $EA, $C0, $C3, $21, $B2, $66
    db   $CD, $26, $3D, $C9

toc_01_67BC:
    ld   a, [$DB96]
    jumptable
    db   $CC, $67, $F3, $67, $0B, $68, $1D, $68
    db   $36, $68, $FD, $55, $3E, $01, $EA, $67
    db   $C1, $CD, $76, $17, $FA, $6B, $C1, $FE
    db   $04, $20, $17, $CD, $36, $56, $3E, $03
    db   $E0, $A9, $3E, $30, $E0, $AA, $CD, $45
    db   $44, $AF, $EA, $BF, $C1, $3E, $14, $EA
    db   $FE, $D6, $C9, $3E, $15, $EA, $FF, $D6
    db   $3E, $FF, $EA, $9A, $DB, $AF, $E0, $96
    db   $E0, $97, $EA, $6B, $C1, $EA, $6C, $C1
    db   $C3, $45, $44, $CD, $C3, $17, $FA, $6B
    db   $C1, $FE, $04, $20, $07, $CD, $45, $44
    db   $AF, $EA, $C4, $C3, $C9, $FA, $9F, $C1
    db   $A7, $C0, $FA, $C4, $C3, $3C, $EA, $C4
    db   $C3, $CA, $45, $44, $FE, $80, $20, $05
    db   $3E, $E7, $CD, $97, $21, $C9, $F0, $CC
    db   $E6, $B0, $28, $07, $3E, $13, $E0, $F2
    db   $CD, $0F, $66, $C9, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $F0, $F0, $F0, $F0
    db   $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    db   $F0, $F0, $F0, $F0, $E0, $E0, $E0, $E0
    db   $E0, $E2, $E5, $E8, $EB, $EE, $F1, $F4
    db   $F7, $FA, $FD, $00, $03, $06, $09, $0C
    db   $0F, $12, $15, $18, $1B, $1E, $21, $24
    db   $27, $2A, $2D, $30, $33, $36, $39, $3C
    db   $3F, $42, $45, $48, $33, $36, $39, $3C
    db   $3F, $42, $45, $48, $F0, $F0, $F0, $F0
    db   $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    db   $F0, $F0, $F0, $E0, $E2, $E4, $E6, $E8
    db   $EA, $EC, $EE, $F0, $F2, $F4, $F6, $F8
    db   $FA, $FC, $FE, $00, $02, $04, $06, $08
    db   $0A, $0C, $0E, $10, $12, $14, $16, $18
    db   $1A, $1C, $1D, $1E, $20, $22, $24, $26
    db   $28, $2A, $2C, $2E, $20, $22, $24, $26
    db   $28, $2A, $2C, $2E, $F0, $F0, $F0, $F0
    db   $F0, $F0, $F0, $F0, $F0, $DF, $E0, $E2
    db   $E3, $E5, $E6, $E8, $E9, $EB, $EC, $EE
    db   $EF, $F1, $F2, $F4, $F5, $F7, $F8, $FA
    db   $FB, $FD, $FE, $00, $01, $03, $04, $06
    db   $07, $09, $0A, $0C, $0D, $0F, $10, $12
    db   $13, $15, $16, $18, $19, $1B, $1C, $1E
    db   $1F, $21, $22, $24, $19, $1B, $1C, $1E
    db   $1F, $21, $22, $24, $F0, $F0, $F0, $F0
    db   $F0, $F0, $F0, $F0, $F0, $F0, $E2, $E3
    db   $E5, $E6, $E8, $E9, $EB, $EC, $EE, $F0
    db   $F2, $F3, $F6, $F7, $F8, $F9, $FA, $FC
    db   $FD, $FE, $FF, $00, $01, $03, $04, $06
    db   $07, $09, $0A, $0C, $0D, $0F, $10, $12
    db   $13, $15, $16, $18, $19, $1B, $1C, $1E
    db   $1F, $21, $22, $22, $24, $25, $27, $29
    db   $2B, $2C, $2E, $2F, $F0, $F0, $F0, $F0
    db   $F0, $F0, $F0, $F0, $E1, $E2, $E4, $E5
    db   $E6, $E8, $E9, $EA, $EC, $ED, $EE, $F0
    db   $F1, $F2, $F4, $F5, $F6, $F8, $F9, $FA
    db   $FC, $FE, $FF, $00, $01, $02, $04, $05
    db   $06, $08, $09, $0A, $0C, $0D, $0E, $10
    db   $11, $12, $14, $15, $16, $18, $19, $1A
    db   $1C, $1D, $1E, $20, $22, $23, $24, $25
    db   $27, $28, $2A, $2B, $F0, $F0, $F0, $F0
    db   $F0, $F0, $F0, $E2, $E3, $E4, $E5, $E6
    db   $E8, $E9, $EA, $EC, $ED, $EE, $EF, $F1
    db   $F2, $F3, $F5, $F6, $F8, $F9, $FA, $FB
    db   $FD, $FE, $FF, $00, $01, $02, $03, $05
    db   $06, $07, $08, $0A, $0B, $0C, $0D, $0F
    db   $10, $11, $12, $14, $15, $16, $17, $19
    db   $1A, $1B, $1D, $1E, $20, $21, $22, $23
    db   $25, $26, $27, $28, $F0, $F0, $F0, $F0
    db   $F0, $F0, $E3, $E4, $E5, $E6, $E7, $E8
    db   $E9, $EB, $EC, $ED, $EE, $F0, $F1, $F2
    db   $F3, $F4, $F6, $F7, $F8, $F9, $FB, $FC
    db   $FD, $FE, $FF, $00, $01, $02, $03, $04
    db   $06, $07, $08, $09, $0A, $0B, $0C, $0E
    db   $10, $11, $12, $13, $14, $15, $16, $18
    db   $19, $1A, $1B, $1C, $1D, $1F, $20, $21
    db   $22, $23, $24, $25, $F0, $F0, $F0, $F0
    db   $F0, $E4, $E5, $E6, $E7, $E8, $E9, $EA
    db   $EB, $EC, $EE, $EF, $F0, $F1, $F2, $F3
    db   $F4, $F5, $F6, $F8, $F9, $FA, $FB, $FC
    db   $FD, $FE, $FF, $00, $01, $02, $03, $04
    db   $05, $06, $07, $08, $09, $0A, $0C, $0D
    db   $0E, $0F, $10, $11, $12, $13, $15, $16
    db   $17, $18, $19, $1A, $1B, $1C, $1D, $1E
    db   $1F, $21, $22, $23, $F0, $F0, $F0, $F0
    db   $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC
    db   $ED, $EE, $EF, $F0, $F1, $F2, $F3, $F4
    db   $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC
    db   $FD, $FE, $FF, $00, $01, $02, $03, $04
    db   $05, $06, $07, $08, $09, $0A, $0B, $0C
    db   $0D, $0E, $0F, $10, $11, $12, $13, $14
    db   $15, $16, $17, $18, $19, $1A, $1B, $1C
    db   $1D, $1E, $1F, $20, $F0, $F0, $F0, $E6
    db   $E7, $E8, $E8, $E9, $EA, $EB, $EC, $ED
    db   $EE, $EF, $F0, $F0, $F1, $F2, $F3, $F4
    db   $F5, $F6, $F7, $F8, $F8, $F9, $FA, $FB
    db   $FC, $FD, $FE, $FF, $00, $01, $02, $03
    db   $04, $05, $06, $07, $07, $08, $09, $0A
    db   $0B, $0C, $0D, $0E, $0F, $10, $11, $12
    db   $13, $14, $15, $16, $17, $18, $19, $1A
    db   $1A, $1B, $1C, $1D, $F0, $F0, $E7, $E8
    db   $E9, $EA, $EB, $EC, $EC, $EC, $ED, $EE
    db   $EF, $F0, $F1, $F2, $F2, $F3, $F4, $F5
    db   $F6, $F7, $F7, $F8, $F9, $FA, $FB, $FC
    db   $FC, $FD, $FE, $FF, $00, $01, $02, $03
    db   $04, $04, $05, $06, $07, $08, $09, $09
    db   $0A, $0B, $0C, $0D, $0E, $0E, $0F, $10
    db   $11, $12, $13, $14, $15, $16, $16, $17
    db   $18, $19, $1A, $1B, $F0, $E9, $E9, $EA
    db   $EB, $EB, $EC, $ED, $EE, $EE, $EF, $F0
    db   $F0, $F1, $F2, $F3, $F4, $F4, $F5, $F6
    db   $F7, $F8, $F8, $F9, $FA, $FB, $FC, $FC
    db   $FD, $FE, $FF, $00, $00, $01, $02, $03
    db   $03, $04, $05, $06, $06, $07, $08, $09
    db   $0A, $0A, $0B, $0C, $0C, $0D, $0E, $0E
    db   $10, $11, $12, $12, $13, $14, $15, $15
    db   $16, $17, $18, $18, $EB, $EC, $EC, $ED
    db   $EE, $EE, $EF, $F0, $F0, $F1, $F2, $F2
    db   $F3, $F4, $F4, $F5, $F6, $F6, $F7, $F8
    db   $F8, $F9, $FA, $FA, $FB, $FC, $FC, $FD
    db   $FE, $FE, $FF, $00, $00, $01, $02, $02
    db   $03, $04, $04, $05, $06, $06, $07, $08
    db   $08, $09, $0A, $0A, $0B, $0C, $0C, $0D
    db   $0E, $0E, $0F, $10, $10, $11, $12, $12
    db   $13, $14, $14, $15, $ED, $EE, $EE, $EF
    db   $F0, $F0, $F1, $F1, $F2, $F2, $F3, $F3
    db   $F3, $F4, $F5, $F5, $F6, $F6, $F7, $F8
    db   $F8, $F9, $F9, $FA, $FB, $FB, $FC, $FC
    db   $FE, $FF, $FF, $00, $00, $01, $01, $02
    db   $03, $03, $04, $04, $05, $06, $06, $07
    db   $07, $08, $09, $09, $0A, $0A, $0B, $0C
    db   $0C, $0D, $0D, $0E, $0F, $0F, $10, $10
    db   $11, $12, $12, $13, $F0, $F1, $F1, $F2
    db   $F2, $F3, $F3, $F4, $F4, $F5, $F5, $F6
    db   $F6, $F7, $F7, $F8, $F8, $F9, $F9, $FA
    db   $FA, $FB, $FB, $FC, $FC, $FD, $FD, $FE
    db   $FE, $FF, $FF, $00, $00, $01, $01, $02
    db   $02, $03, $03, $04, $04, $05, $05, $06
    db   $06, $07, $07, $08, $08, $09, $09, $0A
    db   $0A, $0B, $0B, $0C, $0C, $0D, $0D, $0E
    db   $0E, $0F, $0F, $10, $F3, $F4, $F4, $F4
    db   $F5, $F5, $F6, $F6, $F6, $F7, $F7, $F8
    db   $F8, $F8, $F9, $F9, $FA, $FA, $FA, $FB
    db   $FB, $FC, $FC, $FC, $FD, $FD, $FE, $FE
    db   $FF, $FF, $00, $00, $00, $01, $01, $02
    db   $02, $03, $03, $03, $04, $04, $05, $05
    db   $05, $06, $06, $07, $07, $07, $08, $08
    db   $09, $09, $09, $0A, $0A, $0B, $0B, $0B
    db   $0C, $0C, $0D, $0D, $F5, $F6, $F6, $F6
    db   $F7, $F7, $F7, $F8, $F8, $F8, $F9, $F9
    db   $F9, $FA, $FA, $FA, $FB, $FB, $FB, $FC
    db   $FC, $FC, $FD, $FD, $FD, $FE, $FE, $FE
    db   $FF, $FF, $FF, $00, $00, $01, $01, $01
    db   $02, $02, $02, $03, $03, $03, $04, $04
    db   $04, $05, $05, $05, $06, $06, $06, $07
    db   $07, $07, $08, $08, $08, $09, $09, $09
    db   $0A, $0A, $0A, $0B, $FC, $FC, $FB, $FB
    db   $FB, $FB, $FA, $FA, $FA, $FA, $FB, $FB
    db   $FB, $FB, $FC, $FC, $FC, $FC, $FD, $FD
    db   $FD, $FD, $FE, $FE, $FE, $FE, $FF, $FF
    db   $FF, $FF, $00, $00, $00, $00, $01, $01
    db   $01, $01, $02, $02, $02, $02, $03, $03
    db   $03, $03, $04, $04, $04, $04, $05, $05
    db   $05, $05, $06, $06, $06, $06, $07, $07
    db   $07, $07, $08, $08, $FB, $FB, $FB, $FB
    db   $FB, $FC, $FC, $FC, $FC, $FC, $FC, $FD
    db   $FD, $FD, $FD, $FD, $FE, $FE, $FE, $FE
    db   $FE, $FE, $FF, $FF, $FF, $FF, $FF, $FF
    db   $00, $00, $00, $00, $00, $00, $01, $01
    db   $01, $01, $01, $01, $02, $02, $02, $02
    db   $02, $02, $03, $03, $03, $03, $03, $03
    db   $04, $04, $04, $04, $04, $04, $05, $05
    db   $05, $05, $05, $05, $FD, $FD, $FD, $FD
    db   $FD, $FD, $FD, $FD, $FE, $FE, $FE, $FE
    db   $FE, $FE, $FE, $FE, $FE, $FE, $FF, $FE
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $02, $02, $02, $02, $02
    db   $02, $02, $02, $02, $02, $03, $03, $03
    db   $03, $03, $03, $03, $84, $68, $C4, $68
    db   $04, $69, $84, $69, $04, $6A, $44, $6A
    db   $C4, $6A, $04, $6B, $44, $6B, $C4, $6B
    db   $04, $6C, $44, $6C, $84, $6C, $C4, $6C
    db   $04, $6D, $44, $6D, $44, $68, $28, $2A
    db   $2C, $2C, $2E, $2E, $30, $30, $31, $33
    db   $33, $34, $35, $36, $38, $3A, $3A

toc_01_6DB7:
    ld   hl, $C17C
    xor  a
    ldi  [hl], a
    ldi  [hl], a
    ld   d, $00
    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .else_01_6DD2

    ld   a, [$C17E]
    inc  a
    cp   $10
    jr   c, .else_01_6DCF

    ld   a, $10
toc_01_6DB7.else_01_6DCF:
    ld   [$C17E], a
toc_01_6DB7.else_01_6DD2:
    ld   a, [$C17E]
    ld   e, a
    ld   hl, $6DA6
    add  hl, de
    ld   a, [hl]
    ld   [$FFD7], a
    sla  e
    ld   hl, $6D84
    add  hl, de
    ldi  a, [hl]
    ld   b, [hl]
    ld   c, a
toc_01_6DB7.loop_01_6DE6:
    ifNe [gbLY], 16, .loop_01_6DE6

toc_01_6DB7.loop_01_6DEC:
    ld   a, [gbSTAT]
    and  STATF_OAM | STATF_VB
    jr   nz, .loop_01_6DEC

toc_01_6DB7.loop_01_6DF2:
    ld   a, [$C17D]
    inc  a
    ld   [$C17D], a
    and  %00000001
    jr   nz, .loop_01_6DF2

    ld   a, [$FFD7]
    ld   l, a
    ld   a, [$C17C]
    ld   e, a
    inc  a
    ld   [$C17C], a
    cp   $3A
    jr   z, .else_01_6E23

    cp   l
    jr   c, .else_01_6E15

    assign [gbBGP], $55
    jr   .loop_01_6DEC

toc_01_6DB7.else_01_6E15:
    ld   hl, $0000
    add  hl, de
    add  hl, bc
    ld   a, [hl]
    ld   hl, hBaseScrollY
    add  a, [hl]
    ld   [gbSCY], a
    jr   .loop_01_6DEC

toc_01_6DB7.else_01_6E23:
    copyFromTo [hBaseScrollY], [gbSCY]
    copyFromTo [$DB97], [gbBGP]
    ret


toc_01_6E2D:
    ld   a, [$FFCC]
    and  %01001100
    jr   z, .return_01_6E39

    push af
    assign [$FFF2], $0A
    pop  af
toc_01_6E2D.return_01_6E39:
    ret


    db   $C6, $C2, $C0, $C2

toc_01_6E3E:
    ifNot [hButtonsInactiveDelay], toc_01_6E48

    dec  a
    ld   [hButtonsInactiveDelay], a
    jr   toc_01_6EAD

toc_01_6E48:
    ld   a, [$FFCC]
    and  %10000000
    jr   z, toc_01_6EAD

    call toc_01_27D2
    ifEq [$DB96], $0B, toc_01_6E90

    assign [hButtonsInactiveDelay], 40
    assign [$D6FF], $11
    assign [$DB96], $0D
    clear [$C280]
    ld   [$C281], a
    ld   [$C282], a
    ld   [$C283], a
    ld   [$C284], a
    ld   [gbBGP], a
    ld   [$DB97], a
    assign [$C17E], $10
    call toc_01_727D
    assign [$D368], $0D
    ld   [$D00F], a
    call toc_01_7B11
    jr   toc_01_6EA4

toc_01_6E90:
    jp   toc_01_44BC

    db   $AF, $EA, $96, $DB, $E0, $96, $E0, $97
    db   $E0, $47, $EA, $97, $DB, $21, $95, $DB
    db   $34

toc_01_6EA4:
    assign [gbIE], IE_VBLANK
    assign [gbLYC], 79
    ret


toc_01_6EAD:
    ifGte [$DB96], $05, toc_01_6ECD

    ifNot [$D000], toc_01_6EBE

    dec  a
    ld   [$D000], a
toc_01_6EBE:
    rra
    nop
    and  %00000011
    ld   e, a
    ld   d, $00
    ld   hl, $6E3A
    add  hl, de
    ld   a, [hl]
    ld   [$DB97], a
toc_01_6ECD:
    ld   a, [$DB96]
    jumptable
    db   $ED, $6E, $11, $6F, $19, $6F, $84, $6F
    db   $8A, $70, $D4, $70, $0D, $71, $75, $71
    db   $24, $72, $4F, $72, $6C, $72, $9C, $72
    db   $03, $73, $11, $73, $CD, $7B, $29, $CD
    db   $D2, $27, $3E, $1A, $CD, $A8, $27, $3E
    db   $02, $EA, $FE, $D6, $AF, $E0, $E7, $3E
    db   $A2, $EA, $3D, $C1, $F0, $40, $E6, $DF
    db   $EA, $FD, $D6, $E0, $40, $C3, $45, $44
    db   $3E, $10, $EA, $FE, $D6, $C3, $45, $44
    db   $CD, $C4, $7A, $3E, $0E, $EA, $FF, $D6
    db   $3E, $C6, $EA, $97, $DB, $3E, $1C, $EA
    db   $98, $DB, $3E, $E0, $EA, $99, $DB, $3E
    db   $03, $E0, $FF, $3E, $00, $E0, $45, $1E
    db   $11, $21, $00, $D0, $AF, $22, $1D, $20
    db   $FC, $EA, $80, $C2, $EA, $81, $C2, $EA
    db   $B0, $C3, $EA, $B1, $C3, $EA, $B2, $C3
    db   $E0, $ED, $3E, $05, $EA, $82, $C2, $3E
    db   $C0, $EA, $02, $C2, $3E, $4E, $EA, $12
    db   $C2, $AF, $EA, $40, $C3, $EA, $41, $C3
    db   $EA, $42, $C3, $EA, $43, $C3, $C3, $45
    db   $44, $81, $40, $00, $00, $00, $00, $00
    db   $00, $00, $08, $08, $08, $04, $00, $00
    db   $00, $00, $00, $CD, $2B, $73, $CD, $9B
    db   $73, $FA, $02, $D0, $A7, $28, $60, $3C
    db   $EA, $02, $D0, $FE, $18, $38, $57, $D6
    db   $18, $1F, $1F, $1F, $E6, $0F, $5F, $16
    db   $00, $21, $72, $6F, $19, $7E, $EA, $97
    db   $DB, $21, $7B, $6F, $19, $7E, $EA, $98
    db   $DB, $7B, $FE, $08, $C2, $EF, $6F, $AF
    db   $EA, $80, $C2, $EA, $81, $C2, $EA, $82
    db   $C2, $EA, $90, $C2, $3E, $05, $EA, $96
    db   $DB, $EA, $0F, $D0, $CD, $11, $7B, $3E
    db   $11, $EA, $FE, $D6, $3E, $FF, $EA, $01
    db   $D0, $AF, $E0, $96, $EA, $00, $C1, $EA
    db   $02, $C1, $EA, $03, $C1, $3E, $92, $EA
    db   $01, $C1, $3E, $03, $E0, $FF, $C9, $FA
    db   $02, $C2, $FE, $50, $20, $12, $3E, $04
    db   $EA, $96, $DB, $3E, $0F, $EA, $FF, $D6
    db   $3E, $01, $E0, $FF, $AF, $E0, $96, $C9
    db   $CD, $C4, $7A, $F0, $E7, $E6, $07, $C2
    db   $89, $70, $21, $96, $FF, $34, $21, $00
    db   $C2, $35, $23, $35, $23, $35, $0E, $00
    db   $F0, $96, $FE, $10, $28, $19, $0C, $FE
    db   $30, $28, $14, $0C, $FE, $38, $28, $0F
    db   $0C, $FE, $58, $28, $0A, $0C, $FE, $5A
    db   $28, $05, $0C, $FE, $69, $20, $49, $1E
    db   $01, $16, $00, $21, $80, $C2, $19, $7E
    db   $A7, $28, $13, $1D, $7B, $FE, $FF, $20
    db   $F2, $C9, $28, $78, $60, $38, $68, $58
    db   $04, $02, $01, $04, $03, $01, $06, $00
    db   $21, $59, $70, $09, $7E, $21, $80, $C2
    db   $19, $77, $21, $53, $70, $09, $7E, $21
    db   $00, $C2, $19, $77, $21, $10, $C2, $19
    db   $36, $30, $21, $E0, $C2, $19, $36, $20
    db   $3E, $1C, $EA, $00, $D0, $CD, $D7, $08
    db   $C9, $CD, $2B, $73, $FA, $01, $D0, $3C
    db   $EA, $01, $D0, $FE, $80, $20, $05, $F5
    db   $CD, $8C, $73, $F1, $FE, $90, $20, $03
    db   $CD, $81, $70, $FE, $A0, $20, $1B, $3E
    db   $03, $EA, $96, $DB, $3E, $0E, $EA, $FF
    db   $D6, $3E, $03, $E0, $FF, $AF, $EA, $80
    db   $C2, $EA, $81, $C2, $3E, $01, $EA, $02
    db   $D0, $C9, $F0, $E7, $E6, $7F, $20, $0A
    db   $CD, $ED, $27, $E6, $00, $20, $03, $CD
    db   $81, $70, $C9, $3E, $10, $EA, $FF, $D6
    db   $CD, $45, $44, $C9, $00, $00, $00, $00
    db   $40, $40, $40, $80, $85, $85, $85, $C5
    db   $C9, $C9, $C9, $C9, $00, $00, $00, $00
    db   $04, $04, $04, $04, $18, $18, $18, $18
    db   $1C, $1C, $1C, $1C, $00, $00, $00, $00
    db   $40, $40, $40, $40, $90, $90, $90, $90
    db   $E0, $E0, $E0, $E0, $CD, $79, $71, $FA
    db   $01, $D0, $FE, $A0, $20, $06, $F5, $3E
    db   $02, $E0, $45, $F1, $3D, $EA, $01, $D0
    db   $20, $1A, $3E, $07, $EA, $96, $DB, $3E
    db   $06, $EA, $80, $C2, $3E, $B0, $EA, $00
    db   $C2, $3E, $68, $EA, $10, $C2, $3E, $01
    db   $EA, $D0, $C3, $C9, $FE, $34, $30, $33
    db   $E6, $03, $20, $0B, $FA, $10, $D0, $FE
    db   $0C, $28, $04, $3C, $EA, $10, $D0, $F0
    db   $E7, $E6, $03, $5F, $FA, $10, $D0, $83
    db   $5F, $16, $00, $21, $DD, $70, $19, $7E
    db   $EA, $97, $DB, $21, $ED, $70, $19, $7E
    db   $EA, $98, $DB, $21, $FD, $70, $19, $7E
    db   $EA, $99, $DB, $C9, $CD, $9B, $73, $C9
    db   $FA, $91, $C2, $FE, $02, $30, $10, $FA
    db   $14, $C1, $3C, $FE, $A0, $20, $05, $3E
    db   $0F, $E0, $F4, $AF, $EA, $14, $C1, $C9
    db   $9A, $16, $0F, $80, $81, $82, $83, $84
    db   $85, $86, $87, $88, $89, $8A, $8B, $8C
    db   $8D, $8E, $8F, $9A, $36, $0F, $90, $91
    db   $92, $93, $94, $95, $96, $97, $98, $99
    db   $9A, $9B, $9C, $9D, $9E, $9F, $9A, $56
    db   $0F, $A0, $A1, $A2, $A3, $A4, $A5, $A6
    db   $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE
    db   $AF, $9A, $76, $0F, $B0, $B1, $B2, $B3
    db   $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB
    db   $BC, $BD, $BE, $BF, $9A, $96, $0F, $C0
    db   $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8
    db   $C9, $CA, $CB, $CC, $CD, $CE, $CF, $9A
    db   $B6, $0F, $D0, $D1, $D2, $D3, $D4, $D5
    db   $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD
    db   $DE, $DF, $9A, $D6, $0F, $E0, $E1, $E2
    db   $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA
    db   $EB, $EC, $ED, $EE, $EF, $CA, $71, $B7
    db   $71, $DD, $71, $A4, $71, $F0, $71, $91
    db   $71, $03, $72, $FA, $02, $D0, $CB, $27
    db   $5F, $16, $00, $21, $16, $72, $19, $2A
    db   $56, $5F, $21, $01, $D6, $0E, $13, $1A
    db   $13, $22, $0D, $20, $FA, $36, $00, $FA
    db   $02, $D0, $3C, $EA, $02, $D0, $FE, $07
    db   $20, $03, $CD, $45, $44, $C9, $FA, $7E
    db   $C1, $FE, $10, $38, $07, $3E, $19, $E0
    db   $F4, $CD, $45, $44, $C9, $9B, $B9, $09
    db   $65, $66, $67, $68, $69, $6A, $6B, $6C
    db   $6D, $6E, $00, $11, $5E, $72, $21, $01
    db   $D6, $0E, $0E, $1A, $13, $22, $0D, $20
    db   $FA, $CD, $45, $44

toc_01_727D:
    assign [$D001], $A0
    clear [$D002]
    assign [$D003], $FF
    ret


    db   $18, $18, $38, $40, $58, $60, $80, $88
    db   $20, $48, $44, $28, $44, $28, $28, $40
    db   $CD, $9B, $73, $F0, $E7, $E6, $3F, $20
    db   $3C, $1E, $01, $16, $00, $21, $80, $C2
    db   $19, $7E, $A7, $28, $08, $1D, $7B, $FE
    db   $FF, $20, $F2, $18, $28, $36, $08, $21
    db   $E0, $C2, $19, $36, $3F, $FA, $03, $D0
    db   $3C, $EA, $03, $D0, $E6, $07, $4F, $06
    db   $00, $21, $8C, $72, $09, $7E, $21, $00
    db   $C2, $19, $77, $21, $94, $72, $09, $7E
    db   $21, $10, $C2, $19, $77, $FA, $02, $D0
    db   $3C, $EA, $02, $D0, $E6, $0F, $20, $16
    db   $FA, $01, $D0, $3D, $EA, $01, $D0, $20
    db   $0D, $CD, $45, $44, $AF, $EA, $6B, $C1
    db   $EA, $6C, $C1, $CD, $CA, $27, $C9, $CD
    db   $76, $17, $FA, $6B, $C1, $FE, $04, $20
    db   $03, $C3, $1A, $5F, $C9, $3E, $11, $EA
    db   $FE, $D6, $3E, $0B, $EA, $96, $DB, $3E
    db   $C9, $EA, $97, $DB, $3E, $1C, $EA, $98
    db   $DB, $AF, $E0, $96, $E0, $97, $C9, $CD
    db   $ED, $27, $E6, $18, $C6, $10, $E0, $D8
    db   $CD, $ED, $27, $E6, $18, $C6, $10, $E0
    db   $D7, $21, $4C, $C0, $0E, $10, $FA, $96
    db   $DB, $FE, $04, $20, $02, $0E, $15, $F0
    db   $D8, $22, $F0, $D7, $22, $CD, $ED, $27
    db   $E6, $01, $3E, $28, $28, $07, $CD, $ED
    db   $27, $E6, $06, $C6, $70, $22, $3E, $00
    db   $22, $F0, $D7, $C6, $1C, $E0, $D7, $FE
    db   $A0, $38, $0A, $D6, $98, $E0, $D7, $F0
    db   $D8, $C6, $25, $E0, $D8, $0D, $20, $CF
    db   $C9, $99, $2B, $83, $1E, $20, $22, $24
    db   $99, $2C, $83, $1F, $21, $23, $25, $00
    db   $11, $01, $D6, $21, $7D, $73, $0E, $0F
    db   $2A, $12, $13, $0D, $20, $FA, $C9, $AF
    db   $EA, $C0, $C3, $0E, $02, $06, $00, $79
    db   $EA, $23, $C1, $21, $80, $C2, $09, $7E
    db   $A7, $28, $1F, $21, $00, $C2, $09, $7E
    db   $E0, $EE, $21, $10, $C2, $09, $7E, $E0
    db   $EC, $21, $B0, $C3, $09, $7E, $E0, $F1
    db   $21, $90, $C2, $09, $7E, $E0, $F0, $CD
    db   $D5, $73, $0D, $79, $FE, $FF, $20, $CF
    db   $C9, $21, $80, $C2, $09, $7E, $FE, $05
    db   $28, $4F, $FE, $06, $CA, $24, $75, $FE
    db   $07, $CA, $0C, $77, $FE, $08, $CA, $A2
    db   $76, $CD, $91, $08, $20, $06, $21, $80
    db   $C2, $09, $70, $C9, $35, $CD, $F0, $74
    db   $C9, $00, $00, $1C, $00, $00, $08, $1E
    db   $00, $10, $F8, $20, $00, $10, $00, $22
    db   $00, $10, $08, $24, $00, $10, $10, $26
    db   $00, $F8, $04, $32, $00, $E8, $04, $32
    db   $00, $D8, $04, $32, $00, $C8, $04, $32
    db   $00, $02, $01, $00, $00, $00, $01, $02
    db   $02, $FA, $02, $D0, $A7, $3E, $00, $20
    db   $0A, $F0, $E7, $C6, $D0, $1F, $1F, $1F
    db   $1F, $E6, $07, $5F, $16, $00, $21, $25
    db   $74, $19, $7E, $21, $EC, $FF, $86, $77
    db   $21, $FD, $73, $11, $00, $C0, $C5, $0E
    db   $06, $F0, $EC, $86, $23, $12, $13, $F0
    db   $EE, $86, $23, $12, $13, $2A, $12, $13
    db   $2A, $12, $13, $0D, $20, $EB, $FA, $02
    db   $D0, $FE, $10, $38, $1D, $21, $15, $74
    db   $11, $18, $C0, $0E, $04, $F0, $EC, $86
    db   $23, $12, $13, $F0, $EE, $86, $23, $12
    db   $13, $2A, $12, $13, $2A, $12, $13, $0D
    db   $20, $EB, $C1, $C9, $00, $00, $34, $00
    db   $00, $08, $36, $00, $10, $00, $2C, $00
    db   $20, $F8, $2C, $00, $28, $00, $2E, $20
    db   $30, $F0, $2E, $00, $08, $00, $36, $20
    db   $08, $08, $34, $20, $18, $00, $30, $00
    db   $18, $08, $2C, $20, $28, $10, $2E, $20
    db   $28, $10, $2E, $20, $00, $08, $34, $20
    db   $00, $00, $36, $20, $10, $08, $2C, $20
    db   $20, $10, $2C, $20, $28, $08, $2E, $00
    db   $30, $18, $2E, $20, $08, $08, $36, $00
    db   $08, $00, $34, $00, $18, $08, $30, $20
    db   $18, $00, $2C, $00, $28, $F8, $2E, $00
    db   $28, $F8, $2E, $00, $21, $80, $C2, $09
    db   $7E, $3D, $CB, $27, $CB, $27, $CB, $27
    db   $5F, $CB, $27, $83, $5F, $50, $21, $90
    db   $74, $19, $0E, $06, $CD, $26, $3D, $FA
    db   $C0, $C3, $C6, $18, $EA, $C0, $C3, $C9
    db   $00, $00, $02, $00, $04, $00, $06, $00
    db   $08, $00, $0A, $00, $0C, $00, $0E, $00
    db   $CD, $79, $71, $AF, $EA, $40, $C3, $11
    db   $14, $75, $CD, $3B, $3C, $FA, $C0, $C3
    db   $C6, $08, $EA, $C0, $C3, $F0, $F0, $C7
    db   $46, $75, $70, $75, $9B, $75, $D6, $75
    db   $46, $76, $CD, $5F, $7B, $F0, $E7, $1F
    db   $1F, $1F, $E6, $01, $CD, $87, $3B, $F0
    db   $EE, $FE, $48, $30, $08, $CD, $91, $08
    db   $36, $40, $CD, $8D, $3B, $21, $D0, $C3
    db   $09, $35, $20, $07, $36, $04, $21, $00
    db   $C2, $09, $35, $C9, $CD, $09, $7B, $3E
    db   $01, $CD, $87, $3B, $CD, $91, $08, $20
    db   $1C, $CD, $8D, $3B, $3E, $07, $EA, $81
    db   $C2, $3E, $FE, $EA, $01, $C2, $3E, $6E
    db   $EA, $11, $C2, $AF, $EA, $91, $C2, $EA
    db   $E1, $C2, $E0, $E7, $C9, $35, $C9, $CD
    db   $5F, $7B, $FA, $01, $C2, $3D, $EA, $01
    db   $C2, $F0, $E7, $E6, $01, $20, $21, $21
    db   $96, $FF, $34, $7E, $FE, $30, $20, $08
    db   $CD, $91, $08, $36, $40, $C3, $8D, $3B
    db   $FE, $20, $20, $04, $CD, $F3, $76, $AF
    db   $FE, $22, $20, $04, $CD, $EE, $76, $AF
    db   $F0, $E7, $1F, $1F, $E6, $01, $CD, $87
    db   $3B, $C9, $CD, $91, $08, $20, $62, $CD
    db   $92, $7B, $F0, $E7, $E6, $01, $20, $4D
    db   $FA, $01, $C2, $3D, $EA, $01, $C2, $F0
    db   $E7, $E6, $03, $20, $40, $21, $96, $FF
    db   $34, $7E, $FE, $40, $28, $0B, $FE, $3A
    db   $20, $0C, $CD, $91, $08, $36, $30, $18
    db   $05, $CD, $91, $08, $36, $50, $F0, $96
    db   $FE, $56, $20, $11, $3E, $A0, $77, $E0
    db   $43, $3E, $01, $E0, $FF, $CD, $91, $08
    db   $36, $E0, $C3, $8D, $3B, $FE, $20, $20
    db   $04, $CD, $F3, $76, $AF, $FE, $22, $20
    db   $04, $CD, $EE, $76, $AF, $F0, $E7, $1F
    db   $1F, $1F, $1F, $E6, $01, $CD, $87, $3B
    db   $C9, $35, $CD, $09, $7B, $3E, $01, $C3
    db   $87, $3B, $CD, $09, $7B, $F0, $E7, $E6
    db   $01, $20, $32, $3E, $02, $CD, $87, $3B
    db   $3E, $00, $EA, $B1, $C3, $CD, $91, $08
    db   $28, $01, $35, $FE, $A0, $30, $1E, $FE
    db   $90, $30, $10, $FE, $50, $30, $16, $FE
    db   $4A, $30, $08, $FE, $3C, $30, $0E, $FE
    db   $36, $38, $0A, $3E, $03, $CD, $87, $3B
    db   $3E, $01, $EA, $B1, $C3, $C9, $38, $00
    db   $38, $20, $3A, $00, $3A, $20, $3A, $00
    db   $3A, $20, $3C, $00, $3E, $00, $3C, $00
    db   $3E, $00, $3A, $00, $3A, $20, $3A, $00
    db   $3A, $20, $38, $00, $38, $20, $CD, $91
    db   $08, $35, $20, $06, $21, $80, $C2, $09
    db   $70, $C9, $7E, $1F, $1F, $1F, $E6, $07
    db   $E0, $F1, $AF, $EA, $40, $C3, $11, $82
    db   $76, $CD, $3B, $3C, $FA, $C0, $C3, $C6
    db   $08, $EA, $C0, $C3, $C9, $98, $00, $43
    db   $7D, $98, $20, $43, $7D, $98, $40, $43
    db   $7D, $98, $60, $43, $7D, $00, $98, $04
    db   $03, $7D, $7D, $4C, $4D, $98, $24, $43
    db   $7D, $98, $44, $43, $7D, $98, $64, $43
    db   $7D, $00, $21, $DA, $76, $18, $03, $21
    db   $C9, $76, $11, $01, $D6, $C5, $0E, $18
    db   $2A, $12, $13, $0D, $20, $FA, $C1, $C9
    db   $10, $00, $12, $00, $14, $00, $16, $00
    db   $F0, $EE, $FE, $F0, $30, $12, $AF, $EA
    db   $40, $C3, $11, $04, $77, $CD, $3B, $3C
    db   $FA, $C0, $C3, $C6, $08, $EA, $C0, $C3
    db   $F0, $F0, $C7, $2F, $77, $3B, $77, $4B
    db   $77, $A1, $77, $CD, $91, $08, $35, $20
    db   $05, $36, $90, $CD, $8D, $3B, $C9, $F0
    db   $E7, $E6, $03, $20, $06, $CD, $91, $08
    db   $35, $28, $01, $C9, $C3, $8D, $3B, $FA
    db   $0A, $D0, $FE, $13, $28, $3E, $FA, $0E
    db   $D0, $3C, $EA, $0E, $D0, $E6, $03, $20
    db   $32, $FA, $10, $C2, $FE, $A0, $30, $04
    db   $3C, $EA, $10, $C2, $FA, $11, $C2, $FE
    db   $A0, $30, $04, $3C, $EA, $11, $C2, $F0
    db   $97, $F5, $3D, $E0, $97, $F1, $E6, $07
    db   $20, $11, $C5, $CD, $41, $7A, $C1, $FA
    db   $0A, $D0, $FE, $0B, $20, $05, $3E, $01
    db   $EA, $68, $D3, $C9, $CD, $8D, $3B, $CD
    db   $91, $08, $36, $17, $3E, $07, $E0, $A9
    db   $3E, $70, $E0, $AA, $C9, $F0, $E7, $E6
    db   $03, $20, $19, $CD, $91, $08, $35, $20
    db   $13, $CD, $45, $44, $AF, $EA, $02, $D0
    db   $EA, $03, $D0, $EA, $04, $D0, $EA, $80
    db   $C2, $EA, $81, $C2, $C9, $7C, $7C, $44
    db   $45, $7D, $7D, $7D, $7D, $7D, $7D, $7D
    db   $7D, $7D, $7D, $7D, $7D, $4C, $4D, $7C
    db   $7C, $7C, $7C, $7C, $7C, $44, $45, $7D
    db   $7D, $7D, $7D, $7D, $7D, $7D, $7D, $4C
    db   $4D, $7C, $7C, $7C, $7C, $7C, $7C, $7C
    db   $7C, $7C, $70, $71, $72, $73, $74, $75
    db   $76, $77, $78, $79, $7C, $7C, $7C, $7C
    db   $7C, $7C, $7C, $7C, $7C, $7C, $7C, $7C
    db   $46, $7D, $7D, $7D, $7D, $4B, $7C, $7C
    db   $7C, $7C, $7C

toc_01_780F:
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   e, h
    ld   e, l
    ld   e, [hl]
    ld   e, a
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   e, b
    ld   e, c
    ld   e, d
    ld   e, e
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   d, h
    ld   d, l
    ld   d, [hl]
    ld   d, a
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   d, b
    ld   d, c
    ld   d, d
    ld   d, e
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    dec  hl
    inc  l
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, h
    ld   a, [$D00A]
    and  a
    jr   nz, .else_01_7A51

    assign [$D00B], $F4
    assign [$D00C], $9B
toc_01_780F.else_01_7A51:
    ld   a, [$D00A]
    ld   e, a
    ld   d, $00
    sla  e
    rl   d
    sla  e
    rl   d
    ld   a, e
    sla  e
    rl   d
    sla  e
    rl   d
    add  a, e
    ld   e, a
    ld   a, d
    adc  $00
    ld   d, a
    ld   c, $00
    ld   hl, $D601
    ld   a, [$D00C]
    ldi  [hl], a
    ld   a, [$D00B]
    ldi  [hl], a
    ld   a, $13
    ldi  [hl], a
toc_01_780F.loop_01_7A7E:
    push hl
    ld   hl, $77C1
    add  hl, de
    ld   a, [hl]
    pop  hl
    ldi  [hl], a
    inc  de
    inc  c
    ld   a, c
    cp   $14
    jr   nz, .loop_01_7A7E

    ld   [hl], $00
    incAddr $D00A
    ld   a, [$D00B]
    sub  a, $20
    ld   [$D00B], a
    ld   a, [$D00C]
    sbc  $00
    ld   [$D00C], a
    ret


    db   $00, $50, $80, $50, $00, $51, $80, $51
    db   $00, $52, $80, $52, $00, $53, $80, $53
    db   $00, $02, $04, $06, $06, $04, $02, $00
    db   $03, $02, $01, $00, $00, $01, $02, $03
    db   $21, $00, $C1, $F0, $E7, $E6, $07, $20
    db   $01, $34, $23, $F0, $E7, $E6, $0F, $20
    db   $01, $34, $23, $F0, $E7, $E6, $1F, $20
    db   $01, $34, $23, $F0, $E7, $E6, $0F, $20
    db   $01, $34, $23, $FA, $04, $D0, $C6, $28
    db   $EA, $04, $D0, $30, $01, $34, $F0, $E7
    db   $C6, $FC, $1F, $1F, $1F, $1F, $E6, $07
    db   $5F, $16, $00, $21, $BC, $7A, $19, $3E
    db   $00, $96, $EA, $06, $C1, $F0, $E7, $E6
    db   $0F, $FE, $04, $38, $4D

toc_01_7B11:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000111
    ld   e, a
    ld   d, $00
    ld   hl, $7AB4
    add  hl, de
    ld   e, [hl]
    ld   hl, $7AA4
    ifNot [$D00F], .else_01_7B2D

    ld   hl, $7AAC
toc_01_7B11.else_01_7B2D:
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   de, $8900
    ifNot [$D00F], .else_01_7B3D

    ld   de, $9300
toc_01_7B11.else_01_7B3D:
    ld   a, [hFrameCounter]
    and  %00000011
    sla  a
    sla  a
    sla  a
    sla  a
    sla  a
    ld   e, a
    add  a, l
    ld   l, a
    ld   a, l
    ld   [$D006], a
    ld   a, h
    ld   [$D007], a
    ld   a, e
    ld   [$D008], a
    ld   a, d
    ld   [$D009], a
    ret


    db   $21, $00, $C1, $F0, $E7, $E6, $07, $20
    db   $01, $34, $21, $01, $C1, $FA, $04, $D0
    db   $C6, $50, $EA, $04, $D0, $30, $01, $34
    db   $23, $FA, $05, $D0, $C6, $58, $EA, $05
    db   $D0, $30, $01, $34, $23, $FA, $0D, $D0
    db   $C6, $B0, $EA, $0D, $D0, $30, $01, $34
    db   $C3, $09, $7B, $21, $00, $C1, $F0, $E7
    db   $E6, $0F, $20, $01, $34, $21, $01, $C1
    db   $FA, $04, $D0, $C6, $28, $EA, $04, $D0
    db   $30, $01, $34, $23, $FA, $05, $D0, $C6
    db   $2C, $EA, $05, $D0, $30, $01, $34, $23
    db   $FA, $0D, $D0, $C6, $58, $EA, $0D, $D0
    db   $30, $01, $34, $C3, $09, $7B

toc_01_7BC5:
    ld   a, [hBGTilesLoadingStage]
    cp   $08
    jp   c, toc_01_7C87

    jr   nz, .else_01_7BD6

    call toc_01_7C00
    incAddr hBGTilesLoadingStage
    ret


toc_01_7BC5.else_01_7BD6:
    call toc_01_7BFA
    clear [hNeedsUpdatingBGTiles]
    ld   [hBGTilesLoadingStage], a
    ret


    db   $0F, $51, $B1, $EF, $EC, $AA, $4A, $0C
    db   $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8
    db   $D0, $D2, $D4, $D6, $D8, $DA, $DC, $DE
    db   $01, $1F, $01

toc_01_7BFA:
    ld   c, $08
    ld   e, $04
    jr   toc_01_7C00.toc_01_7C04

toc_01_7C00:
    ld   c, $04
    ld   e, $00
toc_01_7C00.toc_01_7C04:
    ld   a, c
    ld   [$FFE0], a
    ld   d, $00
toc_01_7C00.loop_01_7C09:
    clear [$FFD7]
    ld   [$FFD8], a
    ld   [$FFD9], a
    ld   [$FFDA], a
    ld   hl, $DB65
    add  hl, de
    ld   a, [hl]
    bit  1, a
    jp   nz, .else_01_7C3A

    ld   c, $00
    ld   b, c
    ld   hl, $7BDF
    add  hl, de
    ld   a, [hl]
    ld   l, a
    ld   h, $9D
    push hl
    assign [$FFD7], $7C
    ld   [$FFD8], a
    ld   [$FFD9], a
    ld   hl, $7BE7
    add  hl, de
    ld   a, [hl]
    ld   [$FFDA], a
    pop  hl
    jr   .toc_01_7C58

toc_01_7C00.else_01_7C3A:
    ld   c, $00
    ld   b, c
    ld   hl, $7BDF
    add  hl, de
    ld   a, [hl]
    ld   l, a
    ld   h, $9D
    push hl
    ld   hl, $7BEF
    add  hl, de
    ld   a, [hl]
    ld   [$FFD7], a
    inc  a
    ld   [$FFD8], a
    add  a, $0F
    ld   [$FFD9], a
    inc  a
    ld   [$FFDA], a
    pop  hl
toc_01_7C00.toc_01_7C58:
    ld   a, [$FFD7]
    ld   [hl], a
    call toc_01_7C79
    ld   a, [$FFD8]
    ld   [hl], a
    inc  c
    call toc_01_7C79
    ld   a, [$FFD9]
    ld   [hl], a
    inc  c
    call toc_01_7C79
    ld   a, [$FFDA]
    ld   [hl], a
    inc  e
    ld   a, e
    ld   hl, $FFE0
    cp   [hl]
    jp   nz, .loop_01_7C09

    ret


toc_01_7C79:
    push hl
    ld   hl, $7BF7
    add  hl, bc
    ld   a, [hl]
    pop  hl
    add  a, l
    ld   l, a
    ld   a, h
    adc  $00
    ld   h, a
    ret


toc_01_7C87:
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
    ld   hl, $4D00
    add  hl, bc
    call toc_01_08C6
    ld   a, [hBGTilesLoadingStage]
    inc  a
    ld   [hBGTilesLoadingStage], a
    ret


    db   $00, $01, $02, $03, $04, $05, $06, $07
    db   $08, $09, $0A, $0B, $10, $1B, $20, $2B
    db   $30, $3B, $40, $4B, $50, $5B, $60, $6B
    db   $70, $7B, $80, $8B, $90, $91, $92, $93
    db   $94, $95, $96, $97, $98, $99, $9A, $9B
    db   $FF

toc_01_7CDE:
    ld   bc, $7CB5
toc_01_7CDE.toc_01_7CE1:
    ld   a, [bc]
    cp   $FF
    jr   z, .return_01_7CF2

    ld   e, a
    ld   d, $00
    ld   hl, $D700
    add  hl, de
    ld   [hl], $FF
    inc  bc
    jr   .toc_01_7CE1

toc_01_7CDE.return_01_7CF2:
    ret


toc_01_7CF3:
    ld   bc, $0400
    ld   hl, gbBGDAT0
toc_01_7CF3.loop_01_7CF9:
    ld   e, $00
    ld   a, l
    and  %00100000
    jr   z, .else_01_7D01

    inc  e
toc_01_7CF3.else_01_7D01:
    ld   d, $AE
    ld   a, l
    and  %00000001
    xor  e
    jr   z, .else_01_7D0A

    inc  d
toc_01_7CF3.else_01_7D0A:
    ld   a, l
    and  %00011111
    cp   $14
    jr   nc, .else_01_7D12

    ld   [hl], d
toc_01_7CF3.else_01_7D12:
    inc  hl
    dec  bc
    ld   a, b
    or   c
    jr   nz, .loop_01_7CF9

    ret


copyDMARoutine:
    ld   c, $C0
    ld   b, $0A
    ld   hl, $7D27
copyDMARoutine.copyInstructions:
    ldi  a, [hl]
    ld   [$ff00+c], a
    inc  c
    dec  b
    jr   nz, .copyInstructions

    ret


DMARoutine:
    assign [gbDMA], $C0
    ld   a, $28
DMARoutine.loop_01_7D2D:
    dec  a
    jr   nz, .loop_01_7D2D

    ret


    db   $80, $80, $40, $40, $20, $20, $10, $10
    db   $08, $08, $04, $04, $02, $02, $01, $01
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $80, $80, $40, $40, $20, $20, $10, $10
    db   $08, $08, $04, $04, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $80, $80, $40, $40, $20, $20, $10, $10
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $80, $80, $40, $40, $20, $20, $10, $10
    db   $08, $08, $04, $04, $02, $02, $01, $01
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00
    db   $2D, $9E, $2C, $9E, $2B, $9E, $2D, $9E
    db   $31, $9E, $2D, $9E, $2B, $9E, $2D, $9E

toc_01_7DC1:
    ld   a, [DEBUG_TOOL2]
    and  a
    ret  nz

    ifNot [$DBA5], toc_01_7DE7

    ifGte [$FFF7], $08, toc_01_7DE7

    sla  a
    ld   e, a
    ld   d, $00
    ld   hl, $7DB1
    add  hl, de
    ldi  a, [hl]
    ld   h, [hl]
    ld   l, a
    ld   [hl], $A3
    ifNot [$FFF9], toc_01_7DE7

    ld   [hl], $7F
toc_01_7DE7:
    ret


    db   $27, $6A, $6C, $21, $22, $23, $24, $25
    db   $26, $6A, $FF, $6C, $6A, $6C, $6A, $6C
    db   $65, $65, $66, $31, $32, $33, $34, $35
    db   $36, $67, $68, $64, $67, $69, $65, $66
    db   $40, $40, $41, $42, $43, $44, $FA, $FA
    db   $63, $40, $40, $40, $40, $40, $40, $60
    db   $FF, $FA, $48, $49, $4A, $FA, $FA, $FA
    db   $62, $6D, $6D, $6D, $6D, $6D, $6D, $FF
    db   $00, $01, $00, $01, $FA, $FF, $5E, $5F
    db   $04, $05, $06, $07, $28, $29, $29, $2A
    db   $10, $11, $10, $11, $FA, $FA, $6E, $6F
    db   $14, $15, $16, $17, $38, $20, $20, $3A
    db   $00, $01, $00, $01, $FB, $FF, $FE, $FE
    db   $08, $09, $0A, $0B, $38, $20, $20, $3A
    db   $10, $11, $10, $11, $FB, $FB, $FE, $FE
    db   $18, $19, $1A, $1B, $48, $49, $49, $4A
    db   $FB, $FF, $0C, $0D, $40, $40, $40, $40
    db   $FA, $FA, $FF, $58, $0E, $0F, $FA, $FA
    db   $FB, $FB, $1C, $1D, $FA, $FA, $FA, $FA
    db   $FA, $FA, $FA, $5D, $1E, $1F, $FA, $FA
    db   $0C, $0D, $0C, $0D, $FB, $FB, $28, $2A
    db   $FA, $FA, $FA, $58, $2D, $2E, $2E, $2F
    db   $1C, $1D, $1C, $1D, $FB, $56, $61, $4A
    db   $FA, $FA, $59, $5A, $3D, $3E, $3E, $3F
    db   $FD, $FD, $FD, $FD, $FB, $FB, $FB, $FB
    db   $28, $29, $5B, $FA, $FF, $FF, $54, $54
    db   $FD, $FD, $FD, $FD, $FB, $FB, $FF, $FB
    db   $38, $30, $3A, $FA, $FF, $FF, $54, $54
    db   $FD, $FD, $FD, $FF, $FD, $FD, $FB, $FB
    db   $48, $FE, $4A, $FA, $56, $57, $54, $54
    db   $03, $12, $13, $12, $13, $02, $FF, $FB
    db   $5C, $2B, $FA, $FA, $FA, $FA, $54, $54

toc_01_7EE8:
    ld   de, $9822
    ld   bc, $0000
toc_01_7EE8.toc_01_7EEE:
    ld   a, [$C5A2]
    and  a
    jr   nz, .else_01_7F06

    ifEq [wGameMode], GAMEMODE_CREDITS, .else_01_7F06

    ld   hl, $D800
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    ld   a, $2C
    jr   z, .else_01_7F0B

toc_01_7EE8.else_01_7F06:
    ld   hl, $7DE8
    add  hl, bc
    ld   a, [hl]
toc_01_7EE8.else_01_7F0B:
    ld   [de], a
    inc  c
    jr   z, .return_01_7F23

    inc  e
    ld   a, e
    and  %00011111
    cp   $12
    jr   nz, .else_01_7F21

    ld   a, e
    and  %11100000
    add  a, $22
    ld   e, a
    ld   a, d
    adc  $00
    ld   d, a
toc_01_7EE8.else_01_7F21:
    jr   .toc_01_7EEE

toc_01_7EE8.return_01_7F23:
    ret


    db   $0F, $00, $1F, $00, $3F, $00, $3F, $11
    db   $3F, $1F, $3F, $1F, $3F, $19, $3F, $11
    db   $3F, $03, $FF, $1F, $FF, $40, $FF, $4A
    db   $FF, $51, $FF, $5F, $FE, $5F, $7E, $1F
    db   $3E, $1F, $3C, $1F, $3F, $1F, $3F, $1F
    db   $3F, $1F, $3F, $1F, $3A, $1D, $39, $17
    db   $33, $1F, $3B, $16, $39, $1F, $1C, $0B
    db   $0F, $05, $07, $03, $03, $00, $00, $00
    db   $4C, $62, $63, $66, $6B, $63, $65, $64
    db   $60, $4C, $4D, $4C, $4C, $4C, $4E, $4E
    db   $4E, $4D, $4D, $4F, $61, $63, $63, $00
    db   $00, $00, $00, $00, $00, $4E, $4E, $4D
    db   $40, $40, $6C, $40, $40, $6C, $40, $6E
    db   $4A, $40, $46, $40, $40, $40, $48, $48
    db   $48, $46, $48, $4A, $40, $46, $6C, $00
    db   $00, $00, $00, $00, $00, $48, $48, $46
    db   $79, $79, $77, $79, $79, $77, $78, $79
    db   $79, $63, $7A, $00, $00, $00, $7B, $7B
    db   $7B, $7A, $7B, $79, $7C, $7A, $77, $00
    db   $00, $00, $00, $00, $00, $7C, $7B, $7A
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF
