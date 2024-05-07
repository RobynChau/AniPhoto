//
//  EPSAniGANFilterCell.h
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EPSSimplifiedFilterModel;

@interface EPSAniGANFilterCell : UICollectionViewCell

+ (NSString *)cellIdentifier;

- (void)updateWithModel:(EPSSimplifiedFilterModel *)model;

@end

NS_ASSUME_NONNULL_END
