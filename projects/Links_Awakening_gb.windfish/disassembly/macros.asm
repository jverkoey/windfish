
; Arguments:
; - 1 type: ffimm8addr
; - 2 type: imm8
assign: MACRO
    ld   a, \2
    ld   \1, a
    ENDM

; Arguments:
; - 1 type: imm8
call_changebank: MACRO
    ld   a, \1
    call toc_01_07B9
    ENDM

; Arguments:
; - 1 type: imm8
changebank: MACRO
    ld   a, \1
    ld   [$2100], a
    ENDM

; Arguments:
; - 1 type: imm16addr
clear: MACRO
    xor  a
    ld   \1, a
    ENDM

; Arguments:
; - 1 type: ffimm8addr
; - 2 type: imm16addr
copyFromTo: MACRO
    ld   a, \1
    ld   \2, a
    ENDM

; Arguments:
; - 1 type: ffimm8addr
; - 2 type: imm8
; - 3 type: simm8
ifEq: MACRO
    ld   a, \1
    cp   \2
    jr   z, \3
    ENDM

; Arguments:
; - 1 type: ffimm8addr
; - 2 type: imm8
; - 3 type: simm8
ifGte: MACRO
    ld   a, \1
    cp   \2
    jr   nc, \3
    ENDM

; Arguments:
; - 1 type: ffimm8addr
; - 2 type: imm8
; - 3 type: simm8
ifLt: MACRO
    ld   a, \1
    cp   \2
    jr   c, \3
    ENDM

; Arguments:
; - 1 type: imm16addr
; - 2 type: imm8
; - 3 type: simm8
ifNe: MACRO
    ld   a, \1
    cp   \2
    jr   nz, \3
    ENDM

; Arguments:
; - 1 type: imm16addr
; - 2 type: simm8
ifNot: MACRO
    ld   a, \1
    and  a
    jr   z, \2
    ENDM

; Arguments:
; - 1 type: imm16
incAddr: MACRO
    ld   hl, \1
    inc  [hl]
    ENDM

jumptable: MACRO
    rst  $00
    ENDM

; Arguments:
; - 1 type: imm16addr
; - 2 type: imm16addr
loadHL: MACRO
    ld   a, \1
    ld   h, a
    ld   a, \2
    ld   l, a
    ENDM

; Arguments:
; - 1 type: ffimm8addr
; - 2 type: imm8
mask: MACRO
    ld   a, \1
    and  \2
    ld   \1, a
    ENDM

; Arguments:
; - 1 type: ffimm8addr
; - 2 type: imm8
returnIfGte: MACRO
    ld   a, \1
    cp   \2
    ret  nc
    ENDM

; Arguments:
; - 1 type: imm16addr
; - 2 type: imm8
returnIfLt: MACRO
    ld   a, \1
    cp   \2
    ret  c
    ENDM
