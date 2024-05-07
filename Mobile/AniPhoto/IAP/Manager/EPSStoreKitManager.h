//
//  EPSStoreKitManager.h
//  AniPhoto
//
//  Created by PhatCH on 05/12/2022.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "EPSStoreKitItems.h"
#import "EPSStoreKitProducts.h"

#define kProMonthIdentifier @"com.PhatCH.AniPhoto.Pro.Month"
#define kProYearIdentifier @"com.PhatCH.AniPhoto.Pro.Year"
#define kProPlusMonthIdentifier @"com.PhatCH.AniPhoto.ProPlus.Month"
#define kProPlusYearIdentifier @"com.PhatCH.AniPhoto.ProPlus.Year"
#define kCreditIdentifier @"com.PhatCH.AniPhoto.Credit"

NS_ASSUME_NONNULL_BEGIN

@protocol EPSStoreKitDelegate <NSObject>

- (void)onUpdateProducts;

@end

@interface EPSStoreKitManager : NSObject <
SKRequestDelegate,
SKProductsRequestDelegate,
SKPaymentTransactionObserver,
SKPaymentQueueDelegate
>

@property (nonatomic, weak) id<EPSStoreKitDelegate> delegate;
@property (nonatomic, strong) SKProductsRequest *currentRequest;
@property (nonatomic, strong) EPSStoreKitItems *items;
@property (nonatomic, strong) EPSStoreKitProducts *products;

+ (EPSStoreKitManager *)shared;
- (void)requestProductsWithIDs:(NSMutableSet<NSString *> *)productIDs;
- (void)requestAllProducts;
- (void)buyProduct:(SKProduct *)product;
- (void)restoreProducts;

@end

NS_ASSUME_NONNULL_END
