//
//  EPS.m
//  AniPhoto
//
//  Created by PhatCH on 05/03/2024.
//

#import "UIColor+EPS.h"

@implementation UIColor (EPS)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    hexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }

    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];

    CGFloat red = ((rgbValue & 0xFF0000) >> 16) / 255.0;
    CGFloat green = ((rgbValue & 0x00FF00) >> 8) / 255.0;
    CGFloat blue = (rgbValue & 0x0000FF) / 255.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)customYellow {
    return [UIColor colorWithHexString:@"#FFCD55"];
}

+ (UIColor *)customOrange {
    return [UIColor colorWithHexString:@"#FF6914"];
}

+ (UIColor *)customBlue {
    return [UIColor colorWithHexString:@"#50EEE4"];
}

+ (UIColor *)customGreen {
    return [UIColor colorWithHexString:@"#69F964"];
}

+ (UIColor *)customPink {
    return [UIColor colorWithHexString:@"#F62A6E"];
}

+ (UIColor *)customPurple {
    return [UIColor colorWithHexString:@"#8934F1"];
}

@end

