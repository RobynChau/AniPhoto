//
//  EPSAniGANResultSecondaryToolView.m
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import "EPSAniGANResultSecondaryToolView.h"

#import "EPSDefines.h"

@interface EPSAniGANResultSecondaryToolView ()
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *downloadButton;
@end

@implementation EPSAniGANResultSecondaryToolView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.darkGrayColor;

        _shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _shareButton.backgroundColor = UIColor.lightGrayColor;
        _shareButton.layer.cornerRadius = 20.0f;
        NSAttributedString *shareButtonTitle = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.font([UIFont systemFontOfSize:17]).textColor(UIColor.whiteColor).lineSpacing(8);
            make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
                UIImage *image = [[UIImage systemImageNamed:@"square.and.arrow.up"] imageWithTintColor:UIColor.whiteColor];
                make.image = image;
                make.bounds = CGRectMake(0, -2, 16, 20);
            });
            make.append(@" ");
            make.append(@"Share");
        }];
        [_shareButton setAttributedTitle:shareButtonTitle forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(_shareButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_shareButton];

        _downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _downloadButton.backgroundColor = UIColor.systemBlueColor;
        _downloadButton.layer.cornerRadius = 20.0f;
        NSAttributedString *downloadButtonTitle = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.font([UIFont systemFontOfSize:17]).textColor(UIColor.whiteColor).lineSpacing(8);
            make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
                UIImage *image = [[UIImage systemImageNamed:@"square.and.arrow.down"] imageWithTintColor:UIColor.whiteColor];
                make.image = image;
                make.bounds = CGRectMake(0, -2, 16, 20);
            });
            make.append(@" ");
            make.append(@"Download");
        }];
        [_downloadButton setAttributedTitle:downloadButtonTitle forState:UIControlStateNormal];
        [_downloadButton addTarget:self action:@selector(_downloadButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_downloadButton];
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
    CGFloat padding = 20;
    CGSize buttonSize = CGSizeMake((self.frame.size.width - 3 * padding) / 2, 40);
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).inset(padding);
        make.width.equalTo(@(buttonSize.width));
        make.height.equalTo(@(buttonSize.height));
    }];
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).inset(padding);
        make.width.equalTo(@(buttonSize.width));
        make.height.equalTo(@(buttonSize.height));
    }];
    [super updateConstraints];
}

- (void)_shareButtonPressed {
    if (CHECK_DELEGATE(self.delegate, @selector(toolView:didSelectToolType:))) {
        [self.delegate toolView:self didSelectToolType:EPSAniGANResultSecondaryToolTypeShare];
    }
}

- (void)_downloadButtonPressed {
    if (CHECK_DELEGATE(self.delegate, @selector(toolView:didSelectToolType:))) {
        [self.delegate toolView:self didSelectToolType:EPSAniGANResultSecondaryToolTypeDownload];
    }
}


@end
