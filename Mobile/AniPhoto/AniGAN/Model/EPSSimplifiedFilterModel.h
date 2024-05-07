//
//  EPSSimplifiedFilterModel.h
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSSimplifiedFilterModel : NSObject

@property (nonatomic, copy, readonly) NSString *filterName;
@property (nonatomic, copy, readonly) NSString *imageName;

+ (NSArray<EPSSimplifiedFilterModel *> *)allFilterModels;

@end

NS_ASSUME_NONNULL_END
