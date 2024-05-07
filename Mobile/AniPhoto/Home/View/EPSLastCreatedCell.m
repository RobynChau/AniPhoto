//
//  EPSLastCreatedCell.m
//  AniPhoto
//
//  Created by PhatCH on 29/4/24.
//

#import "EPSLastCreatedCell.h"

// Utilities
#import <SDWebImage/SDWebImage.h>
#import "Masonry.h"

@interface EPSLastCreatedCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *generateStatus;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIView *bottomLine;
@end

@implementation EPSLastCreatedCell

+ (NSString *)cellIdentifier {
    return @"EPSLastCreatedCell";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.alpha = 0.5;
        _imageView.image = [UIImage imageNamed:@"output"];
        [self addSubview:_imageView];

        _generateStatus = [[UILabel alloc] init];
        _generateStatus.font = [UIFont boldSystemFontOfSize:20];
        _generateStatus.textAlignment = NSTextAlignmentCenter;
        _generateStatus.text = @"Ready!";
        [self addSubview:_generateStatus];

        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.font = [UIFont systemFontOfSize:12];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.text = @"Tap to download.";
        [self addSubview:_descriptionLabel];

        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = UIColor.greenColor;
        [self addSubview:_bottomLine];

        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;
    }
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.equalTo(self);
    }];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self).inset(3);
        make.height.equalTo(@18);
    }];
    [self.generateStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.descriptionLabel.mas_top).inset(5);
        make.height.equalTo(@20);
    }];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.equalTo(@(0.8));
    }];
    [super updateConstraints];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.imageView.alpha = 0.5;
    self.generateStatus.hidden = NO;
    self.descriptionLabel.hidden = NO;
    self.bottomLine.hidden = NO;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setShouldShowOverlay:(BOOL)shouldShowOverlay {
    if (shouldShowOverlay) {
        self.generateStatus.hidden = NO;
        self.descriptionLabel.hidden = NO;
        self.bottomLine.hidden = NO;
        _imageView.alpha = 0.5;
    } else {
        self.generateStatus.hidden = YES;
        self.descriptionLabel.hidden = YES;
        self.bottomLine.hidden = YES;
        _imageView.alpha = 1.0;
    }
}

@end
