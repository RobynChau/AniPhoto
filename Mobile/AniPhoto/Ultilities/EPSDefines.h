//
//  EPSDefines.h
//  AniPhoto
//
//  Created by PhatCH on 04/03/2024.
//

#import <Foundation/Foundation.h>
#import "Masonry.h"
#import "TSHelper.h"
#import "EPSRequestBuilder.h"
#import "NSString+EPS.h"
#import "UIColor+EPS.h"
#import "UIImage+EPS.h"
#import "NSDictionary+Accessors.h"
#import "NSDateFormatter+MediumDateFormatter.h"
#import "SJAttributesFactory.h"
#import "UIView+Toast.h"
#import "EPSSegmentedControl.h"
#import "EPSLoadingView.h"

NS_ASSUME_NONNULL_BEGIN

#define kServerEndPointURL @"https://vohuynh19-animegan-server.hf.space"
#define kUserAccessToken @"accessToken"
#define kUserLastSignInDate @"lastSignInDate"
#define kEPSSignInManagerDidFetchUserInfo @"kEPSSignInManagerDidFetchUserInfo"
#define kEPSSignInManagerDidFetchUserCredit @"kEPSSignInManagerDidFetchUserCredit"
#define kEPSSignInManagerDidFetchUserSubscription @"kEPSSignInManagerDidFetchUserSubscription"
#define kEPSSignInManagerDidSignOutUser @"kEPSSignInManagerDidSignOutUser"

#define kEPSStoreKitManagerDidUpdateProducts @"kEPSStoreKitManagerDidUpdateProducts"
#define kEPSStoreKitManagerIsPurchasingSubscription @"kEPSStoreKitManagerIsPurchasingSubscription"
#define kEPSStoreKitManagerDidFinishPurchaseSubscription @"kEPSStoreKitManagerDidFinishPurchaseSubscription"
#define kEPSStoreKitManagerDidFailPurchaseSubscription @"kEPSStoreKitManagerDidFailPurchaseSubscription"
#define kEPSStoreKitManagerIsPurchasingCredits @"kEPSStoreKitManagerIsPurchasingCredits"
#define kEPSStoreKitManagerDidFinishPurchaseCredits @"kEPSStoreKitManagerDidFinishPurchaseCredits"
#define kEPSStoreKitManagerDidFailPurchaseCredits @"kEPSStoreKitManagerDidFailPurchaseCredits"

#define kQuotaMax 1000000000

typedef enum : NSUInteger {
    EPSHomeSectionTypeDefault           = 0,
    EPSHomeSectionTypeExclusive         = 1,
    EPSHomeSectionTypeLatest            = 2,
    EPSHomeSectionTypeTrendy            = 3,
    EPSHomeSectionTypePhotoEdit         = 4,
    EPSHomeSectionTypeCinematic         = 5,
    EPSHomeSectionTypeLastCreated       = 6,
} EPSHomeSectionType;

#define CHECK_CLASS(obj, Type)       ([obj isKindOfClass:[Type class]])
#define CHECK_DELEGATE(delegateObj, selectorObj)  (delegateObj && [delegateObj respondsToSelector:selectorObj])
#define IS_NONEMPTY_DICT(dict)          (dict && [dict isKindOfClass:[NSDictionary class]] && ((NSDictionary*)dict).count>0)
#define IS_EMPTY_DICT(dict)             !IS_NONEMPTY_DICT(dict)
#define IS_NONEMPTY_STRING(str)      (str && [str isKindOfClass:[NSString class]] && ((NSString*)str).length>0)
#define IS_EMPTY_STRING(str)            !IS_NONEMPTY_STRING(str)
#define EPSDynamicCast(x, c) ({ \
    id __val = x;\
    ((c *) ([__val isKindOfClass:[c class]] ? __val : nil));\
})

NS_ASSUME_NONNULL_END
