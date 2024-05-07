//
//  EPSStoreKitManager.m
//  AniPhoto
//
//  Created by PhatCH on 05/12/2022.
//

#import "EPSStoreKitManager.h"
#import "EPSUserSessionManager.h"
#import "EPSDefines.h"

@implementation EPSStoreKitManager

#pragma mark - Init

+ (instancetype) shared {
    static EPSStoreKitManager* sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        sharedInstance = [[EPSStoreKitManager alloc] init];
    });

    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self setItems:[[EPSStoreKitItems alloc] init]];
        [self setProducts:[[EPSStoreKitProducts alloc] init]];
        [SKPaymentQueue defaultQueue].delegate = self;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return  self;
}

#pragma mark - StoreKit

- (void)requestProductsWithIDs:(NSMutableSet<NSString *> *)productIDs {
    if (_currentRequest) {
        [_currentRequest cancel];
    }
    [self setCurrentRequest:[[SKProductsRequest alloc] initWithProductIdentifiers:productIDs]];
    _currentRequest.delegate = self;
    [_currentRequest start];
}

- (void)requestAllProducts {
    NSMutableSet<NSString*>* oAllIDs = [[NSMutableSet alloc] initWithSet:EPSStoreKitManager.shared.items.consumable];
    oAllIDs = [[oAllIDs setByAddingObjectsFromSet:EPSStoreKitManager.shared.items.nonConsumable] mutableCopy];
    oAllIDs = [[oAllIDs setByAddingObjectsFromSet:EPSStoreKitManager.shared.items.renewableSubscriptions] mutableCopy];
    oAllIDs = [[oAllIDs setByAddingObjectsFromSet:EPSStoreKitManager.shared.items.nonRenewableSubscriptions] mutableCopy];

    [self requestProductsWithIDs:oAllIDs];
}

- (void)buyProduct:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreProducts {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKRequestDelegate

- (void)requestDidFinish:(SKRequest*)inRequest {
    NSLog(@"IN_APP_PURCHASE requestDidFinish");
}

- (void)request:(SKRequest*)inRequest didFailWithError:(NSError*)inError {
    NSLog(@"IN_APP_PURCHASE request didFailWithError: %@",inError.localizedDescription);
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest*)inRequest didReceiveResponse:(SKProductsResponse*)inResponse {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.products.consumable removeAllObjects];
        [self.products.nonConsumable removeAllObjects];
        [self.products.renewableSubscriptions removeAllObjects];
        [self.products.nonRenewableSubscriptions removeAllObjects];

        for (SKProduct* iProduct in inResponse.products) {
            if ([self.items.consumable containsObject:iProduct.productIdentifier]) {
                [self.products.consumable addObject:iProduct];
            } else if ([self.items.nonConsumable containsObject:iProduct.productIdentifier]) {
                [self.products.nonConsumable addObject:iProduct];
            } else if ([self.items.renewableSubscriptions containsObject:iProduct.productIdentifier]) {
                [self.products.renewableSubscriptions addObject:iProduct];
            } else if ([self.items.nonRenewableSubscriptions containsObject:iProduct.productIdentifier]) {
                [self.products.nonRenewableSubscriptions addObject:iProduct];
            } else {
                NSLog(@"%@", [NSString stringWithFormat:@"ERROR! Wrong product ID: %@", iProduct.productIdentifier]);
            }
        }
        if (CHECK_DELEGATE(self.delegate, @selector(onUpdateProducts))) {
            [self.delegate onUpdateProducts];
        }
    });
}


// ---------------------------------------
#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)inQueue updatedTransactions:(NSArray<SKPaymentTransaction *> *)inTransactions {
    for (SKPaymentTransaction* iTransaction in inTransactions) {
        switch (iTransaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                NSLog(@"IN_APP_PURCHASE SKPaymentTransactionStateFailedTID: %@ PID: %@",
                      iTransaction.transactionIdentifier,
                      iTransaction.payment.productIdentifier
                      );
                [self mTransactionFailed:iTransaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"IN_APP_PURCHASE SKPaymentTransactionStateRestoredTID: %@ PID: %@",
                      iTransaction.transactionIdentifier,
                      iTransaction.payment.productIdentifier
                      );
                [self _handleTransactionRestored:iTransaction];
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"IN_APP_PURCHASE SKPaymentTransactionStatePurchased TID: %@ PID: %@",
                      iTransaction.transactionIdentifier,
                      iTransaction.payment.productIdentifier
                      );
                [self _handleTransactionPurchased:iTransaction];
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"IN_APP_PURCHASE SKPaymentTransactionStateDeferredTID: %@ PID: %@",
                      iTransaction.transactionIdentifier,
                      iTransaction.payment.productIdentifier
                      );
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"IN_APP_PURCHASE SKPaymentTransactionStatePurchasingTID: %@ PID: %@",
                      iTransaction.transactionIdentifier,
                      iTransaction.payment.productIdentifier
                      );
                break;
            default:
                NSLog(@"IN_APP_PURCHASE Unhandled transaction state for: %@ state: %@", inTransactions.description, iTransaction.transactionState);
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue*)queue removedTransactions:(NSArray<SKPaymentTransaction*>*)inTransactions {
    NSLog(@"IN_APP_PURCHASE removedTransactions");
}

- (void)paymentQueue:(SKPaymentQueue*)inQueue restoreCompletedTransactionsFailedWithError:(NSError*)inError {

    NSLog(@"IN_APP_PURCHASE restoreCompletedTransactionsFailedWithError");
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)inQueue {
    NSLog(@"IN_APP_PURCHASE paymentQueueRestoreCompletedTransactionsFinished");
}

- (void)paymentQueue:(SKPaymentQueue*)inQueue updatedDownloads:(NSArray<SKDownload*>*)inDownloads {

    NSLog(@"IN_APP_PURCHASE updatedDownloads");
}

- (BOOL)paymentQueue:(SKPaymentQueue*)inQueue shouldAddStorePayment:(SKPayment*)inPayment forProduct:(SKProduct*)inProduct {

    NSLog(@"IN_APP_PURCHASE paymentQueue shouldAddStorePayment forProduct");

    return YES;
}

- (void)paymentQueueDidChangeStorefront:(SKPaymentQueue*)queue {

    NSLog(@"IN_APP_PURCHASE paymentQueueDidChangeStorefront");
}

- (void)paymentQueue:(SKPaymentQueue*)inQueue didRevokeEntitlementsForProductIdentifiers:(NSArray<NSString*>*)inProductIdentifiers {
    NSLog(@"IN_APP_PURCHASE paymentQueue didRevokeEntitlementsForProductIdentifiers");
}


// ---------------------------------------
#pragma mark Private

- (void)_handleTransactionPurchased:(SKPaymentTransaction*)inTransaction {
    [self _submitToServerTransaction:inTransaction];
    [self mDeliverPurchaseNotification:[inTransaction.payment productIdentifier]];
    [[SKPaymentQueue defaultQueue] finishTransaction:inTransaction];
}

- (void)mTransactionFailed:(SKPaymentTransaction*)inTransaction {

    if ([inTransaction error]) {
        NSError* oError = [inTransaction error];
        if ([oError code] != SKErrorPaymentCancelled) {
            NSLog(@"IN_APP_PURCHASE Payment error with code: %d %@",[oError code],[oError description]);
        } else {
            NSLog(@"IN_APP_PURCHASE Payment canceled");
        }
    }

    [[SKPaymentQueue defaultQueue] finishTransaction:inTransaction];
}

- (void)_handleTransactionRestored:(SKPaymentTransaction *)inTransaction {
    [self _handleTransactionPurchased:inTransaction];
}

- (void)mDeliverPurchaseNotification:(NSString *)inProductID {

}

- (void)_submitToServerTransaction:(SKPaymentTransaction*)inTransaction {
    SKPayment *payment = inTransaction.payment;
    if (!CHECK_CLASS(payment, SKPayment)) {
        return;
    }

    if ([self.items.renewableSubscriptions containsObject:payment.productIdentifier]) {
        [TSHelper dispatchOnMainQueue:^{
            [NSNotificationCenter.defaultCenter postNotificationName:kEPSStoreKitManagerIsPurchasingSubscription object:nil];
        }];
        [self _submitToServerSubscription:inTransaction];
    } else if ([self.items.consumable containsObject:payment.productIdentifier]) {
        [TSHelper dispatchOnMainQueue:^{
            [NSNotificationCenter.defaultCenter postNotificationName:kEPSStoreKitManagerIsPurchasingCredits object:nil];
        }];
        [self _submitToServerPurchase:inTransaction];
    }
}

- (void)_updateTempCreditCountForTransaction:(SKPaymentTransaction*)inTransaction {
    SKPayment *payment = inTransaction.payment;
    if (!CHECK_CLASS(payment, SKPayment)) {
        return;
    }
    if ([payment.productIdentifier hasPrefix:@"com.PhatCH.AniPhoto.ProPlus"]) {
        NSInteger currentCreditCount = EPSUserSessionManager.shared.userSession.totalCreditCount;
        [EPSUserSessionManager.shared.userSession updateTempCreditCount:currentCreditCount + kQuotaMax];
    } else if ([payment.productIdentifier hasPrefix:@"com.PhatCH.AniPhoto.Pro"]) {
        NSInteger currentCreditCount = EPSUserSessionManager.shared.userSession.totalCreditCount;
        [EPSUserSessionManager.shared.userSession updateTempCreditCount:currentCreditCount + 50];
    } else if ([payment.productIdentifier hasPrefix:@"com.PhatCH.AniPhoto.Credit"]) {
        NSInteger currentCreditCount = EPSUserSessionManager.shared.userSession.totalCreditCount;
        [EPSUserSessionManager.shared.userSession updateTempCreditCount:currentCreditCount + 50];
    }
}

- (void)_submitToServerSubscription:(SKPaymentTransaction *)transaction {
    NSString *urlString = [NSString stringWithFormat:@"%@/subscriptions/confirm-subscription", kServerEndPointURL];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionConfiguration *sessionConfiguration = EPSRequestBuilder.defaultSessionConfiguration;

    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    NSString *encodedReceipt = nil;
    if (!receipt) {
        NSLog(@"no receipt");
        encodedReceipt = NSUUID.UUID.UUIDString;
    } else {
        encodedReceipt = [receipt base64EncodedStringWithOptions:0];
    }

    NSDictionary *mapData = @{
        @"subscription_id": transaction.payment.productIdentifier,
        @"apple_receipt_data_jwt": encodedReceipt,
    };

    NSError *convertPostDataError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&convertPostDataError];

    if (!bodyData) {
        return;
    }

    [EPSRequestBuilder dataTaskForURL:url
                 sessionConfiguration:sessionConfiguration
                          requestType:EPSHTTPRequestTypePost
                             bodyData:bodyData
                           completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (IS_NONEMPTY_DICT(response)) {
            [TSHelper dispatchAsyncMainQueue:^{
                [NSNotificationCenter.defaultCenter postNotificationName:kEPSStoreKitManagerDidFinishPurchaseSubscription object:nil];
            }];
        } else {
            [TSHelper dispatchAsyncMainQueue:^{
                [NSNotificationCenter.defaultCenter postNotificationName:kEPSStoreKitManagerDidFailPurchaseSubscription object:nil];
            }];
        }
    }];
}

- (void)_submitToServerPurchase:(SKPaymentTransaction *)transaction {
    NSString *urlString = [NSString stringWithFormat:@"%@/quotas/confirm-buy", kServerEndPointURL];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionConfiguration *sessionConfiguration = EPSRequestBuilder.defaultSessionConfiguration;

    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    NSString *encodedReceipt = nil;
    if (!receipt) {
        NSLog(@"no receipt");
        encodedReceipt = NSUUID.UUID.UUIDString;
    } else {
        encodedReceipt = [receipt base64EncodedStringWithOptions:0];
    }

    NSDictionary *mapData = @{
        @"quota_product_id": transaction.payment.productIdentifier,
        @"apple_receipt_data_jwt": encodedReceipt,
    };

    NSError *convertPostDataError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&convertPostDataError];

    if (!bodyData) {
        return;
    }

    [EPSRequestBuilder dataTaskForURL:url
                 sessionConfiguration:sessionConfiguration
                          requestType:EPSHTTPRequestTypePost
                             bodyData:bodyData
                           completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (IS_NONEMPTY_DICT(response)) {
            [TSHelper dispatchAsyncMainQueue:^{
                [NSNotificationCenter.defaultCenter postNotificationName:kEPSStoreKitManagerDidFinishPurchaseCredits object:nil];
            }];
        } else {
            [TSHelper dispatchAsyncMainQueue:^{
                [NSNotificationCenter.defaultCenter postNotificationName:kEPSStoreKitManagerDidFailPurchaseCredits object:nil];
            }];
        }
    }];
}

@end
