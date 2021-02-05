
changebank: MACRO
    ld   a, \1
    ld   [$2100], a
    ENDM
