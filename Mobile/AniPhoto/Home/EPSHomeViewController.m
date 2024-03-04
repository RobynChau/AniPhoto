//
//  EPSHomeViewController.m
//  AniPhoto
//
//  Created by PhatCH on 02/01/2024.
//

#import "EPSHomeViewController.h"
#import "EPSHomePhotoCell.h"
#import "EPSPickerViewController.h"
#import "EPSSettingsViewController.h"

#define BUTTON_WIDTH 180

@interface EPSHomeViewController () <
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UICollectionView *collectionView1;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UILabel *label2a;
@property (nonatomic, strong) UILabel *label2b;
@property (nonatomic, strong) UICollectionView *collectionView2;
@property (nonatomic, strong) NSArray *homeImageArray;
@end

@implementation EPSHomeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;
        
        _homeImageArray = @[@"output", @"output2", @"output3", @"output4", @"output5", @"output6", @"output7"];
        
        _label1 = [[UILabel alloc] init];
        _label1.text = @"Edit Tools";
        _label1.textColor = UIColor.labelColor;
        _label1.font = [UIFont boldSystemFontOfSize:18];
        _label1.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_label1];
        
        UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc] init];
        layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView1 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout1];
        _collectionView1.tag = 1;
        [_collectionView1 registerClass:EPSHomePhotoCell.class forCellWithReuseIdentifier:@"Cell"];
        _collectionView1.showsHorizontalScrollIndicator = NO;
        _collectionView1.delegate = self;
        _collectionView1.dataSource = self;
        _collectionView1.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_collectionView1];
        
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = UIColor.secondaryLabelColor;
        _separator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_separator];
        
        _label2a = [[UILabel alloc] init];
        _label2a.text = @"Photos";
        _label2a.textColor = UIColor.labelColor;
        _label2a.font = [UIFont boldSystemFontOfSize:18];
        _label2a.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_label2a];
        
        _label2b = [[UILabel alloc] init];
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage systemImageNamed:@"chevron.right"];
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:@"All "];
        [myString appendAttributedString:attachmentString];
        _label2b.attributedText = myString;
        _label2b.textColor = UIColor.labelColor;
        _label2b.font = [UIFont boldSystemFontOfSize:18];
        _label2b.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_label2b];
        
        UICollectionViewFlowLayout *layout2 = [[UICollectionViewFlowLayout alloc] init];
        layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView2 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout2];
        _collectionView2.tag = 2;
        [_collectionView2 registerClass:EPSHomePhotoCell.class forCellWithReuseIdentifier:@"Cell"];
        _collectionView2.showsHorizontalScrollIndicator = NO;
        _collectionView2.delegate = self;
        _collectionView2.dataSource = self;
        _collectionView2.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_collectionView2];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithImage:[UIImage systemImageNamed:@"wand.and.stars"]
                                                  style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(createButtonPressed)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithImage:[UIImage systemImageNamed:@"info.circle"]
                                                 style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(settingButtonPressed)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)updateViewConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.label1.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.label1.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:15],
        [self.label1.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.label1.heightAnchor constraintEqualToConstant:40],
        
        [self.collectionView1.topAnchor constraintEqualToAnchor:self.label1.bottomAnchor],
        [self.collectionView1.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:10],
        [self.collectionView1.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.collectionView1.heightAnchor constraintEqualToConstant:160],
        
        [self.separator.topAnchor constraintEqualToAnchor:self.collectionView1.bottomAnchor constant:10],
        [self.separator.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:15],
        [self.separator.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.separator.heightAnchor constraintEqualToConstant:1],
        
        [self.label2a.topAnchor constraintEqualToAnchor:self.separator.bottomAnchor constant:10],
        [self.label2a.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:15],
        [self.label2a.widthAnchor constraintEqualToConstant:100],
        [self.label2a.heightAnchor constraintEqualToConstant:40],
        
        [self.label2b.topAnchor constraintEqualToAnchor:self.separator.bottomAnchor constant:10],
        [self.label2b.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-10],
        [self.label2a.widthAnchor constraintEqualToConstant:100],
        [self.label2b.heightAnchor constraintEqualToConstant:40],
        
        [self.collectionView2.topAnchor constraintEqualToAnchor:self.label2a.bottomAnchor],
        [self.collectionView2.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:10],
        [self.collectionView2.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.collectionView2.heightAnchor constraintEqualToConstant:250],
    ]];
    [super updateViewConstraints];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (collectionView.tag == 1) {
        EPSHomePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        cell.backgroundColor = UIColor.tertiarySystemBackgroundColor;
        [cell setCellImage:[UIImage imageNamed:@"tool"]];
        return cell;
    } else {
        EPSHomePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        NSString *imageName = self.homeImageArray[indexPath.item];
        [cell setCellImage:[UIImage imageNamed:imageName]];
        return cell;
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.homeImageArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 1) {
        return CGSizeMake(150, 120);
    } else {
        return CGSizeMake(150, 220);
    }
}

- (void)createButtonPressed {
    EPSPickerViewController *picker = [[EPSPickerViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:picker];
    navVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)settingButtonPressed {
    EPSSettingsViewController *vc = [[EPSSettingsViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

@end
