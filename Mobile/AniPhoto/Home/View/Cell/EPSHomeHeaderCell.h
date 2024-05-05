//
//  EPSHomeHeaderCell.h
//  AniPhoto
//
//  Created by PhatCH on 29/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSHomeHeaderCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;

+ (NSString *)cellIdentifier;

@end

NS_ASSUME_NONNULL_END
