//
//  EPSAniGANViewController.m
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import "EPSAniGANViewController.h"
#import "EPSAniGANEmptyView.h"
#import "EPSPhotoGenerator.h"
#import "EPSAniGANResultViewController.h"
#import "EPSSimplifiedFilterModel.h"
#import "EPSAniGANFilterCell.h"
#import "EPSUserSessionManager.h"
#import "EPSSubscriptionViewController.h"

#import "EPSDefines.h"

#define BUTTON_WIDTH 180
#define INTER_SECTION_PADDING 15.0f
#define HEADER_SECTION_HEIGHT 240
#define MODEL_SECTION_HEADER_HEIGHT 50
#define MODEL_SECTION_HEADER_BOTTOM_PADDING 10
#define MODEL_SECTION_CONTENT_HEIGHT 280
#define MODEL_SECTION_INTER_ITEM_SPACING 16
#define MODEL_SECTION_CONTENT_LEADING_PADDING 10
#define CREATED_SECTION_CONTENT_HEIGHT 180

@interface EPSAniGANViewController () <
UICollectionViewDelegate
, UICollectionViewDataSource
, UIViewControllerTransitioningDelegate
>
@property (nonatomic, strong) EPSAniGANEmptyView *emptyView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *generateButton;
@property (nonatomic, strong) UICollectionView *filterVC;
@property (nonatomic, strong) EPSFilter *currentFilter;
@property (nonatomic, strong) NSArray<EPSSimplifiedFilterModel *> *filterModels;
@property (nonatomic, strong) UILabel *styleLabel;
@property (nonatomic, strong) UILabel *currentCreditLabel;
@end

@implementation EPSAniGANViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _filterModels = [EPSSimplifiedFilterModel allFilterModels];

        _emptyView = [[EPSAniGANEmptyView alloc] init];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_changeImageButtonPressed)];
        [_emptyView addGestureRecognizer:tapGesture];
        [self.view addSubview:_emptyView];

        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.hidden = YES;
        _imageView.backgroundColor = [UIColor.secondarySystemBackgroundColor colorWithAlphaComponent:0.5];
        [self.view addSubview:_imageView];

        _generateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _generateButton.backgroundColor = UIColor.clearColor;
        _generateButton.layer.cornerRadius = 20.0f;
        _generateButton.layer.masksToBounds = YES;
        NSAttributedString *buttonTitle = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.font([UIFont systemFontOfSize:17]).textColor(UIColor.blackColor).lineSpacing(8);
            make.append(@"Generate Now 🚀");
        }];
        [_generateButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];
        [_generateButton addTarget:self action:@selector(generateButtonPressed) forControlEvents:UIControlEventTouchDown];
        [_generateButton setGradientBackgroundColors:@[UIColor.customBlue,
                                                       UIColor.customGreen]
                                           direction:DTImageGradientDirectionToRight
                                               state:UIControlStateNormal];
        [self.view addSubview:_generateButton];

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(80, 80);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _filterVC = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _filterVC.allowsMultipleSelection = NO;
        _filterVC.showsVerticalScrollIndicator = NO;
        _filterVC.showsHorizontalScrollIndicator = NO;
        _filterVC.delegate = self;
        _filterVC.dataSource = self;
        [_filterVC registerClass:EPSAniGANFilterCell.class forCellWithReuseIdentifier:EPSAniGANFilterCell.cellIdentifier];
        [self.view addSubview:_filterVC];

        _styleLabel = [[UILabel alloc] init];
        _styleLabel.text = @"Styles";
        _styleLabel.font = [UIFont systemFontOfSize:16];
        [self.view addSubview:_styleLabel];

        _currentCreditLabel = [[UILabel alloc] init];
        NSAttributedString *creditText = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.font([UIFont systemFontOfSize:18]).textColor(UIColor.whiteColor).lineSpacing(8);
            make.append(@"My credits: ");
            make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
                UIImage *image = [[UIImage systemImageNamed:@"leaf.fill"] imageWithTintColor:UIColor.greenColor];
                make.image = image;
                make.bounds = CGRectMake(0, -2, 18, 18);
            });
            make.append(EPSUserSessionManager.shared.userSession.totalCreditCount >= kQuotaMax ? @" Unlimited" : @(EPSUserSessionManager.shared.userSession.totalCreditCount).stringValue);
        }];
        _currentCreditLabel.attributedText = creditText;
        [self.view addSubview:_currentCreditLabel];

        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didFetchUserCredit) name:kEPSSignInManagerDidFetchUserCredit object:nil];

    }
    return self;
}

- (void)updateViewConstraints {
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(6, 0, 0, 0));
        make.height.equalTo(self.view).multipliedBy(0.5);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view.mas_safeAreaLayoutGuide);
        make.height.equalTo(self.view).multipliedBy(0.5);
    }];
    [self.generateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuide).inset(30);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(@50);
    }];
    [self.filterVC mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.generateButton.mas_top).inset(15);
        make.leading.trailing.equalTo(self.view).insets(UIEdgeInsetsMake(0, 12, 0, 0));;
        make.height.equalTo(@85);
    }];
    [self.styleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).insets(UIEdgeInsetsMake(0, 12, 0, 0));
        make.bottom.equalTo(self.filterVC.mas_top).inset(10);
        make.height.equalTo(@20);
    }];
    [self.currentCreditLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view).insets(UIEdgeInsetsMake(0, 12, 0, 0));
        make.bottom.equalTo(self.styleLabel.mas_top).inset(20);
        make.height.equalTo(@20);
    }];
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                                                                          target:self
                                                                                          action:@selector(_closeButtonPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"photo.on.rectangle.angled"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(_changeImageButtonPressed)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.filterVC selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)_closeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_changeImageButtonPressed {
    EPSCameraConfiguration *config = [[EPSCameraConfiguration alloc] init];
    config.allowRecordVideo = NO;
    config.devicePosition = DevicePositionFront;
    EPSCustomCamera *camera = [[EPSCustomCamera alloc] initWithCameraConfig:config canEdit:NO];
    camera.takeDoneBlock = ^(UIImage * _Nullable image, NSURL * _Nullable imageURL) {
        self.imageView.image = image;
        self.imageView.hidden = NO;
        self.emptyView.hidden = YES;
    };
    [self showDetailViewController:camera sender:nil];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    EPSAniGANFilterCell *cell = (EPSAniGANFilterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:EPSAniGANFilterCell.cellIdentifier forIndexPath:indexPath];
    EPSSimplifiedFilterModel *model = self.filterModels[indexPath.item];
    [cell updateWithModel:model];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    return self.filterModels.count;
}

- (void)generateButtonPressed {
    if (!self.imageView.image) {
        [self _changeImageButtonPressed];
        return;
    }

    if (EPSUserSessionManager.shared.userSession.totalCreditCount == 0) {
        EPSSubscriptionViewController *vc = [[EPSSubscriptionViewController alloc] init];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        navVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navVC animated:YES completion:nil];
        return;
    }

    EPSAniGANResultViewController *vc = [[EPSAniGANResultViewController alloc] initWithOriginImage:self.imageView.image shouldGenerate:YES isStandAloneVC:NO];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Animation Transition Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return [[EPSAniGANPresentEditorTransition alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[EPSAniGANDismissEditorTransition alloc] init];
}

- (void)_didFetchUserCredit {
    NSAttributedString *creditText = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.font([UIFont systemFontOfSize:18]).textColor(UIColor.whiteColor).lineSpacing(8);
        make.append(@"My credits: ");
        make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
            UIImage *image = [[UIImage systemImageNamed:@"leaf.fill"] imageWithTintColor:UIColor.greenColor];
            make.image = image;
            make.bounds = CGRectMake(0, -2, 18, 18);
        });
        make.append(EPSUserSessionManager.shared.userSession.totalCreditCount >= kQuotaMax ? @" Unlimited" : @(EPSUserSessionManager.shared.userSession.totalCreditCount).stringValue);
    }];
    self.currentCreditLabel.attributedText = creditText;
}

@end
