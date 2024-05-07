//
//  EPSLoadingView.m
//  AniPhoto
//
//  Created by PhatCH on 17/4/24.
//

#import "EPSLoadingView.h"
#import "Masonry.h"

@interface EPSLoadingView ()
@property (nonatomic, assign) BOOL shouldShowLabel;
@property (nonatomic, assign) BOOL shouldDim;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *loadingLabel;
@end

@implementation EPSLoadingView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)init {
    self = [self initWithShouldShowLabel:NO shouldDim:YES];
    return self;
}

- (instancetype)initWithShouldShowLabel:(BOOL)shouldShowLabel
                              shouldDim:(BOOL)shouldDim {
    self = [super init];
    if (self) {
        _shouldShowLabel = shouldShowLabel;
        _shouldDim = shouldDim;

        if (_shouldDim) {
            self.backgroundColor = UIColor.darkGrayColor;
            self.alpha = 0.5;
        } else {
            self.backgroundColor = UIColor.clearColor;
            self.alpha = 1.0;
        }

        _spinner = [[UIActivityIndicatorView alloc] 
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        [self addSubview:_spinner];

        if (_shouldShowLabel) {
            _loadingLabel = [[UILabel alloc] init];
            _loadingLabel.text = @"Loading...";
            _loadingLabel.font = [UIFont boldSystemFontOfSize:20];
            _loadingLabel.textColor = UIColor.labelColor;
            [_loadingLabel sizeToFit];
            [self addSubview:_loadingLabel];
        }
    }

    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    if (self.shouldShowLabel) {
        [self.loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self);
        }];
        [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.loadingLabel.mas_top).inset(15);
            make.width.height.equalTo(@50);
        }];
    } else {
        [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self);
            make.width.height.equalTo(@50);
        }];
    }
    [super updateConstraints];
}

- (void)setHidden:(BOOL)hidden {
    [self setUserInteractionEnabled:YES];
    [super setHidden:hidden];
    if (hidden) {
        [self.spinner stopAnimating];
    } else {
        [self.spinner startAnimating];
    }
}

@end
