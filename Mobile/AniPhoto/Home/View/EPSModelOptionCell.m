//
//  EPSModelOptionCell.m
//  AniPhoto
//
//  Created by PhatCH on 03/01/2024.
//

#import "EPSModelOptionCell.h"

@interface EPSModelOptionCell ()
@end

@implementation EPSModelOptionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;

        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageView.layer.cornerRadius = 10.0f;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
    }
    return self;
}

+ (NSString *)cellIdentifier {
    return @"EPSModelOptionCell";
}

- (void)setCellImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end