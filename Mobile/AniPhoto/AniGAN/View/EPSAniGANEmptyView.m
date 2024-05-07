//
//  EPSAniGANEmptyView.m
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import "EPSAniGANEmptyView.h"
#import "NSString+EPS.h"
#import "Masonry.h"

@interface EPSAniGANEmptyView ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation EPSAniGANEmptyView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor.secondarySystemBackgroundColor colorWithAlphaComponent:0.5];

        _iconView = [[UIImageView alloc] init];
        _iconView.image = [UIImage systemImageNamed:@"photo"];
        [self addSubview:_iconView];

        _label = [[UILabel alloc] init];
        _label.textColor = UIColor.labelColor;
        _label.font = [UIFont systemFontOfSize:12];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = @"Add an image";
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsUpdateConstraints];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    CGSize iconSize = CGSizeMake(50, 40);
    CGSize textSize = [self.label.text sizeOfStringWithStyledFont:self.label.font withSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    CGFloat top = (self.frame.size.height - iconSize.height) / 2;
    [self.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).inset(top);
        make.width.equalTo(@(iconSize.width));
        make.height.equalTo(@(iconSize.height));
    }];
    [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_bottom).inset(10);
        make.leading.trailing.centerX.equalTo(self);
        make.height.equalTo(@(textSize.height));
    }];
    [super updateConstraints];
}

@end
