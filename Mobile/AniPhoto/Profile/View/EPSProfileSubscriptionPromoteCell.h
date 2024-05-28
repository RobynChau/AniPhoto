//
//  EPSProfileSubscriptionPromoteCell.h
//  AniPhoto
//
//  Created by PhatCH on 22/5/24.
//

#import <UIKit/UIKit.h>
#import "EPSUserSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface EPSProfileSubscriptionPromoteCell : UITableViewCell

+ (NSString *)reuseIdentifier;

- (void)updateWithPromoteSubscription;

@end

NS_ASSUME_NONNULL_END
