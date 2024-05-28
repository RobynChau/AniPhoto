//
//  EPSUserSession.h
//  AniPhoto
//
//  Created by PhatCH on 25/5/24.
//

#import <Foundation/Foundation.h>
#import "EPSUserSubscription.h"

NS_ASSUME_NONNULL_BEGIN

@interface EPSUserSession : NSObject

@property (nonatomic, copy, readonly) NSString *accessToken;
@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *userEmail;
@property (nonatomic, assign, readonly) NSInteger latSignInDate;

@property (nonatomic, assign, readonly) NSInteger totalCreditCount;

@property (nonatomic, strong, readonly) EPSUserSubscription *currentSubscription;

- (instancetype)initWithAccessToken:(nullable NSString *)accessToken;

- (void)updateWithID:(NSString *)userID
                name:(NSString *)userName
               email:(NSString *)userEmail;

- (void)updateWithTotalCreditCount:(NSInteger)totalCreditCount;

- (void)updateWithSubscriptionID:(NSString *)subscriptionID
                    purchaseTime:(NSInteger)purchaseTime
                      expireTime:(NSInteger)expireTime;

- (BOOL)isSignedIn;

- (BOOL)isSubscribing;

- (void)updateTempCreditCount:(NSInteger)tempCreditCount;

- (void)signOutUserSession;

@end

NS_ASSUME_NONNULL_END
