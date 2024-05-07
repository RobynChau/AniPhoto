//
//  EPSHomeToolCollectionView.m
//  AniPhoto
//
//  Created by PhatCH on 19/5/24.
//

#import "EPSHomeToolCollectionView.h"
#import "EPSHomeToolCell.h"

#import "Masonry.h"

@interface EPSHomeToolCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, assign) BOOL shouldScroll;
@property (nonatomic, strong) UICollectionView *toolCollectionView;

@end

@implementation EPSHomeToolCollectionView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithShouldScroll:(BOOL)shouldScroll {
    self = [super init];
    if (self) {
        _shouldScroll = shouldScroll;

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (shouldScroll) {
            layout.itemSize = CGSizeMake(102, 135);
            layout.minimumInteritemSpacing = 10;
        } else {
            layout.itemSize = CGSizeMake(66, 90);
            layout.minimumInteritemSpacing = 1;
        }

        _toolCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _toolCollectionView.showsVerticalScrollIndicator = NO;
        _toolCollectionView.showsHorizontalScrollIndicator = NO;
        _toolCollectionView.tag = 0;

        _toolCollectionView.delegate = self;
        _toolCollectionView.dataSource = self;
        [_toolCollectionView registerClass:EPSHomeToolCell.class
                forCellWithReuseIdentifier:[EPSHomeToolCell cellIdentifier]];
        [self addSubview:_toolCollectionView];
    }
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    [self.toolCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(self);
    }];
    [super updateConstraints];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    EPSHomeToolCell *cell = [collectionView
                             dequeueReusableCellWithReuseIdentifier:EPSHomeToolCell.cellIdentifier
                             forIndexPath:indexPath];
    if (indexPath.item == 0) {
        [cell setUpWithType:EPSHomeToolTypeEdit];
    } else {
        [cell setUpWithType:EPSHomeToolTypeAniGAN];
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

@end
