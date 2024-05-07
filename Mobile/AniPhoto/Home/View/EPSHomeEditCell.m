//
//  EPSHomeEditCell.m
//  AniPhoto
//
//  Created by PhatCH on 19/5/24.
//

#import "EPSHomeEditCell.h"
#import "Masonry.h"
#import "NSString+EPS.h"

@interface EPSHomeEditCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation EPSHomeEditCell

+ (NSString *)cellIdentifier {
    return @"EPSHomeEditCell";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;

        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];

        _iconView = [[UIImageView alloc] init];
        _iconView.image = [UIImage systemImageNamed:@"plus"];
        _iconView.tintColor = UIColor.labelColor;
        [self addSubview:_iconView];

        _label = [[UILabel alloc] init];
        _label.text = @"Edit";
        _label.font = [UIFont systemFontOfSize:15];
        _label.textColor = UIColor.labelColor;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    CGSize textSize = [self.label.text sizeOfStringWithStyledFont:self.label.font withSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self);
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_top).inset(self.frame.size.height / 3);
        make.size.equalTo(@30);
    }];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.iconView.mas_bottom).inset(5);
        make.height.equalTo(@(textSize.height));
    }];
    [super updateConstraints];
}

- (void)setImage:(nullable UIImage *)image {
    if (image) {
        self.imageView.image = image;
        self.iconView.hidden = YES;
        self.label.hidden = YES;
    } else {
        self.imageView.image = nil;
        self.iconView.hidden = NO;
        self.label.hidden = NO;
    }
}

- (UIImage *)cellImage {
    return self.imageView.image;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.iconView.hidden = YES;
    self.label.hidden = YES;
}

@end
