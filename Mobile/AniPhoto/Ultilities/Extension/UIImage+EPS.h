//
//  UIImage+EPS.h
//  AniPhoto
//
//  Created by PhatCH on 17/4/24.
//

#import <UIKit/UIKit.h>
#import "EPSImageHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (EPS)

- (UIImage*)scaleToSize:(CGSize)size;

- (NSData *)imageData;

- (NSString *)imageFileSize;

- (NSString *)imageFileType;

- (UIImage *)normalizedImage;

- (UIImage *)reflectedImageWithHeight:(NSUInteger)height fromAlpha:(float)fromAlpha toAlpha:(float)toAlpha;

+ (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)imgBounds;

@end

NS_ASSUME_NONNULL_END
