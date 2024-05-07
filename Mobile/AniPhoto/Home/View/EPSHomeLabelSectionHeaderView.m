//
//  EPSHomeLabelSectionHeaderView.m
//  AniPhoto
//
//  Created by PhatCH on 17/4/24.
//

#import "EPSHomeLabelSectionHeaderView.h"

#import "Masonry.h"
#import "EPSDefines.h"
#import "NSString+EPS.h"
#import "UIColor+EPS.h"

@interface EPSHomeLabelSectionHeaderView ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *accessoryIcon;
@property (nonatomic, strong) UILabel *accessoryLabel;
@property (nonatomic, assign) NSInteger sectionIndex;
@end

@implementation EPSHomeLabelSectionHeaderView

+ (NSString *)reusableViewIdentifier {
    return @"EPSHomeLabelSectionHeaderView";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:24];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = UIColor.whiteColor;
        [self addSubview:_nameLabel];

        _accessoryLabel = [[UILabel alloc] init];
        _accessoryLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightThin];
        _accessoryLabel.textColor = UIColor.whiteColor;
        _accessoryLabel.textAlignment = NSTextAlignmentRight;
        _accessoryLabel.text = @"See All";
        [self addSubview:_accessoryLabel];

        _accessoryIcon = [[UIImageView alloc] init];
        _accessoryIcon.image = [UIImage systemImageNamed:@"chevron.forward"];
        _accessoryIcon.tintColor = UIColor.secondaryLabelColor;
        [self addSubview:_accessoryIcon];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_headerViewTapped)];
        [self addGestureRecognizer:tapGesture];
    }
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    CGSize nameSize = [self.nameLabel.text sizeOfStringWithStyledFont:self.nameLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGSize accessorySize = [self.accessoryLabel.text sizeOfStringWithStyledFont:self.accessoryLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self);
        make.width.equalTo(@(nameSize.width));
    }];
    [self.accessoryIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.centerY.equalTo(self);
        make.size.equalTo(@14);
    }];
    [self.accessoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.trailing.equalTo(self.accessoryIcon.mas_leading).inset(5);
        make.width.equalTo(@(accessorySize.width));
    }];
    [super updateConstraints];
}

- (void)prepareForReuse {
    self.nameLabel.text = nil;
    self.sectionIndex = -1;
    self.delegate = nil;
    [super prepareForReuse];
}

- (void)setName:(NSString *)name sectionIndex:(NSInteger)index {
    self.nameLabel.text = name;
    self.sectionIndex = index;
}

- (void)_headerViewTapped {
    if (CHECK_DELEGATE(self.delegate, @selector(headerView:didSelectHeader:))) {
        [self.delegate headerView:self didSelectHeader:YES];
    }
}

@end
