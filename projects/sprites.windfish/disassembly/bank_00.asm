SECTION "ROM Bank 00", ROM0[$00]

RST_0000:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0008:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0010:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0018:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0020:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0028:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0030:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

RST_0038:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

VBlankInterrupt:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

LCDCInterrupt:
    add  sp, $02
    ret


    db   $FF, $FF, $FF, $FF, $FF

TimerOverflowInterrupt:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

SerialTransferCompleteInterrupt:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38

JoypadTransitionInterrupt:
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
    rst  $38
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

Boot:
    nop
    jp   main

HeaderLogo:

    db   $CE, $ED, $66, $66, $CC, $0D, $00, $0B
    db   $03, $73, $00, $83, $00, $0C, $00, $0D
    db   $00, $08, $11, $1F, $88, $89, $00, $0E
    db   $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
    db   $BB, $BB, $67, $63, $6E, $0E, $EC, $CC
    db   $DD, $DC, $99, $9F, $BB, $B9, $33, $3E

HeaderTitle:
    db   "mooneye-gb test"

HeaderIsColorGB:
    db   not_color_gameboy

HeaderNewLicenseeCode:
    db   $5A, $5A

HeaderSGBFlag:
    db   not_super_gameboy

HeaderCartridgeType:
    db   cartridge_romonly

HeaderROMSize:
    db   romsize_2banks

HeaderRAMSize:
    db   ramsize_none

HeaderDestinationCode:
    db   destination_nonjapanese

HeaderOldLicenseeCode:
    db   $33

HeaderMaskROMVersion:
    db   $00

HeaderComplementCheck:
    db   $2D

HeaderGlobalChecksum:
    db   $A1, $AD

main:
    ld   sp, $E000
    call disable_lcd_safe
    call reset_screen
    call print_load_font
    ld   hl, gbLCDC
    set  7, [hl]
    ld   a, IE_LCDC
    ld   [gbIE], a
    ld   a, $00
    ld   [$FF80], a
    ld   hl, $0176
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_0

_testcase_data_0:
    db   $01, $00

_testcase_end_0:
    ld   a, $01
    ld   [$FF80], a
    ld   hl, $0189
    ld   d, $2D
    ld   e, $2C
    call run_testcase
    jr   _testcase_end_1

_testcase_data_1:
    db   $02, $00, $00

_testcase_end_1:
    ld   a, $02
    ld   [$FF80], a
    ld   hl, $019D
    ld   d, $2E
    ld   e, $2D
    call run_testcase
    jr   _testcase_end_2

_testcase_data_2:
    db   $03, $00, $00, $00

_testcase_end_2:
    ld   a, $03
    ld   [$FF80], a
    ld   hl, $01B2
    ld   d, $30
    ld   e, $2F
    call run_testcase
    jr   _testcase_end_3

_testcase_data_3:
    db   $04, $00, $00, $00, $00

_testcase_end_3:
    ld   a, $04
    ld   [$FF80], a
    ld   hl, $01C8
    ld   d, $31
    ld   e, $30
    call run_testcase
    jr   _testcase_end_4

_testcase_data_4:
    db   $05, $00, $00, $00, $00, $00

_testcase_end_4:
    ld   a, $05
    ld   [$FF80], a
    ld   hl, $01DF
    ld   d, $33
    ld   e, $32
    call run_testcase
    jr   _testcase_end_5

_testcase_data_5:
    db   $06, $00, $00, $00, $00, $00, $00

_testcase_end_5:
    ld   a, $06
    ld   [$FF80], a
    ld   hl, $01F7
    ld   d, $34
    ld   e, $33
    call run_testcase
    jr   _testcase_end_6

_testcase_data_6:
    db   $07, $00, $00, $00, $00, $00, $00, $00

_testcase_end_6:
    ld   a, $07
    ld   [$FF80], a
    ld   hl, $0210
    ld   d, $36
    ld   e, $35
    call run_testcase
    jr   _testcase_end_7

_testcase_data_7:
    db   $08, $00, $00, $00, $00, $00, $00, $00
    db   $00

_testcase_end_7:
    ld   a, $08
    ld   [$FF80], a
    ld   hl, $022A
    ld   d, $37
    ld   e, $36
    call run_testcase
    jr   _testcase_end_8

_testcase_data_8:
    db   $09, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00

_testcase_end_8:
    ld   a, $09
    ld   [$FF80], a
    ld   hl, $0245
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_9

_testcase_data_9:
    db   $0A, $00, $00, $00, $00, $00, $00, $00
    db   $00, $00, $00

_testcase_end_9:
    ld   a, $0A
    ld   [$FF80], a
    ld   hl, $0261
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_10

_testcase_data_10:
    db   $0A, $01, $01, $01, $01, $01, $01, $01
    db   $01, $01, $01

_testcase_end_10:
    ld   a, $0B
    ld   [$FF80], a
    ld   hl, $027D
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_11

_testcase_data_11:
    db   $0A, $02, $02, $02, $02, $02, $02, $02
    db   $02, $02, $02

_testcase_end_11:
    ld   a, $0C
    ld   [$FF80], a
    ld   hl, $0299
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_12

_testcase_data_12:
    db   $0A, $03, $03, $03, $03, $03, $03, $03
    db   $03, $03, $03

_testcase_end_12:
    ld   a, $0D
    ld   [$FF80], a
    ld   hl, $02B5
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_13

_testcase_data_13:
    db   $0A, $04, $04, $04, $04, $04, $04, $04
    db   $04, $04, $04

_testcase_end_13:
    ld   a, $0E
    ld   [$FF80], a
    ld   hl, $02D1
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_14

_testcase_data_14:
    db   $0A, $05, $05, $05, $05, $05, $05, $05
    db   $05, $05, $05

_testcase_end_14:
    ld   a, $0F
    ld   [$FF80], a
    ld   hl, $02ED
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_15

_testcase_data_15:
    db   $0A, $06, $06, $06, $06, $06, $06, $06
    db   $06, $06, $06

_testcase_end_15:
    ld   a, $10
    ld   [$FF80], a
    ld   hl, $0309
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_16

_testcase_data_16:
    db   $0A, $07, $07, $07, $07, $07, $07, $07
    db   $07, $07, $07

_testcase_end_16:
    ld   a, $11
    ld   [$FF80], a
    ld   hl, $0325
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_17

_testcase_data_17:
    db   $0A, $08, $08, $08, $08, $08, $08, $08
    db   $08, $08, $08

_testcase_end_17:
    ld   a, $12
    ld   [$FF80], a
    ld   hl, $0341
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_18

_testcase_data_18:
    db   $0A, $09, $09, $09, $09, $09, $09, $09
    db   $09, $09, $09

_testcase_end_18:
    ld   a, $13
    ld   [$FF80], a
    ld   hl, $035D
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_19

_testcase_data_19:
    db   $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A
    db   $0A, $0A, $0A

_testcase_end_19:
    ld   a, $14
    ld   [$FF80], a
    ld   hl, $0379
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_20

_testcase_data_20:
    db   $0A, $0B, $0B, $0B, $0B, $0B, $0B, $0B
    db   $0B, $0B, $0B

_testcase_end_20:
    ld   a, $15
    ld   [$FF80], a
    ld   hl, $0395
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_21

_testcase_data_21:
    db   $0A, $0C, $0C, $0C, $0C, $0C, $0C, $0C
    db   $0C, $0C, $0C

_testcase_end_21:
    ld   a, $16
    ld   [$FF80], a
    ld   hl, $03B1
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_22

_testcase_data_22:
    db   $0A, $0D, $0D, $0D, $0D, $0D, $0D, $0D
    db   $0D, $0D, $0D

_testcase_end_22:
    ld   a, $17
    ld   [$FF80], a
    ld   hl, $03CD
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_23

_testcase_data_23:
    db   $0A, $0E, $0E, $0E, $0E, $0E, $0E, $0E
    db   $0E, $0E, $0E

_testcase_end_23:
    ld   a, $18
    ld   [$FF80], a
    ld   hl, $03E9
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_24

_testcase_data_24:
    db   $0A, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    db   $0F, $0F, $0F

_testcase_end_24:
    ld   a, $19
    ld   [$FF80], a
    ld   hl, $0405
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_25

_testcase_data_25:
    db   $0A, $10, $10, $10, $10, $10, $10, $10
    db   $10, $10, $10

_testcase_end_25:
    ld   a, $1A
    ld   [$FF80], a
    ld   hl, $0421
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_26

_testcase_data_26:
    db   $0A, $11, $11, $11, $11, $11, $11, $11
    db   $11, $11, $11

_testcase_end_26:
    ld   a, $1B
    ld   [$FF80], a
    ld   hl, $043D
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_27

_testcase_data_27:
    db   $0A, $20, $20, $20, $20, $20, $20, $20
    db   $20, $20, $20

_testcase_end_27:
    ld   a, $1C
    ld   [$FF80], a
    ld   hl, $0459
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_28

_testcase_data_28:
    db   $0A, $21, $21, $21, $21, $21, $21, $21
    db   $21, $21, $21

_testcase_end_28:
    ld   a, $1D
    ld   [$FF80], a
    ld   hl, $0475
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_29

_testcase_data_29:
    db   $0A, $A0, $A0, $A0, $A0, $A0, $A0, $A0
    db   $A0, $A0, $A0

_testcase_end_29:
    ld   a, $1E
    ld   [$FF80], a
    ld   hl, $0491
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_30

_testcase_data_30:
    db   $0A, $A1, $A1, $A1, $A1, $A1, $A1, $A1
    db   $A1, $A1, $A1

_testcase_end_30:
    ld   a, $1F
    ld   [$FF80], a
    ld   hl, $04AD
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_31

_testcase_data_31:
    db   $0A, $A2, $A2, $A2, $A2, $A2, $A2, $A2
    db   $A2, $A2, $A2

_testcase_end_31:
    ld   a, $20
    ld   [$FF80], a
    ld   hl, $04C9
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_32

_testcase_data_32:
    db   $0A, $A7, $A7, $A7, $A7, $A7, $A7, $A7
    db   $A7, $A7, $A7

_testcase_end_32:
    ld   a, $21
    ld   [$FF80], a
    ld   hl, $04E5
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_33

_testcase_data_33:
    db   $0A, $A7, $A7, $A7, $A7, $A7, $A7, $A7
    db   $A7, $A7, $A7

_testcase_end_33:
    ld   a, $22
    ld   [$FF80], a
    ld   hl, $0501
    ld   d, $29
    ld   e, $28
    call run_testcase
    jr   _testcase_end_34

_testcase_data_34:
    db   $0A, $A8, $A8, $A8, $A8, $A8, $A8, $A8
    db   $A8, $A8, $A8

_testcase_end_34:
    ld   a, $23
    ld   [$FF80], a
    ld   hl, $051D
    ld   d, $29
    ld   e, $28
    call run_testcase
    jr   _testcase_end_35

_testcase_data_35:
    db   $0A, $A9, $A9, $A9, $A9, $A9, $A9, $A9
    db   $A9, $A9, $A9

_testcase_end_35:
    ld   a, $24
    ld   [$FF80], a
    ld   hl, $0539
    ld   d, $3A
    ld   e, $39
    call run_testcase
    jr   _testcase_end_36

_testcase_data_36:
    db   $0A, $00, $00, $00, $00, $00, $A0, $A0
    db   $A0, $A0, $A0

_testcase_end_36:
    ld   a, $25
    ld   [$FF80], a
    ld   hl, $0555
    ld   d, $3A
    ld   e, $39
    call run_testcase
    jr   _testcase_end_37

_testcase_data_37:
    db   $0A, $01, $01, $01, $01, $01, $A1, $A1
    db   $A1, $A1, $A1

_testcase_end_37:
    ld   a, $26
    ld   [$FF80], a
    ld   hl, $0571
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_38

_testcase_data_38:
    db   $0A, $02, $02, $02, $02, $02, $A2, $A2
    db   $A2, $A2, $A2

_testcase_end_38:
    ld   a, $27
    ld   [$FF80], a
    ld   hl, $058D
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_39

_testcase_data_39:
    db   $0A, $03, $03, $03, $03, $03, $A3, $A3
    db   $A3, $A3, $A3

_testcase_end_39:
    ld   a, $28
    ld   [$FF80], a
    ld   hl, $05A9
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_40

_testcase_data_40:
    db   $0A, $04, $04, $04, $04, $04, $A4, $A4
    db   $A4, $A4, $A4

_testcase_end_40:
    ld   a, $29
    ld   [$FF80], a
    ld   hl, $05C5
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_41

_testcase_data_41:
    db   $0A, $05, $05, $05, $05, $05, $A5, $A5
    db   $A5, $A5, $A5

_testcase_end_41:
    ld   a, $2A
    ld   [$FF80], a
    ld   hl, $05E1
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_42

_testcase_data_42:
    db   $0A, $06, $06, $06, $06, $06, $A6, $A6
    db   $A6, $A6, $A6

_testcase_end_42:
    ld   a, $2B
    ld   [$FF80], a
    ld   hl, $05FD
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_43

_testcase_data_43:
    db   $0A, $07, $07, $07, $07, $07, $A7, $A7
    db   $A7, $A7, $A7

_testcase_end_43:
    ld   a, $2C
    ld   [$FF80], a
    ld   hl, $0619
    ld   d, $3A
    ld   e, $39
    call run_testcase
    jr   _testcase_end_44

_testcase_data_44:
    db   $0A, $40, $40, $40, $40, $40, $A0, $A0
    db   $A0, $A0, $A0

_testcase_end_44:
    ld   a, $2D
    ld   [$FF80], a
    ld   hl, $0635
    ld   d, $3A
    ld   e, $39
    call run_testcase
    jr   _testcase_end_45

_testcase_data_45:
    db   $0A, $41, $41, $41, $41, $41, $A1, $A1
    db   $A1, $A1, $A1

_testcase_end_45:
    ld   a, $2E
    ld   [$FF80], a
    ld   hl, $0651
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_46

_testcase_data_46:
    db   $0A, $42, $42, $42, $42, $42, $A2, $A2
    db   $A2, $A2, $A2

_testcase_end_46:
    ld   a, $2F
    ld   [$FF80], a
    ld   hl, $066D
    ld   d, $39
    ld   e, $38
    call run_testcase
    jr   _testcase_end_47

_testcase_data_47:
    db   $0A, $43, $43, $43, $43, $43, $A3, $A3
    db   $A3, $A3, $A3

_testcase_end_47:
    ld   a, $30
    ld   [$FF80], a
    ld   hl, $0689
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_48

_testcase_data_48:
    db   $0A, $44, $44, $44, $44, $44, $A4, $A4
    db   $A4, $A4, $A4

_testcase_end_48:
    ld   a, $31
    ld   [$FF80], a
    ld   hl, $06A5
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_49

_testcase_data_49:
    db   $0A, $45, $45, $45, $45, $45, $A5, $A5
    db   $A5, $A5, $A5

_testcase_end_49:
    ld   a, $32
    ld   [$FF80], a
    ld   hl, $06C1
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_50

_testcase_data_50:
    db   $0A, $46, $46, $46, $46, $46, $A6, $A6
    db   $A6, $A6, $A6

_testcase_end_50:
    ld   a, $33
    ld   [$FF80], a
    ld   hl, $06DD
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_51

_testcase_data_51:
    db   $0A, $47, $47, $47, $47, $47, $A7, $A7
    db   $A7, $A7, $A7

_testcase_end_51:
    ld   a, $34
    ld   [$FF80], a
    ld   hl, $06F9
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_52

_testcase_data_52:
    db   $01, $00

_testcase_end_52:
    ld   a, $35
    ld   [$FF80], a
    ld   hl, $070C
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_53

_testcase_data_53:
    db   $01, $01

_testcase_end_53:
    ld   a, $36
    ld   [$FF80], a
    ld   hl, $071F
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_54

_testcase_data_54:
    db   $01, $02

_testcase_end_54:
    ld   a, $37
    ld   [$FF80], a
    ld   hl, $0732
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_55

_testcase_data_55:
    db   $01, $03

_testcase_end_55:
    ld   a, $38
    ld   [$FF80], a
    ld   hl, $0745
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_56

_testcase_data_56:
    db   $01, $04

_testcase_end_56:
    ld   a, $39
    ld   [$FF80], a
    ld   hl, $0758
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_57

_testcase_data_57:
    db   $01, $05

_testcase_end_57:
    ld   a, $3A
    ld   [$FF80], a
    ld   hl, $076B
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_58

_testcase_data_58:
    db   $01, $06

_testcase_end_58:
    ld   a, $3B
    ld   [$FF80], a
    ld   hl, $077E
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_59

_testcase_data_59:
    db   $01, $07

_testcase_end_59:
    ld   a, $3C
    ld   [$FF80], a
    ld   hl, $0791
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_60

_testcase_data_60:
    db   $01, $08

_testcase_end_60:
    ld   a, $3D
    ld   [$FF80], a
    ld   hl, $07A4
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_61

_testcase_data_61:
    db   $01, $09

_testcase_end_61:
    ld   a, $3E
    ld   [$FF80], a
    ld   hl, $07B7
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_62

_testcase_data_62:
    db   $01, $0A

_testcase_end_62:
    ld   a, $3F
    ld   [$FF80], a
    ld   hl, $07CA
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_63

_testcase_data_63:
    db   $01, $0B

_testcase_end_63:
    ld   a, $40
    ld   [$FF80], a
    ld   hl, $07DD
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_64

_testcase_data_64:
    db   $01, $0C

_testcase_end_64:
    ld   a, $41
    ld   [$FF80], a
    ld   hl, $07F0
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_65

_testcase_data_65:
    db   $01, $0D

_testcase_end_65:
    ld   a, $42
    ld   [$FF80], a
    ld   hl, $0803
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_66

_testcase_data_66:
    db   $01, $0E

_testcase_end_66:
    ld   a, $43
    ld   [$FF80], a
    ld   hl, $0816
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_67

_testcase_data_67:
    db   $01, $0F

_testcase_end_67:
    ld   a, $44
    ld   [$FF80], a
    ld   hl, $0829
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_68

_testcase_data_68:
    db   $01, $10

_testcase_end_68:
    ld   a, $45
    ld   [$FF80], a
    ld   hl, $083C
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_69

_testcase_data_69:
    db   $01, $11

_testcase_end_69:
    ld   a, $46
    ld   [$FF80], a
    ld   hl, $084F
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_70

_testcase_data_70:
    db   $01, $A0

_testcase_end_70:
    ld   a, $47
    ld   [$FF80], a
    ld   hl, $0862
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_71

_testcase_data_71:
    db   $01, $A1

_testcase_end_71:
    ld   a, $48
    ld   [$FF80], a
    ld   hl, $0875
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_72

_testcase_data_72:
    db   $01, $A2

_testcase_end_72:
    ld   a, $49
    ld   [$FF80], a
    ld   hl, $0888
    ld   d, $2B
    ld   e, $2A
    call run_testcase
    jr   _testcase_end_73

_testcase_data_73:
    db   $01, $A3

_testcase_end_73:
    ld   a, $4A
    ld   [$FF80], a
    ld   hl, $089B
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_74

_testcase_data_74:
    db   $01, $A4

_testcase_end_74:
    ld   a, $4B
    ld   [$FF80], a
    ld   hl, $08AE
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_75

_testcase_data_75:
    db   $01, $A5

_testcase_end_75:
    ld   a, $4C
    ld   [$FF80], a
    ld   hl, $08C1
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_76

_testcase_data_76:
    db   $01, $A6

_testcase_end_76:
    ld   a, $4D
    ld   [$FF80], a
    ld   hl, $08D4
    ld   d, $2A
    ld   e, $29
    call run_testcase
    jr   _testcase_end_77

_testcase_data_77:
    db   $01, $A7

_testcase_end_77:
    ld   a, $4E
    ld   [$FF80], a
    ld   hl, $08E7
    ld   d, $2E
    ld   e, $2D
    call run_testcase
    jr   _testcase_end_78

_testcase_data_78:
    db   $02, $00, $08

_testcase_end_78:
    ld   a, $4F
    ld   [$FF80], a
    ld   hl, $08FB
    ld   d, $2E
    ld   e, $2D
    call run_testcase
    jr   _testcase_end_79

_testcase_data_79:
    db   $02, $01, $09

_testcase_end_79:
    ld   a, $50
    ld   [$FF80], a
    ld   hl, $090F
    ld   d, $2D
    ld   e, $2C
    call run_testcase
    jr   _testcase_end_80

_testcase_data_80:
    db   $02, $02, $0A

_testcase_end_80:
    ld   a, $51
    ld   [$FF80], a
    ld   hl, $0923
    ld   d, $2D
    ld   e, $2C
    call run_testcase
    jr   _testcase_end_81

_testcase_data_81:
    db   $02, $03, $0B

_testcase_end_81:
    ld   a, $52
    ld   [$FF80], a
    ld   hl, $0937
    ld   d, $2C
    ld   e, $2B
    call run_testcase
    jr   _testcase_end_82

_testcase_data_82:
    db   $02, $04, $0C

_testcase_end_82:
    ld   a, $53
    ld   [$FF80], a
    ld   hl, $094B
    ld   d, $2C
    ld   e, $2B
    call run_testcase
    jr   _testcase_end_83

_testcase_data_83:
    db   $02, $05, $0D

_testcase_end_83:
    ld   a, $54
    ld   [$FF80], a
    ld   hl, $095F
    ld   d, $2C
    ld   e, $2B
    call run_testcase
    jr   _testcase_end_84

_testcase_data_84:
    db   $02, $06, $0E

_testcase_end_84:
    ld   a, $55
    ld   [$FF80], a
    ld   hl, $0973
    ld   d, $2C
    ld   e, $2B
    call run_testcase
    jr   _testcase_end_85

_testcase_data_85:
    db   $02, $07, $0F

_testcase_end_85:
    ld   a, $56
    ld   [$FF80], a
    ld   hl, $0987
    ld   d, $2E
    ld   e, $2D
    call run_testcase
    jr   _testcase_end_86

_testcase_data_86:
    db   $02, $08, $10

_testcase_end_86:
    ld   a, $57
    ld   [$FF80], a
    ld   hl, $099B
    ld   d, $2E
    ld   e, $2D
    call run_testcase
    jr   _testcase_end_87

_testcase_data_87:
    db   $02, $09, $11

_testcase_end_87:
    ld   a, $58
    ld   [$FF80], a
    ld   hl, $09AF
    ld   d, $2D
    ld   e, $2C
    call run_testcase
    jr   _testcase_end_88

_testcase_data_88:
    db   $02, $0A, $12

_testcase_end_88:
    ld   a, $59
    ld   [$FF80], a
    ld   hl, $09C3
    ld   d, $2D
    ld   e, $2C
    call run_testcase
    jr   _testcase_end_89

_testcase_data_89:
    db   $02, $0B, $13

_testcase_end_89:
    ld   a, $5A
    ld   [$FF80], a
    ld   hl, $09D7
    ld   d, $2C
    ld   e, $2B
    call run_testcase
    jr   _testcase_end_90

_testcase_data_90:
    db   $02, $0C, $14

_testcase_end_90:
    ld   a, $5B
    ld   [$FF80], a
    ld   hl, $09EB
    ld   d, $2C
    ld   e, $2B
    call run_testcase
    jr   _testcase_end_91

_testcase_data_91:
    db   $02, $0D, $15

_testcase_end_91:
    ld   a, $5C
    ld   [$FF80], a
    ld   hl, $09FF
    ld   d, $2C
    ld   e, $2B
    call run_testcase
    jr   _testcase_end_92

_testcase_data_92:
    db   $02, $0E, $16

_testcase_end_92:
    ld   a, $5D
    ld   [$FF80], a
    ld   hl, $0A13
    ld   d, $2C
    ld   e, $2B
    call run_testcase
    jr   _testcase_end_93

_testcase_data_93:
    db   $02, $0F, $17

_testcase_end_93:
    ld   a, $5E
    ld   [$FF80], a
    ld   hl, $0A27
    ld   d, $2E
    ld   e, $2D
    call run_testcase
    jr   _testcase_end_94

_testcase_data_94:
    db   $02, $10, $18

_testcase_end_94:
    ld   a, $5F
    ld   [$FF80], a
    ld   hl, $0A3B
    ld   d, $44
    ld   e, $43
    call run_testcase
    jr   _testcase_end_95

_testcase_data_95:
    db   $0A, $00, $08, $10, $18, $20, $28, $30
    db   $38, $40, $48

_testcase_end_95:
    ld   a, $60
    ld   [$FF80], a
    ld   hl, $0A57
    ld   d, $42
    ld   e, $41
    call run_testcase
    jr   _testcase_end_96

_testcase_data_96:
    db   $0A, $01, $09, $11, $19, $21, $29, $31
    db   $39, $41, $49

_testcase_end_96:
    ld   a, $61
    ld   [$FF80], a
    ld   hl, $0A73
    ld   d, $3F
    ld   e, $3E
    call run_testcase
    jr   _testcase_end_97

_testcase_data_97:
    db   $0A, $02, $0A, $12, $1A, $22, $2A, $32
    db   $3A, $42, $4A

_testcase_end_97:
    ld   a, $62
    ld   [$FF80], a
    ld   hl, $0A8F
    ld   d, $3D
    ld   e, $3C
    call run_testcase
    jr   _testcase_end_98

_testcase_data_98:
    db   $0A, $03, $0B, $13, $1B, $23, $2B, $33
    db   $3B, $43, $4B

_testcase_end_98:
    ld   a, $63
    ld   [$FF80], a
    ld   hl, $0AAB
    ld   d, $3A
    ld   e, $39
    call run_testcase
    jr   _testcase_end_99

_testcase_data_99:
    db   $0A, $04, $0C, $14, $1C, $24, $2C, $34
    db   $3C, $44, $4C

_testcase_end_99:
    ld   a, $64
    ld   [$FF80], a
    ld   hl, $0AC7
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_100

_testcase_data_100:
    db   $0A, $05, $0D, $15, $1D, $25, $2D, $35
    db   $3D, $45, $4D

_testcase_end_100:
    ld   a, $65
    ld   [$FF80], a
    ld   hl, $0AE3
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_101

_testcase_data_101:
    db   $0A, $06, $0E, $16, $1E, $26, $2E, $36
    db   $3E, $46, $4E

_testcase_end_101:
    ld   a, $66
    ld   [$FF80], a
    ld   hl, $0AFF
    ld   d, $38
    ld   e, $37
    call run_testcase
    jr   _testcase_end_102

_testcase_data_102:
    db   $0A, $07, $0F, $17, $1F, $27, $2F, $37
    db   $3F, $47, $4F

_testcase_end_102:
    ld   a, $67
    ld   [$FF80], a
    ld   hl, $0B1B
    ld   d, $44
    ld   e, $43
    call run_testcase
    jr   _testcase_end_103

_testcase_data_103:
    db   $0A, $48, $40, $38, $30, $28, $20, $18
    db   $10, $08, $00

_testcase_end_103:
    ld   a, $68
    ld   [$FF80], a
    ld   hl, $0B37
    ld   d, $42
    ld   e, $41
    call run_testcase
    jr   _testcase_end_104

_testcase_data_104:
    db   $0A, $49, $41, $39, $31, $29, $21, $19
    db   $11, $09, $01

_testcase_end_104:
    di
    ld   hl, $0B49
    jp   quit

_testcase_end_104@quit_inline_1:
    db   $CD, $BA, $48, $CD, $FC, $48, $54, $65
    db   $73, $74, $20, $4F, $4B, $00, $16, $00
    db   $C9

run_testcase:
    push de
    push hl
run_testcase.run_testcase@wait_ly_5:
    ld   a, [gbLY]
    cp   143
    jr   nz, .run_testcase@wait_ly_5

run_testcase.run_testcase@wait_ly_6:
    ld   a, [gbLY]
    cp   144
    jr   nz, .run_testcase@wait_ly_6

    ld   hl, gbLCDC
    res  7, [hl]
    call clear_oam
    pop  de
    call prepare_sprites
    pop  de
    ld   c, d
    ld   hl, gbRAM
    call prepare_nop_area
    ld   c, e
    ld   hl, $C060
    call prepare_nop_area
    ld   hl, gbLCDC
    set  7, [hl]
    ld   hl, gbLCDC
    set  1, [hl]

.testcase_round_a:
    ld   hl, $0B98
    push hl
    ld   hl, gbRAM
    push hl
    jp   setup_and_wait_mode2@wait_ly_7

testcase_round_a_ret:
    ld   b, $00
testcase_round_a_ret.loop_01_0B9A:
    inc  b
    ld   a, [gbSTAT]
    and  %00000011
    jr   nz, .loop_01_0B9A

    ld   a, b
    ld   c, $01
    cp   c
    jp   nz, test_fail

.testcase_round_b:
    ld   hl, $0BB3
    push hl
    ld   hl, $C060
    push hl
    jp   setup_and_wait_mode2@wait_ly_7

testcase_round_b_ret:
    ld   b, $00
testcase_round_b_ret.loop_01_0BB5:
    inc  b
    ld   a, [gbSTAT]
    and  %00000011
    jr   nz, .loop_01_0BB5

    ld   a, b
    ld   c, $02
    cp   c
    jp   nz, test_fail

    ret


prepare_sprites:
    ld   a, [de]
    ld   c, a
    ld   b, $30
    ld   hl, gbOAMRAM
prepare_sprites.loop_01_0BCB:
    inc  de
    ld   a, $52
    ldi  [hl], a
    ld   a, [de]
    ldi  [hl], a
    ld   a, b
    ldi  [hl], a
    inc  b
    xor  a
    ldi  [hl], a
    dec  c
    jr   nz, .loop_01_0BCB

    ret


prepare_nop_area:
    xor  a
prepare_nop_area.loop_01_0BDB:
    ldi  [hl], a
    dec  c
    jr   nz, .loop_01_0BDB

    ld   a, $C9
    ldi  [hl], a
    ret


setup_and_wait_mode2@wait_ly_7:
    ld   a, [gbLY]
    cp   66
    jr   nz, setup_and_wait_mode2@wait_ly_7

toc_01_0BE9:
    ld   a, [gbSTAT]
    and  %00000011
    cp   $00
    jr   nz, toc_01_0BE9

toc_01_0BF1:
    ld   a, [gbSTAT]
    and  %00000011
    cp   $03
    jr   nz, toc_01_0BF1

    ld   a, STATF_MODE10
    ld   [gbSTAT], a
    xor  a
    ld   [gbIF], a
    ei
    halt
    nop
    jp   fail_halt

test_fail:
    di
    ld   hl, $0C0D
    jp   quit

test_fail@quit_inline_2:
    db   $CD, $FC, $48, $54, $45, $53, $54, $20
    db   $23, $00, $FA, $80, $FF, $CD, $D9, $48
    db   $CD, $FC, $48, $20, $46, $41, $49, $4C
    db   $45, $44, $00, $16, $42, $C9

fail_halt:
    di
    ld   hl, $0C32
    jp   quit

fail_halt@quit_inline_3:
    db   $CD, $BA, $48, $CD, $FC, $48, $46, $41
    db   $49, $4C, $3A, $20, $48, $41, $4C, $54
    db   $00, $16, $42, $C9, $FF, $FF, $FF, $FF
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
    db   $FF, $FF, $FF, $FF, $FF, $FF
