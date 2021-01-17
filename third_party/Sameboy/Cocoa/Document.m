#include <AVFoundation/AVFoundation.h>
#include <CoreAudio/CoreAudio.h>
#include <Core/gb.h>
#include "GBAudioClient.h"
#include "Document.h"
#include "AppDelegate.h"
#include "HexFiend/HexFiend.h"
#include "GBMemoryByteArray.h"
#include "GBWarningPopover.h"
#include "GBCheatWindowController.h"
#include "GBTerminalTextFieldCell.h"
#include "BigSurToolbar.h"

/* Todo: The general Objective-C coding style conflicts with SameBoy's. This file needs a cleanup. */
/* Todo: Split into category files! This is so messy!!! */

enum model {
    MODEL_NONE,
    MODEL_DMG,
    MODEL_CGB,
    MODEL_AGB,
    MODEL_SGB,
};

@interface Document () <EmulatorDelegate>
{

    NSMutableAttributedString *pending_console_output;
    NSRecursiveLock *console_output_lock;
    NSTimer *console_output_timer;
    NSTimer *hex_timer;
    
    bool fullScreen;
    bool in_sync_input;
    HFController *hex_controller;

    NSString *lastConsoleInput;
    HFLineCountingRepresenter *lineRep;

    CVImageBufferRef cameraImage;
    AVCaptureSession *cameraSession;
    AVCaptureConnection *cameraConnection;
    AVCaptureStillImageOutput *cameraOutput;
    
    GB_oam_info_t oamInfo[40];
    uint16_t oamCount;
    uint8_t oamHeight;
    bool oamUpdating;
    
    NSMutableData *currentPrinterImageData;
    enum {GBAccessoryNone, GBAccessoryPrinter, GBAccessoryWorkboy, GBAccessoryLinkCable} accessory;
    
    bool rom_warning_issued;
    
    NSMutableString *capturedOutput;
    bool logToSideView;
    bool shouldClearSideView;
    enum model current_model;
    
    bool modelsChanging;
    
    bool borderModeChanged;
    
    /* Link cable*/
    Document *master;
    Document *slave;
    bool linkCableBit;
}

@end

static void setWorkboyTime(GB_gameboy_t *gb, time_t t)
{
    [[NSUserDefaults standardUserDefaults] setInteger:time(NULL) - t forKey:@"GBWorkboyTimeOffset"];
}

static time_t getWorkboyTime(GB_gameboy_t *gb)
{
    return time(NULL) - [[NSUserDefaults standardUserDefaults] integerForKey:@"GBWorkboyTimeOffset"];
}


@implementation Document
{
    NSConditionLock *has_debugger_input;
    NSMutableArray *debugger_input_queue;
}

@synthesize emulator = _emulator;

- (instancetype)init 
{
    self = [super init];
    if (self) {
        has_debugger_input = [[NSConditionLock alloc] initWithCondition:0];
        debugger_input_queue = [[NSMutableArray alloc] init];
        console_output_lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (NSString *)bootROMPathForName:(NSString *)name
{
    NSURL *url = [[NSUserDefaults standardUserDefaults] URLForKey:@"GBBootROMsFolder"];
    if (url) {
        NSString *path = [url path];
        path = [path stringByAppendingPathComponent:name];
        path = [path stringByAppendingPathExtension:@"bin"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return path;
        }
    }
    
    return [[NSBundle mainBundle] pathForResource:name ofType:@"bin"];
}

- (GB_model_t)internalModel
{
    switch (current_model) {
        case MODEL_DMG:
            return (GB_model_t)[[NSUserDefaults standardUserDefaults] integerForKey:@"GBDMGModel"];
            
        case MODEL_NONE:
        case MODEL_CGB:
            return (GB_model_t)[[NSUserDefaults standardUserDefaults] integerForKey:@"GBCGBModel"];
            
        case MODEL_SGB:
            return (GB_model_t)[[NSUserDefaults standardUserDefaults] integerForKey:@"GBSGBModel"];
        
        case MODEL_AGB:
            return GB_MODEL_AGB;
    }
}

- (void) updatePalette
{
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"GBColorPalette"]) {
        case 1:
            _emulator.palette = &GB_PALETTE_DMG;
            break;
            
        case 2:
            _emulator.palette = &GB_PALETTE_MGB;
            break;
            
        case 3:
            _emulator.palette = &GB_PALETTE_GBL;
            break;
            
        default:
            _emulator.palette = &GB_PALETTE_GREY;
            break;
    }
}

- (void) updateBorderMode
{
    borderModeChanged = true;
}

- (void) updateRumbleMode
{
    _emulator.rumbleMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"GBRumbleMode"];
}

- (void) initCommon
{
    _emulator = [[Emulator alloc] initWithModel:[self internalModel]];
    _emulator.delegate = self;

    _emulator.colorCorrectionMode = (GB_color_correction_mode_t) [[NSUserDefaults standardUserDefaults] integerForKey:@"GBColorCorrection"];
    _emulator.lightTemperature = [[NSUserDefaults standardUserDefaults] doubleForKey:@"GBLightTemperature"];
    _emulator.interferenceVolume = [[NSUserDefaults standardUserDefaults] doubleForKey:@"GBInterferenceVolume"];
    _emulator.borderMode = (GB_border_mode_t) [[NSUserDefaults standardUserDefaults] integerForKey:@"GBBorderMode"];
    [self updatePalette];
    _emulator.highPassMode = (GB_highpass_mode_t) [[NSUserDefaults standardUserDefaults] integerForKey:@"GBHighpassFilter"];
    _emulator.rewindLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"GBRewindLength"];
    [self updateRumbleMode];
}

- (void) updateMinSize
{
    NSSize screenSize = _emulator.screenSize;
    self.mainWindow.contentMinSize = screenSize;
    if (self.mainWindow.contentView.bounds.size.width < screenSize.width ||
        self.mainWindow.contentView.bounds.size.width < screenSize.height) {
        [self.mainWindow zoom:nil];
    }
}

- (void) start
{
    self.view.mouseHidingEnabled = (self.mainWindow.styleMask & NSWindowStyleMaskFullScreen) != 0;
    if (master) {
        [master start];
        return;
    }
    [_emulator start];
}

- (void) stop
{
    if (master) {
        if (!master->_emulator.running) return;
        _emulator.debuggerEnabled = false;
        if (_emulator.debuggerStopped) {
            [self interruptDebugInputRead];
        }
        [master stop];
        _emulator.debuggerEnabled = true;
        return;
    }
    if (!_emulator.running) return;
    _emulator.debuggerEnabled = false;
    if (_emulator.debuggerStopped) {
        [self interruptDebugInputRead];
    }
    [_emulator stop];
}

- (IBAction)reset:(id)sender
{
    [self stop];
    double old_width = _emulator.screenSize.width;
    
    if ([sender tag] != MODEL_NONE) {
        current_model = (enum model)[sender tag];
    }
    
    if (!modelsChanging && [sender tag] == MODEL_NONE) {
        [_emulator reset];
    }
    else {
        [_emulator resetWithModel:[self internalModel]];
    }
    
    if (old_width != _emulator.screenSize.width) {
        [self.view screenSizeChanged];
    }
    
    [self updateMinSize];
    
    if ([sender tag] != 0) {
        /* User explictly selected a model, save the preference */
        [[NSUserDefaults standardUserDefaults] setBool:current_model == MODEL_DMG forKey:@"EmulateDMG"];
        [[NSUserDefaults standardUserDefaults] setBool:current_model == MODEL_SGB forKey:@"EmulateSGB"];
        [[NSUserDefaults standardUserDefaults] setBool:current_model == MODEL_AGB forKey:@"EmulateAGB"];
    }
    
    /* Reload the ROM, SAV and SYM files */
    [self loadROM];

    [self start];

    if (hex_controller) {
        /* Verify bank sanity, especially when switching models. */
        [(GBMemoryByteArray *)(hex_controller.byteArray) setSelectedBank:0];
        [self hexUpdateBank:self.memoryBankInput ignoreErrors:true];
    }
}

- (IBAction)togglePause:(id)sender
{
    if (master) {
        [master togglePause:sender];
        return;
    }
    if (_emulator.running) {
        [self stop];
    }
    else {
        [self start];
    }
}

- (void)dealloc
{
    [cameraSession stopRunning];
    if (cameraImage) {
        CVBufferRelease(cameraImage);
    }
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController 
{
    [super windowControllerDidLoadNib:aController];
    // Interface Builder bug?
    [self.consoleWindow setContentSize:self.consoleWindow.minSize];
    /* Close Open Panels, if any */
    for (NSWindow *window in [[NSApplication sharedApplication] windows]) {
        if ([window isKindOfClass:[NSOpenPanel class]]) {
            [(NSOpenPanel *)window cancel:self];
        }
    }
    
    NSMutableParagraphStyle *paragraph_style = [[NSMutableParagraphStyle alloc] init];
    [paragraph_style setLineSpacing:2];
        
    self.debuggerSideViewInput.font = [NSFont userFixedPitchFontOfSize:12];
    self.debuggerSideViewInput.textColor = [NSColor whiteColor];
    self.debuggerSideViewInput.defaultParagraphStyle = paragraph_style;
    [self.debuggerSideViewInput setString:@"registers\nbacktrace\n"];
    ((GBTerminalTextFieldCell *)self.consoleInput.cell).emulator = _emulator;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSideView)
                                                 name:NSTextDidChangeNotification
                                               object:self.debuggerSideViewInput];
    
    self.consoleOutput.textContainerInset = NSMakeSize(4, 4);
    [self.view becomeFirstResponder];
    self.view.frameBlendingMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"GBFrameBlendingMode"];
    CGRect window_frame = self.mainWindow.frame;
    window_frame.size.width  = MAX([[NSUserDefaults standardUserDefaults] integerForKey:@"LastWindowWidth"],
                                  window_frame.size.width);
    window_frame.size.height = MAX([[NSUserDefaults standardUserDefaults] integerForKey:@"LastWindowHeight"],
                                   window_frame.size.height);
    [self.mainWindow setFrame:window_frame display:YES];
    self.vramStatusLabel.cell.backgroundStyle = NSBackgroundStyleRaised;
    
    
    
    self.consoleWindow.title = [NSString stringWithFormat:@"Debug Console – %@", [self.fileURL.path lastPathComponent]];
    self.debuggerSplitView.dividerColor = [NSColor clearColor];
    if (@available(macOS 11.0, *)) {
        self.memoryWindow.toolbarStyle = NSWindowToolbarStyleExpanded;
        self.printerFeedWindow.toolbarStyle = NSWindowToolbarStyleUnifiedCompact;
        [self.printerFeedWindow.toolbar removeItemAtIndex:1];
        self.printerFeedWindow.toolbar.items.firstObject.image =
            [NSImage imageWithSystemSymbolName:@"square.and.arrow.down"
                      accessibilityDescription:@"Save"];
        self.printerFeedWindow.toolbar.items.lastObject.image =
            [NSImage imageWithSystemSymbolName:@"printer"
                      accessibilityDescription:@"Print"];
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateHighpassFilter)
                                                 name:@"GBHighpassFilterChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateColorCorrectionMode)
                                                 name:@"GBColorCorrectionChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLightTemperature)
                                                 name:@"GBLightTemperatureChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInterferenceVolume)
                                                 name:@"GBInterferenceVolumeChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFrameBlendingMode)
                                                 name:@"GBFrameBlendingModeChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePalette)
                                                 name:@"GBColorPaletteChanged"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBorderMode)
                                                 name:@"GBBorderModeChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRumbleMode)
                                                 name:@"GBRumbleModeChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRewindLength)
                                                 name:@"GBRewindLengthChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dmgModelChanged)
                                                 name:@"GBDMGModelChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sgbModelChanged)
                                                 name:@"GBSGBModelChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cgbModelChanged)
                                                 name:@"GBCGBModelChanged"
                                               object:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EmulateDMG"]) {
        current_model = MODEL_DMG;
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EmulateSGB"]) {
        current_model = MODEL_SGB;
    }
    else {
        current_model = [[NSUserDefaults standardUserDefaults] boolForKey:@"EmulateAGB"]? MODEL_AGB : MODEL_CGB;
    }
    
    [self initCommon];
    self.view.emulator = _emulator;
    [self.view screenSizeChanged];
    [self loadROM];
    [self reset:nil];

}

- (void) initMemoryView
{
    hex_controller = [[HFController alloc] init];
    [hex_controller setBytesPerColumn:1];
    [hex_controller setEditMode:HFOverwriteMode];
    
    [hex_controller setByteArray:[[GBMemoryByteArray alloc] initWithDocument:self]];

    /* Here we're going to make three representers - one for the hex, one for the ASCII, and one for the scrollbar.  To lay these all out properly, we'll use a fourth HFLayoutRepresenter. */
    HFLayoutRepresenter *layoutRep = [[HFLayoutRepresenter alloc] init];
    HFHexTextRepresenter *hexRep = [[HFHexTextRepresenter alloc] init];
    HFStringEncodingTextRepresenter *asciiRep = [[HFStringEncodingTextRepresenter alloc] init];
    HFVerticalScrollerRepresenter *scrollRep = [[HFVerticalScrollerRepresenter alloc] init];
    lineRep = [[HFLineCountingRepresenter alloc] init];
    HFStatusBarRepresenter *statusRep = [[HFStatusBarRepresenter alloc] init];

    lineRep.lineNumberFormat = HFLineNumberFormatHexadecimal;

    /* Add all our reps to the controller. */
    [hex_controller addRepresenter:layoutRep];
    [hex_controller addRepresenter:hexRep];
    [hex_controller addRepresenter:asciiRep];
    [hex_controller addRepresenter:scrollRep];
    [hex_controller addRepresenter:lineRep];
    [hex_controller addRepresenter:statusRep];

    /* Tell the layout rep which reps it should lay out. */
    [layoutRep addRepresenter:hexRep];
    [layoutRep addRepresenter:scrollRep];
    [layoutRep addRepresenter:asciiRep];
    [layoutRep addRepresenter:lineRep];
    [layoutRep addRepresenter:statusRep];


    [(NSView *)[hexRep view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    /* Grab the layout rep's view and stick it into our container. */
    NSView *layoutView = [layoutRep view];
    NSRect layoutViewFrame = self.memoryView.frame;
    [layoutView setFrame:layoutViewFrame];
    [layoutView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable | NSViewMaxYMargin];
    [self.memoryView addSubview:layoutView];

    self.memoryBankItem.enabled = false;
}

+ (BOOL)autosavesInPlace 
{
    return YES;
}

- (NSString *)windowNibName 
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)type
{
    return YES;
}

- (void) loadROM
{
    NSString *rom_warnings = [self captureOutputForBlock:^{
        [_emulator loadROM:self.fileURL];
        [self.cheatWindowController cheatsUpdated];
    }];
    if (rom_warnings && !rom_warning_issued) {
        rom_warning_issued = true;
        [GBWarningPopover popoverWithContents:rom_warnings onWindow:self.mainWindow];
    }
}

- (void)close
{
    [self disconnectLinkCable];
    [[NSUserDefaults standardUserDefaults] setInteger:self.mainWindow.frame.size.width forKey:@"LastWindowWidth"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.mainWindow.frame.size.height forKey:@"LastWindowHeight"];
    [self stop];
    [self.consoleWindow close];
    [super close];
}

- (IBAction) interrupt:(id)sender
{
    [self log:"^C\n"];
    [_emulator debuggerBreak];
    [self start];
    [self.consoleWindow makeKeyAndOrderFront:nil];
    [self.consoleInput becomeFirstResponder];
}

- (IBAction)mute:(id)sender
{
    [_emulator toggleMute];
    [[NSUserDefaults standardUserDefaults] setBool:_emulator.isMuted forKey:@"Mute"];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
    if ([anItem action] == @selector(mute:)) {
        [(NSMenuItem *)anItem setState:_emulator.isMuted];
    }
    else if ([anItem action] == @selector(togglePause:)) {
        if (master) {
            [(NSMenuItem *)anItem setState:(!master->_emulator.running) || _emulator.debuggerStopped];
        }
        [(NSMenuItem *)anItem setState:!_emulator.running || _emulator.debuggerStopped];
        return !_emulator.debuggerStopped;
    }
    else if ([anItem action] == @selector(reset:) && anItem.tag != MODEL_NONE) {
        [(NSMenuItem*)anItem setState:anItem.tag == current_model];
    }
    else if ([anItem action] == @selector(interrupt:)) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DeveloperMode"]) {
            return false;
        }
    }
    else if ([anItem action] == @selector(disconnectAllAccessories:)) {
        [(NSMenuItem*)anItem setState:accessory == GBAccessoryNone];
    }
    else if ([anItem action] == @selector(connectPrinter:)) {
        [(NSMenuItem*)anItem setState:accessory == GBAccessoryPrinter];
    }
    else if ([anItem action] == @selector(connectWorkboy:)) {
        [(NSMenuItem*)anItem setState:accessory == GBAccessoryWorkboy];
    }
    else if ([anItem action] == @selector(connectLinkCable:)) {
        [(NSMenuItem*)anItem setState:[(NSMenuItem *)anItem representedObject] == master ||
                                       [(NSMenuItem *)anItem representedObject] == slave];
    }
    else if ([anItem action] == @selector(toggleCheats:)) {
        [(NSMenuItem*)anItem setState:_emulator.cheatsEnabled];
    }
    return [super validateUserInterfaceItem:anItem];
}


- (void) windowWillEnterFullScreen:(NSNotification *)notification
{
    fullScreen = true;
    self.view.mouseHidingEnabled = _emulator.running;
}

- (void) windowWillExitFullScreen:(NSNotification *)notification
{
    fullScreen = false;
    self.view.mouseHidingEnabled = NO;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame
{
    if (fullScreen) {
        return newFrame;
    }
    NSSize screenSize = _emulator.screenSize;
    
    NSRect rect = window.contentView.frame;

    unsigned titlebarSize = window.contentView.superview.frame.size.height - rect.size.height;
    unsigned step = screenSize.width / [[window screen] backingScaleFactor];

    rect.size.width = floor(rect.size.width / step) * step + step;
    rect.size.height = rect.size.width * screenSize.height / screenSize.width + titlebarSize;

    if (rect.size.width > newFrame.size.width) {
        rect.size.width = screenSize.width;
        rect.size.height = screenSize.height + titlebarSize;
    }
    else if (rect.size.height > newFrame.size.height) {
        rect.size.width = screenSize.width;
        rect.size.height = screenSize.height + titlebarSize;
    }

    rect.origin = window.frame.origin;
    rect.origin.y -= rect.size.height - window.frame.size.height;

    return rect;
}

- (void) appendPendingOutput
{
    [console_output_lock lock];
    if (shouldClearSideView) {
        shouldClearSideView = false;
        [self.debuggerSideView setString:@""];
    }
    if (pending_console_output) {
        NSTextView *textView = logToSideView? self.debuggerSideView : self.consoleOutput;
        
        [hex_controller reloadData];
        [self reloadVRAMData: nil];
        
        [textView.textStorage appendAttributedString:pending_console_output];
        [textView scrollToEndOfDocument:nil];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DeveloperMode"]) {
            [self.consoleWindow orderFront:nil];
        }
        pending_console_output = nil;
}
    [console_output_lock unlock];

}

- (IBAction)showConsoleWindow:(id)sender
{
    [self.consoleWindow orderBack:nil];
}

- (IBAction)consoleInput:(NSTextField *)sender 
{
    NSString *line = [sender stringValue];
    if ([line isEqualToString:@""] && lastConsoleInput) {
        line = lastConsoleInput;
    }
    else if (line) {
        lastConsoleInput = line;
    }
    else {
        line = @"";
    }

    if (!in_sync_input) {
        [self log:">"];
    }
    [self log:[line UTF8String]];
    [self log:"\n"];
    [has_debugger_input lock];
    [debugger_input_queue addObject:line];
    [has_debugger_input unlockWithCondition:1];

    [sender setStringValue:@""];
}

- (void) interruptDebugInputRead
{
    [has_debugger_input lock];
    [debugger_input_queue addObject:[NSNull null]];
    [has_debugger_input unlockWithCondition:1];
}

- (void) updateSideView
{

    if (!_emulator.debuggerStopped) {
        return;
    }
    
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateSideView];
        });
        return;
    }
    
    [console_output_lock lock];
    shouldClearSideView = true;
    [self appendPendingOutput];
    logToSideView = true;
    [console_output_lock unlock];
    
    for (NSString *line in [self.debuggerSideViewInput.string componentsSeparatedByString:@"\n"]) {
        [_emulator debuggerExecuteCommand:line];
    }
    
    [console_output_lock lock];
    [self appendPendingOutput];
    logToSideView = false;
    [console_output_lock unlock];
}

- (NSString *) getDebuggerInput
{
    [self updateSideView];
    [self log:">"];
    in_sync_input = true;
    [has_debugger_input lockWhenCondition:1];
    NSString *input = [debugger_input_queue firstObject];
    [debugger_input_queue removeObjectAtIndex:0];
    [has_debugger_input unlockWithCondition:[debugger_input_queue count] != 0];
    in_sync_input = false;
    shouldClearSideView = true;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC / 10)), dispatch_get_main_queue(), ^{
        if (shouldClearSideView) {
            shouldClearSideView = false;
            [self.debuggerSideView setString:@""];
        }
    });
    if ((id) input == [NSNull null]) {
        return nil;
    }
    return input;
}

- (NSString *) getAsyncDebuggerInput
{
    [has_debugger_input lock];
    NSString *input = [debugger_input_queue firstObject];
    if (input) {
        [debugger_input_queue removeObjectAtIndex:0];
    }
    [has_debugger_input unlockWithCondition:[debugger_input_queue count] != 0];
    if ((id)input == [NSNull null]) {
        return nil;
    }
    return input;
}

- (IBAction)saveState:(id)sender
{
    bool __block success = false;
    [self performAtomicBlock:^{
        success = [_emulator saveState:[[self.fileURL URLByDeletingPathExtension] URLByAppendingPathExtension:[NSString stringWithFormat:@"s%ld", (long)[sender tag] ]]] == 0;
    }];
    
    if (!success) {
        [GBWarningPopover popoverWithContents:@"Failed to write save state." onWindow:self.mainWindow];
        NSBeep();
    }
}

- (IBAction)loadState:(id)sender
{
    bool __block success = false;
    NSString *error =
    [self captureOutputForBlock:^{
        success = [_emulator loadState:[[self.fileURL URLByDeletingPathExtension] URLByAppendingPathExtension:[NSString stringWithFormat:@"s%ld", (long)[sender tag] ]]] == 0;
    }];
    
    if (!success) {
        if (error) {
            [GBWarningPopover popoverWithContents:error onWindow:self.mainWindow];
        }
        NSBeep();
    }
}

- (IBAction)clearConsole:(id)sender
{
    [self.consoleOutput setString:@""];
}

- (void)log:(const char *)log
{
    [self log:@(log) withAttributes:0];
}

- (uint8_t) readMemory:(uint16_t)addr
{
    return [_emulator readMemory:addr];
}

- (void) writeMemory:(uint16_t)addr value:(uint8_t)value
{
    [_emulator writeMemory:addr value:value];
}

- (void) performAtomicBlock: (void (^)())block
{
    while (!_emulator.isInitialized);
    bool was_running = _emulator.running && !_emulator.debuggerStopped;
    if (master) {
        was_running |= master->_emulator.running;
    }
    if (was_running) {
        [self stop];
    }
    block();
    if (was_running) {
        [self start];
    }
}

- (NSString *) captureOutputForBlock: (void (^)())block
{
    capturedOutput = [[NSMutableString alloc] init];
    [self performAtomicBlock:block];
    NSString *ret = [capturedOutput stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    capturedOutput = nil;
    return [ret length]? ret : nil;
}

- (void) reloadMemoryView
{
    if (self.memoryWindow.isVisible) {
        [hex_controller reloadData];
    }
}

- (IBAction) reloadVRAMData: (id) sender
{
    if (self.vramWindow.isVisible) {
        switch ([self.vramTabView.tabViewItems indexOfObject:self.vramTabView.selectedTabViewItem]) {
            case 0:
            /* Tileset */
            {
                GB_palette_type_t palette_type = GB_PALETTE_NONE;
                NSUInteger palette_menu_index = self.tilesetPaletteButton.indexOfSelectedItem;
                if (palette_menu_index) {
                    palette_type = palette_menu_index > 8? GB_PALETTE_OAM : GB_PALETTE_BACKGROUND;
                }
                self.tilesetImageView.image = [_emulator drawTilesetWithPaletteType:palette_type
                                                                          menuIndex:palette_menu_index];
                self.tilesetImageView.layer.magnificationFilter = kCAFilterNearest;
            }
            break;
                
            case 1:
            /* Tilemap */
            {
                GB_palette_type_t palette_type = GB_PALETTE_NONE;
                NSUInteger palette_menu_index = self.tilemapPaletteButton.indexOfSelectedItem;
                if (palette_menu_index > 1) {
                    palette_type = palette_menu_index > 9? GB_PALETTE_OAM : GB_PALETTE_BACKGROUND;
                }
                else if (palette_menu_index == 1) {
                    palette_type = GB_PALETTE_AUTO;
                }

                self.tilemapImageView.scrollRect = NSMakeRect([_emulator readMemory:0xFF00 | GB_IO_SCX],
                                                              [_emulator readMemory:0xFF00 | GB_IO_SCY],
                                                              160, 144);
                self.tilemapImageView.image =
                    [_emulator drawTilemapWithPaletteType:palette_type
                                             paletteIndex:palette_menu_index
                                                  mapType:(GB_map_type_t) self.tilemapMapButton.indexOfSelectedItem
                                              tilesetType:(GB_tileset_type_t) self.TilemapSetButton.indexOfSelectedItem];
                self.tilemapImageView.layer.magnificationFilter = kCAFilterNearest;
            }
            break;
                
            case 2:
            /* OAM */
            {
                oamCount = [_emulator getOAMInfo:oamInfo spriteHeight:&oamHeight];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!oamUpdating) {
                        oamUpdating = true;
                        [self.spritesTableView reloadData];
                        oamUpdating = false;
                    }
                });
            }
            break;
            
            case 3:
            /* Palettes */
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.paletteTableView reloadData];
                });
            }
            break;
        }
    }
}

- (IBAction) showMemory:(id)sender
{
    if (!hex_controller) {
        [self initMemoryView];
    }
    [self.memoryWindow makeKeyAndOrderFront:sender];
}

- (IBAction)hexGoTo:(id)sender
{
    NSString *error = [self captureOutputForBlock:^{
        uint16_t addr;
        if ([_emulator debuggerEvaluate:[sender stringValue] result:&addr resultBank:NULL]) {
            return;
        }
        addr -= lineRep.valueOffset;
        if (addr >= hex_controller.byteArray.length) {
            [_emulator log:"Value $%04x is out of range.\n", addr];
            return;
        }
        [hex_controller setSelectedContentsRanges:@[[HFRangeWrapper withRange:HFRangeMake(addr, 0)]]];
        [hex_controller _ensureVisibilityOfLocation:addr];
        [self.memoryWindow makeFirstResponder:self.memoryView.subviews[0].subviews[0]];
    }];
    if (error) {
        NSBeep();
        [GBWarningPopover popoverWithContents:error onView:sender];
    }
}

- (void)hexUpdateBank:(NSControl *)sender ignoreErrors: (bool)ignore_errors
{
    NSString *error = [self captureOutputForBlock:^{
        uint16_t addr, bank;
        if ([_emulator debuggerEvaluate:[sender stringValue] result:&addr resultBank:&bank]) {
            return;
        }

        if (bank == (uint16_t) -1) {
            bank = addr;
        }

        uint16_t n_banks = 1;
        switch ([(GBMemoryByteArray *)(hex_controller.byteArray) mode]) {
            case GBMemoryROM: {
                size_t rom_size;
                [_emulator getDirectAccess:GB_DIRECT_ACCESS_ROM size:&rom_size bank:NULL];
                n_banks = rom_size / 0x4000;
                break;
            }
            case GBMemoryVRAM:
                n_banks = _emulator.isCGB ? 2 : 1;
                break;
            case GBMemoryExternalRAM: {
                size_t ram_size;
                [_emulator getDirectAccess:GB_DIRECT_ACCESS_CART_RAM size:&ram_size bank:NULL];
                n_banks = (ram_size + 0x1FFF) / 0x2000;
                break;
            }
            case GBMemoryRAM:
                n_banks = _emulator.isCGB ? 8 : 1;
                break;
            case GBMemoryEntireSpace:
                break;
        }

        bank %= n_banks;

        [sender setStringValue:[NSString stringWithFormat:@"$%x", bank]];
        [(GBMemoryByteArray *)(hex_controller.byteArray) setSelectedBank:bank];
        [hex_controller reloadData];
    }];
    
    if (error && !ignore_errors) {
        NSBeep();
        [GBWarningPopover popoverWithContents:error onView:sender];
    }
}

- (IBAction)hexUpdateBank:(NSControl *)sender
{
    [self hexUpdateBank:sender ignoreErrors:false];
}

- (IBAction)hexUpdateSpace:(NSPopUpButtonCell *)sender
{
    self.memoryBankItem.enabled = [sender indexOfSelectedItem] != GBMemoryEntireSpace;
    GBMemoryByteArray *byteArray = (GBMemoryByteArray *)(hex_controller.byteArray);
    [byteArray setMode:(GB_memory_mode_t)[sender indexOfSelectedItem]];
    uint16_t bank;
    switch ((GB_memory_mode_t)[sender indexOfSelectedItem]) {
        case GBMemoryEntireSpace:
        case GBMemoryROM:
            lineRep.valueOffset = 0;
            [_emulator getDirectAccess:GB_DIRECT_ACCESS_ROM size:NULL bank:&bank];
            byteArray.selectedBank = bank;
            break;
        case GBMemoryVRAM:
            lineRep.valueOffset = 0x8000;
            [_emulator getDirectAccess:GB_DIRECT_ACCESS_VRAM size:NULL bank:&bank];
            byteArray.selectedBank = bank;
            break;
        case GBMemoryExternalRAM:
            lineRep.valueOffset = 0xA000;
            [_emulator getDirectAccess:GB_DIRECT_ACCESS_CART_RAM size:NULL bank:&bank];
            byteArray.selectedBank = bank;
            break;
        case GBMemoryRAM:
            lineRep.valueOffset = 0xC000;
            [_emulator getDirectAccess:GB_DIRECT_ACCESS_RAM size:NULL bank:&bank];
            byteArray.selectedBank = bank;
            break;
    }
    [self.memoryBankInput setStringValue:[NSString stringWithFormat:@"$%x", byteArray.selectedBank]];
    [hex_controller reloadData];
    [self.memoryView setNeedsDisplay:YES];
}

+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName
{
    return YES;
}

- (IBAction)toggleTilesetGrid:(NSButton *)sender
{
    if (sender.state) {
        self.tilesetImageView.horizontalGrids = @[
                                                  [[GBImageViewGridConfiguration alloc] initWithColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.25] size:8],
                                                  [[GBImageViewGridConfiguration alloc] initWithColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.5] size:128],
                                                  
        ];
        self.tilesetImageView.verticalGrids = @[
                                                  [[GBImageViewGridConfiguration alloc] initWithColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.25] size:8],
                                                  [[GBImageViewGridConfiguration alloc] initWithColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.5] size:64],
        ];
        self.tilemapImageView.horizontalGrids = @[
                                                  [[GBImageViewGridConfiguration alloc] initWithColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.25] size:8],
                                                  ];
        self.tilemapImageView.verticalGrids = @[
                                                [[GBImageViewGridConfiguration alloc] initWithColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.25] size:8],
                                                ];
    }
    else {
        self.tilesetImageView.horizontalGrids = nil;
        self.tilesetImageView.verticalGrids = nil;
        self.tilemapImageView.horizontalGrids = nil;
        self.tilemapImageView.verticalGrids = nil;
    }
}

- (IBAction)toggleScrollingDisplay:(NSButton *)sender
{
    self.tilemapImageView.displayScrollRect = sender.state;
}

- (IBAction)vramTabChanged:(NSSegmentedControl *)sender
{
    [self.vramTabView selectTabViewItemAtIndex:[sender selectedSegment]];
    [self reloadVRAMData:sender];
    [self.vramTabView.selectedTabViewItem.view addSubview:self.gridButton];
    self.gridButton.hidden = [sender selectedSegment] >= 2;

    NSUInteger height_diff = self.vramWindow.frame.size.height - self.vramWindow.contentView.frame.size.height;
    CGRect window_rect = self.vramWindow.frame;
    window_rect.origin.y += window_rect.size.height;
    switch ([sender selectedSegment]) {
        case 0:
            window_rect.size.height = 384 + height_diff + 48;
            break;
        case 1:
        case 2:
            window_rect.size.height = 512 + height_diff + 48;
            break;
        case 3:
            window_rect.size.height = 20 * 16 + height_diff + 24;
            break;
            
        default:
            break;
    }
    window_rect.origin.y -= window_rect.size.height;
    [self.vramWindow setFrame:window_rect display:YES animate:YES];
}

- (void)mouseDidLeaveImageView:(GBImageView *)view
{
    self.vramStatusLabel.stringValue = @"";
}

- (void)imageView:(GBImageView *)view mouseMovedToX:(NSUInteger)x Y:(NSUInteger)y
{
    if (view == self.tilesetImageView) {
        uint8_t bank = x >= 128? 1 : 0;
        x &= 127;
        uint16_t tile = x / 8 + y / 8 * 16;
        self.vramStatusLabel.stringValue = [NSString stringWithFormat:@"Tile number $%02x at %d:$%04x", tile & 0xFF, bank, 0x8000 + tile * 0x10];
    }
    else if (view == self.tilemapImageView) {
        uint16_t map_offset = x / 8 + y / 8 * 32;
        uint16_t map_base = 0x1800;
        GB_map_type_t map_type = (GB_map_type_t) self.tilemapMapButton.indexOfSelectedItem;
        GB_tileset_type_t tileset_type = (GB_tileset_type_t) self.TilemapSetButton.indexOfSelectedItem;
        uint8_t lcdc = ((uint8_t *)[_emulator getDirectAccess:GB_DIRECT_ACCESS_IO size:NULL bank:NULL])[GB_IO_LCDC];
        uint8_t *vram = [_emulator getDirectAccess:GB_DIRECT_ACCESS_VRAM size:NULL bank:NULL];
        
        if (map_type == GB_MAP_9C00 || (map_type == GB_MAP_AUTO && lcdc & 0x08)) {
            map_base = 0x1c00;
        }
        
        if (tileset_type == GB_TILESET_AUTO) {
            tileset_type = (lcdc & 0x10)? GB_TILESET_8800 : GB_TILESET_8000;
        }
        
        uint8_t tile = vram[map_base + map_offset];
        uint16_t tile_address = 0;
        if (tileset_type == GB_TILESET_8000) {
            tile_address = 0x8000 + tile * 0x10;
        }
        else {
            tile_address = 0x9000 + (int8_t)tile * 0x10;
        }
        
        if (_emulator.isCGB) {
            uint8_t attributes = vram[map_base + map_offset + 0x2000];
            self.vramStatusLabel.stringValue = [NSString stringWithFormat:@"Tile number $%02x (%d:$%04x) at map address $%04x (Attributes: %c%c%c%d%d)",
                                                tile,
                                                attributes & 0x8? 1 : 0,
                                                tile_address,
                                                0x8000 + map_base + map_offset,
                                                (attributes & 0x80) ? 'P' : '-',
                                                (attributes & 0x40) ? 'V' : '-',
                                                (attributes & 0x20) ? 'H' : '-',
                                                attributes & 0x8? 1 : 0,
                                                attributes & 0x7
                                                ];
        }
        else {
            self.vramStatusLabel.stringValue = [NSString stringWithFormat:@"Tile number $%02x ($%04x) at map address $%04x",
                                                tile,
                                                tile_address,
                                                0x8000 + map_base + map_offset
                                                ];
        }

    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == self.paletteTableView) {
        return 16; /* 8 BG palettes, 8 OBJ palettes*/
    }
    else if (tableView == self.spritesTableView) {
        return oamCount;
    }
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSUInteger columnIndex = [[tableView tableColumns] indexOfObject:tableColumn];
    if (tableView == self.paletteTableView) {
        if (columnIndex == 0) {
            return [NSString stringWithFormat:@"%s %u", row >= 8 ? "Object" : "Background", (unsigned)(row & 7)];
        }

        uint8_t *palette_data = [_emulator getDirectAccess:row >= 8? GB_DIRECT_ACCESS_OBP : GB_DIRECT_ACCESS_BGP size:NULL bank:NULL];

        uint16_t index = columnIndex - 1 + (row & 7) * 4;
        return @((palette_data[(index << 1) + 1] << 8) | palette_data[(index << 1)]);
    }
    else if (tableView == self.spritesTableView) {
        switch (columnIndex) {
            case 0:
                return [Emulator imageFromData:[NSData dataWithBytesNoCopy:oamInfo[row].image
                                                                    length:64 * 4 * 2
                                                             freeWhenDone:NO]
                                         width:8
                                        height:oamHeight
                                         scale:16.0/oamHeight];
            case 1:
                return @((unsigned)oamInfo[row].x - 8);
            case 2:
                return @((unsigned)oamInfo[row].y - 16);
            case 3:
                return [NSString stringWithFormat:@"$%02x", oamInfo[row].tile];
            case 4:
                return [NSString stringWithFormat:@"$%04x", 0x8000 + oamInfo[row].tile * 0x10];
            case 5:
                return [NSString stringWithFormat:@"$%04x", oamInfo[row].oam_addr];
            case 6:
                if (_emulator.isCGB) {
                    return [NSString stringWithFormat:@"%c%c%c%d%d",
                            oamInfo[row].flags & 0x80? 'P' : '-',
                            oamInfo[row].flags & 0x40? 'Y' : '-',
                            oamInfo[row].flags & 0x20? 'X' : '-',
                            oamInfo[row].flags & 0x08? 1 : 0,
                            oamInfo[row].flags & 0x07];
                }
                return [NSString stringWithFormat:@"%c%c%c%d",
                        oamInfo[row].flags & 0x80? 'P' : '-',
                        oamInfo[row].flags & 0x40? 'Y' : '-',
                        oamInfo[row].flags & 0x20? 'X' : '-',
                        oamInfo[row].flags & 0x10? 1 : 0];
            case 7:
                return oamInfo[row].obscured_by_line_limit? @"Dropped: Too many sprites in line": @"";

        }
    }
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return tableView == self.spritesTableView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (IBAction)showVRAMViewer:(id)sender
{
    [self.vramWindow makeKeyAndOrderFront:sender];
    [self reloadVRAMData: nil];
}

- (void)printDocument:(id)sender
{
    if (self.feedImageView.image.size.height == 0) {
        NSBeep(); return;
    }
    NSImageView *view = [[NSImageView alloc] initWithFrame:(NSRect){{0,0}, self.feedImageView.image.size}];
    view.image = self.feedImageView.image;
    [[NSPrintOperation printOperationWithView:view] runOperationModalForWindow:self.printerFeedWindow delegate:nil didRunSelector:NULL contextInfo:NULL];
}

- (IBAction)savePrinterFeed:(id)sender
{
    bool shouldResume = _emulator.running;
    [self stop];
    NSSavePanel * savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"png"]];
    [savePanel beginSheetModalForWindow:self.printerFeedWindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            [savePanel orderOut:self];
            CGImageRef cgRef = [self.feedImageView.image CGImageForProposedRect:NULL
                                                                        context:nil
                                                                          hints:nil];
            NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
            [imageRep setSize:(NSSize){160, self.feedImageView.image.size.height / 2}];
            NSData *data = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
            [data writeToURL:savePanel.URL atomically:NO];
            [self.printerFeedWindow setIsVisible:NO];
        }
        if (shouldResume) {
            [self start];
        }
    }];
}

- (IBAction)disconnectAllAccessories:(id)sender
{
    [self disconnectLinkCable];
    [self performAtomicBlock:^{
        accessory = GBAccessoryNone;
        [_emulator disconnectSerial];
    }];
}

- (IBAction)connectPrinter:(id)sender
{
    [self disconnectLinkCable];
    [self performAtomicBlock:^{
        accessory = GBAccessoryPrinter;
        [_emulator connectPrinter];
    }];
}

- (IBAction)connectWorkboy:(id)sender
{
    [self disconnectLinkCable];
    [self performAtomicBlock:^{
        accessory = GBAccessoryWorkboy;
        [_emulator connectWorkboyWithSetTimeCallback:setWorkboyTime getTimeCallback:getWorkboyTime];
    }];
}

- (void) updateHighpassFilter
{
    if (_emulator.isInitialized) {
        _emulator.highPassMode = (GB_highpass_mode_t) [[NSUserDefaults standardUserDefaults] integerForKey:@"GBHighpassFilter"];
    }
}

- (void) updateColorCorrectionMode
{
    if (_emulator.isInitialized) {
        _emulator.colorCorrectionMode = (GB_color_correction_mode_t) [[NSUserDefaults standardUserDefaults] integerForKey:@"GBColorCorrection"];
    }
}

- (void) updateLightTemperature
{
    if (_emulator.isInitialized) {
        _emulator.lightTemperature = [[NSUserDefaults standardUserDefaults] doubleForKey:@"GBLightTemperature"];
    }
}

- (void) updateInterferenceVolume
{
    if (_emulator.isInitialized) {
        _emulator.interferenceVolume = [[NSUserDefaults standardUserDefaults] doubleForKey:@"GBInterferenceVolume"];
    }
}

- (void) updateFrameBlendingMode
{
    self.view.frameBlendingMode = (GB_frame_blending_mode_t) [[NSUserDefaults standardUserDefaults] integerForKey:@"GBFrameBlendingMode"];
}

- (void) updateRewindLength
{
    [self performAtomicBlock:^{
        if (_emulator.isInitialized) {
            _emulator.rewindLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"GBRewindLength"];
        }
    }];
}

- (void)dmgModelChanged
{
    modelsChanging = true;
    if (current_model == MODEL_DMG) {
        [self reset:nil];
    }
    modelsChanging = false;
}

- (void)sgbModelChanged
{
    modelsChanging = true;
    if (current_model == MODEL_SGB) {
        [self reset:nil];
    }
    modelsChanging = false;
}

- (void)cgbModelChanged
{
    modelsChanging = true;
    if (current_model == MODEL_CGB) {
        [self reset:nil];
    }
    modelsChanging = false;
}

- (void)setFileURL:(NSURL *)fileURL
{
    [super setFileURL:fileURL];
    self.consoleWindow.title = [NSString stringWithFormat:@"Debug Console – %@", [[fileURL path] lastPathComponent]];
    
}

- (BOOL)splitView:(GBSplitView *)splitView canCollapseSubview:(NSView *)subview;
{
    if ([[splitView arrangedSubviews] lastObject] == subview) {
        return YES;
    }
    return NO;
}

- (CGFloat)splitView:(GBSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return 600;
}

- (CGFloat)splitView:(GBSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex 
{
    return splitView.frame.size.width - 321;
}

- (BOOL)splitView:(GBSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view 
{
    if ([[splitView arrangedSubviews] lastObject] == view) {
        return NO;
    }
    return YES;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    GBSplitView *splitview = notification.object;
    if ([[[splitview arrangedSubviews] firstObject] frame].size.width < 600) {
        [splitview setPosition:600 ofDividerAtIndex:0];
    }
    /* NSSplitView renders its separator without the proper vibrancy, so we made it transparent and move an
       NSBox-based separator that renders properly so it acts like the split view's separator. */
    NSRect rect = self.debuggerVerticalLine.frame;
    rect.origin.x = [[[splitview arrangedSubviews] firstObject] frame].size.width - 1;
    self.debuggerVerticalLine.frame = rect;
}

- (IBAction)showCheats:(id)sender
{
    [self.cheatsWindow makeKeyAndOrderFront:nil];
}

- (IBAction)toggleCheats:(id)sender
{
    _emulator.cheatsEnabled = !_emulator.cheatsEnabled;
}

- (void)disconnectLinkCable
{
    bool wasRunning = self->_emulator.running;
    Document *partner = master ?: slave;
    if (partner) {
        [self stop];
        partner->master = nil;
        partner->slave = nil;
        master = nil;
        slave = nil;
        if (wasRunning) {
            [partner start];
            [self start];
        }
        [_emulator setTurboMode:false noFrameSkip:false];
        [partner->_emulator setTurboMode:false noFrameSkip:false];
        partner->accessory = GBAccessoryNone;
        accessory = GBAccessoryNone;
    }
}

- (void)connectLinkCable:(NSMenuItem *)sender
{
    [self disconnectAllAccessories:sender];
    Document *partner = [sender representedObject];
    [partner disconnectAllAccessories:sender];
    
    bool wasRunning = self->_emulator.running;
    [self stop];
    [partner stop];
    [partner->_emulator setTurboMode:true noFrameSkip:true];

    // Bind the two _emulators + documents together. Note: this creates a retain cycle.
    slave = partner;
    partner->master = self;
    [_emulator connectLinkCableToEmulator:partner->_emulator];

    partner->accessory = GBAccessoryLinkCable;
    accessory = GBAccessoryLinkCable;
    if (wasRunning) {
        [self start];
    }
}

#pragma mark - EmulatorDelegate

- (BOOL)isRewinding {
    return self.view.isRewinding;
}

- (BOOL)isMuted {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"Mute"];
}

- (void)willRun {
    _emulator.lcdOutput = self.view.pixels;
    hex_timer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(reloadMemoryView) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:hex_timer forMode:NSDefaultRunLoopMode];

    /* Clear pending alarms, don't play alarms while playing */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"GBNotificationsUsed"]) {
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        for (NSUserNotification *notification in [center scheduledNotifications]) {
            if ([notification.identifier isEqualToString:self.fileURL.path]) {
                [center removeScheduledNotification:notification];
                break;
            }
        }

        for (NSUserNotification *notification in [center deliveredNotifications]) {
            if ([notification.identifier isEqualToString:self.fileURL.path]) {
                [center removeDeliveredNotification:notification];
                break;
            }
        }
    }
}

- (void)didRun {
    [hex_timer invalidate];
    self.view.mouseHidingEnabled = NO;
    [_emulator saveBattery:[[self.fileURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"sav"]];
    [_emulator saveCheats:[[self.fileURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"cht"]];

    unsigned time_to_alarm = _emulator.timeToAlarm;

    if (time_to_alarm) {
        [NSUserNotificationCenter defaultUserNotificationCenter].delegate = (id)[NSApp delegate];
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        NSString *friendlyName = [[self.fileURL lastPathComponent] stringByDeletingPathExtension];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\([^)]+\\)|\\[[^\\]]+\\]" options:0 error:nil];
        friendlyName = [regex stringByReplacingMatchesInString:friendlyName options:0 range:NSMakeRange(0, [friendlyName length]) withTemplate:@""];
        friendlyName = [friendlyName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        notification.title = [NSString stringWithFormat:@"%@ Played an Alarm", friendlyName];
        notification.informativeText = [NSString stringWithFormat:@"%@ requested your attention by playing a scheduled alarm", friendlyName];
        notification.identifier = self.fileURL.path;
        notification.deliveryDate = [NSDate dateWithTimeIntervalSinceNow:time_to_alarm];
        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"GBNotificationsUsed"];
    }
    [_view setRumble:0];
}

#pragma mark - CallbackBridgeDelegate

- (void) loadBootROM: (GB_boot_rom_t)type
{
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
    [_emulator loadBootROM:[self bootROMPathForName:names[type]]];
}

- (void) vblank
{
    [self.view flip];
    if (borderModeChanged) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            size_t previous_width = _emulator.screenSize.width;
            _emulator.borderMode = (GB_border_mode_t) [[NSUserDefaults standardUserDefaults] integerForKey:@"GBBorderMode"];
            if (_emulator.screenSize.width != previous_width) {
                [self.view screenSizeChanged];
                [self updateMinSize];
            }
        });
        borderModeChanged = false;
    }
    _emulator.lcdOutput = self.view.pixels;
    if (self.vramWindow.isVisible) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.mouseHidingEnabled = (self.mainWindow.styleMask & NSWindowStyleMaskFullScreen) != 0;
            [self reloadVRAMData: nil];
        });
    }
    if (self.view.isRewinding) {
        _emulator.rewind = true;
    }
}

- (void) log: (const char *) string withAttributes: (GB_log_attributes) attributes
{
    NSString *nsstring = @(string); // For ref-counting
    if (capturedOutput) {
        [capturedOutput appendString:nsstring];
        return;
    }


    NSFont *font = [NSFont userFixedPitchFontOfSize:12];
    NSUnderlineStyle underline = NSUnderlineStyleNone;
    if (attributes & GB_LOG_BOLD) {
        font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
    }

    if (attributes &  GB_LOG_UNDERLINE_MASK) {
        underline = (attributes &  GB_LOG_UNDERLINE_MASK) == GB_LOG_DASHED_UNDERLINE? NSUnderlinePatternDot | NSUnderlineStyleSingle : NSUnderlineStyleSingle;
    }

    NSMutableParagraphStyle *paragraph_style = [[NSMutableParagraphStyle alloc] init];
    [paragraph_style setLineSpacing:2];
    NSMutableAttributedString *attributed =
    [[NSMutableAttributedString alloc] initWithString:nsstring
                                           attributes:@{NSFontAttributeName: font,
                                                        NSForegroundColorAttributeName: [NSColor whiteColor],
                                                        NSUnderlineStyleAttributeName: @(underline),
                                                        NSParagraphStyleAttributeName: paragraph_style}];

    [console_output_lock lock];
    if (!pending_console_output) {
        pending_console_output = attributed;
    }
    else {
        [pending_console_output appendAttributedString:attributed];
    }

    if (![console_output_timer isValid]) {
        console_output_timer = [NSTimer timerWithTimeInterval:(NSTimeInterval)0.05 target:self selector:@selector(appendPendingOutput) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:console_output_timer forMode:NSDefaultRunLoopMode];
    }

    [console_output_lock unlock];

    /* Make sure mouse is not hidden while debugging */
    self.view.mouseHidingEnabled = NO;
}

- (uint8_t)cameraGetPixelAtX:(uint8_t)x andY:(uint8_t) y
{
    if (!cameraImage) {
        return 0;
    }

    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(cameraImage);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(cameraImage);
    uint8_t offsetX = (CVPixelBufferGetWidth(cameraImage) - 128) / 2;
    uint8_t offsetY = (CVPixelBufferGetHeight(cameraImage) - 112) / 2;
    uint8_t ret = baseAddress[(x + offsetX) * 2 + (y + offsetY) * bytesPerRow];

    return ret;
}

- (void)cameraRequestUpdate
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            if (!cameraSession) {
                if (@available(macOS 10.14, *)) {
                    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
                        case AVAuthorizationStatusAuthorized:
                            break;
                        case AVAuthorizationStatusNotDetermined: {
                            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                                [self cameraRequestUpdate];
                            }];
                            return;
                        }
                        case AVAuthorizationStatusDenied:
                        case AVAuthorizationStatusRestricted:
                            [_emulator cameraDidUpdate];
                            return;
                    }
                }

                NSError *error;
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice: device error: &error];
                CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions([[[device formats] firstObject] formatDescription]);

                if (!input) {
                    [_emulator cameraDidUpdate];
                    return;
                }

                cameraOutput = [[AVCaptureStillImageOutput alloc] init];
                /* Greyscale is not widely supported, so we use YUV, whose first element is the brightness. */
                [cameraOutput setOutputSettings: @{(id)kCVPixelBufferPixelFormatTypeKey: @(kYUVSPixelFormat),
                                                   (id)kCVPixelBufferWidthKey: @(MAX(128, 112 * dimensions.width / dimensions.height)),
                                                   (id)kCVPixelBufferHeightKey: @(MAX(112, 128 * dimensions.height / dimensions.width)),}];


                cameraSession = [AVCaptureSession new];
                cameraSession.sessionPreset = AVCaptureSessionPresetPhoto;

                [cameraSession addInput: input];
                [cameraSession addOutput: cameraOutput];
                [cameraSession startRunning];
                cameraConnection = [cameraOutput connectionWithMediaType: AVMediaTypeVideo];
            }

            [cameraOutput captureStillImageAsynchronouslyFromConnection: cameraConnection completionHandler: ^(CMSampleBufferRef sampleBuffer, NSError *error) {
                if (error) {
                    [_emulator cameraDidUpdate];
                }
                else {
                    if (cameraImage) {
                        CVBufferRelease(cameraImage);
                        cameraImage = NULL;
                    }
                    cameraImage = CVBufferRetain(CMSampleBufferGetImageBuffer(sampleBuffer));
                    /* We only need the actual buffer, no need to ever unlock it. */
                    CVPixelBufferLockBaseAddress(cameraImage, 0);
                }

                [_emulator cameraDidUpdate];
            }];
        }
        @catch (NSException *exception) {
            /* I have not tested camera support on many devices, so we catch exceptions just in case. */
            [_emulator cameraDidUpdate];
        }
    });
}

- (void)gotNewSample:(GB_sample_t *)sample {
    [_emulator gotNewSample:sample];
}

- (void) printImage:(uint32_t *)imageBytes height:(unsigned) height
          topMargin:(unsigned) topMargin bottomMargin: (unsigned) bottomMargin
           exposure:(unsigned) exposure
{
    uint32_t paddedImage[160 * (topMargin + height + bottomMargin)];
    memset(paddedImage, 0xFF, sizeof(paddedImage));
    memcpy(paddedImage + (160 * topMargin), imageBytes, 160 * height * sizeof(imageBytes[0]));
    if (!self.printerFeedWindow.isVisible) {
        currentPrinterImageData = [[NSMutableData alloc] init];
    }
    [currentPrinterImageData appendBytes:paddedImage length:sizeof(paddedImage)];
    /* UI related code must run on main thread. */
    dispatch_async(dispatch_get_main_queue(), ^{
        self.feedImageView.image = [Emulator imageFromData:currentPrinterImageData
                                                     width:160
                                                    height:currentPrinterImageData.length / 160 / sizeof(imageBytes[0])
                                                     scale:2.0];
        NSRect frame = self.printerFeedWindow.frame;
        frame.size = self.feedImageView.image.size;
        [self.printerFeedWindow setContentMaxSize:frame.size];
        frame.size.height += self.printerFeedWindow.frame.size.height - self.printerFeedWindow.contentView.frame.size.height;
        [self.printerFeedWindow setFrame:frame display:NO animate: self.printerFeedWindow.isVisible];
        [self.printerFeedWindow orderFront:NULL];
    });
}

- (void)rumbleChanged:(double)amp
{
    [_view setRumble:amp];
}

- (void)linkCableBitStart:(bool)bit
{
    linkCableBit = bit;
}

- (bool)linkCableBitEnd
{
    bool ret = self.partner->_emulator.serialDataBit;
    self.partner->_emulator.serialDataBit = linkCableBit;
    return ret;
}

- (void)infraredStateChanged:(bool)state
{
    if (self.partner) {
        self.partner->_emulator.infraredInput = state;
    }
}

@end