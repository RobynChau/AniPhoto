//
//  ToolView.m
//  AniPhoto
//
//  Created by PhatCH on 20/12/2023.
//

#import "ToolView.h"
#import "ToolViewCell.h"

@interface ToolView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *toolView;

@end

@implementation ToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.systemBackgroundColor;

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(40, 70);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _toolView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
                                       collectionViewLayout:layout];
        _toolView.backgroundColor = UIColor.systemBackgroundColor;
        [_toolView registerClass:ToolViewCell.class forCellWithReuseIdentifier:@"Cell"];
        _toolView.delegate = self;
        _toolView.dataSource = self;
        [self addSubview:_toolView];
    }

    return self;
}


- (ToolViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ToolViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { 
    return 10;
}

@end
