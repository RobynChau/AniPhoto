//
//  EPSImageHelper.h
//  AniPhoto
//
//  Created by PhatCH on 25/4/24.
//

#import <UIKit/UIKit.h>

/* Number of components for an opaque grey colorSpace = 3 */
#define kEPSNumberOfComponentsPerGreyPixel 3
/* Number of components for an ARGB pixel (Alpha / Red / Green / Blue) = 4 */
#define kEPSNumberOfComponentsPerARBGPixel 4
/* Minimun value for a pixel component */
#define kEPSMinPixelComponentValue (UInt8)0
/* Maximum value for a pixel component */
#define kEPSMaxPixelComponentValue (UInt8)255

/* Convert degrees value to radians */
#define EPS_DEGREES_TO_RADIANS(__DEGREES) (__DEGREES * 0.017453293) // (M_PI / 180.0f)
/* Convert radians value to degrees */
#define EPS_RADIANS_TO_DEGREES(__RADIANS) (__RADIANS * 57.295779513) // (180.0f / M_PI)

/* Returns the lower value */
#define EPS_MIN(__A, __B) ((__A) < (__B) ? (__A) : (__B))
/* Returns the higher value */
#define EPS_MAX(__A ,__B) ((__A) > (__B) ? (__A) : (__B))
/* Returns a correct value for a pixel component (0 - 255) */
#define EPS_SAFE_PIXEL_COMPONENT_VALUE(__COLOR) (EPS_MIN(kEPSMaxPixelComponentValue, EPS_MAX(kEPSMinPixelComponentValue, __COLOR)))

/* iOS version runtime check */
#define EPS_IOS_VERSION_LESS_THAN(__VERSIONSTRING) ([[[UIDevice currentDevice] systemVersion] compare:__VERSIONSTRING options:NSNumericSearch] == NSOrderedAscending)

/* dispatch_release() not needed in iOS 6+ original idea from FMDB https://github.com/ccgus/fmdb/commit/aef763eeb64e6fa654e7d121f1df4c16a98d9f4f */
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    #define EPS_DISPATCH_RELEASE(__QUEUE)
#else
    #define EPS_DISPATCH_RELEASE(__QUEUE) (dispatch_release(__QUEUE))
#endif

CGContextRef EPSCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow, BOOL withAlpha);
CGImageRef EPSCreateGradientImage(const size_t pixelsWide, const size_t pixelsHigh, const CGFloat fromAlpha, const CGFloat toAlpha);
CIContext* EPSGetCIContext(void);
CGColorSpaceRef EPSGetRGBColorSpace(void);
void EPSImagesKitRelease(void);
BOOL EPSImageHasAlpha(CGImageRef imageRef);

