#import "WINDStringAttributes.h"

#import <Cocoa/Cocoa.h>

@implementation WINDStringAttributes {
  NSDictionary<NSAttributedStringKey, id> *_attributes;
}

+ (NSFont *)font __attribute__((objc_direct)) {
  return [NSFont monospacedSystemFontOfSize: 11 weight: NSFontWeightRegular];
}

+ (instancetype)baseAttributes {
  WINDStringAttributes *attributes = [[WINDStringAttributes alloc] init];
  attributes->_attributes = @{
    NSForegroundColorAttributeName: NSColor.textColor,
    NSFontAttributeName: [self font],
  };
  return attributes;
}

+ (instancetype)opcodeAttributes {
  WINDStringAttributes *attributes = [[WINDStringAttributes alloc] init];
  attributes->_attributes = @{
    NSForegroundColorAttributeName: NSColor.systemGreenColor,
    NSFontAttributeName: [self font],
  };
  return attributes;
}

+ (instancetype)macroAttributes {
  WINDStringAttributes *attributes = [[WINDStringAttributes alloc] init];
  attributes->_attributes = @{
    NSForegroundColorAttributeName: NSColor.systemBrownColor,
    NSFontAttributeName: [self font],
  };
  return attributes;
}

+ (instancetype)commentAttributes {
  WINDStringAttributes *attributes = [[WINDStringAttributes alloc] init];
  attributes->_attributes = @{
    NSForegroundColorAttributeName: NSColor.systemGreenColor,
    NSFontAttributeName: [self font],
  };
  return attributes;
}

- (NSAttributedString *)attributedStringWithString:(nonnull NSString *)string {
  return [[NSAttributedString alloc] initWithString:string attributes:_attributes];
}

- (void)addToAttributedString:(nonnull NSMutableAttributedString *)string atRange:(NSRange)range {
  [string addAttributes:_attributes range:range];
}

@end

@implementation NSMutableAttributedString (WindfishPerformance)

- (void)wind_addAttribute:(nonnull NSAttributedStringKey)name value:(nullable id)value range:(NSRange)range {
  [self addAttribute:name value:value range:range];
}

@end
