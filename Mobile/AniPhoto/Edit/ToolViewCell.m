//
//  ToolViewCell.m
//  AniPhoto
//
//  Created by PhatCH on 20/12/2023.
//

#import "ToolViewCell.h"

@interface ToolViewCell ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *labelView;
@end

@implementation ToolViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - (self.frame.size.width * 0.7)) / 2, 0, self.frame.size.width * 0.7, self.frame.size.width)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.image = [UIImage systemImageNamed:@"slider.horizontal.3"];
        _iconView.tintColor = UIColor.labelColor;
        [self addSubview:_iconView];

        _labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - self.frame.size.width + 5, self.frame.size.width, self.frame.size.height - self.frame.size.width - 5)];
        _labelView.text = @"Tool";
        _labelView.textColor = UIColor.labelColor;
        _labelView.textAlignment = NSTextAlignmentCenter;
        _labelView.font = [UIFont systemFontOfSize:12];
        [self addSubview:_labelView];
    }
    return self;
}

@end
