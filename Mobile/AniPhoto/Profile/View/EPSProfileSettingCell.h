//
//  EPSProfileSettingCell.h
//  AniPhoto
//
//  Created by PhatCH on 22/01/2024.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSProfileSettingCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (nonatomic, strong) UIImageView *customImageView;
@property (nonatomic, strong) UILabel *customTextLabel;

@end

NS_ASSUME_NONNULL_END
