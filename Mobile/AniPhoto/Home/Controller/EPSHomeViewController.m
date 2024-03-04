//
//  EPSHomeViewController.m
//  AniPhoto
//
//  Created by PhatCH on 02/01/2024.
//

#import "EPSHomeViewController.h"
#import "EPSModelOptionCell.h"
#import "EPSPickerViewController.h"
#import "EPSSettingsViewController.h"
#import "EPSHomePhotoSectionHeaderView.h"
#import "EPSHomeLabelSectionHeaderView.h"

#define BUTTON_WIDTH 180

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
    _settingButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_settingButton];

    _createButton = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"wand.and.stars"]
                                             target:self
                                             action:@selector(createButtonPressed)];
    _createButton.tintColor = UIColor.labelColor;
    _createButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_createButton];
}

- (void)_setupCollectionView {
    UICollectionViewCompositionalLayout *layout = [self createCollectionViewLayout];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView registerClass:EPSModelOptionCell.class forCellWithReuseIdentifier:EPSModelOptionCell.cellIdentifier];
    [_collectionView registerClass:EPSHomePhotoSectionHeaderView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:EPSHomePhotoSectionHeaderView.reusableViewIdentifier];
    [_collectionView registerClass:EPSHomeLabelSectionHeaderView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:EPSHomeLabelSectionHeaderView.reusableViewIdentifier];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (UICollectionViewCompositionalLayout *)createCollectionViewLayout {
    UICollectionViewCompositionalLayout *layout =
    [[UICollectionViewCompositionalLayout alloc]
     initWithSectionProvider:
         ^NSCollectionLayoutSection * _Nullable(NSInteger section,
                                                id<NSCollectionLayoutEnvironment> _Nonnull layoutEnvironment) {
        CGFloat headerHeight = 50;
        if (section == 0) {
            headerHeight += 300;
        }
        // Item
        NSCollectionLayoutItem *itemLayout =
        [NSCollectionLayoutItem
         itemWithLayoutSize:[NSCollectionLayoutSize
                             sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                             heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];
        itemLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 0, 8);

        NSCollectionLayoutBoundarySupplementaryItem *supplementaryLayout =
        [NSCollectionLayoutBoundarySupplementaryItem
         supplementaryItemWithLayoutSize:[NSCollectionLayoutSize
                                          sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
                                          heightDimension:[NSCollectionLayoutDimension absoluteDimension:headerHeight]]
         elementKind:UICollectionElementKindSectionHeader
         containerAnchor:[NSCollectionLayoutAnchor layoutAnchorWithEdges:NSDirectionalRectEdgeTop | NSDirectionalRectEdgeLeading]];
        // Group
        NSCollectionLayoutGroup *groupLayout =
        [NSCollectionLayoutGroup
         horizontalGroupWithLayoutSize:[NSCollectionLayoutSize
                                        sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.1]
                                        heightDimension:[NSCollectionLayoutDimension absoluteDimension:240 + headerHeight]]
         subitem:itemLayout
         count:3];
        groupLayout.contentInsets = NSDirectionalEdgeInsetsMake(headerHeight + 10, 0, 0, 0);

        // Section
        NSCollectionLayoutSection *sectionLayout = [NSCollectionLayoutSection sectionWithGroup:groupLayout];
        sectionLayout.boundarySupplementaryItems = @[supplementaryLayout];
        sectionLayout.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuous;
        sectionLayout.contentInsets = NSDirectionalEdgeInsetsMake(0, 0, 20, 0);

        return sectionLayout;
    }];
    return layout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)updateViewConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.settingButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:65],
        [self.settingButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.settingButton.heightAnchor constraintEqualToConstant:36],
        [self.settingButton.widthAnchor constraintEqualToConstant:36],

        [self.createButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:65],
        [self.createButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.createButton.heightAnchor constraintEqualToConstant:36],
        [self.createButton.widthAnchor constraintEqualToConstant:36],
    ]];
    [super updateViewConstraints];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EPSModelOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSModelOptionCell.cellIdentifier forIndexPath:indexPath];
    NSInteger index = indexPath.item + indexPath.section >= self.sampleOutputs.count ? indexPath.item + indexPath.section - self.sampleOutputs.count : indexPath.item + indexPath.section;
    [cell setCellImage:[UIImage imageNamed:self.sampleOutputs[index]]];
    cell.backgroundColor = UIColor.redColor;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 0) {
            EPSHomePhotoSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EPSHomePhotoSectionHeaderView.reusableViewIdentifier forIndexPath:indexPath];
            [header setSectionType:HomeModelSectionTypeExclusive sectionName:@"AI Photo"];
            return header;
        } else {
            EPSHomeLabelSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EPSHomeLabelSectionHeaderView.reusableViewIdentifier forIndexPath:indexPath];
            [header setSectionType:HomeModelSectionTypeExclusive sectionName:@"AI Photo"];
            return header;
        }
    }
    return nil;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
