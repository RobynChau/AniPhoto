//
//  EPSModelOptionSectionLabel.m
//  AniPhoto
//
//  Created by PhatCH on 16/4/24.
//

#import "EPSModelOptionSectionLabel.h"

@interface EPSModelOptionSectionLabel ()
// Data
@property (nonatomic, assign) HomeModelSectionType sectionType;
@property (nonatomic, copy) NSString *title;

// UI
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation EPSModelOptionSectionLabel

- (instancetype)initWithType:(HomeModelSectionType)sectionType
                       title:(NSString *)title {
    self = [super init];
    if (self) {
        _sectionType = sectionType;
        _title = title;
    }
    return self;
}

- (CGSize)calculatedSize {
    return CGSizeMake(self.frame.size.width, 100);
}

@end
