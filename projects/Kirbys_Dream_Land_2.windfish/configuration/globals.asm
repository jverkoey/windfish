HeaderIsColorGB EQU $0143 ; [HW_COLORGAMEBOY]

HeaderSGBFlag EQU $0146 ; [HW_SUPERGAMEBOY]

HeaderCartridgeType EQU $0147 ; [HW_CARTRIDGETYPE]

HeaderROMSize EQU $0148 ; [HW_ROMSIZE]

HeaderRAMSize EQU $0149 ; [HW_RAMSIZE]

HeaderDestinationCode EQU $014A ; [HW_DESTINATIONCODE]

gbVRAM EQU $8000 ; [hex]

gbBGCHARDAT EQU $8800 ; [hex]

gbBGDAT0 EQU $9800 ; [hex]

gbBGDAT1 EQU $9C00 ; [hex]

gbCARTRAM EQU $A000 ; [hex]

gbRAM EQU $C000 ; [hex]

wScrollPosition1 EQU $DA02 ; [decimal]

wScrollPosition2 EQU $DA04 ; [decimal]

wQueuedDMATransfer EQU $DA0F ; [decimal]

wStashL EQU $DA11 ; [decimal]

wStashH EQU $DA12 ; [decimal]

wLCDInterruptTrampoline EQU $DA13 ; [decimal]

gbOAMRAM EQU $FE00 ; [hex]

gbP1 EQU $FF00 ; [JOYPAD]

gbSB EQU $FF01 ; [hex]

gbSC EQU $FF02 ; [hex]

gbDIV EQU $FF04 ; [hex]

gbTIMA EQU $FF05 ; [hex]

gbTMA EQU $FF06 ; [hex]

gbTAC EQU $FF07 ; [hex]

gbIF EQU $FF0F ; [hex]

gbAUD1SWEEP EQU $FF10 ; [hex]

gbAUD1LEN EQU $FF11 ; [hex]

gbAUD1ENV EQU $FF12 ; [hex]

gbAUD1LOW EQU $FF13 ; [hex]

gbAUD1HIGH EQU $FF14 ; [hex]

gbAUD2LEN EQU $FF16 ; [hex]

gbAUD2ENV EQU $FF17 ; [hex]

gbAUD2LOW EQU $FF18 ; [hex]

gbAUD2HIGH EQU $FF19 ; [hex]

gbAUD3ENA EQU $FF1A ; [hex]

gbAUD3LEN EQU $FF1B ; [hex]

gbAUD3LEVEL EQU $FF1C ; [hex]

gbAUD3LOW EQU $FF1D ; [hex]

gbAUD3HIGH EQU $FF1E ; [hex]

gbAUD4LEN EQU $FF20 ; [hex]

gbAUD4ENV EQU $FF21 ; [hex]

gbAUD4POLY EQU $FF22 ; [hex]

gbAUD4CONSEC EQU $FF23 ; [hex]

gbAUDVOL EQU $FF24 ; [binary]

gbAUDTERM EQU $FF25 ; [binary]

gbAUDENA EQU $FF26 ; [HW_AUDIO_ENABLE]

gbAUD3WAVERAM EQU $FF30 ; [hex]

gbLCDC EQU $FF40 ; [LCDCF]

gbSTAT EQU $FF41 ; [STATF]

gbSCY EQU $FF42 ; [decimal]

gbSCX EQU $FF43 ; [decimal]

gbLY EQU $FF44 ; [decimal]

gbLYC EQU $FF45 ; [decimal]

gbDMA EQU $FF46 ; [hex]

gbBGP EQU $FF47 ; [hex]

gbOBP0 EQU $FF48 ; [hex]

gbOBP1 EQU $FF49 ; [hex]

gbWY EQU $FF4A ; [hex]

gbWX EQU $FF4B ; [hex]

gbKEY1 EQU $FF4D ; [hex]

gbVBK EQU $FF4F ; [hex]

gbHDMA1 EQU $FF51 ; [hex]

gbHDMA2 EQU $FF52 ; [hex]

gbHDMA3 EQU $FF53 ; [hex]

gbHDMA4 EQU $FF54 ; [hex]

gbHDMA5 EQU $FF55 ; [hex]

gbRP EQU $FF56 ; [hex]

gbBCPS EQU $FF68 ; [hex]

gbBCPD EQU $FF69 ; [hex]

gbOCPS EQU $FF6A ; [hex]

gbOCPD EQU $FF6B ; [hex]

gbSVBK EQU $FF70 ; [hex]

gbPCM12 EQU $FF76 ; [hex]

gbPCM34 EQU $FF77 ; [hex]

hDesiredBankChange EQU $FF96 ; [decimal]

hLastBank EQU $FFA4 ; [decimal]

gbIE EQU $FFFF ; [HW_IE]