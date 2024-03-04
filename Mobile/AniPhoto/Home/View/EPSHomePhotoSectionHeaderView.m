//
//  EPSHomePhotoSectionHeaderView.m
//  AniPhoto
//
//  Created by PhatCH on 17/4/24.
//

#import "EPSHomePhotoSectionHeaderView.h"
#import <SDWebImage/SDWebImage.h>

@interface EPSHomePhotoSectionHeaderView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation EPSHomePhotoSectionHeaderView

+ (NSString *)reusableViewIdentifier {
    return @"EPSHomePhotoSectionHeaderView";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [_imageView sd_setImageWithURL:[NSURL URLWithString:@"https://unsplash.com/photos/tq8Cuap8_wY/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8NHx8YW5pbWV8ZW58MHx8fHwxNzEzMjgxMzE3fDA&force=true&w=2400"]];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imageView];

        _typeLabel = [[UILabel alloc] init];
        _typeLabel.font = [UIFont systemFontOfSize:10];
        _typeLabel.textColor = UIColor.systemPurpleColor;
        _typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_typeLabel];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:26];
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_nameLabel];
    }
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)setNeedsUpdateConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [_imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_imageView.heightAnchor constraintEqualToAnchor:self.heightAnchor constant:-50],

        [_typeLabel.bottomAnchor constraintEqualToAnchor:_nameLabel.topAnchor constant:5],
        [_typeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [_typeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_typeLabel.heightAnchor constraintEqualToConstant:20],

        [_nameLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [_nameLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_nameLabel.heightAnchor constraintEqualToConstant:30],
    ]];
    [super setNeedsUpdateConstraints];
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
