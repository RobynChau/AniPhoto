//
//  EPSAniGANResultToolCell.h
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import <UIKit/UIKit.h>

@class EPSSimplifiedToolModel;

NS_ASSUME_NONNULL_BEGIN

@interface EPSAniGANResultToolCell : UICollectionViewCell

+ (NSString *)cellIdentifier;

- (void)updateWithModel:(EPSSimplifiedToolModel *)model;

@end

NS_ASSUME_NONNULL_END
