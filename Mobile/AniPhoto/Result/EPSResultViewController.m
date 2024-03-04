//
//  EPSResultViewController.m
//  AniPhoto
//
//  Created by PhatCH on 24/4/24.
//

#import "EPSResultViewController.h"
#import "EPSShareableImage.h"
#import "Masonry.h"
#import "UIView+Toast.h"

@interface EPSResultViewController ()
@property (nonatomic, strong) UIImage *resultPhoto;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *finishButton;

@end

@implementation EPSResultViewController

- (BOOL)isModalInPresentation {
    return YES;
}

- (instancetype)initWithResultPhoto:(UIImage *)resultPhoto {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;
        
        _resultPhoto = resultPhoto;

        _imageView = [[UIImageView alloc] initWithImage:_resultPhoto];
        _imageView.layer.cornerRadius = 10.0f;
        _imageView.layer.masksToBounds = YES;
        _imageView.backgroundColor = UIColor.clearColor;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imageView];

        _shareButton = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"square.and.arrow.up"] target:self action:@selector(shareButtonPressed)];
        _shareButton.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        _shareButton.layer.cornerRadius = 25.0f;
        _shareButton.layer.borderWidth = 0.5f;
        _shareButton.layer.borderColor = UIColor.tertiaryLabelColor.CGColor;
        _shareButton.tintColor = UIColor.labelColor;
        _shareButton.contentEdgeInsets = UIEdgeInsetsMake(4, 4, 8, 4);
        [self.view addSubview:_shareButton];

        _backButton = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"chevron.backward"] target:self action:@selector(backButtonPressed)];
        _backButton.tintColor = UIColor.labelColor;
        [self.view addSubview:_backButton];

        _finishButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _finishButton.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        _finishButton.layer.cornerRadius = 16.0f;
        [_finishButton setTitle:@"Finish" forState:UIControlStateNormal];
        [_finishButton setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(finishButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_finishButton];
    }
    return self;
}

- (void)updateViewConstraints {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).inset(10);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).inset(15);
        make.size.equalTo(@20);
    }];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).inset(10);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).inset(15);
        make.height.equalTo(@35);
        make.width.equalTo(@80);
    }];
    CGSize photoSize = self.resultPhoto.size;
    CGFloat imageViewWidth = photoSize.width >= self.view.frame.size.width ? self.view.frame.size.width * 0.8 : photoSize.width;
    CGFloat imageViewHeight = photoSize.height * imageViewWidth / photoSize.width;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).inset(85);
        make.width.equalTo(@(imageViewWidth));
        make.height.equalTo(@(imageViewHeight));
    }];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.imageView.mas_bottom).inset(50);
        make.size.equalTo(@50);
    }];
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)shareButtonPressed {
    EPSShareableImage *shareImage = [[EPSShareableImage alloc] initWithImage:self.resultPhoto title:@"AniPhoto"];
    NSArray *items = @[shareImage];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [activityViewController
     setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType,
                                     BOOL completed,
                                     NSArray * _Nullable returnedItems,
                                     NSError * _Nullable activityError) {
        if (activityType == UIActivityTypeSaveToCameraRoll && !activityError) {
            [CSToastManager setTapToDismissEnabled:YES];
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.backgroundColor = [UIColor.labelColor colorWithAlphaComponent:0.7];
            [self.view makeToast:@"Save Done!" duration:2 position:CSToastPositionCenter style:style];
        }
    }];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishButtonPressed {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
