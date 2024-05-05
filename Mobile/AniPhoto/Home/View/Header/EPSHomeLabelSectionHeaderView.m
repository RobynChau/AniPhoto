//
//  EPSHomeLabelSectionHeaderView.m
//  AniPhoto
//
//  Created by PhatCH on 17/4/24.
//

#import "EPSHomeLabelSectionHeaderView.h"
#import "Masonry.h"
#import "UIColor+EPS.h"

@interface EPSHomeLabelSectionHeaderView ()
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
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
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.font = [UIFont systemFontOfSize:14];
        _typeLabel.textColor = [UIColor colorWithHexString:@"#b049f5"];
        [self addSubview:_typeLabel];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:26];
        _nameLabel.textColor = UIColor.whiteColor;
        [self addSubview:_nameLabel];
    }
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).inset(0);
        make.top.trailing.equalTo(self);
        make.height.equalTo(@20);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).inset(0);
        make.top.equalTo(self.typeLabel.mas_bottom).inset(8);
        make.trailing.equalTo(self);
        make.height.equalTo(@20);
    }];
    [super updateConstraints];
}

- (void)prepareForReuse {
    _typeLabel.text = nil;
    _nameLabel.text = nil;
    [super prepareForReuse];
}

- (void)setSectionType:(HomeModelSectionType)sectionType
           sectionName:(NSString *)sectionName {
    switch (sectionType) {
        case HomeModelSectionTypeDefault:
            _typeLabel.text = @"Hot";
            break;
        case HomeModelSectionTypeExclusive:
            _typeLabel.text = @"Exclusive";
            break;
        case HomeModelSectionTypeLatest:
            _typeLabel.text = @"Latest";
            break;
        case HomeModelSectionTypeTrendy:
            _typeLabel.text = @"Trendy";
            break;
        case HomeModelSectionTypePhotoEdit:
            _typeLabel.text = @"Photo Edit";
            break;
        case HomeModelSectionTypeCinematic:
            _typeLabel.text = @"Cinematic";
            break;
        default:
            _typeLabel.text = @"Hot";
            break;
    }

    _nameLabel.text = sectionName;
}

@end
