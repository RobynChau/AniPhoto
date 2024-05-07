//
//  EPSDatabaseManager.h
//  AniPhoto
//
//  Created by PhatCH on 8/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSDatabaseManager : NSObject

+ (instancetype)sharedInstance;
- (BOOL)saveImage:(UIImage *)image withCreationTime:(NSDate *)creationTime;
- (NSArray<UIImage *> *)loadImages;

@end

NS_ASSUME_NONNULL_END
