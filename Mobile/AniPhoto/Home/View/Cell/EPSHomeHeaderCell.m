//
//  EPSHomeHeaderCell.m
//  AniPhoto
//
//  Created by PhatCH on 29/4/24.
//

#import "EPSHomeHeaderCell.h"
#import "Masonry.h"
#import <SDWebImage/SDWebImage.h>

#define URL @"https://unsplash.com/photos/tq8Cuap8_wY/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8NHx8YW5pbWV8ZW58MHx8fHwxNzEzMjgxMzE3fDA&force=true&w=2400"

@interface EPSHomeHeaderCell ()
@end

@implementation EPSHomeHeaderCell

+ (NSString *)cellIdentifier {
    return @"EPSHomeHeaderCell";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [_imageView sd_setImageWithURL:[NSURL URLWithString:URL]];
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
