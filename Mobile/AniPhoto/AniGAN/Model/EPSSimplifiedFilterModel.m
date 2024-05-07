//
//  EPSSimplifiedFilterModel.m
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import "EPSSimplifiedFilterModel.h"

@interface EPSSimplifiedFilterModel ()

@property (nonatomic, copy) NSString *filterName;
@property (nonatomic, copy) NSString *imageName;

@end

@implementation EPSSimplifiedFilterModel

+ (NSArray<EPSSimplifiedFilterModel *> *)allFilterModels {
    return @[
        [[EPSSimplifiedFilterModel alloc] initWithName:@"og" imageName:@"filter_og"],
        [[EPSSimplifiedFilterModel alloc] initWithName:@"clarendon" imageName:@"filter_clarendon"],
        [[EPSSimplifiedFilterModel alloc] initWithName:@"fade" imageName:@"filter_fade"],
        [[EPSSimplifiedFilterModel alloc] initWithName:@"linear" imageName:@"filter_linear"],
        [[EPSSimplifiedFilterModel alloc] initWithName:@"nashville" imageName:@"filter_nashville"],
        [[EPSSimplifiedFilterModel alloc] initWithName:@"noir" imageName:@"filter_noir"],
    ];
}

- (instancetype)initWithName:(NSString *)filterName imageName:(NSString *)imageName{
    self = [super init];
    if (self) {
        _filterName = filterName;
        _imageName = imageName;
    }
    return self;
}

@end
