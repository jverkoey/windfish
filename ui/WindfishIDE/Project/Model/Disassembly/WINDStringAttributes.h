#import <Foundation/Foundation.h>

// Work around https://bugs.swift.org/browse/SR-6197 which causes NSMutableAttributedString performance to tank when any
// attribute modification occurs from Swift.

@interface WINDStringAttributes: NSObject

+ (nonnull instancetype)baseAttributes;
+ (nonnull instancetype)opcodeAttributes;
+ (nonnull instancetype)macroAttributes;
+ (nonnull instancetype)commentAttributes;

- (nonnull NSAttributedString *)attributedStringWithString:(nonnull NSString *)string;

- (void)addToAttributedString:(nonnull NSMutableAttributedString *)string atRange:(NSRange)range;
- (void)setAttribute:(nonnull NSAttributedStringKey)attribute toValue:(nullable id)value;

@end

@interface NSMutableAttributedString (WindfishPerformance)

- (void)wind_addAttribute:(nonnull NSAttributedStringKey)name value:(nullable id)value range:(NSRange)range;

@end
