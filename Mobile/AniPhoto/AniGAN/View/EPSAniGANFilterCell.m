//
//  EPSAniGANFilterCell.m
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import "EPSAniGANFilterCell.h"
#import "EPSSimplifiedFilterModel.h"
#import "Masonry.h"

@interface EPSAniGANFilterCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation EPSAniGANFilterCell

+ (NSString *)cellIdentifier {
    return @"EPSAniGANFilterCell";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5.0f;
        self.clipsToBounds = YES;

        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
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
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self);
    }];
    [super updateConstraints];
}

- (void)updateWithModel:(EPSSimplifiedFilterModel *)model {
    self.imageView.image = [UIImage imageNamed:model.imageName];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.layer.borderColor = nil;
    self.layer.borderWidth = 0.0f;
    self.alpha = 1.0f;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.layer.borderColor = UIColor.greenColor.CGColor;
        self.layer.borderWidth = 1.0f;
        self.alpha = 0.8f;
    } else {
        self.layer.borderColor = nil;
        self.layer.borderWidth = 0.0f;
        self.alpha = 1.0f;
    }
}

@end
