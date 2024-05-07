//
//  EPSUserSubscription.h
//  AniPhoto
//
//  Created by PhatCH on 26/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    EPSSubscriptionPlanTypeUnknown      = 0,
    EPSSubscriptionPlanTypePro          = 1,
    EPSSubscriptionPlanTypeProPlus      = 2,
    EPSSubscriptionPlanTypeHide         = 3,
} EPSSubscriptionPlanType;

@interface EPSUserSubscription : NSObject

@property (nonatomic, copy, readonly) NSString *subscriptionID;
@property (nonatomic, assign, readonly) NSInteger purchaseTime;
@property (nonatomic, assign, readonly) NSInteger expireTime;

- (void)updateWithID:(NSString *)subscriptionID
        purchaseTime:(NSInteger)purchaseTime
          expireTime:(NSInteger)expireTime;

- (BOOL)isSubscriptionValid;

- (EPSSubscriptionPlanType)subscriptionPlanType;

@end

NS_ASSUME_NONNULL_END
