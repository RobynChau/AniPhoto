//
//  EPSSettingsViewController.m
//  AniPhoto
//
//  Created by PhatCH on 19/01/2024.
//

#import "EPSSettingsViewController.h"
#import "EPSSettingCell.h"
#import "EPSSettingSectionConfiguration.h"

@interface EPSSettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *settingsView;
@property (nonatomic, strong) NSArray<EPSSettingSectionConfiguration *> *sectionSettings;
@end

@implementation EPSSettingsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
        _settingsView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        [_settingsView registerClass:EPSSettingCell.class forCellReuseIdentifier:EPSSettingCell.reuseIdentifier];
        _settingsView.translatesAutoresizingMaskIntoConstraints = NO;
        _settingsView.delegate = self;
        _settingsView.dataSource = self;
        [self.view addSubview:_settingsView];

        _sectionSettings = @[
            [EPSSettingSectionConfiguration subscriptionSettingsConfig],
            [EPSSettingSectionConfiguration socialSettingsConfig],
            [EPSSettingSectionConfiguration generalSettingsConfig],
            [EPSSettingSectionConfiguration supportSettingsConfig],
        ];
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
    [NSLayoutConstraint activateConstraints:@[
        [self.settingsView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.settingsView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.settingsView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.settingsView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
    [super updateViewConstraints];
}

- (EPSSettingCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSInteger sectionIndex = indexPath.section;
    NSInteger itemIndex = indexPath.item;
    EPSSettingSectionConfiguration *sectionConfig = self.sectionSettings[sectionIndex];
    EPSSettingItemConfiguration *itemConfig = sectionConfig.items[itemIndex];
    EPSSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:EPSSettingCell.reuseIdentifier];
    cell.customImageView.image = [UIImage systemImageNamed:itemConfig.iconName];
    cell.customTextLabel.text = itemConfig.settingTitle;
    cell.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.sectionSettings[section].items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionSettings.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    EPSSettingSectionConfiguration *sectionSettings = self.sectionSettings[section];
    return sectionSettings.sectionTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

@end
