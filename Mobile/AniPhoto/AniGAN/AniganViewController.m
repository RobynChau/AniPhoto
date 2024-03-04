//
//  AniganViewController.m
//  AniPhoto
//
//  Created by PhatCH on 01/01/2024.
//

#import "AniganViewController.h"
#import "EPSEditorViewController.h"
#import <CoreML/CoreML.h>
#import <SDWebImage/SDWebImage.h>

@interface AniganViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation AniganViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - self.view.frame.size.width * 0.92) / 2, 220, self.view.frame.size.width * 0.92, self.view.frame.size.width * 0.92)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _spinner.tintColor = UIColor.blackColor;
    _spinner.center = _imageView.center;
    [_spinner startAnimating];
    [self.view addSubview:_spinner];
    
    // Set up your navigation bar with a right button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(donePickingPhoto)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [self loadProcessedImage];
}

- (void)loadProcessedImage {
    if (self.processedImageURL) {
        NSURL *url = [NSURL URLWithString:self.processedImageURL];
        [self.imageView sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem.enabled = YES;
                self.imageView.image = image;
                [self.spinner stopAnimating];
            });
        }];
    }
}

- (void)donePickingPhoto {
    EPSEditorViewController *vc = [[EPSEditorViewController alloc] init];
    vc.processedImage = self.imageView.image;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
