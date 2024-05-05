//
//  EPSModelOptionCell.h
//  AniPhoto
//
//  Created by PhatCH on 03/01/2024.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSModelOptionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

+ (NSString *)cellIdentifier;

- (void)setCellImage:(UIImage *)image;


@end

NS_ASSUME_NONNULL_END
