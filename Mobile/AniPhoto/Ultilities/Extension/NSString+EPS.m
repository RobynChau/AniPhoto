//
//  NSString+EPS.m
//  AniPhoto
//
//  Created by PhatCH on 29/4/24.
//

#import "NSString+EPS.h"

@implementation NSString (EPS)

- (CGSize)sizeOfStringWithStyledFont:(UIFont*)styledFont withSize:(CGSize)size {
    CGSize estimatedSize = size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        estimatedSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX);
    }

    NSAttributedString *attributedText = nil;
    if (styledFont) {
        attributedText = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:styledFont}];
    }
    else {
        attributedText = [[NSAttributedString alloc] initWithString:self];
    }
    CGSize tempSize = [attributedText boundingRectWithSize:estimatedSize
                                                   options:(NSStringDrawingUsesLineFragmentOrigin)
                                                   context:nil].size;
    return CGSizeMake(ceilf(tempSize.width), ceilf(tempSize.height));
}

- (CGSize)sizeOfStringWithStyledFont:(UIFont*)styledFont withSize:(CGSize)size withLineBreakMode:(NSLineBreakMode)lineBreakMode {
    CGSize estimatedSize = size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        estimatedSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX);
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:styledFont, NSParagraphStyleAttributeName:paragraphStyle}];
    CGSize tempSize = [attributedText boundingRectWithSize:estimatedSize
                                                   options:(NSStringDrawingUsesLineFragmentOrigin)
                                                   context:nil].size;
    return CGSizeMake(ceilf(tempSize.width), ceilf(tempSize.height));
}

- (CGSize)sizeOfStringWithStyledFont:(UIFont*)styledFont withSize:(CGSize)size withOptions:(NSStringDrawingOptions)options {
    CGSize estimatedSize = size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        estimatedSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX);
    }

    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:styledFont}];
    CGSize tempSize = [attributedText boundingRectWithSize:estimatedSize
                                                   options:options
                                                   context:nil].size;
    return CGSizeMake(ceilf(tempSize.width), ceilf(tempSize.height));
}

- (CGSize)sizeOfStringWithStyledFont:(UIFont *)styledFont maxWidth:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    CGSize estimatedSize = CGSizeMake(width > 0 ? width : [UIScreen mainScreen].bounds.size.width
                                      , numberOfLines > 0 ? numberOfLines * styledFont.lineHeight : CGFLOAT_MAX);
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:styledFont}];
    CGSize tempSize = [attributedText boundingRectWithSize:estimatedSize
                                                   options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                   context:nil].size;
    return CGSizeMake(ceilf(tempSize.width), ceilf(tempSize.height));
}

- (CGSize)sizeOfStringWithAttributes:(NSDictionary *)attributes maxSize:(CGSize)maxSize numberOfLines:(NSInteger)numberOfLines {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self attributes:attributes];

    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:maxSize];
    textContainer.maximumNumberOfLines = numberOfLines;
    textContainer.lineFragmentPadding = 0;
    textContainer.lineBreakMode = NSLineBreakByTruncatingTail;

    NSLayoutManager *layoutManager = [NSLayoutManager new];
    layoutManager.textStorage = textStorage;
    [layoutManager addTextContainer:textContainer];

    return [layoutManager boundingRectForGlyphRange:NSMakeRange(0, textStorage.length) inTextContainer:textContainer].size;
}

@end
