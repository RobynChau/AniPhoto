//
//  EPSHomeViewController.m
//  AniPhoto
//
//  Created by PhatCH on 02/01/2024.
//

#import "EPSHomeViewController.h"
#import "EPSPickerViewController.h"
#import "EPSSettingsViewController.h"
#import "EPSModelOptionCell.h"
#import "EPSHomeHeaderCell.h"
#import "EPSLastCreatedCell.h"
#import "EPSHomeLabelSectionHeaderView.h"

// Utilities
#import "Masonry.h"

#define BUTTON_WIDTH 180
#define INTER_SECTION_PADDING 15.0f
#define HEADER_SECTION_HEIGHT 320
#define MODEL_SECTION_HEADER_HEIGHT 50
#define MODEL_SECTION_HEADER_BOTTOM_PADDING 10
#define MODEL_SECTION_CONTENT_HEIGHT 280
#define MODEL_SECTION_INTER_ITEM_SPACING 16
#define MODEL_SECTION_CONTENT_LEADING_PADDING 10
#define CREATED_SECTION_CONTENT_HEIGHT 180

@interface EPSHomeViewController () <
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
>
@property (nonatomic, strong) UIImageView *headerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *sampleOutputs;

@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIButton *createButton;
@end

@implementation EPSHomeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;
        _sampleOutputs = @[@"output", @"output2", @"output3", @"output4", @"output5", @"output6", @"output7"];

        [self _setupView];
    }
    return self;
}

- (void)_setupView {
    [self _setupCollectionView];

    _settingButton = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"info.circle.fill"]
                                              target:self
                                              action:@selector(settingButtonPressed)];
    _settingButton.tintColor = UIColor.labelColor;
    [self.view addSubview:_settingButton];

    _createButton = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"wand.and.stars"]
                                             target:self
                                             action:@selector(createButtonPressed)];
    _createButton.tintColor = UIColor.labelColor;
    [self.view addSubview:_createButton];
}

- (void)_setupCollectionView {
    UICollectionViewCompositionalLayout *layout = [self createCollectionViewLayout];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;

    [_collectionView registerClass:EPSModelOptionCell.class
        forCellWithReuseIdentifier:EPSModelOptionCell.cellIdentifier];
    [_collectionView registerClass:EPSHomeHeaderCell.class 
        forCellWithReuseIdentifier:EPSHomeHeaderCell.cellIdentifier];
    [_collectionView registerClass:EPSLastCreatedCell.class
        forCellWithReuseIdentifier:EPSLastCreatedCell.cellIdentifier];
    [_collectionView registerClass:EPSHomeLabelSectionHeaderView.class
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:EPSHomeLabelSectionHeaderView.reusableViewIdentifier];

    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (UICollectionViewCompositionalLayout *)createCollectionViewLayout {
    UICollectionViewCompositionalLayout *layout =
    [[UICollectionViewCompositionalLayout alloc]
     initWithSectionProvider: ^NSCollectionLayoutSection * _Nullable(NSInteger section,
                                                                     id<NSCollectionLayoutEnvironment> _Nonnull layoutEnvironment) {
        if (section == 0) {
            return [self _headerSectionLayout];
        } else if (section == 1) {
            return [self _createdSectionLayout];
        } else {
            return [self _modelSectionLayout];
        }
    }];
    return layout;
}

- (NSCollectionLayoutSection *)_headerSectionLayout {
    NSCollectionLayoutItem *itemLayout =
    [NSCollectionLayoutItem
     itemWithLayoutSize:[NSCollectionLayoutSize
                         sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                         heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];

    NSCollectionLayoutGroup *groupLayout =
    [NSCollectionLayoutGroup
     horizontalGroupWithLayoutSize:[NSCollectionLayoutSize
                                    sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:HEADER_SECTION_HEIGHT]]
     subitem:itemLayout
     count:1];

    NSCollectionLayoutSection *sectionLayout = [NSCollectionLayoutSection sectionWithGroup:groupLayout];
    sectionLayout.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPagingCentered;
    sectionLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, INTER_SECTION_PADDING, 0);

    return sectionLayout;
}

- (NSCollectionLayoutSection *)_modelSectionLayout {
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
                                    heightDimension:[NSCollectionLayoutDimension absoluteDimension:MODEL_SECTION_CONTENT_HEIGHT + MODEL_SECTION_HEADER_HEIGHT]]
     subitem:itemLayout
     count:3];
    groupLayout.contentInsets = NSDirectionalEdgeInsetsMake(MODEL_SECTION_HEADER_HEIGHT + MODEL_SECTION_HEADER_BOTTOM_PADDING, 0, 0, 0);

    // Section
    NSCollectionLayoutSection *sectionLayout = [NSCollectionLayoutSection sectionWithGroup:groupLayout];
    sectionLayout.boundarySupplementaryItems = @[supplementaryLayout];
    sectionLayout.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuous;
    sectionLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, MODEL_SECTION_CONTENT_LEADING_PADDING, INTER_SECTION_PADDING, 0);

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
    sectionLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, MODEL_SECTION_CONTENT_LEADING_PADDING, INTER_SECTION_PADDING, 0);

    return sectionLayout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)updateViewConstraints {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).inset(-60);
    }];
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).inset(10);
            make.leading.mas_equalTo(self.view).inset(20);
            make.size.mas_equalTo(@44);
    }];
    [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).inset(10);
            make.trailing.mas_equalTo(self.view).inset(20);
            make.size.mas_equalTo(@44);
    }];
    [super updateViewConstraints];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        EPSHomeHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSHomeHeaderCell.cellIdentifier forIndexPath:indexPath];
        return cell;
    } else if (indexPath.section == 1) {
        EPSLastCreatedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSLastCreatedCell.cellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        EPSModelOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSModelOptionCell.cellIdentifier forIndexPath:indexPath];
        NSInteger index = indexPath.item + indexPath.section >= self.sampleOutputs.count ? indexPath.item + indexPath.section - self.sampleOutputs.count : indexPath.item + indexPath.section;
        [cell setCellImage:[UIImage imageNamed:self.sampleOutputs[index]]];
        cell.backgroundColor = UIColor.redColor;
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        EPSHomeLabelSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EPSHomeLabelSectionHeaderView.reusableViewIdentifier forIndexPath:indexPath];
        [header setSectionType:HomeModelSectionTypeExclusive sectionName:@"AI Photo"];
        return header;
    }
    return nil;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 5;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    EPSModelOptionCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    EPSPickerViewController *picker = [[EPSPickerViewController alloc] initWithImage:cell.imageView.image modelName:@"AniGAN" modelDes:@"It works best with vertical portrait photos of a person"];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:picker];
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)createButtonPressed {
    EPSPickerViewController *picker = [[EPSPickerViewController alloc]
                                       initWithImage:[UIImage imageNamed:@"output"]
                                       modelName:@"AniGAN"
                                       modelDes:@"It works best with vertical portrait photos of a person"];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:picker];
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)settingButtonPressed {
    EPSSettingsViewController *vc = [[EPSSettingsViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

@end
