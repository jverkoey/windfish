#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef NSInteger GBFlag NS_TYPED_ENUM;
extern const GBFlag GBFlagCarry;
extern const GBFlag GBFlagHalfCarry;
extern const GBFlag GBFlagSubtract;
extern const GBFlag GBFlagZero;

typedef NSInteger GBPaletteType NS_TYPED_ENUM;
extern const GBPaletteType GBPaletteTypeNone;
extern const GBPaletteType GBPaletteTypeBackground;
extern const GBPaletteType GBPaletteTypeOAM;
extern const GBPaletteType GBPaletteTypeAuto;

typedef NSInteger GBMapType NS_TYPED_ENUM;
extern const GBMapType GBMapTypeAuto;
extern const GBMapType GBMapType9800;
extern const GBMapType GBMapType9C00;

typedef NSInteger GBTilesetType NS_TYPED_ENUM;
extern const GBTilesetType GBTilesetTypeAuto;
extern const GBTilesetType GBTilesetType8800;
extern const GBTilesetType GBTilesetType8000;

typedef NSInteger GBDirectAccess NS_TYPED_ENUM;
extern const GBDirectAccess GBDirectAccessROM;
extern const GBDirectAccess GBDirectAccessRAM;
extern const GBDirectAccess GBDirectAccessCART_RAM;
extern const GBDirectAccess GBDirectAccessVRAM;
extern const GBDirectAccess GBDirectAccessHRAM;
extern const GBDirectAccess GBDirectAccessIO;
extern const GBDirectAccess GBDirectAccessBOOTROM;
extern const GBDirectAccess GBDirectAccessOAM;
extern const GBDirectAccess GBDirectAccessBGP;
extern const GBDirectAccess GBDirectAccessOBP;
extern const GBDirectAccess GBDirectAccessIE;

typedef struct {
  uint32_t image[128];
  uint8_t x, y, tile, flags;
  uint16_t oam_addr;
  bool obscured_by_line_limit;
} GBOAMInfo;

typedef NS_OPTIONS(NSUInteger, GBLogAttributes) {
  GBLogAttributesBold = 1,
  GBLogAttributesDashedUnderline = 2,
  GBLogAttributesUnderline = 4,
};

@protocol SameboyEmulatorDelegate <NSObject>
@required
- (void)log:(nonnull NSString *)log withAttributes:(GBLogAttributes)attributes;
- (void)willRun;
- (void)didRun;
- (void)vblank;
- (nullable NSString *)getDebuggerInput;
@property (nonatomic, readonly) BOOL isMuted;
@property (nonatomic, readonly) BOOL isRewinding;
@end

@class SameboyEmulator;

@interface SameboyGBView: NSView

- (void)bindWithEmulator:(nonnull SameboyEmulator *)emulator;
- (void)screenSizeChanged;
- (void)flip;
@property(nonatomic, readonly, nonnull) uint32_t *pixels;

@end

@interface SameboyEmulator: NSObject

@property(nonatomic, weak, nullable) id<SameboyEmulatorDelegate> delegate;

- (void)setDebuggerEnabled:(BOOL)debuggerEnabled;

- (void)start;
- (void)loadROM:(nonnull NSURL *)url;
- (void)loadROMFromBuffer:(nonnull const uint8_t *)buffer size:(size_t)size;
- (void)debuggerBreak;

- (nonnull NSImage *)drawTilesetWithPaletteType:(GBPaletteType)paletteType menuIndex:(NSUInteger)menuIndex;
- (nonnull NSImage *)drawTilemapWithPaletteType:(GBPaletteType)paletteType
                                   paletteIndex:(uint8_t)paletteIndex
                                        mapType:(GBMapType)mapType
                                    tilesetType:(GBTilesetType)tilesetType;

@property(nonatomic, nonnull) uint32_t *lcdOutput;
@property(nonatomic) bool debugStopped;
@property(nonatomic) UInt8 a;
@property(nonatomic) UInt8 f;
@property(nonatomic) BOOL fcarry;
@property(nonatomic) BOOL fhalfcarry;
@property(nonatomic) BOOL fsubtract;
@property(nonatomic) BOOL fzero;
@property(nonatomic) UInt8 b;
@property(nonatomic) UInt8 c;
@property(nonatomic) UInt8 d;
@property(nonatomic) UInt8 e;
@property(nonatomic) UInt8 h;
@property(nonatomic) UInt8 l;
@property(nonatomic) UInt16 pc;
@property(nonatomic) UInt16 sp;
@property(nonatomic) UInt16 romBank;

@property(nonatomic) UInt8 scx;
@property(nonatomic) UInt8 scy;

- (nullable void *)getDirectAccess:(GBDirectAccess)access size:(nullable size_t *)size bank:(nullable uint16_t *)bank;
- (uint8_t)getOAMInfo:(nonnull GBOAMInfo *)dest spriteHeight:(nonnull uint8_t *)sprite_height;

- (uint32_t *_Nonnull)lcdOutput UNAVAILABLE_ATTRIBUTE;

@property(nonatomic) unsigned int backtraceSize;
- (void)getBacktraceReturn:(int)index bank:(uint16_t *_Nonnull)bank addr:(uint16_t *_Nonnull)addr;

+ (nonnull NSImage *)imageFromData:(nonnull NSData *)data
                             width:(NSUInteger)width
                            height:(NSUInteger)height
                             scale:(double)scale;

@end
