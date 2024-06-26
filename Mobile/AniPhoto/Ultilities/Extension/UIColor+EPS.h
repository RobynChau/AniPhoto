//
//  EPS.h
//  AniPhoto
//
//  Created by PhatCH on 05/03/2024.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (EPS)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)customBlue;
+ (UIColor *)customGreen;
+ (UIColor *)customYellow;
+ (UIColor *)customOrange;
+ (UIColor *)customPink;
+ (UIColor *)customPurple;
@end

NS_ASSUME_NONNULL_END
