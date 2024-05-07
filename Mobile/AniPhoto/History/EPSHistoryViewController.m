//
//  EPSHistoryViewController.m
//  AniPhoto
//
//  Created by PhatCH on 21/5/24.
//

#import "EPSHistoryViewController.h"
#import "EPSLastCreatedCell.h"
#import "EPSDatabaseManager.h"
#import "EPSAniGANResultViewController.h"

#import "Masonry.h"
#import "EPSDefines.h"

#define HORIZONTAL_PADDING 12
#define INTER_ITEM_PADDING 12

@interface EPSHistoryViewController () <
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<UIImage *> *lastCreatedImages;
@end

@implementation EPSHistoryViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;

        _lastCreatedImages = [[EPSDatabaseManager sharedInstance] loadImages];

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;

        [_collectionView registerClass:EPSLastCreatedCell.class
            forCellWithReuseIdentifier:EPSLastCreatedCell.cellIdentifier];
        [self.view addSubview:_collectionView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Recently Created";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                             target:self
                                             action:@selector(_closeButtonPressed)];
}

- (void)updateViewConstraints {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom
            .equalTo(self.view.mas_safeAreaLayoutGuide)
            .insets(UIEdgeInsetsMake(16, HORIZONTAL_PADDING, 0, HORIZONTAL_PADDING));
    }];
    [super updateViewConstraints];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    EPSLastCreatedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSLastCreatedCell.cellIdentifier forIndexPath:indexPath];
    UIImage *image = self.lastCreatedImages[indexPath.item];
    [cell setImage:image];
    [cell setShouldShowOverlay:NO];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    return self.lastCreatedImages.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    EPSLastCreatedCell *cell = EPSDynamicCast([collectionView cellForItemAtIndexPath:indexPath], EPSLastCreatedCell);
    if (cell) {
        UIImage *selectedImage = self.lastCreatedImages[indexPath.item];
        EPSAniGANResultViewController *vc = [[EPSAniGANResultViewController alloc] initWithOriginImage:selectedImage shouldGenerate:NO isStandAloneVC:YES];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        navVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navVC animated:YES completion:nil];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionViewSize = collectionView.frame.size.width - INTER_ITEM_PADDING;
    CGFloat itemWidth = collectionViewSize / 2;
    return CGSizeMake(itemWidth, itemWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return INTER_ITEM_PADDING;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return INTER_ITEM_PADDING;
}

- (void)_closeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
