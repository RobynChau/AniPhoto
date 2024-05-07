//
//  EPSHomeBannerCell.m
//  AniPhoto
//
//  Created by PhatCH on 21/5/24.
//

#import "EPSHomeBannerCell.h"
#import "Masonry.h"

@interface EPSHomeBannerCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation EPSHomeBannerCell

+ (NSString *)cellIdentifier {
    return @"EPSHomeBannerCell";
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
        _imageView.image = [UIImage imageNamed:@"home_banner"];
        [self addSubview:_imageView];
    }
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

@end
