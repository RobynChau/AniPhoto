//
//  EPSUserInfoViewController.m
//  AniPhoto
//
//  Created by PhatCH on 26/5/24.
//

#import "EPSUserInfoViewController.h"

#import "EPSDefines.h"
#import "EPSUserSessionManager.h"

@interface EPSUserInfoViewController () <
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation EPSUserInfoViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;

        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return self;
}

- (void)updateViewConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self.view.mas_safeAreaLayoutGuide);
    }];
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Profile";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                             target:self
                                             action:@selector(_closeButtonTapped)];
}

- (void)_closeButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.item == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"Name  %@", EPSUserSessionManager.shared.userSession.userName];
    } else if (indexPath.item == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"Email  %@", EPSUserSessionManager.shared.userSession.userEmail];
    }
    cell.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


@end
