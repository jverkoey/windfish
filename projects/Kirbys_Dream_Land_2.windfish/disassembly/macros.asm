
__ifNotZero: MACRO
    ld   a, \1
    or   a
    jr   z, \2
    ENDM

_ifZero: MACRO
    ld   a, \1
    and  a
    jr   nz, \2
    ENDM

assign: MACRO
    ld   a, \2
    ld   \1, a
    ENDM

cbcall: MACRO
    ld   a, \1
    ld   hl, \2
    call changeBankAndCall
    ENDM

cbcallNoInterrupts: MACRO
    ld   hl, \2
    ld   a, \1
    call cbcallWithoutInterrupts
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
    jr   nz, \3
    ENDM

ifGte: MACRO
    ld   a, \1
    cp   \2
    jr   nc, \3
    ENDM

ifNe: MACRO
    ld   a, \1
    cp   \2
    jr   z, \3
    ENDM

ifNotZero: MACRO
    ld   a, \1
    and  a
    jr   z, \2
    ENDM

ifNotZeroAtAddress: MACRO
    ld   hl, \1
    ld   a, [hl]
    and  a
    jr   z, \2
    ENDM

incAddr: MACRO
    ld   hl, \1
    inc  [hl]
    ENDM

mask: MACRO
    ld   a, \1
    and  \2
    ld   \1, a
    ENDM

memcpyFromTo: MACRO
    ld   hl, \1
    ld   de, \2
    ld   bc, \3
    call memcpy
    ENDM

plotFromTo: MACRO
    ld   hl, \1
    ld   de, \2
    call decompressHAL
    ENDM

returnIfGte: MACRO
    ld   a, \1
    cp   \2
    ret  nc
    ENDM
