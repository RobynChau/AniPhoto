//
//  EPSStoreKitProducts.m
//  AniPhoto
//
//  Created by PhatCH on 05/12/2022.
//

#import "EPSStoreKitProducts.h"

@implementation EPSStoreKitProducts

#pragma mark - Init

- (instancetype)init {
	self = [super init];
	if (self) {
		[self setConsumable:[[NSMutableArray alloc] init]];
		[self setNonConsumable:[[NSMutableArray alloc] init]];
		[self setRenewableSubscriptions:[[NSMutableArray alloc] init]];
		[self setNonRenewableSubscriptions:[[NSMutableArray alloc] init]];
	}
	return self;
}

@end
