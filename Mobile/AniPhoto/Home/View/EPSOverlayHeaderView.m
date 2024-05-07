//
//  EPSOverlayHeaderView.m
//  AniPhoto
//
//  Created by PhatCH on 19/5/24.
//

#import "EPSOverlayHeaderView.h"
#import "Masonry.h"

@interface EPSOverlayHeaderView ()
@property (nonatomic, strong) UILabel *appNameLabel;
@end

@implementation EPSOverlayHeaderView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _appNameLabel = [[UILabel alloc] init];
        _appNameLabel.textColor = UIColor.labelColor;
        _appNameLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
        _appNameLabel.textAlignment = NSTextAlignmentLeft;
        _appNameLabel.text = title;
        [self addSubview:_appNameLabel];
    }
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    [self.appNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
        make.height.equalTo(@30);
    }];
    [super updateConstraints];
}

@end
