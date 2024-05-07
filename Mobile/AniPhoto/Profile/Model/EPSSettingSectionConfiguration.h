//
//  EPSSettingSectionConfiguration.h
//  AniPhoto
//
//  Created by PhatCH on 22/01/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    EPSSettingItemStyleDefault              =0,
    EPSSettingItemStyleDestruction          = 1,
} EPSSettingItemStyle;

@interface EPSSettingItemConfiguration : NSObject

@property (nonatomic, copy, readonly) NSString *settingTitle;
@property (nonatomic, copy, readonly, nullable) NSString *iconName;
@property (nonatomic, assign) EPSSettingItemStyle style;

@end

@interface EPSSettingSectionConfiguration : NSObject

@property (nonatomic, copy, readonly) NSString *sectionTitle;
@property (nonatomic, strong, readonly) NSArray<EPSSettingItemConfiguration *> *items;

+ (EPSSettingSectionConfiguration *)generalSettingsConfig;
+ (EPSSettingSectionConfiguration *)supportSettingsConfig;
+ (EPSSettingSectionConfiguration *)socialSettingsConfig;
+ (EPSSettingSectionConfiguration *)subscriptionSettingsConfig;
+ (EPSSettingSectionConfiguration *)signOutSettingsConfig;
+ (EPSSettingSectionConfiguration *)headerSettingsConfig;
+ (EPSSettingSectionConfiguration *)promoteSubConfig;

@end

NS_ASSUME_NONNULL_END
