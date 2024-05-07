//
//  EPSSettingSectionConfiguration.m
//  AniPhoto
//
//  Created by PhatCH on 22/01/2024.
//

#import "EPSSettingSectionConfiguration.h"

@implementation EPSSettingItemConfiguration

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(nullable NSString *)iconName {
    self = [self initWithTitle:title 
                      iconName:iconName
                         style:EPSSettingItemStyleDefault];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(nullable NSString *)iconName
                        style:(EPSSettingItemStyle)style {
    self = [super init];
    if (self) {
        _settingTitle = title;
        _iconName = iconName;
        _style = style;
    }
    return self;
}

@end

@implementation EPSSettingSectionConfiguration

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray<EPSSettingItemConfiguration *> *)item {
    self = [super init];
    if (self) {
        _sectionTitle = title;
        _items = item;
    }
    return self;
}

+ (EPSSettingSectionConfiguration *)generalSettingsConfig {
    NSArray *items = @[
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Privacy policy" iconName:nil],
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Terms of use" iconName:nil],
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"More information" iconName:nil],
    ];
    EPSSettingSectionConfiguration *setting = [[EPSSettingSectionConfiguration alloc]
                                               initWithTitle:@"General"
                                               items:items];
    return setting;
}

+ (EPSSettingSectionConfiguration *)supportSettingsConfig {
    NSArray *items = @[
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"FAQ" 
                                                  iconName:nil],
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Contact us" 
                                                  iconName:nil],
    ];
    EPSSettingSectionConfiguration *setting = [[EPSSettingSectionConfiguration alloc] 
                                               initWithTitle:@"Support"
                                               items:items];
    return setting;
}

+ (EPSSettingSectionConfiguration *)socialSettingsConfig {
    NSArray *items = @[
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Follow us on Instagram" 
                                                  iconName:@"instagram_logo"],
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Follow us on Tiktok"
                                                  iconName:@"tiktok_logo"],
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Rate the app" 
                                                  iconName:@"star.circle.fill"],
    ];
    EPSSettingSectionConfiguration *setting = [[EPSSettingSectionConfiguration alloc]
                                               initWithTitle:@"Social"
                                               items:items];
    return setting;
}

+ (EPSSettingSectionConfiguration *)subscriptionSettingsConfig {
    NSArray *items = @[
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Manage subscriptions" 
                                                  iconName:@"person.circle.fill"],
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Redeem offer code"
                                                  iconName:@"creditcard.fill"],
    ];
    EPSSettingSectionConfiguration *setting = [[EPSSettingSectionConfiguration alloc]
                                               initWithTitle:@"Subscriptions"
                                               items:items];
    return setting;
}

+ (EPSSettingSectionConfiguration *)signOutSettingsConfig {
    NSArray *items = @[
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Sign Out"
                                                  iconName:@"rectangle.portrait.and.arrow.forward.fill"
                                                     style:EPSSettingItemStyleDestruction],
    ];
    EPSSettingSectionConfiguration *setting = [[EPSSettingSectionConfiguration alloc]
                                               initWithTitle:@"Sign Out"
                                               items:items];
    return setting;
}

+ (EPSSettingSectionConfiguration *)headerSettingsConfig {
    NSArray *items = @[
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Header"
                                                  iconName:@"rectangle.portrait.and.arrow.forward.fill"
                                                     style:EPSSettingItemStyleDestruction],
    ];
    EPSSettingSectionConfiguration *setting = [[EPSSettingSectionConfiguration alloc]
                                               initWithTitle:@"Header"
                                               items:items];
    return setting;
}

+ (EPSSettingSectionConfiguration *)promoteSubConfig {
    NSArray *items = @[
        [[EPSSettingItemConfiguration alloc] initWithTitle:@"Promote"
                                                  iconName:@"rectangle.portrait.and.arrow.forward.fill"
                                                     style:EPSSettingItemStyleDestruction],
    ];
    EPSSettingSectionConfiguration *setting = [[EPSSettingSectionConfiguration alloc]
                                               initWithTitle:@"Promote"
                                               items:items];
    return setting;
}

@end
