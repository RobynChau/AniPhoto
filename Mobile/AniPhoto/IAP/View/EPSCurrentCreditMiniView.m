//
//  EPSCurrentCreditMiniView.m
//  AniPhoto
//
//  Created by PhatCH on 24/5/24.
//

#import "EPSCurrentCreditMiniView.h"

#import "EPSDefines.h"

#define labelFont [UIFont boldSystemFontOfSize:14]

@interface EPSCurrentCreditMiniView ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation EPSCurrentCreditMiniView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.2];
        self.layer.cornerRadius = 10.0f;
        self.layer.masksToBounds = YES;
        self.clipsToBounds = YES;

        _label = [[UILabel alloc] init];
        NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
                UIImage *image = [[UIImage systemImageNamed:@"leaf.fill"] imageWithTintColor:UIColor.greenColor];
                make.image = image;
                make.bounds = CGRectMake(0, -2, 14, 14);
            });
            make.font(labelFont).textColor(UIColor.whiteColor).lineSpacing(8);
            make.append(@"  ");
            make.append(@"...");
            make.alignment(NSTextAlignmentCenter);
        }];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.attributedText = text;
        [self addSubview:_label];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsUpdateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
    [super updateConstraints];
}

- (void)updateWithCredit:(NSInteger)credit {
    NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
            UIImage *image = [[UIImage systemImageNamed:@"leaf.fill"] imageWithTintColor:UIColor.greenColor];
            make.image = image;
            make.bounds = CGRectMake(0, 0, 9, 9);
        });
        make.font([UIFont boldSystemFontOfSize:9]).textColor(UIColor.whiteColor).lineSpacing(8);
        make.append(@" ");
        make.append(@(credit).stringValue);
        make.alignment(NSTextAlignmentCenter);
    }];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.attributedText = text;
}

- (void)updateWithTotalCreditCount:(NSInteger)totalCreditCount {
    NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
            UIImage *image = [[UIImage systemImageNamed:@"leaf.fill"] imageWithTintColor:UIColor.greenColor];
            make.image = image;
            make.bounds = CGRectMake(0, -2, 14, 14);
        });
        make.font(labelFont).textColor(UIColor.whiteColor).lineSpacing(8);
        make.append(@"  ");
        make.append(@(totalCreditCount).stringValue);
        make.alignment(NSTextAlignmentCenter);
    }];
    self.label.attributedText = text;
}

- (void)updateWithUnlimitedCredit {
    NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
            UIImage *image = [[UIImage systemImageNamed:@"leaf.fill"] imageWithTintColor:UIColor.greenColor];
            make.image = image;
            make.bounds = CGRectMake(0, -2, 14, 14);
        });
        make.font(labelFont).textColor(UIColor.whiteColor).lineSpacing(8);
        make.append(@"  ");
        make.append(@"Unlimited");
        make.alignment(NSTextAlignmentCenter);
    }];
    self.label.attributedText = text;
}

- (UIFont *)getCurrentFont {
    return labelFont;
}

@end
