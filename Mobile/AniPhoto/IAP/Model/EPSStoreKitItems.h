//
//  EPSStoreKitItems.h
//  AniPhoto
//
//  Created by PhatCH on 05/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPSStoreKitItems : NSObject

@property (nonatomic, strong) NSMutableSet<NSString *> *consumable;
@property (nonatomic, strong) NSMutableSet<NSString *> *nonConsumable;
@property (nonatomic, strong) NSMutableSet<NSString *> *renewableSubscriptions;
@property (nonatomic, strong) NSMutableSet<NSString *> *nonRenewableSubscriptions;

@end

NS_ASSUME_NONNULL_END
