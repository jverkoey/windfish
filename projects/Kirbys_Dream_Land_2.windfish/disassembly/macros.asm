
assign: MACRO
    ld   a, \2
    ld   \1, a
    ENDM

cbcall: MACRO
    ld   a, \1
    ld   hl, \2
    call cbcall
    ENDM

changebank: MACRO
    ld   a, \1
    ld   [$2100], a
    ENDM

clear: MACRO
    xor  a
    ld   \1, a
    ENDM

ifEq: MACRO
    ld   a, \1
    cp   \2
    jr   nz, \3
    ENDM

ifNotZero: MACRO
    ld   a, \1
    and  a
    jr   z, \2
    ENDM

memcpyFromTo: MACRO
    ld   hl, \1
    ld   de, \2
    ld   bc, \3
    call memcpy
    ENDM