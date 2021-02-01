
assign: MACRO
    ld   a, \2
    ld   \1, a
    ENDM

call_changebank: MACRO
    ld   a, \1
    call toc_01_07B9
    ENDM

changebank: MACRO
    ld   a, \1
    ld   [$2100], a
    ENDM

clear: MACRO
    xor  a
    ld   \1, a
    ENDM

copyFromTo: MACRO
    ld   a, \1
    ld   \2, a
    ENDM

ifEq: MACRO
    ld   a, \1
    cp   \2
    jr   z, \3
    ENDM

ifGte: MACRO
    ld   a, \1
    cp   \2
    jr   nc, \3
    ENDM

ifLt: MACRO
    ld   a, \1
    cp   \2
    jr   c, \3
    ENDM

ifNe: MACRO
    ld   a, \1
    cp   \2
    jr   nz, \3
    ENDM

ifNot: MACRO
    ld   a, \1
    and  a
    jr   z, \2
    ENDM

ifNotZero: MACRO
    ld   a, \1
    and  a
    jp   z, \2
    ENDM

incAddr: MACRO
    ld   hl, \1
    inc  [hl]
    ENDM

jumptable: MACRO
    rst  $00
    ENDM

loadHL: MACRO
    ld   a, \1
    ld   h, a
    ld   a, \2
    ld   l, a
    ENDM

mask: MACRO
    ld   a, \1
    and  \2
    ld   \1, a
    ENDM

returnIfGte: MACRO
    ld   a, \1
    cp   \2
    ret  nc
    ENDM

returnIfLt: MACRO
    ld   a, \1
    cp   \2
    ret  c
    ENDM
