//
//  EPSModelOptionSectionViewController.m
//  AniPhoto
//
//  Created by PhatCH on 16/4/24.
//

#import "EPSModelOptionSectionViewController.h"
#import "EPSModelOptionSectionLabel.h"
#import "EPSModelOptionCell.h"
#import "EPSModelOption.h"

@interface EPSModelOptionSectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

// Data
@property (nonatomic, assign) HomeModelSectionType sectionType;
@property (nonatomic, copy) NSString *sectionName;
@property (nonatomic, assign) BOOL isExclusive;
@property (nonatomic, strong) NSArray<EPSModelOption *> *modelOptions;

// UI
@property (nonatomic, strong) EPSModelOptionSectionLabel *sectionLabel;
@property (nonatomic, strong) UICollectionView *optionsCollectionView;
@end

@implementation EPSModelOptionSectionViewController

- (instancetype)initWithType:(HomeModelSectionType)sectionType
                 sectionName:(NSString *)sectionName
                 isExclusive:(BOOL)isExclusive
                modelOptions:(NSArray<EPSModelOption *> *)modelOptions {
    self = [super init];
    if (self) {
        _sectionType = sectionType;
        _sectionName = sectionName;
        _isExclusive = isExclusive;
        _modelOptions = modelOptions;
        
        [self _setupView];
    }
    return self;
}

- (void)_setupView {
    _sectionLabel = [[EPSModelOptionSectionLabel alloc] initWithType:_sectionType title:_sectionName];
    _sectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_sectionLabel];


    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _optionsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_optionsCollectionView registerClass:EPSModelOptionCell.class forCellWithReuseIdentifier:EPSModelOptionCell.cellIdentifier];
    _optionsCollectionView.showsHorizontalScrollIndicator = NO;
    _optionsCollectionView.delegate = self;
    _optionsCollectionView.dataSource = self;
    _optionsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_optionsCollectionView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(400, 500);
}

- (void)updateViewConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.sectionLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.sectionLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.sectionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.sectionLabel.heightAnchor constraintEqualToConstant:self.sectionLabel.calculatedSize.height],

        [self.optionsCollectionView.topAnchor constraintEqualToAnchor:self.sectionLabel.bottomAnchor],
        [self.optionsCollectionView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:10],
        [self.optionsCollectionView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.optionsCollectionView.heightAnchor constraintEqualToConstant:250],
    ]];
    [super updateViewConstraints];
}

- (__kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                           cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EPSModelOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPSModelOptionCell.cellIdentifier
                                                                         forIndexPath:indexPath];
    cell.backgroundColor = UIColor.greenColor;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 220);
}


@end
