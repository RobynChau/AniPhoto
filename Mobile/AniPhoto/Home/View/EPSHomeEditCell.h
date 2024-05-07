//
//  EPSHomeEditCell.h
//  AniPhoto
//
//  Created by PhatCH on 19/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSHomeEditCell : UICollectionViewCell

+ (NSString *)cellIdentifier;
- (void)setImage:(nullable UIImage *)image;
- (UIImage *)cellImage;
@end

NS_ASSUME_NONNULL_END
