//
//  EPSHomeViewController.m
//  AniPhoto
//
//  Created by PhatCH on 14/5/24.
//

#import "EPSHomeViewController.h"
#import "EPSHomeToolCollectionView.h"
#import "EPSOverlayHeaderView.h"
#import "EPSLastCreatedCell.h"
#import "EPSHomeLabelSectionHeaderView.h"
#import "EPSHomeToolCell.h"
#import "EPSHomeEditCell.h"
#import "EPSHomeBannerCell.h"
#import "EPSUserSessionManager.h"
#import "EPSAniGANViewController.h"
#import "EPSAniGANResultViewController.h"
#import "EPSHistoryViewController.h"

// Utilities
#import "EPSDatabaseManager.h"
#import "EPSDefines.h"
#import "AniPhoto-Swift.h"

#define BUTTON_WIDTH 180
#define INTER_SECTION_PADDING 15.0f
#define BANNER_SECTION_HEIGHT 160
#define MODEL_SECTION_HEADER_HEIGHT 50
#define MODEL_SECTION_HEADER_BOTTOM_PADDING 10
#define MODEL_SECTION_CONTENT_HEIGHT 280
#define MODEL_SECTION_INTER_ITEM_SPACING 16
#define MODEL_SECTION_CONTENT_LEADING_PADDING 10
#define CREATED_SECTION_CONTENT_HEIGHT 180

#define TOOL_SECTION_INDEX 0
#define BANNER_SECTION_INDEX 1
#define LAST_CREATED_SECTION_INDEX 2
#define EDIT_SECTION_INDEX 3

@interface EPSHomeViewController () <
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
PHPhotoLibraryChangeObserver,
EPSHomeToolViewDelegate,
EPSHomeLabelSectionHeaderDelegate
> {
    dispatch_queue_t        _actionQueue;
    const char*             _actionQueueName;
    NSString*               _actionQueueNameStr;
}
@property (nonatomic, strong) NSArray<UIImage *> *lastCreatedImages;
@property (nonatomic, strong) NSMutableArray<UIImage *> *latestPhotoPreviews;
@property (nonatomic, strong) NSArray<NSNumber *> *tools;

@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) EPSOverlayHeaderView *overlayHeaderView;

@end

@implementation EPSHomeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;

        [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];

        _actionQueueNameStr = @"com.PhatCH.EPSHomeViewController";
        _actionQueueName = [_actionQueueNameStr UTF8String];
        _actionQueue = createDispatchQueueWithObject(self, _actionQueueName, YES);

        _lastCreatedImages = [[EPSDatabaseManager sharedInstance] loadImages];
        _latestPhotoPreviews = [NSMutableArray array];
        _tools = @[@(EPSHomeToolTypeEdit), @(EPSHomeToolTypeAniGAN), @(EPSHomeToolTypeSticker), @(EPSHomeToolTypeText), @(EPSHomeToolTypeFilter)];

        [self _fetchLatestPhoto];
        [self _setupView];

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(dbDidUpdate)
         name:@"EPSDtaManagerDidUpdateDB"
         object:nil];
    }
    return self;
}

- (void)dealloc {
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)_setupView {
    [self _setupMainCollectionView];

    _overlayHeaderView = [[EPSOverlayHeaderView alloc] initWithTitle:@"AniPhoto"];
    [self.view addSubview:_overlayHeaderView];
}

- (void)_setupMainCollectionView {
    UICollectionViewCompositionalLayout *layout = [self createCollectionViewLayout];
    _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _mainCollectionView.showsVerticalScrollIndicator = NO;
    _mainCollectionView.showsHorizontalScrollIndicator = NO;

    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;

    [_mainCollectionView registerClass:EPSLastCreatedCell.class
            forCellWithReuseIdentifier:EPSLastCreatedCell.cellIdentifier];
    [_mainCollectionView registerClass:EPSHomeToolCell.class
            forCellWithReuseIdentifier:EPSHomeToolCell.cellIdentifier];
    [_mainCollectionView registerClass:EPSHomeEditCell.class
            forCellWithReuseIdentifier:EPSHomeEditCell.cellIdentifier];
    [_mainCollectionView registerClass:EPSHomeBannerCell.class
            forCellWithReuseIdentifier:EPSHomeBannerCell.cellIdentifier];
    [_mainCollectionView registerClass:EPSHomeLabelSectionHeaderView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:EPSHomeLabelSectionHeaderView.reusableViewIdentifier];
    [self.view addSubview:_mainCollectionView];
}

- (UICollectionViewCompositionalLayout *)createCollectionViewLayout {
    UICollectionViewCompositionalLayout *layout =
    [[UICollectionViewCompositionalLayout alloc]
     initWithSectionProvider: ^NSCollectionLayoutSection * _Nullable(NSInteger section,
                                                                     id<NSCollectionLayoutEnvironment> _Nonnull layoutEnvironment) {
        if (section == TOOL_SECTION_INDEX) {
            return [self _toolSectionLayout];
        } else if (section == BANNER_SECTION_INDEX) {
            return [self _bannerSectionLayout];
        } else if (section == LAST_CREATED_SECTION_INDEX) {
            return [self _createdSectionLayout];
        } else if (section == EDIT_SECTION_INDEX) {
            return [self _editSectionLayout];
        }
        return nil;
    }];
    return layout;
}

- (NSCollectionLayoutSection *)_toolSectionLayout {
    // Item
    NSCollectionLayoutItem *itemLayout =
    [NSCollectionLayoutItem
     itemWithLayoutSize:[NSCollectionLayoutSize
                         sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.2]
                         heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];
    itemLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, 0);

    // Group
    NSCollectionLayoutGroup *groupLayout =
    [NSCollectionLayoutGroup
     horizontalGroupWithLayoutSize:[NSCollectionLayoutSize
                                    sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:100]]
     subitem:itemLayout
     count:5];
    groupLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, 0);

    // Section
    NSCollectionLayoutSection *sectionLayout = [NSCollectionLayoutSection sectionWithGroup:groupLayout];
    sectionLayout.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPagingCentered;
    sectionLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, 0);

    return sectionLayout;
}

- (NSCollectionLayoutSection *)_createdSectionLayout {
    // Item
    NSCollectionLayoutItem *itemLayout =
    [NSCollectionLayoutItem
     itemWithLayoutSize:[NSCollectionLayoutSize
                         sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                         heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];
    itemLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, MODEL_SECTION_INTER_ITEM_SPACING);

    NSCollectionLayoutBoundarySupplementaryItem *supplementaryLayout =
    [NSCollectionLayoutBoundarySupplementaryItem
     supplementaryItemWithLayoutSize:[NSCollectionLayoutSize
                                      sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                                      heightDimension:[NSCollectionLayoutDimension absoluteDimension:MODEL_SECTION_HEADER_HEIGHT]]
     elementKind:UICollectionElementKindSectionHeader
     containerAnchor:[NSCollectionLayoutAnchor layoutAnchorWithEdges:NSDirectionalRectEdgeTop | NSDirectionalRectEdgeLeading]];
    // Group
    NSCollectionLayoutGroup *groupLayout =
    [NSCollectionLayoutGroup
     horizontalGroupWithLayoutSize:[NSCollectionLayoutSize
                                    sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.3]
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:CREATED_SECTION_CONTENT_HEIGHT + MODEL_SECTION_HEADER_HEIGHT]]
     subitem:itemLayout
     count:3];
    groupLayout.contentInsets = NSDirectionalEdgeInsetsMake(MODEL_SECTION_HEADER_HEIGHT + MODEL_SECTION_HEADER_BOTTOM_PADDING, 0, 0, 0);

    // Section
    NSCollectionLayoutSection *sectionLayout = [NSCollectionLayoutSection sectionWithGroup:groupLayout];
    sectionLayout.boundarySupplementaryItems = @[supplementaryLayout];
    sectionLayout.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuous;
    sectionLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, INTER_SECTION_PADDING, 0);

    return sectionLayout;
}

- (NSCollectionLayoutSection *)_editSectionLayout {
    // Item
    NSCollectionLayoutItem *itemLayout =
    [NSCollectionLayoutItem
     itemWithLayoutSize:[NSCollectionLayoutSize
                         sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                         heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];
    itemLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, MODEL_SECTION_INTER_ITEM_SPACING);

    NSCollectionLayoutBoundarySupplementaryItem *supplementaryLayout =
    [NSCollectionLayoutBoundarySupplementaryItem
     supplementaryItemWithLayoutSize:[NSCollectionLayoutSize
                                      sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                                      heightDimension:[NSCollectionLayoutDimension absoluteDimension:MODEL_SECTION_HEADER_HEIGHT]]
     elementKind:UICollectionElementKindSectionHeader
     containerAnchor:[NSCollectionLayoutAnchor layoutAnchorWithEdges:NSDirectionalRectEdgeTop | NSDirectionalRectEdgeLeading]];
    // Group
    NSCollectionLayoutGroup *groupLayout =
    [NSCollectionLayoutGroup
     horizontalGroupWithLayoutSize:[NSCollectionLayoutSize
                                    sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.3]
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:120 + MODEL_SECTION_HEADER_HEIGHT]]
     subitem:itemLayout
     count:4];
    groupLayout.contentInsets = NSDirectionalEdgeInsetsMake(MODEL_SECTION_HEADER_HEIGHT + MODEL_SECTION_HEADER_BOTTOM_PADDING, 0, 0, 0);

    // Section
    NSCollectionLayoutSection *sectionLayout = [NSCollectionLayoutSection sectionWithGroup:groupLayout];
    sectionLayout.boundarySupplementaryItems = @[supplementaryLayout];
    sectionLayout.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuous;
    sectionLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, INTER_SECTION_PADDING, 0);

    return sectionLayout;
}

- (NSCollectionLayoutSection *)_bannerSectionLayout {
    NSCollectionLayoutItem *itemLayout =
    [NSCollectionLayoutItem
     itemWithLayoutSize:[NSCollectionLayoutSize
                         sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                         heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];

    NSCollectionLayoutGroup *groupLayout =
    [NSCollectionLayoutGroup
     horizontalGroupWithLayoutSize:[NSCollectionLayoutSize
                                    sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:BANNER_SECTION_HEIGHT]]
     subitem:itemLayout
     count:1];

    NSCollectionLayoutSection *sectionLayout = [NSCollectionLayoutSection sectionWithGroup:groupLayout];
    sectionLayout.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPagingCentered;
    sectionLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, INTER_SECTION_PADDING, 0);

    return sectionLayout;
}

- (void)updateViewConstraints {
    [self.overlayHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(-30, 10, 0, 10));
        make.height.equalTo(@32);
    }];

    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view).insets(UIEdgeInsetsMake(0, 10, 0, 10));
        make.top.equalTo(self.view.mas_safeAreaLayoutGuide).inset(20);
    }];
    [super updateViewConstraints];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                                   cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == TOOL_SECTION_INDEX) {
        EPSHomeToolCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSHomeToolCell.cellIdentifier forIndexPath:indexPath];
        EPSHomeToolType toolType = ((NSNumber *)self.tools[indexPath.item]).integerValue;
        [cell setUpWithType:toolType];
        return cell;
    } else if (indexPath.section == BANNER_SECTION_INDEX) {
        EPSHomeBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSHomeBannerCell.cellIdentifier forIndexPath:indexPath];
        return cell;
    } else if (indexPath.section == LAST_CREATED_SECTION_INDEX) {
        EPSLastCreatedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSLastCreatedCell.cellIdentifier forIndexPath:indexPath];
        UIImage *image = self.lastCreatedImages[indexPath.item];
        [cell setImage:image];
        [cell setShouldShowOverlay:YES];
        return cell;
    } else if (indexPath.section == EDIT_SECTION_INDEX) {
        EPSHomeEditCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSHomeEditCell.cellIdentifier forIndexPath:indexPath];
        if (indexPath.item == 0) {
            [cell setImage:nil];
        } else {
            UIImage *image = self.latestPhotoPreviews[indexPath.item - 1];
            [cell setImage:image];
        }
        return cell;
    }
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == LAST_CREATED_SECTION_INDEX) {
            EPSHomeLabelSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EPSHomeLabelSectionHeaderView.reusableViewIdentifier forIndexPath:indexPath];
            [header setName:@"Recently Created" sectionIndex:LAST_CREATED_SECTION_INDEX];
            header.delegate = self;
            return header;
        } else if (indexPath.section == EDIT_SECTION_INDEX) {
            EPSHomeLabelSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EPSHomeLabelSectionHeaderView.reusableViewIdentifier forIndexPath:indexPath];
            [header setName:@"Edit Your Photos" sectionIndex:EDIT_SECTION_INDEX];
            header.delegate = self;
            return header;
        }
    }
    return nil;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == TOOL_SECTION_INDEX) {
        return self.tools.count;
    } else if (section == LAST_CREATED_SECTION_INDEX) {
        return self.lastCreatedImages.count;
    } else if (section == BANNER_SECTION_INDEX) {
        return 1;
    } else if (section == EDIT_SECTION_INDEX) {
        return self.latestPhotoPreviews.count + 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return EDIT_SECTION_INDEX + 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TOOL_SECTION_INDEX) {
        EPSHomeToolCell *cell = EPSDynamicCast([collectionView cellForItemAtIndexPath:indexPath], EPSHomeToolCell);
        if (cell) {
            switch (cell.toolType) {
                case EPSHomeToolTypeNone:
                    return;
                case EPSHomeToolTypeEdit:
                    [self _editToolButtonPressedWithImage:nil selectedToolType:EPSHomeToolTypeNone];
                    break;
                case EPSHomeToolTypeAniGAN:
                    [self _presentAniGANViewController];
                    break;
                case EPSHomeToolTypeSticker:
                case EPSHomeToolTypeText:
                case EPSHomeToolTypeFilter:
                    [self _editToolButtonPressedWithImage:nil selectedToolType:cell.toolType];
                    break;
            }
        }
    } else if (indexPath.section == BANNER_SECTION_INDEX) {
        
    } else if (indexPath.section == LAST_CREATED_SECTION_INDEX) {
        EPSLastCreatedCell *cell = EPSDynamicCast([collectionView cellForItemAtIndexPath:indexPath], EPSLastCreatedCell);
        if (cell) {
            UIImage *selectedImage = self.lastCreatedImages[indexPath.item];
            EPSAniGANResultViewController *vc = [[EPSAniGANResultViewController alloc] initWithOriginImage:selectedImage shouldGenerate:NO isStandAloneVC:YES];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:YES completion:nil];
        }
    } else if (indexPath.section == EDIT_SECTION_INDEX) {
        EPSHomeEditCell *cell = EPSDynamicCast([collectionView cellForItemAtIndexPath:indexPath], EPSHomeEditCell);
        if (cell) {
            [self _editToolButtonPressedWithImage:cell.cellImage selectedToolType:EPSHomeToolTypeNone];
        }
    }
}

- (void)headerView:(EPSHomeLabelSectionHeaderView *)headerView didSelectHeader:(BOOL)didSelect {
    if (headerView.sectionIndex == LAST_CREATED_SECTION_INDEX) {
        EPSHistoryViewController *vc = [[EPSHistoryViewController alloc] init];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        navVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navVC animated:YES completion:nil];
    } else if (headerView.sectionIndex == EDIT_SECTION_INDEX) {
        [self _editToolButtonPressedWithImage:nil selectedToolType:EPSHomeToolTypeNone];
    }
}

- (void)toolView:(nonnull EPSHomeToolCollectionView *)toolView didSelectTool:(EPSHomeToolType)toolType {

}

- (void)_fetchLatestPhoto {
    [TSHelper dispatchAsyncOnQueue:_actionQueue withName:_actionQueueName withTask:^{
        [self.latestPhotoPreviews removeAllObjects];
        [EPSPhotoManager getCameraRollAlbumWithAllowSelectImage:YES allowSelectVideo:NO completion:^(EPSAlbumListModel * _Nonnull cameraRoll) {
            NSArray *fetchResults = [EPSPhotoManager fetchPhotoIn:cameraRoll.result ascending:NO allowSelectImage:YES allowSelectVideo:NO limitCount:9];
            for (EPSPhotoModel *model in fetchResults) {
                [EPSPhotoManager fetchOriginalImageFor:model.asset progress:nil completion:^(UIImage * _Nullable image, BOOL isDegraded) {
                    if (image && !isDegraded && self.latestPhotoPreviews.count < 10) {
                        [self.latestPhotoPreviews addObject:image];
                    }
                    if (self.latestPhotoPreviews.count == 9) {
                        [TSHelper dispatchAsyncMainQueue:^{
                            [self.mainCollectionView reloadData];
                        }];
                    }
                }];
            }
        }];
    }];
}

- (void)_editToolButtonPressedWithImage:(UIImage *)selectImage selectedToolType:(EPSHomeToolType)homeToolType {
    if (selectImage) {
        [self _presentPhotoEditorWithImage:selectImage selectedToolType:homeToolType];
    } else {
        EPSPhotoConfiguration *config = [EPSPhotoConfiguration default];
        config.allowSelectVideo = NO;
        config.maxSelectCount = 1;
        config.allowSelectGif = NO;
        config.allowEditImage = NO;

        EPSPhotoPreviewSheet *sheetPicker = [[EPSPhotoPreviewSheet alloc] initWithConfiguration:config];
        sheetPicker.selectImageBlock = ^(NSArray<EPSResultModel *> * _Nonnull selectResults, BOOL isFullImage) {
            EPSResultModel *selectResult = selectResults.firstObject;
            UIImage *pickedImage = selectResult.image;
            [self _presentPhotoEditorWithImage:pickedImage selectedToolType:homeToolType];
        };
        [sheetPicker showPhotoLibraryWithSender:self];
    }
}

- (void)_presentPhotoEditorWithImage:(UIImage *)image selectedToolType:(EPSHomeToolType)homeToolType {
    EPSImageEditorViewController *editorVC = [[EPSImageEditorViewController alloc]
                                              initWithImage:image
                                              editModel:nil];
    editorVC.editFinishBlock = ^(UIImage * _Nonnull image, EPSEditImageModel * _Nullable model) {
        [[EPSDatabaseManager sharedInstance] saveImage:image withCreationTime:NSDate.now];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EPSDtaManagerDidUpdateDB" object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            EPSAniGANResultViewController *resultVC = [[EPSAniGANResultViewController alloc] initWithOriginImage:image shouldGenerate:NO isStandAloneVC:YES];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:resultVC];
            navVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navVC animated:YES completion:nil];
        });
    };
    editorVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:editorVC animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            switch (homeToolType) {
                case EPSHomeToolTypeNone:
                case EPSHomeToolTypeEdit:
                case EPSHomeToolTypeAniGAN:
                    break;
                case EPSHomeToolTypeSticker:
                    [editorVC selectToolAtIndex:2];
                    [editorVC imageStickerBtnClick];
                    break;
                case EPSHomeToolTypeText:
                    [editorVC selectToolAtIndex:3];
                    [editorVC textStickerBtnClick];
                    break;
                case EPSHomeToolTypeFilter:
                    [editorVC selectToolAtIndex:5];
                    [editorVC filterBtnClick];
                    break;
            }
        });
    }];
}

- (void)_presentAniGANViewController {
    EPSAniGANViewController *vc = [[EPSAniGANViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)dbDidUpdate {
    _lastCreatedImages = [[EPSDatabaseManager sharedInstance] loadImages];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainCollectionView reloadData];
    });
}
- (void)photoLibraryDidChange:(nonnull PHChange *)changeInstance { 
    [self _fetchLatestPhoto];
}

@end
