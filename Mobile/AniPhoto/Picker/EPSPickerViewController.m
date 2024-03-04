//
//  EPSEditorViewController.m
//  DemoProject
//
//  Created by PhatCH on 12/12/2023.
//

#import "EPSPickerViewController.h"
#import "EPSResultWaitingViewController.h"
#import <PhotosUI/PhotosUI.h>
#import "EPSUserEntity.h"
#import "AnimeGANv2_1024.h"
#import "EPSDefines.h"
#import "UIImage+EPS.h"
#import "EPSLoadingView.h"
#import "Masonry.h"

#define BUTTON_WIDTH 180

@interface EPSPickerViewController () <
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *modelNameLabel;
@property (nonatomic, strong) UILabel *modelDescriptionLabel;
@property (nonatomic, strong) UIButton *choosePhotoButton;
@property (nonatomic, strong) UIImageView *blurImageView;
@property (nonatomic, strong) EPSLoadingView *loadingView;
@end

@implementation EPSPickerViewController

- (instancetype)initWithImage:(UIImage *)image
                    modelName:(NSString *)modelName
                     modelDes:(NSString *)modelDes {
    self = [super init];
    if (self) {
        _blurImageView = [[UIImageView alloc] init];
        _blurImageView.alpha = 0.1;
        _blurImageView.image = [self _blurImageWithImage:image];
        [self.view addSubview:_blurImageView];

        _imageView = [[UIImageView alloc] init];
        _imageView.layer.cornerRadius = 20.0f;
        _imageView.layer.masksToBounds = YES;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = image;
        [self.view addSubview:_imageView];

        _modelNameLabel = [[UILabel alloc] init];
        _modelNameLabel.text = modelName;
        _modelNameLabel.font = [UIFont boldSystemFontOfSize:20];
        [_modelNameLabel sizeToFit];
        [self.view addSubview:_modelNameLabel];

        _modelDescriptionLabel = [[UILabel alloc] init];
        _modelDescriptionLabel.numberOfLines = 2;
        _modelDescriptionLabel.font = [UIFont systemFontOfSize:16];
        _modelDescriptionLabel.text = modelDes;
        [_modelDescriptionLabel sizeToFit];
        [self.view addSubview:_modelDescriptionLabel];

        _choosePhotoButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _choosePhotoButton.backgroundColor = UIColor.whiteColor;
        _choosePhotoButton.layer.cornerRadius = 20.0f;
        [_choosePhotoButton setTitle:@"Import" forState:UIControlStateNormal];
        [_choosePhotoButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_choosePhotoButton addTarget:self action:@selector(presentPhotoPicker) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_choosePhotoButton];

        _loadingView = [[EPSLoadingView alloc] initWithShouldShowLabel:NO shouldDim:YES];
        _loadingView.hidden = YES;
        [self.view addSubview:_loadingView];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                   target:self
                                   action:@selector(closeButtonPressed)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)updateViewConstraints {
    [self.blurImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(1);
    }];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).multipliedBy(0.8);
        make.height.equalTo(self.view.mas_width).multipliedBy(1.2);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).inset(20);
        make.centerX.equalTo(self.view);
    }];
    [self.choosePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.8);
        make.height.equalTo(@50);
        make.bottom.equalTo(self.view).inset(50);
    }];
    [self.modelNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.modelDescriptionLabel.mas_top).inset(20);
        make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 20, 0, 20));
    }];
    [self.modelDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.choosePhotoButton.mas_top).inset(20);
        make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 20, 0, 20));
    }];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)presentPhotoPicker {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:^{
        self.loadingView.hidden = YES;
    }];
    self.loadingView.hidden = NO;
}

- (nullable UIImage *)_blurImageWithImage:(UIImage *)sourceImage {
    const CGFloat SMALL_THUMB_SIZE = 160;
    CGFloat originW = sourceImage.size.width;
    CGFloat originH = sourceImage.size.height;
    CGFloat scaleW = SMALL_THUMB_SIZE;
    CGFloat scaleH = ceilf(originH / originW * scaleW);
    CGFloat radius = ceilf((8 * scaleH * sourceImage.scale) / 100);
    UIImage *smallThumb = [sourceImage scaleToSize:CGSizeMake(scaleW, scaleH)];

    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:smallThumb.CGImage];

    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:[inputImage imageByClampingToExtent] forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];

    // CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
    // up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];

    UIImage *blurThumb = [UIImage imageWithCGImage:cgImage];

    if (cgImage) {
        CGImageRelease(cgImage);
    }

    if (blurThumb && blurThumb.size.width != scaleW) {
        blurThumb = [blurThumb scaleToSize:CGSizeMake(scaleW, scaleH)];
    }

    return blurThumb;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *pickedImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    EPSResultWaitingViewController *waitingResultVC = [[EPSResultWaitingViewController alloc] initWithSourceImage:pickedImage];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:waitingResultVC];
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
