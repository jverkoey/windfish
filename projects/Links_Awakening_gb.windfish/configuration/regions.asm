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