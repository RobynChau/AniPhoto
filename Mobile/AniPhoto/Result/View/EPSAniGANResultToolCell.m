//
//  EPSAniGANResultToolCell.m
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import "EPSAniGANResultToolCell.h"
#import "EPSSimplifiedToolModel.h"
#import "Masonry.h"

@interface EPSAniGANResultToolCell ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation EPSAniGANResultToolCell

+ (NSString *)cellIdentifier {
    return @"EPSAniGANResultToolCell";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _iconView = [[UIImageView alloc] init];
        _iconView.image = [UIImage imageNamed:@"zl_clip"];
        [self addSubview:_iconView];

        _label = [[UILabel alloc] init];
        _label.text = @"Crop";
        _label.font = [UIFont systemFontOfSize:14];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

- (void)updateConstraints {
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self);
        make.size.equalTo(@26);
    }];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_bottom).inset(8);
        make.leading.trailing.equalTo(self);
        make.height.equalTo(@15);
    }];
    [super updateConstraints];
}

- (void)updateWithModel:(EPSSimplifiedToolModel *)model {
    self.iconView.image = [UIImage imageNamed:model.iconName];
    self.label.text = model.toolName;
}

- (void)prepareForReuse {
    self.iconView.image = nil;
    self.label.text = nil;
    [super prepareForReuse];
}

@end
