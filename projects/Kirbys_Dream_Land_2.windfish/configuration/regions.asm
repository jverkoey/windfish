RST_0000: ; [Region] $00:$0000 [8]

RST_0008: ; [Region] $00:$0008 [8]

RST_0010: ; [Region] $00:$0010 [8]

RST_0018: ; [Region] $00:$0018 [8]

RST_0020: ; [Region] $00:$0020 [8]

RST_0028: ; [Region] $00:$0028 [8]

RST_0030: ; [Region] $00:$0030 [8]

RST_0038: ; [Region] $00:$0038 [8]

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

main: ; [Label] $00:$0150 [0]

memset: ; [Function] $00:$062F [0]

memcpy: ; [Function] $00:$0621 [0]

startCopying: ; [Label] $00:$0628 [0]

copy: ; [Label] $00:$0625 [0]

loadBank: ; [Label] $00:$05F3 [0]

changeBankAndCall: ; [Label] $00:$05E5 [0]

copyHLToFF30: ; [Label] $00:$3001 [0]

loop: ; [Label] $00:$3006 [0]

stashHL: ; [Label] $00:$0604 [0]

cbcallWithoutInterrupts: ; [Label] $00:$05CF [0]

loadBank: ; [Label] $00:$05DD [0]

LCDInterruptTrampolineReturn: ; [Function] $00:$0342 [0]

LCDCInterruptHandler: ; [Function] $00:$030C [0]

wait: ; [Label] $00:$0318 [0]

toc_00_022B: ; [Function] $00:$022B [0]

paintPixel: ; [Label] $00:$0757 [0]

whilePixelsRemain: ; [Label] $00:$0750 [0]

readCommandByte: ; [Label] $00:$070E [0]

fill: ; [Label] $00:$074F [0]

copyBytes: ; [Label] $00:$0743 [0]

decompressHAL: ; [Label] $00:$0708 [0]

readLongCommand: ; [Label] $00:$0718 [0]

vblankHandler: ; [Label] $00:$0159 [0]

waitForVBlank: ; [Label] $00:$015E [0]

passC0ToDMATransfer: ; [Label] $00:$0177 [0]

startDMATransfer: ; [Label] $00:$017C [0]

loadScrollPosition: ; [Label] $00:$018D [0]

doCE82PlusB: ; [Label] $00:$2F31 [0]

joypadHandler: ; [Label] $00:$041E [0]

readJoypad: ; [Label] $00:$0386 [0]

resetCounter: ; [Label] $00:$0432 [0]

checkCounter: ; [Label] $00:$0429 [0]

toc_01_0DFF: ; [Function] $01:$0DFF [0]

toc_01_0DCE: ; [Function] $01:$0DCE [0]

toc_01_0684: ; [Function] $01:$0684 [0]

initialize: ; [Function] $1A:$4000 [0]

waitForVBlank: ; [Label] $1A:$4003 [0]

DMARoutine: ; [Function] $1A:$40E8 [0]

initializeHardware: ; [Function] $1E:$4232 [0]

toc_07_57BC: ; [Function] $07:$57BC [0]

toc_07_401D: ; [Function] $07:$401D [0]

toc_08_4062: ; [Function] $08:$4062 [0]

data_446E: ; [Data] $1E:$446E [48]

data_5B6F: ; [Data] $1E:$5B6F [198]

setCE06ToAA: ; [Label] $1E:$4268 [0]

clearCE56: ; [Label] $1F:$4242 [0]

memcpy4281_to_CE2E: ; [Label] $1F:$424E [0]

data_1F_4281: ; [Data] $1F:$4281 [20]

data_1E_4343: ; [Label] $1E:$4343 [20]

toc_1E_5FE1: ; [Function] $1E:$5FE1 [0]

toc_1E_5F68: ; [Function] $1E:$5F68 [0]

toc_07_5FEE: ; [Function] $07:$5FEE [0]

toc_08_4000: ; [Function] $08:$4000 [0]

toc_1A_4246: ; [Function] $1A:$4246 [0]

toc_1E_6002: ; [Function] $1E:$6002 [0]

toc_1E_5FEB: ; [Function] $1E:$5FEB [0]

toc_1E_5DFF: ; [Function] $1E:$5DFF [0]

toc_1E_4299: ; [Function] $1E:$4299 [0]

toc_08_5E92: ; [Function] $08:$5E92 [0]

toc_0F_68D2: ; [Function] $0F:$68D2 [0]

toc_10_7A2D: ; [Function] $10:$7A2D [0]

data_10_72D1: ; [Data] $10:$72D1 [26]

wait: ; [Label] $1A:$40EE [0]

toc_1E_6011: ; [Function] $1E:$6011 [0]

toc_1E_606D: ; [Function] $1E:$606D [0]