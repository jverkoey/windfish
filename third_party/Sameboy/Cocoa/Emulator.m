#import "Emulator.h"

#include "GBAudioClient.h"

static unsigned *multiplication_table_for_frequency(unsigned frequency)
{
    unsigned *ret = malloc(sizeof(*ret) * 0x100);
    for (unsigned i = 0; i < 0x100; i++) {
        ret[i] = i * frequency;
    }
    return ret;
}

static uint32_t rgbEncode(GB_gameboy_t *gb, uint8_t r, uint8_t g, uint8_t b)
{
    return (r << 0) | (g << 8) | (b << 16) | 0xFF000000;
}

@interface Emulator () <GBCallbackBridgeDelegate>
@end

@implementation Emulator {
    GBCallbackBridge *_callbackBridge;

    GB_gameboy_t _gb;
    volatile bool _running;
    volatile bool _stopping;

    signed _linkOffset;

    GBAudioClient *_audioClient;
    NSCondition *_audioLock;
    GB_sample_t *_audioBuffer;
    size_t _audioBufferSize;
    size_t _audioBufferPosition;
    size_t _audioBufferNeeded;
}

@synthesize running = _running;

- (void)dealloc {
    if (_audioBuffer) {
        free(_audioBuffer);
    }
    GB_free(&_gb);
}

- (nonnull instancetype)initWithModel:(GB_model_t)model {
    self = [super init];
    if (self) {
        GB_init(&_gb, model);

        _audioLock = [[NSCondition alloc] init];

        GB_set_rgb_encode_callback(&_gb, rgbEncode);
    }
    return self;
}

- (GB_gameboy_t *)gb {
  return &_gb;
}

- (void)setDelegate:(id<EmulatorDelegate>)delegate {
  if (_delegate == delegate) {
    return;
  }
  _delegate = delegate;

  _callbackBridge = [[GBCallbackBridge alloc] initWithGameboy:&_gb delegate:delegate];
}

- (void)loadBootROM:(nonnull NSString *)path {
    GB_load_boot_rom(&_gb, path.UTF8String);
}

- (void)loadROM:(NSURL *)url {
    NSURL *baseURL = [url URLByDeletingPathExtension];

    GB_debugger_clear_symbols(&_gb);
    if ([[url pathExtension] isEqualToString:@"isx"]) {
        GB_load_isx(&_gb, url.path.UTF8String);
        GB_load_battery(&_gb, [baseURL URLByAppendingPathExtension:@"ram"].path.UTF8String);
    }
    else {
        GB_load_rom(&_gb, [url.path UTF8String]);
    }
    GB_load_battery(&_gb, [baseURL URLByAppendingPathExtension:@"sav"].path.UTF8String);
    GB_load_cheats(&_gb, [baseURL URLByAppendingPathExtension:@"cht"].path.UTF8String);
    GB_debugger_load_symbol_file(&_gb, [[[NSBundle mainBundle] pathForResource:@"registers" ofType:@"sym"] UTF8String]);
    GB_debugger_load_symbol_file(&_gb, [baseURL URLByAppendingPathExtension:@"sym"].path.UTF8String);
}

- (void)loadROMFromBuffer:(nonnull const uint8_t *)buffer size:(size_t)size {
    GB_load_rom_from_buffer(&_gb, buffer, size);
}

- (void)start {
    if (_running) return;
    [[[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil] start];
}

- (bool)isInitialized {
    return GB_is_inited(&_gb);
}

- (void)stop {
    [_audioLock lock];
    _stopping = true;
    [_audioLock signal];
    [_audioLock unlock];
    _running = false;
    while (_stopping) {
        [_audioLock lock];
        [_audioLock signal];
        [_audioLock unlock];
    }
    GB_debugger_set_disabled(&_gb, false);
}

- (void)reset {
    GB_reset(&_gb);
}

- (void)resetWithModel:(GB_model_t)model {
    GB_switch_model_and_reset(&_gb, model);
}

- (BOOL)isOddFrame {
    return GB_is_odd_frame(&_gb);
}

#pragma mark Configuration

- (void)setColorCorrectionMode:(GB_color_correction_mode_t)colorCorrectionMode {
    GB_set_color_correction_mode(&_gb, colorCorrectionMode);
}

- (void)setLightTemperature:(double)lightTemperature {
    GB_set_light_temperature(&_gb, lightTemperature);
}

- (void)setInterferenceVolume:(double)interferenceVolume {
    GB_set_interference_volume(&_gb, interferenceVolume);
}

- (void)setBorderMode:(GB_border_mode_t)borderMode {
    GB_set_border_mode(&_gb, borderMode);
}

- (void)setHighPassMode:(GB_highpass_mode_t)highPassMode {
    GB_set_highpass_filter_mode(&_gb, highPassMode);
}

- (void)setRewindLength:(double)rewindLength {
    GB_set_rewind_length(&_gb, rewindLength);
}

- (void)setClockMultiplier:(double)clockMultiplier {
    GB_set_clock_multiplier(&_gb, clockMultiplier);
}

- (void)setLcdOutput:(uint32_t *)lcdOutput {
    GB_set_pixels_output(&_gb, lcdOutput);
}

- (void)setPalette:(const GB_palette_t *)palette {
    GB_set_palette(&_gb, palette);
}

- (void)setRumbleMode:(GB_rumble_mode_t)rumbleMode {
    GB_set_rumble_mode(&_gb, rumbleMode);
}

- (void)setTurboMode:(BOOL)enabled noFrameSkip:(BOOL)noFrameSkip {
    GB_set_turbo_mode(&_gb, enabled, noFrameSkip);
}

#pragma mark Hardware characteristics

- (NSSize)screenSize {
    return NSMakeSize(GB_get_screen_width(&_gb), GB_get_screen_height(&_gb));
}

- (BOOL)isSGB {
    return GB_is_sgb(&_gb);
}

- (BOOL)isCGB {
    return GB_is_cgb(&_gb);
}

#pragma mark Audio

- (void)toggleMute {
    if (_audioClient.isPlaying) {
        [_audioClient stop];
    }
    else {
        [_audioClient start];
    }
}

- (bool)isMuted {
    return !_audioClient.isPlaying;
}

#pragma mark Link cable

- (void)connectLinkCableToEmulator:(Emulator *)partner {
    _slave = partner;

    partner->_master = self;

    [_callbackBridge enableSerialCallbacks];
    [partner->_callbackBridge enableSerialCallbacks];

    _linkOffset = 0;
}

- (Emulator *)partner {
  return _slave ?: _master;
}

- (bool)isSlave {
  return _master;
}

- (void)setKeyStateForButton:(GB_key_t)button forPlayer:(unsigned int)player pressed:(bool)pressed {
    GB_set_key_state_for_player(&_gb, button, player, pressed);
}

- (void)setSerialDataBit:(bool)serialDataBit {
    GB_serial_set_data_bit(&_gb, serialDataBit);
}

- (bool)serialDataBit {
    return GB_serial_get_data_bit(&_gb);
}

#pragma mark Cheats

- (void)setCheatsEnabled:(BOOL)cheatsEnabled {
    GB_set_cheats_enabled(&_gb, cheatsEnabled);
}

- (BOOL)cheatsEnabled {
    return GB_cheats_enabled(&_gb);
}

#pragma mark Debugger

- (void)debuggerBreak {
    GB_debugger_break(&_gb);
}

- (char *)debuggerCompleteSubstring:(char *)input context:(uintptr_t *)context {
    return GB_debugger_complete_substring(&_gb, input, context);
}

- (void)debuggerExecuteCommand:(NSString *)command {
    NSString *stripped = [command stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if ([stripped length]) {
        char *dupped = strdup(stripped.UTF8String);
        GB_attributed_log(&_gb, GB_LOG_BOLD, "%s:\n", dupped);
        GB_debugger_execute_command(&_gb, dupped);
        GB_log(&_gb, "\n");
        free(dupped);
    }
}

- (bool)debuggerEvaluate:(NSString *)string
                  result:(uint16_t *)result
              resultBank:(uint16_t *)result_bank {
    return GB_debugger_evaluate(&_gb, string.UTF8String, result, result_bank);
}

- (void)setDebuggerEnabled:(BOOL)debuggerEnabled {
    GB_debugger_set_disabled(&_gb, !debuggerEnabled);
}

- (BOOL)debuggerStopped {
    return GB_debugger_is_stopped(&_gb);
}

- (unsigned int)timeToAlarm {
    return GB_time_to_alarm(&_gb);
}

#pragma mark Logging

- (void)log:(nonnull const char *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    GB_log(&_gb, fmt, args);
    va_end(args);
}

#pragma mark State restoration

- (int)saveState:(NSURL *)url {
    return GB_save_state(&_gb, url.path.UTF8String);
}

- (int)loadState:(NSURL *)url {
    return GB_load_state(&_gb, url.path.UTF8String);
}

- (int)saveBattery:(nonnull NSURL *)url {
    return GB_save_battery(&_gb, url.path.UTF8String);
}

- (int)saveCheats:(nonnull NSURL *)url {
    return GB_save_cheats(&_gb, url.path.UTF8String);
}

- (void)setInfraredInput:(bool)infraredInput {
    GB_set_infrared_input(&_gb, infraredInput);
}

#pragma mark Memory

- (uint8_t)readMemory:(uint16_t)addr {
    while (!GB_is_inited(&_gb));
    return GB_read_memory(&_gb, addr);
}

- (void)writeMemory:(uint16_t)addr value:(uint8_t)value {
    while (!GB_is_inited(&_gb));
    GB_write_memory(&_gb, addr, value);
}

- (nullable void *)getDirectAccess:(GB_direct_access_t)access size:(size_t *)size bank:(uint16_t *)bank {
    return GB_get_direct_access(&_gb, access, size, bank);
}

- (NSImage *)drawTilesetWithPaletteType:(GB_palette_type_t)paletteType menuIndex:(NSUInteger)menuIndex {
    size_t bufferLength = 256 * 192 * 4;
    NSMutableData *data = [NSMutableData dataWithCapacity:bufferLength];
    data.length = bufferLength;
    GB_draw_tileset(&_gb, (uint32_t *)data.mutableBytes, paletteType, (menuIndex - 1) & 7);
    return [Emulator imageFromData:data width:256 height:192 scale:1.0];
}

- (NSImage *)drawTilemapWithPaletteType:(GB_palette_type_t)paletteType
                           paletteIndex:(uint8_t)paletteIndex
                                mapType:(GB_map_type_t)mapType
                            tilesetType:(GB_tileset_type_t)tilesetType {
    size_t bufferLength = 256 * 256 * 4;
    NSMutableData *data = [NSMutableData dataWithCapacity:bufferLength];
    data.length = bufferLength;
    GB_draw_tilemap(&_gb, (uint32_t *)data.mutableBytes, paletteType, (paletteIndex - 2) & 7, mapType, tilesetType);
    return [Emulator imageFromData:data width:256 height:256 scale:1.0];
}

- (uint8_t)getOAMInfo:(GB_oam_info_t *)dest spriteHeight:(uint8_t *)sprite_height {
    return GB_get_oam_info(&_gb, dest, sprite_height);
}

#pragma mark Multiplayer

- (unsigned int)numberOfPlayers {
    return GB_get_player_count(&_gb);
}

#pragma mark Peripherals

- (void)disconnectSerial {
    GB_disconnect_serial(&_gb);
}

- (void)connectPrinter {
    GB_connect_printer(&_gb, GBCallbackPrintImage);
}

- (void)connectWorkboyWithSetTimeCallback:(GB_workboy_set_time_callback)setTimeCallback
                          getTimeCallback:(GB_workboy_get_time_callback)getTimeCallback {
    GB_connect_workboy(&_gb, setTimeCallback, getTimeCallback);
}

- (bool)workboyEnabled {
    return GB_workboy_is_enabled(&_gb);
}

- (void)setWorkboyKey:(uint8_t)key {
    GB_workboy_set_key(&_gb, key);
}

- (void)cameraDidUpdate {
    GB_camera_updated(&_gb);
}

#pragma mark - CallbackBridgeDelegate

- (void)gotNewSample:(GB_sample_t *)sample {
    [_audioLock lock];
    if (_audioClient.isPlaying) {
        if (_audioBufferPosition == _audioBufferSize) {
            if (_audioBufferSize >= 0x4000) {
                _audioBufferPosition = 0;
                [_audioLock unlock];
                return;
            }

            if (_audioBufferSize == 0) {
                _audioBufferSize = 512;
            }
            else {
                _audioBufferSize += _audioBufferSize >> 2;
            }
            _audioBuffer = realloc(_audioBuffer, sizeof(*sample) * _audioBufferSize);
        }
        _audioBuffer[_audioBufferPosition++] = *sample;
    }
    if (_audioBufferPosition == _audioBufferNeeded) {
        [_audioLock signal];
        _audioBufferNeeded = 0;
    }
    [_audioLock unlock];
}

#pragma mark - Private

- (void)preRun {
    [self.delegate willRun];

    GB_set_sample_rate(&_gb, 96000);
    _audioClient = [[GBAudioClient alloc] initWithRendererBlock:^(UInt32 sampleRate, UInt32 nFrames, GB_sample_t *buffer) {
        [_audioLock lock];

        if (_audioBufferPosition < nFrames) {
            _audioBufferNeeded = nFrames;
            [_audioLock wait];
        }

        if (_stopping) {
            memset(buffer, 0, nFrames * sizeof(*buffer));
            [_audioLock unlock];
            return;
        }

        if (_audioBufferPosition >= nFrames && _audioBufferPosition < nFrames + 4800) {
            memcpy(buffer, _audioBuffer, nFrames * sizeof(*buffer));
            memmove(_audioBuffer, _audioBuffer + nFrames, (_audioBufferPosition - nFrames) * sizeof(*buffer));
            _audioBufferPosition = _audioBufferPosition - nFrames;
        }
        else {
            memcpy(buffer, _audioBuffer + (_audioBufferPosition - nFrames), nFrames * sizeof(*buffer));
            _audioBufferPosition = 0;
        }
        [_audioLock unlock];
    } andSampleRate:96000];
    if (!self.delegate.isMuted) {
        [_audioClient start];
    }
}

- (void)run {
    assert(!_master);
    _running = true;
    [self preRun];
    if (_slave) {
        [_slave preRun];
        unsigned *masterTable = multiplication_table_for_frequency(GB_get_clock_rate(&_gb));
        unsigned *slaveTable = multiplication_table_for_frequency(GB_get_clock_rate(&_slave->_gb));
        while (_running) {
            if (_linkOffset <= 0) {
                _linkOffset += slaveTable[GB_run(&_gb)];
            }
            else {
                _linkOffset -= masterTable[GB_run(&_slave->_gb)];
            }
        }
        free(masterTable);
        free(slaveTable);
        [_slave postRun];
    }
    else {
        while (_running) {
            if (_rewind) {
                _rewind = false;
                GB_rewind_pop(&_gb);
                if (!GB_rewind_pop(&_gb)) {
                    _rewind = self.delegate.isRewinding;
                }
            }
            else {
                GB_run(&_gb);
            }
        }
    }
    [self postRun];
    _stopping = false;
}

- (void)postRun {
    [self.delegate didRun];

    [_audioLock lock];
    memset(_audioBuffer, 0, (_audioBufferSize - _audioBufferPosition) * sizeof(*_audioBuffer));
    _audioBufferPosition = _audioBufferNeeded;
    [_audioLock signal];
    [_audioLock unlock];
    [_audioClient stop];

    _audioClient = nil;
}

+ (NSImage *)imageFromData:(NSData *)data width:(NSUInteger)width height:(NSUInteger)height scale:(double)scale {
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef) data);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    CGImageRef iref = CGImageCreate(width,
                                    height,
                                    8,
                                    32,
                                    4 * width,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,
                                    NULL,
                                    YES,
                                    renderingIntent);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);

    NSImage *ret = [[NSImage alloc] initWithCGImage:iref size:NSMakeSize(width * scale, height * scale)];
    CGImageRelease(iref);

    return ret;
}

@end
