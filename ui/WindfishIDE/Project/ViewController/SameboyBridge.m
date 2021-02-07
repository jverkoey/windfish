#import "SameboyBridge.h"

#import "Core/gb.h"
#import "Cocoa/Emulator.h"
#import "Cocoa/GBView.h"

const GBFlag GBFlagCarry = (int)GB_CARRY_FLAG;
const GBFlag GBFlagHalfCarry = (int)GB_HALF_CARRY_FLAG;
const GBFlag GBFlagSubtract = (int)GB_SUBTRACT_FLAG;
const GBFlag GBFlagZero = (int)GB_ZERO_FLAG;

const GBPaletteType GBPaletteTypeNone = GB_PALETTE_NONE;
const GBPaletteType GBPaletteTypeBackground = GB_PALETTE_BACKGROUND;
const GBPaletteType GBPaletteTypeOAM = GB_PALETTE_OAM;
const GBPaletteType GBPaletteTypeAuto = GB_PALETTE_AUTO;

const GBMapType GBMapTypeAuto = GB_MAP_AUTO;
const GBMapType GBMapType9800 = GB_MAP_9800;
const GBMapType GBMapType9C00 = GB_MAP_9C00;

const GBTilesetType GBTilesetTypeAuto = GB_TILESET_AUTO;
const GBTilesetType GBTilesetType8800 = GB_TILESET_8800;
const GBTilesetType GBTilesetType8000 = GB_TILESET_8000;

const GBDirectAccess GBDirectAccessROM = GB_DIRECT_ACCESS_ROM;
const GBDirectAccess GBDirectAccessRAM = GB_DIRECT_ACCESS_RAM;
const GBDirectAccess GBDirectAccessCART_RAM = GB_DIRECT_ACCESS_CART_RAM;
const GBDirectAccess GBDirectAccessVRAM = GB_DIRECT_ACCESS_VRAM;
const GBDirectAccess GBDirectAccessHRAM = GB_DIRECT_ACCESS_HRAM;
const GBDirectAccess GBDirectAccessIO = GB_DIRECT_ACCESS_IO;
const GBDirectAccess GBDirectAccessBOOTROM = GB_DIRECT_ACCESS_BOOTROM;
const GBDirectAccess GBDirectAccessOAM = GB_DIRECT_ACCESS_OAM;
const GBDirectAccess GBDirectAccessBGP = GB_DIRECT_ACCESS_BGP;
const GBDirectAccess GBDirectAccessOBP = GB_DIRECT_ACCESS_OBP;
const GBDirectAccess GBDirectAccessIE = GB_DIRECT_ACCESS_IE;

static void gb_get_backtrace_return(GB_gameboy_t *gb, int i, uint16_t *bank, uint16_t *addr) {
  *bank = gb->backtrace_returns[i].bank;
  *addr = gb->backtrace_returns[i].addr;
}

@interface SameboyEmulator () <EmulatorDelegate>
@property(nonatomic, strong) Emulator *emulator;
@end

@implementation SameboyEmulator

- (instancetype)init {
  self = [super init];
  if (self) {
    _emulator = [[Emulator alloc] initWithModel:GB_MODEL_DMG_B];
    _emulator.delegate = self;
  }
  return self;
}

- (void)setDebuggerEnabled:(BOOL)debuggerEnabled {
  [_emulator setDebuggerEnabled:debuggerEnabled];
}

- (void)setLcdOutput:(uint32_t *)lcdOutput {
  _emulator.lcdOutput = lcdOutput;
}

- (void)loadBootROM:(GB_boot_rom_t)type {
  static NSString *const names[] = {
    [GB_BOOT_ROM_DMG0] = @"dmg0_boot",
    [GB_BOOT_ROM_DMG] = @"dmg_boot",
    [GB_BOOT_ROM_MGB] = @"mgb_boot",
    [GB_BOOT_ROM_SGB] = @"sgb_boot",
    [GB_BOOT_ROM_SGB2] = @"sgb2_boot",
    [GB_BOOT_ROM_CGB0] = @"cgb0_boot",
    [GB_BOOT_ROM_CGB] = @"cgb_boot",
    [GB_BOOT_ROM_AGB] = @"agb_boot",
  };
  [_emulator loadBootROM:[[NSBundle mainBundle] pathForResource:names[type] ofType:@"bin"]];
}

- (void)log:(NSString *)log withAttributes:(GB_log_attributes)_attributes {
  GBLogAttributes attributes = 0;
  if (_attributes & GB_LOG_BOLD) {
    attributes |= GBLogAttributesBold;
  }
  if (_attributes & GB_LOG_UNDERLINE) {
    attributes |= GBLogAttributesUnderline;
  }
  if (_attributes & GB_LOG_DASHED_UNDERLINE) {
    attributes |= GBLogAttributesDashedUnderline;
  }
  [_delegate log:log withAttributes:attributes];
}

- (void)loadROM:(nonnull NSURL *)url {
  [_emulator loadROM:url];
}

- (void)loadROMFromBuffer:(const uint8_t *)buffer size:(size_t)size {
  [_emulator loadROMFromBuffer:buffer size:size];
}

- (bool)debugStopped {
  return _emulator.gb->debug_stopped;
}

- (void)setDebugStopped:(bool)debugStopped {
  _emulator.gb->debug_stopped = debugStopped;
}

- (NSSize)screenSize {
  return _emulator.screenSize;
}

- (UInt8)a {
  return _emulator.gb->a;
}

- (UInt8)f {
  return _emulator.gb->f;
}

- (BOOL)fcarry {
  return (_emulator.gb->f & GB_CARRY_FLAG) != 0;
}

- (BOOL)fhalfcarry {
  return (_emulator.gb->f & GB_HALF_CARRY_FLAG) != 0;
}

- (BOOL)fsubtract {
  return (_emulator.gb->f & GB_SUBTRACT_FLAG) != 0;
}

- (BOOL)fzero {
  return (_emulator.gb->f & GB_ZERO_FLAG) != 0;
}

- (UInt8)b {
  return _emulator.gb->b;
}

- (UInt8)c {
  return _emulator.gb->c;
}

- (UInt8)d {
  return _emulator.gb->d;
}

- (UInt8)e {
  return _emulator.gb->e;
}

- (UInt8)h {
  return _emulator.gb->h;
}

- (UInt8)l {
  return _emulator.gb->l;
}

- (UInt16)pc {
  return _emulator.gb->pc;
}

- (UInt16)sp {
  return _emulator.gb->sp;
}

- (UInt16)romBank {
  return _emulator.gb->mbc_rom_bank;
}

- (UInt8)scx {
  return [_emulator readMemory:0xFF00 | GB_IO_SCX];
}

- (UInt8)scy {
  return [_emulator readMemory:0xFF00 | GB_IO_SCY];
}

- (unsigned int)backtraceSize {
  return _emulator.gb->backtrace_size;
}

- (void)start {
  [_emulator start];
}

- (void)reset {
  [_emulator reset];
}

- (void)debuggerBreak {
  [_emulator debuggerBreak];
}

- (void)getBacktraceReturn:(int)index bank:(uint16_t *_Nonnull)bank addr:(uint16_t *_Nonnull)addr {
  gb_get_backtrace_return(_emulator.gb, index, bank, addr);
}

- (void)didRun {
  [_delegate didRun];
}

- (void)willRun {
  [_delegate willRun];
}

- (nonnull NSImage *)drawTilesetWithPaletteType:(GBPaletteType)paletteType menuIndex:(NSUInteger)menuIndex {
  return [_emulator drawTilesetWithPaletteType:(GB_palette_type_t)paletteType menuIndex:menuIndex];
}

- (nonnull NSImage *)drawTilemapWithPaletteType:(GBPaletteType)paletteType
                                   paletteIndex:(uint8_t)paletteIndex
                                        mapType:(GBMapType)mapType
                                    tilesetType:(GBTilesetType)tilesetType {
  return [_emulator drawTilemapWithPaletteType:(GB_palette_type_t)paletteType
                                  paletteIndex:paletteIndex
                                       mapType:(GB_map_type_t)mapType
                                   tilesetType:(GB_tileset_type_t)tilesetType];
}

- (uint8_t)getOAMInfo:(nonnull GBOAMInfo *)dest spriteHeight:(nonnull uint8_t *)sprite_height {
  GB_oam_info_t info[40] = {0,};
  uint8_t result = [_emulator getOAMInfo:info spriteHeight:sprite_height];
  memcpy(dest, info, sizeof(GBOAMInfo) * 40);
  return result;
}

- (void *)getDirectAccess:(GBDirectAccess)access size:(size_t *)size bank:(uint16_t *)bank {
  return [_emulator getDirectAccess:(GB_direct_access_t)access size:size bank:bank];
}

+ (nonnull NSImage *)imageFromData:(nonnull NSData *)data
                             width:(NSUInteger)width
                            height:(NSUInteger)height
                             scale:(double)scale {
  return [Emulator imageFromData:data width:width height:height scale:scale];
}

- (BOOL)isMuted {
  return [_delegate isMuted];
}

- (BOOL)isRewinding {
  return [_delegate isRewinding];
}

- (void)vblank {
  [_delegate vblank];
}

- (NSString *)getDebuggerInput {
  return [_delegate getDebuggerInput];
}

- (void)gotNewSample:(nonnull GB_sample_t *)sample {
  // No-op.
}

@end

@implementation SameboyGBView {
  GBView *_gbView;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _gbView = [[GBView alloc] initWithFrame:self.bounds];
    _gbView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self addSubview:_gbView];
  }
  return self;
}

- (void)bindWithEmulator:(nonnull SameboyEmulator *)emulator {
  _gbView.emulator = emulator.emulator;
}

- (void)screenSizeChanged {
  [_gbView screenSizeChanged];
}

- (void)flip {
  [_gbView flip];
}

- (uint32_t *)pixels {
  return _gbView.pixels;
}

@end
