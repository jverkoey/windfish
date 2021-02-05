SECTION "ROM Bank 04", ROMX[$4000], BANK[$04]

toc_04_4000:
    ld   hl, $C200
    add  hl, bc
    ld   a, [hl]
    add  a, $08
    ld   [hl], a
    ret


    db   $CD, $0E, $38, $CD, $12, $3F, $21, $B0
    db   $C2, $09, $7E, $C7

    dw JumpTable_401F_04 ; 00
    dw JumpTable_42D2_04 ; 01
    dw JumpTable_4833_04 ; 02
    dw JumpTable_48D0_04 ; 03
    dw JumpTable_4936_04 ; 04

JumpTable_401F_04:
    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    cp   $03
    jr   c, .else_04_4057

    ld   a, $5C
    call toc_01_3C01
    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    sub  a, $18
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $02
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $27
    ld   hl, $C360
    add  hl, de
    ld   [hl], $08
    call toc_01_3E64
    assign [$FFF4], $29
    ret


.else_04_4057:
    ld   hl, $C360
    add  hl, bc
    ld   [hl], $20
    ld   a, c
    ld   [$D002], a
    call toc_04_429C
    call toc_04_7F1F
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $81
    ld   hl, $C350
    add  hl, bc
    ld   [hl], $80
    call toc_04_6DCD
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    ld   [$FFE8], a
    and  %10000000
    jr   z, .else_04_408E

    xor  a
    ld   [hl], a
    ld   hl, $C320
    add  hl, bc
    ld   [hl], b
.else_04_408E:
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_4099_04 ; 00
    dw JumpTable_40AC_04 ; 01
    dw JumpTable_415F_04 ; 02
    dw JumpTable_41FD_04 ; 03

JumpTable_4099_04:
    ifGte [hLinkPositionY], 112, .return_04_40A7

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $FF
.return_04_40A7:
    ret


    db   $00, $01, $00, $02

JumpTable_40AC_04:
    call toc_01_08E2
    call toc_01_3BEB
    call toc_01_3BBF
    jr   nc, .else_04_40D0

    call toc_01_093B.toc_01_0942
    assign [$FFF2], $09
    assign [$C13E], $10
    ld   a, $14
    call toc_01_3C30
    copyFromTo [$FFD7], [hLinkPositionYIncrement]
    copyFromTo [$FFD8], [hLinkPositionXIncrement]
.else_04_40D0:
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_04_4121

    ld   a, [$FFE8]
    and  %10000000
    jr   z, .else_04_40E8

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $10
    assign [$FFF2], $20
.else_04_40E8:
    ld   a, [hLinkPositionX]
    push af
    assign [hLinkPositionX], 80
    ld   a, [hLinkPositionY]
    push af
    assign [hLinkPositionY], 72
    ld   a, $08
    call toc_01_3C25
    ld   a, [$FFEE]
    ld   hl, hLinkPositionX
    sub  a, [hl]
    add  a, $02
    cp   $04
    jr   nc, .else_04_4118

    ld   a, [$FFEF]
    ld   hl, hLinkPositionY
    sub  a, [hl]
    add  a, 2
    cp   4
    jr   nc, .else_04_4118

    ld   hl, $C2D0
    add  hl, bc
    inc  [hl]
.else_04_4118:
    pop  af
    ld   [hLinkPositionY], a
    pop  af
    ld   [hLinkPositionX], a
    call toc_04_6D94
.else_04_4121:
    call toc_01_0891
    cp   $01
    jr   nz, .else_04_414D

    ld   a, $5C
    call toc_01_3C01
    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    sub  a, $26
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $02
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $47
    assign [$FFF2], $06
.else_04_414D:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $40A8
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ret


JumpTable_415F_04:
    call toc_01_0891
    jr   z, .else_04_4194

    dec  a
    jr   nz, .else_04_416D

    call JumpTable_3B8D_00
    ld   [hl], $03
    ret


.else_04_416D:
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_04_418E

    call toc_01_3DAF
    call toc_01_0891
    cp   $28
    jr   nc, .else_04_4191

    ld   e, $08
    ld   a, [hFrameCounter]
    and  %00000100
    jr   z, .else_04_4189

    ld   e, $F8
.else_04_4189:
    ld   hl, $C240
    add  hl, bc
    ld   [hl], e
.else_04_418E:
    call toc_04_6D94
.else_04_4191:
    call toc_01_3B9E
.else_04_4194:
    call toc_01_08E2
    call toc_01_3BEB
    call toc_04_7B54
    ld   a, [$FFEE]
    ld   hl, hLinkPositionX
    sub  a, [hl]
    add  a, $10
    cp   $20
    jr   nc, .else_04_41F8

    ld   a, [$FFEC]
    ld   hl, hLinkPositionY
    sub  a, [hl]
    add  a, $10
    cp   $20
    jr   nc, .else_04_41F8

    call toc_01_093B.toc_01_0942
    ifNe [$DB00], $03, .else_04_41C7

    ld   a, [hPressedButtonsMask]
    and  J_B
    jr   nz, .else_04_41D4

    jr   .else_04_41F8

.else_04_41C7:
    ifNe [$DB01], $03, .else_04_41F8

    ld   a, [hPressedButtonsMask]
    and  J_A
    jr   z, .else_04_41F8

.else_04_41D4:
    _ifZero [$C3CF], .else_04_41F8

    inc  a
    ld   [$C3CF], a
    ld   hl, $C280
    add  hl, bc
    ld   [hl], $07
    ld   hl, $C490
    add  hl, bc
    ld   [hl], b
    copyFromTo [hLinkDirection], [$C15D]
    ld   hl, $FFF3
    ld   [hl], $02
    call toc_01_0891
    ld   [hl], $08
.else_04_41F8:
    xor  a
    call toc_01_3B87
    ret


JumpTable_41FD_04:
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_422E

    ld   [hl], b
    call JumpTable_3B8D_00
    ld   [hl], $02
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $20
    ld   a, $08
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
    call toc_01_0891
    ld   [hl], $C0
    ret


.else_04_422E:
    call toc_04_6D4A
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $01
    ld   hl, $C350
    add  hl, bc
    ld   [hl], $00
    ld   hl, $C430
    add  hl, bc
    ld   [hl], $00
    call toc_01_3BB4
    ld   hl, $C430
    add  hl, bc
    ld   [hl], $D0
    ld   a, [$FFE8]
    and  %10000000
    jr   z, .else_04_4261

    ld   hl, $C320
    add  hl, bc
    ld   [hl], $10
    assign [$FFF2], $20
    ld   a, $0C
    call toc_01_3C25
.else_04_4261:
    call toc_04_6D94
    call toc_01_3B9E
    jp   JumpTable_40AC_04.else_04_414D

    db   $F0, $00, $76, $00, $F0, $08, $76, $20
    db   $00, $00, $78, $00, $00, $08, $78, $20
    db   $F0, $00, $7A, $00, $F0, $08, $7C, $00
    db   $00, $00, $7E, $00, $00, $08, $7E, $20
    db   $F0, $00, $7C, $20, $F0, $08, $7A, $20
    db   $00, $00, $7E, $00, $00, $08, $7E, $20
    db   $26, $00

toc_04_429C:
    ld   hl, $C3B0
    add  hl, bc
    ld   a, [hl]
    rla
    rla
    rla
    rla
    and  %11110000
    ld   e, a
    ld   d, b
    ld   hl, $426A
    add  hl, de
    ld   c, $04
    call toc_01_3D26
    ld   a, $04
    call toc_01_3DD0
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_04_42D1

    ld   a, [$FFEF]
    add  a, $0A
    ld   [$FFEC], a
    clear [$FFF1]
    ld   de, $429A
    call toc_01_3CD0
    call toc_01_3DBA
.return_04_42D1:
    ret


JumpTable_42D2_04:
    call toc_04_46EC
    ifEq [$FFEA], $05, toc_04_4309

    ld   hl, $C420
    add  hl, bc
    ld   a, [hFrameCounter]
    ld   [hl], a
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_42EB_04 ; 00
    dw JumpTable_42F4_04 ; 01
    dw JumpTable_42FF_04 ; 02

JumpTable_42EB_04:
    call toc_01_0891
    ld   [hl], $40
    call JumpTable_3B8D_00
    ret


JumpTable_42F4_04:
    call toc_01_0891
    jr   nz, .return_04_42FE

    ld   [hl], $A0
    call JumpTable_3B8D_00
.return_04_42FE:
    ret


JumpTable_42FF_04:
    call toc_01_0891
    jp   z, toc_04_5746

    call JumpTable_50ED_04.toc_04_50F3
    ret


toc_04_4309:
    call toc_04_7F1F
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    ld   [$D000], a
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    ld   [$D001], a
    ifEq [$FFF0], $05, .else_04_4325

    call toc_01_3BBF
.else_04_4325:
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_4334_04 ; 00
    dw JumpTable_4371_04 ; 01
    dw JumpTable_4492_04 ; 02
    dw JumpTable_44DC_04 ; 03
    dw JumpTable_450A_04 ; 04
    dw JumpTable_4568_04 ; 05

JumpTable_4334_04:
    call toc_01_0891
    jr   nz, .return_04_4360

    call JumpTable_3B8D_00
    call toc_01_088C
    ld   [hl], $FF
    ld   a, [$D002]
    ld   e, a
    ld   d, b
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    ld   a, $52
    jr   nz, .else_04_435D

    call JumpTable_3B8D_00
    ld   [hl], $04
    ld   hl, $C360
    add  hl, bc
    ld   [hl], $08
    ld   a, $53
.else_04_435D:
    call toc_01_2197
.return_04_4360:
    ret


    db   $10, $14, $18, $20, $28, $30, $38, $40
    db   $FF, $FF, $60, $40, $01, $FF, $08, $F8

JumpTable_4371_04:
    call toc_04_6D94
    ld   hl, $C380
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   a, [hFrameCounter]
    and  %00000111
    jr   nz, .else_04_4397

    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    ld   hl, $436F
    add  hl, de
    cp   [hl]
    jr   z, .else_04_4397

    ld   hl, $436D
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
.else_04_4397:
    ld   hl, $436B
    add  hl, de
    ld   a, [$FFEE]
    cp   [hl]
    jr   nz, .else_04_43A8

    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    xor  %00000001
    ld   [hl], a
.else_04_43A8:
    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .else_04_43CE

    ld   hl, $C2C0
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $436D
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    ld   hl, $436F
    add  hl, de
    cp   [hl]
    jr   nz, .else_04_43CE

    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    xor  %00000001
    ld   [hl], a
.else_04_43CE:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    call toc_01_0891
    jr   nz, .else_04_4429

    push hl
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    ld   e, a
    cp   $08
    jr   c, .else_04_43F0

    call JumpTable_3B8D_00
    pop  hl
    ld   [hl], $30
    ret


.else_04_43F0:
    ld   d, b
    ld   hl, $4361
    add  hl, de
    ld   a, [hl]
    pop  hl
    ld   [hl], a
    ld   a, $5C
    call toc_01_3C01
    jr   c, .else_04_4429

    ld   a, [$FFD7]
    sub  a, $0C
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    sub  a, $14
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $03
    ld   hl, $C320
    add  hl, de
    ld   [hl], $20
    ld   hl, $C240
    add  hl, de
    ld   [hl], $0C
    ld   hl, $C340
    add  hl, de
    ld   [hl], $42
.else_04_4429:
    call toc_01_088C
    jr   nz, .else_04_4478

    ld   [hl], $20
    ld   a, $5C
    call toc_01_3C01
    jr   c, .else_04_4478

    push bc
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    inc  [hl]
    and  %00000001
    ld   c, a
    ld   hl, $4490
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
    ld   hl, $C320
    add  hl, de
    ld   [hl], $24
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $04
    ld   hl, $C340
    add  hl, de
    ld   [hl], $12
    push de
    pop  bc
    ld   a, $1F
    call toc_01_3C25
    pop  bc
    ld   hl, $C300
    add  hl, bc
    ld   [hl], $10
    assign [$FFF4], $28
.else_04_4478:
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_04_448F

    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    ld   a, $02
    jr   z, .else_04_448C

    inc  a
.else_04_448C:
    call toc_01_3B87
.return_04_448F:
    ret


    db   $F4, $0C

JumpTable_4492_04:
    ld   a, [$D002]
    ld   e, a
    ld   d, b
    ld   a, [hLinkPositionX]
    push af
    ld   hl, $C200
    add  hl, de
    ld   a, [hl]
    ld   [hLinkPositionX], a
    ld   a, [hLinkPositionY]
    push af
    ld   hl, $C210
    add  hl, de
    ld   a, [hl]
    sub  a, 32
    ld   [hLinkPositionY], a
    ld   a, $10
    call toc_01_3C25
    call toc_04_6D94
    ld   hl, hLinkPositionX
    ld   a, [$FFEE]
    sub  a, [hl]
    add  a, $03
    cp   $06
    jr   nc, .else_04_44D5

    ld   hl, hLinkPositionY
    ld   a, [$FFEC]
    sub  a, [hl]
    add  a, 3
    cp   6
    jr   nc, .else_04_44D5

    call toc_01_0891
    ld   [hl], $10
    call JumpTable_3B8D_00
.else_04_44D5:
    pop  af
    ld   [hLinkPositionY], a
    pop  af
    ld   [hLinkPositionX], a
    ret


JumpTable_44DC_04:
    call toc_01_0891
    jp   z, toc_04_6D44

    cp   $04
    jr   nz, .return_04_4509

    ld   a, $5C
    call toc_01_3C01
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
    ld   [hl], $02
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $C7
    assign [$FFF2], $1F
.return_04_4509:
    ret


JumpTable_450A_04:
    ld   hl, $C350
    add  hl, bc
    ld   [hl], $0C
    ld   hl, $C430
    add  hl, bc
    ld   [hl], $81
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    cp   $02
    jr   nz, .else_04_4528

    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $80
    ret


.else_04_4528:
    call toc_04_6D4A
    call toc_01_3BEB
    call toc_04_6D94
    call toc_01_3B9E
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .else_04_455B

    ld   a, $10
    call toc_01_3C30
    ld   hl, $C240
    add  hl, bc
    ld   a, [$FFD8]
    sub  a, [hl]
    and  %10000000
    jr   z, .else_04_454C

    dec  [hl]
    dec  [hl]
.else_04_454C:
    inc  [hl]
    ld   hl, $C250
    add  hl, bc
    ld   a, [$FFD7]
    sub  a, [hl]
    and  %10000000
    jr   z, .else_04_455A

    dec  [hl]
    dec  [hl]
.else_04_455A:
    inc  [hl]
.else_04_455B:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    add  a, 2
    jp   toc_01_3B87

JumpTable_4568_04:
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $41
    call toc_01_0891
    jr   nz, .else_04_45E4

    call JumpTable_3B8D_00
    ld   [hl], $04
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $01
    call toc_01_27ED
    and  %00000001
    jr   nz, .else_04_4599

    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
.else_04_4599:
    call toc_01_3DAF
    ld   hl, $C410
    add  hl, bc
    ld   [hl], b
    ld   a, $5C
    call toc_01_3C01
    jr   c, .return_04_45E3

    push bc
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    inc  [hl]
    and  %00000001
    ld   c, a
    ld   hl, $4490
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
    ld   hl, $C320
    add  hl, de
    ld   [hl], $24
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $04
    ld   hl, $C340
    add  hl, de
    ld   [hl], $12
    push de
    pop  bc
    ld   a, $1F
    call toc_01_3C25
    pop  bc
    assign [$FFF4], $28
.return_04_45E3:
    ret


.else_04_45E4:
    ld   a, [hLinkPositionX]
    push af
    assign [hLinkPositionX], 80
    ld   a, [hLinkPositionY]
    push af
    assign [hLinkPositionY], 72
    ld   a, $20
    call toc_01_3C30
    ld   a, [$FFD8]
    cpl
    inc  a
    push af
    ld   a, [$FFD7]
    push af
    ld   a, 4
    call toc_01_3C30
    ld   hl, $FFD8
    pop  af
    add  a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $FFD7
    pop  af
    add  a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    pop  af
    ld   [hLinkPositionY], a
    pop  af
    ld   [hLinkPositionX], a
    call toc_04_6D94
    call toc_04_4627
    jp   JumpTable_450A_04.else_04_455B

toc_04_4627:
    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    sub  a, $48
    ld   e, a
    ld   a, $48
    sub  a, e
    ld   hl, $C2D0
    add  hl, bc
    ld   [hl], a
    ld   hl, $C200
    add  hl, bc
    ld   a, [hl]
    sub  a, $50
    ld   e, a
    ld   a, $50
    sub  a, e
    ld   hl, $C440
    add  hl, bc
    ld   [hl], a
    ret


    db   $F0, $F4, $60, $00, $F0, $FC, $62, $00
    db   $F0, $04, $64, $00, $F0, $0C, $62, $20
    db   $F0, $14, $60, $20, $00, $F4, $66, $00
    db   $00, $FC, $68, $00, $00, $04, $6A, $00
    db   $00, $0C, $68, $20, $00, $14, $66, $20
    db   $F0, $F4, $60, $00, $F0, $FC, $62, $00
    db   $F0, $04, $64, $20, $F0, $0C, $62, $20
    db   $F0, $14, $60, $20, $00, $F4, $66, $00
    db   $00, $FC, $68, $00, $00, $04, $6A, $20
    db   $00, $0C, $68, $20, $00, $14, $66, $20
    db   $F0, $F4, $60, $00, $F0, $FC, $62, $00
    db   $F0, $04, $64, $00, $F0, $0C, $6C, $00
    db   $F0, $14, $6E, $00, $00, $F4, $66, $00
    db   $00, $FC, $68, $00, $00, $04, $6A, $00
    db   $00, $0C, $70, $00, $00, $14, $72, $00
    db   $F0, $F4, $6E, $20, $F0, $FC, $6C, $20
    db   $F0, $04, $64, $20, $F0, $0C, $62, $20
    db   $F0, $14, $60, $20, $00, $F4, $72, $20
    db   $00, $FC, $70, $20, $00, $04, $6A, $20
    db   $00, $0C, $68, $20, $00, $14, $66, $20
    db   $74, $00, $74, $20

toc_04_46EC:
    ifNe [$FFF0], $05, .else_04_4706

    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .else_04_4706

    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    ld   [$FFEC], a
    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    ld   [$FFEE], a
.else_04_4706:
    ld   hl, $C3B0
    add  hl, bc
    ld   a, [hl]
    ld   e, a
    ld   d, b
    sla  e
    sla  e
    sla  e
    ld   a, e
    sla  e
    sla  e
    add  a, e
    ld   e, a
    ld   hl, $4648
    add  hl, de
    ld   c, $0A
    call toc_01_3D26
    ld   a, $0A
    call toc_01_3DD0
    ld   a, [$FFEC]
    add  a, $10
    ld   [$FFEC], a
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    ld   [$FFF1], a
    ld   de, $46E8
    call toc_01_3CD0
    call toc_01_3DBA
    ret


    db   $10, $00, $1E, $00, $10, $08, $1E, $60
    db   $10, $00, $1E, $00, $10, $08, $1E, $60
    db   $10, $00, $1E, $00, $10, $08, $1E, $60
    db   $10, $00, $1E, $00, $10, $08, $1E, $60
    db   $08, $00, $30, $00, $08, $08, $30, $60
    db   $08, $00, $30, $00, $08, $08, $30, $60
    db   $08, $00, $30, $00, $08, $08, $30, $60
    db   $08, $00, $30, $00, $08, $08, $30, $60
    db   $04, $00, $30, $00, $04, $08, $30, $60
    db   $14, $00, $1E, $00, $14, $08, $1E, $60
    db   $14, $00, $1E, $00, $14, $08, $1E, $60
    db   $14, $00, $1E, $00, $14, $08, $1E, $60
    db   $00, $00, $30, $00, $00, $08, $30, $60
    db   $10, $00, $1E, $00, $10, $08, $1E, $60
    db   $10, $00, $1E, $00, $10, $08, $1E, $60
    db   $10, $00, $1E, $00, $10, $08, $1E, $60
    db   $F2, $FA, $30, $00, $F2, $02, $30, $60
    db   $F2, $06, $30, $00, $F2, $0E, $30, $60
    db   $FE, $FA, $30, $00, $FE, $02, $30, $60
    db   $FE, $06, $30, $00, $FE, $0E, $30, $60
    db   $F0, $F8, $30, $40, $F0, $00, $30, $20
    db   $F0, $08, $30, $40, $F0, $10, $30, $20
    db   $00, $F8, $30, $40, $00, $00, $30, $20
    db   $00, $08, $30, $40, $00, $10, $30, $20
    db   $F0, $F8, $32, $00, $F0, $00, $32, $60
    db   $F0, $08, $32, $00, $F0, $10, $32, $60
    db   $00, $F8, $32, $00, $00, $00, $32, $60
    db   $00, $08, $32, $00, $00, $10, $32, $60
    db   $06, $05, $04, $05, $04, $03, $02, $01
    db   $00, $00, $01, $02, $03, $04, $05, $04
    db   $05, $06

JumpTable_4833_04:
    call toc_04_48AE
    call toc_04_7F1F
    call toc_01_0891
    bit  7, a
    jr   z, .else_04_4862

    and  %01111111
    jr   nz, .else_04_4852

    ld   a, [$D002]
    ld   e, a
    ld   d, b
    ld   hl, $C290
    add  hl, de
    ld   [hl], $03
    jp   toc_04_6D44

.else_04_4852:
    rra
    rra
    rra
    and  %00001111
    ld   e, a
    ld   d, b
    ld   hl, $482A
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ret


.else_04_4862:
    and  a
    jp   z, toc_04_6D44

    cp   $06
    jr   nz, .else_04_489B

    ld   a, $5C
    call toc_01_3C01
    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ifGte [$FFD8], $14, .else_04_487E

    ld   a, $14
.else_04_487E:
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $01
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $40
    ld   hl, $C340
    add  hl, de
    ld   [hl], $01
    ld   hl, $C350
    add  hl, de
    ld   [hl], $8C
.else_04_489B:
    call toc_01_0891
    rra
    rra
    rra
    and  %00001111
    ld   e, a
    ld   d, b
    ld   hl, $4821
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ret


toc_04_48AE:
    ld   a, [$FFF1]
    rla
    rla
    rla
    rla
    rla
    and  %11100000
    ld   e, a
    ld   d, b
    ld   hl, $4741
    add  hl, de
    ld   c, $08
    call toc_01_3D26
    ld   a, $08
    call toc_01_3DD0
    ret


    db   $34, $00, $34, $20, $34, $10, $34, $30

JumpTable_48D0_04:
    ld   de, $48C8
    call toc_01_3C3B
    call toc_04_7F1F
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    push af
    ld   a, [$D000]
    add  a, [hl]
    ld   [hl], a
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    push af
    ld   a, [$D001]
    add  a, [hl]
    ld   [hl], a
    call toc_04_6D94
    pop  af
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    pop  af
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    _ifZero [$FFF0], .else_04_492F

    call toc_04_6DCD
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   z, .return_04_492E

    ld   [hl], b
    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $08
    ld   hl, $C240
    add  hl, bc
    ld   [hl], $E0
.return_04_492E:
    ret


.else_04_492F:
    call toc_01_0891
    call z, toc_04_6D44
    ret


JumpTable_4936_04:
    ld   de, $48C8
    call toc_01_3C3B
    call toc_04_7F1F
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    call toc_01_3BBF
    call toc_04_6D94
    call toc_04_6DCD
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jp   nz, toc_04_6D44

    ret


    db   $EE, $12, $F8, $08

toc_04_4967:
    clear [$FFE8]
.loop_04_496A:
    ld   a, $5B
    call toc_01_3C01
    ld   hl, $C390
    add  hl, de
    ld   [hl], $01
    push bc
    ld   a, [$FFE8]
    ld   c, a
    ld   hl, $4963
    add  hl, bc
    ld   a, [$FFD7]
    add  a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $4965
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C240
    add  hl, de
    ld   [hl], a
    ld   hl, $C320
    add  hl, de
    ld   [hl], $10
    ld   hl, $C290
    add  hl, de
    ld   [hl], $01
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C360
    add  hl, de
    ld   [hl], $05
    pop  bc
    ld   a, [$FFE8]
    inc  a
    ld   [$FFE8], a
    cp   $02
    jr   nz, .loop_04_496A

    jp   toc_04_6D44

toc_04_49B5:
    ld   hl, $C310
    add  hl, bc
    ld   [hl], $7E
    call toc_01_0891
    ld   [hl], $A0
    ret


    db   $CD, $0E, $38, $CD, $12, $3F, $CD, $52
    db   $4E, $21, $90, $C3, $09, $7E, $C7

    dw JumpTable_49D4_04 ; 00
    dw JumpTable_4DF9_04 ; 01

JumpTable_49D4_04:
    ld   hl, $C360
    add  hl, bc
    ld   [hl], $50
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_49E5_04 ; 00
    dw JumpTable_4A25_04 ; 01
    dw JumpTable_4A64_04 ; 02
    dw JumpTable_4A78_04 ; 03

JumpTable_49E5_04:
    ifNe [$C157], $05, .else_04_49F3

    call JumpTable_3B8D_00
    assign [$FFF2], $08
.else_04_49F3:
    call toc_01_0891
    jr   nz, .return_04_4A24

    ld   [hl], $50
    ifGte [$C1AE], $02, .return_04_4A24

    ld   a, $1B
    call toc_01_3C01
    call toc_01_27ED
    and  %00111111
    add  a, $40
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    call toc_01_27ED
    and  %00111111
    add  a, $30
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C310
    add  hl, de
    ld   [hl], $70
.return_04_4A24:
    ret


JumpTable_4A25_04:
    call toc_04_4DB1
    call toc_04_7F1F
    call toc_04_6DCD
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    cp   $A0
    jr   z, .else_04_4A39

    dec  [hl]
    dec  [hl]
.else_04_4A39:
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   z, .return_04_4A63

    ld   [hl], b
    assign [$C157], $50
    assign [$C158], $04
    call toc_01_0891
    ld   [hl], $40
    call toc_01_08D7
    _ifZero [$C146], .else_04_4A60

    call toc_01_0887
    ld   [hl], $14
.else_04_4A60:
    call JumpTable_3B8D_00
.return_04_4A63:
    ret


JumpTable_4A64_04:
    call toc_04_4DB1
    call toc_04_7F1F
    call toc_01_0891
    jr   nz, .else_04_4A72

    call JumpTable_3B8D_00
.else_04_4A72:
    call toc_04_4B28
    jp   toc_01_3BBF

JumpTable_4A78_04:
    call toc_04_4DB1
    call toc_04_7F1F
    call toc_01_08E2
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_4A9F

    cp   INTERACTIVE_MOTION_LOCKED_GRAB_SLASH
    jp   z, toc_04_4967

    ld   [hLinkInteractiveMotionBlocked], a
    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .else_04_4A9A

    ld   hl, hLinkPositionY
    dec  [hl]
.else_04_4A9A:
    ld   a, $06
    jp   toc_01_3B87

.else_04_4A9F:
    call toc_04_4B4C
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_4AC5

    inc  a
    call toc_01_3B87
    call toc_01_088C
    jr   nz, .else_04_4AC5

    ld   [hl], $28
    ld   hl, $C2B0
    add  hl, bc
    dec  [hl]
.else_04_4AC5:
    clear [$FFE8]
    ld   a, $14
    call toc_04_4B28.toc_04_4B31
    call toc_01_3BEB
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C300
    add  hl, bc
    or   [hl]
    jr   nz, .else_04_4AE9

    call toc_04_4B28
    call toc_01_3BBF
    assign [$FFE8], $01
    call toc_01_3BEB
.else_04_4AE9:
    ld   a, $14
    call toc_04_4B28.toc_04_4B31
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_04_4B0B

    ld   a, [hFrameCounter]
    and  %00011111
    jr   nz, .return_04_4B0B

    call toc_01_088C
    ld   [hl], $50
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    cp   $04
    jr   z, .return_04_4B0B

    inc  [hl]
.return_04_4B0B:
    ret


    db   $08, $14, $00, $0C, $08, $15, $00, $0B
    db   $08, $16, $00, $08, $08, $17, $00, $06
    db   $08, $18, $00, $04, $08, $03, $08, $03
    db   $08, $0C, $02, $0C

toc_04_4B28:
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    sla  a
    sla  a
.toc_04_4B31:
    ld   e, a
    ld   d, b
    ld   hl, $4B0C
    add  hl, de
    push hl
    pop  de
    push bc
    sla  c
    sla  c
    ld   hl, $D580
    add  hl, bc
    ld   c, $04
.loop_04_4B44:
    ld   a, [de]
    inc  de
    ldi  [hl], a
    dec  c
    jr   nz, .loop_04_4B44

    pop  bc
    ret


toc_04_4B4C:
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    jumptable
    dw JumpTable_4B76_04 ; 00
    dw JumpTable_4BC1_04 ; 01

    db   $10, $0C, $06, $02, $F0, $F4, $FA, $FE
    db   $10, $0C, $06, $02, $F0, $F4, $FA, $FE
    db   $02, $06, $0C, $10, $02, $06, $0C, $10
    db   $FE, $FA, $F4, $F0, $FE, $FA, $F4, $F0

JumpTable_4B76_04:
    call toc_01_0891
    and  a
    jr   nz, .return_04_4BC0

    call toc_01_27ED
    and  %00011111
    add  a, $10
    ld   [hl], a
    ld   hl, $C2D0
    add  hl, bc
    inc  [hl]
    ld   e, $00
    ifLt [$FFEE], $50, .else_04_4B92

    inc  e
.else_04_4B92:
    ld   d, $00
    ifLt [$FFEC], $48, .else_04_4B9C

    inc  d
    inc  d
.else_04_4B9C:
    ld   a, d
    or   e
    sla  a
    sla  a
    push af
    call toc_01_27ED
    and  %00000011
    pop  de
    or   d
    ld   e, a
    ld   d, b
    ld   hl, $4B56
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $4B66
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
.return_04_4BC0:
    ret


JumpTable_4BC1_04:
    call toc_01_0891
    jr   z, .else_04_4BD1

    and  %00001110
    jr   nz, .return_04_4BD0

    call toc_04_6D94
    call toc_01_3B9E
.return_04_4BD0:
    ret


.else_04_4BD1:
    ld   [hl], $30
    ld   hl, $C2D0
    add  hl, bc
    ld   [hl], b
    ret


    db   $F0, $F0, $60, $00, $F0, $F8, $62, $00
    db   $F0, $00, $70, $00, $F0, $08, $70, $20
    db   $F0, $10, $62, $20, $F0, $18, $60, $20
    db   $00, $F0, $64, $00, $00, $F8, $6E, $00
    db   $00, $00, $72, $00, $00, $08, $72, $20
    db   $00, $10, $6E, $20, $00, $18, $64, $20
    db   $00, $00, $FF, $00, $00, $00, $FF, $00
    db   $00, $00, $FF, $00, $00, $00, $FF, $00
    db   $F0, $F0, $68, $00, $F0, $F8, $6A, $00
    db   $F0, $00, $7E, $00, $F0, $08, $7E, $20
    db   $F0, $10, $6A, $20, $F0, $18, $68, $20
    db   $00, $F0, $6C, $00, $00, $F8, $6E, $00
    db   $00, $00, $72, $00, $00, $08, $72, $20
    db   $00, $10, $6E, $20, $00, $18, $6C, $20
    db   $00, $00, $FF, $00, $00, $00, $FF, $00
    db   $00, $00, $FF, $00, $00, $00, $FF, $00
    db   $F0, $F0, $60, $00, $F0, $F8, $62, $00
    db   $F0, $00, $62, $20, $F0, $08, $62, $00
    db   $F0, $10, $62, $20, $F0, $18, $60, $20
    db   $00, $F0, $64, $00, $00, $F8, $66, $00
    db   $00, $00, $66, $20, $00, $08, $66, $00
    db   $00, $10, $66, $20, $00, $18, $64, $20
    db   $00, $00, $FF, $00, $00, $00, $FF, $00
    db   $00, $00, $FF, $00, $00, $00, $FF, $00
    db   $F0, $EC, $60, $00, $F0, $F4, $62, $00
    db   $F0, $FC, $62, $20, $F0, $04, $74, $00
    db   $F0, $0C, $62, $00, $F0, $14, $62, $20
    db   $F0, $1C, $60, $20, $00, $EC, $64, $00
    db   $00, $F4, $66, $00, $00, $FC, $66, $20
    db   $00, $04, $76, $00, $00, $0C, $66, $00
    db   $00, $14, $66, $20, $00, $1C, $64, $20
    db   $00, $00, $FF, $00, $00, $00, $FF, $00
    db   $F0, $E8, $60, $00, $F0, $F0, $62, $00
    db   $F0, $F8, $62, $20, $F0, $00, $78, $00
    db   $F0, $08, $78, $20, $F0, $10, $62, $00
    db   $F0, $18, $62, $20, $F0, $20, $60, $20
    db   $00, $E8, $64, $00, $00, $F0, $66, $00
    db   $00, $F8, $66, $20, $00, $00, $7A, $00
    db   $00, $08, $7A, $20, $00, $10, $66, $00
    db   $00, $18, $66, $20, $00, $20, $64, $20
    db   $F0, $E8, $60, $00, $F0, $F0, $62, $00
    db   $F0, $F8, $62, $20, $F0, $00, $78, $00
    db   $F0, $08, $78, $20, $F0, $10, $62, $00
    db   $F0, $18, $62, $20, $F0, $20, $60, $20
    db   $00, $E8, $64, $00, $00, $F0, $66, $00
    db   $00, $F8, $66, $20, $00, $00, $7C, $00
    db   $00, $08, $7C, $20, $00, $10, $66, $00
    db   $00, $18, $66, $20, $00, $20, $64, $20
    db   $F0, $E6, $60, $00, $F0, $EE, $62, $00
    db   $F0, $F6, $62, $20, $F0, $FE, $78, $00
    db   $F0, $0A, $78, $20, $F0, $12, $62, $00
    db   $F0, $1A, $62, $20, $F0, $22, $60, $20
    db   $00, $E6, $64, $00, $00, $EE, $66, $00
    db   $00, $F6, $66, $20, $00, $FE, $7C, $00
    db   $00, $0A, $7C, $20, $00, $12, $66, $00
    db   $00, $1A, $66, $20, $00, $22, $64, $20
    db   $0C, $F5, $26, $00, $0C, $FB, $26, $00
    db   $0C, $01, $26, $00, $0C, $07, $26, $00
    db   $0C, $0D, $26, $00, $0C, $13, $26, $00

toc_04_4DB1:
    ld   hl, $C3B0
    add  hl, bc
    ld   a, [hl]
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
    rla
    rl   d
    and  %11000000
    ld   e, a
    ld   hl, $4BD9
    add  hl, de
    ld   c, $10
    call toc_01_3D26
    ld   a, $10
    call toc_01_3DD0
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_04_4DF8

    ld   a, [$FFEF]
    sub  a, $08
    ld   [$FFEC], a
    ld   hl, $4D99
    ld   c, $06
    call toc_01_3D26
    ld   a, $06
    call toc_01_3DD0
    call toc_01_3DBA
.return_04_4DF8:
    ret


JumpTable_4DF9_04:
    call toc_04_5000
    ld   a, [$FFEA]
    cp   $05
    jp   z, toc_04_4E60

    ld   hl, $C420
    add  hl, bc
    ld   a, [hFrameCounter]
    ld   [hl], a
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_4E13_04 ; 00
    dw JumpTable_4E1B_04 ; 01
    dw JumpTable_4E26_04 ; 02

JumpTable_4E13_04:
    call toc_01_0891
    ld   [hl], $40
    jp   JumpTable_3B8D_00

JumpTable_4E1B_04:
    call toc_01_0891
    jr   nz, .return_04_4E25

    ld   [hl], $A0
    call JumpTable_3B8D_00
.return_04_4E25:
    ret


JumpTable_4E26_04:
    call toc_01_0891
    jr   nz, .else_04_4E4F

    ld   e, $0F
    ld   d, b
.loop_04_4E2E:
    ld   a, c
    cp   e
    jr   z, .else_04_4E43

    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_04_4E43

    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $5B
    jr   z, .else_04_4E4C

.else_04_4E43:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_04_4E2E

    jp   toc_04_5746

.else_04_4E4C:
    jp   toc_04_6D44

.else_04_4E4F:
    jp   JumpTable_50ED_04.toc_04_50F3

    db   $CD, $87, $08, $28, $08, $3E, $02, $E0
    db   $A1, $3E, $6A, $E0, $9D, $C9

toc_04_4E60:
    call toc_04_7F1F
    ld   hl, $C410
    add  hl, bc
    ld   a, [hl]
    cp   $02
    jr   nz, .else_04_4E83

    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_4E82

    call JumpTable_3B8D_00
    ld   [hl], $02
    assign [$FFF2], $24
    call toc_01_3DAF
    jr   .else_04_4E83

.else_04_4E82:
    inc  [hl]
.else_04_4E83:
    call toc_04_6D4A
    clear [$FFE8]
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_4EA4_04 ; 00
    dw JumpTable_4EEB_04 ; 01
    dw JumpTable_4F65_04 ; 02
    dw JumpTable_4F80_04 ; 03

    db   $10, $0C, $00, $F4, $F0, $F4, $00, $0C
    db   $00, $0C, $10, $0C, $00, $F4, $F0, $F4

JumpTable_4EA4_04:
    ld   a, $18
    call toc_04_4B28.toc_04_4B31
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_04_4EE7

    call toc_01_27ED
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $4E94
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $4E9C
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    call toc_01_27ED
    and  %00000011
    jr   nz, .else_04_4ED8

    ld   a, $18
    call toc_01_3C25
.else_04_4ED8:
    call toc_01_27ED
    and  %00001111
    ld   hl, $C320
    add  hl, bc
    add  a, $08
    ld   [hl], a
    call JumpTable_3B8D_00
.else_04_4EE7:
    ld   a, b
    jp   toc_01_3B87

JumpTable_4EEB_04:
    call toc_01_0891
    and  a
    jr   nz, .else_04_4F60

    call toc_04_6D94
    call toc_01_3B9E
    call toc_04_6DCD
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    dec  [hl]
    ld   a, $18
    call toc_04_4B28.toc_04_4B31
    call toc_01_3BBF
    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_04_4F14

    call toc_01_3BEB
    xor  a
.else_04_4F14:
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   z, .else_04_4F60

    ld   [hl], b
    ld   hl, $C440
    add  hl, bc
    ld   [hl], b
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    sub  a, $E0
    and  %10000000
    jr   z, .else_04_4F49

    assign [$C157], $18
    assign [$FFF2], $0B
    _ifZero [$C146], .else_04_4F49

    call toc_01_0887
    ld   [hl], $0E
    ld   hl, $C320
    add  hl, bc
    ld   [hl], b
    jr   .else_04_4F57

.else_04_4F49:
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    ld   [hl], b
    cp   $F2
    jr   nc, .else_04_4F57

    assign [$FFF2], $20
.else_04_4F57:
    call JumpTable_3B8D_00
    ld   [hl], b
    call toc_01_0891
    ld   [hl], $20
.else_04_4F60:
    ld   a, $01
    jp   toc_01_3B87

JumpTable_4F65_04:
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $60
    call toc_04_6DCD
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    cp   $70
    jr   c, .return_04_4F7F

    call toc_01_0891
    ld   [hl], $30
    call JumpTable_3B8D_00
.return_04_4F7F:
    ret


JumpTable_4F80_04:
    ld   a, $FF
    call toc_01_3B87
    call toc_01_0891
    jr   nz, .return_04_4FAF

    ld   [hl], $18
    ld   hl, $C440
    add  hl, bc
    ld   [hl], $01
    call JumpTable_3B8D_00
    ld   [hl], $01
    ld   hl, $C320
    add  hl, bc
    ld   [hl], $C0
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, bc
    ld   [hl], a
    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, bc
    ld   [hl], a
    assign [$FFF2], $08
.return_04_4FAF:
    ret


    db   $F0, $F8, $60, $00, $F0, $00, $62, $00
    db   $F0, $08, $62, $20, $F0, $10, $60, $20
    db   $00, $F8, $64, $00, $00, $00, $66, $00
    db   $00, $08, $66, $20, $00, $10, $64, $20
    db   $F0, $F8, $68, $00, $F0, $00, $6A, $00
    db   $F0, $08, $6A, $20, $F0, $10, $68, $20
    db   $00, $F8, $6C, $00, $00, $00, $66, $00
    db   $00, $08, $66, $20, $00, $10, $6C, $20
    db   $0C, $FB, $26, $00, $0C, $01, $26, $00
    db   $0C, $07, $26, $00, $0C, $0D, $26, $00

toc_04_5000:
    ld   hl, $C3B0
    add  hl, bc
    ld   a, [hl]
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
    ld   hl, $4FB0
    add  hl, de
    ld   c, $08
    call toc_01_3D26
    ld   a, $08
    call toc_01_3DD0
    ld   hl, $C3B0
    add  hl, bc
    ld   a, [hl]
    cp   $FF
    jr   z, .else_04_504A

    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_504A

    ld   a, [$FFEF]
    sub  a, $02
    ld   [$FFEC], a
    ld   hl, $4FF0
    ld   c, $04
    call toc_01_3D26
    ld   a, $04
    call toc_01_3DD0
.else_04_504A:
    jp   toc_01_3DBA

toc_04_504D:
    call toc_01_0891
    ld   [hl], $FF
    ld   hl, $C410
    add  hl, bc
    ld   [hl], $08
    ld   hl, $C360
    add  hl, bc
    ld   [hl], $12
    ld   hl, $C200
    add  hl, bc
    call .toc_04_5069
    ld   hl, $C210
    add  hl, bc
.toc_04_5069:
    ld   a, [hl]
    add  a, $08
    ld   [hl], a
    ld   a, $FF
    jp   toc_01_3B87

    db   $21, $B0, $C2, $09, $7E, $C7

    dw JumpTable_5080_04 ; 00
    dw JumpTable_5470_04 ; 01
    dw JumpTable_550B_04 ; 02
    dw JumpTable_559C_04 ; 03

JumpTable_5080_04:
    clear [wScreenShakeHorizontal]
    call toc_01_3F12
    call toc_01_380E
    call toc_04_5438
    ld   a, [$FFEA]
    cp   $05
    jp   z, toc_04_5115

    ld   hl, $C420
    add  hl, bc
    ld   a, [hFrameCounter]
    ld   [hl], a
    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    jumptable
    dw JumpTable_50A7_04 ; 00
    dw JumpTable_50E3_04 ; 01
    dw JumpTable_50ED_04 ; 02

JumpTable_50A7_04:
    call toc_01_0891
    ld   [hl], $80
    ld   e, $0F
    ld   d, b
.loop_04_50AF:
    ld   a, c
    cp   e
    jr   z, .else_04_50D7

    ld   hl, $C340
    add  hl, de
    ld   a, [hl]
    and  %10000000
    jr   nz, .else_04_50D7

    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    cp   $05
    jr   c, .else_04_50D7

    ld   [hl], $01
    ld   hl, $C480
    add  hl, de
    ld   [hl], $1F
    ld   hl, $C340
    add  hl, de
    ld   a, [hl]
    and  %11110000
    or   %00000010
    ld   [hl], a
.else_04_50D7:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_04_50AF

.toc_04_50DD:
    ld   hl, $C440
    add  hl, bc
    inc  [hl]
    ret


JumpTable_50E3_04:
    call toc_01_0891
    jr   nz, .return_04_50EC

    ld   [hl], $FF
    jr   JumpTable_50A7_04.toc_04_50DD

.return_04_50EC:
    ret


JumpTable_50ED_04:
    call toc_01_0891
    jp   z, toc_04_5746

.toc_04_50F3:
    and  %00000111
    jr   nz, .return_04_5114

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
    call toc_04_59FB
.return_04_5114:
    ret


toc_04_5115:
    call toc_04_7F1F
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_5126

    ld   hl, $C390
    add  hl, bc
    ld   [hl], $FF
.else_04_5126:
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $08
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_5135_04 ; 00
    dw JumpTable_5160_04 ; 01
    dw JumpTable_51F1_04 ; 02

JumpTable_5135_04:
    call toc_01_0891
    jr   nz, .return_04_513F

    ld   [hl], $FF
    call JumpTable_3B8D_00
.return_04_513F:
    ret


    db   $03, $03, $03, $03, $03, $02, $01, $00
    db   $01, $00, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01, $01, $01, $01, $01, $00
    db   $00, $00, $00, $00, $00, $00, $00, $00

JumpTable_5160_04:
    call toc_01_0891
    jr   z, .else_04_5174

    rra
    rra
    rra
    and  %00011111
    ld   e, a
    ld   d, b
    ld   hl, $5140
    add  hl, de
    ld   a, [hl]
    jp   toc_01_3B87

.else_04_5174:
    call JumpTable_3B8D_00
    call toc_01_088C
    ld   [hl], $A0
    call toc_01_0887
    ld   [hl], $FF
    ld   a, $B6
    call toc_01_2197
    ret


    db   $03, $02, $04, $02, $28, $38, $48, $58
    db   $68, $78, $28, $78, $28, $78, $28, $38
    db   $48, $58, $68, $78, $30, $30, $30, $30
    db   $30, $30, $40, $40, $50, $50, $60, $60
    db   $60, $60, $60, $60, $28, $38, $48, $58
    db   $68, $78, $18, $88, $18, $88, $18, $88
    db   $18, $88, $28, $38, $48, $58, $68, $78
    db   $20, $20, $20, $20, $20, $20, $30, $30
    db   $40, $40, $50, $50, $60, $60, $70, $70
    db   $70, $70, $70, $70, $00, $13, $01, $12
    db   $02, $11, $03, $10, $04, $0F, $05, $0E
    db   $06, $0D, $07, $0C, $08, $0B, $09, $0A
    db   $18, $88, $18, $88, $20, $70, $70, $20
    db   $00, $FF

JumpTable_51F1_04:
    ld   a, [hFrameCounter]
    and  %00111111
    jr   nz, .else_04_5203

    call toc_01_27ED
    and  %00000001
    jr   nz, .else_04_5203

    call toc_01_0891
    ld   [hl], $1F
.else_04_5203:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    ld   e, a
    ld   d, b
    ld   hl, $51EF
    add  hl, de
    ld   a, [hl]
    ld   [wScreenShakeHorizontal], a
    call toc_01_0887
    jr   nz, .else_04_527C

    call toc_01_27ED
    and  %00001111
    add  a, $18
    ld   [hl], a
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    cp   $14
    jr   c, .else_04_527C

    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    cp   $04
    jr   c, .else_04_527C

    ld   a, $5A
    call toc_01_3C01
    jr   c, .else_04_527C

    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $01
.loop_04_5240:
    call toc_01_27ED
    and  %00001111
    ld   hl, $C2C0
    add  hl, bc
    cp   [hl]
    jr   z, .loop_04_5240

    ld   [hl], a
    push bc
    ld   c, a
    ld   hl, $518B
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $519B
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $7F
    ld   hl, $C340
    add  hl, de
    ld   [hl], $C2
    ld   hl, $C350
    add  hl, de
    ld   [hl], $00
    ld   hl, $C430
    add  hl, de
    ld   [hl], $00
    pop  bc
.else_04_527C:
    call toc_01_088C
    jr   nz, .else_04_52D2

    ld   [hl], $40
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    cp   $14
    jr   nc, .else_04_52D2

    ld   a, $5A
    call toc_01_3C01
    jr   c, .else_04_52D2

    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $02
    push bc
    ld   hl, $C3D0
    add  hl, bc
    ld   c, [hl]
    inc  [hl]
    ld   hl, $51D3
    add  hl, bc
    ld   c, [hl]
    ld   hl, $51AB
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $51BF
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C340
    add  hl, de
    ld   [hl], $12
    ld   hl, $C350
    add  hl, de
    ld   [hl], $00
    ld   hl, $C430
    add  hl, de
    ld   [hl], $00
    ld   hl, $C4D0
    add  hl, de
    ld   [hl], $02
    pop  bc
.else_04_52D2:
    ld   hl, $C300
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_04_5349

    ld   [hl], $40
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    cp   $04
    jr   nc, .else_04_5349

    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    cp   $12
    jr   c, .else_04_5349

    ld   a, $5A
    call toc_01_3C01
    jr   c, .else_04_5349

    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $03
    push bc
    ld   hl, $C2D0
    add  hl, bc
    ld   c, [hl]
    inc  [hl]
    ld   hl, $51E7
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   [$FFEE], a
    ld   hl, $51EB
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   [$FFEF], a
    ld   hl, $C340
    add  hl, de
    ld   [hl], $12
    ld   hl, $C350
    add  hl, de
    ld   [hl], $00
    ld   hl, $C430
    add  hl, de
    ld   [hl], $00
    ld   hl, $C4D0
    add  hl, de
    ld   [hl], $1B
    push de
    pop  bc
    ld   hl, $C240
    add  hl, bc
    ld   [hl], $01
    call toc_01_3B9E
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_04_5348

    call toc_04_6D44
.else_04_5348:
    pop  bc
.else_04_5349:
    call toc_01_0891
    rra
    rra
    rra
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $5187
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_5368

    ld   a, $02
    call toc_01_3B87
.else_04_5368:
    ld   hl, $C390
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_04_5387

    dec  [hl]
    rra
    rra
    rra
    rra
    and  %00001111
    ld   e, a
    ld   d, b
    ld   hl, $5388
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ld   hl, $C340
    add  hl, bc
    ld   [hl], $48
.return_04_5387:
    ret


    db   $02, $01, $00, $FF, $FF, $FF, $FF, $FF
    db   $FF, $FF, $FF, $FF, $FF, $00, $01, $02
    db   $F8, $F0, $70, $00, $F8, $F8, $72, $00
    db   $F8, $10, $72, $20, $F8, $18, $70, $20
    db   $08, $F8, $7C, $00, $08, $00, $7E, $00
    db   $08, $08, $7E, $20, $08, $10, $7C, $20
    db   $F8, $F0, $74, $00, $F8, $F8, $76, $00
    db   $F8, $10, $76, $20, $F8, $18, $74, $20
    db   $08, $F8, $7C, $00, $08, $00, $7E, $00
    db   $08, $08, $7E, $20, $08, $10, $7C, $20
    db   $F8, $F0, $74, $00, $F8, $F8, $76, $00
    db   $F8, $10, $76, $20, $F8, $18, $74, $20
    db   $08, $F8, $60, $00, $08, $00, $62, $00
    db   $08, $08, $62, $20, $08, $10, $60, $20
    db   $F8, $F0, $78, $00, $F8, $F8, $7A, $00
    db   $F8, $10, $7A, $20, $F8, $18, $78, $20
    db   $08, $F8, $60, $00, $08, $00, $62, $00
    db   $08, $08, $62, $20, $08, $10, $60, $20
    db   $F8, $F0, $70, $00, $F8, $F8, $72, $00
    db   $F8, $10, $72, $20, $F8, $18, $70, $20
    db   $08, $F8, $60, $00, $08, $00, $62, $00
    db   $08, $08, $62, $20, $08, $10, $60, $20

toc_04_5438:
    ld   hl, $C3B0
    add  hl, bc
    ld   a, [hl]
    rla
    rla
    rla
    rla
    rla
    and  %11100000
    ld   e, a
    ld   d, b
    ld   hl, $5398
    add  hl, de
    ld   c, $08
    call toc_01_3D26
    ret


    db   $68, $00, $68, $20, $6A, $00, $6A, $20
    db   $6C, $00, $6C, $20, $6E, $00, $6E, $20
    db   $00, $01, $02, $03, $03, $03, $03, $03
    db   $03, $02, $01, $00, $00, $00, $00, $00

JumpTable_5470_04:
    ld   de, $5450
    call toc_01_3C3B
    call toc_04_7F1F
    call toc_01_0891
    jp   z, toc_04_6D44

    cp   $50
    jr   nz, .else_04_5488

    ld   hl, $FFF2
    ld   [hl], $40
.else_04_5488:
    rra
    rra
    rra
    and  %00001111
    ld   e, a
    ld   d, b
    ld   hl, $5460
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    cp   $03
    jr   nz, .return_04_54FA

    ifEq [$C11C], $06, .return_04_54FA

    _ifZero [hLinkPositionZHigh], .return_04_54FA

    call toc_04_6DFF
    add  a, $08
    cp   $10
    jr   nc, .return_04_54FA

    call toc_04_6E0F
    add  a, $08
    cp   $10
    jr   nc, .return_04_54FA

    ld   a, $0C
    call toc_01_3C30
    ld   a, [$FFD7]
    cpl
    inc  a
    ld   [hLinkPositionYIncrement], a
    ld   a, [$FFD8]
    cpl
    inc  a
    ld   [hLinkPositionXIncrement], a
    push bc
    call toc_01_20D6
    pop  bc
    call toc_04_6DFF
    add  a, $03
    cp   $06
    jr   nc, .return_04_54FA

    call toc_04_6E0F
    add  a, $03
    cp   $06
    jr   nc, .return_04_54FA

    copyFromTo [$FFEE], [hLinkPositionX]
    assign [$C11C], $06
    call toc_01_093B
    ld   [$C198], a
    call toc_01_0891
    ld   [hl], $40
    assign [$DBCB], $50
.return_04_54FA:
    ret


    db   $40, $00, $40, $20, $42, $00, $42, $20
    db   $70, $00, $70, $20, $72, $00, $72, $20

JumpTable_550B_04:
    ld   de, $54FB
    ifNe [$FFF7], $01, .else_04_5517

    ld   de, $5503
.else_04_5517:
    call toc_01_3C3B
    call toc_01_08E2
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, JumpTable_5583_04.toc_04_5594

    call toc_04_7F1F
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ld   a, [hFrameCounter]
    and  %00000111
    jr   nz, .else_04_553C

    assign [$FFF2], $3F
.else_04_553C:
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_5545_04 ; 00
    dw JumpTable_5564_04 ; 01
    dw JumpTable_5583_04 ; 02

JumpTable_5545_04:
    call toc_01_0891
    ld   [hl], $60
    call JumpTable_3B8D_00
    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    cp   $01
    jp   z, toc_04_5608

    cp   $10
    jp   z, toc_04_5616

    cp   $20
    jp   z, toc_04_560F

    jp   toc_04_5624

JumpTable_5564_04:
    call toc_01_3BEB
    call toc_01_0891
    jr   z, .else_04_557A

    cp   $30
    jr   c, .return_04_5582

    and  %00000011
    jr   nz, .return_04_5579

    ld   hl, $C310
    add  hl, bc
    inc  [hl]
.return_04_5579:
    ret


.else_04_557A:
    call JumpTable_3B8D_00
    ld   a, $18
    call toc_01_3C25
.return_04_5582:
    ret


JumpTable_5583_04:
    call toc_04_6D94
    call toc_01_3B9E
    call toc_01_3BB4
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_04_5597

.toc_04_5594:
    call toc_01_3E64
.return_04_5597:
    ret


    db   $F0, $10, $F0, $30

JumpTable_559C_04:
    ld   de, $5598
    call toc_01_3C3B
    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, JumpTable_5583_04.toc_04_5594

    call toc_04_7F1F
    ld   a, [$FFF0]
    jumptable
    dw JumpTable_55B6_04 ; 00
    dw JumpTable_55C2_04 ; 01
    dw JumpTable_55E1_04 ; 02

JumpTable_55B6_04:
    call toc_04_561D
    call JumpTable_3B8D_00
    call toc_01_0891
    ld   [hl], $60
    ret


JumpTable_55C2_04:
    call toc_01_3BEB
    call toc_01_0891
    jr   z, .else_04_55D8

    cp   $30
    jr   c, .return_04_55E0

    and  %00000011
    jr   nz, .return_04_55D7

    ld   hl, $C310
    add  hl, bc
    inc  [hl]
.return_04_55D7:
    ret


.else_04_55D8:
    call JumpTable_3B8D_00
    ld   a, $18
    call toc_01_3C25
.return_04_55E0:
    ret


JumpTable_55E1_04:
    call toc_04_6D94
    call toc_01_3B9E
    call toc_01_3BB4
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  a
    jp   nz, JumpTable_5583_04.toc_04_5594

    ret


    db   $10, $12, $11, $13, $10, $12, $11, $13
    db   $14, $16, $15, $17, $76, $77, $76, $77
    db   $76, $49, $76, $49

toc_04_5608:
    ld   de, $55FC
    ld   a, $AA
    jr   toc_04_5624.toc_04_5629

toc_04_560F:
    ld   de, $5600
    ld   a, $AE
    jr   toc_04_5624.toc_04_5629

toc_04_5616:
    ld   de, $5604
    ld   a, $1D
    jr   toc_04_5624.toc_04_5629

toc_04_561D:
    ld   de, $55F8
    ld   a, $0D
    jr   toc_04_5624.toc_04_5629

toc_04_5624:
    ld   de, $55F4
    ld   a, $0D
.toc_04_5629:
    ld   [$FFD7], a
    push de
    ld   a, [$FFEF]
    sub  a, $0F
    ld   [hSwordIntersectedAreaY], a
    ld   a, [$FFEE]
    sub  a, $07
    ld   [hSwordIntersectedAreaX], a
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
    ld   a, [$FFD7]
    ld   [hl], a
    call toc_01_2839
    ld   a, [$D600]
    ld   e, a
    ld   d, $00
    ld   hl, $D601
    add  hl, de
    add  a, $0A
    ld   [$D600], a
    pop  de
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


toc_04_5680:
    clear [$D201]
    ld   e, $80
    ld   hl, $D100
.loop_04_5689:
    xor  a
    ldi  [hl], a
    dec  e
    jr   nz, .loop_04_5689

    ret


    db   $06, $07, $00, $01, $02, $03, $04, $05
    db   $CD, $1F, $7F, $C3, $B4, $3B, $CD, $0E
    db   $38, $CD, $97, $56, $CD, $F8, $58, $CD
    db   $E2, $08, $FA, $24, $C1, $A7, $C2, $80
    db   $56, $CD, $12, $3F, $F0, $EA, $FE, $05
    db   $CA, $86, $57, $F0, $F0, $C7

    dw JumpTable_56C5_04 ; 00
    dw JumpTable_56D4_04 ; 01
    dw JumpTable_56E5_04 ; 02
    dw JumpTable_5712_04 ; 03

JumpTable_56C5_04:
    call toc_01_0891
    ld   [hl], $60
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $FF
    call JumpTable_3B8D_00
    ret


JumpTable_56D4_04:
    call toc_01_0891
    jr   nz, .return_04_56E4

    ld   [hl], $FF
    ld   hl, $C420
    add  hl, bc
    ld   [hl], $FF
    call JumpTable_3B8D_00
.return_04_56E4:
    ret


JumpTable_56E5_04:
    call toc_01_0891
    and  %00011111
    jr   nz, .return_04_56F9

    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    cp   $04
    jr   z, .else_04_56FA

    inc  [hl]
    call toc_04_59FB
.return_04_56F9:
    ret


.else_04_56FA:
    call toc_01_0891
    ld   [hl], $30
    jp   JumpTable_3B8D_00

    db   $00, $06, $08, $06, $00, $FA, $F8, $FA
    db   $F8, $FA, $00, $06, $08, $06, $00, $FA

JumpTable_5712_04:
    call toc_01_0891
    jp   z, toc_04_5746

    and  %00000011
    jr   nz, .return_04_5745

    ld   a, [hl]
    rra
    rra
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $5702
    add  hl, de
    ld   a, [$FFEE]
    add  a, [hl]
    ld   [$FFEE], a
    ld   hl, $570A
    add  hl, de
    ld   a, [$FFEC]
    add  a, [hl]
    ld   [$FFEC], a
    call toc_04_59FB
    call toc_01_0891
    cp   $10
    jr   nz, .return_04_5745

    ld   hl, $C2D0
    add  hl, bc
    ld   [hl], $05
.return_04_5745:
    ret


toc_04_5746:
    ld   a, $36
    call toc_01_3C01
    ifLt [$FFD7], $88, .else_04_5753

    ld   a, $88
.else_04_5753:
    cp   $18
    jr   nc, .else_04_5759

    ld   a, $18
.else_04_5759:
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ifLt [$FFD8], $70, .else_04_5766

    ld   a, $70
.else_04_5766:
    cp   $20
    jr   nc, .else_04_576C

    ld   a, $20
.else_04_576C:
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C320
    add  hl, de
    ld   [hl], $10
    ld   a, [$FFDA]
    ld   hl, $C310
    add  hl, de
    ld   [hl], a
    ld   hl, $FFF4
    ld   [hl], $1A
    jp   toc_04_6D44

    db   $CD, $BA, $3D, $CD, $1F, $7F, $AF, $EA
    db   $D6, $D3, $1E, $10, $21, $60, $C3, $09
    db   $7E, $FE, $02, $38, $08, $21, $00, $C3
    db   $09, $7E, $A7, $28, $0A, $CD, $BB, $57
    db   $3E, $01, $EA, $D6, $D3, $1E, $0B, $21
    db   $01, $D2, $7E, $3C, $77, $BB, $38, $05
    db   $70, $3E, $1B, $E0, $F4, $21, $D0, $C3
    db   $09, $7E, $3C, $E6, $7F, $77, $5F, $50
    db   $21, $00, $D0, $19, $F0, $EE, $77, $21
    db   $00, $D1, $19, $F0, $EC, $77, $CD, $DC
    db   $5A, $21, $B0, $C2, $09, $5E, $CB, $3B
    db   $50, $21, $8F, $56, $19, $7E, $CD, $87
    db   $3B, $C9, $F8, $F8, $60, $00, $F8, $00
    db   $62, $00, $F8, $08, $62, $20, $F8, $10
    db   $60, $20, $08, $F8, $64, $00, $08, $00
    db   $66, $00, $08, $08, $66, $20, $08, $10
    db   $64, $20, $F8, $F8, $60, $00, $F8, $00
    db   $62, $00, $F8, $08, $62, $20, $F8, $10
    db   $60, $20, $08, $F8, $6C, $00, $08, $00
    db   $6E, $00, $08, $08, $62, $60, $08, $10
    db   $60, $60, $F8, $F8, $68, $00, $F8, $00
    db   $6A, $00, $F8, $08, $62, $20, $F8, $10
    db   $60, $20, $08, $F8, $68, $40, $08, $00
    db   $6A, $40, $08, $08, $62, $60, $08, $10
    db   $60, $60, $F8, $F8, $6C, $40, $F8, $00
    db   $6E, $40, $F8, $08, $62, $20, $F8, $10
    db   $60, $20, $08, $F8, $60, $40, $08, $00
    db   $62, $40, $08, $08, $62, $60, $08, $10
    db   $60, $60, $F8, $F8, $64, $40, $F8, $00
    db   $66, $40, $F8, $08, $66, $60, $F8, $10
    db   $64, $60, $08, $F8, $60, $40, $08, $00
    db   $62, $40, $08, $08, $62, $60, $08, $10
    db   $60, $60, $F8, $F8, $60, $00, $F8, $00
    db   $62, $00, $F8, $08, $6E, $60, $F8, $10
    db   $6C, $60, $08, $F8, $60, $40, $08, $00
    db   $62, $40, $08, $08, $62, $60, $08, $10
    db   $60, $60, $F8, $F8, $60, $00, $F8, $00
    db   $62, $00, $F8, $08, $6A, $20, $F8, $10
    db   $68, $20, $08, $F8, $60, $40, $08, $00
    db   $62, $40, $08, $08, $6A, $60, $08, $10
    db   $68, $60, $F8, $F8, $60, $00, $F8, $00
    db   $62, $00, $F8, $08, $62, $20, $F8, $10
    db   $60, $20, $08, $F8, $60, $40, $08, $00
    db   $62, $40, $08, $08, $6E, $20, $08, $10
    db   $6C, $20, $70, $00, $70, $20, $72, $00
    db   $72, $20, $74, $00, $74, $20, $76, $00
    db   $76, $20, $21, $D0, $C2, $09, $7E, $FE
    db   $05, $D2, $FA, $59, $21, $40, $C3, $09
    db   $36, $08, $21, $B0, $C3, $09, $7E, $17
    db   $17, $17, $17, $17, $E6, $E0, $5F, $50
    db   $21, $E8, $57, $19, $0E, $08, $CD, $26
    db   $3D, $21, $40, $C3, $09, $36, $02, $21
    db   $D0, $C3, $09, $7E, $E0, $D7, $21, $D0
    db   $C2, $09, $7E, $FE, $04, $D2, $FA, $59
    db   $F0, $D7, $D6, $0C, $E6, $7F, $5F, $50
    db   $21, $00, $D0, $19, $7E, $E0, $EE, $21
    db   $00, $D1, $19, $7E, $E0, $EC, $3E, $00
    db   $E0, $F1, $11, $E8, $58, $CD, $3B, $3C
    db   $21, $D0, $C2, $09, $7E, $FE, $03, $D2
    db   $FA, $59, $F0, $D7, $D6, $18, $E6, $7F
    db   $5F, $50, $21, $00, $D0, $19, $7E, $E0
    db   $EE, $21, $00, $D1, $19, $7E, $E0, $EC
    db   $3E, $00, $E0, $F1, $11, $E8, $58, $CD
    db   $3B, $3C, $21, $D0, $C2, $09, $7E, $FE
    db   $02, $30, $71, $F0, $D7, $D6, $24, $E6
    db   $7F, $5F, $50, $21, $00, $D0, $19, $7E
    db   $E0, $EE, $21, $00, $D1, $19, $7E, $E0
    db   $EC, $3E, $01, $E0, $F1, $11, $E8, $58
    db   $CD, $3B, $3C, $21, $D0, $C2, $09, $7E
    db   $A7, $20, $49, $F0, $D7, $D6, $2E, $E6
    db   $7F, $5F, $50, $21, $00, $D0, $19, $7E
    db   $E0, $EE, $21, $00, $D1, $19, $7E, $E0
    db   $EC, $F0, $E7, $1F, $1F, $1F, $E6, $01
    db   $C6, $02, $E0, $F1, $F0, $E7, $17, $17
    db   $E6, $10, $21, $ED, $FF, $AE, $77, $11
    db   $E8, $58, $CD, $3B, $3C, $21, $20, $C4
    db   $09, $7E, $A7, $20, $0F, $21, $30, $C4
    db   $09, $36, $90, $CD, $EB, $3B, $21, $30
    db   $C4, $09, $36, $D0, $C9

toc_04_59FB:
    call toc_04_7F1F.toc_04_7F25
    copyFromTo [$FFEE], [$FFD7]
    copyFromTo [$FFEC], [$FFD8]
    ld   a, $02
    call toc_01_0953
    assign [$FFF4], $13
    ret


toc_04_5A10:
    ld   hl, $C460
    add  hl, bc
    ld   e, [hl]
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
.loop_04_5A27:
    xor  a
    ldi  [hl], a
    dec  e
    ld   a, e
    cp   $00
    jr   nz, .loop_04_5A27

    pop  de
    ld   hl, $D100
    add  hl, de
    ld   e, $20
.loop_04_5A36:
    xor  a
    ldi  [hl], a
    dec  e
    ld   a, e
    cp   $00
    jr   nz, .loop_04_5A36

    ret


    db   $70, $00, $70, $20, $70, $40, $70, $60
    db   $72, $00, $74, $00, $74, $20, $72, $20
    db   $76, $00, $78, $00, $78, $20, $76, $20
    db   $76, $40, $78, $40, $78, $60, $76, $60
    db   $7A, $00, $7A, $20, $7C, $00, $7C, $20
    db   $03, $03, $05, $05, $00, $00, $04, $04
    db   $02, $02, $06, $06, $01, $01, $07, $07
    db   $00, $06, $0C, $0E, $10, $0E, $0C, $06
    db   $00, $FA, $F4, $F2, $F0, $F2, $F4, $FA
    db   $00, $06, $0C, $0E, $CD, $75, $5B, $FA
    db   $24, $C1, $A7, $20, $08, $21, $10, $C4
    db   $09, $7E, $A7, $28, $03, $CD, $10, $5A
    db   $CD, $1F, $7F, $21, $D0, $C3, $09, $7E
    db   $3C, $E6, $1F, $77, $E0, $D7, $21, $60
    db   $C4, $09, $5E, $CB, $23, $CB, $23, $CB
    db   $23, $CB, $23, $CB, $23, $16, $00, $D5
    db   $21, $00, $D0, $19, $F0, $D7, $5F, $19
    db   $F0, $EE, $77, $D1, $21, $00, $D1, $19
    db   $F0, $D7, $5F, $19, $F0, $EC, $77, $CD
    db   $4A, $6D, $CD, $B4, $3B, $21, $20, $C4
    db   $09, $7E, $A7, $20, $03, $CD, $94, $6D
    db   $CD, $9E, $3B, $21, $A0, $C2, $09, $7E
    db   $A7, $28, $2C, $1E, $08, $CB, $47, $20
    db   $0E, $1E, $00, $CB, $4F, $20, $08, $1E
    db   $04, $CB, $57, $20, $02, $1E, $0C, $21
    db   $B0, $C2, $09, $73, $CD, $ED, $27, $1F
    db   $38, $08, $21, $C0, $C2, $09, $7E, $2F
    db   $3C, $77, $CD, $91, $08, $36, $10, $CD
    db   $8C, $08, $20, $39, $36, $04, $F0, $EB
    db   $FE, $59, $20, $02, $36, $06, $21, $C0
    db   $C2, $09, $7E, $21, $B0, $C2, $09, $86
    db   $E6, $0F, $77, $21, $B0, $C2, $09, $5E
    db   $50, $21, $67, $5A, $19, $7E, $CD, $87
    db   $3B, $21, $77, $5A, $19, $7E, $21, $50
    db   $C2, $09, $77, $21, $7B, $5A, $19, $7E
    db   $21, $40, $C2, $09, $77, $CD, $91, $08
    db   $20, $13, $CD, $ED, $27, $E6, $1F, $C6
    db   $10, $77, $CD, $ED, $27, $E6, $02, $3D
    db   $21, $C0, $C2, $09, $77, $C9, $11, $3F
    db   $5A, $CD, $3B, $3C, $CD, $1F, $7F, $21
    db   $D0, $C3, $09, $7E, $E0, $D7, $21, $60
    db   $C4, $09, $5E, $CB, $23, $CB, $23, $CB
    db   $23, $CB, $23, $CB, $23, $50, $D5, $D5
    db   $21, $00, $D0, $19, $F0, $D7, $D6, $09
    db   $E6, $1F, $5F, $50, $19, $7E, $E0, $EE
    db   $D1, $21, $00, $D1, $19, $F0, $D7, $D6
    db   $09, $E6, $1F, $5F, $50, $19, $7E, $E0
    db   $EC, $3E, $08, $E0, $F1, $11, $3F, $5A
    db   $CD, $3B, $3C, $D1, $D5, $21, $00, $D0
    db   $19, $F0, $D7, $D6, $10, $E6, $1F, $5F
    db   $50, $19, $7E, $E0, $EE, $D1, $21, $00
    db   $D1, $19, $F0, $D7, $D6, $10, $E6, $1F
    db   $5F, $50, $19, $7E, $E0, $EC, $3E, $09
    db   $E0, $F1, $11, $3F, $5A, $CD, $3B, $3C
    db   $CD, $BA, $3D, $C9, $58, $00, $5A, $00
    db   $5C, $00, $5E, $00, $0C, $F4, $08, $F8
    db   $CD, $9D, $5D, $18, $09, $CD, $0C, $7F
    db   $11, $F3, $5B, $CD, $3B, $3C, $F0, $F0
    db   $A7, $28, $28, $3E, $FF, $CD, $87, $3B
    db   $CD, $FF, $6D, $C6, $10, $FE, $20, $30
    db   $19, $CD, $0F, $6E, $C6, $10, $FE, $20
    db   $30, $10, $FA, $33, $C1, $A7, $28, $0A
    db   $CD, $8D, $3B, $70, $21, $00, $C3, $09
    db   $36, $30, $C9, $F0, $E7, $1F, $1F, $1F
    db   $1F, $A9, $E6, $01, $CD, $87, $3B, $F0
    db   $E7, $E6, $00, $28, $05, $3E, $FF, $CD
    db   $87, $3B, $CD, $1F, $7F, $CD, $4A, $6D
    db   $CD, $EB, $3B, $CD, $94, $6D, $CD, $CD
    db   $6D, $CD, $FF, $5C, $21, $00, $C3, $09
    db   $7E, $A7, $C2, $FE, $5C, $CD, $BF, $3B
    db   $CD, $91, $08, $20, $0F, $CD, $ED, $27
    db   $E6, $1F, $C6, $20, $77, $E6, $01, $21
    db   $B0, $C2, $09, $77, $CD, $8C, $08, $20
    db   $0F, $CD, $ED, $27, $E6, $0F, $C6, $18
    db   $77, $E6, $01, $21, $C0, $C2, $09, $77
    db   $F0, $E7, $A9, $E6, $03, $20, $60, $21
    db   $B0, $C2, $09, $F0, $EE, $FE, $28, $30
    db   $04, $36, $00, $18, $06, $FE, $78, $38
    db   $07, $36, $01, $CD, $91, $08, $36, $20
    db   $21, $C0, $C2, $09, $F0, $EC, $FE, $28
    db   $30, $04, $36, $00, $18, $06, $FE, $60
    db   $38, $07, $36, $01, $CD, $8C, $08, $36
    db   $20, $21, $B0, $C2, $09, $5E, $50, $21
    db   $FB, $5B, $19, $7E, $21, $40, $C2, $09
    db   $96, $E6, $80, $20, $02, $34, $34, $35
    db   $21, $C0, $C2, $09, $5E, $50, $21, $FD
    db   $5B, $19, $7E, $21, $50, $C2, $09, $96
    db   $E6, $80, $20, $02, $34, $34, $35, $C9
    db   $F0, $E7, $E6, $03, $20, $17, $21, $10
    db   $C3, $09, $7E, $FE, $10, $28, $0E, $CB
    db   $7F, $28, $03, $34, $18, $07, $FE, $10
    db   $30, $02, $34, $C9, $35, $C9, $F8, $F8
    db   $60, $00, $F8, $00, $62, $00, $F8, $08
    db   $62, $20, $F8, $10, $60, $20, $08, $F8
    db   $64, $00, $08, $00, $66, $00, $08, $08
    db   $68, $00, $08, $10, $6A, $00, $F8, $F8
    db   $60, $00, $F8, $00, $62, $00, $F8, $08
    db   $62, $20, $F8, $10, $60, $20, $08, $F8
    db   $64, $00, $08, $00, $6C, $00, $08, $08
    db   $6E, $00, $08, $10, $6A, $00, $F8, $F8
    db   $60, $00, $F8, $00, $62, $00, $F8, $08
    db   $62, $20, $F8, $10, $60, $20, $08, $F8
    db   $6A, $20, $08, $00, $68, $20, $08, $08
    db   $66, $20, $08, $10, $64, $20, $F8, $F8
    db   $60, $00, $F8, $00, $62, $00, $F8, $08
    db   $62, $20, $F8, $10, $60, $20, $08, $F8
    db   $6A, $20, $08, $00, $6E, $20, $08, $08
    db   $6C, $20, $08, $10, $64, $20, $CD, $0C
    db   $7F, $F0, $ED, $F5, $17, $E6, $40, $E0
    db   $D7, $F1, $E6, $0F, $E0, $ED, $21, $B0
    db   $C3, $09, $7E, $17, $17, $17, $17, $17
    db   $E6, $E0, $21, $D7, $FF, $86, $5F, $50
    db   $21, $1D, $5D, $19, $0E, $08, $CD, $26
    db   $3D, $C9, $70, $00, $72, $00, $72, $20
    db   $70, $20, $74, $00, $74, $20, $00, $00
    db   $00, $00, $7A, $00, $7A, $20, $FF, $00
    db   $FF, $00, $76, $00, $78, $00, $78, $20
    db   $76, $20, $F0, $F1, $FE, $03, $20, $25
    db   $F0, $EE, $D6, $08, $E0, $EE, $3E, $06
    db   $E0, $F1, $11, $C9, $5D, $CD, $3B, $3C
    db   $F0, $EE, $C6, $10, $E0, $EE, $3E, $07
    db   $E0, $F1, $11, $C9, $5D, $CD, $3B, $3C
    db   $CD, $BA, $3D, $18, $06, $11, $C9, $5D
    db   $CD, $3B, $3C, $CD, $1F, $7F, $CD, $4A
    db   $6D, $F0, $F0, $C7

    dw JumpTable_5E29_04 ; 00
    dw JumpTable_5E6E_04 ; 01
    dw JumpTable_5EAF_04 ; 02

JumpTable_5E29_04:
    call toc_01_3BB4
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    call toc_01_0891
    cp   24
    jr   nz, .else_04_5E42

    call toc_04_5EC0
    and  a
.else_04_5E42:
    jr   nc, .return_04_5E6A

    call toc_04_6DFF
    add  a, 32
    cp   64
    jr   nc, .return_04_5E6A

    call toc_04_6E0F
    add  a, 32
    cp   64
    jr   nc, .return_04_5E6A

    ld   hl, $C420
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .return_04_5E6A

    call toc_01_0891
    ld   [hl], $20
    call JumpTable_3B8D_00
    assign [$FFF2], $3C
.return_04_5E6A:
    ret


    db   $04, $03, $02

JumpTable_5E6E_04:
    call toc_01_0891
    cp   $18
    jp   nc, toc_01_3BB4

    and  a
    jr   nz, .else_04_5E9C

    ld   [hl], $40
    call JumpTable_3B8D_00
    ld   a, $FF
    call toc_01_3B87
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


.else_04_5E9C:
    rra
    rra
    rra
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $5E6B
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ret


    db   $02, $03, $04

JumpTable_5EAF_04:
    call toc_01_0891
    cp   $18
    jr   nc, toc_04_5EDF.return_04_5EEE

    and  a
    jr   nz, toc_04_5EDF

    ld   [hl], $30
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


toc_04_5EC0:
    ld   a, $58
    call toc_01_3C01
    jr   c, .return_04_5EDE

    ld   hl, $C200
    add  hl, de
    ld   a, [$FFD7]
    ld   [hl], a
    ld   hl, $C210
    add  hl, de
    ld   a, [$FFD8]
    ld   [hl], a
    push bc
    push de
    pop  bc
    ld   a, $18
    call toc_01_3C25
    pop  bc
.return_04_5EDE:
    ret


toc_04_5EDF:
    rra
    rra
    rra
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $5EAC
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
.return_04_5EEE:
    ret


    db   $7C, $00, $7C, $20, $7E, $00, $7E, $20
    db   $11, $EF, $5E, $CD, $3B, $3C, $CD, $1F
    db   $7F, $F0, $E7, $1F, $1F, $1F, $E6, $01
    db   $CD, $87, $3B, $CD, $94, $6D, $CD, $A9
    db   $3B, $CD, $CA, $3B, $CD, $EB, $3B, $21
    db   $A0, $C2, $09, $7E, $A7, $28, $06, $CD
    db   $44, $6D, $CD, $E9, $6B, $C9, $00, $F0
    db   $78, $00, $00, $F8, $7A, $00, $00, $00
    db   $70, $00, $00, $08, $72, $00, $00, $F0
    db   $7C, $00, $00, $F8, $7E, $00, $00, $00
    db   $70, $00, $00, $08, $72, $00, $00, $F0
    db   $78, $00, $00, $F8, $7A, $00, $00, $00
    db   $74, $00, $00, $08, $76, $00, $9A, $10
    db   $9C, $10, $21, $40, $C4, $09, $7E, $A7
    db   $28, $32, $F0, $EC, $C6, $04, $E0, $EC
    db   $11, $55, $5F, $CD, $3B, $3C, $CD, $94
    db   $6D, $CD, $CD, $6D, $21, $20, $C3, $09
    db   $35, $21, $10, $C3, $09, $7E, $E6, $80
    db   $28, $0D, $CD, $44, $6D, $AF, $EA, $7F
    db   $DB, $EA, $67, $C1, $C3, $98, $08, $3E
    db   $02, $E0, $A1, $C9, $F0, $F9, $A7, $C2
    db   $7B, $60, $21, $40, $C3, $09, $36, $84
    db   $21, $90, $C3, $09, $7E, $E0, $E8, $FA
    db   $9F, $C1, $A7, $21, $45, $5F, $20, $10
    db   $21, $D0, $C3, $09, $7E, $34, $21, $25
    db   $5F, $E6, $30, $28, $03, $21, $35, $5F
    db   $0E, $04, $CD, $26, $3D, $3E, $04, $CD
    db   $D0, $3D, $CD, $54, $7B, $F0, $F0, $C7

    dw JumpTable_5FD5_04 ; 00
    dw JumpTable_5FE3_04 ; 01
    dw JumpTable_6016_04 ; 02

JumpTable_5FD5_04:
    call toc_04_7BBC
    jr   nc, .return_04_5FE2

    ld   a, $45
    call toc_01_2197
    call JumpTable_3B8D_00
.return_04_5FE2:
    ret


JumpTable_5FE3_04:
    _ifZero [wDialogState], .return_04_600E

    call JumpTable_3B8D_00
    ifNotZero [$C177], .else_04_5FF8

    ld   [hl], b
    ld   a, $46
    jp   toc_01_2197

.else_04_5FF8:
    ld   a, [$DB5E]
    sub  a, $10
    ld   a, [$DB5D]
    sbc  $00
    jr   c, .else_04_600F

    assign [$DB92], $0A
    ld   a, $47
    call toc_01_2197
.return_04_600E:
    ret


.else_04_600F:
    ld   [hl], b
    ld   a, $4E
    call toc_01_2197
    ret


JumpTable_6016_04:
    _ifZero [wDialogState], .return_04_6022

    call toc_01_3EAD
    call toc_04_67C1
.return_04_6022:
    ret


    db   $58, $00, $5A, $00, $56, $20, $FF, $00
    db   $5C, $00, $5E, $00, $58, $00, $5A, $00
    db   $58, $00, $5A, $00, $5C, $00, $5E, $00
    db   $5C, $00, $5E, $00, $56, $00, $FF, $00
    db   $5E, $20, $5C, $20, $58, $00, $5A, $00
    db   $06, $16, $10, $10, $38, $38, $39, $39
    db   $16, $38, $F6, $00, $F1, $F0, $F0, $F0
    db   $F0, $FE, $04, $F2, $00, $F0, $FA, $00
    db   $00, $F8, $F8, $F8, $F2, $FE, $E8, $00
    db   $E0, $E8, $00, $00, $00, $00, $14, $10
    db   $E0, $F8, $10, $00, $00, $00, $00, $F0
    db   $21, $B0, $C2, $09, $7E, $C7

    dw JumpTable_60A2_04 ; 00
    dw JumpTable_6241_04 ; 01
    dw JumpTable_63FC_04 ; 02
    dw JumpTable_66E7_04 ; 03

    db   $18, $58, $60, $18, $88, $40, $4C, $34
    db   $68, $50, $01, $00, $00, $01, $00, $02
    db   $02, $02, $03, $03, $00, $3E, $1E, $10
    db   $30

JumpTable_60A2_04:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_04_60F2

    inc  [hl]
    push bc
    ld   c, $05
.loop_04_60B2:
    ld   a, $54
    call toc_01_3C01
    ld   hl, $6088
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $608D
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $6092
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C380
    add  hl, de
    ld   [hl], a
    ld   hl, $6097
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], a
    ld   hl, $609C
    add  hl, bc
    ld   a, [hl]
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], a
    dec  c
    jr   nz, .loop_04_60B2

    clear [$D004]
    pop  bc
    ret


.else_04_60F2:
    ld   a, [$FFF1]
    ld   e, a
    ld   d, b
    ld   hl, $604B
    add  hl, de
    ld   a, [hl]
    ld   [hLinkAnimationState], a
    ld   hl, $6055
    add  hl, de
    ld   a, [hLinkPositionX]
    add  a, [hl]
    ld   [$FFEE], a
    ld   hl, $605F
    add  hl, de
    ld   a, [hLinkPositionY]
    add  a, [hl]
    ld   [$FFEC], a
    ld   de, $6023
    call toc_01_3C3B
    ld   a, [$FFF0]
    jumptable
    db   $26, $61, $4E, $61, $B7, $61, $B8, $61
    db   $02, $62, $0F, $62, $2C, $62, $FA, $9F
    db   $C1, $A7, $20, $12, $F0, $CC, $E6, $30
    db   $28, $0C, $CD, $8D, $3B, $CD, $91, $08
    db   $36, $23, $AF, $EA, $02, $D0, $3E, $09
    db   $CD, $8D, $61, $C9, $01, $08, $08, $08
    db   $08, $08, $01, $02, $03, $00, $CD, $91
    db   $08, $20, $36, $CD, $8D, $3B, $3E, $02
    db   $EA, $B0, $C3, $3E, $54, $CD, $01, $3C
    db   $21, $00, $C2, $19, $36, $78, $21, $10
    db   $C2, $19, $36, $18, $21, $40, $C2, $19
    db   $36, $E2, $21, $50, $C2, $19, $36, $FA
    db   $21, $B0, $C2, $19, $36, $01, $21, $E0
    db   $C2, $19, $36, $14, $3E, $08, $E0, $F2
    db   $C9, $1F, $1F, $E6, $1F, $5F, $50, $21
    db   $44, $61, $19, $7E, $EA, $B0, $C3, $5F
    db   $50, $21, $69, $60, $19, $F0, $98, $86
    db   $E0, $EE, $21, $72, $60, $19, $F0, $99
    db   $86, $E0, $EC, $AF, $E0, $F1, $11, $2D
    db   $62, $CD, $3B, $3C, $C3, $BA, $3D, $C9
    db   $FA, $9F, $C1, $A7, $20, $3B, $FA, $77
    db   $C1, $A7, $20, $2D, $FA, $04, $D0, $FE
    db   $05, $38, $0B, $3E, $4B, $CD, $97, $21
    db   $CD, $8D, $3B, $36, $05, $C9, $FA, $5E
    db   $DB, $D6, $10, $FA, $5D, $DB, $DE, $00
    db   $38, $18, $3E, $0A, $EA, $92, $DB, $3E
    db   $47, $CD, $97, $21, $CD, $8D, $3B, $70
    db   $C9, $3E, $46, $CD, $97, $21, $CD, $8D
    db   $3B, $C9, $3E, $4E, $CD, $97, $21, $C3
    db   $8D, $3B, $FA, $9F, $C1, $A7, $20, $06
    db   $CD, $AD, $3E, $CD, $C1, $67, $C9, $FA
    db   $9F, $C1, $A7, $20, $16, $CD, $8D, $3B
    db   $36, $04, $FA, $77, $C1, $A7, $20, $06
    db   $3E, $4C, $CD, $97, $21, $C9, $3E, $46
    db   $CD, $97, $21, $C9, $C9, $50, $00, $54
    db   $00, $50, $00, $52, $00, $50, $40, $54
    db   $00, $54, $40, $50, $40, $54, $60, $50
    db   $60

JumpTable_6241_04:
    ld   a, c
    ld   [$D003], a
    ld   de, $622D
    call toc_01_3C3B
    copyFromTo [$FFEE], [$D000]
    copyFromTo [$FFEF], [$D001]
    call toc_04_7F1F
    ld   a, [$FFF0]
    jumptable
    db   $5F, $62, $C8, $62, $CD, $A1, $6D, $CD
    db   $97, $6D, $F0, $CB, $E6, $01, $28, $11
    db   $F0, $E7, $E6, $01, $20, $0B, $21, $40
    db   $C2, $09, $7E, $A7, $28, $03, $34, $18
    db   $05, $CD, $91, $08, $20, $26, $F0, $E7
    db   $E6, $01, $20, $0A, $21, $50, $C2, $09
    db   $7E, $FE, $20, $28, $01, $34, $21, $D0
    db   $C3, $09, $7E, $3C, $FE, $03, $77, $20
    db   $0B, $AF, $77, $21, $40, $C2, $09, $7E
    db   $A7, $28, $01, $34, $21, $10, $C2, $09
    db   $7E, $FE, $2A, $38, $17, $CD, $AF, $3D
    db   $CD, $8D, $3B, $F0, $EC, $E0, $D8, $F0
    db   $EE, $E0, $D7, $3E, $01, $CD, $53, $09
    db   $3E, $0E, $E0, $F2, $C9, $21, $B0, $C3
    db   $36, $00, $CD, $91, $08, $28, $05, $21
    db   $B0, $C3, $36, $04, $CD, $8C, $08, $28
    db   $05, $21, $B0, $C3, $36, $05, $F0, $E7
    db   $1F, $1F, $1F, $1F, $E6, $01, $CD, $87
    db   $3B, $CD, $94, $6D, $F0, $E7, $E6, $07
    db   $20, $1F, $21, $50, $C2, $09, $7E, $D6
    db   $04, $28, $07, $E6, $80, $28, $02, $34
    db   $34, $35, $21, $40, $C2, $09, $7E, $A7
    db   $28, $07, $E6, $80, $28, $02, $34, $34
    db   $35, $F0, $CC, $E6, $30, $28, $5F, $CD
    db   $91, $08, $36, $08, $F0, $98, $F5, $D6
    db   $17, $E0, $98, $3E, $04, $CD, $25, $3C
    db   $F1, $E0, $98, $F0, $EC, $FE, $25, $30
    db   $39, $F0, $EE, $FE, $70, $38, $33, $21
    db   $90, $C2, $36, $03, $3E, $48, $CD, $97
    db   $21, $CD, $44, $6D, $1E, $0F, $50, $21
    db   $80, $C2, $19, $7E, $A7, $28, $15, $21
    db   $B0, $C2, $19, $7E, $FE, $02, $38, $0C
    db   $21, $90, $C2, $19, $7E, $FE, $02, $38
    db   $03, $E6, $01, $77, $1D, $7B, $FE, $FF
    db   $20, $DD, $F0, $E7, $1F, $1F, $1F, $E6
    db   $01, $CD, $87, $3B, $18, $25, $F0, $CC
    db   $E6, $05, $28, $1F, $F0, $EC, $FE, $30
    db   $38, $19, $21, $00, $C3, $09, $7E, $A7
    db   $20, $11, $21, $50, $C2, $09, $36, $FA
    db   $21, $00, $C3, $09, $36

JumpTable_6398_04:
    ld   d, b
    call toc_01_088C
    ld   [hl], $10
    ld   a, [$FFEE]
    ld   hl, $C200
    add  hl, bc
    cp   [hl]
    jr   nz, .else_04_63B0

    ld   a, [$FFEF]
    ld   hl, $C210
    add  hl, bc
    cp   [hl]
    jr   z, .else_04_63C2

.else_04_63B0:
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    push af
    push hl
    and  %10000000
    jr   z, .else_04_63BC

    ld   [hl], b
.else_04_63BC:
    call toc_01_3B9E
    pop  hl
    pop  af
    ld   [hl], a
.else_04_63C2:
    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_63CE

    xor  a
    call toc_01_3B87
.else_04_63CE:
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    rla
    jr   c, .return_04_63DB

    ld   a, $02
    call toc_01_3B87
.return_04_63DB:
    ret


    db   $4C, $00, $4A, $00, $4C, $00, $4E, $00
    db   $48, $00, $4A, $00, $48, $00, $4E, $00
    db   $4A, $20, $4C, $20, $4E, $20, $4C, $20
    db   $4A, $20, $48, $20, $4E, $20, $48, $20

JumpTable_63FC_04:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_04_640A

    ld   a, [$FFF1]
    add  a, $04
    ld   [$FFF1], a
.else_04_640A:
    ld   de, $63DC
    call toc_01_3C3B
.toc_04_6410:
    call toc_04_7F1F
    call toc_04_6D94
    ld   a, [$FFF0]
    jumptable
    db   $25, $64, $5D, $64, $B4, $64, $EF, $64
    db   $3C, $65, $4D, $66, $CD, $61, $67, $21
    db   $B0, $C2, $09, $7E, $FE, $03, $CA, $FE
    db   $66, $CD, $91, $08, $20, $0D, $36, $30
    db   $21, $80, $C3, $09, $7E, $EE, $01, $77
    db   $CD, $8D, $3B, $F0, $E7, $E6, $03, $20
    db   $0F, $21, $40, $C2, $09, $7E, $A7, $28
    db   $07, $E6, $80, $28, $02, $34, $34, $35
    db   $18, $47, $10, $F0, $CD, $61, $67, $21
    db   $B0, $C2, $09, $7E, $FE, $03, $CA, $28
    db   $67, $CD, $91, $08, $20, $06, $36, $50
    db   $CD, $8D, $3B, $70, $F0, $E7, $1F, $1F
    db   $1F, $E6, $01, $CD, $87, $3B, $F0, $E7
    db   $E6, $03, $20, $1D, $21, $40, $C2, $09
    db   $7E, $E5, $21, $80, $C3, $09, $5E, $16
    db   $00, $21, $5B, $64, $19, $96, $E1, $A7
    db   $28, $07, $E6, $80, $28, $02, $34, $34
    db   $35, $21, $10, $C2, $09, $7E, $FE, $34
    db   $30, $06, $34, $21, $50, $C2, $09, $70
    db   $C9, $F2, $14, $F0, $E7, $1F, $1F, $1F
    db   $E6, $01, $CD, $87, $3B, $CD, $91, $08
    db   $20, $03, $CD, $8D, $3B, $F0, $98, $F5
    db   $F0, $99, $F5, $21, $80, $C3, $09, $5E
    db   $50, $21, $B2, $64, $19, $FA, $00, $D0
    db   $86, $E0, $98, $FA, $01, $D0, $E0, $99
    db   $3E, $04, $CD, $25, $3C, $F1, $E0, $99
    db   $F1, $E0, $98, $C3, $94, $6D, $F0, $E7
    db   $1F, $1F, $E6, $01, $C6, $02, $CD, $87
    db   $3B, $F0, $98, $F5, $F0, $99, $F5, $FA
    db   $00, $D0, $C6, $04, $E0, $98, $FA, $01
    db   $D0, $E0, $99, $3E, $10, $CD, $25, $3C
    db   $F1, $E0, $99, $F1, $E0, $98, $CD, $94
    db   $6D, $FA, $00, $D0, $21, $EE, $FF, $96
    db   $C6, $08, $FE, $10, $30, $10, $CD, $AF
    db   $3D, $CD, $8D, $3B, $FA, $03, $D0, $5F
    db   $50, $21, $80, $C2, $19, $70, $C9, $54
    db   $00, $08, $F8, $21, $80, $C3, $09, $5E
    db   $50, $21, $3A, $65, $19, $F0, $EE, $86
    db   $E0, $EE, $21, $F1, $FF, $70, $11, $38
    db   $65, $CD, $D0, $3C, $CD, $BA, $3D, $F0
    db   $E7, $1F, $1F, $1F, $E6, $01, $CD, $87
    db   $3B, $F0, $E7, $E6, $07, $20, $35, $F0
    db   $98, $F5, $F0, $99, $F5, $3E, $00, $E0
    db   $98, $3E, $59, $E0, $99, $3E, $08, $CD
    db   $30, $3C, $F0, $D7, $21, $50, $C2, $09
    db   $96, $34, $E6, $80, $28, $02, $35, $35
    db   $F0, $D8, $21, $40, $C2, $09, $96, $34
    db   $E6, $80, $28, $02, $35, $35, $F1, $E0
    db   $99, $F1, $E0, $98, $F0, $CC, $E6, $30
    db   $28, $50, $21, $B0, $C2, $09, $7E, $FE
    db   $03, $20, $07, $CD, $ED, $27, $E6, $03
    db   $28, $40, $F0, $98, $F5, $D6, $14, $E0
    db   $98, $F0, $99, $F5, $C6, $08, $E0, $99
    db   $3E, $03, $CD, $30, $3C, $F0, $D7, $21
    db   $50, $C2, $09, $96, $34, $34, $E6, $80
    db   $28, $04, $35, $35, $35, $35, $F0, $D8
    db   $21, $40, $C2, $09, $96, $34, $34, $E6
    db   $80, $28, $04, $35, $35, $35, $35, $F1
    db   $E0, $99, $F1, $E0, $98, $CD, $91, $08
    db   $36, $10, $CD, $94, $6D, $21, $40, $C2
    db   $09, $7E, $A7, $28, $08, $07, $E6, $01
    db   $21, $80, $C3, $09, $77, $21, $B0, $C3
    db   $36, $05, $CD, $91, $08, $28, $0B, $F0
    db   $E7, $E6, $30, $28, $05, $21, $B0, $C3
    db   $36, $07, $F0, $EC, $FE, $2C, $30, $18
    db   $F0, $EE, $FE, $74, $38, $12, $CD, $8D
    db   $3B, $21, $40, $C2, $09, $36, $05, $21
    db   $50, $C2, $09, $36, $F0, $C3, $B6, $62
    db   $F0, $EE, $FE, $03, $30, $0D, $21, $90
    db   $C2, $36, $03, $3E, $49, $CD, $97, $21
    db   $C3, $44, $6D, $C9, $21, $B0, $C3, $36
    db   $01, $CD, $94, $6D, $21, $50, $C2, $09
    db   $34, $00, $7E, $FE, $0C, $20, $66, $21
    db   $90, $C2, $36, $03, $79, $FE, $0F, $20
    db   $41, $F0, $F8, $E6, $10, $20, $3B, $3E
    db   $01, $E0, $F2, $F0, $F6, $5F, $16, $01
    db   $21, $00, $D9, $19, $7E, $F6, $10, $77
    db   $E0, $F8, $FA, $5C, $DB, $3C, $EA, $5C
    db   $DB, $FE, $04, $20, $11, $AF, $EA, $5C
    db   $DB, $21, $93, $DB, $36, $40, $21, $5B
    db   $DB, $34, $3E, $FF, $18, $02, $3E, $FE
    db   $CD, $85, $21, $21, $90, $DB, $36, $20
    db   $18, $18, $21, $B0, $C2, $09, $7E, $FE
    db   $03, $1E, $14, $3E, $4A, $28, $04, $1E
    db   $05, $3E, $4D, $21, $90, $DB, $73, $CD
    db   $97, $21, $CD, $44, $6D, $C9, $44, $00
    db   $42, $00, $44, $00, $46, $00, $40, $00
    db   $42, $00, $40, $00, $46, $00, $42, $20
    db   $44, $20, $46, $20, $44, $20, $42, $20
    db   $40, $20, $46, $20, $40, $20

JumpTable_66E7_04:
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   nz, .else_04_66F5

    ld   a, [$FFF1]
    add  a, $04
    ld   [$FFF1], a
.else_04_66F5:
    ld   de, $66C7
    call toc_01_3C3B
    jp   JumpTable_63FC_04.toc_04_6410

    db   $CD, $91, $08, $20, $0D, $36, $18, $21
    db   $80, $C3, $09, $7E, $EE, $01, $77, $CD
    db   $8D, $3B, $F0, $E7, $E6, $03, $20, $0F
    db   $21, $40, $C2, $09, $7E, $A7, $28, $07
    db   $E6, $80, $28, $02, $34, $34, $35, $C9
    db   $08, $F8, $CD, $91, $08, $20, $06, $36
    db   $50, $CD, $8D, $3B, $70, $F0, $E7, $1F
    db   $1F, $1F, $E6, $01, $CD, $87, $3B, $F0
    db   $E7, $E6, $03, $20, $1D, $21, $40, $C2
    db   $09, $7E, $E5, $21, $80, $C3, $09, $5E
    db   $16, $00, $21, $26, $67, $19, $96, $E1
    db   $A7, $28, $07, $E6, $80, $28, $02, $34
    db   $34, $35, $C9, $FA, $02, $D0, $A7, $20
    db   $59, $FA, $03, $D0, $5F, $50, $21, $80
    db   $C2, $19, $7E, $A7, $28, $4C, $21, $90
    db   $C2, $19, $7E, $A7, $28, $44, $FA, $00
    db   $D0, $21, $EE, $FF, $96, $07, $07, $E6
    db   $01, $21, $80, $C3, $09, $BE, $20, $32
    db   $FA, $00, $D0, $21, $EE, $FF, $96, $C6
    db   $18, $FE, $30, $30, $25, $FA, $01, $D0
    db   $21, $EF, $FF, $96, $C6, $10, $FE, $20
    db   $30, $18, $CD, $8D, $3B, $36, $02, $21
    db   $02, $D0, $34, $21, $04, $D0, $34, $CD
    db   $91, $08, $CD, $ED, $27, $E6, $3F, $C6
    db   $30, $77, $C9

toc_04_67C1:
    call toc_01_090F
    ld   a, [hLinkPositionX]
    swap a
    and  %00001111
    ld   e, a
    ld   a, [hLinkPositionY]
    sub  a, 8
    and  %11110000
    or   e
    ld   [$D416], a
    ret


    db   $4C, $00, $4C, $20, $4E, $00, $4E, $20
    db   $7C, $00, $7C, $20, $7E, $00, $7E, $20
    db   $21, $5E, $D4, $34, $11, $D6, $67, $F0
    db   $F7, $FE, $01, $20, $03, $11, $DE, $67
    db   $CD, $3B, $3C, $CD, $1F, $7F, $CD, $EB
    db   $3B, $F0, $F0, $C7

    dw JumpTable_680A_04 ; 00
    dw JumpTable_68C0_04 ; 01

    db   $00, $03, $01, $02

JumpTable_680A_04:
    call toc_01_0887
    jr   nz, .else_04_6815

    ld   [hl], $10
    call JumpTable_3B8D_00
    ret


.else_04_6815:
    ld   a, [$C11C]
    cp   $00
    jp   nz, .else_04_68A7

    ld   a, [hLinkPositionXIncrement]
    push af
    ld   a, [hLinkPositionYIncrement]
    push af
    ld   e, $00
    ld   a, [$FFEB]
    cp   $52
    ld   a, $14
    jr   nz, .else_04_6830

    inc  e
    ld   a, $08
.else_04_6830:
    push de
    call toc_01_3C30
    pop  de
    ld   a, [$FFD7]
    bit  0, e
    jr   z, .else_04_683D

    cpl
    inc  a
.else_04_683D:
    ld   [hLinkPositionYIncrement], a
    ld   a, [$FFD8]
    bit  0, e
    jr   z, .else_04_6847

    cpl
    inc  a
.else_04_6847:
    ld   [hLinkPositionXIncrement], a
    push bc
    call toc_01_20D6
    call toc_01_3E49
    pop  bc
    pop  af
    ld   [hLinkPositionYIncrement], a
    pop  af
    ld   [hLinkPositionXIncrement], a
    clear [$C144]
    ld   a, [$FFEB]
    cp   $52
    jp   nz, .else_04_68A7

    _ifZero [$C146], .else_04_6897

    call toc_04_6DFF
    add  a, $04
    cp   $08
    jr   nc, .else_04_6897

    call toc_04_6E0F
    add  a, $04
    cp   $08
    jr   nc, .else_04_6897

    copyFromTo [$FFEE], [hLinkPositionX]
    copyFromTo [$FFEC], [hLinkPositionY]
    assign [$C11C], $06
    call toc_01_093B
    ld   [$C198], a
    assign [$DBCB], $FF
    assign [$FFF3], $0C
    ret


.else_04_6897:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $6806
    add  hl, de
    ld   a, [hl]
    ld   [hLinkDirection], a
.else_04_68A7:
    call toc_04_68D0
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ld   a, [hFrameCounter]
    and  %00011111
    jr   nz, .return_04_68BF

    assign [$FFF4], $1F
.return_04_68BF:
    ret


JumpTable_68C0_04:
    call toc_01_0887
    jr   nz, .else_04_68CB

    ld   [hl], $40
    call JumpTable_3B8D_00
    ld   [hl], b
.else_04_68CB:
    ld   a, $00
    jp   toc_01_3B87

toc_04_68D0:
    ld   e, $0F
    ld   d, b
.loop_04_68D3:
    push de
    ld   a, e
    cp   c
    jp   z, .else_04_6968

    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jp   z, .else_04_6968

    call toc_01_3DBA
    push bc
    push de
    pop  bc
    ld   a, [hFrameCounter]
    xor  c
    and  %00000001
    jr   nz, .else_04_6967

    ld   a, [hLinkPositionX]
    push af
    ld   a, [hLinkPositionY]
    push af
    copyFromTo [$FFEE], [hLinkPositionX]
    copyFromTo [$FFEF], [hLinkPositionY]
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    push af
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    push af
    ld   a, $10
    call toc_01_3C30
    ld   e, $00
    ifNe [$FFEB], $52, .else_04_6917

    inc  e
.else_04_6917:
    ld   a, [$FFD7]
    bit  0, e
    jr   nz, .else_04_691F

    cpl
    inc  a
.else_04_691F:
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ld   a, [$FFD8]
    bit  0, e
    jr   nz, .else_04_692C

    cpl
    inc  a
.else_04_692C:
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    call toc_01_3DBA
    call toc_04_6D94
    call toc_01_3B9E
    ld   a, [$FFEE]
    ld   hl, hLinkPositionX
    sub  a, [hl]
    add  a, $02
    cp   $04
    jr   nc, .else_04_6955

    ld   a, [$FFEC]
    ld   hl, hLinkPositionY
    sub  a, [hl]
    add  a, 2
    cp   4
    jr   nc, .else_04_6955

    call toc_04_6D44
.else_04_6955:
    pop  af
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    pop  af
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    pop  af
    ld   [hLinkPositionY], a
    pop  af
    ld   [hLinkPositionX], a
.else_04_6967:
    pop  bc
.else_04_6968:
    pop  de
    dec  e
    ld   a, e
    cp   $FF
    jp   nz, .loop_04_68D3

    ret


    db   $F0, $F7, $FE, $14, $38, $15, $F0, $F8
    db   $E6, $10, $C2, $44, $6D, $21, $60, $C4
    db   $09, $36, $FF, $21, $E0, $C4, $09, $36
    db   $3C, $18, $0C, $5F, $50, $21, $65, $DB
    db   $19, $7E, $E6, $01, $C2, $44, $6D, $CD
    db   $8B, $6A, $CD, $BA, $3D, $CD, $1F, $7F
    db   $CD, $4A, $6D, $21, $30, $C4, $09, $36
    db   $00, $CD, $B4, $3B, $F0, $F0, $C7

    dw JumpTable_69B6_04 ; 00
    dw JumpTable_6A01_04 ; 01
    dw JumpTable_6A2E_04 ; 02

JumpTable_69B6_04:
    call toc_01_0891
    jr   nz, .else_04_69E8

    ld   a, [hFrameCounter]
    xor  c
    and  %00000111
    jr   nz, .else_04_69C7

    ld   a, $04
    call toc_01_3C25
.else_04_69C7:
    call toc_04_6D94
    call toc_01_3B9E
    call toc_04_6DFF
    add  a, $30
    cp   $60
    jr   nc, .else_04_69E8

    call toc_04_6E0F
    add  a, $30
    cp   $60
    jr   nc, .else_04_69E8

    call toc_01_0891
    ld   [hl], $28
    call JumpTable_3B8D_00
.return_04_69E7:
    ret


.else_04_69E8:
    ld   a, [hFrameCounter]
    and  %00000001
    jr   nz, .return_04_69E7

.toc_04_69EE:
    ld   hl, $C3D0
    add  hl, bc
    inc  [hl]
    ld   a, [hl]
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


    db   $04, $0C, $00, $08

JumpTable_6A01_04:
    call toc_01_0891
    jr   nz, .else_04_6A2B

    call toc_04_6E1F
    ld   hl, $C380
    add  hl, bc
    ld   [hl], e
    ld   d, b
    ld   hl, $C3D0
    add  hl, bc
    ld   a, [hl]
    and  %00001111
    ld   hl, $69FD
    add  hl, de
    cp   [hl]
    jr   nz, .else_04_6A2B

    ld   hl, $C2B0
    add  hl, bc
    ld   [hl], $38
    ld   hl, $C440
    add  hl, bc
    ld   [hl], b
    call JumpTable_3B8D_00
.else_04_6A2B:
    jp   JumpTable_69B6_04.toc_04_69EE

JumpTable_6A2E_04:
    call toc_04_6DE7
    ld   hl, $C2B0
    add  hl, bc
    dec  [hl]
    dec  [hl]
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .else_04_6A42

    ld   hl, $C440
    add  hl, bc
    inc  [hl]
.else_04_6A42:
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_6A4E

    and  %10000000
    jr   z, .return_04_6A6A

.else_04_6A4E:
    ld   [hl], b
    call JumpTable_3B8D_00
    ld   [hl], b
    call toc_01_0891
    ld   [hl], $10
    ld   hl, $C380
    add  hl, bc
    ld   e, [hl]
    ld   d, b
    ld   hl, $69FD
    add  hl, de
    ld   a, [hl]
    add  a, $08
    ld   hl, $C3D0
    add  hl, bc
    ld   [hl], a
.return_04_6A6A:
    ret


    db   $70, $00, $72, $00, $74, $00, $76, $00
    db   $78, $00, $78, $20, $0A, $06, $03, $01
    db   $00, $01, $03, $06, $0A, $0E, $11, $13
    db   $14, $13, $11, $0E, $0A, $06, $03, $01
    db   $11, $6B, $6A, $CD, $3B, $3C, $21, $D0
    db   $C2, $09, $7E, $A7, $28, $5C, $AF, $E0
    db   $D7, $21, $80, $C3, $09, $7E, $21, $D0
    db   $C2, $09, $CB, $4F, $20, $26, $FE, $01
    db   $7E, $20, $06, $21, $D7, $FF, $34, $2F
    db   $3C, $21, $EE, $FF, $86, $77, $21, $40
    db   $C4, $09, $F0, $D7, $A7, $7E, $28, $03
    db   $2F, $E6, $0F, $21, $EC, $FF, $86, $C6
    db   $F3, $77, $18, $46, $FE, $02, $7E, $20
    db   $06, $21, $D7, $FF, $34, $2F, $3C, $21
    db   $EC, $FF, $86, $77, $21, $40, $C4, $09
    db   $F0, $D7, $A7, $7E, $20, $03, $2F, $E6
    db   $0F, $21, $EE, $FF, $86, $C6, $F8, $77
    db   $18, $20, $21, $D0, $C3, $09, $7E, $E6
    db   $0F, $5F, $16, $00, $21, $77, $6A, $19
    db   $F0, $EC, $86, $C6, $F0, $E0, $EC, $21
    db   $7B, $6A, $19, $F0, $EE, $86, $C6, $F3
    db   $E0, $EE, $3E, $02, $E0, $F1, $11, $6B
    db   $6A, $CD, $3B, $3C, $21, $40, $C4, $09
    db   $7E, $A7, $CA, $A7, $6B, $21, $B0, $C2
    db   $09, $7E, $E6, $80, $20, $11, $CD, $8C
    db   $08, $20, $0C, $21, $30, $C4, $09, $36
    db   $40, $CD, $B4, $3B, $CD, $A8, $6B, $F0
    db   $EE, $C6, $04, $21, $00, $C2, $09, $96
    db   $CB, $2F, $CB, $2F, $E0, $D7, $E0, $D9
    db   $F0, $EC, $21, $10, $C2, $09, $96, $CB
    db   $2F, $CB, $2F, $E0, $D8, $E0, $DA, $FA
    db   $C0, $C3, $5F, $16, $00, $21, $30, $C0
    db   $19, $E5, $D1, $CD, $BA, $3D, $3E, $03
    db   $E0, $DB, $F0, $EC, $21, $D8, $FF, $86
    db   $12, $13, $F0, $EE, $21, $D7, $FF, $86
    db   $12, $13, $3E, $24, $12, $13, $3E, $00
    db   $12, $13, $F0, $D7, $21, $D9, $FF, $86
    db   $E0, $D7, $F0, $D8, $21, $DA, $FF, $86
    db   $E0, $D8, $F0, $DB, $3D, $20, $D1, $3E
    db   $03, $CD, $D0, $3D, $C9, $F0, $EE, $E0
    db   $DB, $CB, $37, $E6, $0F, $5F, $F0, $EC
    db   $D6, $10, $C6, $04, $E0, $DC, $E6, $F0
    db   $B3, $5F, $16, $00, $21, $11, $D7, $7C
    db   $19, $67, $7E, $E0, $AF, $5F, $FA, $A5
    db   $DB, $57, $CD, $DB, $29, $FE, $00, $28
    db   $22, $FE, $01, $20, $1E, $21, $B0, $C2
    db   $09, $7E, $2F, $3C, $77, $CD, $8C, $08
    db   $36, $08, $3E, $07, $E0, $F2, $F0, $EE
    db   $E0, $D7, $F0, $EC, $E0, $D8, $3E, $05
    db   $CD, $53, $09, $C9, $70, $00, $70, $20
    db   $78, $00, $7A, $00, $74, $00, $76, $00
    db   $7C, $00, $7E, $00, $72, $00, $72, $20
    db   $7E, $20, $7C, $20, $76, $20, $74, $20
    db   $7A, $20, $78, $20, $10, $0E, $0C, $06
    db   $00, $FA, $F4, $F2, $F0, $F2, $F4, $FA
    db   $00, $06, $0C, $0E, $10, $0E, $0C, $06
    db   $F0, $F0, $A7, $C2, $D9, $6C, $11, $F7
    db   $6B, $CD, $3B, $3C, $CD, $1F, $7F, $CD
    db   $BF, $3B, $CD, $9E, $3B, $CD, $91, $08
    db   $28, $39, $FE, $10, $20, $34, $3E, $2B
    db   $CD, $01, $3C, $38, $2D, $3E, $08, $E0
    db   $F4, $F0, $D7, $21, $00, $C2, $19, $77
    db   $F0, $D8, $21, $10, $C2, $19, $77, $F0
    db   $D9, $21, $80, $C3, $19, $77, $21, $40
    db   $C2, $09, $7E, $21, $40, $C2, $19, $77
    db   $21, $50, $C2, $09, $7E, $21, $50, $C2
    db   $19, $77, $C9, $21, $D0, $C3, $09, $7E
    db   $3C, $77, $E6, $07, $20, $4F, $21, $80
    db   $C3, $09, $7E, $3C, $E6, $0F, $77, $CB
    db   $3F, $21, $B0, $C3, $09, $77, $3E, $2A
    db   $CD, $01, $3C, $38, $38, $F0, $D7, $21
    db   $00, $C2, $19, $77, $F0, $D8, $21, $10
    db   $C2, $19, $77, $21, $90, $C2, $19, $36
    db   $01, $21, $B0, $C2, $19, $71, $21, $40
    db   $C3, $19, $36, $C0, $C5, $F0, $D9, $4F
    db   $21, $1B, $6C, $09, $7E, $21, $40, $C2
    db   $19, $77, $21, $17, $6C, $09, $7E, $21
    db   $50, $C2, $19, $77, $C1, $C9, $CD, $A9
    db   $3B, $21, $A0, $C2, $09, $7E, $A7, $C2
    db   $44, $6D, $F0, $EE, $21, $98, $FF, $96
    db   $C6, $10, $FE, $20, $30, $35, $F0, $EF
    db   $21, $99, $FF, $96, $C6, $10, $FE, $20
    db   $30, $29, $CD, $44, $6D, $FA, $C7, $DB
    db   $A7, $20, $20, $21, $B0, $C2, $09, $5E
    db   $50, $21, $E0, $C2, $19, $7E, $A7, $20
    db   $12, $36, $20, $21, $20, $C4, $19, $36
    db   $10, $C5, $D5, $C1, $3E, $40, $CD, $25
    db   $3C, $C1, $C9, $21, $40, $C2, $09, $7E
    db   $21, $00, $C2, $09, $86, $77, $FE, $9C
    db   $D2, $44, $6D, $21, $50, $C2, $09, $7E
    db   $21, $10, $C2, $09, $86, $77, $FE, $78
    db   $D8

toc_04_6D44:
    ld   hl, $C280
    add  hl, bc
    ld   [hl], b
    ret


toc_04_6D4A:
    ld   hl, $C410
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_04_6D93

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
    call toc_04_6D94
    ld   hl, $C430
    add  hl, bc
    ld   a, [hl]
    and  %00100000
    jr   nz, .else_04_6D86

    call toc_01_3B9E
.else_04_6D86:
    ld   hl, $C250
    add  hl, bc
    pop  af
    ld   [hl], a
    ld   hl, $C240
    add  hl, bc
    pop  af
    ld   [hl], a
    pop  af
.return_04_6D93:
    ret


toc_04_6D94:
    call toc_04_6DA1
    push bc
    ld   a, c
    add  a, $10
    ld   c, a
    call toc_04_6DA1
    pop  bc
    ret


toc_04_6DA1:
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_04_6DCC

    push af
    swap a
    and  %11110000
    ld   hl, $C260
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, $C200
.toc_04_6DB9:
    add  hl, bc
    pop  af
    ld   e, $00
    bit  7, a
    jr   z, .else_04_6DC3

    ld   e, $F0
.else_04_6DC3:
    swap a
    and  %00001111
    or   e
    rr   d
    adc  [hl]
    ld   [hl], a
.return_04_6DCC:
    ret


toc_04_6DCD:
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, toc_04_6DA1.return_04_6DCC

    push af
    swap a
    and  %11110000
    ld   hl, $C330
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, $C310
    jr   toc_04_6DA1.toc_04_6DB9

toc_04_6DE7:
    ld   hl, $C2B0
    add  hl, bc
    ld   a, [hl]
    push af
    swap a
    and  %11110000
    ld   hl, $C2C0
    add  hl, bc
    add  a, [hl]
    ld   [hl], a
    rl   d
    ld   hl, $C2D0
    jp   toc_04_6DA1.toc_04_6DB9

toc_04_6DFF:
    ld   e, $00
    ld   a, [hLinkPositionX]
    ld   hl, $C200
    add  hl, bc
    sub  a, [hl]
    bit  7, a
    jr   z, .else_04_6E0D

    inc  e
.else_04_6E0D:
    ld   d, a
    ret


toc_04_6E0F:
    ld   e, $02
    ld   a, [hLinkPositionY]
    ld   hl, $C210
    add  hl, bc
    sub  a, [hl]
    bit  7, a
    jr   nz, .else_04_6E1D

    inc  e
.else_04_6E1D:
    ld   d, a
    ret


toc_04_6E1F:
    call toc_04_6DFF
    ld   a, e
    ld   [$FFD7], a
    ld   a, d
    bit  7, a
    jr   z, .else_04_6E2C

    cpl
    inc  a
.else_04_6E2C:
    push af
    call toc_04_6E0F
    ld   a, e
    ld   [$FFD8], a
    ld   a, d
    bit  7, a
    jr   z, .else_04_6E3A

    cpl
    inc  a
.else_04_6E3A:
    pop  de
    cp   d
    jr   nc, .else_04_6E42

    ld   a, [$FFD7]
    jr   .toc_04_6E44

.else_04_6E42:
    ld   a, [$FFD8]
.toc_04_6E44:
    ld   e, a
    ret


    db   $FA, $73, $DB, $F5, $F0, $F8, $E6, $10
    db   $28, $04, $AF, $EA, $73, $DB, $CD, $5C
    db   $6E, $F1, $EA, $73, $DB, $C9, $21, $B0
    db   $C2, $09, $7E, $A7, $C2, $37, $74, $79
    db   $EA, $10, $D2, $3E, $02, $EA, $0A, $C5
    db   $CD, $8C, $08, $3D, $20, $04, $3E, $19
    db   $E0, $F2, $F0, $F1, $3C, $28, $17, $F0
    db   $E7, $E6, $1F, $20, $08, $CD, $1F, $6E
    db   $21, $80, $C3, $09, $73, $CD, $09, $7C
    db   $11, $59, $76, $CD, $3B, $3C, $CD, $6E
    db   $73, $CD, $BA, $3D, $CD, $54, $7B, $CD
    db   $27, $73, $F0, $F0, $FE, $03, $38, $0D
    db   $FA, $73, $DB, $A7, $28, $07, $3E, $02
    db   $E0, $A1, $EA, $67, $C1, $F0, $F0, $C7

    dw JumpTable_6EEE_04 ; 00
    dw JumpTable_6F69_04 ; 01
    dw JumpTable_6FC6_04 ; 02
    dw JumpTable_7026_04 ; 03
    dw JumpTable_70A4_04 ; 04
    dw JumpTable_70FE_04 ; 05
    dw JumpTable_7124_04 ; 06
    dw JumpTable_7163_04 ; 07
    dw JumpTable_71AD_04 ; 08
    dw JumpTable_71E3_04 ; 09
    dw JumpTable_7200_04 ; 0A
    dw JumpTable_725C_04 ; 0B
    dw JumpTable_729E_04 ; 0C

    db   $38, $58, $78, $58, $40, $70, $2E, $2E
    db   $2E, $3E, $4E, $4E, $00, $00, $00, $04
    db   $01, $02, $05, $02, $02, $00, $03, $04
    db   $81, $81, $81, $82, $81, $81

JumpTable_6EEE_04:
    ld   e, $06
    ld   d, $00
.loop_04_6EF2:
    push de
    ld   a, $4F
    ld   e, $0E
    call toc_01_3C13
    ld   hl, $C2B0
    add  hl, de
    ld   [hl], $01
    ld   hl, $6EC7
    add  hl, de
    ld   a, [hl]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   hl, $6ECD
    add  hl, de
    ld   a, [hl]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $6ED9
    add  hl, de
    ld   a, [hl]
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], a
    ld   hl, $6EDF
    add  hl, de
    ld   a, [hl]
    ld   hl, $C340
    add  hl, de
    ld   [hl], a
    ld   hl, $6ED3
    add  hl, de
    ld   a, [hl]
    ld   hl, $C380
    add  hl, de
    ld   [hl], a
    push bc
    push de
    pop  bc
    call toc_04_7614
    pop  bc
    pop  de
    dec  e
    jr   nz, .loop_04_6EF2

    clear [$D206]
    assign [$D202], $10
    ld   [$D203], a
    assign [$D205], $16
    assign [$D204], $18
    assign [$D200], $00
    assign [$D201], $04
    call JumpTable_3B8D_00
    ld   a, [$DB0E]
    ld   hl, $C390
    add  hl, bc
    ld   [hl], a
    ret


JumpTable_6F69_04:
    ld   a, [$C167]
    and  a
    ret  nz

    ifNotZero [$DB73], .else_04_6F85

    ifLt [hLinkPositionX], 108, .else_04_6F85

    ld   hl, $DAA0
    set  4, [hl]
    assign [hLinkPositionX], 107
    jr   .toc_04_6F8A

.else_04_6F85:
    call toc_04_7B77
    jr   nc, .return_04_6FC5

.toc_04_6F8A:
    clear [$C120]
    ld   [hLinkPositionXIncrement], a
    ld   e, $06
    ld   hl, $C390
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .else_04_6F9B

    dec  e
.else_04_6F9B:
    ld   hl, $C440
    add  hl, bc
    ld   a, [hl]
    cp   e
    jr   c, .else_04_6FA9

    ld   a, $40
    call toc_01_2197
    ret


.else_04_6FA9:
    ifNotZero [$DB73], .else_04_6FB3

    ld   a, $F7
    jr   .else_04_6FBF

.else_04_6FB3:
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    and  a
    ld   a, $3B
    jr   z, .else_04_6FBF

    ld   a, $3E
.else_04_6FBF:
    call toc_01_2197
    call JumpTable_3B8D_00
.return_04_6FC5:
    ret


JumpTable_6FC6_04:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    _ifZero [wDialogState], .return_04_7002

    ifEq [$C173], $F8, .else_04_6FDE

    ifGte [$C177], $01, .else_04_6FF1

.else_04_6FDE:
    ld   a, [$DB5E]
    sub  a, $10
    ld   a, [$DB5D]
    sbc  $00
    jr   nc, .else_04_7003

    ld   a, $34
    call toc_01_2197
    jr   .else_04_6FFC

.else_04_6FF1:
    ifNotZero [$DB73], .else_04_6FFC

    ld   a, $F8
    jp   toc_01_2197

.else_04_6FFC:
    ld   hl, $C290
    add  hl, bc
    ld   [hl], $01
.return_04_7002:
    ret


.else_04_7003:
    ifNotZero [$DB73], .else_04_700C

    ld   [$DB74], a
.else_04_700C:
    ld   hl, $C2D0
    add  hl, bc
    ld   a, [hl]
    ld   [hl], $01
    and  a
    ld   a, $3C
    jr   z, .else_04_701A

    ld   a, $3F
.else_04_701A:
    call toc_01_2197
    assign [$DB92], $0A
    call JumpTable_3B8D_00
    ret


JumpTable_7026_04:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    ld   [$D200], a
    assign [$D203], $10
    ld   a, [hFrameCounter]
    and  %00010000
    ld   [$D202], a
    ifNotZero [$DB73], .else_04_708C

    call toc_01_0887
    jr   z, .else_04_704F

    dec  a
    jr   nz, .return_04_704E

    call .toc_04_709C
.return_04_704E:
    ret


.else_04_704F:
    call toc_04_7F1F
    push bc
    ld   a, [$C50F]
    ld   c, a
    ld   a, [hFrameCounter]
    and  %00010000
    ld   a, $04
    jr   z, .else_04_7060

    inc  a
.else_04_7060:
    call toc_01_3B87
    ld   hl, $C240
    add  hl, bc
    ld   [hl], $F8
    call toc_04_6DA1
    ld   hl, $C200
    add  hl, bc
    pop  bc
    ld   a, [hl]
    cp   $28
    jr   nz, .return_04_708B

    call toc_01_0887
    ld   [hl], $18
    ld   a, [$C50F]
    ld   e, a
    ld   d, b
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], $02
    ld   e, $01
    call JumpTable_7163_04.toc_04_719F
.return_04_708B:
    ret


.else_04_708C:
    ld   a, [hPressedButtonsMask]
    and  J_B
    jr   z, .return_04_70A3

    ifLt [hLinkPositionX], 32, .return_04_70A3

    cp   48
    jr   nc, .return_04_70A3

.toc_04_709C:
    call JumpTable_3B8D_00
.toc_04_709F:
    assign [$FFF4], $20
.return_04_70A3:
    ret


JumpTable_70A4_04:
    call toc_04_70EA
    assign [$D203], $10
    ld   a, [hFrameCounter]
    and  %00010000
    ld   [$D202], a
    ifNotZero [$DB73], .else_04_70C0

    ld   e, $02
    call JumpTable_7163_04.toc_04_719F
    jr   .toc_04_70C6

.else_04_70C0:
    ld   a, [hPressedButtonsMask]
    and  J_B
    jr   z, .else_04_70D7

.toc_04_70C6:
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .return_04_70E9

    ld   a, [$D204]
    inc  a
    ld   [$D204], a
    cp   $88
    jr   c, .return_04_70E9

.else_04_70D7:
    call JumpTable_3B8D_00
    ifNotZero [$DB73], .else_04_70E5

    call toc_01_0887
    ld   [hl], $10
.else_04_70E5:
    assign [$FFF4], $21
.return_04_70E9:
    ret


toc_04_70EA:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    ld   [$D200], a
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_GRAB_SLASH
    assign [hLinkDirection], DIRECTION_UP
    ret


JumpTable_70FE_04:
    call toc_04_70EA
    assign [$D202], $10
    ld   a, [hFrameCounter]
    and  %00010000
    ld   [$D203], a
    call toc_01_0887
    ret  nz

    _ifZero [$DB73], .else_04_711D

    ld   a, [hPressedButtonsMask]
    and  J_A
    jr   z, .return_04_7123

.else_04_711D:
    call JumpTable_7026_04.toc_04_709F
    call JumpTable_3B8D_00
.return_04_7123:
    ret


JumpTable_7124_04:
    call toc_04_70EA
    assign [$D202], $10
    ld   a, [hFrameCounter]
    and  %00010000
    ld   [$D203], a
    ifNotZero [$DB73], .else_04_713B

    jr   .toc_04_7141

.else_04_713B:
    ld   a, [hPressedButtonsMask]
    and  J_A
    jr   z, .else_04_7152

.toc_04_7141:
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .return_04_7162

    ld   a, [$D205]
    inc  a
    ld   [$D205], a
    cp   $55
    jr   c, .return_04_7162

.else_04_7152:
    call JumpTable_3B8D_00
    call JumpTable_70A4_04.else_04_70E5
    call toc_01_0891
    ld   [hl], $60
    ld   e, $00
    call JumpTable_7163_04.toc_04_719F
.return_04_7162:
    ret


JumpTable_7163_04:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    ld   [$D200], a
    assign [$D202], $10
    ld   [$D203], a
    call toc_01_0891
    cp   $30
    jr   nc, .else_04_7181

    ld   hl, $D201
    ld   [hl], $02
.else_04_7181:
    and  a
    jr   nz, .return_04_71AC

    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .return_04_71AC

    ld   a, [$D206]
    inc  a
    ld   [$D206], a
    cp   $0F
    jr   nz, .return_04_71AC

    call toc_01_0891
    ld   [hl], $FF
    call JumpTable_3B8D_00
    ld   e, DIRECTION_RIGHT
.toc_04_719F:
    ld   a, [$DB73]
    and  a
    ret  z

    ld   a, e
    ld   [hLinkDirection], a
    push bc
    call toc_01_087C
    pop  bc
.return_04_71AC:
    ret


JumpTable_71AD_04:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    ld   [$D200], a
    call toc_01_0891
    cp   200
    jr   nz, .else_04_71C3

    ld   hl, $D206
    ld   [hl], $10
.else_04_71C3:
    cp   160
    jr   nz, .else_04_71CC

    ld   hl, $D201
    ld   [hl], $03
.else_04_71CC:
    cp   80
    jr   nz, .else_04_71D9

    ld   hl, $D201
    ld   [hl], $04
    call toc_04_72A2
    ret


.else_04_71D9:
    and  a
    jr   nz, .return_04_71E2

    call JumpTable_3B8D_00
    call JumpTable_7026_04.toc_04_709F
.return_04_71E2:
    ret


JumpTable_71E3_04:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    ld   [$D200], a
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .return_04_71FF

    ld   a, [$D206]
    dec  a
    ld   [$D206], a
    jr   nz, .return_04_71FF

    call JumpTable_3B8D_00
.return_04_71FF:
    ret


JumpTable_7200_04:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    ld   [$D200], a
    ld   a, [hLinkPositionX]
    push af
    ld   a, [hLinkPositionY]
    push af
    assign [hLinkPositionY], 22
    assign [hLinkPositionX], 24
    copyFromTo [$D204], [$C201]
    copyFromTo [$D205], [$C211]
    push bc
    ld   c, $01
    ld   a, $04
    call toc_01_3C25
    call toc_04_6D94
    copyFromTo [$C201], [$D204]
    copyFromTo [$C211], [$D205]
    pop  bc
    pop  af
    ld   [hLinkPositionY], a
    pop  af
    ld   [hLinkPositionX], a
    ifNe [$D204], $18, .return_04_725B

    ifNe [$D205], $16, .return_04_725B

    call toc_01_0891
    ld   [hl], $C0
    call JumpTable_3B8D_00
    call JumpTable_70A4_04.else_04_70E5
.return_04_725B:
    ret


JumpTable_725C_04:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    and  %00000001
    ld   [$D200], a
    call toc_01_0891
    cp   96
    jr   nz, .else_04_7292

    ld   hl, $D201
    ld   [hl], $02
    ld   hl, $C2C0
    add  hl, bc
    ld   a, [hl]
    and  a
    jr   z, .return_04_7291

    ld   [hl], $00
    dec  a
    ld   e, a
    ld   d, b
    ld   hl, $C290
    add  hl, de
    ld   [hl], $02
    ifNotZero [$DB73], .return_04_7291

    ld   hl, $C3B0
    add  hl, de
    ld   [hl], $07
.return_04_7291:
    ret


.else_04_7292:
    and  a
    jr   nz, .return_04_729D

    ld   hl, $D201
    ld   [hl], $04
    call JumpTable_3B8D_00
.return_04_729D:
    ret


JumpTable_729E_04:
    call JumpTable_6FC6_04.else_04_6FFC
    ret


toc_04_72A2:
    ifNotZero [$DB73], .else_04_72CF

    ld   a, $FF
    call toc_01_3B87
    ld   a, $4F
    call toc_01_3C01
    ld   a, [$D204]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$D205]
    add  a, $18
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C3B0
    add  hl, de
    ld   [hl], $06
    ld   hl, $C2B0
    add  hl, de
    inc  [hl]
.else_04_72CF:
    ld   e, $0F
    ld   d, b
.loop_04_72D2:
    ld   hl, $C280
    add  hl, de
    ld   a, [hl]
    and  a
    jr   z, .else_04_7320

    ld   hl, $C290
    add  hl, de
    ld   a, [hl]
    and  a
    jr   nz, .else_04_7320

    ld   hl, $C3A0
    add  hl, de
    ld   a, [hl]
    cp   $4F
    jr   nz, .else_04_7320

    ld   hl, $C200
    add  hl, de
    ld   a, [$D204]
    sub  a, [hl]
    add  a, $04
    cp   $08
    jr   nc, .else_04_7320

    ld   hl, $C210
    add  hl, de
    ld   a, [$D205]
    add  a, $18
    sub  a, [hl]
    add  a, $06
    cp   $0C
    jr   nc, .else_04_7320

    ld   hl, $C290
    add  hl, de
    ld   [hl], $01
    ld   a, e
    inc  a
    ld   hl, $C2C0
    add  hl, bc
    ld   [hl], a
    call toc_01_088C
    ld   [hl], $10
    incAddr $C440
    ret


.else_04_7320:
    dec  e
    ld   a, e
    cp   $FF
    jr   nz, .loop_04_72D2

    ret


    db   $21, $C0, $C2, $09, $7E, $A7, $28, $22
    db   $3D, $5F, $50, $FA, $04, $D2, $21, $00
    db   $C2, $19, $77, $FA, $05, $D2, $C6, $18
    db   $21, $10, $C2, $19, $77, $3E, $10, $21
    db   $06, $D2, $96, $C6, $FE, $21, $10, $C3
    db   $19, $77, $C9, $76, $00, $78, $00, $78
    db   $20, $76, $20, $70, $00, $70, $20, $72
    db   $00, $70, $20, $72, $00, $72, $20, $7E
    db   $00, $7E, $20, $26, $00, $26, $00, $FA
    db   $04, $D2, $E0, $EE, $FA, $05, $D2, $21
    db   $06, $D2, $86, $C6, $08, $E0, $EC, $FA
    db   $01, $D2, $E0, $F1, $11, $52, $73, $CD
    db   $3B, $3C, $FA, $04, $D2, $E0, $EE, $FA
    db   $05, $D2, $E0, $EC, $FA, $00, $D2, $E0
    db   $F1, $11, $52, $73, $CD, $3B, $3C, $FA
    db   $06, $D2, $FE, $08, $38, $16, $FA, $04
    db   $D2, $E0, $EE, $FA, $05, $D2, $C6, $10
    db   $E0, $EC, $3E, $05, $E0, $F1, $11, $52
    db   $73, $CD, $3B, $3C, $F0, $E7, $E6, $01
    db   $20, $26, $FA, $04, $D2, $E0, $EE, $FA
    db   $05, $D2, $C6, $20, $E0, $EC, $AF, $E0
    db   $F1, $11, $6A, $73, $FA, $C0, $C3, $F5
    db   $CD, $3B, $3C, $F1, $5F, $50, $21, $31
    db   $C0, $19, $34, $23, $23, $23, $23, $35
    db   $21, $20, $C0, $3E, $50, $22, $3E, $28
    db   $22, $3E, $7A, $22, $FA, $02, $D2, $22
    db   $3E, $60, $22, $3E, $28, $22, $3E, $3E
    db   $22, $FA, $02, $D2, $22, $3E, $50, $22
    db   $3E, $30, $22, $3E, $7C, $22, $FA, $03
    db   $D2, $22, $3E, $60, $22, $3E, $30, $22
    db   $3E, $3E, $22, $FA, $03, $D2, $22, $C9
    db   $FF, $FF, $9E, $10, $A6, $10, $8E, $10
    db   $86, $10, $A8, $10, $9A, $10, $9C, $10
    db   $6C, $00, $6E, $00, $6E, $20, $6C, $20
    db   $F0, $F1, $FE, $06, $38, $12, $11, $17
    db   $74, $FE, $07, $28, $09, $F0, $E7, $E6
    db   $10, $20, $03, $11, $1B, $74, $18, $1B
    db   $FE, $03, $20, $09, $FA, $4B, $DB, $A7
    db   $C2, $44, $6D, $18, $13, $FE, $00, $20
    db   $0F, $FA, $0E, $DB, $A7, $C2, $44, $6D
    db   $11, $2B, $74, $CD, $3B, $3C, $18, $06
    db   $11, $1F, $74, $CD, $D0, $3C, $CD, $1F
    db   $7F, $F0, $F0, $C7

    dw JumpTable_7487_04 ; 00
    dw JumpTable_74BA_04 ; 01
    dw JumpTable_74C5_04 ; 02
    dw JumpTable_751C_04 ; 03
    dw JumpTable_75E2_04 ; 04
    dw JumpTable_75F9_04 ; 05

JumpTable_7487_04:
    call toc_04_6D94
    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    jumptable
    db   $9A, $74, $A2, $74, $AA, $74, $B2, $74
    db   $A1, $74, $F0, $EE, $FE, $3A, $DA, $0B
    db   $76, $C9, $F0, $EC, $FE, $4E, $D2, $0B
    db   $76, $C9, $F0, $EE, $FE, $78, $D2, $0B
    db   $76, $C9, $F0, $EC, $FE, $2E, $DA, $0B
    db   $76, $C9

JumpTable_74BA_04:
    call toc_04_6E1F
    ld   a, e
    xor  %00000001
    ld   e, a
    call JumpTable_7163_04.toc_04_719F
    ret


JumpTable_74C5_04:
    ifNotZero [$DB73], .else_04_74CF

    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
.else_04_74CF:
    call toc_04_6DCD
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jr   z, .else_04_74F7

    xor  a
    ld   [hl], a
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    sra  a
    cpl
    ld   [hl], a
    cp   $07
    jr   nc, .else_04_74F3

    ld   [hl], b
    jr   .else_04_74F7

.else_04_74F3:
    assign [$FFF2], $09
.else_04_74F7:
    ld   a, [hFrameCounter]
    and  %00000011
    jr   nz, .return_04_7508

    ld   hl, $C210
    add  hl, bc
    ld   a, [hl]
    cp   $56
    jr   z, .else_04_7509

    inc  a
    ld   [hl], a
.return_04_7508:
    ret


.else_04_7509:
    add  a, $0A
    ld   [hl], a
    ld   hl, $C310
    add  hl, bc
    ld   [hl], $0A
    call JumpTable_3B8D_00
    ret


    db   $44, $43, $42, $41, $3D, $2A

JumpTable_751C_04:
    ifNotZero [$DB73], .else_04_7526

    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
.else_04_7526:
    call toc_04_6DCD
    ld   hl, $C320
    add  hl, bc
    dec  [hl]
    dec  [hl]
    ld   hl, $C310
    add  hl, bc
    ld   a, [hl]
    and  %10000000
    jp   z, .return_04_75E1

    xor  a
    ld   [hl], a
    ld   hl, $C320
    add  hl, bc
    ld   a, [hl]
    sra  a
    cpl
    ld   [hl], a
    cp   $07
    jr   nc, .else_04_754A

    xor  a
    ld   [hl], a
.else_04_754A:
    ifLt [$FFF1], $06, .else_04_7558

    ld   a, $F9
    call toc_01_2197
    jp   JumpTable_3B8D_00

.else_04_7558:
    ld   a, [$FFEE]
    ld   hl, hLinkPositionX
    sub  a, [hl]
    add  a, $07
    cp   $0E
    ret  nc

    ld   a, [$FFEC]
    ld   hl, hLinkPositionY
    sub  a, [hl]
    add  a, $05
    cp   $0A
    ret  nc

    ld   a, [$D210]
    ld   e, a
    ld   d, b
    ld   hl, $C480
    add  hl, de
    ld   a, [hl]
    and  a
    ret  nz

    ld   [hl], $18
    ifNe [$FFF1], $00, .else_04_758D

    assign [$DB0E], $01
    call toc_01_0898
    jp   toc_04_6D44

.else_04_758D:
    call toc_04_6D44
    ld   hl, $FFF3
    ld   [hl], $01
    ld   a, [$FFF1]
    ld   e, a
    ld   d, b
    ld   hl, $7516
    add  hl, de
    ld   a, [hl]
    call toc_01_2197
    ld   a, [$FFF1]
    dec  a
    jr   nz, .else_04_75A7

    ret


.else_04_75A7:
    dec  a
    jr   nz, .else_04_75B3

    ld   a, [$DB90]
    add  a, $1E
    ld   [$DB90], a
    ret


.else_04_75B3:
    dec  a
    jr   nz, .else_04_75D3

    ld   hl, $DB76
    ld   a, [$DB4C]
    cp   [hl]
    jr   nc, .else_04_75C6

    add  a, $10
    daa
    cp   [hl]
    jr   c, .else_04_75C6

    ld   a, [hl]
.else_04_75C6:
    ld   [$DB4C], a
    ld   d, $0C
    call toc_01_3E95
    assign [$FFA5], $0B
    ret


.else_04_75D3:
    dec  a
    jr   nz, .else_04_75DC

    ld   d, $04
    call toc_01_3E95
    ret


.else_04_75DC:
    assign [$DB93], $FF
.return_04_75E1:
    ret


JumpTable_75E2_04:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    ld   [$C167], a
    ld   a, [$C1AD]
    and  a
    ret  nz

    ld   [$DB74], a
    assign [$C1BC], $18
    jp   JumpTable_3B8D_00

JumpTable_75F9_04:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    ld   [$C167], a
    ret


    db   $FC, $00, $04, $00, $00, $00, $04, $00
    db   $FC, $00, $21, $80, $C3, $09, $7E, $3C
    db   $E6, $03, $77

toc_04_7614:
    ld   e, a
    ld   d, b
    ld   hl, $7601
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $7606
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    ret


    db   $F0, $E7, $E6, $1F, $20, $09, $CD, $1F
    db   $6E, $7B, $21, $80, $C3, $09, $77, $CD
    db   $09, $7C, $11, $59, $76, $CD, $3B, $3C
    db   $CD, $54, $7B, $CD, $BC, $7B, $30, $0D
    db   $FA, $7F, $D4, $FE, $03, $3E, $39, $38
    db   $01, $3C, $CD, $97, $21, $C9, $60, $00
    db   $62, $00, $62, $20, $60, $20, $64, $00
    db   $66, $00, $66, $20, $64, $20, $68, $00
    db   $6A, $00, $6C, $00, $6E, $00, $6A, $20
    db   $68, $20, $6E, $20, $6C, $20, $FA, $0A
    db   $C5, $A7, $20, $08, $3E, $01, $EA, $0A
    db   $C5, $CD, $0F, $78, $FA, $4E, $DB, $A7
    db   $28, $06, $F0, $E7, $E6, $5F, $20, $09
    db   $CD, $1F, $6E, $7B, $21, $80, $C3, $09
    db   $77, $CD, $09, $7C, $11, $59, $76, $CD
    db   $3B, $3C, $CD, $DE, $7A, $F0, $F0, $FE
    db   $04, $30, $03, $CD, $54, $7B, $F0, $F0
    db   $C7

    dw JumpTable_7786_04 ; 00
    dw JumpTable_7830_04 ; 01
    dw JumpTable_78E1_04 ; 02
    dw JumpTable_7A66_04 ; 03
    dw JumpTable_7A70_04 ; 04
    dw JumpTable_7AAB_04 ; 05
    dw JumpTable_6398_04 ; 06

    db   $02, $B2, $B0, $B0, $98, $A4, $01, $7F
    db   $7F, $98, $67, $02, $B1, $B0, $7F, $98
    db   $A8, $01, $0A, $B3, $98, $6A, $02, $7F
    db   $B2, $B0, $98, $AC, $01, $BA, $B1, $98
    db   $6E, $02, $B1, $B0, $7F, $98, $B0, $01
    db   $0A, $09, $98, $63, $02, $B9, $B8, $B0
    db   $98, $A4, $01, $7F, $7F, $98, $63, $02
    db   $B1, $B0, $7F, $98, $A4, $01, $0A, $09
    db   $00, $98, $62, $43, $7F, $98, $83, $42
    db   $7F, $98, $A3, $42, $7F, $00, $00, $00
    db   $00, $98, $66, $43, $7F, $98, $87, $42
    db   $7F, $98, $A7, $42, $7F, $00, $00, $00
    db   $00, $98, $6A, $43, $7F, $98, $8B, $42
    db   $7F, $98, $AB, $42, $7F, $00, $00, $00
    db   $00, $98, $6E, $43, $7F, $98, $8F, $42
    db   $7F, $98, $AF, $42, $7F, $00, $00, $00
    db   $00, $01, $02, $03, $00, $01, $02, $03
    db   $04, $05, $02, $03, $04, $06, $02, $03
    db   $04, $07, $08, $09, $0A, $30, $31, $32
    db   $33, $2C, $2D, $39, $00, $00, $00, $00
    db   $02, $00, $00, $00, $09, $00, $00, $00
    db   $00, $00, $10, $20, $10, $80, $10, $00
    db   $00, $00, $00, $00, $00, $00, $03, $00
    db   $00, $00, $00, $C8, $0A, $14, $0A, $D4
    db   $0A, $00, $00, $00

JumpTable_7786_04:
    ifNotZero [$DB46], .else_04_77C7

    ld   hl, $C210
    add  hl, bc
    ld   [hl], $40
    ld   hl, $C200
    add  hl, bc
    ld   [hl], $50
    ld   hl, $C380
    add  hl, bc
    ld   [hl], $03
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    ld   [$C167], a
    ifNe [$C16B], $04, .return_04_77C6

    ld   a, [hLinkPositionY]
    sub  a, 1
    ld   [hLinkPositionY], a
    cp   116
    jr   nz, .return_04_77C6

    ld   a, $38
    call toc_01_2197
    ld   hl, $C290
    add  hl, bc
    ld   [hl], $04
    assign [$D368], $19
.return_04_77C6:
    ret


.else_04_77C7:
    ld   e, $00
    ld   d, b
    ld   a, [$DB66]
    and  %00000010
    jr   z, .else_04_77D3

    ld   e, $04
.else_04_77D3:
    push bc
    ld   hl, $DB00
    ld   c, $0B
.loop_04_77D9:
    ldi  a, [hl]
    cp   $0B
    jr   nz, .else_04_77E0

    ld   e, $08
.else_04_77E0:
    dec  c
    ld   a, c
    cp   $FF
    jr   nz, .loop_04_77D9

    ld   hl, $DB00
    ld   c, $0B
.loop_04_77EB:
    ldi  a, [hl]
    cp   $05
    jr   nz, .else_04_77F2

    ld   e, $0C
.else_04_77F2:
    dec  c
    ld   a, c
    cp   $FF
    jr   nz, .loop_04_77EB

    ld   hl, $7743
    add  hl, de
    ld   de, $C505
    ld   c, $04
.loop_04_7801:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop_04_7801

    pop  bc
    call JumpTable_3B8D_00
    call toc_04_780F
    ret


toc_04_780F:
    ld   de, $D601
    push bc
    ld   hl, $C505
    ld   c, $04
.loop_04_7818:
    ldi  a, [hl]
    and  a
    jr   z, .else_04_7821

    push hl
    call toc_04_790F
    pop  hl
.else_04_7821:
    dec  c
    jr   nz, .loop_04_7818

    pop  bc
    ret


    db   $00, $00, $00, $01, $01, $02, $02, $03
    db   $03, $03

JumpTable_7830_04:
    ifNotZero [$C509], .else_04_7855

    ld   hl, $C380
    add  hl, bc
    ld   a, [hl]
    and  %00000001
    jr   z, .else_04_7855

    ifNe [$C11C], $00, .else_04_7855

    ifLt [hLinkPositionY], 123, .else_04_7855

    sub  a, 2
    ld   [hLinkPositionY], a
    ld   a, $2F
    jp   toc_01_2197

.else_04_7855:
    ifGte [hLinkPositionY], 72, .else_04_78C1

    ifNe [hLinkDirection], DIRECTION_UP, .else_04_78C1

    ld   a, [$FFCC]
    and  %00110000
    jr   z, .else_04_78C1

    ifNotZero [$C509], .else_04_7888

    ld   a, [hLinkPositionX]
    add  a, 0
    swap a
    and  %00001111
    ld   e, a
    ld   d, b
    ld   hl, $7826
    add  hl, de
    ld   a, [$C50B]
    cp   [hl]
    jr   nz, .else_04_78C1

    assign [$FFF2], $13
    jp   JumpTable_78E1_04.toc_04_78F1

.else_04_7888:
    ld   a, [hLinkPositionX]
    add  a, 0
    swap a
    and  %00001111
    ld   e, a
    ld   d, b
    ld   hl, $7826
    add  hl, de
    ld   a, [hl]
    ld   [$C50B], a
    ld   e, a
    ld   d, b
    ld   hl, $C505
    add  hl, de
    ld   a, [hl]
    ld   [$C509], a
    ld   [hl], b
    and  a
    jr   z, .else_04_78AC

    assign [$FFF2], $13
.else_04_78AC:
    push bc
    ld   a, e
    swap a
    ld   e, a
    ld   hl, $7703
    add  hl, de
    ld   de, $D601
    ld   c, $0D
.loop_04_78BA:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop_04_78BA

    pop  bc
.else_04_78C1:
    call toc_04_7B77
    jr   nc, .return_04_78E0

    ifNotZero [$C509], .else_04_78DB

    dec  a
    ld   e, a
    ld   d, b
    ld   hl, $7757
    add  hl, de
    ld   a, [hl]
    call toc_01_2197
    call JumpTable_3B8D_00
    ret


.else_04_78DB:
    ld   a, $2E
    call toc_01_2197
.return_04_78E0:
    ret


JumpTable_78E1_04:
    ld   a, [wDialogState]
    and  a
    ret  nz

    ifEq [$C177], $00, toc_04_792F

    cp   $02
    jr   z, .else_04_7908

.toc_04_78F1:
    ld   a, [$C50B]
    ld   e, a
    ld   d, b
    ld   hl, $C505
    add  hl, de
    ld   a, [$C509]
    ld   [hl], a
    ld   de, $D601
    call toc_04_790F
    clear [$C509]
.else_04_7908:
    ld   hl, $C290
    add  hl, bc
    ld   [hl], $01
    ret


toc_04_790F:
    push de
    dec  a
    ld   d, a
    sla  a
    ld   e, a
    sla  a
    sla  a
    add  a, e
    add  a, d
    ld   e, a
    ld   d, b
    ld   hl, $76C0
    add  hl, de
    pop  de
    push bc
    ld   c, $0B
.loop_04_7925:
    ldi  a, [hl]
    ld   [de], a
    inc  de
    dec  c
    jr   nz, .loop_04_7925

    xor  a
    ld   [de], a
    pop  bc
    ret


toc_04_792F:
    ld   a, [$C509]
    ld   e, a
    cp   $02
    jr   nz, .else_04_793F

    _ifZero [$C5A9], .else_04_7989

    jr   .else_04_7990

.else_04_793F:
    cp   $04
    jr   nz, .else_04_795D

    ld   hl, $DB00
    ld   d, $0C
.loop_04_7948:
    ldi  a, [hl]
    cp   $02
    jr   z, .else_04_7952

    dec  d
    jr   nz, .loop_04_7948

    jr   .else_04_7990

.else_04_7952:
    ld   a, [$DB4D]
    ld   hl, $DB77
    cp   [hl]
    jr   nc, .else_04_7989

    jr   .else_04_7990

.else_04_795D:
    cp   $06
    jr   nz, .else_04_797B

    ld   hl, $DB00
    ld   d, $0C
.loop_04_7966:
    ldi  a, [hl]
    cp   $05
    jr   z, .else_04_7970

    dec  d
    jr   nz, .loop_04_7966

    jr   .else_04_7990

.else_04_7970:
    ld   a, [$DB45]
    ld   hl, $DB78
    cp   [hl]
    jr   nc, .else_04_7989

    jr   .else_04_7990

.else_04_797B:
    cp   $03
    jr   nz, .else_04_7990

    ld   hl, $DB00
    ld   d, $0C
.loop_04_7984:
    ldi  a, [hl]
    cp   $04
    jr   nz, .else_04_798D

.else_04_7989:
    ld   a, $29
    jr   .toc_04_79A8

.else_04_798D:
    dec  d
    jr   nz, .loop_04_7984

.else_04_7990:
    ld   d, b
    ld   hl, $7761
    add  hl, de
    ld   a, [hl]
    ld   hl, $776A
    add  hl, de
    ld   e, [hl]
    ld   d, a
    ld   a, [$DB5E]
    sub  a, e
    ld   a, [$DB5D]
    sbc  d
    jr   nc, .else_04_79B2

    ld   a, $34
.toc_04_79A8:
    call toc_01_2197
    ld   hl, $C290
    add  hl, bc
    ld   [hl], $03
    ret


.else_04_79B2:
    ld   hl, $C509
    ld   a, [hl]
    push af
    ld   [hl], $00
    ld   e, a
    ld   d, b
    ld   hl, $777C
    add  hl, de
    ld   a, [$DB92]
    add  a, [hl]
    ld   [$DB92], a
    rl   a
    ld   hl, $7773
    add  hl, de
    rr   a
    ld   a, [$DB91]
    adc  [hl]
    ld   [$DB91], a
    ld   hl, $C290
    add  hl, bc
    ld   [hl], $01
    pop  af
    push af
    ld   a, $35
    call toc_01_2197
    pop  af
.toc_04_79E3:
    dec  a
    jumptable
    dw JumpTable_7A2E_04 ; 00
    dw JumpTable_7A5A_04 ; 01
    dw JumpTable_7A60_04 ; 02
    dw JumpTable_7A34_04 ; 03
    dw JumpTable_79F7_04 ; 04
    dw JumpTable_7A02_04 ; 05
    dw JumpTable_7A10_04 ; 06
    dw JumpTable_7A16_04 ; 07
    dw JumpTable_7A24_04 ; 08

JumpTable_79F7_04:
    ld   d, $05
    call toc_01_3E95
    assign [$DB45], $20
    ret


JumpTable_7A02_04:
    ld   a, [$DB45]
    add  a, $0A
    daa
    jr   nc, .else_04_7A0C

    ld   a, $99
.else_04_7A0C:
    ld   [$DB45], a
    ret


JumpTable_7A10_04:
    ld   d, $09
    call toc_01_3E95
    ret


JumpTable_7A16_04:
    ld   a, [$DB47]
    add  a, $0A
    daa
    jr   nc, .else_04_7A20

    ld   a, $99
.else_04_7A20:
    ld   [$DB47], a
    ret


JumpTable_7A24_04:
    ld   a, [$DB0D]
    add  a, $01
    daa
    ld   [$DB0D], a
    ret


JumpTable_7A2E_04:
    ld   d, $0B
    call toc_01_3E95
    ret


JumpTable_7A34_04:
    ld   a, [$DB4D]
    add  a, $0A
    daa
    jr   nc, .else_04_7A3E

    ld   a, $99
.else_04_7A3E:
    ld   [$DB4D], a
    ld   d, $02
    call toc_01_3E95
    ret


    db   $FA, $45, $DB, $C6, $0A, $27, $30, $02
    db   $3E, $99, $EA, $45, $DB, $16, $0C, $CD
    db   $95, $3E, $C9

JumpTable_7A5A_04:
    assign [$DB93], $18
    ret


JumpTable_7A60_04:
    ld   d, $04
    call toc_01_3E95
    ret


JumpTable_7A66_04:
    _ifZero [wDialogState], .return_04_7A6F

    call JumpTable_78E1_04.toc_04_78F1
.return_04_7A6F:
    ret


JumpTable_7A70_04:
    _ifZero [wDialogState], .return_04_7AAA

    ld   a, $CA
    call toc_01_3C01
    assign [$FFF4], $26
    ld   a, [$FFD7]
    ld   hl, $C200
    add  hl, de
    ld   [hl], a
    ld   a, [$FFD8]
    ld   hl, $C210
    add  hl, de
    ld   [hl], a
    ld   hl, $C2D0
    add  hl, de
    ld   [hl], $01
    ld   hl, $C2E0
    add  hl, de
    ld   [hl], $C0
    call toc_01_0891
    ld   [hl], $C0
    call JumpTable_3B8D_00
    clear [$DB0D]
    assign [$DB94], $FF
.return_04_7AAA:
    ret


JumpTable_7AAB_04:
    assign [hLinkInteractiveMotionBlocked], INTERACTIVE_MOTION_LOCKED_TALKING
    call toc_01_0891
    jr   nz, .return_04_7AC3

    _ifZero [$DB5A], .return_04_7AC3

    ld   [$DB46], a
    ld   [$C50A], a
    jp   toc_04_6D44

.return_04_7AC3:
    ret


    db   $1D, $3D, $5D, $7D, $96, $10, $A8, $10
    db   $86, $10, $80, $10, $88, $10, $FF, $FF
    db   $90, $10, $AE, $10, $A0, $10, $2A, $40
    db   $2A, $60, $3E, $04, $E0, $E6, $5F, $50
    db   $21, $04, $C5, $19, $7E, $A7, $28, $2E
    db   $3D, $E0, $F1, $21, $C3, $7A, $F0, $E6
    db   $5F, $19, $7E, $E0, $EE, $3E, $32, $E0
    db   $EC, $F0, $F1, $FE, $01, $20, $05, $21
    db   $EC, $FF, $36, $2F, $FE, $05, $20, $08
    db   $11, $C6, $7A, $CD, $3B, $3C, $18, $06
    db   $11, $C8, $7A, $CD, $D0, $3C, $F0, $E6
    db   $3D, $20, $C1, $CD, $26, $7B, $CD, $BA
    db   $3D, $C9, $FA, $09, $C5, $A7, $28, $27
    db   $3D, $E0, $F1, $3E, $01, $EA, $5C, $C1
    db   $CD, $3B, $09, $F0, $98, $E0, $EE, $F0
    db   $99, $D6, $0E, $E0, $EC, $F0, $F1, $FE
    db   $05, $20, $06, $11, $C6, $7A, $C3, $3B
    db   $3C, $11, $C8, $7A, $CD, $D0, $3C, $C9

toc_04_7B54:
    call toc_01_3BD5
    jr   nc, .return_04_7B76

    call toc_01_094A
    call toc_01_093B.toc_01_0942
    ifNotZero [$C1A6], .return_04_7B76

    ld   e, a
    ld   d, b
    ld   hl, $C39F
    add  hl, de
    ld   a, [hl]
    cp   $03
    jr   nz, .return_04_7B76

    ld   hl, $C28F
    add  hl, de
    ld   [hl], $00
.return_04_7B76:
    ret


toc_04_7B77:
    ld   a, [hLinkPositionX]
    ld   hl, $FFEE
    sub  a, [hl]
    add  a, 32
    cp   48
    jr   nc, .else_04_7BBA

    ld   a, [hLinkPositionY]
    ld   hl, $FFEF
    sub  a, [hl]
    add  a, 16
    cp   32
    jr   nc, .else_04_7BBA

    call toc_04_6E1F
    ld   a, [hLinkDirection]
    xor  DIRECTION_LEFT
    cp   e
    jr   nz, .else_04_7BBA

    ld   hl, $C1AD
    ld   [hl], $01
    ld   a, [wDialogState]
    ld   hl, $C14F
    or   [hl]
    ld   hl, $C134
    or   [hl]
    jr   nz, .else_04_7BBA

    ifNe [wWYStash], 128, .else_04_7BBA

    ld   a, [$FFCC]
    and  %00010000
    jr   z, .else_04_7BBA

    scf
    ret


.else_04_7BBA:
    and  a
    ret


toc_04_7BBC:
    ld   a, [wDialogState]
    ld   hl, $C14F
    or   [hl]
    ld   hl, $C146
    or   [hl]
    ld   hl, $C134
    or   [hl]
    jr   nz, .else_04_7C03

    ifNe [wWYStash], 128, .else_04_7C03

    ld   a, [hLinkPositionX]
    ld   hl, $FFEE
    sub  a, [hl]
    add  a, 16
    cp   32
    jr   nc, .else_04_7C03

    ld   a, [hLinkPositionY]
    ld   hl, $FFEF
    sub  a, [hl]
    add  a, 20
    cp   40
    jr   nc, .else_04_7C03

    call toc_04_6E1F
    ld   a, [hLinkDirection]
    xor  DIRECTION_LEFT
    cp   e
    jr   nz, .else_04_7C03

    ld   hl, $C1AD
    ld   [hl], $01
    ld   a, [$FFCC]
    and  %00010000
    jr   z, .else_04_7C03

    scf
    ret


.else_04_7C03:
    and  a
    ret


    db   $06, $04, $02, $00, $21, $80, $C3, $09
    db   $5E, $50, $21, $05, $7C, $19, $E5, $21
    db   $D0, $C3, $09, $34, $7E, $1F, $1F, $1F
    db   $E1, $E6, $01, $B6, $C3, $87, $3B, $21
    db   $40, $C2, $09, $7E, $F5, $36, $01, $21
    db   $50, $C2, $09, $7E, $F5, $36, $01, $CD
    db   $9E, $3B, $21, $A0, $C2, $09, $7E, $F5
    db   $21, $40, $C2, $09, $36, $FF, $21, $50
    db   $C2, $09, $36, $FF, $CD, $9E, $3B, $21
    db   $A0, $C2, $09, $F1, $B6, $77, $F1, $21
    db   $50, $C2, $09, $77, $F1, $21, $40, $C2
    db   $09, $77, $C9, $7A, $20, $78, $20, $78
    db   $00, $7A, $00, $7E, $00, $7E, $20, $70
    db   $00, $72, $00, $74, $00, $76, $00, $7C
    db   $00, $7C, $20, $6A, $20, $68, $20, $68
    db   $00, $6A, $00, $6E, $00, $6E, $20, $60
    db   $00, $62, $00, $64, $00, $66, $00, $6C
    db   $00, $6C, $20, $11, $60, $7C, $F0, $F7
    db   $FE, $07, $20, $03, $11, $78, $7C, $CD
    db   $8C, $08, $17, $17, $17, $E6, $10, $E0
    db   $ED, $CD, $3B, $3C, $CD, $1F, $7F, $21
    db   $10, $C4, $09, $7E, $FE, $08, $20, $0D
    db   $F0, $F0, $A7, $20, $08, $CD, $8D, $3B
    db   $CD, $87, $08, $36, $6F, $CD, $4A, $6D
    db   $CD, $94, $6D, $CD, $9E, $3B, $F0, $F0
    db   $C7

    dw JumpTable_7CDA_04 ; 00
    dw JumpTable_7D15_04 ; 01

    db   $08, $F8, $00, $00, $00, $00, $F8, $00

JumpTable_7CDA_04:
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_04_7D02

    call toc_01_27ED
    and  %00011111
    add  a, $30
    ld   [hl], a
    and  %00000011
    ld   e, a
    ld   d, b
    ld   hl, $7CD2
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $7CD6
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
.else_04_7D02:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


    db   $05, $05, $04, $03, $02, $02, $02

JumpTable_7D15_04:
    ifNotZero [$C14A], .else_04_7D20

    call JumpTable_3B8D_00
    ld   [hl], b
    ret


.else_04_7D20:
    call toc_01_3BEB
    call toc_04_6DFF
    add  a, $12
    cp   $24
    jr   nc, .else_04_7D35

    call toc_04_6E0F
    add  a, $12
    cp   $24
    jr   c, .else_04_7D43

.else_04_7D35:
    ld   a, [hFrameCounter]
    xor  c
    and  %00000011
    jr   nz, .else_04_7D41

    ld   a, $0E
    call toc_01_3C25
.else_04_7D41:
    jr   .toc_04_7D46

.else_04_7D43:
    call toc_01_3DAF
.toc_04_7D46:
    call toc_01_0887
    jp   z, JumpTable_7DF7_04.else_04_7E2F

    cp   $18
    jr   nz, .else_04_7D57

    ld   [hl], $0A
    call toc_01_088C
    ld   [hl], $30
.else_04_7D57:
    rra
    rra
    rra
    rra
    and  %00000111
    ld   e, a
    ld   d, b
    ld   hl, $7D0E
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ret


    db   $7A, $20, $78, $20, $78, $00, $7A, $00
    db   $6A, $20, $68, $20, $68, $00, $6A, $00
    db   $08, $F8, $00, $00, $00, $00, $F8, $08
    db   $11, $68, $7D, $F0, $F7, $FE, $07, $20
    db   $03, $11, $70, $7D, $CD, $3B, $3C, $CD
    db   $1F, $7F, $CD, $4A, $6D, $CD, $8C, $08
    db   $20, $03, $CD, $B4, $3B, $CD, $94, $6D
    db   $CD, $9E, $3B, $F0, $F0, $C7

    dw JumpTable_7DAC_04 ; 00
    dw JumpTable_7DC0_04 ; 01
    dw JumpTable_7DF7_04 ; 02

JumpTable_7DAC_04:
    call toc_01_0891
    jr   nz, .else_04_7DB4

    call JumpTable_3B8D_00
.else_04_7DB4:
    ld   a, [hFrameCounter]
    rra
    rra
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


JumpTable_7DC0_04:
    call toc_01_27ED
    and  %00000011
    jr   z, .else_04_7DCE

    call toc_01_27ED
    and  %00000011
    jr   .toc_04_7DD1

.else_04_7DCE:
    call toc_04_6E1F
.toc_04_7DD1:
    ld   e, a
    ld   d, b
    ld   hl, $7D78
    add  hl, de
    ld   a, [hl]
    ld   hl, $C240
    add  hl, bc
    ld   [hl], a
    ld   hl, $7D7C
    add  hl, de
    ld   a, [hl]
    ld   hl, $C250
    add  hl, bc
    ld   [hl], a
    call toc_01_0891
    call toc_01_27ED
    and  %00001111
    add  a, $20
    ld   [hl], a
    call JumpTable_3B8D_00
    ld   [hl], b
    ret


JumpTable_7DF7_04:
    call toc_01_3BF6
    call toc_01_0891
    jr   z, .else_04_7E2F

    ld   hl, $C2A0
    add  hl, bc
    ld   a, [hl]
    and  %00000011
    jr   nz, .else_04_7E0F

    ld   a, [hl]
    and  %00001100
    jr   nz, .else_04_7E19

    jr   .toc_04_7E25

.else_04_7E0F:
    ld   hl, $C240
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    ld   [hl], a
    jr   .toc_04_7E21

.else_04_7E19:
    ld   hl, $C250
    add  hl, bc
    ld   a, [hl]
    cpl
    inc  a
    ld   [hl], a
.toc_04_7E21:
    assign [$FFF2], $09
.toc_04_7E25:
    ld   a, [hFrameCounter]
    rra
    rra
    and  %00000001
    call toc_01_3B87
    ret


.else_04_7E2F:
    call toc_04_7E36
    call toc_04_6D44
    ret


toc_04_7E36:
    ld   a, $02
    call toc_01_3C01
    jr   c, .return_04_7E5A

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
.return_04_7E5A:
    ret


    db   $56, $00, $56, $20, $54, $00, $54, $20
    db   $52, $00, $52, $20, $50, $00, $50, $20
    db   $11, $5B, $7E, $CD, $3B, $3C, $CD, $1F
    db   $7F, $CD, $4A, $6D, $CD, $94, $6D, $CD
    db   $9E, $3B, $F0, $F0, $E6, $03, $C7

    dw JumpTable_7E8A_04 ; 00
    dw JumpTable_7E9F_04 ; 01
    dw JumpTable_7EC3_04 ; 02
    dw JumpTable_7EF0_04 ; 03

JumpTable_7E8A_04:
    ld   a, $FF
    call toc_01_3B87
    call toc_01_0891
    jr   nz, .return_04_7E9C

    ld   [hl], $1F
    call JumpTable_3B8D_00
    call toc_01_3DAF
.return_04_7E9C:
    ret


    db   $01, $00

JumpTable_7E9F_04:
    call toc_01_0891
    jr   nz, .else_04_7EB0

    call toc_01_27ED
    and  %00111111
    add  a, $70
    ld   [hl], a
    call JumpTable_3B8D_00
    ret


.else_04_7EB0:
    ld   hl, $7E9D
.toc_04_7EB3:
    srl  a
    srl  a
    srl  a
    srl  a
    ld   e, a
    ld   d, b
    add  hl, de
    ld   a, [hl]
    call toc_01_3B87
    ret


JumpTable_7EC3_04:
    call toc_01_3BB4
    call toc_01_0891
    jr   nz, .else_04_7ED4

    ld   [hl], $1F
    call JumpTable_3B8D_00
    call toc_01_3DAF
    ret


.else_04_7ED4:
    ld   a, [hFrameCounter]
    xor  c
    push af
    and  %00001111
    jr   nz, .else_04_7EE1

    ld   a, $08
    call toc_01_3C25
.else_04_7EE1:
    pop  af
    srl  a
    srl  a
    and  %00000001
    call toc_01_3B87
    inc  [hl]
    inc  [hl]
    ret


    db   $00, $01

JumpTable_7EF0_04:
    call toc_01_0891
    jr   nz, .else_04_7F06

    call toc_01_27ED
    and  %00011111
    add  a, $30
    ld   [hl], a
    call JumpTable_3B8D_00
    ld   a, $08
    call toc_01_3C25
    ret


.else_04_7F06:
    ld   hl, $7EEE
    jp   JumpTable_7E9F_04.toc_04_7EB3

    db   $21, $40, $C2, $09, $7E, $CB, $17, $3E
    db   $00, $38, $02, $3E, $20, $21, $ED, $FF
    db   $AE, $77, $C9

toc_04_7F1F:
    ifNe [$FFEA], $05, .else_04_7F3F

.toc_04_7F25:
    ifEq [wGameMode], GAMEMODE_WORLD_MAP, .else_04_7F3F

    ld   hl, $C1A8
    ld   a, [wDialogState]
    or   [hl]
    ld   hl, $C14F
    or   [hl]
    jr   nz, .else_04_7F3F

    ifNotZero [$C124], .return_04_7F40

.else_04_7F3F:
    pop  af
.return_04_7F40:
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
    db   $FF, $FF, $FF, $FF, $FF, $FF, $FF
