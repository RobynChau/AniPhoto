//
//  EPSEditorViewController.m
//  AniPhoto
//
//  Created by PhatCH on 20/12/2023.
//

#import "EPSEditorViewController.h"
#import "ToolView.h"
#import "EPSHomeViewController.h"
#import "ResultViewController.h"

@interface EPSEditorViewController ()
@property (nonatomic, strong) ToolView *toolView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation EPSEditorViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_imageView];
        
        _toolView = [[ToolView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 150, self.view.frame.size.width - 10, 100)];
        _toolView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_toolView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
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
        
        [self.toolView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:10],
        [self.toolView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.toolView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.toolView.heightAnchor constraintEqualToConstant:100],
    ]];
    [super updateViewConstraints];
}

- (void)doneButtonPressed {
    ResultViewController *vc = [[ResultViewController alloc] init];
    vc.processedImage = self.imageView.image;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
