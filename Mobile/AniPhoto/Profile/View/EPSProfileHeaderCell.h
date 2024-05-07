//
//  EPSProfileHeaderCell.h
//  AniPhoto
//
//  Created by PhatCH on 22/5/24.
//

#import <UIKit/UIKit.h>
#import "EPSUserSession.h"

NS_ASSUME_NONNULL_BEGIN

@class EPSProfileHeaderCell;

typedef enum : NSUInteger {
    EPSProfileHeaderCellTapActionTypeUnknown                    = 0,
    EPSProfileHeaderCellTapActionTypeSignIn                     = 1,
    EPSProfileHeaderCellTapActionTypeCheckInfo                  = 2,
    EPSProfileHeaderCellTapActionTypeBuyCredit                  = 3,
    EPSProfileHeaderCellTapActionTypeCheckSubscription          = 4,
} EPSProfileHeaderCellTapActionType;

@protocol EPSProfileHeaderCellDelegate <NSObject>

- (void)headerCell:(EPSProfileHeaderCell *)headerCell didSelectForTapActionType:(EPSProfileHeaderCellTapActionType)tapActionType;

@end

@interface EPSProfileHeaderCell : UITableViewCell

@property (nonatomic, weak) id<EPSProfileHeaderCellDelegate> delegate;

+ (NSString *)reuseIdentifier;

- (void)updateWithUserModel:(EPSUserSession *)userSession;
- (BOOL)isSignInHeader;

@end

NS_ASSUME_NONNULL_END
