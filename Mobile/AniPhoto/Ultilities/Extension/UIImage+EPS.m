//
//  UIImage+EPS.m
//  AniPhoto
//
//  Created by PhatCH on 17/4/24.
//

#import "UIImage+EPS.h"

@implementation UIImage (EPS)

- (UIImage *)scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    CGRect rect = {0,0,size.width,size.height};
    [self drawInRect:rect];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (NSData *)imageData {
    return UIImagePNGRepresentation(self) ? : UIImageJPEGRepresentation(self, 1.0);
}

- (NSString *)imageFileSize {
    NSData *imageData = [self imageData];

    if (!imageData) {
        return @"Unknown";
    }

    double size = (double)imageData.length;

    if (size < 1024) {
        return [NSString stringWithFormat:@"%.2f bytes", size];
    } else if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f KB", size / 1024.0];
    } else {
        return [NSString stringWithFormat:@"%.2f MB", size / (1024.0 * 1024.0)];
    }
}

- (NSString *)imageFileType {
    NSData *imageData = [self imageData];
    if (!imageData || imageData.length < 8) {
        return @"Unknown";
    }
    const unsigned char *bytes = [imageData bytes];

    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 && bytes[4] == 0x0D && bytes[5] == 0x0A && bytes[6] == 0x1A && bytes[7] == 0x0A) {
        return @"PNG";
    } else if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return @"JPG";
    } else {
        return @"Unknown";
    }
}

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }

    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (UIImage*)reflectedImageWithHeight:(NSUInteger)height fromAlpha:(float)fromAlpha toAlpha:(float)toAlpha {
    if (!height)
        return nil;

    // create a bitmap graphics context the size of the image
    UIGraphicsBeginImageContextWithOptions((CGSize){.width = self.size.width, .height = height}, NO, 0.0f);
    CGContextRef mainViewContentContext = UIGraphicsGetCurrentContext();

    // create a 2 bit CGImage containing a gradient that will be used for masking the
    // main view content to create the 'fade' of the reflection. The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
    CGImageRef gradientMaskImage = EPSCreateGradientImage(1, height, fromAlpha, toAlpha);

    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the  pre-masked content bitmap and the gradient bitmap
    CGContextClipToMask(mainViewContentContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = self.size.width, .size.height = height}, gradientMaskImage);
    CGImageRelease(gradientMaskImage);

    // draw the image into the bitmap context
    CGContextDrawImage(mainViewContentContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size = self.size}, self.CGImage);

    // convert the finished reflection image to a UIImage
    UIImage* theImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return theImage;
}


@end
