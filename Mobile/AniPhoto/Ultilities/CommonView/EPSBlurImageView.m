//
//  EPSBlurImageView.m
//  AniPhoto
//
//  Created by PhatCH on 25/4/24.
//

#import "EPSBlurImageView.h"

@implementation EPSBlurImageView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addGradientLayers];
}

- (void)addGradientLayers {
    CAGradientLayer *bottomGradientLayer = [CAGradientLayer layer];
    bottomGradientLayer.frame = CGRectMake(0, self.frame.size.height - self.frame.size.height * 0.3, self.frame.size.width, self.frame.size.height * 0.3);
    bottomGradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor, (id)[[UIColor blackColor] colorWithAlphaComponent:1].CGColor];
    [self.layer addSublayer:bottomGradientLayer];
}

@end
