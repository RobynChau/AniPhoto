//
//  EPSProfileSubscriptionPromoteCell.m
//  AniPhoto
//
//  Created by PhatCH on 22/5/24.
//

#import "EPSProfileSubscriptionPromoteCell.h"

#import "EPSDefines.h"
#import "AniPhoto-Swift.h"

@interface EPSProfileSubscriptionPromoteCell ()

@property (nonatomic, strong) EPSGradientLabel *proLabel;
@property (nonatomic, strong) EPSGradientLabel *proPlusLabel;
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

        _proLabel = [[EPSGradientLabel alloc] init];
        _proLabel.text = @"AniPhoto Pro";
        _proLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        [_proLabel
         setAxialGradientParametersWithStartPoint:CGPointMake(0, 0.5)
         endPoint:CGPointMake(1, 0.5)
         colors:@[UIColor.customYellow, UIColor.customOrange]
         locations:nil
         options:nil];
        [self addSubview:_proLabel];

        _proPlusLabel = [[EPSGradientLabel alloc] init];
        _proPlusLabel.text = @"AniPhoto Pro+";
        _proPlusLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        [_proPlusLabel
         setAxialGradientParametersWithStartPoint:CGPointMake(0, 0.5)
         endPoint:CGPointMake(1, 0.5)
         colors:@[UIColor.customPink, UIColor.customPurple]
         locations:nil
         options:nil];
        [self addSubview:_proPlusLabel];
        _proPlusLabel.hidden = YES;

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
    CGSize nameTextSize = [self.proLabel.text sizeOfStringWithStyledFont:self.proLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGSize nameTextSize2 = [self.proPlusLabel.text sizeOfStringWithStyledFont:self.proPlusLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGSize descTextSize = [self.descLabel.text sizeOfStringWithStyledFont:self.descLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];

    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    [self.proLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).insets(UIEdgeInsetsMake(20, 12, 0, 0));
        make.height.equalTo(@(nameTextSize.height));
        make.width.equalTo(@(nameTextSize.width));
    }];
    [self.proPlusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).insets(UIEdgeInsetsMake(20, 12, 0, 0));
        make.height.equalTo(@(nameTextSize2.height));
        make.width.equalTo(@(nameTextSize2.width));
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.proLabel.mas_bottom).inset(10);
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

- (void)updateWithPromoteSubscription {
    EPSSubscriptionPlanType promotionPlan = [EPSUserSessionManager.shared getPromoteSubscriptionType];
    NSLog(@"PhatCH Update With %ld", promotionPlan);
    if (promotionPlan == EPSSubscriptionPlanTypeUnknown) {
        self.proLabel.hidden = YES;
        self.proPlusLabel.hidden = YES;
        self.descLabel.hidden = YES;
        self.subButton.hidden = YES;
    } else if (promotionPlan == EPSSubscriptionPlanTypePro) {
        self.proLabel.hidden = NO;
        self.proPlusLabel.hidden = YES;
        self.descLabel.hidden = NO;
        self.subButton.hidden = NO;
        [self.subButton setGradientBackgroundColors:@[UIColor.customYellow, UIColor.customOrange]
                                          direction:DTImageGradientDirectionToRight
                                              state:UIControlStateNormal];
        [self.proLabel setText:@"AniPhoto Pro"];
        self.descLabel.text = @"50 credits every month";
    } else if (promotionPlan == EPSSubscriptionPlanTypeProPlus) {
        self.proLabel.hidden = YES;
        self.proPlusLabel.hidden = NO;
        self.descLabel.hidden = NO;
        self.subButton.hidden = NO;
        [self.subButton setGradientBackgroundColors:@[UIColor.customPink, UIColor.customPurple]
                                          direction:DTImageGradientDirectionToRight
                                              state:UIControlStateNormal];
        [self.proLabel setText:@"AniPhoto Pro+"];
        self.descLabel.text = @"Unlimited credits";
    } else if (promotionPlan == EPSSubscriptionPlanTypeHide) {
        self.proLabel.hidden = YES;
        self.proPlusLabel.hidden = YES;
        self.descLabel.hidden = YES;
        self.subButton.hidden = YES;
        self.subButton.hidden = YES;
    }
}

@end
