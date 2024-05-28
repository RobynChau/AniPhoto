//
//  EPSSubscriptionViewController.m
//  AniPhoto
//
//  Created by PhatCH on 22/5/24.
//

#import "EPSSubscriptionViewController.h"
#import "EPSStoreKitManager.h"
#import "EPSSignInViewController.h"

#import "EPSDefines.h"
#import "EPSUserSessionManager.h"
#import "AniPhoto-Swift.h"

@interface EPSSubscriptionViewController () <
EPSSegmentedControlDataSource,
EPSSegmentedControlDelegate
>
@property (nonatomic, strong) EPSSegmentedControl *segmentControl;
@property (nonatomic, strong) EPSGradientLabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UIButton *yearButton;
@property (nonatomic, strong) UIButton *monthButton;
@property (nonatomic, strong) UILabel *productName;
@property (nonatomic, strong) UILabel *productDesc;
@property (nonatomic, strong) UILabel *productPrice;
@property (nonatomic, strong) SKProduct *monthProduct;
@property (nonatomic, strong) SKProduct *yearProduct;
@property (nonatomic, strong) EPSLoadingView *loadingView;
@property (nonatomic, assign) NSInteger initialSelectIndex;
@property (nonatomic, strong) UIImageView *featureImageView;
@end

@implementation EPSSubscriptionViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;

        _initialSelectIndex = 0;
        EPSSubscriptionPlanType promotePlan = [EPSUserSessionManager.shared getPromoteSubscriptionType];
        if (promotePlan == EPSSubscriptionPlanTypeProPlus) {
            _initialSelectIndex = 1;
        }

        _segmentControl = [[EPSSegmentedControl alloc] init];
        _segmentControl.backgroundColor = UIColor.lightGrayColor;
        _segmentControl.dataSource = self;
        _segmentControl.delegate = self;
        _segmentControl.selectorViewColor = UIColor.clearColor;
        _segmentControl.shadowsEnabled = NO;
        _segmentControl.shapeStyle = EPSSegmentedControlShapeStyleRoundedRect;
        _segmentControl.cornerRadius = 8.0f;
        _segmentControl.applyCornerRadiusToSelectorView = YES;
        _segmentControl.currentState = _initialSelectIndex;
        [self.view addSubview:_segmentControl];

        _label1 = [[EPSGradientLabel alloc] init];
        _label1.text = @"Welcome to AniPhoto";
        _label1.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        [_label1
         setAxialGradientParametersWithStartPoint:CGPointMake(0, 0.5)
         endPoint:CGPointMake(1, 0.5)
         colors:@[UIColor.yellowColor, UIColor.systemBlueColor]
         locations:nil
         options:nil];
        [self.view addSubview:_label1];

        _label2 = [[UILabel alloc] init];
        _label2.text = @"Unleash Your Creativity!";
        _label2.font = [UIFont systemFontOfSize:16 weight:UIFontWeightThin];
        _label2.textColor = UIColor.labelColor;
        [self.view addSubview:_label2];

        _featureImageView = [[UIImageView alloc] init];
        _featureImageView.backgroundColor = UIColor.lightGrayColor;
        _featureImageView.layer.cornerRadius = 8.0f;
        _featureImageView.clipsToBounds = YES;
        _featureImageView.image = [UIImage imageNamed:@"pro_features"];
        [self.view addSubview:_featureImageView];

        _productName = [[UILabel alloc] init];
        _productName.textColor = UIColor.labelColor;
        [self.view addSubview:_productName];

        _productDesc = [[UILabel alloc] init];
        _productDesc.textColor = UIColor.labelColor;
        [self.view addSubview:_productDesc];

        _productPrice = [[UILabel alloc] init];
        _productPrice.textColor = UIColor.labelColor;
        [self.view addSubview:_productPrice];

        _yearButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _yearButton.layer.cornerRadius = 20.0f;
        _yearButton.layer.masksToBounds = YES;
        [_yearButton setTitle:@"Subscribe 1" forState:UIControlStateNormal];
        [_yearButton setFont:[UIFont systemFontOfSize:18]];
        [_yearButton setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
        [_yearButton addTarget:self action:@selector(_yearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _yearButton.hidden = YES;
        [_yearButton setGradientBackgroundColors:@[UIColor.customYellow, UIColor.customOrange]
                                       direction:DTImageGradientDirectionToRight
                                           state:UIControlStateNormal];
        [self.view addSubview:_yearButton];

        _monthButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _monthButton.layer.cornerRadius = 20.0f;
        _monthButton.layer.masksToBounds = YES;
        //        _monthButton.layer.borderWidth = 2.0f;
        //        _monthButton.layer.borderColor = UIColor.orangeColor.CGColor;
        [_monthButton setTitle:@"Subscribe 2" forState:UIControlStateNormal];
        [_monthButton setFont:[UIFont systemFontOfSize:18]];
        [_monthButton setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
        [_monthButton setBackgroundColor:UIColor.clearColor];
        [_monthButton addTarget:self action:@selector(_monthButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_monthButton setGradientBackgroundColors:@[UIColor.customYellow, UIColor.customOrange]
                                        direction:DTImageGradientDirectionToRight
                                            state:UIControlStateNormal];
        [self.view addSubview:_monthButton];

        _loadingView = [[EPSLoadingView alloc] initWithShouldShowLabel:NO shouldDim:YES];
        _loadingView.hidden = YES;
        [self.view insertSubview:_loadingView aboveSubview:_featureImageView];

        [self _updateProducts];

        [self _updateButtonLabel];

        [NSNotificationCenter.defaultCenter
         addObserver:self
         selector:@selector(_storeKitUpdatedProducts)
         name:kEPSStoreKitManagerDidUpdateProducts
         object:nil];
        [NSNotificationCenter.defaultCenter
         addObserver:self
         selector:@selector(_storeKitIsPurchasingSubscription)
         name:kEPSStoreKitManagerIsPurchasingSubscription
         object:nil];
        [NSNotificationCenter.defaultCenter
         addObserver:self
         selector:@selector(_storeKitDidFinishPurchaseSubscription)
         name:kEPSStoreKitManagerDidFinishPurchaseSubscription
         object:nil];
        [NSNotificationCenter.defaultCenter
         addObserver:self
         selector:@selector(_storeKitDidFailPurchaseSubscription)
         name:kEPSStoreKitManagerDidFailPurchaseSubscription
         object:nil];
    }
    return self;
}

- (void)updateViewConstraints {
    CGSize label1Size = [self.label1.text sizeOfStringWithStyledFont:self.label1.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGSize label2Size = [self.label2.text sizeOfStringWithStyledFont:self.label2.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self.view.mas_safeAreaLayoutGuide);
        make.width.equalTo(@230);
        make.height.equalTo(@30);
    }];
    [self.label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentControl.mas_bottom).inset(20);
        make.leading.equalTo(self.view).insets(UIEdgeInsetsMake(0, 12, 0, 0));
        make.width.equalTo(@(label1Size.width));
        make.height.equalTo(@(label1Size.height));
    }];
    [self.label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.label1.mas_bottom).inset(10);
        make.leading.equalTo(self.view).insets(UIEdgeInsetsMake(0, 12, 0, 0));
        make.width.equalTo(@(label2Size.width));
        make.height.equalTo(@(label2Size.height));
    }];
    [self.featureImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.label2.mas_bottom).inset(100);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.9);
        make.height.equalTo(self.view.mas_width).multipliedBy(0.7875);
    }];
    [self.productName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).inset(100);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    [self.productDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.productName.mas_bottom).inset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    [self.productPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.productDesc.mas_bottom).inset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    [self.yearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.monthButton.mas_top).inset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(@55);
    }];
    [self.monthButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuide).inset(50);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(@55);
    }];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                             target:self
                                             action:@selector(_closeButtonPressed)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.segmentControl.currentState = self.initialSelectIndex;
    [self.segmentControl selectStateViewAtIndex:self.initialSelectIndex];
    [self.segmentControl changeStateToState:self.initialSelectIndex];
    [self _updateButtonLabel];
}

- (NSInteger)numberOfStatesInSegmentedControl:(EPSSegmentedControl *)segmentedControl {
    return 2;
}

- (NSString *)segmentedControl:(EPSSegmentedControl *)segmentedControl titleForStateAtIndex:(NSInteger)index {
    if (index == 0) {
        return @"AniPhoto Pro";
    } else if (index == 1) {
        return @"AniPhoto Pro+";
    }
    return nil;
}

- (NSArray<UIColor *> *)segmentedControl:(EPSSegmentedControl *)segmentedControl gradientColorsForStateAtIndex:(NSInteger)index {
    if (index == 0) {
        return @[UIColor.customYellow, UIColor.customOrange];
    } else if (index == 1) {
        return @[UIColor.customPink, UIColor.customPurple];
    }
    return @[];
}

- (void)segmentedControl:(EPSSegmentedControl *)segmentedControl didChangeStateFromStateAtIndex:(NSInteger)fromIndex toStateAtIndex:(NSInteger)toIndex {
    if (toIndex == 0) {
        [self.yearButton setGradientBackgroundColors:@[UIColor.customYellow, UIColor.customOrange]
                                           direction:DTImageGradientDirectionToRight
                                               state:UIControlStateNormal];
        [self.monthButton setGradientBackgroundColors:@[UIColor.customYellow, UIColor.customOrange]
                                            direction:DTImageGradientDirectionToRight
                                                state:UIControlStateNormal];
        self.monthButton.layer.borderColor = UIColor.orangeColor.CGColor;
        self.featureImageView.image = [UIImage imageNamed:@"pro_features"];
    } else {
        [self.yearButton setGradientBackgroundColors:@[UIColor.systemPinkColor, UIColor.purpleColor]
                                           direction:DTImageGradientDirectionToRight
                                               state:UIControlStateNormal];
        [self.monthButton setGradientBackgroundColors:@[UIColor.systemPinkColor, UIColor.purpleColor]
                                            direction:DTImageGradientDirectionToRight
                                                state:UIControlStateNormal];
        self.featureImageView.image = [UIImage imageNamed:@"proplus_features"];
    }
    [self _updateProducts];
    [self _updateButtonLabel];
}

- (void)_closeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_updateProducts {
    if (self.segmentControl.currentState == 0) {
        for (SKProduct *product in EPSStoreKitManager.shared.products.renewableSubscriptions) {
            if ([product.productIdentifier isEqualToString:kProMonthIdentifier]) {
                self.monthProduct = product;
            } else if ([product.productIdentifier isEqualToString:kProYearIdentifier]) {
                self.yearProduct = product;
            }
        }
    } else {
        for (SKProduct *product in EPSStoreKitManager.shared.products.renewableSubscriptions) {
            if ([product.productIdentifier isEqualToString:kProPlusMonthIdentifier]) {
                self.monthProduct = product;
            } else if ([product.productIdentifier isEqualToString:kProPlusYearIdentifier]) {
                self.yearProduct = product;
            }
        }
    }
}

- (void)_updateButtonLabel {
    if (self.monthProduct) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:self.monthProduct.priceLocale];
        NSString *cost = [formatter stringFromNumber:self.monthProduct.price];
        [self.monthButton setTitle:[NSString stringWithFormat:@"%@/month", cost] forState:UIControlStateNormal];
    } else {
        self.monthButton.hidden = YES;
    }

    if (self.yearProduct) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setLocale:self.yearProduct.priceLocale];
        NSString *cost = [formatter stringFromNumber:self.yearProduct.price];
        [self.yearButton setTitle:[NSString stringWithFormat:@"%@/year", cost] forState:UIControlStateNormal];
    } else {
        self.yearButton.hidden = YES;
    }
}

- (void)_monthButtonPressed {
    if ([EPSUserSessionManager.shared.userSession isSignedIn]) {
        [EPSStoreKitManager.shared buyProduct:self.monthProduct];
    } else {
        EPSSignInViewController *vc = [[EPSSignInViewController alloc] init];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        navVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navVC animated:YES completion:nil];
    }
}

- (void)_yearButtonPressed {
    if ([EPSUserSessionManager.shared.userSession isSignedIn]) {
        [EPSStoreKitManager.shared buyProduct:self.yearProduct];
    } else {
        EPSSignInViewController *vc = [[EPSSignInViewController alloc] init];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        navVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navVC animated:YES completion:nil];
    }
}

- (void)_storeKitIsPurchasingSubscription {
    [TSHelper dispatchAsyncMainQueue:^{
        self.loadingView.hidden = NO;
    }];
}

- (void)_storeKitDidFinishPurchaseSubscription {
    [TSHelper dispatchAsyncMainQueue:^{
        self.loadingView.hidden = YES;
        UIAlertController *ac = [UIAlertController
                                 alertControllerWithTitle:@"Thank your for joining AniPhoto"
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    }];
}

- (void)_storeKitDidFailPurchaseSubscription {
    [TSHelper dispatchAsyncMainQueue:^{
        self.loadingView.hidden = YES;
        UIAlertController *ac = [UIAlertController
                                 alertControllerWithTitle:@"Fail to purchase subscription"
                                 message:@"There is an error during purchasing your subscription. Please try purchase again"
                                 preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    }];
}

- (void)_storeKitUpdatedProducts {
    [self _updateProducts];
    [self _updateButtonLabel];
}

@end
