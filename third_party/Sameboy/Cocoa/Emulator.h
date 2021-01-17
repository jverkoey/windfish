#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "GBCallbackBridge.h"
#include <Core/gb.h>

@protocol EmulatorDelegate <GBCallbackBridgeDelegate>
@required
- (void)willRun;
- (void)didRun;
@property (nonatomic, readonly) BOOL isMuted;
@property (nonatomic, readonly) BOOL isRewinding;
@end

/** An Emulator represents the state of a GB_gameboy_t as it emulates its rom. */
__attribute__((objc_subclassing_restricted))
@interface Emulator : NSObject

- (nonnull instancetype)initWithModel:(GB_model_t)model;
- (nonnull instancetype)init NS_UNAVAILABLE;

@property (nonatomic, nonnull, readonly) GB_gameboy_t *gb;

@property (nonatomic, nullable, weak) id<EmulatorDelegate> delegate;

#pragma mark Emulation

- (void)loadBootROM:(nonnull NSString *)path;

- (void)loadROM:(nonnull NSURL *)url;
- (void)loadROMFromBuffer:(nonnull const uint8_t *)buffer size:(size_t)size;

/** Asynchronously starts running the emulator on a background thread. */
- (void)start;

@property (nonatomic) bool isInitialized;

/** Asynchronously tells the emulator to stop running. */
- (void)stop;

- (void)reset;
- (void)resetWithModel:(GB_model_t)model;

/** Is the emulator currently emulating? */
@property (nonatomic, readonly) bool running;
@property (nonatomic, readonly) BOOL isOddFrame;

/** Is the emulator currently emulating in reverse? */
@property (nonatomic) bool rewind;

#pragma mark Configuration

@property (nonatomic) GB_color_correction_mode_t colorCorrectionMode;
@property (nonatomic) double lightTemperature;
@property (nonatomic) double interferenceVolume;
@property (nonatomic) GB_border_mode_t borderMode;
@property (nonatomic) GB_highpass_mode_t highPassMode;
@property (nonatomic) double rewindLength;
@property (nonatomic) double clockMultiplier;
@property (nonatomic, nonnull) uint32_t *lcdOutput;
@property (nonatomic, nonnull) const GB_palette_t *palette;
@property (nonatomic) GB_rumble_mode_t rumbleMode;
- (void)setTurboMode:(BOOL)enabled noFrameSkip:(BOOL)noFrameSkip;

// Configuration properties are write-only.
- (GB_color_correction_mode_t)colorCorrectionMode UNAVAILABLE_ATTRIBUTE;
- (double)lightTemperature UNAVAILABLE_ATTRIBUTE;
- (double)interferenceVolume UNAVAILABLE_ATTRIBUTE;
- (GB_border_mode_t)borderMode UNAVAILABLE_ATTRIBUTE;
- (GB_highpass_mode_t)highPassMode UNAVAILABLE_ATTRIBUTE;
- (double)rewindLength UNAVAILABLE_ATTRIBUTE;
- (double)clockMultiplier UNAVAILABLE_ATTRIBUTE;
- (uint32_t *_Nonnull)lcdOutput UNAVAILABLE_ATTRIBUTE;
- (const GB_palette_t *_Nonnull)palette UNAVAILABLE_ATTRIBUTE;
- (GB_rumble_mode_t)rumbleMode UNAVAILABLE_ATTRIBUTE;

#pragma mark Hardware characteristics

@property (nonatomic, readonly) NSSize screenSize;
@property (nonatomic, readonly) BOOL isSGB;
@property (nonatomic, readonly) BOOL isCGB;

#pragma mark Audio

/** Toggles the ability to output sound. */
- (void)toggleMute;

@property (nonatomic, readonly) bool isMuted;

- (void)gotNewSample:(nonnull GB_sample_t *)sample;

#pragma mark Link cable

- (unsigned int)numberOfPlayers;

- (void)connectLinkCableToEmulator:(nonnull Emulator *)partner;
@property (nonatomic, weak, nullable) Emulator *master;
@property (nonatomic, strong, nullable) Emulator *slave;
@property (nonatomic, weak, nullable, readonly) Emulator *partner;
- (bool)isSlave;

@property (nonatomic) bool serialDataBit;
@property (nonatomic) bool infraredInput;
- (bool)infraredInput UNAVAILABLE_ATTRIBUTE;

- (void)setKeyStateForButton:(GB_key_t)button forPlayer:(unsigned int)player pressed:(bool)pressed;

#pragma mark Cheats

@property (nonatomic) BOOL cheatsEnabled;

#pragma mark Debugger

- (void)debuggerBreak;
- (char *_Nonnull)debuggerCompleteSubstring:(nonnull char *)input context:(nonnull uintptr_t *)context;
- (void)debuggerExecuteCommand:(NSString *_Nonnull)command;
- (bool)debuggerEvaluate:(nonnull NSString *)string
                  result:(nullable uint16_t *)result
              resultBank:(nullable uint16_t *)result_bank;

- (void)setDebuggerEnabled:(BOOL)debuggerEnabled;
@property (nonatomic, readonly) BOOL debuggerStopped;

- (unsigned int)timeToAlarm;

#pragma mark Logging

- (void)log:(nonnull const char *)fmt, ...;

#pragma mark State restoration

- (int)saveState:(nonnull NSURL *)url;
- (int)loadState:(nonnull NSURL *)url;
- (int)saveBattery:(nonnull NSURL *)url;
- (int)saveCheats:(nonnull NSURL *)url;

#pragma mark Memory

- (uint8_t)readMemory:(uint16_t)addr;
- (void)writeMemory:(uint16_t)addr value:(uint8_t)value;
- (nullable void *)getDirectAccess:(GB_direct_access_t)access size:(nullable size_t *)size bank:(nullable uint16_t *)bank;

- (nonnull NSImage *)drawTilesetWithPaletteType:(GB_palette_type_t)paletteType menuIndex:(NSUInteger)menuIndex;
- (nonnull NSImage *)drawTilemapWithPaletteType:(GB_palette_type_t)paletteType
                                   paletteIndex:(uint8_t)paletteIndex
                                        mapType:(GB_map_type_t)mapType
                                    tilesetType:(GB_tileset_type_t)tilesetType;
- (uint8_t)getOAMInfo:(nonnull GB_oam_info_t *)dest spriteHeight:(nonnull uint8_t *)sprite_height;

#pragma mark Peripherals

- (void)disconnectSerial;

- (void)connectPrinter;

- (void)connectWorkboyWithSetTimeCallback:(nonnull GB_workboy_set_time_callback)setTimeCallback
                          getTimeCallback:(nonnull GB_workboy_get_time_callback)getTimeCallback;
@property (nonatomic, readonly) bool workboyEnabled;
- (void)setWorkboyKey:(uint8_t)key;

- (void)cameraDidUpdate;

#pragma mark Delegating events

#pragma mark Miscellaneous

+ (nonnull NSImage *)imageFromData:(nonnull NSData *)data
                             width:(NSUInteger)width
                            height:(NSUInteger)height
                             scale:(double)scale;

@end
