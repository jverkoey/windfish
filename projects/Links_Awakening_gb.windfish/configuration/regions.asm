RST_0000: ; [Region] $00:$0000 [8]

RST_0008: ; [Data] $00:$0008 [8]

RST_0010: ; [Data] $00:$0010 [8]

RST_0018: ; [Data] $00:$0018 [8]

RST_0020: ; [Data] $00:$0020 [8]

RST_0028: ; [Data] $00:$0028 [8]

RST_0030: ; [Data] $00:$0030 [8]

RST_0038: ; [Data] $00:$0038 [8]

VBlankInterrupt: ; [Region] $00:$0040 [8]

LCDCInterrupt: ; [Region] $00:$0048 [8]

TimerOverflowInterrupt: ; [Region] $00:$0050 [8]

SerialTransferCompleteInterrupt: ; [Region] $00:$0058 [8]

JoypadTransitionInterrupt: ; [Region] $00:$0060 [8]

Boot: ; [Region] $00:$0100 [4]

HeaderLogo: ; [Image (1bpp)] $00:$0104 [48]

HeaderTitle: ; [String] $00:$0134 [15]

HeaderNewLicenseeCode: ; [Label] $00:$0144 [0]

HeaderOldLicenseeCode: ; [Label] $00:$014B [0]

HeaderMaskROMVersion: ; [Label] $00:$014C [0]

HeaderComplementCheck: ; [Label] $00:$014D [0]

HeaderGlobalChecksum: ; [Label] $00:$014E [0]

main: ; [Function] $00:$0150 [0]

JumpTable: ; [Function] $00:$2872 [0]

LoadMapData: ; [Function] $00:$04A1 [0]

vblank: ; [Function] $01:$0525 [0]

waitForVBlank: ; [Label] $00:$2887 [0]

setupLCD: ; [Function] $00:$2881 [0]

clearRegion: ; [Label] $00:$2999 [0]

clearBGTiles: ; [Function] $00:$298A [0]

clearRAM: ; [Label] $00:$2996 [0]

loopSetRegion: ; [Label] $00:$28B1 [0]

setRegion: ; [Function] $00:$28AD [0]

initializeBGDAT0: ; [Function] $00:$28A8 [0]

copyHLToDE: ; [Function] $00:$28C5 [0]

enableRAM: ; [Label] $00:$27B5 [0]

tile_link_walking: ; [Image (2bpp)] $0C:$4000 [64]

tile_sword_vert: ; [Image (2bpp)] $0C:$4040 [32]

tile_sword_horiz: ; [Image (2bpp)] $0C:$4060 [64]

tile_sword_swipe: ; [Image (2bpp)] $0C:$40A0 [64]

tile_music_note: ; [Image (2bpp)] $0C:$40E0 [32]

tile_explosion: ; [Image (2bpp)] $0C:$4100 [64]

tile_0C_4140: ; [Image (2bpp)] $0C:$4140 [32]

tile_0D_4000: ; [Image (2bpp)] $0D:$4000 [16]

tile_0D_4010: ; [Image (2bpp)] $0D:$4010 [16]

text_credits: ; [String] $17:$4099 [612]

DMARoutine: ; [Region] $01:$7D27 [10]

copyDMARoutine: ; [Function] $01:$7D19 [0]

copyInstructions: ; [Label] $01:$7D20 [0]

resetHardware: ; [Label] $01:$40CE [0]

tile_0C_4160: ; [Image (2bpp)] $0C:$4160 [32]

tile_0c_4180: ; [Image (2bpp)] $0C:$4180 [32]

tile_0C_41A0: ; [Image (2bpp)] $0C:$41A0 [32]

tile_0C_41C0: ; [Image (2bpp)] $0C:$41C0 [32]

tile_0C_41E0: ; [Image (2bpp)] $0C:$41E0 [32]

tile_fairy: ; [Image (2bpp)] $0C:$4200 [32]

tile_0C_4220: ; [Image (2bpp)] $0C:$4220 [32]

tile_0C_4240: ; [Image (2bpp)] $0C:$4240 [32]

tile_0C_4260: ; [Image (2bpp)] $0C:$4260 [32]

tile_0C_4280: ; [Image (2bpp)] $0C:$4280 [32]

tile_sword_up1: ; [Image (2bpp)] $0C:$42A0 [32]

tile_sword_right1: ; [Image (2bpp)] $0C:$42C0 [64]

tile_0C_4300: ; [Image (2bpp)] $0C:$4300 [32]

tile_0C_4320: ; [Image (2bpp)] $0C:$4320 [32]

tile_0C_4340: ; [Image (2bpp)] $0C:$4340 [32]

tile_0C_4360: ; [Image (2bpp)] $0C:$4360 [32]

tile_0C_4380: ; [Image (2bpp)] $0C:$4380 [32]

tile_0C_43A0: ; [Image (2bpp)] $0C:$43A0 [32]

loop_initializeSaveFile: ; [Label] $01:$46F9 [0]

initializeSaveFile: ; [Label] $01:$46F3 [0]

loop_verifySaveFile: ; [Label] $01:$46E5 [0]

verifySaveFile: ; [Label] $01:$46DD [0]

return: ; [Label] $01:$4710 [0]

clearSaveFile: ; [Label] $01:$4706 [0]