#import <Cocoa/Cocoa.h>
#import <JoyKit/JoyKit.h>
@class Document;
@class Emulator;

typedef enum {
    GB_FRAME_BLENDING_MODE_DISABLED,
    GB_FRAME_BLENDING_MODE_SIMPLE,
    GB_FRAME_BLENDING_MODE_ACCURATE,
    GB_FRAME_BLENDING_MODE_ACCURATE_EVEN = GB_FRAME_BLENDING_MODE_ACCURATE,
    GB_FRAME_BLENDING_MODE_ACCURATE_ODD,
} GB_frame_blending_mode_t;

@interface GBView : NSView<JOYListener>
- (void) flip;
- (uint32_t *) pixels;
@property (nonatomic, weak) IBOutlet Document *document;
@property (nonatomic) Emulator *emulator;
@property (nonatomic) GB_frame_blending_mode_t frameBlendingMode;
@property (nonatomic, getter=isMouseHidingEnabled) BOOL mouseHidingEnabled;
@property (nonatomic) bool isRewinding;
@property (nonatomic, strong) NSView *internalView;
- (void) createInternalView;
- (uint32_t *)currentBuffer;
- (uint32_t *)previousBuffer;
- (void)screenSizeChanged;
- (void)setRumble: (double)amp;
@end
