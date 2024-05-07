//
//  EPSCreditProductView.m
//  AniPhoto
//
//  Created by PhatCH on 24/5/24.
//

#import "EPSCreditProductView.h"

#import "EPSStoreKitManager.h"
#import "EPSDefines.h"

@interface EPSCreditProductView ()
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@end

@implementation EPSCreditProductView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        self.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        self.layer.cornerRadius = 8.0f;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = UIColor.whiteColor.CGColor;
        self.layer.masksToBounds = YES;
        self.clipsToBounds = YES;

        _numLabel = [[UILabel alloc] init];
        NSAttributedString *text = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
                UIImage *image = [[UIImage systemImageNamed:@"leaf.fill"] imageWithTintColor:UIColor.greenColor];
                make.image = image;
                make.bounds = CGRectMake(0, -2, 24, 24);
            });
            make.font([UIFont boldSystemFontOfSize:24]).textColor(UIColor.whiteColor).lineSpacing(8);
            make.append(@" ");
            make.append(@"50");
            make.alignment(NSTextAlignmentCenter);
        }];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.attributedText = text;
        [self addSubview:_numLabel];

        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightThin];
        [self addSubview:_priceLabel];
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
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.centerX.equalTo(self);
        make.bottom.equalTo(self.priceLabel.mas_top).inset(5);
        make.height.equalTo(@30);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.centerX.equalTo(self);
        make.top.equalTo(self).inset(80);
        make.height.equalTo(@20);
    }];
    [super updateConstraints];
}

- (void)updateWithProduct:(SKProduct *)product {
    if (product) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:product.priceLocale];
        NSString *cost = [formatter stringFromNumber:product.price];
        self.priceLabel.text = [NSString stringWithFormat:@"%@", cost];
    }
}

@end
