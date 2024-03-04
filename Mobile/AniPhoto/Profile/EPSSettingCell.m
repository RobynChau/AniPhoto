//
//  EPSSettingCell.m
//  AniPhoto
//
//  Created by PhatCH on 22/01/2024.
//

#import "EPSSettingCell.h"

@interface EPSSettingCell ()

@end

@implementation EPSSettingCell

+ (NSString *)reuseIdentifier {
    return @"SettingCell";
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _customImageView = [[UIImageView alloc] init];
        _customImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_customImageView];

        _customTextLabel = [[UILabel alloc] init];
        _customTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _customTextLabel.textColor = UIColor.labelColor;
        [self addSubview:_customTextLabel];
    }
    return self;
}

- (void)updateConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.customImageView.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:10],
        [self.customImageView.centerYAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerYAnchor],
        [self.customImageView.heightAnchor constraintEqualToConstant:25],
        [self.customImageView.widthAnchor constraintEqualToConstant:25],

        [self.customTextLabel.leadingAnchor constraintEqualToAnchor:self.customImageView.trailingAnchor constant:10],
        [self.customTextLabel.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor],
        [self.customTextLabel.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor],
        [self.customTextLabel.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor],
    ]];
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    self.customImageView.image = nil;
    self.customTextLabel.text = nil;
    [super prepareForReuse];
}

@end
