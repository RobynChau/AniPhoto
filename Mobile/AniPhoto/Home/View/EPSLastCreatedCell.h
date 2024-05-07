//
//  EPSLastCreatedCell.h
//  AniPhoto
//
//  Created by PhatCH on 29/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSLastCreatedCell : UICollectionViewCell

+ (NSString *)cellIdentifier;

- (void)setShouldShowOverlay:(BOOL)shouldShowOverlay;
- (void)setImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
