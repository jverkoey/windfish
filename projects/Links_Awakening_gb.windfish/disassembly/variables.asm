gbVRAM EQU $8000

gbBGCHARDAT EQU $8800

gbBGDAT0 EQU $9800

gbBGDAT1 EQU $9C00

gbCARTRAM EQU $A000

gbRAM EQU $C000

wScrollXOffsetForSection EQU $C100

wLCDSectionIndex EQU $C105

wIntroBGYOffset EQU $C106

wNameIndex EQU $C108

wScreenShakeHorizontal EQU $C155

wScreenShakeVertical EQU $C156

wTransitionGfx EQU $C17F

wDialogState EQU $C19F

wAlternateBackgroundEnabled EQU $C500

wLCDCStash EQU $D6FD

wTileMapToLoad EQU $D6FE

wBGMapToLoad EQU $D6FF

wGameMode EQU $DB95

wGameplaySubtype EQU $DB96

wWYStash EQU $DB9A

wCurrentBank EQU $DBAF

gbOAMRAM EQU $FE00

gbP1 EQU $FF00

gbSB EQU $FF01

gbSC EQU $FF02

gbDIV EQU $FF04

gbTIMA EQU $FF05

gbTMA EQU $FF06

gbTAC EQU $FF07

gbIF EQU $FF0F

gbAUD1SWEEP EQU $FF10

gbAUD1LEN EQU $FF11

gbAUD1ENV EQU $FF12

gbAUD1LOW EQU $FF13

gbAUD1HIGH EQU $FF14

gbAUD2LEN EQU $FF16

gbAUD2ENV EQU $FF17

gbAUD2LOW EQU $FF18

gbAUD2HIGH EQU $FF19

gbAUD3ENA EQU $FF1A

gbAUD3LEN EQU $FF1B

gbAUD3LEVEL EQU $FF1C

gbAUD3LOW EQU $FF1D

gbAUD3HIGH EQU $FF1E

gbAUD4LEN EQU $FF20

gbAUD4ENV EQU $FF21

gbAUD4POLY EQU $FF22

gbAUD4CONSEC EQU $FF23

gbAUDVOL EQU $FF24

gbAUDTERM EQU $FF25

gbAUDENA EQU $FF26

gbAUD3WAVERAM EQU $FF30

gbLCDC EQU $FF40

gbSTAT EQU $FF41

gbSCY EQU $FF42

gbSCX EQU $FF43

gbLY EQU $FF44

gbLYC EQU $FF45

gbDMA EQU $FF46

gbBGP EQU $FF47

gbOBP0 EQU $FF48

gbOBP1 EQU $FF49

gbWY EQU $FF4A

gbWX EQU $FF4B

gbKEY1 EQU $FF4D

gbVBK EQU $FF4F

gbHDMA1 EQU $FF51

gbHDMA2 EQU $FF52

gbHDMA3 EQU $FF53

gbHDMA4 EQU $FF54

gbHDMA5 EQU $FF55

gbRP EQU $FF56

gbBCPS EQU $FF68

gbBCPD EQU $FF69

gbOCPS EQU $FF6A

gbOCPD EQU $FF6B

gbSVBK EQU $FF70

gbPCM12 EQU $FF76

gbPCM34 EQU $FF77

hRomBank EQU $FF80

hTemp EQU $FF81

hCodeTemp EQU $FF82

hNeedsUpdatingBGTiles EQU $FF90

hNeedsUpdatingEnemiesTiles EQU $FF91

hBGTilesLoadingStage EQU $FF92

hEnemiesTilesLoadingStage EQU $FF93

hWorldTileset EQU $FF94

hBaseScrollX EQU $FF96

hBaseScrollY EQU $FF97

hLinkPositionX EQU $FF98

hLinkPositionY EQU $FF99

hLinkPositionXIncrement EQU $FF9A

hLinkPositionYIncrement EQU $FF9B

hLinkAnimationState EQU $FF9D

hLinkDirection EQU $FF9E

hLinkFinalPositionX EQU $FF9F

hLinkFinalPositionY EQU $FFA0

hLinkInteractiveMotionBlocked EQU $FFA1

hLinkPositionZHigh EQU $FFA2

hLinkPositionZLow EQU $FFA3

hAnimatedTilesGroup EQU $FFA4

hAnimatedTilesFrameCount EQU $FFA6

hAnimatedTilesDataOffset EQU $FFA7

hMusicFadeOutTimer EQU $FFA8

hVolumeRight EQU $FFA9

hVolumeLeft EQU $FFAA

hMusicFadeInTimer EQU $FFAB

hObjectUnderEntity EQU $FFAF

hDefaultMusicTrack EQU $FFB0

hNextMusicTrackToFadeInto EQU $FFB1

hLinkWalksSlow EQU $FFB2

hButtonsInactiveDelay EQU $FFB5

hNextDefaultMusicTrack EQU $FFBF

hPressedButtonsMask EQU $FFCB

hSwordIntersectedAreaY EQU $FFCD

hSwordIntersectedAreaX EQU $FFCE

hNeedsRenderingFrame EQU $FFD1

hIEStash EQU $FFD2

hFrameCounter EQU $FFE7

hIsRenderingFrame EQU $FFFD

gbIE EQU $FFFF