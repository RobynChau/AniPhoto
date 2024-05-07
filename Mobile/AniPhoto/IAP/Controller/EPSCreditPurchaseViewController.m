//
//  EPSCreditPurchaseViewController.m
//  AniPhoto
//
//  Created by PhatCH on 23/5/24.
//

#import "EPSCreditPurchaseViewController.h"
#import "EPSSubscriptionViewController.h"
#import "EPSCurrentCreditFullView.h"
#import "EPSCreditProductView.h"

#import "EPSDefines.h"
#import "EPSStoreKitManager.h"

@interface EPSCreditPurchaseViewController ()
@property (nonatomic, strong) EPSCurrentCreditFullView *creditView;
@property (nonatomic, strong) UIButton *purchaseButton;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UILabel *buyLabel;
@property (nonatomic, strong) EPSCreditProductView *productView;
@property (nonatomic, strong) SKProduct *product;
@property (nonatomic, strong) EPSLoadingView *loadingView;
@end

@implementation EPSCreditPurchaseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _findProduct];

        self.view.backgroundColor = UIColor.systemBackgroundColor;

        _creditView = [[EPSCurrentCreditFullView alloc] init];
        [self.view addSubview:_creditView];

        _purchaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _purchaseButton.layer.cornerRadius = 20.0f;
        _purchaseButton.layer.masksToBounds = YES;
        [_purchaseButton setTitle:@"Purchase now" forState:UIControlStateNormal];
        [_purchaseButton setFont:[UIFont systemFontOfSize:18]];
        [_purchaseButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_purchaseButton setGradientBackgroundColors:@[UIColor.customBlue,
                                                       UIColor.customGreen]
                                           direction:DTImageGradientDirectionToRight
                                               state:UIControlStateNormal];
        [_purchaseButton addTarget:self action:@selector(_purchaseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_purchaseButton];

        _subscribeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _subscribeButton.layer.cornerRadius = 20.0f;
        _subscribeButton.layer.masksToBounds = YES;
        [_subscribeButton setTitle:@"Join AniPhoto Pro" forState:UIControlStateNormal];
        [_subscribeButton setFont:[UIFont systemFontOfSize:18]];
        [_subscribeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_subscribeButton setGradientBackgroundColors:@[UIColor.customYellow,
                                                        UIColor.customOrange]
                                            direction:DTImageGradientDirectionToRight
                                                state:UIControlStateNormal];
        [_subscribeButton addTarget:self action:@selector(_subscribeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_subscribeButton];

        _buyLabel = [[UILabel alloc] init];
        _buyLabel.text = @"Buy credits";
        _buyLabel.textColor = UIColor.labelColor;
        _buyLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        [self.view addSubview:_buyLabel];

        _productView = [[EPSCreditProductView alloc] init];
        [_productView updateWithProduct:_product];
        [self.view addSubview:_productView];

        _loadingView = [[EPSLoadingView alloc] initWithShouldShowLabel:NO shouldDim:YES];
        _loadingView.hidden = YES;
        [self.view insertSubview:_loadingView atIndex:0];

        [NSNotificationCenter.defaultCenter
         addObserver:self
         selector:@selector(_storeKitUpdatedProducts)
         name:kEPSStoreKitManagerDidUpdateProducts
         object:nil];
        [NSNotificationCenter.defaultCenter
         addObserver:self
         selector:@selector(_storeKitIsPurchasingCredits)
         name:kEPSStoreKitManagerIsPurchasingCredits
         object:nil];
        [NSNotificationCenter.defaultCenter
         addObserver:self
         selector:@selector(_storeKitDidFinishPurchaseCredits)
         name:kEPSStoreKitManagerDidFinishPurchaseCredits
         object:nil];
        [NSNotificationCenter.defaultCenter
         addObserver:self
         selector:@selector(_storeKitDidFailPurchaseCredits)
         name:kEPSStoreKitManagerDidFailPurchaseCredits
         object:nil];
    }
    return self;
}

- (void)updateViewConstraints {
    CGSize buyLabelSize = [self.buyLabel.text sizeOfStringWithStyledFont:self.buyLabel.font withSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];

    [self.creditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(16, 12, 0, 12));
        make.height.equalTo(@120);
    }];
    [self.subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.purchaseButton.mas_top).inset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(@50);
    }];
    [self.purchaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuide).inset(50);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(@50);
    }];
    [self.buyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(0, 12, 0, 12));
        make.top.equalTo(self.creditView.mas_bottom).inset(35);
        make.height.equalTo(@(buyLabelSize.height));
        make.width.equalTo(@(buyLabelSize.width));
    }];
    [self.productView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_safeAreaLayoutGuide).inset(12);
        make.top.equalTo(self.buyLabel.mas_bottom).inset(18);
        make.height.equalTo(@180);
        make.width.equalTo(@150);
    }];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)_findProduct {
    for (SKProduct *product in EPSStoreKitManager.shared.products.consumable) {
        if ([product.productIdentifier isEqualToString:kCreditIdentifier]) {
            self.product = product;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Credit Shop";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                             target:self
                                             action:@selector(_closeButtonPressed)];
}

- (void)_purchaseButtonPressed {
    [EPSStoreKitManager.shared buyProduct:self.product];
}

- (void)_subscribeButtonPressed {
    EPSSubscriptionViewController *vc = [[EPSSubscriptionViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)_closeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_storeKitIsPurchasingCredits {
    [TSHelper dispatchAsyncMainQueue:^{
        self.loadingView.hidden = NO;
    }];
}

- (void)_storeKitDidFinishPurchaseCredits {
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

- (void)_storeKitDidFailPurchaseCredits {
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


@end
