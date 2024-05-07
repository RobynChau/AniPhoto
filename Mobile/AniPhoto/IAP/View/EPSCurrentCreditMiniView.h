//
//  EPSCurrentCreditMiniView.h
//  AniPhoto
//
//  Created by PhatCH on 24/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSCurrentCreditMiniView : UIView

@property (nonatomic, strong, readonly) UILabel *label;

- (UIFont *)getCurrentFont;
- (void)updateWithTotalCreditCount:(NSInteger)totalCreditCount;
- (void)updateWithUnlimitedCredit;
@end

NS_ASSUME_NONNULL_END
