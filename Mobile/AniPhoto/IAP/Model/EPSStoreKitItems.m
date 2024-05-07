//
//  EPSStoreKitItems.m
//  AniPhoto
//
//  Created by PhatCH on 05/12/2022.
//

#import "EPSStoreKitItems.h"

@implementation EPSStoreKitItems

#pragma mark - Init

- (instancetype)init {

	self = [super init];
	if (self) {
		[self setConsumable:[[NSMutableSet alloc] initWithArray:@[
            @"com.PhatCH.AniPhoto.Credit"
		]]];
		
		[self setNonConsumable:[[NSMutableSet alloc] initWithArray:@[
		]]];
		
		[self setRenewableSubscriptions:[[NSMutableSet alloc] initWithArray:@[
            @"com.PhatCH.AniPhoto.Pro.Month",
            @"com.PhatCH.AniPhoto.Pro.Year",
            @"com.PhatCH.AniPhoto.ProPlus.Month",
            @"com.PhatCH.AniPhoto.ProPlus.Year",
        ]]];

		[self setNonRenewableSubscriptions:[[NSMutableSet alloc] initWithArray:@[
		]]];
	}
	return self;
}

@end
