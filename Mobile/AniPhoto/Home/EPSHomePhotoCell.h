//
//  EPSHomePhotoCell.h
//  AniPhoto
//
//  Created by PhatCH on 03/01/2024.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSHomePhotoCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;

- (void)setCellImage:(UIImage *)image;


@end

NS_ASSUME_NONNULL_END
