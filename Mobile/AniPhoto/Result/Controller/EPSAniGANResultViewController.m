//
//  EPSAniGANResultViewController.m
//  AniPhoto
//
//  Created by PhatCH on 20/5/24.
//

#import "EPSAniGANResultViewController.h"
#import "EPSAniGANResultSecondaryToolView.h"
#import "EPSAniGANResultToolCell.h"
#import "EPSSimplifiedToolModel.h"
#import "EPSShareableImage.h"
#import "EPSLoadingView.h"

#import "EPSDatabaseManager.h"
#import "EPSPhotoGenerator.h"
#import "EPSDefines.h"
#import "AniPhoto-Swift.h"

@interface EPSAniGANResultViewController () <
UICollectionViewDelegate,
UICollectionViewDataSource,
EPSAniGANResultSecondaryToolViewDelegate
>
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) EPSLoadingView *loadingView;
@property (nonatomic, strong) EPSAniGANResultSecondaryToolView *secondaryToolView;
@property (nonatomic, strong) UICollectionView *toolView;
@property (nonatomic, strong) NSArray<EPSSimplifiedToolModel *> *toolModels;
@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) BOOL shouldGenerate;
@property (nonatomic, assign) BOOL isStandAloneVC;
@end

@implementation EPSAniGANResultViewController

- (instancetype)initWithOriginImage:(UIImage *)image shouldGenerate:(BOOL)shouldGenerate isStandAloneVC:(BOOL)isStandAloneVC {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;

        _isFirstAppear = YES;
        _shouldGenerate = shouldGenerate;
        _isStandAloneVC = isStandAloneVC;
        _originImage = image;

        _toolModels = [[EPSSimplifiedToolModel allTools] copy];

        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        if (!_shouldGenerate) {
            _imageView.image = image;
        }
        [self.view addSubview:_imageView];

        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = UIColor.darkGrayColor;
        [self.view addSubview:_bottomView];

        _secondaryToolView = [[EPSAniGANResultSecondaryToolView alloc] init];
        _secondaryToolView.delegate = self;
        [self.view addSubview:_secondaryToolView];

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(50, 50);
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _toolView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _toolView.backgroundColor = UIColor.darkGrayColor;
        _toolView.delegate = self;
        _toolView.dataSource = self;
        _toolView.showsVerticalScrollIndicator = NO;
        _toolView.showsHorizontalScrollIndicator = NO;
        [_toolView registerClass:EPSAniGANResultToolCell.class forCellWithReuseIdentifier:EPSAniGANResultToolCell.cellIdentifier];
        [self.view addSubview:_toolView];

        _loadingView = [[EPSLoadingView alloc] initWithShouldShowLabel:NO shouldDim:NO];
        _loadingView.hidden = !shouldGenerate;
        [self.view addSubview:_loadingView];
    }
    return self;
}

- (void)updateViewConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(10, 0, 0, 0));
        make.bottom.equalTo(self.secondaryToolView.mas_top);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.equalTo(@120);
    }];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(0, 12, 0, 12));
        make.height.equalTo(@60);
    }];
    [self.secondaryToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.toolView.mas_top);
        make.leading.trailing.equalTo(self.view.mas_safeAreaLayoutGuide);
        make.height.equalTo(@60);
    }];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isFirstAppear) {
        if (self.isStandAloneVC) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                                     target:self
                                                     action:@selector(_homeButtonPressed)];
        } else {
            self.navigationItem.title = @"AI Cartoon";
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                      initWithImage:[UIImage systemImageNamed:@"house"]
                                                      style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(_homeButtonPressed)];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.isFirstAppear && self.shouldGenerate) {
        self.isFirstAppear = NO;
        [self _generateImage];
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EPSAniGANResultToolCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSAniGANResultToolCell.cellIdentifier forIndexPath:indexPath];
    [cell updateWithModel:self.toolModels[indexPath.item]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.toolModels.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.toolModels.count) {
        return;
    }

    EPSSimplifiedToolModel *toolModel = self.toolModels[indexPath.item];

    EPSImageEditorViewController *editor = [[EPSImageEditorViewController alloc]
                                            initWithImage:self.imageView.image
                                            editModel:nil];
    editor.editFinishBlock = ^(UIImage * _Nonnull image, EPSEditImageModel * _Nullable model) {
        self.imageView.image = image;
    };
    editor.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:editor animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [editor selectToolAtIndex:indexPath.item];
            switch (toolModel.toolType) {
                case EPSSimplifiedToolModelTypeDoodle:
                    [editor drawBtnClick];
                    break;
                case EPSSimplifiedToolModelTypeCrop:
                    [editor clipBtnClick];
                    break;
                case EPSSimplifiedToolModelTypeSticker:
                    [editor imageStickerBtnClick];
                    break;
                case EPSSimplifiedToolModelTypeText:
                    [editor textStickerBtnClick];
                    break;
                case EPSSimplifiedToolModelTypeMosaic:
                    [editor mosaicBtnClick];
                    break;
                case EPSSimplifiedToolModelTypeFilter:
                    [editor filterBtnClick];
                    break;
                case EPSSimplifiedToolModelTypeAdjust:
                    [editor adjustBtnClick];
                    break;
            }
        });
    }];
}

- (void)toolView:(nonnull EPSAniGANResultSecondaryToolView *)toolView didSelectToolType:(EPSAniGANResultSecondaryToolType)toolType {
    switch (toolType) {
        case EPSAniGANResultSecondaryToolTypeShare:
            [self _shareImage:self.imageView.image];
            break;
        case EPSAniGANResultSecondaryToolTypeDownload: {
            [self _saveImageToPhotoLibrary:self.imageView.image];
            break;
        }
    }
}

- (void)_shareImage:(UIImage *)image {
    EPSShareableImage *shareImage = [[EPSShareableImage alloc] initWithImage:image title:@"AniPhoto"];
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

- (void)_saveImageToPhotoLibrary:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    [EPSPhotoManager saveImageToAlbumWithImage:compressedImage completion:^(BOOL success, PHAsset * _Nullable asset) {
        [self _toastSaveImage:success];
    }];
}

- (void)_toastSaveImage:(BOOL)isSuccess {
    NSString *toastText = isSuccess ? @"Save Photo Done" : @"Cannot Save Photo";
    [CSToastManager setTapToDismissEnabled:YES];
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.backgroundColor = [UIColor.labelColor colorWithAlphaComponent:0.7];
    [self.view makeToast:toastText duration:2 position:CSToastPositionCenter style:style];
}

- (void)_homeButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_generateImage {
    [[EPSPhotoGenerator manager]
     generatePhotoWithUIImage:self.originImage
     completion:^(UIImage * _Nullable resultImage, NSError * _Nullable error) {
        if (resultImage) {
            [self _handleGenerateImageSuccess:resultImage];
        } else {
            [self _handleGenerateImageFail];
        }}];
}

- (void)_handleGenerateImageSuccess:(UIImage *)image {
    [[EPSDatabaseManager sharedInstance] saveImage:image withCreationTime:NSDate.now];
    [TSHelper dispatchAsyncMainQueue:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EPSDtaManagerDidUpdateDB" object:nil];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        self.loadingView.hidden = YES;
        self.imageView.image = image;
    }];
}

- (void)_handleGenerateImageFail {
    [TSHelper dispatchAsyncMainQueue:^{
        UIAlertController *ac = [UIAlertController
                                 alertControllerWithTitle:@"Fail to generate photo"
                                 message:@"There is an error while generating your photo. Please try again"
                                 preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"Try again"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * _Nonnull action) {
            [self _generateImage];
        }]];
        [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                               style:UIAlertActionStyleCancel
                                             handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [self presentViewController:ac animated:YES completion:nil];
    }];
}

@end
