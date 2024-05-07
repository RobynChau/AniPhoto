//
//  EPSSimplifiedToolModel.m
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import "EPSSimplifiedToolModel.h"

@interface EPSSimplifiedToolModel ()
@property (nonatomic, copy) NSString *toolName;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, assign) EPSSimplifiedToolModelType toolType;
@end

@implementation EPSSimplifiedToolModel

+ (NSArray<EPSSimplifiedToolModel *> *)allTools {
    return @[
        [[EPSSimplifiedToolModel alloc] initWithName:@"Doodle" iconName:@"zl_doodle" toolType:EPSSimplifiedToolModelTypeDoodle],
        [[EPSSimplifiedToolModel alloc] initWithName:@"Crop" iconName:@"zl_crop" toolType:EPSSimplifiedToolModelTypeCrop],
        [[EPSSimplifiedToolModel alloc] initWithName:@"Sticker" iconName:@"zl_imageSticker" toolType:EPSSimplifiedToolModelTypeSticker],
        [[EPSSimplifiedToolModel alloc] initWithName:@"Text" iconName:@"zl_textSticker" toolType:EPSSimplifiedToolModelTypeText],
        [[EPSSimplifiedToolModel alloc] initWithName:@"Mosaic" iconName:@"zl_mosaic" toolType:EPSSimplifiedToolModelTypeMosaic],
        [[EPSSimplifiedToolModel alloc] initWithName:@"Filter" iconName:@"zl_filter" toolType:EPSSimplifiedToolModelTypeFilter],
        [[EPSSimplifiedToolModel alloc] initWithName:@"Adjust" iconName:@"zl_adjust" toolType:EPSSimplifiedToolModelTypeAdjust],
    ];
}

- (instancetype)initWithName:(NSString *)toolName
                    iconName:(NSString *)iconName
                    toolType:(EPSSimplifiedToolModelType)toolType {
    self = [super init];
    if (self) {
        _toolName = toolName;
        _iconName = iconName;
        _toolType = toolType;
    }
    return self;
}

@end
