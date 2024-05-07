//
//  EPSHomeToolCell.m
//  AniPhoto
//
//  Created by PhatCH on 14/5/24.
//

#import "EPSHomeToolCell.h"
#import "Masonry.h"

@interface EPSHomeToolCell ()
@property (nonatomic, assign) EPSHomeToolType toolType;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation EPSHomeToolCell

+ (NSString *)cellIdentifier {
    return @"EPSHomeToolCell";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

+ (CGSize)itemSize {
    return CGSizeMake(60, 90);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _toolType = EPSHomeToolTypeEdit;

        _circleView = [[UIView alloc] init];
        _circleView.layer.cornerRadius = 30.0;
        _circleView.layer.masksToBounds = YES;
        _circleView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        [self addSubview:_circleView];

        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = UIColor.clearColor;
        _imageView.tintColor = UIColor.labelColor;
        _imageView.image = [UIImage systemImageNamed:@"plus"];
        [self addSubview:_imageView];

        _label = [[UILabel alloc] init];
        _label.text = @"Tool";
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self);
        make.size.equalTo(@60);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.circleView.mas_centerY);
        make.size.equalTo(@30);
    }];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.circleView.mas_bottom);
        make.leading.trailing.bottom.equalTo(self);
    }];
}

- (void)setUpWithType:(EPSHomeToolType)toolType {
    self.toolType = toolType;
    switch (self.toolType) {
        case EPSHomeToolTypeNone:
            break;
        case EPSHomeToolTypeEdit:
            self.circleView.backgroundColor = UIColor.darkGrayColor;
            self.imageView.image = [UIImage systemImageNamed:@"plus"];
            self.label.text = @"Edit";
            self.label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
            break;
        case EPSHomeToolTypeAniGAN:
            self.circleView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
            self.imageView.image = [UIImage systemImageNamed:@"wand.and.stars"];
            self.label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
            self.label.text = @"AI Cartoon";
            break;
        case EPSHomeToolTypeSticker:
            self.circleView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
            self.imageView.image = [UIImage imageNamed:@"zl_imageSticker"];
            self.label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
            self.label.text = @"Sticker";
            break;
        case EPSHomeToolTypeText:
            self.circleView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
            self.imageView.image = [UIImage imageNamed:@"zl_textSticker"];
            self.label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
            self.label.text = @"Text";
            break;
        case EPSHomeToolTypeFilter:
            self.circleView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
            self.imageView.image = [UIImage imageNamed:@"zl_filter"];
            self.label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
            self.label.text = @"Filter";
            break;
    }
}

@end
