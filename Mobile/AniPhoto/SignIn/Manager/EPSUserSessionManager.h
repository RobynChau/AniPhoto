//
//  EPSUserSessionManager.h
//  AniPhoto
//
//  Created by PhatCH on 9/5/24.
//

#import <UIKit/UIKit.h>
#import "EPSUserSession.h"
#import "EPSUserSubscription.h"

NS_ASSUME_NONNULL_BEGIN

@interface EPSUserSessionManager : NSObject

+ (EPSUserSessionManager *)shared;

@property (nonatomic, copy, readonly) NSString *deviceID;
@property (nonatomic, copy, readonly) EPSUserSession *userSession;

- (void)initiateUserSession;

- (BOOL)isAuthenticated;
- (void)signInUserWithAccessToken:(NSString *)accessToken;
- (void)signOutUser;
- (void)presentSignInWithViewController:(__kindof UIViewController *)rootVC
                             completion:(nullable void (^)(BOOL success, NSError *_Nullable error))completion;

- (void)fetchUserInfo;
- (void)fetchUserCredit;
- (void)fetchUserSubscription;

- (EPSSubscriptionPlanType)getCurrentSubscriptionType;
- (EPSSubscriptionPlanType)getPromoteSubscriptionType;

@end

NS_ASSUME_NONNULL_END
