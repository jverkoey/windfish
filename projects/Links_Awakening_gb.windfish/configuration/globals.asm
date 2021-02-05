DEBUG_TOOL1 EQU $0003 ; [bool]

DEBUG_TOOL2 EQU $0004 ; [bool]

DEBUG_TOOL3 EQU $0005 ; [hex]

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

wScrollXOffsetForSection EQU $C100 ; [decimal]

wLCDSectionIndex EQU $C105 ; [decimal]

wIntroBGYOffset EQU $C106 ; [decimal]

wNameIndex EQU $C108 ; [decimal]

wDialogState EQU $C19F ; [binary]

wLCDCStash EQU $D6FD ; [LCDCF]

wTileMapToLoad EQU $D6FE ; [hex]

wGameMode EQU $DB95 ; [GAMEMODE]

wWYStash EQU $DB9A ; [decimal]

wCurrentBank EQU $DBAF ; [hex]

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

gbAUDVOL EQU $FF24 ; [hex]

gbAUDTERM EQU $FF25 ; [hex]

gbAUDENA EQU $FF26 ; [hex]

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

gbWY EQU $FF4A ; [decimal]

gbWX EQU $FF4B ; [decimal]

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

hRomBank EQU $FF80 ; [hex]

hTemp EQU $FF81 ; [hex]

hCodeTemp EQU $FF82 ; [hex]

hNeedsUpdatingBGTiles EQU $FF90 ; [UPDATE_BG_TILES]

hNeedsUpdatingEnemiesTiles EQU $FF91 ; [bool]

hBGTilesLoadingStage EQU $FF92 ; [hex]

hEnemiesTilesLoadingStage EQU $FF93 ; [hex]

hWorldTileset EQU $FF94 ; [hex]

hBaseScrollX EQU $FF96 ; [decimal]

hBaseScrollY EQU $FF97 ; [decimal]

hLinkPositionX EQU $FF98 ; [decimal]

hLinkPositionY EQU $FF99 ; [decimal]

hLinkPositionXIncrement EQU $FF9A ; [decimal]

hLinkPositionYIncrement EQU $FF9B ; [decimal]

hLinkAnimationState EQU $FF9D ; [LINK_ANIMATION]

hLinkDirection EQU $FF9E ; [DIRECTION]

hLinkFinalPositionX EQU $FF9F ; [decimal]

hLinkFinalPositionY EQU $FFA0 ; [decimal]

hLinkInteractiveMotionBlocked EQU $FFA1 ; [INTERACTIVE_MOTION]

hLinkPositionZHigh EQU $FFA2 ; [hex]

hLinkPositionZLow EQU $FFA3 ; [hex]

hAnimatedTilesGroup EQU $FFA4 ; [ANIMATED_TILE]

hAnimatedTilesFrameCount EQU $FFA6 ; [decimal]

hAnimatedTilesDataOffset EQU $FFA7 ; [hex]

hMusicFadeOutTimer EQU $FFA8 ; [decimal]

hVolumeRight EQU $FFA9 ; [hex]

hVolumeLeft EQU $FFAA ; [hex]

hMusicFadeInTimer EQU $FFAB ; [decimal]

hObjectUnderEntity EQU $FFAF ; [decimal]

hDefaultMusicTrack EQU $FFB0 ; [MUSIC]

hNextMusicTrackToFadeInto EQU $FFB1 ; [MUSIC]

hLinkWalksSlow EQU $FFB2 ; [bool]

hButtonsInactiveDelay EQU $FFB5 ; [decimal]

hNextDefaultMusicTrack EQU $FFBF ; [MUSIC]

hPressedButtonsMask EQU $FFCB ; [BUTTON]

hSwordIntersectedAreaY EQU $FFCD ; [hex]

hSwordIntersectedAreaX EQU $FFCE ; [hex]

hNeedsRenderingFrame EQU $FFD1 ; [bool]

hIEStash EQU $FFD2 ; [hex]

hFrameCounter EQU $FFE7 ; [decimal]

hIsRenderingFrame EQU $FFFD ; [bool]

gbIE EQU $FFFF ; [HW_IE]