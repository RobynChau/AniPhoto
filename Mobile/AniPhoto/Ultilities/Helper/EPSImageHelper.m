//
//  EPSImageHelper.m
//  AniPhoto
//
//  Created by LAP14667 on 25/4/24.
//

#import "EPSImageHelper.h"

static CIContext* __ciContext = nil;
static CGColorSpaceRef __rgbColorSpace = NULL;


CGContextRef EPSCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow, BOOL withAlpha)
{
    /// Use the generic RGB color space
    /// We avoid the NULL check because CGColorSpaceRelease() NULL check the value anyway, and worst case scenario = fail to create context
    /// Create the bitmap context, we want pre-multiplied ARGB, 8-bits per component
    CGImageAlphaInfo alphaInfo = (withAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst);
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, bytesPerRow, EPSGetRGBColorSpace(), kCGBitmapByteOrderDefault | alphaInfo);

    return bmContext;
}

// The following function was taken from the increadibly awesome HockeyKit
// Created by Peter Steinberger on 10.01.11.
// Copyright 2012 Peter Steinberger. All rights reserved.
CGImageRef EPSCreateGradientImage(const size_t pixelsWide, const size_t pixelsHigh, const CGFloat fromAlpha, const CGFloat toAlpha)
{
    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);

    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
    CGFloat colors[] = {toAlpha, 1.0f, fromAlpha, 1.0f};

    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);

    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientEndPoint = CGPointZero;
    CGPoint gradientStartPoint = (CGPoint){.x = 0.0f, .y = pixelsHigh};

    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint, gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);

    // convert the context into a CGImageRef and release the context
    CGImageRef theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);

    // return the imageref containing the gradient
    return theCGImage;
}

CIContext* EPSGetCIContext(void)
{
    if (!__ciContext)
    {
        NSNumber* num = [[NSNumber alloc] initWithBool:NO];
        NSDictionary* opts = [[NSDictionary alloc] initWithObjectsAndKeys:num, kCIContextUseSoftwareRenderer, nil];
        __ciContext = [CIContext contextWithOptions:opts];
    }
    return __ciContext;
}

CGColorSpaceRef EPSGetRGBColorSpace(void)
{
    if (!__rgbColorSpace)
    {
        __rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return __rgbColorSpace;
}

void EPSImagesKitRelease(void)
{
    if (__rgbColorSpace)
        CGColorSpaceRelease(__rgbColorSpace), __rgbColorSpace = NULL;
    if (__ciContext)
        __ciContext = nil;
}

BOOL EPSImageHasAlpha(CGImageRef imageRef)
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);

    return hasAlpha;
}
