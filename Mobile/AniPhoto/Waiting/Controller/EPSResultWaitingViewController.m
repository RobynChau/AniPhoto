//
//  EPSResultWaitingViewController.m
//  AniPhoto
//
//  Created by PhatCH on 17/4/24.
//

#import "EPSResultWaitingViewController.h"
#import "EPSResultViewController.h"
#import "EPSLoadingView.h"
#import "EPSPhotoGenerator.h"
#import "Masonry.h"
#import "UIImage+EPS.h"
#import "EPSBlurImageView.h"

@interface EPSResultWaitingViewController ()
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) EPSBlurImageView *imageView;
@property (nonatomic, strong) UILabel *waitLabel;
@property (nonatomic, strong) UIButton *enableNotificationButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) EPSLoadingView *loadingView;
@end

@implementation EPSResultWaitingViewController

- (BOOL)isModalInPresentation {
    return YES;
}

- (instancetype)initWithSourceImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _sourceImage = image;

        _imageView = [[EPSBlurImageView alloc] init];
//        _imageView.contentMode = UIViewContentModeTop;
        _imageView.image = [self combineImage];
        [self.view addSubview:_imageView];

        _loadingView = [[EPSLoadingView alloc] initWithShouldShowLabel:YES shouldDim:NO];
        _loadingView.hidden = NO;
        [self.view addSubview:_loadingView];

        _waitLabel = [[UILabel alloc] init];
        _waitLabel.textAlignment = NSTextAlignmentCenter;
        _waitLabel.font = [UIFont systemFontOfSize:14];
        _waitLabel.text = @"The generation process can take some time to complete, activate notifications to know when your creation is ready";
        _waitLabel.numberOfLines = 4;
        [self.view addSubview:_waitLabel];

        _enableNotificationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _enableNotificationButton.backgroundColor = UIColor.whiteColor;
        _enableNotificationButton.layer.cornerRadius = 20.0f;
        [_enableNotificationButton setTitle:@"Enable notification 🔔" forState:UIControlStateNormal];
        [_enableNotificationButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_enableNotificationButton setFont:[UIFont boldSystemFontOfSize:17]];
        [_enableNotificationButton addTarget:self action:@selector(enableNotificationButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_enableNotificationButton];

        _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _closeButton.backgroundColor = UIColor.clearColor;
        [_closeButton setTitle:@"Hide" forState:UIControlStateNormal];
        [_closeButton setFont:[UIFont boldSystemFontOfSize:17]];
        [_closeButton setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_closeButton];
    }
    return self;
}

- (void)updateViewConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self.view);
    }];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self.view);
    }];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).inset(40);
        make.width.equalTo(@40);
    }];
    [self.enableNotificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.closeButton.mas_top).inset(20);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.6);
        make.height.equalTo(@45);
    }];
    [self.waitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.enableNotificationButton.mas_top).inset(20);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.6);
    }];
    [super updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[EPSPhotoGenerator manager] 
     generatePhotoWithUIImage:self.sourceImage
     completion:^(UIImage * _Nullable resultImage, NSError * _Nullable error) {
        if (resultImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                EPSResultViewController *resultVC = [[EPSResultViewController alloc] initWithResultPhoto:resultImage];
                [self.navigationController pushViewController:resultVC animated:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self closeButtonPressed];
                }];
                UIAlertAction *retry = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self closeButtonPressed];
                }];
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error Generating Photo" message:@"There is a problem generating photo. Please try again" preferredStyle:UIAlertControllerStyleAlert];
                [ac addAction:cancel];
                [ac addAction:retry];
                [self presentViewController:ac animated:YES completion:nil];
            });
        }
    }];
}

- (UIImage *)combineImage {
    UIImage *bottomImage = [self.sourceImage reflectedImageWithHeight:self.sourceImage.size.height * 0.35 fromAlpha:1 toAlpha:1];
    UIImage *topImage = self.sourceImage;

    CGSize size = CGSizeMake(topImage.size.width, topImage.size.height + bottomImage.size.height);
    UIGraphicsBeginImageContext(size);

    [topImage drawInRect:CGRectMake(0, 0, size.width, topImage.size.height)];
    [bottomImage drawInRect:CGRectMake(0, topImage.size.height,size.width, bottomImage.size.height)];

    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return [self blurredImageWithImage:finalImage];
}

- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage{
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];

    CIFilter *filter = [CIFilter filterWithName:@"CIMaskedVariableBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];

    // Create a mask that goes from white to black vertically.
    CIFilter *maskFilter = [CIFilter filterWithName:@"CISmoothLinearGradient"];
    [maskFilter setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forKey:@"inputColor0"];
    [maskFilter setValue:[CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] forKey:@"inputColor1"];
    [maskFilter setValue:[CIVector vectorWithCGPoint:CGPointMake(0, 0)] forKey:@"inputPoint0"];
    [maskFilter setValue:[CIVector vectorWithCGPoint:CGPointMake(0, inputImage.extent.size.height * 0.5)] forKey:@"inputPoint1"];
    CIImage *maskImage = [maskFilter outputImage];

    [filter setValue:maskImage forKey:@"inputMask"];
    [filter setValue:@(30) forKey:@"inputRadius"];

    CIImage *result = [filter valueForKey:kCIOutputImageKey];

    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];

    UIImage *blurThumb = [UIImage imageWithCGImage:cgImage];

    if (cgImage) {
        CGImageRelease(cgImage);
    }
    return blurThumb;
}


- (void)enableNotificationButtonPressed {

}

- (void)closeButtonPressed {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}

@end
