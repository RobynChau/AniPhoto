//
//  EPSHomeToolCell.h
//  AniPhoto
//
//  Created by PhatCH on 14/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    EPSHomeToolTypeNone         = 0,
    EPSHomeToolTypeEdit         = 1,
    EPSHomeToolTypeAniGAN       = 2,
    EPSHomeToolTypeSticker      = 3,
    EPSHomeToolTypeText         = 4,
    EPSHomeToolTypeFilter       = 5,

} EPSHomeToolType;

@interface EPSHomeToolCell : UICollectionViewCell


@property (nonatomic, readonly) EPSHomeToolType toolType;

+ (NSString *)cellIdentifier;

- (void)setUpWithType:(EPSHomeToolType)toolType;

@end

NS_ASSUME_NONNULL_END
