//
//  EPSProfileViewController.m
//  AniPhoto
//
//  Created by PhatCH on 19/01/2024.
//

#import "EPSProfileViewController.h"
#import "EPSProfileSettingCell.h"
#import "EPSProfileHeaderCell.h"
#import "EPSProfileSubscriptionPromoteCell.h"
#import "EPSSettingSectionConfiguration.h"
#import "EPSUserSessionManager.h"
#import "EPSSubscriptionViewController.h"
#import "EPSCreditPurchaseViewController.h"
#import "EPSSignInViewController.h"
#import "EPSUserInfoViewController.h"
#import "EPSOverlayHeaderView.h"

#import "EPSDefines.h"
#import <StoreKit/StoreKit.h>

@interface EPSProfileViewController () <
UITableViewDelegate,
UITableViewDataSource,
EPSProfileHeaderCellDelegate
>
@property (nonatomic, strong) UITableView *mainView;
@property (nonatomic, strong) NSArray<EPSSettingSectionConfiguration *> *sectionSettings;
@property (nonatomic, strong) EPSOverlayHeaderView *overlayHeaderView;
@end

@implementation EPSProfileViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

        _mainView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        [_mainView registerClass:EPSProfileSettingCell.class 
              forCellReuseIdentifier:EPSProfileSettingCell.reuseIdentifier];
        [_mainView registerClass:EPSProfileHeaderCell.class 
              forCellReuseIdentifier:EPSProfileHeaderCell.reuseIdentifier];
        [_mainView registerClass:EPSProfileSubscriptionPromoteCell.class
              forCellReuseIdentifier:EPSProfileSubscriptionPromoteCell.reuseIdentifier];
        _mainView.delegate = self;
        _mainView.dataSource = self;
        [self.view addSubview:_mainView];

        _sectionSettings = @[
            [EPSSettingSectionConfiguration headerSettingsConfig],
            [EPSSettingSectionConfiguration promoteSubConfig],
            [EPSSettingSectionConfiguration subscriptionSettingsConfig],
            [EPSSettingSectionConfiguration socialSettingsConfig],
            [EPSSettingSectionConfiguration generalSettingsConfig],
            [EPSSettingSectionConfiguration supportSettingsConfig],
            [EPSSettingSectionConfiguration signOutSettingsConfig],
        ];

        _overlayHeaderView = [[EPSOverlayHeaderView alloc] initWithTitle:@"Profile"];
        [self.view addSubview:_overlayHeaderView];

        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didFetchUserInfo) name:kEPSSignInManagerDidFetchUserInfo object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didFetchUserCredit) name:kEPSSignInManagerDidFetchUserCredit object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didSignOutUser) name:kEPSSignInManagerDidSignOutUser object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didFetchUserSubscription) name:kEPSSignInManagerDidFetchUserSubscription object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setNeedsUpdateConstraints];
    
}

- (void)updateViewConstraints {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view.mas_safeAreaLayoutGuide);
    }];
    [self.overlayHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(-30, 10, 0, 10));
        make.height.equalTo(@32);
    }];
    [super updateViewConstraints];
}

- (__kindof UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSInteger sectionIndex = indexPath.section;
    NSInteger itemIndex = indexPath.item;
    EPSSettingSectionConfiguration *sectionConfig = self.sectionSettings[sectionIndex];
    if ([sectionConfig.sectionTitle isEqualToString:@"Header"]) {
        EPSProfileHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:EPSProfileHeaderCell.reuseIdentifier];
        cell.delegate = self;
        [cell updateWithUserModel:EPSUserSessionManager.shared.userSession];
        cell.backgroundColor = UIColor.clearColor;
        return cell;
    } else if ([sectionConfig.sectionTitle isEqualToString:@"Promote"]) {
        EPSProfileSubscriptionPromoteCell *cell = [tableView dequeueReusableCellWithIdentifier:EPSProfileSubscriptionPromoteCell.reuseIdentifier];
        [cell updateWithPromoteSubscription];
        cell.backgroundColor = UIColor.clearColor;
        return cell;
    } else {
        EPSSettingItemConfiguration *itemConfig = sectionConfig.items[itemIndex];
        EPSProfileSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:EPSProfileSettingCell.reuseIdentifier];
        UIImage *icon = [UIImage systemImageNamed:itemConfig.iconName];
        if (!CHECK_CLASS(icon, UIImage)) {
            icon = [UIImage imageNamed:itemConfig.iconName];
        }
        cell.customImageView.image = icon;
        cell.customImageView.tintColor = UIColor.labelColor;
        cell.customTextLabel.text = itemConfig.settingTitle;
        cell.customTextLabel.textColor = UIColor.labelColor;
        cell.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.sectionSettings[section].items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionSettings.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    EPSSettingSectionConfiguration *sectionConfig = self.sectionSettings[section];
    if ([sectionConfig.sectionTitle isEqualToString:@"Header"]
        || [sectionConfig.sectionTitle isEqualToString:@"Promote"]) {
        return nil;
    }

    return sectionConfig.sectionTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    EPSSettingSectionConfiguration *sectionConfig = self.sectionSettings[indexPath.section];
    if ([sectionConfig.sectionTitle isEqualToString:@"Header"]) {
        return 80;
    } else if ([sectionConfig.sectionTitle isEqualToString:@"Promote"]) {
        return 160;
    }
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionIndex = indexPath.section;
    NSInteger itemIndex = indexPath.item;
    EPSSettingSectionConfiguration *sectionConfig = self.sectionSettings[sectionIndex];
    EPSSettingItemConfiguration *itemConfig = sectionConfig.items[itemIndex];

    if ([sectionConfig.sectionTitle isEqualToString:@"Header"]) {

    } else if ([sectionConfig.sectionTitle isEqualToString:@"Promote"]) {
        if ([EPSUserSessionManager.shared.userSession isSignedIn]) {
            EPSSubscriptionViewController *vc = [[EPSSubscriptionViewController alloc] init];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:YES completion:nil];
        } else {
            EPSSignInViewController *vc = [[EPSSignInViewController alloc] init];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:YES completion:nil];
        }
    } else {
        if ([itemConfig.settingTitle isEqualToString:@"Rate the app"]) {
            if (@available(iOS 14.0, *)) {
                [SKStoreReviewController requestReviewInScene:self.view.window.windowScene];
            } else {
                [SKStoreReviewController requestReview];
            }
        } else if ([itemConfig.settingTitle isEqualToString:@"Sign Out"]) {
            [self _handleSignOutButtonTapped];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)headerCell:(EPSProfileHeaderCell *)headerCell didSelectForTapActionType:(EPSProfileHeaderCellTapActionType)tapActionType {
    switch (tapActionType) {
        case EPSProfileHeaderCellTapActionTypeSignIn: {
            EPSSignInViewController *vc = [[EPSSignInViewController alloc] init];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:YES completion:^{
                [self.mainView reloadData];
            }];
            break;
        }
        case EPSProfileHeaderCellTapActionTypeCheckInfo: {
            EPSUserInfoViewController *vc = [[EPSUserInfoViewController alloc] init];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:YES completion:nil];
            break;
        }
        case EPSProfileHeaderCellTapActionTypeBuyCredit: {
            EPSCreditPurchaseViewController *vc = [[EPSCreditPurchaseViewController alloc] init];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:YES completion:nil];
            break;
        }
        case EPSProfileHeaderCellTapActionTypeCheckSubscription: {
            EPSSubscriptionViewController *vc = [[EPSSubscriptionViewController alloc] init];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:YES completion:nil];
            break;
        }
        case EPSProfileHeaderCellTapActionTypeUnknown:
        default:
            break;
    }
}

- (void)_didFetchUserInfo {
    [self.mainView reloadData];
}

- (void)_didFetchUserCredit {
    [self.mainView reloadData];
}

- (void)_didFetchUserSubscription {
    if ([EPSUserSessionManager.shared getPromoteSubscriptionType] == EPSSubscriptionPlanTypeHide) {
        _sectionSettings = @[
            [EPSSettingSectionConfiguration headerSettingsConfig],
            [EPSSettingSectionConfiguration subscriptionSettingsConfig],
            [EPSSettingSectionConfiguration socialSettingsConfig],
            [EPSSettingSectionConfiguration generalSettingsConfig],
            [EPSSettingSectionConfiguration supportSettingsConfig],
            [EPSSettingSectionConfiguration signOutSettingsConfig],
        ];
    } else {
        _sectionSettings = @[
            [EPSSettingSectionConfiguration headerSettingsConfig],
            [EPSSettingSectionConfiguration promoteSubConfig],
            [EPSSettingSectionConfiguration subscriptionSettingsConfig],
            [EPSSettingSectionConfiguration socialSettingsConfig],
            [EPSSettingSectionConfiguration generalSettingsConfig],
            [EPSSettingSectionConfiguration supportSettingsConfig],
            [EPSSettingSectionConfiguration signOutSettingsConfig],
        ];
    }
    [self.mainView reloadData];
}

- (void)_didSignOutUser {
    [self.mainView reloadData];
}

- (void)_handleSignOutButtonTapped {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Are you sure to log out"
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Log Out" 
                                           style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction * _Nonnull action) {
        [EPSUserSessionManager.shared signOutUser];
    }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleCancel
                                         handler:nil]];

    [self presentViewController:ac animated:YES completion:nil];
}

@end
