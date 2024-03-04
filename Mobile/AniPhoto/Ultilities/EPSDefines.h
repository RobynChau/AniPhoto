//
//  EPSDefines.h
//  AniPhoto
//
//  Created by PhatCH on 04/03/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kModelServerLink @"https://1078-34-16-192-14.ngrok-free.app"

typedef enum : NSUInteger {
    HomeModelSectionTypeDefault         = 0,
    HomeModelSectionTypeExclusive       = 1,
    HomeModelSectionTypeLatest          = 2,
    HomeModelSectionTypeTrendy          = 3,
    HomeModelSectionTypePhotoEdit       = 4,
    HomeModelSectionTypeCinematic       = 5,
} HomeModelSectionType;

NS_ASSUME_NONNULL_END
