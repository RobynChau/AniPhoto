//
//  EPSProfileHeaderCell.m
//  AniPhoto
//
//  Created by PhatCH on 22/5/24.
//

#import "EPSProfileHeaderCell.h"
#import "EPSCurrentCreditMiniView.h"

#import "EPSDefines.h"
#import "EPSUserSessionManager.h"
#import "NSString+EPS.h"

@interface EPSProfileHeaderCell ()
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *subscriptionLabel;
@property (nonatomic, strong) UILabel *proLabel;
@property (nonatomic, strong) EPSCurrentCreditMiniView *creditView;
@end

@implementation EPSProfileHeaderCell

+ (NSString *)reuseIdentifier {
    return @"EPSProfileHeaderCell";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _circleView = [[UIImageView alloc] init];
        _circleView.backgroundColor = UIColor.darkGrayColor;
        _circleView.layer.masksToBounds = YES;
        _circleView.layer.cornerRadius = 25;
        [self addSubview:_circleView];

        _avatarView = [[UIImageView alloc] init];
        _avatarView.image = [UIImage systemImageNamed:@"person"];
        _avatarView.backgroundColor = UIColor.clearColor;
        [self addSubview:_avatarView];

        _proLabel = [[UILabel alloc] init];
        _proLabel.layer.cornerRadius = 5.0f;
        _proLabel.clipsToBounds = YES;
        _proLabel.backgroundColor = UIColor.darkGrayColor;
        _proLabel.text = @"Pro";
        _proLabel.textColor = UIColor.whiteColor;
        _proLabel.textAlignment = NSTextAlignmentCenter;
        _proLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_proLabel];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
        _nameLabel.text = @"Robyn Chau";
        [self addSubview:_nameLabel];

        _subscriptionLabel = [[UILabel alloc] init];
        _subscriptionLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
        _subscriptionLabel.text = @"Expiration: 2024.05.23";
        [self addSubview:_subscriptionLabel];

        _creditView = [[EPSCurrentCreditMiniView alloc] init];
        [self addSubview:_creditView];
    }
    return self;
}

- (void)didMoveToSuperview {
    self.selectedBackgroundView.hidden = YES;
}

- (void)updateConstraints {
    CGSize nameTextSize = [self.nameLabel.text sizeOfStringWithStyledFont:self.nameLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGSize subTextSize = [self.subscriptionLabel.text sizeOfStringWithStyledFont:self.subscriptionLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat totalHeight = self.frame.size.height;
    CGSize creditViewSize = [self.creditView.label.attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).insets(UIEdgeInsetsMake(10, 0, 0, 0));
        make.size.equalTo(@50);
    }];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.circleView);
        make.size.equalTo(@30);
    }];
    [self.proLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        make.top.equalTo(self.circleView.mas_bottom).inset(-8);
        make.width.equalTo(@50);
        make.height.equalTo(@15);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).inset((totalHeight - nameTextSize.height - subTextSize.height - 5) / 2);
        make.leading.equalTo(self.circleView.mas_trailing).inset(10);
        make.height.equalTo(@(nameTextSize.height));
        make.width.equalTo(@200);
    }];
    [self.subscriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).inset((totalHeight - nameTextSize.height - subTextSize.height - 5) / 2);
        make.leading.equalTo(self.circleView.mas_trailing).inset(10);
        make.height.equalTo(@(subTextSize.height));
        make.width.equalTo(@200);
    }];
    [self.creditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.centerY.equalTo(self);
        make.width.greaterThanOrEqualTo(@(creditViewSize.width + 15));
        make.height.equalTo(@25);
    }];
    [super updateConstraints];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:touch.view];
    if (CGRectContainsPoint(self.circleView.frame, touchLocation)) {
        if (self.isSignInHeader) {
            if (CHECK_DELEGATE(self.delegate, @selector(headerCell:didSelectForTapActionType:))) {
                [self.delegate headerCell:self didSelectForTapActionType:EPSProfileHeaderCellTapActionTypeSignIn];
            }
        } else {
            if (CHECK_DELEGATE(self.delegate, @selector(headerCell:didSelectForTapActionType:))) {
                [self.delegate headerCell:self didSelectForTapActionType:EPSProfileHeaderCellTapActionTypeCheckInfo];
            }
        }
    } else if (CGRectContainsPoint(self.nameLabel.frame, touchLocation)) {
        if (self.isSignInHeader) {
            if (CHECK_DELEGATE(self.delegate, @selector(headerCell:didSelectForTapActionType:))) {
                [self.delegate headerCell:self didSelectForTapActionType:EPSProfileHeaderCellTapActionTypeSignIn];
            }
        } else {
            if (CHECK_DELEGATE(self.delegate, @selector(headerCell:didSelectForTapActionType:))) {
                [self.delegate headerCell:self didSelectForTapActionType:EPSProfileHeaderCellTapActionTypeCheckInfo];
            }
        }
    } else if (CGRectContainsPoint(self.subscriptionLabel.frame, touchLocation)) {
        if (self.isSignInHeader) {
            if (CHECK_DELEGATE(self.delegate, @selector(headerCell:didSelectForTapActionType:))) {
                [self.delegate headerCell:self didSelectForTapActionType:EPSProfileHeaderCellTapActionTypeSignIn];
            }
        } else {
            if (CHECK_DELEGATE(self.delegate, @selector(headerCell:didSelectForTapActionType:))) {
                [self.delegate headerCell:self didSelectForTapActionType:EPSProfileHeaderCellTapActionTypeCheckSubscription];
            }
        }
    } else if (CGRectContainsPoint(self.creditView.frame, touchLocation)) {
        if (self.isSignInHeader) {
            if (CHECK_DELEGATE(self.delegate, @selector(headerCell:didSelectForTapActionType:))) {
                [self.delegate headerCell:self didSelectForTapActionType:EPSProfileHeaderCellTapActionTypeSignIn];
            }
        } else {
            if ([EPSUserSessionManager.shared getCurrentSubscriptionType] != EPSSubscriptionPlanTypeProPlus) {
                if (CHECK_DELEGATE(self.delegate, @selector(headerCell:didSelectForTapActionType:))) {
                    [self.delegate headerCell:self didSelectForTapActionType:EPSProfileHeaderCellTapActionTypeBuyCredit];
                }
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.delegate = nil;
}

- (void)updateWithUserModel:(EPSUserSession *)userSession {
    if (userSession && userSession.isSignedIn) {
        if (IS_NONEMPTY_STRING(userSession.userName)) {
            self.nameLabel.text = userSession.userName;
        } else {
            self.nameLabel.text = @"...";
        }
    } else {
        self.nameLabel.text = @"Sign up or Login";
    }
    
    if ([userSession.currentSubscription subscriptionPlanType] == EPSSubscriptionPlanTypeProPlus
        || userSession.totalCreditCount >= kQuotaMax) {
        [self.creditView updateWithUnlimitedCredit];
        self.proLabel.text = @"Pro+";
    } else {
        [self.creditView updateWithTotalCreditCount:userSession.totalCreditCount];
        self.proLabel.text = @"Pro";
    }

    if ([userSession isSubscribing]) {
        NSString *expireDateString = [NSDateFormatter.shared stringFromDate:[NSDate dateWithTimeIntervalSince1970:userSession.currentSubscription.expireTime]];
        self.subscriptionLabel.text = [NSString stringWithFormat:@"Expiration: %@", expireDateString];
        self.proLabel.backgroundColor = UIColor.customYellow;
    } else {
        self.subscriptionLabel.text = @"Join AniPhoto Pro";
        self.proLabel.backgroundColor = UIColor.darkGrayColor;
    }

    CGSize creditViewSize = [self.creditView.label.attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    [self.creditView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(creditViewSize.width + 15));
    }];
    [self setNeedsUpdateConstraints];
}

- (BOOL)isSignInHeader {
    return [self.nameLabel.text isEqualToString:@"Sign up or Login"];
}

@end
