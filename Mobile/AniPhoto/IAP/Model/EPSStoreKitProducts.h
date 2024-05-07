//
//  EPSStoreKitProducts.h
//  AniPhoto
//
//  Created by PhatCH on 05/12/2022.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSStoreKitProducts : NSObject

@property (nonatomic, strong) NSMutableArray<SKProduct *> *consumable;
@property (nonatomic, strong) NSMutableArray<SKProduct *> *nonConsumable;
@property (nonatomic, strong) NSMutableArray<SKProduct *> *renewableSubscriptions;
@property (nonatomic, strong) NSMutableArray<SKProduct *> *nonRenewableSubscriptions;

@end

NS_ASSUME_NONNULL_END
