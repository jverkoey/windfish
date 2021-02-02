#import <Foundation/Foundation.h>

@interface WINDStringAttributes: NSObject

+ (nonnull instancetype)baseAttributes;
+ (nonnull instancetype)opcodeAttributes;
+ (nonnull instancetype)macroAttributes;
+ (nonnull instancetype)commentAttributes;

- (nonnull NSAttributedString *)attributedStringWithString:(nonnull NSString *)string;

- (void)addToAttributedString:(nonnull NSMutableAttributedString *)string atRange:(NSRange)range;

@end
