//
//  NSString+EPS.h
//  AniPhoto
//
//  Created by LAP14667 on 29/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (EPS)

- (CGSize)sizeOfStringWithStyledFont:(UIFont*)styledFont withSize:(CGSize)size;
- (CGSize)sizeOfStringWithStyledFont:(UIFont*)styledFont withSize:(CGSize)size withLineBreakMode:(NSLineBreakMode)lineBreakMode;
- (CGSize)sizeOfStringWithStyledFont:(UIFont*)styledFont withSize:(CGSize)size withOptions:(NSStringDrawingOptions)options;
- (CGSize)sizeOfStringWithStyledFont:(UIFont *)styledFont maxWidth:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;
- (CGSize)sizeOfStringWithAttributes:(NSDictionary *)attributes maxSize:(CGSize)maxSize numberOfLines:(NSInteger)numberOfLines;

@end

NS_ASSUME_NONNULL_END
