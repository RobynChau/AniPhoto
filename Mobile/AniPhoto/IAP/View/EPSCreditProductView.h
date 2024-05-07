//
//  EPSCreditProductView.h
//  AniPhoto
//
//  Created by PhatCH on 24/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SKProduct;

@interface EPSCreditProductView : UIView

- (void)updateWithProduct:(SKProduct *)product;

@end

NS_ASSUME_NONNULL_END
