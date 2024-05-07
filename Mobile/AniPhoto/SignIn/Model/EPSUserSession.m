//
//  EPSUserSession.m
//  AniPhoto
//
//  Created by PhatCH on 25/5/24.
//

#import "EPSUserSession.h"
#import "EPSDefines.h"

@interface EPSUserSession ()
@property (nonatomic, copy, readwrite) NSString *accessToken;
@property (nonatomic, copy, readwrite) NSString *userName;
@property (nonatomic, copy, readwrite) NSString *userID;
@property (nonatomic, copy, readwrite) NSString *userEmail;
@property (nonatomic, assign, readwrite) NSInteger latSignInDate;

@property (nonatomic, assign, readwrite) NSInteger totalCreditCount;

@property (nonatomic, strong, readwrite) EPSUserSubscription *currentSubscription;
@end

@implementation EPSUserSession

- (instancetype)initWithAccessToken:(NSString *)accessToken {
    self = [super init];
    if (self) {
        _accessToken = accessToken;
        _totalCreditCount = 0;
        _currentSubscription = [[EPSUserSubscription alloc] init];
    }
    return self;
}

- (void)updateWithID:(NSString *)userID
                name:(NSString *)userName
               email:(NSString *)userEmail {
    self.userID = userID;
    self.userName = userName;
    self.userEmail = userEmail;
}

- (void)updateWithTotalCreditCount:(NSInteger)totalCreditCount {
    self.totalCreditCount = totalCreditCount;
}

- (void)updateWithSubscriptionID:(NSString *)subscriptionID
                    purchaseTime:(NSInteger)purchaseTime
                      expireTime:(NSInteger)expireTime {
    [self.currentSubscription updateWithID:subscriptionID 
                              purchaseTime:purchaseTime
                                expireTime:expireTime];
}

- (BOOL)isSignedIn {
    return IS_NONEMPTY_STRING(self.accessToken);
}

- (BOOL)isSubscribing {
    return [self.currentSubscription isSubscriptionValid];
}

- (void)updateTempCreditCount:(NSInteger)tempCreditCount {
    self.totalCreditCount = tempCreditCount;
}

@end
