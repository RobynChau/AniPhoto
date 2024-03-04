//
//  ResultViewController.m
//  AniPhoto
//
//  Created by PhatCH on 03/01/2024.
//

#import "ResultViewController.h"

@interface ResultViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *shareButton;
@end

@implementation ResultViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage systemImageNamed:@"photo"];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_imageView];
        
        _shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _shareButton.backgroundColor = UIColor.systemBlueColor;
        _shareButton.layer.cornerRadius = 20.0f;
        [_shareButton setTitle:@"Share" forState:UIControlStateNormal];
        [_shareButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchDown];
        _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_shareButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.processedImage) {
        self.imageView.image = self.processedImage;
    }
}

- (void)updateViewConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.imageView.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
        [self.imageView.widthAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.widthAnchor multiplier:0.92],
        [self.imageView.heightAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.widthAnchor multiplier:0.92],
        [self.imageView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:100],
        
        [self.shareButton.centerXAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.centerXAnchor],
        [self.shareButton.widthAnchor constraintEqualToConstant:100],
        [self.shareButton.heightAnchor constraintEqualToConstant:50],
        [self.shareButton.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor constant:-100],
    ]];
    [super updateViewConstraints];
}

- (void)shareButtonPressed {
    NSArray *activityItems = @[self.imageView.image];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                         applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)doneButtonPressed {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
