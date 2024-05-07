//
//  EPSUserSubscription.m
//  AniPhoto
//
//  Created by PhatCH on 26/5/24.
//

#import "EPSUserSubscription.h"

#import "EPSStoreKitManager.h"
#import "EPSDefines.h"

@interface EPSUserSubscription ()

@property (nonatomic, copy, readwrite) NSString *subscriptionID;
@property (nonatomic, assign, readwrite) NSInteger purchaseTime;
@property (nonatomic, assign, readwrite) NSInteger expireTime;

@end

@implementation EPSUserSubscription

- (instancetype)init {
    self = [super init];
    if (self) {
        _subscriptionID = nil;
        _purchaseTime = NSNotFound;
        _expireTime = NSNotFound;
    }
    return self;
}

- (void)updateWithID:(NSString *)subscriptionID
        purchaseTime:(NSInteger)purchaseTime
          expireTime:(NSInteger)expireTime {
    self.subscriptionID = subscriptionID;
    self.purchaseTime = purchaseTime;
    self.expireTime = expireTime;
}

- (BOOL)isSubscriptionValid {
    return (IS_NONEMPTY_STRING(self.subscriptionID)
            && self.expireTime < NSDate.date.timeIntervalSince1970);
}

- (EPSSubscriptionPlanType)subscriptionPlanType {
    if ([self.subscriptionID hasPrefix:@"com.PhatCH.AniPhoto.ProPlus"]) {
        return EPSSubscriptionPlanTypeProPlus;
    } else if ([self.subscriptionID hasPrefix:@"com.PhatCH.AniPhoto.Pro"]) {
        return EPSSubscriptionPlanTypePro;
    }
    return EPSSubscriptionPlanTypeUnknown;
}

@end
