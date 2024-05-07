//
//  EPSSimplifiedToolModel.h
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    EPSSimplifiedToolModelTypeDoodle        = 0,
    EPSSimplifiedToolModelTypeCrop          = 1,
    EPSSimplifiedToolModelTypeSticker       = 2,
    EPSSimplifiedToolModelTypeText          = 3,
    EPSSimplifiedToolModelTypeMosaic        = 4,
    EPSSimplifiedToolModelTypeFilter        = 5,
    EPSSimplifiedToolModelTypeAdjust        = 6,
} EPSSimplifiedToolModelType;

@interface EPSSimplifiedToolModel : NSObject

@property (nonatomic, copy, readonly) NSString *toolName;
@property (nonatomic, copy, readonly) NSString *iconName;
@property (nonatomic, assign, readonly) EPSSimplifiedToolModelType toolType;

+ (NSArray<EPSSimplifiedToolModel *> *)allTools;

@end

NS_ASSUME_NONNULL_END
