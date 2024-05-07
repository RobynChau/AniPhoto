//
//  EPSProfileSubscriptionPromoteCell.m
//  AniPhoto
//
//  Created by PhatCH on 22/5/24.
//

#import "EPSProfileSubscriptionPromoteCell.h"

#import "EPSDefines.h"

@interface EPSProfileSubscriptionPromoteCell ()

@property (nonatomic, strong) EPSGradientLabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *subButton;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation EPSProfileSubscriptionPromoteCell

+ (NSString *)reuseIdentifier {
    return @"EPSProfileSubscriptionPromoteCell";
}


+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.image = [UIImage imageNamed:@"gradient_fill2"];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_backgroundImageView];

        _nameLabel = [[EPSGradientLabel alloc] init];
        _nameLabel.text = @"AniPhoto Pro+";
        _nameLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        [_nameLabel
         setAxialGradientParametersWithStartPoint:CGPointMake(0, 0.5)
         endPoint:CGPointMake(1, 0.5)
         colors:@[UIColor.customYellow, UIColor.customOrange]
         locations:nil
         options:nil];
        [self addSubview:_nameLabel];

        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _descLabel.text = @"Unlimited credits";
        [self addSubview:_descLabel];

        _subButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _subButton.backgroundColor = UIColor.clearColor;
        _subButton.layer.cornerRadius = 12.0f;
        _subButton.layer.masksToBounds = YES;
        NSAttributedString *buttonTitle = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.font([UIFont systemFontOfSize:13]).textColor(UIColor.whiteColor).lineSpacing(8);
            make.append(@"Upgrade Now");
        }];
        [_subButton setGradientBackgroundColors:@[UIColor.customYellow, UIColor.customOrange]
                                      direction:DTImageGradientDirectionToRight
                                          state:UIControlStateNormal];
        [_subButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];
        [self addSubview:_subButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updateConstraints {
    CGSize nameTextSize = [self.nameLabel.text sizeOfStringWithStyledFont:self.nameLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGSize descTextSize = [self.descLabel.text sizeOfStringWithStyledFont:self.descLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];

    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self).insets(UIEdgeInsetsMake(20, 12, 0, 0));
        make.height.equalTo(@(nameTextSize.height));
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).inset(10);
        make.leading.trailing.equalTo(self).insets(UIEdgeInsetsMake(0, 12, 0, 0));
        make.height.equalTo(@(descTextSize.height));
    }];
    [self.subButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).inset(12);
        make.trailing.equalTo(self.mas_trailing).inset(20);
        make.width.equalTo(@120);
        make.height.equalTo(@32);
    }];
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)updateWithPromoteSubscription:(EPSSubscriptionPlanType)subscriptionType {
    switch (subscriptionType) {
        case EPSSubscriptionPlanTypeUnknown: {
            self.nameLabel.text = @"...";
            self.descLabel.text = @"...";
            self.nameLabel.hidden = YES;
            self.descLabel.hidden = YES;
            self.subButton.hidden = YES;
            break;
        }
        case EPSSubscriptionPlanTypePro: {
            self.nameLabel.text = @"AniPhoto Pro";
            self.descLabel.text = @"50 credits every month";
            self.nameLabel.hidden = NO;
            self.descLabel.hidden = NO;
            self.subButton.hidden = NO;
            self.subButton.hidden = NO;
            [self.nameLabel
             setAxialGradientParametersWithStartPoint:CGPointMake(0, 0.5)
             endPoint:CGPointMake(1, 0.5)
             colors:@[UIColor.customYellow, UIColor.customOrange]
             locations:nil
             options:nil];
            [self.subButton setGradientBackgroundColors:@[UIColor.customYellow, UIColor.customOrange]
                                              direction:DTImageGradientDirectionToRight
                                                  state:UIControlStateNormal];
            break;
        }
        case EPSSubscriptionPlanTypeProPlus: {
            self.nameLabel.text = @"AniPhoto Pro+";
            self.descLabel.text = @"Unlimited credits";
            self.nameLabel.hidden = NO;
            self.descLabel.hidden = NO;
            self.subButton.hidden = NO;
            [self.nameLabel
             setAxialGradientParametersWithStartPoint:CGPointMake(0, 0.5)
             endPoint:CGPointMake(1, 0.5)
             colors:@[UIColor.customPink, UIColor.customPurple]
             locations:nil
             options:nil];
            [self.subButton setGradientBackgroundColors:@[UIColor.customPink, UIColor.customPurple]
                                              direction:DTImageGradientDirectionToRight
                                                  state:UIControlStateNormal];
            break;
        }
        case EPSSubscriptionPlanTypeHide: {
            self.nameLabel.hidden = YES;
            self.descLabel.hidden = YES;
            self.subButton.hidden = YES;
            self.subButton.hidden = YES;
            break;
        }
    }

}

@end
