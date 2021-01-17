#import <Cocoa/Cocoa.h>

@class Emulator;

@interface GBTerminalTextFieldCell : NSTextFieldCell
@property (nonatomic) Emulator *emulator;
@end
