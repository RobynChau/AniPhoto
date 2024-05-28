//
//  EPSCurrentCreditFullView.m
//  AniPhoto
//
//  Created by PhatCH on 24/5/24.
//

#import "EPSCurrentCreditFullView.h"

#import "EPSUserSessionManager.h"
#import "EPSDefines.h"

@interface EPSCurrentCreditFullView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *creditNumLabel;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation EPSCurrentCreditFullView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;

        _gradientLayer = [[CAGradientLayer alloc] init];
        _gradientLayer.colors = @[(id)UIColor.customBlue.CGColor,
                                  (id)UIColor.customGreen.CGColor];
        _gradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradientLayer.endPoint = CGPointMake(1, 0.5);
        _gradientLayer.cornerRadius = 12.0f;
        _gradientLayer.masksToBounds = YES;
        [self.layer insertSublayer:_gradientLayer atIndex:0];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"My credits";
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        [self addSubview:_titleLabel];

        _iconView = [[UIImageView alloc] init];
        _iconView.image = [[UIImage systemImageNamed:@"leaf.fill"] imageWithTintColor:UIColor.greenColor];
        _iconView.tintColor = UIColor.greenColor;
        [self addSubview:_iconView];

        _creditNumLabel = [[UILabel alloc] init];
        NSInteger creditCount = EPSUserSessionManager.shared.userSession.totalCreditCount;
        _creditNumLabel.text = creditCount == NSNotFound ? @"..." : @(creditCount).stringValue;
        _creditNumLabel.textColor = UIColor.blackColor;
        _creditNumLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightBold];
        [self addSubview:_creditNumLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsUpdateConstraints];
    self.gradientLayer.frame = self.bounds;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsUpdateConstraints];
    self.gradientLayer.frame = self.bounds;
}

- (void)updateConstraints {
    CGSize titleSize = [self.titleLabel.text sizeOfStringWithStyledFont:self.titleLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGSize creditSize = [self.creditNumLabel.text sizeOfStringWithStyledFont:self.creditNumLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self).insets(UIEdgeInsetsMake(12, 12, 0, 0));
        make.height.equalTo(@(titleSize.height));
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).inset(12);
        make.top.equalTo(self.titleLabel.mas_bottom).inset(10);
        make.size.equalTo(@(creditSize.height));
    }];
    [self.creditNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.iconView.mas_trailing).inset(5);
        make.top.equalTo(self.titleLabel.mas_bottom).inset(10);
        make.trailing.equalTo(self);
        make.height.equalTo(@(creditSize.height));
    }];
    [super updateConstraints];
}

- (void)updateWithUserCredit:(NSInteger)totalCreditCount {
    self.creditNumLabel.text = @(totalCreditCount).stringValue;
}

@end
